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

staload "./ratfun.sats"

(* ****** ****** *)

assume rat(a:t@ype) = (a, a)

(* ****** ****** *)

fun{a:t0p}
gcd (m: a, n: a): a = let
//
val zero = intmod_ofint<a> (0)
//
fun aux (m: a, n: a): a =
  if intmod_cmp<a> (n, zero) > 0 then aux (n, intmod_mod<a> (m, n)) else m
//
fun abs (x: a): a =
  if intmod_cmp<a> (x, zero) >= 0 then x else intmod_neg<a> (x)
//
in
  aux (abs (m), abs (n))
end // end of [gcd]

(* ****** ****** *)

implement{a}
rat_make (p, q) = let
//
val zero = intmod_ofint<a> (0)
//
fun make
(
  p: a, q: a
) : rat(a) = let
  val r = gcd<a> (p, q)
in
  (intmod_div<a> (p, r), intmod_div<a> (q, r))
end // end of [make]
//
val () =
  if intmod_cmp<a> (q, zero) = 0 then $raise Denominator
//
in
  if intmod_cmp<a> (q, zero) > 0
    then make (p, q) else make (intmod_neg<a> (p), intmod_neg<a> (q))
  // end of [if]
end // end of [rat_make]

(* ****** ****** *)

implement{a}
fprint_rat
  (out, x) = {
//
val () = intmod_fprint<a> (out, x.0)
//
val one = intmod_ofint<a> (1)
//
val () =
  if intmod_cmp<a> (x.1, one) > 0 then (
    fprint_string (out, "/"); intmod_fprint<a> (out, x.1)
  ) (* end of [if] *)
//
} // end of [fprint_rat]

(* ****** ****** *)

implement{a} rat_numer (x) = x.0
implement{a} rat_denom (x) = x.1

(* ****** ****** *)

implement{a} rat_neg (x) = (intmod_neg<a> (x.0), x.1)

implement{a}
rat_add (x, y) =
  rat_make<a>
  (
    intmod_add<a> (intmod_mul<a> (x.0, y.1), intmod_mul<a> (x.1, y.0))
  , intmod_mul<a> (x.1, y.1)
  ) (* end of [rat_make] *)
// end of [rat_add]

implement{a}
rat_sub (x, y) =
  rat_make<a>
  (
    intmod_sub<a> (intmod_mul<a> (x.0, y.1), intmod_mul<a> (x.1, y.0))
  , intmod_mul<a> (x.1, y.1)
  ) (* end of [rat_make] *)
// end of [rat_sub]

implement{a}
rat_mul (x, y) =
  rat_make<a> (intmod_mul<a> (x.0, y.0), intmod_mul<a> (x.1, y.1))
// end of [rat_mul]

implement{a}
rat_div (x, y) = let
  val zero = intmod_ofint<a> (0)
in
  if intmod_cmp<a> (y.0, zero) = 0
    then $raise DivisionByZero
    else rat_make<a> (intmod_mul<a> (x.0, y.1), intmod_mul<a> (x.1, y.0))
  // end of [if]
end // end of [rat_div]

implement{a}
rat_cmp (x, y) =
  intmod_cmp<a> (intmod_mul<a> (x.0, y.1), intmod_mul<a> (x.1, y.0))
// end of [rat_cmp]

(* ****** ****** *)

(* end of [ratfun.dats] *)
