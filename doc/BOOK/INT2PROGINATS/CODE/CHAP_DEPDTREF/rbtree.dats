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
** Example: functional red-black trees
**
** Updated for the linear-only dialect of ATS2 (no GC): a tree is linear, and insertion consumes the tree
*)

(* ****** ****** *)

#include "share/atspre_staload.hats"

typedef cmp (a:t@ype) = (a, a) -> int

//
#define BLK 0
#define RED 1
sortdef clr = {c:nat | c <= 1}
//
datavtype rbtree
(
  a:t@ype+
, int // color
, int // bheight
, int // violations
) = // rbtree
  | rbtree_nil(a, BLK, 0, 0) of ()
  | {c,cl,cr:clr}{bh:nat}{v:int}
    {c==BLK && v==0 || c == RED && v==cl+cr}
    rbtree_cons(a, c, bh+1-c, v) of
    (
      int c, rbtree0 (a, cl, bh), a, rbtree0(a, cr, bh)
    ) (* end of [rbtree_cons] *)
// end of [rbtree]
//
where rbtree0(a:t@ype, c:int, bh:int) = rbtree(a, c, bh, 0)
//

fn{
a:t@ype
} insfix_l // right rotation for fixing left insertion
  {cl,cr:clr} {bh:nat} {v:nat} (
  tl: rbtree (a, cl, bh, v), x0: a, tr: rbtree (a, cr, bh, 0)
) : [c:clr] rbtree0 (a, c, bh+1) = let
  #define B BLK; #define R RED; #define cons rbtree_cons
in
  case+ tl of
  | ~cons(R, tll, y, tlr) =>
    (
      case+ tll of
      | ~cons(R, a, x, b) =>
          cons(R, cons(B, a, x, b), y, cons(B, tlr, x0, tr)) // shallow rot
      | _ =>>
        (
          case+ tlr of
          | ~cons(R, b, y1, c) =>
              cons(R, cons(B, tll, y, b), y1, cons(B, c, x0, tr)) // deep rotation
          | _ =>> cons(B, cons(R, tll, y, tlr), x0, tr)
        )
    )
  | _ =>> cons(B, tl, x0, tr)
end // end of [insfix_l]

fn{
a:t@ype
} insfix_r // left rotation for fixing right insertion
  {cl,cr:clr} {bh:nat} {v:nat} (
  tl: rbtree (a, cl, bh, 0), x0: a, tr: rbtree (a, cr, bh, v)
) : [c:clr] rbtree0 (a, c, bh+1) = let
  #define B BLK; #define R RED; #define cons rbtree_cons
in
  case+ tr of
  | ~cons(R, trl, z, trr) =>
    (
      case+ trr of
      | ~cons(R, c, z1, d) =>
          cons(R, cons(B, tl, x0, trl), z, cons(B, c, z1, d)) // shallow rot
      | _ =>>
        (
          case+ trl of
          | ~cons(R, b, y, c) =>
              cons(R, cons(B, tl, x0, b), y, cons(B, c, z, trr)) // deep rotation
          | _ =>> cons(B, tl, x0, cons(R, trl, z, trr))
        )
    )
  | _ =>> cons(B, tl, x0, tr)
end // end of [insfix_r]

extern
fun{
a:t@ype
} rbtree_insert
  {c:clr}{bh:nat}
(
  t: rbtree0 (a, c, bh), x0: a, cmp: cmp(a)
) : [bh1:nat] rbtree0 (a, BLK, bh1)

implement{a}
rbtree_insert
  (t, x0, cmp) = let
//
#define B BLK
#define R RED
#define nil rbtree_nil
#define cons rbtree_cons
//
fun ins
  {c:clr}{bh:nat} .<bh,c>.
(
  t: rbtree0 (a, c, bh), x0: a
) :
[
  cl:clr;v:nat | v <= c
] rbtree (a, cl, bh, v) =
(
  case+ t of
  | ~nil((*void*)) =>
    cons{..}{..}{..}{0}(R, nil, x0, nil)
  | ~cons(c, tl, x, tr) => let
      val sgn = cmp(x0, x)
    in
      //
      // [ifcase] for combining a sequence
      // of chaining if-then-else expressions
      //
      ifcase
      | sgn < 0 => let
          val [cl:int,v:int] tl = ins(tl, x0)
        in
          if c = B
            then insfix_l(tl, x, tr)
            else cons{..}{..}{..}{cl}(R, tl, x, tr)
          // end of [if]
        end (* sgn < 0 *)
      | sgn > 0 => let
          val [cr:int,v:int] tr = ins(tr, x0)
        in
          if c = B
            then insfix_r(tl, x, tr)
            else cons{..}{..}{..}{cr}(R, tl, x, tr)
          // end of [if]
        end (* sgn > 0 *)
      | _(* sgn = 0 *) => cons{..}{..}{..}{0}(c, tl, x, tr) // [x0] found
    end // end of [cons]
) (* end of [ins] *)
//
val t = ins(t, x0)
//
in
  case+ t of ~cons(R, tl, x, tr) => cons(B, tl, x, tr) | _ =>> t
end // end of [rbtree_insert]

fun{
a:t@ype
} rbtree_free
  {c:clr}{bh:int}{v:int}
(
  t: rbtree (a, c, bh, v)
) : void =
  case+ t of
  | ~rbtree_cons (_, tl, _, tr) => (rbtree_free<a> (tl); rbtree_free<a> (tr))
  | ~rbtree_nil () => ()

fun{
a:t@ype
} rbtree_height
  {c:clr}{bh:int}{v:int}
(
  t: !rbtree (a, c, bh, v)
) : int =
  case+ t of
  | rbtree_cons (_, tl, _, tr) => 1 + max (rbtree_height<a> (tl), rbtree_height<a> (tr))
  | rbtree_nil () => 0

fun{
a:t@ype
} rbtree_size
  {c:clr}{bh:int}{v:int}
(
  t: !rbtree (a, c, bh, v)
) : int =
  case+ t of
  | rbtree_cons (_, tl, _, tr) => 1 + rbtree_size<a> (tl) + rbtree_size<a> (tr)
  | rbtree_nil () => 0

implement main0 () = {
  val cmp = lam (x: int, y: int): int => compare (x, y)
  fun loop (t: [c:clr][bh:nat] rbtree0 (int, c, bh), i: int, n: int, cmp: cmp(int)): [bh:nat] rbtree0 (int, BLK, bh) =
    if i < n then loop (rbtree_insert<int> (t, (i * 7919) mod 1000, cmp), i+1, n, cmp) else rbtree_insert<int> (t, 0, cmp)
  val t = loop (rbtree_nil (), 0, 1000, cmp)
  val () = assertloc (rbtree_size<int> (t) = 1000)
  val () = assertloc (rbtree_height<int> (t) <= 20)
  val () = println! ("size = ", rbtree_size<int> (t), " height = ", rbtree_height<int> (t))
  val () = rbtree_free<int> (t)
}

(* ****** ****** *)

(* end of [rbtree.dats] *)
