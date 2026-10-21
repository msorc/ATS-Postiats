(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test01_xats2cc.dats
//
// The test exercises the static arguments of a function and the
// tuple types.  In ATS2 a static argument is introduced with
// [{}] and a tuple type is written @(a, b).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

typedef
sintsint_t = @(int, int)

(* ****** ****** *)

fun
sum2 {i:int} (p: @(int, int), x: int(i)): int =
  p.0 + p.1 + x

(* ****** ****** *)

implement
main0 () = {
  val N1 = 10
  val N2 = N1 + N1
  val N3 = N1 * N2
  val p = @(N1, N2)
  val () = println! ("N3 = ", N3)
  val () = println! ("sum2 = ", sum2 (p, N3))
} // end of [main0]

(* ****** ****** *)

(* end of [test01_xats2cc.dats] *)
