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
** Templates as a special form of functors
**
** List mapping: updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

extern
fun
{a:t@ype}
{b:t@ype}
list_map_fun{n:nat}
  (xs: !list_vt(a, n), fopr: a -> b): list_vt(b, n)

extern
fun
{a:t@ype}
{b:t@ype}
list_map_clo{n:nat}
  (xs: !list_vt(a, n), fopr: &(a) -<clo1> b): list_vt(b, n)

(* ****** ****** *)

extern
fun
{a:t@ype}
{b:t@ype}
list_map{n:nat}
  (xs: !list_vt(a, n)): list_vt(b, n)

extern
fun
{a:t@ype}{b:t@ype} list_map$fopr(x: a): b

implement
{a}{b}
list_map (xs) = let
//
fun
aux{n:nat}
  (xs: !list_vt(a, n)): list_vt(b, n) =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) => list_vt_cons(list_map$fopr<a><b>(x), aux(xs))
) (* end of [aux] *)
//
in
  aux(xs)
end // end of [list_map]

(* ****** ****** *)

implement
{a}{b}
list_map_fun(xs, fopr) = let
//
implement list_map$fopr<a><b> (x) = fopr(x)
//
in
  list_map<a><b> (xs)
end // end of [list_map_fun]

(* ****** ****** *)

implement
{a}{b}
list_map_clo(xs, fopr) = let
//
fun
aux{n:nat}
(
  xs: !list_vt(a, n), fopr: &(a) -<clo1> b
) : list_vt(b, n) =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) => let
    val y = fopr(x)
  in
    list_vt_cons(y, aux(xs, fopr))
  end // end of [list_vt_cons]
) (* end of [aux] *)
//
in
  aux(xs, fopr)
end // end of [list_map_clo]

(* ****** ****** *)

implement
main0 () =
{
//
val xs = $list_vt{int}(0, 1, 2, 3, 4)
//
val ys = list_map_fun<int><int> (xs, lam x => x * x)
val ((*void*)) = println! ("ys = ", ys) // ys = 0, 1, 4, 9, 16
//
val d = 10
var f = lam@ (x: int): int => x + d
val zs = list_map_clo<int><int> (xs, f)
val ((*void*)) = println! ("zs = ", zs) // zs = 10, 11, 12, 13, 14
//
val ws = let
  val d = 100
  implement list_map$fopr<int><int> (x) = x + d
in
  list_map<int><int> (xs)
end // end of [val]
val ((*void*)) = println! ("ws = ", ws) // ws = 100, 101, 102, 103, 104
//
val ((*freed*)) = list_vt_free (xs)
val ((*freed*)) = list_vt_free (ys)
val ((*freed*)) = list_vt_free (zs)
val ((*freed*)) = list_vt_free (ws)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [list_map.dats] *)
