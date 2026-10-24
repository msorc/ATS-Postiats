(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** datatype -> datavtype: a tree whose nodes live on the heap.
** The type is linear: it must be consumed (here by tree_free),
** and a function that only reads it takes it as !tree.
*)
#include "share/atspre_staload.hats"
//
datavtype tree =
  | Leaf of () | Node of (tree, int, tree)
//
fun insert (t: tree, k: int): tree =
  case+ t of
  | ~Leaf () => Node (Leaf, k, Leaf)
  | ~Node (l, x, r) =>
      if k < x then Node (insert (l, k), x, r)
      else Node (l, x, insert (r, k))
//
fun size (t: !tree): int =
  case+ t of
  | Leaf () => 0
  | Node (l, _, r) => size (l) + 1 + size (r)
//
fun tree_free (t: tree): void =
  case+ t of
  | ~Leaf () => ()
  | ~Node (l, _, r) => (tree_free (l); tree_free (r))
//
implement main0 () = {
  val t = insert (insert (insert (Leaf, 5), 2), 8)
  val () = println! ("size = ", size (t))
  val () = tree_free (t)
}
