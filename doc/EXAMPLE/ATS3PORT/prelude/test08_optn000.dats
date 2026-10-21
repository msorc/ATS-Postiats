(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test08_optn000.dats
//
// ATS3's [optn] is an option type; in ATS2 the closest
// counterpart is [option_vt].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/option_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

implement
main0 () = {
  val ns = option_vt_some<int> (10)
  val () = fprint_option_vt (stdout_ref, ns)
  val () = println! ()
  val n = (if option_vt_is_some (ns) then 1 else 0): int
  val () = println! ("|ns| = ", n)
  val () = println! ("head(ns) = ", option_vt_unsome (ns))
} // end of [main0]

(* ****** ****** *)

(* end of [test08_optn000.dats] *)
