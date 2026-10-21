(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test09_llist00.dats
//
// ATS3's [list_vt] is a linear (lazy) list; in ATS2 a
// [list_vt] is also a linear list, but it is not lazy: the
// laziness of ATS2 is provided by [stream_vt].
//
// The test defines its own [length] function over a list; the
// same is done here.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

fun
my_length {n:int} (xs: !list_vt(int, n)): int =
(
case+ xs of
| list_vt_nil() => 0
| list_vt_cons(_, xs1) => 1 + my_length (xs1)
) (* end of [my_length] *)

(* ****** ****** *)

implement
list_vt_map$fopr<int><int> (x) = x * x

(* ****** ****** *)

implement
main0 () = {
  val ns = list_make_intrange (0, 10)
  val ns = list_vt_cast{int} (ns)
  val ln = my_length (ns)
  val () = println! ("ln = ", ln)
  val ys = list_vt_map<int><int> (ns)
  val () = fprint_list_vt (stdout_ref, ys)
  val () = println! ()
  val zs0 = list_vt_copy<int> (ns)
  val zs1 = list_vt_reverse (zs0)
  val zs = list_vt_map<int><int> (zs1)
  val () = fprint_list_vt (stdout_ref, zs)
  val () = println! ()
  val () = list_vt_free (ns)
  val () = list_vt_free (ys)
  val () = list_vt_free (zs)
  val () = list_vt_free (zs1)
} // end of [main0]

(* ****** ****** *)

(* end of [test09_llist00.dats] *)
