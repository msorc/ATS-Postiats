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

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

extern
fun fprint_newline_ne (out: FILEref): void = "mac#libatsdoc_fprint_newline"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload
LOC = "src/pats_location.sats"
typedef position = $LOC.position
//
macdef posincby1
  (pos) = $LOC.position_incby_count (,(pos), 1u)
macdef posincbyc
  (pos, i) = $LOC.position_incby_char (,(pos), ,(i))
//
(* ****** ****** *)

staload "src/pats_lexbuf.sats"

(* ****** ****** *)

staload "./../SATS/atsdoc_translate.sats"

(* ****** ****** *)

(* ****** ****** *)

#define i2c int2char0

#define u2i g0uint2int_uint_int
#define i2u g0int2uint_int_uint

(* ****** ****** *)

macdef
neof (i) = (,(i) >= 0)

(* ****** ****** *)

implement
fprint_funarg (out, x) =
  case+ funarg_view (x) of
  | ~FAint (int) => fprint_string (out, int)
  | ~FAident (ide) => fprint_string (out, ide)
  | ~FAstrsub (str) => let
      val () = fprint_char (out , '"')
      val () = fprint_string (out, str)
      val () = fprint_char (out , '"')
    in
      // nothing
    end // end of [FAstrsub]
  | ~FAfunres (res) => fprint_string (out, res) 
  | ~FAnil () => fprint_string (out, "#error")
// end of [fprint_funarg]

implement
fprint_funarglst (out, xs) = let
  fun loop (out: FILEref, xs: funarglst, i: int): void =
    case+ glist_view<funarg> (xs) of
    | ~GLcons (x, xs) => let
        val () = if i > 0 then fprint_string (out, ", ")
        val () = fprint_funarg (out, x)
      in
        loop (out, xs, i+1)
      end // end of [GLcons]
    | ~GLnil () => ()
  // end of [loop]
  val () = fprint_char (out, '\(')
  val () = loop (out, xs, 0)
  val () = fprint_char (out, ')')
in
  // nothing
end // end of [fprint_funarglst]

(* ****** ****** *)
//
// HX: [stroutptr] of ATS1 (a queue of chars): a growable buffer (C)
//
extern
fun sbuf_make (): ptr = "mac#libatsdoc_sbuf_make"
extern
fun sbuf_add_char (b: ptr, c: char): void = "mac#libatsdoc_sbuf_add_char"
extern
fun sbuf_add_string (b: ptr, s: string): void = "mac#libatsdoc_sbuf_add_string"
extern
fun sbuf_takeout (b: ptr): Strptr1 = "mac#libatsdoc_sbuf_takeout_nonul"

%{^
#include "libatsdoc/CATS/libatsdoc_sbuf.cats"
%}

(* the contents of the buffer (which is freed); the string is kept *)
fun sbuf2string (b: ptr): string = $UN.castvwtp0{string}(sbuf_takeout (b))

(* ****** ****** *)

extern
fun trans_extcode_START (
  out: ptr, buf: &lexbuf, pos0: &position, pos: &position
) : void // end of [trans_extcode_START]

(* ****** ****** *)

implement
trans_extcode
  (buf, pos0, pos) = let
  val out = sbuf_make ()
  val () = trans_extcode_START (out, buf, pos0, pos)
  val loc = $LOC.location_make_pos_pos (pos0, pos)
  val str = sbuf2string (out)
  val ext = tranitm_make (loc, tranitm_node_EXTCODE (str))
  val () = the_tranitmlst_add (ext)
in
  // nothing
end // end of [trans_extcode]

implement
trans_extcode_START
  (out, buf, pos0, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then let
  val c = (i2c)i
in
  case+ c of
  | '%' when // HX: only if '%}' initiates a newline
      $LOC.position_get_ncol (pos) = 0 => let
      val res = testing_literal (buf, pos, "%}")
    in
      if res >= 0 then (
        // HX: '%}' is skipped
      ) else let
        val () = posincby1 (pos)
        val () = sbuf_add_char (out, c)
      in
        trans_extcode_START (out, buf, pos0, pos)
      end // end of [if]
    end // end of ['%' when ...]
  | _ => let
      val () = posincbyc (pos, i)
      val () = sbuf_add_char (out, c)
    in
      trans_extcode_START (out, buf, pos0, pos)
    end // end of [_]
end else (
  lexbufpos2_docerr (buf, pos0, pos, DE_EXTCODE_unclose)
) (* end of [if] *)
//
end // end of [trans_extcode_START]

(* ****** ****** *)

#define SQUOTE '\''
#define DQUOTE '"'
#define SHARP '#'
#define SLASH '\\'

extern
fun trans_string ( // single quoted
  SDQ: char, out: ptr, buf: &lexbuf, pos0: &position, pos: &position
) : void // end of [trans_sstring]
extern
fun trans_string_SHARP
  (out: ptr, buf: &lexbuf, pos: &position): void
// end of [trans_sstring_SHARP]
extern
fun trans_string_SLASH
  (SDQ: char, out: ptr, buf: &lexbuf, pos: &position): void
// end of [trans_sstring_SLASH]

(* ****** ****** *)

implement
trans_string
  (SDQ, out, buf, pos0, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then let
  val c = (i2c)i
in
  case+ c of
  | _ when c = SDQ => let
      val () = posincby1 (pos) in () // HX: closing properly
    end // end of [SDQ]
  | DQUOTE => let
      val () = posincby1 (pos)
      val () = sbuf_add_char (out, SLASH)
      val () = sbuf_add_char (out, DQUOTE)
    in
      trans_string (SDQ, out, buf, pos0, pos)      
    end
  | SHARP => let
      val () = posincby1 (pos)
      val () = trans_string_SHARP (out, buf, pos)
    in
      trans_string (SDQ, out, buf, pos0, pos)
    end // end of [SHARP]
  | SLASH => let
      val () = posincby1 (pos)
      val () = trans_string_SLASH (SDQ, out, buf, pos)
    in
      trans_string (SDQ, out, buf, pos0, pos)
    end // end OF [SLASH]
  | _ => let
      val () = posincbyc (pos, i)
      val () = sbuf_add_char (out, c)
    in
      trans_string (SDQ, out, buf, pos0, pos)
    end // end of [_]
end else (
  lexbufpos2_docerr (buf, pos0, pos, DE_STRING_unclose)
) (* end of [if] *)
//
end // end of [trans_dstring]

implement
trans_string_SHARP
  (out, buf, pos) = let
  var pos0: position
  val () = $LOC.position_copy (pos0, pos)
  val opt = trans_funcall (buf, pos0, pos)
in
//
case+ opt of
| ~Some_vt (fres) => let
    val () = sbuf_add_char (out, '#')
    val () = sbuf_add_string (out, fres)
    val () = sbuf_add_char (out, '$') // HX: '$' is used as a sep!
  in
    // nothing
  end // end of [Some_vt]
| ~None_vt () => let
    val () = sbuf_add_char (out, '#') in (*nothing*)
  end // end of [if]
//
end // end of [trans_dstring_SHARP]

(* ****** ****** *)

implement
trans_string_SLASH
  (SDQ, out, buf, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then let
  val c = (i2c)i in
  case+ c of
  | _ when c = SDQ => let
      val () = posincby1 (pos)
      val () = sbuf_add_char (out, SLASH)
      val () = sbuf_add_char (out, SDQ)
    in
      // nothing
    end // end of [SDQ]
  | SHARP => let
      val () = posincby1 (pos) in sbuf_add_char (out, SHARP)
    end // end of [SHARP]
  | SLASH => let
      val () = posincby1 (pos) in sbuf_add_char (out, SLASH)
    end // end of [SLASH]
  | _ => let
      val () = posincbyc (pos, i)
      val () = sbuf_add_char (out, SLASH)
      val () = sbuf_add_char (out, c)
    in
      // nothing
    end // end of [_]
end else (
  sbuf_add_char (out, SLASH)
) (* end of [if] *)
//
end // end of [trans_dstring_SLASH]

(* ****** ****** *)

extern
fun trans_funres
  (buf: &lexbuf, pos: &position): Option_vt (string)
// end of [trans_funres]

extern
fun trans_funres_LBRACKET
  (buf: &lexbuf, pos0: &position, pos: &position): Option_vt (string)
// end of [trans_funres_LBRACKET]

(* ****** ****** *)

implement
trans_funres (buf, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then let
  val c = (i2c)i in
  case+ c of
  | '\[' => let
      var pos0: position
      val () = $LOC.position_copy (pos0, pos)
      val () = posincby1 (pos)
    in
      trans_funres_LBRACKET (buf, pos0, pos)
    end // end of ['\[']
  | _ => None_vt ()
end else None_vt () // end of [if]
//
end // end of [trans_funres]

implement
trans_funres_LBRACKET
  (buf, pos0, pos) = let
//
  val k = testing_ident (buf, pos)
  val () = if k < 0 then
    lexbufpos2_docerr (buf, pos0, pos, DE_FUNRES_none)
  // end of [val]
  val k = (if k >= 0 then k else 0): int
  val k = (i2u)k
//
  val st0 = lexbuf_get_base (buf)
  val st1 = $LOC.position_get_ntot (pos0)
  val st = st1 - st0
  val st = $UN.cast{uint}(st)
  val str = lexbuf_get_substrptr1 (buf, st+1u, k)
  val ide = $UN.castvwtp0{string}(str)
//
  val i = lexbufpos_get_char (buf, pos)
in
//
if i = char2int0(']') then let
  val () = posincby1 (pos) in Some_vt (ide)
end else let
  val () = lexbufpos2_docerr (buf, pos0, pos, DE_FUNRES_unclose)
in
  Some_vt (ide)
end // end of [if]
//
end // end of [trans_funres_LBRACKET]

(* ****** ****** *)

extern
fun trans_funarg
  (buf: &lexbuf, pos: &position): funarg
// end of [trans_funarg]

extern
fun trans_funarglst (
  buf: &lexbuf, pos: &position, knd: &int, err: &int
) : funarglst // end of [trans_funarglst]
extern
fun trans_funarglst_OPEN (
  buf: &lexbuf, pos0: &position, pos: &position, cls: char, err: &int, ind: int
) : funarglst // end of [trans_funarglst_OPEN]

(* ****** ****** *)

implement
trans_funarg (buf, pos) = let
//
  val _(*uint*) = testing_spaces (buf, pos)
//
  val i = lexbufpos_get_char (buf, pos)
//
in
//
if neof(i) then let
  val c = (i2c)i in
  case+ c of
  | SQUOTE => let
      var pos0: position
      val () = $LOC.position_copy (pos0, pos)
      val () = posincby1 (pos)
      val out = sbuf_make ()
      val () = trans_string (SQUOTE, out, buf, pos0, pos)
      val str = sbuf2string (out)
    in
      funarg_FAstrsub (str)
    end // end of [SQUOTE]
  | DQUOTE => let
      var pos0: position
      val () = $LOC.position_copy (pos0, pos)
      val () = posincby1 (pos)
      val out = sbuf_make ()
      val () = trans_string (DQUOTE, out, buf, pos0, pos)
      val str = sbuf2string (out)
    in
      funarg_FAstrsub (str)
    end // end of ['"']
  | SHARP => let
      var pos0: position
      val () = posincby1 (pos)
      val () = $LOC.position_copy (pos0, pos)
      val opt = trans_funcall (buf, pos0, pos)
    in
      case+ opt of
      | ~Some_vt (fres) => funarg_FAfunres (fres) | ~None_vt () => funarg_FAnil ()
    end // end of [SHARP]
  | _ when DIGIT_test (c) => let
      val st0 = lexbuf_get_base (buf)
      val st1 = $LOC.position_get_ntot (pos)
      val st = st1 - st0
      val st = $UN.cast{uint}(st)
//
      val () = posincby1 (pos)
      val ln = ftesting_seq0 (buf, pos, DIGIT_test)
      val str = lexbuf_get_substrptr1 (buf, st, ln+1u)
      val str = $UN.castvwtp0{string}(str)
    in
      funarg_FAint (str)
    end // end of [_ when ...]
  | _ when IDENTFST_test (c) => let
//
      val st0 = lexbuf_get_base (buf)
      val st1 = $LOC.position_get_ntot (pos)
      val st = st1 - st0
      val st = $UN.cast{uint}(st)
//
      val () = posincby1 (pos)
      val ln = ftesting_seq0 (buf, pos, IDENTRST_test)
      val str = lexbuf_get_substrptr1 (buf, st, ln+1u)
      val str = $UN.castvwtp0{string}(str)
    in
      funarg_FAident (str)
    end // end of [_ when ...]
  | _ => funarg_FAnil ()
end else (
  funarg_FAnil ()
) (* end of [if] *)
//
end // end of [trans_funarg]

(* ****** ****** *)

fn isdelim (c: char): bool =
  if c = '\(' then true else if c = '\{' then true else false
// end of [isdelim]

fn codelim (c: char): char =
  case+ c of '\(' => ')' | '\{' => '}' | _ => c
// end of [codelim]

fn delim_get_kind (c: char): int =
  if c = '\(' then 0 else if c = '\{' then 1 else ~1
// end of [delim_get_kind]

implement
trans_funarglst
  (buf, pos, knd, err) = let
  val i = lexbufpos_get_char (buf, pos)
//
in
//
if neof(i) then let
  val c = (i2c)i
in
  case+ c of
  | _ when isdelim(c) => let
      var pos0: position
      val () = $LOC.position_copy (pos0, pos)
      val () = posincby1 (pos)
      val () = knd := delim_get_kind (c)
      val cls = codelim (c)
    in
      trans_funarglst_OPEN (buf, pos0, pos, cls, err, 0)
    end // end of ['"']
  | _ => let
      val () = err := err + 1 in glist_nil ()
    end // end of [_]
end else (
  glist_nil ()
) (* end of [if] *)
//
end // end of [trans_funarglst]

implement
trans_funarglst_OPEN
  (buf, pos0, pos, cls, err, ind) = let
//
  val _(*uint*) = testing_spaces (buf, pos)
//
  val i = lexbufpos_get_char (buf, pos)
//
in
//
if neof(i) then let
  val c = (i2c)i in
  case+ c of
  | _ when c = cls => let
      val () = posincby1 (pos) in glist_nil ()
    end // end of [')']
  | _ => (
      if ind > 0 then (
        if c = ',' then let
          val () = posincby1 (pos) 
          val _(*uint*) = testing_spaces (buf, pos)
          val arg = trans_funarg (buf, pos)
          val args = trans_funarglst_OPEN (buf, pos0, pos, cls, err, ind+1)
        in
          glist_cons<funarg> (arg, args)
        end else let
          val () = err := err + 1
          val () = lexbufpos2_docerr (buf, pos0, pos, DE_FUNARGLST_unclose)
        in
          glist_nil ()
        end // end of [if]
      ) else let
        val arg = trans_funarg (buf, pos)
        val args = trans_funarglst_OPEN (buf, pos0, pos, cls, err, ind+1)
      in
        glist_cons<funarg> (arg, args)
      end // end of [if]
   ) (* end of [_] *)
end else let
  val () = err := err + 1
  val () = lexbufpos2_docerr (buf, pos0, pos, DE_FUNARGLST_unclose)
in
  glist_nil ()
end (* end of [if] *)
//
end // end of [trans_funarglst_OPEN]

(* ****** ****** *)

implement
trans_funcall
  (buf, pos0, pos) = let
//
  val k = testing_ident (buf, pos)
in
//
if k >= 0 then let
//
  val st0 = lexbuf_get_base (buf)
  val st1 = $LOC.position_get_ntot (pos0)
  val st = st1 - st0
  val st = $UN.cast{uint}(st)
//
  val k = i2u (k)
  val fnam = lexbuf_get_substrptr1 (buf, st, k)
  val fnam = $UN.castvwtp0{string}(fnam)
  val fres = funcall_get_fres () // HX: incrementally stamped
//
// HX: [fres] may be supplied by the user
//
  val opt = trans_funres (buf, pos) 
  val fres = (case+ opt of
    | ~Some_vt ide => ide | ~None_vt () => fres
  ) : string // end of [val]
//
  var knd: int = 0
  var err: int = 0
  val xs = trans_funarglst (buf, pos, knd, err)
  val loc = $LOC.location_make_pos_pos (pos0, pos)
  val fcal = tranitm_make (loc, tranitm_node_FUNCALL (fnam, knd, xs, fres))
  val () = the_tranitmlst_add (fcal)
//
in
  Some_vt (fres)
end else None_vt () // end of [if]
//
end // end of [trans_funcall]

(* ****** ****** *)

implement
fprint_the_tranitmlst
  (out, basename) = let
(*
** HX: [basename] is no longer needed!
*)
  fun loop (
    out: FILEref, xs: glist(tranitm)
  ) : void =
    case+ glist_view<tranitm> (xs) of
    | ~GLcons (x, xs) => let
        val () = fprint_string (out, "(*\n")
        val () = fprint_loc (out, x.tranitm_loc())
        val () = fprint_string (out, "\n*)\n")
        val () = fprint_tranitm (out, x)
        val () = fprint_newline_ne (out) // HX: more readable
      in
        loop (out, xs)
      end // end of [GLcons]
    | ~GLnil () => ()
  // end of [loop]
  val xs = the_tranitmlst_get ()
in
  loop (out, xs)
end // end of [fprint_the_tranitmlst]

(* ****** ****** *)

(* end of [atsdoc_translate_item.dats] *)
