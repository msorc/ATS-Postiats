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
// Start Time: May, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_namespace.sats)
// The closure of [the_namespace_search] is an (env, function) pair (PORTING.md, T1-1).
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)

staload
S2EXP = "./pats_staexp2.sats"
typedef filenv = $S2EXP.filenv

(* ****** ****** *)
//
fun
the_namespace_add (x: filenv): void
//
// HX: [fsearch] is called with [env] and each of the file environments
//
// HX: the two lists that the template [the_namespace_search] reads (internal)
//
fun the_namespace_get_fenvlst (): glist (filenv)
fun the_namespace_get_fenvlstlst (): glist (glist (filenv))
//
fun{a:type}
the_namespace_search
  (env: ptr, fsearch: (ptr, filenv) -> Option_vt(a)): Option_vt(a)
// end of [the_namespace_search]
//
(* ****** ****** *)

fun the_namespace_pop (): void
fun the_namespace_push (): void

fun the_namespace_localjoin (): void

fun the_namespace_save (): void
fun the_namespace_restore (): void

(* ****** ****** *)

(* end of [pats_namespace.sats] *)
