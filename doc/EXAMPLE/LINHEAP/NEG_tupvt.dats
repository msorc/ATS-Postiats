(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** a boxed linear tuple: it could never be freed
*)
#include "share/atspre_staload.hats"
implement main0 () = { val t = $tup_vt(1, 2) val $tup(a, b) = t }
