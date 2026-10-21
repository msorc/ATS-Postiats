(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test11_gasq000.dats
//
// The ATS3 [GASQ] layer offers a binary search over a sorted
// array ([GASQ(xs).bin$search(x0)]); the shim provides
// [gasq_bin$search] for ATS2.
//
// The integer square root is computed by searching, in the
// array [0, ..., N-1], for the first index [i] such that
// (N-1-i)^2 is not less than the given number.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/gorder.sats"
staload "prelude/SATS/arrayptr.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

#define
N 31600

(* ****** ****** *)
//
// [cmp_isqrt]: comparing the square of [N-1-i] with [n0].
//
fun
cmp_isqrt (i: int, n0: int): int =
(
  let
    val d: int = (N - 1 - i) * (N - 1 - i) - n0
  in
    if d < 0 then ~1 else if d > 0 then 1 else 0
  end
) (* end of [cmp_isqrt] *)

(* ****** ****** *)

fun
isqrt (n0: int): int =
(
  let
    val A = arrayptr_make_elt (size_of_int (N), n0)
    val () =
    let
      typedef tenv = size_t
      implement
      array_iforeach$fwork<int><tenv> (i, x, env) = x := g0uint2int_size_int (i)
      var env: tenv = i2sz (0)
      val _ = arrayptr_iforeach_env<int><tenv> (A, size_of_int (N), env)
    in
      ()
    end // end of [let]
    val i =
    gasq_bin$search
      (A, N, n0, cmp_isqrt)
    val () = arrayptr_free (A)
  in
    N - 1 - i
  end
) (* end of [isqrt] *)

(* ****** ****** *)

implement
main0 () = {
  val () = println! ("isqrt(80) = ", isqrt (80))
  val () = println! ("isqrt(81) = ", isqrt (81))
  val () = println! ("isqrt(82) = ", isqrt (82))
  val () = println! ("isqrt(99) = ", isqrt (99))
  val () = println! ("isqrt(100) = ", isqrt (100))
  val () = println! ("isqrt(101) = ", isqrt (101))
  val () = println! ("isqrt(10000000) = ", isqrt (10000000))
  val () = println! ("isqrt(100000000) = ", isqrt (100000000))
  val () = println! ("isqrt(1000000000) = ", isqrt (1000000000))
} // end of [main0]

(* ****** ****** *)

(* end of [test11_gasq000.dats] *)
