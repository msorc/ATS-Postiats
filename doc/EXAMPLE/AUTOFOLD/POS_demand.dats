(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand
** The demand points: a use of an unfolded variable against a folded type
** (a return, an argument), the end of the scope of its fields, and the
** cases where nothing is folded (explicit [fold@], unfolded parameters).
*)
#include "share/atspre_staload.hats"
//
(* ****** ****** *)
//
// [xs] is returned right after [@list_vt_cons]
//
fun
bump_head
  {n:nat}
  (xs: list_vt (int, n)): list_vt (int, n) =
(
  case+ xs of
  | @list_vt_cons (x, _) => (x := x + 1; xs)
  | list_vt_nil () => xs
)
//
// [xs] is passed to a function that takes [!list_vt]
//
fun
zero_length
  {n:nat}
  (xs: !list_vt (int, n)): int =
(
  case+ xs of
  | @list_vt_cons (x, _) => (x := 0; list_vt_length<int> (xs))
  | list_vt_nil () => 0
)
//
// one branch folds explicitly, the other does not
//
fun
dup_head
  {n:nat}
  (xs: !list_vt (int, n)): int =
(
  case+ xs of
  | @list_vt_cons (x, xs1) =>
    (
      if x > 10
        then let prval () = fold@ (xs) in 2 end
        else (x := x + x; 1)
    )
  | list_vt_nil () => 0
)
//
// explicit fold then use (unchanged)
//
fun
explicit_fold
  {n:nat}
  (xs: list_vt (int, n)): list_vt (int, n) =
(
  case+ xs of
  | @list_vt_cons (x, _) => let
      val () = x := 2 * x
      prval () = fold@ (xs)
    in
      xs
    end // end of [list_vt_cons]
  | list_vt_nil () => xs
)
//
// a field gets a value of another static index: the folded type follows
//
fun
push_second
  {n:nat}
  (xs: list_vt (int, n)): List0_vt (int) =
(
  case+ xs of
  | @list_vt_cons (_, xs1) => (xs1 := list_vt_cons (0, xs1); xs)
  | list_vt_nil () => xs
)
//
// a function that takes the unfolded type: no fold happens at the call
//
fun
peek_unfolded
  {l0,l1,l2:addr}
(
  pf1: !int @ l1
| xs: !list_vt_cons_unfold (l0, l1, l2), p1: ptr l1
) : int = !p1
//
fun
peek_head
  {n:pos}
  (xs: !list_vt (int, n)): int = let
  val+ @list_vt_cons (x, _) = xs
  val r = peek_unfolded (view@ x | xs, addr@ x)
in
  r
end // end of [peek_head]
//
(* ****** ****** *)

implement
main0 () = {
//
val xs = $list_vt{int}(1, 2, 3)
val xs = bump_head (xs)
val () = assertloc (list_vt_length (xs) = 3)
val () = assertloc (dup_head (xs) = 1)
val () = assertloc (peek_head (xs) = 4)
val xs = explicit_fold (xs)
val () = assertloc (peek_head (xs) = 8)
val () = assertloc (zero_length (xs) = 3)
val () = assertloc (peek_head (xs) = 0)
val xs = push_second (xs)
val () = assertloc (list_vt_length (xs) = 4)
val () = list_vt_free (xs)
//
val () = println! ("POS_demand: ok")
//
} (* end of [main0] *)

(* end of [POS_demand.dats] *)
