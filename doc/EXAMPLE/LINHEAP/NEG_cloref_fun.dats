(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** a function declared as a cloref closure
*)
#include "share/atspre_staload.hats"
fun f (x: int):<cloref1> int = x
implement main0 () = ()
