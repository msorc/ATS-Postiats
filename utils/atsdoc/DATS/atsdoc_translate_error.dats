(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(*                              Hongwei Xi                             *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
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
// Author: Hongwei Xi (gmhwxi AT gmail DOT com)
// Start Time: August, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

%{^
#include "libatsdoc/CATS/libatsdoc_sbuf.cats"
%}

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

extern
fun fprint_newline_ne (out: FILEref): void = "mac#libatsdoc_fprint_newline"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload
FIL = "src/pats_filename.sats"

staload
LOC = "src/pats_location.sats"
typedef location = $LOC.location

(* ****** ****** *)

staload "src/pats_lexbuf.sats"

(* ****** ****** *)

staload "./../SATS/atsdoc_translate.sats"

(* ****** ****** *)

(* ****** ****** *)

implement
fprint_loc
  (out, loc) = () where {
  val () = fprint_string (out, $FIL.filename_get_givename ($LOC.location_get_filename(loc)))
  val () = fprint_string (out, ": ")
  val () = fprint_lint (out, $LOC.location_get_beg_ntot(loc)+1L)
  val () = fprint_string (out, "(line=")
  val () = fprint_int (out, $LOC.location_get_beg_nrow(loc)+1)
  val () = fprint_string (out, ", offs=")
  val () = fprint_int (out, $LOC.location_get_beg_ncol(loc)+1)
  val () = fprint_string (out, ") -- ")
  val () = fprint_lint (out, $LOC.location_get_end_ntot(loc)+1L)
  val () = fprint_string (out, "(line=")
  val () = fprint_int (out, $LOC.location_get_end_nrow(loc)+1)
  val () = fprint_string (out, ", offs=")
  val () = fprint_int (out, $LOC.location_get_end_ncol(loc)+1)
  val () = fprint_string (out, ")")
} // end of [fprint_loc]

(* ****** ****** *)

implement
docerr_make (loc, node) = docerr_DOCERR (loc, node)

(* ****** ****** *)

local

#define MAXLEN 100
//
// HX: the errors are accumulated in reverse order
//
val the_length: ptr = let
  val p = the_garena_alloc (sizeof<int>)
  val () = $UN.ptr0_set<int> (p, 0)
in p end
val the_docerrlst: ptr = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<glist(docerr)> (p, glist_nil ())
in p end

in // in of [local]

implement
the_docerrlst_length () = $UN.ptr0_get<int> (the_length)

implement
the_docerrlst_clear
  () = () where {
  val () = $UN.ptr0_set<int> (the_length, 0)
  val () = $UN.ptr0_set<glist(docerr)> (the_docerrlst, glist_nil ())
} // end of [the_docerrlst_clear]

implement
the_docerrlst_add
  (err) = () where {
  val n = $UN.ptr0_get<int> (the_length)
  val () = $UN.ptr0_set<int> (the_length, n + 1)
  val () = if n < MAXLEN then let
    val xs = $UN.ptr0_get<glist(docerr)> (the_docerrlst)
  in
    $UN.ptr0_set<glist(docerr)> (the_docerrlst, glist_cons<docerr> (err, xs))
  end // end of [val]
} // end of [the_docerrlst_add]

(* the errors, in the order of insertion; [n] is the number of errors added *)
fun the_docerrlst_get
  (n: &int? >> int): glist(docerr) = xs where {
  val () = n := $UN.ptr0_get<int> (the_length)
  val () = $UN.ptr0_set<int> (the_length, 0)
  val xs = $UN.ptr0_get<glist(docerr)> (the_docerrlst)
  val xs = glist_reverse<docerr> (xs)
  val () = $UN.ptr0_set<glist(docerr)> (the_docerrlst, glist_nil ())
} // end of [the_docerrlst_get]

end // end of [local]

(* ****** ****** *)

fun fprint_docerr (out: FILEref, err: docerr): void = let
  val+ ~DOCERR (loc, node) = docerr_view (err)
  val () = fprint_loc (out, loc)
in
//
case+ 0 of
//
| _ when node = DE_EXTCODE_unclose => () where {
    val () = fprint_string (out, ": error(atsdoc)")
    val () = fprint_string (out, ": the external code block is unclosed.")
    val () = fprint_newline_ne (out)
  }
//
| _ when node = DE_STRING_unclose => () where {
    val () = fprint_string (out, ": error(atsdoc)")
    val () = fprint_string (out, ": the string argument is unclosed.")
    val () = fprint_newline_ne (out)
  }
//
| _ when node = DE_FUNARGLST_unclose => () where {
    val () = fprint_string (out, ": error(atsdoc)")
    val () = fprint_string (out, ": the funarg list is not properly closed.")
    val () = fprint_newline_ne (out)
  }
| _ when node = DE_FUNRES_none => () where {
    val () = fprint_string (out, ": error(atsdoc)")
    val () = fprint_string (out, ": the funres identifier is ill-formed.")
    val () = fprint_newline_ne (out)
  }
| _ (*DE_FUNRES_unclose*) => () where {
    val () = fprint_string (out, ": error(atsdoc)")
    val () = fprint_string (out, ": the optional funres is not properly closed.")
    val () = fprint_newline_ne (out)
  }
//
end // end of [fprint_docerr]

implement
fprint_the_docerrlst
  (out) = let
  var n: int?
  val xs = the_docerrlst_get (n)
  fun loop (
    out: FILEref, xs: glist(docerr), n: int
  ) : int =
    case+ glist_view<docerr> (xs) of
    | ~GLcons (x, xs) => (
        fprint_docerr (out, x); loop (out, xs, n-1)
      ) // end of [GLcons]
    | ~GLnil () => n
  // end of [loop]
in
//
if glist_is_cons<> (xs) then let
  val n = loop (out, xs, n)
  val () = if n > 0 then {
    val () = fprint_string
      (out, "There are possibly some additional errors.")
    val () = fprint_newline_ne (out)
  } // end of [if]
in
  // nothing
end else () // end of [if]
//
end // end of [fprint_the_docerrlst]

(* ****** ****** *)

implement
lexbufpos2_docerr (
  buf, pos0, pos1, node
) = let
  val loc = $LOC.location_make_pos_pos (pos0, pos1)
  val () = the_docerrlst_add (docerr_make (loc, node))
in
  // nothing
end // end of [lexbufpos2_docerr]

(* ****** ****** *)

(* end of [atsdoc_translate_error.dats] *)
