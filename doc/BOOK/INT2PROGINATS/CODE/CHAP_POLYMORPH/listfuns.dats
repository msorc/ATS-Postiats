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
** Example: function templates on lists
**
** Updated for the linear-only dialect of ATS2 (no GC):
** the lists are linear (datavtype); a function either borrows a list
** (the type !mylist(a)) or consumes it (the type mylist(a))
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

fun{
a:t@ype
} mylist_length
  (xs: !mylist a): int =
(
  case+ xs of
  | mylist_cons (_, xs) => 1 + mylist_length<a> (xs) | mylist_nil () => 0
) (* end of [mylist_length] *)

(* ****** ****** *)

fun{
a:t@ype
} mylist_free (xs: mylist a): void =
(
  case+ xs of
  | ~mylist_cons (_, xs) => mylist_free<a> (xs) | ~mylist_nil () => ()
) (* end of [mylist_free] *)

(* ****** ****** *)
//
// A list is copied
//
fun{
a:t@ype
} mylist_copy
  (xs: !mylist a): mylist a =
(
  case+ xs of
  | mylist_nil () => mylist_nil ()
  | mylist_cons (x, xs) => mylist_cons{a}(x, mylist_copy<a> (xs))
) (* end of [mylist_copy] *)

(* ****** ****** *)

fun{
a:t@ype
} mylist_last
(
  xs: !mylist a
) : Option_vt (a) = let
//
fun loop
  (x: a, xs: !mylist a): a =
(
  case+ xs of
  | mylist_nil () => x | mylist_cons (x, xs) => loop (x, xs)
) (* end of [loop] *)
//
in
  case+ xs of
  | mylist_nil () => None_vt ()
  | mylist_cons (x, xs) => Some_vt{a}(loop (x, xs))
end // end of [mylist_last]

(* ****** ****** *)

fun
{a:t@ype}
mylist_append
(
xs: mylist a, ys: mylist a
) : mylist a =
(
case+ xs of
| ~mylist_nil() => ys
| ~mylist_cons(x, xs) =>
    mylist_cons{a}(x, mylist_append<a>(xs, ys))
  // end of [mylist_cons]
) (* end of [mylist_append] *)

(* ****** ****** *)

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

(* ****** ****** *)

fun
{a:t@ype}
mylist_reverse
  (xs: mylist a): mylist a = mylist_reverse_append<a>(xs, mylist_nil)
// end of [mylist_reverse]

(* ****** ****** *)

fun
{a:t@ype}
{b:t@ype}
mylist_map
(
  xs: !mylist a, f0: &(a) -<clo1> b
) : mylist b =
(
case+ xs of
| mylist_nil() =>
  mylist_nil()
| mylist_cons(x, xs) => let
    val y = f0(x)
  in
    mylist_cons{b}(y, mylist_map<a><b>(xs, f0))
  end // end of [mylist_cons]
) (* end of [mylist_map] *)

(* ****** ****** *)

fun
{a:t@ype}
{b:t@ype}
mylist_foldleft
(
  ini: a
, xs0: !mylist(b), f0: &(a, b) -<clo1> a
) : a =
(
//
case+ xs0 of
| mylist_nil() => ini
| mylist_cons(x, xs) => let
    val ini = f0(ini, x) in mylist_foldleft<a><b> (ini, xs, f0)
  end // end of [mylist_cons]
//
) (* end of [mylist_foldleft] *)

(* ****** ****** *)

fun
{a:t@ype}
{b:t@ype}
mylist_foldright
(
  xs0: !mylist(a)
, res: b, f0: &(a, b) -<clo1> b
) : b =
(
//
case+ xs0 of
| mylist_nil() => res
| mylist_cons(x, xs) => let
    val res = mylist_foldright<a><b>(xs, res, f0)
  in
    f0(x, res)
  end // end of [mylist_cons]
//
) (* end of [mylist_foldright] *)

(* ****** ****** *)

fun{
a,b:t@ype
} mylist_zip
(
xs: !mylist(a)
,
ys: !mylist(b)
) : mylist@(a, b) = let
//
  typedef ab = @( a, b )
//
in
//
case+ xs of
| mylist_nil () => mylist_nil ()
| mylist_cons (x, xs) =>
  (
    case+ ys of
    | mylist_nil () => mylist_nil ()
    | mylist_cons (y, ys) =>
        mylist_cons{ab}(@(x, y), mylist_zip<a,b>(xs, ys))
  ) (* end of [mylist_cons] *)
//
end // end of [mylist_zip]

(* ****** ****** *)

fun
{a,
 b:t@ype}
{c:t@ype}
mylist_zipwith
(
  xs: !mylist(a)
, ys: !mylist(b)
, f0: &(a, b) -<clo1> c
) : mylist(c) =
(
case+ xs of
| mylist_nil () => mylist_nil ()
| mylist_cons (x, xs) =>
  (
    case+ ys of
    | mylist_nil () => mylist_nil ()
    | mylist_cons (y, ys) => let
        val z = f0(x, y)
      in
        mylist_cons{c}(z, mylist_zipwith<a,b><c> (xs, ys, f0))
      end // end of [mylist_cons]
  ) (* end of [mylist_cons] *)
) (* end of [mylist_zipwith] *)

(* ****** ****** *)

fun
mylist_make_range
  (lo: int, hi: int): mylist(int) =
  if lo < hi then mylist_cons (lo, mylist_make_range (lo+1, hi)) else mylist_nil ()
// end of [mylist_make_range]

fun
mylist_print
  (xs: !mylist(int)): void =
(
case+ xs of
| mylist_nil () => print_newline ()
| mylist_cons (x, xs) => (print x; print ' '; mylist_print (xs))
)

(* ****** ****** *)

implement
main0 () =
{
//
val xs = mylist_make_range (0, 5)
val () = assertloc (mylist_length (xs) = 5)
//
val-~Some_vt (x) = mylist_last<int> (xs)
val () = assertloc (x = 4)
//
val ys = mylist_copy (xs)
val zs = mylist_append (xs, ys)
val () = assertloc (mylist_length (zs) = 10)
val () = mylist_print (zs)
//
val zs = mylist_reverse (zs)
val () = mylist_print (zs)
//
var f = lam@ (x: int): int => x * x
val ws = mylist_map<int><int> (zs, f)
val () = mylist_print (ws)
//
var g = lam@ (res: int, x: int): int => res + x
val s1 = mylist_foldleft<int><int> (0, ws, g)
val s2 = mylist_foldright<int><int> (ws, 0, g)
val () = assertloc (s1 = 60 && s2 = 60)
//
var h = lam@ (x: int, y: int): int => x * y
val us = mylist_zipwith<int,int><int> (zs, ws, h)
val () = mylist_print (us)
val vs = mylist_zip<int,int> (zs, ws)
val () = assertloc (mylist_length (vs) = 10)
//
val () = mylist_free (zs)
val () = mylist_free (ws)
val () = mylist_free (us)
val () = mylist_free (vs)
//
val e = mylist_nil{int}()
val ((*empty*)) = case+ mylist_last (e) of
  | ~None_vt () => () | ~Some_vt (_) => assertloc (false)
val () = mylist_free (e)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [listfuns.dats] *)
