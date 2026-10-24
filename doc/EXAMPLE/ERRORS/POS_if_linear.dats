(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** the two ways to write an [if] with linear branches (see doc/GUIDE/faq.md):
** as the body of a function with a declared result type, or with an ascription
*)
#include "share/atspre_staload.hats"
//
fun
cons_if (b: bool, x: int, res: List0_vt(int)): List0_vt(int) =
if b then list_vt_cons(x, res) else res
//
fun
f2 (x: int, res: List0_vt(int)): List0_vt(int) =
let
  val res = (if x = 0 then res else list_vt_cons(1, res)): List0_vt(int)
in res end
//
implement
main0 () = {
  val xs = cons_if(true, 1, list_vt_nil())
  val xs = f2(0, xs)
  val xs = f2(1, xs)
  val () = assertloc(list_vt_length(xs) = 2)
  val () = list_vt_free(xs)
}
