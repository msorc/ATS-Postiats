(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test08_xats2cc.dats
//
// The test exercises the use of the functions as values.  In
// ATS2 a function that captures no variable is an ordinary
// function, and it can be passed around as a value.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

fun
gfun (x: int): int = x + 1

fun
gfun2 (x: int): int = x * 2

(* ****** ****** *)

fun
ap (f: (int) -> int, x: int): int = f (x)

(* ****** ****** *)

implement
main0 () = {
  val r1 = ap (gfun, 4) // 5
  val r2 = ap (lam (w: int): int => w + 2, 4) // 6
  val r5 = ap (gfun2, 3) // 6
  val r6 = gfun (7) // 8
  val () = println! ("r1 = ", r1)
  val () = println! ("r2 = ", r2)
  val () = println! ("r5 = ", r5)
  val () = println! ("r6 = ", r6)
} // end of [main0]

(* ****** ****** *)

(* end of [test08_xats2cc.dats] *)
