(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: proof-argument elision
** A call with no proof arguments of a function whose proof parameters
** are all preserved at-views (!T @ l): the checker finds each view at
** the address given by the other arguments and restores it after the
** call, as for an explicit [view@ x] argument.
*)
#include "share/atspre_staload.hats"
//
(* ****** ****** *)
//
fun
get {l:addr}
  (pf: !int @ l | p: ptr l): int = !p
//
fun
incr {l:addr}
  (pf: !int @ l | p: ptr l): void = !p := !p + 1
//
// two proof parameters
//
fun
swap {l1,l2:addr}
(
  pf1: !int @ l1, pf2: !int @ l2 | p1: ptr l1, p2: ptr l2
) : void = let
  val x = !p1 in !p1 := !p2; !p2 := x
end // end of [swap]
//
// the >> form: the type of the view changes
//
fun
init {l:addr}
  (pf: !int? @ l >> int @ l | p: ptr l, x: int): void = !p := x
//
//
// an array: [array_v (a, l, n)] is the at-view [@[a][n] @ l]
//
fun
first {l:addr}{n:pos}
  (pf: !array_v (int, l, n) | p: ptr l): int = let
  prval (pf1, pf2) = array_v_uncons (pf)
  val x = !p
  prval () = pf := array_v_cons (pf1, pf2)
in
  x
end // end of [first]
//
(* ****** ****** *)
//
// on a local variable
//
fun
test_var (): int = let
  var x: int = 1
  val () = incr (addr@ x)
  val () = incr (addr@ x)
in
  get (addr@ x) + x
end // end of [test_var]
//
// on a pointer variable of a local variable
//
fun
test_ptr (): int = let
  var x: int = 10
  val p = addr@ x
  val () = incr (p)
in
  get (p)
end // end of [test_ptr]
//
// on a malloc'd cell
//
fun
test_malloc (): int = let
  val (pf, pfgc | p) = ptr_alloc<int> ()
  val () = init (p, 41)
  val () = incr (p)
  val r = get (p)
  val () = ptr_free (pfgc, pf | p)
in
  r
end // end of [test_malloc]
//
// two proofs
//
fun
test_swap (): int = let
  var x: int = 1
  var y: int = 2
  val () = swap (addr@ x, addr@ y)
in
  10 * x + y
end // end of [test_swap]
//
// on a local array
//
fun
test_array (): int = let
  var A = @[int](7, 8, 9)
in
  first (addr@ A)
end // end of [test_array]
//
// the prelude: ptr_get, ptr_set, ptr_exch
//
fun
test_prelude (): int = let
  var x: int? // uninitialized
  val () = ptr_set<int> (addr@ x, 5)
  val v = ptr_get<int> (addr@ x)
  var y: int = 7
  val () = ptr_exch<int> (addr@ x, y)
in
  v + 10 * x + 100 * y
end // end of [test_prelude]
//
(* ****** ****** *)

implement
main0 () = {
  val () = assertloc (test_var () = 6)
  val () = assertloc (test_ptr () = 11)
  val () = assertloc (test_malloc () = 42)
  val () = assertloc (test_swap () = 21)
  val () = assertloc (test_array () = 7)
  val () = assertloc (test_prelude () = 575)
  val () = println! ("POS_elide: ok")
}

(* ****** ****** *)

(* end of [POS_elide.dats] *)
