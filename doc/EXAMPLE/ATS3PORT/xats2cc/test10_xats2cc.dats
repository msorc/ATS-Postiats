(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test10_xats2cc.dats
//
// The test exercises the external functions that are written in
// C and that are used as first-class values.  In ATS2 an
// external function is declared with [extern fun] and the name
// of the C function is given after [=].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

#define
ATS_EXTERN_PREFIX ""

%{#
#include "test10_cats.cats"
%} // end of [%{#]

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

extern
fun
XATS2JS_test_inc (i0: int): int = "ext#%XATS2JS_test_inc"

(* ****** ****** *)

fun
ap2 (f: (int) -> int, x: int): int = f (x)

(* ****** ****** *)

implement
main0 () = {
  val r1 = ap2 (XATS2JS_test_inc, 41) // 42
  val r3 = XATS2JS_test_inc (7) // 8
  val r4 = ap2 (lam (w: int): int => w + 100, 1) // 101
  val () = println! ("r1 = ", r1)
  val () = println! ("r3 = ", r3)
  val () = println! ("r4 = ", r4)
} // end of [main0]

(* ****** ****** *)

(* end of [test10_xats2cc.dats] *)
