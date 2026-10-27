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
// Start Time: February, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3.dats, see PORTING.md, "Constraint solving (constraint3)")
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

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_constraint3"

(* ****** ****** *)

staload "./pats_intinf.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_stacst2.sats"

(* ****** ****** *)

staload _(*anon*) = "./pats_staexp2_scst.dats" // [s2cstmap_find]

(* ****** ****** *)

staload "./pats_trans3_env.sats"

(* ****** ****** *)

staload "./pats_constraint3.sats"

(* ****** ****** *)

#include "./pats_constraint3.hats"

(* ****** ****** *)

#include "./pats_constraint3_gen_dats.hats"

(* ****** ****** *)

implement
s3exp_err (s2t) = s3exp_S3Eerr (s2t)

(* ****** ****** *)

implement
s3exp_var (s2v) = let
  val isb = s2var_is_bool (s2v)
in
  if isb then s3exp_S3Ebvar (s2v) else s3exp_S3Evar (s2v)
end // end of [s3exp_var]

(* ****** ****** *)

implement s3exp_bvar (s2v) = s3exp_S3Ebvar (s2v)

(* ****** ****** *)

implement
s3exp_cst (s2c) = s3exp_S3Ecst (s2c)

(* ****** ****** *)

implement
s3exp_app (_fun, _arg) = s3exp_S3Eapp (_fun, _arg)

(* ****** ****** *)
//
implement s3exp_null = s3exp_S3Enull ()
implement s3exp_unit = s3exp_S3Enull () // HX: [sic] (as in ATS1)
//
implement s3exp_true = s3exp_S3Ebool (true)
implement s3exp_false = s3exp_S3Ebool (false)
//
implement intinf_0 = intinf_make_int (0)
implement intinf_1 = intinf_make_int (1)
implement intinf_2 = intinf_make_int (2)
implement intinf_neg_1 = intinf_make_int (~1)
//
implement s3exp_0 = s3exp_S3Enull ()
implement s3exp_1 = s3exp_S3Eunit ()
implement s3exp_2 = s3exp_intinf (intinf_2)
implement s3exp_neg_1 = s3exp_intinf (intinf_neg_1)
//
(* ****** ****** *)

implement
s3exp_bool (b) =
  if b then s3exp_true else s3exp_false
// end of [s3exp_bool]

(* ****** ****** *)

implement
s3exp_get_srt (s3e) = let
in
//
case+ s3exp_view (s3e) of
| ~S3Evar (s2v) =>
    s2var_get_srt (s2v)
| ~S3Ecst (s2c) =>
    s2cst_get_srt (s2c)
| ~S3Enull () => s2rt_int
| ~S3Eunit () => s2rt_int
| ~S3Ebool (b) => s2rt_bool
//
| ~S3Ebvar _ => s2rt_bool
| ~S3Ebneg _ => s2rt_bool
| ~S3Ebadd _ => s2rt_bool
| ~S3Ebmul _ => s2rt_bool
| ~S3Ebeq _ => s2rt_bool
| ~S3Ebneq _ => s2rt_bool
| ~S3Ebineq _ => s2rt_bool
//
| ~S3Ebdom _ => s2rt_bool
//
| ~S3Eiatm _ => s2rt_int
| ~S3Eicff _ => s2rt_int
| ~S3Eisum _ => s2rt_int
| ~S3Eimul _ => s2rt_int
//
| ~S3Esizeof _ => s2rt_int
//
| ~S3Eapp (s3e_fun, _) => (
    case+ s2rt_viewof (s3exp_get_srt (s3e_fun)) of
    | ~S2RTfun (_, s2t) => s2t
    | v => (s2rt_view_free (v); $ERR.abort_interr<s2rt> ())
  ) // end of [S3Eapp]
//
| ~S3Eerr (s2t) => s2t
//
end // end of [s3exp_get_srt]

(* ****** ****** *)

implement
s3exp_get_fvs (s3e0) = let
//
vtypedef res = s2varset_vt
//
fun traux (
  res: res, xs: s2varlst_vt
) : res =
  case+ xs of
  | ~list_vt_cons (x, xs) => let
      val res = s2varset_vt_add (res, x) in traux (res, xs)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => res
// end of [traux]
//
fun loop
  (res: res, s3e0: s3exp): res = let
in
//
case+ s3exp_view (s3e0) of
| ~S3Evar (s2v) => s2varset_vt_add (res, s2v)
| ~S3Ecst _ => res
| ~S3Enull _ => res
| ~S3Eunit _ => res
| ~S3Ebool _ => res
//
| ~S3Ebvar (s2v) => s2varset_vt_add (res, s2v)
| ~S3Ebneg (s3e) => loop (res, s3e)
| ~S3Ebadd (s3e1, s3e2) => let
    val res = loop (res, s3e1) in loop (res, s3e2)
  end // end of [S3Ebadd]
| ~S3Ebmul (s3e1, s3e2) => let
    val res = loop (res, s3e1) in loop (res, s3e2)
  end // end of [S3Ebmul]
| ~S3Ebeq (s3e1, s3e2) => let
    val res = loop (res, s3e1) in loop (res, s3e2)
  end // end of [S3Ebeq]
| ~S3Ebneq (s3e1, s3e2) => let
    val res = loop (res, s3e1) in loop (res, s3e2)
  end // end of [S3Ebneq]
| ~S3Ebineq (_, s3e) => loop (res, s3e)
//
| ~S3Ebdom (s2v) => s2varset_vt_add (res, s2v)
//
| ~S3Eiatm (s2vs) => traux (res, s2varmset_listize (s2vs))
| ~S3Eicff (_, s3e) => loop (res, s3e)
| ~S3Eisum (s3es) => looplst (res, s3es)
| ~S3Eimul (s3e1, s3e2) => let
    val res = loop (res, s3e1) in loop (res, s3e2)
  end // end of [S3Eimul]
//
| ~S3Esizeof _ => res
//
| ~S3Eapp (s3e1, s3es2) => let
    val res = loop (res, s3e1)
  in
    looplst (res, s3es2)
  end // end of [S3Eapp]
//
| ~S3Eerr (s2t) => res
//
end // end of [loop]
//
and looplst
  (res: res, xs: s3explst): res =
  if glist_is_cons (xs) then let
    val res = loop (res, glist_head<s3exp> (xs))
  in
    looplst (res, glist_tail<s3exp> (xs))
  end else res
// end of [looplst]
//
val res = s2varset_vt_nil ()
//
in
  loop (res, s3e0)
end // end of [s3exp_get_fvs]

(* ****** ****** *)

implement
s3exp_syneq
  (x1, x2) = let
in
//
case+ s3exp_view (x1) of
| ~S3Evar s2v1 => (
  case+ s3exp_view (x2) of
  | ~S3Evar s2v2 => s2v1 = s2v2 | v => (s3exp_view_free (v); false)
  ) // end of [S3Evar]
| ~S3Ecst s2c1 => (
  case+ s3exp_view (x2) of
  | ~S3Ecst s2c2 => s2c1 = s2c2 | v => (s3exp_view_free (v); false)
  ) // end of [S3Ecst]
//
| ~S3Enull () => (
  case+ s3exp_view (x2) of
  | ~S3Enull () => true | v => (s3exp_view_free (v); false)
  ) // end of [S3Enull]
| ~S3Eunit () => (
  case+ s3exp_view (x2) of
  | ~S3Eunit () => true | v => (s3exp_view_free (v); false)
  ) // end of [S3Eunit]
| ~S3Ebool b1 => (
  case+ s3exp_view (x2) of
  | ~S3Ebool b2 => (b1 = b2) | v => (s3exp_view_free (v); false)
  ) // end of [S3Ebool]
//
| ~S3Ebvar (s2v1) => (
  case+ s3exp_view (x2) of
  | ~S3Ebvar (s2v2) => s2v1 = s2v2 | v => (s3exp_view_free (v); false)
  ) // end of [S3Ebvar]
//
| ~S3Ebneg (x1) => (
  case+ s3exp_view (x2) of
  | ~S3Ebneg (x2) => s3exp_syneq (x1, x2) | v => (s3exp_view_free (v); false)
  ) // end of [S3Ebneg]
//
| ~S3Ebadd (x11, x12) => (
  case+ s3exp_view (x2) of
  | ~S3Ebadd (x21, x22) =>
    if s3exp_syneq (x11, x21) then s3exp_syneq (x12, x22) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Ebadd] *)
| ~S3Ebmul (x11, x12) => (
  case+ s3exp_view (x2) of
  | ~S3Ebmul (x21, x22) =>
    if s3exp_syneq (x11, x21) then s3exp_syneq (x12, x22) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Ebmul] *)
//
| ~S3Ebeq (x11, x12) => (
  case+ s3exp_view (x2) of
  | ~S3Ebeq (x21, x22) =>
    if s3exp_syneq (x11, x21) then s3exp_syneq (x12, x22) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Ebeq] *)
| ~S3Ebneq (x11, x12) => (
  case+ s3exp_view (x2) of
  | ~S3Ebneq (x21, x22) =>
    if s3exp_syneq (x11, x21) then s3exp_syneq (x12, x22) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Ebneq] *)
//
| ~S3Ebineq (knd1, x1) =>
  (case+ s3exp_view (x2) of
  | ~S3Ebineq (knd2, x2) =>
    if knd1 = knd2 then s3exp_syneq (x1, x2) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) // end of [S3Ebineq]
//
| ~S3Ebdom (s2v1) => (
  case+ s3exp_view (x2) of
  | ~S3Ebdom (s2v2) => s2v1 = s2v2 | v => (s3exp_view_free (v); false)
  ) // end of [S3Ebdom]
//
| ~S3Eiatm (s2vs1) => (
  case+ s3exp_view (x2) of
  | ~S3Eiatm (s2vs2) => s2varmset_is_equal (s2vs1, s2vs2)
  | v => (s3exp_view_free (v); false)
  ) (* end of [S3Eiatm] *)
| ~S3Eicff (c1, x1) => (
  case+ s3exp_view (x2) of
  | ~S3Eicff (c2, x2) =>
    if c1 = c2 then s3exp_syneq (x1, x2) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Eicff] *)
| ~S3Eisum (xs1) => (
  case+ s3exp_view (x2) of
  | ~S3Eisum (xs2) => s3explst_syneq (xs1, xs2)
  | v => (s3exp_view_free (v); false)
  ) (* end of [S3Eiadd] *)
| ~S3Eimul (x11, x12) => (
  case+ s3exp_view (x2) of
  | ~S3Eimul (x21, x22) =>
    if s3exp_syneq (x11, x21) then s3exp_syneq (x12, x22) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Eimul] *)
//
| ~S3Esizeof (s2ze1) => (
  case+ s3exp_view (x2) of
  | ~S3Esizeof (s2ze2) => s2zexp_syneq (s2ze1, s2ze2)
  | v => (s3exp_view_free (v); false)
  ) (* end of [S3Esizeof] *)
//
| ~S3Eapp (x1, xs1) => (
  case+ s3exp_view (x2) of
  | ~S3Eapp (x2, xs2) =>
    if s3exp_syneq (x1, x2) then s3explst_syneq (xs1, xs2) else false
  | v => (s3exp_view_free (v); false) // end of [_]
  ) (* end of [S3Eapp] *)
//
| ~S3Eerr (s2t) => false
//
end // end of [s3exp_syneq]

(* ****** ****** *)

implement
s3explst_syneq
  (xs1, xs2) = (
  if glist_is_cons (xs1) then (
    if glist_is_cons (xs2) then (
      if s3exp_syneq (glist_head<s3exp> (xs1), glist_head<s3exp> (xs2))
        then s3explst_syneq (glist_tail<s3exp> (xs1), glist_tail<s3exp> (xs2)) else false
    ) else false
  ) else (
    if glist_is_cons (xs2) then false else true
  ) (* end of [glist_nil] *)
) (* end of [s3explst_syneq] *)

(* ****** ****** *)

local

fun
synlt_s2hnf_s2hnf
(
  s2f1: s2hnf, s2f2: s2hnf
) : bool = let
  val s2e2 = s2hnf2exp s2f2
in
  case+ s2exp_node_view (s2e2.s2exp_node ()) of
  | ~S2Eapp (_, s2es2) => synlte_s2hnf_s2explst (s2f1, s2es2)
  | v => (s2exp_node_view_free (v); false)
end // end pf [s2exp_synlt]

and
synlte_s2hnf_s2hnf
(
  s2f1: s2hnf, s2f2: s2hnf
) : bool =
  s2hnf_syneq (s2f1, s2f2) orelse synlt_s2hnf_s2hnf (s2f1, s2f2)
(* end of [synlte_s2hnf_s2hnf] *)

//
// HX-2012-02:
// [s2f1] <= at least one of [s2es2]
//
and
synlte_s2hnf_s2explst
(
  s2f1: s2hnf, s2es2: s2explst
): bool =
  if glist_is_cons (s2es2) then let
    val s2e2 = glist_head<s2exp> (s2es2)
    val s2es2 = glist_tail<s2exp> (s2es2)
    val s2f2 = s2exp2hnf (s2e2)
  in
    if synlte_s2hnf_s2hnf (s2f1, s2f2)
      then true else synlte_s2hnf_s2explst (s2f1, s2es2)
    // end of [if]
  end else false
// end of [synlte_s2hnf_s2explst]

in (* in of [local] *)

fun
s2exp_synlt
(
  s2e1: s2exp, s2e2: s2exp
) : bool = let
  val s2f1 = s2exp2hnf (s2e1) and s2f2 = s2exp2hnf (s2e2)
in
  synlt_s2hnf_s2hnf (s2f1, s2f2)
end // end of [s2exp_synlt]

fun
s2exp_synlte
(
  s2e1: s2exp, s2e2: s2exp
) : bool = let
  val s2f1 = s2exp2hnf (s2e1) and s2f2 = s2exp2hnf (s2e2)
in
  synlte_s2hnf_s2hnf (s2f1, s2f2)
end // end of [s2exp_synlt]

end // end of [local]

(* ****** ****** *)

local

fun auxlt
(
  isint: bool
, s2e1: s2exp, s2e2: s2exp
, lt: &int >> int
) : s2exp =
  if isint then
    s2exp_intlt (s2e1, s2e2)
  else let
    val islt = s2exp_synlt (s2e1, s2e2)
    val () = (if islt then lt := 1 else lt := ~1): void
  in
    s2exp_bool (islt)
  end // end of [if]
// end of [auxlt]
//
fun auxlte
(
  isint: bool
, s2e1: s2exp, s2e2: s2exp
, lte: &int >> int
) : s2exp =
  if isint then
    s2exp_intlte (s2e1, s2e2)
  else let
    val islte = s2exp_synlte (s2e1, s2e2)
    val () = (if islte then lte := 1 else lte := ~1): void
  in
    s2exp_bool (islte)
  end // end of [if]
//
fun auxlst
(
  s2es1: s2explst, s2es2: s2explst
) : s2exp = let
in
//
if glist_is_cons (s2es1) then let
  val s2e1 = glist_head<s2exp> (s2es1)
  val s2es1 = glist_tail<s2exp> (s2es1)
  var lt: int = 0
  var lte: int = 0
in
  if glist_is_cons (s2es2) then let
    val s2e2 = glist_head<s2exp> (s2es2)
    val s2es2 = glist_tail<s2exp> (s2es2)
    val isint = s2rt_is_int (s2e1.s2exp_srt ())
    val s2p_lt = auxlt (isint, s2e1, s2e2, lt)
  in
    if lt > 0 then s2p_lt (*true*)
    else if lt = 0 then let
      val s2p_lte =
        auxlte (isint, s2e1, s2e2, lte)
      // end of [val]
      val s2p_rest = auxlst (s2es1, s2es2)
    in
      s2exp_badd (s2p_lt, s2exp_bmul (s2p_lte, s2p_rest))
    end // end of [lt = 0]
    else let (* lt < 0 *)
      val s2p_lte =
        auxlte (isint, s2e1, s2e2, lte)
      // end of [val]
    in
      if lte >= 0
        then auxlst (s2es1, s2es2) else s2p_lte (*false*)
      // end of [if]
    end // end of [lt < 0]
  end else s2exp_bool (true)
end (* end of [list_cons] *)
else s2exp_bool (false)
//
end // end of [auxlst]

in (* in of [local] *)

fun s2exp_metdec_reduce
  (met: s2explst, met_bound: s2explst): s2exp = auxlst (met, met_bound)
// end of [s2exp_metdec_reduce]

end // end of [local]

(* ****** ****** *)

local

fun
auxeq
(
  env: &s2vbcfenv, s2e1: s2exp, s2e2: s2exp
) : s3exp = let
//
val s2t1 = s2e1.s2exp_srt ()
val s3e1 = s3exp_make (env, s2e1)
val s3e2 = s3exp_make (env, s2e2)
//
in
//
if s2rt_is_int (s2t1) then s3exp_ieq (s3e1, s3e2)
else if s2rt_is_addr (s2t1) then s3exp_ieq (s3e1, s3e2)
else if s2rt_is_bool (s2t1) then s3exp_beq (s3e1, s3e2)
else (
  if s2exp_syneq (s2e1, s2e2) then s3exp_true else s3exp_err (s2rt_bool)
) // end of [_]
//
end // end of [auxeq]

fun
auxbind (
  loc0: location
, env: &s2vbcfenv, s2v1: s2var, s2e2: s2exp
) : s3exp = let
//
val s2e1 = s2exp_var (s2v1)
val s3be = auxeq (env, s2e1, s2e2)
val s2f2 = s2exp2hnf (s2e2)
val () = trans3_env_hypadd_bind (loc0, s2v1, s2f2)
//
in
  s3be
end // end of [aux_bind]

in (* in of [local] *)

implement
s3exp_make
  (env, s2e0) = let
  val s2f0 = s2exp2hnf (s2e0)
  val s2e0 = s2hnf2exp (s2f0)
in
//
case+ s2exp_node_view (s2e0.s2exp_node ()) of
//
| ~S2Evar s2v => s3exp_var (s2v)
//
| ~S2Eint i => s3exp_int (i)
| ~S2Eintinf (int) => s3exp_intinf (int)
//
| ~S2Ecst s2c => (
  if s2cstref_equ_cst (the_null_addr, s2c) then s3exp_null
  else if s2cstref_equ_cst (the_true_bool, s2c) then s3exp_true
  else if s2cstref_equ_cst (the_false_bool, s2c) then s3exp_false
  else s3exp_cst (s2c) (*non-primitive-cst*)
  ) (* end of [S2Ecst] *)
//
| ~S2Eapp
    (s2e1, s2es2) => (
  case+ s2exp_node_view (s2e1.s2exp_node ()) of
  | ~S2Ecst s2c1 =>
      s3exp_make_s2cst_s2explst (env, s2c1, s2es2)
    // end of [S2Ecst]
  | v (*non-cst*) => let
      val () = s2exp_node_view_free (v)
      val s3e1 = s3exp_make (env, s2e1)
      val s3es2 = s3explst_make (env, s2es2)
    in
      s3exp_S3Eapp (s3e1, s3es2)
    end // end of [non-cst]
  ) (* end of [S2Eapp] *)
| ~S2Eeqeq (s2e1, s2e2) => auxeq (env, s2e1, s2e2)
| ~S2Emetdec (met, met_bound) => let
    val s2e_met = s2exp_metdec_reduce (met, met_bound)
  in
    s3exp_make (env, s2e_met)
  end // end of [S3Emetdec]
| ~S2Esizeof (s2e) => let
    val s2ze = s2zexp_make_s2exp (s2e) in s3exp_S3Esizeof (s2ze)
  end // end of [S2Esizeof]
//
| v => let // an expression that cannot be handled
    val () = s2exp_node_view_free (v)
  in
    s3exp_err (s2e0.s2exp_srt ())
  end // end of [_]
//
end // end of [s3exp_make]

implement
s3exp_make_h3ypo
  (env, h3p) = (
  case+ h3ypo_node_view (h3p.h3ypo_node ()) of
  | ~H3YPOprop s2p => s3exp_make (env, s2p)
  | ~H3YPObind (s2v1, s2e2) => auxbind (h3p.h3ypo_loc (), env, s2v1, s2e2)
  | ~H3YPOeqeq (s2e1, s2e2) => auxeq (env, s2e1, s2e2)
) // end of [s3exp_make_h3ypo]

end // end of [local]

(* ****** ****** *)

implement
s3explst_make
  (env, s2es) = let
in
//
if glist_is_cons (s2es) then let
  val s3e = s3exp_make (env, glist_head<s2exp> (s2es))
  val s3es = s3explst_make (env, glist_tail<s2exp> (s2es))
in
  glist_cons<s3exp> (s3e, s3es)
end else glist_nil{s3exp} ((*void*))
//
end // end of [s3explst_make]

(* ****** ****** *)

local
//
vtypedef s3expopt_vt = Option_vt (s3exp)
//
datavtype
s2vbclst =
  | S2VBCFLSTsvar of (s2var, s2vbclst)
  | S2VBCFLSTsbexp of (s3exp, s2vbclst)
  | S2VBCFLSTcons of (
      s2cst(*scf*), s3explst(*arg*), s2var(*res*), s3expopt_vt(*rel*), s2vbclst
    ) // end of [S2VBCFLSTcons]
  | S2VBCFLSTnonlin of (s2var, s3exp, s2vbclst)
  | S2VBCFLSTmark of s2vbclst
  | S2VBCFLSTnil of ()
// end of [s2vbclst]

assume
s2vbcfenv_vtype = s2vbclst

in (* in of [local] *)

implement
s2vbcfenv_nil () = S2VBCFLSTnil ()

implement
s2vbcfenv_free (env) = (
  case+ env of
  | ~S2VBCFLSTsvar (_, env) => s2vbcfenv_free (env)
  | ~S2VBCFLSTsbexp (_, env) => s2vbcfenv_free (env)
  | ~S2VBCFLSTcons (_, _, _, opt, env) => let
      val () = option_vt_free (opt) in s2vbcfenv_free (env)
    end // end of [S2VBCFLSTcons]
  | ~S2VBCFLSTnonlin (_, _, env) => s2vbcfenv_free (env)
  | ~S2VBCFLSTmark (env) => s2vbcfenv_free (env)
  | ~S2VBCFLSTnil () => ()
) // end of [s2vbcfenv_free]

implement
s2vbcfenv_pop (env) = let
  fun aux (
    env: s2vbclst
  ) : s2vbclst = case+ env of
    | ~S2VBCFLSTsvar (_, env) => aux (env)
    | ~S2VBCFLSTsbexp (_, env) => aux (env)
    | ~S2VBCFLSTcons
        (_, _, _, opt, env) => let
        val () = option_vt_free (opt) in aux (env)
      end (* end of [S2VBCFLSTcons] *)
    | ~S2VBCFLSTnonlin (_, _, env) => aux (env)
    | ~S2VBCFLSTmark (env) => env // HX: pop is done
    | ~S2VBCFLSTnil () => S2VBCFLSTnil ()
  // end of [aux]
in
  env := aux (env)
end (* end of [s2vbcflst_pop] *)

implement
s2vbcfenv_push (env) = let
  val () = env := S2VBCFLSTmark (env) in (*nothing*)
end // end of [s2vbcfenv_push]

(* ****** ****** *)

implement
s2vbcfenv_find_cstapp
  (env0, s2c0, s3es0) = let
in
//
case+ env0 of
//
| @S2VBCFLSTsvar
    (_, env) => let
    val ans = s2vbcfenv_find_cstapp (env, s2c0, s3es0)
  in
    ans
  end // end of [S2VBCFLSTsvar]
//
| @S2VBCFLSTsbexp
    (_, env) => let
    val ans = s2vbcfenv_find_cstapp (env, s2c0, s3es0)
  in
    ans
  end // end of [S2VBCFLSTsbexp]
//
| @S2VBCFLSTcons
    (s2c, s3es, s2v, _, env) => let
    val test = (
      if eq_s2cst_s2cst (s2c0, s2c)
        then s3explst_syneq (s3es0, s3es) else false
      // end of [val]
    ) : bool // end of [val]
  in
    if test then let
      val s2v = s2v
    in
      Some_vt (s2v)
    end else let
      val ans = s2vbcfenv_find_cstapp (env, s2c0, s3es0)
    in
      ans
    end (* end of [if] *)
  end // end of [S2VBCFLSTcons]
//
| @S2VBCFLSTnonlin
    (_, _, env) => let
    val ans = s2vbcfenv_find_cstapp (env, s2c0, s3es0)
  in
    ans
  end // end of [S2VBCFLSTnonlin]
//
| @S2VBCFLSTmark (env) => let
    val ans = s2vbcfenv_find_cstapp (env, s2c0, s3es0)
  in
    ans
  end // end of [S2VBCFLSTmark]
| @S2VBCFLSTnil () => None_vt () // end of [S2VBCFLSTnil]
//
end // end of [s2vbcfenv_find_cstapp]

(* ****** ****** *)

implement
s2vbcfenv_find_nonlin
  (env0, s3e0) = let
in
//
case+ env0 of
//
| @S2VBCFLSTsvar
    (_, env) => let
    val ans = s2vbcfenv_find_nonlin (env, s3e0)
  in
    ans
  end // end of [S2VBCFLSTsvar]
//
| @S2VBCFLSTsbexp
    (_, env) => let
    val ans = s2vbcfenv_find_nonlin (env, s3e0)
  in
    ans
  end // end of [S2VBCFLSTsbexp]
//
| @S2VBCFLSTcons
    (_, _, _, _, env) => let
    val ans = s2vbcfenv_find_nonlin (env, s3e0)
  in
    ans
  end // end of [S2VBCFLSTcons]
//
| @S2VBCFLSTnonlin
    (s2v, s3e, env) => let
    val test = s3exp_syneq (s3e0, s3e)
    val ans = (
      if test then Some_vt (s2v) else
        s2vbcfenv_find_nonlin (env, s3e0)
      // end of [if]
    ) : Option_vt (s2var)
  in
    ans
  end // end of [S2VBCFLSTnonlin]
//
| @S2VBCFLSTmark (env) => let
    val ans = s2vbcfenv_find_nonlin (env, s3e0)
  in
    ans
  end // end of [S2VBCFLSTmark]
| @S2VBCFLSTnil () => None_vt () // end of [S2VBCFLSTnil]
//
end // end of [s2vbcfenv_find_nonlin]

(* ****** ****** *)

implement
s2vbcfenv_extract (env) = let
//
fun loop (
  env: !s2vbcfenv
, s2vs: &s2varlst_vt >> _, s3bes: &s3explst_vt >> _
) : void = let
in
//
case+ env of
| @S2VBCFLSTsvar
    (s2v, env1) => let
    val () = s2vs := list_vt_cons (s2v, s2vs)
    val isb = s2var_is_bool (s2v)
    val () =
    if isb then
      s3bes := list_vt_cons (s3exp_S3Ebdom (s2v), s3bes)
    // end of [val]
    val () = loop (env1, s2vs, s3bes) in ()
  end // end of [S2VBCFLSTsvar]
| @S2VBCFLSTsbexp
    (s3be, env1) => let
    val () = s3bes := list_vt_cons (s3be, s3bes)
    val () = loop (env1, s2vs, s3bes) in ()
  end // end of [S2VBCFLSTsbexp]
| @S2VBCFLSTcons (
    s2c, arg, res, rel, env1
  ) => let
    val () = (
      case+ rel of
      | @Some_vt (s3be) => let
          val () = s3bes := list_vt_cons (s3be, s3bes) in ()
        end // end of [Some_vt]
      | @None_vt () => fold@ (rel)
    ) : void // end of [val]
    val () = loop (env1, s2vs, s3bes)
  in
    ()
  end // end of [S2VBCFLSTcons]
| @S2VBCFLSTnonlin
    (s2v, _, env1) => let
    val () = s2vs := list_vt_cons (s2v, s2vs)
    val () = loop (env1, s2vs, s3bes) in ()
  end // end of [S2VBCFLSTnonlin]
| @S2VBCFLSTmark (env1) => let
    val () = loop (env1, s2vs, s3bes) in ()
  end // end of [S2VBCFLSTmark]
| @S2VBCFLSTnil () => ()
//
end // [end of loop]
//
var s2vs: s2varlst_vt = list_vt_nil ()
var s3bes: s3explst_vt = list_vt_nil ()
val () = loop (env, s2vs, s3bes)
//
in
  @(s2vs, s3bes)
end // end of [s2vbcfenv_extract]

(* ****** ****** *)

fun
s2vbcfenv_add2_cstapp
(
  env: &s2vbcfenv
// HX: [s2c] is a defined (stadef) constant
, s2c: s2cst, arg1: s2explst, arg2: s3explst
, s2v: s2var
) : void = let
//
val () = env := S2VBCFLSTsvar (s2v, env)
//
val s2e_cst = s2exp_cst (s2c)
val s2e_var = s2exp_var (s2v)
val s2es1 = glist_append<s2exp> (arg1, glist_sing<s2exp> (s2e_var))
val s2e_rel =
  s2exp_app_srt (s2rt_bool, s2e_cst, s2es1)
//
val s3be = s3exp_make (env, s2e_rel)
//
val s3be = s3exp_lintize (env, s3be) // nonlin terms -> vars
//
in
  env := S2VBCFLSTcons (s2c, arg2, s2v, Some_vt (s3be), env)
end // end of [s2vbcfenv_add2_cstapp]

(* ****** ****** *)

implement
s2vbcfenv_add_svar
  (env, s2v) = (env := S2VBCFLSTsvar (s2v, env))
// end of [s2vbcfenv_add_svar]

implement
s2vbcfenv_add_sbexp
  (env, s3be) = (env := S2VBCFLSTsbexp (s3be, env))
// end of [s2vbcfenv_add_sbexp]

implement
s2vbcfenv_add_nonlin
  (env, s2v, s3e) = (
  env := S2VBCFLSTnonlin (s2v, s3e, env)
) (* end of [s2vbcfenv_add_nonlin] *)

(* ****** ****** *)

implement
s2vbcfenv_add_cstapp
  (env, s2c, s2es_arg, s2v) = let
//
val s3es_arg = s3explst_make (env, s2es_arg)
//
in
  s2vbcfenv_add2_cstapp (env, s2c, s2es_arg, s3es_arg, s2v)
end // end of [s2vbcfenv_add_cstapp]

(* ****** ****** *)

implement
s2vbcfenv_replace_cstapp
  (env, s2t, s2c, s2es_arg) = let
//
val s3es_arg =
  s3explst_make (env, s2es_arg)
//
val ans =
  s2vbcfenv_find_cstapp (env, s2c, s3es_arg)
//
in
//
case+ ans of
| ~Some_vt (s2v) => s2v
| ~None_vt
    ((*void*)) => s2v where
  {
    val s2v = s2var_make_srt (s2t)
    val () = s2vbcfenv_add2_cstapp (env, s2c, s2es_arg, s3es_arg, s2v)
  } (* end of [None_vt] *)
//
end // end of [s2vbcfenv_replace_cstapp]

(* ****** ****** *)

implement
s2vbcfenv_replace_nonlin
  (env, s3e) = let
//
val ans = s2vbcfenv_find_nonlin (env, s3e)
//
in
//
case+ ans of
| ~Some_vt (s2v) => s2v
| ~None_vt
    ((*void*)) => s2v where
  {
    val s2t = s3exp_get_srt (s3e)
    val s2v = s2var_make_srt (s2t)
    val () = s2vbcfenv_add_nonlin (env, s2v, s3e)
  } (* end of [None_vt] *)
//
end // end of [s2vbcfenv_replace_nonlin]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

local

stadef env = s2vbcfenv
typedef tfun = (&env, s2explst) -> s3exp

assume s2cfunmap_type = s2cstmap (tfun)

//
// HX: the (never freed) map, kept in a cell of the arena
//
val the_s2cfunmap = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, $UN.cast{ptr} (s2cstmap_nil<tfun> ()))
in
  p
end // end of [val]

in (* in of [local] *)

implement
s3exp_make_s2cst_s2explst
  (env, s2c, s2es) = let
val opt = s2cstmap_find<tfun> ($UN.ptr0_get<s2cfunmap> (the_s2cfunmap), s2c)
//
in
//
case+ opt of
| ~Some_vt f => f (env, s2es)
| ~None_vt _ => let
    val s3e = s3exp_cst (s2c)
    val s3es = s3explst_make (env, s2es)
  in
    s3exp_app (s3e, s3es)
  end // end of [None_vt]
//
end // end of [s3exp_make_s2cst_s2explst]

(* ****** ****** *)

implement
constraint3_initialize () = let
  var map: s2cfunmap = $UN.ptr0_get<s2cfunmap> (the_s2cfunmap)
  val () = constraint3_initialize_map (map)
in
  $UN.ptr0_set<s2cfunmap> (the_s2cfunmap, map)
end // end of [constraint3_initialize]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_constraint3.dats] *)
