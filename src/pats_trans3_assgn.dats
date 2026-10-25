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
// Start Time: April, 2012
//
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_assgn.dats, see PORTING.md, "Level 3 translation, group 4")
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
#include "./pats_staexp2.hats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> () = prerr "pats_trans3_assgn"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

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
auxerr_proof
(
  loc0: loc_t, s2e: s2exp, d3ls: d3lablst, s2e_sel: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": a non-proof component is replaced of the type"
  val () = (prerr ": ["; prerr_s2exp (s2e_sel); prerr "]."; prerr_newline ())
in
  the_trans3errlst_add(trans3err_T3E_s2addr_assgn_deref_proof(loc0, s2e, d3ls))
end // end of [auxerr_proof]

fun
auxerr_linsel
(
  loc0: loc_t, s2e: s2exp, d3ls: d3lablst, s2e_sel: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": a linear component is abandoned of the type"
  val () = (prerr ": ["; prerr_s2exp (s2e_sel); prerr "]."; prerr_newline ())
in
  the_trans3errlst_add(trans3err_T3E_s2addr_assgn_deref_linsel(loc0, s2e, d3ls))
end // end of [auxerr_linsel]

fun
auxerr_context
(
  loc0: loc_t, s2e: s2exp, d3ls: d3lablst, s2e_sel: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": the type of the selected component cannot be changed"
  val () = (prerr ": ["; prerr_s2exp (s2e_sel); prerr "]."; prerr_newline ())
in
  the_trans3errlst_add (trans3err_T3E_s2addr_assgn_deref_context (loc0, s2e, d3ls))
end // end of [auxerr_context]

in (* in of [local] *)

extern
fun d2var_assgn_lin0
(
  loc0: loc_t, d2v: d2var, s2e_new: s2exp
) : void // end of [d2var_assgn_lin0]
extern
fun d2var_assgn_lin1
(
  loc0: loc_t, d2v: d2var, d3ls: d3lablst, s2e_new: s2exp
) : void // end of [d2var_assgn_lin1]
extern
fun d2var_assgn_lin01
(
  loc0: loc_t, d2v: d2var, d3ls: d3lablst, s2e_new: s2exp
) : void // end of [d2var_assgn_lin01]

implement
d2var_assgn_lin0
  (loc0, d2v, s2e_new) = let
  val opt = d2var_get_type (d2v)
in
//
case+ gopt_view (opt) of
//
| ~GOnone () =>
    d2var_set_type(d2v, gopt_some(s2e_new))
  // end of [None]
//
| ~GOsome (s2e) => let
//
    val
    islin = s2exp_is_lin(s2e)
//
    val d3ls = glist_nil() and s2e_sel = s2e
//
    val () =
    if islin
      then auxerr_linsel(loc0, s2e, d3ls, s2e_sel)
    // end of [if]
//
  in
    d2var_set_type(d2v, gopt_some(s2e_new))
  end // end of [Some]
//
end // end of [d2var_assgn_lin0]

implement
d2var_assgn_lin1
  (loc0, d2v, d3ls, s2e_new) = let
//
val s2e =
  d2var_get_type_some(loc0, d2v)
var ctxtopt: s2ctxtopt = gopt_none()
val s2e_sel =
  s2exp_get_dlablst_context(loc0, s2e, d3ls, ctxtopt)
// end of [val]
//
val
isprf =
s2exp_is_prf(s2e_sel)
val () = if ~( isprf )
  then auxerr_proof(loc0, s2e, d3ls, s2e_sel)
//
val
islin =
s2exp_is_lin(s2e_sel)
val () = if  ( islin )
  then auxerr_linsel(loc0, s2e, d3ls, s2e_sel)
//
val isctx = gopt_is_some (ctxtopt)
val () = if ~( isctx )
  then auxerr_context(loc0, s2e, d3ls, s2e_sel)
//
val s2e =
(
  case+ gopt_view (ctxtopt) of
  | ~GOsome (ctxt) => s2ctxt_hrepl(ctxt, s2e_new) | ~GOnone () => s2e
) : s2exp // end of [val]
//
val () = d2var_set_type (d2v, gopt_some(s2e))
//
in
  // nothing
end // end of [d2var_assgn_lin1]

implement
d2var_assgn_lin01
(
  loc0, d2v, d3ls, s2e_new
) = let
  val () = d2var_inc_linval(d2v)
in
  if glist_is_cons (d3ls)
    then d2var_assgn_lin1(loc0, d2v, d3ls, s2e_new)
    else d2var_assgn_lin0(loc0, d2v, s2e_new)
  // end of [if]
end // end of [d2var_assgn_lin01]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_pfobj
(
  loc0: loc_t, s2l: s2exp
) : void = let
//
  val () = prerr_error3_loc (loc0)
//
  val () =
  prerr (": assignment cannot be performed")
  val () =
  (
    prerr ": proof search for the view at [";
    prerr_s2exp (s2l); prerr "] failed."; prerr_newline ()
  ) (* prerrln! *)
in
  the_trans3errlst_add(trans3err_T3E_pfobj_search_none(loc0, s2l))
end // end of [auxerr_pfobj]

fun
auxerr_sharing
(
  loc0: loc_t, s2e_elt: s2exp, d3ls: d3lablst
) : void = let
//
  val () = prerr_error3_loc (loc0)
//
  val () =
  (
    prerr ": a boxed non-linear record is selected for field-update."; prerr_newline ()
  ) (* prerrln! *)
in
//
the_trans3errlst_add
  (trans3err_T3E_s2addr_assgn_deref_sharing(loc0, s2e_elt, d3ls))
//
end // end of [auxerr_sharing]

fun
auxerr_linsel
(
  loc0: loc_t
, s2e_elt: s2exp, d3ls: d3lablst, s2e_sel: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () =
  prerr (
    ": a linear component of the following type is abandoned: "
  ) (* prerr *)
  val () = (prerr "["; prerr_s2exp (s2e_sel); prerr "]."; prerr_newline ())
in
  the_trans3errlst_add
    (trans3err_T3E_s2addr_assgn_deref_linsel(loc0, s2e_elt, d3ls))
  // the_trans3errlst_add
end // end of [auxerr_linsel]

fun
auxck_tszeq
(
  loc0: loc_t
, s2e1: s2exp, s2e2: s2exp
) : void = let
//
val
tszeq = s2exp_tszeq(s2e1, s2e2)
//
in
//
if ~tszeq then let
//
  val () =
  prerr_error3_loc (loc0)
//
  val () = prerr ": assignment cannot be performed"
  val () = prerr ": mismatch of bef/aft type-sizes:\n"
  val () = (prerr "bef: ["; prerr_s2exp (s2e1); prerr "]")
  val () = prerr_newline ((*void*))
  val () = (prerr "aft: ["; prerr_s2exp (s2e2); prerr "]")
  val () = prerr_newline ((*void*))
//
in
  the_trans3errlst_add(trans3err_T3E_s2exp_assgn_tszeq(loc0, s2e1, s2e2))
end // end of [if] // end of [val]
//
end // end of [auxck_tszeq]

fun
auxmain
(
  loc0: loc_t
, pfobj: pfobj
, d3ls: d3lablst
, d3e_r: d3exp
, s2rt: &s2exp? >> s2exp
) : d3exp = let
val+~PFOBJ
(
  d2vw, s2e_ctx, s2e_elt, s2l
) = pfobj
//
val () = s2rt := s2e_elt
//
var linrest: int = 0 and sharing: int = 0
//
val @(s2e_sel, s2ps) =
  s2exp_get_dlablst_linrest_sharing
    (loc0, s2e_elt, d3ls, linrest, sharing)
  // s2exp_get_dlablst_linrest_sharing
val ((*void*)) =
  if sharing > 0
    then auxerr_sharing (loc0, s2e_elt, d3ls)
  // end of [if]
//
val s2e_sel = s2exp_hnfize (s2e_sel)
val ((*void*)) = trans3_env_add_proplst_vt (loc0, s2ps)
//
val islin = s2exp_is_lin (s2e_sel)
val ((*void*)) =
  if islin
    then auxerr_linsel (loc0, s2e_elt, d3ls, s2e_sel)
  // end of [if]
//
var ctxtopt: s2ctxtopt = gopt_none ()
val _(*s2e_sel*) =
  s2exp_get_dlablst_context (loc0, s2e_elt, d3ls, ctxtopt)
// end of [val]
in
//
case+ gopt_view (ctxtopt) of
//
| ~GOsome (ctxt) => let
//
    val () =
    d3exp_open_and_add(d3e_r)
    val
    s2e_sel2 = d3exp_get_type(d3e_r)
//
    val () = auxck_tszeq(loc0, s2e_sel, s2e_sel2)
//
    val () = d2var_inc_linval (d2vw)
//
    val
    s2e_elt = s2ctxt_hrepl(ctxt, s2e_sel2)
//
    val s2e0 = s2exp_hrepl(s2e_ctx, s2e_elt)
//
    val ((*void*)) = d2var_set_type (d2vw, gopt_some(s2e0))
//
  in
    d3e_r
  end (* end of [Some] *)
//
| ~GOnone ((*void*)) => d3exp_trdn(d3e_r, s2e_sel) // HX: assignment changes no type
//
end // end of [auxmain]

in (* in of [local] *)

implement
s2addr_assgn_deref
(
  loc0, s2l, d3ls, d3e_r, s2rt
) = let
//
val opt = pfobj_search_atview (s2l)
//
in
  case+ opt of
  | ~Some_vt (pfobj) =>
      auxmain(loc0, pfobj, d3ls, d3e_r, s2rt)
    // end of [Some_vt]
  | ~None_vt ((*void*)) => let
      val () =
        s2rt := s2exp_t0ype_err()
      // end of [val]
      val () = auxerr_pfobj(loc0, s2l) in d3e_r
    end // end of [None_vt]
end // end of [s2addr_assgn_deref]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_nonderef
  (d3e: d3exp): void = let
//
  val loc = d3e.d3exp_loc ()
//
  val () = prerr_error3_loc (loc)
//
  val () =
  (
    prerr ": the dynamic expression cannot be dereferenced."; prerr_newline ()
  ) (* prerrln! *)
//
in
  the_trans3errlst_add(trans3err_T3E_d3exp_nonderef(d3e))
end // end of [auxerr_nonderef]

fun
auxerr_refsharing
(
  loc0: loc_t, d3e_l: d3exp, d3ls: d3lablst
) : void = let
//
  val () = prerr_error3_loc (loc0)
//
  val () =
  (
    prerr ": a boxed non-linear record is selected for field-update."; prerr_newline ()
  ) (* prerrln! *)
  // end of [val]
//
in
  the_trans3errlst_add(trans3err_T3E_d3exp_assgn_deref_refsharing(d3e_l, d3ls))
end // end of [auxerr_refsharing]

fun
auxerr_reflinsel
(
  loc0: loc_t
, d3e_l: d3exp, d3ls: d3lablst, s2e_sel: s2exp
) : void = let
//
  val () = prerr_error3_loc (loc0)
//
  val () =
  prerr (
    ": a linear component of the following type is abandoned: "
  ) (* prerr *)
//
  val () = (prerr "["; prerr_s2exp (s2e_sel); prerr "]"; prerr_newline ())
//
in
  the_trans3errlst_add(trans3err_T3E_d3exp_assgn_deref_reflinsel(d3e_l, d3ls))
end // end of [auxerr_reflinsel]

fun aux1
(
  loc0: loc_t
, s2f0: s2hnf
, d3e_l: d3exp
, d3ls: d3lablst
, d3e_r: d3exp
) : d3exp = let
//
val opt =
  un_s2exp_ptr_addr_type(s2f0)
//
in
//
case+ opt of
//
| ~None_vt() =>
    aux2(loc0, s2f0, d3e_l, d3ls, d3e_r)
  // end of [None_vt]
//
| ~Some_vt(s2l) => let
    var
    s2rt: s2exp
    val
    d3e_r =
    s2addr_assgn_deref
      (loc0, s2l, d3ls, d3e_r, s2rt)
    // end of [val]
  in
    d3exp_assgn_ptr(loc0, d3e_l, s2rt, d3ls, d3e_r)
  end // end of [Some_vt]
//
end // end of [aux1]

and aux2
(
  loc0: loc_t
, s2f0: s2hnf
, d3e_l: d3exp
, d3ls: d3lablst
, d3e_r: d3exp
) : d3exp = let
  val opt = un_s2exp_ref_vt0ype_type (s2f0)
in
//
case+ opt of
| ~Some_vt (s2e) => let
    val s2rt = s2e // HX: selection root
//
    var linrest: int = 0
    and sharing: int = 0
//
    val @(s2e_sel, s2ps) =
    s2exp_get_dlablst_linrest_sharing
    (
      loc0, s2rt, d3ls, linrest, sharing
    ) (* s2exp_get_dlablst_linrest_sharing *)
//
    val () =
    if sharing > 0
      then auxerr_refsharing (loc0, d3e_l, d3ls)
    // end of [if]
//
    val s2e_sel = s2exp_hnfize (s2e_sel)
    val () = trans3_env_add_proplst_vt (loc0, s2ps)
    val islin = s2exp_is_lin (s2e_sel)
    val () =
    if islin
      then auxerr_reflinsel (loc0, d3e_l, d3ls, s2e_sel)
    // end of [if]
    val d3e_r = d3exp_trdn (d3e_r, s2e_sel)
    val _(*err*) = the_effenv_check_ref (loc0)
  in
    d3exp_assgn_ref (loc0, d3e_l, s2rt, d3ls, d3e_r)
  end // end of [Some_vt]
| ~None_vt () => aux3 (loc0, s2f0, d3e_l, d3ls, d3e_r)
//
end // end of [aux2]

and aux3
(
  loc0: loc_t
, s2f0: s2hnf
, d3e_l: d3exp
, d3ls: d3lablst
, d3e_r: d3exp
) : d3exp = let
  val () = auxerr_nonderef (d3e_l) in d3exp_errexp_void (loc0)
end // end of [aux3]

in (* in of [local] *)

implement
d2exp_trup_assgn_deref
  (loc0, d2e_l, d2ls, d2e_r) = let
val d3e_l = d2exp_trup (d2e_l)
val ((*void*)) = d3exp_open_and_add (d3e_l)
//
val d3ls = d2lablst_trup (d2ls)
val s2e0 = d3exp_get_type (d3e_l)
val s2f0 = s2exp2hnf_cast (s2e0)
//
val d3e_r = d2exp_trup (d2e_r)
val ((*void*)) = d3exp_open_and_add (d3e_r)
//
in
  aux1 (loc0, s2f0, d3e_l, d3ls, d3e_r)
end // end of [d2exp_trup_assgn_deref]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_wrt_if
  (loc0: loc_t): void = let
  val err = the_effenv_check_wrt (loc0)
in
//
if (
err > 0
) then (
  the_trans3errlst_add(trans3err_T3E_d2exp_trup_wrt(loc0))
) (* end of [then] *)
//
end // end of [auxerr_wrt_if]

fun
d2exp_trup_assgn_main
(
  d2e0: d2exp, d2e_l: d2exp, d2e_r: d2exp
) : d3exp = let
//
val loc0 = d2e0.d2exp_loc ()
val d2lv = d2exp_lvalize(d2e_l)
//
in
//
case+ d2lval_view (d2lv) of
//
| ~D2LVALvar_mut
    (d2v, d2ls) => let
//
    val () =
      assertloc (gopt_is_some (d2var_get_addr (d2v))) // HX: [val-Some(s2l)]
    val s2l = gopt_unsome (d2var_get_addr (d2v))
//
    val d3ls  = d2lablst_trup(d2ls)
//
    var s2rt  : s2exp
    val d3e_r = d2exp_trup(d2e_r)
    val ()    = d3exp_open_and_add(d3e_r)
    val d3e_r =
      s2addr_assgn_deref(loc0, s2l, d3ls, d3e_r, s2rt)
    // end of [val]
    val ((*void*)) =
      if d3exp_isnot_prf(d3e_r) then auxerr_wrt_if(loc0)
    // end of [val]
  in
    d3exp_assgn_var(loc0, d2v, s2rt, d3ls, d3e_r)
  end // end of [D2LVALvar_mut]
//
| ~D2LVALvar_lin
    (d2v, d2ls) => let
    val loc_l = d2e_l.d2exp_loc ()
    val d3ls  = d2lablst_trup (d2ls)
    val d3e_r = d2exp_trup (d2e_r)
    val ()    = d3exp_open_and_add (d3e_r)
    val s2e_r = d3exp_get_type (d3e_r)
    val opt   = d2var_get_type (d2v)
    val s2rt  =
    (
      case+ gopt_view (opt) of
      | ~GOsome (s2e) => s2e
      | ~GOnone ((*void*)) => s2exp_void_t0ype()
    ) : s2exp // end of [val]
    val () =
      d2var_assgn_lin01(loc_l, d2v, d3ls, s2e_r)
    // end of [val]
  in
    d3exp_assgn_var(loc0, d2v, s2rt, d3ls, d3e_r)
  end // end of [D2LVALvar_lin]
//
| ~D2LVALderef
    (d2e_l, d2ls) => let
    val () = auxerr_wrt_if(loc0)
  in
    d2exp_trup_assgn_deref(loc0, d2e_l, d2ls, d2e_r)
  end // end of [D2LVALd2ref]
//
| ~D2LVALviewat _ => d2exp_trup_viewat_assgn (d2e0)
//
| ~D2LVALarrsub
  (
    d2s, arr, loc_ind, ind // d2s: lrbrackets
  ) => let
//
    val d2es =
      glist_cons(arr, glist_append(ind, glist_sing(d2e_r)))
    // end of [val]
//
    val d2a0 =
      d2exparg_D2EXPARGdyn(~1(*npf*), loc0, d2es)
    val d3e_sub =
      d2exp_trup_applst_sym(d2e0, d2s, glist_sing(d2a0))
    // end of [val]
//
  in
    d3exp_trdn (d3e_sub, s2exp_void_t0ype((*void*)))
  end // [D2LVALarrsub]
//
| v (*rest-of-d2lv*) => let
    val () = d2lval_view_free (v)
    val opt = d2exp_get_seloverld (d2e_l)
  in
    case+ gopt_view (opt) of
    | ~GOsome (d2s) => let
        val _top = d2exp_top(loc0)
        val d2e0 = d2exp_get_seloverld_root (d2e_l)
        val d2a0 =
          d2exparg_D2EXPARGdyn (~1(*npf*), loc0, glist_pair(d2e0, d2e_r))
        val d3e_sel =
          d2exp_trup_applst_sym ((*d2e*)_top, d2s, glist_sing(d2a0))
        // end of [val]
      in
        d3exp_trdn (d3e_sel, s2exp_void_t0ype ())
      end // end of [Some]
    | ~GOnone ((*void*)) => let
        val loc_l = d2e_l.d2exp_loc ()
        val () = prerr_error3_loc (loc_l)
        val () = prerr ": a left-value is required but a non-left-value is given."
        val () = prerr_newline ((*void*))
        val () = the_trans3errlst_add (trans3err_T3E_d2exp_nonlval (d2e_l))
      in
        d3exp_errexp_void (loc0)
      end // end of [None]
  end // end of [rest-of-d2lv]
//
end // end of [d2exp_trup_assgn_main]

in (* in of [local] *)

implement
d2exp_trup_assgn
  (d2e0) = let
//
// HX: [val-D2Eassgn(d2e_l, d2e_r) = d2e0.d2exp_node] (MatchError)
//
in
  case+ d2exp_node_view (d2e0.d2exp_node ()) of
  | ~D2Eassgn (d2e_l, d2e_r) =>
      d2exp_trup_assgn_main (d2e0, d2e_l, d2e_r)
  | v => (
      d2exp_node_view_free (v); assertloc (false); d3exp_errexp (d2e0.d2exp_loc ())
    ) (* end of [rest-of-d2exp] *)
end // end of [d2exp_trup_assgn]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_assgn.dats] *)
