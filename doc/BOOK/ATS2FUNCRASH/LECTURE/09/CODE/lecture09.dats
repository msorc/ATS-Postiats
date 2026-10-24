(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
#include "./../../04/CODE/intfun.hats"
//
(* ****** ****** *)
//
// Stopping a loop by raising an exception
//
fun
int_exists
(n: int, test: (int) -> bool): bool = let
//
exception True of ()
//
in
//
try let
//
var fwork =
lam@(i: int): void => if test(i) then $raise True()
//
val () = int_foreach(n, fwork)
//
in
  false
end with ~True() => true
//
end // end of [int_exists]
//
val () = println! ("exists i < 10. i*i = 49: ", int_exists(10, lam(i) => i*i = 49))
val () = println! ("exists i < 5. i*i = 49: ", int_exists(5, lam(i) => i*i = 49))
//
(* ****** ****** *)
//
// Binary trees are shared data: they are kept in the global arena
// (the encoding is generated from tree.spec by arenagen)
//
staload "./tree.sats"
#include "./tree_gen_dats.hats"
//
(* ****** ****** *)
//
fun
tree_height(t0: tree): int =
(
case+ tree_view(t0) of
| ~TREEnil() => 0
| ~TREEcons(tl, _, tr) =>
  1 + max(tree_height(tl), tree_height(tr))
)
//
(* ****** ****** *)
//
fun
tree_is_perfect(t0: tree): bool =
(
case+ tree_view(t0) of
| ~TREEnil() => true
| ~TREEcons(tl, _, tr) =>
  tree_is_perfect(tl) &&
  tree_is_perfect(tr) &&
  (tree_height(tl) = tree_height(tr))
)
//
(* ****** ****** *)
//
fun
tree_is_perfect2
  (t0: tree): bool = let
//
exception NotPerfect of ()
//
fun
aux(t0: tree): int =
case+ tree_view(t0) of
| ~TREEnil() => 0
| ~TREEcons(tl, _, tr) => let
    val hl = aux(tl) and hr = aux(tr)
  in
    if hl = hr
      then 1+max(hl, hr) else $raise NotPerfect()
    // end of [if]
  end
//
in
  try let val _ = aux(t0) in true end with ~NotPerfect() => false
end // end of [tree_is_perfect2]
//
(* ****** ****** *)
//
// the perfect tree of a given height; the subtrees are shared
//
fun
tree_perfect(h: int): tree =
if h <= 0
  then tree_TREEnil()
  else let
    val t = tree_perfect(h-1) in tree_TREEcons(t, h, t)
  end // end of [else]
//
val perfect = tree_perfect(10)
val unperfect = tree_TREEcons(perfect, 0, tree_TREEnil())
//
val () = println! ("height(perfect) = ", tree_height(perfect))
val () = println! ("is_perfect(perfect) = ", tree_is_perfect(perfect))
val () = println! ("is_perfect2(perfect) = ", tree_is_perfect2(perfect))
val () = println! ("is_perfect(unperfect) = ", tree_is_perfect(unperfect))
val () = println! ("is_perfect2(unperfect) = ", tree_is_perfect2(unperfect))
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture09.dats] *)
