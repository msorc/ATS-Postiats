(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test06_list000.dats
//
// ATS3 has a rich list library ([list_ncpy], [list], [map],
// [maprev], [appends], [list_2choose_lstrm], ...).  In ATS2
// the lists are [list_vt]s, which are linear: they have to be
// freed, and the mapping is done by the template function
// [list_vt_map] (whose element function is [list_vt_map$fopr]).
//
// The parts of the ATS3 test that enumerate all the pairs and
// all the triples of a list are dropped: in ATS2 a list has a
// static length, so such a list cannot be built.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

implement
list_vt_map$fopr<int><int> (x) = x * x

(* ****** ****** *)

implement
main0 () = {
  val ns = list_make_elt<int> (10, 1)
  val () = fprint_list_vt (stdout_ref, ns)
  val () = println! ()
  val () = println! ("|ns| = ", list_vt_length (ns))
  val xs = list_make_intrange (0, 10)
  val xs = list_vt_cast{int} (xs)
  val () = fprint_list_vt (stdout_ref, xs)
  val () = println! ()
  val ys = list_vt_map<int><int> (xs)
  val () = fprint_list_vt (stdout_ref, ys)
  val () = println! ()
  val zs0 = list_vt_copy<int> (xs)
  val zs1 = list_vt_reverse (zs0)
  val zs = list_vt_map<int><int> (zs1)
  val () = fprint_list_vt (stdout_ref, zs)
  val () = println! ()
  val yszs = list_vt_append (ys, zs)
  val () = fprint_list_vt (stdout_ref, yszs)
  val () = println! ()
  val rxs0 = list_vt_copy<int> (xs)
  val rxs = list_vt_reverse (rxs0)
  val () = fprint_list_vt (stdout_ref, rxs)
  val () = println! ()
  val () = list_vt_free (ns)
  val () = list_vt_free (xs)
  val () = list_vt_free (zs1)
  val () = list_vt_free (yszs)
  val () = list_vt_free (rxs)
} // end of [main0]

(* ****** ****** *)

(* end of [test06_list000.dats] *)
