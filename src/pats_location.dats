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
//
#include "share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_location.sats"

(* ****** ****** *)

assume
position_t0ype =
$extype_struct
"pats_position_struct" of
{
  ntot= lint, nrow= int, ncol= int
} // end of [position_t0ype]

(* ****** ****** *)
//
implement
print_position
  (pos) = fprint_position (stdout_ref, pos)
//
(* ****** ****** *)

implement
fprint_position
  (out, pos) = let
//
val ntot = pos.ntot
val nrow = pos.nrow
val ncol = pos.ncol
//
val () = fprint_lint (out, ntot+1L)
val () = fprint_string (out, "(line=")
val () = fprint_int (out, nrow+1)
val () = fprint_string (out, ", offs=")
val () = fprint_int (out, ncol+1)
val () = fprint_string (out, ")")
//
in
  // nothing
end // end of [fprint_position]

(* ****** ****** *)

implement position_get_ntot (pos) = pos.ntot
implement position_get_nrow (pos) = pos.nrow
implement position_get_ncol (pos) = pos.ncol

(* ****** ****** *)

implement
position_init
(
  pos0, ntot, nrow, ncol
) = () where {
  val () = pos0.ntot := ntot
  val () = pos0.nrow := nrow
  val () = pos0.ncol := ncol
} (* end of [position_init] *)

implement
position_copy
(
  pos0, pos1
) = () where {
  val () = pos0.ntot := pos1.ntot
  val () = pos0.nrow := pos1.nrow
  val () = pos0.ncol := pos1.ncol
} (* end of [position_copy] *)

(* ****** ****** *)

implement
position_incby_char
  (pos, i) =
if i >= 0 then let
//
  #define c2i char2int0
//
  val () =
    pos.ntot := pos.ntot + 1L
  // end of [val]
  val () = if i = (c2i)'\n' then let
    val () = pos.nrow := pos.nrow + 1
    val () = pos.ncol := 0
  in
    // nothing
  end else let
    val () = pos.ncol := pos.ncol + 1
  in
    // nothing
  end // end of [if]
in
  // nothing
end // end of [position_incby_char]

(* ****** ****** *)

implement
position_decby_count
  (pos, n) = () where {
//
  #define u2i g0uint2int_uint_int
  #define u2l g0uint2int_uint_lint
//
  val () = pos.ntot := pos.ntot - (u2l)n
  val () = pos.ncol := pos.ncol - (u2i)n
} // end of [position_decby_count]

implement
position_incby_count
  (pos, n) = () where {
//
  #define u2i g0uint2int_uint_int
  #define u2l g0uint2int_uint_lint
//
  val () = pos.ntot := pos.ntot + (u2l)n
  val () = pos.ncol := pos.ncol + (u2i)n
} // end of [position_incby_count]

(* ****** ****** *)
//
// HX-2026-10: the arena encoding of location/locpragma
//
#include "./pats_location_gen_dats.hats"
//
(* ****** ****** *)

implement
location_get_bchar (loc) = loc.beg_ntot()

(* ****** ****** *)

implement
location_beg_nrow (loc) = loc.beg_nrow()

(* ****** ****** *)

implement
location_beg_ntot (loc) = loc.beg_ntot()
implement
location_end_ntot (loc) = loc.end_ntot()

(* ****** ****** *)
//
implement
print_location
  (loc) = fprint_location(stdout_ref, loc)
//
implement
prerr_location
  (loc) = fprint_location(stderr_ref, loc)
//
(* ****** ****** *)
//
%{^
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//
static int patsopt_legacyerrors_state = -1 ;
//
int
patsopt_legacyerrors_get()
{
  if (patsopt_legacyerrors_state < 0)
  {
    char *e = getenv("PATSOPT_LEGACY_ERRORS") ;
    patsopt_legacyerrors_state = (e && *e) ? 1 : 0 ;
  }
  return patsopt_legacyerrors_state ;
}
void
patsopt_legacyerrors_set(int flag)
{
  patsopt_legacyerrors_state = flag ; return ;
}
//
static char *patsopt_errloc_file = (char*)0 ; // pending
static long patsopt_errloc_beg = -1 ;
static long patsopt_errloc_end = -1 ;
static int patsopt_errloc_row = 0 ; // 1-based
static int patsopt_errloc_atexit = 0 ;
//
static char *patsopt_errloc_cname = (char*)0 ; // cache
static char *patsopt_errloc_cbuf = (char*)0 ;
static long patsopt_errloc_clen = -1 ;
//
static
void
patsopt_errloc_load(const char *name)
{
  FILE *fp ; long n ;
  if (patsopt_errloc_cname && !strcmp(patsopt_errloc_cname, name)) return ;
  free(patsopt_errloc_cname) ; free(patsopt_errloc_cbuf) ;
  patsopt_errloc_cname = (char*)0 ; patsopt_errloc_cbuf = (char*)0 ;
  patsopt_errloc_clen = -1 ;
  fp = fopen(name, "rb") ;
  if (!fp) return ;
  if (fseek(fp, 0L, SEEK_END) != 0 ||
      (n = ftell(fp)) < 0 || fseek(fp, 0L, SEEK_SET) != 0)
    { fclose(fp) ; return ; }
  patsopt_errloc_cbuf = (char*)malloc((size_t)n+1) ;
  if (!patsopt_errloc_cbuf) { fclose(fp) ; return ; }
  if (fread(patsopt_errloc_cbuf, 1, (size_t)n, fp) != (size_t)n)
    { free(patsopt_errloc_cbuf) ;
      patsopt_errloc_cbuf = (char*)0 ; fclose(fp) ; return ; }
  fclose(fp) ;
  patsopt_errloc_cbuf[n] = 0 ;
  patsopt_errloc_clen = n ;
  patsopt_errloc_cname = strdup(name) ;
  return ;
}
//
void
patsopt_errloc_flush()
{
  char *file = patsopt_errloc_file ;
  long beg = patsopt_errloc_beg, end = patsopt_errloc_end ;
  int row = patsopt_errloc_row ;
  const char *buf ; long len, ls, le, p ;
  int nshown = 0, w, k ;
  char num[32] ;
  if (!file) return ;
  patsopt_errloc_file = (char*)0 ; patsopt_errloc_beg = -1 ;
  patsopt_errloc_load(file) ; free(file) ;
  if (patsopt_errloc_clen < 0) return ;
  buf = patsopt_errloc_cbuf ; len = patsopt_errloc_clen ;
  if (beg < 0 || beg > len) return ;
  if (end < beg) end = beg ;
  if (end > len) end = len ;
  ls = beg ; while (ls > 0 && buf[ls-1] != '\n') ls -= 1 ;
  { // width of the gutter
    int r = row, lines = 1 ; long q ;
    for (q = beg ; q < end && lines < 3 ; q += 1)
      if (buf[q] == '\n') lines += 1 ;
    sprintf(num, "%d", r + lines - 1) ;
    w = (int)strlen(num) ; if (w < 5) w = 5 ;
  }
  for (;;)
  {
    long a, b ; // highlighted bytes [a,b) of the line
    le = ls ; while (le < len && buf[le] != '\n') le += 1 ;
    p = le ; if (p > ls && buf[p-1] == '\r') p -= 1 ;
    a = (beg > ls) ? beg : ls ;
    if (beg < ls) while (a < p && (buf[a] == ' ' || buf[a] == '\t')) a += 1 ;
    b = (end < p) ? end : p ;
    if (b < a) b = a ;
    fprintf(stderr, "%*d | ", w, row) ;
    fwrite(buf+ls, 1, (size_t)(p-ls), stderr) ; fputc('\n', stderr) ;
    if (p > ls)
    {
      fprintf(stderr, "%*s | ", w, "") ;
      for (k = ls ; k < a ; k += 1)
        if (((unsigned char)buf[k] & 0xC0) != 0x80)
          fputc(buf[k] == '\t' ? '\t' : ' ', stderr) ;
      if (b == a) fputc('^', stderr) ;
      else {
        int first = 1 ;
        for (k = a ; k < b ; k += 1)
          if (((unsigned char)buf[k] & 0xC0) != 0x80)
            { fputc(first ? '^' : '~', stderr) ; first = 0 ; }
      }
      fputc('\n', stderr) ;
    }
    nshown += 1 ;
    if (le + 1 >= end || le >= len) break ;
    if (nshown >= 3) { fprintf(stderr, "%*s ...\n", w, "") ; break ; }
    ls = le + 1 ; row += 1 ;
  }
  return ;
}
//
void
patsopt_errloc_pending(const char *file, long beg, long end, int row)
{
  patsopt_errloc_flush() ;
  if (beg < 0 || end < beg || !file) return ;
  patsopt_errloc_file = strdup(file) ;
  patsopt_errloc_beg = beg ; patsopt_errloc_end = end ;
  patsopt_errloc_row = row ;
  if (!patsopt_errloc_atexit)
    { patsopt_errloc_atexit = 1 ; atexit(patsopt_errloc_flush) ; }
  return ;
}
%}
//
extern fun patsopt_legacyerrors_get (): int = "mac#"
extern fun patsopt_errloc_flush (): void = "mac#"
extern
fun patsopt_errloc_pending
  (file: string, beg: lint, fin: lint, row: int): void = "mac#"
//
(* ****** ****** *)

implement
prerr_errloc_flush () = patsopt_errloc_flush ()

implement
prerr_errloc (loc) = let
  val err = stderr_ref
in
//
if patsopt_legacyerrors_get() > 0
  then fprint_location (err, loc)
  else let
    val b = loc.beg_ntot() and e = loc.end_ntot()
    val nr1 = loc.beg_nrow()+1 and nr2 = loc.end_nrow()+1
    val nc1 = loc.beg_ncol()+1 and nc2 = loc.end_ncol()+1
    val fil = loc.filename()
    val () = patsopt_errloc_flush ()
    val () = fprint_locpragma (err, loc.locpragma())
    val () = $FIL.fprint_filename_full (err, fil)
    val () = fprint_string (err, ":")
    val () = fprint_int (err, nr1)
    val () = fprint_string (err, ":")
    val () = fprint_int (err, nc1)
    val () = fprint_string (err, "-")
    val () =
    if nr2 > nr1 then (fprint_int (err, nr2); fprint_string (err, ":"))
    val () = fprint_int (err, nc2)
    val () =
    if b >= 0L then
      patsopt_errloc_pending
      ($SYM.symbol_get_name($FIL.filename_get_fullname(fil)), b, e, nr1)
  in
    // nothing
  end // end of [else]
//
end // end of [prerr_errloc]

(* ****** ****** *)

implement
fprint_locrange
  (out, loc) = () where {
//
val () =
  fprint_lint (out, loc.beg_ntot()+1L)
val () = fprint_string (out, "(line=")
val () = fprint_int (out, loc.beg_nrow()+1)
val () = fprint_string (out, ", offs=")
val () = fprint_int (out, loc.beg_ncol()+1)
val () = fprint_string (out, ")")
//
val () = fprint_string (out, " -- ")
//
val () =
  fprint_lint (out, loc.end_ntot()+1L)
val () = fprint_string (out, "(line=")
val () = fprint_int (out, loc.end_nrow()+1)
val () = fprint_string (out, ", offs=")
val () = fprint_int (out, loc.end_ncol()+1)
val () = fprint_string (out, ")")
//
} (* end of [fprint_locrange] *)

(* ****** ****** *)

implement
fprint_location
  (out, loc) = let
in
//
fprint_locpragma(out, loc.locpragma());
$FIL.fprint_filename_full (out, loc.filename());
fprint_string (out, ": "); fprint_locrange (out, loc)
//
end (* end of [fprint_location] *)

(* ****** ****** *)

implement
fprint2_location
  (out, loc) = let
in
//
fprint_locpragma(out, loc.locpragma());
$FIL.fprint2_filename_full (out, loc.filename());
fprint_string (out, ": "); fprint_locrange (out, loc)
//
end (* end of [fprint2_location] *)

(* ****** ****** *)

implement
location_dummy =
location_LOCATION
(
  $FIL.filename_dummy
, ~1L, ~1, ~1, ~1L, ~1, ~1, locpragma0_make()
) (* end of [location_dummy] *)

(* ****** ****** *)

implement
location_filename_origin
  (fil) =
location_LOCATION
(
  fil, 0L, 0, 0, 0L, 0, 0, locpragma0_make()
) (* end of [location_filename_origin] *)

(* ****** ****** *)

implement
location_make_pos_pos
  (pos1, pos2) = let
  val fil = $FIL.filename_get_current ()
in
  location_make_fil_pos_pos (fil, pos1, pos2)
end // end of [location_make_pos_pos]

(* ****** ****** *)

implement
location_make_fil_pos_pos
  (fil, pos1, pos2) =
location_LOCATION
(
  fil
, pos1.ntot, pos1.nrow, pos1.ncol
, pos2.ntot, pos2.nrow, pos2.ncol
, the_location_pragma_get()
) // end of [location_make_pos_pos]

(* ****** ****** *)

implement
location_leftmost
  (loc) =
location_LOCATION
(
  loc.filename()
, loc.beg_ntot(), loc.beg_nrow(), loc.beg_ncol()
, loc.beg_ntot(), loc.beg_nrow(), loc.beg_ncol()
, loc.locpragma()
) // end of [location_leftmost]

implement
location_rightmost
  (loc) =
location_LOCATION
(
  loc.filename()
, loc.end_ntot(), loc.end_nrow(), loc.end_ncol()
, loc.end_ntot(), loc.end_nrow(), loc.end_ncol()
, loc.locpragma()
) // end of [location_rightmost]

(* ****** ****** *)

local

fn
location_is_none
(
  loc: location
) : bool = (loc.beg_ntot() < 0L)

fn
location_combine_main
(
  loc1: location, loc2: location
) : location = let
//
  var beg_ntot: lint
  var beg_nrow: int and beg_ncol: int
  var end_ntot: lint
  var end_nrow: int and end_ncol: int
//
  val () =
  if loc1.beg_ntot() <= loc2.beg_ntot()
    then begin
      beg_nrow := loc1.beg_nrow();
      beg_ncol := loc1.beg_ncol();
      beg_ntot := loc1.beg_ntot();
    end // end of [then]
    else begin
      beg_nrow := loc2.beg_nrow();
      beg_ncol := loc2.beg_ncol();
      beg_ntot := loc2.beg_ntot();
    end // end of [else]
  // end of [if] // end of [val]
//
  val () =
  if loc1.end_ntot() >= loc2.end_ntot()
    then begin
      end_nrow := loc1.end_nrow();
      end_ncol := loc1.end_ncol();
      end_ntot := loc1.end_ntot();
    end // end of [then]
    else begin
      end_nrow := loc2.end_nrow();
      end_ncol := loc2.end_ncol();
      end_ntot := loc2.end_ntot();
    end // end of [else]
  // end of [if] // end of [val]
//
in
  location_LOCATION
  (
    loc1.filename()
  , beg_ntot, beg_nrow, beg_ncol
  , end_ntot, end_nrow, end_ncol
  , loc1.locpragma()
  ) (* end of [location_LOCATION] *)
end // end of [location_combine_main]

in // in of [local]

implement
location_combine
  (loc1, loc2) = case+ 0 of
  | _ when location_is_none loc1 => loc2
  | _ when location_is_none loc2 => loc1
  | _ (*rest*) => location_combine_main (loc1, loc2)
// end of [location_combine]

end // end of [local]

(* ****** ****** *)

implement
fprint_line_pragma
  (out, loc) = let
//
val
line = loc.beg_nrow()
//
val () =
if
line >= 0
then let
  val () = fprint_string (out, "#line ")
  val () = fprint_int (out, line+1) // counting from 1
  val () = fprint_string (out, " \"")
  val () = $FIL.fprint_filename_full (out, loc.filename())
  val () = fprint_string (out, "\"\n")
in
  // nothing
end // end of [then]
else let
in
  // nothing
end // end of [else]
//
in
  // nothing
end // end of [fprint_line_pragma]

(* ****** ****** *)

local
//
// HX: the global state is kept in cells of the global arena
//
val the_locpragma = the_garena_alloc (sizeof<locpragma>)
val () = $UN.ptr0_set<locpragma> (the_locpragma, locpragma0_make())
val the_locpragmalst = the_garena_alloc (sizeof<glist(locpragma)>)
val () = $UN.ptr0_set<glist(locpragma)> (the_locpragmalst, glist_nil())
//
in (* in-of-local *)
//
implement
locpragma0_make()= locpragma_LOCPRAGMA0()
implement
locpragma1_make(x)= locpragma_LOCPRAGMA1(x)
implement
locpragma2_make(x1, x2)= locpragma_LOCPRAGMA2(x1, x2)
//
implement
the_location_pragma_get
  ((*void*)) = $UN.ptr0_get<locpragma> (the_locpragma)
implement
the_location_pragma_set
  (x0) = $UN.ptr0_set<locpragma> (the_locpragma, x0)
//
implement
the_location_pragma_pop
  ((*void*)) = () where
{
//
  val xs = $UN.ptr0_get<glist(locpragma)> (the_locpragmalst)
  val-~GLcons(x, xs) = glist_view (xs)
  val () = $UN.ptr0_set<locpragma> (the_locpragma, x)
  val () = $UN.ptr0_set<glist(locpragma)> (the_locpragmalst, xs)
//
} (* end of [the_location_pragma_pop] *)
//
implement
the_location_pragma_push
  ((*void*)) = () where
{
//
  val x0 = $UN.ptr0_get<locpragma> (the_locpragma)
  val xs = $UN.ptr0_get<glist(locpragma)> (the_locpragmalst)
  val () = $UN.ptr0_set<locpragma> (the_locpragma, locpragma0_make())
  val () = $UN.ptr0_set<glist(locpragma)> (the_locpragmalst, glist_cons(x0, xs))
//
} (* end of [the_location_pragma_push] *)

(* ****** ****** *)

implement
fprint_locpragma(out, x) =
(
//
case+ locpragma_view(x) of
| ~LOCPRAGMA0() => ()
| ~LOCPRAGMA1(loc) =>
  fprint! (out, "#locpragma(", loc, "): ")
| ~LOCPRAGMA2(fil, loc) =>
  fprint! (out, "#locpragma(", fil, ": ", loc, "): ")
//
) (* end of [fprint_locpragma] *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_location.dats] *)
