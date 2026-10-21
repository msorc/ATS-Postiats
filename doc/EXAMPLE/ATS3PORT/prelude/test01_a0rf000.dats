(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test01_a0rf000.dats
//
// In ATS3 a [ref] is a boxed mutable cell and [type(x)]
// prints the type of a value at run-time.  ATS2 has no
// run-time type reflection, so the [type(...)] parts of the
// output are dropped (the static types are given in the
// comments instead).
//
// In ATS2 a [ref] is formed by giving up the view of some
// memory for good, so it is made from a variable.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/reference.sats"

(* ****** ****** *)

local
//
var
A0_var: int = 0
//
val
A0 = ref_make_viewptr{int} (view@ A0_var | addr@ A0_var)
//
in // in of [local]

implement
main0 () = {
  val x0 = ref_get_elt (A0) // x0 : int
  val () = println! ("A0 = ", x0)
  val () = println! ("x0 = ", x0)
  val () = ref_set_elt (A0, 10)
  val x1 = ref_get_elt (A0) // x1 : int
  val () = println! ("A0 = ", x1)
} // end of [main0]

end // end of [local]

(* ****** ****** *)

(* end of [test01_a0rf000.dats] *)
