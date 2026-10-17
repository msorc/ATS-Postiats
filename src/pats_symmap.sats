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

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol

(* ****** ****** *)

absvtype
symmap_vtype (itm:type) = ptr
stadef symmap = symmap_vtype

(* ****** ****** *)

//
// HX-2026-10: the functions on a symmap are templates, as they are
// implemented by (template) functions of libats/linmap_avltree
//
fun{itm:type} symmap_make_nil ():<> symmap (itm)

fun{itm:type} symmap_free (map: symmap (itm)):<> void

(* ****** ****** *)

fun{itm:type}
symmap_search
  (map: !symmap itm, k: symbol):<> Option_vt (itm)
// end of [symmap_search]

fun{itm:type}
symmap_insert (
  map: &symmap (itm), key: symbol, itm: itm
) :<> void // end of [symmap_insert]

(* ****** ****** *)

fun{itm:type}
symmap_joinwth (m1: &symmap itm, m2: !symmap itm):<> void
// end of [symmap_joinwth]

(* ****** ****** *)

fun{itm:type}
fprint_symmap (
  out: FILEref, map: !symmap itm, f: (FILEref, itm) -> void
) : void // end of [fprint_symmap]

(* ****** ****** *)

(* end of [pats_symmap.sats] *)
