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

staload
SYMMAP = "./pats_symmap.sats"
vtypedef symmap (itm:type) = $SYMMAP.symmap (itm)

(* ****** ****** *)

absvt@ype
symenv_vt0ype (itm:type) // HX: a flat record (see pats_symenv.dats)
stadef symenv = symenv_vt0ype

(* ****** ****** *)

fun{itm:type}
symenv_make_nil
  (
  // nothing
  ) : [l:addr] (symenv(itm) @ l | ptr(l))
// end of [symenv_make_nil]

fun{itm:type}
symenv_free
  {l:addr}
  (pf: symenv(itm) @ l | p: ptr(l)):<> void
// end of [symenv_free]

(* ****** ****** *)

fun{itm:type} symenv_search
   // HX: search all
  (env: &symenv itm, k: symbol):<> Option_vt (itm)
// end of [symenv_search]

fun{itm:type} symenv_insert
   // HX: insert first
  (env: &symenv itm, k: symbol, i: itm):<> void
// end of [symenv_insert]

(* ****** ****** *)

fun{itm:type} symenv_pop
  (env: &symenv itm):<> symmap (itm)
fun{itm:type} symenv_pop_free(env: &symenv itm):<> void

fun{itm:type} symenv_push
  (env: &symenv itm, map: symmap (itm)):<> void
fun{itm:type} symenv_push_nil(env: &symenv itm):<> void

(* ****** ****** *)

fun{itm:type} symenv_top_clear(env: &symenv itm):<> void

(* ****** ****** *)
//
// HX: saving the current env
//
fun{itm:type} symenv_savecur
   (env: &symenv itm):<> void
// end of [symenv_savecur]

//
// HX: restoring the last saved env
//
fun{itm:type} symenv_restore
   (env: &symenv itm):<> symmap (itm)
// end of [symenv_restore]

(* ****** ****** *)
//
// HX: handling: local ... in ... end
//
fun{itm:type} symenv_localjoin
   (env: &symenv itm):<> void
// end of [symenv_localjoin]
//
(* ****** ****** *)

fun{itm:type}
symenv_pervasive_search
 (env: &symenv itm, k: symbol):<> Option_vt (itm)
// end of [symenv_pervasive_search]

fun{itm:type}
symenv_pervasive_insert
  (env: &symenv itm, k: symbol, i: itm):<> void
// end of [symenv_pervasive_insert]

(* ****** ****** *)

fun{itm:type}
symenv_pervasive_joinwth0
  (env: &symenv itm, map:  symmap itm):<> void
// end of [symenv_pervasive_joinwth0]
fun{itm:type}
symenv_pervasive_joinwth1
  (env: &symenv itm, map: !symmap itm):<> void
// end of [symenv_pervasive_joinwth1]

(* ****** ****** *)

fun{itm:type}
fprint_symenv_map
  (
  out: FILEref, env: &symenv itm, f: (FILEref, itm) -> void
) : void // end of [fprint_symenv_map]

(* ****** ****** *)

(* end of [pats_symenv.sats] *)
