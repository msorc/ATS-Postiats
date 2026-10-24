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

staload "./mylist.sats"
staload _(*anon*) = "./mylist.dats"

(* ****** ****** *)

extern
fun{a:t0p}
eq_elt_elt (x: a, y: a): bool // a generic equality

(* ****** ****** *)
//
// no meaningful generic implementation exists,
// and two specific template implementations are given
//
implement eq_elt_elt<int> (x, y) = g0int_eq (x, y)
implement eq_elt_elt<double> (x, y) = g0float_eq (x, y)

(* ****** ****** *)

fun{
a:t0p
} listeq
(
  xs: !mylist a
, ys: !mylist a
) : bool = (
  case+ xs of
  | mylist_cons (x, xs) =>
    (
      case+ ys of
      | mylist_cons (y, ys) =>
          if eq_elt_elt<a> (x, y) then listeq (xs, ys) else false
      | mylist_nil () => false
    ) (* end of [mylist_cons] *)
  | mylist_nil () =>
    (
      case+ ys of mylist_nil () => true | mylist_cons _ => false
    ) (* end of [mylist_nil] *)
) (* end of [listeq] *)

(* ****** ****** *)

fun{
a:t0p
} listeqf
(
  xs: !mylist a
, ys: !mylist a
, eq: (a, a) -> bool
) : bool = (
  case+ xs of
  | mylist_cons (x, xs) =>
    (
      case+ ys of
      | mylist_cons (y, ys) =>
          if eq (x, y) then listeqf (xs, ys, eq) else false
      | mylist_nil () => false
    ) (* end of [mylist_cons] *)
  | mylist_nil () =>
    (
      case+ ys of mylist_nil () => true | mylist_cons _ => false
    ) (* end of [mylist_nil] *)
) (* end of [listeqf] *)

(* ****** ****** *)

implement
main0 () =
{
//
val xs = mylist_cons (1, mylist_cons (2, mylist_nil ()))
val ys = mylist_cons (1, mylist_cons (2, mylist_nil ()))
val zs = mylist_cons (1, mylist_cons (3, mylist_nil ()))
//
val () = assertloc (listeq<int> (xs, ys))
val () = assertloc (~listeq<int> (xs, zs))
val () = assertloc (listeqf<int> (xs, ys, lam (x, y) => x = y))
//
val () = mylist_free (xs)
val () = mylist_free (ys)
val () = mylist_free (zs)
//
val xs = mylist_cons (1.0, mylist_nil ())
val ys = mylist_cons (1.0, mylist_nil ())
val () = assertloc (listeq<double> (xs, ys))
val () = mylist_free (xs)
val () = mylist_free (ys)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [listeq.dats] *)
