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
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload M = "libats/libc/SATS/math.sats"
staload "./ratfun.sats"
staload _(*anon*) = "./ratfun.dats"
dynload "./ratfun.dats"

(* ****** ****** *)
//
// Specific implementations for the type [int]
//
implement intmod_ofint<int> (i) = i
implement intmod_fprint<int> (out, x) = fprint_int (out, x)
implement intmod_neg<int> (x) = ~x
implement intmod_add<int> (x, y) = x + y
implement intmod_sub<int> (x, y) = x - y
implement intmod_mul<int> (x, y) = x * y
implement intmod_div<int> (x, y) = x / y
implement intmod_mod<int> (x, y) = x mod y
implement intmod_cmp<int> (x, y) = compare (x, y)
//
(* ****** ****** *)
//
// Specific implementations for the type [double]
//
implement intmod_ofint<double> (i) = g0i2f(i)
implement intmod_fprint<double> (out, x) = fprint_double (out, x)
implement intmod_neg<double> (x) = ~x
implement intmod_add<double> (x, y) = x + y
implement intmod_sub<double> (x, y) = x - y
implement intmod_mul<double> (x, y) = x * y
implement intmod_div<double> (x, y) = $M.trunc_double (x / y) // truncation
implement intmod_mod<double> (x, y) = $M.fmod_double (x, y)
implement intmod_cmp<double> (x, y) = compare (x, y)
//
(* ****** ****** *)

implement
main0 () =
{
//
val r_1_2 = rat_make<int> (2, 4)
val () = fprintln! (stdout_ref, "r_1_2 = ", r_1_2)
//
val r_1_3 = rat_make<int> (~3, ~9)
val () = fprintln! (stdout_ref, "r_1_3 = ", r_1_3)
//
val r_5_6 = rat_add<int> (r_1_2, r_1_3)
val () = fprintln! (stdout_ref, "r_5_6 = ", r_5_6)
//
val r_1_6 = rat_sub<int> (r_1_2, r_1_3)
val () = fprintln! (stdout_ref, "r_1_6 = ", r_1_6)
//
val r_1_1 = rat_add<int> (r_5_6, r_1_6)
val () = fprintln! (stdout_ref, "r_1_1 = ", r_1_1)
//
val d_1_2 = rat_make<double> (2.0, 4.0)
val d_1_3 = rat_make<double> (~3.0, ~9.0)
val d_5_6 = rat_add<double> (d_1_2, d_1_3)
val () = fprintln! (stdout_ref, "d_5_6 = ", d_5_6)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test_ratfun.dats] *)
