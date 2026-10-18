/* ******************************************************************* */
/*                                                                     */
/*                         ATS/contrib/afiber                          */
/*                                                                     */
/* ******************************************************************* */

/*
** Copyright (C) 2026 Mikhail Sorochan
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following stated conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
*/

/* ****** ****** */

/*
** MS-2026-10:
** afiber: stackful cooperative fibers (green threads) with no GC.
** Each fiber owns an mmap'd C stack (with a guard page) and is
** switched by hand on x86-64 (ucontext elsewhere). The scheduler is
** one weak global shared by every unit. The stacks of finished
** fibers are recycled through a per-worker free list
** (ATSCNTRB_AFIBER_STACK_CACHE: 0 = unbounded, n = at most n cached
** stacks per worker); cached stacks are not returned to the OS
** (but see [afiber_workers_stop]).
**
** One worker (the main thread) is the default: cooperative, FIFO,
** deterministic. [afiber_workers_start(n)] adds n-1 pthreads that
** run fibers too (M:N scheduling). That needs the exception-frame
** head to be a field of the fiber (a fiber can resume on another
** thread inside a [try]): compile with -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_
** and this file supplies [my_atsexnframe_getref] and [atsruntime_raise].
** Otherwise the head of the exception-frame chain (setjmp/longjmp)
** is saved and restored per fiber at every switch, which is only
** right for one worker.
**
** A fiber that parks is not saved until the switch has happened, so
** it must not become visible to another worker before that: every
** hand-off is a "post action" stored in the worker and executed by
** the context that lands after the switch ([atscntrb_afiber__resumed]).
*/

/* ****** ****** */

#ifndef ATSCNTRB_AFIBER_CATS_AFIBER
#define ATSCNTRB_AFIBER_CATS_AFIBER

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <sched.h>
#include <pthread.h>
#include <sys/mman.h>

/* ****** ****** */

/*
** MS-2026-10:
** x86-64: a hand-written register switch (no signal-mask system call);
** elsewhere, or with -DATSCNTRB_AFIBER_UCONTEXT: ucontext.
*/
#if defined(__x86_64__) && !defined(ATSCNTRB_AFIBER_UCONTEXT)
#define ATSCNTRB_AFIBER_ASM 1
#else
#include <ucontext.h>
#endif

/* ****** ****** */

#if defined(__SANITIZE_ADDRESS__)
#define ATSCNTRB_AFIBER_ASAN 1
#elif defined(__has_feature)
#if __has_feature(address_sanitizer)
#define ATSCNTRB_AFIBER_ASAN 1
#endif
#endif

#if defined(__SANITIZE_THREAD__)
#define ATSCNTRB_AFIBER_TSAN 1
// the fiber interface of ThreadSanitizer (not all installs have the header)
void *__tsan_get_current_fiber(void) ;
void *__tsan_create_fiber(unsigned flags) ;
void __tsan_destroy_fiber(void *fiber) ;
void __tsan_switch_to_fiber(void *fiber, unsigned flags) ;
#endif

#ifdef ATSCNTRB_AFIBER_ASAN
#include <sanitizer/common_interface_defs.h>
#include <sanitizer/asan_interface.h>
#endif

/* ****** ****** */

/*
** MS-2026-10:
** ATSCNTRB_AFIBER_MN: the exception-frame head lives in the fiber
** record (this file defines the getter); then fibers can migrate.
** ATSCNTRB_AFIBER_SWAPHEAD: the runtime's global head is swapped at
** every switch (one worker only).
*/
#if defined(_ATS_CCOMP_RUNTIME_TRYWITH_NONE_) && !defined(_ATS_CCOMP_EXCEPTION_NONE_)
#define ATSCNTRB_AFIBER_MN 1
#endif
#if defined(_ATS_CCOMP_RUNTIME_TRYWITH_NONE_) || defined(_ATS_CCOMP_EXCEPTION_NONE_)
#define ATSCNTRB_AFIBER_CANMN 1
#endif
#if !defined(ATSCNTRB_AFIBER_CANMN)
#define ATSCNTRB_AFIBER_SWAPHEAD 1
#endif

#ifndef _ATS_CCOMP_EXCEPTION_NONE_
#define ATSCNTRB_AFIBER_EXNPTR atsexnframe_ptr
#else
#define ATSCNTRB_AFIBER_EXNPTR void*
#endif

/* ****** ****** */

#ifndef ATSCNTRB_AFIBER_STACKSZ
#define ATSCNTRB_AFIBER_STACKSZ (256*1024)
#endif

#ifndef ATSCNTRB_AFIBER_STACK_CACHE
#define ATSCNTRB_AFIBER_STACK_CACHE 0
#endif

// the stack of the idle context of worker 0
#define ATSCNTRB_AFIBER_IDLESZ (64*1024)
// the pthread stack of the other workers (they only run the idle loop)
#define ATSCNTRB_AFIBER_THRSZ (256*1024)

/* ****** ****** */

enum {
  ATSCNTRB_AFIBER_RUNNABLE = 0
, ATSCNTRB_AFIBER_RUNNING = 1
, ATSCNTRB_AFIBER_BLOCKED = 2
, ATSCNTRB_AFIBER_SLEEPING = 3
, ATSCNTRB_AFIBER_WAITALL = 4
, ATSCNTRB_AFIBER_DEAD = 5
} ;

// what the context that lands after a switch has to do
enum {
  ATSCNTRB_AFIBER_POST_NONE = 0
, ATSCNTRB_AFIBER_POST_UNLOCK = 1 // release the spinlock [post_arg] (park)
, ATSCNTRB_AFIBER_POST_YIELD = 2 // make the fiber [post_arg] runnable
, ATSCNTRB_AFIBER_POST_SLEEP = 3 // put the fiber [post_arg] on the sleep list
, ATSCNTRB_AFIBER_POST_DEAD = 4 // finish the dead fiber [post_arg]
} ;

/* ****** ****** */

typedef
struct atscntrb_afiber_s
{
#ifdef ATSCNTRB_AFIBER_ASM
  void *sp ; // the saved stack pointer while not running
#else
  ucontext_t ctx ;
#endif
  void *stack ; // the whole mmap'd region (guard page included); NULL for main
  size_t stacksz ;
  void *stack_lo ; // above the guard page
  size_t stack_usable ;
  ATSCNTRB_AFIBER_EXNPTR exnframe ; // the head of the exception-frame chain (ATSCNTRB_AFIBER_MN), else saved there while not running
  int state ;
  int detached ;
  void (*entry)(void*) ; // the ATS wrapper that runs and frees the closure
  void *env ;
  struct atscntrb_afiber_s *joiner ; // the fiber parked in [join] on this one
  struct atscntrb_afiber_s *next ; // the run queue, a wait queue or the sleep list
  unsigned long long deadline_ns ; // when SLEEPING
  void *asan_fake_stack ;
  void *tsan_fiber ; // ThreadSanitizer's handle of the fiber
  long id ;
  int lock ; // a spinlock: the join/detach/death hand-off (main: WAITALL)
} atscntrb_afiber_t ;

typedef
struct {
  atscntrb_afiber_t *head ;
  atscntrb_afiber_t *tail ;
} atscntrb_afiber_q ; // a FIFO; also the object behind [afiber_waitq]

typedef
struct atscntrb_afiber_worker_s
{
  int id ; // 0: the main thread
  atscntrb_afiber_t *current ; // the fiber (or the idle context) running on this thread
  atscntrb_afiber_t *prev ; // for the ASan [finish] call after a switch
  atscntrb_afiber_t idle ; // the idle context (workers > 1)
  int post_kind ;
  void *post_arg ;
  atscntrb_afiber_t *reap ; // one worker: a dead detached fiber whose stack is no longer in use
  void *stack_cache ; // free list of default-size stacks, linked through the word at stack_lo
  long ncached ;
  pthread_t thr ;
  pthread_mutex_t mu ; // the idle wait of this worker
  pthread_cond_t cv ;
  int waiting ; // 1 while the worker sleeps (or is about to) in the idle wait
} atscntrb_afiber_worker_t ;

typedef
struct {
  atscntrb_afiber_t main ; // the main thread's own context, id 0
  atscntrb_afiber_worker_t w0 ; // worker 0 (the main thread)
  atscntrb_afiber_worker_t *wk ; // workers 1..nworkers-1, when started
  int nworkers ;
  int lock ; // the sched lock: runq, sleepq, mainslot
  atscntrb_afiber_q runq ;
  atscntrb_afiber_t *sleepq ; // singly linked, ascending deadline
  atscntrb_afiber_t *mainslot ; // main, made runnable, for worker 0 (workers > 1)
  int nidle ; // workers in the idle wait
  int stop ;
  unsigned rr ; // round robin for the wake-ups
  long nlive ; // fibers not yet dead, main excluded
  long nextid ;
  int inited ;
} atscntrb_afiber_sched_t ;

/* ****** ****** */

// the state is read by other workers (join, is_done): atomic accesses
#define \
atscntrb_afiber__setstate(f, v) __atomic_store_n(&((f)->state), (v), __ATOMIC_RELAXED)
#define \
atscntrb_afiber__getstate(f) __atomic_load_n(&((f)->state), __ATOMIC_RELAXED)

/* ****** ****** */

/*
** One scheduler per process, shared by every compilation
** unit that includes this file (a weak definition in each)
*/
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak)) atscntrb_afiber_sched_t atscntrb_afiber__sched ;
// the worker of the calling thread (NULL: not a worker)
__attribute__((weak)) __thread atscntrb_afiber_worker_t *atscntrb_afiber__tls_worker ;
#else
static atscntrb_afiber_sched_t atscntrb_afiber__sched ; // per unit: documented limitation
static __thread atscntrb_afiber_worker_t *atscntrb_afiber__tls_worker ;
#endif

/*
** A fiber may resume on another thread after any switch, so the
** address of the __thread variable must not be kept across one: it
** is only read here, in a function that is never inlined, and the
** barrier keeps the compiler from reusing an earlier result.
*/
static
__attribute__((noinline))
atscntrb_afiber_worker_t*
atscntrb_afiber__tls_get()
{
  atscntrb_afiber_worker_t *w = atscntrb_afiber__tls_worker ;
  __asm__ volatile ("" ::: "memory") ;
  return w ;
} // end of [atscntrb_afiber__tls_get]

static
__attribute__((noinline))
void
atscntrb_afiber__tls_set
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber__tls_worker = w ;
  __asm__ volatile ("" ::: "memory") ;
} // end of [atscntrb_afiber__tls_set]

/* ****** ****** */

ATSinline()
void
atscntrb_afiber__fatal
  (const char *msg)
{
  fprintf(stderr, "afiber: %s\n", msg) ; abort() ;
} // end of [atscntrb_afiber__fatal]

/* ****** ****** */

ATSinline()
atscntrb_afiber_sched_t*
atscntrb_afiber__sched_get()
{
  atscntrb_afiber_sched_t *s = &atscntrb_afiber__sched ;
  if (__builtin_expect(!s->inited, 0)) {
    memset(s, 0, sizeof(*s)) ;
    atscntrb_afiber__setstate(&(s->main), ATSCNTRB_AFIBER_RUNNING) ;
    s->main.id = 0 ;
    s->w0.id = 0 ;
    s->w0.current = &(s->main) ;
    s->nworkers = 1 ;
    s->inited = 1 ;
    atscntrb_afiber__tls_set(&(s->w0)) ; // the thread that gets here first is worker 0
  }
  return s ;
} // end of [atscntrb_afiber__sched_get]

#if defined(__GNUC__) || defined(__clang__)
// so that the main thread is the one that initializes the scheduler
static
__attribute__((constructor))
void
atscntrb_afiber__init()
{
  (void)atscntrb_afiber__sched_get() ;
} // end of [atscntrb_afiber__init]
#endif

/*
** the worker of the calling thread; with one worker, the main one
*/
ATSinline()
atscntrb_afiber_worker_t*
atscntrb_afiber__cw()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  if (s->nworkers <= 1) return &(s->w0) ;
  {
    atscntrb_afiber_worker_t *w = atscntrb_afiber__tls_get() ;
    if (!w) atscntrb_afiber__fatal("this thread is not an afiber worker") ;
    return w ;
  }
} // end of [atscntrb_afiber__cw]

/* ****** ****** */

/*
** Spinlocks (test-and-test-and-set). With one worker nothing can be
** contended, and they cost a plain store.
*/
ATSinline()
int
atscntrb_afiber__mt()
{
  return atscntrb_afiber__sched.nworkers > 1 ;
} // end of [atscntrb_afiber__mt]

ATSinline()
void
atscntrb_afiber__spin_lock
  (int *p)
{
  unsigned n = 0 ;
  if (!atscntrb_afiber__mt()) { *p = 1 ; return ; }
  for ( ; ; ) {
    if (!__atomic_load_n(p, __ATOMIC_RELAXED)
        && !__atomic_exchange_n(p, 1, __ATOMIC_ACQUIRE)) return ;
    n += 1 ;
    if (n < 100) {
#if defined(__x86_64__) || defined(__i386__)
      __asm__ volatile ("pause" ::: "memory") ;
#endif
    } else {
      sched_yield() ;
    }
  }
} // end of [atscntrb_afiber__spin_lock]

ATSinline()
void
atscntrb_afiber__spin_unlock
  (int *p)
{
  if (!atscntrb_afiber__mt()) { *p = 0 ; return ; }
  __atomic_store_n(p, 0, __ATOMIC_RELEASE) ;
} // end of [atscntrb_afiber__spin_unlock]

/* ****** ****** */

ATSinline()
void
atscntrb_afiber__q_push
  (atscntrb_afiber_q *q, atscntrb_afiber_t *f)
{
  f->next = (atscntrb_afiber_t*)0 ;
  if (q->tail) q->tail->next = f ; else q->head = f ;
  q->tail = f ;
} // end of [atscntrb_afiber__q_push]

ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__q_pop
  (atscntrb_afiber_q *q)
{
  atscntrb_afiber_t *f = q->head ;
  if (f) {
    q->head = f->next ;
    if (!q->head) q->tail = (atscntrb_afiber_t*)0 ;
    f->next = (atscntrb_afiber_t*)0 ;
  }
  return f ;
} // end of [atscntrb_afiber__q_pop]

/* ****** ****** */

ATSinline()
unsigned long long
atscntrb_afiber_clock_ns()
{
  struct timespec ts ;
  clock_gettime(CLOCK_MONOTONIC, &ts) ;
  return (unsigned long long)ts.tv_sec * 1000000000ULL + (unsigned long long)ts.tv_nsec ;
} // end of [atscntrb_afiber_clock_ns]

ATSinline()
atstype_size
atscntrb_afiber_stacksz_default()
{
  return (atstype_size)ATSCNTRB_AFIBER_STACKSZ ;
} // end of [atscntrb_afiber_stacksz_default]

/* ****** ****** */

ATSinline()
size_t
atscntrb_afiber__stack_usable
  (size_t usable)
{
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  return usable ;
#else
  size_t page = (size_t)sysconf(_SC_PAGESIZE) ;
  usable = (usable + page - 1) / page * page ;
  if (usable < 2*page) usable = 2*page ;
  return usable ;
#endif
} // end of [atscntrb_afiber__stack_usable]

// the size of the whole region for a usable size (guard page included)
ATSinline()
size_t
atscntrb_afiber__stack_total
  (size_t usable)
{
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  return usable ;
#else
  return (size_t)sysconf(_SC_PAGESIZE) + usable ;
#endif
} // end of [atscntrb_afiber__stack_total]

ATSinline()
void
atscntrb_afiber__stack_alloc
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f, size_t usable)
{
  usable = atscntrb_afiber__stack_usable(usable) ;
  if (w->stack_cache
      && usable == atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ)) {
    void *lo = w->stack_cache ;
    w->stack_cache = *(void**)lo ;
    w->ncached -= 1 ;
    f->stack_lo = lo ;
    f->stack_usable = usable ;
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
    f->stack = lo ;
#else
    f->stack = (char*)lo - (size_t)sysconf(_SC_PAGESIZE) ;
#endif
    f->stacksz = atscntrb_afiber__stack_total(usable) ;
    return ;
  }
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  f->stack = ATS_MALLOC(usable) ;
  f->stacksz = usable ;
  f->stack_lo = f->stack ;
  f->stack_usable = usable ;
#else
  {
  size_t page = (size_t)sysconf(_SC_PAGESIZE) ;
  size_t total = page + usable ;
  int flags = MAP_PRIVATE | MAP_ANONYMOUS ;
  void *base ;
#ifdef MAP_NORESERVE
  flags |= MAP_NORESERVE ;
#endif
#ifdef MAP_STACK
  flags |= MAP_STACK ;
#endif
  base = mmap((void*)0, total, PROT_READ|PROT_WRITE, flags, -1, 0) ;
  if (base == MAP_FAILED) atscntrb_afiber__fatal("mmap for a fiber stack failed") ;
  if (mprotect(base, page, PROT_NONE) != 0) atscntrb_afiber__fatal("mprotect for a guard page failed") ;
  f->stack = base ;
  f->stacksz = total ;
  f->stack_lo = (char*)base + page ;
  f->stack_usable = usable ;
  }
#endif
} // end of [atscntrb_afiber__stack_alloc]

// give the stack back to the system
ATSinline()
void
atscntrb_afiber__stack_unmap
  (void *stack, size_t stacksz, void *lo, size_t usable)
{
#ifdef ATSCNTRB_AFIBER_ASAN
  __asan_unpoison_memory_region(lo, usable) ;
#endif
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  ATS_MFREE(stack) ;
#else
  munmap(stack, stacksz) ;
#endif
} // end of [atscntrb_afiber__stack_unmap]

// the stack of [f] goes to the cache of [w], or back to the system
ATSinline()
void
atscntrb_afiber__stack_release
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f)
{
  if (!f->stack) return ;
  if (f->stacksz == atscntrb_afiber__stack_total
        (atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ))
      && (ATSCNTRB_AFIBER_STACK_CACHE == 0 || w->ncached < (long)(ATSCNTRB_AFIBER_STACK_CACHE))) {
#ifdef ATSCNTRB_AFIBER_ASAN
    __asan_unpoison_memory_region(f->stack_lo, f->stack_usable) ;
#endif
    *(void**)f->stack_lo = w->stack_cache ;
    w->stack_cache = f->stack_lo ;
    w->ncached += 1 ;
  } else {
    atscntrb_afiber__stack_unmap(f->stack, f->stacksz, f->stack_lo, f->stack_usable) ;
  }
  f->stack = (void*)0 ;
} // end of [atscntrb_afiber__stack_release]

ATSinline()
void
atscntrb_afiber__free
  (atscntrb_afiber_t *f)
{
  atscntrb_afiber__stack_release(atscntrb_afiber__cw(), f) ;
#ifdef ATSCNTRB_AFIBER_TSAN
  if (f->tsan_fiber) __tsan_destroy_fiber(f->tsan_fiber) ;
#endif
  ATS_MFREE(f) ;
} // end of [atscntrb_afiber__free]

/* ****** ****** */
//
// waking idle workers
//
// A worker that finds nothing to run increments [nidle], and then looks
// at the queues once more; a producer pushes, and then looks at [nidle]
// (both sides with sequentially consistent ordering): one of the two
// sees the other, so a wake-up cannot be lost.
//
ATSinline()
int
atscntrb_afiber__signal_worker
  (atscntrb_afiber_worker_t *w)
{
  int r ;
  if (!__atomic_load_n(&(w->waiting), __ATOMIC_SEQ_CST)) return 0 ;
  pthread_mutex_lock(&(w->mu)) ;
  r = w->waiting ;
  if (r) { __atomic_store_n(&(w->waiting), 0, __ATOMIC_SEQ_CST) ; pthread_cond_signal(&(w->cv)) ; }
  pthread_mutex_unlock(&(w->mu)) ;
  return r ;
} // end of [atscntrb_afiber__signal_worker]

ATSinline()
atscntrb_afiber_worker_t*
atscntrb_afiber__worker_at
  (atscntrb_afiber_sched_t *s, int i)
{
  return (i == 0) ? &(s->w0) : &(s->wk[i-1]) ;
} // end of [atscntrb_afiber__worker_at]

// wake one idle worker; [only0]: only worker 0 can use the work (main)
ATSinline()
void
atscntrb_afiber__kick
  (atscntrb_afiber_sched_t *s, int only0)
{
  __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
  if (__atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) <= 0) return ;
  if (only0) { atscntrb_afiber__signal_worker(&(s->w0)) ; return ; }
  {
    int n = s->nworkers ;
    int i0 = (int)(__atomic_fetch_add(&(s->rr), 1, __ATOMIC_RELAXED) % (unsigned)n) ;
    int k ;
    for (k = 0; k < n; k += 1) {
      if (atscntrb_afiber__signal_worker(atscntrb_afiber__worker_at(s, (i0 + k) % n))) return ;
    }
  }
} // end of [atscntrb_afiber__kick]

// wake every idle worker (the earliest sleep deadline changed)
ATSinline()
void
atscntrb_afiber__kick_all
  (atscntrb_afiber_sched_t *s)
{
  int k ;
  __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
  if (__atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) <= 0) return ;
  for (k = 0; k < s->nworkers; k += 1) atscntrb_afiber__signal_worker(atscntrb_afiber__worker_at(s, k)) ;
} // end of [atscntrb_afiber__kick_all]

/* ****** ****** */

/*
** make [f] runnable. With workers, main goes to the main slot of
** worker 0; the other fibers go to the shared FIFO.
*/
static
__attribute__((noinline))
void
atscntrb_afiber__wake_mt
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_t *f)
{
  int tomain ;
  tomain = (f == &(s->main)) ;
  atscntrb_afiber__spin_lock(&(s->lock)) ;
  if (tomain) s->mainslot = f ; else atscntrb_afiber__q_push(&(s->runq), f) ;
  atscntrb_afiber__spin_unlock(&(s->lock)) ;
  atscntrb_afiber__kick(s, tomain) ;
} // end of [atscntrb_afiber__wake_mt]

// (the one worker case is the hot path of the one-worker scheduler)
ATSinline()
void
atscntrb_afiber__wake
  (atscntrb_afiber_t *f)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
  if (__builtin_expect(s->nworkers <= 1, 1)) { atscntrb_afiber__q_push(&(s->runq), f) ; return ; }
  atscntrb_afiber__wake_mt(s, f) ;
} // end of [atscntrb_afiber__wake]

// the sleep list is ascending in deadline; the caller holds the sched lock (workers > 1)
ATSinline()
void
atscntrb_afiber__sleep_insert
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_t *f)
{
  atscntrb_afiber_t **pp = &(s->sleepq) ;
  while (*pp && (*pp)->deadline_ns <= f->deadline_ns) pp = &((*pp)->next) ;
  f->next = *pp ; *pp = f ;
} // end of [atscntrb_afiber__sleep_insert]

/*
** the next fiber for worker [w], or NULL (expired sleepers are
** moved to the run queue first)
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__pick_slow
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  int mt = (s->nworkers > 1) ;
  int kickmain = 0, more = 0 ;
  atscntrb_afiber_t *next ;
  if (mt) atscntrb_afiber__spin_lock(&(s->lock)) ;
  if (s->sleepq) {
    unsigned long long now = atscntrb_afiber_clock_ns() ;
    while (s->sleepq && s->sleepq->deadline_ns <= now) {
      atscntrb_afiber_t *f = s->sleepq ; s->sleepq = f->next ;
      atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
      if (mt && f == &(s->main)) { s->mainslot = f ; kickmain = 1 ; }
      else atscntrb_afiber__q_push(&(s->runq), f) ;
    }
  }
  if (mt && w->id == 0 && s->mainslot) { next = s->mainslot ; s->mainslot = (atscntrb_afiber_t*)0 ; }
  else next = atscntrb_afiber__q_pop(&(s->runq)) ;
  if (mt) more = (s->runq.head != (atscntrb_afiber_t*)0) ;
  if (mt) atscntrb_afiber__spin_unlock(&(s->lock)) ;
  if (kickmain) atscntrb_afiber__kick(s, 1) ;
  if (more) atscntrb_afiber__kick(s, 0) ;
  return next ;
} // end of [atscntrb_afiber__pick_slow]

ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__pick
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  if (__builtin_expect(s->nworkers <= 1 && !s->sleepq, 1)) // one worker, nobody sleeps
    return atscntrb_afiber__q_pop(&(s->runq)) ;
  return atscntrb_afiber__pick_slow(w) ;
} // end of [atscntrb_afiber__pick]

/* ****** ****** */

/*
** finish a dead fiber, on the stack of whoever landed after the last
** switch of [f]: mark it DEAD, hand it to its joiner or free it if
** it is detached, count it out, wake main if it waits for all.
** With one worker this runs before the switch; the stack of a
** detached fiber is then freed later (reap).
*/
ATSinline()
void
atscntrb_afiber__finish_dead
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *j ;
  int det ;
  long left = __atomic_sub_fetch(&(s->nlive), 1, __ATOMIC_SEQ_CST) ;
  atscntrb_afiber__spin_lock(&(f->lock)) ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_DEAD) ;
  j = f->joiner ; f->joiner = (atscntrb_afiber_t*)0 ; det = f->detached ;
  atscntrb_afiber__spin_unlock(&(f->lock)) ;
  // [f] may be freed by the joiner from here on
  if (j) atscntrb_afiber__wake(j) ;
  else if (det) { if (s->nworkers <= 1) w->reap = f ; else atscntrb_afiber__free(f) ; }
  if (left == 0) {
    atscntrb_afiber__spin_lock(&(s->main.lock)) ;
    if (atscntrb_afiber__getstate(&(s->main)) == ATSCNTRB_AFIBER_WAITALL) atscntrb_afiber__wake(&(s->main)) ;
    atscntrb_afiber__spin_unlock(&(s->main.lock)) ;
  }
} // end of [atscntrb_afiber__finish_dead]

ATSinline()
void
atscntrb_afiber__run_post
  (atscntrb_afiber_worker_t *w)
{
  int k = w->post_kind ;
  void *a = w->post_arg ;
  if (k == ATSCNTRB_AFIBER_POST_NONE) return ;
  w->post_kind = ATSCNTRB_AFIBER_POST_NONE ;
  switch (k) {
  case ATSCNTRB_AFIBER_POST_UNLOCK:
    atscntrb_afiber__spin_unlock((int*)a) ; break ;
  case ATSCNTRB_AFIBER_POST_YIELD:
    atscntrb_afiber__wake((atscntrb_afiber_t*)a) ; break ;
  case ATSCNTRB_AFIBER_POST_SLEEP:
    {
      atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
      int newhead ;
      atscntrb_afiber__spin_lock(&(s->lock)) ;
      atscntrb_afiber__sleep_insert(s, (atscntrb_afiber_t*)a) ;
      newhead = (s->sleepq == (atscntrb_afiber_t*)a) ;
      atscntrb_afiber__spin_unlock(&(s->lock)) ;
      if (newhead) atscntrb_afiber__kick_all(s) ;
    }
    break ;
  case ATSCNTRB_AFIBER_POST_DEAD:
    atscntrb_afiber__finish_dead(w, (atscntrb_afiber_t*)a) ; break ;
  }
} // end of [atscntrb_afiber__run_post]

/* ****** ****** */

/*
** called right after a switch lands, in the context that lands
** ([asanfin]: not the first run of a worker thread, which was not
** entered by a switch). The worker is looked up again: the fiber
** may have come back on another thread.
*/
ATSinline()
void
atscntrb_afiber__resumed
  (int asanfin)
{
  atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
#ifdef ATSCNTRB_AFIBER_ASAN
  if (asanfin)
    __sanitizer_finish_switch_fiber
      (w->current->asan_fake_stack, (const void**)&(w->prev->stack_lo), &(w->prev->stack_usable)) ;
#endif
  if (w->reap) { atscntrb_afiber__free(w->reap) ; w->reap = (atscntrb_afiber_t*)0 ; }
  atscntrb_afiber__run_post(w) ;
} // end of [atscntrb_afiber__resumed]

#ifdef ATSCNTRB_AFIBER_ASM
/*
** saves the callee-saved registers and the fp control words on the
** current stack, stores rsp in *save_sp, loads new_sp and undoes it
*/
static
__attribute__((naked, noinline, used))
void
atscntrb_afiber__swap
  (void **save_sp, void *new_sp)
{
  __asm__ volatile (
    "pushq %rbp\n\t"
    "pushq %rbx\n\t"
    "pushq %r12\n\t"
    "pushq %r13\n\t"
    "pushq %r14\n\t"
    "pushq %r15\n\t"
    "subq $8, %rsp\n\t"
    "stmxcsr (%rsp)\n\t"
    "fnstcw 4(%rsp)\n\t"
    "movq %rsp, (%rdi)\n\t"
    "movq %rsi, %rsp\n\t"
    "ldmxcsr (%rsp)\n\t"
    "fldcw 4(%rsp)\n\t"
    "addq $8, %rsp\n\t"
    "popq %r15\n\t"
    "popq %r14\n\t"
    "popq %r13\n\t"
    "popq %r12\n\t"
    "popq %rbx\n\t"
    "popq %rbp\n\t"
    "ret\n\t"
  ) ;
} // end of [atscntrb_afiber__swap]
#endif // ifdef ATSCNTRB_AFIBER_ASM

/*
** switch from the fiber running on [w] to [next]; the post action of
** [w] is already set. It returns when something switches back to
** the fiber, maybe on another thread: nothing may be cached across it.
*/
ATSinline()
void
atscntrb_afiber__switch_to
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *next)
{
  atscntrb_afiber_t *from = w->current ;
#ifdef ATSCNTRB_AFIBER_ASAN
  int final = (atscntrb_afiber__getstate(from) == ATSCNTRB_AFIBER_DEAD || w->post_kind == ATSCNTRB_AFIBER_POST_DEAD) ;
#endif
  w->prev = from ;
  w->current = next ;
  atscntrb_afiber__setstate(next, ATSCNTRB_AFIBER_RUNNING) ;
#ifdef ATSCNTRB_AFIBER_SWAPHEAD
  {
    atsexnframe_ptr *hp = my_atsexnframe_getref() ;
    from->exnframe = (*hp) ;
    *hp = next->exnframe ;
  }
#endif
#ifdef ATSCNTRB_AFIBER_TSAN
  if (!from->tsan_fiber) from->tsan_fiber = __tsan_get_current_fiber() ; // a native context
  if (!next->tsan_fiber) atscntrb_afiber__fatal("tsan: no fiber to switch to") ;
  __tsan_switch_to_fiber(next->tsan_fiber, 0) ;
#endif
#ifdef ATSCNTRB_AFIBER_ASAN
  __sanitizer_start_switch_fiber
    (final ? (void**)0 : &(from->asan_fake_stack), next->stack_lo, next->stack_usable) ;
#endif
#ifdef ATSCNTRB_AFIBER_ASM
  atscntrb_afiber__swap(&(from->sp), next->sp) ;
#else
  if (swapcontext(&(from->ctx), &(next->ctx)) != 0) atscntrb_afiber__fatal("swapcontext failed") ;
#endif
  atscntrb_afiber__resumed(1) ;
} // end of [atscntrb_afiber__switch_to]

/* ****** ****** */

/*
** the caller has already re-queued, parked or killed the current
** fiber (or stored the post action that does it)
*/
ATSinline()
void
atscntrb_afiber__schedule()
{
  for ( ; ; ) {
    atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
    atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
    atscntrb_afiber_t *next = atscntrb_afiber__pick(w) ;
    if (next) {
      if (next == w->current) { // no switch: run the post action here
        atscntrb_afiber__setstate(next, ATSCNTRB_AFIBER_RUNNING) ; atscntrb_afiber__run_post(w) ; return ;
      }
      atscntrb_afiber__switch_to(w, next) ; return ;
    }
    if (s->nworkers > 1) { // nothing to run: park on the idle context
      atscntrb_afiber__switch_to(w, &(w->idle)) ; return ;
    }
    if (s->sleepq) {
      unsigned long long now = atscntrb_afiber_clock_ns() ;
      unsigned long long dl = s->sleepq->deadline_ns ;
      if (dl > now) {
        struct timespec ts ;
        ts.tv_sec = (time_t)((dl - now) / 1000000000ULL) ;
        ts.tv_nsec = (long)((dl - now) % 1000000000ULL) ;
        nanosleep(&ts, (struct timespec*)0) ;
      }
      continue ;
    }
    atscntrb_afiber__fatal("deadlock: every fiber is blocked") ;
  }
} // end of [atscntrb_afiber__schedule]

/* ****** ****** */

/*
** the idle loop of a worker, on its idle context: run what there
** is, else wait on the condition variable of the worker (until the
** earliest sleep deadline, if there is one). All workers idle with
** nothing queued and nobody sleeping is a deadlock.
*/
ATSinline()
void
atscntrb_afiber__idle_loop()
{
  for ( ; ; ) {
    atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
    atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
    atscntrb_afiber_t *next ;
    int has, anyq, hasleep, stop ;
    unsigned long long dl = 0 ;
    if (w->id != 0 && __atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE)) return ;
    next = atscntrb_afiber__pick(w) ;
    if (next) { atscntrb_afiber__switch_to(w, next) ; continue ; }
    pthread_mutex_lock(&(w->mu)) ;
    __atomic_store_n(&(w->waiting), 1, __ATOMIC_SEQ_CST) ;
    __atomic_add_fetch(&(s->nidle), 1, __ATOMIC_SEQ_CST) ;
    __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
    atscntrb_afiber__spin_lock(&(s->lock)) ;
    anyq = (s->runq.head != (atscntrb_afiber_t*)0) || (s->mainslot != (atscntrb_afiber_t*)0) ;
    has = (s->runq.head != (atscntrb_afiber_t*)0) || (w->id == 0 && s->mainslot != (atscntrb_afiber_t*)0) ;
    hasleep = (s->sleepq != (atscntrb_afiber_t*)0) ;
    if (hasleep) dl = s->sleepq->deadline_ns ;
    atscntrb_afiber__spin_unlock(&(s->lock)) ;
    stop = __atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE) ;
    if (!has && !stop) {
      if (!anyq && !hasleep
          && __atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) == s->nworkers)
        atscntrb_afiber__fatal("deadlock: every fiber is blocked") ;
      while (__atomic_load_n(&(w->waiting), __ATOMIC_SEQ_CST)
             && !__atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE)) {
        if (hasleep) {
          struct timespec ts ;
          ts.tv_sec = (time_t)(dl / 1000000000ULL) ;
          ts.tv_nsec = (long)(dl % 1000000000ULL) ;
          if (pthread_cond_timedwait(&(w->cv), &(w->mu), &ts) == ETIMEDOUT) break ;
        } else {
          pthread_cond_wait(&(w->cv), &(w->mu)) ;
        }
      }
    }
    __atomic_store_n(&(w->waiting), 0, __ATOMIC_SEQ_CST) ;
    __atomic_sub_fetch(&(s->nidle), 1, __ATOMIC_SEQ_CST) ;
    pthread_mutex_unlock(&(w->mu)) ;
  }
} // end of [atscntrb_afiber__idle_loop]

/* ****** ****** */

ATSinline()
void
atscntrb_afiber__make_context
  (atscntrb_afiber_t *f, void (*fn)(void))
{
#ifdef ATSCNTRB_AFIBER_ASM
  {
    uintptr_t top = ((uintptr_t)f->stack_lo + f->stack_usable) & ~(uintptr_t)15 ;
    uint64_t *p = (uint64_t*)top ;
    unsigned int mxcsr ; unsigned short fcw ;
    __asm__ volatile ("stmxcsr %0" : "=m"(mxcsr)) ;
    __asm__ volatile ("fnstcw %0" : "=m"(fcw)) ;
    p[-1] = 0 ; // null return address: backtraces end here
    p[-2] = (uint64_t)(uintptr_t)fn ;
    p[-3] = 0 ; p[-4] = 0 ; p[-5] = 0 ; p[-6] = 0 ; p[-7] = 0 ; p[-8] = 0 ; // rbp rbx r12-r15
    p[-9] = ((uint64_t)fcw << 32) | (uint64_t)mxcsr ; // mxcsr at +0, fcw at +4
    f->sp = (void*)(top - 72) ;
  }
#else
  if (getcontext(&(f->ctx)) != 0) atscntrb_afiber__fatal("getcontext failed") ;
  f->ctx.uc_stack.ss_sp = f->stack_lo ;
  f->ctx.uc_stack.ss_size = f->stack_usable ;
  f->ctx.uc_link = (ucontext_t*)0 ;
  makecontext(&(f->ctx), fn, 0) ;
#endif
} // end of [atscntrb_afiber__make_context]

/* ****** ****** */

// where the idle context of worker 0 starts
static
void
atscntrb_afiber__idle_entry()
{
  atscntrb_afiber__resumed(1) ;
  atscntrb_afiber__idle_loop() ;
  atscntrb_afiber__fatal("an idle loop returned") ;
} // end of [atscntrb_afiber__idle_entry]

// where a fiber starts
static
void
atscntrb_afiber__trampoline()
{
  atscntrb_afiber_worker_t *w ;
  atscntrb_afiber_t *f ;
  atscntrb_afiber__resumed(1) ;
  w = atscntrb_afiber__cw() ;
  f = w->current ;
  f->entry(f->env) ;
  // the fiber may be on another thread now
  w = atscntrb_afiber__cw() ;
  f = w->current ;
  if (atscntrb_afiber__sched.nworkers <= 1) {
    atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_DEAD) ;
    atscntrb_afiber__finish_dead(w, f) ;
  } else {
    w->post_kind = ATSCNTRB_AFIBER_POST_DEAD ;
    w->post_arg = f ;
  }
  atscntrb_afiber__schedule() ;
  atscntrb_afiber__fatal("a dead fiber was resumed") ;
} // end of [atscntrb_afiber__trampoline]

/* ****** ****** */

ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__create
(
  void (*entry)(void*), void *env, size_t stacksz, int detached
) {
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *f = ATS_MALLOC(sizeof(atscntrb_afiber_t)) ;
  memset(f, 0, sizeof(atscntrb_afiber_t)) ;
  atscntrb_afiber__stack_alloc(atscntrb_afiber__cw(), f, stacksz) ;
  atscntrb_afiber__make_context(f, atscntrb_afiber__trampoline) ;
#ifdef ATSCNTRB_AFIBER_TSAN
  f->tsan_fiber = __tsan_create_fiber(0) ;
#endif
  f->entry = entry ;
  f->env = env ;
  f->detached = detached ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
  f->id = __atomic_add_fetch(&(s->nextid), 1, __ATOMIC_SEQ_CST) ;
  __atomic_add_fetch(&(s->nlive), 1, __ATOMIC_SEQ_CST) ;
  atscntrb_afiber__wake(f) ;
  return f ;
} // end of [atscntrb_afiber__create]

/* ****** ****** */

#define \
atscntrb_afiber_create_funenv(fwork, env, sz) \
  ((atstype_ptr)atscntrb_afiber__create((void(*)(void*))(fwork), (void*)(env), (size_t)(sz), 0))
#define \
atscntrb_afiber_create_funenv_detached(fwork, env, sz) \
  ((void)atscntrb_afiber__create((void(*)(void*))(fwork), (void*)(env), (size_t)(sz), 1))

/* ****** ****** */

ATSinline()
void
atscntrb_afiber_yield()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
  if (s->nworkers <= 1) { // queue the fiber first: exact FIFO order
    atscntrb_afiber__wake(w->current) ;
    atscntrb_afiber__schedule() ;
  } else {
    atscntrb_afiber_t *next = atscntrb_afiber__pick(w) ;
    if (!next) return ;
    w->post_kind = ATSCNTRB_AFIBER_POST_YIELD ;
    w->post_arg = w->current ;
    atscntrb_afiber__switch_to(w, next) ;
  }
} // end of [atscntrb_afiber_yield]

ATSinline()
void
atscntrb_afiber_join
  (atstype_ptr fb)
{
  atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
  atscntrb_afiber_t *f = (atscntrb_afiber_t*)fb ;
  if (f == w->current) atscntrb_afiber__fatal("a fiber cannot join itself") ;
  atscntrb_afiber__spin_lock(&(f->lock)) ;
  if (atscntrb_afiber__getstate(f) != ATSCNTRB_AFIBER_DEAD) {
    if (f->joiner) atscntrb_afiber__fatal("a fiber is joined twice") ;
    f->joiner = w->current ;
    atscntrb_afiber__setstate(w->current, ATSCNTRB_AFIBER_BLOCKED) ;
    w->post_kind = ATSCNTRB_AFIBER_POST_UNLOCK ;
    w->post_arg = &(f->lock) ;
    atscntrb_afiber__schedule() ;
  } else {
    atscntrb_afiber__spin_unlock(&(f->lock)) ;
  }
  atscntrb_afiber__free(f) ;
} // end of [atscntrb_afiber_join]

ATSinline()
void
atscntrb_afiber_detach
  (atstype_ptr fb)
{
  atscntrb_afiber_t *f = (atscntrb_afiber_t*)fb ;
  atscntrb_afiber__spin_lock(&(f->lock)) ;
  if (atscntrb_afiber__getstate(f) == ATSCNTRB_AFIBER_DEAD) {
    atscntrb_afiber__spin_unlock(&(f->lock)) ;
    atscntrb_afiber__free(f) ;
  } else {
    f->detached = 1 ;
    atscntrb_afiber__spin_unlock(&(f->lock)) ;
  }
} // end of [atscntrb_afiber_detach]

ATSinline()
atstype_lint
atscntrb_afiber_get_id
  (atstype_ptr fb)
{
  return (atstype_lint)(((atscntrb_afiber_t*)fb)->id) ;
} // end of [atscntrb_afiber_get_id]

ATSinline()
atstype_bool
atscntrb_afiber_is_done
  (atstype_ptr fb)
{
  return (atscntrb_afiber__getstate((atscntrb_afiber_t*)fb) == ATSCNTRB_AFIBER_DEAD) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiber_is_done]

ATSinline()
atstype_lint
atscntrb_afiber_self()
{
  return (atstype_lint)(atscntrb_afiber__cw()->current->id) ;
} // end of [atscntrb_afiber_self]

ATSinline()
atstype_bool
atscntrb_afiber_is_main()
{
  return (atscntrb_afiber__cw()->current == &(atscntrb_afiber__sched_get()->main)) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiber_is_main]

ATSinline()
atstype_lint
atscntrb_afiber_nlive()
{
  return (atstype_lint)__atomic_load_n(&(atscntrb_afiber__sched_get()->nlive), __ATOMIC_SEQ_CST) ;
} // end of [atscntrb_afiber_nlive]

ATSinline()
void
atscntrb_afiber_run_until_done()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  for ( ; ; ) {
    atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
    if (w->current != &(s->main)) atscntrb_afiber__fatal("afiber_run_until_done: not the main fiber") ;
    atscntrb_afiber__spin_lock(&(s->main.lock)) ;
    if (__atomic_load_n(&(s->nlive), __ATOMIC_SEQ_CST) == 0) {
      atscntrb_afiber__spin_unlock(&(s->main.lock)) ;
      return ;
    }
    atscntrb_afiber__setstate(&(s->main), ATSCNTRB_AFIBER_WAITALL) ;
    w->post_kind = ATSCNTRB_AFIBER_POST_UNLOCK ;
    w->post_arg = &(s->main.lock) ;
    atscntrb_afiber__schedule() ;
  }
} // end of [atscntrb_afiber_run_until_done]

ATSinline()
void
atscntrb_afiber_sleep_ns
  (unsigned long long ns)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
  atscntrb_afiber_t *f = w->current ;
  if (ns == 0) { atscntrb_afiber_yield() ; return ; }
  f->deadline_ns = atscntrb_afiber_clock_ns() + ns ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_SLEEPING) ;
  if (s->nworkers <= 1) {
    atscntrb_afiber__sleep_insert(s, f) ;
  } else { // the fiber joins the sleep list once it has switched off its stack
    w->post_kind = ATSCNTRB_AFIBER_POST_SLEEP ;
    w->post_arg = f ;
  }
  atscntrb_afiber__schedule() ;
} // end of [atscntrb_afiber_sleep_ns]

/* ****** ****** */

/*
** M:N: [n] counts the main thread. Main only, once, with no lock held.
*/
static
void*
atscntrb_afiber__thread_main
  (void *arg)
{
  atscntrb_afiber_worker_t *w = (atscntrb_afiber_worker_t*)arg ;
  atscntrb_afiber__tls_set(w) ;
  atscntrb_afiber__resumed(0) ;
  atscntrb_afiber__idle_loop() ;
  return (void*)0 ;
} // end of [atscntrb_afiber__thread_main]

ATSinline()
void
atscntrb_afiber__worker_init
  (atscntrb_afiber_worker_t *w, int id)
{
  pthread_condattr_t ca ;
  w->id = id ;
  w->idle.id = -1 - (long)id ;
  atscntrb_afiber__setstate(&(w->idle), ATSCNTRB_AFIBER_RUNNING) ;
  pthread_mutex_init(&(w->mu), (const pthread_mutexattr_t*)0) ;
  pthread_condattr_init(&ca) ;
  pthread_condattr_setclock(&ca, CLOCK_MONOTONIC) ;
  pthread_cond_init(&(w->cv), &ca) ;
  pthread_condattr_destroy(&ca) ;
  w->waiting = 0 ;
} // end of [atscntrb_afiber__worker_init]

ATSinline()
void
atscntrb_afiber_workers_start
  (atstype_int n)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  int i ;
  pthread_attr_t attr ;
  if (n < 1) atscntrb_afiber__fatal("afiber_workers_start: n < 1") ;
  if (n == 1) return ;
#ifndef ATSCNTRB_AFIBER_CANMN
  atscntrb_afiber__fatal("afiber_workers_start(n > 1): compile with -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ (and -pthread)") ;
#endif
  if (s->nworkers > 1) atscntrb_afiber__fatal("afiber_workers_start: the workers are already started") ;
  if (atscntrb_afiber__tls_get() != &(s->w0) || s->w0.current != &(s->main))
    atscntrb_afiber__fatal("afiber_workers_start: main only") ;
  s->wk = ATS_MALLOC((size_t)(n-1) * sizeof(atscntrb_afiber_worker_t)) ;
  memset(s->wk, 0, (size_t)(n-1) * sizeof(atscntrb_afiber_worker_t)) ;
  atscntrb_afiber__worker_init(&(s->w0), 0) ;
  // the idle context of worker 0: a small stack, entered by a switch
  atscntrb_afiber__stack_alloc(&(s->w0), &(s->w0.idle), (size_t)ATSCNTRB_AFIBER_IDLESZ) ;
  atscntrb_afiber__make_context(&(s->w0.idle), atscntrb_afiber__idle_entry) ;
#ifdef ATSCNTRB_AFIBER_TSAN
  s->w0.idle.tsan_fiber = __tsan_create_fiber(0) ;
#endif
  for (i = 1; i < n; i += 1) {
    atscntrb_afiber__worker_init(&(s->wk[i-1]), i) ;
    s->wk[i-1].current = &(s->wk[i-1].idle) ;
  }
  s->stop = 0 ; s->nidle = 0 ;
  __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
  s->nworkers = n ;
  pthread_attr_init(&attr) ;
  pthread_attr_setstacksize(&attr, (size_t)ATSCNTRB_AFIBER_THRSZ < (size_t)PTHREAD_STACK_MIN ? (size_t)PTHREAD_STACK_MIN : (size_t)ATSCNTRB_AFIBER_THRSZ) ;
  for (i = 1; i < n; i += 1) {
    if (pthread_create(&(s->wk[i-1].thr), &attr, atscntrb_afiber__thread_main, &(s->wk[i-1])) != 0)
      atscntrb_afiber__fatal("pthread_create failed") ;
  }
  pthread_attr_destroy(&attr) ;
} // end of [atscntrb_afiber_workers_start]

// the stacks cached by a worker go back to the system
ATSinline()
void
atscntrb_afiber__cache_drain
  (atscntrb_afiber_worker_t *w)
{
  while (w->stack_cache) {
    void *lo = w->stack_cache ;
    size_t usable = atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ) ;
    w->stack_cache = *(void**)lo ;
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
    atscntrb_afiber__stack_unmap(lo, usable, lo, usable) ;
#else
    atscntrb_afiber__stack_unmap
      ((char*)lo - (size_t)sysconf(_SC_PAGESIZE), atscntrb_afiber__stack_total(usable), lo, usable) ;
#endif
  }
  w->ncached = 0 ;
} // end of [atscntrb_afiber__cache_drain]

/*
** Main only, with no live fiber (after [afiber_run_until_done]): stop
** and join the worker threads, and free what the workers own.
*/
ATSinline()
void
atscntrb_afiber_workers_stop()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  int i, n = s->nworkers ;
  if (n <= 1) return ;
  if (atscntrb_afiber__tls_get() != &(s->w0) || s->w0.current != &(s->main))
    atscntrb_afiber__fatal("afiber_workers_stop: main only") ;
  if (__atomic_load_n(&(s->nlive), __ATOMIC_SEQ_CST) != 0)
    atscntrb_afiber__fatal("afiber_workers_stop: fibers are still alive") ;
  __atomic_store_n(&(s->stop), 1, __ATOMIC_SEQ_CST) ;
  for (i = 1; i < n; i += 1) {
    atscntrb_afiber_worker_t *w = &(s->wk[i-1]) ;
    pthread_mutex_lock(&(w->mu)) ;
    __atomic_store_n(&(w->waiting), 0, __ATOMIC_SEQ_CST) ;
    pthread_cond_signal(&(w->cv)) ;
    pthread_mutex_unlock(&(w->mu)) ;
  }
  for (i = 1; i < n; i += 1) pthread_join(s->wk[i-1].thr, (void**)0) ;
  for (i = 0; i < n; i += 1) {
    atscntrb_afiber_worker_t *w = atscntrb_afiber__worker_at(s, i) ;
    atscntrb_afiber__cache_drain(w) ;
    pthread_cond_destroy(&(w->cv)) ;
    pthread_mutex_destroy(&(w->mu)) ;
  }
  atscntrb_afiber__stack_unmap(s->w0.idle.stack, s->w0.idle.stacksz, s->w0.idle.stack_lo, s->w0.idle.stack_usable) ;
#ifdef ATSCNTRB_AFIBER_TSAN
  __tsan_destroy_fiber(s->w0.idle.tsan_fiber) ;
#endif
  memset(&(s->w0.idle), 0, sizeof(s->w0.idle)) ;
  ATS_MFREE(s->wk) ; s->wk = (atscntrb_afiber_worker_t*)0 ;
  s->mainslot = (atscntrb_afiber_t*)0 ;
  s->nidle = 0 ; s->stop = 0 ;
  s->nworkers = 1 ;
} // end of [atscntrb_afiber_workers_stop]

ATSinline()
atstype_int
atscntrb_afiber_nworkers()
{
  return (atstype_int)(atscntrb_afiber__sched_get()->nworkers) ;
} // end of [atscntrb_afiber_nworkers]

// 0 on the main thread; -1 on a thread that is not a worker
ATSinline()
atstype_int
atscntrb_afiber_worker_id()
{
  atscntrb_afiber_worker_t *w = atscntrb_afiber__tls_get() ;
  atscntrb_afiber__sched_get() ;
  return w ? (atstype_int)(w->id) : (atstype_int)(-1) ;
} // end of [atscntrb_afiber_worker_id]

ATSinline()
atstype_int
atscntrb_afiber_ncpu()
{
#ifdef CPU_COUNT
  cpu_set_t cs ;
  if (sched_getaffinity(0, sizeof(cs), &cs) == 0) return (atstype_int)CPU_COUNT(&cs) ;
#endif
  { long n = sysconf(_SC_NPROCESSORS_ONLN) ; return (atstype_int)(n < 1 ? 1 : n) ; }
} // end of [atscntrb_afiber_ncpu]

/* ****** ****** */

/*
** spinlocks for the user (a protected object is a queue, a channel...):
** never yield or park while holding one, except through [waitq_park]
*/
ATSinline()
atstype_ptr
atscntrb_afiber_spin_make()
{
  int *p = ATS_MALLOC(sizeof(int)) ;
  *p = 0 ;
  return (atstype_ptr)p ;
} // end of [atscntrb_afiber_spin_make]

ATSinline()
void
atscntrb_afiber_spin_free
  (atstype_ptr l)
{
  if (*(int*)l) atscntrb_afiber__fatal("afiber_spin_free: the lock is held") ;
  ATS_MFREE(l) ;
} // end of [atscntrb_afiber_spin_free]

ATSinline()
void
atscntrb_afiber_spin_lock
  (atstype_ptr l)
{
  atscntrb_afiber__spin_lock((int*)l) ;
} // end of [atscntrb_afiber_spin_lock]

ATSinline()
void
atscntrb_afiber_spin_unlock
  (atstype_ptr l)
{
  atscntrb_afiber__spin_unlock((int*)l) ;
} // end of [atscntrb_afiber_spin_unlock]

/* ****** ****** */

ATSinline()
atstype_ptr
atscntrb_afiber_waitq_make()
{
  atscntrb_afiber_q *q = ATS_MALLOC(sizeof(atscntrb_afiber_q)) ;
  q->head = (atscntrb_afiber_t*)0 ; q->tail = (atscntrb_afiber_t*)0 ;
  return (atstype_ptr)q ;
} // end of [atscntrb_afiber_waitq_make]

ATSinline()
void
atscntrb_afiber_waitq_free
  (atstype_ptr q0)
{
  atscntrb_afiber_q *q = (atscntrb_afiber_q*)q0 ;
  if (q->head) atscntrb_afiber__fatal("afiber_waitq_free: a fiber is still parked") ;
  ATS_MFREE(q) ;
} // end of [atscntrb_afiber_waitq_free]

ATSinline()
atstype_bool
atscntrb_afiber_waitq_is_empty
  (atstype_ptr q0)
{
  return (((atscntrb_afiber_q*)q0)->head == (atscntrb_afiber_t*)0) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiber_waitq_is_empty]

/*
** the caller holds [lk]: the fiber is queued, and [lk] is released only
** once the fiber has switched off its stack; it is taken again before
** the return (condition variable style)
*/
ATSinline()
void
atscntrb_afiber_waitq_park
  (atstype_ptr q0, atstype_ptr lk)
{
  atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
  atscntrb_afiber__setstate(w->current, ATSCNTRB_AFIBER_BLOCKED) ;
  atscntrb_afiber__q_push((atscntrb_afiber_q*)q0, w->current) ;
  w->post_kind = ATSCNTRB_AFIBER_POST_UNLOCK ;
  w->post_arg = lk ;
  atscntrb_afiber__schedule() ;
  atscntrb_afiber__spin_lock((int*)lk) ;
} // end of [atscntrb_afiber_waitq_park]

ATSinline()
atstype_bool
atscntrb_afiber_waitq_wake_one
  (atstype_ptr q0)
{
  atscntrb_afiber_t *f = atscntrb_afiber__q_pop((atscntrb_afiber_q*)q0) ;
  if (!f) return atsbool_false ;
  atscntrb_afiber__wake(f) ; return atsbool_true ;
} // end of [atscntrb_afiber_waitq_wake_one]

ATSinline()
void
atscntrb_afiber_waitq_wake_all
  (atstype_ptr q0)
{
  atscntrb_afiber_t *f ;
  while ((f = atscntrb_afiber__q_pop((atscntrb_afiber_q*)q0))) atscntrb_afiber__wake(f) ;
} // end of [atscntrb_afiber_waitq_wake_all]

/* ****** ****** */

/*
** a parking mutex between fibers
*/
typedef
struct {
  int lock ;
  int locked ;
  atscntrb_afiber_q q ;
} atscntrb_afiber_mutex_t ;

ATSinline()
atstype_ptr
atscntrb_afiber_mutex_make()
{
  atscntrb_afiber_mutex_t *m = ATS_MALLOC(sizeof(atscntrb_afiber_mutex_t)) ;
  memset(m, 0, sizeof(*m)) ;
  return (atstype_ptr)m ;
} // end of [atscntrb_afiber_mutex_make]

ATSinline()
void
atscntrb_afiber_mutex_free
  (atstype_ptr m0)
{
  atscntrb_afiber_mutex_t *m = (atscntrb_afiber_mutex_t*)m0 ;
  if (m->locked || m->q.head) atscntrb_afiber__fatal("afiber_mutex_free: the mutex is in use") ;
  ATS_MFREE(m) ;
} // end of [atscntrb_afiber_mutex_free]

ATSinline()
void
atscntrb_afiber_mutex_lock
  (atstype_ptr m0)
{
  atscntrb_afiber_mutex_t *m = (atscntrb_afiber_mutex_t*)m0 ;
  atscntrb_afiber__spin_lock(&(m->lock)) ;
  while (m->locked) atscntrb_afiber_waitq_park((atstype_ptr)&(m->q), (atstype_ptr)&(m->lock)) ;
  m->locked = 1 ;
  atscntrb_afiber__spin_unlock(&(m->lock)) ;
} // end of [atscntrb_afiber_mutex_lock]

ATSinline()
void
atscntrb_afiber_mutex_unlock
  (atstype_ptr m0)
{
  atscntrb_afiber_mutex_t *m = (atscntrb_afiber_mutex_t*)m0 ;
  atscntrb_afiber__spin_lock(&(m->lock)) ;
  m->locked = 0 ;
  atscntrb_afiber_waitq_wake_one((atstype_ptr)&(m->q)) ;
  atscntrb_afiber__spin_unlock(&(m->lock)) ;
} // end of [atscntrb_afiber_mutex_unlock]

/* ****** ****** */

#ifdef ATSCNTRB_AFIBER_MN
/*
** MS-2026-10:
** The exception-frame head of a fiber is a field of its record, so a
** fiber can move between threads inside a [try]. These are the
** definitions of pats_ccomp_runtime_trywith.c (which the program does
** not include with -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_), weak, so that
** every unit can carry them. A thread that is not a worker (it cannot
** use fibers) gets a head of its own.
*/
static __thread atsexnframe_ptr atscntrb_afiber__thread_head ;

__attribute__((weak))
atsexnframe_ptr*
my_atsexnframe_getref ()
{
  atscntrb_afiber_worker_t *w ;
  (void)atscntrb_afiber__sched_get() ; // the first caller may be a [try] in main
  w = atscntrb_afiber__tls_get() ;
  if (w) return &(w->current->exnframe) ;
  return &atscntrb_afiber__thread_head ;
} // end of [my_atsexnframe_getref]

__attribute__((weak))
void
atsruntime_raise
  (void *exn0)
{
  atsexnframe_t *frame ;
  frame = *(my_atsexnframe_getref()) ;
  do {
    if (!frame) break ;
    (frame)->exn = (atstype_exnconptr)exn0 ;
    atspre_longjmp((frame)->env, 1/*retval*/) ;
  } while (0) ;
  atsruntime_handle_uncaughtexn(exn0) ;
  return ;
} // end of [atsruntime_raise]
#endif // ifdef ATSCNTRB_AFIBER_MN

/* ****** ****** */

#endif // ifndef ATSCNTRB_AFIBER_CATS_AFIBER

/* ****** ****** */

/* end of [afiber.cats] */
