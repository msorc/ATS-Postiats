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
** Example: a datatype with constructors that have arguments
** is linear (datavtype): its values must be consumed
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype intopt =
  | intopt_none of () | intopt_some of (int)
// end of [intopt]

(* ****** ****** *)
//
// the argument is borrowed
//
fun intopt_get (x: !intopt): int =
  case+ x of intopt_none () => ~1 | intopt_some (n) => n
//
// the argument is consumed
//
fun intopt_free (x: intopt): void =
  case+ x of ~intopt_none () => () | ~intopt_some (_) => ()

(* ****** ****** *)

implement
main0 () =
{
//
val x = intopt_some (1)
val () = assertloc (intopt_get (x) = 1)
val () = intopt_free (x)
//
val y = intopt_none ()
val () = assertloc (intopt_get (y) = ~1)
val () = intopt_free (y)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [intopt.dats] *)
