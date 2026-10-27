(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** Overloaded symbols: when no candidate has the arity of a call with
** no proof arguments, the candidates whose proofs can be omitted are
** tried (and resolved on the dynamic arguments as usual).
*)
#include "share/atspre_staload.hats"
//
(* ****** ****** *)
//
fun
get_int {l:addr}
  (pf: !int @ l | p: ptr l): int = !p
fun
get_dbl {l:addr}
  (pf: !double @ l | p: ptr l): double = !p
//
fun
get_add {l:addr}
  (pf: !int @ l | p: ptr l, i: int): int = !p + i
//
fun
put_int {l:addr}
  (pf: !int @ l | p: ptr l, x: int): void = !p := x
fun
put_dbl {l:addr}
  (pf: !double @ l | p: ptr l, x: double): void = !p := x
//
// one candidate
//
symintr get1
overload get1 with get_int
//
// two candidates, of different arities
// (HX: [get_int] and [get_dbl] together would be ambiguous: the
// candidates are resolved on the dynamic arguments, not on the views)
//
symintr get2
overload get2 with get_int
overload get2 with get_add
//
// two candidates, of the same arity: resolved on the arguments
//
symintr put
overload put with put_int
overload put with put_dbl
//
(* ****** ****** *)

implement
main0 () = {
//
  var x: int = 1
  var d: double = 2.0
//
  val () = put (addr@ x, 3)
  val () = put (addr@ d, 4.5)
  val () = assertloc (get1 (addr@ x) = 3)
  val () = assertloc (get2 (addr@ x) = 3)
  val () = assertloc (get2 (addr@ x, 10) = 13)
  val () = assertloc (get_dbl (addr@ d) = 4.5)
//
// the explicit form is unchanged
//
  val () = put (view@ x | addr@ x, 5)
  val () = assertloc (get1 (view@ x | addr@ x) = 5)
//
  val () = println! ("POS_elide_overload: ok")
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [POS_elide_overload.dats] *)
