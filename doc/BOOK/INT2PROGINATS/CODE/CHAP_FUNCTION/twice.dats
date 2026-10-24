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
** A simple example of higher-order functions
**
** Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
** Time: May 10, 2013
*)

(* ****** ****** *)

(*
** Updated for the linear-only dialect of ATS2 (no GC):
** the original puzzle builds closures that are shared and applied
** repeatedly; with linear closures only the first level is expressible
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun{a:t@ype}
twice (f: &(a) -<clo1> a, x: a): a = f (f (x))

(* ****** ****** *)
//
val Z = 0
//
(* ****** ****** *)

implement
main0 () =
{
//
var S = lam@ (x: int): int => x + 1
//
val ans0 = twice<int> (S, Z)
//
val () = println! ("ans0 = ", ans0)
//
val () = assertloc (ans0 = 2)
//
} // end of [main0]

(* ****** ****** *)

(* end of [twice.dats]  *)
