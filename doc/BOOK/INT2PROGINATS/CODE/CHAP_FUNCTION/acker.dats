(*
** Copyright (C) 2011 Hongwei Xi, ATS Trustful Software, Inc.
**
** Permission is hereby granted, free of charge, to any person
** obtaining a copy of this software and associated documentation
** files (the "Software"), to deal in the Software without
** restriction, including without limitation the rights to use,
** copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following
** conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
** OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
** NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
** HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
** OTHER DEALINGS IN THE SOFTWARE.
*)

(* ****** ****** *)

(*
** Example:
** Implementations of the Ackermann function
**
** Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
** Time: January, 2011
*)

(* ****** ****** *)

(*
** Updated for the linear-only dialect of ATS2 (no GC):
** the curried version [acker2] is rejected by the compiler (a curried
** application constructs a cloref closure) and the version [acker3],
** which returns a cloptr closure, must free every closure it creates
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

fun acker1
  (m: int, n: int): int =
(
  if m > 0 then
    if n > 0 then acker1 (m-1, acker1 (m, n-1)) else acker1 (m-1, 1)
  else n+1 // end of [if]
)

(* ****** ****** *)
//
// A curried version that returns a linear closure; the caller
// of [acker3] is responsible for freeing the closure it receives
//
fun acker3 (m: int): (int) -<cloptr1> int =
lam (n: int): int =<cloptr1> let
//
  fun call (m: int, n: int): int = let
    val f = acker3 (m)
    val r = f (n)
    val () = cloptr_free ($UN.castvwtp0{cloptr(void)}(f))
  in
    r
  end // end of [call]
//
in
  if m > 0 then
    if n > 0 then call (m-1, call (m, n-1)) else call (m-1, 1)
  else n+1 // end of [if]
end // end of [acker3]

(* ****** ****** *)

implement
main0 () =
{
val () = assertloc (acker1 (3, 3) = 61)
val () = let
  val f = acker3 (3)
  val r = f (3)
  val () = cloptr_free ($UN.castvwtp0{cloptr(void)}(f))
in
  assertloc (r = 61)
end // end of [val]
} // end of [main0]

(* ****** ****** *)

(* end of [acker.dats]  *)
