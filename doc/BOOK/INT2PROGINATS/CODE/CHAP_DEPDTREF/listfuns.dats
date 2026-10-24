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
** Example: function templates on lists (redux)
**
** Dependent lists as linear datatypes (datavtype): updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)

//
#include
"share/atspre_staload.hats"
//

datavtype
mylist (a:t@ype+, int) =
  | mylist_nil (a, 0) of () // [of ()] is optional
  | {n:nat} mylist_cons (a, n+1) of (a, mylist(a, n))

fun{
a:t@ype
} mylist_length
  {n:nat} .<n>.
  (xs: !mylist(a, n)): int(n) =
  case+ xs of
  | mylist_nil() => 0
  | mylist_cons(_, xs1) => 1 + mylist_length<a>(xs1)
// end of [mylist_length]

fun
{a:t@ype}
mylist_length2{n:nat} .<>.
  (xs: !mylist(a, n)): int(n) = let
//
fun loop{i,j:nat} .<i>.
  (xs: !mylist(a, i), j: int(j)): int(i+j) =
  case+ xs of
  | mylist_cons(_, xs1) => loop(xs1, j+1) | mylist_nil() => j
// end of [loop]
//
in
  loop(xs, 0)
end // end of [mylist_length2]

fun{
a:t@ype
} mylist_last
  {n:nat} .<>.
(
  xs: !mylist(a, n)
) : option_vt(a, n > 0) = let
//
fun loop
  {n:pos} .<n>.
(
  xs: !mylist(a, n)
) : a = let
  val+ mylist_cons(x, xs1) = xs
in
  case+ xs1 of
  | mylist_nil() => x
  | mylist_cons(_, _) => loop(xs1)
end // end of [loop]
//
in
  case+ xs of
  | mylist_nil() => None_vt() | mylist_cons _ => Some_vt(loop(xs))
end // end of [mylist_last]

fun
{a:t@ype}
mylist_append
  {m,n:nat} .<m>.
(
  xs: mylist(a, m)
, ys: mylist(a, n)
) : mylist(a, m+n) =
(
  case+ xs of
  | ~mylist_nil() => ys
  | ~mylist_cons(x, xs) => mylist_cons(x, mylist_append<a>(xs, ys))
) (* end of [mylist_append] *)

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
// end of [mylist_reverse]

fun{
a:t@ype}
{b:t@ype
} mylist_map
  {n:nat} .<n>.
(
  xs: !mylist(a, n), f: &(a) -<clo1> b
) : mylist(b, n) =
(
  case+ xs of
  | mylist_nil() => mylist_nil()
  | mylist_cons(x, xs) => let
      val y = f(x)
    in
      mylist_cons(y, mylist_map<a><b>(xs, f))
    end // end of [mylist_cons]
) (* end of [mylist_map] *)

fun{
a,b:t@ype
} mylist_zip
  {n:nat} .<n>.
(
  xs: !mylist(a, n)
, ys: !mylist(b, n)
) : mylist((a, b), n) =
(
  case+ xs of
  | mylist_nil() => mylist_nil((*void*))
  | mylist_cons(x, xs) =>
    (
      case+ ys of
      | mylist_cons(y, ys) => mylist_cons((x, y), mylist_zip<a,b>(xs, ys))
    )
) (* end of [mylist_zip] *)

fun{
a,b:t@ype
}{c:t@ype
} mylist_zipwith
  {n:nat} .<n>.
(
  xs: !mylist(a, n)
, ys: !mylist(b, n)
, f: &(a, b) -<clo1> c
) : mylist(c, n) =
(
  case+ xs of
  | mylist_cons(x, xs) =>
    (
      case+ ys of
      | mylist_cons(y, ys) => let
          val z = f(x, y)
        in
          mylist_cons(z, mylist_zipwith<a,b><c>(xs, ys, f))
        end
    ) (* end of [mylist_cons] *)
  | _ =>> mylist_nil((*void*))
) (* end of [mylist_zipwith] *)

fun{a:t@ype}
mylist_free{n:nat} .<n>. (xs: mylist(a, n)): void =
  case+ xs of
  | ~mylist_nil () => () | ~mylist_cons (_, xs) => mylist_free<a> (xs)

(* ****** ****** *)

implement
main0 () =
{
//
val xs = mylist_cons (1, mylist_cons (2, mylist_cons (3, mylist_nil ())))
val n = mylist_length<int> (xs)
val () = assertloc (n = 3)
val () = assertloc (mylist_length2<int> (xs) = 3)
//
val-~Some_vt (x) = mylist_last<int> (xs)
val () = assertloc (x = 3)
//
val ys = mylist_reverse<int> (mylist_append<int> (xs, mylist_nil ()))
//
var f = lam@ (x: int): int => x * x
val zs = mylist_map<int><int> (ys, f)
val ws = mylist_zip<int,int> (ys, zs)
//
var g = lam@ (x: int, y: int): int => x + y
val us = mylist_zipwith<int,int><int> (ys, zs, g)
val () = assertloc (mylist_length<int> (us) = 3)
//
val () = mylist_free<int> (ys)
val () = mylist_free<int> (zs)
val () = mylist_free<(int,int)> (ws)
val () = mylist_free<int> (us)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [listfuns.dats] *)
