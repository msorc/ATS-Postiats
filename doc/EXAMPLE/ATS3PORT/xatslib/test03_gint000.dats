(* ****** ****** *)
//
// A port of the ATS3 test
//
//   xatslib/githwxi/TEST/CATS/JS/test03_gint000.dats
//
// The ATS3 test makes the list of the digits of an integer; in
// ATS2 the digits are made into a string (there is no way of
// making a list of a length that is only known at run-time).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/string.sats"
staload "prelude/SATS/char.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)
//
// [digit_char]: the character of a digit.
//
fun
digit_char (d: int): char = int2char0 (d + 48)

(* ****** ****** *)
//
// [nint_dgt_str]: the digits of an integer, most significant
// first.
//
fun
nint_dgt_str (n0: int): string =
(
  let
    fun loop (n: int, acc: string): string =
      if n <= 0 then acc
      else loop (n / 10, string_append2 (char2string (digit_char (n % 10)), acc))
  in
    if n0 <= 0 then "0" else loop (n0 / 10, char2string (digit_char (n0 % 10)))
  end
) (* end of [nint_dgt_str] *)

(* ****** ****** *)

implement
main0 () = {
  val ds = nint_dgt_str (123456789)
  val () = println! ("ds = ", ds)
} // end of [main0]

(* ****** ****** *)

(* end of [test03_gint000.dats] *)
