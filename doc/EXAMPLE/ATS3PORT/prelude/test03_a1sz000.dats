(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test03_a1sz000.dats
//
// ATS3's [a1sz] is an immutable array with a static size; its
// closest ATS2 counterpart is a [list_vt] with a static length.
// The ATS3 function [a1sz_make_list] is therefore the identity
// in ATS2.
//
// Note that the element type of a [list_vt] has to be known
// statically for the list to be printable; this is what the
// [list_vt_cast] below is for.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"
staload "prelude/SATS/intrange.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)
//
// [fact]: the product of the elements 1, 2, ..., n.
//
fun
fact (n: int): int =
let
  typedef tenv = int
  implement
  intrange_foreach$fwork<tenv> (i, env) = env := env * (i + 1)
  var env: tenv = 1
  val _ = intrange_foreach_env<tenv> (0, n, env)
in
  env
end // end of [fact]

(* ****** ****** *)

implement
list_vt_map$fopr<int><int> (x) = x * x

(* ****** ****** *)

implement
main0 () = {
  val A0 = list_make_elt (10, 1)
  val A0 = list_vt_cast{int} (A0)
  val () = fprint_list_vt (stdout_ref, A0)
  val () = println! ()
  val N = 10
  val A1 = list_make_intrange (1, 11)
  val A1 = list_vt_cast{int} (A1)
  val () = fprint_list_vt (stdout_ref, A1)
  val () = println! ()
  val () = println! ("fact(10) = ", fact (10))
  val xs0 = list_make_intrange (0, 10)
  val xs0 = list_vt_cast{int} (xs0)
  val xs = list_vt_map<int><int> (xs0)
  val () = fprint_list_vt (stdout_ref, xs)
  val () = println! ()
  val () = list_vt_free (A0)
  val () = list_vt_free (A1)
  val () = list_vt_free (xs0)
  val () = list_vt_free (xs)
} // end of [main0]

(* ****** ****** *)

(* end of [test03_a1sz000.dats] *)
