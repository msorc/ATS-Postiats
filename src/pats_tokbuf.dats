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

(* ****** ****** *)
//
staload
LBF = "./pats_lexbuf.sats"
//
vtypedef lexbuf = $LBF.lexbuf
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload "./pats_lexing.sats"

(* ****** ****** *)

staload "./pats_tokbuf.sats"

(* ****** ****** *)
//
// HX-2026-10: no GC
// the queue of tokens lives in C (see pats_tokbuf.cats)
//
vtypedef
tokbuf_struct =
$extype_struct
"pats_tokbuf_struct" of
{
  ntok= uint
, lexbuf= lexbuf
} // end of [tokbuf_struct]
//
vtypedef
tokbuf_pre =
$extype_struct
"pats_tokbuf_struct" of
{
  ntok= uint
, lexbuf= lexbuf?
} // end of [tokbuf_pre]

(* ****** ****** *)

assume tokbuf_vt0ype = tokbuf_struct

(* ****** ****** *)
//
extern
fun
tokbuf_init
  (buf: &tokbuf? >> tokbuf_pre): void = "mac#patsopt_tokbuf_init"
extern
fun
tokbuf_fini
  (buf: &tokbuf_pre >> tokbuf?): void = "mac#patsopt_tokbuf_fini"
//
extern
fun
tokbuf_qsize
  (buf: &tokbuf): size_t = "mac#patsopt_tokbuf_qsize"
extern
fun
tokbuf_qget
  (buf: &tokbuf, i: size_t): ptr = "mac#patsopt_tokbuf_qget"
extern
fun
tokbuf_qins_end
  (buf: &tokbuf, x: ptr): void = "mac#patsopt_tokbuf_qins_end"
extern
fun
tokbuf_qins_beg
  (buf: &tokbuf, x: ptr): void = "mac#patsopt_tokbuf_qins_beg"
extern
fun
tokbuf_qclear
  (buf: &tokbuf, n: size_t): void = "mac#patsopt_tokbuf_qclear"
//
(* ****** ****** *)

implement
tokbuf_initize_filp
  (buf, fp) = {
val () = tokbuf_init (buf)
val () = $LBF.lexbuf_initize_filp (buf.lexbuf, fp)
} // end of [tokbuf_initize_filp]

(* ****** ****** *)

implement
tokbuf_initize_getc
  (buf, getc) = () where {
val () = tokbuf_init (buf)
val () = $LBF.lexbuf_initize_getc (buf.lexbuf, getc)
} // end of [tokbuf_initize_getc]

(* ****** ****** *)

implement
tokbuf_initize_string
  (buf, inp) = () where {
val () = tokbuf_init (buf)
val () = $LBF.lexbuf_initize_string (buf.lexbuf, inp)
} // end of [tokbuf_initize_string]

(* ****** ****** *)

implement
tokbuf_initize_lexbuf
  (buf, lbf) = () where {
val () = tokbuf_init (buf)
val () = buf.lexbuf := lbf
} // end of [tokbuf_initize_lexbuf]

(* ****** ****** *)

implement
tokbuf_uninitize
  (buf) = () where {
val () = $LBF.lexbuf_uninitize (buf.lexbuf)
val () = tokbuf_fini (buf)
} // end of [tokbuf_uninitize]

(* ****** ****** *)

implement
tokbuf_get_ntok (buf) = buf.ntok
implement
tokbuf_set_ntok (buf, n) = buf.ntok := n

(* ****** ****** *)

implement
tokbuf_incby1 (buf) = buf.ntok := buf.ntok + 1u
implement
tokbuf_incby_count (buf, k) = buf.ntok := buf.ntok + k

(* ****** ****** *)

implement
tokbuf_reset (buf) = let
//
  val ntok = buf.ntok
  val () = buf.ntok := 0u
  val ntok = g0uint2uint_uint_size (ntok)
  val nqsz = tokbuf_qsize (buf)
in
  if ntok < nqsz
    then tokbuf_qclear (buf, ntok)
    else tokbuf_qclear (buf, nqsz)
  // end of [if]
end // end of [tokbuf_reset]

(* ****** ****** *)

implement
tokbuf_get_token
  (buf) = let
//
val ntok = g0uint2uint_uint_size (buf.ntok)
val nqsz = tokbuf_qsize (buf)
//
in
//
if
ntok < nqsz
then
  $UN.cast{token}(tokbuf_qget (buf, ntok))
else let
  val tok =
    lexing_next_token_ncmnt (buf.lexbuf)
  val () = tokbuf_qins_end (buf, $UN.cast{ptr}(tok))
in
  tok
end // end of [else]
//
end // end of [tokbuf_get_token]

(* ****** ****** *)

implement
tokbuf_getinc_token
  (buf) = tok where
{
  val tok = tokbuf_get_token (buf)
  val ((*void*)) = buf.ntok := buf.ntok + 1u
} (* end of [tokbuf_getinc_token] *)

(* ****** ****** *)

implement
tokbuf_discard_all
  (buf) = let
  val tok = tokbuf_getinc_token (buf)
in
  if token_node_is_T_EOF (tok.token_node())
    then () else tokbuf_discard_all (buf)
end // end of [tokbuf_discard_all]

(* ****** ****** *)

implement
tokbuf_unget_token
  (buf, tok) = tokbuf_qins_beg (buf, $UN.cast{ptr}(tok))
// end of [tokbuf_unget_token]

(* ****** ****** *)

(* end of [pats_tokbuf.dats] *)
