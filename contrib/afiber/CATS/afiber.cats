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
** afiber: stackful cooperative fibers (green threads)
** on one OS thread, with no GC. Each fiber owns an mmap'd
** C stack (with a guard page) and is switched by hand on x86-64 (ucontext elsewhere).
** The scheduler is one weak global shared by every unit.
** The stacks of finished fibers are recycled through a free list
** (ATSCNTRB_AFIBER_STACK_CACHE: 0 = unbounded, n = at most n cached
** stacks); cached stacks are not returned to the OS.
** The head of the exception-frame chain (setjmp/longjmp) is
** saved and restored per fiber at every switch.
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

#ifdef ATSCNTRB_AFIBER_ASAN
#include <sanitizer/common_interface_defs.h>
#include <sanitizer/asan_interface.h>
#endif

/* ****** ****** */

#ifndef ATSCNTRB_AFIBER_STACKSZ
#define ATSCNTRB_AFIBER_STACKSZ (256*1024)
#endif

#ifndef ATSCNTRB_AFIBER_STACK_CACHE
#define ATSCNTRB_AFIBER_STACK_CACHE 0
#endif

/* ****** ****** */

enum {
  ATSCNTRB_AFIBER_RUNNABLE = 0
, ATSCNTRB_AFIBER_RUNNING = 1
, ATSCNTRB_AFIBER_BLOCKED = 2
, ATSCNTRB_AFIBER_SLEEPING = 3
, ATSCNTRB_AFIBER_WAITALL = 4
, ATSCNTRB_AFIBER_DEAD = 5
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
  void *exnframe ; // saved *my_atsexnframe_getref() while not running
  int state ;
  int detached ;
  void (*entry)(void*) ; // the ATS wrapper that runs and frees the closure
  void *env ;
  struct atscntrb_afiber_s *joiner ; // the fiber parked in [join] on this one
  struct atscntrb_afiber_s *next ; // the run queue, a wait queue or the sleep list
  unsigned long long deadline_ns ; // when SLEEPING
  void *asan_fake_stack ;
  long id ;
} atscntrb_afiber_t ;

typedef
struct {
  atscntrb_afiber_t *head ;
  atscntrb_afiber_t *tail ;
} atscntrb_afiber_q ; // a FIFO; also the object behind [afiber_waitq]

typedef
struct {
  atscntrb_afiber_t main ; // the OS thread's own context, id 0
  atscntrb_afiber_t *current ;
  atscntrb_afiber_t *prev ; // for the ASan [finish] call after a switch
  atscntrb_afiber_q runq ;
  atscntrb_afiber_t *sleepq ; // singly linked, ascending deadline
  atscntrb_afiber_t *reap ; // a dead detached fiber whose stack is no longer in use
  void *stack_cache ; // free list of default-size stacks, linked through the word at stack_lo
  long ncached ;
  long nlive ; // fibers not yet dead, main excluded
  long nextid ;
  int inited ;
} atscntrb_afiber_sched_t ;

/* ****** ****** */

/*
** One scheduler per process, shared by every compilation
** unit that includes this file (a weak definition in each)
*/
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak)) atscntrb_afiber_sched_t atscntrb_afiber__sched ;
#else
static atscntrb_afiber_sched_t atscntrb_afiber__sched ; // per unit: documented limitation
#endif

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
  if (!s->inited) {
    memset(s, 0, sizeof(*s)) ;
    s->main.state = ATSCNTRB_AFIBER_RUNNING ;
    s->main.id = 0 ;
    s->current = &(s->main) ;
    s->inited = 1 ;
  }
  return s ;
} // end of [atscntrb_afiber__sched_get]

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
  (atscntrb_afiber_t *f, size_t usable)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  usable = atscntrb_afiber__stack_usable(usable) ;
  if (s->stack_cache
      && usable == atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ)) {
    void *lo = s->stack_cache ;
    s->stack_cache = *(void**)lo ;
    s->ncached -= 1 ;
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

ATSinline()
void
atscntrb_afiber__free
  (atscntrb_afiber_t *f)
{
  if (f->stack) {
    atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
    if (f->stacksz == atscntrb_afiber__stack_total
          (atscntrb_afiber__stack_usable((size_t)ATSCNTRB_AFIBER_STACKSZ))
        && (ATSCNTRB_AFIBER_STACK_CACHE == 0 || s->ncached < (long)(ATSCNTRB_AFIBER_STACK_CACHE))) {
#ifdef ATSCNTRB_AFIBER_ASAN
      __asan_unpoison_memory_region(f->stack_lo, f->stack_usable) ;
#endif
      *(void**)f->stack_lo = s->stack_cache ;
      s->stack_cache = f->stack_lo ;
      s->ncached += 1 ;
    } else {
#ifdef ATSCNTRB_AFIBER_STACK_MALLOC
      ATS_MFREE(f->stack) ;
#else
      munmap(f->stack, f->stacksz) ;
#endif
    }
  }
  ATS_MFREE(f) ;
} // end of [atscntrb_afiber__free]

/* ****** ****** */

/*
** called right after a switch lands in the current fiber
*/
ATSinline()
void
atscntrb_afiber__resumed()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
#ifdef ATSCNTRB_AFIBER_ASAN
  __sanitizer_finish_switch_fiber
    (s->current->asan_fake_stack, (const void**)&(s->prev->stack_lo), &(s->prev->stack_usable)) ;
#endif
  if (s->reap) { atscntrb_afiber__free(s->reap) ; s->reap = (atscntrb_afiber_t*)0 ; }
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

ATSinline()
void
atscntrb_afiber__switch_to
  (atscntrb_afiber_t *next)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *from = s->current ;
  s->prev = from ;
  s->current = next ;
  next->state = ATSCNTRB_AFIBER_RUNNING ;
#ifndef _ATS_CCOMP_EXCEPTION_NONE_
  {
    atsexnframe_ptr *hp = my_atsexnframe_getref() ;
    from->exnframe = (void*)(*hp) ;
    *hp = (atsexnframe_ptr)(next->exnframe) ;
  }
#endif
#ifdef ATSCNTRB_AFIBER_ASAN
  __sanitizer_start_switch_fiber
    (from->state == ATSCNTRB_AFIBER_DEAD ? (void**)0 : &(from->asan_fake_stack), next->stack_lo, next->stack_usable) ;
#endif
#ifdef ATSCNTRB_AFIBER_ASM
  atscntrb_afiber__swap(&(from->sp), next->sp) ;
#else
  if (swapcontext(&(from->ctx), &(next->ctx)) != 0) atscntrb_afiber__fatal("swapcontext failed") ;
#endif
  atscntrb_afiber__resumed() ;
} // end of [atscntrb_afiber__switch_to]

/* ****** ****** */

ATSinline()
void
atscntrb_afiber__wake
  (atscntrb_afiber_t *f)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  f->state = ATSCNTRB_AFIBER_RUNNABLE ;
  atscntrb_afiber__q_push(&(s->runq), f) ;
} // end of [atscntrb_afiber__wake]

/*
** the caller has already re-queued, parked or killed the current fiber
*/
ATSinline()
void
atscntrb_afiber__schedule()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *next ;
  for ( ; ; ) {
    if (s->sleepq) {
      unsigned long long now = atscntrb_afiber_clock_ns() ;
      while (s->sleepq && s->sleepq->deadline_ns <= now) {
        atscntrb_afiber_t *f = s->sleepq ; s->sleepq = f->next ; atscntrb_afiber__wake(f) ;
      }
    }
    next = atscntrb_afiber__q_pop(&(s->runq)) ;
    if (next) break ;
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
  if (next == s->current) { next->state = ATSCNTRB_AFIBER_RUNNING ; return ; }
  atscntrb_afiber__switch_to(next) ;
} // end of [atscntrb_afiber__schedule]

/* ****** ****** */

static
void
atscntrb_afiber__trampoline()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *f = s->current ;
  atscntrb_afiber__resumed() ;
  f->entry(f->env) ;
  f->state = ATSCNTRB_AFIBER_DEAD ;
  s->nlive -= 1 ;
  if (f->joiner) {
    atscntrb_afiber_t *j = f->joiner ; f->joiner = (atscntrb_afiber_t*)0 ; atscntrb_afiber__wake(j) ;
  } else if (f->detached) {
    s->reap = f ;
  }
  if (s->nlive == 0 && s->main.state == ATSCNTRB_AFIBER_WAITALL) atscntrb_afiber__wake(&(s->main)) ;
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
  atscntrb_afiber__stack_alloc(f, stacksz) ;
#ifdef ATSCNTRB_AFIBER_ASM
  {
    uintptr_t top = ((uintptr_t)f->stack_lo + f->stack_usable) & ~(uintptr_t)15 ;
    uint64_t *p = (uint64_t*)top ;
    unsigned int mxcsr ; unsigned short fcw ;
    __asm__ volatile ("stmxcsr %0" : "=m"(mxcsr)) ;
    __asm__ volatile ("fnstcw %0" : "=m"(fcw)) ;
    p[-1] = 0 ; // null return address: backtraces end here
    p[-2] = (uint64_t)(uintptr_t)&atscntrb_afiber__trampoline ;
    p[-3] = 0 ; p[-4] = 0 ; p[-5] = 0 ; p[-6] = 0 ; p[-7] = 0 ; p[-8] = 0 ; // rbp rbx r12-r15
    p[-9] = ((uint64_t)fcw << 32) | (uint64_t)mxcsr ; // mxcsr at +0, fcw at +4
    f->sp = (void*)(top - 72) ;
  }
#else
  if (getcontext(&(f->ctx)) != 0) atscntrb_afiber__fatal("getcontext failed") ;
  f->ctx.uc_stack.ss_sp = f->stack_lo ;
  f->ctx.uc_stack.ss_size = f->stack_usable ;
  f->ctx.uc_link = (ucontext_t*)0 ;
  makecontext(&(f->ctx), atscntrb_afiber__trampoline, 0) ;
#endif
  f->entry = entry ;
  f->env = env ;
  f->detached = detached ;
  f->state = ATSCNTRB_AFIBER_RUNNABLE ;
  f->id = ++(s->nextid) ;
  s->nlive += 1 ;
  atscntrb_afiber__q_push(&(s->runq), f) ;
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
  atscntrb_afiber__wake(s->current) ;
  atscntrb_afiber__schedule() ;
} // end of [atscntrb_afiber_yield]

ATSinline()
void
atscntrb_afiber_join
  (atstype_ptr fb)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *f = (atscntrb_afiber_t*)fb ;
  if (f == s->current) atscntrb_afiber__fatal("a fiber cannot join itself") ;
  if (f->state != ATSCNTRB_AFIBER_DEAD) {
    if (f->joiner) atscntrb_afiber__fatal("a fiber is joined twice") ;
    f->joiner = s->current ;
    s->current->state = ATSCNTRB_AFIBER_BLOCKED ;
    atscntrb_afiber__schedule() ;
  }
  atscntrb_afiber__free(f) ;
} // end of [atscntrb_afiber_join]

ATSinline()
void
atscntrb_afiber_detach
  (atstype_ptr fb)
{
  atscntrb_afiber_t *f = (atscntrb_afiber_t*)fb ;
  if (f->state == ATSCNTRB_AFIBER_DEAD) atscntrb_afiber__free(f) ; else f->detached = 1 ;
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
  return (((atscntrb_afiber_t*)fb)->state == ATSCNTRB_AFIBER_DEAD) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiber_is_done]

ATSinline()
atstype_lint
atscntrb_afiber_self()
{
  return (atstype_lint)(atscntrb_afiber__sched_get()->current->id) ;
} // end of [atscntrb_afiber_self]

ATSinline()
atstype_bool
atscntrb_afiber_is_main()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  return (s->current == &(s->main)) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiber_is_main]

ATSinline()
atstype_lint
atscntrb_afiber_nlive()
{
  return (atstype_lint)(atscntrb_afiber__sched_get()->nlive) ;
} // end of [atscntrb_afiber_nlive]

ATSinline()
void
atscntrb_afiber_run_until_done()
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  if (s->current != &(s->main)) atscntrb_afiber__fatal("afiber_run_until_done: not the main fiber") ;
  if (s->nlive == 0) return ;
  s->main.state = ATSCNTRB_AFIBER_WAITALL ;
  atscntrb_afiber__schedule() ;
} // end of [atscntrb_afiber_run_until_done]

ATSinline()
void
atscntrb_afiber_sleep_ns
  (unsigned long long ns)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  atscntrb_afiber_t *f = s->current ;
  atscntrb_afiber_t **pp ;
  if (ns == 0) { atscntrb_afiber_yield() ; return ; }
  f->deadline_ns = atscntrb_afiber_clock_ns() + ns ;
  f->state = ATSCNTRB_AFIBER_SLEEPING ;
  pp = &(s->sleepq) ;
  while (*pp && (*pp)->deadline_ns <= f->deadline_ns) pp = &((*pp)->next) ;
  f->next = *pp ; *pp = f ;
  atscntrb_afiber__schedule() ;
} // end of [atscntrb_afiber_sleep_ns]

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

ATSinline()
void
atscntrb_afiber_waitq_park
  (atstype_ptr q0)
{
  atscntrb_afiber_sched_t *s = atscntrb_afiber__sched_get() ;
  s->current->state = ATSCNTRB_AFIBER_BLOCKED ;
  atscntrb_afiber__q_push((atscntrb_afiber_q*)q0, s->current) ;
  atscntrb_afiber__schedule() ;
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

#endif // ifndef ATSCNTRB_AFIBER_CATS_AFIBER

/* ****** ****** */

/* end of [afiber.cats] */
