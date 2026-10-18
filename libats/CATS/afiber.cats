/* ******************************************************************* */
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/* ******************************************************************* */

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2026 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
**
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
**
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*/

/* ****** ****** */

/*
** HX-2026-10:
** afiber: stackful cooperative fibers (green threads)
** on one OS thread, with no GC. Each fiber owns an mmap'd
** C stack (with a guard page) and is switched with ucontext.
** The scheduler is one weak global shared by every unit.
** The head of the exception-frame chain (setjmp/longjmp) is
** saved and restored per fiber at every switch.
*/

/* ****** ****** */

#ifndef ATSLIB_LIBATS_CATS_AFIBER
#define ATSLIB_LIBATS_CATS_AFIBER

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <ucontext.h>
#include <sys/mman.h>

/* ****** ****** */

#if defined(__SANITIZE_ADDRESS__)
#define ATSLIB_AFIBER_ASAN 1
#elif defined(__has_feature)
#if __has_feature(address_sanitizer)
#define ATSLIB_AFIBER_ASAN 1
#endif
#endif

#ifdef ATSLIB_AFIBER_ASAN
#include <sanitizer/common_interface_defs.h>
#endif

/* ****** ****** */

#ifndef ATSLIB_AFIBER_STACKSZ
#define ATSLIB_AFIBER_STACKSZ (256*1024)
#endif

/* ****** ****** */

enum {
  ATSLIB_AFIBER_RUNNABLE = 0
, ATSLIB_AFIBER_RUNNING = 1
, ATSLIB_AFIBER_BLOCKED = 2
, ATSLIB_AFIBER_SLEEPING = 3
, ATSLIB_AFIBER_WAITALL = 4
, ATSLIB_AFIBER_DEAD = 5
} ;

/* ****** ****** */

typedef
struct atslib_afiber_s
{
  ucontext_t ctx ;
  void *stack ; // the whole mmap'd region (guard page included); NULL for main
  size_t stacksz ;
  void *stack_lo ; // above the guard page
  size_t stack_usable ;
  void *exnframe ; // saved *my_atsexnframe_getref() while not running
  int state ;
  int detached ;
  void (*entry)(void*) ; // the ATS wrapper that runs and frees the closure
  void *env ;
  struct atslib_afiber_s *joiner ; // the fiber parked in [join] on this one
  struct atslib_afiber_s *next ; // the run queue, a wait queue or the sleep list
  unsigned long long deadline_ns ; // when SLEEPING
  void *asan_fake_stack ;
  long id ;
} atslib_afiber_t ;

typedef
struct {
  atslib_afiber_t *head ;
  atslib_afiber_t *tail ;
} atslib_afiber_q ; // a FIFO; also the object behind [afiber_waitq]

typedef
struct {
  atslib_afiber_t main ; // the OS thread's own context, id 0
  atslib_afiber_t *current ;
  atslib_afiber_t *prev ; // for the ASan [finish] call after a switch
  atslib_afiber_q runq ;
  atslib_afiber_t *sleepq ; // singly linked, ascending deadline
  atslib_afiber_t *reap ; // a dead detached fiber whose stack is no longer in use
  long nlive ; // fibers not yet dead, main excluded
  long nextid ;
  int inited ;
} atslib_afiber_sched_t ;

/* ****** ****** */

/*
** One scheduler per process, shared by every compilation
** unit that includes this file (a weak definition in each)
*/
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak)) atslib_afiber_sched_t atslib_afiber__sched ;
#else
static atslib_afiber_sched_t atslib_afiber__sched ; // per unit: documented limitation
#endif

/* ****** ****** */

ATSinline()
void
atslib_afiber__fatal
  (const char *msg)
{
  fprintf(stderr, "libats/afiber: %s\n", msg) ; abort() ;
} // end of [atslib_afiber__fatal]

/* ****** ****** */

ATSinline()
atslib_afiber_sched_t*
atslib_afiber__sched_get()
{
  atslib_afiber_sched_t *s = &atslib_afiber__sched ;
  if (!s->inited) {
    memset(s, 0, sizeof(*s)) ;
    s->main.state = ATSLIB_AFIBER_RUNNING ;
    s->main.id = 0 ;
    s->current = &(s->main) ;
    s->inited = 1 ;
  }
  return s ;
} // end of [atslib_afiber__sched_get]

/* ****** ****** */

ATSinline()
void
atslib_afiber__q_push
  (atslib_afiber_q *q, atslib_afiber_t *f)
{
  f->next = (atslib_afiber_t*)0 ;
  if (q->tail) q->tail->next = f ; else q->head = f ;
  q->tail = f ;
} // end of [atslib_afiber__q_push]

ATSinline()
atslib_afiber_t*
atslib_afiber__q_pop
  (atslib_afiber_q *q)
{
  atslib_afiber_t *f = q->head ;
  if (f) {
    q->head = f->next ;
    if (!q->head) q->tail = (atslib_afiber_t*)0 ;
    f->next = (atslib_afiber_t*)0 ;
  }
  return f ;
} // end of [atslib_afiber__q_pop]

/* ****** ****** */

ATSinline()
unsigned long long
atslib_afiber_clock_ns()
{
  struct timespec ts ;
  clock_gettime(CLOCK_MONOTONIC, &ts) ;
  return (unsigned long long)ts.tv_sec * 1000000000ULL + (unsigned long long)ts.tv_nsec ;
} // end of [atslib_afiber_clock_ns]

ATSinline()
atstype_size
atslib_afiber_stacksz_default()
{
  return (atstype_size)ATSLIB_AFIBER_STACKSZ ;
} // end of [atslib_afiber_stacksz_default]

/* ****** ****** */

ATSinline()
void
atslib_afiber__stack_alloc
  (atslib_afiber_t *f, size_t usable)
{
#ifdef ATSLIB_AFIBER_STACK_MALLOC
  f->stack = ATS_MALLOC(usable) ;
  f->stacksz = usable ;
  f->stack_lo = f->stack ;
  f->stack_usable = usable ;
#else
  size_t page = (size_t)sysconf(_SC_PAGESIZE) ;
  size_t total ;
  int flags = MAP_PRIVATE | MAP_ANONYMOUS ;
  void *base ;
#ifdef MAP_NORESERVE
  flags |= MAP_NORESERVE ;
#endif
#ifdef MAP_STACK
  flags |= MAP_STACK ;
#endif
  usable = (usable + page - 1) / page * page ;
  if (usable < 2*page) usable = 2*page ;
  total = page + usable ;
  base = mmap((void*)0, total, PROT_READ|PROT_WRITE, flags, -1, 0) ;
  if (base == MAP_FAILED) atslib_afiber__fatal("mmap for a fiber stack failed") ;
  if (mprotect(base, page, PROT_NONE) != 0) atslib_afiber__fatal("mprotect for a guard page failed") ;
  f->stack = base ;
  f->stacksz = total ;
  f->stack_lo = (char*)base + page ;
  f->stack_usable = usable ;
#endif
} // end of [atslib_afiber__stack_alloc]

ATSinline()
void
atslib_afiber__free
  (atslib_afiber_t *f)
{
  if (f->stack) {
#ifdef ATSLIB_AFIBER_STACK_MALLOC
    ATS_MFREE(f->stack) ;
#else
    munmap(f->stack, f->stacksz) ;
#endif
  }
  ATS_MFREE(f) ;
} // end of [atslib_afiber__free]

/* ****** ****** */

/*
** called right after a switch lands in the current fiber
*/
ATSinline()
void
atslib_afiber__resumed()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
#ifdef ATSLIB_AFIBER_ASAN
  __sanitizer_finish_switch_fiber
    (s->current->asan_fake_stack, (const void**)&(s->prev->stack_lo), &(s->prev->stack_usable)) ;
#endif
  if (s->reap) { atslib_afiber__free(s->reap) ; s->reap = (atslib_afiber_t*)0 ; }
} // end of [atslib_afiber__resumed]

ATSinline()
void
atslib_afiber__switch_to
  (atslib_afiber_t *next)
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *from = s->current ;
  s->prev = from ;
  s->current = next ;
  next->state = ATSLIB_AFIBER_RUNNING ;
#ifndef _ATS_CCOMP_EXCEPTION_NONE_
  {
    atsexnframe_ptr *hp = my_atsexnframe_getref() ;
    from->exnframe = (void*)(*hp) ;
    *hp = (atsexnframe_ptr)(next->exnframe) ;
  }
#endif
#ifdef ATSLIB_AFIBER_ASAN
  __sanitizer_start_switch_fiber
    (from->state == ATSLIB_AFIBER_DEAD ? (void**)0 : &(from->asan_fake_stack), next->stack_lo, next->stack_usable) ;
#endif
  if (swapcontext(&(from->ctx), &(next->ctx)) != 0) atslib_afiber__fatal("swapcontext failed") ;
  atslib_afiber__resumed() ;
} // end of [atslib_afiber__switch_to]

/* ****** ****** */

ATSinline()
void
atslib_afiber__wake
  (atslib_afiber_t *f)
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  f->state = ATSLIB_AFIBER_RUNNABLE ;
  atslib_afiber__q_push(&(s->runq), f) ;
} // end of [atslib_afiber__wake]

/*
** the caller has already re-queued, parked or killed the current fiber
*/
ATSinline()
void
atslib_afiber__schedule()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *next ;
  for ( ; ; ) {
    if (s->sleepq) {
      unsigned long long now = atslib_afiber_clock_ns() ;
      while (s->sleepq && s->sleepq->deadline_ns <= now) {
        atslib_afiber_t *f = s->sleepq ; s->sleepq = f->next ; atslib_afiber__wake(f) ;
      }
    }
    next = atslib_afiber__q_pop(&(s->runq)) ;
    if (next) break ;
    if (s->sleepq) {
      unsigned long long now = atslib_afiber_clock_ns() ;
      unsigned long long dl = s->sleepq->deadline_ns ;
      if (dl > now) {
        struct timespec ts ;
        ts.tv_sec = (time_t)((dl - now) / 1000000000ULL) ;
        ts.tv_nsec = (long)((dl - now) % 1000000000ULL) ;
        nanosleep(&ts, (struct timespec*)0) ;
      }
      continue ;
    }
    atslib_afiber__fatal("deadlock: every fiber is blocked") ;
  }
  if (next == s->current) { next->state = ATSLIB_AFIBER_RUNNING ; return ; }
  atslib_afiber__switch_to(next) ;
} // end of [atslib_afiber__schedule]

/* ****** ****** */

static
void
atslib_afiber__trampoline()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *f = s->current ;
  atslib_afiber__resumed() ;
  f->entry(f->env) ;
  f->state = ATSLIB_AFIBER_DEAD ;
  s->nlive -= 1 ;
  if (f->joiner) {
    atslib_afiber_t *j = f->joiner ; f->joiner = (atslib_afiber_t*)0 ; atslib_afiber__wake(j) ;
  } else if (f->detached) {
    s->reap = f ;
  }
  if (s->nlive == 0 && s->main.state == ATSLIB_AFIBER_WAITALL) atslib_afiber__wake(&(s->main)) ;
  atslib_afiber__schedule() ;
  atslib_afiber__fatal("a dead fiber was resumed") ;
} // end of [atslib_afiber__trampoline]

/* ****** ****** */

ATSinline()
atslib_afiber_t*
atslib_afiber__create
(
  void (*entry)(void*), void *env, size_t stacksz, int detached
) {
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *f = ATS_MALLOC(sizeof(atslib_afiber_t)) ;
  memset(f, 0, sizeof(atslib_afiber_t)) ;
  atslib_afiber__stack_alloc(f, stacksz) ;
  if (getcontext(&(f->ctx)) != 0) atslib_afiber__fatal("getcontext failed") ;
  f->ctx.uc_stack.ss_sp = f->stack_lo ;
  f->ctx.uc_stack.ss_size = f->stack_usable ;
  f->ctx.uc_link = (ucontext_t*)0 ;
  makecontext(&(f->ctx), atslib_afiber__trampoline, 0) ;
  f->entry = entry ;
  f->env = env ;
  f->detached = detached ;
  f->state = ATSLIB_AFIBER_RUNNABLE ;
  f->id = ++(s->nextid) ;
  s->nlive += 1 ;
  atslib_afiber__q_push(&(s->runq), f) ;
  return f ;
} // end of [atslib_afiber__create]

/* ****** ****** */

#define \
atslib_afiber_create_funenv(fwork, env, sz) \
  ((atstype_ptr)atslib_afiber__create((void(*)(void*))(fwork), (void*)(env), (size_t)(sz), 0))
#define \
atslib_afiber_create_funenv_detached(fwork, env, sz) \
  ((void)atslib_afiber__create((void(*)(void*))(fwork), (void*)(env), (size_t)(sz), 1))

/* ****** ****** */

ATSinline()
void
atslib_afiber_yield()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber__wake(s->current) ;
  atslib_afiber__schedule() ;
} // end of [atslib_afiber_yield]

ATSinline()
void
atslib_afiber_join
  (atstype_ptr fb)
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *f = (atslib_afiber_t*)fb ;
  if (f == s->current) atslib_afiber__fatal("a fiber cannot join itself") ;
  if (f->state != ATSLIB_AFIBER_DEAD) {
    if (f->joiner) atslib_afiber__fatal("a fiber is joined twice") ;
    f->joiner = s->current ;
    s->current->state = ATSLIB_AFIBER_BLOCKED ;
    atslib_afiber__schedule() ;
  }
  atslib_afiber__free(f) ;
} // end of [atslib_afiber_join]

ATSinline()
void
atslib_afiber_detach
  (atstype_ptr fb)
{
  atslib_afiber_t *f = (atslib_afiber_t*)fb ;
  if (f->state == ATSLIB_AFIBER_DEAD) atslib_afiber__free(f) ; else f->detached = 1 ;
} // end of [atslib_afiber_detach]

ATSinline()
atstype_lint
atslib_afiber_get_id
  (atstype_ptr fb)
{
  return (atstype_lint)(((atslib_afiber_t*)fb)->id) ;
} // end of [atslib_afiber_get_id]

ATSinline()
atstype_bool
atslib_afiber_is_done
  (atstype_ptr fb)
{
  return (((atslib_afiber_t*)fb)->state == ATSLIB_AFIBER_DEAD) ? atsbool_true : atsbool_false ;
} // end of [atslib_afiber_is_done]

ATSinline()
atstype_lint
atslib_afiber_self()
{
  return (atstype_lint)(atslib_afiber__sched_get()->current->id) ;
} // end of [atslib_afiber_self]

ATSinline()
atstype_bool
atslib_afiber_is_main()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  return (s->current == &(s->main)) ? atsbool_true : atsbool_false ;
} // end of [atslib_afiber_is_main]

ATSinline()
atstype_lint
atslib_afiber_nlive()
{
  return (atstype_lint)(atslib_afiber__sched_get()->nlive) ;
} // end of [atslib_afiber_nlive]

ATSinline()
void
atslib_afiber_run_until_done()
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  if (s->current != &(s->main)) atslib_afiber__fatal("afiber_run_until_done: not the main fiber") ;
  if (s->nlive == 0) return ;
  s->main.state = ATSLIB_AFIBER_WAITALL ;
  atslib_afiber__schedule() ;
} // end of [atslib_afiber_run_until_done]

ATSinline()
void
atslib_afiber_sleep_ns
  (unsigned long long ns)
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  atslib_afiber_t *f = s->current ;
  atslib_afiber_t **pp ;
  if (ns == 0) { atslib_afiber_yield() ; return ; }
  f->deadline_ns = atslib_afiber_clock_ns() + ns ;
  f->state = ATSLIB_AFIBER_SLEEPING ;
  pp = &(s->sleepq) ;
  while (*pp && (*pp)->deadline_ns <= f->deadline_ns) pp = &((*pp)->next) ;
  f->next = *pp ; *pp = f ;
  atslib_afiber__schedule() ;
} // end of [atslib_afiber_sleep_ns]

/* ****** ****** */

ATSinline()
atstype_ptr
atslib_afiber_waitq_make()
{
  atslib_afiber_q *q = ATS_MALLOC(sizeof(atslib_afiber_q)) ;
  q->head = (atslib_afiber_t*)0 ; q->tail = (atslib_afiber_t*)0 ;
  return (atstype_ptr)q ;
} // end of [atslib_afiber_waitq_make]

ATSinline()
void
atslib_afiber_waitq_free
  (atstype_ptr q0)
{
  atslib_afiber_q *q = (atslib_afiber_q*)q0 ;
  if (q->head) atslib_afiber__fatal("afiber_waitq_free: a fiber is still parked") ;
  ATS_MFREE(q) ;
} // end of [atslib_afiber_waitq_free]

ATSinline()
atstype_bool
atslib_afiber_waitq_is_empty
  (atstype_ptr q0)
{
  return (((atslib_afiber_q*)q0)->head == (atslib_afiber_t*)0) ? atsbool_true : atsbool_false ;
} // end of [atslib_afiber_waitq_is_empty]

ATSinline()
void
atslib_afiber_waitq_park
  (atstype_ptr q0)
{
  atslib_afiber_sched_t *s = atslib_afiber__sched_get() ;
  s->current->state = ATSLIB_AFIBER_BLOCKED ;
  atslib_afiber__q_push((atslib_afiber_q*)q0, s->current) ;
  atslib_afiber__schedule() ;
} // end of [atslib_afiber_waitq_park]

ATSinline()
atstype_bool
atslib_afiber_waitq_wake_one
  (atstype_ptr q0)
{
  atslib_afiber_t *f = atslib_afiber__q_pop((atslib_afiber_q*)q0) ;
  if (!f) return atsbool_false ;
  atslib_afiber__wake(f) ; return atsbool_true ;
} // end of [atslib_afiber_waitq_wake_one]

ATSinline()
void
atslib_afiber_waitq_wake_all
  (atstype_ptr q0)
{
  atslib_afiber_t *f ;
  while ((f = atslib_afiber__q_pop((atslib_afiber_q*)q0))) atslib_afiber__wake(f) ;
} // end of [atslib_afiber_waitq_wake_all]

/* ****** ****** */

#endif // ifndef ATSLIB_LIBATS_CATS_AFIBER

/* ****** ****** */

/* end of [afiber.cats] */
