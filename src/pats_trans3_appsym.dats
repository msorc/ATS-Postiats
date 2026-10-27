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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_appsym.dats, see PORTING.md,
// "Level 3 translation, group 2 (dynexp_dn/appsym/caseof/patcon)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload
_(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
(
  // argless
) =
  prerr "pats_trans3_appsym"
//
(* ****** ****** *)

staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

staload "./pats_trans3_appsym.sats"
#include "./pats_trans3_appsym_gen_dats.hats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

extern
fun aritest_d2exparglst_s2exp
  (d2as: d2exparglst, s2e: s2exp): bool
(*
** HX: for handling dynamic overloading
*)
local
//
fun loop
(
  d2as: d2exparglst
, s2e: s2exp, npf: int, d2es: d2explst
) : bool = let
  val s2e = s2exp_hnfize (s2e)
in
  case+ s2exp_node_view(s2e.s2exp_node()) of
  | ~S2Efun
    (
      _(*fc*), _(*lin*), _(*eff*), npf1, s2es_arg, s2e_res
    ) =>
      if (npf = npf1) then let
        // HX: [list_length_compare (d2es, s2es_arg)] of ATS1
        val sgn =
          glist_length (d2es) = glist_length (s2es_arg) in
        // end of [val]
        if sgn
          then aritest_d2exparglst_s2exp (d2as, s2e_res) else false
        // end of [if]
      end else false // end of [if]
    // end of [S2Efun]
  | ~S2Eexi (_(*s2vs*), _(*s2ps*), s2e) => loop (d2as, s2e, npf, d2es)
  | ~S2Euni (_(*s2vs*), _(*s2ps*), s2e) => loop (d2as, s2e, npf, d2es)
  | ~S2Emetfun (_(*opt*), _(*met*), s2e) => loop (d2as, s2e, npf, d2es)
  | v => (s2exp_node_view_free (v); false) // end of [_]
end // end of [loop]
//
in // in of [local]

implement
aritest_d2exparglst_s2exp
  (d2as, s2e) = let
in
  case+ glist_view(d2as) of
  | ~GLcons
      (d2a, d2as) => (
    case+ d2exparg_view(d2a) of
    | ~D2EXPARGdyn (
        npf, _(*loc*), d2es
      ) => loop (d2as, s2e, npf, d2es)
    | ~D2EXPARGsta _ =>
        aritest_d2exparglst_s2exp (d2as, s2e)
    ) // end of [list_cons]
  | ~GLnil ((*void*)) => true
end // end of [aritest_d2exparglst_s2exp]

end // end of [local]

(* ****** ****** *)
//
// HX-2026-10: proof-argument elision: the arity test of a candidate
// for a call whose first dynamic arguments have no [|] (npf = ~1) and
// omit the proofs of the candidate (preserved at-views, !T @ l); it is
// only tried when no candidate passes [aritest_d2exparglst_s2exp]
//
fun
s2exp_fun_elide_npf
  (s2e: s2exp): int = let
  val s2e = s2exp_hnfize (s2e)
in
  case+ s2exp_node_view(s2e.s2exp_node()) of
  | ~S2Efun
    (
      _(*fc*), _(*lin*), _(*eff*), npf1, _(*arg*), _(*res*)
    ) => npf1
  | ~S2Eexi (_(*s2vs*), _(*s2ps*), s2e) => s2exp_fun_elide_npf (s2e)
  | ~S2Euni (_(*s2vs*), _(*s2ps*), s2e) => s2exp_fun_elide_npf (s2e)
  | ~S2Emetfun (_(*opt*), _(*met*), s2e) => s2exp_fun_elide_npf (s2e)
  | v => (s2exp_node_view_free (v); 0)
end // end of [s2exp_fun_elide_npf]

fun
aritest_elide_loop
(
  d2as: d2exparglst
, s2e: s2exp, npf: int, d2es: d2explst
) : bool = let
  val s2e = s2exp_hnfize (s2e)
in
  case+ s2exp_node_view(s2e.s2exp_node()) of
  | ~S2Efun
    (
      _(*fc*), _(*lin*), _(*eff*), npf1, s2es_arg, s2e_res
    ) =>
      if (npf < 0 && npf1 > 0) then let
        val sgn =
          glist_length (d2es) + npf1 = glist_length (s2es_arg)
        // end of [val]
      in
        if sgn then (
          if s2explst_elide_test (npf1, s2es_arg) = 0
            then aritest_d2exparglst_s2exp (d2as, s2e_res) else false
          // end of [if]
        ) else false
      end else false // end of [if]
    // end of [S2Efun]
  | ~S2Eexi (_(*s2vs*), _(*s2ps*), s2e) => aritest_elide_loop (d2as, s2e, npf, d2es)
  | ~S2Euni (_(*s2vs*), _(*s2ps*), s2e) => aritest_elide_loop (d2as, s2e, npf, d2es)
  | ~S2Emetfun (_(*opt*), _(*met*), s2e) => aritest_elide_loop (d2as, s2e, npf, d2es)
  | v => (s2exp_node_view_free (v); false) // end of [_]
end // end of [aritest_elide_loop]

fun
aritest_elide_d2exparglst_s2exp
  (d2as: d2exparglst, s2e: s2exp): bool =
(
  case+ glist_view(d2as) of
  | ~GLcons
      (d2a, d2as) => (
    case+ d2exparg_view(d2a) of
    | ~D2EXPARGdyn (
        npf, _(*loc*), d2es
      ) => aritest_elide_loop (d2as, s2e, npf, d2es)
    | ~D2EXPARGsta _ =>
        aritest_elide_d2exparglst_s2exp (d2as, s2e)
    ) // end of [list_cons]
  | ~GLnil ((*void*)) => false
) (* end of [aritest_elide_d2exparglst_s2exp] *)

(* ****** ****** *)

fun
d2exp_trup_item
(
  loc0: $LOC.location, d2i: d2itm, t2mas: t2mpmarglst
) : d3exp = let
in
//
case+ d2itm_view(d2i) of
| ~D2ITMcst d2c => let
    val s2qs =
      d2cst_get_decarg (d2c)
    // end of [val]
    val s2e = d2cst_get_type (d2c)
    val s2e = s2exp_unis (s2qs, s2e)
  in
    d3exp_item (loc0, s2e, d2i, t2mas)
  end
| ~D2ITMvar d2v => let
    val s2qs = d2var_get_decarg (d2v)
    val-~GOsome (s2e) = gopt_view(d2var_get_type (d2v))
    val s2e = s2exp_unis (s2qs, s2e)
  in
    d3exp_item (loc0, s2e, d2i, t2mas)
  end
| v => let
    val () = d2itm_view_free (v)
    val () = prerr_error3_loc (loc0)
    val () = filprerr_ifdebug "d2exp_trup_item"
    val () = prerr_string ": a dynamic constant or variable is expected."
    val () = prerr_newline ()
    val () =  the_trans3errlst_add (trans3err_T3E_d2exp_trup_item (loc0, d2i))
  in
    d3exp_errexp (loc0)
  end // end of [_]
//
end // end of [d2exp_trup_item]

(* ****** ****** *)

fun d3exp_trup_item
  (d3e0: d3exp): d3exp = let
//
val loc0 = d3e0.d3exp_loc()
val-~D3Eitem (d2i, t2mas) = d3exp_node_view(d3e0.d3exp_node())
val isnil = glist_is_nil (t2mas)
//
in
//
case+ d2itm_view(d2i) of
| ~D2ITMcst d2c => (
    if isnil then
      d2exp_trup_cst (loc0, d2c)
    else
      d2exp_trup_tmpcst (loc0, d2c, t2mas)
    // end of [if]
  ) // end of [D2ITMcst]
| ~D2ITMvar d2v => (
    if isnil then
      d2exp_trup_var (loc0, d2v)
    else
      d2exp_trup_tmpvar (loc0, d2v, t2mas)
    // end of [if]
  ) // end of [D2ITMvar]
| v => let
    val () = d2itm_view_free (v)
    val () = assertloc (false) in d3exp_errexp (loc0)
  end // end of [_]
//
end // end of [d3exp_trup_item]

(* ****** ****** *)
//
// HX-2026-10: [d3pitm] is the record of pats_trans3_appsym.spec
//
fun
d3pitm_make
(
  pval: int, d3e: d3exp
) : d3pitm = d3pitm_new(pval, d3e)
// end of [d3pitm_make]

fun
d3pitm_get_dexp
(
  d3pi: d3pitm
) : d3exp = d3pitm_dexp(d3pi)
// end of [d3pitm_get_dexp]

fun
d3pitm_get_type
(
  d3pi: d3pitm
) : s2exp = let
  val d3e = d3pitm_dexp(d3pi) in d3e.d3exp_type()
end // end of [d3pitm_get_type]

fun
d3pitm_get_pval
(
  d3pi: d3pitm
) : int = d3pitm_pval(d3pi)
// end of [d3pitm_get_pval]

fun
fprint_d3pitm
(
  out: FILEref, x: d3pitm
) : void = let
  val pval = d3pitm_pval(x)
  val d3e = d3pitm_dexp(x)
  val-~D3Eitem
    (d2i, t2mas) = d3exp_node_view(d3e.d3exp_node())
  val () = fprint_d2itm (out, d2i)
  val () = fprint_string (out, " of ")
  val () = fprint_int (out, pval)
in
  // nothing
end // end of [fprint_d3pitm]

(* ****** ****** *)

extern
fun
d3exp_trup_applst
(
  d2e0: d2exp, d3e_fun: d3exp, d3as: d3exparglst
) : d3exp // end of [d3exp_trup_applst]
implement
d3exp_trup_applst
  (d2e0, d3e_fun, d3as) = let
  val loc0 = d2e0.d2exp_loc()
in
//
case+ glist_view(d3as) of
//
| ~GLcons (d3a, d3as) => (
  case+ d3exparg_view(d3a) of
  | ~D3EXPARGsta
      (locarg, s2as) => let
      val loc_fun = d3e_fun.d3exp_loc()
      val s2e_fun = d3e_fun.d3exp_type()
      var err: int = 0
      val @(s2e_fun, s2ps) =
        s2exp_uni_instantiate_sexparglst (s2e_fun, s2as, err)
      // end of [val]
      val () = trans3_env_add_proplst_vt (loc_fun, s2ps)
      val d3e_fun = d3exp_app_sta (loc0, s2e_fun, d3e_fun)
    in
      d3exp_trup_applst (d2e0, d3e_fun, d3as)
    end // end of [D3EXPARGsta]
  | ~D3EXPARGdyn
      (npf, locarg, d3es_arg) => let
      val loc_fun = d3e_fun.d3exp_loc()
      val s2e_fun = d3e_fun.d3exp_type()
      val () = d3explst_open_and_add (d3es_arg)
      var err: int = 0
      val @(s2e_fun, s2ps) =
        s2exp_unimet_instantiate_all (s2e_fun, locarg, err)
      // HX: [err] is not used
      val () = trans3_env_add_proplst_vt (loc_fun, s2ps)
      val d3e_fun = d3exp_app_unista (loc0, s2e_fun, d3e_fun)
      val-~S2Efun (
        fc, _(*lin*), s2fe_fun, npf_fun, s2es_fun_arg, s2e_fun_res
      ) = s2exp_node_view(s2e_fun.s2exp_node()) // end of[val]
//
// HX-2026-10: proof-argument elision: the call has no [|] and the
// candidate was selected by [aritest_elide_d2exparglst_s2exp] (the
// other arity test requires npf = npf_fun)
//
      val elide = (npf < 0 && npf_fun > 0): bool
//
      val loc_app = $LOC.location_combine (loc_fun, locarg)
      val s2es_fun_arg =
        s2fun_opninv_and_add (locarg, s2es_fun_arg, s2e_fun_res)
      val d3es_arg =
      (
        if elide
          then let
            val s2es_dyn =
              s2explst_elide_drop (npf_fun, s2es_fun_arg)
            val d3es_dyn = d3explst_trdn_arg (d3es_arg, s2es_dyn)
            val d3es_pf =
              d3explst_elide_proofs (locarg, npf_fun, s2es_fun_arg)
            // end of [val]
          in
            glist_append (d3es_pf, d3es_dyn)
          end // end of [then]
          else d3explst_trdn_arg (d3es_arg, s2es_fun_arg)
        // end of [if]
      ) : d3explst // end of [val]
      val npf = (if elide then npf_fun else npf): int
//
      val @(
        iswth, s2e_res, wths2es
      ) = un_s2exp_wthtype (loc_app, s2e_fun_res)
//
      val d3e_fun = d3exp_fun_restore (fc, d3e_fun)
      val d3es_arg =
      (
        if iswth
          then d3explst_arg_restore (d3es_arg, s2es_fun_arg, wths2es)
          else d3es_arg
        // end of [if]
      ) : d3explst // end of [val]
//
      val err = the_effenv_check_s2eff (loc_app, s2fe_fun)
      val (
      ) = if (err > 0) then (
        the_trans3errlst_add (trans3err_T3E_d3exp_trup_applst_eff (loc_app, s2fe_fun))
      ) // end of [if] // end of [val]
//
      val d3e_fun = d3exp_app_dyn (loc0, s2e_res, d3e_fun, npf, d3es_arg)
    in
      d3exp_trup_applst (d2e0, d3e_fun, d3as)
    end // end of [D3EXPARGdyn]
  ) (* end of [list_cons] *)
//
| ~GLnil ((*void*)) => d3e_fun // end of [list_nil]
//
end // end of [d3exp_trup_applst]

(* ****** ****** *)

local

(* ****** ****** *)

typedef XY = @(d3pitm, s2kexp)

(* ****** ****** *)

fun
auxsel_arity
(
  locsym: $LOC.location
, d2pis: d2pitmlst
, d2piss: List0_vt(d2pitmlst)
, t2mas: t2mpmarglst
, d2args: d2exparglst
, elide: int // HX-2026-10: 1: the arity test of proof elision
) : d3pitmlst_vt = let
in
//
case+ glist_view(d2pis) of
| ~GLnil
    ((*void*)) =>
  (
  case+ d2piss of
  | ~list_vt_nil() => list_vt_nil ()
  | ~list_vt_cons(d2pis, d2piss) =>
      auxsel_arity (locsym, d2pis, d2piss, t2mas, d2args, elide)
    // end of [list_cons]
  ) (* end of [list_nil] *)
| ~GLcons
    (d2pi, d2pis) => let
    val ~D2PITM (pval, d2i) = d2pitm_view(d2pi)
  in
    case+ d2itm_view(d2i) of
    | ~D2ITMsymdef
        (_(*sym*), d2pis_new) => let
        val d2piss = list_vt_cons (d2pis, d2piss)
      in
        auxsel_arity (locsym, d2pis_new, d2piss, t2mas, d2args, elide)
      end // end of [D2ITMsymdef]
    | v => let
        val () = d2itm_view_free (v)
        val d3e = d2exp_trup_item(locsym, d2i, t2mas)
        val test =
        (
          if elide = 0
            then aritest_d2exparglst_s2exp(d2args, d3e.d3exp_type())
            else aritest_elide_d2exparglst_s2exp(d2args, d3e.d3exp_type())
          // end of [if]
        ) : bool // end of [val]
        val d3pis = auxsel_arity(locsym, d2pis, d2piss, t2mas, d2args, elide)
      in
        if test then let
          val d3pi = d3pitm_make(pval, d3e) in list_vt_cons(d3pi, d3pis)
        end else d3pis // end of [if]
      end // end of [_]
  end // end of [list_cons]
//
end // end of [auxsel_arity]

fun
auxsel_skexplst
(
  xys: List0_vt(XY)
, s2kes: s2kexplst
) : List0_vt(XY) = let
in
//
case+ xys of
| ~list_vt_nil() =>
    list_vt_nil((*void*))
  // list_vt_nil
| ~list_vt_cons(xy, xys) =>
  (
  case+ s2kexp_view(xy.1) of
  | ~S2KEfun
    (
      s2kes_arg, s2ke_res
    ) => let
      val ismat =
        s2kexplst_ismat(s2kes, s2kes_arg)
      // end of [val]
      val x = @(xy.0, s2ke_res)
      val xs = auxsel_skexplst(xys, s2kes)
    in
      if ismat then list_vt_cons (x, xs) else xs
    end // end of [list_vt_cons]
  | v (*non-S2KEfun*) =>
      (s2kexp_view_free(v); auxsel_skexplst(xys, s2kes))
  ) (* end of [list_vt_cons] *)
//
end // end of [auxsel_skexplst]

fun
auxmap_loop
(
  xys: List0_vt(XY), res: List0_vt(d3pitm)
) : List0_vt(d3pitm) =
(
case+ xys of
| ~list_vt_nil
    ((*void*)) => list_vt_reverse(res)
| ~list_vt_cons
    (xy, xys) => auxmap_loop(xys, list_vt_cons(xy.0, res))
) (* end of [auxmap_loop] *)

// HX: [auxmap] of ATS1 (the order of the list is kept)
fun
auxmap
(xys: List0_vt(XY)): d3pitmlst =
  l2l(auxmap_loop(xys, list_vt_nil()))

// HX: [list_map_fun<d3exp><s2kexp>(d3es, lam d3e => s2kexp_make_s2exp(d3e.d3exp_type))]
fun
auxmap_s2kexp
(
  d3es: d3explst, res: List0_vt(s2kexp)
) : s2kexplst =
(
case+ glist_view(d3es) of
| ~GLnil((*void*)) => l2l(list_vt_reverse(res))
| ~GLcons(d3e, d3es) => let
    val s2ke = s2kexp_make_s2exp(d3e.d3exp_type())
  in
    auxmap_s2kexp(d3es, list_vt_cons(s2ke, res))
  end // end of [GLcons]
) (* end of [auxmap_s2kexp] *)

fun
auxsel_arglst
(
  xys: List0_vt(XY)
, d2as: d2exparglst, d3as: d3exparglst_vt
) : @( d3pitmlst, d3exparglst, d2exparglst ) = let
//
in
//
case+ glist_view(d2as) of
| ~GLnil() => let
    val d3as =
      list_vt_reverse(d3as)
    // end of [val]
  in
    @(auxmap(xys), l2l(d3as), glist_nil())
  end // end of [list_nil]
| ~GLcons(d2a, d2as1) => let
    // HX: [d2as] is the whole list (shared), [d2as1] its tail
  in
  case+ xys of
  | ~list_vt_nil
      ((*void*)) => let
      val d3as =
        list_vt_reverse (d3as)
      // end of [val]
    in
      @(glist_nil(), l2l(d3as), d2as)
    end // end of [list_vt_nil]
  | ~list_vt_cons
      (xy, xys1) => (
    case+ xys1 of
    | ~list_vt_nil () => let
        val d3as = list_vt_reverse(d3as)
      in
        @(glist_sing(xy.0), l2l(d3as), d2as)
      end
    | xys1 => let
        val xys = list_vt_cons(xy, xys1)
      in
        case+ d2exparg_view(d2a) of
        | ~D2EXPARGsta
            (locarg, s2as) => let
            val d3a = d3exparg_D3EXPARGsta(locarg, s2as)
          in
            auxsel_arglst(xys, d2as1, list_vt_cons(d3a, d3as))
          end (* D2EXPARGsta *)
        | ~D2EXPARGdyn
            (npf, locarg, d2es) => let
            val d3es = d2explst_trup (d2es)
            val s2kes = auxmap_s2kexp (d3es, list_vt_nil())
            val xs = auxsel_skexplst(xys, s2kes)
            val d3a = d3exparg_D3EXPARGdyn (npf, locarg, d3es)
          in
            auxsel_arglst (xs, d2as1, list_vt_cons (d3a, d3as))
          end (* D2EXPARGdyn *)
      end // end of [_]
    ) // end of [list_vt_cons]
  end // end of [list_cons]
//
end // end of [auxsel_arglst]

#define ITMPVALMIN ~1000000

fun
auxselmax_max
(
xs: d3pitmlst, mpval: int
) : int =
(
case+ glist_view(xs) of
| ~GLnil() => mpval
| ~GLcons(x, xs) => let
    val pval = d3pitm_get_pval(x)
  in
    auxselmax_max(xs, (if mpval < pval then pval else mpval))
  end
) (* end of [auxselmax_max] *)

// HX: [list_filter_cloptr] of ATS1 (head first, the order is kept)
fun
auxselmax_filter
(
xs: d3pitmlst, mpval: int, res: List0_vt(d3pitm)
) : List0_vt(d3pitm) =
(
case+ glist_view(xs) of
| ~GLnil() => list_vt_reverse(res)
| ~GLcons(x, xs) =>
    if d3pitm_get_pval(x) = mpval
      then auxselmax_filter(xs, mpval, list_vt_cons(x, res))
      else auxselmax_filter(xs, mpval, res)
    // end of [if]
) (* end of [auxselmax_filter] *)

fun
auxselmax
(
  d3pis: d3pitmlst
) : d3pitmlst = let
//
val
mpval = auxselmax_max(d3pis, ITMPVALMIN)
val
d3pis =
auxselmax_filter(d3pis, mpval, list_vt_nil())
//
in
  l2l(d3pis)
end // end of [auxselmax]

fun
auxeq_d2itm
(
  d2i1: d2itm
, d2i2: d2itm
) : bool =
(
case+ d2itm_view(d2i1) of
| ~D2ITMcst(d2c1) =>
  (
  case+ d2itm_view(d2i2) of
  | ~D2ITMcst(d2c2) => (d2c1 = d2c2)
  | v => (d2itm_view_free(v); false)
  )
| ~D2ITMvar(d2v1) =>
  (
  case+ d2itm_view(d2i2) of
  | ~D2ITMvar(d2v2) => (d2v1 = d2v2)
  | v => (d2itm_view_free(v); false)
  )
| v (* rest-of-d2itm *) => (d2itm_view_free(v); false)
) (* end of [auxeq_d2itm] *)


fun
auxeq_d3pitm
(
  d3pi1: d3pitm
, d3pi2: d3pitm
) : bool = let
//
val d3e1 = d3pitm_get_dexp(d3pi1)
val d3e2 = d3pitm_get_dexp(d3pi2)
//
in
//
case+
d3exp_node_view(d3e1.d3exp_node())
of (* case+ *)
| ~D3Eitem(d2i1, _) =>
  (
  case+
  d3exp_node_view(d3e2.d3exp_node())
  of (* case+ *)
  | ~D3Eitem(d2i2, _) => auxeq_d2itm(d2i1, d2i2)
  | v => (d3exp_node_view_free(v); false)
  )
| v (*non-D3Eitem*) => (d3exp_node_view_free(v); false)
//
end // end of [auxeq_d3pitm]

// HX: [list_filter_cloptr (d3pis, lam(x) => ~auxeq_d3pitm(d3pi0, x))]
fun
auxeq_d3pitm_filter
(
  d3pi0: d3pitm, xs: d3pitmlst, res: List0_vt(d3pitm)
) : List0_vt(d3pitm) =
(
case+ glist_view(xs) of
| ~GLnil() => list_vt_reverse(res)
| ~GLcons(x, xs) =>
    if ~auxeq_d3pitm(d3pi0, x)
      then auxeq_d3pitm_filter(d3pi0, xs, list_vt_cons(x, res))
      else auxeq_d3pitm_filter(d3pi0, xs, res)
    // end of [if]
) (* end of [auxeq_d3pitm_filter] *)

fun
auxeq_d3pitm_remdup
(
  d3pis: d3pitmlst
) : d3pitmlst =
(
case+ glist_view(d3pis) of
| ~GLnil() => glist_nil()
| ~GLcons(d3pi0, d3pis) => let
    val
    d3pis =
    auxeq_d3pitm_filter(d3pi0, d3pis, list_vt_nil())
    // end of [val]
  in
    glist_cons(d3pi0, l2l(d3pis))
  end
) (* end of [auxeq_d3pitm_remdup] *)

// HX: [fopr] of ATS1 mapped over [d3pis] (head first)
fun
auxmap_xy
(
  d3pis: d3pitmlst, res: List0_vt(XY)
) : List0_vt(XY) =
(
case+ glist_view(d3pis) of
| ~GLnil() => list_vt_reverse(res)
| ~GLcons(d3pi, d3pis) => let
    val s2e =
      d3pitm_get_type(d3pi)
    // end of [val]
    val xy = @(d3pi, s2kexp_make_s2exp(s2e))
  in
    auxmap_xy(d3pis, list_vt_cons(xy, res))
  end // end of [GLcons]
) (* end of [auxmap_xy] *)

// HX-2026-10: the omitted proofs are dropped from the arguments
fun
s2kexp_elide_drop
  (n: int, s2kes: s2kexplst): s2kexplst =
(
  if n > 0 then (
    if glist_is_cons (s2kes)
      then s2kexp_elide_drop (n-1, glist_tail (s2kes)) else s2kes
    // end of [if]
  ) else s2kes
) (* end of [s2kexp_elide_drop] *)

fun
auxmap_xy_elide
(
  d3pis: d3pitmlst, res: List0_vt(XY)
) : List0_vt(XY) =
(
case+ glist_view(d3pis) of
| ~GLnil() => list_vt_reverse(res)
| ~GLcons(d3pi, d3pis) => let
    val s2e =
      d3pitm_get_type(d3pi)
    // end of [val]
    val npf1 = s2exp_fun_elide_npf (s2e)
    val s2ke = s2kexp_make_s2exp(s2e)
    val s2ke =
    (
      case+ s2kexp_view(s2ke) of
      | ~S2KEfun (s2kes_arg, s2ke_res) =>
          s2kexp_S2KEfun (s2kexp_elide_drop (npf1, s2kes_arg), s2ke_res)
      | v => (s2kexp_view_free (v); s2ke)
    ) : s2kexp // end of [val]
    val xy = @(d3pi, s2ke)
  in
    auxmap_xy_elide(d3pis, list_vt_cons(xy, res))
  end // end of [GLcons]
) (* end of [auxmap_xy] *)

in (* in of [local] *)

implement
d2exp_trup_applst_sym
  (d2e0, d2s, d2as) = let
//
val t2mas = glist_nil((*void*))
//
in
  d2exp_trup_applst_tmpsym(d2e0, d2s, t2mas, d2as)
end // end of [d2exp_trup_applst_sym]

implement
d2exp_trup_applst_tmpsym
  (d2e0, d2s, t2mas, d2as) = let
val
loc0 = d2e0.d2exp_loc()
val
locsym = d2s.d2sym_loc()
//
val
d2pis = d2s.d2sym_pitmlst()
val
d3pis =
auxsel_arity
  (locsym, d2pis, list_vt_nil, t2mas, d2as, 0)
//
// HX-2026-10: when no candidate has the arity of the call, the
// candidates whose proofs can be omitted (proof-argument elision)
val elide = (if list_vt_is_nil (d3pis) then 1 else 0): int
val d3pis =
(
  if elide = 0 then d3pis else let
    val () = list_vt_free (d3pis)
  in
    auxsel_arity (locsym, d2pis, list_vt_nil, t2mas, d2as, 1)
  end // end of [else]
) : d3pitmlst_vt // end of [val]
//
// HX: the items of [d3pis] are shared (arena records)
val d3pis = l2l(d3pis)
val xys =
(
  if elide = 0
    then auxmap_xy (d3pis, list_vt_nil())
    else auxmap_xy_elide (d3pis, list_vt_nil())
  // end of [if]
) : List0_vt(XY) // end of [val]
//
val @(d3pis, d3as, d2as_rest) = auxsel_arglst(xys, d2as, list_vt_nil)
//
val d3pis = auxselmax(d3pis)
//
// HX-2017-02-12:
// For removing duplicates of
// overloaded dyncsts and dynvars
val d3pis = auxeq_d3pitm_remdup(d3pis)
//
in
//
case+ glist_view(d3pis) of
//
| ~GLnil
  (
    (*void*)
  ) => let
    val () =
      prerr_error3_loc (loc0)
    // end of [val]
    val () = prerr_string ": the symbol [";
    val () = fprint_d2sym(stderr_ref, d2s)
    val () = prerr_string "] cannot be resolved as no match is found."
    val () = prerr_newline((*void*))
    val () =
    the_trans3errlst_add
      (trans3err_T3E_d2exp_trup_applst_sym_nil(d2e0, d2s))
    // end of [val]
  in
    d3exp_errexp(loc0)
  end // end of [list_nil]
//
| ~GLcons (d3pi, d3pis_rest) =>
  (
  case+ glist_view(d3pis_rest) of
  | ~GLnil() => let
      val d3e_fun = d3pitm_get_dexp(d3pi)
      val d3e_fun = d3exp_trup_item(d3e_fun)
      val d3e_fun = d3exp_trup_applst(d2e0, d3e_fun, d3as)
    in
      d23exp_trup_applst(d2e0, d3e_fun, d2as_rest)
    end // end of [list_sing]
  | ~GLcons(d3pi2, _) => let
      val d3pi1 = d3pi
      val () = prerr_error3_loc(loc0)
      val () = prerr_string ": the symbol [";
      val () = fprint_d2sym(stderr_ref, d2s)
      val () = prerr_string "] cannot be resolved due to too many matches:\n"
      val () = fprint_d3pitm(stderr_ref, d3pi1)
      val () = prerr_newline()
      val () = fprint_d3pitm(stderr_ref, d3pi2)
      val () = prerr_newline()
      val () =
        the_trans3errlst_add (trans3err_T3E_d2exp_trup_applst_sym_cons2(d2e0, d2s))
      // end of [val]
    in
      d3exp_errexp (loc0)
    end // end of [list_cons2]
  ) (* end of [GLcons] *)
//
end // end of [d2exp_trup_applst_tmpsym]
//
end // end of [local]

(* ****** ****** *)

local

fun
auxins
(
  npf: int
, d2e_rt: d2exp, d2es: d2explst
) : d2explst =
(
if npf > 0
  then let
    val () = assertloc (glist_is_cons (d2es)) // HX: val-list_cons (d2e, d2es) = d2es
    val d2e = glist_head (d2es)
    val d2es = glist_tail (d2es)
  in
    glist_cons (d2e, auxins (npf-1, d2e_rt, d2es))
  end // end of [then]
  else glist_cons (d2e_rt, d2es)
// end of [if]
)

fun
auxins2
(
  d2e0: d2exp
, d2e_rt: d2exp, d2as: d2exparglst
) : d2exparglst =
(
case+ glist_view(d2as) of
//
| ~GLnil() => let
    val d2a =
      d2exparg_D2EXPARGdyn(~1(*npf*), d2e0.d2exp_loc(), glist_sing(d2e_rt))
    // end of [val]
  in
    glist_sing (d2a)
  end // end of [list_nil]
//
| ~GLcons(d2a, d2as) =>
  (
    case+ d2exparg_view(d2a) of
    | ~D2EXPARGsta _ =>
        glist_cons(d2a, auxins2 (d2e0, d2e_rt, d2as))
    | ~D2EXPARGdyn(npf, loc_arg, d2es) => let
        val d2a =
          d2exparg_D2EXPARGdyn(npf, loc_arg, auxins (npf, d2e_rt, d2es))
        // end of [val]
      in
        glist_cons(d2a, d2as)
      end // end of [D2EXPARGdyn]
  ) (* end of [list_cons] *)
//
) (* end of [auxins2] *)

in (* in-of-local *)

implement
d2exp_trup_applst_seloverld
  (d2e0, d2e_fun, d2s, d2as_arg) = let
//
val
d2e_rt =
d2exp_get_seloverld_root(d2e_fun)
val
d2as_arg = auxins2(d2e0, d2e_rt, d2as_arg)
//
in
  d2exp_trup_applst_sym(d2e0, d2s, d2as_arg)
end // end of [d2exp_trup_applst_seloverld]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_appsym.dats] *)
