(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test06_xats2cc.dats
//
// The test exercises the closures that outlive the scope in
// which they are made.  In ATS2 a flat closure is held in a
// variable, so it can be used after the scope in which it was
// made has been left.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

implement
main0 () = {
  var add5 = lam@ (w: int): int => w + 5
  val r3 = add5 (10)
  val r4 = add5 (1)
  val r5 =
  let
    val k = 7
    var f = lam@ (w: int): int => w * k
  in
    f (6)
  end // end of [let]
  val () = println! ("r3 = ", r3)
  val () = println! ("r4 = ", r4)
  val () = println! ("r5 = ", r5)
} // end of [main0]

(* ****** ****** *)

(* end of [test06_xats2cc.dats] *)
