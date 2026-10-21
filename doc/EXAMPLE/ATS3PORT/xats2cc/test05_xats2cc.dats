(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test05_xats2cc.dats
//
// The test exercises the closures over a variable of an inner
// scope.  In ATS2 a closure that captures flat variables is a
// flat closure, which is held in a variable and made with
// [lam@].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

implement
main0 () = {
  val r1 =
  let
    val x = 100
    var f = lam@ (w: int): int => w + x
  in
    f (5)
  end // end of [let]
  val r2 =
  let
    val x = 10
    var f = lam@ (w: int): int => w + x
  in
    f (3)
  end // end of [let]
  val () = println! ("r1 = ", r1)
  val () = println! ("r2 = ", r2)
} // end of [main0]

(* ****** ****** *)

(* end of [test05_xats2cc.dats] *)
