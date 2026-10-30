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
// Start Time: November, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_dynexp_up.dats, see PORTING.md,
// "Level 3 translation, group 1 (dynexp_up/util/syncst)")
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

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload GLOB = "./pats_global.sats"
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_trans3_dynexp_up"
//
(* ****** ****** *)
//
staload LAB = "./pats_label.sats"
staload LOC = "./pats_location.sats"
typedef loc_t = $LOC.location
//
staload SYN = "./pats_syntax.sats"
//
(* ****** ****** *)

(*
** for T_* constructors
*)
staload "./pats_lexing.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"
staload "./pats_staexp2_sprint.sats"

(* ****** ****** *)

staload "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_patcst2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload MAC = "./pats_dmacro2.sats"
staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans2.hats" // [l2l], [glist_map_fun], the [$ERR] aborts

(* ****** ****** *)

#include "./pats_syntax_token.hats" // [token_char_get], [token_string_get]

(* ****** ****** *)

extern fun d2exp_trup_sym (d2e0: d2exp): d3exp

(* ****** ****** *)

extern fun d2exp_trup_extval (d2e0: d2exp): d3exp
extern fun d2exp_trup_extfcall (d2e0: d2exp): d3exp
extern fun d2exp_trup_extmcall (d2e0: d2exp): d3exp

(* ****** ****** *)

extern fun d2exp_trup_con (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_tmpid (d2e0: d2exp): d3exp

(* ****** ****** *)

extern fun d2exp_trup_lst (d2e0: d2exp): d3exp
extern fun d2exp_trup_tup (d2e0: d2exp): d3exp
extern fun d2exp_trup_rec (d2e0: d2exp): d3exp
extern fun d2exp_trup_seq (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun
d2exp_trup_effmask(d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun
d2exp_trup_vararg( d2e0: d2exp ): d3exp

(* ****** ****** *)

extern
fun
d2exp_trup_vcopyenv(d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun
d2exp_trup_tempenver(d2e0: d2exp): d3exp

(* ****** ****** *)
//
// HX-2026-10: the triple is a flat tuple
//
extern
fun
d2exp_trup_arg_body
(
  loc0: loc_t
, fc0: funclo
, lin: int, npf: int, p2ts: p2atlst, d2e: d2exp
) : @(s2exp, p3atlst, d3exp)

(* ****** ****** *)
//
extern
fun
d2exp_trup_letwhere
  (d2e0: d2exp, d2cs: d2eclist, d2e: d2exp): d3exp
// end of [d2exp_trup_letwhere]
//
(* ****** ****** *)

extern
fun
d2exp_trup_lam_dyn (d2e0: d2exp): d3exp
extern
fun
d2exp_trup_laminit_dyn (d2e0: d2exp): d3exp
extern
fun
d2exp_trup_lam_sta (d2e0: d2exp): d3exp
extern
fun
d2exp_trup_lam_met (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_fix (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_delay (d2e0: d2exp): d3exp
extern
fun d2exp_trup_ldelay (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_for (d2e0: d2exp): d3exp
extern
fun d2exp_trup_while (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_trywith (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_mac (d2e0: d2exp): d3exp
extern
fun d2exp_trup_macsyn (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_solassert (d2e0: d2exp): d3exp
extern
fun d2exp_trup_solverify (d2e0: d2exp): d3exp

(* ****** ****** *)

fun
d2exp_is_sym
  (d2e: d2exp): bool =
  d2exp_node_is_D2Esym (d2e.d2exp_node ())
// end of [d2exp_is_sym]

(* ****** ****** *)
//
// HX: [val-D2Esym(d2s) = d2e.d2exp_node] (the MatchError of ATS1 is an abort)
//
fn
d2exp_get_D2Esym
  (d2e: d2exp): d2sym = (
//
case+ d2exp_node_view (d2e.d2exp_node ()) of
| ~D2Esym (d2s) => d2s
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d2sym> ((*MatchError*)))
//
) (* end of [d2exp_get_D2Esym] *)

(* ****** ****** *)
//
// HX: [list_last] of ATS1 (the list is not empty)
//
fun
s2exparglst_last
  (xs: s2exparglst): s2exparg = let
  val x = glist_head (xs)
  val xs1 = glist_tail (xs)
in
  if glist_is_cons (xs1) then s2exparglst_last (xs1) else x
end // end of [s2exparglst_last]

(* ****** ****** *)
//
// HX: the arm [_(*rest-of-d0exp*)] of [D2Eapplst] in [d2exp_trup]
//
fn
d2exp_trup_applst_rest
(
  d2e0: d2exp, _fun: d2exp, _arg: d2exparglst
) : d3exp = let
  val opt = d2exp_get_seloverld(_fun)
in
  case+ gopt_view (opt) of
  | ~GOnone () =>
      d2exp_trup_applst(d2e0, _fun, _arg)
    // end of [None]
  | ~GOsome (d2s) =>
      d2exp_trup_applst_seloverld(d2e0, _fun, d2s, _arg)
    // end of [Some]
end // end of [d2exp_trup_applst_rest]

(* ****** ****** *)
//
// HX: the arm [D2Earrinit] of [d2exp_trup]: [d3e_asz] and the (static) size [s2i_asz]
// ([s2i_asz] is a [var] of ATS1)
//
fn
d2exp_trup_arrinit_asz
(
  loc0: loc_t, nxs: int, opt: d2expopt
) : @(d3exp, s2exp) = (
//
case+ gopt_view (opt) of
//
| ~GOnone ((*void*)) => let
    val s2i_asz = s2exp_int(nxs)
    val s2e_asz =
      s2exp_int_index_t0ype(s2i_asz)
    val d3e_asz =
      d3exp_int (loc0, s2e_asz, nxs)
  in
    @(d3e_asz, s2i_asz)
  end (* end of [None] *)
//
| ~GOsome (d2e_asz) => let
    val d3e_asz = d2exp_trup(d2e_asz)
    val s2e_asz = d3exp_get_type(d3e_asz)
    val s2i_asz = let
      val s2f = s2exp2hnf (s2e_asz)
      val opt =
        un_s2exp_g1size_index_t0ype(s2f)
      // end of [val]
    in
      case+ opt of
      | ~Some_vt(s2i) => s2i
      | ~None_vt((*void*)) => s2exp_errexp(s2rt_int)
    end // end of [let] // end of [val]
  in
    @(d3e_asz, s2i_asz)
  end (* end of [Some] *)
//
) (* end of [d2exp_trup_arrinit_asz] *)

(* ****** ****** *)

implement
d2exp_trup
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
val
d3e0 = (
case+
d2exp_node_view (d2e0.d2exp_node ())
of (* case+ *)
//
| ~D2Evar(d2v) => d2exp_trup_var(loc0, d2v)
| ~D2Ecst(d2c) => d2exp_trup_cst(loc0, d2c)
//
| ~D2Eint(int) => d2exp_trup_int(d2e0, int)
| ~D2Eintrep(rep) => d2exp_trup_intrep(d2e0, rep)
//
| ~D2Ebool(bool) => d2exp_trup_bool(d2e0, bool)
| ~D2Echar(char) => d2exp_trup_char(d2e0, char)
//
| ~D2Efloat(rep) => d2exp_trup_float(d2e0, rep)
| ~D2Estring(str) => d2exp_trup_string(d2e0, str)
//
| ~D2Ei0nt(tok) => d2exp_trup_i0nt(d2e0, tok)
//
| ~D2Ec0har(tok) => let
    val c = token_char_get(tok) // [val-T_CHAR(c) = tok.token_node]
  in
    d2exp_trup_char(d2e0, c)
  end // end of [D2Ec0har]
| ~D2Ef0loat (tok) => d2exp_trup_f0loat(d2e0, tok)
| ~D2Es0tring (tok) => let
    val str = token_string_get(tok) // [val-T_STRING(str) = tok.token_node]
  in
    d2exp_trup_string(d2e0, str)
  end // end of [D2Es0tring]
//
| ~D2Ecstsp(csp) => d2exp_trup_cstsp(d2e0, csp)
//
| ~D2Etyrep(s2e) => d2exp_trup_tyrep(d2e0, s2e)
//
| ~D2Eliteral(d2e) => d2exp_trup_literal(d2e0, d2e)
//
(*
| D2Etop() => // case for analysis
*)
| ~D2Etop2(s2e) => d3exp_top(loc0, s2e)
//
| ~D2Eempty() =>
    d3exp_empty(loc0, s2exp_void_t0ype())
  // end of [D2Eempty]
//
| ~D2Eextval _ => d2exp_trup_extval (d2e0)
| ~D2Eextfcall _ => d2exp_trup_extfcall (d2e0)
| ~D2Eextmcall _ => d2exp_trup_extmcall (d2e0)
//
| ~D2Econ _ => d2exp_trup_con (d2e0)
//
| ~D2Esym _ => d2exp_trup_sym (d2e0)
//
| ~D2Efoldat _ => d2exp_trup_foldat (d2e0)
| ~D2Efreeat _ => d2exp_trup_freeat (d2e0)
//
| ~D2Etmpid _ => d2exp_trup_tmpid (d2e0)
//
| ~D2Elet
    (d2cs, d2e) => d2exp_trup_letwhere(d2e0, d2cs, d2e)
  // end of [D2Elet]
| ~D2Ewhere
    (d2e, d2cs) => d2exp_trup_letwhere(d2e0, d2cs, d2e)
  // end of [D2Ewhere]
//
| ~D2Eapplst
    (_fun, _arg) => (
    case+
    d2exp_node_view (_fun.d2exp_node ())
    of // case+
//
    | ~D2Esym(d2s) =>
        d2exp_trup_applst_sym(d2e0, d2s, _arg)
      // end of [D2Esym]
    | ~D2Etmpid
        (d2e, t2mas) => (
        // [D2Etmpid (d2e, t2mas) when d2exp_is_sym(d2e)]
        if d2exp_is_sym(d2e) then let
          val d2s = d2exp_get_D2Esym(d2e)
        in
          d2exp_trup_applst_tmpsym(d2e0, d2s, t2mas, _arg)
        end else d2exp_trup_applst_rest(d2e0, _fun, _arg)
      ) (* end of [D2Etmpid when ...] *)
//
    | ~D2Emac(d2m) => let
        val d2e0 =
          $MAC.dmacro_eval_app_short (loc0, d2m, _arg)
        // end of [val]
      in
        d2exp_trup(d2e0)
      end // end of [D2Emac]
//
    | v (*rest-of-d0exp*) => let
        val () = d2exp_node_view_free (v)
      in
        d2exp_trup_applst_rest(d2e0, _fun, _arg)
      end // end of [rest-of-d0exp]
  ) (* end of [D2Eapplst] *)
//
| ~D2Eifhead
    (_, _, _, opt) => let
    val s2e_if =
    (
      if gopt_is_none (opt)
        then
        s2exp_void_t0ype()
        else
        s2exp_Var_make_srt
          (loc0, s2rt_t0ype)
        // end of [Some]
    ) : s2exp // end of [val]
    val s2f_if = s2exp2hnf_cast(s2e_if)
  in
    d2exp_trdn_ifhead (d2e0, s2f_if)
  end // end of [D2Eifhead]
| ~D2Esifhead _ => let
    val
    s2e_sif =
    s2exp_Var_make_srt(loc0, s2rt_t0ype)
    val s2f_sif = s2exp2hnf_cast(s2e_sif)
  in
    d2exp_trdn_sifhead (d2e0, s2f_sif)
  end // end of [D2Esifhead]
//
| ~D2Eifcasehd
    (knd, _, _) => let
    val
    s2e_if =
    (
      if knd = 0
        then
        s2exp_void_t0ype()
        else
        s2exp_Var_make_srt(loc0, s2rt_t0ype)
      // end of [if]
    ) : s2exp // end of [val]
    val
    s2f_if = s2exp2hnf_cast(s2e_if)
  in
    d2exp_trdn_ifcasehd (d2e0, s2f_if)
  end // end of [D2Eifhead]
//
| ~D2Ecasehead _ => let
    val
    s2e_case =
    s2exp_Var_make_srt(loc0, s2rt_t0ype)
    val s2f_case = s2exp2hnf_cast(s2e_case)
  in
    d2exp_trdn_casehead (d2e0, s2f_case)
  end // end of [D2Ecasehead]
| ~D2Escasehead _ => let
    val
    s2e_scase =
    s2exp_Var_make_srt(loc0, s2rt_t0ype)
    val s2f_scase = s2exp2hnf_cast(s2e_scase)
  in
    d2exp_trdn_scasehead (d2e0, s2f_scase)
  end // end of [D2Escasehead]
//
| ~D2Esing (d2e) => d2exp_trup (d2e)
//
| ~D2Elist (npf, d2es) => let
    val d2e0 =
      d2exp_tup_flt (loc0, npf,d2es) in d2exp_trup (d2e0)
    // end of [val]
  end // end of [D2Elist]
//
| ~D2Elst _ => d2exp_trup_lst (d2e0)
| ~D2Etup _ => d2exp_trup_tup (d2e0)
| ~D2Erec _ => d2exp_trup_rec (d2e0)
| ~D2Eseq _ => d2exp_trup_seq (d2e0)
//
| ~D2Eselab
    (d2e, d2ls) =>
    d2exp_trup_selab(loc0, d2e, d2ls)
  // end of [D2Eselab]
//
| ~D2Eptrof _ => d2exp_trup_ptrof (d2e0)
| ~D2Eviewat _ => d2exp_trup_viewat (d2e0)
//
| ~D2Ederef(d2s, d2e) =>
    d2exp_trup_deref(loc0, d2s, d2e, glist_nil{d2lab}((*void*)))
  // end of [D2Ederef]
//
| ~D2Eassgn _ => d2exp_trup_assgn (d2e0)
| ~D2Exchng _ => d2exp_trup_xchng (d2e0)
//
| ~D2Earrsub (
    d2s, arr, loc_ind, ind // d2s = lrbrackets
  ) => let
    val loc_arr = arr.d2exp_loc ()
    val loc_arg = $LOC.location_combine (loc_arr, loc_ind)
    val d2es_arg = glist_cons(arr, ind)
    val d2a = d2exparg_D2EXPARGdyn(~1(*npf*), loc_arg, d2es_arg)
//
    val d2as = glist_sing(d2a)
//
  in
    d2exp_trup_applst_sym (d2e0, d2s, d2as)
  end // end of [D2Earrsub]
| ~D2Earrpsz
    (opt, d2es) => let
    val s2e = (
      case+ gopt_view (opt) of
      | ~GOsome(s2e) => s2e
      | ~GOnone((*void*)) => let
          val
          s2t = s2rt_t0ype in s2exp_Var_make_srt(loc0, s2t)
        end // end of [None]
    ) : s2exp // end of [val]
    val asz = glist_length (d2es)
    val d3es = d2explst_trdn_elt(d2es, s2e)
    val s2e_arrpsz =
      s2exp_arrpsz_vt0ype_int_vt0ype(s2e, asz)
    // end of [val]
  in
    d3exp_arrpsz(loc0, s2e_arrpsz, s2e, d3es, asz)
  end // end of [D2Earrpsz]
| ~D2Earrinit
  (
    s2e_elt, opt, d2es
  ) => let
//
    val nxs = glist_length (d2es)
//
    val (d3e_asz, s2i_asz) =
      d2exp_trup_arrinit_asz (loc0, nxs, opt)
//
    val s2e_elt =
    (
      if glist_is_cons (d2es)
        then s2e_elt
        else s2exp_top (0(*knd*), s2e_elt)
      // end of [if]
    ) : s2exp (* end of [val] *)
    val d3es = d2explst_trdn_elt (d2es, s2e_elt)
//
    val s2e_tyarr = s2exp_tyarr (s2e_elt, glist_sing(s2i_asz))
//
  in
    d3exp_arrinit (loc0, s2e_tyarr, s2e_elt, d3e_asz, d3es)
  end // end of [D2Earrinit]
//
| ~D2Eraise
    (d2e_exn) => let
    val err =
      the_effenv_check_exn (loc0)
    // end of [val]
    val () =
    if (err > 0) then
      the_trans3errlst_add (trans3err_T3E_d2exp_trup_exn(loc0))
    // end of [if] // end of [val]
    val s2e_exn = s2exp_exception_vtype ()
    val d3e_exn = d2exp_trdn (d2e_exn, s2e_exn)
    val s2e_raise = s2exp_bottom_vt0ype_uni ()
  in
    d3exp_raise (loc0, s2e_raise, d3e_exn)
  end // end of [D2Eraise]
//
| ~D2Eeffmask _ => d2exp_trup_effmask(d2e0)
//
| ~D2Evararg (_) => d2exp_trup_vararg(d2e0)
//
| ~D2Evcopyenv _ => d2exp_trup_vcopyenv(d2e0)
//
| ~D2Eshowtype
    (d2e) => d3e where
  {
    val d3e = d2exp_trup (d2e)
    val () = fshowtype_d3exp_up (d3e)
  } (* end of [D2Eshowtype] *)
//
| ~D2Etempenver _ => d2exp_trup_tempenver(d2e0)
//
| ~D2Elam_dyn _ => d2exp_trup_lam_dyn (d2e0)
| ~D2Elaminit_dyn _ => d2exp_trup_laminit_dyn (d2e0)
| ~D2Elam_sta _ => d2exp_trup_lam_sta (d2e0)
| ~D2Elam_met _ => d2exp_trup_lam_met (d2e0)
//
| ~D2Efix _ => d2exp_trup_fix(d2e0)
//
| ~D2Edelay _ => d2exp_trup_delay(d2e0)
| ~D2Eldelay _ => d2exp_trup_ldelay(d2e0)
//
| ~D2Efor _ => d2exp_trup_for (d2e0)
| ~D2Ewhile _ => d2exp_trup_while (d2e0)
| ~D2Eloopexn (knd) => d2exp_trup_loopexn (loc0, knd)
//
| ~D2Etrywith _ => d2exp_trup_trywith (d2e0)
//
| ~D2Eann_type
    (d2e, s2e_ann) => let
    val d3e = d2exp_trdn (d2e, s2e_ann)
  in
    d3exp_ann_type (loc0, d3e, s2e_ann)
  end // end of [D2Eann_type]
//
| ~D2Eann_seff
    (d2e, _(*s2fe*)) => let
  in
    d2exp_trup (d2e) // HX: [d2e] should be a value
  end // end of [D2Eann_seff]
//
| ~D2Emac _ => d2exp_trup_mac (d2e0)
| ~D2Emacsyn _ => d2exp_trup_macsyn (d2e0)
//
| ~D2Esolassert _ => d2exp_trup_solassert (d2e0)
| ~D2Esolverify _ => d2exp_trup_solverify (d2e0)
//
| ~D2Eerrexp((*error*)) => d3exp_errexp (loc0) // : [s2exp_t0ype_err]
//
| v (*unspported*) => let
    val () = d2exp_node_view_free (v)
    val () = prerr_interror_loc(loc0)
    val () = prerr (": d2exp_trup: d2e0 = ")
    val () = prerr_d2exp (d2e0)
    val () = prerr_newline ()
  in
    exitloc(1)
  end // end of [_(*unsupported*)]
//
) : d3exp // end of [val]
in
//
d3e0 // the return value
//
end // end of [d2exp_trup]

(* ****** ****** *)

implement
d2explst_trup
  (d2es) = glist_map_fun<d2exp,d3exp> (d2es, d2exp_trup)
// end of [d2explst_trup]

(* ****** ****** *)

fun
d2explst_trup_arg
(
  d2es: d2explst
) : d23explst = let
in
//
case+ glist_view (d2es) of
//
| ~GLcons
    (d2e, d2es) => let
    val d23e = let
      val isval = d2exp_is_varlamcst (d2e)
    in
      if isval
        then D23Ed2exp d2e
        else let
          val d3e = d2exp_trup (d2e) in D23Ed3exp d3e
        end // end of [else]
      // end of [if]
    end : d23exp // end of [val]
    val d23es = d2explst_trup_arg (d2es)
  in
    list_vt_cons (d23e, d23es)
  end // end of [cons]
//
| ~GLnil ((*void*)) => list_vt_nil ()
//
end // end of [d2explst_trup_arg]

(* ****** ****** *)

fn
d23exp_open_and_add
  (d23e: !d23exp): void = (
//
  case+ d23e of
  | @D23Ed2exp (d2e) => ()
  | @D23Ed3exp (d3e) => let
      val () =
        d3exp_open_and_add(d3e) in ()
      // end of [val]
    end // end of [D23Ed3exp]
//
) (* end of [d23exp_open_and_add] *)

fun
d23explst_open_and_add
  (d23es: !d23explst): void = (
//
  case+ d23es of
  | list_vt_nil() => ()
  | @list_vt_cons
      (d23e, d23es1) => let
      val () = d23exp_open_and_add(d23e)
      val () = d23explst_open_and_add(d23es1)
    in
      // nothing
    end // end of [cons]
//
) (* end of [d23explst_open_and_add] *)

(* ****** ****** *)

fun
d23explst_trdn_aux
(
  d23es: d23explst, s2es: s2explst, err: &int
) : d3explst = let
in
//
case+ d23es of
| ~list_vt_nil () =>
  (
    if glist_is_nil (s2es)
      then glist_nil()
      else let
        val () = err := err - 1 in glist_nil()
      end // end of [list_cons]
  ) (* end of [list_vt_nil] *)
| ~list_vt_cons
    (d23e, d23es) =>
  (
    case+ glist_view (s2es) of
    | ~GLnil() => let
        val () = err := err + 1
        val () = d23exp_free(d23e)
        val () = d23explst_free(d23es)
      in
        glist_nil()
      end // end of [list_nil]
    | ~GLcons
        (s2e, s2es) => let
        val d3e = (
          case+ d23e of
          | ~D23Ed2exp(d2e) => d2exp_trdn(d2e, s2e)
          // HX-2026-10: fold on demand (a mutable variable)
          | ~D23Ed3exp(d3e) => d3exp_trdn_autofold(d3e, s2e)
        ) : d3exp // end of [val]
        val d3es = d23explst_trdn_aux(d23es, s2es, err)
      in
        glist_cons(d3e, d3es)
      end // end of [list_cons]
  ) (* end of [list_vt_cons] *)
end // end of [d23explst_trdn_aux]

fn d23explst_trdn
(
  locarg: loc_t
, d23es: d23explst, s2es: s2explst
) : d3explst = let
//
var serr: int = 0
val d3es = d23explst_trdn_aux(d23es, s2es, serr)
//
val () =
if
(serr != 0)
then let
  val () =
    prerr_error3_loc(locarg)
  val () =
    filprerr_ifdebug "d23explst_trdn"
  val () = prerr ": arity mismatch"
  val () = if serr < 0 then prerr ": more arguments are expected."
  val () = if serr > 0 then prerr ": fewer arguments are expected."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add(trans3err_T3E_d23explst_trdn_arity (locarg, serr))
end // end of [then]
//
in
//
d3es (* return value *)
//
end // end of [d23explst_trdn]

(* ****** ****** *)

implement
d2var_get_type_some
  (loc0, d2v) = let
//
fun auxerr
(
  loc0: loc_t, d2v: d2var
) : void = let
//
  val
  islin = d2var_is_linear(d2v)
//
  val () = prerr_error3_loc (loc0)
//
  val legacy = $GLOB.the_LEGACYERRORS_get () > 0
//
  val () =
  if islin && legacy then let
    val () = prerr (": the linear dynamic variable [")
    val () = prerr_d2var (d2v)
    val () = prerr ("] is no longer available.")
  in
    prerr_newline ()
  end // end of [if]
//
  val () =
  if not(islin) && legacy then let
    val () = prerr (": the (non-linear) dynamic variable [")
    val () = prerr_d2var (d2v)
    val () = prerr ("] is not available for external use.")
  in
    prerr_newline ()
  end // end of [if]
//
// HX-2026-10: the surface syntax (pats_staexp2_sprint)
//
  val () =
  if not(legacy) then let
    val () = sprint_reset ()
    val () =
    if islin
      then prerr (": the linear variable ") else prerr (": the variable ")
    val () = prerr_d2var_s (d2v)
    val () =
    if islin
      then prerr (" is no longer available (it has been consumed)")
      else prerr (" is not available for external use")
    // end of [if]
  in
    prerr_newline ()
  end // end of [if]
//
in
  the_trans3errlst_add (trans3err_T3E_d2var_typeless (loc0, d2v))
end // end of [auxerr]
//
val opt = d2var_get_type (d2v)
//
in
//
case+ gopt_view (opt) of
| ~GOsome s2e => s2e
| ~GOnone ((*void*)) => let
    val () = auxerr (loc0, d2v) in s2exp_t0ype_err ()
  end // end of [None]
//
end // end of [d2var_get_type_some]

(* ****** ****** *)

implement
d2exp_trup_var_mutabl
  (loc0, d2v) = let
  val s2l = gopt_unsome<s2exp> (d2var_get_addr (d2v)) // [val-Some (s2l) = ..]
  var s2rt: s2exp
  val s2e_sel = s2addr_deref (loc0, s2l, glist_nil{d3lab}((*void*)), s2rt)
in
  d3exp_var (loc0, s2e_sel, d2v)
end // end of [d2exp_trup_var_mutabl]

(* ****** ****** *)

implement
d2exp_trup_var_nonmut
  (loc0, d2v) = let
//
// HX: lin >= 0; nonlin = ~1
//
val lin = d2var_get_linval (d2v)
val s2qs = d2var_get_decarg (d2v)
val s2e0 = d2var_get_type_some (loc0, d2v)
//
val () =
if (
lin >= 0
) then let
  val isllamlocal =
    the_d2varenv_d2var_is_llamlocal (d2v)
  // end of [val]
in
//
if
isllamlocal
then let
  val () = d2var_inc_linval (d2v)
in
  d2var_set_type (d2v, gopt_none ((*void*))) // HX: [d2v] is consumed
end // end of [then]
else let
  val () = prerr_error3_loc (loc0)
  val () = prerr ": the linear dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] is expected to be local but it is not."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_d2var_trup_llamlocal (d2v))
end // end of [else]
//
end // end of [if] // end of [val]
//
in
//
if glist_is_nil (s2qs)
  then d3exp_var (loc0, s2e0, d2v)
  else let
    var err: int = 0
    val locsarg =
      $LOC.location_rightmost (loc0)
    val (s2e_tmp, s2ess) =
      s2exp_tmp_instantiate_rest (s2e0, locsarg, s2qs, err)
  in
    d3exp_tmpvar (loc0, s2e_tmp, d2v, s2ess)
  end // end of [list_cons]
//
end // end of [d2exp_trup_var_nonmut]

implement
d2exp_trup_var
  (loc0, d2v) = let
in
  if d2var_is_mutabl (d2v) then
    d2exp_trup_var_mutabl (loc0, d2v)
  else
    d2exp_trup_var_nonmut (loc0, d2v)
  // end of [if]
end // end of [d2exp_trup_var]

(* ****** ****** *)

implement
d2exp_trup_cst
  (loc0, d2c) = let
  val s2e = d2cst_get_type (d2c)
  val s2qs = d2cst_get_decarg (d2c)
in
//
if glist_is_nil (s2qs)
  then d3exp_cst (loc0, s2e, d2c)
  else let
    var err: int = 0
    val locsarg =
      $LOC.location_rightmost (loc0)
    val (s2e_tmp, s2ess) =
      s2exp_tmp_instantiate_rest (s2e, locsarg, s2qs, err)
  in
    d3exp_tmpcst (loc0, s2e_tmp, d2c, s2ess)
  end // end of [list_cons]
//
end // end of [d2cst_trup_cst]

(* ****** ****** *)

implement
d2exp_trup_sym
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
val d2s = d2exp_get_D2Esym (d2e0) // [val-D2Esym(d2s) = d2e0.d2exp_node]
//
val () = prerr_error3_loc (loc0)
val () = filprerr_ifdebug "d2exp_trup_sym"
//
val leg = $GLOB.the_LEGACYERRORS_get () > 0
val () = prerr_string (if leg then ": the symbol [" else ": the symbol ")
val () = prerr_d2sym (d2s)
val () =
  prerr_string (if leg then "] cannot be resolved." else " cannot be resolved.")
val () = prerr_newline ()
//
val () =
  the_trans3errlst_add (trans3err_T3E_d2exp_trup_sym (d2e0))
//
in
  d3exp_errexp (loc0) // : [s2exp_t0ype_err]
end // end of [d2exp_trup_sym]

(* ****** ****** *)

implement
d2exp_trup_extval
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eextval(s2e, name) => d3exp_extval (loc0, s2e, name)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_extval]

(* ****** ****** *)

local

fun auxerr
(
  loc0: loc_t, d3e: d3exp
) : void = let
  val loc = d3e.d3exp_loc ()
  val () = prerr_error3_loc (loc)
  val () = filprerr_ifdebug "d2exp_trup_extfcall"
  val () = prerr ": no linear argument is allowed for the extfcall."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d3exp_extfcall_arg (loc0, d3e))
end // end of [auxerr]

fun auxcheck
(
  loc0: loc_t, d3es: d3explst
) : void = let
in
//
case+ glist_view (d3es) of
| ~GLcons
    (d3e, d3es) => let
    val s2e = d3exp_get_type (d3e)
    val islin = s2exp_is_lin (s2e)
    val () = if islin then auxerr (loc0, d3e)
  in
    auxcheck (loc0, d3es)
  end // end of [list_cons]
| ~GLnil ((*void*)) => ()
//
end // end of [auxcheck]

in (* in of [local] *)

implement
d2exp_trup_extfcall
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eextfcall (s2e, _fun, _arg) => let
    val d3es_arg = d2explst_trup (_arg)
    val ((*void*)) = auxcheck (loc0, d3es_arg)
  in
    d3exp_extfcall (loc0, s2e, _fun, d3es_arg)
  end // end of [D2Eextfcall]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_extfcall]

end // end of [local]

(* ****** ****** *)

local

fun auxerr
(
  loc0: loc_t, d3e: d3exp
) : void = let
  val loc = d3e.d3exp_loc ()
  val () = prerr_error3_loc (loc)
  val () = filprerr_ifdebug "d2exp_trup_extmcall"
  val () = prerr ": no linear argument is allowed for the extmcall."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d3exp_extmcall_arg (loc0, d3e))
end // end of [auxerr]

fun auxcheck
(
  loc0: loc_t, d3es: d3explst
) : void = let
in
//
case+ glist_view (d3es) of
| ~GLcons
    (d3e, d3es) => let
    val s2e = d3exp_get_type (d3e)
    val islin = s2exp_is_lin (s2e)
    val () = if islin then auxerr (loc0, d3e)
  in
    auxcheck (loc0, d3es)
  end // end of [list_cons]
| ~GLnil ((*void*)) => ()
//
end // end of [auxcheck]

in (* in of [local] *)

implement
d2exp_trup_extmcall
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eextmcall (s2e, _obj, _mtd, _arg) => let
    val d3e_obj = d2exp_trup (_obj)
    val d3es_arg = d2explst_trup (_arg)
    val ((*void*)) = auxcheck (loc0, d3es_arg)
  in
    d3exp_extmcall (loc0, s2e, d3e_obj, _mtd, d3es_arg)
  end // end of [D2Eextmcall]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_extmcall]

end // end of [local]

(* ****** ****** *)

fn
d2exp_trup_con_main
(
  d2e0: d2exp
, d2c: d2con, locfun: loc_t, s2as: s2exparglst
, npf: int, locarg: loc_t, d2es_arg: d2explst
) : d3exp = let
  val loc0 = d2e0.d2exp_loc ()
  val s2e_con = d2con_get_type (d2c)
//
  var err: int = 0
  val (s2e, s2ps) =
    s2exp_uni_instantiate_sexparglst (s2e_con, s2as, err)
  // HX: [err] is not used
  val () = trans3_env_add_proplst_vt (locfun, s2ps)
//
  val () = if (err > 0) then let
    val () = prerr_error3_loc (locfun)
    val () = filprerr_ifdebug "d2exp_trup_con"
    val () = prerr ": static application cannot be properly typechecked."
    val () = prerr_newline ()
  in
    the_trans3errlst_add (
      trans3err_T3E_s2exp_uni_instantiate_sexparglst (locfun, s2e_con, s2as)
    ) // end of [the_trans3errlst_add]
  end // end of [val]
//
  val d23es_arg =
    d2explst_trup_arg (d2es_arg)
  // end of [val]
  val () = d23explst_open_and_add (d23es_arg)
//
  var err: int = 0
  val locsarg = $LOC.location_rightmost (locfun)
  val (s2e, s2ps) = s2exp_uni_instantiate_all (s2e, locsarg, err)
  // HX: [err] is not used
  val () = trans3_env_add_proplst_vt (locsarg, s2ps)
//
in
//
case+ s2exp_node_view (s2e.s2exp_node ()) of
| ~S2Efun (
    _fc, _lin, _s2fe, npf_con, s2es_arg, s2e_res
  ) => let
    val err = $SOL.pfarity_equal_solve (loc0, npf_con, npf)
    val () = if (err > 0) then let
      val () = prerr_error3_loc (loc0)
      val () = filprerr_ifdebug "d2exp_trup_con"
      val () = prerr ": proof arity mismatch: the constructor ["
      val () = prerr_d2con (d2c)
      val () = prerr "] requires ["
      val () = prerr_int (npf_con)
      val () = prerr "] arguments."
      val () = prerr_newline ()
      val () = prerr_the_staerrlst ()
    in
      the_trans3errlst_add (trans3err_T3E_d2exp_trup_con_npf (d2e0, npf)) // nothing
    end // end of [val]
    val d3es_arg = d23explst_trdn (locarg, d23es_arg, s2es_arg)
  in
    d3exp_con (loc0, s2e_res, d2c, npf, d3es_arg)
  end // end of [S2Efun]
| v => let
    val () = s2exp_node_view_free (v)
    val () = d23explst_free (d23es_arg) in d3exp_errexp (loc0)
  end // end of [_]
//
end // end [d2exp_trup_con_main]

implement
d2exp_trup_con (d2e0) =
(
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Econ (
    d2c, locfun, s2as, npf, locarg, d2es_arg
  ) => d2exp_trup_con_main (d2e0, d2c, locfun, s2as, npf, locarg, d2es_arg)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
) (* end of [d2exp_trup_con] *)

(* ****** ****** *)

implement
d2exp_trup_tmpcst
  (loc0, d2c, t2mas) = let
//
val locarg =
  $LOC.location_rightmost (loc0)
//
val s2qs = d2cst_get_decarg (d2c)
val s2e_d2c = d2cst_get_type (d2c)
//
var err: int = 0
val (s2e_tmp, t2mas) =
  s2exp_tmp_instantiate_tmpmarglst (s2e_d2c, locarg, s2qs, t2mas, err)
// end of [val]
in
  d3exp_tmpcst (loc0, s2e_tmp, d2c, t2mas)
end // end of [d2exp_trup_tmpcst]

implement
d2exp_trup_tmpvar
  (loc0, d2v, t2mas) = let
//
val locarg =
  $LOC.location_rightmost (loc0)
val s2qs = d2var_get_decarg (d2v)
val s2e_d2v = d2var_get_type_some (loc0, d2v)
var err: int = 0
val (s2e_tmp, t2mas) =
  s2exp_tmp_instantiate_tmpmarglst (s2e_d2v, locarg, s2qs, t2mas, err)
// end of [val]
in
  d3exp_tmpvar (loc0, s2e_tmp, d2v, t2mas)
end // end of [d2exp_trup_tmpvar]

implement
d2exp_trup_tmpid
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Etmpid (d2e_id, t2mas) => (
  case+
  d2exp_node_view (d2e_id.d2exp_node ())
  of (* case+ *)
  | ~D2Ecst (d2c) =>
      d2exp_trup_tmpcst (loc0, d2c, t2mas)
  | ~D2Evar (d2v) =>
      d2exp_trup_tmpvar (loc0, d2v, t2mas)
  | v => let
//
      val () = d2exp_node_view_free (v)
//
      val () = prerr_error3_loc (loc0)
      val () = filprerr_ifdebug "d2exp_trup_tmpid"
//
      val () = prerr (": a non-template is treated as a template: ")
      val () = prerr_d2exp (d2e0)
      val () = prerr_newline ()
//
      val () = the_trans3errlst_add (trans3err_T3E_d2exp_trup_tmpid (d2e0))
//
    in
      d3exp_errexp (loc0)
    end // end of [_]
  ) (* end of [D2Etmpid] *)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_tmpid]

(* ****** ****** *)

implement
d2exp_trup_applst
  (d2e0, d2e_fun, d2as_arg) = let
  val d3e_fun = d2exp_trup (d2e_fun)
  val () = d3exp_open_and_add (d3e_fun)
in
  d23exp_trup_applst (d2e0, d3e_fun, d2as_arg)
end // end of [d2exp_trup_applst]

(* ****** ****** *)

fun
d23exp_trup_applst_sta
(
  d2e0: d2exp
, d3e_fun: d3exp
, s2as: s2exparglst, d2as: d2exparglst
) : d3exp = let
  val loc_fun = d3e_fun.d3exp_loc ()
  val s2e_fun = d3e_fun.d3exp_type ()
  val loc_app = let
    fun aux
    (
      loc: loc_t, s2as: s2exparglst
    ) : loc_t = (
      if glist_is_nil (s2as)
        then loc
        else let
          val s2a = s2exparglst_last (s2as)
        in
          $LOC.location_combine (loc, s2a.s2exparg_loc ())
        end // end of [list_cons]
    ) (* end of [aux] *)
  in
    aux (loc_fun, s2as)
  end // end of [let] // end of [val]
//
  var err: int = 0
  val (s2e_fun, s2ps) =
    s2exp_uni_instantiate_sexparglst (s2e_fun, s2as, err)
  val ((*void*)) = trans3_env_add_proplst_vt (loc_app, s2ps)
//
  val ((*void*)) =
  if (err > 0) then let
    val () = prerr_error3_loc (loc_app)
    val () =
      filprerr_ifdebug "d2exp_trup_applst_sta"
    val () = prerr (": static application cannot be properly typechecked.")
    val () = prerr_newline ()
  in
    the_trans3errlst_add (
      trans3err_T3E_s2exp_uni_instantiate_sexparglst (loc_app, s2e_fun, s2as)
    ) // end of [the_trans3errlst_add]
  end // end of [let] // end of [val]
//
  val d3e_fun = d3exp_app_sta (loc_app, s2e_fun, d3e_fun)
in
  d23exp_trup_applst (d2e0, d3e_fun, d2as)
end // end of [d2exp_trup_applst_sta]

(* ****** ****** *)
//
// HX-2026-10: proof-argument elision
//
// A call with no proof arguments (no [|]: npf = ~1) of a function whose proof
// parameters are all preserved at-views (!T @ l, or !T @ l >> T' @ l)
// gets them from the proof search: the other arguments are checked
// first (they determine each address l), then the view at l is taken
// as [view@] does and restored after the call (d3explst_arg_restore).
// Such calls were errors (proof arity mismatch) before.
//
fun
s2exp_elide_atview
(
  s2e: s2exp
) : bool =
(
case+
s2exp_node_view(s2e.s2exp_node())
of // case+
| ~S2Erefarg
    (refval, s2e_v) =>
  (
    if refval = 0
      then let
        val s2f_v = s2exp_hnfize (s2e_v)
      in
        case+
        s2exp_node_view(s2f_v.s2exp_node())
        of // case+
        | ~S2Eat (_, _) => true
        | v => (s2exp_node_view_free (v); false)
      end // end of [then]
      else false
    // end of [if]
  ) (* end of [S2Erefarg] *)
| v => (s2exp_node_view_free (v); false)
) (* end of [s2exp_elide_atview] *)

//
// HX-2026-10: the type of a proof that is not an at-view: an application of
// a view constant (a dataview) or a static variable (a template parameter
// of a view sort), possibly under an existential
//
fun
s2exp_is_byview
(
  s2e: s2exp
) : bool = let
//
val s2e = s2exp_hnfize (s2e)
val isapp = (
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Eapp (s2e1, _) => (
      case+ s2exp_node_view (s2e1.s2exp_node ()) of
      | ~S2Ecst (_) => true
      | v => (s2exp_node_view_free (v); false)
      )
  | v => (s2exp_node_view_free (v); false)
) : bool // end of [val]
val isvar = (
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Evar (_) => true
  | v => (s2exp_node_view_free (v); false)
) : bool // end of [val]
val isunknown = (
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2EVar (_) => true
  | v => (s2exp_node_view_free (v); false)
) : bool // end of [val]
val isexi = (
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Eexi (_, _, s2e1) => s2exp_is_byview (s2e1)
  | v => (s2exp_node_view_free (v); false)
) : bool // end of [val]
//
in
//
  if isapp then true
  else (if isvar then true else (if isunknown then true else isexi))
//
end // end of [s2exp_is_byview]
//
// the proof parameter is of a type that is not an at-view: the proof is found
// by its type in the environment
//
fun
s2exp_elide_byview
(
  s2e: s2exp
) : bool = let
//
val s2e = s2exp_hnfize (s2e)
val isrefarg = (
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Erefarg (refval, s2e1) => (
      if refval = 0 then (
        case+ s2exp_node_view (s2e1.s2exp_node ()) of
        | ~S2Eat (_, _) => false // an at-view: the other path
        | v => (
            s2exp_node_view_free (v);
            s2exp_is_byview (s2e1)
            )
        ) else false // passed by reference
      )
  | v => (s2exp_node_view_free (v); false)
) : bool // end of [val]
//
in
//
  isrefarg
//
end // end of [s2exp_elide_byview]
//
fun
s2explst_elide_test_loop
(
  k: int, npf: int, s2es: s2explst
) : int =
(
if k > npf then 0 else
(
case+ glist_view(s2es) of
| ~GLnil () => k
| ~GLcons (s2e, s2es) =>
    if s2exp_elide_atview (s2e) || s2exp_elide_byview (s2e)
      then s2explst_elide_test_loop (k+1, npf, s2es) else k
    // end of [if]
)
) (* end of [s2explst_elide_test_loop] *)

implement
s2explst_elide_test
  (npf, s2es) = s2explst_elide_test_loop (1, npf, s2es)
// end of [s2explst_elide_test]

implement
s2explst_elide_drop
  (npf, s2es) =
(
if npf > 0 then
(
  if glist_is_cons (s2es)
    then s2explst_elide_drop (npf-1, glist_tail (s2es)) else s2es
  // end of [if]
) else s2es
) (* end of [s2explst_elide_drop] *)

fun
s2explst_elide_nth
(
  k: int, s2es: s2explst
) : s2exp =
(
case+ glist_view(s2es) of
| ~GLnil () => s2exp_errexp (s2rt_view)
| ~GLcons (s2e, s2es) =>
    if k <= 1 then s2e else s2explst_elide_nth (k-1, s2es)
) (* end of [s2explst_elide_nth] *)

// the line appended to [proof arity mismatch] for a call with no
// proof arguments when the proofs cannot be omitted
fun
prerr_elide_hint
(
  k: int, s2es: s2explst
) : void = let
  val s2e = s2explst_elide_nth (k, s2es)
  val () = sprint_reset ()
  val () = prerr "  the proof arguments cannot be omitted: proof argument "
  val () = prerr_int (k)
  val () =
  (
    case+
    s2exp_node_view(s2e.s2exp_node())
    of // case+
    | ~S2Erefarg
        (refval, s2e_v) => let
        val () = prerr " is of type "
        val () = prerr_s2exp_s (s2exp_hnfize (s2e_v))
      in
        if refval = 0
          then prerr ", which is not an at-view (T @ l)."
          else prerr ", which is passed by reference (&)."
        // end of [if]
      end // end of [S2Erefarg]
    | v => let
        val () = s2exp_node_view_free (v)
        val () = prerr " is of type "
        val () = prerr_s2exp_s (s2exp_hnfize (s2e))
      in
        prerr ", which is consumed (no !)."
      end // end of [_]
  ) : void // end of [val]
  val () = prerr_newline ()
  val () =
    prerr "  (only proofs of preserved at-views, !T @ l, can be omitted.)"
in
  prerr_newline ()
end // end of [prerr_elide_hint]

fun
auxerr_elide_noaddr
(
  locarg: loc_t, k: int, s2e: s2exp
) : void = let
  val () = sprint_reset ()
  val () = prerr_error3_loc (locarg)
  val () = prerr ": the address of the omitted proof argument "
  val () = prerr_int (k)
  val () = prerr " of type "
  val () = prerr_s2exp_s (s2e)
  val () = prerr " cannot be inferred from the other arguments"
  val () = prerr "; pass the proof explicitly."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_elide (locarg, k))
end // end of [auxerr_elide_noaddr]

fun
s2exp_is_errexp
  (s2e: s2exp): bool =
(
case+
s2exp_node_view(s2e.s2exp_node())
of // case+
| ~S2Eerrexp () => true
| v => (s2exp_node_view_free (v); false)
) (* end of [s2exp_is_errexp] *)

//
// HX-2026-10: no proof of the view [s2e] is in scope for the omitted proof
// argument [k]
//
fun
prerr_elide_noproof_msg
(
  locarg: loc_t, k: int, s2e: s2exp
) : void = let
//
val () = sprint_reset ()
val () = prerr_error3_loc (locarg)
val () = prerr ": no proof of the view "
val () = prerr_s2exp_s (s2e)
val () = prerr " is in scope for the omitted proof argument "
val () = prerr_int (k)
val () = prerr "; pass the proof explicitly."
val () = prerr_newline ()
//
in
  ()
end // end of [prerr_elide_noproof_msg]
//
fun
auxerr_elide_noproof
(
  locarg: loc_t, k: int, s2e: s2exp
) : void = let
//
val legacy = ($GLOB.the_LEGACYERRORS_get () > 0) : bool
val () = (
  if legacy then () else prerr_elide_noproof_msg (locarg, k, s2e)
)
//
in
  the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_elide (locarg, k))
end // end of [auxerr_elide_noproof]
//
// HX-2026-10: more than one proof of the view [s2e] is in scope for the
// omitted proof argument [k]
//
fun
prerr_d2varlst_names
(
  xs: glist (d2var)
) : void = let
//
in
//
case+ glist_view (xs) of
| ~GLnil () => ()
| ~GLcons (d2v, xs1) => let
    val () = $SYM.prerr_symbol (d2var_get_sym (d2v))
  in
    if glist_is_cons (xs1)
    then (prerr " or "; prerr_d2varlst_names (xs1)) else ()
  end // end of [GLcons]
//
end // end of [prerr_d2varlst_names]
//
fun
prerr_elide_ambiguous_msg
(
  locarg: loc_t, k: int, cands: glist (d2var)
) : void = let
//
val () = sprint_reset ()
val () = prerr_error3_loc (locarg)
val () = prerr ": the omitted proof argument "
val () = prerr_int (k)
val () = prerr " could be "
val () = prerr_d2varlst_names (cands)
val () = prerr "; pass the proof explicitly."
val () = prerr_newline ()
//
in
  ()
end // end of [prerr_elide_ambiguous_msg]
//
fun
auxerr_elide_ambiguous
(
  locarg: loc_t, k: int, s2e: s2exp, cands: glist (d2var)
) : void = let
//
val legacy = ($GLOB.the_LEGACYERRORS_get () > 0) : bool
val () = (
  if legacy then () else prerr_elide_ambiguous_msg (locarg, k, cands)
)
//
in
  the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_elide (locarg, k))
end // end of [auxerr_elide_ambiguous]
//
// HX-2026-10: no proof of the view is in scope
//
fun
d3exp_elide_proof_none
(
  locarg: loc_t, k: int, s2e_v: s2exp
) : d3exp = let
//
val () = auxerr_elide_noproof (locarg, k, s2e_v)
//
in
  d3exp_errexp (locarg)
end // end of [d3exp_elide_proof_none]
//
// HX-2026-10: more than one proof of the view is in scope
//
fun
d3exp_elide_proof_amb
(
  locarg: loc_t, k: int, s2e_v: s2exp, cands: glist (d2var)
) : d3exp = let
//
val () = auxerr_elide_ambiguous (locarg, k, s2e_v, cands)
//
in
  d3exp_errexp (locarg)
end // end of [d3exp_elide_proof_amb]
//
// HX-2026-10: the proof is found: it is used as it is (the type of the
// variable is restored after the call)
//
fun
d3exp_elide_proof_one
(
  locarg: loc_t, s2e_v: s2exp, cands: glist (d2var)
, used: &glist(d2var) >> _
) : d3exp = let
//
val d2v = (
  case+ glist_view (cands) of
  | ~GLcons (d2v, _) => d2v
  | ~GLnil () => d2var_make_any (locarg) // unreachable
) : d2var // end of [val]
// HX-2026-10: the proof is used as an explicit proof argument [d2v] would
// be (consumed until the restoration; a proof from outside of an enclosing
// [llam] is an error)
val d3e = d2exp_trup_var_nonmut (locarg, d2v)
// HX-2026-10: the proof is used: the next omitted proof does not look
// for it again
val () = used := glist_cons (d2v, used)
//
in
  d3exp_trdn (d3e, s2exp_refarg (0, s2e_v))
end // end of [d3exp_elide_proof_one]
//
// HX-2026-10: the omitted proof of a view that is not an at-view: the proof
// is found by its type in the environment (it must be unique)
//
fun
d3exp_elide_proof_byview
(
  locarg: loc_t, k: int, s2e_v: s2exp
, used: &glist(d2var) >> _
) : d3exp = let
//
val cands = pfobj_search_bytype (s2e_v, used)
val ncands = glist_length (cands)
val ans = (
  if ncands = 0 then 0 else (if ncands = 1 then 1 else 2)
) : int // end of [val]
val d3e = (
  if ans = 0
    then d3exp_elide_proof_none (locarg, k, s2e_v)
    else (
      if ans = 2
        then d3exp_elide_proof_amb (locarg, k, s2e_v, cands)
        else d3exp_elide_proof_one (locarg, s2e_v, cands, used)
      )
) : d3exp // end of [val]
//
in
  d3e
//
end // end of [d3exp_elide_proof_byview]
//
// the omitted proof of the parameter [s2e_arg] (!T @ l), of position [k]
fun
d3exp_elide_proof
(
  locarg: loc_t, k: int, s2e_arg: s2exp
, used: &glist(d2var) >> _
) : d3exp = let
  val-~S2Erefarg
    (_, s2e_v) = s2exp_node_view(s2e_arg.s2exp_node())
  val s2f_v = s2exp_hnfize (s2e_v)
  val isatview = (
    case+ s2exp_node_view (s2f_v.s2exp_node ()) of
    | ~S2Eat (_, _) => true
    | v => (s2exp_node_view_free (v); false)
  ) : bool // end of [val]
//
in
//
if ~isatview then
  d3exp_elide_proof_byview (locarg, k, s2f_v, used)
else let
  val-~S2Eat
    (_, s2l) = s2exp_node_view(s2f_v.s2exp_node())
  val s2l = s2exp_hnfize (s2l)
  val unsolved =
  (
    case+
    s2exp_node_view(s2l.s2exp_node())
    of // case+
    | ~S2EVar _ => true
    | v => (s2exp_node_view_free (v); false)
  ) : bool // end of [val]
//
// HX-2026-10: on an error, the pointer of the [view@] is an error
// expression (not of a pointer type), so that the restoration
// after the call (d3lval_set_type_err) reports nothing more
//
in
//
if unsolved then let
//
// HX-2026-10: the address of the at-view is not solved by the other
// arguments: the proof is searched by its type (the at-views of the same
// element type); when there is exactly one, it is used (its type solves
// the address), else the error is reported
//
  val cands = pfobj_search_atview_bytype (s2f_v)
  val ncands = glist_length (cands)
in
  if ncands = 1 then
    d3exp_elide_proof_one (locarg, s2f_v, cands, used)
  else let
    val () = auxerr_elide_noaddr (locarg, k, s2f_v)
  in
    d3exp_viewat
    (
      locarg, s2exp_errexp (s2rt_view), d3exp_errexp (locarg), glist_nil ()
    )
  end // end of [if]
end else let
  val s2e_at =
    s2addr_viewat_deref (locarg, s2l, glist_nil ())
  // end of [val]
in
  if s2exp_is_errexp (s2e_at) then
    d3exp_viewat (locarg, s2e_at, d3exp_errexp (locarg), glist_nil ())
  else let
    val s2e_ptr = s2exp_ptr_addr_type (s2l)
    val d3e_ptr = d3exp_empty (locarg, s2e_ptr)
    val d3e_pf = d3exp_viewat (locarg, s2e_at, d3e_ptr, glist_nil ())
  in
    d3exp_trdn (d3e_pf, s2e_arg)
  end // end of [if]
end // end of [if]
end // end of [if]
//
end // end of [d3exp_elide_proof]

fun
d3explst_elide_proofs_loop
(
  locarg: loc_t, k: int, npf: int, s2es: s2explst
, used: &glist(d2var) >> _
) : d3explst =
(
if k > npf then glist_nil () else
(
case+ glist_view(s2es) of
| ~GLnil () => glist_nil ()
| ~GLcons (s2e, s2es) => let
    val d3e = d3exp_elide_proof (locarg, k, s2e, used)
  in
    glist_cons (d3e, d3explst_elide_proofs_loop (locarg, k+1, npf, s2es, used))
  end // end of [GLcons]
)
) (* end of [d3explst_elide_proofs_loop] *)

implement
d3explst_elide_proofs
  (locarg, npf, s2es) = let
//
var used: glist (d2var) = glist_nil ()
//
in
  d3explst_elide_proofs_loop (locarg, 1, npf, s2es, used)
end // end of [d3explst_elide_proofs]

(* ****** ****** *)

fun
d23exp_trup_app23
(
  d2e0: d2exp
, d3e_fun: d3exp
, npf: int, locarg: loc_t, d23es_arg: d23explst
) : d3exp = let
//
  val loc_fun = d3e_fun.d3exp_loc ()
  val s2e_fun = d3e_fun.d3exp_type ()
//
  var err: int = 0
  val locsarg = $LOC.location_rightmost (loc_fun)
  val (s2e_fun, s2ps) = s2exp_unimet_instantiate_all (s2e_fun, locsarg, err)
  val () = trans3_env_add_proplst_vt (locsarg, s2ps)
  val d3e_fun =
    d3exp_app_unista (loc_fun, s2e_fun, d3e_fun)
  // end of [d3e_fun]
in
//
case+ s2exp_node_view (s2e_fun.s2exp_node ()) of
//
| ~S2Efun (
    fc, _(*lin*), s2fe_fun, npf_fun, s2es_fun_arg, s2e_fun_res
  ) => let
//
//
// HX-2026-10: [npf] is ~1 for a call with no [|] (the parser).
// [elide] = 0: the proofs are omitted and found by the
// proof search; [elide] = k > 0: they are omitted but parameter k is
// not a preserved at-view; [elide] = ~1: the proofs are not omitted
//
    val elide =
    (
      if npf < 0 // HX: no [|] in the call
        then (
          if npf_fun > 0
            then s2explst_elide_test (npf_fun, s2es_fun_arg) else ~1
          // end of [if]
        ) else ~1
      // end of [if]
    ) : int // end of [val]
//
    val err =
    (
      if elide = 0 then 0
      else $SOL.pfarity_equal_solve (loc_fun, npf_fun, npf)
    ) : int // end of [val]
//
    val () =
    if (err > 0) then let
      val () = prerr_error3_loc (loc_fun)
      val () = filprerr_ifdebug "d23exp_trup_app23"
      val () = prerr ": proof arity mismatch"
      val () = prerr (": the function requires ")
      val () = prerr_int (npf_fun)
      val () = prerr (" proof arguments.")
      val () = prerr_newline ()
      val () = prerr_the_staerrlst ()
//
// HX-2026-10: the hint is new text (ATS1 has none): legacy mode omits it
//
      val () =
      if (elide > 0 && $GLOB.the_LEGACYERRORS_get () = 0)
        then prerr_elide_hint (elide, s2es_fun_arg)
      // end of [if]
    in
      the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_npf (loc_fun, npf))
    end // end of [let] // end of [val]
//
    val loc_app = $LOC.location_combine (loc_fun, locarg)
    val s2es_fun_arg =
      s2fun_opninv_and_add (locarg, s2es_fun_arg, s2e_fun_res)
    val d3es_arg =
    (
      if elide = 0
        then let
          val s2es_dyn =
            s2explst_elide_drop (npf_fun, s2es_fun_arg)
          val d3es_dyn = d23explst_trdn (locarg, d23es_arg, s2es_dyn)
          val d3es_pf = d3explst_elide_proofs (locarg, npf_fun, s2es_fun_arg)
        in
          glist_append (d3es_pf, d3es_dyn)
        end // end of [then]
        else d23explst_trdn (locarg, d23es_arg, s2es_fun_arg)
      // end of [if]
    ) : d3explst // end of [val]
    val npf = (if elide = 0 then npf_fun else npf): int
//
    val (
      iswth
    , s2e_res
    , wths2es
    ) = un_s2exp_wthtype (loc_app, s2e_fun_res)
//
    val d3e_fun = d3exp_fun_restore (fc, d3e_fun)
    val d3es_arg = (
      if iswth then
        d3explst_arg_restore (d3es_arg, s2es_fun_arg, wths2es)
      else d3es_arg
    ) : d3explst // end of [val]
//
    val err =
      the_effenv_check_s2eff (loc_app, s2fe_fun)
    // end of [val]
    val () = if (err > 0) then (
      the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_eff (loc_app, s2fe_fun))
    ) // end of [if] // end of [val]
  in
    d3exp_app_dyn (loc_app, s2e_res, d3e_fun, npf, d3es_arg)
  end // end of [S2Efun]
| v => let
    val () = s2exp_node_view_free (v)
    val () = d23explst_free (d23es_arg)
    val () = prerr_error3_loc (loc_fun)
    val () = filprerr_ifdebug "d23exp_trup_app23"
    val () = prerr (": the applied dynamic expression is of non-function type: ")
    val () = prerr_s2exp (s2e_fun)
    val () = prerr_newline ()
    val () = the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_fun (loc_fun, s2e_fun))
  in
    d3exp_errexp (loc_fun)
  end // end of [_]
//
end // end of [d23exp_trup_app23]

fun
d23exp_trup_applst_dyn
(
  d2e0: d2exp
, d3e_fun: d3exp
, npf: int, locarg: loc_t, d2es_arg: d2explst
, d2as: d2exparglst
) : d3exp = let
  val loc_fun = d3e_fun.d3exp_loc ()
  val loc_app = $LOC.location_combine (loc_fun, locarg)
  val s2e_fun = d3e_fun.d3exp_type ()
  val d23es_arg = d2explst_trup_arg (d2es_arg)
  val ((*void*)) = d23explst_open_and_add (d23es_arg)
in
//
let
  val d3e_fun =
  d23exp_trup_app23
  (
    d2e0, d3e_fun, npf, locarg, d23es_arg
  ) // end of [val]
in
  d23exp_trup_applst (d2e0, d3e_fun, d2as)
end (* end of [_] *)
//
end // end of [d2exp_trup_applst_dyn]

(* ****** ****** *)

implement
d23exp_trup_applst
(
  d2e0: d2exp
, d3e_fun: d3exp, d2as: d2exparglst
) : d3exp = let
in
//
case+ glist_view (d2as) of
| ~GLcons
    (d2a, d2as) => (
  case+ d2exparg_view (d2a) of
  | ~D2EXPARGsta
      (locarg, s2as) =>
    (
      d23exp_trup_applst_sta (d2e0, d3e_fun, s2as, d2as)
    ) (* end of [D2EXPARGsta] *)
  | ~D2EXPARGdyn
      (npf, locarg, d2es_arg) =>
    (
      d23exp_trup_applst_dyn (d2e0, d3e_fun, npf, locarg, d2es_arg, d2as)
    ) (* end of [D2EXPARGdyn] *)
  ) // end of [cons]
| ~GLnil ((*void*)) => d3e_fun
//
end // end of [d2exp_trup_applst]

(* ****** ****** *)

implement
d2exp_trup_lst
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Elst (lin, opt, d2es) => let
    val islin =
    (
      if lin >= 0 then test_linkind (lin) else false
    ) : bool // end of [val]
    val isnonlin = not(islin)
    val s2e_elt = (
    //
    case+ gopt_view (opt) of
    | ~GOsome s2e => s2e
    | ~GOnone ((*void*)) => let
        val s2t =
        (
          if isnonlin then s2rt_t0ype else s2rt_vt0ype
        ) : s2rt // end of [val]
      in
        s2exp_Var_make_srt (loc0, s2t)
      end // end of [None]
    //
    ) : s2exp // end of [val]
    val n = glist_length (d2es)
    val d3es = d2explst_trdn_elt(d2es, s2e_elt)
    //
    // HX-2026-10: no GC
    // list literals are always linear; [$list_t]
    // is rejected by [d3exp_linheap_check]
    //
    val s2e_lst =
      s2exp_list_vt0ype_int_vtype (s2e_elt, n)
    // end of [val]
  in
    d3exp_linheap_check(d3exp_lst(loc0, s2e_lst, lin, s2e_elt, d3es))
  end // end of [D2Elst]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_lst]

(* ****** ****** *)

implement
d2exp_trup_tup
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Etup (knd, npf, d2es) => let
    val d3es = d2explst_trup(d2es)
    //
    val ls2es = d3explst_get_labtype(d3es)
    val s2tup = s2exp_tyrec(knd, npf, ls2es)
  in
    d3exp_linheap_check(d3exp_tup(loc0, s2tup, knd, npf, d3es))
  end // end of [D2Etup]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_tup]

(* ****** ****** *)
//
extern
fun
labd3explst_get_type
(ld3es: labd3explst): labs2explst
//
fn
labd3exp_get_type
  (ld3e: labd3exp): labs2exp = let
  val l = ld3e.labd3exp_lab ()
  val d3e = ld3e.labd3exp_elt ()
in
  labs2exp_new ($SYN.l0ab_lab (l), gopt_none ((*void*)), d3e.d3exp_type ())
end // end of [labd3exp_get_type]
//
implement
labd3explst_get_type(ld3es) =
  glist_map_fun<labd3exp,labs2exp> (ld3es, labd3exp_get_type)
// end of [labd3explst_get_type]
//
(* ****** ****** *)

fun
d2exp_trup_rec_aux
(
  ld2es: labd2explst
) : labd3explst =
(
  case+ glist_view (ld2es) of
  | ~GLnil() => glist_nil()
  | ~GLcons(ld2e, ld2es) => let
      val l = ld2e.labd2exp_lab ()
      val d2e = ld2e.labd2exp_elt ()
      val ld3e =
        labd3exp_new (l, d2exp_trup (d2e))
      // end of [val]
    in
      glist_cons (ld3e, d2exp_trup_rec_aux(ld2es))
    end // end of [list_cons]
) (* end of [d2exp_trup_rec_aux] *)

implement
d2exp_trup_rec
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Erec (recknd, npf, ld2es) => let
    val ld3es = d2exp_trup_rec_aux ld2es
//
    val ls2es = labd3explst_get_type(ld3es)
    val s2e_rec = s2exp_tyrec(recknd, npf, ls2es)
//
  in
    d3exp_linheap_check(d3exp_rec(loc0, s2e_rec, recknd, npf, ld3es))
  end // end of [D2Erec]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_rec]

(* ****** ****** *)
//
// HX-2026-10: [s2e_res] of ATS1 ([&(s2exp?) >> s2exp]) is the second component of the result
//
fun
d2exp_trup_seq_aux
(
  d2e: d2exp
, d2es: d2explst
, s2e_void: s2exp
) : @(d3explst, s2exp) =
  if glist_is_cons (d2es) then let
    val d2e1 = glist_head (d2es)
    val d2es1 = glist_tail (d2es)
    val d3e = d2exp_trdn (d2e, s2e_void)
    val (d3es, s2e_res) = d2exp_trup_seq_aux (d2e1, d2es1, s2e_void)
  in
    @(glist_cons (d3e, d3es), s2e_res)
  end // end of [cons]
  else let
    val d3e = d2exp_trup (d2e)
    val s2e_res = s2exp_hnfize (d3e.d3exp_type ())
  in
    @(glist_sing (d3e), s2e_res)
  end // end of [nil]
// end of [d2exp_trup_seq_aux]

implement
d2exp_trup_seq
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
val s2e_void = s2exp_void_t0ype ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eseq (d2es) => (
  if glist_is_cons (d2es) then let
    val d2e = glist_head (d2es)
    val d2es = glist_tail (d2es)
    val (d3es, s2e_res) = d2exp_trup_seq_aux (d2e, d2es, s2e_void)
  in
    d3exp_seq (loc0, s2e_res, d3es)
  end // end of [cons]
  else d3exp_empty (loc0, s2e_void)
  ) (* end of [D2Eseq] *)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_seq]

(* ****** ****** *)

implement
d2exp_trup_letwhere
  (d2e0, d2cs, d2e_scope) = let
  val loc0 = d2e0.d2exp_loc ()
  val () = the_effenv_push ()
  val () = the_s2cstbindlst_push ()
  val () = the_d2varenv_push_let ()
//
  val d3cs = d2eclist_tr (d2cs)
  val d3e_scope = d2exp_trup (d2e_scope)
//
  val () = the_d2varenv_check (loc0)
//
  val () = the_effenv_pop ()
  val () = the_s2cstbindlst_pop_and_unbind ()
  val () = the_d2varenv_pop ()
in
  d3exp_let (loc0, d3cs, d3e_scope)
end // end of [d2exp_trup_letwhere]

(* ****** ****** *)

implement
d2exp_trup_effmask
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eeffmask (s2fe, d2e) => let
    val () = the_effenv_push_effmask (s2fe)
    val d3e = d2exp_trup (d2e)
    val () = the_effenv_pop ()
  in
    d3exp_effmask (loc0, s2fe, d3e)
  end // end of [D2Eeffmask]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_effmask]

(* ****** ****** *)

implement
d2exp_trup_vararg
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Evararg (d2es) => let
    val d3es = d2explst_trup(d2es)
    //
    val s2es = d3explst_get_type(d3es)
    val s2types = s2exp_types_list(s2es)
  in
    d3exp_vararg(loc0, s2types, d3es)
  end // end of [D2Evararg]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_vararg]

(* ****** ****** *)

implement
d2exp_trup_vcopyenv
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Evcopyenv (knd, d2e) => (
  case+
  d2exp_node_view (d2e.d2exp_node ()) of
  | ~D2Evar (d2v) => let
      val opt =
        d2var_get_type (d2v)
      // end of [val]
      val s2f = (
        case+ gopt_view (opt) of
        | ~GOsome s2e =>
          (
            if test_prfkind(knd)
              then s2exp_vcopyenv_v(s2e) else s2exp_vcopyenv_vt(s2e)
            // end of [if]
          ) (* end of [Some] *)
        | ~GOnone () => s2exp_void_t0ype ()
      ) : s2exp // end of [val]
    in
      d3exp_vcopyenv (loc0, s2f, knd, d2v)
    end // end of [D2Evar]
  | v (*non-D2Evar*) => let
      val () = d2exp_node_view_free (v)
    in
      d2exp_trup (d2e) // HX: ignoring [$vcopyenv]
    end // end of [non-D2Evar]
  ) (* end of [D2Evcopyenv] *)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_vcopyenv]

(* ****** ****** *)

implement
d2exp_trup_tempenver
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Etempenver (d2vs) =>
    d3exp_tempenver (loc0, s2exp_void_t0ype(), d2vs)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_tempenver]

(* ****** ****** *)
//
// HX: the (linearity) check of the patterns of the arguments of a function
//
fn
funarg_patck_exhaust_linck
(
  p2t: p2at, p2tc: p2atcst, s2e: s2exp
) : void =
(
if p2atcst_is_P2TCany(p2tc)
  then ()
  else let (* non-P2TCany *)
    val
    islin =
    s2exp_is_lin(s2e)
  in
    if islin then let
      val () =
      prerr_error3_loc(p2t.p2at_loc ())
      val () =
      filprerr_ifdebug("funarg_patck_exhaust")
      val () = prerr
        (": the linear pattern cannot be used as a function argument.")
      val () = prerr_newline ()
    in
      the_trans3errlst_add(trans3err_T3E_d2exp_trup_arg_body_linpat(p2t))
    end // end of [_]
  end // end of [non-P2TCany]
// end of [if]
) (* end of [funarg_patck_exhaust_linck] *)
//
// HX-2026-10: the list is an immutable [p2atcstlst] here ([p2atcstlst_vt] in ATS1,
// borrowed as a [p2atcstlst] by [$UN.castvwtp1], PC-2)
//
fun
funarg_patck_exhaust_aux
( p2ts: p2atlst
, s2es: s2explst
) : p2atcstlst =
  if glist_is_nil (p2ts) then glist_nil()
  else if glist_is_nil (s2es) then glist_nil()
  else let
    val p2t = glist_head (p2ts)
    val p2ts = glist_tail (p2ts)
    val s2e = glist_head (s2es)
    val s2es = glist_tail (s2es)
    val p2tc = p2at2cst(p2t)
    val ((*void*)) =
      funarg_patck_exhaust_linck(p2t, p2tc, s2e)
    // end of [val]
  in
    glist_cons(p2tc, funarg_patck_exhaust_aux(p2ts, s2es))
  end // end of [list_cons]
// end of [funarg_patck_exhaust_aux]

implement
funarg_patck_exhaust
(
  loc0, p2ts_arg, s2es_arg
) = () where
{
//
val p2tcs =
  funarg_patck_exhaust_aux(p2ts_arg, s2es_arg)
//
val cp2tcss =
  p2atcstlst_comp(p2tcs)
val isexhaust =
(
  if list_vt_is_nil(cp2tcss) then true else false
) : bool // end of [val]
val () =
if ~isexhaust then let
//
val cp2tcss = p2atcstlstlst_vt_copy(cp2tcss) in
//
  trans3_env_add_patcstlstlst_false(loc0, CK_case_pos, cp2tcss, s2es_arg)
end // end of [if] // end of [val]
//
val ((*freed*)) = p2atcstlstlst_vt_free(cp2tcss)
//
} (* end of [funarg_patck_exhaust] *)

(* ****** ****** *)

implement
d2exp_trup_arg_body
(
  loc0
, fc0, lin, npf
, p2ts_arg, d2e_body
) = let
val
() = trans3_env_push()
//
var fc: funclo = fc0
//
val d2e_body =
  d2exp_funclo_of_d2exp(d2e_body, fc)
//
var s2fe: s2eff // HX: assigned by [d2exp_s2eff_of_d2exp] (ATS1: [= s2eff_nil])
val d2e_body =
  d2exp_s2eff_of_d2exp(d2e_body, s2fe)
//
val
() = the_effenv_push_lam(s2fe)
//
val s2es_arg = p2atlst_syn_type(p2ts_arg)
//
val () =
funarg_patck_exhaust(loc0, p2ts_arg, s2es_arg)
//
val p3ts_arg = p2atlst_trup_arg(npf, p2ts_arg)
//
val
() = the_d2varenv_push_lam(lin)
val () = the_d2varenv_add_p3atlst(p3ts_arg)
val
() = the_pfmanenv_push_lam(lin) // lin:0/1:stopping/continue
val () = the_pfmanenv_add_p3atlst(p3ts_arg)
//
val
() = the_lamlpenv_push_lam(p3ts_arg)
//
val d3e_body = d2exp_trup(d2e_body)
//
val () = the_d2varenv_check(loc0)
val () =
  if lin > 0 then the_d2varenv_check_llam(loc0)
//
val () = the_effenv_pop()
val () = the_d2varenv_pop()
val () = the_pfmanenv_pop()
val () = the_lamlpenv_pop()
//
val () = trans3_env_pop_and_add_main(loc0)
//
val s2e_res = d3e_body.d3exp_type ()
//
val islin = (lin > 0)
val isprf = s2exp_is_prf(s2e_res)
//
val s2t_fun =
  s2rt_prf_lin_fc(loc0, isprf, islin, fc)
//
val s2e_fun = s2exp_fun_srt
(
  s2t_fun, fc, lin, s2fe, npf, s2es_arg, s2e_res
) (* end of [val] *)
//
in
//
  @(s2e_fun, p3ts_arg, d3e_body)
//
end // end of [d2exp_trup_arg_body]

(* ****** ****** *)

implement
d2exp_trup_lam_dyn
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Elam_dyn
    (lin, npf, p2ts_arg, d2e_body) => let
    val fc0 = FUNCLOfun () // default
    val s2ep3tsd3e =
      d2exp_trup_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
    val s2e_fun = s2ep3tsd3e.0
    val p3ts_arg = s2ep3tsd3e.1
    val d3e_body = s2ep3tsd3e.2
  in
    d3exp_linheap_check
      (d3exp_lam_dyn (loc0, s2e_fun, lin, npf, p3ts_arg, d3e_body))
    // end of [d3exp_linheap_check]
  end // end of [D2Elam_dyn]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_lam_dyn]

(* ****** ****** *)

implement
d2exp_trup_laminit_dyn
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Elaminit_dyn
    (lin, npf, p2ts_arg, d2e_body) => let
    val fc0 = FUNCLOclo (0) // default
    val s2ep3tsd3e =
      d2exp_trup_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
    val s2e_fun = s2ep3tsd3e.0
    val p3ts_arg = s2ep3tsd3e.1
    val d3e_body = s2ep3tsd3e.2
    val () = (
      case+ s2exp_node_view (s2e_fun.s2exp_node ()) of
      | ~S2Efun
        (
          fc, _, _, _, _, _
        ) =>
        (
        case+ fc of
        | FUNCLOclo0 () => () // [CLO]
        | _ (*non-FUNCLOclo(0)*) => let
           val () =
           prerr_error3_loc(loc0)
           val () =
           filprerr_ifdebug("d2exp_trup_laminit_dyn")
           val () = prerr
             (": the initializing value is expected to be a flat closure but it is not.")
           val () = prerr_newline ()
         in
           the_trans3errlst_add(trans3err_T3E_d2exp_trup_laminit_funclo(d2e0, fc))
         end // end of [_]
        ) // end of [S2Efun]
      | v (* non-S2Efun *) => ( s2exp_node_view_free (v) (*deadcode*) )
    ) : void // end of [val]
  in
    d3exp_laminit_dyn(loc0, s2e_fun, lin, npf, p3ts_arg, d3e_body)
  end // end of [D2Elaminit_dyn]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_laminit_dyn]

(* ****** ****** *)

implement
d2exp_trup_lam_sta
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Elam_sta (s2vs, s2ps, d2e_body) => let
//
    val () = trans3_env_push ()
    val () = trans3_env_add_svarlst (s2vs)
    val () = trans3_env_hypadd_proplst (loc0, s2ps)
//
    val d3e_body = d2exp_trup (d2e_body)
//
    val () = trans3_env_pop_and_add_main (loc0)
//
    val s2e = d3e_body.d3exp_type ()
    val s2e_uni = s2exp_uni (s2vs, s2ps, s2e)
  in
    d3exp_lam_sta (loc0, s2e_uni, s2vs, s2ps, d3e_body)
  end // end of [D2Elam_sta]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_lam_sta]

(* ****** ****** *)

implement
d2exp_trup_lam_met
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Elam_met
    (d2vs_ref, s2es_met, d2e_body) => let
    val () = s2explst_check_termet (loc0, s2es_met)
    val () = termetenv_push_dvarlst (d2vs_ref.d2varlstref_val (), s2es_met)
    val d3e_body = d2exp_trup (d2e_body)
    val () = termetenv_pop ()
  in
    d3exp_lam_met (loc0, s2es_met, d3e_body)
  end // end of [D2Elam_met]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_lam_met]

(* ****** ****** *)

local

fun
s2exp_clo2fun
  (s2e0: s2exp): s2exp = let
in
//
case+ s2exp_node_view (s2e0.s2exp_node ()) of
| ~S2Efun
  (
    fc, lin, s2fe, npf, s2es_arg, s2e_res
  ) =>
    s2exp_fun_srt (s2e0.s2exp_srt (), FUNCLOfun, lin, s2fe, npf, s2es_arg, s2e_res)
| v (*non-S2Efun*) => (s2exp_node_view_free (v); s2e0)
//
end // end of [s2exp_clo2fun]

in (* in-of-local *)

implement
d2exp_trup_fix (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Efix (knd, d2v, d2e_def) => let
    val s2e_def = d2exp_syn_type (d2e_def)
    val s2e2_def = s2exp_clo2fun (s2e_def)
//
    val s2e2opt_def = gopt_some (s2e2_def)
    val () = d2var_set_type (d2v, s2e2opt_def)
    val () = d2var_set_mastype (d2v, s2e2opt_def)
//
    val d3e_def = d2exp_trup (d2e_def)
//
  in
    d3exp_fix (loc0, s2e_def, knd, d2v, d3e_def)
  end // end of [D2Efix]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_fix]

end // end of [local]

(* ****** ****** *)

implement
d2exp_trup_delay
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Edelay (d2e_eval) => let
    val fc0 = FUNCLOfun () // HX: this is ignored
    val lin = 0
    val npf = ~1
    val p2ts_arg = glist_nil{p2at} ()
    val s2ep3tsd3e =
      d2exp_trup_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_eval)
    val s2e_fun = s2ep3tsd3e.0
    val p3ts_arg = s2ep3tsd3e.1
    val d3e_eval = s2ep3tsd3e.2
//
    val s2e_eval = d3exp_get_type (d3e_eval)
//
// HX-2026-10: no GC
// [$delay] is always rejected by [d3exp_linheap_check];
// the type assigned here is only for error recovery
//
    val s2e_lazy = s2exp_lazy_vt0ype_vtype (s2e_eval)
//
  in
    d3exp_linheap_check (d3exp_delay (loc0, s2e_lazy, d3e_eval))
  end // end of [D2Edelay]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_delay_trup]

(* ****** ****** *)

implement
d2exp_trup_ldelay
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Eldelay (d2e_eval, opt) => let
//
    val lsbis =
      the_d2varenv_save_lstbefitmlst ()
    val lsaft = lstaftc3nstr_initize (lsbis)
//
    val loc_eval = d2e_eval.d2exp_loc ()
    val ctr = c3nstroptref_make_none (loc_eval)
    val d3e_eval = let
      val () = trans3_env_push ()
      val d3e_eval = d2exp_trup (d2e_eval)
      val () = trans3_env_add_cnstr_ref (ctr)
      val () = trans3_env_pop_and_add_main (loc_eval)
    in
      d3e_eval
    end // end of [val]
    val () = lstaftc3nstr_update (lsaft, ctr)
//
    val () = lstbefitmlst_restore_type (lsbis)
//
    val d2e_free =
    (
    case+ gopt_view (opt) of
    | ~GOsome(d2e) => d2e
    | ~GOnone() => d2exp_empty(loc_eval)
    ) : d2exp // end of [val]
//
    val loc_free = d2e_free.d2exp_loc ()
    val ctr = c3nstroptref_make_none (loc_free)
    val d3e_free = let
      val () = trans3_env_push ()
      val s2e_void = s2exp_void_t0ype ((*void*))
      val d3e_free = d2exp_trdn (d2e_free, s2e_void)
      val () = trans3_env_add_cnstr_ref (ctr)
      val () = trans3_env_pop_and_add_main (loc_free)
    in
      d3e_free
    end // end of [val]
    val () = lstaftc3nstr_update (lsaft, ctr)
//
    val invres = i2nvresstate_nil
//
    val () =
      lstaftc3nstr_process (lsaft, invres)
    val () = lstaftc3nstr_finalize (lsaft)
//
    val () = i2nvresstate_update (loc0, invres)
//
    val s2e_eval = d3exp_get_type (d3e_eval)
    val s2e_lazy = s2exp_lazy_vt0ype_vtype (s2e_eval)
//
  in
    d3exp_ldelay (loc0, s2e_lazy, d3e_eval, d3e_free)
  end // end of [D2Eldelay]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_ldelay]

(* ****** ****** *)

implement
d2exp_trup_for (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Efor (i2nv, init, test, post, body) =>
    d2exp_trup_loop (loc0, i2nv, gopt_some(init), test, gopt_some(post), body)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_for]

implement
d2exp_trup_while (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Ewhile (i2nv, test, body) =>
    d2exp_trup_loop (loc0, i2nv, gopt_none((*init*)), test, gopt_none((*post*)), body)
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_while]

(* ****** ****** *)

implement
d2exp_trup_trywith
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Etrywith (r2es, d2e, c2ls) => let
    val d3e = d2exp_trup (d2e)
    val s2e_res = d3exp_get_type (d3e)
//
    val () = the_d2varenv_push_try ()
    val () = the_pfmanenv_push_try ()
//
    val s2e_pat =
      s2exp_exception_vtype ()
    // end of [val]
//
    val loc = d3e.d3exp_loc ()
    val d3e_dummy = d3exp_top (loc, s2e_pat)
    val d3es = glist_sing (d3e_dummy)
//
    val s2es_pat = glist_sing (s2e_pat)
//
    val c3ls = c2laulst_trdn (
      loc0, CK_case_neg, r2es, c2ls, d3es, s2es_pat, s2e_res
    ) // end of [val]
//
    val ((*void*)) = the_d2varenv_pop ()
    val ((*void*)) = the_pfmanenv_pop ()
//
  in
    d3exp_trywith (loc0, d3e, c3ls)
  end // end of [D2Etrywith]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_trywith]

(* ****** ****** *)

implement
d2exp_trup_mac
  (d2e0) = let
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Emac (d2m) => let
    val d2e_mac =
      $MAC.dmacro_eval_app_short (d2e0.d2exp_loc (), d2m, glist_nil{d2exparg}((*d2as*)))
    // end of [val]
  in
    d2exp_trup (d2e_mac)
  end // end of [D2Emac]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [D2Emac]

implement
d2exp_trup_macsyn
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Emacsyn (knd, d2e) => let
//
    val d2e_mac = (
    //
    case+ knd of
    | $SYN.MSKdecode () => $MAC.dmacro_eval_decode (d2e)
    | $SYN.MSKxstage () => $MAC.dmacro_eval_xstage (d2e)
    | $SYN.MSKencode () => let
        val () =
        prerr_errmac_loc(loc0)
        val () = prerr ": the macro syntax `(...) is used incorrectly."
        val () = prerr_newline ()
      in
        d2exp_errexp (loc0)
      end // end of [MSKINDencode]
    //
    ) : d2exp // end of [val]
//
  in
    d2exp_trup (d2e_mac)
  end // end of [D2Emacsyn]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_macsyn]

(* ****** ****** *)

implement
d2exp_trup_solassert
  (d2e0) = let
//
val
loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Esolassert (d2e_prf) => let
    val d3e_prf = d2exp_trup(d2e_prf)
    val s2e_prop = d3exp_get_type(d3e_prf)
//
    val ((*added*)) = trans3_env_solver_assert (loc0, s2e_prop)
//
  in
    d3exp_empty (loc0, s2exp_void_t0ype())
  end // end of [D2Esolassert]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [D2Esolassert]

(* ****** ****** *)

implement
d2exp_trup_solverify
  (d2e0) = let
//
val
loc0 = d2e0.d2exp_loc ()
//
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Esolverify (s2e_prop) => let
    val s2f_prop = s2exp_hnfize(s2e_prop)
//
    val ((*added*)) = trans3_env_solver_verify (loc0, s2f_prop)
//
  in
    d3exp_solverify (loc0, s2f_prop)
  end // end of [D2Esolverify]
| v => (d2exp_node_view_free (v); $ERR.abort_interr<d3exp> ((*MatchError*)))
//
end // end of [d2exp_trup_solverify]

(* ****** ****** *)

(* end of [pats_trans3_dynexp_up.dats] *)
