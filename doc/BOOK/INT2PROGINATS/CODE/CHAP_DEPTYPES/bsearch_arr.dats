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
** Example: binary search on arrays
**
** Updated for the linear-only dialect of ATS2 (no GC): an array is an arrayptr, which is borrowed by the search
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun{
a:t@ype
} bsearch_arr{n:nat}
(
  A: !arrayptr(a, n), n: int n, x0: a, cmp: (a, a) -> int
) : int = let
//
fun loop
  {i,j:int |
   0 <= i; i <= j+1; j+1 <= n}
(
  A: !arrayptr(a, n), l: int i, u: int j
) : int =
(
  if l <= u then let
    val m = l + half(u - l)
    val x = A[m]
    val sgn = cmp(x0, x)
  in
    if sgn >= 0 then loop(A, m+1, u) else loop(A, l, m-1)
  end else u // end of [if]
) (* end of [loop] *)
//
in
  loop(A, 0, n-1)
end // end of [bsearch_arr]

implement
main0 () =
{
//
val A = arrayptr_make_elt<int> (i2sz(5), 0)
val () = A[0] := 1 and () = A[1] := 3 and () = A[2] := 5 and () = A[3] := 7 and () = A[4] := 9
//
val cmp = lam (x: int, y: int): int => compare (x, y)
//
val () = assertloc (bsearch_arr<int> (A, 5, 6, cmp) = 2)
val () = assertloc (bsearch_arr<int> (A, 5, 0, cmp) = ~1)
val () = assertloc (bsearch_arr<int> (A, 5, 9, cmp) = 4)
//
val () = arrayptr_free (A)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [bsearch_arr.dats] *)
