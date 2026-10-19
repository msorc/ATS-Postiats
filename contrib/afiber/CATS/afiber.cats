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
#include <stddef.h>
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
** ATSCNTRB_AFIBER_SINGLE (given with -D): one worker for good, the M:N
** branches are compiled out; afiber_workers_start(n > 1) is fatal.
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

#ifdef ATSCNTRB_AFIBER_SINGLE
#define ATSCNTRB_AFIBER_ONEWORKER(s) 1
#else
#define ATSCNTRB_AFIBER_ONEWORKER(s) ((s)->nworkers <= 1)
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

// MS-2026-10: the size of a cache line, for the layout of the scheduler and the workers
#define ATSCNTRB_AFIBER_LINE 64

// MS-2026-10: the slots of the local run queue of a worker (a power of two)
#define ATSCNTRB_AFIBER_RINGSZ 256

// MS-2026-10: how long a thief waits before it takes a [runnext] (Go: 3 us; the owner
// of the slot is probably about to run it itself)
#ifndef ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS
#define ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS 3000
#endif

#ifndef ATSCNTRB_AFIBER_STACK_CACHE
#define ATSCNTRB_AFIBER_STACK_CACHE 0
#endif

/*
** MS-2026-10 (step D): a stack slab. A default-size stack that is not in
** the free list of the worker is carved from a region of
** ATSCNTRB_AFIBER_STACK_SLAB stacks that one [mmap] made; its guard page
** gets its [mprotect] when the stack is carved. So a fresh stack costs one
** syscall (none with ATSCNTRB_AFIBER_NOGUARD) and every SLAB-th one an
** [mmap] more. 1: one [mmap] per stack. Not used with
** ATSCNTRB_AFIBER_STACK_MALLOC.
*/
#ifndef ATSCNTRB_AFIBER_STACK_SLAB
#define ATSCNTRB_AFIBER_STACK_SLAB 32
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

/*
** MS-2026-10: the layout is by cache lines. Each group below is an
** anonymous struct aligned (and so padded) to a line: no two groups
** share a line, and the workers (an array) never share one either.
*/
typedef
struct atscntrb_afiber_worker_s
{
  struct { // written by the owning thread on every switch
    int id ; // 0: the main thread
    atscntrb_afiber_t *current ; // the fiber (or the idle context) running on this thread
    atscntrb_afiber_t *prev ; // for the ASan [finish] call after a switch
    int post_kind ;
    void *post_arg ;
    atscntrb_afiber_t *reap ; // one worker: a dead detached fiber whose stack is no longer in use
    void *stack_cache ; // free list of default-size stacks (address of the lowest usable byte), linked through the last word of the region
    long ncached ;
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  struct { // the local run queue: [tail] is written by the owner only, [head] by thieves (CAS) and the owner
    atscntrb_afiber_t *runnext ; // the fiber to run next (atomic; a thief may take it)
    unsigned head ;              // atomic
    unsigned tail ;              // atomic store by the owner, atomic load by thieves
    int spinning ;               // 1 while this worker spins looking for work (set by the kicker or itself)
    unsigned rnd ;               // xorshift state: where the next stealing round starts
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  atscntrb_afiber_t *ring[ATSCNTRB_AFIBER_RINGSZ] __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ; // the slots, accessed with relaxed atomics
  struct { // read by every kick, written by the idling worker
    int waiting ; // 1 while the worker sleeps (or is about to) in the idle wait
    pthread_mutex_t mu ; // the idle wait of this worker
    pthread_cond_t cv ;
    pthread_t thr ;
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  atscntrb_afiber_t idle __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ; // the idle context (workers > 1), cold
  struct { // the stack slab being carved (owning thread only)
    char *slab_cur ; // the next piece (its guard page, if any, first)
    long slab_left ; // the pieces not yet carved
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
} __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) atscntrb_afiber_worker_t ;

typedef
struct {
  struct { // the sched lock and what it protects
    int lock ; // the sched lock: runq, runqn, sleepq, mainslot, sleep_dl
    atscntrb_afiber_q runq ; // workers > 1: the overflow of the local run queues, expired sleepers
    atscntrb_afiber_t *sleepq ; // singly linked, ascending deadline
    atscntrb_afiber_t *mainslot ; // main, made runnable, for worker 0 (workers > 1)
    unsigned long long sleep_dl ; // workers > 1: the earliest sleep deadline, ~0 if nobody sleeps (stored under the lock, read atomically)
    long runqn ; // workers > 1: the length of runq
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  struct { // the wake-ups
    int nidle ; // workers in the idle wait
    unsigned rr ; // round robin for the wake-ups
    int stop ;
    int nspinning ; // workers looking for work (spinning); at most one is woken at a time
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  struct { // bumped on every spawn and every death
    long nlive ; // fibers not yet dead, main excluded
    long nextid ;
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  struct { // read-mostly: written only at start and stop
    int nworkers ;
    atscntrb_afiber_worker_t *wk ; // workers 1..nworkers-1, when started (line-aligned)
    int inited ;
    void *wk_raw ; // the block [wk] was rounded up from (cold)
  } __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ;
  atscntrb_afiber_t main __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ; // the main thread's own context, id 0
  atscntrb_afiber_worker_t w0 ; // worker 0 (the main thread)
} atscntrb_afiber_sched_t ;

#if __STDC_VERSION__ >= 201112L
_Static_assert(offsetof(atscntrb_afiber_sched_t, lock) % ATSCNTRB_AFIBER_LINE == 0, "afiber: sched.lock is not line-aligned") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, nidle) / ATSCNTRB_AFIBER_LINE != offsetof(atscntrb_afiber_sched_t, lock) / ATSCNTRB_AFIBER_LINE, "afiber: sched.nidle shares lock's line") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, nlive) / ATSCNTRB_AFIBER_LINE != offsetof(atscntrb_afiber_sched_t, lock) / ATSCNTRB_AFIBER_LINE, "afiber: sched.nlive shares lock's line") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, nworkers) / ATSCNTRB_AFIBER_LINE != offsetof(atscntrb_afiber_sched_t, lock) / ATSCNTRB_AFIBER_LINE, "afiber: sched.nworkers shares lock's line") ;
_Static_assert(offsetof(atscntrb_afiber_worker_t, runnext) == ATSCNTRB_AFIBER_LINE, "afiber: the run queue shares a line with the first worker group") ;
_Static_assert(offsetof(atscntrb_afiber_worker_t, ring) / ATSCNTRB_AFIBER_LINE != offsetof(atscntrb_afiber_worker_t, runnext) / ATSCNTRB_AFIBER_LINE, "afiber: ring shares runnext's line") ;
_Static_assert(offsetof(atscntrb_afiber_worker_t, ring) % ATSCNTRB_AFIBER_LINE == 0, "afiber: ring is not line-aligned") ;
_Static_assert((ATSCNTRB_AFIBER_RINGSZ & (ATSCNTRB_AFIBER_RINGSZ-1)) == 0, "afiber: RINGSZ is not a power of two") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, sleep_dl) / ATSCNTRB_AFIBER_LINE == offsetof(atscntrb_afiber_sched_t, lock) / ATSCNTRB_AFIBER_LINE, "afiber: sleep_dl is not on the lock's line") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, runqn) / ATSCNTRB_AFIBER_LINE == offsetof(atscntrb_afiber_sched_t, lock) / ATSCNTRB_AFIBER_LINE, "afiber: runqn is not on the lock's line") ;
_Static_assert(offsetof(atscntrb_afiber_sched_t, nspinning) / ATSCNTRB_AFIBER_LINE == offsetof(atscntrb_afiber_sched_t, nidle) / ATSCNTRB_AFIBER_LINE, "afiber: nspinning is not on nidle's line") ;
_Static_assert(sizeof(atscntrb_afiber_worker_t) % ATSCNTRB_AFIBER_LINE == 0, "afiber: worker size is not a multiple of a line") ;
#endif

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
#ifdef ATSCNTRB_AFIBER_SINGLE
  return &(s->w0) ;
#else
  if (s->nworkers <= 1) return &(s->w0) ;
  {
    atscntrb_afiber_worker_t *w = atscntrb_afiber__tls_get() ;
    if (!w) atscntrb_afiber__fatal("this thread is not an afiber worker") ;
    return w ;
  }
#endif
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
#ifdef ATSCNTRB_AFIBER_SINGLE
  return 0 ;
#else
  return atscntrb_afiber__sched.nworkers > 1 ;
#endif
} // end of [atscntrb_afiber__mt]

/*
** MS-2026-10 (step G): the holder of a lock of ours (channel, mutex,
** scheduler) is a running thread and holds it for tens of ns. The
** waiter spins with [pause], the count doubling up to 256 per round,
** for ATSCNTRB_AFIBER_SPIN_PAUSES pauses (a few us) before the first
** [sched_yield] (a syscall that costs more than the wait, and that can
** deschedule the spinner for a time slice); after that it yields in
** the loop (the holder may be preempted). -DATSCNTRB_AFIBER_SPIN_OLD
** brings back the old policy (100 pauses, then yield) for comparison.
*/
#ifndef ATSCNTRB_AFIBER_SPIN_MAXR
#ifndef ATSCNTRB_AFIBER_MAIN_SPIN_NS
#define ATSCNTRB_AFIBER_MAIN_SPIN_NS 200000ULL // worker 0 looks for work this long while main is parked
#endif
#define ATSCNTRB_AFIBER_SPIN_MAXR 256
#endif
#ifndef ATSCNTRB_AFIBER_SPIN_PAUSES
#define ATSCNTRB_AFIBER_SPIN_PAUSES 2000
#endif
ATSinline()
void
atscntrb_afiber__spin_lock
  (int *p)
{
  unsigned n = 0 ;
#ifndef ATSCNTRB_AFIBER_SPIN_OLD
  unsigned r = 1, i ;
#endif
  if (!atscntrb_afiber__mt()) { *p = 1 ; return ; }
  for ( ; ; ) {
    if (!__atomic_load_n(p, __ATOMIC_RELAXED)
        && !__atomic_exchange_n(p, 1, __ATOMIC_ACQUIRE)) return ;
#ifdef ATSCNTRB_AFIBER_SPIN_OLD
    n += 1 ;
    if (n < 100) {
#if defined(__x86_64__) || defined(__i386__)
      __asm__ volatile ("pause" ::: "memory") ;
#endif
    } else {
      sched_yield() ;
    }
#else
    if (n < ATSCNTRB_AFIBER_SPIN_PAUSES) {
      for (i = 0 ; i < r ; i++) {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile ("pause" ::: "memory") ;
#elif defined(__aarch64__)
        __asm__ volatile ("isb" ::: "memory") ;
#endif
      }
      n += r ;
      if (r < ATSCNTRB_AFIBER_SPIN_MAXR) r <<= 1 ;
    } else {
      sched_yield() ;
    }
#endif
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

// the page size, asked once (a benign race: every thread stores the same value)
ATSinline()
size_t
atscntrb_afiber__pagesz()
{
  static size_t pg = 0 ;
  size_t p = __atomic_load_n(&pg, __ATOMIC_RELAXED) ;
  if (__builtin_expect(p == 0, 0)) {
    p = (size_t)sysconf(_SC_PAGESIZE) ;
    __atomic_store_n(&pg, p, __ATOMIC_RELAXED) ;
  }
  return p ;
}

// the size of the guard page below a stack: none with NOGUARD or malloc'd stacks
ATSinline()
size_t
atscntrb_afiber__guardsz()
{
#if defined(ATSCNTRB_AFIBER_STACK_MALLOC) || defined(ATSCNTRB_AFIBER_NOGUARD)
  return 0 ;
#else
  return atscntrb_afiber__pagesz() ;
#endif
}

// the whole region of a fiber stack made by [create] holds the record of the
// fiber in its top [RECSZ] bytes
#define ATSCNTRB_AFIBER_RECSZ ((sizeof(atscntrb_afiber_t) + 63) & ~(size_t)63)

ATSinline()
size_t
atscntrb_afiber__stack_usable
  (size_t usable)
{
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  return usable ;
#else
  size_t page = atscntrb_afiber__pagesz() ;
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
  return atscntrb_afiber__guardsz() + usable ;
} // end of [atscntrb_afiber__stack_total]

// the link of the free list: the last word of the region, inside the record
// area (the page of the first frame, already touched)
#define ATSCNTRB_AFIBER_CACHELINK(lo) \
  ((void**)((char*)(lo) + atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ) - sizeof(void*)))

/*
** get a stack of (at least) [usable] bytes: the whole region is
** [*full] bytes from [*lo]; [*stack] (size [*stacksz]) is what [munmap]
** takes (the guard page included).
*/
ATSinline()
void
atscntrb_afiber__stack_get
  (atscntrb_afiber_worker_t *w, size_t usable,
   void **stack, size_t *stacksz, void **lo, size_t *full)
{
  size_t guard = atscntrb_afiber__guardsz() ;
  usable = atscntrb_afiber__stack_usable(usable) ;
  *full = usable ;
  *stacksz = guard + usable ;
  if (w->stack_cache
      && usable == atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ)) {
    void *l = w->stack_cache ;
    w->stack_cache = *ATSCNTRB_AFIBER_CACHELINK(l) ;
    w->ncached -= 1 ;
    *lo = l ;
    *stack = (char*)l - guard ;
    return ;
  }
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
  *stack = ATS_MALLOC(usable) ;
  *lo = *stack ;
#else
  {
  size_t page = atscntrb_afiber__pagesz() ;
  size_t total = *stacksz ;
  int flags = MAP_PRIVATE | MAP_ANONYMOUS ;
  char *base ;
#ifdef MAP_NORESERVE
  flags |= MAP_NORESERVE ;
#endif
#ifdef MAP_STACK
  flags |= MAP_STACK ;
#endif
  if (ATSCNTRB_AFIBER_STACK_SLAB > 1
      && usable == atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ)) {
    if (w->slab_left == 0) {
      /*
      ** One region of SLAB stacks. The guard pages are protected one at a
      ** time as the stacks are carved: the mappings stay two per stack (a
      ** read-write stack, a PROT_NONE guard, alternating), so the bound of
      ** [vm.max_map_count] is that of one [mmap] per stack. What is not
      ** carved at [workers_stop] is unmapped by [cache_drain]; in a
      ** one-worker program it stays mapped to the exit (MAP_NORESERVE:
      ** untouched pages cost nothing).
      */
      void *slab = mmap((void*)0, total * (size_t)ATSCNTRB_AFIBER_STACK_SLAB, PROT_READ|PROT_WRITE, flags, -1, 0) ;
      if (slab == MAP_FAILED) atscntrb_afiber__fatal("mmap for a fiber stack slab failed") ;
      w->slab_cur = (char*)slab ;
      w->slab_left = (long)ATSCNTRB_AFIBER_STACK_SLAB ;
    }
    base = w->slab_cur ;
    w->slab_cur += total ;
    w->slab_left -= 1 ;
  } else {
    void *p = mmap((void*)0, total, PROT_READ|PROT_WRITE, flags, -1, 0) ;
    if (p == MAP_FAILED) atscntrb_afiber__fatal("mmap for a fiber stack failed") ;
    base = (char*)p ;
  }
  if (guard && mprotect(base, page, PROT_NONE) != 0) atscntrb_afiber__fatal("mprotect for a guard page failed") ;
  *stack = base ;
  *lo = base + guard ;
  }
#endif
} // end of [atscntrb_afiber__stack_get]

// a stack for a context that is not made by [create] (the idle contexts): no record in it
ATSinline()
void
atscntrb_afiber__stack_alloc
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f, size_t usable)
{
  atscntrb_afiber__stack_get(w, usable, &(f->stack), &(f->stacksz), &(f->stack_lo), &(f->stack_usable)) ;
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
  // possibly a piece of a slab: munmap splits the mapping
  munmap(stack, stacksz) ;
#endif
} // end of [atscntrb_afiber__stack_unmap]

/*
** the stack of [f] goes to the cache of [w], or back to the system. The
** record [f] is in that stack: it is not to be touched after this.
*/
ATSinline()
void
atscntrb_afiber__stack_release
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f)
{
  void *stack = f->stack ;
  size_t stacksz = f->stacksz ;
  void *lo = f->stack_lo ;
  size_t usable = f->stack_usable ; // without the record
  if (stacksz == atscntrb_afiber__stack_total
        (atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ))
      && (ATSCNTRB_AFIBER_STACK_CACHE == 0 || w->ncached < (long)(ATSCNTRB_AFIBER_STACK_CACHE))) {
#ifdef ATSCNTRB_AFIBER_ASAN
    __asan_unpoison_memory_region(lo, usable) ;
#endif
    *ATSCNTRB_AFIBER_CACHELINK(lo) = w->stack_cache ;
    w->stack_cache = lo ;
    w->ncached += 1 ;
  } else {
    atscntrb_afiber__stack_unmap(stack, stacksz, lo, usable) ;
  }
} // end of [atscntrb_afiber__stack_release]

// [f] was made by [create]: its record is at the top of its stack, and goes with it
ATSinline()
void
atscntrb_afiber__free
  (atscntrb_afiber_t *f)
{
#ifdef ATSCNTRB_AFIBER_TSAN
  if (f->tsan_fiber) __tsan_destroy_fiber(f->tsan_fiber) ;
#endif
  atscntrb_afiber__stack_release(atscntrb_afiber__cw(), f) ;
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
// MS-2026-10: at most one worker is woken at a time (Go's [wakep]): the
// kicker takes [nspinning] from 0 to 1 and flags the worker it wakes
// ([spinning]); that worker searches for work (it "spins"), and the
// last spinner that finds some wakes the next idle worker, so the work
// propagates without a wake-up per fiber.
//
ATSinline()
int
atscntrb_afiber__signal_worker
  (atscntrb_afiber_worker_t *w, int spin)
{
  int r ;
  if (!__atomic_load_n(&(w->waiting), __ATOMIC_SEQ_CST)) return 0 ;
  pthread_mutex_lock(&(w->mu)) ;
  r = w->waiting ;
  if (r) {
    if (spin) __atomic_store_n(&(w->spinning), 1, __ATOMIC_RELAXED) ;
    __atomic_store_n(&(w->waiting), 0, __ATOMIC_SEQ_CST) ; pthread_cond_signal(&(w->cv)) ;
  }
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

/*
** wake one idle worker. [only0]: only worker 0 can use the work (main).
** Otherwise nothing is done if somebody is already looking for work.
*/
static
__attribute__((noinline))
void
atscntrb_afiber__kick
  (atscntrb_afiber_sched_t *s, int only0)
{
  int tries ;
  __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
  if (__atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) <= 0) return ;
  if (only0) { atscntrb_afiber__signal_worker(&(s->w0), 0) ; return ; }
  for (tries = 0; tries < 2; tries += 1) {
    int e = 0, n, i0, k ;
    if (__atomic_load_n(&(s->nspinning), __ATOMIC_SEQ_CST) != 0) return ;
    if (!__atomic_compare_exchange_n(&(s->nspinning), &e, 1, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)) return ;
    n = s->nworkers ;
    i0 = (int)(__atomic_fetch_add(&(s->rr), 1, __ATOMIC_RELAXED) % (unsigned)n) ;
    for (k = 0; k < n; k += 1) {
      if (atscntrb_afiber__signal_worker(atscntrb_afiber__worker_at(s, (i0 + k) % n), 1)) return ;
    }
    // nobody was waiting (the idlers were being woken): give the claim back, and look once more
    __atomic_sub_fetch(&(s->nspinning), 1, __ATOMIC_SEQ_CST) ;
    __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
    if (__atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) <= 0) return ;
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
  for (k = 0; k < s->nworkers; k += 1) atscntrb_afiber__signal_worker(atscntrb_afiber__worker_at(s, k), 0) ;
} // end of [atscntrb_afiber__kick_all]

/* ****** ****** */
//
// MS-2026-10: the global FIFO with workers: [runq] (and its length) under
// the sched lock; the head is stored atomically (it is read without the
// lock to see whether there is anything to take)
//
ATSinline()
void
atscntrb_afiber__glob_push
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_t *f)
{
  f->next = (atscntrb_afiber_t*)0 ;
  if (s->runq.tail) s->runq.tail->next = f ; else __atomic_store_n(&(s->runq.head), f, __ATOMIC_RELAXED) ;
  s->runq.tail = f ;
  s->runqn += 1 ;
} // end of [atscntrb_afiber__glob_push]

ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__glob_pop
  (atscntrb_afiber_sched_t *s)
{
  atscntrb_afiber_t *f = s->runq.head ;
  if (f) {
    __atomic_store_n(&(s->runq.head), f->next, __ATOMIC_RELAXED) ;
    if (!f->next) s->runq.tail = (atscntrb_afiber_t*)0 ;
    f->next = (atscntrb_afiber_t*)0 ;
    s->runqn -= 1 ;
  }
  return f ;
} // end of [atscntrb_afiber__glob_pop]

/* ****** ****** */
//
// MS-2026-10: the local run queue of a worker (Go's runq): a ring of
// RINGSZ slots with [runnext] in front of it. The owner is the only one
// to write [tail] and the slots at [tail]; [head] moves by CAS (by the
// owner when it takes the oldest, by a thief when it takes half). The
// owner writes slot [t] only when [t - head < RINGSZ] for a head it has
// loaded: a thief that read the slots [h, t) cannot see them overwritten
// before its CAS on head decides, and after it they are the thief's.
//
#define ATSCNTRB_AFIBER_RMASK (ATSCNTRB_AFIBER_RINGSZ - 1)

ATSinline()
void
atscntrb_afiber__cpu_relax()
{
#if defined(__x86_64__) || defined(__i386__)
  __asm__ volatile ("pause" ::: "memory") ;
#endif
} // end of [atscntrb_afiber__cpu_relax]

// the ring is full: move half of it and [f] to the global FIFO (false: a thief was faster, retry)
static
__attribute__((noinline))
int
atscntrb_afiber__runq_putslow
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f, unsigned h, unsigned t)
{
  atscntrb_afiber_t *batch[ATSCNTRB_AFIBER_RINGSZ/2 + 1] ;
  unsigned n = (t - h) / 2, i ;
  if (n != ATSCNTRB_AFIBER_RINGSZ/2) return 0 ; // the head moved
  for (i = 0; i < n; i += 1) batch[i] = __atomic_load_n(&(w->ring[(h + i) & ATSCNTRB_AFIBER_RMASK]), __ATOMIC_RELAXED) ;
  if (!__atomic_compare_exchange_n(&(w->head), &h, h + n, 0, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED)) return 0 ;
  batch[n] = f ;
  atscntrb_afiber__spin_lock(&(s->lock)) ;
  for (i = 0; i <= n; i += 1) atscntrb_afiber__glob_push(s, batch[i]) ;
  atscntrb_afiber__spin_unlock(&(s->lock)) ;
  atscntrb_afiber__kick(s, 0) ;
  return 1 ;
} // end of [atscntrb_afiber__runq_putslow]

/*
** owner only: queue [f]. [next]: it goes to [runnext] and the fiber
** that was there (if any) is queued at the tail instead.
*/
ATSinline()
void
atscntrb_afiber__runq_put
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f, int next)
{
  if (next) {
    f = __atomic_exchange_n(&(w->runnext), f, __ATOMIC_ACQ_REL) ;
    if (!f) return ;
  }
  for ( ; ; ) {
    unsigned h = __atomic_load_n(&(w->head), __ATOMIC_ACQUIRE) ;
    unsigned t = w->tail ; // only the owner writes it
    if (t - h < ATSCNTRB_AFIBER_RINGSZ) {
      __atomic_store_n(&(w->ring[t & ATSCNTRB_AFIBER_RMASK]), f, __ATOMIC_RELAXED) ;
      __atomic_store_n(&(w->tail), t + 1, __ATOMIC_RELEASE) ;
      return ;
    }
    if (atscntrb_afiber__runq_putslow(s, w, f, h, t)) return ;
  }
} // end of [atscntrb_afiber__runq_put]

// owner only: the next fiber of the local queue, or NULL
ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__runq_get
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber_t *f ;
  if (__atomic_load_n(&(w->runnext), __ATOMIC_RELAXED)) {
    f = __atomic_exchange_n(&(w->runnext), (atscntrb_afiber_t*)0, __ATOMIC_ACQ_REL) ; // a thief may have taken it
    if (f) return f ;
  }
  for ( ; ; ) {
    unsigned h = __atomic_load_n(&(w->head), __ATOMIC_ACQUIRE) ;
    unsigned t = w->tail ;
    if (t == h) return (atscntrb_afiber_t*)0 ;
    f = __atomic_load_n(&(w->ring[h & ATSCNTRB_AFIBER_RMASK]), __ATOMIC_RELAXED) ;
    if (__atomic_compare_exchange_n(&(w->head), &h, h + 1, 0, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED)) return f ;
  }
} // end of [atscntrb_afiber__runq_get]

// busy-wait about [ns] nanoseconds
static
__attribute__((noinline))
void
atscntrb_afiber__spin_ns
  (unsigned long long ns)
{
  unsigned long long t0 = atscntrb_afiber_clock_ns() ;
  while (atscntrb_afiber_clock_ns() - t0 < ns) atscntrb_afiber__cpu_relax() ;
} // end of [atscntrb_afiber__spin_ns]

/*
** [thief] (its ring is empty) takes half of the ring of [victim]: one
** fiber is returned to run now, the others go to the ring of [thief].
** [steal_runnext]: with an empty ring, take [runnext] too, but only after
** a short wait, and if the victim still has nothing else (Go's rule: a
** fiber that just handed a message to its partner gets to run it itself).
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__runq_steal
  (atscntrb_afiber_worker_t *victim, atscntrb_afiber_worker_t *thief, int steal_runnext)
{
  for ( ; ; ) {
    unsigned h = __atomic_load_n(&(victim->head), __ATOMIC_ACQUIRE) ;
    unsigned t = __atomic_load_n(&(victim->tail), __ATOMIC_ACQUIRE) ;
    unsigned n = t - h, i, tt ;
    n = n - n/2 ;
    if (n == 0) {
      atscntrb_afiber_t *rn ;
      if (!steal_runnext) return (atscntrb_afiber_t*)0 ;
      rn = __atomic_load_n(&(victim->runnext), __ATOMIC_RELAXED) ;
      if (!rn) return (atscntrb_afiber_t*)0 ;
      if (ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS > 0) atscntrb_afiber__spin_ns(ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS) ;
      if (__atomic_load_n(&(victim->head), __ATOMIC_ACQUIRE) != __atomic_load_n(&(victim->tail), __ATOMIC_ACQUIRE)) continue ; // it has work in the ring now
      if (__atomic_compare_exchange_n(&(victim->runnext), &rn, (atscntrb_afiber_t*)0, 0, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED)) return rn ;
      return (atscntrb_afiber_t*)0 ; // the owner took it (or replaced it)
    }
    if (n > ATSCNTRB_AFIBER_RINGSZ/2) continue ; // inconsistent read
    tt = thief->tail ;
    for (i = 0; i < n; i += 1)
      __atomic_store_n(&(thief->ring[(tt + i) & ATSCNTRB_AFIBER_RMASK]),
        __atomic_load_n(&(victim->ring[(h + i) & ATSCNTRB_AFIBER_RMASK]), __ATOMIC_RELAXED), __ATOMIC_RELAXED) ;
    if (!__atomic_compare_exchange_n(&(victim->head), &h, h + n, 0, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED)) continue ;
    n -= 1 ;
    {
      atscntrb_afiber_t *f = __atomic_load_n(&(thief->ring[(tt + n) & ATSCNTRB_AFIBER_RMASK]), __ATOMIC_RELAXED) ;
      if (n > 0) __atomic_store_n(&(thief->tail), tt + n, __ATOMIC_RELEASE) ;
      return f ;
    }
  }
} // end of [atscntrb_afiber__runq_steal]

// one round over the other workers, from a random one; the first hit is returned
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__steal_round
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w, int steal_runnext)
{
  int n = s->nworkers, k, i0 ;
  unsigned x = w->rnd ;
  x ^= x << 13 ; x ^= x >> 17 ; x ^= x << 5 ;
  w->rnd = x ;
  i0 = (int)(x % (unsigned)n) ;
  for (k = 0; k < n; k += 1) {
    atscntrb_afiber_worker_t *v = atscntrb_afiber__worker_at(s, (i0 + k) % n) ;
    atscntrb_afiber_t *f ;
    if (v == w) continue ;
    f = atscntrb_afiber__runq_steal(v, w, steal_runnext) ;
    if (f) return f ;
  }
  return (atscntrb_afiber_t*)0 ;
} // end of [atscntrb_afiber__steal_round]

/* ****** ****** */

/*
** make [f] runnable. With workers, main goes to the main slot of
** worker 0 (it runs only there, never in a ring); the other fibers go
** to [runnext] of the worker that wakes them (the fiber it replaces is
** queued behind its ring).
*/
static
__attribute__((noinline))
void
atscntrb_afiber__wake_mt
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_t *f)
{
  if (f == &(s->main)) {
    atscntrb_afiber__spin_lock(&(s->lock)) ;
    __atomic_store_n(&(s->mainslot), f, __ATOMIC_RELAXED) ;
    atscntrb_afiber__spin_unlock(&(s->lock)) ;
    atscntrb_afiber__kick(s, 1) ;
    return ;
  }
  atscntrb_afiber__runq_put(s, atscntrb_afiber__cw(), f, 1) ;
  atscntrb_afiber__kick(s, 0) ;
} // end of [atscntrb_afiber__wake_mt]

// (the one worker case is the hot path of the one-worker scheduler)
ATSinline()
void
atscntrb_afiber__wake
  (atscntrb_afiber_t *f)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
  if (__builtin_expect(ATSCNTRB_AFIBER_ONEWORKER(s), 1)) { atscntrb_afiber__q_push(&(s->runq), f) ; return ; }
  atscntrb_afiber__wake_mt(s, f) ;
} // end of [atscntrb_afiber__wake]

/*
** a fiber that yields (workers > 1), after its switch: it goes to the
** tail of the ring of [w], not to [runnext] (that would run it straight
** back); main goes to the main slot.
*/
static
__attribute__((noinline))
void
atscntrb_afiber__wake_yield
  (atscntrb_afiber_worker_t *w, atscntrb_afiber_t *f)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
  if (f == &(s->main)) { atscntrb_afiber__wake_mt(s, f) ; return ; }
  atscntrb_afiber__runq_put(s, w, f, 0) ;
  atscntrb_afiber__kick(s, 0) ;
} // end of [atscntrb_afiber__wake_yield]

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
** one worker: the next fiber for worker [w], or NULL (expired sleepers
** are moved to the run queue first)
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__pick_slow
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  if (s->sleepq) {
    unsigned long long now = atscntrb_afiber_clock_ns() ;
    while (s->sleepq && s->sleepq->deadline_ns <= now) {
      atscntrb_afiber_t *f = s->sleepq ; s->sleepq = f->next ;
      atscntrb_afiber__setstate(f, ATSCNTRB_AFIBER_RUNNABLE) ;
      atscntrb_afiber__q_push(&(s->runq), f) ;
    }
  }
  return atscntrb_afiber__q_pop(&(s->runq)) ;
} // end of [atscntrb_afiber__pick_slow]

/*
** MS-2026-10: workers > 1, the global part of [pick]: under the sched
** lock move the expired sleepers to the global FIFO, then take the
** first of the FIFO (or main, for worker 0), and some more of it for
** the ring of [w] (Go's globrunqget: about 1/nworkers of what is there,
** at most half a ring), so the lock is not taken once per fiber.
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__pick_global
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w)
{
  int kickmain = 0, more = 0, moved = 0 ;
  atscntrb_afiber_t *f ;
  atscntrb_afiber__spin_lock(&(s->lock)) ;
  if (s->sleepq) {
    unsigned long long now = atscntrb_afiber_clock_ns() ;
    if (s->sleepq->deadline_ns <= now) {
      while (s->sleepq && s->sleepq->deadline_ns <= now) {
        atscntrb_afiber_t *g = s->sleepq ; s->sleepq = g->next ;
        atscntrb_afiber__setstate(g, ATSCNTRB_AFIBER_RUNNABLE) ;
        if (g == &(s->main)) { __atomic_store_n(&(s->mainslot), g, __ATOMIC_RELAXED) ; kickmain = 1 ; }
        else atscntrb_afiber__glob_push(s, g) ;
      }
      __atomic_store_n(&(s->sleep_dl), s->sleepq ? s->sleepq->deadline_ns : ~0ULL, __ATOMIC_RELAXED) ;
    }
  }
  if (w->id == 0 && s->mainslot) {
    f = s->mainslot ; __atomic_store_n(&(s->mainslot), (atscntrb_afiber_t*)0, __ATOMIC_RELAXED) ;
  } else {
    long len = s->runqn ;
    f = atscntrb_afiber__glob_pop(s) ;
    if (f && s->runqn > 0) {
      long n = len / (long)s->nworkers ; // the share of this worker, besides [f]
      unsigned h = __atomic_load_n(&(w->head), __ATOMIC_ACQUIRE) ;
      unsigned t = w->tail ;
      if (n > (long)(ATSCNTRB_AFIBER_RINGSZ/2)) n = ATSCNTRB_AFIBER_RINGSZ/2 ;
      if (n > s->runqn) n = s->runqn ;
      while (n > 0 && t - h < ATSCNTRB_AFIBER_RINGSZ) {
        atscntrb_afiber_t *g = atscntrb_afiber__glob_pop(s) ;
        __atomic_store_n(&(w->ring[t & ATSCNTRB_AFIBER_RMASK]), g, __ATOMIC_RELAXED) ;
        t += 1 ; n -= 1 ; moved = 1 ;
      }
      if (moved) __atomic_store_n(&(w->tail), t, __ATOMIC_RELEASE) ;
    }
    more = (s->runq.head != (atscntrb_afiber_t*)0) ;
  }
  atscntrb_afiber__spin_unlock(&(s->lock)) ;
  if (kickmain) atscntrb_afiber__kick(s, 1) ;
  if (more || moved) atscntrb_afiber__kick(s, 0) ;
  return f ;
} // end of [atscntrb_afiber__pick_global]

/*
** workers > 1: the next fiber for [w], or NULL: main (worker 0 only),
** the local queue, the global FIFO and the sleepers, one stealing round.
** [last]: the stealing round may take a [runnext] too.
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__pick_mt
  (atscntrb_afiber_worker_t *w, int last)
{
  atscntrb_afiber_sched_t *s = &atscntrb_afiber__sched ;
  atscntrb_afiber_t *f ;
  if (w->id == 0 && __atomic_load_n(&(s->mainslot), __ATOMIC_ACQUIRE)) {
    atscntrb_afiber__spin_lock(&(s->lock)) ;
    f = s->mainslot ; __atomic_store_n(&(s->mainslot), (atscntrb_afiber_t*)0, __ATOMIC_RELAXED) ;
    atscntrb_afiber__spin_unlock(&(s->lock)) ;
    if (f) return f ;
  }
  f = atscntrb_afiber__runq_get(w) ;
  if (f) return f ;
  {
    unsigned long long dl = __atomic_load_n(&(s->sleep_dl), __ATOMIC_RELAXED) ;
    if (__atomic_load_n(&(s->runq.head), __ATOMIC_RELAXED)
        || (dl != ~0ULL && dl <= atscntrb_afiber_clock_ns())) {
      f = atscntrb_afiber__pick_global(s, w) ;
      if (f) return f ;
    }
  }
  return atscntrb_afiber__steal_round(s, w, last) ;
} // end of [atscntrb_afiber__pick_mt]

ATSinline()
atscntrb_afiber_t*
atscntrb_afiber__pick
  (atscntrb_afiber_worker_t *w)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  if (__builtin_expect(ATSCNTRB_AFIBER_ONEWORKER(s), 1)) {
    if (__builtin_expect(!s->sleepq, 1)) // one worker, nobody sleeps
      return atscntrb_afiber__q_pop(&(s->runq)) ;
    return atscntrb_afiber__pick_slow(w) ;
  }
  return atscntrb_afiber__pick_mt(w, 0) ;
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
  else if (det) { if (ATSCNTRB_AFIBER_ONEWORKER(s)) w->reap = f ; else atscntrb_afiber__free(f) ; }
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
    if (ATSCNTRB_AFIBER_ONEWORKER(atscntrb_afiber__sched_get())) atscntrb_afiber__wake((atscntrb_afiber_t*)a) ;
    else atscntrb_afiber__wake_yield(w, (atscntrb_afiber_t*)a) ;
    break ;
  case ATSCNTRB_AFIBER_POST_SLEEP:
    {
      atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
      int newhead ;
      atscntrb_afiber__spin_lock(&(s->lock)) ;
      atscntrb_afiber__sleep_insert(s, (atscntrb_afiber_t*)a) ;
      newhead = (s->sleepq == (atscntrb_afiber_t*)a) ;
      if (newhead) __atomic_store_n(&(s->sleep_dl), ((atscntrb_afiber_t*)a)->deadline_ns, __ATOMIC_RELAXED) ;
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
    if (!ATSCNTRB_AFIBER_ONEWORKER(s)) { // nothing to run: park on the idle context
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
** MS-2026-10: after the announcement of an idle worker: is there work
** that [pick] could take? Relaxed loads are enough (the announcement and
** the producers' pushes are ordered by the seq-cst fences). Main counts
** for worker 0 only. A [runnext] counts: its owner will run it, unless
** a stealing round with [last] takes it first.
*/
static
__attribute__((noinline))
int
atscntrb_afiber__peek_work
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w)
{
  int k, n = s->nworkers ;
  unsigned long long dl = __atomic_load_n(&(s->sleep_dl), __ATOMIC_RELAXED) ;
  if (__atomic_load_n(&(s->runq.head), __ATOMIC_RELAXED)) return 1 ;
  if (w->id == 0 && __atomic_load_n(&(s->mainslot), __ATOMIC_RELAXED)) return 1 ;
  if (dl != ~0ULL && dl <= atscntrb_afiber_clock_ns()) return 1 ;
  for (k = 0; k < n; k += 1) {
    atscntrb_afiber_worker_t *v = atscntrb_afiber__worker_at(s, k) ;
    if (__atomic_load_n(&(v->head), __ATOMIC_RELAXED) != __atomic_load_n(&(v->tail), __ATOMIC_RELAXED)) return 1 ;
    if (__atomic_load_n(&(v->runnext), __ATOMIC_RELAXED)) return 1 ;
  }
  return 0 ;
} // end of [atscntrb_afiber__peek_work]

/*
** Step H: main is pinned to worker 0, and it parks (join, channel, ...)
** while the fibers it waits for run on the other workers. If worker 0
** went to sleep on its condition variable every time, main's wake-up
** would cost a futex wake-up (5-10 us). So worker 0, having found
** nothing in its spinning rounds, keeps looking (rounds of [pick_mt],
** which also steals, so it keeps helping) for up to
** ATSCNTRB_AFIBER_MAIN_SPIN_NS, as long as main is blocked (BLOCKED or
** WAITALL: not SLEEPING, a sleeper has a deadline), fibers are alive and
** some other worker is not idle. Main's arrival in [mainslot] is seen by
** [pick_mt] at the top of the next round (it reads the slot with acquire
** and then takes [s->lock]). When every other worker is idle too, or after
** the bound, the caller announces and sleeps as usual (the deadlock
** detection is there). This spin is NOT counted in [nspinning] (the
** spinner accounting of the caller has been closed): a counted spinner
** would suppress the kicks that wake the other workers, and worker 0 is
** not an extra spinner, it is the one that waits for main; it does not
** announce itself in [nidle] either, so [kick] still sees the true count.
*/
static
__attribute__((noinline))
atscntrb_afiber_t*
atscntrb_afiber__main_spin
  (atscntrb_afiber_sched_t *s, atscntrb_afiber_worker_t *w)
{
  unsigned long long t0 = 0ULL ;
  int st, j ;
  atscntrb_afiber_t *next ;
  for ( ; ; ) {
    st = atscntrb_afiber__getstate(&(s->main)) ;
    if (st != ATSCNTRB_AFIBER_BLOCKED && st != ATSCNTRB_AFIBER_WAITALL) return (atscntrb_afiber_t*)0 ;
    if (__atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) >= s->nworkers - 1) return (atscntrb_afiber_t*)0 ;
    if (__atomic_load_n(&(s->nlive), __ATOMIC_SEQ_CST) <= 0) return (atscntrb_afiber_t*)0 ;
    if (__atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE)) return (atscntrb_afiber_t*)0 ;
    if (t0 == 0ULL) t0 = atscntrb_afiber_clock_ns() ;
    else if (atscntrb_afiber_clock_ns() - t0 > ATSCNTRB_AFIBER_MAIN_SPIN_NS) return (atscntrb_afiber_t*)0 ;
    next = atscntrb_afiber__pick_mt(w, 0) ;
    if (next) return next ;
    for (j = 0; j < 30; j += 1) atscntrb_afiber__cpu_relax() ;
  }
} // end of [atscntrb_afiber__main_spin]

/*
** the idle loop of a worker, on its idle context: run what there
** is, else wait on the condition variable of the worker (until the
** earliest sleep deadline, if there is one). All workers idle with
** nothing queued and nobody sleeping is a deadlock.
**
** MS-2026-10: a worker that ran dry, or that was woken by a kick
** ([spinning] is set), first spins: up to 4 rounds of [pick] (each with
** a stealing round; the last one may take a [runnext]). A spinner that
** finds work, and was the last one, wakes the next idle worker (Go's
** resetspinning). Only then it announces itself ([nidle]), looks once
** more (the work may have been pushed before the announcement) and waits.
*/
ATSinline()
void
atscntrb_afiber__idle_loop()
{
  int recheck = 0 ; // the last look found work that [pick] did not take: take a [runnext] too
  for ( ; ; ) {
    atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
    atscntrb_afiber_worker_t *w = atscntrb_afiber__cw() ;
    atscntrb_afiber_t *next = (atscntrb_afiber_t*)0 ;
    int spin, rounds, r, stop ;
    unsigned long long dl ;
    if (w->id != 0 && __atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE)) return ;
    spin = __atomic_load_n(&(w->spinning), __ATOMIC_RELAXED) ; // set by the kicker, who has counted it
    if (!spin && 2 * __atomic_load_n(&(s->nspinning), __ATOMIC_RELAXED) < s->nworkers - __atomic_load_n(&(s->nidle), __ATOMIC_RELAXED)) {
      __atomic_add_fetch(&(s->nspinning), 1, __ATOMIC_SEQ_CST) ;
      __atomic_store_n(&(w->spinning), 1, __ATOMIC_RELAXED) ;
      spin = 1 ;
    }
    rounds = spin ? 4 : 1 ;
    for (r = 0; r < rounds; r += 1) {
      next = atscntrb_afiber__pick_mt(w, recheck || (spin && r == rounds - 1)) ;
      if (next) break ;
      if (r + 1 < rounds) { int j ; for (j = 0; j < 30; j += 1) atscntrb_afiber__cpu_relax() ; }
    }
    if (spin) {
      __atomic_store_n(&(w->spinning), 0, __ATOMIC_RELAXED) ;
      if (__atomic_sub_fetch(&(s->nspinning), 1, __ATOMIC_SEQ_CST) == 0 && next) atscntrb_afiber__kick(s, 0) ;
    }
    if (!next && w->id == 0) next = atscntrb_afiber__main_spin(s, w) ;
    if (next) { recheck = 0 ; atscntrb_afiber__switch_to(w, next) ; continue ; }
    pthread_mutex_lock(&(w->mu)) ;
    __atomic_store_n(&(w->waiting), 1, __ATOMIC_SEQ_CST) ;
    __atomic_add_fetch(&(s->nidle), 1, __ATOMIC_SEQ_CST) ;
    __atomic_thread_fence(__ATOMIC_SEQ_CST) ;
    if (atscntrb_afiber__peek_work(s, w)) { // announce, then look: there is work, go and take it
      __atomic_store_n(&(w->waiting), 0, __ATOMIC_SEQ_CST) ;
      __atomic_sub_fetch(&(s->nidle), 1, __ATOMIC_SEQ_CST) ;
      pthread_mutex_unlock(&(w->mu)) ;
      recheck = 1 ;
      continue ;
    }
    recheck = 0 ;
    dl = __atomic_load_n(&(s->sleep_dl), __ATOMIC_RELAXED) ;
    stop = __atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE) ;
    if (!stop) {
      if (dl == ~0ULL && !__atomic_load_n(&(s->mainslot), __ATOMIC_RELAXED)
          && __atomic_load_n(&(s->nidle), __ATOMIC_SEQ_CST) == s->nworkers)
        atscntrb_afiber__fatal("deadlock: every fiber is blocked") ;
      while (__atomic_load_n(&(w->waiting), __ATOMIC_SEQ_CST)
             && !__atomic_load_n(&(s->stop), __ATOMIC_ACQUIRE)) {
        if (dl != ~0ULL) {
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
  if (ATSCNTRB_AFIBER_ONEWORKER(&atscntrb_afiber__sched)) {
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
  atscntrb_afiber_t *f ;
  void *stack, *lo ; size_t stackbytes, full, rec ;
  atscntrb_afiber__stack_get(atscntrb_afiber__cw(), stacksz, &stack, &stackbytes, &lo, &full) ;
  // the record of the fiber: the top of its stack region, on a line
  rec = ((uintptr_t)lo + full - ATSCNTRB_AFIBER_RECSZ) & ~(uintptr_t)63 ;
  f = (atscntrb_afiber_t*)rec ;
  memset(f, 0, sizeof(atscntrb_afiber_t)) ;
  f->stack = stack ;
  f->stacksz = stackbytes ;
  f->stack_lo = lo ;
  f->stack_usable = rec - (uintptr_t)lo ;
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
  if (ATSCNTRB_AFIBER_ONEWORKER(s)) { // queue the fiber first: exact FIFO order
    atscntrb_afiber__wake(w->current) ;
    atscntrb_afiber__schedule() ;
  } else {
    atscntrb_afiber_t *next = atscntrb_afiber__pick_mt(w, 0) ;
    if (!next) return ; // nothing else to run: the yield is a no-op
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
  if (ATSCNTRB_AFIBER_ONEWORKER(s)) {
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
  w->runnext = (atscntrb_afiber_t*)0 ; w->head = 0 ; w->tail = 0 ; w->spinning = 0 ; // MS-2026-10
  w->rnd = 2463534242u ^ ((unsigned)id * 0x9E3779B9u) ; if (!w->rnd) w->rnd = 1 ;
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
#ifdef ATSCNTRB_AFIBER_SINGLE
  atscntrb_afiber__fatal("afiber_workers_start(n > 1): compiled with -DATSCNTRB_AFIBER_SINGLE") ;
#endif
#ifndef ATSCNTRB_AFIBER_CANMN
  atscntrb_afiber__fatal("afiber_workers_start(n > 1): compile with -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ (and -pthread)") ;
#endif
  if (s->nworkers > 1) atscntrb_afiber__fatal("afiber_workers_start: the workers are already started") ;
  if (atscntrb_afiber__tls_get() != &(s->w0) || s->w0.current != &(s->main))
    atscntrb_afiber__fatal("afiber_workers_start: main only") ;
  // MS-2026-10: over-allocate and round up: the workers sit on their own lines whatever ATS_MALLOC is
  s->wk_raw = ATS_MALLOC((size_t)(n-1) * sizeof(atscntrb_afiber_worker_t) + ATSCNTRB_AFIBER_LINE) ;
  s->wk = (atscntrb_afiber_worker_t*)(((uintptr_t)s->wk_raw + (ATSCNTRB_AFIBER_LINE-1)) & ~(uintptr_t)(ATSCNTRB_AFIBER_LINE-1)) ;
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
  s->stop = 0 ; s->nidle = 0 ; s->nspinning = 0 ;
  { // MS-2026-10: what the one-worker phase left in the global FIFO and the sleep list
    atscntrb_afiber_t *g ;
    s->runqn = 0 ;
    for (g = s->runq.head; g; g = g->next) s->runqn += 1 ;
    s->sleep_dl = s->sleepq ? s->sleepq->deadline_ns : ~0ULL ;
  }
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
    w->stack_cache = *ATSCNTRB_AFIBER_CACHELINK(lo) ;
    atscntrb_afiber__stack_unmap
      ((char*)lo - atscntrb_afiber__guardsz(), atscntrb_afiber__stack_total(usable), lo, usable) ;
  }
  w->ncached = 0 ;
#ifndef ATSCNTRB_AFIBER_STACK_MALLOC
  // what was never carved of the slab
  if (w->slab_left > 0)
    munmap(w->slab_cur, (size_t)w->slab_left * atscntrb_afiber__stack_total
             (atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ))) ;
  w->slab_cur = (char*)0 ; w->slab_left = 0 ;
#endif
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
  for (i = 0; i < n; i += 1) { // MS-2026-10: no live fiber, so no local queue holds one
    atscntrb_afiber_worker_t *v = atscntrb_afiber__worker_at(s, i) ;
    if (v->head != v->tail || v->runnext) atscntrb_afiber__fatal("afiber_workers_stop: a run queue is not empty") ;
  }
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
  ATS_MFREE(s->wk_raw) ; s->wk_raw = (void*)0 ; s->wk = (atscntrb_afiber_worker_t*)0 ;
  s->mainslot = (atscntrb_afiber_t*)0 ;
  s->nidle = 0 ; s->stop = 0 ; s->nspinning = 0 ;
  s->sleep_dl = ~0ULL ; s->runqn = 0 ;
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
**
** MS-2026-10: Go's sync.Mutex adapted to fibers (the waitq [q] is the
** semaphore). One atomic word [state]:
**   bit 0 LOCKED   the mutex is held
**   bit 1 WOKEN    a waiter is awake (spinning, or just woken) and
**                  competes for the mutex: nobody else needs to be woken
**   bit 2 STARVING the lock is handed over to the head of [q] (below)
**   bits 3..       the number of waiters (parked, or about to park)
** [lock] only guards [q]. Fast path: one CAS 0 -> LOCKED to lock, one
** fetch_sub of LOCKED to unlock (plain stores with one worker).
**
** lock, slow path: spin a few rounds ([pause], several workers only) while
** the mutex is held and not starving, setting WOKEN while spinning so that
** [unlock] does not wake anybody else; then one CAS puts in the new state:
** take LOCKED if it is free, or add a waiter if it is held, and in the
** latter case park on [q]. The woken fiber retries as the "awake" waiter
** (WOKEN is cleared by its next CAS). At most one waiter is awake at a
** time, so the woken fibers do not stampede against the bargers and
** re-park by the dozen. A waiter that was waiting for more than 1 ms
** (and is woken and loses again) sets STARVING: now [unlock] clears
** LOCKED, new arrivals and spinners queue instead of taking it, and the
** head of [q] is woken and takes the mutex (a FIFO hand-off); the waiter
** leaves STARVING when it waited less than 1 ms or it is the last one.
**
** No wake-up is lost: a waiter announces itself (waiters + 1) in the very
** CAS that finds LOCKED set, so the word is the single point of
** serialization: either that CAS precedes the unlocker's fetch_sub (which
** then sees the waiter in the value it gets back, and wakes one), or it
** follows it and sees LOCKED clear (it takes the mutex instead). The
** waiter takes [lock] BEFORE that CAS and keeps it until it is in [q]
** and off its stack (the park pushes before the switch and releases [lock]
** after it), so an unlocker that counted the waiter and then takes [lock]
** to pop [q] always finds it. The unlocker claims one waiter in a CAS
** (waiters - 1, WOKEN) before popping, so two unlockers never pop for the
** same waiter. The mutex is not FIFO in the normal mode (bargers win).
*/
#define ATSCNTRB_AFIBER_MX_LOCKED 1u
#define ATSCNTRB_AFIBER_MX_WOKEN 2u
#define ATSCNTRB_AFIBER_MX_STARVING 4u
#define ATSCNTRB_AFIBER_MX_SHIFT 3
#define ATSCNTRB_AFIBER_MX_ONE (1u << ATSCNTRB_AFIBER_MX_SHIFT)
#define ATSCNTRB_AFIBER_MX_STARVE_NS 1000000ULL

typedef
struct {
  int lock ;           // guards q
  unsigned int state ; // see above
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
  if (m->state != 0 || m->q.head) atscntrb_afiber__fatal("afiber_mutex_free: the mutex is in use") ;
  ATS_MFREE(m) ;
} // end of [atscntrb_afiber_mutex_free]

// compare-and-swap of the state word (a plain store with one worker);
// on failure *old is refreshed
ATSinline()
int
atscntrb_afiber__mx_cas
  (unsigned int *p, unsigned int *old, unsigned int nw)
{
  if (!atscntrb_afiber__mt()) {
    if (*p == *old) { *p = nw ; return 1 ; }
    *old = *p ; return 0 ;
  }
  return __atomic_compare_exchange_n(p, old, nw, 0, __ATOMIC_ACQ_REL, __ATOMIC_RELAXED) ;
} // end of [atscntrb_afiber__mx_cas]

ATSinline()
unsigned int
atscntrb_afiber__mx_load
  (unsigned int *p)
{
  if (!atscntrb_afiber__mt()) return *p ;
  return __atomic_load_n(p, __ATOMIC_RELAXED) ;
} // end of [atscntrb_afiber__mx_load]

__attribute__((noinline))
static
void
atscntrb_afiber__mx_lock_slow
  (atscntrb_afiber_mutex_t *m)
{
  unsigned int *s = &(m->state) ;
  unsigned long long t0 = 0ULL ;
  int starving = 0, awoke = 0, iter = 0 ;
  unsigned int old = atscntrb_afiber__mx_load(s), nw ;
  for ( ; ; ) {
    if ((old & (ATSCNTRB_AFIBER_MX_LOCKED | ATSCNTRB_AFIBER_MX_STARVING)) == ATSCNTRB_AFIBER_MX_LOCKED
        && atscntrb_afiber__mt() && iter < 4) {
      // spin; tell [unlock] that an awake waiter exists
      int j ;
      if (!awoke && !(old & ATSCNTRB_AFIBER_MX_WOKEN) && (old >> ATSCNTRB_AFIBER_MX_SHIFT) != 0
          && atscntrb_afiber__mx_cas(s, &old, old | ATSCNTRB_AFIBER_MX_WOKEN)) awoke = 1 ;
      for (j = 0 ; j < 30 ; j += 1) atscntrb_afiber__cpu_relax() ;
      iter += 1 ;
      old = atscntrb_afiber__mx_load(s) ;
      continue ;
    }
    if (!(old & (ATSCNTRB_AFIBER_MX_LOCKED | ATSCNTRB_AFIBER_MX_STARVING))) {
      nw = old | ATSCNTRB_AFIBER_MX_LOCKED ;
      if (awoke) nw &= ~ATSCNTRB_AFIBER_MX_WOKEN ;
      if (atscntrb_afiber__mx_cas(s, &old, nw)) return ;
      continue ;
    }
    // held (or starving): announce under [lock], then park
    atscntrb_afiber__spin_lock(&(m->lock)) ;
    old = atscntrb_afiber__mx_load(s) ;
    for ( ; ; ) {
      if (!(old & (ATSCNTRB_AFIBER_MX_LOCKED | ATSCNTRB_AFIBER_MX_STARVING))) break ;
      nw = old + ATSCNTRB_AFIBER_MX_ONE ;
      if (starving && (old & ATSCNTRB_AFIBER_MX_LOCKED)) nw |= ATSCNTRB_AFIBER_MX_STARVING ;
      if (awoke) nw &= ~ATSCNTRB_AFIBER_MX_WOKEN ;
      if (atscntrb_afiber__mx_cas(s, &old, nw)) break ;
    }
    if (!(old & (ATSCNTRB_AFIBER_MX_LOCKED | ATSCNTRB_AFIBER_MX_STARVING))) {
      atscntrb_afiber__spin_unlock(&(m->lock)) ;
      continue ; // it became free: retry the plain CAS
    }
    if (t0 == 0ULL) t0 = atscntrb_afiber_clock_ns() ;
    atscntrb_afiber_waitq_park((atstype_ptr)&(m->q), (atstype_ptr)&(m->lock)) ;
    atscntrb_afiber__spin_unlock(&(m->lock)) ;
    // woken (WOKEN was set by the unlocker), or handed the mutex (STARVING)
    starving = starving || (atscntrb_afiber_clock_ns() - t0 > ATSCNTRB_AFIBER_MX_STARVE_NS) ;
    old = atscntrb_afiber__mx_load(s) ;
    if (old & ATSCNTRB_AFIBER_MX_STARVING) {
      // the mutex was handed to us: take LOCKED, drop our waiter count,
      // leave the starving mode if we did not wait long or are the last
      unsigned int delta = ATSCNTRB_AFIBER_MX_LOCKED - ATSCNTRB_AFIBER_MX_ONE ;
      if (!starving || (old >> ATSCNTRB_AFIBER_MX_SHIFT) == 1) delta -= ATSCNTRB_AFIBER_MX_STARVING ;
      if (atscntrb_afiber__mt()) __atomic_add_fetch(s, delta, __ATOMIC_ACQ_REL) ;
      else *s += delta ;
      return ;
    }
    awoke = 1 ; iter = 0 ;
  }
} // end of [atscntrb_afiber__mx_lock_slow]

ATSinline()
void
atscntrb_afiber_mutex_lock
  (atstype_ptr m0)
{
  atscntrb_afiber_mutex_t *m = (atscntrb_afiber_mutex_t*)m0 ;
  if (!atscntrb_afiber__mt()) {
    if (m->state == 0) { m->state = ATSCNTRB_AFIBER_MX_LOCKED ; return ; }
  } else {
    unsigned int z = 0 ;
    if (__atomic_compare_exchange_n(&(m->state), &z, ATSCNTRB_AFIBER_MX_LOCKED, 0, __ATOMIC_ACQUIRE, __ATOMIC_RELAXED)) return ;
  }
  atscntrb_afiber__mx_lock_slow(m) ;
} // end of [atscntrb_afiber_mutex_lock]

__attribute__((noinline))
static
void
atscntrb_afiber__mx_unlock_slow
  (atscntrb_afiber_mutex_t *m, unsigned int old)
{
  unsigned int *s = &(m->state) ;
  if (!(old & ATSCNTRB_AFIBER_MX_STARVING)) {
    for ( ; ; ) {
      // nobody to wake, or somebody is awake / holds it: nothing to do
      if ((old >> ATSCNTRB_AFIBER_MX_SHIFT) == 0
          || (old & (ATSCNTRB_AFIBER_MX_LOCKED | ATSCNTRB_AFIBER_MX_WOKEN | ATSCNTRB_AFIBER_MX_STARVING))) return ;
      if (atscntrb_afiber__mx_cas(s, &old, (old - ATSCNTRB_AFIBER_MX_ONE) | ATSCNTRB_AFIBER_MX_WOKEN)) break ;
    }
  }
  // (starving: hand-off, the woken fiber takes LOCKED and the count itself)
  atscntrb_afiber__spin_lock(&(m->lock)) ;
  atscntrb_afiber_waitq_wake_one((atstype_ptr)&(m->q)) ;
  atscntrb_afiber__spin_unlock(&(m->lock)) ;
} // end of [atscntrb_afiber__mx_unlock_slow]

ATSinline()
void
atscntrb_afiber_mutex_unlock
  (atstype_ptr m0)
{
  atscntrb_afiber_mutex_t *m = (atscntrb_afiber_mutex_t*)m0 ;
  unsigned int nw ;
  if (!atscntrb_afiber__mt()) nw = (m->state -= ATSCNTRB_AFIBER_MX_LOCKED) ;
  else nw = __atomic_sub_fetch(&(m->state), ATSCNTRB_AFIBER_MX_LOCKED, __ATOMIC_ACQ_REL) ;
  if (nw != 0) atscntrb_afiber__mx_unlock_slow(m, nw) ;
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
