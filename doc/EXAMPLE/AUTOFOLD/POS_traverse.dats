(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand
** Traversals of linear data through [@Con] patterns without [fold@]:
** the checker folds the variables where the folded type is required.
*)
#include "share/atspre_staload.hats"
//
datavtype
mylist (a:t@ype, int) =
  | mynil (a, 0) of ()
  | {n:nat} mycons (a, n+1) of (a, mylist (a, n))
//
datavtype tree =
  | leaf of ()
  | node of (tree, int, tree)
//
(* ****** ****** *)
//
// the length: the clause ends with the views of the fields
//
fun
{a:t@ype}
mylist_length
  {n:nat} .<n>.
  (xs: !mylist (a, n)): int (n) =
(
  case+ xs of
  | mynil () => 0
  | @mycons (_, xs1) => 1 + mylist_length<a> (xs1)
)
//
// in-place increment through the fields
//
fun
mylist_incr
  {n:nat} .<n>.
  (xs: !mylist (int, n)): void =
(
  case+ xs of
  | mynil () => ()
  | @mycons (x, xs1) => (x := x + 1; mylist_incr (xs1))
)
//
// a search that returns in the middle of a [let]
//
fun
tree_search
  (t: !tree, k: int): bool =
(
  case+ t of
  | leaf () => false
  | @node (tl, x, tr) => let
      val x0 = x
    in
      if k = x0 then true
      else if k < x0 then tree_search (tl, k) else tree_search (tr, k)
    end // end of [node]
)
//
// the same shape with [val+ @Con (..) = ..] in a [let]
//
fun
mylist_head
  {n:pos}
  (xs: !mylist (int, n)): int = let
  val+ @mycons (x, _) = xs
  val x0 = x
in
  x0
end // end of [mylist_head]
//
fun
tree_size
  (t: !tree): int =
(
  case+ t of
  | leaf () => 0
  | @node (tl, _, tr) => let
      val n = 1 + tree_size (tl) + tree_size (tr)
    in
      n
    end // end of [node]
)
//
//
// the scope of the fields ends before the function does:
// a [case] in a [val], and a block in a branch of an [if]
//
fun
tree_rootkey
  (t: !tree): int = let
  val k = (case+ t of leaf () => ~1 | @node (_, x, _) => x + 0)
in
  k
end // end of [tree_rootkey]
//
fun
tree_setroot
  (t: !tree, k: int): void = {
  val () =
  if k >= 0 then {
    val () = (
      case+ t of
      | leaf () => ()
      | @node (_, x, _) => { val () = x := k }
    ) : void // end of [val]
  } (* end of [if] *)
} (* end of [tree_setroot] *)
//
fun
mylist_sethead
  {n:pos}
  (xs: !mylist (int, n), x0: int): void = {
  val () =
  if x0 >= 0 then {
    val+ @mycons (x, _) = xs
    val () = x := x0
  } (* end of [if] *)
} (* end of [mylist_sethead] *)
//
fun
tree_insert
  (t: tree, k: int): tree =
(
  case+ t of
  | ~leaf () => node (leaf, k, leaf)
  | @node (tl, x, tr) =>
    (
      if k < x then (tl := tree_insert (tl, k); t)
      else (tr := tree_insert (tr, k); t)
    )
)
//
fun
tree_free (t: tree): void =
  case+ t of
  | ~leaf () => ()
  | ~node (tl, _, tr) => (tree_free (tl); tree_free (tr))
//
fun
{a:t@ype}
mylist_free
  {n:nat} .<n>.
  (xs: mylist (a, n)): void =
  case+ xs of
  | ~mynil () => ()
  | ~mycons (_, xs1) => mylist_free<a> (xs1)
//
fun
mylist_sum
  {n:nat} .<n>.
  (xs: !mylist (int, n)): int =
(
  case+ xs of
  | mynil () => 0
  | @mycons (x, xs1) => x + mylist_sum (xs1)
)
//
(* ****** ****** *)

implement
main0 () = {
//
val xs = mycons (1, mycons (2, mycons (3, mynil ())))
val () = assertloc (mylist_length<int> (xs) = 3)
val () = mylist_incr (xs)
val () = assertloc (mylist_sum (xs) = 9)
val () = assertloc (mylist_head (xs) = 2)
val () = mylist_sethead (xs, 7)
val () = assertloc (mylist_head (xs) = 7)
val () = mylist_sethead (xs, 2)
val () = mylist_free<int> (xs)
//
var t: tree = leaf ()
val () = t := tree_insert (t, 5)
val () = t := tree_insert (t, 3)
val () = t := tree_insert (t, 8)
val () = t := tree_insert (t, 4)
val () = assertloc (tree_search (t, 4))
val () = assertloc (~tree_search (t, 6))
val () = assertloc (tree_size (t) = 4)
val () = assertloc (tree_rootkey (t) = 5)
val () = tree_setroot (t, 6)
val () = assertloc (tree_rootkey (t) = 6)
val () = tree_free (t)
//
val () = println! ("POS_traverse: ok")
//
} (* end of [main0] *)

(* end of [POS_traverse.dats] *)
