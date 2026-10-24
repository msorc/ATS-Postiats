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
** Termination-checking and dependent types for debugging
**
** Metrics for recursive functions
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun fact {n:nat} .<n>.
  (x: int n): int = if x > 0 then x * fact(x-1) else 1
// end of [fact]

fun f91 {i:int} .<max(101-i,0)>. (x: int i)
  : [j:int | (i < 101 && j==91) || (i >= 101 && j==i-10)] int(j) =
  if x >= 101 then x-10 else f91 (f91 (x+11))
// end of [f91]

fun acker
  {m,n:nat} .<m,n>.
  (x: int m, y: int n): Nat =
  if x > 0
    then (
     if y > 0 then acker(x-1, acker(x, y-1)) else acker(x-1, 1)
    ) else y + 1
// end of [acker]

fun isevn
  {n:nat} .<2*n>.
  (n: int n) : bool =
  if n = 0 then true else isodd(n-1)
and isodd
  {n:nat} .<2*n+1>.
  (n: int n) : bool = not(isevn(n))

fun
isqrt
{x:nat}
(
  x: int x
) : int = let
//
fun
search
{x,l,r:nat | l < r} .<r-l>.
(
  x: int x, l: int l, r: int r
) : int = let
  val diff = r - l
in
  case+ 0 of
  | _ when diff > 1 => let
      val m = l + half(diff)
    in
      if x / m < m
        then search(x, l, m) else search(x, m, r)
      // end of [if]
    end // end of [if]
  | _ (* diff <= 1 *) => l (* the result is found *)
end // end of [search]
//
in
  if x > 0 then search(x, 0, x) else 0
end // end of [isqrt]

implement
main0 () =
{
//
val () = assertloc (fact (5) = 120)
val () = assertloc (f91 (50) = 91)
val () = assertloc (acker (2, 3) = 9)
val () = assertloc (isevn (10))
val () = assertloc (~isodd (10))
val () = assertloc (isqrt (99) = 9)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [terminate.dats] *)
