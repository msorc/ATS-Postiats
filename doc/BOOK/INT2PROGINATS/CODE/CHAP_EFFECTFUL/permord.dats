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
** Example: ordering permutations
**
** Updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun
print_intarray
  {n:nat}
(
  A: !arrayptr(int, n), asz: int(n)
) : void =
  loop(A, 0, ", ") where
{
//
// The integers are to be separated by the string [sep]
//
  fun loop
    {i:nat | i <= n}
  (
    A: !arrayptr(int, n), i: int(i), sep: string
  ) : void =
    if i < asz then let
      val () = if i > 0 then print sep
      val () = print A[i]
    in
      loop(A, i+1, sep)
    end // end of [if]
} (* end of [print_intarray] *)

fun
lrotate
  {n:nat}{i,j:int | 0 <= i; i <= j; j < n}
(
  A: !arrayptr(int, n), i: int(i), j: int(j)
) : void = let
  fun
  lshift
    {i,j:int | 0 <= i; i <= j; j < n}
  (
    A: !arrayptr(int, n), i: int(i), j: int(j)
  ) : void =
  if i < j then let
    val x = A[i+1]
  in
    A[i] := x; lshift(A, i+1, j)
  end // end of [if]
in
  if i < j then let
    val tmp = A[i] in lshift(A, i, j); A[j] := tmp
  end // end of [if]
end // end of [lrotate]

fun
rrotate
  {n:nat}{i,j:int | 0 <= i; i <= j; j < n}
(
  A: !arrayptr(int, n), i: int(i), j: int(j)
) : void = let
  fun
  rshift
    {i,j:int | 0 <= i; i <= j; j < n}
  (
    A: !arrayptr(int, n), i: int(i), j: int(j)
  ) : void =
  if i < j then let
    val x = A[j-1]
  in
    A[j] := x; rshift(A, i, j-1)
  end // end of [if]
in
  if i < j then let
    val tmp = A[j] in rshift(A, i, j); A[i] := tmp
  end // end of [if]
end // end of [rrotate]

fun
permute
  {n:nat}
(
 n: int(n)
) : void = let
//
// Creating array A of size n
//
  val A =
  arrayptr_make_elt<int>(i2sz(n), 0)
//
// Initializing A
// with integers from 1 to n, inclusive
//
  fun init
    {i:nat | i <= n}
    (A: !arrayptr(int, n), i: int(i)): void =
    if i < n
      then (A[i] := i+1; init(A, i+1))
    // end of [if]
//
  val () = init(A, 0)
//
  fun aux
    {i:int | 1 <= i; i <= n+1}
    (A: !arrayptr(int, n), i: int(i)): void =
  (
    if i <= n
      then aux2(A, i, i)
      else (
        print_intarray(A, n); print_newline()
      ) (* end of [else] *)
  ) (* end of [aux] *)
//
  and aux2
    {i,j:int | 1 <= i; i <= n; i <= j; j <= n+1}
    (A: !arrayptr(int, n), i: int(i), j: int(j)): void =
  (
    if j <= n then let
      val () = (
        rrotate(A, i-1, j-1); aux(A, i+1); lrotate(A, i-1, j-1)
      ) // end of [val]
    in
      aux2 (A, i, j + 1)
    end // end of [if]
  ) (* end of [aux2] *)
//
  val () = aux(A, 1)
in
  arrayptr_free(A)
end (* end of [permute] *)

implement main0 () = permute (3)

(* ****** ****** *)

(* end of [permord.dats] *)
