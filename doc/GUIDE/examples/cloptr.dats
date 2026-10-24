(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** cloref -> cloptr (a linear closure, freed explicitly)
** or lam@ (a flat closure: no allocation, passed by address).
*)
#include "share/atspre_staload.hats"
//
// a linear closure that captures y: it is freed after use
//
fun make_adder (y: int): (int) -<cloptr1> int =
  lam (x) => x + y
//
fun twice (f: !((int) -<cloptr1> int), x: int): int = let
  val y = f (x)
in
  f (y)
end
//
// a flat closure lives in a variable: nothing to free
//
fun apply_flat (f: &(int) -<clo1> int, x: int): int = f (x)
//
implement main0 () = {
  val add5 = make_adder (5)
  val () = println! ("twice add5 1 = ", twice (add5, 1))
  val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(add5))
//
  val y = 10
  var f = lam@ (x: int): int => x + y
  val () = println! ("flat = ", apply_flat (f, 1))
}
