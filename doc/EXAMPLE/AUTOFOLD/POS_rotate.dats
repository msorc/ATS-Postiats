(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand
** The rotation shape of libats/DATS/linmap_avltree.dats: a [fold@] between
** two writes of fields stays explicit (the variable is assigned, which is not
** a demand point); the last [fold@] may be left out.
*)
#include "share/atspre_staload.hats"
//
datavtype tree =
  | leaf of ()
  | node of (tree, int, tree)
//
fun
tree_free (t: tree): void =
  case+ t of
  | ~leaf () => ()
  | ~node (tl, _, tr) => (tree_free (tl); tree_free (tr))
//
// the in-order list of the keys, as a number in base 10
//
fun
tree_digits
  (t: !tree, acc: int): int =
(
  case+ t of
  | leaf () => acc
  | @node (tl, x, tr) => let
      val acc = tree_digits (tl, acc)
      val acc = 10 * acc + x
    in
      tree_digits (tr, acc)
    end // end of [node]
)
//
fun
tree_root (t: !tree): int =
  case+ t of
  | leaf () => ~1 | @node (_, x, _) => x
//
// the right rotation with all the [fold@]s (unchanged)
//
fun
rotr_explicit
  (t: tree): tree =
(
  case+ t of
  | @node (tl, x, tr) => let
      val l = tl
    in
      case+ l of
      | @node (ll, y, lr) => let
          val () = tl := lr
          prval () = fold@ (t)
          val () = lr := t
          prval () = fold@ (l)
        in
          l
        end // end of [node]
      | leaf () => let
          val () = tl := l
          prval () = fold@ (t)
        in
          t
        end // end of [leaf]
    end // end of [node]
  | leaf () => t
)
//
// the same without the last [fold@]s: [l] and [t] are returned
//
fun
rotr_implicit
  (t: tree): tree =
(
  case+ t of
  | @node (tl, x, tr) => let
      val l = tl
    in
      case+ l of
      | @node (ll, y, lr) => let
          val () = tl := lr
          prval () = fold@ (t)
          val () = lr := t
        in
          l
        end // end of [node]
      | leaf () => let
          val () = tl := l
        in
          t
        end // end of [leaf]
    end // end of [node]
  | leaf () => t
)
//
(* ****** ****** *)

implement
main0 () = {
//
val t12 = node (node (leaf, 1, leaf), 2, node (leaf, 3, leaf))
val t = node (t12, 4, node (leaf, 5, leaf))
val () = assertloc (tree_digits (t, 0) = 12345)
val t = rotr_explicit (t)
val () = assertloc (tree_root (t) = 2)
val () = assertloc (tree_digits (t, 0) = 12345)
val t = rotr_implicit (t)
val () = assertloc (tree_root (t) = 1)
val () = assertloc (tree_digits (t, 0) = 12345)
val t = rotr_implicit (t)
val () = assertloc (tree_root (t) = 1)
val () = tree_free (t)
//
val () = println! ("POS_rotate: ok")
//
} (* end of [main0] *)

(* end of [POS_rotate.dats] *)
