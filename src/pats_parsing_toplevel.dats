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

(* ****** ****** *)

staload
LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_lexing.sats"
staload "./pats_tokbuf.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_parsing.sats"

staload _(*templates*) = "./pats_syntax.dats"
staload _(*templates*) = "./pats_parsing_util.dats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)
//
// HX: the tokens at which the parser resumes after an error
//
fn
is_toplevel_resume(x: tnode): bool =
(
  token_node_is_T_EOF(x)
//
|| token_node_is_T_STACST(x)
|| token_node_is_T_STADEF(x)
//
|| token_node_is_T_SORTDEF(x)
|| token_node_is_T_DATASORT(x)
//
|| token_node_is_T_ASSUME(x)
|| token_node_is_T_REASSUME(x)
//
|| token_node_is_T_ABSTYPE(x)
|| token_node_is_T_TYPEDEF(x)
|| token_node_is_T_DATATYPE(x)
|| token_node_is_T_EXCEPTION(x)
//
|| token_node_is_T_FUN(x)
|| token_node_is_T_VAL(x)
|| token_node_is_T_VAR(x)
//
|| token_node_is_T_IMPLEMENT(x)
//
|| token_node_is_T_FIXITY(x)
|| token_node_is_T_NONFIX(x)
|| token_node_is_T_SYMINTR(x)
|| token_node_is_T_SYMELIM(x)
//
|| token_node_is_T_LOCAL(x)
//
|| token_node_is_T_STATIC(x)
|| token_node_is_T_EXTERN(x)
//
|| token_node_is_T_SRPERROR(x)
|| token_node_is_T_SRPPRERR(x)
|| token_node_is_T_SRPPRINT(x)
//
|| token_node_is_T_SRPASSERT(x)
//
|| token_node_is_T_SRPUNDEF(x)
|| token_node_is_T_SRPDEFINE(x)
//
|| token_node_is_T_SRPIF(x)
|| token_node_is_T_SRPIFDEF(x)
|| token_node_is_T_SRPIFNDEF(x)
//
|| token_node_is_T_SRPINCLUDE(x)
//
|| token_node_is_T_SRPSTALOAD(x)
|| token_node_is_T_SRPDYNLOAD(x)
//
|| token_node_is_T_SRPREQUIRE(x)
) (* end of [is_toplevel_resume] *)

(* ****** ****** *)

fun
pskip_tokbuf
(
  buf: &tokbuf
) : token = let
//
val tok =
  tokbuf_get_token(buf)
//
in
//
if is_toplevel_resume(tok.token_node())
  then tok
  else let
    val () = tokbuf_incby1 (buf) in pskip_tokbuf (buf)
  end (* end of [_] *)
//
end // end of [pskip_tokbuf]

fun
pskip1_tokbuf_reset
  (buf: &tokbuf): token = let
//
val tok = tokbuf_get_token (buf)
//
val tnode = tok.token_node()
//
val () =
if token_node_is_T_EOF(tnode) then ()
else if tnode_is_comment(tnode) then ()
else let
  val loc = tok.token_loc()
  val err = parerr_make (loc, PE_DISCARD)
in
  the_parerrlst_add (err)
end // end of [if]
//
val () = tokbuf_incby1 (buf)
//
val tok = pskip_tokbuf (buf)
//
val ((*void*)) = tokbuf_reset (buf)
//
in
  tok
end // end of [pskip1_tokbuf_reset]

(* ****** ****** *)

fun
p_toplevel_fun
(
  buf: &tokbuf
, nerr: &int? >> int, f: parser (d0ecl)
) : d0eclist = let
  fun loop (
    buf: &tokbuf
  , nerr: &int >> int, f: parser (d0ecl)
  , res: List0_vt(d0ecl) // HX: in the reverse order
  ) : List0_vt(d0ecl) = let
    val nerr0 = nerr
    val d0ecl = f (buf, 1(*bt*), nerr)
  in
    if nerr > nerr0 then let
        val tok0 = tokbuf_get_token (buf)
//
        val () =
          if token_node_is_T_EOF (tok0.token_node())
            then (nerr := nerr0) else ()
//
        val tok1 = pskip1_tokbuf_reset (buf)
//
      in
        if token_node_is_T_EOF (tok1.token_node())
          then res else loop (buf, nerr, f, res)
      end // end of [nerr > nerr0]
    else let (*noerror*)
//
        val () = tokbuf_reset (buf)
//
        val () = let
          val xs = // HX: for skipping semicolons
            pstar_fun<token>(buf, 1(*bt*), p_SEMICOLON) in list_vt_free (xs)
          // end of [val]
        end // end of [val]
//
      in
        loop (buf, nerr, f, list_vt_cons (d0ecl, res))
      end // end of [_]
   end (* end of [loop] *)
  val () = nerr := 0
  val res = loop (buf, nerr, f, list_vt_nil ())
//
  val _(*EOF*) = p_EOF (buf, 0(*bt*), nerr) // HX: no more tokens
//
in
  l2l(list_vt_reverse(res))
end // end of [p_toplevel_fun]

(* ****** ****** *)

implement
p_toplevel_sta (buf, nerr) = p_toplevel_fun (buf, nerr, p_d0ecl_sta)
implement
p_toplevel_dyn (buf, nerr) = p_toplevel_fun (buf, nerr, p_d0ecl_dyn)

(* ****** ****** *)

(* end of [pats_parsing_toplevel.dats] *)
