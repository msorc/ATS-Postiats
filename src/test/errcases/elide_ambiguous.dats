(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The proof of a view that is not an at-view (a dataview) is omitted: the
** checker looks for a proof of that view in the environment. When the type
** of the proof is not known (the template argument of the view sort is
** not given at the call), the proofs of the same head cannot be told
** apart and there are two of them.
*)
#include "share/atspre_staload.hats"
//
dataview
cell_v (l:addr) = CELL (l) of (int @ l)
//
fun
read {v:view}
  (pf: !v | p0: int): int = 0
//
implement
main0 () = {
  var x: int = 1
  var y: int = 2
  prval pf1 = CELL (view@ x)
  prval pf2 = CELL (view@ y)
  val r = read (1) // error: two proofs are in scope
}
(* end of [elide_ambiguous.dats] *)
