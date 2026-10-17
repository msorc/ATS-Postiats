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
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_claulst.dats, see PORTING.md, "ccomp group C2")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"

(* ****** ****** *)

staload INTINF = "./pats_intinf.sats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
  ((*void*)) = prerr "pats_ccomp_claulst"
//
(* ****** ****** *)
//
staload
LAB = "./pats_label.sats"
staload
LOC = "./pats_location.sats"
typedef location = $LOC.location
//
staload SYN = "./pats_syntax.sats"
//
overload compare with $LAB.compare_label_label
//
(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload
P2TC = "./pats_patcst2.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)
//
// [matoken], [patcomp], [patckontref] (see [pats_ccomp_claulst.spec])
//
staload "./pats_ccomp_claulst.sats"

(* ****** ****** *)

#include "./pats_typerase.hats"
#include "./pats_ccomp_c2.hats"

macdef l2l (xs) = glist_make_list_vt (,(xs))

(* ****** ****** *)

#include "./pats_ccomp_claulst_gen_dats.hats"

(* ****** ****** *)

(*
extern
fun
tmprimval_make_none
  (pmv: primval): tmprimval
extern
fun
tmprimval_make_some
  (pmv: primval): tmprimval
//
implement
tmprimval_make_none
  (pmv) = TPMVnone (pmv)
implement
tmprimval_make_some
  (pmv) = let
  val loc = pmv.primval_loc
  val hse = pmv.primval_type
  val tmp = tmpvar_make (loc, hse)
in
  TPMVsome (tmp, pmv)
end // end of [tmprimval_make_some]
*)

(* ****** ****** *)
//
extern
fun
tmprimval2pmv
  (tpmv: tmprimval): primval
extern
fun
tmprimval2pmv2
  (tpmv: tmprimval, d2v: d2var): primval
//
(* ****** ****** *)

implement
tmprimval2pmv
  (tpmv) = let
(*
val () = println! ("tmprimval2pmv")
*)
in
//
case+ tmprimval_view (tpmv) of
| ~TPMVnone (pmv) => pmv
| ~TPMVsome (tmp, _) => let
    val loc = tmpvar_get_loc (tmp) in primval_make_tmp (loc, tmp)
  end // end of [TPMVsome]
//
end // end of [tmprimval2pmv]

(* ****** ****** *)

implement
tmprimval2pmv2
  (tpmv, d2v) = let
//
fun ptrof (pmv: primval): primval =
  primval_ptrof (pmv.primval_loc(), hisexp_typtr, pmv)
//
val ismut = d2var_is_mutabl (d2v)
//
in
//
case+ tmprimval_view (tpmv) of
| ~TPMVnone (pmv) =>
    if ismut then ptrof (pmv) else pmv
| ~TPMVsome (tmp, pmv) =>
  (
    if ismut then ptrof (pmv) else let
      val loc =
        tmpvar_get_loc (tmp) in primval_make_tmp (loc, tmp)
      // end of [val]
    end // end of [if]
  ) // end of [TPMVsome]
//
end // end of [tmprimval2pmv2]

(* ****** ****** *)

implement
fprint_tmprimval
  (out, x) = let
//
macdef
prstr(str) =
fprint_string (out, ,(str))
//
in
//
case+ tmprimval_view (x) of
| ~TPMVnone (pmv) =>
  {
    val () = prstr "TPMVnone("
    val () = fprint_primval (out, pmv)
    val () = prstr ")"
  }
| ~TPMVsome (tmp, pmv) =>
  {
    val () = prstr "TPMVsome("
    val () = fprint_tmpvar (out, tmp)
    val () = prstr "<-"
    val () = fprint_primval (out, pmv)
    val () = prstr ")"
  }
//
end // end of [fprint_tmprimval]

(* ****** ****** *)

extern
fun
tmpmovlst_add
(
  tmvlst: &tmpmovlst_vt >> _
, tpmv1: tmprimval, tpmv2: tmprimval
) : void // end of [tmpmovlst_add]

(* ****** ****** *)

implement
tmpmovlst_add
  (tmvlst, tpmv1, tpmv2) = let
//
(*
val
out = stdout_ref
//
val () =
fprintln! (out, "tmpmovlst_add: tpmv1 = ", tpmv1)
val () =
fprintln! (out, "tmpmovlst_add: tpmv2 = ", tpmv2)
*)
//
in
//
case+ tmprimval_view (tpmv2) of
| ~TPMVnone _ => ()
| ~TPMVsome (tmp2, _) =>
  (
    tmvlst := list_vt_cons (tmpmov_new (tpmv1, tmp2), tmvlst)
  ) (* end of [TPMVsome] *)
end // end of [tmpmovlst_add]

(* ****** ****** *)

(*
extern
fun
fprint_matoken (out: FILEref, x: matoken): void
extern
fun
fprint_matokenlst (out: FILEref, xs: matokenlst): void
*)

(* ****** ****** *)
//
extern
fun
patckontref_make
  ((*void*)): patckontref
implement
patckontref_make
  ((*void*)) = patckontref_new (patckont_PTCKNTnone ())
//
extern
fun
patckontref_make_loc
  (loc: location): patckontref
implement
patckontref_make_loc
  (loc) = patckontref_new (patckont_PTCKNTcaseof_fail (loc))
//
(* ****** ****** *)

vtypedef
patcomplst_vt = List0_vt (patcomp)

(* ****** ****** *)
//
extern
fun
fprint_patcomp
  (out: FILEref, x: patcomp): void
//
overload fprint with fprint_patcomp
//
(* ****** ****** *)

implement
fprint_patcomp
  (out, x0) = let
//
macdef
prstr (s) = fprint_string (out, ,(s))
//
in
//
case+ patcomp_view (x0) of
//
| ~PTCMPany (d2v) =>
  {
    val () = prstr "PTCMPany("
    val () = fprint_d2var (out, d2v)
    val () = prstr ")"
  }
| ~PTCMPvar (d2v, tpmv) =>
  {
    val () = prstr "PTCMPvar("
    val () = fprint_d2var (out, d2v)
    val () = prstr ", "
    val () = fprint_tmprimval (out, tpmv)
    val () = prstr ")"
  }
//
| ~PTCMPasvar (d2v, tpmv) =>
  {
    val () = prstr "PTCMPasvar("
    val () = fprint_d2var (out, d2v)
    val () = prstr ", "
    val () = fprint_tmprimval (out, tpmv)
    val () = prstr ")"
  }
//
| ~PTCMPlablparen (lab) =>
  {
    val () = prstr "PTCMPlablparen("
    val () = $LAB.fprint_label (out, lab)
    val () = prstr ")"
  }
//
| ~PTCMPpatlparen
    (ptck, tpmv, tlab, opt, kntr) =>
  {
    val () = prstr "PTCMPpatlparen("
    val () = fprint_patck (out, ptck)
    val () = prstr ", "
    val () = fprint_pckindopt (out, opt)
    val () = prstr ", "
    val () = fprint_tmprimval (out, tpmv)
    val () = prstr ", "
    val () = fprint_tmplab (out, tlab)
    val () = prstr ", "
    val () = fprint_patckont (out, patckontref_val (kntr))
    val () = prstr ")"
  }
//
| ~PTCMPreclparen
    (tpmv, tlab) =>
  {
    val () = prstr "PTCMPreclparen("
    val () = fprint_tmprimval (out, tpmv)
    val () = prstr ", "
    val () = fprint_tmplab (out, tlab)
    val () = prstr ")"
  }
//
| ~PTCMPrparen () =>
  {
    val () = prstr "PTCMPrparen()"
  }
//
| ~PTCMPpatneg (ptck, tpmv) =>
  {
    val () = prstr "PTCMPpatckneg("
    val () = fprint_patck (out, ptck)
    val () = prstr ", "
    val () = fprint_tmprimval (out, tpmv)
    val () = prstr ")"
  }
//
| ~PTCMPtmplabend (tlab) =>
  {
    val () = prstr "PTCMPtmplabend("
    val () = fprint_tmplab (out, tlab)
    val () = prstr ")"
  }
| ~PTCMPtmplabgua (tlab, kntr) =>
  {
    val () = prstr "PTCMPtmplabgua("
    val () = fprint_tmplab (out, tlab)
    val () = prstr ", "
    val () = fprint_patckont (out, patckontref_val (kntr))
    val () = prstr ")"
  }
//
end // end of [fprint_patcomp]

(* ****** ****** *)
//
extern
fun
fprint_patcomplst
  (out: FILEref, xs: patcomplst): void
extern
fun
fprint_patcomplstlst
  (out: FILEref, xs: patcomplstlst): void
//
overload fprint with fprint_patcomplst
overload fprint with fprint_patcomplstlst
//
(* ****** ****** *)

implement
fprint_patcomplst
  (out, xs) = let
//
// HX: [$UT.fprintlst (out, xs, "; ", fprint_patcomp)]
//
fun
loop
(
  xs: patcomplst, i: int
) : void =
  if glist_is_cons (xs) then let
    val () = if i > 0 then fprint_string (out, "; ")
    val () = fprint_patcomp (out, glist_head<patcomp> (xs))
  in
    loop (glist_tail<patcomp> (xs), i+1)
  end else ((*void*))
//
in
  loop (xs, 0)
end // end of [fprint_patcomplst]

implement
fprint_patcomplstlst
  (out, xss) = let
//
// HX: [$UT.fprintlst (out, xss, "\n", fprint_patcomplst)]
//
fun
loop
(
  xss: patcomplstlst, i: int
) : void =
  if glist_is_cons (xss) then let
    val () = if i > 0 then fprint_string (out, "\n")
    val () = fprint_patcomplst (out, glist_head<patcomplst> (xss))
  in
    loop (glist_tail<patcomplst> (xss), i+1)
  end else ((*void*))
//
in
  loop (xss, 0)
end // end of [fprint_patcomplstlst]

(* ****** ****** *)

extern
fun
patcomplst_find_tmplab
  (xs: patcomplst): Option_vt (tmplab)
// end of [patcomplst_find_tmplab]

(* ****** ****** *)

implement
patcomplst_find_tmplab
  (xs) = let
(*
val () =
fprintln!
(
  stdout_ref
, "patcomplst_find_tmplab: xs = ", xs
) (* end of [val] *)
*)
in
//
if glist_is_cons (xs) then let
  val x = glist_head<patcomp> (xs)
  val xs = glist_tail<patcomp> (xs)
in
  case+ patcomp_view (x) of
  | ~PTCMPpatlparen
      (_, _, tl, _, _) => Some_vt (tl)
    // end of [PTCMPpatlparen]
  | ~PTCMPreclparen (_, tl) => Some_vt (tl)
  | ~PTCMPtmplabend (tl) => Some_vt (tl)
  | ~PTCMPtmplabgua (tl, _) => Some_vt (tl)
  | v (*rest-patscomp*) => let
      val () = patcomp_view_free (v) in patcomplst_find_tmplab (xs)
    end // end of [rest-patcomp]
end else None_vt ()
//
end // end of [patcomplst_find_tmplab]

(* ****** ****** *)
//
extern
fun
patcomplst_find_guafail
  (xs: patcomplst): patckont
//
implement
patcomplst_find_guafail
  (xs) = let
//
(*
val
out = stdout_ref
val () =
fprintln!
( out,
  "patcomplst_find_guafail: xs = ", xs
) (* end of [val] *)
*)
//
in
//
if glist_is_cons (xs) then let
  val x = glist_head<patcomp> (xs)
  val xs = glist_tail<patcomp> (xs)
(*
    val () = fprintln!(out, "x = ", x)
*)
in
  case+ patcomp_view (x) of
  | ~PTCMPtmplabgua (_, kntr) => patckontref_val (kntr)
  | v (*non-PTCMPtmplabgua*) => let
      val () = patcomp_view_free (v) in patcomplst_find_guafail (xs)
    end // end of [non-PTCMPtmplabgua]
end else patckont_PTCKNTnone (*void*) ()
//
end // end of [patcomplst_find_guafail]
//
(* ****** ****** *)
//
extern
fun
patcomplst_unskip
  (xs: patcomplst, na: &int): patcomplst
extern
fun
patcomplst_unrparen
  (xs: patcomplst, na: &int): patcomplst
//
(* ****** ****** *)

implement
patcomplst_unskip (xs, na) = let
//
fun auxlst
(
  xs: patcomplst, na: &int
) : patcomplst = let
in
//
if glist_is_cons (xs) then let
  val x = glist_head<patcomp> (xs)
  val xs = glist_tail<patcomp> (xs)
in
  case+ patcomp_view (x) of
//
  | ~PTCMPany _ => xs
  | ~PTCMPvar _ => xs
  | ~PTCMPasvar _ => auxlst (xs, na)
//
  | ~PTCMPlablparen _ => auxlst2 (1(*plvl*), xs, na)
//
  | ~PTCMPpatlparen _ => let
      val () = na := na + 1 in auxlst2 (1(*plvl*), xs, na)
    end // end of [PTCMPconlparen]
//
  | ~PTCMPreclparen _ => let
      val () = na := na + 1 in auxlst2 (1(*plvl*), xs, na)
    end // end of [reclparen]
//
  | ~PTCMPrparen _ => let val () = assertloc (false) in xs end
//
  | v (*rest-of-patcomp*) => let
      val () = patcomp_view_free (v) in xs
    end // end of [rest-of-patcomp]
//
end else glist_nil ((*void*))
//
end // end of [auxlst]
//
and auxlst2
(
  plvl: int
, xs: patcomplst, na: &int
) : patcomplst = let
in
//
if glist_is_cons (xs) then let
  val x = glist_head<patcomp> (xs)
  val xs = glist_tail<patcomp> (xs)
in
  case+ patcomp_view (x) of
//
  | ~PTCMPany _ => auxlst2 (plvl, xs, na)
  | ~PTCMPvar _ => auxlst2 (plvl, xs, na)
  | ~PTCMPasvar _ => auxlst2 (plvl, xs, na)
//
  | ~PTCMPlablparen _ => auxlst2 (plvl+1, xs, na)
//
  | ~PTCMPpatlparen _ => let
      val () = na := na + 1 in auxlst2 (plvl+1, xs, na)
    end // end of [PTCMPconlparen]
  | ~PTCMPreclparen _ => let
      val () = na := na + 1 in auxlst2 (plvl+1, xs, na)
    end // end of [PTCMPreclparen]
//
  | ~PTCMPrparen () =>
    (
      if plvl = 0 then xs else auxlst2 (plvl, xs, na)
    ) // end of [PTCMPrparen]
//
  | v (* rest-of-PTCMP *) => let
      val () = patcomp_view_free (v) in auxlst2 (plvl, xs, na)
    end // end of [rest-of-PTCMP]
//
end else glist_nil ((*void*))
//
end // end of [auxlst2]
//
in
  auxlst (xs, na)
end // end of [patcomplst_unskip]

(* ****** ****** *)

implement
patcomplst_unrparen
  (xs0, na) = let
in
//
if glist_is_cons (xs0) then let
  val x = glist_head<patcomp> (xs0)
  val xs1 = glist_tail<patcomp> (xs0)
in
  if patcomp_is_PTCMPrparen (x)
    then xs1
    else let
      val xs0 =
        patcomplst_unskip (xs0, na)
      // end of [val]
    in
      patcomplst_unrparen (xs0, na)
    end // end of [else]
  // end of [if]
end else glist_nil ((*void*))
//
end // end of [patcomplst_unrparen]

(* ****** ****** *)

extern
fun
patcomplst_subtest
  (xs1: patcomplst, xs2: patcomplst): patckont
// end of [patcomplst_subtest]
extern
fun
patcomplst_subtests
  (xs1: patcomplst, xss2: patcomplstlst): patckont
// end of [patcomplst_subtests]

(* ****** ****** *)
//
extern
fun
patck_isbin (ptck: patck): bool
extern
fun
patck_ismat (ptck1: patck, ptck2: patck): bool
//
(* ****** ****** *)

implement
patck_isbin (ptck) = let
in
//
case+ patck_view (ptck) of
| ~PATCKbool _ => true
| ~PATCKcon (d2c) =>
    if d2con_is_con (d2c) then d2con_is_binarian (d2c) else false
  // end of [PATCKcon]
| v => (patck_view_free (v); false)
end // end of [patck_isbin]

(* ****** ****** *)

implement
patck_ismat
  (ptck1, ptck2) = let
in
//
case+ patck_view (ptck1) of
//
| ~PATCKcon (d2c1) =>
  (
  case+ patck_view (ptck2) of
  | ~PATCKcon (d2c2) => d2c1 = d2c2
  | v => (patck_view_free (v); false)
  )
//
| ~PATCKint (i1) =>
  (
  case+ patck_view (ptck2) of
  | ~PATCKint (i2) => i1 = i2
  | v => (patck_view_free (v); false)
  )
| ~PATCKbool (b1) =>
  (
  case+ patck_view (ptck2) of
  | ~PATCKbool (b2) => b1 = b2
  | v => (patck_view_free (v); false)
  )
| ~PATCKchar (c1) =>
  (
  case+ patck_view (ptck2) of
  | ~PATCKchar (c2) => c1 = c2
  | v => (patck_view_free (v); false)
  )
| ~PATCKstring (str1) =>
  (
  case+ patck_view (ptck2) of
  | ~PATCKstring (str2) => str1 = str2
  | v => (patck_view_free (v); false)
  )
//
(*
| PATCKi0nt of (i0nt)
| PATCKf0loat of (f0loat)
*)
//
| v (*rest-of-PATCK*) => (patck_view_free (v); false)
end // end of [patck_ismat]

(* ****** ****** *)

local

fun
auxlst
(
  xs10: patcomplst
, xs20: patcomplst
, tmvlst: &tmpmovlst_vt >> _
) : Option_vt (patcomplst) = let
in
//
if glist_is_cons (xs10) then
(
  if glist_is_cons (xs20)
    then auxlst2 (xs10, xs20, tmvlst) else None_vt ()
  // end of [if]
) else Some_vt (xs20)
//
end // end of [auxlst]

and
auxlst2
(
  xs10: patcomplst
, xs20: patcomplst
, tmvlst: &tmpmovlst_vt >> _
) : Option_vt (patcomplst) = let
//
val x1 = glist_head<patcomp> (xs10) // HX: [val+list_cons]
val xs1 = glist_tail<patcomp> (xs10)
val x2 = glist_head<patcomp> (xs20) // HX: [val+list_cons]
val xs2 = glist_tail<patcomp> (xs20)
//
(*
val out = stdout_ref
val () = fprintln! (out, "auxlst2: x1 = ", x1)
val () = fprintln! (out, "auxlst2: xs1 = ", xs1)
val () = fprintln! (out, "auxlst2: x2 = ", x2)
val () = fprintln! (out, "auxlst2: xs2 = ", xs2)
*)
//
in
//
if patcomp_is_PTCMPany (x2) then let
    var na: int = 0
    val xs1 = patcomplst_unskip (xs10, na)
  in
    auxlst (xs1, xs2, tmvlst)
  end
else if patcomp_is_PTCMPvar (x2) then let
    var na: int = 0
    val xs1 = patcomplst_unskip (xs10, na)
  in
    auxlst (xs1, xs2, tmvlst)
  end
//
else if patcomp_is_PTCMPasvar (x2) then auxlst (xs10, xs2, tmvlst)
//
else if patcomp_is_PTCMPrparen (x2) then let
    var na: int = 0
    val xs1 = patcomplst_unrparen (xs10, na)
  in
    auxlst (xs1, xs2, tmvlst)
  end
//
else if patcomp_is_PTCMPany (x1) then Some_vt (xs20)
else if patcomp_is_PTCMPvar (x1) then Some_vt (xs20)
//
else if patcomp_is_PTCMPasvar (x1) then auxlst (xs1, xs20, tmvlst)
//
else if patcomp_is_PTCMPrparen (x1) then Some_vt (xs20)
//
else
(
case+ patcomp_view (x2) of
//
| ~PTCMPlablparen (lab2) =>
  (
    case+ patcomp_view (x1) of
    | ~PTCMPlablparen
        (lab1) => let
        val sgn = compare (lab1, lab2)
      in
        if sgn = 0 then auxlst (xs1, xs2, tmvlst) else None_vt ()
      end // end of [PTCMPlablparen]
    | v => (patcomp_view_free (v); None_vt ())
  )
//
| ~PTCMPpatlparen
    (ptck2, tpmv2, _, _, _) =>
  (
    case+ patcomp_view (x1) of
    | ~PTCMPpatneg
        (ptck1, tpmv1) => let
        val ismat = patck_ismat (ptck1, ptck2)
        val ((*void*)) =
          tmpmovlst_add (tmvlst, tpmv1, tpmv2)
        // end of [val]
      in
        if ismat
          then None_vt () else let
          val isbin = patck_isbin (ptck1)
        in
          if isbin then Some_vt (xs2) else Some_vt (xs20)
        end // end of [else] // end of [if]
      end // end of [PTCMPpatneg]
    | ~PTCMPpatlparen
        (ptck1, tpmv1, _, _, _) => let
        val ismat = patck_ismat (ptck1, ptck2)
        val ((*void*)) =
          tmpmovlst_add (tmvlst, tpmv1, tpmv2)
        // end of [val]
      in
        if ismat
          then auxlst (xs1, xs2, tmvlst) else None_vt(*void*)
        // end of [if]
      end // end of [PTCMPpatlparen]
    | v (*non-PTCMPpatlparen*) => (patcomp_view_free (v); None_vt ((*void*)))
  )
//
// HX-2015-04-21:
// bug-2015-04-21 due to
// the following clause being missing
//
| ~PTCMPreclparen (tpmv2, _) =>
  (
    case+ patcomp_view (x1) of
    | ~PTCMPreclparen (tpmv1, _) => let
        val ((*void*)) =
          tmpmovlst_add (tmvlst, tpmv1, tpmv2)
        // end of [val]
      in
        auxlst (xs1, xs2, tmvlst)
      end // end of [PTCMPreclparen]
    | v (*non-PTCMPreclparen*) => (patcomp_view_free (v); None_vt ((*void*)))
  ) (* end of [PTCMPreclparen] *)
//
| v (* rest-of-PTCMP *) => (patcomp_view_free (v); None_vt ((*void*)))
//
) (* end of [else] *)
//
end // end of [auxlst2]

fun
auxmovfin
(
  xs2: patcomplst, tmvlst: &tmpmovlst_vt >> _
) : void = let
//
(*
//
val
out = stdout_ref
val () =
  fprintln! (out, "auxmovfin: xs2 = ", xs2)
//
*)
//
fun ftpmv
(
  tpmv2: tmprimval
, tmvlst: &tmpmovlst_vt >> _
) : void =
(
  case+ tmprimval_view (tpmv2) of
  | ~TPMVnone
      (pmv) => ((*void*))
  | ~TPMVsome
      (tmp, pmv) => let
      val tpmv1 = tmprimval_TPMVnone (pmv)
    in
      tmpmovlst_add (tmvlst, tpmv1, tpmv2)
    end // end of [TPMVsome]
) (* end of [ftpmv] *)
//
in
//
if glist_is_cons (xs2) then let
  val x2 = glist_head<patcomp> (xs2)
  val xs2 = glist_tail<patcomp> (xs2)
in
  case+ patcomp_view (x2) of
  | ~PTCMPpatlparen
      (ptck2, tpmv2, _, _, _) => ftpmv (tpmv2, tmvlst)
    // end of [PTCMPpatlparen]
  | ~PTCMPreclparen (tpmv2, _) => ftpmv (tpmv2, tmvlst) // HX: bug-2013-12-04
  | v (*rest-of-PTCMP...lparen*) => let
      val () = patcomp_view_free (v) in auxmovfin (xs2, tmvlst)
    end // end of [rest-of-PTCMP...lparen]
end else ((*void*))
//
end // end of [auxmovfin]

in (* in of [local] *)

implement
patcomplst_subtest
  (xs10, xs20) = let
//
var tmvlst
  : tmpmovlst_vt = list_vt_nil()
//
val opt = auxlst(xs10, xs20, tmvlst)
//
// HX-2026-10: [auxmovfin] is called before the match (it only ran on the [Some_vt]
// branch in ATS1) so that the variable is consumed once, outside of the branches
//
val opt =
(
  case+ opt of
  | ~None_vt() => None_vt()
  | ~Some_vt(xs2) => let
      val () = auxmovfin(xs2, tmvlst) in Some_vt(xs2)
    end // end of [Some_vt]
) : Option_vt (patcomplst)
//
val tmvlst1 = tmvlst
//
in
//
case+ opt of
| ~None_vt() => let
    val () = list_vt_free<tmpmov>(tmvlst1)
  in
    patckont_PTCKNTnone((*void*))
  end // end of [None_vt]
| ~Some_vt(xs2) => let
    val tmvlst1 = list_vt_reverse(tmvlst1)
    val tmvlst1 = l2l(tmvlst1)
    val opt_tlab = patcomplst_find_tmplab(xs2)
    val-~Some_vt(tlab) = opt_tlab
  in
    patckont_PTCKNTtmplabmov(tlab, tmvlst1)
  end // end of [some_vt]
//
end // end of [patcomplst_subtest]

end // end of [local]

(* ****** ****** *)

implement
patcomplst_subtests
  (xs1, xss2) = let
in
//
if glist_is_cons (xss2) then let
    val xs2 = glist_head<patcomplst> (xss2)
    val xss2 = glist_tail<patcomplst> (xss2)
    val ptjmp = patcomplst_subtest(xs1, xs2)
  in
    if patckont_is_PTCKNTnone (ptjmp)
      then patcomplst_subtests(xs1, xss2) else ptjmp
  end // end of [list_cons]
else patckont_PTCKNTnone()
//
end // end of [patcomplst_subtests]

(* ****** ****** *)
//
extern
fun
patcomplst_jumpfill_rest
  (xs1: patcomplst, xss2: patcomplstlst): void
//
(* ****** ****** *)

implement
patcomplst_jumpfill_rest
  (xs1, xss2) = let
//
(*
val out = stdout_ref
val ((*void*)) =
fprintln! (out, "patcomplst_jumpfill_rest: xs1 = ", xs1)
*)
//
// HX: [rxs] is the reversed prefix of [xs1] (a [list_vt] in ATS1;
// [pxs1] is its copy, reversed, to which a [PTCMPpatneg] is added)
//
fun auxlst
(
  xs1: patcomplst
, xss2: patcomplstlst
, rxs: patcomplst
) : void = let
in
//
if glist_is_cons (xs1) then let
    val x1 = glist_head<patcomp> (xs1)
    val xs1 = glist_tail<patcomp> (xs1)
    val () = (
      case+ patcomp_view (x1) of
      | ~PTCMPpatlparen
        (
          ptck, tpmv, tlab, opt, kntr
        ) => let
          val rxs1 =
            glist_cons<patcomp> (patcomp_PTCMPpatneg (ptck, tpmv), rxs)
          val pxs1 = glist_reverse<patcomp> (rxs1)
          val ptjmp = patcomplst_subtests (pxs1, xss2)
        in
          set_patckontref_val (kntr, ptjmp)
        end (* end of [PTCMPpatlparen] *)
      | ~PTCMPtmplabgua(tlab, kntr) => let
          val pxs1 = glist_reverse<patcomp> (rxs)
          val ptjmp = patcomplst_subtests (pxs1, xss2)
        in
          if patckont_is_PTCKNTnone (ptjmp)
            then () else set_patckontref_val (kntr, ptjmp) // HX-2016-10-11: fixing bug-2016-10-08
        end (* end of [PTCMPtmplabgua] *)
      | v (* rest-of-PTCMP *) => patcomp_view_free (v)
    ) : void // end of [val]
  in
    auxlst (xs1, xss2, glist_cons<patcomp> (x1, rxs))
  end // end of [list_cons]
else ((*void*)) // HX: [list_vt_free (rxs)]
//
end // end of [auxlst]
//
in
  auxlst (xs1, xss2, glist_nil ())
end // end of [patcomplst_jumpfill_rest]

(* ****** ****** *)
//
extern
fun
patcomplst_jumpfill_fail
  (xs: patcomplst, fail: patckont): void
//
(* ****** ****** *)

implement
patcomplst_jumpfill_fail
  (xs, fail) = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<patcomp> (xs)
    val xs = glist_tail<patcomp> (xs)
    val () = (
      case+ patcomp_view (x) of
      | ~PTCMPpatlparen
          (_, _, _, _, kntr) =>
        (
          if patckont_is_PTCKNTnone (patckontref_val (kntr))
            then set_patckontref_val (kntr, fail) else ()
          // end of [if]
        ) (* end of [PTCMPpatlparen] *)
      | v (* non-PTCMPpatlparen *) => patcomp_view_free (v)
    ) : void // end of [val]
  in
    patcomplst_jumpfill_fail (xs, fail)
  end // end of [list_cons]
else ((*void*))
//
end // end of [patcomplst_jumpfill_fail]

(* ****** ****** *)
//
extern
fun
patcomplstlst_jumpfill
  (xss: patcomplstlst, fail: patckont): void
//
(* ****** ****** *)

implement
patcomplstlst_jumpfill
  (xss, fail) = let
in
//
if glist_is_cons (xss) then let
    val xs = glist_head<patcomplst> (xss)
    val xss = glist_tail<patcomplst> (xss)
    val () = patcomplst_jumpfill_rest (xs, xss)
    val () = patcomplst_jumpfill_fail (xs, fail)
  in
    patcomplstlst_jumpfill (xss, fail)
  end // end of [list_cons]
else ((*void*))
//
end // end of [patcomplstlst_jumpfill]

(* ****** ****** *)
//
extern
fun
himatchlst_patcomp
(
  lvl0: int
, hicl: hiclau, pmvs: primvalist, hips: hipatlst
) : patcomplst // end of [himatchlst_patcomp]
//
(* ****** ****** *)

local

(* ****** ****** *)

fun
auxtpmv_make
(
  hip: hipat, pmv0: primval
) : tmprimval = let
  val loc = hip.hipat_loc()
  val hse = hip.hipat_type()
  val tmp = tmpvar_make (loc, hse)
in
  tmprimval_TPMVsome (tmp, pmv0)
end // end of [auxtpmv_make]

(* ****** ****** *)

fun
addrparen
(
  mtks: matokenlst
) : matokenlst = glist_cons (matoken_MTKrparen (), mtks)

(* ****** ****** *)

fun
addselcon
(
  tpmv: tmprimval
, hse_sum: hisexp
, lxs: labhipatlst
, mtks: matokenlst
) : matokenlst = let
in
//
if glist_is_cons (lxs) then let
    val lx = glist_head<labhipat> (lxs)
    val lxs = glist_tail<labhipat> (lxs)
    val lab = lx.labhipat_lab ()
    val hip = lx.labhipat_elt ()
    val loc = hip.hipat_loc()
    val hse = hip.hipat_type()
    val pmv = tmprimval2pmv (tpmv)
    val pmvsel = primval_selcon (loc, hse, pmv, hse_sum, lab)
    val tpmvsel = auxtpmv_make (hip, pmvsel)
    val mtk0 = matoken_MTKlabpat (lab, hip, tpmvsel)
    val mtks = addselcon (tpmv, hse_sum, lxs, mtks)
  in
    glist_cons (mtk0, mtks)
  end // end of [list_cons]
else mtks
//
end // end of [addselcon]

fun
addselect
(
  tpmv: tmprimval
, hse_rec: hisexp
, lxs: labhipatlst
, mtks: matokenlst
) : matokenlst = let
in
//
if glist_is_cons (lxs) then let
    val lx = glist_head<labhipat> (lxs)
    val lxs = glist_tail<labhipat> (lxs)
    val lab = lx.labhipat_lab ()
    val hip = lx.labhipat_elt ()
    val loc = hip.hipat_loc()
    val hse = hip.hipat_type()
    val pml = primlab_lab (loc, lab)
    val pmv = tmprimval2pmv (tpmv)
    val pmvsel = primval_select (loc, hse, pmv, hse_rec, pml)
    val tpmvsel = auxtpmv_make (hip, pmvsel)
    val mtk0 = matoken_MTKlabpat (lab, hip, tpmvsel)
    val mtks = addselect (tpmv, hse_rec, lxs, mtks)
  in
    glist_cons (mtk0, mtks)
  end // end of [list_cons]
else mtks
//
end // end of [addselect]

(* ****** ****** *)
//
// HX-2026-10: the ATS1 functions returned a [list_vt] built from the
// head ([list_vt_cons (ptcmp0, ptcmps)]); here [res] collects the
// components in reverse and is returned (reversed) at the end: every
// component is made before the rest is processed, as in ATS1.
//
fun
auxcomplst
(
  lvl0: int, mtks: matokenlst, res: patcomplst_vt
) : patcomplst_vt = let
in
//
if glist_is_cons (mtks) then
(
  auxcomplst_mtk
    (lvl0, glist_head<matoken> (mtks), glist_tail<matoken> (mtks), res)
) else res
//
end // end of [auxcomplst]

and
auxcomplst_mtk
(
  lvl0: int
, mtk0: matoken, mtks: matokenlst, res: patcomplst_vt
) : patcomplst_vt = let
in
//
case+ matoken_view (mtk0) of
//
| ~MTKpat(hip, tpmv) =>
  (
    auxcomplst_pat(lvl0, tpmv, hip, mtks, res)
  )
//
| ~MTKlabpat
    (lab, hip, tpmv) =>
  (
    auxcomplst_labpat(lvl0, tpmv, lab, hip, mtks, res)
  ) (* end of [MTKlabpat] *)
//
| ~MTKrparen((*void*)) =>
  (
    auxcomplst(lvl0, mtks, list_vt_cons(patcomp_PTCMPrparen (), res))
  ) (* end of [MTKrparen] *)
//
end // end of [auxcomplst_mtk]

and
auxcomplst_pat
(
  lvl0: int
, tpmv: tmprimval
, hip0: hipat
, mtks: matokenlst
, res: patcomplst_vt
) : patcomplst_vt = let
//
val loc0 = hip0.hipat_loc()
//
in
//
case+
hipat_node_view(hip0.hipat_node())
of (* case+ *)
//
| ~HIPany(d2v) => let
    val ptcmp0 = patcomp_PTCMPany(d2v)
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp0, res))
  end // end of [HIPany]
| ~HIPvar(d2v) => let
    val () =
    d2var_set_level(d2v, lvl0)
    val nused = d2var_get_utimes(d2v)
    val ptcmp0 =
    (
      if nused > 0
        then patcomp_PTCMPvar(d2v, tpmv) else patcomp_PTCMPany(d2v)
      // end of [if]
    ) : patcomp // end of [val]
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp0, res))
  end // end of [HIPvar]
//
| ~HIPint(i) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKint(i), tpmv, tl, gopt_none((*knd*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPint]
| ~HIPintrep(rep) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val i0 = $UN.cast{int}(i0) where // HX: [int_of_llint]
    {
      val i0 = $UT.llint_make_string(rep)
    }
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKint(i0), tpmv, tl, gopt_none((*void*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPintrep]
//
| ~HIPbool(b) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKbool(b), tpmv, tl, gopt_none((*knd*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPint]
//
| ~HIPchar(c) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKchar(c), tpmv, tl, gopt_none((*knd*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPint]
//
| ~HIPstring(str) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKstring(str), tpmv, tl, gopt_none((*knd*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPint]
//
| ~HIPfloat(rep) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val f = $UT.double_make_string(rep)
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKfloat(f), tpmv, tl, gopt_none((*knd*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPint]
//
| ~HIPi0nt(tok) => let
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val i0 = $P2TC.i0nt2intinf(tok)
    val i0 = $INTINF.intinf_get_int(i0)
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKint(i0), tpmv, tl, gopt_none((*void*)), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPi0nt]
//
| ~HIPempty() => auxcomplst (lvl0, mtks, res)
//
| ~HIPcon
  (
    knd, d2c, hse_sum, lxs
  ) => let
//
    val () =
    the_dynconlst_add(d2c)
//
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKcon(d2c), tpmv, tl, gopt_some(knd), kntr)
    // end of [val]
    val mtks = addrparen(mtks)
    val mtks = addselcon(tpmv, hse_sum, lxs, mtks)
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp0, res))
  end // end of [HIPcon]
//
| ~HIPcon_any
    (knd, d2c) => let
//
    val () =
    the_dynconlst_add(d2c)
//
    val tl = tmplab_make(loc0)
    val kntr = patckontref_make()
    val ptcmp0 =
    patcomp_PTCMPpatlparen
      (patck_PATCKcon(d2c), tpmv, tl, gopt_some(knd), kntr)
    // end of [val]
    val ptcmp1 = patcomp_PTCMPrparen()
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  end // end of [HIPcon_any]
//
| ~HIPrec
  (
    knd, pck, lxs, hse_rec
  ) => let
    val tl = tmplab_make(loc0)
    val mtks = addrparen(mtks)
    val mtks =
    addselect(tpmv, hse_rec, lxs, mtks)
    val ptcmp0 = patcomp_PTCMPreclparen(tpmv, tl)
  in
    auxcomplst(lvl0, mtks, list_vt_cons(ptcmp0, res))
  end // end of [HIPrec]
//
| ~HIPrefas(d2v, hip) => let
    val () =
    d2var_set_level(d2v, lvl0)
    val ptcmp0 = patcomp_PTCMPasvar(d2v, tpmv)
  in
    auxcomplst_pat(lvl0, tpmv, hip, mtks, list_vt_cons(ptcmp0, res))
  end // end of [HIPrefas]
//
| ~HIPann(hip, _(*ann*)) =>
    auxcomplst_pat(lvl0, tpmv, hip, mtks, res)
  // end of [HIPann(hip, ann)]
//
| v (* rest-of-hipat *) => let
    val () = hipat_node_view_free (v)
    val () =
    prerr_interror_loc(loc0)
    val () =
    (
      prerr_string (": himatchlst_patcomp"); prerr_newline ()
    ) (* end of [val] *)
    val () =
    (
      print_string (": auxcomplst_pat: hip0 = "); print_hipat (hip0); print_newline ()
    ) (* end of [val] *)
    val () = assertloc(false) in res
  end // end of [rest-of-hipat]
//
end // end of [auxcomplst_pat]

and
auxcomplst_labpat
(
  lvl0: int
, tpmv: tmprimval
, lab0: label, hip0: hipat
, mtks: matokenlst, res: patcomplst_vt
) : patcomplst_vt = let
  val ptcmp0 = patcomp_PTCMPlablparen(lab0)
  val ptcmp1 = patcomp_PTCMPrparen((*void*))
in
  auxcomplst_pat
    (lvl0, tpmv, hip0, mtks, list_vt_cons(ptcmp1, list_vt_cons(ptcmp0, res)))
  // end of [auxcomplst_pat]
end // end of [auxcomplst_labpat]

in (* in of [local] *)

implement
himatchlst_patcomp
  (lvl0, hicl, pmvs, hips) = let
//
fun auxloc
(
  hip: hipat, hips: hipatlst
) : location = let
in
//
if glist_is_cons (hips) then
  auxloc (glist_head<hipat> (hips), glist_tail<hipat> (hips))
else
  $LOC.location_rightmost (hip.hipat_loc())
// end of [if]
//
end // end of [auxloc]
//
fun auxlst
(
  pmvs: primvalist, hips: hipatlst
) : matokenlst = let
in
//
if glist_is_cons (pmvs) then let
    val pmv = glist_head<primval> (pmvs)
    val pmvs = glist_tail<primval> (pmvs)
    val tpmv = tmprimval_TPMVnone (pmv)
    val hip = glist_head_exn<hipat> (hips)
    val hips = glist_tail_exn<hipat> (hips)
    val mtk0 = matoken_MTKpat (hip, tpmv)
    val mtks = auxlst (pmvs, hips)
  in
    glist_cons (mtk0, mtks)
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [auxlst]
//
in
//
if glist_is_cons (pmvs) then let
    val pmv = glist_head<primval> (pmvs)
    val pmvs = glist_tail<primval> (pmvs)
    val tpmv = tmprimval_TPMVnone(pmv)
    val hip = glist_head_exn<hipat>(hips)
    val hips = glist_tail_exn<hipat>(hips)
    val lend = auxloc(hip, hips)
    val mtks = auxlst(pmvs, hips)
    val ptcmps = auxcomplst_pat(lvl0, tpmv, hip, mtks, list_vt_nil())
    val tlab = tmplab_make(lend)
    val isnot = glist_is_nil(hicl.hiclau_gua())
    val ptcmpz =
    (
      if isnot
        then patcomp_PTCMPtmplabend(tlab)
        else let
          val loc = hicl.hiclau_loc()
          val kntr = patckontref_make_loc(loc) in patcomp_PTCMPtmplabgua(tlab, kntr)
        end // end of [else]
      // end of [if]
    ) : patcomp // end of [val]
    // HX: [list_vt_extend (ptcmps, ptcmpz)] (ptcmps is reversed here)
  in
    glist_ofrev_vt<patcomp> (list_vt_cons (ptcmpz, ptcmps), glist_nil ())
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [himatchlst_patcomp]

end // end of [local]

(* ****** ****** *)
//
extern
fun
hiclau_patcomp
(
  lvl0: int
, hicl: hiclau, pmvs: primvalist
) : patcomplst // endfun
//
implement
hiclau_patcomp
  (lvl0, hicl, pmvs) = let
//
val hips = hicl.hiclau_pat()
val ptcmps = himatchlst_patcomp(lvl0, hicl, pmvs, hips)
//
(*
val out = stdout_ref
val () = fprintln! (out, "hiclau_patcomp: hips =\n", hips)
val () = fprintln! (out, "hiclau_patcomp: ptcmps =\n", ptcmps)
*)
//
in
  ptcmps
end // end of [hiclau_patcomp]
//
(* ****** ****** *)

extern
fun
hiclaulst_patcomp
(
  lvl0: int
, hicls: hiclaulst, pmvs: primvalist
) : patcomplstlst // endfun
implement
hiclaulst_patcomp
  (lvl0, hicls, pmvs) = let
//
fun
loop
(
  hicls: hiclaulst, res: List0_vt(patcomplst)
) : patcomplstlst = let
in
//
if glist_is_cons (hicls) then let
    val hicl = glist_head<hiclau> (hicls)
    val hicls = glist_tail<hiclau> (hicls)
    val xs = hiclau_patcomp (lvl0, hicl, pmvs)
  in
    loop (hicls, list_vt_cons (xs, res))
  end // end of [list_cons]
else glist_ofrev_vt<patcomplst> (res, glist_nil ())
//
end // end of [loop]
//
in
  loop (hicls, list_vt_nil ())
end // end of [hiclaulst_patcomp]

(* ****** ****** *)

extern
fun
patcomplst_ccomp
  (env: !ccompenv, xs: patcomplst): instrlst_vt
// end of [patcomplst_ccomp]

(* ****** ****** *)

local

fun
addtpmv
(
  res: instrlst_vt, tpmv: tmprimval
) : instrlst_vt = let
in
//
case+ tmprimval_view (tpmv) of
| ~TPMVnone _ => res
| ~TPMVsome
    (tmp, pmv) => let
    val loc = tmpvar_get_loc (tmp)
    val ins = instr_move_val (loc, tmp, pmv)
  in
    list_vt_cons (ins, res)
  end // end of [TPMVsome]
//
end (* end of [addtpmv] *)

fun
addtlab
(
  res: instrlst_vt, tlab: tmplab
) : instrlst_vt = let
  val loc = tmplab_get_loc (tlab)
  val ins = instr_tmplab (loc, tlab) in list_vt_cons (ins, res)
end // end of [addtlab]

(* ****** ****** *)

fun
addfreecon
(
  env: !ccompenv
, pmv: primval, opt: pckindopt, ptck: patck
) : void = let
in
//
case+ gopt_view (opt) of
| ~GOsome (knd) => (
  case+ patck_view (ptck) of
  | ~PATCKcon(d2c) =>
      ccompenv_add_freeconenv_if(env, pmv, knd, d2c)
  | v(*non-PATCKcon*) => patck_view_free (v)
  ) (* end of [Some] *)
| ~GOnone ((*void*)) => ()
//
end // end of [addfreecon]

(* ****** ****** *)

fun
fptcmplst
(
  env: !ccompenv
, xs0: patcomplst
, res1: instrlst_vt
, res2: instrlst_vt
) : instrlst_vt = let
(*
val () = println! ("fptcmplst")
*)
in
//
if glist_is_cons (xs0) then
(
  fptcmplst2
    (env, glist_head<patcomp> (xs0), glist_tail<patcomp> (xs0), res1, res2)
) else let
    val
    res2 = list_vt_reverse(res2)
  in
    list_vt_reverse_append(res1, res2)
  end // end of [list_nil]
//
end (* end of [fptcmplst] *)

and
fptcmplst2
(
  env: !ccompenv
, x0: patcomp, xs1: patcomplst
, res1: instrlst_vt
, res2: instrlst_vt
) : instrlst_vt = let
(*
val () = println! ("fptcmplst2")
*)
in
//
case+ patcomp_view (x0) of
| ~PTCMPany(d2v) =>
    fptcmplst(env, xs1, res1, res2)
  // end of [PTCMPany]
| ~PTCMPvar(d2v, tpmv) => let
    val pmv = tmprimval2pmv2(tpmv, d2v)
    val ((*void*)) =
      ccompenv_add_vbindmapenvall(env, d2v, pmv)
    val res2 = let
      val ismut = d2var_is_mutabl(d2v)
    in
      if ismut then res2 else addtpmv(res2, tpmv)
    end : instrlst_vt // end of [val]
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPvar]
| ~PTCMPasvar(d2v, tpmv) => let
    val pmv = tmprimval2pmv2(tpmv, d2v)
    val ((*void*)) =
      ccompenv_add_vbindmapenvall(env, d2v, pmv)
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPasvar]
//
| ~PTCMPpatlparen
  (
    ptck, tpmv, tlab, opt, kntr
  ) => let
    val res1 = addtpmv(res1, tpmv)
    val res1 = addtlab(res1, tlab)
//
    val pmv = tmprimval2pmv(tpmv)
    val ((*void*)) = addfreecon(env, pmv, opt, ptck)
    val ins = instr_patck(pmv.primval_loc(), pmv, ptck, patckontref_val(kntr))
//
    val res1 = list_vt_cons(ins, res1)
//
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPreclparen]
//
| ~PTCMPreclparen
    (tpmv, tlab) => let
    val res1 = addtpmv(res1, tpmv)
    val res1 = addtlab(res1, tlab)
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPreclparen]
//
| ~PTCMPtmplabend
    (tlab) => let
    val res1 = addtlab(res1, tlab)
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPtmplabend]
| ~PTCMPtmplabgua
    (tlab, _) => let
    val res1 = addtlab(res1, tlab)
  in
    fptcmplst (env, xs1, res1, res2)
  end // end of [PTCMPtmplabgua]
//
| v (*non-PTCMP*) => let
    val () = patcomp_view_free (v) in fptcmplst(env, xs1, res1, res2)
  end // end of [non-PTCMP]
//
end (* end of [fptcmplst2] *)

in (* in of [local] *)

implement
patcomplst_ccomp
  (env, xs) = let
//
(*
val () =
println! ("patcomplst_ccomp")
*)
//
in
  fptcmplst (env, xs, list_vt_nil(), list_vt_nil())
end // end of [patcomplst_ccomp]

end // end of [local]

(* ****** ****** *)
//
extern
fun
higmat_ccomp
(
  env: !ccompenv, res: !instrseq
, lvl0: int, hig: higmat, fail: patckont
) : void // end of [higmat_ccomp]
//
extern
fun
higmatlst_ccomp
(
  env: !ccompenv, res: !instrseq
, lvl0: int, higs: higmatlst, fail: patckont
) : void // end of [higmatlst_ccomp]
//
(* ****** ****** *)

implement
higmat_ccomp
(
  env, res, lvl0, hig, fail
) = let
//
val hde = hig.higmat_exp()
//
val hip = (
//
case+
gopt_view(hig.higmat_pat()) of
| ~GOsome (hip) => hip
| ~GOnone ((*void*)) => let
    val hse = hisexp_bool_t0ype ()
  in
    hipat_bool (hde.hidexp_loc(), hse, true)
  end // end of [None]
//
) : hipat // end of [val]
//
val
pmv = hidexp_ccomp(env, res, hde)
//
val () = hipatck_ccomp(env, res, fail, hip, pmv)
val () = himatch_ccomp(env, res, lvl0, hip, pmv)
//
in
  // nothing
end // end of [higmat_ccomp]

implement
higmatlst_ccomp
  (env, res, lvl0, higs, fail) = let
//
(*
val () = println! ("higmatlst_ccomp")
*)
//
in
//
if glist_is_cons (higs) then let
    val () =
      higmat_ccomp(env, res, lvl0, glist_head<higmat> (higs), fail)
    // end of [val]
  in
    higmatlst_ccomp(env, res, lvl0, glist_tail<higmat> (higs), fail)
  end (* end of [list_cons] *)
else ((*void*))
//
end // end of [higmatlst_ccomp]

(* ****** ****** *)

local

fun auxcl
(
  env: !ccompenv
, lvl0: int
, hicl: hiclau
, ptcmps: patcomplst
, tmpret: tmpvar
) : ibranch = let
//
val res = instrseq_make_nil ()
//
val (pf0 | ()) = ccompenv_push (env)
val ((*void*)) = ccompenv_inc_freeconenv (env)
//
val inss = patcomplst_ccomp (env, ptcmps)
val ((*void*)) = instrseq_addlst_vt (res, inss)
//
val higs = hicl.hiclau_gua() (* guard-list *)
//
val () = (
//
if glist_is_cons (higs) then let
    val () =
    instrseq_add_comment(res, "ibranch-guard:")
    val fail = patcomplst_find_guafail (ptcmps)
  in
    higmatlst_ccomp(env, res, lvl0, higs, fail)
  end // end of [list_cons]
else ((*void*))
//
) : void // end of [val]
//
val loc = hicl.hiclau_loc()
//
val
pmvs_freecon =
  ccompenv_getdec_freeconenv(env)
//
val () =
  instrseq_add_freeconlst(res, loc, pmvs_freecon)
//
val () = instrseq_add_comment(res, "ibranch-mbody:")
//
val () =
hidexp_ccomp_ret(env, res, tmpret, hicl.hiclau_body())
//
val () = ccompenv_pop(pf0 | env)
//
val inss = instrseq_get_free(res)
//
(*
val () =
fprintln!
  (stdout_ref, "hiclaulst_ccomp: auxcl: inss =\n", inss)
// end of [val]
*)
//
in
  ibranch_make(hicl.hiclau_loc(), inss)
end (* end of [auxcl] *)

fun
auxclist
(
  env: !ccompenv
, lvl0: int
, hicls: hiclaulst
, ptcmpss: patcomplstlst
, tmpret: tmpvar
, res: List0_vt(ibranch)
) : ibranchlst = let
in
//
if glist_is_cons (hicls) then let
//
    val hicl = glist_head<hiclau> (hicls)
    val hicls = glist_tail<hiclau> (hicls)
    val ptcmps = glist_head_exn<patcomplst> (ptcmpss)
    val ptcmpss = glist_tail_exn<patcomplst> (ptcmpss)
//
    val ibranch =
      auxcl(env, lvl0, hicl, ptcmps, tmpret)
//
  in
    auxclist(env, lvl0, hicls, ptcmpss, tmpret, list_vt_cons (ibranch, res))
  end // end of [list_cons]
else glist_ofrev_vt<ibranch> (res, glist_nil ())
//
end (* end of [auxclist] *)

in (* in of [local] *)

implement
hiclaulst_ccomp
(
  env, lvl0, pmvs, hicls, tmpret, fail
) = let
//
val ptcmpss =
  hiclaulst_patcomp(lvl0, hicls, pmvs)
val ((*void*)) =
  patcomplstlst_jumpfill(ptcmpss, fail)
//
(*
val () = fprintln! (stdout_ref, "ptcmpss =\n", ptcmpss)
*)
//
in
  auxclist(env, lvl0, hicls, ptcmpss, tmpret, list_vt_nil ())
end // end of [hiclaulst_ccomp]

end // end of [local]

(* ****** ****** *)

(* end of [pats_ccomp_claulst.dats] *)
