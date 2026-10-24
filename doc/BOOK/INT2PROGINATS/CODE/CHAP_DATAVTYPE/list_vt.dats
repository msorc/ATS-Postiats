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
** Linear Lists
**
** Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
** Time: September, 2011
*)

(* ****** ****** *)
//
// HX-2026-10: no GC
// The functional lists [list] are replaced with linear lists [list_vt]
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fn{
a:t@ype
} length{n:nat}
  (xs: !list_vt (a, n)): int n = let
  fun loop
    {i,j:nat | i+j==n} .<i>.
    (xs: !list_vt (a, i), j: int j): int (n) =
    case+ xs of
    | list_vt_cons (_, xs1) => loop (xs1, j+1) | list_vt_nil () => j
  // end of [loop]
in
  loop (xs, 0)
end // end of [length]

fun
list_vt_2x{n:nat}
  (xs: !list_vt (int, n) >> _): void =
(
  case+ xs of
  | @list_vt_cons
      (x, xs1) => let
      val () = x := 2 * x
      val () = list_vt_2x (xs1)
      prval () = fold@ (xs)
    in
      // nothing
    end // end of [list_vt_cons]
  | list_vt_nil () => ()
) (* end of [list_vt_2x] *)

fun{
a:t@ype
} list_vt_free1
  {n:nat} .<n>. (xs: list_vt (a, n)): void =
  case+ xs of
  | ~list_vt_cons (x, xs1) => list_vt_free1 (xs1)
  | ~list_vt_nil ((*void*)) => ()
// end of [list_vt_free1]

fun{
a:t@ype
} list_vt_free2
  {n:nat} .<n>. (xs: list_vt (a, n)): void =
  case+ xs of
  | @list_vt_cons
      (x, xs1) => let
      val xs1_ = xs1 // [xs1_] is the value stored in [xs1]
      val ((*void*)) = free@{a}{0}(xs) in list_vt_free2 (xs1_)
    end // end of [list_vt_cons]
  | @list_vt_nil () => free@{a} (xs)
// end of [list_vt_free2]

fn{
a:t@ype
} reverse{n:nat}
(
  xs: list_vt (a, n)
) : list_vt (a, n) = let
  fun revapp
    {i,j:nat | i+j==n} .<i>.
  (
    xs: list_vt (a, i), ys: list_vt (a, j)
  ) : list_vt (a, n) =
    case+ xs of
    | @list_vt_cons
        (_, xs1) => let
        val xs1_ = xs1
        val () = xs1 := ys
        prval () = fold@ (xs)
      in
        revapp (xs1_, xs)
      end // end of [list_vt_cons]
    | ~list_vt_nil ((*void*)) => ys
  // end of [revapp]
in
  revapp (xs, list_vt_nil)
end // end of [reverse]

fn{
a:t@ype
} append{m,n:nat}
(
  xs: list_vt (a, m)
, ys: list_vt (a, n)
) : list_vt (a, m+n) = let
  fun loop {m,n:nat} .<m>. // [loop] is tail-recursive
  (
    xs: &list_vt (a, m) >> list_vt (a, m+n), ys: list_vt (a, n)
  ) : void =
    case+ xs of
    | @list_vt_cons
        (_, xs1) => let
        val () = loop (xs1, ys) in fold@ (xs)
      end // end of [list_vt_cons]
    | ~list_vt_nil ((*void*)) => xs := ys
  // end of [loop]
  var xs: List_vt (a) = xs // creating a left-value for [xs]
  val () = loop (xs, ys)
in
  xs
end // end of [append]

fun{
a:t@ype
} append1{m,n:nat}
(
  xs: list_vt (a, m), ys: list_vt (a, n)
) : list_vt (a, m+n) =
  case+ xs of
  | ~list_vt_nil() => ys
  | ~list_vt_cons(x, xs) => list_vt_cons(x, append1<a>(xs, ys))
// end of [append1]

fun{
a:t@ype
} append2{m,n:nat}
(
  xs: list_vt (a, m), ys: list_vt (a, n)
) : list_vt (a, m+n) = let
//
fun loop
  {m,n:nat} .<m>.
(
  xs: list_vt (a, m), ys: list_vt (a, n)
, res: &(List_vt a)? >> list_vt (a, m+n)
) : void =
(
  case+ xs of
  | ~list_vt_nil() =>
      (res := ys)
    // end of [list_vt_nil]
  | ~list_vt_cons(x, xs) => let
      val () =
      res := list_vt_cons{a}{0}(x, _)
      val+ list_vt_cons (_, res1) = res
      val () = loop (xs, ys, res1)
      prval ((*void*)) = fold@ (res)
    in
      // nothing
    end // end of [list_vt_cons]
) (* end of [loop] *)
//
var res: List_vt(a)
val () = loop (xs, ys, res)
//
in
  res
end // end of [append2]

fun{a:t@ype}
find_rightmost
  {n:nat} .<n>.
(
  xs: !list_vt (a, n), P: &(a) -<clo1> bool
) : Option_vt (a) =
(
  case+ xs of
  | list_vt_cons (x, xs) => let
      val opt = find_rightmost (xs, P)
    in
      case opt of
      | ~None_vt () => if P (x) then Some_vt (x) else None_vt ()
      | _ (*Some_vt*) => opt
    end // end of [list_vt_cons]
  | list_vt_nil () => None_vt ()
) (* end of [find_rightmost] *)

fn{a:t@ype}
list_optcons
  {b:bool}{n:nat}
(
  opt: option_vt (a, b), xs: list_vt (a, n)
) : list_vt (a, n+bool2int(b)) =
  case+ opt of
  | ~Some_vt (x) => list_vt_cons (x, xs) | ~None_vt () => xs
// end of [list_optcons]

implement
main0 () =
{
//
val xs = $list_vt{int}(1, 2, 3)
val () = assertloc (length<int> (xs) = 3)
//
val () = list_vt_2x (xs) // 2, 4, 6
val xs = reverse<int> (xs) // 6, 4, 2
val ys = append<int> (xs, $list_vt{int}(7, 8))
val ys = append1<int> (ys, $list_vt{int}(9))
val ys = append2<int> (ys, $list_vt{int}(10))
val () = println! (ys) // 6, 4, 2, 7, 8, 9, 10
//
var P = lam@ (x: int): bool => x > 7
val-~Some_vt (r) = find_rightmost<int> (ys, P)
val () = assertloc (r = 10)
//
val ys = list_optcons<int> (Some_vt 0, ys)
val ys = list_optcons<int> (None_vt (), ys)
val () = println! (ys) // 0, 6, 4, 2, 7, 8, 9, 10
//
val () = list_vt_free1<int> (ys)
val zs = $list_vt{int}(1, 2)
val () = list_vt_free2<int> (zs)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [list_vt.dats] *)
