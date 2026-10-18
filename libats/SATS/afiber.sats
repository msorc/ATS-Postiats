(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2014 Hongwei Xi, ATS Trustful Software, Inc.
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
*)


(* ****** ****** *)
//
// HX-2026-10:
// afiber: stackful cooperative fibers (green threads)
// on one OS thread, with no GC.
//
// A fiber handle [afiber_vt] is linear: it must be joined
// or detached. Spawning never switches; [afiber_yield],
// [afiber_join], [afiber_sleep_*] and the wait queues do.
// Exceptions work within a fiber (the handler chain is per
// fiber); an uncaught exception ends the process, as with
// athread. If main returns while fibers are suspended, they
// are discarded: end main with [afiber_run_until_done].
// A stack overflow hits a guard page (SIGSEGV): pass a
// larger size to [afiber_spawn_sz] for deep recursion.
//
(* ****** ****** *)

%{#
#include "libats/CATS/afiber.cats"
%} // end of [%{#]

(* ****** ****** *)
//
#define
ATS_PACKNAME "ATSLIB.libats.afiber"
#define
ATS_EXTERN_PREFIX "atslib_" // prefix for external names
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
// wait queues: the parking primitive (in place of condvars)
//
absvtype
afiber_waitq_vtype = ptr
vtypedef afiber_waitq = afiber_waitq_vtype
//
fun afiber_waitq_make ((*void*)): afiber_waitq = "mac#%"
fun afiber_waitq_free (q: afiber_waitq): void = "mac#%" // fatal if a fiber is parked
//
fun afiber_waitq_is_empty (q: !afiber_waitq): bool = "mac#%"
//
fun afiber_waitq_park (q: !afiber_waitq): void = "mac#%" // returns when woken
fun afiber_waitq_wake_one (q: !afiber_waitq): bool = "mac#%"
fun afiber_waitq_wake_all (q: !afiber_waitq): void = "mac#%"
//
(* ****** ****** *)

(* end of [afiber.sats] *)
