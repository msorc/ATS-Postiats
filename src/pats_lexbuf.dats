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
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload
R = "./pats_reader.sats"
stadef reader = $R.reader

(* ****** ****** *)

staload "./pats_lexbuf.sats"

(* ****** ****** *)
//
#define uc2i uchar2int0
#define i2uc int2uchar0
//
#define u2i g0uint2int_uint_int
fn u2l(x: uint): lint = $UN.cast{lint}(x)
#define u2sz g0uint2uint_uint_size
//
fn l2u(x: lint): uint = $UN.cast{uint}(x)
fn l2sz(x: lint): size_t = $UN.cast{size_t}(x)
//
#define sz2i g0uint2int_size_int
fn sz2l(x: size_t): lint = $UN.cast{lint}(x)
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// the character queue lives in C (see pats_lexbuf.cats)
//
vtypedef
lexbuf_struct =
$extype_struct
"pats_lexbuf_struct" of {
  base= lint
, base_nrow=int, base_ncol= int
, nspace= int
, reader= reader
} (* end of [lexbuf_struct] *)
//
assume lexbuf_vt0ype = lexbuf_struct
//
vtypedef
lexbuf_pre =
$extype_struct
"pats_lexbuf_struct" of {
  base= lint
, base_nrow=int, base_ncol= int
, nspace= int
, reader= reader?
} (* end of [lexbuf_pre] *)
//
extern
fun
lexbuf_init
  (buf: &lexbuf? >> lexbuf_pre): void = "mac#patsopt_lexbuf_init"
extern
fun
lexbuf_fini
  (buf: &lexbuf_pre >> lexbuf?): void = "mac#patsopt_lexbuf_fini"
//
extern
fun
lexbuf_qsize
  (buf: &lexbuf): size_t = "mac#patsopt_lexbuf_qsize"
extern
fun
lexbuf_qget
  (buf: &lexbuf, i: size_t): int = "mac#patsopt_lexbuf_qget"
extern
fun
lexbuf_qins
  (buf: &lexbuf, c: int): void = "mac#patsopt_lexbuf_qins"
extern
fun
lexbuf_qclear
  (buf: &lexbuf, n: size_t): void = "mac#patsopt_lexbuf_qclear"
extern
fun
lexbuf_qsub
  (buf: &lexbuf, st: size_t, ln: size_t): ptr = "mac#patsopt_lexbuf_qsub"
//
(* ****** ****** *)

implement
lexbuf_initize_filp
  (buf, fp) = () where
{
val () = lexbuf_init (buf)
val () = $R.reader_initize_filp (buf.reader, fp)
} (* end of [lexbuf_initize_filp] *)

(* ****** ****** *)

implement
lexbuf_initize_getc
  (buf, getc) = () where
{
val () = lexbuf_init (buf)
val () = $R.reader_initize_getc (buf.reader, getc)
} (* end of [lexbuf_initize_getc] *)

(* ****** ****** *)

implement
lexbuf_initize_string
  (buf, inp) = () where
{
val () = lexbuf_init (buf)
val () = $R.reader_initize_string (buf.reader, inp)
} (* end of [lexbuf_initize_string] *)

(* ****** ****** *)

implement
lexbuf_initize_charlst_vt
  (buf, inp) = () where {
val () = lexbuf_init (buf)
val () = $R.reader_initize_charlst_vt (buf.reader, inp)
} (* end of [lexbuf_initize_charlst_vt] *)

(* ****** ****** *)

implement
lexbuf_uninitize
  (buf) = () where {
val () = $R.reader_uninitize (buf.reader)
val () = lexbuf_fini (buf)
} // end of [lexbuf_uninitize]

(* ****** ****** *)

implement
lexbufpos_diff
  (buf, pos) = let
  val nchr = $LOC.position_get_ntot (pos) - buf.base
in
  (l2u)nchr
end // end of [lexbufpos_diff]

(* ****** ****** *)

implement
lexbuf_get_base (buf) = buf.base

(* ****** ****** *)

implement
lexbuf_get_position
  (buf, pos) = let
  val ntot = buf.base
  val nrow = buf.base_nrow
  val ncol = buf.base_ncol
in
  $LOC.position_init (pos, ntot, nrow, ncol)
end // end of [lexbuf_get_position]

(* ****** ****** *)

implement
lexbuf_set_position
  (buf, pos) = let
//
val base = buf.base
val ntot = $LOC.position_get_ntot (pos)
//
val () = buf.base := ntot
val () = buf.base_nrow := $LOC.position_get_nrow (pos)
val () = buf.base_ncol := $LOC.position_get_ncol (pos)
//
val nchr = (l2sz)(ntot - base)
val nbuf = lexbuf_qsize (buf)
//
in
//
if
nchr < nbuf
then lexbuf_qclear (buf, nchr)
else lexbuf_qclear (buf, nbuf)
//
end // end of [lexbuf_set_position]

(* ****** ****** *)

implement
lexbuf_get_nspace (buf) = buf.nspace
implement
lexbuf_set_nspace (buf, n) = buf.nspace := n

(* ****** ****** *)

implement
lexbufpos_get_location
  (buf, pos) = let
  var bpos: position
  val ((*void*)) =
    lexbuf_get_position (buf, bpos)
  // end of [val]
in
  $LOC.location_make_pos_pos (bpos, pos)
end // end of [lexbufpos_get_location]

(* ****** ****** *)

implement
lexbuf_get_char
  (buf, nchr) = let
//
val nchr = (u2sz)nchr
val n = lexbuf_qsize (buf)
//
in
//
if
nchr < n
then lexbuf_qget (buf, nchr)
else let
  val i = $R.reader_get_char (buf.reader)
in
  if i >= 0 then let
    val c = (i2uc)i
    val () = lexbuf_qins (buf, uc2i(c))
  in
    i
  end else
    i (* EOF *)
  // end of [if]
end // end of [else]
//
end // end of [lexbuf_get_char]

(* ****** ****** *)

implement
lexbufpos_get_char
  (buf, pos) = let
  val nchr = $LOC.position_get_ntot (pos) - buf.base
  val nchr = (l2u)nchr
in
  lexbuf_get_char (buf, nchr)
end // end of [lexbufpos_get_char]

(* ****** ****** *)

implement
lexbuf_incby_count
  (buf, cnt) = let
//
  val nchr = u2sz(cnt)
  val n = lexbuf_qsize (buf)
in
  if nchr < n then let
    val () = buf.base := buf.base + (u2l)cnt
    val () = buf.base_ncol := buf.base_ncol + (u2i)cnt
    val () = lexbuf_qclear (buf, nchr)
  in
    // nothing
  end else let
    val () = buf.base := buf.base + (sz2l)n
    val () = buf.base_ncol := buf.base_ncol + (sz2i)n
    val () = lexbuf_qclear (buf, n)
  in
    // nothing
  end (* end of [if] *)
end // end of [lexbuf_incby_count]

(* ****** ****** *)

implement
lexbuf_get_strptr0
  (buf, ln) =
  lexbuf_get_substrptr0(buf, 0u, ln)
// end of [lexbuf_get_strptr0]

implement
lexbuf_get_strptr1
  (buf, ln) =
  lexbuf_get_substrptr1(buf, 0u, ln)
// end of [lexbuf_get_strptr]

(* ****** ****** *)

implement
lexbuf_get_substrptr0
  (buf, st, ln) = let
//
  val i = u2sz(st)
  val k = u2sz(ln)
  val n = lexbuf_qsize (buf)
//
in
//
if i + k <= n then
  $UN.castvwtp0{Strptr0}(lexbuf_qsub (buf, i, k))
else
  $UN.castvwtp0{Strptr0}(the_null_ptr)
// end of [if]
//
end // end of [lexbuf_get_substrptr0]

implement
lexbuf_get_substrptr1
  (buf, st, ln) = str where {
  val str = lexbuf_get_substrptr0 (buf, st, ln)
  val ((*void*)) = assertloc (strptr_isnot_null (str))
  val str = $UN.castvwtp0{Strptr1}(str)
} // end of [lexbuf_get_substrptr1]

(* ****** ****** *)

implement
lexbufpos_get_strptr0
  (buf, pos) = let
  val ln = lexbufpos_diff(buf, pos)
in
  lexbuf_get_strptr0(buf, ln)
end
// end of [lexbufpos_get_strptr0]

implement
lexbufpos_get_strptr1
  (buf, pos) = let
  val ln = lexbufpos_diff(buf, pos)
in
  lexbuf_get_strptr1(buf, ln)
end
// end of [lexbufpos_get_strptr1]

(* ****** ****** *)

(* end of [pats_lexbuf.dats] *)
