(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The proof of a view that is not an at-view (a dataview, a template
** parameter of a view sort) may be omitted: the checker finds it by its
** type in the environment.
*)
#include "share/atspre_staload.hats"
staload "prelude/SATS/array.sats"
//
// ****** ****** *
//
// the proof of a template parameter of a view sort is found by its type
//
fun
callee
  {v:view}
  {vt:vtype}
  {n:int}
(
  pf: !v
| A0: &(@[int][n]) >> @[int][n]
, asz: size_t(n), tsz: sizeof_t(int)
, f0: (!v | &int >> _, !vt) -<fun> void, env: !vt
) : void = ()
//
fun
by_template
  {v:view}
  {vt:vtype}
  {n:int}
(
  pf: !v
| A0: &(@[int][n]) >> @[int][n]
, asz: size_t(n), tsz: sizeof_t(int)
, f0: (!v | &int >> _, !vt) -<fun> void, env: !vt
) : void = callee {v}{vt}{n} (A0, asz, tsz, f0, env) // the proof is omitted
//
// ****** ****** *
//
// the proof of a dataview is found by its type
//
dataview
cell_v (l:addr) = CELL (l) of (int @ l)
//
fun
by_dataview {l:addr}
  (pf: !cell_v (l) | p0: ptr l): int = 0
//
fun
use_dataview {l:addr}
  (pf: !cell_v (l) | p0: ptr l): int = by_dataview (p0) // the proof is omitted
//
// ****** ****** *
//
// two proofs of the same head are told apart by their indices: the type
// of the proof parameter is resolved by the dynamic arguments
//
fun
read2 {l1:addr}{l2:addr}
  (pf1: !cell_v (l1), pf2: !cell_v (l2) | p1: ptr l1, p2: ptr l2): int = 0
//
fun
use_two () = let
  var x: int = 1
  var y: int = 2
  prval pf1 = CELL (view@ x)
  prval pf2 = CELL (view@ y)
  val r = read2 (addr@ x, addr@ y) // the two proofs are omitted
  prval CELL (pf1x) = pf1
  prval () = view@ x := pf1x
  prval CELL (pf2x) = pf2
  prval () = view@ y := pf2x
in
  r
end // end of [use_two]
//
// ****** ****** *)
//
implement
main0 () = {
//
val _ = use_two ()
val () = println! ("POS_elide_byview: ok")
//
} (* end of [main0] *)

(* end of [POS_elide_byview.dats] *)
