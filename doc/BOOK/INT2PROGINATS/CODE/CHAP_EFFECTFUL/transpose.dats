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
** Example: matrix transposition
**
** Updated for the linear-only dialect of ATS2 (no GC): a matrix is a matrixptr, which is freed explicitly
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun{a:t@ype}
matrixptr_transpose
  {n:nat}
(
  M: !matrixptr(a, n, n), n: int(n)
) : void = let
//
fun loop1
  {i:nat | i <= n}
  (M: !matrixptr(a, n, n), i: int(i)): void =
  if i < n then loop2(M, i, 0) else ()
//
and loop2
  {i,j:nat | i < n; j <= i}
  (M: !matrixptr(a, n, n), i: int(i), j: int(j)): void =
  if j < i then let
    val tmp = matrixptr_get_at_int (M, i, n, j)
    val x = matrixptr_get_at_int (M, j, n, i)
    val () = matrixptr_set_at_int (M, i, n, j, x)
    val () = matrixptr_set_at_int (M, j, n, i, tmp)
  in
    loop2(M, i, j+1)
  end else loop1(M, i+1) // end of [if]
//
in
  loop1 (M, 0)
end // end of [matrixptr_transpose]

implement main0 () = {
  val M = matrixptr_make_elt<int> (i2sz(3), i2sz(3), 0)
  val () = matrixptr_set_at_int (M, 0, 3, 1, 5)
  val () = matrixptr_transpose<int> (M, 3)
  val x = matrixptr_get_at_int (M, 1, 3, 0)
  val () = println! (x)
  val () = matrixptr_free (M)
}

(* ****** ****** *)

(* end of [transpose.dats] *)
