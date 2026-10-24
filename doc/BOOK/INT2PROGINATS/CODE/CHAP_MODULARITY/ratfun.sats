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
** A functorial package for rational numbers
**
** The integers that are employed in the representation of rational numbers
** are of an unspecified type [a]. The operations on these integers are
** function templates, for which there are no generic implementations:
** a specific implementation is to be given for each type of integers.
*)

(* ****** ****** *)

exception Denominator
exception DivisionByZero

(* ****** ****** *)
//
// the integer operations
//
fun{a:t0p} intmod_ofint (i: int): a
fun{a:t0p} intmod_fprint (out: FILEref, x: a): void
fun{a:t0p} intmod_neg (x: a): a // negation
fun{a:t0p} intmod_add (x: a, y: a): a // addition
fun{a:t0p} intmod_sub (x: a, y: a): a // subtraction
fun{a:t0p} intmod_mul (x: a, y: a): a // multiplication
fun{a:t0p} intmod_div (x: a, y: a): a // division
fun{a:t0p} intmod_mod (x: a, y: a): a // modulo operation
fun{a:t0p} intmod_cmp (x: a, y: a): int // comparison

(* ****** ****** *)

abst@ype rat(a:t@ype) = (a, a)

(* ****** ****** *)
//
fun{a:t0p} rat_make (p: a, q: a): rat a
//
fun{a:t0p} fprint_rat (out: FILEref, x: rat a): void
//
overload fprint with fprint_rat
//
fun{a:t0p} rat_numer (x: rat a): a // numerator of [x]
fun{a:t0p} rat_denom (x: rat a): a // denominator of [x]
//
fun{a:t0p} rat_neg (x: rat a): rat a // negation
fun{a:t0p} rat_add (x: rat a, y: rat a): rat a // addition
fun{a:t0p} rat_sub (x: rat a, y: rat a): rat a // subtraction
fun{a:t0p} rat_mul (x: rat a, y: rat a): rat a // multiplication
fun{a:t0p} rat_div (x: rat a, y: rat a): rat a // division
fun{a:t0p} rat_cmp (x: rat a, y: rat a): int // comparison
//
(* ****** ****** *)

(* end of [ratfun.sats] *)
