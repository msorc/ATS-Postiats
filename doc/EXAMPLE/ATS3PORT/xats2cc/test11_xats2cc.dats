(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test11_xats2cc.dats
//
// The test exercises an external function that has a static
// argument and the instantiation of a function with a static
// argument.  In ATS2 the static arguments of a function are
// introduced with [{}] and the instances are given with [{}]
// as well.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)
//
// [test_inc1]: a function with a static argument.  The ATS3
// test uses an external function with a static argument; the
// C backend of ATS2 cannot emit a function whose type mentions
// a static type variable, so the static argument is an index
// here.
//
fun
test_inc1 {i:nat} (i0: int(i)): int(i) = i0

(* ****** ****** *)
//
// [g_si]: a function with a static argument.
//
fun
g_si {i:nat} (i0: int(i)): int(i) = i0

(* ****** ****** *)

implement
main0 () = {
  val r1 = test_inc1{41} (41) // 41
  val r3 = g_si{41} (41) // 41
  val () = println! ("r1 = ", r1)
  val () = println! ("r3 = ", r3)
} // end of [main0]

(* ****** ****** *)

(* end of [test11_xats2cc.dats] *)
