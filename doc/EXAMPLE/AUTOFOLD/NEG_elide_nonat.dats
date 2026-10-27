(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The proof parameter is not an at-view (a dataview): the proof cannot
** be omitted, the call still needs it. (An [array_v (a, l, n)] is the
** at-view [@[a][n] @ l]: its proof can be omitted.)
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
  prval pf = CELL (view@ x)
  val r = read (addr@ x) // error: the proof of [cell_v] is needed
  prval CELL (pf1) = pf
  prval () = view@ x := pf1
}
(* end of [NEG_elide_nonat.dats] *)
