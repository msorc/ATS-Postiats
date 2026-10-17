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
// Start Time: January, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_caseof.dats, see PORTING.md,
// "ccomp group C1 (ccompenv/environ/caseof/looping/trywith/lazyeval)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

// HX-2026-10: in ATS1 this function was [extern] in this file with the name
// [hidexplst_ccompv] (a different function from the one of pats_ccomp_dynexp.dats,
// the C names differ by the file); here the name is made file-specific
//
fun
hidexplst_ccompv_caseof
  (env: !ccompenv, res: !instrseq, hdes: hidexplst): primvalist = let
//
(*
val () =
println! ("hidexplst_ccompv")
*)
//
in
//
case+ glist_view(hdes) of
| ~GLnil
    ((*void*)) => glist_nil()
  // end of [list_nil]
| ~GLcons
    (hde, hdes) => let
    val pmv = hidexp_ccompv(env, res, hde)
    val pmvs = hidexplst_ccompv_caseof(env, res, hdes)
  in
    glist_cons<primval>(pmv, pmvs)
  end // end of [list_cons]    
//
end // end of [hidexplst_ccompv_caseof]

(* ****** ****** *)

implement
hidexp_ccomp_ret_case
  (env, res, tmpret, hde0) = let
//
val loc0 = hde0.hidexp_loc()
//
val-~HDEcase
  (knd, hdes, hicls) = hidexp_node_view(hde0.hidexp_node())
//
// HX: [pmvs] should not contain lvalues
//
val pmvs = hidexplst_ccompv_caseof(env, res, hdes)
//
val fail =
(
case+ knd of
| CK_case_pos() => patckont_PTCKNTnone()
| CK_case_neg() => patckont_PTCKNTcaseof_fail(loc0)
| CK_case((*none*)) => patckont_PTCKNTcaseof_fail(loc0)
) : patckont // end of [val]
//
val lvl0 = the_d2varlev_get((*void*))
//
val ibranchlst =
  hiclaulst_ccomp(env, lvl0, pmvs, hicls, tmpret, fail)
//
val ins =
  instr_caseof(loc0, ibranchlst)
//
val ((*void*)) = instrseq_add (res, ins)
//
in
  // nothing
end // end of [hidexp_ccomp_ret_case]

(* ****** ****** *)

(* end of [pats_ccomp_caseof.dats] *)
