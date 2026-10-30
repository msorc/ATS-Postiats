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
// Start Time: March, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_dvar.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The local variables are a [d2varset_vt] (persistent, kept as a [ptr] in a cell) and a [glist] of frames in a cell
// (see [pats_trans3_env_dvar.spec]).
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

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload GLOB = "./pats_global.sats"
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_trans3_env_dvar"
//
(* ****** ****** *)

staload
LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"
staload "./pats_staexp2_sprint.sats"

(* ****** ****** *)

staload "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"
staload "./pats_trans3_env_dvar.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

#include "./pats_trans3_env_dvar_gen_dats.hats"

(* ****** ****** *)

implement
d2var_mutablize
  (loc0, d2v, s2e0, opt) = let
//
val s2e_elt =
  d2var_get_type_some (loc0, d2v)
//
val s2e_addr = let
  val opt = d2var_get_addr (d2v)
in
  case+ gopt_view (opt) of
  | ~GOsome (s2e_addr) =>
      s2e_addr // HX: [d2v] is introduced by vardec
  | ~GOnone () => let
      val sym = d2var_get_sym (d2v)
      val s2v_addr = s2var_make_id_srt (sym, s2rt_addr)
      val () = trans3_env_add_svar (s2v_addr) // adding svar
      val s2e_addr = s2exp_var (s2v_addr)
      val () = d2var_set_addr (d2v, gopt_some s2e_addr)
    in
      s2e_addr
    end // end of [None]
end // end of [let] // end of [val]
//
val s2e_ptr = s2exp_ptr_addr_type (s2e_addr)
val () = d2var_set_type (d2v, gopt_some (s2e_ptr))
val () = d2var_set_mastype (d2v, gopt_some (s2e_ptr))
val () = d2var_set_linval (d2v, ~1(*nonlin*))
//
// HX-2012-07: this is often needed in 'unsafe' programming style
//
val () = let
  val s2p = s2exp_agtz (s2e_addr) in trans3_env_hypadd_prop (loc0, s2p)
end // end of [val]
//
val d2vw =
  d2var_ptr_viewat_make (d2v, opt) // linval is properly set
val () = d2var_set_view (d2v, gopt_some d2vw) // [d2v] is mutable
//
val s2at0 = s2exp_at (s2e0, s2e_addr)
val () = d2var_set_mastype (d2vw, gopt_some (s2at0))
val s2at_elt = s2exp_at (s2e_elt, s2e_addr)
val () = d2var_set_type (d2vw, gopt_some (s2at_elt))
//
in
  d2vw
end // end of [d2var_mutablize]

implement
d2var_mutablize_none
  (loc0, d2v, s2e0) =
  d2var_mutablize (loc0, d2v, s2e0, gopt_none ())
// end of [d2var_mutablize_none]

(* ****** ****** *)

extern
fun the_d2varenv_push (): void

local

typedef ld2vsetlst = glist (ld2vsfrm)

val the_ld2vs =
  gcell_make<ptr> ($UN.castvwtp0{ptr} (d2varset_vt_nil ()))
// end of [val]

val the_ld2vss = gcell_make<ld2vsetlst> (glist_nil ())

// HX: the set in the cell is taken out and put back
fn
ld2vs_take (): d2varset_vt = $UN.castvwtp0{d2varset_vt} (gcell_get<ptr> (the_ld2vs))
fn
ld2vs_put (xs: d2varset_vt): void = gcell_set<ptr> (the_ld2vs, $UN.castvwtp0{ptr} (xs))

fn
frm_ismem (frm: ld2vsfrm, d2v: d2var): bool = let
  val xs = $UN.castvwtp0{d2varset_vt} (frm.ld2vsfrm_set ())
  val ans = d2varset_vt_ismem (xs, d2v)
  val _ = $UN.castvwtp0{ptr} (xs)
in
  ans
end // end of [frm_ismem]

fn
frm_listize (frm: ld2vsfrm): d2varlst_vt = let
  val xs = $UN.castvwtp0{d2varset_vt} (frm.ld2vsfrm_set ())
  val ans = d2varset_vt_listize (xs)
  val _ = $UN.castvwtp0{ptr} (xs)
in
  ans
end // end of [frm_listize]

in // in of [local]

implement
the_d2varenv_get_top () = let
  val p = ld2vs_take ()
  val res = d2varset_vt_listize (p)
  val () = ld2vs_put (p)
in
  res
end // end of [the_d2varenv_get_top]

implement
the_d2varenv_get_llamd2vs () = let
  val xss = gcell_get<ld2vsetlst> (the_ld2vss)
in
  if glist_is_cons (xss) then let
    val frm = glist_head (xss)
  in
    if frm.ld2vsfrm_knd () = 1 then let
      val d2vs = frm.ld2vsfrm_d2vs ()
      val () = set_ld2vsfrm_d2vs (frm, glist_nil ())
    in
      glist_listize (d2vs)
    end else list_vt_nil () // end of [LD2VSset]
  end else list_vt_nil () // end of [LD2VSnil]
end // end of [the_d2varenv_get_llamd2vs]

(* ****** ****** *)

implement
the_d2varenv_add_dvar
  (d2v) = let
  val p = ld2vs_take ()
  val p = d2varset_vt_add (p, d2v)
  val opt = d2var_get_view (d2v)
  val p = (
    case+ gopt_view (opt) of
    | ~GOsome (d2vw) => d2varset_vt_add (p, d2vw)
    | ~GOnone () => p
  ) : d2varset_vt
in
  ld2vs_put (p)
end // end of [the_d2varenv_add]

fun
add_dvarlst_loop (
  set: d2varset_vt, d2vs: d2varlst
) : d2varset_vt =
  case+ glist_view (d2vs) of
  | ~GLcons (d2v, d2vs) => let
      val set = d2varset_vt_add (set, d2v) in add_dvarlst_loop (set, d2vs)
    end // end of [list_cons]
  | ~GLnil () => set
// end of [add_dvarlst_loop]

implement
the_d2varenv_add_dvarlst
  (d2vs) = ld2vs_put (add_dvarlst_loop (ld2vs_take (), d2vs))
// end of [the_d2varenv_addlst]

implement
the_d2varenv_add_dvaropt
  (opt) = (
  case+ gopt_view (opt) of
  | ~GOsome (d2v) => the_d2varenv_add_dvar (d2v)
  | ~GOnone () => ()
) // end of [the_d2varenv_add_dvaropt]

(* ****** ****** *)

fun
pop_loop (
  ld2vss: ld2vsetlst
) : ld2vsetlst =
  if glist_is_cons (ld2vss) then let
    val frm = glist_head (ld2vss)
    val ld2vss = glist_tail (ld2vss)
  in
    if frm.ld2vsfrm_knd () = 0 then let
      val () = ld2vs_put ($UN.castvwtp0{d2varset_vt} (frm.ld2vsfrm_set ())) in ld2vss
    end else pop_loop (ld2vss)
  end else let
    val () = ld2vs_put (d2varset_vt_nil ()) in glist_nil ()
  end // end of [if]
// end of [pop_loop]

implement
the_d2varenv_pop
   ((*none*)) = let
   val () = d2varset_vt_free (ld2vs_take ())
in
   gcell_set<ld2vsetlst> (the_ld2vss, pop_loop (gcell_get<ld2vsetlst> (the_ld2vss)))
end // end of [the_d2varenv_pop]

(* ****** ****** *)

implement
the_d2varenv_push () = let
  val d2vs = ld2vs_take ()
  val () = ld2vs_put (d2varset_vt_nil ())
  val frm = ld2vsfrm_new (0, 0, $UN.castvwtp0{ptr} (d2vs), glist_nil ())
in
  gcell_set<ld2vsetlst> (the_ld2vss, glist_cons (frm, gcell_get<ld2vsetlst> (the_ld2vss)))
end // end of [the_d2varenv_push]

implement
the_d2varenv_push_lam (lin) = let
  val () = the_d2varenv_push ()
  val frm = ld2vsfrm_new (1, lin, the_null_ptr, glist_nil ())
in
  gcell_set<ld2vsetlst> (the_ld2vss, glist_cons (frm, gcell_get<ld2vsetlst> (the_ld2vss)))
end // end of [the_d2varenv_push_lam]

implement
the_d2varenv_push_let () = the_d2varenv_push ()

// HX: preventing
implement // linear resources from being accessed
the_d2varenv_push_try () = the_d2varenv_push_lam (0)

(* ****** ****** *)

fun
is_llamlocal_loop (
  ld2vss: ld2vsetlst, d2v0: d2var
) : bool =
  if glist_is_cons (ld2vss) then let
    val frm = glist_head (ld2vss)
    val ld2vss1 = glist_tail (ld2vss)
  in
    if frm.ld2vsfrm_knd () = 1 then let
      val lin = frm.ld2vsfrm_lin ()
    in
      if lin > 0 then let
        val () = set_ld2vsfrm_d2vs (frm, glist_cons (d2v0, frm.ld2vsfrm_d2vs ()))
      in
        is_llamlocal_loop (ld2vss1, d2v0)
      end else false // end of [llam]
    end else let
      val ans = frm_ismem (frm, d2v0)
    in
      if ans then true else is_llamlocal_loop (ld2vss1, d2v0)
    end // end of [LD2VSset]
  end else false // end of [LD2VSnil]
// end of [is_llamlocal_loop]

implement
the_d2varenv_d2var_is_llamlocal
  (d2v0) = let // [d2v0] is linear
//
val ans = let
  val p = ld2vs_take ()
  val ans = d2varset_vt_ismem (p, d2v0)
  val () = ld2vs_put (p)
in
  ans
end // end of [val]
//
in
//
if ans then true else is_llamlocal_loop (gcell_get<ld2vsetlst> (the_ld2vss), d2v0)
//
end // end of [the_d2varenv_d2var_is_llamlocal]

(* ****** ****** *)

fun
save_aux (
  d2v: d2var
, res: &lstbefitmlst >> _
) : void = let
  val linval = d2var_get_linval (d2v)
in
  if linval >= 0 then let
    val x = lstbefitm_make (d2v, linval) in res := glist_cons (x, res)
  end else () // end of [if]
end // end of [save_aux]

fun
save_auxlst (
  d2vs: d2varlst_vt
, res: &lstbefitmlst >> _
) : void = (
  case+ d2vs of
  | ~list_vt_cons (d2v, d2vs) => let
      val () = save_aux (d2v, res) in save_auxlst (d2vs, res)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
) (* end of [auxlst] *)

fun
save_auxsetlst (
  xs: ld2vsetlst, res: &lstbefitmlst >> _
) : void = let
in
//
if glist_is_cons (xs) then let
  val frm = glist_head (xs)
  val xs1 = glist_tail (xs)
in
  if frm.ld2vsfrm_knd () = 0 then {
    val () = save_auxlst (frm_listize (frm), res)
    val () = save_auxsetlst (xs1, res)
  } else (
    if frm.ld2vsfrm_lin () > 0 then save_auxsetlst (xs1, res) else ()
  ) // end of [LD2VSlam]
end else () // end of [nil]
//
end // end of [save_auxsetlst]

implement
the_d2varenv_save_lstbefitmlst
  () = let
//
var res: lstbefitmlst = glist_nil ()
val () = let
  val p = ld2vs_take ()
  val d2vs = d2varset_vt_listize (p)
  val () = ld2vs_put (p)
in
  save_auxlst (d2vs, res)
end // end of [val]
val () = save_auxsetlst (gcell_get<ld2vsetlst> (the_ld2vss), res)
//
in
  res
end // end of [the_d2varset_save_lstbefitmlst]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

extern
fun the_d2varenv_add_labp3atlst (xs: labp3atlst): void

implement
the_d2varenv_add_p3at
  (p3t) = let
//
val opt = p3at_get_dvaropt (p3t)
val () = the_d2varenv_add_dvaropt (opt)
//
in
//
case+ p3at_node_view (p3t.p3at_node ()) of
//
| ~P3Tany (d2v) => the_d2varenv_add_dvar (d2v)
| ~P3Tvar (d2v) => the_d2varenv_add_dvar (d2v)
//
| ~P3Tcon (
    _(*pck*), d2c, npf, p3ts
  ) => the_d2varenv_add_p3atlst (p3ts)
//
| ~P3Tann (p3t, s2e) => the_d2varenv_add_p3at (p3t)
//
| ~P3Tint _ => ()
| ~P3Tintrep _ => ()
//
| ~P3Tbool _ => ()
| ~P3Tchar _ => ()
| ~P3Tfloat _ => ()
| ~P3Tstring _ => ()
//
| ~P3Ti0nt _ => ()
| ~P3Tf0loat _ => ()
//
| ~P3Tempty _ => ()
//
| ~P3Trec (
    knd, npf, pck, lp3ts
  ) =>
    the_d2varenv_add_labp3atlst(lp3ts)
  // end of [P3Trec]
| ~P3Tlst (
    lin, _elt, p3ts
  ) => the_d2varenv_add_p3atlst( p3ts )
//
| ~P3Trefas(d2v, p3t) => {
    val () = the_d2varenv_add_dvar(d2v)
    val () = the_d2varenv_add_p3at(p3t)
  } // end of [P3Trefas]
//
| ~P3Texist
    (s2vs, p3t) => the_d2varenv_add_p3at(p3t)
  // P3Texist
//
| ~P3Tvbox (d2v) => the_d2varenv_add_dvar(d2v)
//
| ~P3Terrpat ((*void*)) => ((*ignored*))
//
end // end of [the_d2varenv_add_p3at]

implement
the_d2varenv_add_p3atlst
  (p3ts) =
  case+ glist_view (p3ts) of
  | ~GLcons (p3t, p3ts) => (the_d2varenv_add_p3at (p3t); the_d2varenv_add_p3atlst (p3ts))
  | ~GLnil () => ()
// end of [the_d2varenv_add_p3atlst]

implement
the_d2varenv_add_labp3atlst
  (xs) = loop (xs) where {
  fun loop (
    xs: labp3atlst
  ) : void =
    case+ glist_view (xs) of
    | ~GLnil () => ()
    | ~GLcons
        (x, xs) => loop(xs) where
      {
        val p3t = x.labp3at_elt ()
        val () = the_d2varenv_add_p3at (p3t)
      } (* end of [list_cons] *)
  // end of [loop]
} // end of [the_d2varenv_add_labp3atlst]

(* ****** ****** *)
//
extern
fun
d2vfin_check
  (loc0: loc_t, d2v: d2var): void
//
(* ****** ****** *)

//
// HX-2026-10: the message (after the location) for a linear variable
// that is not consumed: [d2v] still has the type [s2e]
//
fn
prerr_d2var_unconsumed
(
  d2v: d2var, s2e: s2exp
) : void =
(
if $GLOB.the_LEGACYERRORS_get () > 0 then {
  val () = prerr ": the linear dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] needs to be consumed but it is preserved with the type ["
  val () = prerr_s2exp (s2e)
  val () = prerr "] instead."
  val () = prerr_newline ()
} else {
  val () = sprint_reset ()
  val () = prerr ": the linear variable "
  val () = prerr_d2var_s (d2v)
  val () = prerr " of type "
  val () = prerr_s2exp_s (s2e)
  val () = prerr " is not consumed at the end of its scope"
  val () = prerr_newline ()
  val () = prerr "  hint: consume it (free it, return it or pass it on),"
  val () = prerr " or declare the parameter as !T"
  val () = prerr_newline ()
} (* end of [if] *)
) (* end of [prerr_d2var_unconsumed] *)

fun
d2vfin_check_auxerr1
(
  loc0: loc_t
, d2v: d2var, s2e1: s2exp, s2e2: s2exp
) : void = {
  val () = prerr_error3_loc (loc0)
  val () =
  if $GLOB.the_LEGACYERRORS_get () > 0 then {
    val () = prerr ": the linear dynamic variable ["
    val () = prerr_d2var (d2v)
    val () = prerr "] is preserved but with an incompatible type."
  } else { // HX-2026-10: the surface syntax (pats_staexp2_sprint)
    val () = sprint_reset ()
    val () = prerr ": the linear variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " does not have the required type at the end of its scope"
  } (* end of [if] *)
  val () = prerr_newline ()
  val () = prerr_the_staerrlst ()
  val () =  the_trans3errlst_add (trans3err_T3E_d2var_fin_some_some (loc0, d2v))
} (* end of [d2vfin_check_auxerr1] *)

fun
d2vfin_check_auxerr2
(
  loc0: loc_t, d2v: d2var, s2e: s2exp
) : void = {
  val () = prerr_error3_loc (loc0)
  val () = prerr_d2var_unconsumed (d2v, s2e)
  val () = the_trans3errlst_add (trans3err_T3E_d2var_fin_none_some (loc0, d2v))
} (* end of [d2vfin_check_auxerr2] *)

fun
d2vfin_check_some
(
  loc0: loc_t, d2v: d2var, s2e: s2exp
) : void = let
//
val d2vfin = d2var_get_finknd (d2v)
//
in
//
case+ d2vfin_view (d2vfin) of
//
| ~D2VFINnone() => let
    val islin = s2exp_is_lin2 (s2e)
    val () = if islin then d2vfin_check_auxerr2 (loc0, d2v, s2e)
    val linval = d2var_get_linval (d2v)
  in
    if linval >= 0 then d2var_set_type(d2v, gopt_none ())
  end // end of [D2VFINnone]
//
| ~D2VFINsome
    (s2e_fin) => let
    val () = trans3_env_push()
    val err = $SOL.s2exp_tyleq_solve (loc0, s2e, s2e_fin)
    val () = if err > 0 then d2vfin_check_auxerr1 (loc0, d2v, s2e, s2e_fin)
    val knd = c3nstrkind_C3TKsome_fin (d2v, s2e_fin, s2e)
    val ((*void*)) = trans3_env_pop_and_add (loc0, knd)
  in
    d2var_set_type (d2v, gopt_some s2e_fin)
  end // end of [D2VFINsome]
//
| ~D2VFINsome_lvar
    (s2e_fin) => let
//
    val () = trans3_env_push()
//
    val s2e = (
      case+
      s2exp_node_view (s2e.s2exp_node ())
      of // case+
      | ~S2Eat(s2at, s2l) =>
        let
          val isnonlin = s2exp_is_nonlin(s2at)
        in
          if isnonlin then s2exp_at(s2exp_topize_0(s2at), s2l) else s2e
        end // end of [S2Eat]
      | v (* non-S2Eat *) => (s2exp_node_view_free (v); s2e) // this should cause a failure later on!

    ) : s2exp // end of [val]
//
    val err =
    $SOL.s2exp_tyleq_solve(loc0, s2e, s2e_fin)
    val () =
    if err > 0 then d2vfin_check_auxerr1(loc0, d2v, s2e, s2e_fin)
//
    val knd = c3nstrkind_C3TKsome_lvar(d2v, s2e_fin, s2e)
    val ((*void*)) = trans3_env_pop_and_add(loc0, knd)
//
  in
    d2var_set_type (d2v, gopt_some (s2e_fin))
  end // end of [D2VFINsome_lvar]
//
| ~D2VFINsome_vbox
    (s2e_box) => let
    val () = trans3_env_push ()
    val err =
    $SOL.s2exp_tyleq_solve (loc0, s2e, s2e_box)
    val () = if err > 0 then d2vfin_check_auxerr1 (loc0, d2v, s2e, s2e_box)
    val knd = c3nstrkind_C3TKsome_vbox (d2v, s2e_box, s2e)
    val ((*void*)) = trans3_env_pop_and_add (loc0, knd)
  in
    d2var_set_type (d2v, gopt_some (s2e_box))
  end // end of [D2VFINsome_vbox]
//
| ~D2VFINdone _ => () // HX: handled by [funarg_d2vfin_check]
// end of [case]
//
end // end of [d2vfin_check_some]

fun
d2vfin_check_none_auxerr
(
  loc0: loc_t, d2v: d2var
) : void = {
  val () = prerr_error3_loc (loc0)
  val () =
  if $GLOB.the_LEGACYERRORS_get () > 0 then {
    val () = prerr ": the linear dynamic variable ["
    val () = prerr_d2var (d2v)
    val () = prerr "] needs to be preserved but it is consumed instead."
  } else { // HX-2026-10: the surface syntax (pats_staexp2_sprint)
    val () = sprint_reset ()
    val () = prerr ": the linear variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " must still be available here, but it was consumed"
  } (* end of [if] *)
  val () = prerr_newline ()
} (* end of [d2vfin_check_none_auxerr] *)

fun
d2vfin_check_none
(
  loc0: loc_t, d2v: d2var
) : void = let
//
val d2vfin = d2var_get_finknd (d2v)
//
in
//
case+ d2vfin_view (d2vfin) of
| ~D2VFINnone () => ()
| ~D2VFINsome _ => let
    val () = d2vfin_check_none_auxerr (loc0, d2v)
  in
    the_trans3errlst_add (trans3err_T3E_d2var_fin_none_some (loc0, d2v))
  end // end of [D2VFINsome]
| ~D2VFINsome_lvar _ => let
    val () = d2vfin_check_none_auxerr (loc0, d2v)
  in
    the_trans3errlst_add (trans3err_T3E_d2var_fin_none_some (loc0, d2v))
  end // end of [D2VFINsome_lvar]
| ~D2VFINsome_vbox _ => let
    val () = d2vfin_check_none_auxerr (loc0, d2v)
  in
    the_trans3errlst_add (trans3err_T3E_d2var_fin_none_some (loc0, d2v))
  end // end of [D2VFINsome_vbox]
| ~D2VFINdone _ => () // HX: handled by [funarg_d2vfin_check]
//
end // end of [d2vfin_check_none]

(* ****** ****** *)
//
// HX-2026-10: fold on demand: the hook is installed by pats_trans3_fldfrat.dats
//
local
//
val the_autofold_hook = gcell_make<ptr> (the_null_ptr)
//
val the_autofold_lval_hook = gcell_make<ptr> (the_null_ptr)
//
in (* in-of-local *)
//
implement
the_d2varenv_set_autofold_hook
  (f) = gcell_set<ptr> (the_autofold_hook, $UN.cast{ptr}(f))
//
implement
the_d2varenv_autofold
  (knd, loc0, d2v, s2e) = let
  val p = gcell_get<ptr> (the_autofold_hook)
in
  if ptr_is_null (p) then 0 else let
    val f = $UN.cast{d2varenv_autofold_hook}(p) in f (knd, loc0, d2v, s2e)
  end // end of [if]
end // end of [the_d2varenv_autofold]
//
implement
the_d2varenv_set_autofold_lval_hook
  (f) = gcell_set<ptr> (the_autofold_lval_hook, $UN.cast{ptr}(f))
//
implement
the_d2varenv_autofold_lval
  (knd, loc0, d3e, s2e) = let
  val p = gcell_get<ptr> (the_autofold_lval_hook)
in
  if ptr_is_null (p) then 0 else let
    val f = $UN.cast{d3expenv_autofold_hook}(p) in f (knd, loc0, d3e, s2e)
  end // end of [if]
end // end of [the_d2varenv_autofold_lval]
//
fun
the_d2varenv_autofold_on (): bool =
  ptr_isnot_null (gcell_get<ptr> (the_autofold_hook))
//
fun
d2varenv_autofold_loop
(
  knd: int, loc0: loc_t, d2vs: d2varlst_vt
) : void =
  case+ d2vs of
  | ~list_vt_cons (d2v, d2vs) => let
      val _ = the_d2varenv_autofold (knd, loc0, d2v, s2exp_t0ype_err ())
    in
      d2varenv_autofold_loop (knd, loc0, d2vs)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
//
fun
the_d2varenv_autofold_top
  (knd: int, loc0: loc_t): void =
  if the_d2varenv_autofold_on () then
    d2varenv_autofold_loop (knd, loc0, the_d2varenv_get_top ())
  // end of [if]
//
// HX: @(the result of the try, the number of errors)
fun
d2vfin_check_autofold
  (loc0: loc_t, d2v: d2var): @(int, int) =
  if the_d2varenv_autofold_on () then let
    val ans = the_d2varenv_autofold (1, loc0, d2v, s2exp_t0ype_err ())
  in
    @(ans, the_trans3errlst_count ())
  end else @(0, 0) // end of [if]
//
fun
d2vfin_check_autofold_hint
  (loc0: loc_t, d2v: d2var, ans: int, nerr: int): void =
  if the_d2varenv_autofold_on () then (
    if the_trans3errlst_count () > nerr then {
      // HX: 5: the try of [d2v] has failed; 2: [d2v] may be the view of a field
      val knd = (if ans = 2 then 5 else 2): int
      val _ = the_d2varenv_autofold (knd, loc0, d2v, s2exp_t0ype_err ())
    } // end of [if]
  ) // end of [if]
//
end // end of [local]

(* ****** ****** *)

implement
d2vfin_check (loc0, d2v) = let
//
// HX-2026-10: fold on demand
val @(ans, nerr) = d2vfin_check_autofold (loc0, d2v)
//
val opt = d2var_get_type (d2v)
//
val () = (
case+ gopt_view (opt) of
| ~GOsome (s2e) => d2vfin_check_some (loc0, d2v, s2e)
| ~GOnone () => d2vfin_check_none (loc0, d2v)
) : void // end of [val]
//
in
  d2vfin_check_autofold_hint (loc0, d2v, ans, nerr)
end // end of [d2vfin_check]

fun
the_d2varenv_check_loop
(
  loc0: loc_t, d2vs: d2varlst_vt
) : void =
  case+ d2vs of
  | ~list_vt_cons (d2v, d2vs) => let
      val () = d2vfin_check (loc0, d2v) in the_d2varenv_check_loop (loc0, d2vs)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
(* end of [loop] *)

implement
the_d2varenv_check (loc0) = let
  // HX-2026-10: fold on demand: the unfolded variables whose fields end here
  val () = the_d2varenv_autofold_top (0(*fold*), loc0)
  val () = the_d2varenv_check_loop (loc0, the_d2varenv_get_top ())
in
  the_d2varenv_autofold_top (4(*forget*), loc0)
end // end of [the_d2varenv_check]

(* ****** ****** *)

fun
check_llam_aux
(
  loc0: loc_t, d2v: d2var
) : void = let
  val opt = d2var_get_type (d2v)
in
  case+ gopt_view (opt) of
  | ~GOsome (s2e) => let
      val islin = s2exp_is_lin (s2e)
    in
      if islin then let
        val () = prerr_error3_loc (loc0)
        val () = prerr_d2var_unconsumed (d2v, s2e)
        val () = assertloc (false)
      in
        $extfcall (void, "exit", 1)
      end else
        d2var_set_type (d2v, gopt_none ())
      // end of [if]
    end // end of [Some]
  | ~GOnone () => ()
end // end of [check_llam_aux]

fun
check_llam_auxlst
(
  loc0: loc_t, d2vs: d2varlst_vt
) : void =
(
  case+ d2vs of
  | ~list_vt_cons
      (d2v, d2vs) => let
      val () = check_llam_aux (loc0, d2v)
      val () = check_llam_auxlst (loc0, d2vs)
    in
      // nothing
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
) (* end of [auxlst] *)

implement
the_d2varenv_check_llam
  (loc0) = check_llam_auxlst (loc0, the_d2varenv_get_llamd2vs ())
// end of [the_d2varenv_check_llam]

(* ****** ****** *)

fun
d2vfin_checked
  (d2v: d2var): void = let
  val d2vfin = d2var_get_finknd (d2v)
in
//
if d2vfin_is_D2VFINdone (d2vfin)
  then () else d2var_set_finknd (d2v, d2vfin_D2VFINdone (d2vfin))
//
end // end of [d2vfin_checked]

fun
funarg_d2vfin_check_auxvar
(
  loc0: loc_t, d2v: d2var
) : void = let
val d2v = let
  val opt = d2var_get_view (d2v) in
  case+ gopt_view (opt) of ~GOsome (d2v) => d2v | ~GOnone () => d2v
end : d2var // end of [val]
//
val () = d2vfin_check (loc0, d2v)
//
in
  d2vfin_checked (d2v) // HX: indicating that [d2vfin_check] should skip it
end // end of [auxvar]
//
fun
funarg_d2vfin_check_auxpatlst
(
  loc0: loc_t, p3ts: p3atlst
) : void = let
in
//
case+ glist_view (p3ts) of
| ~GLcons
    (p3t, p3ts) => let
    val () = (
      case+ p3at_node_view (p3t.p3at_node ()) of
      | ~P3Tvar (d2v) => funarg_d2vfin_check_auxvar (loc0, d2v)
      | ~P3Trefas (d2v, _) => funarg_d2vfin_check_auxvar (loc0, d2v)
      | v => p3at_node_view_free (v)
    ) : void // end of [val]
  in
    funarg_d2vfin_check_auxpatlst (loc0, p3ts)
  end // end of [list_cons]
| ~GLnil () => ()
//
end // end of [auxpatlst]

implement
funarg_d2vfin_check (loc0) = let
//
val opt = the_lamlpenv_get_funarg ()
//
in
//
case+ opt of
| ~Some_vt p3ts => let
    val () = funarg_d2vfin_check_auxpatlst (loc0, p3ts)
  in
    // nothing
  end // end of [Some_vt]
//
| ~None_vt () => let
    val () = prerr_interror_loc (loc0)
    val () = prerr ": funarg_d2vfin_check: there is no funarg."
    val () = prerr_newline ()
  in
    assertloc (false)
  end // end of [None_vt]
end (* end of [funarg_d2vfin_check] *)

(* ****** ****** *)

fun
wthtype_p3at_get_var
  (p3t: p3at): d2var = let
in
//
case+ p3at_node_view (p3t.p3at_node ()) of
| ~P3Tvar (d2v) => d2v
| ~P3Trefas (d2v, _) => d2v
| v => let
    val () = p3at_node_view_free (v)
    val () =
      prerr_interror_loc (p3t.p3at_loc ())
    // end of [val]
    val () = prerr ": s2exp_wthtype_instantiate"
    val () = (prerr ": p2at_get_var: the pattern is expected to be a variable."; prerr_newline ())
    val ((*exit*)) = assertloc (false)
  in
    $ERR.abort_interr<d2var>((*deadcode*))
  end // end of [_]
//
end // end of [p3at_get_var]
//
fn
wthtype_d2vfin_unchecked
  (d2v: d2var): void = let
  val d2vfin = d2var_get_finknd (d2v)
in
//
case+ d2vfin_view (d2vfin) of
| ~D2VFINdone(d2vfin) => d2var_set_finknd(d2v, d2vfin)
| v (*non-D2VFINdone*) => d2vfin_view_free (v) // HX: is this deadcode?
//
end // end of [d2vfin_unchecked]
//
fn
wthtype_aux_invar
(
  refknd: int, p3t: p3at, s2e: s2exp
) : void = let
//
val d2v = wthtype_p3at_get_var (p3t)
//
in
//
if refknd = 0 then wthtype_d2vfin_unchecked (d2v)
else let
    val-~GOsome (d2v_view) = gopt_view (d2var_get_view (d2v))
  in wthtype_d2vfin_unchecked (d2v_view) end // end of [_]
//
end // end of [aux_invar]
//
fn
wthtype_aux_trans
(
  refknd: int, p3t: p3at, s2e: s2exp
) : void = let
//
val d2v = wthtype_p3at_get_var (p3t)
//
in
//
if refknd = 0 then
    d2var_set_finknd (d2v, d2vfin_D2VFINsome s2e)
else let
    val-~GOsome (d2v_view) = gopt_view (d2var_get_view (d2v))
    val-~GOsome (s2e_addr) = gopt_view (d2var_get_addr (d2v))
    val s2e_at = s2exp_at (s2e, s2e_addr)
  in
    d2var_set_finknd (d2v_view, d2vfin_D2VFINsome (s2e_at))
  end // end of [_]
//
end // end of [aux_trans]
//
fun
wthtype_auxlst
(
  loc0: loc_t
, p3ts: p3atlst, wths2es: wths2explst
) : void = let
in
//
case+ wths2explst_view (wths2es) of
| ~WTHS2EXPLSTcons_invar
    (refknd, s2e, wths2es) => let
    val-~GLcons (p3t, p3ts) = glist_view (p3ts)
    val () = wthtype_aux_invar (refknd, p3t, s2e)
  in
    wthtype_auxlst (loc0, p3ts, wths2es)
  end // end of [WTHS2EXPLSTcons_invar]
| ~WTHS2EXPLSTcons_trans
    (refknd, s2e, wths2es) => let
    val-~GLcons (p3t, p3ts) = glist_view (p3ts)
    val () = wthtype_aux_trans (refknd, p3t, s2e)
  in
    wthtype_auxlst (loc0, p3ts, wths2es)
  end // end of [WTHS2EXPLSTcons_trans]
| ~WTHS2EXPLSTcons_none
    (wths2es) => let
    val-~GLcons (p3t, p3ts) = glist_view (p3ts)
  in
    wthtype_auxlst (loc0, p3ts, wths2es)
  end // end of [WTHS2EXPLSTcons_none]
| ~WTHS2EXPLSTnil () => ()
//
end // end of [auxlst]

implement
s2exp_wthtype_instantiate (loc0, s2e0) = let
//
var err: int = 0
val @(s2e, s2ps) =
  s2exp_exi_instantiate_all (s2e0, loc0, err)
val () = trans3_env_add_proplst_vt (loc0, s2ps)
//
in
//
case+ s2exp_node_view (s2e.s2exp_node ()) of
//
| ~S2Ewthtype
    (s2e, wths2es) => let
    val-~Some_vt (p3ts) = opt where {
      val opt = the_lamlpenv_get_funarg ()
    } // end of [val]
    val () = wthtype_auxlst (loc0, p3ts, wths2es)
  in
    s2e
  end // end of [S2Ewthtype]
//
| v (*non-withtype*) => (s2exp_node_view_free (v); s2e)
//
end // end of [s2exp_wthtype_instantiate]

(* ****** ****** *)

(* end of [pats_trans3_env_dvar.dats] *)
