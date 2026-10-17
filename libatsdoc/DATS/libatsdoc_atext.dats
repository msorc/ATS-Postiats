(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustworthy Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
SYM = "./../SATS/libatsdoc_symbol.sats"
//
(* ****** ****** *)

staload "./../SATS/libatsdoc_atext.sats"

%{^
#include "libatsdoc/CATS/libatsdoc_symbol.cats"
%}

(* ****** ****** *)

#include "./libatsdoc_atext_gen_dats.hats"

(* ****** ****** *)

implement atext_nil () = atext_ATEXTnil ()
implement
atext_strcst (x) = atext_ATEXTstrcst (the_garena_strdup (x))
implement
atext_strsub (x) = atext_ATEXTstrsub (the_garena_strdup (x))
implement
atext_apptxt2 (x1, x2) = atext_ATEXTapptxt2 (x1, x2)
implement
atext_appstr2 (x1, x2) =
  atext_ATEXTappstr2 (the_garena_strdup (x1), the_garena_strdup (x2))
implement
atext_apptxt3 (x1, x2, x3) = atext_ATEXTapptxt3 (x1, x2, x3)
implement
atext_appstr3 (x1, x2, x3) =
  atext_ATEXTappstr3
    (the_garena_strdup (x1), the_garena_strdup (x2), the_garena_strdup (x3))
implement atext_concatxt (xs) = atext_ATEXTconcatxt (xs)
implement atext_concatxtsep (xs, sep) = atext_ATEXTconcatxtsep (xs, sep)

(* ****** ****** *)

local

fun
glist_of_list_vt
  (xs: atextlst_vt): atextlst = let
  fun loop
    (xs: atextlst_vt, res: atextlst): atextlst =
    case+ xs of
    | ~list_vt_cons (x, xs) => loop (xs, glist_cons<atext> (x, res))
    | ~list_vt_nil () => res
in
  glist_reverse<atext> (loop (xs, glist_nil ()))
end // end of [glist_of_list_vt]

in (* in of [local] *)

implement
atext_concatxt_vt (xs) = atext_concatxt (glist_of_list_vt (xs))
implement
atext_concatxtsep_vt (xs, sep) = atext_concatxtsep (glist_of_list_vt (xs), sep)

end // end of [local]

(* ****** ****** *)

implement atext_newline () = atext_strcst ("\n")

(* ****** ****** *)
//
// HX: the string of the [strptr] is kept for ever
//
implement
atext_strptr (x) = atext_ATEXTstrcst ($UN.castvwtp0{string}(x))

implement
atext_strptr0 (x) = let
  val notnull = strptr_isnot_null (x)
in
  if notnull then
    atext_strptr ($UN.castvwtp0{Strptr1}(x))
  else let
    val () = strptr_free (x) in atext_nil ()
  end // end of [if]
end // end of [atext_strptr0]
//
implement
atext_strcstptr (x) = atext_ATEXTstrcst ($UN.castvwtp0{string}(x))
implement
atext_strsubptr (x) = atext_ATEXTstrsub ($UN.castvwtp0{string}(x))
//
(* ****** ****** *)

extern
fun libatsdoc_filepath2strptr
  (path: string): Strptr0 = "ext#libatsdoc_filepath2strptr"

implement
atext_filepath (path) =
  atext_strptr0 (libatsdoc_filepath2strptr (path))
// end of [atext_filepath]

(* ****** ****** *)

%{$
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

/*
** reads [nbyte] bytes (or up to EOF) of [fd]: -1 for an error
*/
static
long
libatsdoc_fildes_read_all
  (int fd, char *buf, long nbyte)
{
  long ntot = 0 ;
  while (ntot < nbyte)
  {
    ssize_t n = read (fd, buf + ntot, (size_t)(nbyte - ntot)) ;
    if (n < 0) { if (errno == EINTR) continue ; return -1 ; }
    if (n == 0) break ;
    ntot += n ;
  }
  return ntot ;
}

atstype_ptr
libatsdoc_file2strptr
  (atstype_int fd)
{
  int nerr = 0 ;
  char* sbp = (char*)0 ;
//
  long int ofs_beg, ofs_end, nbyte, nread ;
//
  ofs_beg = lseek (fd, 0L, SEEK_CUR) ;
  if (ofs_beg < 0) nerr += 1 ;
  ofs_end = lseek (fd, 0L, SEEK_END) ;
  if (ofs_end < 0) nerr += 1 ;
  ofs_beg = lseek (fd, ofs_beg, SEEK_SET) ;
  if (ofs_beg < 0) nerr += 1 ;
  nbyte = ofs_end - ofs_beg ;
//
  if (nerr == 0) { sbp = (char*)malloc(nbyte + 1) ; }
  if (sbp == NULL) nerr += 1 ;
//
  if (nerr == 0) {
    nread = libatsdoc_fildes_read_all (fd, sbp, nbyte) ;
    if (nread < 0) nerr += 1 ;
  }
//
  if (nerr == 0) {
    sbp[ofs_end] = '\0'; return sbp ;
  }
//
  if (sbp) free (sbp) ; return NULL ;
} /* end of [libatsdoc_file2strptr] */

atstype_ptr
libatsdoc_filepath2strptr
  (atstype_ptr path)
{
  FILE *fp ;
  char *sbp ;
  size_t cap = 4096, len = 0, n ;
  fp = fopen ((char*)path, "r") ;
  if (!fp) return NULL ;
  sbp = (char*)malloc(cap + 1) ;
  while (1) {
    n = fread (sbp + len, 1, cap - len, fp) ;
    len += n ;
    if (len < cap) break ; // EOF or error
    cap *= 2 ;
    sbp = (char*)realloc(sbp, cap + 1) ;
  }
  fclose (fp) ;
  sbp[len] = '\0' ;
  return sbp ;
} /* end of [libatsdoc_filepath2strptr] */

atstype_ptr
libatsdoc_fopen_r (atstype_ptr path)
{
  return fopen ((char*)path, "r") ;
}
%} // end of [%{$]

(* ****** ****** *)

local
//
extern
fun
libatsdoc_tmpfile(): ptr = "mac#tmpfile"
extern
fun
libatsdoc_fileno(out: ptr): int = "mac#fileno"
extern
fun
libatsdoc_rewind(out: ptr): void = "mac#rewind"
extern
fun
libatsdoc_fflush(out: ptr): int = "mac#fflush"
extern
fun
libatsdoc_fclose(out: ptr): int = "mac#fclose"
//
in (* in of [local] *)

implement{a}
tostring_fprint
  (prfx, fpr, x) = let
//
val out = libatsdoc_tmpfile ()
//
in
//
if
$UN.cast{lint}(out) != 0L
then let
//
  val () = fpr($UN.castvwtp0{FILEref}(out), x)
  val err = libatsdoc_fflush(out)
  val () = libatsdoc_rewind(out)
  val [fd:int] fd = g1ofg0 (libatsdoc_fileno(out))
//
  prval pffil = $UN.castview0{fildes_v(fd)}(0)
  val res = file2strptr(pffil | fd)
  prval ((*void*)) = $UN.castview0{void}(pffil)
//
  val err = libatsdoc_fclose(out)
in
  res (*strptr*)
end // end of [then]
else strptr_null((*void*))
//
end // end of [tostring_fprint]

end // end of [local]

(* ****** ****** *)

implement
tostring_strsub (sub) = 
  tostring_fprint<string> ("libatsdoc_tostring_strsub", fprint_strsub, sub)
// end of [tostring_strsub]

(* ****** ****** *)

//
// HX: the value of a symbol (a C table, libatsdoc_symbol.dats) is its atext
//
extern
fun symbol_get_value (s: symbol): ptr = "mac#libatsdoc_symbol_get_value"
extern
fun symbol_set_value (s: symbol, x: atext): void = "mac#libatsdoc_symbol_set_value"

implement
theAtextMap_search (s) = let
  val x = symbol_get_value (s)
in
  if $UN.cast{lint}(x) != 0L
    then Some_vt ($UN.cast{atext}(x)) else None_vt ()
end // end of [theAtextMap_search]

implement
theAtextMap_insert (s, x) = symbol_set_value (s, x)

implement
theAtextMap_insert_str (s, x) = let
  val s = $SYM.symbol_make_string (s) in theAtextMap_insert (s, x)
end // end of [theAtextMap_insert_str]

(* ****** ****** *)

implement
fprint_atext (out, x) = (
  case+ atext_view (x) of
//
  | ~ATEXTnil () => ()
//
  | ~ATEXTstrcst (str) => fprint_string (out, str)
  | ~ATEXTstrsub (sub) => fprint_strsub (out, sub)
//
  | ~ATEXTapptxt2 (x1, x2) => {
      val () = fprint_atext (out, x1)
      val () = fprint_atext (out, x2)
    }
  | ~ATEXTappstr2 (x1, x2) => {
      val () = fprint_string (out, x1)
      val () = fprint_string (out, x2)
    }
//
  | ~ATEXTapptxt3 (x1, x2, x3) => {
      val () = fprint_atext (out, x1)
      val () = fprint_atext (out, x2)
      val () = fprint_atext (out, x3)
    }
  | ~ATEXTappstr3 (x1, x2, x3) => {
      val () = fprint_string (out, x1)
      val () = fprint_string (out, x2)
      val () = fprint_string (out, x3)
    }
//
  | ~ATEXTconcatxt (xs) => fprint_atextlst (out, xs)
  | ~ATEXTconcatxtsep (xs, sep) => fprint_atextlst_sep (out, xs, sep)
//
) (* end of [fprint_atext] *)

implement
fprint_atextlst (out, xs) =
  case+ glist_view<atext> (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs) => (fprint_atext (out, x); fprint_atextlst (out, xs))
// end of [fprint_atextlst]

implement
fprint_atextlst_sep
  (out, xs, sep) = let
  fun loop (
    xs: atextlst, i: int
  ) : void =
    case+ glist_view<atext> (xs) of
    | ~GLcons (x, xs) => let
        val () = if i > 0 then fprint_atext (out, sep)
        val () = fprint_atext (out, x)
      in
        loop (xs, i+1)
      end // end of [GLcons]
    | ~GLnil () => ()
  // end of [loop]
in
  loop (xs, 0)
end // end of [fprint_atextlst_sep]

(* ****** ****** *)

(*
** HX: as in ATS1, EOF is -1 (the reader of a string returns the char as a
** signed int: a string that contains the byte 0xFF stops there)
*)
extern
fun fputc_err (c: char, out: FILEref): int = "mac#fputc"

(*
** HX: a reader (as in libatsdoc_reader.dats of ATS1, which is not ported:
** the readers of src/ need the initialization of src/): a string or a file
*)
extern
fun rd_make_string (s: string): ptr = "mac#libatsdoc_rd_make_string"
extern
fun rd_make_filp (fp: ptr): ptr = "mac#libatsdoc_rd_make_filp"
extern
fun rd_get (r: ptr): int = "mac#libatsdoc_rd_get"
extern
fun rd_free (r: ptr): void = "mac#libatsdoc_rd_free"

%{^
#include <stdio.h>
#include <stdlib.h>
typedef struct { int kind ; void *ptr ; } libatsdoc_rd_struct ; // kind: 0 file, 1 string
static inline
atstype_ptr
libatsdoc_rd_make_string (atstype_ptr s)
{
  libatsdoc_rd_struct *r = (libatsdoc_rd_struct*)malloc(sizeof(libatsdoc_rd_struct)) ;
  r->kind = 1 ; r->ptr = s ; return r ;
}
static inline
atstype_ptr
libatsdoc_rd_make_filp (atstype_ptr fp)
{
  libatsdoc_rd_struct *r = (libatsdoc_rd_struct*)malloc(sizeof(libatsdoc_rd_struct)) ;
  r->kind = 0 ; r->ptr = fp ; return r ;
}
// HX: as in ATS1, a char of a string is the (signed) char: 0xFF is EOF
static inline
atstype_int
libatsdoc_rd_get (atstype_ptr r0)
{
  libatsdoc_rd_struct *r = (libatsdoc_rd_struct*)r0 ;
  if (r->kind == 0) return fgetc ((FILE*)r->ptr) ;
  else {
    const char *p = (const char*)r->ptr ;
    if (*p == '\0') return -1 ;
    r->ptr = (void*)(p + 1) ; return (int)(signed char)*p ;
  }
}
static inline
atstype_void
libatsdoc_rd_free (atstype_ptr r0)
{
  libatsdoc_rd_struct *r = (libatsdoc_rd_struct*)r0 ;
  if (r->kind == 0) fclose ((FILE*)r->ptr) ;
  free (r) ; return ;
}
%}

extern fun fprsub_reader (out: FILEref, inp: ptr): void

(* ****** ****** *)

extern
fun sbuf_make (): ptr = "mac#libatsdoc_sbuf_make"
extern
fun sbuf_add_char (b: ptr, c: char): void = "mac#libatsdoc_sbuf_add_char"
extern
fun sbuf_length (b: ptr): size_t = "mac#libatsdoc_sbuf_length"
extern
fun sbuf_takeout (b: ptr): Strptr1 = "mac#libatsdoc_sbuf_takeout"

%{^
#include "libatsdoc/CATS/libatsdoc_sbuf.cats"
%}

local

#define i2c int2char0

fun
IDENTFST_test
  (c: char): bool = case+ 0 of
  | _ when ('a' <= c andalso c <= 'z') => true
  | _ when ('A' <= c andalso c <= 'Z') => true
  | _ when c = '_' => true
  | _ => false
// end of [IDENTFST_test]

fun
IDENTRST_test
  (c: char): bool = case+ 0 of
  | _ when ('a' <= c andalso c <= 'z') => true
  | _ when ('A' <= c andalso c <= 'Z') => true
  | _ when ('0' <= c andalso c <= '9') => true
  | _ when c = '_' => true
  | _ when c = '\'' => true
  | _ => false
// end of [IDENTRST_test]

(*
** HX: an identifier is read into a growable buffer (libatsdoc_sbuf.cats)
*)

fun ident_get (
  inp: ptr, cur: &int, b: ptr
) : void = let
  val fst = (i2c)cur
in
  if IDENTFST_test (fst) then let
    val () = sbuf_add_char (b, fst)
    val () = cur := rd_get (inp)
  in
    identrst_get (inp, cur, b)
  end else ()
end // end of [ident_get]

and identrst_get (
  inp: ptr, cur: &int, b: ptr
) : void = let
  val fst = (i2c)cur
in
  if IDENTRST_test (fst) then let
    val () = sbuf_add_char (b, fst)
    val () = cur := rd_get (inp)
  in
    identrst_get (inp, cur, b)
  end else ()
end // end of [identrst_get]

(*
** HX: [id] is not empty: a marked token is replaced by its text
** (or left as it is when there is no such text)
*)
fun fprsub_ident
  (out: FILEref, id: !Strptr1): void = let
  val id1 = $UN.strptr2string (id)
  val sym = $SYM.symbol_make_string (id1)
  val ans = theAtextMap_search (sym)
in
  case+ ans of
  | ~Some_vt xt => fprint_atext (out, xt)
  | ~None_vt () => (
      fprint_string (out, "#"); fprint_string (out, id1); fprint_string (out, "$")
    ) // end of [None_vt]
end // end of [fprsub_ident]

in // in of [local]

implement
fprsub_reader (out, inp) = let
//
fun aux (
  out: FILEref, inp: ptr, cur: &int
) : void =
  if cur != ~1 then let
    val fst = (i2c)cur
    val () = cur := rd_get (inp)
  in 
    case+ fst of
    | '#' => aux_SHARP (out, inp, cur)
    | '\\' => aux_SLASH (out, inp, cur)
    | _ => let
        val _ = fputc_err (fst, out) in aux (out, inp, cur)
      end // end of [_]
  end // end of [if]
//
and aux_SHARP (
  out: FILEref, inp: ptr, cur: &int
) : void =
  if cur != ~1 then let
    val b = sbuf_make ()
    val () = ident_get (inp, cur, b)
    val n = sbuf_length (b)
    val cs = sbuf_takeout (b)
    val dlrend = (cur = char2int0('$')): bool
//
    val () =
      if dlrend then let
        val () = cur := rd_get (inp)
      in
        if n > 0 then fprsub_ident (out, cs) // valid identifier
      end else let
        val _ = fputc_err ('#', out)
      in
        fprint_strptr (out, cs)
      end // end of [if]
    // end of [val]
    val () = strptr_free (cs)
  in
    aux (out, inp, cur)
  end else let
    val _ = fputc_err ('#', out) in (*nothing*)
  end // end of [if]
//
and aux_SLASH (
  out: FILEref, inp: ptr, cur: &int
) : void =
  if cur != ~1 then let
    val fst = (i2c)cur
    val () = cur := rd_get (inp)
  in
    case+ fst of
    | '#' => let
        val _ = fputc_err ('#', out) in aux (out, inp, cur)
      end // end of ['#']
    | '\\' => let
        val _ = fputc_err ('\\', out) in aux (out, inp, cur)
      end // end of ['\\']
    | _ => let
        val _ = fputc_err ('\\', out); val _ = fputc_err (fst, out)
      in
        aux (out, inp, cur)
      end // end of [_]
  end else let
    val _ = fputc_err ('\\', out) in (*nothing*)
  end // end of [if]
//
  var cur: int
  val () = cur := rd_get (inp)
in
  aux (out, inp, cur)
end // end of [fprsub_reader]

end // end of [local]

(* ****** ****** *)

implement
fprint_strsub
  (out, sub) = let
  val inp = rd_make_string (sub)
  val () = fprsub_reader (out, inp)
  val () = rd_free (inp)
in
  // nothing
end // end of [fprint_strsub]

(* ****** ****** *)

extern
fun libatsdoc_fopen_r (path: string): ptr = "ext#libatsdoc_fopen_r"

implement
fprint_filsub (out, path) = let
  val filp = libatsdoc_fopen_r (path)
in
//
if
$UN.cast{lint}(filp) != 0L
then let
  val inp = rd_make_filp (filp)
  val () = fprsub_reader (out, inp)
  val () = rd_free (inp) // HX: the file is closed
in
  // nothing
end else let
  val () = fprint_string (stderr_ref, "fprint_filsub: [")
  val () = fprint_string (stderr_ref, path)
  val () = fprint_string (stderr_ref, "] cannot be opened!\n")
  val () = $extfcall (void, "exit", 1)
in
  // nothing
end // end of [if]
//
end // end of [fprint_filsub]

(* ****** ****** *)

(* end of [libatsdoc_atext.dats] *)
