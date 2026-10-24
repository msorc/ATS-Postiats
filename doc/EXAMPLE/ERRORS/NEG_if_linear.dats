(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** an [if] with linear branches and no expected type (see doc/GUIDE/faq.md)
*)
#include "share/atspre_staload.hats"
//
fun
f1 (x: int, res: List0_vt(int)): List0_vt(int) =
let
  val res = if x = 0 then res else list_vt_cons(1, res)
in res end
//
implement main0 () = list_vt_free(f1(0, list_vt_nil()))
