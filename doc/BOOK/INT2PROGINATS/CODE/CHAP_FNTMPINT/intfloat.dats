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
** Template-based support for late-binding
**
** Updated for the linear-only dialect of ATS2 (no GC): intfloat is a datavtype
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype
intfloat = INT of int | FLOAT of double

(* ****** ****** *)

fun
intfloat_free (x: intfloat): void =
  case+ x of ~INT _ => () | ~FLOAT _ => ()

(* ****** ****** *)
//
// the argument is borrowed
//
fun
print_intfloat
  (x: !intfloat): void =
(
case+ x of
| INT(int) => print_int(int)
| FLOAT(float) => print_double(float)
)

(* ****** ****** *)
//
fun
fprint_intfloat
(
  x: !intfloat
, print_int: int -> void
, print_double: double -> void
) : void =
(
case+ x of
| INT(int) => print_int(int)
| FLOAT(float) => print_double(float)
)
//
(* ****** ****** *)
//
extern
fun{}
tprint_int(int): void
extern
fun{}
tprint_double(double): void
extern
fun{}
tprint_intfloat(!intfloat): void
//
(* ****** ****** *)
//
implement
tprint_int<> (x) = print_int(x)
implement
tprint_double<> (x) = print_double(x)
//
(* ****** ****** *)
//
implement
tprint_intfloat<> (x) =
(
case+ x of
| INT(int) => tprint_int<> (int)
| FLOAT(float) => tprint_double<> (float)
)
//
(* ****** ****** *)

implement
main0 () =
{
//
val x0 = INT(0)
val x1 = FLOAT(1.0)
//
val () = (
  tprint_intfloat<> (x0); print_newline()
) (* end of [val] *)
//
val () = (
  tprint_intfloat<> (x1); print_newline()
) (* end of [val] *)
//
local
//
implement
tprint_int<> (x) = print! ("INT(", x, ")")
implement
tprint_double<> (x) = print! ("FLOAT(", x, ")")
//
in (* in-of-local *)
//
val () = (
  tprint_intfloat<> (x0); print_newline()
) (* end of [val] *)
//
val () = (
  tprint_intfloat<> (x1); print_newline()
) (* end of [val] *)
//
end // end of [local]
//
val ((*freed*)) = intfloat_free (x0)
val ((*freed*)) = intfloat_free (x1)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [intfloat.dats] *)
