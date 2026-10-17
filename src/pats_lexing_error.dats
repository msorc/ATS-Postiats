(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: March, 2011
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_lexing.sats"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef location = $LOC.location
overload fprint with $LOC.fprint_location

(* ****** ****** *)
//
// HX: the global (never freed) cells for the global state
//
fun{a:t@ype}
gcell_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [gcell_make]

(* ****** ****** *)

implement
lexerr_make (loc, node) = lexerr_LEXERR (loc, node)

(* ****** ****** *)
//
// HX-2011-03-12:
// [n] stores the total number of errors, some of
// which may not be recorded
//
extern
fun the_lexerrlst_get (n: &int >> int): glist(lexerr)

(* ****** ****** *)

local
//
// HX-2011-03-12:
// MAXLEN is the max number of errors to be reported
//
#define MAXLEN 100
//
// HX-2026-10: the global state is kept in cells of the global arena
//
val the_length = gcell_make<int> (0)
val the_lexerrlst = gcell_make<glist(lexerr)> (glist_nil())
//
fn
the_length_get(): int = $UN.ptr0_get<int> (the_length)
fn
the_length_set(n: int): void = $UN.ptr0_set<int> (the_length, n)
fn
the_lexerrlst_get_(): glist(lexerr) =
  $UN.ptr0_get<glist(lexerr)> (the_lexerrlst)
fn
the_lexerrlst_set(xs: glist(lexerr)): void =
  $UN.ptr0_set<glist(lexerr)> (the_lexerrlst, xs)
//
in // in of [local]

implement
the_lexerrlst_clear
  () = () where {
  val () = the_length_set (0)
  val () = the_lexerrlst_set (glist_nil())
} // end of [the_lexerrlst_clear]

implement
the_lexerrlst_add
  (err) = () where {
  val n = the_length_get ()
  val () = the_length_set (n + 1)
  val () = if n < MAXLEN then
    the_lexerrlst_set (glist_cons (err, the_lexerrlst_get_()))
  // end of [val]
} // end of [the_lexerrlst_add]

implement
the_lexerrlst_get
  (n) = xs where {
  val () = n := the_length_get ()
  val () = the_length_set (0)
  val xs = glist_reverse (the_lexerrlst_get_())
  val () = the_lexerrlst_set (glist_nil())
} // end of [the_lexerrlst_get]

end // end of [local]

(* ****** ****** *)

implement
fprint_lexerr
  (out, x) = let
  val loc = x.lexerr_loc()
  val () = fprint (out, loc)
in
//
case+ lexerr_node_view (x.lexerr_node()) of
| ~LE_CHAR_oct () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the char format (oct) is incorrect.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_CHAR_hex () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the char format (hex) is incorrect.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_CHAR_unclose () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the char constant is unclosed.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_STRING_char_oct () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the string-char format (oct) is incorrect.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_STRING_char_hex () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the string-char format (hex) is incorrect.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_STRING_unclose () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the string constant is unclosed.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_COMMENT_block_unclose
  (
  ) => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the comment block is unclosed.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_EXTCODE_unclose () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the external code block is unclosed.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_DIGIT_oct_89 (c) => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": illegal digit (oct): ")
    val () = fprint_char(out, c)
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_IDIGITS_empty () => () where { // YD-2018-07-10: fix hex int format.
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the integer digits is empty.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_FEXPONENT_empty () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the floating exponent is empty.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_FEXPONENT_missing () => () where { // YD-2018-07-09: fix hex float format.
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the floating exponent is missing.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_FINTFRAC_missing () => () where { // YD-2018-07-10: fix hex float format.
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": integral or fractional part is missing.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_QUOTE_dangling () => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": the quote symbol (') is dangling.")
    val ((*void*)) = fprint_newline (out)
  }
| ~LE_UNSUPPORTED_char (c) => () where {
    val () = fprint_string(out, ": error(lexing)")
    val () = fprint_string(out, ": unsupported char: ")
    val () = fprint_char(out, c)
    val ((*void*)) = fprint_newline (out)
  }
(*
| _ => () where {
    val () = fprint_string(out, ": error(lexing): unspecified")
    val () = fprint_newline (out)
  }
*)
//
end // end of [fprint_lexerr]

(* ****** ****** *)

implement
fprint_the_lexerrlst
  (out) = let
  var n: int = 0
  val xs = the_lexerrlst_get (n)
//
  fun loop (
    out: FILEref, xs: glist(lexerr), n: int
  ) : int =
    case+ glist_view(xs) of
    | ~GLcons (x, xs) => let
        val () = fprint_lexerr (out, x) in loop (out, xs, n-1)
      end // end of [GLcons]
    | ~GLnil () => n
  (* end of [loop] *)
//
in
//
if glist_is_cons (xs) then let
    val n = loop (out, xs, n)
    val () = if n > 0 then {
      val () = fprint_string
        (out, "There are possibly some additional errors.")
      val () = fprint_newline (out)
    } // end of [if]
  in
    1 (* containing errors *)
  end // end of [then]
else 0 (* free of errors *)
//
end // end of [fprint_the_lexerrlst]

(* ****** ****** *)

(* ****** ****** *)

(* end of [pats_lexing_error.dats] *)
