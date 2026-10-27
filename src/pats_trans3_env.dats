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
// Start Time: October, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The only .dats that includes [pats_trans3_env_gen_dats.hats] (the other pats_trans3_env_*.dats use the sats).
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

staload
UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"
vtypedef charlst_vt = $UT.charlst_vt
macdef charset_listize = $UT.charset_listize

(* ****** ****** *)

staload
INTINF = "./pats_intinf.sats"
vtypedef intinflst_vt = $INTINF.intinflst_vt
macdef intinfset_listize = $INTINF.intinfset_listize

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload GLOB = "./pats_global.sats"
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_env"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
staload
LAB = "./pats_label.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_sprint.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_stacst2.sats"
staload "./pats_patcst2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

#include "./pats_trans3_env_gen_dats.hats"

(* ****** ****** *)

implement
c3nstr_prop
  (loc, s2e) = c3nstr_new (
  loc, c3nstrkind_C3TKmain(), c3nstr_node_C3NSTRprop(s2e)
) // end of [c3nstr_prop]

implement
c3nstr_itmlst
  (loc, knd, s3is) = c3nstr_new (
  loc, knd, c3nstr_node_C3NSTRitmlst (s3is)
) // end of [c3nstr_itmlst]

implement
c3nstr_case_exhaustiveness
  (loc, casknd, p2tcs) = let
  val p2tcs = p2atcstlst_of_vt (p2tcs)
in c3nstr_new (
  loc
, c3nstrkind_C3TKcase_exhaustiveness (casknd, p2tcs)
, c3nstr_node_C3NSTRprop(s2exp_bool(false))
) end // end of [c3nstr_case_exhaustiveness]

implement
c3nstr_termet_isnat
  (loc, s2e) = c3nstr_new (
  loc
, c3nstrkind_C3TKtermet_isnat()
, c3nstr_node_C3NSTRprop(s2exp_intgte(s2e, s2exp_int(0)))
) // end of [c3nstr_termet_isnat]

implement
c3nstr_termet_isdec
  (loc, met, mbd) = c3nstr_new (
  loc
, c3nstrkind_C3TKtermet_isdec()
, c3nstr_node_C3NSTRprop(s2exp_metdec(met, mbd))
) // end of [c3nstr_termet_isdec]

(* ****** ****** *)

implement
c3nstr_solverify
  (loc, s2e_prop) = c3nstr_new (
  loc, c3nstrkind_C3TKsolverify(), c3nstr_node_C3NSTRsolverify(s2e_prop)
) // end of [c3nstr_solverify]

(* ****** ****** *)

implement
c3nstroptref_make_none
  (loc) = c3nstroptref_new (loc, gopt_none())
// end of [c3nstroptref_make_none]

(* ****** ****** *)

implement
h3ypo_prop
  (loc, s2p) = h3ypo_new (loc, h3ypo_node_H3YPOprop (s2p))

implement
h3ypo_bind
  (loc, s2v1, s2f2) = let
  val s2e2 = s2hnf2exp (s2f2)
in
  h3ypo_new (loc, h3ypo_node_H3YPObind (s2v1, s2e2))
end // end of [h3ypo_bind]

implement
h3ypo_eqeq
  (loc, s2f1, s2f2) = let
  val s2e1 = s2hnf2exp (s2f1)
  val s2e2 = s2hnf2exp (s2f2)
in
  h3ypo_new (loc, h3ypo_node_H3YPOeqeq (s2e1, s2e2))
end // end of [h3ypo_eqeq]

(* ****** ****** *)

implement
s2exp_Var_make_srt
  (loc, s2t) = let
  val s2V = s2Var_make_srt (loc, s2t)
  val () = trans3_env_add_sVar (s2V)
in
  s2exp_Var (s2V)
end // end of [s2exp_Var_make_srt]

implement
s2exp_Var_make_var (loc, s2v) = let
  val s2V = s2Var_make_var (loc, s2v)
  val () = trans3_env_add_sVar (s2V)
in
  s2exp_Var (s2V)
end // end of [s2exp_Var_make_var]

(* ****** ****** *)

implement
stasub_make_svarlst
  (loc, s2vs) = let
//
fun loop (
  loc: loc_t, s2vs: s2varlst, sub: &stasub >> _
) : void =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => let
      val s2e =
        s2exp_Var_make_var (loc, s2v)
      // end of [val]
      val () = stasub_add (sub, s2v, s2e)
    in
      loop (loc, s2vs, sub)
    end // end of [list_cons]
  | ~GLnil () => ()
// end of [loop]
//
var sub = stasub_make_nil ()
val () = loop (loc, s2vs, sub)
//
in
  sub
end // end of [stasub_make_svarlst]

(* ****** ****** *)

fun
stasub_s2varlst_instantiate_none
(
  sub: &stasub >> _
, locarg: loc_t, s2vs: s2varlst
, err: &int // HX: [err] is not used
) : void = let
in
//
case+ glist_view (s2vs) of
| ~GLcons (s2v, s2vs) => let
    val s2e =
      s2exp_Var_make_var (locarg, s2v)
    // end of [val]
    val () = stasub_add (sub, s2v, s2e)
  in
    stasub_s2varlst_instantiate_none (sub, locarg, s2vs, err)
  end // end of [list_cons]
| ~GLnil () => () // end of [list_nil]
//
end // end of [stasub_s2varlst_instantiate_none]

fun
stasub_s2varlst_instantiate_some
(
  sub: &stasub >> _
, locarg: loc_t, s2vs: s2varlst, s2es: s2explst
, err: &int
) : void = let
//
fun
auxerr1
(
  locarg: loc_t, serr: int
) : void = let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "stasub_s2varlst_instantiate_some"
  val () = prerr ": static arity mismatch"
  val () = if serr > 0 then prerr ": more arguments are expected."
  val () = if serr < 0 then prerr ": fewer arguments are expected."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_s2varlst_instantiate_arity (locarg, serr))
end // end of [auxerr1]
fun
auxerr2
(
  locarg: loc_t, s2t1: s2rt, s2t2: s2rt
) : void = let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "stasub_s2varlst_instantiate_some"
  val () =
  if $GLOB.the_LEGACYERRORS_get () > 0 then {
    val () = prerr ": mismatch of sorts:\n"
    val () = prerr "the needed sort is ["
    val () = (prerr_s2rt (s2t1); prerr "];"; prerr_newline ())
    val () = prerr "the actual sort is ["
    val () = (prerr_s2rt (s2t2); prerr "]."; prerr_newline ())
  } else { // HX-2026-10: the surface syntax (pats_staexp2_sprint)
    val () = prerr ": sort mismatch: expected "
    val () = prerr_s2rt_s (s2t1)
    val () = prerr ", actual "
    val () = prerr_s2rt_s (s2t2)
    val () = prerr_newline ()
  } (* end of [if] *)
in
  the_trans3errlst_add (trans3err_T3E_s2varlst_instantiate_srtck (locarg, s2t1, s2t2))
end // end of [auxerr2]
//
in
//
case+ glist_view (s2vs) of
| ~GLcons
    (s2v, s2vs) => (
  case+ glist_view (s2es) of
  | ~GLcons (s2e, s2es) => let
      val s2t1 = s2var_get_srt (s2v)
      val s2t2 = s2e.s2exp_srt ()
      val ismat = s2rt_ltmat1 (s2t2, s2t1)
    in
      if ismat then let
        val () = stasub_add (sub, s2v, s2e)
      in
        stasub_s2varlst_instantiate_some (sub, locarg, s2vs, s2es, err)
      end else let
        val () = err := err + 1
        val () = auxerr2 (locarg, s2t1, s2t2)
        val () = stasub_add (sub, s2v, s2exp_errexp(s2t1))
      in
        stasub_s2varlst_instantiate_some (sub, locarg, s2vs, s2es, err)
      end (* end of [if] *)
    end // end of [list_cons]
  | ~GLnil () => let
      val () = err := err + 1
      val () = auxerr1 (locarg, 1) // HX: more arguments expected
    in
      // nothing
    end // end of [list_nil]
  ) // end of [list_cons]
| ~GLnil () => (
  case+ glist_view (s2es) of
  | ~GLcons _ => let
      val () = err := err + 1
      val () = auxerr1 (locarg, ~1) // HX: fewer arguments expected
    in
      // nothing
    end // end of [list_cons]
  | ~GLnil () => ()
  ) // end of [list_nil]
end // end of [stasub_s2varlst_instantiate_some]

fun
stasub_s2varlst_instcollect
(
  sub: &stasub >> _
, locarg: loc_t, s2vs: s2varlst, res: s2explst_vt
) : s2explst_vt = let
in
//
case+ glist_view (s2vs) of
| ~GLcons (s2v, s2vs) => let
    val s2e =
      s2exp_Var_make_var (locarg, s2v)
    // end of [val]
    val () = stasub_add (sub, s2v, s2e)
    val res = list_vt_cons (s2e, res)
  in
    stasub_s2varlst_instcollect (sub, locarg, s2vs, res)
  end // end of [list_cons]
| ~GLnil () => list_vt_reverse (res)
//
end // end of [stasub_s2varlst_instcollect]

(* ****** ****** *)

fun
exiuni_loop (
  knd: int, locarg: loc_t
, sub: &stasub >> _
, s2f: s2hnf
, s2ps_res: &s2explst_vt >> _
, err: &int
) : s2exp = let
  val s2e = s2hnf2exp (s2f)
  var s2vs: s2varlst
  and s2ps: s2explst
  var s2e1: s2exp // scope
  val ans = uns2exp_exiuni (knd, s2e, s2vs, s2ps, s2e1)
in
//
case+ ans of
| true => let
    // HX: [sub] should be properly extended first
    val () = stasub_s2varlst_instantiate_none (sub, locarg, s2vs, err)
    val s2ps = s2explst_subst_vt (sub, s2ps)
    val () = s2ps_res := list_vt_reverse_append (s2ps, s2ps_res)
    val s2f1 = s2exp2hnf (s2e1)
  in
    exiuni_loop (knd, locarg, sub, s2f1, s2ps_res, err)
  end // end of [S2Euni/S2Eexi]
| false => s2exp_subst (sub, s2e)
//
end // end of [exiuni_loop]

implement
s2exp_exiuni_instantiate_all
  (knd, s2e0, locarg, err) = let // HX: [err] is not used
//
var sub
  : stasub = stasub_make_nil ()
// end of [var]
val s2f0 = s2exp2hnf (s2e0)
var s2ps_res: s2explst_vt = list_vt_nil ()
val s2e_res = exiuni_loop (knd, locarg, sub, s2f0, s2ps_res, err)
val () = stasub_free (sub)
val s2ps_res = list_vt_reverse (s2ps_res)
//
in
  @(s2e_res, s2ps_res)
end // end of [s2exp_exiuni_instantiate_all]

implement
s2exp_exi_instantiate_all
  (s2e0, locarg, err) =
  s2exp_exiuni_instantiate_all (0, s2e0, locarg, err)
// end of [s2exp_exi_instantiate_all]

implement
s2exp_uni_instantiate_all
  (s2e0, locarg, err) =
  s2exp_exiuni_instantiate_all (1, s2e0, locarg, err)
// end of [s2exp_uni_instantiate_all]

implement
s2exp_unimet_instantiate_all
  (s2e0, locarg, err) = let
  val @(s2e, s2ps_fst) =
    s2exp_uni_instantiate_all(s2e0, locarg, err)
  val s2f = s2exp2hnf (s2e)
  val s2e = s2hnf2exp (s2f)
in
//
case+ s2exp_node_view (s2e.s2exp_node ()) of
| ~S2Emetfun
    (opt, s2es_met, s2e1) => (
  case+ gopt_view (opt) of
  | ~GOsome (stamp) => let
      val () = s2exp_termet_instantiate (locarg, stamp, s2es_met)
      val @(s2e1, s2ps_rest) = s2exp_uni_instantiate_all (s2e1, locarg, err)
      val s2ps_all = list_vt_append (s2ps_fst, s2ps_rest)
    in
      @(s2e1, s2ps_all)
    end // end of [S2Emetfun]
  | ~GOnone () => @(s2e1, s2ps_fst) // HX: the body (the pattern variable [s2e] of ATS1 shadows the whole)
  ) // end of [S2Emetfun]
| v => (s2exp_node_view_free (v); @(s2e, s2ps_fst))
//
end // end of [s2exp_unimet_instantiate_all]

(* ****** ****** *)

implement
s2exp_exi_instantiate_sexparg
  (s2e0, s2a, err) = let
//
val locarg = s2a.s2exparg_loc ()
//
fun
auxerr
(
  locarg: loc_t
) : void = let
  val () =
  prerr_error3_loc(locarg)
  val () =
  filprerr_ifdebug "s2exp_exi_instantiate_sexparg"
  val () =
  (prerr ": the static abstraction is overly done."; prerr_newline ())
in
  the_trans3errlst_add(trans3err_T3E_s2varlst_instantiate_nabs(locarg, 1))
end (* end of [auxerr] *)
//
in
//
case+
s2exparg_node_view (s2a.s2exparg_node ())
of (* case+ *)
//
| ~S2EXPARGall () =>
    s2exp_exi_instantiate_all (s2e0, locarg, err)
  // end of [S2EXPARGall]
//
| ~S2EXPARGone () => let
    val s2e0 = s2exp_hnfize (s2e0)
  in
    case+
    s2exp_node_view (s2e0.s2exp_node ())
    of // case+
    | ~S2Eexi (
        s2vs, s2ps, s2e1
      ) => let
        var sub: stasub = stasub_make_nil ()
        val () = stasub_s2varlst_instantiate_none (sub, locarg, s2vs, err)
        val s2e1 = s2exp_subst (sub, s2e1)
        val s2ps = s2explst_subst_vt (sub, s2ps)
        val ((*freed*)) = stasub_free (sub)
      in
        @(s2e1, s2ps)
      end // end of [S2Eexi]
    | v (*non-S2Eexi*) => let
        val () = s2exp_node_view_free (v)
        val () = err := err + 1
        val () = auxerr (locarg) in @(s2e0, list_vt_nil ())
      end // end of [_]
   end
//
| ~S2EXPARGseq (s2es) => let
    val s2e0 = s2exp_hnfize (s2e0)
  in
    case+
    s2exp_node_view (s2e0.s2exp_node ())
    of // case+
    | ~S2Eexi (
        s2vs, s2ps, s2e1
      ) => let
        var sub: stasub = stasub_make_nil ()
        val () = stasub_s2varlst_instantiate_some (sub, locarg, s2vs, s2es, err)
        val s2e1 = s2exp_subst (sub, s2e1)
        val s2ps = s2explst_subst_vt (sub, s2ps)
        val () = stasub_free (sub)
      in
        @(s2e1, s2ps)
      end // end of [S2Eexi]
    | v (*non-S2Eexi*) => let
        val () = s2exp_node_view_free (v)
        val () = err := err + 1
        val () = auxerr (locarg) in @(s2e0, list_vt_nil ())
      end (* end of [_] *)
  end // end of [S2EXPARGseq]
//
end // end of [s2exp_exi_instantiate_sexparg]

(* ****** ****** *)

fun
unisexp_auxerr
(
  locarg: loc_t
) : void = let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "s2exp_uni_instantiate_sexparglst"
  val () = prerr ": the static application is overly done."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_s2varlst_instantiate_napp (locarg, 1))
end (* end of [unisexp_auxerr] *)

fun
unisexp_loop
(
  sub: &stasub >> _
, s2f: s2hnf
, s2ps_res: &s2explst_vt >> _
, s2as: s2exparglst
, err: &int
) : s2exp = let
  val s2e = s2hnf2exp (s2f)
in
//
case+ glist_view (s2as) of
| ~GLcons (s2a, s2as1) => let
    val locarg = s2a.s2exparg_loc ()
  in
    case+ s2exparg_node_view (s2a.s2exparg_node ()) of
    | ~S2EXPARGall () => (
      case+ s2exp_node_view (s2e.s2exp_node ()) of
      | ~S2Euni (s2vs, s2ps, s2e1) => let
          // HX: [sub] should be properly extended first
          val () = stasub_s2varlst_instantiate_none (sub, locarg, s2vs, err)
          val s2ps = s2explst_subst_vt (sub, s2ps)
          val () = s2ps_res := list_vt_reverse_append (s2ps, s2ps_res)
          val s2f1 = s2exp2hnf (s2e1)
        in
          unisexp_loop (sub, s2f1, s2ps_res, s2as, err)
        end
      | v => let
          val () = s2exp_node_view_free (v)
        in
          unisexp_loop (sub, s2f, s2ps_res, s2as1, err)
        end
      ) // end of [S2EXPARGall]
    | ~S2EXPARGone () => (
      case+ s2exp_node_view (s2e.s2exp_node ()) of
      | ~S2Euni (s2vs, s2ps, s2e1) => let
          // HX: [sub] should be properly extended first
          val () = stasub_s2varlst_instantiate_none (sub, locarg, s2vs, err)
          val s2ps = s2explst_subst_vt (sub, s2ps)
          val () = s2ps_res := list_vt_reverse_append (s2ps, s2ps_res)
          val s2f1 = s2exp2hnf (s2e1)
        in
          unisexp_loop (sub, s2f1, s2ps_res, s2as1, err)
        end // end of [S2Euni]
      | v => let
          val () = s2exp_node_view_free (v)
          val () = err := err + 1
          val () = unisexp_auxerr (locarg)
        in
          unisexp_loop (sub, s2f, s2ps_res, s2as1, err)
        end (* end of [_] *)
      ) // end of [S2EXPARGone]
    | ~S2EXPARGseq (s2es) => (
      case+ s2exp_node_view (s2e.s2exp_node ()) of
      | ~S2Euni (s2vs, s2ps, s2e1) => let
          // HX: [sub] should be properly extended first
          val () = stasub_s2varlst_instantiate_some (sub, locarg, s2vs, s2es, err)
          val s2ps = s2explst_subst_vt (sub, s2ps)
          val () = s2ps_res := list_vt_reverse_append (s2ps, s2ps_res)
          val s2f1 = s2exp2hnf (s2e1)
        in
          unisexp_loop (sub, s2f1, s2ps_res, s2as1, err)
        end // end of [S2Euni]
      | v => let
          val () = s2exp_node_view_free (v)
          val () = err := err + 1
          val () = unisexp_auxerr (locarg)
        in
          unisexp_loop (sub, s2f, s2ps_res, s2as1, err)
        end (* end of [_] *)
      ) // end of [S2EXPARGseq]
  end // end of [list_cons]
| ~GLnil () => let
    val s2e = s2hnf2exp (s2f) in s2exp_subst (sub, s2e)
  end // end of [list_nil]
//
end // end of [unisexp_loop]

implement
s2exp_uni_instantiate_sexparglst
  (s2e0, s2as, err) = let
//
var sub
  : stasub = stasub_make_nil ()
// end of [var]
val s2f0 = s2exp2hnf (s2e0)
var s2ps_res: s2explst_vt = list_vt_nil ()
val s2e_res = unisexp_loop (sub, s2f0, s2ps_res, s2as, err)
val () = stasub_free (sub)
val s2ps_res = list_vt_reverse (s2ps_res)
//
in
  @(s2e_res, s2ps_res)
end // end of [s2exp_uni_instantiate_sexparglst]

(* ****** ****** *)

fun
tmp_instantiate_rest_loop
(
  locarg: loc_t
, sub: &stasub >> _
, s2qs: s2qualst
, t2mas: t2mpmarglst_vt
, nerr: &int // HX: unused
) : t2mpmarglst_vt = let
in
  case+ glist_view (s2qs) of
  | ~GLnil() =>
      list_vt_reverse (t2mas)
    // end of [list_nil]
  | ~GLcons(s2q, s2qs) => let
//
      val
      s2vs = s2q.s2qua_svs ()
      val () =
      assertloc(glist_is_nil(s2q.s2qua_sps ()))
//
      val s2es =
      stasub_s2varlst_instcollect(sub, locarg, s2vs, list_vt_nil())
//
      val t2ma =
        t2mpmarg_make (locarg, l2l(s2es))
      val t2mas = list_vt_cons (t2ma, t2mas)
//
    in
      tmp_instantiate_rest_loop (locarg, sub, s2qs, t2mas, nerr)
    end // end of [list_cons]
end // end of [tmp_instantiate_rest_loop]

implement
s2exp_tmp_instantiate_rest
  (s2e_tmp, locarg, s2qs, nerr) = let
//
var sub
  : stasub = stasub_make_nil ()
// end of [var]
//
val
t2mas =
tmp_instantiate_rest_loop (
  locarg, sub, s2qs, list_vt_nil(), nerr
) (* end of [val] *)
//
val s2e_res = s2exp_subst (sub, s2e_tmp)
//
val ((*freed*)) = stasub_free (sub)
//
in
  @(s2e_res, l2l(t2mas))
end // end of [s2exp_tmp_instantiate_rest]

(* ****** ****** *)

fun
tmp_instantiate_auxerr
(
  locarg: loc_t
) : void = let
  val () =
  prerr_error3_loc (locarg)
  val () =
  filprerr_ifdebug "s2exp_tmp_instantiate_tmpmarglst"
  val () =
  (prerr ": the template instantiation is overly done."; prerr_newline ())
in
  the_trans3errlst_add(trans3err_T3E_s2varlst_instantiate_napp(locarg, 1))
end (* end of [tmp_instantiate_auxerr] *)

fun
tmp_instantiate_auxsome
(
  sub: &stasub >> _
, locarg: &loc_t >> _
, s2qs: s2qualst
, t2mas: t2mpmarglst
, nerr: &int
) : s2qualst = let
in
//
case+ glist_view (s2qs) of
| ~GLnil () => (
  case+ glist_view (t2mas) of
  | ~GLnil() => glist_nil ()
  | ~GLcons(t2ma, t2mas) => let
      val () = nerr := nerr + 1
      val () = locarg := t2ma.t2mpmarg_loc ()
      val () = tmp_instantiate_auxerr (locarg)
    in
      tmp_instantiate_auxsome (sub, locarg, s2qs, t2mas, nerr)
    end // end of [list_cons]
  ) (* end of [list_nil] *)
| ~GLcons(s2q, s2qs1) => (
  case+ glist_view (t2mas) of
  | ~GLnil() => s2qs
  | ~GLcons(t2ma, t2mas) => let
//
      val
      s2vs = s2q.s2qua_svs ()
      val () =
      assertloc(glist_is_nil(s2q.s2qua_sps ()))
//
      val
      s2es = t2ma.t2mpmarg_arg ()
      val () = locarg := t2ma.t2mpmarg_loc ()
//
      val () =
      stasub_s2varlst_instantiate_some (sub, locarg, s2vs, s2es, nerr)
//
    in
      tmp_instantiate_auxsome (sub, locarg, s2qs1, t2mas, nerr)
    end // end of [list_cons]
  ) (* end of [list_cons] *)
//
end // end of [tmp_instantiate_auxsome]

implement
s2exp_tmp_instantiate_tmpmarglst
  (s2e_tmp, locarg, s2qs, t2mas, nerr) = let
//
var locarg: loc_t = locarg
//
var sub
  : stasub = stasub_make_nil()
// end of [var]
val
s2qs =
tmp_instantiate_auxsome
(
  sub, locarg, s2qs, t2mas, nerr
) (* end of [val] *)
//
val
s2e_res = s2exp_subst (sub, s2e_tmp)
//
val ((*freed*)) = stasub_free (sub)
//
in
//
case+ glist_view (s2qs) of
//
| ~GLnil() => @(s2e_res, t2mas)
//
| ~GLcons (_, _) => let
    val locarg =
      $LOC.location_rightmost (locarg)
    val @(s2e2_res, t2mas2) =
      s2exp_tmp_instantiate_rest (s2e_res, locarg, s2qs, nerr)
  in
    @(s2e2_res, glist_append (t2mas, t2mas2))
  end // end of [list_cons]
//
end // end of [s2exp_tmp_instantiate_tmpmarglst]

(* ****** ****** *)

local
//
val the_s2Varset = gcell_make<s2Varset> (s2Varset_nil ())
val the_s2Varsetlst = gcell_make<glist(s2Varset)> (glist_nil ())
//
in (* in of [local] *)

fun
the_s2Varset_env_push (): void = let
  val xs = gcell_get<s2Varset> (the_s2Varset)
  val xss = gcell_get<glist(s2Varset)> (the_s2Varsetlst)
in
  gcell_set<glist(s2Varset)> (the_s2Varsetlst, glist_cons (xs, xss))
end // end of [the_s2Varset_env_push]

fun
the_s2Varset_env_pop (): s2Varset = let
  val xss = gcell_get<glist(s2Varset)> (the_s2Varsetlst)
  val s2Vs = (
    case+ glist_view (xss) of
    | ~GLcons (xs, xss1) => let
        val () = gcell_set<glist(s2Varset)> (the_s2Varsetlst, xss1) in xs
      end
    | ~GLnil () => s2Varset_nil ()
  ) : s2Varset
  val xs = gcell_get<s2Varset> (the_s2Varset)
  val () = gcell_set<s2Varset> (the_s2Varset, s2Vs)
in
  xs
end // end of [the_s2Varset_env_pop]

fun
the_s2Varset_env_get (): s2Varset = gcell_get<s2Varset> (the_s2Varset)

fun
the_s2Varset_env_add (x: s2Var): void =
  gcell_set<s2Varset> (the_s2Varset, s2Varset_add (gcell_get<s2Varset> (the_s2Varset), x))
// end of [the_s2Varset_env_add]

end // end of [local]

(* ****** ****** *)
//
// HX:
// it is declared in [pats_staexp2_util.sats]
//
implement
s2exp_hnfize_flag_svar
  (s2e0, s2v, flag) = let
//
val ans = the_s2varbindmap_search (s2v)
//
in
//
case+ ans of
| ~None_vt () => s2e0
| ~Some_vt s2e => let
    val () = flag := flag + 1 in s2exp_hnfize (s2e)
  end // end of [Some_vt]
//
end // end of [s2exp_hnfize_flag_svar]

(* ****** ****** *)

extern
fun aux1_s2exp (s2v: s2var, s2e: s2exp): bool
and aux1_s2explst (s2v: s2var, s2es: s2explst): bool
and aux1_s2explstlst (s2v: s2var, s2ess: s2explstlst): bool
extern
fun aux1_s2var (s2v: s2var, s2v1: s2var): bool

implement
aux1_s2exp
  (s2v0, s2e0) = let
in
//
case+
s2exp_node_view (s2e0.s2exp_node ())
of // case+
| ~S2Evar(s2v) =>
  if (s2v0 = s2v)
    then true else aux1_s2var(s2v0, s2v)
  // end of [if]
//
| ~S2Eapp(s2e, s2es) =>
  if aux1_s2exp(s2v0, s2e)
    then true else aux1_s2explst(s2v0, s2es)
  // end of [if] // end of [S2Eapp]
//
| ~S2Eextype
    (_(*name*), s2ess) =>
    aux1_s2explstlst (s2v0, s2ess)
| ~S2Eextkind
    (_(*name*), s2ess) =>
    aux1_s2explstlst (s2v0, s2ess)
//
| ~S2Esizeof(s2e) => aux1_s2exp(s2v0, s2e)
//
| ~S2Eeqeq(s2e1, s2e2) =>
  if aux1_s2exp(s2v0, s2e1)
    then true else aux1_s2exp(s2v0, s2e2)
  // end of [if] // end of [S2Eeqeq]
//
| ~S2Einvar(s2e) => aux1_s2exp(s2v0, s2e)
| ~S2Erefarg (_, s2e) => aux1_s2exp(s2v0, s2e)
//
| ~S2Elam(s2vs, s2e) => aux1_s2exp(s2v0, s2e)
//
| ~S2Efun(
    fc,  lin, s2fe
  , npf, s2es_arg, s2e_res
  ) =>
  if aux1_s2explst(s2v0, s2es_arg)
    then true else aux1_s2exp(s2v0, s2e_res)
  // end of [if] // end of [S2Efun]
//
| v (* rest-of-S2E *) => (s2exp_node_view_free (v); false)
//
end // end of [aux1_s2exp]

implement
aux1_s2explst
  (s2v0, s2es) =
(
case+ glist_view (s2es) of
| ~GLnil() => false
| ~GLcons(s2e, s2es) =>
  if aux1_s2exp(s2v0, s2e)
    then true else aux1_s2explst(s2v0, s2es)
  // end of [if] // end of [list_cons]
)

implement
aux1_s2explstlst
  (s2v0, s2ess) =
(
case+ glist_view (s2ess) of
| ~GLnil() => false
| ~GLcons(s2es, s2ess) =>
  if aux1_s2explst(s2v0, s2es)
    then true else aux1_s2explstlst(s2v0, s2ess)
  // end of [if] // end of [list_cons]
)

implement
aux1_s2var
  (s2v0, s2v) = let
//
val ans =
  the_s2varbindmap_search (s2v)
//
in
//
case+ ans of
| ~None_vt() => false
| ~Some_vt(s2e) => aux1_s2exp(s2v0, s2e)
//
end // end of [aux1_s2var]

(* ****** ****** *)

implement
s2var_occurcheck_s2exp
  (s2v0, s2e0) = aux1_s2exp (s2v0, s2e0)
// end of [s2var_occurcheck_s2exp]

(* ****** ****** *)

local
//
// HX-2026-10: the items are kept newest first in a [glist] in a cell; [the_s3itmlstlst] holds the saved ones
//
val the_s3itmlst = gcell_make<s3itmlst> (glist_nil ())
val the_s3itmlstlst = gcell_make<glist(s3itmlst)> (glist_nil ())
//
in (* in of [local] *)

fun
the_s3itmlst_env_push
  ((*void*)): void = let
  val s3is = gcell_get<s3itmlst> (the_s3itmlst)
  val () = gcell_set<s3itmlst> (the_s3itmlst, glist_nil ())
  val s3iss = gcell_get<glist(s3itmlst)> (the_s3itmlstlst)
in
  gcell_set<glist(s3itmlst)> (the_s3itmlstlst, glist_cons (s3is, s3iss))
end // end of [the_s3itmlst_env_push]

// HX: the items, oldest first
fun
the_s3itmlst_env_pop (): s3itmlst = let
  val s3iss = gcell_get<glist(s3itmlst)> (the_s3itmlstlst)
  val s3is = (
    case+ glist_view (s3iss) of
    | ~GLcons (xs, xss) => let
        val () = gcell_set<glist(s3itmlst)> (the_s3itmlstlst, xss) in xs
      end
    | ~GLnil () => glist_nil ()
  ) : s3itmlst
  val xs = gcell_get<s3itmlst> (the_s3itmlst)
  val () = gcell_set<s3itmlst> (the_s3itmlst, s3is)
in
  glist_reverse (xs)
end // end of [the_s3itmlst_env_pop]

fun
the_s3itmlst_env_add (s3i: s3itm): void =
  gcell_set<s3itmlst> (the_s3itmlst, glist_cons (s3i, gcell_get<s3itmlst> (the_s3itmlst)))
// end of [the_s3itmlst_env_add]

(* ****** ****** *)

implement
fprint_the_s3itmlst
  (out) = fprint_s3itmlst (out, gcell_get<s3itmlst> (the_s3itmlst))
// end of [fprint_the_s3itmlst]

implement
fprint_the_s3itmlstlst
  (out) = fprint_s3itmlstlst (out, gcell_get<glist(s3itmlst)> (the_s3itmlstlst))
// end of [fprint_the_s3itmlstlst]

end // end of [local]

(* ****** ****** *)

implement
trans3_env_add_svar
  (s2v) = () where {
  val s3i = s3itm_S3ITMsvar (s2v)
  val () = the_s3itmlst_env_add (s3i)
} // end of [trans3_env_add_svar]

implement
trans3_env_add_svarlst (s2vs) =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) =>
      (trans3_env_add_svar (s2v); trans3_env_add_svarlst (s2vs))
  | ~GLnil () => ()
// end of [trans3_env_add_svarlst]

(* ****** ****** *)

implement
trans3_env_add_squa
  (s2q) = () where {
  val () = trans3_env_add_svarlst (s2q.s2qua_svs ())
} // end of [trans3_env_add_svar]

implement
trans3_env_add_squalst (s2qs) =
  case+ glist_view (s2qs) of
  | ~GLcons (s2q, s2qs) =>
      (trans3_env_add_squa (s2q); trans3_env_add_squalst (s2qs))
  | ~GLnil () => ()
// end of [trans3_env_add_squalst]

(* ****** ****** *)

implement
trans3_env_add_sp2at
  (sp2t) = (
  case+ sp2at_node_view (sp2t.sp2at_node ()) of
  | ~SP2Tcon (s2c, s2vs) => trans3_env_add_svarlst (s2vs)
  | ~SP2Terr () => ()
) // end of [trans3_env_add_sp2at]

(* ****** ****** *)

implement
trans3_env_add_sVar
  (s2V) = () where {
  val s3i = s3itm_S3ITMsVar (s2V)
//
  val () = the_s2Varset_env_add (s2V)
//
  val () = the_s3itmlst_env_add (s3i)
//
} // end of [trans3_env_add_sVar]

implement
trans3_env_add_sVarlst (s2Vs) =
  case+ glist_view (s2Vs) of
  | ~GLcons (s2V, s2Vs) =>
      (trans3_env_add_sVar (s2V); trans3_env_add_sVarlst (s2Vs))
  | ~GLnil () => ()
// end of [trans3_env_add_sVarlst]

implement
trans3_env_add_cnstr
  (c3t) = () where {
  val () = the_s3itmlst_env_add (s3itm_S3ITMcnstr (c3t))
} // end of [trans3_env_add_cnstr]

implement
trans3_env_add_cnstr_ref
  (ref) = () where {
  val () = the_s3itmlst_env_add (s3itm_S3ITMcnstr_ref (ref))
} // end of [trans3_env_add_cnstr_ref]

(* ****** ****** *)

implement
trans3_env_add_prop
  (loc, s2p) = let
  val c3t = c3nstr_prop (loc, s2p) in trans3_env_add_cnstr (c3t)
end // end of [trans3_env_add_prop]

implement
trans3_env_add_proplst
  (loc, s2ps) = case+ glist_view (s2ps) of
  | ~GLcons (s2p, s2ps) => (
      trans3_env_add_prop (loc, s2p); trans3_env_add_proplst (loc, s2ps)
    ) // end of [list_cons]
  | ~GLnil () => ()
// end of [trans3_env_add_proplst]

implement
trans3_env_add_proplst_vt
  (loc, s2ps) = (
  case+ s2ps of
  | ~list_vt_cons (s2p, s2ps) => (
      trans3_env_add_prop (loc, s2p); trans3_env_add_proplst_vt (loc, s2ps)
    )
  | ~list_vt_nil () => ()
) // end of [trans3_env_add_proplst_vt]

(* ****** ****** *)

implement
trans3_env_add_eqeq
  (loc, s2e1, s2e2) = let
  val s2p = s2exp_eqeq (s2e1, s2e2)
in
  trans3_env_add_prop (loc, s2p)
end // end of [trans3_env_add_eqeq]

(* ****** ****** *)
//
// HX: for checking pattern matching exhaustiveness
//
fun
add_patcstlstlst_false_loop (
  loc0: loc_t, casknd: caskind, s2es: s2explst, xss: p2atcstlstlst_vt
) : void =
(
case+ xss of
| ~list_vt_nil () => ()
| ~list_vt_cons (xs, xss) => let
    val () = trans3_env_push ()
    val c3t =
      c3nstr_case_exhaustiveness (loc0, casknd, xs)
    // end of [val]
    val () = trans3_env_hypadd_patcstlst (loc0, xs, s2es)
    val () = trans3_env_add_cnstr (c3t)
    val () = trans3_env_pop_and_add_main (loc0)
  in
    add_patcstlstlst_false_loop (loc0, casknd, s2es, xss)
  end // end of [list_cons]
) (* end of [aux] *)

implement
trans3_env_add_patcstlstlst_false
  (loc0, casknd, cp2tcss, s2es) =
  add_patcstlstlst_false_loop (loc0, casknd, s2es, cp2tcss)
// end of [trans3_env_add_patcstlstlst_false]

(* ****** ****** *)

implement
trans3_env_hypadd_prop
  (loc, s2p) = let
//
val h3p =
  h3ypo_prop (loc, s2p)
//
val s3i = s3itm_S3ITMhypo (h3p)
//
in
  the_s3itmlst_env_add (s3i)
end // end of [trans3_env_hypadd_prop]

implement
trans3_env_hypadd_proplst
  (loc, s2ps) = case+ glist_view (s2ps) of
  | ~GLnil() => ()
  | ~GLcons(s2p, s2ps) => (
      trans3_env_hypadd_prop (loc, s2p); trans3_env_hypadd_proplst (loc, s2ps)
    ) // end of [list_cons]
// end of [trans3_env_hypadd_proplst]

implement
trans3_env_hypadd_proplst_vt
  (loc, s2ps) = (
  case+ s2ps of
  | ~list_vt_cons (s2p, s2ps) => (
      trans3_env_hypadd_prop (loc, s2p); trans3_env_hypadd_proplst_vt (loc, s2ps)
    )
  | ~list_vt_nil () => ()
) // end of [trans3_env_hypadd_proplst_vt]

(* ****** ****** *)

implement
trans3_env_hypadd_propopt
  (loc, opt) =
(
  case+ gopt_view (opt) of
  | ~GOnone () => ()
  | ~GOsome (s2p) => trans3_env_hypadd_prop (loc, s2p)
) // end of [trans3_env_hypadd_propopt]

implement
trans3_env_hypadd_propopt_neg
  (loc, opt) =
(
  case+ gopt_view (opt) of
  | ~GOnone () => ()
  | ~GOsome (s2p) =>
      trans3_env_hypadd_prop (loc, s2exp_bneg (s2p))
    // end of [Some]
) // end of [trans3_env_hypadd_propopt_neg]

(* ****** ****** *)

implement
trans3_env_hypadd_bind
  (loc, s2v1, s2f2) = let
//
// HX: [s2v1] cannot be bound at this point
//
val () =
the_s2varbindmap_insert (s2v1, s2f2)
//
val h3p = h3ypo_bind (loc, s2v1, s2f2)
//
val s3i = s3itm_S3ITMhypo (h3p)
//
in
  the_s3itmlst_env_add (s3i)
end // end of [trans3_env_hypadd_bind]

implement
trans3_env_hypadd_eqeq
  (loc, s2f1, s2f2) = let
  val h3p =
    h3ypo_eqeq (loc, s2f1, s2f2)
  // end of [val]
in
  the_s3itmlst_env_add (s3itm_S3ITMhypo (h3p))
end // end of [trans3_env_hypadd_eqeq]

(* ****** ****** *)

fun
hypadd_patcst_qualoop (
  loc0: loc_t, s2qs: s2qualst
) : void =
  case+ glist_view (s2qs) of
  | ~GLnil () => ()
  | ~GLcons (s2q, s2qs) => let
      val () = trans3_env_add_svarlst (s2q.s2qua_svs ())
      val () = trans3_env_hypadd_proplst (loc0, s2q.s2qua_sps ())
    in
      hypadd_patcst_qualoop (loc0, s2qs)
    end // end of [list_cons]
// end of [hypadd_patcst_qualoop]

fun
hypadd_patcst_intloop (
  loc0: loc_t, s2e_arg: s2exp, xs: intinflst_vt
) : void = (
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (x, xs) => let
      val s2p =
        s2exp_intneq (s2e_arg, s2exp_intinf x)
      // end of [val]
      val () = trans3_env_hypadd_prop (loc0, s2p)
    in
      hypadd_patcst_intloop (loc0, s2e_arg, xs)
    end // end of [list_vt_cons]
) (* end of [hypadd_patcst_intloop] *)

fun
hypadd_patcst_charloop (
  loc0: loc_t, s2e_arg: s2exp, xs: charlst_vt
) : void = (
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (x, xs) => let
      val s2p =
        s2exp_intneq (s2e_arg, s2exp_int_char x)
      // end of [val]
      val () = trans3_env_hypadd_prop (loc0, s2p)
    in
      hypadd_patcst_charloop (loc0, s2e_arg, xs)
    end // end of [list_vt_cons]
) (* end of [hypadd_patcst_charloop] *)

implement
trans3_env_hypadd_patcst
  (loc0, p2tc, s2e0) = let
//
val
s2f0 = s2exp2hnf (s2e0)
//
val s2e = s2hnf_opnexi_and_add (loc0, s2f0)
val s2f = s2exp2hnf (s2e)
val s2e = s2hnf2exp (s2f)
//
in
//
case+ p2atcst_view (p2tc) of
//
| ~P2TCany () => ()
//
| ~P2TCcon
    (d2c, p2tcs) => let
  in
    case+ s2exp_node_view (s2e.s2exp_node ()) of
    | ~S2Edatcontyp (d2c1, _) =>
      (
        if (d2c != d2c1)
          then trans3_env_hypadd_prop (loc0, s2exp_bool (false)) else ()
        // end of [if]
      ) // end of [S2Edatcontyp]
    | v (*non-datcon*) => let
        val () = s2exp_node_view_free (v)
        val @(s2qs_d2c, s2e_d2c) = trans3_env_d2con_instantiate (loc0, d2c)
        val-~S2Efun (_, _, _, _, s2es_fun_arg, s2e_fun_res) = s2exp_node_view (s2e_d2c.s2exp_node ())
        val () = hypadd_patcst_qualoop (loc0, s2qs_d2c)
        val () = $SOL.s2exp_hypequal_solve (loc0, s2e_fun_res, s2e)
        val p2tcs = glist_listize (p2tcs)
      in
        trans3_env_hypadd_patcstlst (loc0, p2tcs, s2es_fun_arg)
      end // end of [_]
    // end of [case-of]
  end // end of [P2TCcon]
//
| ~P2TCempty _ => ()
//
| ~P2TCint (i) => let
    val opt = un_s2exp_g1int_index_t0ype (s2f)
  in
    case+ opt of
    | ~None_vt () => ()
    | ~Some_vt (s2e_arg) =>
        $SOL.s2exp_hypequal_solve (loc0, s2e_arg, s2exp_intinf (i))
      // end of [Some_vt]
  end // end of [P2TCint]
//
| ~P2TCintc (xs) => let
    val opt = un_s2exp_g1int_index_t0ype (s2f)
  in
    case+ opt of
    | ~None_vt () => ()
    | ~Some_vt (s2e_arg) => let
        val xs = intinfset_listize (xs)
      in
        hypadd_patcst_intloop (loc0, s2e_arg, xs)
      end // end of [Some_vt]
  end // end of [P2Tintc]
//
| ~P2TCbool (b) => let
    val opt = un_s2exp_bool_index_t0ype (s2f)
  in
    case+ opt of
    | ~None_vt () => () // end of [None_vt]
    | ~Some_vt (s2e_arg) =>
        $SOL.s2exp_hypequal_solve (loc0, s2e_arg, s2exp_bool (b))
      // end of [Some_vt]
  end // end of [P2TCbool]
//
| ~P2TCchar (c) => let
    val opt = un_s2exp_char_index_t0ype (s2f)
  in
    case+ opt of
    | ~None_vt () => ()
    | ~Some_vt (s2e_arg) =>
        $SOL.s2exp_hypequal_solve (loc0, s2e_arg, s2exp_int_char (c))
      // end of [Some_vt]
  end // end of [P2TCchar]
//
| ~P2TCcharc (xs) => let
    val opt = un_s2exp_char_index_t0ype (s2f)
  in
    case+ opt of
    | ~None_vt () => ()
    | ~Some_vt (s2e_arg) => let
        val xs = charset_listize (xs)
      in
        hypadd_patcst_charloop (loc0, s2e_arg, xs)
      end // end of [Some_vt]
  end // end of [P2Tcharc]
//
| ~P2TCfloat (rep) => ()
| ~P2TCstring (str) => ()
//
| ~P2TCrec
    (knd, lp2tcs) => let
  in
    case+ s2exp_node_view (s2e.s2exp_node ()) of
    | ~S2Etyrec (_, _, ls2es) => let
        val lp2tcs = glist_listize (lp2tcs)
      in
        trans3_env_hypadd_labpatcstlst (loc0, lp2tcs, ls2es)
      end // end of [S2Etyrec]
    | v (*non-tyrec*) => (s2exp_node_view_free (v))
  end // end of [P2TCrec]
//
end // end of [trans3_env_hypadd_patcst]

(* ****** ****** *)

fun
hypadd_patcstlst_loop
(
  loc0: loc_t, p2tcs: p2atcstlst_vt, s2es: s2explst, serr: int
) : int = let
in
//
case+ p2tcs of
| ~list_vt_nil () =>
  (
    case+ glist_view (s2es) of
    | ~GLcons (_, s2es) =>
        hypadd_patcstlst_loop (loc0, list_vt_nil (), s2es, serr - 1)
    | ~GLnil () => serr // the number of errors
  ) (* end of [list_nil] *)
| ~list_vt_cons (p2tc, p2tcs) =>
  (
    case+ glist_view (s2es) of
    | ~GLcons
        (s2e, s2es) => let
        val () =
          trans3_env_hypadd_patcst (loc0, p2tc, s2e)
        // end of [val]
      in
        hypadd_patcstlst_loop (loc0, p2tcs, s2es, serr)
      end // end of [list_cons]
    | ~GLnil ((*void*)) => hypadd_patcstlst_loop (loc0, p2tcs, s2es, serr + 1)
  ) (* end of [list_cons] *)
//
end // end of [hypadd_patcstlst_loop]

implement
trans3_env_hypadd_patcstlst
  (loc0, cp2tcs, s2es_pat) = let
//
val serr = hypadd_patcstlst_loop (loc0, cp2tcs, s2es_pat, 0)
//
val () =
if
(serr != 0)
then let
//
val () = prerr_error3_loc (loc0)
val () =
  filprerr_ifdebug "trans3_env_hypadd_patcstlst"
//
val () = print_string (": constructor arity mismatch")
val () = if serr < 0 then (print_string (": more arguments are expected"); print_newline ())
val () = if serr > 0 then (print_string (": fewer arguments are expected"); print_newline ())
//
in
  the_trans3errlst_add (trans3err_T3E_cp2atcstlst_arity (loc0, serr))
end // end of [then]
//
in
  (*nothing*)
end // end of [trans3_env_hypadd_patcstlst]

(* ****** ****** *)
//
// HX: a stable insertion sort by label (the mergesort of ATS1 is stable)
//
fun
labs2explst_insert
  (x: labs2exp, xs: labs2explst): labs2explst =
  case+ glist_view (xs) of
  | ~GLnil () => glist_sing (x)
  | ~GLcons (y, ys) => let
      val sgn = $LAB.compare_label_label (x.labs2exp_lab (), y.labs2exp_lab ())
    in
      // HX: the elements that are equal stay in their order (stable)
      if sgn < 0 then glist_cons (x, glist_cons (y, ys))
      else glist_cons (y, labs2explst_insert (x, ys))
    end // end of [GLcons]
// end of [labs2explst_insert]

fun
labs2explst_sort
  (xs: labs2explst): labs2explst = let
  fun loop (xs: labs2explst, res: labs2explst): labs2explst =
    case+ glist_view (xs) of
    | ~GLnil () => res
    | ~GLcons (x, xs) => loop (xs, labs2explst_insert (x, res))
in
  loop (xs, glist_nil ())
end // end of [labs2explst_sort]

(* ****** ****** *)

fun
hypadd_labpatcst_aux (
  loc0: loc_t, lp2tcs: labp2atcstlst, ls2es: labs2explst
) : void =
  case+ glist_view (lp2tcs) of
  | ~GLcons
    (lp2tc, lp2tcs1) => (
    case+ glist_view (ls2es) of
    | ~GLcons
        (ls2e, ls2es1) => let
        val l1 = lp2tc.labp2atcst_lab ()
        and p2tc = lp2tc.labp2atcst_elt ()
        val l2 = ls2e.labs2exp_lab ()
        and s2e = ls2e.labs2exp_elt ()
        val sgn = $LAB.compare_label_label (l1, l2)
      in
        if sgn < 0 then
          hypadd_labpatcst_aux (loc0, lp2tcs1, ls2es)
        else if sgn > 0 then
          hypadd_labpatcst_aux (loc0, lp2tcs, ls2es1)
        else let
          val () = trans3_env_hypadd_patcst (loc0, p2tc, s2e)
        in
          hypadd_labpatcst_aux (loc0, lp2tcs1, ls2es1)
        end // end of [if]
      end // end of [list_cons]
    | ~GLnil () => ()
    ) // end of [list_cons]
  | ~GLnil () => ()
// end of [hypadd_labpatcst_aux]

implement
trans3_env_hypadd_labpatcstlst
  (loc0, lp2tcs, ls2es) = let
//
val ls2es = labs2explst_sort (ls2es)
//
val () = hypadd_labpatcst_aux (loc0, labp2atcstlst_of_vt (lp2tcs), ls2es)
//
val () = list_vt_free (lp2tcs)
//
in
  // nothing
end // end of [trans3_env_hypadd_labpatcstlst]

(* ****** ****** *)
//
// HX: enforcing sequentiality of pattern match
//
fun
hypadd_patcstlstlst_aux (
  loc0: loc_t, s2es_pat: s2explst, p2tcss: p2atcstlstlst_vt
) : s3itmlstlst =
(
case+ p2tcss of
| ~list_vt_nil
   ((*void*)) => glist_nil()
| ~list_vt_cons
    (p2tcs, p2tcss) => let
    val () = trans3_env_push ((*none*))
    val () = trans3_env_hypadd_patcstlst (loc0, p2tcs, s2es_pat)
    val s3is = trans3_env_pop ((*none*))
    val s3is = l2l (s3is)
  in
    glist_cons (s3is, hypadd_patcstlstlst_aux (loc0, s2es_pat, p2tcss))
  end // end of [list_vt_cons]
) (* end of [aux] *)

implement
trans3_env_hypadd_patcstlstlst
  (loc0, cp2tcss, s2es_pat) = let
//
val s3iss = hypadd_patcstlstlst_aux (loc0, s2es_pat, cp2tcss)
//
in
  the_s3itmlst_env_add (s3itm_S3ITMdisj (s3iss))
end // end of [trans3_env_hypadd_patcstlstlst]

(* ****** ****** *)

implement
trans3_env_solver_assert
  (loc0, s2e) = the_s3itmlst_env_add(s3itm_S3ITMsolassert(s2e))
// end of [trans3_env_solver_assert]

(* ****** ****** *)

implement
trans3_env_solver_verify
  (loc0, s2e) = let
//
val c3t = c3nstr_solverify(loc0, s2e)
//
in
  the_s3itmlst_env_add(s3itm_S3ITMcnstr(c3t))
end // end of [trans3_env_solver_verify]

(* ****** ****** *)

implement
trans3_env_pop
  ((*none*)) = let
  val _(*s2Vs*) = the_s2Varset_env_pop ()
  val () = the_s2varbindmap_pop ()
in
  glist_listize (the_s3itmlst_env_pop ())
end // end of [trans3_env_pop]

implement
trans3_env_pop_and_add
  (loc, knd) = let
  val _(*s2Vs*) = the_s2Varset_env_pop ()
  val () = the_s2varbindmap_pop ()
  val s3is = the_s3itmlst_env_pop ()
  val c3t = c3nstr_itmlst (loc, knd, s3is)
in
  trans3_env_add_cnstr (c3t)
end // end of [trans3_env_pop_and_add]

implement
trans3_env_pop_and_add_main
  (loc) =
  trans3_env_pop_and_add (loc, c3nstrkind_C3TKmain())
// end of [trans3_env_pop_and_add_main]

implement
trans3_env_push () = let
//
val () = the_s2Varset_env_push ()
//
val () = the_s2varbindmap_push ()
//
val () = the_s3itmlst_env_push ()
//
in
  // nothing
end // end of [trans3_env_push]

(* ****** ****** *)

implement
s2hnf_absuni_and_add
  (loc0, s2f0) = let
//
val s2e0 = s2hnf2exp (s2f0)
//
val s2es2vss2ps = s2exp_absuni (s2e0)
//
val s2vs = s2es2vss2ps.1
//
val () = let
  val s2vs = glist_make_list_vt (list_vt_copy (s2vs))
  val s2Vs = the_s2Varset_env_get ()
  val () = s2varlst_set_sVarset (s2vs, s2Vs)
  val () = trans3_env_add_svarlst (s2vs)
//
in
  // nothing
end // end of [val]
//
val ((*freed*)) = list_vt_free (s2vs)
//
val s2ps = s2es2vss2ps.2
val ((*added*)) =
  trans3_env_hypadd_proplst_vt (loc0, s2ps)
//
in
  s2es2vss2ps.0
end // end of [s2hnf_absuni_and_add]

(* ****** ****** *)

implement
s2hnf_opnexi_and_add
  (loc0, s2f0) = let
//
val s2e0 = s2hnf2exp (s2f0)
//
val s2es2vss2ps = s2exp_opnexi (s2e0)
//
val s2vs = s2es2vss2ps.1
//
val () = let
  val s2vs = glist_make_list_vt (list_vt_copy (s2vs))
  val s2Vs = the_s2Varset_env_get ()
  val () = s2varlst_set_sVarset (s2vs, s2Vs)
  val () = trans3_env_add_svarlst (s2vs)
in
  // nothing
end // end of [val]
//
val ((*freed*)) = list_vt_free (s2vs)
//
val ((*added*)) =
  trans3_env_hypadd_proplst_vt (loc0, s2es2vss2ps.2)
//
in
  s2es2vss2ps.0
end // end of [s2hnf_opnexi_and_add]

(* ****** ****** *)

implement
s2hnf_opn1exi_and_add
  (loc0, s2f0) = let
  val s2e0 = s2hnf2exp (s2f0)
in
//
case+ s2exp_node_view (s2e0.s2exp_node ()) of
| ~S2Eexi (
    s2vs, s2ps, s2e_body
  ) => let
//
    var sub = stasub_make_nil ()
    val s2vs = stasub_extend_svarlst (sub, s2vs)
    val s2ps = s2explst_subst_vt (sub, s2ps) // HX: returning a linear list
    val s2e_body = s2exp_subst (sub, s2e_body)
    val () = stasub_free (sub)
//
    val () = let
      val s2vs = glist_make_list_vt (list_vt_copy (s2vs))
      val s2Vs = the_s2Varset_env_get ()
      val () = s2varlst_set_sVarset (s2vs, s2Vs)
      val () = trans3_env_add_svarlst (s2vs)
    in
      // nothing
    end // end of [val]
    val () = list_vt_free (s2vs)
//
    val () = trans3_env_hypadd_proplst_vt (loc0, s2ps)
//
  in
    s2e_body
  end // end of [S2Eexi]
| v => (s2exp_node_view_free (v); s2e0) // end of [_]
//
end // end of [s2hnf_opn1exi_and_add]

(* ****** ****** *)

fun
opninv_auxres
(
  s2e: s2exp
) : Option_vt (wths2explst) =
(
case+
s2exp_node_view (s2e.s2exp_node ())
of // case+
| ~S2Eexi
    (_, _, s2e) => opninv_auxres (s2e)
  // end of [S2Eexi]
| ~S2Ewthtype
    (_, ws2es) => Some_vt(ws2es)
  // end of [S2Ewthtype]
| v (*rest-of-S2E*) => (s2exp_node_view_free (v); None_vt ())
) (* end of [opninv_auxres] *)

fun
opninv_auxarg
(
  loc: loc_t
, s2es: s2explst, ws2es: wths2explst
) : s2explst = let
in
//
case+ glist_view (s2es) of
//
| ~GLnil
    ((*void*)) => glist_nil ()
| ~GLcons
    (s2e, s2es) => (
  case+ wths2explst_view (ws2es) of
  | ~WTHS2EXPLSTcons_invar
      (_, _, ws2es) => let
      val-~S2Erefarg
        (knd, s2e) = s2exp_node_view (s2e.s2exp_node ())
      var err: int = 0
      val @(s2e, s2ps) =
        s2exp_exi_instantiate_all (s2e, loc, err)
      val () = trans3_env_add_proplst_vt (loc, s2ps)
      val s2e = s2exp_refarg (knd, s2e)
    in
      glist_cons (s2e, opninv_auxarg (loc, s2es, ws2es))
    end // end of [WTHS2EXPLSTcons_invar]
  | ~WTHS2EXPLSTcons_trans
      (_, _, ws2es) =>
      glist_cons (s2e, opninv_auxarg (loc, s2es, ws2es))
  | ~WTHS2EXPLSTcons_none (ws2es) =>
      glist_cons (s2e, opninv_auxarg (loc, s2es, ws2es))
  | ~WTHS2EXPLSTnil((*void*)) => glist_nil((*void*))
  ) (* end of [list_cons] *)
//
end // end of [opninv_auxarg]

implement
s2fun_opninv_and_add
  (locarg, s2es_arg, s2e_res) = let
  val opt = opninv_auxres (s2e_res)
in
  case+ opt of
  | ~Some_vt
      (ws2es) => opninv_auxarg (locarg, s2es_arg, ws2es)
  | ~None_vt () => s2es_arg
end // end of [s2fun_arg_res_opninv_and_add]

(* ****** ****** *)

implement
d2var_opnset_and_add
  (loc, d2v) = let
//
val opt = d2var_get_type (d2v)
//
in
//
case+ gopt_view (opt) of
| ~GOsome (s2e) => let
    val s2f = s2exp2hnf (s2e)
    val s2e = s2hnf_opnexi_and_add (loc, s2f)
  in
    d2var_set_type (d2v, gopt_some (s2e))
  end // end of [Some]
| ~GOnone () => d2var_set_type (d2v, gopt_none ())
//
end // end of [d2var_opnset_and_add]

(* ****** ****** *)

implement
un_s2exp_wthtype
  (loc, s2e) = let
//
var s2e_res: s2exp = s2e
var wths2es: wths2explst = wths2explst_WTHS2EXPLSTnil ()
//
val
iswth = s2exp_is_wthtype (s2e)
//
val () =
if iswth then let
  val s2f = s2exp2hnf (s2e)
  val s2e = s2hnf_opnexi_and_add (loc, s2f)
  val-~S2Ewthtype (s2e, wths2es1) = s2exp_node_view (s2e.s2exp_node ())
in
  s2e_res := s2e; wths2es := wths2es1
end : void // end of [val]
//
in
  @(iswth, s2e_res, wths2es)
end // end of [un_s2exp_wthtype]

(* ****** ****** *)

implement
d3exp_open_and_add
  (d3e) = let
//
val s2e = d3e.d3exp_type ()
val s2f = s2exp2hnf (s2e)
//
val s2e =
  s2hnf_opnexi_and_add(d3e.d3exp_loc (), s2f)
//
in
  d3exp_set_type (d3e, s2e)
end // end of [d3exp_open_and_add]

implement
d3explst_open_and_add
  (d3es) = (
  case+ glist_view (d3es) of
  | ~GLcons (d3e, d3es) => (d3exp_open_and_add (d3e); d3explst_open_and_add (d3es))
  | ~GLnil () => ()
) // end of [d3explst_open_and_add]

(* ****** ****** *)

implement
the_trans3_env_initialize
  ((*void*)) = {
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_bool_t0ype)
  val s2c1 = s2cstref_get_cst (the_bool_bool_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_char_t0ype)
  val s2c1 = s2cstref_get_cst (the_char_int_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_schar_t0ype)
  val s2c1 = s2cstref_get_cst (the_schar_int_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_uchar_t0ype)
  val s2c1 = s2cstref_get_cst (the_uchar_int_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_g0int_t0ype)
  val s2c1 = s2cstref_get_cst (the_g1int_int_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_g0uint_t0ype)
  val s2c1 = s2cstref_get_cst (the_g1uint_int_t0ype)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_ptr_type)
  val s2c1 = s2cstref_get_cst (the_ptr_addr_type)
} // end of [val]
//
val () =
  s2cst_add_sup (s2c1, s2c0) where {
  val s2c0 = s2cstref_get_cst (the_string_type)
  val s2c1 = s2cstref_get_cst (the_string_int_type)
} // end of [val]
//
} // end of [the_trans3_env_initialize]

(* ****** ****** *)

implement
the_trans3_finget_constraint
  ((*void*)) = let
//
val s3is = the_s3itmlst_env_pop ()
//
in
  c3nstr_itmlst($LOC.location_dummy, c3nstrkind_C3TKmain(), s3is)
end // end of [the_trans3_finget_constraint]

(* ****** ****** *)

(* end of [pats_trans3_env.dats] *)
