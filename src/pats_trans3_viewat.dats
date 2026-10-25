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
// Start Time: May, 2012
//
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_viewat.dats, see PORTING.md, "Level 3 translation, group 4")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
(
// argumentless
) = prerr "pats_trans3_viewat"
//
(* ****** ****** *)

staload LAB = "./pats_label.sats"
overload = with $LAB.eq_label_label

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

local

fun
auxerr_pfobj
(
  loc0: loc_t, s2l: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": [view@] operation cannot be performed"
  val () = prerr ": the proof search for view located at ["
  val () = prerr_s2exp (s2l)
  val () = prerr "] failed to turn up a result."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_pfobj_search_none (loc0, s2l))
end // end of [auxerr_pfobj]

fun
auxerr_context
(
  loc0: loc_t, s2e: s2exp, d3ls: d3lablst
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": [view@] operation cannot be performed"
  val () = prerr ": context cannot be formed for the atview being taken."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_s2addr_viewat_deref_context (loc0, s2e, d3ls))
end // end of [auxerr_context]

fun auxlabs (
  d3ls: d3lablst
) : s2lablst =
  if glist_is_cons (d3ls) then let
    val d3l = glist_head (d3ls)
    val d3ls = glist_tail (d3ls)
  in
    case+ d3lab_node_view (d3l.d3lab_node ()) of
    | ~D3LABlab (l) =>
        glist_cons (s2lab_S2LABlab (l), auxlabs d3ls)
    | v => (d3lab_node_view_free (v); glist_nil ()) // deadcode
  end else glist_nil ()
// end of [auxlabs]

fun auxmain
(
  loc0: loc_t
, pfobj: pfobj, d3ls: d3lablst
) : s2exp(*atview*) = let
  val+~PFOBJ (
    d2vw, s2e_ctx, s2e_elt, s2l
  ) = pfobj // end of [val]
  var ctxtopt: s2ctxtopt = gopt_none((*void*))
  val s2e_sel =
    s2exp_get_dlablst_context (loc0, s2e_elt, d3ls, ctxtopt)
  // end of [val]
in
//
case+ gopt_view (ctxtopt) of
| ~GOsome (ctxt) => let
//
    val () = d2var_inc_linval (d2vw)
//
    val s2e_out = s2exp_without (s2e_sel)
    val s2e_elt = s2ctxt_hrepl (ctxt, s2e_out)
    val s2e = s2exp_hrepl (s2e_ctx, s2e_elt)
    val () = d2var_set_type (d2vw, gopt_some (s2e))
//
    val s2ls = auxlabs (d3ls)
    val s2rt = s2exp_proj (s2l, s2e_elt, s2ls)
//
  in
    s2exp_at (s2e_sel, s2rt)
  end // end of [Some]
| ~GOnone ((*void*)) => let
    val (
    ) = auxerr_context
      (loc0, s2e_elt, d3ls) in s2exp_errexp(s2rt_view)
  end // end of [None]
//
end // end of [auxmain]

in (* in of [local] *)

implement
s2addr_viewat_deref
  (loc0, s2l, d3ls) = let
  val opt = pfobj_search_atview (s2l)
in
//
case+ opt of
| ~Some_vt(pfobj) =>
    auxmain(loc0, pfobj, d3ls)
| ~None_vt((*void*)) => let
    val () = auxerr_pfobj(loc0, s2l) in s2exp_errexp(s2rt_view)
  end (* end of [None_vt] *)
end // end of [s2addr_viewat_deref]

end // end of [local]

(* ****** ****** *)

fun s2addr_get_root (
  s2l: s2exp
, s2ls: &s2lablst? >> s2lablst
) : s2exp =
  case+ s2exp_node_view (s2l.s2exp_node ()) of
  | ~S2Eproj (
      s2l1, _(*type*), s2ls1
    ) => (s2ls := s2ls1; s2l1)
  | v => (s2exp_node_view_free (v); s2ls := glist_nil (); s2l)
// end of [s2addr_get_root]

fun eq_dlablst_slablst (
  d3ls: d3lablst, s2ls: s2lablst
) : bool =
  if glist_is_cons (d3ls) then (
    if glist_is_cons (s2ls) then let
      val d3l = glist_head (d3ls) and s2l = glist_head (s2ls)
      val d3ls = glist_tail (d3ls) and s2ls = glist_tail (s2ls)
    in
      case+ d3lab_node_view (d3l.d3lab_node ()) of
      | ~D3LABlab (l1) => (
        case+ s2lab_view (s2l) of
        | ~S2LABlab (l2) =>
            if l1 = l2 then eq_dlablst_slablst (d3ls, s2ls) else false
        | v => (s2lab_view_free (v); false)
        ) // end of [D3LABlab]
      | v => (d3lab_node_view_free (v); false)
    end else false // end of [then]
  ) else (
    if glist_is_cons (s2ls) then false else true
  ) // end of [else]
// end of [eq_dlablst_slablst]

(* ****** ****** *)

local

fun
auxerr_nonatview
(
  loc0: loc_t, s2at_new: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": viewat-restoration cannot be performed"
  val () = prerr ": proof of some atview is needed but one of the following type is given: "
  val () = (prerr "["; prerr_s2exp (s2at_new); prerr "]")
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_s2exp_set_viewat_atview (loc0, s2at_new))
end // end of [auxerr_nonatview]

fun
auxerr_nonwithout
(
  loc0: loc_t, s2e_old: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": viewat-restoration cannot be performed"
  val () = prerr ": the following type is expected to be a without-type but it is not: "
  val () = (prerr "["; prerr_s2exp (s2e_old); prerr "]")
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_s2exp_set_viewat_without (loc0, s2e_old))
end // end of [auxerr_nonwithout]

fun auxck_addreq
(
  loc0: loc_t, s2e1: s2exp, d3ls: d3lablst, s2e2: s2exp
) : void = let
//
val s2e2 = s2exp_hnfize (s2e2)
var s2ls: s2lablst // uninitized
val s2e2_rt = s2addr_get_root (s2e2, s2ls)
val rooteq = s2exp_syneq (s2e1, s2e2_rt)
val addreq = (
  if rooteq then eq_dlablst_slablst (d3ls, s2ls) else false
) : bool // end of [val]
//
in
//
if ~addreq then let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": viewat-restoration cannot be performed"
  val () = prerr ": mismatch of bef/aft locations of atviews:\n"
  val () = (prerr "bef: ["; prerr_s2exp (s2e1); prerr "]")
  val () = prerr_newline ((*void*))
  val () = (prerr "aft: ["; prerr_s2exp (s2e2); prerr "]")
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_s2addr_viewat_addreq (loc0, s2e1, d3ls, s2e2))
end // end of [if]
//
end // end of [auxck_addreq]

in (* in of [local] *)

implement
s2addr_set_viewat (
  loc0, s2l, d3ls, s2at_new
) = let
  val s2at_new = s2exp_hnfize (s2at_new)
in
//
case+
  s2exp_node_view (s2at_new.s2exp_node ()) of
| ~S2Eat (s2e1, s2e2) => let
    val s2e_old =
      s2addr_exch_type (loc0, s2l, d3ls, s2e1)
    val () =
      s2addr_set_viewat_check (loc0, s2l, d3ls, s2at_new, s2e_old, s2e1, s2e2)
    // end of [val]
  in
    // nothing
  end // end of [S2Eat]
| v => (s2exp_node_view_free (v); auxerr_nonatview (loc0, s2at_new))
//
end // end of [s2addr_set_viewat]

implement
s2addr_set_viewat_check (
  loc0, s2l, d3ls, s2at_new, s2e_old, s2e_new, s2l_new
) = let
val s2e_old = let
  val s2e_old =
    s2exp_hnfize (s2e_old) in
  case+ s2exp_node_view (s2e_old.s2exp_node ()) of
  | ~S2Ewithout (s2e) => s2e | v => let
      val () = s2exp_node_view_free (v)
      val () = auxerr_nonwithout (loc0, s2e_old) in s2exp_t0ype_err ()
    end // end of [_]
end : s2exp // end of [val]
(*
//
// HX-2012-05-10:
// skipping the check to keep a benign loophole
//
  val () = auxck_tszeq (loc0, s2e_old, s2e_new)
*)
  val () = auxck_addreq (loc0, s2l, d3ls, s2l_new)
in
  // exitloc (1)
end // end of [s2addr_set_viewat_check]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_nonptr
(
  loc0: loc_t, d3e: d3exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": the dynamic expression is expected to be a pointer."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_d3exp_nonderef (d3e))
end // end of [auxerr_nonptr]

fun auxerr1
(
  loc0: loc_t, d2v: d2var
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": the dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] is not mutable and thus [view@] cannot be applied."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_d2var_nonmut (loc0, d2v))
end // end of [auxerr1]

fun auxlablst1
(
  loc0: loc_t
, s2f0: s2hnf
, d3e_l: d3exp
, d3ls: d3lablst
) : s2exp = let
  val opt = un_s2exp_ptr_addr_type (s2f0)
in
//
case+ opt of
| ~Some_vt(s2l) =>
    s2addr_viewat_deref (loc0, s2l, d3ls)
| ~None_vt((*void*)) => let
    val () = auxerr_nonptr (loc0, d3e_l) in s2exp_t0ype_err ()
  end (* end of [None_vt] *)
//
end // end of [auxlablst1]

fun
d2exp_trup_viewat_main
  (d2e0: d2exp, d2e: d2exp): d3exp = let
//
val loc0 = d2e0.d2exp_loc ()
val d2lv = d2exp_lvalize (d2e)
//
in
//
case+ d2lval_view (d2lv) of
| ~D2LVALvar_mut
    (d2v, d2ls) => let
    val d3ls = d2lablst_trup (d2ls)
    val () = assertloc (gopt_is_some (d2var_get_addr (d2v))) // HX: [val-Some]
    val s2l = gopt_unsome (d2var_get_addr (d2v))
    val s2e = d2var_get_type_some (loc0, d2v)
    val d3e = d3exp_ptrofvar (loc0, s2e, d2v)
    val s2e_at = s2addr_viewat_deref (loc0, s2l, d3ls)
  in
    d3exp_viewat (loc0, s2e_at, d3e, d3ls)
  end // end of [D2LVALvar_mut]
| ~D2LVALderef
    (d2e, d2ls) => let
    val d3e = d2exp_trup (d2e)
    val () = d3exp_open_and_add (d3e)
    val d3ls = d2lablst_trup (d2ls)
    val s2e0 = d3exp_get_type (d3e)
    val s2f0 = s2exp2hnf (s2e0)
    val s2e_at = auxlablst1 (loc0, s2f0, d3e, d3ls)
  in
    d3exp_viewat (loc0, s2e_at, d3e, d3ls)
  end // end of [D2LVALderef]
//
| ~D2LVALvar_lin _ => let
    val () = prerr_error3_loc (loc0)
    val () = prerr ": [view@] operation cannot be applied"
    val () = prerr ": the dynamic expression is addressless."
    val () = prerr_newline ((*void*))
    val () = the_trans3errlst_add (trans3err_T3E_d2exp_addrless (d2e0))
  in
    d3exp_errexp (loc0)
  end // end of [D2LVALvar_lin]
//
| v (*rest-of-d2lval*) => let
    val () = d2lval_view_free (v)
    val () = prerr_error3_loc (loc0)
    val () = prerr ": [view@] operation cannot be applied: "
    val () = prerr_newline ((*void*))
    val () = the_trans3errlst_add (trans3err_T3E_d2exp_nonlval (d2e0))
  in
    d3exp_errexp (loc0)
  end // end of [_(*rest-of-d2lval*)]
//
end // end of [d2exp_trup_viewat_main]

in (* in of [local] *)

implement
d2exp_trup_viewat
  (d2e0) = let
//
// HX: [val-D2Eviewat (d2e) = d2e0.d2exp_node] (MatchError)
//
in
  case+ d2exp_node_view (d2e0.d2exp_node ()) of
  | ~D2Eviewat (d2e) => d2exp_trup_viewat_main (d2e0, d2e)
  | v => (
      d2exp_node_view_free (v); assertloc (false); d3exp_errexp (d2e0.d2exp_loc ())
    ) (* end of [rest-of-d2exp] *)
end // end of [d2exp_trup_viewat]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_nonptr
(
  loc0: loc_t, d3e: d3exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": the dynamic expression is expected to be a pointer."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_d3exp_nonderef (d3e))
end // end of [auxerr_nonptr]

fun auxlablst1
(
  loc0: loc_t
, s2f0: s2hnf
, d3e_l: d3exp
, d3ls: d3lablst
, d3e_r: d3exp
) : d3exp = let
//
val opt = un_s2exp_ptr_addr_type (s2f0)
//
in
//
case+ opt of
| ~Some_vt (s2l) => let
    val s2e_r = d3exp_get_type (d3e_r)
    val () =
      s2addr_set_viewat (loc0, s2l, d3ls, s2e_r)
    // end of [val]
  in
    d3exp_viewat_assgn (loc0, d3e_l, d3ls, d3e_r)
  end // end of [Some_vt]
| ~None_vt ((*void*)) => let
    val (
    ) = auxerr_nonptr (loc0, d3e_l) in d3exp_errexp_void (loc0)
  end // end of [None_vt]
end // end of [auxlablst1]

fun
d2exp_trup_viewat_assgn_main
  (d2e0: d2exp, d2e_l: d2exp, d2e_r: d2exp): d3exp = let
  val loc0 = d2e0.d2exp_loc ()
  val d2lv_l = d2exp_lvalize (d2e_l)
in
//
case+ d2lval_view (d2lv_l) of
| ~D2LVALvar_mut
    (d2v, d2ls) => let
    val d3ls = d2lablst_trup (d2ls)
    val () = assertloc (gopt_is_some (d2var_get_addr (d2v))) // HX: [val-Some]
    val s2l = gopt_unsome (d2var_get_addr (d2v))
    val d3e_r = d2exp_trup (d2e_r)
    val () = d3exp_open_and_add (d3e_r)
    val s2e_r = d3exp_get_type (d3e_r)
    val () = s2addr_set_viewat (loc0, s2l, d3ls, s2e_r)
    val loc = d2e_l.d2exp_loc ()
    val s2e_l = d2var_get_type_some (loc, d2v)
    val d3e_l = d3exp_ptrofvar (loc, s2e_l, d2v)
  in
    d3exp_viewat_assgn (loc0, d3e_l, d3ls, d3e_r)
  end // end of [D2LVALvar_mut]
| ~D2LVALderef
    (d2e_l, d2ls) => let
    val d3e_l = d2exp_trup (d2e_l)
    val () = d3exp_open_and_add (d3e_l)
    val d3ls = d2lablst_trup (d2ls)
    val d3e_r = d2exp_trup (d2e_r)
    val () = d3exp_open_and_add (d3e_r)
    val s2e0 = d3exp_get_type (d3e_l)
    val s2f0 = s2exp2hnf (s2e0)
  in
    auxlablst1 (loc0, s2f0, d3e_l, d3ls, d3e_r)
  end // end of [D2LVALderef]
//
| ~D2LVALvar_lin _ => let
    val loc = d2e_l.d2exp_loc ()
    val () = prerr_error3_loc (loc)
    val () = prerr ": [view@] operation cannot be applied"
    val () = prerr ": the dynamic expression is addressless."
    val () = prerr_newline ((*void*))
    val () = the_trans3errlst_add (trans3err_T3E_d2exp_addrless (d2e0))
  in
    d3exp_errexp_void (loc0)
  end // end of [D2LVALvar_lin]
//
| v => let
    val () = d2lval_view_free (v)
    val loc = d2e_l.d2exp_loc ()
    val () = prerr_error3_loc (loc)
    val () = prerr ": [view@] operation cannot be applied: "
    val () = prerr_newline ((*void*))
    val () = the_trans3errlst_add (trans3err_T3E_d2exp_nonlval (d2e0))
  in
    d3exp_errexp_void (loc0)
  end // end of [_]
//
end // end of [d2exp_trup_viewat_assgn_main]

in (* in of [local] *)

implement
d2exp_trup_viewat_assgn
  (d2e0) = let
//
// HX: [val-D2Eassgn (d2e_l, d2e_r) = d2e0.d2exp_node] and
// [val-D2Eviewat (d2e_l) = d2e_l.d2exp_node] (MatchError)
//
  fun
  aux_viewat (d2e: d2exp): d2exp =
    case+ d2exp_node_view (d2e.d2exp_node ()) of
    | ~D2Eviewat (d2e) => d2e
    | v => (d2exp_node_view_free (v); assertloc (false); d2e)
  // end of [aux_viewat]
in
  case+ d2exp_node_view (d2e0.d2exp_node ()) of
  | ~D2Eassgn (d2e_l, d2e_r) => let
      val d2e_l = aux_viewat (d2e_l)
    in
      d2exp_trup_viewat_assgn_main (d2e0, d2e_l, d2e_r)
    end // end of [D2Eassgn]
  | v => (
      d2exp_node_view_free (v); assertloc (false); d3exp_errexp (d2e0.d2exp_loc ())
    ) (* end of [rest-of-d2exp] *)
end // end of [d2exp_trup_viewat_assgn]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_view.dats] *)
