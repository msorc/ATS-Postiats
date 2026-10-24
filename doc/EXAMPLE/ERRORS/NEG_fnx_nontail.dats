(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
#include "share/atspre_staload.hats"
fnx
f(n: int): int = if n = 0 then 0 else 1 + g(n-1)
and
g(n: int): int = if n = 0 then 0 else 2 + f(n-1)
implement main0 () = println! (f(10))
