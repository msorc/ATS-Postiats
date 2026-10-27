(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The address of the proof is not determined by the other arguments:
** the proof cannot be omitted.
*)
#include "share/atspre_staload.hats"
//
fun
peek {l:addr}
  (pf: !int @ l | x: int): int = x
//
implement
main0 () = {
  var x: int = 1
  val r = peek (2) // error: l cannot be inferred
}
(* end of [NEG_elide_noaddr.dats] *)
