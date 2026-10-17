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
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_tmpvar.dats, see PORTING.md, "ccomp core modules")
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

staload
STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload HSE = "./pats_histaexp.sats"
staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
tmpvar_make
  (loc, hse) = let
  val stamp = $STMP.tmpvar_stamp_make ()
in
  tmpvar_new
  (
    loc, hse
  , 0 (*value*), 0 (*noret*), 0 (*local*)
  , gopt_none((*void*)), 0 // HX: copy indication
  , stamp
  ) (* tmpvar_new *)
end // end of [tmpvar_make]

(* ****** ****** *)
//
implement
tmpvar_get_loc(tmp) = tmpvar_loc(tmp)
//
implement
tmpvar_get_type(tmp) = tmpvar_type(tmp)
//
implement
tmpvar_isref(tmp) = tmpvar_ref(tmp) > 0
implement
tmpvar_isret(tmp) = tmpvar_ret(tmp) > 0
//
implement
tmpvar_get_topknd(tmp) = tmpvar_topknd(tmp)
//
implement
tmpvar_get_origin(tmp) = tmpvar_origin(tmp)
// end of [tmpvar_get_origin]
//
implement
tmpvar_get_stamp (tmp) = tmpvar_stamp(tmp)
implement
tmpvar_get_suffix(tmp) = tmpvar_suffix(tmp)
//
(* ****** ****** *)
//
implement
tmpvar_get_tailcal (tmp) = tmpvar_ret(tmp)
//
(* ****** ****** *)
//
implement
eq_tmpvar_tmpvar (tmp1, tmp2) = $effmask_all
  ($STMP.eq_stamp_stamp (tmpvar_stamp(tmp1), tmpvar_stamp(tmp2)))
// end of [eq_tmpvar_tmpvar]
//
implement
compare_tmpvar_tmpvar (tmp1, tmp2) = $effmask_all
(
let
  val sgn = $STMP.compare_stamp_stamp (tmpvar_stamp(tmp1), tmpvar_stamp(tmp2))
in
  $UN.cast{int}(sgn)
end
) // end of [compare_tmpvar_tmpvar]
//
(* ****** ****** *)
//
implement
print_tmpvar
  (tmp) = fprint_tmpvar (stdout_ref, tmp)
implement
prerr_tmpvar
  (tmp) = fprint_tmpvar (stderr_ref, tmp)
//
implement
fprint_tmpvar
  (out, tmp) = let
  val isref = tmpvar_isref (tmp)
  val isret = tmpvar_isret (tmp)
  val stamp = tmpvar_get_stamp (tmp)
  val () = fprint_string (out, "tmp")
  val () = if isref then fprint_string (out, "ref")
  val () = if isret then fprint_string (out, "ret")
  val () = fprint_string (out, "(")
  val () = $STMP.fprint_stamp (out, stamp)
  val () = fprint_string (out, ")")
in
  // nothing
end // end of [fprint_tmpvar]
//
implement
fprint_tmpvaropt
  (out, opt) = $UT.fprintopt<tmpvar> (out, opt, fprint_tmpvar)
//
(* ****** ****** *)
//
// HX-2026-10: the C functions patsopt_tmpvar_set_* of src/ (declared in the sats)
//
implement tmpvar_set_type (tmp, hse) = set_tmpvar_type (tmp, hse)
implement tmpvar_set_ref (tmp, knd) = set_tmpvar_ref (tmp, knd)
implement tmpvar_set_ret (tmp, ret) = set_tmpvar_ret (tmp, ret)
implement tmpvar_set_topknd (tmp, knd) = set_tmpvar_topknd (tmp, knd)
implement tmpvar_set_origin (tmp, opt) = set_tmpvar_origin (tmp, opt)
implement tmpvar_set_suffix (tmp, sfx) = set_tmpvar_suffix (tmp, sfx)
//
(* ****** ****** *)

implement
tmpvar_make_ref
  (loc, hse) = tmp where {
  val tmp = tmpvar_make (loc, hse)
  val () = tmpvar_set_ref (tmp, 1(*ref*))
} // end of [tmpvar_make_ref]

implement
tmpvar_make_ret
  (loc, hse) = tmp where {
  val tmp = tmpvar_make (loc, hse)
  val () = tmpvar_set_ret (tmp, 1(*ret*))
} // end of [tmpvar_make_ret]

implement
tmpvar_inc_tailcal
  (tmp) = ((*void*)) where {
  val n = tmpvar_get_tailcal (tmp)
  val () = tmpvar_set_ret (tmp, n+1(*ret*))
} // end of [tmpvar_inc_tailcal]

(* ****** ****** *)

implement
tmpvar_copy_err (tmp) = tmp

(* ****** ****** *)

local

(* ****** ****** *)

staload LS = "libats/SATS/linset_avltree.sats"
staload _(*anon*) = "libats/DATS/linset_avltree.dats"
assume tmpvarset_vtype = $LS.set (tmpvar)

staload LM = "libats/SATS/linmap_avltree.sats"
staload _(*anon*) = "libats/DATS/linmap_avltree.dats"
assume tmpvarmap_vtype (a:type) = $LM.map (tmpvar, a)

(* ****** ****** *)

implement
$LS.compare_elt_elt<tmpvar> (tmp1, tmp2) = compare_tmpvar_tmpvar (tmp1, tmp2)
implement
$LM.compare_key_key<tmpvar> (tmp1, tmp2) = compare_tmpvar_tmpvar (tmp1, tmp2)

in (* in of [local] *)

implement
tmpvarset_vt_nil () = $effmask_all ($LS.linset_make_nil ())

implement
tmpvarset_vt_free (xs) = $effmask_all ($LS.linset_free (xs))

implement
tmpvarset_vt_add
  (xs, x) = xs where {
  var xs = xs
  val _(*replaced*) = $effmask_wrt ($LS.linset_insert (xs, x))
} // end of [tmpvarset_vt_add]

implement
tmpvarset_vt_listize (xs) = $effmask_all ($LS.linset_listize ($LS.linset_copy (xs)))
implement
tmpvarset_vt_listize_free (xs) = $effmask_all ($LS.linset_listize (xs))

(* ****** ****** *)

implement{a}
tmpvarmap_vt_nil () = $effmask_all ($LM.linmap_make_nil ())

implement{a}
tmpvarmap_vt_free (map) = $effmask_all ($LM.linmap_free (map))

implement{a}
tmpvarmap_vt_search
  (map, tmp) = $LM.linmap_search_opt (map, tmp)
// end of [tmpvarmap_vt_search]

implement{a}
tmpvarmap_vt_insert
  (map, tmp, x) = let
  var res: a? // uninitialized
  val ans = $LM.linmap_insert (map, tmp, x, res)
  prval () = opt_clear (res)
in
  ans
end // end of [tmpvarmap_vt_insert]

implement{a}
tmpvarmap_vt_remove
  (map, tmp) = $LM.linmap_remove (map, tmp)

end // end of [local]

(* ****** ****** *)

implement
tmpvar_set_tyclo
  (tmp, flab) = () where
{
val hse = hisexp_tyclo ($UN.cast{$HSE.funlab}(flab))
val () = tmpvar_set_type (tmp, hse)
} (* end of [tmpvar_set_tyclo] *)

(* ****** ****** *)

(* end of [pats_ccomp_tmpvar.dats] *)
