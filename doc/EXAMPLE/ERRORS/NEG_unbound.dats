(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
#include "share/atspre_staload.hats"
(*
** an error of the typechecker: only the first function of a [fnx]-group
** is visible after the group, so [g] is unrecognized in [main0]
*)
fnx
f(n: int): int = if n = 0 then 0 else g(n-1)
and
g(n: int): int = if n = 0 then 0 else f(n-1)
implement main0 () = println! (g(10))
