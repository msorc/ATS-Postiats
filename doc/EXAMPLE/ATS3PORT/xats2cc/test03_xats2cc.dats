(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test03_xats2cc.dats
//
// The test exercises the case-expressions over a list.  In ATS2
// the lists are [list_vt]s.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

(* ****** ****** *)

fun {n:int} sumlist (xs: !list_vt(int, n)): int =
(
case+ xs of
| list_vt_nil () => 0
| list_vt_cons (x, xs1) => x + sumlist (xs1)
) (* end of [sumlist] *)

(* ****** ****** *)

implement
main0 () = {
  val xs = $list_vt{int}(1, 2, 3)
  val the_end = sumlist (xs)
  val () = println! ("the_end = ", the_end)
  val () = list_vt_free (xs)
} // end of [main0]

(* ****** ****** *)

(* end of [test03_xats2cc.dats] *)
