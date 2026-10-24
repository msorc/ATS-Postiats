(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** list/list0 -> list_vt: a list is owned by its holder;
** a function that only looks at a list takes it as !list_vt,
** and whoever owns it frees it.
*)
#include "share/atspre_staload.hats"
//
fun sum (xs: !List_vt(int)): int =
  case+ xs of
  | list_vt_nil () => 0
  | list_vt_cons (x, xs1) => x + sum (xs1)
//
implement main0 () = {
  val xs = $list_vt{int}(1, 2, 3, 4)
  val () = println! ("xs = ", xs)
  val () = println! ("sum = ", sum (xs))
//
  // list_vt_map does not consume xs; it makes a new list
  implement list_vt_map$fopr<int><int> (x) = 2 * x
  val ys = list_vt_map<int><int> (xs)
  val () = println! ("ys = ", ys)
//
  // both lists are owned here: free them
  val () = list_vt_free (xs)
  val () = list_vt_free (ys)
}
