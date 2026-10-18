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
// afiber: stackful cooperative fibers (green threads)
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "contrib/afiber/SATS/afiber.sats"

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
