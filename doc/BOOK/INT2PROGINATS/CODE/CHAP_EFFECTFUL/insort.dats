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
** Example: insertion sort on arrays
**
** Updated for the linear-only dialect of ATS2 (no GC): an array is an arrayptr, which is freed explicitly
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun{
a:t@ype
} insertion_sort
  {n:nat}
(
  A: !arrayptr(a, n)
, asz: int(n)
, cmp: (a, a) -> int
) : void = let
  fun
  ins
  {i:int | ~1 <= i; i+1 < n}
  (
    A: !arrayptr(a, n), x: a, i: int(i)
  ) : void =
    if i >= 0 then
    (
      if cmp(x, A[i]) < 0
        then let
          val y = A[i]
        in
          A[i+1] := y; ins(A, x, i-1)
        end
        else (A[i+1] := x)
      // end of [if]
    ) else A[0] := x // end of [if]
  // end of [ins]
  fun
  loop
  {i:int | 1 <= i}
  (
    A: !arrayptr(a, n), i: int(i)
  ) : void =
    if i < asz then let
      val x = A[i]
    in
      ins(A, x, i-1); loop(A, i+1)
    end else ()
  // end of [loop]
in
  loop(A, 1)
end (* end of [insertion_sort] *)

implement main0 () = {
  val A = arrayptr_make_elt<int> (i2sz(5), 0)
  val () = A[0] := 5 and () = A[1] := 3 and () = A[2] := 4 and () = A[3] := 1 and () = A[4] := 2
  val () = insertion_sort<int> (A, 5, lam (x, y) => compare (x, y))
  val () = fprint_arrayptr (stdout_ref, A, i2sz(5))
  val () = print_newline ()
  val () = arrayptr_free (A)
}

(* ****** ****** *)

(* end of [insort.dats] *)
