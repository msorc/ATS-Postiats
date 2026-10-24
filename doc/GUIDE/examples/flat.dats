(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** boxed tuples and records ('(...), '{...}) -> flat ones
** (@(...), @{...}): they live in a variable or inside another
** value, never on a heap of their own.
*)
#include "share/atspre_staload.hats"
//
typedef point = @{x=int, y=int}
//
fun norm1 (p: point): int = abs (p.x) + abs (p.y)
//
fun swap (p: point): @(int, int) = @(p.y, p.x)
//
implement main0 () = {
  val p = @{x= ~3, y=4} : point
  val () = println! ("norm1 = ", norm1 (p))
  val @(a, b) = swap (p)
  val () = println! ("swapped = ", a, ", ", b)
}
