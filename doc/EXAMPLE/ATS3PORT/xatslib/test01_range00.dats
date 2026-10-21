(* ****** ****** *)
//
// A port of the ATS3 test
//
//   xatslib/githwxi/TEST/CATS/JS/test01_range00.dats
//
// The ATS3 [range_ibtw] makes a range of integers; in ATS2 the
// ranges of integers are made with [list_make_intrange] and
// [intrange].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

(* ****** ****** *)

implement
main0 () = {
  val xs = list_make_intrange (1, 10)
  val xs = list_vt_cast{int} (xs)
  val () = fprint_list_vt (stdout_ref, xs)
  val () = println! ()
  val () = list_vt_free (xs)
} // end of [main0]

(* ****** ****** *)

(* end of [test01_range00.dats] *)
