(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test07_gseq000.dats
//
// The ATS3 [GSEQ] layer can zip two sequences ([GSEQ_z2make])
// and zip a sequence with a sequence of pairs ([GSEQ_x2make]).
// In ATS2 the lists have a static length, so a zipper is
// written by indexing into the two lists; the result is a
// [list_vt] of pairs.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)
//
// [zip3]: the zipper of two lists of three elements.
//
fun
zip3 (xs: !list_vt(int, 3), ys: !list_vt(int, 3)): list_vt(@(int, int), 3) =
  list_vt_cons (@(xs[0], ys[0]),
  list_vt_cons (@(xs[1], ys[1]),
  list_vt_cons (@(xs[2], ys[2]), list_vt_nil ())))

(* ****** ****** *)

implement
main0 () = {
  val xs = list_make_intrange (0, 3)
  val xs = list_vt_cast{int} (xs)
  val ys = list_make_intrange (10, 13)
  val ys = list_vt_cast{int} (ys)
  val () = fprint_list_vt (stdout_ref, xs)
  val () = println! ()
  val () = fprint_list_vt (stdout_ref, ys)
  val () = println! ()
  val zs = zip3 (xs, ys)
  val () = fprint_list_vt (stdout_ref, zs)
  val () = println! ()
  val () = list_vt_free (zs)
  val () = list_vt_free (xs)
  val () = list_vt_free (ys)
} // end of [main0]

(* ****** ****** *)

(* end of [test07_gseq000.dats] *)
