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
** Example: mergesort on lists
**
** Updated for the linear-only dialect of ATS2 (no GC):
** the lists are linear (datavtype) and the sorting functions
** consume their list arguments
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype
mylist (a:t@ype+) =
  | mylist_nil of () | mylist_cons of (a, mylist a)
// end of [mylist]

(* ****** ****** *)
//
// the following functions are the same as in [listfuns.dats]
//
fun{
a:t@ype
} mylist_length
  (xs: !mylist a): int =
(
  case+ xs of
  | mylist_cons (_, xs) => 1 + mylist_length<a> (xs) | mylist_nil () => 0
) (* end of [mylist_length] *)

fun{
a:t@ype
} mylist_free (xs: mylist a): void =
(
  case+ xs of
  | ~mylist_cons (_, xs) => mylist_free<a> (xs) | ~mylist_nil () => ()
) (* end of [mylist_free] *)

fun
{a:t@ype}
mylist_reverse_append
(
xs: mylist a, ys: mylist a
) : mylist a =
(
case+ xs of
| ~mylist_nil() => ys
| ~mylist_cons(x, xs) =>
    mylist_reverse_append<a> (xs, mylist_cons{a}(x, ys))
  // end of [mylist_cons]
) (* end of [mylist_reverse_append] *)

fun
{a:t@ype}
mylist_reverse
  (xs: mylist a): mylist a = mylist_reverse_append<a>(xs, mylist_nil)
// end of [mylist_reverse]

(* ****** ****** *)
//
#define :: mylist_cons // writing [::] for mylist_cons
#define cons0 mylist_cons // writing [cons0] for mylist_cons
#define nil0 mylist_nil // writing [nil0] for mylist_nil
//
(* ****** ****** *)
//
typedef
lte (a:t@ype) = (a, a) -> bool
//
fun{
a:t@ype
} merge (
  xs: mylist a, ys: mylist a, lte: lte a
) : mylist a =
(
  case+ xs of
  | ~cons0 (x, xs1) => (
    case+ ys of
    | ~cons0 (y, ys1) =>
        if x \lte y then
          cons0{a}(x, merge<a> (xs1, cons0{a}(y, ys1), lte))
        else
          cons0{a}(y, merge<a> (cons0{a}(x, xs1), ys1, lte))
        // end of [if]
    | ~nil0 () => cons0{a}(x, xs1)
    ) // end of [cons0]
  | ~nil0 () => ys
) (* end of [merge] *)
//
(* ****** ****** *)

fun{
a:t@ype
} mergesort
(
  xs: mylist(a), lte: lte(a)
) : mylist a = let
//
val n = mylist_length<a>(xs)
//
fun msort
(
  xs: mylist(a), n: int, lte: lte(a)
) : mylist a =
  if n >= 2 then split(xs, n, lte, n/2, nil0) else xs
//
and split
(
  xs: mylist(a), n: int, lte: lte(a), i: int, xsf: mylist(a)
) : mylist a =
  if i > 0 then let
    val-~cons0 (x, xs) = xs
  in
    split (xs, n, lte, i-1, cons0{a}(x, xsf))
  end else let
    val xsf = mylist_reverse<a>(xsf) // make sorting stable!
    val xsf = msort (xsf, n/2, lte) and xs = msort (xs, n-n/2, lte)
  in
    merge<a> (xsf, xs, lte)
  end // end of [if]
//
in
  msort (xs, n, lte)
end // end of [mergesort]

(* ****** ****** *)

fun
print_ints
  (xs: !mylist(int)): void =
(
case+ xs of
| nil0 () => print_newline ()
| cons0 (x, xs) => (print x; print ' '; print_ints (xs))
)

(* ****** ****** *)

implement
main0 () =
{
//
val xs =
  8 :: 3 :: 4 :: 1 :: 2 :: 7 :: 6 :: 5 :: 9 :: nil0 ()
//
val ys = mergesort<int> (xs, lam (x, y) => x <= y)
val () = print_ints (ys)
val () = assertloc (mylist_length (ys) = 9)
//
val () = mylist_free (ys)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [mergesort.dats] *)
