(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test04_strn000.dats
//
// ATS3 has a rich string library ([strn_make_ncpy], [strn],
// [strn_reverse], [prefix], [suffix], [slice], ...).  ATS2 has
// much less; the operations that are missing are implemented
// in the shim (see [xats3shim.hats]).
//
// The part of the ATS3 test that builds the list of all the
// strings that differ from "hello" in one position is dropped:
// it needs a mutable string and the ATS3 [list_make_fwork].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/string.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

implement
main0 () = {
  val A9 = "aaaaaaaaa"
  val () = println! ("A9 = ", A9)
  val () = println! ("|A9| = ", string_length (A9))
  val AB = "abcdefghijklmnopqrstuvwxyz"
  val () = println! ("AB = ", AB)
  val BA = string_reverse (AB)
  val () = println! ("BA = ", BA)
  val ABAB = string_append2 (AB, AB)
  val () = println! ("ABAB = ", ABAB)
  val ABBA = string_append2 (AB, BA)
  val () = println! ("ABBA = ", ABBA)
  val () = println! ("prefix(\"abcde\", 3)=", string_prefix ("abcde", 3))
  val () = println! ("suffix(\"abcde\", 3)=", string_suffix ("abcde", 3))
  val () = println! ("slice(\"abcde\", 1, 1)=", string_slice ("abcde", 1, 1))
  val () = println! ("slice(\"abcde\", 1, 2)=", string_slice ("abcde", 1, 2))
} // end of [main0]

(* ****** ****** *)

(* end of [test04_strn000.dats] *)
