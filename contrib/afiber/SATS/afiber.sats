(* ******************************************************************* *)
(*                                                                     *)
(*                         ATS/contrib/afiber                          *)
(*                                                                     *)
(* ******************************************************************* *)

(*
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
*)


(* ****** ****** *)
//
// MS-2026-10:
// afiber: stackful fibers (green threads) with no GC,
// scheduled cooperatively on one OS thread, or on several
// ([afiber_workers_start]).
//
// A fiber handle [afiber_vt] is linear: it must be joined
// or detached. Spawning never switches; [afiber_yield],
// [afiber_join], [afiber_sleep_*] and the wait queues do.
// An uncaught exception ends the process, as with athread.
// If main returns while fibers are suspended, they
// are discarded: end main with [afiber_run_until_done].
// A stack overflow hits a guard page (SIGSEGV): pass a
// larger size to [afiber_spawn_sz] for deep recursion.
// Default-size stacks are recycled through a free list
// ([afiber_spawn_sz] with another size is not cached).
// The same ATSCNTRB_AFIBER_* compile-time settings must be
// used in every unit of a program.
//
// One worker (the default): the main thread runs every fiber,
// switching only at the calls above; the order is FIFO and
// deterministic, nothing is a data race, and the handler chain
// of exceptions is swapped at every switch.
//
// M:N: [afiber_workers_start(n)] makes n-1 more OS threads run
// fibers from one shared FIFO. Compile every unit with
//   -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ -D_GNU_SOURCE
// (the flag makes the exception-frame head a field of the fiber,
// so that a fiber can migrate inside a [try]; without it
// [afiber_workers_start] with n > 1 is fatal). The main fiber stays
// on worker 0 (the main thread). A fiber may resume on another thread
// after any call that can block: do not keep thread-local state
// (errno, a lock owned by thread, __thread variables) across one.
// Fibers share memory: protect shared data with [afiber_mutex],
// a channel, or an [afiber_spin] (which must not be held across a
// call that blocks, except through [afiber_waitq_park]).
// The global arena of libats/arena and plain [ref]s are not
// thread-safe. Call [afiber_workers_stop] after
// [afiber_run_until_done] to join the threads and free their data.
//
(* ****** ****** *)

%{#
#include "contrib/afiber/CATS/afiber.cats"
%} // end of [%{#]

(* ****** ****** *)
//
#define
ATS_PACKNAME "ATSCNTRB.afiber"
#define
ATS_EXTERN_PREFIX "atscntrb_" // prefix for external names
//
(* ****** ****** *)
//
absvtype
afiber_vtype = ptr // joinable handle
vtypedef afiber_vt = afiber_vtype
//
typedef afiber_id = lint // nonlinear identity; main is 0
//
(* ****** ****** *)
//
fun
afiber_create_funenv
  {env:vtype}
(
  fwork: (env) -> void, env: env, stacksz: size_t
) : afiber_vt = "mac#%"
//
fun
afiber_create_funenv_detached
  {env:vtype}
(
  fwork: (env) -> void, env: env, stacksz: size_t
) : void = "mac#%"
//
(* ****** ****** *)
//
fun{}
afiber_spawn
  (fwork: () -<lincloptr1> void): afiber_vt
fun{}
afiber_spawn_sz
  (fwork: () -<lincloptr1> void, stacksz: size_t): afiber_vt
//
fun{}
afiber_spawn_detached
  (fwork: () -<lincloptr1> void): void
fun{}
afiber_spawn_detached_sz
  (fwork: () -<lincloptr1> void, stacksz: size_t): void
//
(* ****** ****** *)
//
fun afiber_yield ((*void*)): void = "mac#%"
//
fun afiber_join (fb: afiber_vt): void = "mac#%" // parks until done; frees
fun afiber_detach (fb: afiber_vt): void = "mac#%" // freed by the scheduler
//
fun afiber_get_id (fb: !afiber_vt): afiber_id = "mac#%"
fun afiber_is_done (fb: !afiber_vt): bool = "mac#%"
//
(* ****** ****** *)
//
fun afiber_self ((*void*)): afiber_id = "mac#%"
fun afiber_is_main ((*void*)): bool = "mac#%"
fun afiber_nlive ((*void*)): lint = "mac#%" // unfinished fibers, main excluded
//
fun afiber_run_until_done ((*void*)): void = "mac#%" // main only: park until nlive = 0
//
(* ****** ****** *)
//
fun afiber_sleep_ns (ns: ullint): void = "mac#%"
fun{} afiber_sleep_usec (us: ullint): void
fun{} afiber_sleep_msec (ms: ullint): void
//
fun afiber_clock_ns ((*void*)): ullint = "mac#%" // CLOCK_MONOTONIC
//
fun afiber_stacksz_default ((*void*)): size_t = "mac#%"
//
(* ****** ****** *)
//
// M:N scheduling
//
fun afiber_workers_start (n: int): void = "mac#%" // main only, once; n counts the main thread
fun afiber_workers_stop ((*void*)): void = "mac#%" // main only, no live fiber
fun afiber_nworkers ((*void*)): int = "mac#%"
fun afiber_worker_id ((*void*)): int = "mac#%" // 0 on the main thread
fun afiber_ncpu ((*void*)): int = "mac#%"
//
(* ****** ****** *)
//
// spinlocks: for short critical sections; never block while held
//
absvtype
afiber_spin_vtype = ptr
vtypedef afiber_spin = afiber_spin_vtype
//
absview afiber_locked_v // some spinlock is held by this fiber
//
fun afiber_spin_make ((*void*)): afiber_spin = "mac#%"
fun afiber_spin_free (lk: afiber_spin): void = "mac#%" // fatal if held
//
fun afiber_spin_lock
  (lk: !afiber_spin): (afiber_locked_v | void) = "mac#%"
fun afiber_spin_unlock
  (pf: afiber_locked_v | lk: !afiber_spin): void = "mac#%"
//
(* ****** ****** *)
//
// wait queues: the parking primitive (in place of condvars).
// A queue is protected by a spinlock that the caller holds.
//
absvtype
afiber_waitq_vtype = ptr
vtypedef afiber_waitq = afiber_waitq_vtype
//
fun afiber_waitq_make ((*void*)): afiber_waitq = "mac#%"
fun afiber_waitq_free (q: afiber_waitq): void = "mac#%" // fatal if a fiber is parked
//
fun afiber_waitq_is_empty
  (pf: !afiber_locked_v | q: !afiber_waitq): bool = "mac#%"
//
// [park] queues the fiber, releases [lk] once the fiber has switched
// off its stack, and takes [lk] again before it returns (so a woken
// fiber must re-check its condition)
fun afiber_waitq_park
  (pf: !afiber_locked_v | q: !afiber_waitq, lk: !afiber_spin): void = "mac#%"
fun afiber_waitq_wake_one
  (pf: !afiber_locked_v | q: !afiber_waitq): bool = "mac#%"
fun afiber_waitq_wake_all
  (pf: !afiber_locked_v | q: !afiber_waitq): void = "mac#%"
//
(* ****** ****** *)
//
// a parking mutex (a fiber that waits lets its worker run others)
//
absvtype
afiber_mutex_vtype = ptr
vtypedef afiber_mutex = afiber_mutex_vtype
//
fun afiber_mutex_make ((*void*)): afiber_mutex = "mac#%"
fun afiber_mutex_free (m: afiber_mutex): void = "mac#%" // fatal if locked
fun afiber_mutex_lock (m: !afiber_mutex): void = "mac#%"
fun afiber_mutex_unlock (m: !afiber_mutex): void = "mac#%"
//
(* ****** ****** *)

(* end of [afiber.sats] *)
