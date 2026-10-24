(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** option -> option_vt: a Some_vt owns its content; take it out
** with a pattern that consumes the cell (~Some_vt, ~None_vt).
*)
#include "share/atspre_staload.hats"
//
fun find_even (xs: !List_vt(int)): Option_vt(int) =
  case+ xs of
  | list_vt_nil () => None_vt ()
  | list_vt_cons (x, xs1) =>
      if x mod 2 = 0 then Some_vt (x) else find_even (xs1)
//
implement main0 () = {
  val xs = $list_vt{int}(1, 3, 6, 7)
  val r = find_even (xs)
  val () = (
    case+ r of
    | ~Some_vt (x) => println! ("first even = ", x)
    | ~None_vt () => println! ("no even number")
  ) : void
  val () = list_vt_free (xs)
}
