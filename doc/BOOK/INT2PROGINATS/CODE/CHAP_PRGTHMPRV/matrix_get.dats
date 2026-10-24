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
** Example: safe matrix subscripting
**
** Updated for the linear-only dialect of ATS2 (no GC): the array is an arrayptr
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

%{^
#define imul2(x, y) ((x)*(y))
%}
extern
fun
imul2{i,j:int}
(
  i: int i, j: int j
) :<> [ij:int] (MUL(i, j, ij) | int ij) = "mac#imul2"

(* ****** ****** *)

extern
fun{
a:t@ype
} matrix_get
  {m,n:int}{i,j:nat | i < m; j < n}
  (A: !arrayptr (a, m*n), col: int n, i: int i, j: int j): (a)
// end of [matrix_get]

(* ****** ****** *)

(*
implement
{a}(*tmp*)
matrix_get (A, n, i, j) = A[i*n+j] // it fails to typecheck!!!
*)

implement
{a}(*tmp*)
matrix_get
  {m,n}{i,j}
  (A, n, i, j) = let
//
  val (pf | _in_) = imul2 (i, n)
//
  prval ((*void*)) = mul_elim(pf)
  prval ((*void*)) = mul_nat_nat_nat(pf)
  prval ((*void*)) = mul_gte_gte_gte{m-1-i,n}()
//
in
  A[_in_+j]
end // end of [matrix_get]

(* ****** ****** *)

implement
main0 () =
{
//
// a matrix of 2 rows and 3 columns
//
val A = arrayptr_make_elt<int> (i2sz(6), 0)
val () = A[4] := 7
val x = matrix_get<int>{2,3}{1,1} (A, 3, 1, 1)
val () = assertloc (x = 7)
val () = arrayptr_free (A)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [matrix_get.dats] *)
