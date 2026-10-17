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
// Start Time: October, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_instrseq.dats, see PORTING.md, "ccomp core modules")
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

staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)
//
// HX-2026-10: the queue of ATS1 ([linqueue_lst]) is a reversed linear list:
// [instrseq_add] conses, [instrseq_get_free] reverses (insertion order kept)
//
datavtype
instrseq = INSTRSEQ of (List0_vt(instr))
assume instrseq_vtype = instrseq

(* ****** ****** *)

implement
instrseq_make_nil () = INSTRSEQ (list_vt_nil ())

(* ****** ****** *)

implement
instrseq_add
  (res, x) = let
in
//
case+ res of
| @INSTRSEQ (xs) => let
    val () = xs := list_vt_cons (x, xs) in fold@ (res)
  end // end of [INSTRSEQ]
//
end // end of [instrseq_add]

(* ****** ****** *)

implement
instrseq_add_comment
  (res, comment) = let
//
val loc = $LOC.location_dummy
//
in
  instrseq_add (res, instr_comment (loc, comment))
end // end of [instrseq_add_comment]

(* ****** ****** *)

implement
instrseq_add_tmpdec
  (res, loc, tmp) =
  instrseq_add (res, instr_tmpdec (loc, tmp))
// end of [instrseq_add_tmpdec]

(* ****** ****** *)

implement
instrseq_add_extvar
  (res, loc, xnm, pmv) =
  instrseq_add (res, instr_extvar (loc, xnm, pmv))
// end of [instrseq_add_extvar]

(* ****** ****** *)

implement
instrseq_add_dcstdef
  (res, loc, d2c, pmv) =
  instrseq_add (res, instr_dcstdef (loc, d2c, pmv))
// end of [instrseq_add_dcstdef]

(* ****** ****** *)

implement
instrseq_addlst
  (res, xs) = let
in
//
if glist_is_cons (xs) then let
  val () = instrseq_add (res, glist_head (xs)) in instrseq_addlst (res, glist_tail (xs))
end else ()
//
end // end of [instrseq_addlst]

(* ****** ****** *)

implement
instrseq_addlst_vt
  (res, xs) = let
in
//
case+ xs of
| ~list_vt_cons
    (x, xs) => let
    val () = instrseq_add (res, x) in instrseq_addlst_vt (res, xs)
  end // end of [list_cons]
| ~list_vt_nil () => ()
//
end // end of [instrseq_addlst_vt]

(* ****** ****** *)

local

fun auxlst
(
  res: !instrseq
, loc0: loc_t, pmvs: primvalist_vt
) : void = let
//
in
//
case+ pmvs of
| ~list_vt_cons
    (pmv, pmvs) => let
    val ins =
      instr_freecon (loc0, pmv)
    val () = instrseq_add (res, ins)
  in
    auxlst (res, loc0, pmvs)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
//
end // end of [auxlist]

in (* in of [local] *)

implement
instrseq_add_freeconlst
  (res, loc0, pmvs) = auxlst (res, loc0, pmvs)
// end of [instrseq_add_freeconlst]

end // end of [local]

(* ****** ****** *)

implement
instrseq_get_free
  (res) = let
  val ~INSTRSEQ (xs) = res
in
  glist_make_list_vt (list_vt_reverse (xs))
end // end of [instrseq_get_free]

(* ****** ****** *)

(* end of [pats_ccomp_instrseq.dats] *)
