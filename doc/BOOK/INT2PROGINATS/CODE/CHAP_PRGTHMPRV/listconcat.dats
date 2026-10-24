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
** Circumventing nonlinear constraints
**
** Updated for the linear-only dialect of ATS2 (no GC): lists of lists are linear
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

//
// [list_concat] does typecheck in ATS2
// [list_concat] does not typecheck in ATS1
//
fun{
a:t@ype
} list_concat{m,n:nat}
(
  xss: list_vt (list_vt (a, n), m)
) : list_vt (a, m * n) =
  case+ xss of
  | ~list_vt_nil () => list_vt_nil ()
  | ~list_vt_cons (xs, xss) => list_vt_append<a> (xs, list_concat xss)
// end of [list_concat]

(* ****** ****** *)
//
// Another implementation that circumvents the nonlinear constraint:
// the proof [pf] is a witness to the equality [p=m*n]
//
fun{
a:t@ype
} list_concat2{m,n:nat}
(
  xss: list_vt(list_vt(a, n), m)
) : [p:nat] (MUL(m, n, p) | list_vt(a, p)) =
(
//
case+ xss of
| ~list_vt_nil () =>
    (MULbas() | list_vt_nil())
| ~list_vt_cons (xs, xss) => let
    val (pf | res) = list_concat2 (xss)
  in
    (MULind pf | list_vt_append<a> (xs, res))
  end // end of [list_vt_cons]
//
) (* end of [list_concat2] *)

(* ****** ****** *)

implement
main0 () =
{
//
val xss =
$list_vt{list_vt(int,2)}($list_vt{int}(1, 2), $list_vt{int}(3, 4))
val ys = list_concat<int>{2,2} (xss)
val () = println! (ys) // 1, 2, 3, 4
val () = list_vt_free (ys)
//
val xss =
$list_vt{list_vt(int,2)}($list_vt{int}(1, 2), $list_vt{int}(3, 4))
val (pf | ys) = list_concat2<int> (xss)
prval () = mul_elim (pf)
val () = println! (ys) // 1, 2, 3, 4
val () = list_vt_free (ys)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [listconcat.dats] *)
