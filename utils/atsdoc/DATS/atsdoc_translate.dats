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
// Start Time: July, 2011
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
//
staload
SYM = "src/pats_symbol.sats"
//
staload
FIL = "src/pats_filename.sats"
//
staload
LOC = "src/pats_location.sats"
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

#include "./atsdoc_translate_gen_dats.hats"

(* ****** ****** *)

#define i2c int2char0

#define i2u g0int2uint_int_uint
#define u2i g0uint2int_uint_int

(* ****** ****** *)

macdef
neof (i) = (,(i) >= 0)

(* ****** ****** *)

extern
fun fputc_ref
  (c: char, out: FILEref): int = "mac#fputc"

(* ****** ****** *)
//
// HX: a cell of the global arena (that is never freed) holds each of
// the global values below
//
local

val the_funres_prefix: ptr = let
  val p = the_garena_alloc (sizeof<string>)
  val () = $UN.ptr0_set<string> (p, "__tok")
in p end

val the_funres_count: ptr = let
  val p = the_garena_alloc (sizeof<int>)
  val () = $UN.ptr0_set<int> (p, 1)
in p end

fun funres_get_count (): int = let
  val n = $UN.ptr0_get<int> (the_funres_count)
  val () = $UN.ptr0_set<int> (the_funres_count, n + 1)
in n end // end of [funres_count]

in // in of [local]

implement
funres_get_prfx () = $UN.ptr0_get<string> (the_funres_prefix)
implement
funres_set_prfx (prfx) =
  $UN.ptr0_set<string> (the_funres_prefix, the_garena_strdup (prfx))

implement
funcall_get_fres () = let
  val prfx = funres_get_prfx ()
  val count = funres_get_count ()
  val cnt = $extfcall (Strptr1, "atsdoc_int2strptr", count)
  val res = string0_append (prfx, $UN.strptr2string (cnt))
  val () = strptr_free (cnt)
  val fres = the_garena_strdup ($UN.strptr2string (res)) // HX: kept (the arena)
  val () = strptr_free (res)
in
  fres
end // end of [funcall_get_fres]

end // end of [local]

%{^
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
static inline
atstype_ptr
atsdoc_int2strptr (atstype_int n)
{
  char *buf = (char*)malloc(32) ;
  sprintf (buf, "%i", n) ;
  return buf ;
}
#include "libatsdoc/CATS/libatsdoc_sbuf.cats"
%}

(* ****** ****** *)

implement
tranitm_make (loc, node) = tranitm_TRANITM (loc, node)

(* ****** ****** *)

implement
fprint_tranitm
  (out, itm) =
  case+ tranitm_view (itm) of
  | ~TRANITM (_, node) => (
    case+ tranitm_node_view (node) of
    | ~EXTCODE (code) => (
        fprint_string (out, code)
      ) // end of [EXTCODE]
    | ~FUNCALL (fnam, knd, xs, fres) => let
        val () = fprint_string (out, "val ")
        val () = fprint_string (out, fres)
        val () = fprint_string (out, " = ")
        val () = fprint_string (out, fnam)
        val () = if knd > 0 then fprint_string (out, "$lst")
        val () = fprint_funarglst (out, xs)
        val () = fprint_newline_ne (out)
        val () = fprint_string (out, "val () = theAtextMap_insert_str (\"")
        val () = fprint_string (out, fres)
        val () = fprint_string (out, "\", ")
        val () = fprint_string (out, fres)
        val () = fprint_string (out, ")")
        val () = fprint_newline_ne (out)
      in
        // nothing
      end // end of [FUNCALL]
    ) (* end of [TRANITM] *)
// end of [fprint_tranitm]

(* ****** ****** *)

(*
** HX: [isspace] and [isdigit] of the C locale (the program never calls [setlocale])
*)
fun SPACE_test (c: char): bool =
  (c = ' ' orelse c = '\t' orelse c = '\n' orelse c = '\v' orelse c = '\f' orelse c = '\r')

(* ****** ****** *)

implement
DIGIT_test (c) = ('0' <= c andalso c <= '9')

implement
IDENTFST_test (c) = case+ 0 of
  | _ when ('a' <= c andalso c <= 'z') => true
  | _ when ('A' <= c andalso c <= 'Z') => true
  | _ when c = '_' => true
  | _ => false
// end of [IDENTFST_test]

implement
IDENTRST_test (c) = case+ 0 of
  | _ when ('a' <= c andalso c <= 'z') => true
  | _ when ('A' <= c andalso c <= 'Z') => true
  | _ when ('0' <= c andalso c <= '9') => true
  | _ when c = '_' => true
  | _ when c = '\'' => true
  | _ => false
// end of [IDENTRST_test]

(* ****** ****** *)

implement
ftesting_seq0
  (buf, pos, f) = diff where {
  fun loop (
    buf: &lexbuf, nchr: uint, f: char -> bool
  ) : uint = let
    val i = lexbuf_get_char (buf, nchr)
  in
    if neof(i) then
      if f ((i2c)i)
        then loop (buf, succ(nchr), f) else nchr
      // end of [if]
    else nchr // end of [if]
  end // end of [loop]
  val nchr0 = lexbufpos_diff (buf, pos)
  val nchr1 = loop (buf, nchr0, f)
  val diff = nchr1 - nchr0
  val () = if diff > 0u 
    then $LOC.position_incby_count (pos, diff) else ()
  // end of [val]
} // end of [ftesting_seq0]

(* ****** ****** *)

implement
testing_spaces
  (buf, pos) = let
  fun loop (
    buf: &lexbuf, pos: &position, k: uint
  ) : uint = let
    val i = lexbufpos_get_char (buf, pos)
  in
    if neof(i) then (
      if SPACE_test ((i2c)i) then let
        val () = posincbyc (pos, i) in loop (buf, pos, k+1u)
      end else k // end of [if]
    ) else k // end of [if]
  end // end of [loop]
in
  loop (buf, pos, 0u)
end // end of [testing_spaces]

(* ****** ****** *)
//
// HX: [lit] contains no '\n'!
//
implement testing_literal
  (buf, pos, lit) = res where {
//
val n = string_length (lit)
//
fun loop (
  buf: &lexbuf, nchr: uint, lit: string, n: size_t, k: size_t
) : int =
  if k < n then let
    val i = lexbuf_get_char (buf, nchr)
  in
    if neof(i) then
      if ((i2c)i = $UN.ptr0_get<char> (ptr0_add_guint<char> ($UN.cast{ptr}(lit), k)))
        then loop (buf, succ(nchr), lit, n, succ(k)) else ~1
      // end of [if]
    else ~1 // end of [if]
  end else $UN.cast{int}(k) // end of [if]
// end of [loop]
//
val nchr0 = lexbufpos_diff (buf, pos)
val res = loop (buf, nchr0, lit, n, i2sz(0))
val () = if res >= 0
  then $LOC.position_incby_count (pos, (i2u)res) else ()
// end of [if] // end of [val]
//
} // end of [testing_literal]

(* ****** ****** *)

implement
testing_ident
  (buf, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then (
  if IDENTFST_test ((i2c)i) then let
    val () = posincby1 (pos)
    val nchr = ftesting_seq0 (buf, pos, IDENTRST_test)
  in
    (u2i)nchr + 1
  end else ~1 // end of [if]
) else ~1 // end of [if]
//
end // end of [testing_ident]

(* ****** ****** *)

local
//
// HX: the items are accumulated in reverse order
//
val theList: ptr = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<glist(tranitm)> (p, glist_nil ())
in p end

in // in of [local]

implement
the_tranitmlst_add (x) = let
  val xs = $UN.ptr0_get<glist(tranitm)> (theList)
in
  $UN.ptr0_set<glist(tranitm)> (theList, glist_cons<tranitm> (x, xs))
end // end of [the_tranitmlst_add]

implement
the_tranitmlst_get () = let
  val xs = $UN.ptr0_get<glist(tranitm)> (theList)
  val () = $UN.ptr0_set<glist(tranitm)> (theList, glist_nil ())
in
  glist_reverse<tranitm> (xs)
end // end of [the_tranitmlst_get]

end // end of [local]

(* ****** ****** *)

extern
fun trans_top_PERCENT
  (out: FILEref, buf: &lexbuf, pos: &position): void
// end of [trans_PERCENT]

extern
fun trans_top_SHARP
  (out: FILEref, buf: &lexbuf, pos: &position): void
// end of [trans_SHARP]

extern
fun trans_top_SLASH
  (out: FILEref, buf: &lexbuf, pos: &position): void
// end of [trans_SLASH]

(* ****** ****** *)

implement
trans_top
  (out, buf) = let
//
  var pos: position
  val () = lexbuf_get_position (buf, pos)
//
  val i0 = lexbuf_get_char (buf, 0u)
//
in
//
if neof(i0) then let
  val c = (i2c)i0 // the first character
  val () = posincbyc (pos, i0)
in
  case+ c of
  | '%' => let
      val () = trans_top_PERCENT (out, buf, pos)
      val () = lexbuf_set_position (buf, pos)
    in
      trans_top (out, buf)
    end
  | '#' => let
      val () = trans_top_SHARP (out, buf, pos)
      val () = lexbuf_set_position (buf, pos)
    in
      trans_top (out, buf)
    end
  | '\\' => let
      val () = trans_top_SLASH (out, buf, pos)
      val () = lexbuf_set_position (buf, pos)
    in
      trans_top (out, buf)
    end
  | _ => let
      val err = fputc_ref (c, out)
      val () = lexbuf_set_position (buf, pos)
    in
      trans_top (out, buf)
    end // end of [_]
//
end else () // end of [if]
//
end // end of [trans_top]

(* ****** ****** *)

implement
trans_top_PERCENT
  (out, buf, pos) = let
  val i = lexbufpos_get_char (buf, pos)
  val c = (i2c)i
in
  case+ c of 
  | '\{' when // '%{' at the beginning
      $LOC.position_get_ncol (pos) = 1 => let
      var pos0: position
      val () = lexbuf_get_position (buf, pos0)
      val () = posincby1 (pos)
    in
      trans_extcode (buf, pos0, pos)
    end // end of ['\{']
  | _ => let
      val () = posincbyc (pos, i)
      val err = fputc_ref ('%', out); val err = fputc_ref (c, out)
    in
      // nothing
    end // end of [_]
end // end of [trans_PERCENT]

(* ****** ****** *)

implement
trans_top_SHARP
  (out, buf, pos) = let
  var pos0: position
  val () = $LOC.position_copy (pos0, pos)
  val opt = trans_funcall (buf, pos0, pos)
in
//
case+ opt of
| ~Some_vt (fres) => let // HX: '$' is a separator!
    val () = fprint_string (out, "#")
    val () = fprint_string (out, fres)
    val () = fprint_string (out, "$")
  in
    // nothing
  end // end of [Some_vt]
| ~None_vt () => let
    val err = fputc_ref ('#', out) in (*nothing*)
  end // end of [if]
//
end // end of [trans_top_SHARP]

(* ****** ****** *)

implement
trans_top_SLASH
  (out, buf, pos) = let
  val i = lexbufpos_get_char (buf, pos)
in
//
if neof(i) then let
  val c = (i2c)i in
  case+ c of
  | '\n' => let
      val () = posincbyc (pos, i)
    in
      // nothing
    end // end of ['\n']
  | '#' => let
      val () = posincby1 (pos); val err = fputc_ref (c, out)
    in
      // nothing
    end // end of ['\\']
  | '\\' => let
      val () = posincby1 (pos); val err = fputc_ref (c, out)
    in
      // nothing
    end // end of ['\\']
  | '%' => let
      val () = posincby1 (pos); val err = fputc_ref (c, out)
    in
      // nothing
    end // end of ['\\']
  | _ => let
      val () = posincby1 (pos)
      val err = fputc_ref ('\\', out); val err = fputc_ref (c, out)
    in
      // nothing
    end // end of [_]
end else let
  val err = fputc_ref ('\\', out)
in
  // nothing
end // end of [if]
//
end // end of [trans_top_SLASH]

(* ****** ****** *)
//
// HX: the (relative) file name [basename] is looked up as in ATS1
// (libatsdoc_filename): it is the name that is printed in the messages,
// and the file is opened by its full name (the normalized absolute path)
//
extern
fun atsdoc_fopen_exn
  (path: string): ptr = "ext#atsdoc_fopen_exn"

extern
fun atsdoc_getc_stdin (): int = "mac#getchar"

(* ****** ****** *)

implement
trans_top_from_stdin
  (tout) = () where {
  var buf: lexbuf
  val () = lexbuf_initize_getc (buf, llam () => atsdoc_getc_stdin ())
  val () = trans_top (tout, buf)
  val () = lexbuf_uninitize (buf)
//
  val () = fprint_the_docerrlst (stderr_ref)
//
} // end of [trans_top_from_stdin]

implement
trans_top_from_filename
  (tout, fil) = let
  val fullname = $SYM.symbol_get_name ($FIL.filename_get_fullname (fil))
  val filp = atsdoc_fopen_exn (fullname)
  var buf: lexbuf
  val () = lexbuf_initize_filp (buf, $UN.cast{FILEref}(filp))
//
  val (pfpush | ()) = $FIL.the_filenamelst_push (fil)
  val () = trans_top (tout, buf)
  val () = $FIL.the_filenamelst_pop (pfpush | (*none*))
//
  val () = lexbuf_uninitize (buf)
in
  fprint_the_docerrlst (stderr_ref)
end // end of [trans_top_from_filename]

(* ****** ****** *)

extern
fun atsdoc_file_exists
  (path: string): int = "ext#atsdoc_file_exists"
extern
fun atsdoc_getcwd (): Strptr1 = "ext#atsdoc_getcwd"

(*
** HX: as [filenameopt_make_relative] of libatsdoc_filename.dats did when
** the lists of paths are empty (they always are in atsdoc)
*)
fun atsdoc_filename_make
  (basename: string): $FIL.filenameopt_vt = let
  val isrel = (
    if $UN.ptr0_get<char> ($UN.cast{ptr}(basename)) = '\000'
      then false else ($UN.ptr0_get<char> ($UN.cast{ptr}(basename)) != '/')
  ) : bool
in
//
if atsdoc_file_exists (basename) != 0 then None_vt ()
else let
  val fullname = (
    if isrel then let
      val cwd = atsdoc_getcwd ()
      val full = $FIL.filename_dirbase ($UN.strptr2string (cwd), basename)
      val () = strptr_free (cwd)
      val res = $FIL.path_normalize ($UN.strptr2string (full)) // HX: a copy
      val () = strptr_free (full)
    in
      res
    end else $FIL.path_normalize (basename)
  ) : string
in
  Some_vt ($FIL.filename_make (basename, basename, fullname))
end // end of [if]
//
end // end of [atsdoc_filename_make]

implement
trans_top_from_basename
  (tout, basename) = let
  val filopt = atsdoc_filename_make (basename)
in
//
case+ filopt of
| ~Some_vt (fil) => trans_top_from_filename (tout, fil)
| ~None_vt () => let
    val () = prerr_string ("The file [")
    val () = prerr_string (basename)
    val () = prerr_string ("] cannot be opened for read.\n")
  in
    // nothing
  end // end of [if]
// end of [case]
//
end // end of [trans_top_from_filename]

(* ****** ****** *)

%{$
atstype_ptr
atsdoc_fopen_exn (atstype_ptr path)
{
  FILE *fil = fopen ((char*)path, "r") ;
  if (!fil) {
    perror ("fopen") ;
    fprintf (stderr, "exit(ATS): [fopen(\"%s\", \"%s\")] failed\n", (char*)path, "r") ;
    exit (1) ;
  }
  return fil ;
}

atstype_int
atsdoc_file_exists (atstype_ptr path)
{
  struct stat buf ;
  return (stat ((char*)path, &buf) == 0) ? 0 : -1 ;
}

atstype_ptr
atsdoc_getcwd (void)
{
  size_t sz = 1024 ;
  char *buf = (char*)malloc(sz) ;
  while (1) {
    if (getcwd (buf, sz)) return buf ;
    sz *= 2 ; buf = (char*)realloc(buf, sz) ;
  }
}
%}

(* end of [atsdoc_translate.dats] *)
