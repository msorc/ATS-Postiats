(* ****** ****** *)
//
// A port of the ATS3 test
//
//   xatslib/githwxi/TEST/CATS/JS/test99_mydiary.dats
//
// The ATS3 test shows a function that returns a tuple, the
// search of a character in a string and the sorting of a list
// with a quicksort.  In ATS2 the sorting is done with the
// [list_vt_quicksort] of the prelude.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/string.sats"
staload "prelude/SATS/char.sats"
staload "prelude/SATS/list_vt.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)
//
// [strenv]: the environment of the search of a character in a
// string.
//
typedef
strenv = bool

implement
string_foreach$fwork<strenv> (c, env) =
  if c = 'f' then env := true

(* ****** ****** *)
//
// [string_exists]: is the character in the string?
//
fun
string_exists {n:int} (s: string(n), c: char): bool =
let
  var env: strenv = false
  val _ = string_foreach_env<strenv> (s, env)
in
  env
end (* end of [string_exists] *)

(* ****** ****** *)

implement
list_vt_map$fopr<int><int> (x) = x * x

(* ****** ****** *)

implement
list_vt_quicksort$cmp<int> (x1, x2) = compare (x1, x2)

(* ****** ****** *)

implement
main0 () = {
  val f0 = lam (x: int) => @(x, x = x)
  val _ = f0 (1)
  val b0 = string_exists ("abcde", 'f')
  val () = println! ("exists(\"abcde\", 'f') = ", b0)
  val xs0 = list_make_intrange (0, 11)
  val xs0 = list_vt_cast{int} (xs0)
  val xs = list_vt_map<int><int> (xs0)
  val () = fprint_list_vt (stdout_ref, xs)
  val () = println! ()
  val rxs0 = list_vt_copy<int> (xs)
  val rxs = list_vt_reverse (rxs0)
  val () = fprint_list_vt (stdout_ref, rxs)
  val () = println! ()
  val sorted = list_vt_quicksort<int> (xs)
  val () = fprint_list_vt (stdout_ref, sorted)
  val () = println! ()
  val () = list_vt_free (xs0)
  val () = list_vt_free (rxs)
  val () = list_vt_free (sorted)
} // end of [main0]

(* ****** ****** *)

(* end of [test99_mydiary.dats] *)
