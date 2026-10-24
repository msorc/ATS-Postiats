(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** a datatype with a non-nullary constructor
*)
datatype intlst = nil | cons of (int, intlst)
implement main0 () = ()
