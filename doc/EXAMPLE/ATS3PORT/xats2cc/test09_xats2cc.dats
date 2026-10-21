(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test09_xats2cc.dats
//
// The test exercises the nested functions and the recursive
// closures that outlive the scope in which they are made.  In
// ATS2 a flat closure is held in a variable, so it can be used
// after the scope in which it was made has been left.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

val
NN = 10

(* ****** ****** *)

fun
parity (n0: int, tt: bool, ff: bool): bool =
(
  isevn (n0)) where {
  fun
  isevn (n: int): bool =
    if n = 0 then tt else isodd (n - 1)
  and
  isodd (n: int): bool =
    if n = 0 then ff else isevn (n - 1)
} (* end of [parity] *)

(* ****** ****** *)

implement
main0 () = {
  // 1. a recursive closure over a variable of the enclosing scope
  var go = fix@ f (i: int, r: int): int =>
    if i >= 3 then r else f (i + 1, r + i)
  val r1 = go (0, 0) // 3
  // 2. a closure over a variable of the enclosing scope
  var step = lam@ (w: int): int => w + NN
  val r2 = step (5) // 15
  // 3. a mutually recursive group of functions
  val r3 = parity (4, true, false) // 1
  // 4. a recursive closure used as a value
  var doubler = lam@ (z: int): int => z * 2
  val r4 = doubler (3) // 6
  val () = println! ("r1 = ", r1)
  val () = println! ("r2 = ", r2)
  val () = println! ("r3 = ", r3)
  val () = println! ("r4 = ", r4)
} // end of [main0]

(* ****** ****** *)

(* ****** ****** *)

(* end of [test09_xats2cc.dats] *)
