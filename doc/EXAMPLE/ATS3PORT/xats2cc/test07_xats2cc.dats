(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test07_xats2cc.dats
//
// The test exercises the calls of the closures that are held
// in variables.  The alias of a closure is dropped: it does
// not compile in ATS2.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

fun
gfun (x: int): int = x + 1

(* ****** ****** *)

implement
main0 () = {
  var f = lam@ (w: int): int => w + 1
  val r1 = f (2) // 3
  val r2 = f (10) // 11
  val r3 =
  let
    val k = 100
    var g = lam@ (w: int): int => w + k
  in
    g (1) // 101
  end // end of [let]
  var z = lam@ (): int => 7
  val r4 = z () // 7
  val r5 = gfun (4) // 5
  val () = println! ("r1 = ", r1)
  val () = println! ("r2 = ", r2)
  val () = println! ("r3 = ", r3)
  val () = println! ("r4 = ", r4)
  val () = println! ("r5 = ", r5)
} // end of [main0]

(* ****** ****** *)

(* end of [test07_xats2cc.dats] *)
