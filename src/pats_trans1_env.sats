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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_env.sats).
// The proofs of the push/pop/save/restore (dummy views in ATS1) are dropped.
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)

staload
FIX = "./pats_fixity.sats"
typedef fxty = $FIX.fxty

(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol

(* ****** ****** *)

staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename

(* ****** ****** *)

staload "./pats_syntax.sats"
staload "./pats_symmap.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

fun the_e1xpenv_add (k: symbol, x: e1xp): void
fun the_e1xpenv_addperv (k: symbol, x: e1xp): void
fun the_e1xpenv_find (k: symbol): Option_vt (e1xp)

(* ****** ******* *)
//
// HX: the dummy proof of ATS1 ([absview e1xpenv_push_v]) is dropped
//
fun the_e1xpenv_pop ((*none*)): symmap (e1xp)
fun the_e1xpenv_push_nil ((*none*)): void

(* ****** ******* *)

fun the_EXTERN_PREFIX_get (): Stropt
fun the_EXTERN_PREFIX_set (prfx: string): void
fun the_EXTERN_PREFIX_set_none (): void

(* ****** ******* *)

fun the_fxtyenv_add (key: symbol, itm: fxty): void
fun the_fxtyenv_find (key: symbol): Option_vt (fxty)

fun the_fxtyenv_pop ((*none*)): symmap (fxty)
fun the_fxtyenv_push_nil ((*none*)): void

fun the_fxtyenv_pervasive_joinwth (map: symmap (fxty)): void

(* ****** ******* *)

fun fprint_the_fxtyenv (out: FILEref): void // mostly for debugging

(* ****** ****** *)

fun the_trans1_env_pop ((*none*)): void
fun the_trans1_env_push ((*none*)): void

(*
** HX: for handling <local ... in ... end>
*)
fun the_trans1_env_localjoin ((*none*)): void

(* ****** ******* *)

fun the_trans1_env_save ((*none*)): void
fun the_trans1_env_restore ((*none*)): void

(* ****** ****** *)

fun
staload_file_search
  (fil: filename): Option_vt(@(int(*ldflg*), d1eclist))
fun
staload_file_insert
  (fil: filename, loadflag: int, d1cs: d1eclist): void

(* ****** ******* *)
//
// HX: an ATSRELOCITM of ATS1 is a (d0ecl, string) or a (d0ecl, string, string)
// (HX-2026-10: the constructors are in [pats_trans1_env.spec] (arenagen))
//
#include "./pats_trans1_env_gen.hats"
//
typedef atsrelocitmlst = glist(atsrelocitm)
//
fun
fprint_atsrelocitm (out: FILEref, x: atsrelocitm): void
fun
fprint_atsrelocitmlst (out: FILEref, xs: atsrelocitmlst): void
//
(* ****** ******* *)
//
fun the_atsrelocitmlst_get (): atsrelocitmlst
//
fun
the_atsreloc_insert
  (d0c: d0ecl, given: string): void
fun
the_atsreloc_insert2
  (d0c: d0ecl, given_s: string, given_t: string): void
//
(* ****** ******* *)

fun the_trans1_env_initialize (): void

(* ****** ******* *)

(* end of [pats_trans1_env.sats] *)
