(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The proof of a view that is not an at-view (a dataview) is omitted: the
** checker looks for a proof of that view in the environment, and there is
** none.
*)
#include "share/atspre_staload.hats"
//
dataview
cell_v (l:addr) = CELL (l) of (int @ l)
//
fun
read {l:addr}
  (pf: !cell_v (l) | p: ptr l): int = let
  prval CELL (pf1) = pf
  val x = !p
  prval () = pf := CELL (pf1)
in
  x
end // end of [read]
//
implement
main0 () = {
  var x: int = 1
  val r = read (addr@ x) // error: no proof of [cell_v] is in scope
}
(* end of [elide_noproof.dats] *)
