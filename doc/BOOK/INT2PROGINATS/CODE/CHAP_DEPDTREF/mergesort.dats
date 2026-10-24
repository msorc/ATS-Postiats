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
** Example: mergesort on lists (redux)
**
** Updated for the linear-only dialect of ATS2 (no GC): the sorting consumes its list
*)

(* ****** ****** *)

#include "share/atspre_staload.hats"

datavtype
mylist (a:t@ype+, int) =
  | mylist_nil (a, 0) of () // [of ()] is optional
  | {n:nat} mylist_cons (a, n+1) of (a, mylist(a, n))

fun{a:t@ype}
mylist_length
  {n:nat} .<n>.
  (xs: !mylist(a, n)): int(n) =
  case+ xs of
  | mylist_nil() => 0
  | mylist_cons(_, xs1) => 1 + mylist_length<a>(xs1)

fun
{a:t@ype}
mylist_reverse_append
  {m,n:nat} .<m>.
(
  xs: mylist(a, m)
, ys: mylist(a, n)
) : mylist(a, m+n) =
(
  case+ xs of
  | ~mylist_nil() => ys
  | ~mylist_cons(x, xs) =>
      mylist_reverse_append<a>(xs, mylist_cons(x, ys))
) (* end of [mylist_reverse_append] *)

fun
{a:t@ype}
mylist_reverse{n:nat} .<>. // defined non-recursively
  (xs: mylist(a, n)): mylist(a, n) = mylist_reverse_append<a>(xs, mylist_nil())

fun{a:t@ype}
mylist_free{n:nat} .<n>. (xs: mylist(a, n)): void =
  case+ xs of
  | ~mylist_nil () => () | ~mylist_cons (_, xs) => mylist_free<a> (xs)

//
typedef lte (a:t@ype) = (a, a) -> bool
//
fun{
a:t@ype
} merge
  {m,n:nat} .<m+n>.
(
  xs0: mylist(a, m), ys0: mylist(a, n), lte: lte a
) : mylist(a, m+n) =
  case+ xs0 of
  | ~mylist_nil() => ys0
  | ~mylist_cons(x, xs1) =>
    (
    case+ ys0 of
    | ~mylist_nil() => mylist_cons(x, xs1)
    | ~mylist_cons(y, ys1) =>
        if x \lte y
          then mylist_cons(x, merge (xs1, mylist_cons(y, ys1), lte))
          else mylist_cons(y, merge (mylist_cons(x, xs1), ys1, lte))
        // end of [if]
    ) // end of [mylist_cons]
// end of [merge]
//
fun{
a:t@ype
} mergesort{n:nat}
(
  xs: mylist(a, n), lte: lte a
) : mylist(a, n) = let
//
  fun msort
    {n:nat} .<n,n>.
  (
    xs: mylist(a, n), n: int n, lte: lte a
  ) : mylist(a, n) =
    if n >= 2
      then split(xs, n, lte, half(n), mylist_nil) else xs
    // end of [if]
  // end of [msort]
  and split
    {n:int | n >= 2}{i:nat | i <= n/2} .<n,i>.
  (
    xs: mylist(a, n-n/2+i)
  , n: int(n), lte: lte a, i: int(i), xsf: mylist(a, n/2-i)
  ) : mylist(a, n) =
    if i > 0 then let
      val ~mylist_cons(x, xs) = xs
    in
      split(xs, n, lte, i-1, mylist_cons(x, xsf))
    end else let
      val n2 = half(n)
      val xsf = mylist_reverse<a>(xsf) // make sorting stable!
      val xsf = msort(xsf, n2, lte) and xs = msort (xs, n-n2, lte)
    in
      merge(xsf, xs, lte)
    end // end of [if]
  // end of [split]
//
  val n = mylist_length<a>(xs)
//
in
  msort(xs, n, lte)
end // end of [mergesort]

fun print_ints{n:nat}(xs: !mylist(int, n)): void =
  case+ xs of
  | mylist_nil () => print_newline ()
  | mylist_cons (x, xs) => (print x; print ' '; print_ints (xs))

implement main0 () = {
  val xs = mylist_cons (8, mylist_cons (3, mylist_cons (4, mylist_cons (1, mylist_cons (2, mylist_cons (7, mylist_cons (6, mylist_cons (5, mylist_cons (9, mylist_nil ())))))))))
  val ys = mergesort<int> (xs, lam (x, y) => x <= y)
  val () = print_ints (ys)
  val () = assertloc (mylist_length<int> (ys) = 9)
  val () = mylist_free<int> (ys)
}

(* ****** ****** *)

(* end of [mergesort.dats] *)
