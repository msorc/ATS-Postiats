(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2016 Hongwei Xi, ATS Trustful Software, Inc.
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

(* Author: Hongwei Xi *)
(* Authoremail: gmhwxiATgmailDOTcom *)
(* Start time: January, 2016 *)

(* ****** ****** *)
//
#include
"share\
/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = $UNSAFE

(* ****** ****** *)
//
staload
"./../SATS/atexting.sats"
//
#staload "libats/SATS/arena.sats" // HX-2026-10
#staload _ = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
implement
token_get_loc
  (tok) = tok.token_loc()
//
(* ****** ****** *)
//
implement
token_make
  (loc, node) =
token_TOKEN(loc, node) (* token_make *)
//
(* ****** ****** *)

implement
token_is_eof(tok) =
(
//
case+
token_node_view(tok.token_node()) of
| ~TOKeof() => true
| v0(*non-eof*) => (token_node_view_free(v0); false)
//
) (* end of [token_is_eof] *)

(* ****** ****** *)

implement
token_is_nsharp
  (tok) = (
//
case+
token_node_view(tok.token_node()) of
| ~TOKsharp(ns) =>
  length(ns) >= the_nsharp_get((*void*))
| v0 (*non-code-beg*) => (token_node_view_free(v0); false)
//
) (* end of [token_is_nsharp] *)

(* ****** ****** *)

implement
token_is_code_beg
  (tok) = (
//
case+
token_node_view(tok.token_node()) of
| ~TOKcode_beg _ =>
  location_is_atlnbeg(tok.token_loc())
| v0 (*non-code-beg*) => (token_node_view_free(v0); false)
//
) (* end of [token_is_code_beg] *)

implement
token_is_code_end(tok) =
(
//
case+
token_node_view(tok.token_node()) of
| ~TOKcode_end _ =>
  location_is_atlnbeg(tok.token_loc())
| v0 (*non-code-end*) => (token_node_view_free(v0); false)
//
) (* end of [token_is_code_end] *)

(* ****** ****** *)
//
implement
token_is_atlnbeg(tok) =
  location_is_atlnbeg(tok.token_loc())
//
(* ****** ****** *)
//
extern
fun{}
fprint_token_node_
  : (FILEref, tnode) -> void
//
(* ****** ****** *)

#ifdef
CODEGEN2
#then
#codegen2
( "fprint"
, token_node, fprint_token_node_
)
#else
//
#include
"./atexting_fprint_token.hats"
//
implement
fprint_val<token> = fprint_token
//
implement{}
fprint_token_node_$TOKspchr$arg1(out, arg0) =
  let val-~TOKspchr(arg1) = token_node_view(arg0) in fprint(out, int2char0(arg1)) end
implement{}
fprint_token_node_$TOKbslash$arg1(out, arg0) =
  let val-~TOKbslash(arg1) = token_node_view(arg0) in fprint(out, int2char0(arg1)) end
//
implement
fprint_token(out, x0) =
  fprint_token_node_<>(out, x0.token_node())
//
implement
fprint_tnode
  (out, node) = fprint_token_node_<>(out, node)
//
implement
fprint_tokenlst
  (out, xs) =
  fprint_glist_sep<token>(out, xs, ", ")
//
#endif // #ifdef

(* ****** ****** *)

(* end of [atexting_token.dats] *)
