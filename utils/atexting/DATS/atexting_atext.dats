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
atext_make
(
  loc, node
) = atext_ATEXT(loc, node) (* $rec *)
//
(* ****** ****** *)
//
implement
atext_make_nil
(
  loc
) = atext_make(loc, atext_node_TEXTnil())
//
(* ****** ****** *)
//
implement
atext_make_token
  (tok) = let
  val loc = tok.token_loc()
in
  atext_make(loc, atext_node_TEXTtoken(tok))
end // end of [atext_make_token]
//
(* ****** ****** *)
//
implement
atext_make_list
  (loc, txts) =
  atext_make(loc, atext_node_TEXTlist(txts))
//
(* ****** ****** *)
//
implement
atext_make_string
  (loc, str) =
  atext_make(loc, atext_node_TEXTstring(str))
//
implement
atext_make_errmsg
  (loc, msg) =
  atext_make(loc, atext_node_TEXTerrmsg(msg))
//
(* ****** ****** *)
//
implement
atext_make_squote
  (loc, txts) =
  atext_make(loc, atext_node_TEXTsquote(txts))
implement
atext_make_dquote
  (loc, tok, txts) =
  atext_make(loc, atext_node_TEXTdquote(tok, txts))
//
(* ****** ****** *)
//
implement
atext_tuple_2
  (loc, x0, x1) =
  atext_make
  (loc, atext_node_TEXTlist(glist_cons<atext>(x0, glist_cons<atext>(x1, glist_nil()))))
implement
atext_tuple_3
  (loc, x0, x1, x2) =
  atext_make
  (loc, atext_node_TEXTlist(glist_cons<atext>(x0, glist_cons<atext>(x1, glist_cons<atext>(x2, glist_nil())))))
//
implement
atext_tuple_4
  (loc, x0, x1, x2, x3) =
  atext_make
  (loc, atext_node_TEXTlist(glist_cons<atext>(x0, glist_cons<atext>(x1, glist_cons<atext>(x2, glist_cons<atext>(x3, glist_nil()))))))
//
implement
atext_tuple_5
  (loc, x0, x1, x2, x3, x4) =
(
  atext_make
  ( loc
  , atext_node_TEXTlist(glist_cons<atext>(x0, glist_cons<atext>(x1, glist_cons<atext>(x2, glist_cons<atext>(x3, glist_cons<atext>(x4, glist_nil())))))))
)
//
implement
atext_tuple_6
  (loc, x0, x1, x2, x3, x4, x5) =
(
  atext_make
  ( loc
  , atext_node_TEXTlist(glist_cons<atext>(x0, glist_cons<atext>(x1, glist_cons<atext>(x2, glist_cons<atext>(x3, glist_cons<atext>(x4, glist_cons<atext>(x5, glist_nil()))))))))
)
//
(* ****** ****** *)
//
extern
fun{}
fprint_atext_node_
  : (FILEref, atext_node) -> void
//
(* ****** ****** *)

#ifdef
CODEGEN2
#then
#codegen2
( "fprint"
, atext_node, fprint_atext_node_
)
#else
//
#include
"./atexting_fprint_atext.hats"
//
implement
fprint_val<token> = fprint_token
implement
fprint_val<atext> = fprint_atext
implement
fprint_val<atextlst> = fprint_atextlst
//
implement
fprint_atext(out, x0) =
  fprint_atext_node_<>(out, x0.atext_node())
//
implement
fprint_atextlst
  (out, xs) =
  fprint_glist_sep<atext>(out, xs, ", ")
//
#endif // #ifdef

(* ****** ****** *)

(* end of [atexting_atext.dats] *)
