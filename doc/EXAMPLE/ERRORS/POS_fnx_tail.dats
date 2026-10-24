(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
#include "share/atspre_staload.hats"
fnx
loop1(i: int): void = if i <= 9 then loop2(i, 1) else ()
and
loop2(i: int, j: int): void =
  if j <= i then let
    val () = print! (j*i, " ")
  in loop2(i, j+1) end
  else (print_newline(); loop1(i+1))
implement main0 () = loop1(1)
