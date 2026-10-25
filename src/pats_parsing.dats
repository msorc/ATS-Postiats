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
// Start Time: April, 2011
//

(* ****** ****** *)
//
// HX-2026-10: no GC (see PORTING.md, section "Parser")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
staload STDIO = "libats/libc/SATS/stdio.sats"

(* ****** ****** *)

staload
ERR = "./pats_error.sats"
staload
FIL = "./pats_filename.sats"
staload
LOC = "./pats_location.sats"
staload
SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_lexing.sats"
staload "./pats_tokbuf.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_parsing.sats"

staload _(*templates*) = "./pats_error.dats"
staload _(*templates*) = "./pats_syntax.dats"
staload _(*templates*) = "./pats_parsing_util.dats"

(* ****** ****** *)

implement
{a}(*tmp*)
parse_from_string_parser
  (inp, f) = let
  var buf: tokbuf
  val () =
  tokbuf_initize_string(buf, inp)
  var nerr: int = 0
  val res = f (buf, 0(*bt*), nerr)
  val _(*EOF*) = p_EOF (buf, 0, nerr) // HX: all tokens need to consumed
  val ((*cleared*)) = tokbuf_uninitize(buf)
in
  if nerr = 0 then Some_vt (res) else None_vt ()
end // end of [parse_from_string_parser]

(* ****** ****** *)

implement
parse_from_tokbuf_toplevel
  (stadyn, buf) = let
//
var nerr: int = 0
val ((*void*)) = the_lexerrlst_clear ()
val ((*void*)) = the_parerrlst_clear ()
//
val d0cs =
(
  if stadyn = 0 then
    p_toplevel_sta (buf, nerr) else p_toplevel_dyn (buf, nerr)
  // end of [if]
) : d0eclist // end of [val]
//
val nerr1 = fprint_the_lexerrlst (stderr_ref)
val nerr2 = fprint_the_parerrlst (stderr_ref)
//
val () = if (nerr1 + nerr2) > 0 then $ERR.abort<void> ()
//
in
  d0cs
end // end of [parse_from_tokbuf]

(* ****** ****** *)
//
// HX-2015-10-04:
// This one is for libatsopt
//
implement
parse_from_string_toplevel
  (stadyn, inp) = d0cs where
{
//
var buf: tokbuf
val () = tokbuf_initize_string(buf, inp)
val d0cs = parse_from_tokbuf_toplevel (stadyn, buf)
val ((*cleared*)) = tokbuf_uninitize (buf)
//
} // end of [parser_from_string_toplevel]

(* ****** ****** *)

implement
parse_from_stdin_toplevel
  (stadyn) =
  parse_from_fileref_toplevel(stadyn, stdin_ref)
// end of [parse_from_stdin_toplevel]

implement
parse_from_fileref_toplevel
  (stadyn, inp) = d0cs where
{
//
var buf: tokbuf
//
val () =
tokbuf_initize_getc
  (buf, llam () => $STDIO.fgetc0(inp))
//
val d0cs = parse_from_tokbuf_toplevel (stadyn, buf)
val () = tokbuf_uninitize (buf)
//
} // end of [parse_from_fileref_toplevel]

(* ****** ****** *)

implement
parse_from_filename_toplevel
  (stadyn, fil) = let
//
var buf: tokbuf
//
val
fname =
$FIL.filename_get_fullname(fil)
//
val
fname = $SYM.symbol_get_name(fname)
//
val fp =
  fileref_open_exn(fname, file_mode_r)
//
val ((*void*)) =
  tokbuf_initize_filp(buf, fp)
// end of [val]
//
val (pf|()) =
  $FIL.the_filenamelst_push(fil)
val () =
  $LOC.the_location_pragma_push()
val d0cs_res =
  parse_from_tokbuf_toplevel(stadyn, buf)
val ((*void*)) =
  $FIL.the_filenamelst_pop(pf|(*none*))
val () =
  $LOC.the_location_pragma_pop((*void*))
//
val ((*void*)) = tokbuf_uninitize (buf)
//
in
  d0cs_res
end // end of [parser_from_filename_toplevel]

(* ****** ****** *)

implement
parse_from_filename_toplevel2
  (stadyn, fil) = let
//
val
isnot = $FIL.filename_isnot_dummy(fil)
//
in
//
if
isnot
then parse_from_filename_toplevel(stadyn, fil)
else glist_nil((*void*))
//
end // end of [parse_from_filename_toplevel2]

(* ****** ****** *)

implement
parse_from_givename_toplevel
  (stadyn, given, filref) = let
//
val filopt =
  $FIL.filenameopt_make_local(given)
// end of [val]
in
//
case+ filopt of
| ~Some_vt(fil) => let
    val () = filref := fil
    val d0cs =
      parse_from_filename_toplevel(stadyn, fil)
    // end of [val]
    val ((*void*)) = $FIL.the_filenamelst_ppush(fil)
  in
    d0cs
  end // end of [Some_vt]
| ~None_vt((*void*)) => let
//
    val () = filref := $FIL.filename_dummy
//
(*
    val () =
    the_parerrlst_add (
    parerr_make($LOC.location_dummy, PE_FILENONE(given))
    ) (* end of [the_parerrlst_add] *)
*)
//
    val () =
    prerr_string("patsopt: error(0)")
    val () = prerr_string(": the given file [")
    val () = prerr_string(given)
    val () = prerr_string("] cannot be accessed.")
    val () = prerr_newline()
//
// HX: this is treated as a meta-level failure:
//
  in
    $raise($ERR.PATSOPT_FILENONE_EXN(given)) (*exit*)
  end // end of [None_vt]
//
end // end of [parse_from_givename_toplevel]

(* ****** ****** *)

implement
parse_from_givename_toplevel2
  (stadyn, given, filref) = let
//
val filopt =
  $FIL.filenameopt_make_local(given)
// end of [val]
in
//
case+ filopt of
| ~Some_vt(fil) => let
    val () = filref := fil
    val d0cs =
      parse_from_filename_toplevel(stadyn, fil)
    // end of [val]
    val ((*void*)) = $FIL.the_filenamelst_ppush(fil)
  in
    d0cs
  end // end of [Some_vt]
| ~None_vt((*void*)) => let
//
    val () =
    prerr_string("patsopt: error(0)")
    val () = prerr_string(": the given file [")
    val () = prerr_string(given)
    val () = prerr_string("] cannot be accessed.")
    val () = prerr_newline()
//
    val () = filref := $FIL.filename_dummy in glist_nil()
  end // end of [None_vt]
//
end // end of [parse_from_givename_toplevel2]

(* ****** ****** *)

implement
parse_from_givenames_toplocal2
(
  stadyn, givens, filref
) = let
//
fun
auxlst
(
  stadyn: int
, givens: glist(string)
, filref: &filename >> filename
) : d0eclist =
(
//
case+ glist_view(givens) of
| ~GLnil
    () => glist_nil()
  // GLnil
| ~GLcons
    (given1, givens) => let
//
    var fil1: filename // HX: [filref] is initialized here
    val d0cs =
    parse_from_givename_toplevel2
      (stadyn, given1, fil1)
    val () = filref := fil1
    val d0c1 =
      d0ecl_toplocal
        (fil1, d0cs)
    // end of [val]
    val d0cs =
      auxlst(stadyn, givens, filref)
    // end of [val]
//
  in
    glist_cons(d0c1, d0cs)
  end (* end of [GLcons] *)
//
) (* end of [auxlst] *)
//
in
//
case+ glist_view(givens) of
| ~GLcons
    (given0, givens) => let
//
    val d0cs =
    parse_from_givename_toplevel2
      (stadyn, given0, filref)
//
    val d0c0 = d0ecl_list(filref, d0cs)
    val d0cs = auxlst(stadyn, givens, filref)
//
  in
    glist_cons(d0c0, d0cs)
  end (* end of [GLcons] *)
| ~GLnil((*void*)) => let
    val () =
    filref := $FIL.filename_dummy in glist_nil()
  end // end of [GLnil]
//
end // end of [parse_from_givenames_toplocal2]

(* ****** ****** *)

(* end of [pats_parsing.dats] *)
