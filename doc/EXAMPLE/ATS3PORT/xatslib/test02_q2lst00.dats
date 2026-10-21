(* ****** ****** *)
//
// A port of the ATS3 test
//
//   xatslib/githwxi/TEST/CATS/JS/test02_q2lst00.dats
//
// The ATS3 test folds a sequence into a queue and then turns
// the queue into a list.  In ATS2 the fold is done directly
// into a [list_vt].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)
//
// [fold_list]: the fold of a sequence into a list.
//
fun {n:int} fold_list (xs: !list_vt(int, n)): list_vt(int, n) =
(
case+ xs of
| list_vt_nil () => list_vt_nil ()
| list_vt_cons (x, xs1) => list_vt_cons (x, fold_list (xs1))
) (* end of [fold_list] *)

(* ****** ****** *)

implement
main0 () = {
  val xs = list_make_intrange (1, 6)
  val xs = list_vt_cast{int} (xs)
  val ys = fold_list (xs)
  val () = fprint_list_vt (stdout_ref, ys)
  val () = println! ()
  val () = println! ("sum(xs) = ", gseq_sum (ys))
  val () = println! ("prod(xs) = ", gseq_prod (ys))
  val () = list_vt_free (ys)
  val () = list_vt_free (xs)
} // end of [main0]

(* ****** ****** *)

(* end of [test02_q2lst00.dats] *)
