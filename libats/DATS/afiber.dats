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
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/afiber.sats"

(* ****** ****** *)

implement
{}(*tmp*)
afiber_spawn_sz
  (fwork, stacksz) = let
//
fun app
(
  f: () -<lincloptr1> void
): void = let
  val () = f () in cloptr_free($UN.castvwtp0{cloptr0}(f))
end // end of [app]
//
in
  afiber_create_funenv (app, fwork, stacksz)
end // end of [afiber_spawn_sz]

implement
{}(*tmp*)
afiber_spawn (fwork) =
  afiber_spawn_sz (fwork, afiber_stacksz_default ())
// end of [afiber_spawn]

(* ****** ****** *)

implement
{}(*tmp*)
afiber_spawn_detached_sz
  (fwork, stacksz) = let
//
fun app
(
  f: () -<lincloptr1> void
): void = let
  val () = f () in cloptr_free($UN.castvwtp0{cloptr0}(f))
end // end of [app]
//
in
  afiber_create_funenv_detached (app, fwork, stacksz)
end // end of [afiber_spawn_detached_sz]

implement
{}(*tmp*)
afiber_spawn_detached (fwork) =
  afiber_spawn_detached_sz (fwork, afiber_stacksz_default ())
// end of [afiber_spawn_detached]

(* ****** ****** *)

implement
{}(*tmp*)
afiber_sleep_usec (us) = afiber_sleep_ns (us * $UN.cast{ullint}(1000))
implement
{}(*tmp*)
afiber_sleep_msec (ms) = afiber_sleep_ns (ms * $UN.cast{ullint}(1000000))

(* ****** ****** *)

(* end of [afiber.dats] *)
