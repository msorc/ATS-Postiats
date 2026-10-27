(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** The proof parameter is consumed (no [!]): the proof cannot be omitted.
*)
#include "share/atspre_staload.hats"
//
fun
release {l:addr}
  (pf: int @ l, pfgc: mfree_gc_v (l) | p: ptr l): void =
  ptr_free (pfgc, pf | p)
//
implement
main0 () = {
  val (pf, pfgc | p) = ptr_alloc<int> ()
  val () = !p := 1
  val () = release (p) // error: the proofs are consumed
}
(* end of [NEG_elide_consumed.dats] *)
