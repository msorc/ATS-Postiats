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
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_funent.dats, see PORTING.md, "ccomp core modules")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"
staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
funent_make
(
  loc, flab
, imparg, tmparg, tmpsub
, tmpret, fls0, d2es, vbmap, inss, tmplst
) = funent_new
(
  loc, flab
, imparg, tmparg, tmpsub
, tmpret
, fls0, gopt_none((*void*)) // flablst, flablst_fin
, d2es, gopt_none((*void*)) // d2envlst, d2envlst_fin
, vbmap, inss, tmplst
, glist_nil((*void*)) // fnxlablst
) (* end of [funent_make] *)

(* ****** ****** *)

implement
funent_get_loc (fent) = funent_loc (fent)

implement
funent_get_lab (fent) = funent_lab (fent)

implement
funent_get_level
  (fent) = funlab_get_level (funent_lab (fent))
// end of [funent_get_level]

implement
funent_get_imparg (fent) = funent_imparg (fent)

implement
funent_get_tmparg (fent) = funent_tmparg (fent)

implement
funent_get_tmpsub (fent) = funent_tmpsub (fent)

implement
funent_get_tmpret (fent) = funent_tmpret (fent)

implement
funent_get_flablst (fent) = funent_flablst (fent)
implement
funent_get_flablst_fin (fent) = funent_flablst_fin (fent)

implement
funent_get_d2envlst (fent) = funent_d2envlst (fent)
implement
funent_get_d2envlst_fin (fent) = funent_d2envlst_fin (fent)

implement
funent_get_vbindmap (fent) = funent_vbindmap (fent)

implement
funent_get_instrlst (fent) = funent_instrlst (fent)

implement
funent_get_tmpvarlst (fent) = funent_tmpvarlst (fent)

(* ****** ****** *)

implement
funent_get_fnxlablst (fent) = funent_fnxlablst (fent)

(* ****** ****** *)
//
// HX-2026-10: the C functions patsopt_funent_set_* of src/ (declared in the sats)
//
implement
funent_set_tmpsub (fent, opt) = set_funent_tmpsub (fent, opt)
implement
funent_set_flablst_fin (fent, opt) = set_funent_flablst_fin (fent, opt)
implement
funent_set_d2envlst_fin (fent, opt) = set_funent_d2envlst_fin (fent, opt)
implement
funent_set_fnxlablst (fent, fls) = set_funent_fnxlablst (fent, fls)
//
(* ****** ****** *)

implement
funent_make2
(
  loc, flab
, imparg, tmparg
, tmpret, fls0, d2es, vbmap, inss
) = let
  val tmps = instrlst_get_tmpvarset (inss)
  val tmps = tmpvarset_vt_add (tmps, tmpret)
  val tmplst = tmpvarset_vt_listize_free (tmps)
  val tmplst = glist_make_list_vt (tmplst)
in
//
funent_make
(
  loc, flab
, imparg, tmparg, gopt_none((*tsub*)), tmpret, fls0, d2es, vbmap, inss, tmplst
) // end of [funent_make]
//
end // end of [funent_make2]

(* ****** ****** *)

implement
fprint_funent
  (out, fent) = let
//
macdef prstr (s) = fprint_string (out, ,(s))
//
val flab = funent_get_lab (fent)
//
val imparg = funent_get_imparg (fent)
val tmparg = funent_get_tmparg (fent)
val tsubopt = funent_get_tmpsub (fent)
//
val tmpret = funent_get_tmpret (fent)
//
val inss = funent_get_instrlst (fent)
//
val () = prstr "FUNENT(\n"
//
val () = prstr "lab="
val () = fprint_funlab (out, flab)
val () = prstr "\n"
//
val () = prstr "imparg="
val () = fprint_s2varlst (out, imparg)
val () = prstr "\n"
//
val () = prstr "tmparg="
val () = $UT.fprintlst<s2explst> (out, tmparg, "; ", fprint_s2explst)
val () = prstr "\n"
//
val () = prstr "tmpsub="
val () = fprint_tmpsubopt (out, tsubopt)
val () = prstr "\n"
//
val () = prstr "tmpret="
val () = fprint_tmpvar (out, tmpret)
val () = prstr "\n"
//
val () = prstr "instrlst=\n"
val () = fprint_instrlst (out, inss)
//
val () = prstr ")"
in
  // nothing
end // end of [fprint_funent]

(* ****** ****** *)

implement
funent_is_tmplt (fent) = let
  val tmparg = funent_get_tmparg (fent)
in
  glist_is_cons (tmparg)
end // end of [funent_is_tmplst]

(* ****** ****** *)

implement
print_funent (fent) = fprint_funent (stdout_ref, fent)
implement
prerr_funent (fent) = fprint_funent (stderr_ref, fent)

(* ****** ****** *)

(* end of [pats_ccomp_funent.dats] *)
