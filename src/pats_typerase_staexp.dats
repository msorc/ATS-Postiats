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
// Start Time: July, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_typerase_staexp.dats, see PORTING.md, "Type erasure (typerase)")
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

staload LAB = "./pats_label.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_typerase.sats"

(* ****** ****** *)

#include "./pats_typerase.hats"

(* ****** ****** *)

extern
fun s2cst_tyer
  (loc: location, flag: int, s2c: s2cst): hisexp
// end of [s2cst_tyer]

(* ****** ****** *)

extern
fun s2hnf_tyer
  (loc: location, flag: int, s2f: s2hnf): hisexp
// end of [s2hnf_tyer]

(* ****** ****** *)

extern
fun
s2exp_tyer_app
(
  loc: location, flag: int, s2t: s2rt, _fun: s2exp, _arg: s2explst
) : hisexp // end of [s2exp_tyer_app]
extern
fun
s2exp_tyer_app2
(
  loc: location, flag: int, s2t: s2rt, _fun: s2exp, _arg: s2explst
) : hisexp // end of [s2exp_tyer_app2]
extern
fun
s2exp_tyer_apphnf
(
  loc: location, flag: int, s2t: s2rt, _fun: s2hnf, _arg: s2explst
) : hisexp // end of [s2exp_tyer_apphnf]
extern
fun
s2exp_tyer_appcst
(
  loc: location, flag: int, s2t: s2rt, _fun: s2cst, _arg: s2explst
) : hisexp // end of [s2exp_tyer_appcst]

(* ****** ****** *)

extern
fun s2explst_tyer_arglst (loc: location, s2es: s2explst): hisexplst

(* ****** ****** *)

extern
fun s2exp_tyer_fun
  (loc: location, flag: int, s2e: s2exp): hisexp
// end of [s2exp_tyer_fun]

(* ****** ****** *)

extern
fun s2exp_tyer_datconptr
  (loc: location, flag: int, s2e: s2exp): hisexp
// end of [s2exp_tyer_datconptr]

extern
fun s2exp_tyer_datcontyp
  (loc: location, flag: int, s2e: s2exp): hisexp
// end of [s2exp_tyer_datcontyp]

(* ****** ****** *)

extern
fun s2exp_tyer_tyarr
  (loc: location, flag: int, s2e: s2exp): hisexp
// end of [s2exp_tyer_tyarr]

extern
fun s2exp_tyer_tyrec
  (loc: location, flag: int, s2e: s2exp): hisexp
// end of [s2exp_tyer_tyrec]

(* ****** ****** *)

extern
fun s2explst_tyer
  (loc: location, s2es: s2explst): hisexplst
extern
fun s2explst_npf_tyer
  (loc: location, npf: int, s2es: s2explst): hisexplst
extern
fun s2explst_npf_tyer_labize
  (loc: location, npf: int, s2es: s2explst): labhisexplst

extern
fun labs2explst_tyer
 (loc: location, flag: int, ls2es: labs2explst): labhisexplst
// end of [labs2explst_tyer]
extern
fun labs2explst_npf_tyer
  (loc: location, flag: int, npf: int, ls2es: labs2explst): labhisexplst
// end of [labs2explst_npf_tyer]

(* ****** ****** *)
//
extern
fun s2zexp_tyer_app
  (loc: location, _fun: s2zexp, _arg: s2zexplst): hisexp
extern
fun s2zexp_tyer_appcst (loc: location, s2c: s2cst, _arg: s2zexplst): hisexp
extern
fun s2zexplst_tyer_arglst (loc: location, s2zes: s2zexplst): hisexplst
//
(* ****** ****** *)

extern
fun s2zexp_tyer_tyrec (loc: location, s2ze: s2zexp): hisexp

(* ****** ****** *)

extern
fun labs2zexplst_tyer (loc: location, ls2zes: labs2zexplst): labhisexplst

(* ****** ****** *)

implement
s2cst_tyer
  (loc0, flag, s2c) = let
//
val opt = s2cst_get_isabs (s2c)
//
in
//
if gopt_is_some (opt) then let
  val opt2 = gopt_unsome (opt)
in
  if gopt_is_some (opt2) then let
    val s2e = gopt_unsome (opt2)
  in
    s2exp_tyer (loc0, flag, s2e)
  end else hisexp_cst (s2c) // end of [None]
end else hisexp_cst (s2c)
//
end // end of [s2cst_tyer]

(* ****** ****** *)

implement
s2exp_tyer
(
  loc0, flag, s2e0
) = let
  val s2f0 = s2exp2hnf (s2e0)
in
  s2hnf_tyer (loc0, flag, s2f0)
end // end of [s2hnf_tyer]

(* ****** ****** *)

implement
s2exp_tyer_deep
  (loc0, s2e0) = s2exp_tyer (loc0, 1(*flag*), s2e0)
// end of [s2exp_tyer_deep]

implement
s2exp_tyer_shallow
  (loc0, s2e0) = s2exp_tyer (loc0, 0(*flag*), s2e0)
// end of [s2exp_tyer_shallow]

(* ****** ****** *)

implement
s2hnf_tyer
  (loc0, flag, s2f0) = let
//
val s2e0 = s2hnf2exp (s2f0)
//
in
//
case+
  s2exp_node_view (s2e0.s2exp_node ()) of
//
| ~S2Ecst(s2c) =>
    s2cst_tyer(loc0, flag, s2c)
//
| ~S2Evar(s2v) => hisexp_tyvar(s2v)
//
| ~S2EVar(s2V) => // HX: use type-size
  s2zexp_tyer(loc0, s2Var_get_szexp(s2V))
  (* end of [S2EVar] *)
//
| ~S2Edatconptr (_, _, _) =>
    s2exp_tyer_datconptr(loc0, flag, s2e0)
| ~S2Edatcontyp (_, _) =>
    s2exp_tyer_datcontyp(loc0, flag, s2e0)
//
| ~S2Eapp
  (
    s2e_fun, s2es_arg
  ) => let
    val s2t0 = s2e0.s2exp_srt ()
  in
    s2exp_tyer_app(loc0, flag, s2t0, s2e_fun, s2es_arg)
  end // end of [S2Eapp]
| ~S2Elam(_, s2e_body) => s2exp_tyer(loc0, flag, s2e_body)
//
| ~S2Efun (_, _, _, _, _, _) => s2exp_tyer_fun(loc0, flag, s2e0)
| ~S2Emetfun(_, _, s2e_body) => s2exp_tyer (loc0, flag, s2e_body)
//
| ~S2Etop(_, s2e) => s2exp_tyer(loc0, flag, s2e)
| ~S2Ewithout (s2e) => s2exp_tyer(loc0, flag, s2e)
//
| ~S2Etyarr (_, _) => s2exp_tyer_tyarr(loc0, flag, s2e0)
| ~S2Etyrec (_, _, _) => s2exp_tyer_tyrec(loc0, flag, s2e0)
//
| ~S2Einvar (s2e) => s2exp_tyer(loc0, flag, s2e)
//
| ~S2Eexi(_, _, s2e) => s2exp_tyer(loc0, flag, s2e)
| ~S2Euni(_, _, s2e) => s2exp_tyer(loc0, flag, s2e)
//
| ~S2Erefarg
    (knd, s2e) => let
    val
    hse =
    s2exp_tyer_shallow(loc0, s2e) in hisexp_refarg(knd, hse)
  end // end of [S2Erefarg]
//
| ~S2Evararg(s2e) => hisexp_vararg(s2e)
//
| ~S2Ewthtype(s2e, _(*ws2es*)) => s2exp_tyer(loc0, flag, s2e)
//
| v (* rest-of-s2exp *) => (s2exp_node_view_free (v); hisexp_s2exp(s2e0))
//
end // end of [s2hnf_tyer]

(* ****** ****** *)

implement
s2exp_tyer_app
(
  loc0, flag, s2t0, s2e_fun, s2es_arg
) = let
  val s2f_fun = s2exp2hnf (s2e_fun)
  val s2e_fun = s2hnf2exp (s2f_fun)
in
//
if s2exp_node_is_S2Ecst (s2e_fun.s2exp_node ()) then let
  val-~S2Ecst (s2c) = s2exp_node_view (s2e_fun.s2exp_node ())
in
  s2exp_tyer_appcst (loc0, flag, s2t0, s2c, s2es_arg)
end else (* hnf *)
  s2exp_tyer_apphnf (loc0, flag, s2t0, s2f_fun, s2es_arg)
  // end of [_]
//
end // end of [s2exp_tyer_app]

implement
s2exp_tyer_app2 (
  loc0, flag, s2t0, s2e_fun, s2es_arg
) = let
//
val s2f_fun = s2exp2hnf (s2e_fun)
val s2e_fun = s2hnf2exp (s2f_fun)
//
in
//
if s2exp_node_is_S2Elam (s2e_fun.s2exp_node ()) then let
  val-~S2Elam (s2vs_arg, s2e_body) = s2exp_node_view (s2e_fun.s2exp_node ())
  var sub = stasub_make_nil ()
  val err =
    stasub_addlst (sub, s2vs_arg, s2es_arg)
  // end of [val]
  val s2e_body = s2exp_subst (sub, s2e_body)
  val ((*freed*)) = stasub_free (sub)
in
  s2exp_tyer (loc0, flag, s2e_body)  
end else (* hnf *)
  s2exp_tyer_apphnf (loc0, flag, s2t0, s2f_fun, s2es_arg)
  // end of [_]
//
end // end of [s2exp_tyer_app2]

(* ****** ****** *)

implement
s2exp_tyer_apphnf
(
  loc0, flag, s2t0, s2f_fun, s2es_arg
) = let
  val hse_fun = s2hnf_tyer (loc0, flag, s2f_fun)
  val hses_arg = s2explst_tyer_arglst (loc0, s2es_arg)
in
  hisexp_app (hse_fun, hses_arg)
end // end of [s2exp_tyer_apphnf]

(* ****** ****** *)

implement
s2exp_tyer_appcst
(
  loc0, flag, s2t0, s2c, s2es_arg
) = let
  val opt = s2cst_get_isabs (s2c)
in
//
if gopt_is_none (opt) then
  hisexp_make_srt (s2t0)
else let
  val opt2 = gopt_unsome (opt)
in
  if gopt_is_some (opt2) then let
    val _fun = gopt_unsome (opt2)
  in
    s2exp_tyer_app2
    (
      loc0, flag, s2t0, _fun, s2es_arg
    ) // end of [Some]
  end else let
    val hse_fun = s2cst_tyer (loc0, flag, s2c)
    val hses_arg = s2explst_tyer_arglst (loc0, s2es_arg)
  in
    hisexp_app (hse_fun, hses_arg)
  end // end of [None]
end (* end of [Some] *)
//
end // end of [s2exp_tyer_appcst]

(* ****** ****** *)

implement
s2exp_tyer_fun
  (loc0, flag, s2e0) = let
//
val-
~S2Efun
(
  fc, lin, s2fe, npf, s2es_arg, s2e_res
) = s2exp_node_view (s2e0.s2exp_node ())
//
in
//
if
flag > 0
then let
//
val
hses_arg =
s2explst_npf_tyer(loc0, npf, s2es_arg)
//
val hse_res = s2exp_tyer_shallow(loc0, s2e_res)
//
in
  hisexp_fun (fc, hses_arg, hse_res)
end // end of [then]
else (
  case+ fc of
  | FUNCLOfun() => hisexp_funptr
  | _ (* FUNCLOclo(knd) *) =>
      if funclo_get_clokind (fc) = 0 then hisexp_clotyp else hisexp_cloptr
    // end of [FUNCLOclo]
) (* end of [else] *)
//
end // end of [s2exp_tyer_fun]

(* ****** ****** *)
//
implement
s2exp_tyer_datconptr
  (loc0, flag, s2e0) = hisexp_datconptr
//
(* ****** ****** *)

implement
s2exp_tyer_datcontyp
  (loc0, flag, s2e0) = let
//
val-~S2Edatcontyp
  (d2c, s2es) = s2exp_node_view (s2e0.s2exp_node ())
//
in
//
if flag > 0 then let
  val npf = d2con_get_npf (d2c)
  val lhses = s2explst_npf_tyer_labize (loc0, npf, s2es)
in
  hisexp_tysum (d2c, lhses)
end else hisexp_datcontyp
//
end // end of [s2exp_tyer_datcontyp]

(* ****** ****** *)

implement
s2exp_tyer_tyarr
  (loc0, flag, s2e0) = let
//
val-~S2Etyarr
  (s2e_elt, dim) = s2exp_node_view (s2e0.s2exp_node ())
val hse_elt = s2exp_tyer (loc0, flag, s2e_elt)
//
in
  hisexp_tyarr (hse_elt, dim)
end // end of [s2exp_tyer_tyarr]

(* ****** ****** *)

implement
s2exp_tyer_tyrec
  (loc0, flag, s2e0) = let
//
val-~S2Etyrec
  (knd, npf, ls2es) = s2exp_node_view (s2e0.s2exp_node ())
val lhses =
  labs2explst_npf_tyer (loc0, flag, npf, ls2es)
//
in
//
if tyreckind_is_TYRECKINDbox (knd) then
  (
    if flag > 0 then
      hisexp_tyrec (knd, lhses) else hisexp_tybox
  ) // end of [TYRECKINDbox]
else if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)
else ( (* TYRECKINDflt0/1 *)
  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))
    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))
    else hisexp_tyrec (knd, lhses) (* non-sing *)
) // end of [TYRECKINDflt0/1]
//
end // end of [s2exp_tyer_tyrec]

(* ****** ****** *)

implement
s2explst_tyer
  (loc0, s2es) = let
in
//
if glist_is_cons (s2es) then let
    val s2e = glist_head<s2exp> (s2es)
    val s2es = glist_tail<s2exp> (s2es)
    val isprf = s2exp_is_prf (s2e)
  in
    if isprf then
      s2explst_tyer (loc0, s2es)
    else let
      val hse =
        s2exp_tyer_shallow (loc0, s2e)
      // end of [val]
      val hses = s2explst_tyer (loc0, s2es)
    in
      glist_cons (hse, hses)
    end // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [s2explst_tyer]

(* ****** ****** *)

implement
s2explst_npf_tyer
  (loc0, npf, s2es) = let
in
//
if npf > 0 then let
  val s2es = glist_tail_exn<s2exp> (s2es)
in
  s2explst_npf_tyer (loc0, npf-1, s2es)
end else
  s2explst_tyer (loc0, s2es)
// end of [if]
//
end // end of [s2explst_npf_tyer]

(* ****** ****** *)

fun
s2explst_npf_tyer_labize_aux (
  loc0: location
, npf: int, s2es: s2explst, i: int
) : labhisexplst = let
in
//
if npf > 0 then let
  val s2es = glist_tail_exn<s2exp> (s2es)
in
  s2explst_npf_tyer_labize_aux (loc0, npf-1, s2es, i+1)
end else ( // HX-2013-01: npf <= 0
//
if glist_is_cons (s2es) then let
    val s2e = glist_head<s2exp> (s2es)
    val s2es = glist_tail<s2exp> (s2es)
    val isprf = s2exp_is_prf (s2e)
  in
    if isprf then
      s2explst_npf_tyer_labize_aux (loc0, npf, s2es, i+1)  
    else let
      val lab =
        $LAB.label_make_int (i)
      val hse =
        s2exp_tyer_shallow (loc0, s2e)
      val lhse = labhisexp_new (lab, gopt_none (), hse)
      val lhses = s2explst_npf_tyer_labize_aux (loc0, npf, s2es, i+1)
    in
      glist_cons (lhse, lhses)
    end // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
) // end of [if]
//
end // end of [s2explst_npf_tyer_labize_aux]

implement
s2explst_npf_tyer_labize
  (loc0, npf, s2es) = s2explst_npf_tyer_labize_aux (loc0, npf, s2es, 0)
// end of [s2explst_npf_tyer_labize]

(* ****** ****** *)

implement
labs2explst_tyer
  (loc0, flag, ls2es) = let
in
//
if glist_is_cons (ls2es) then let
    val ls2e = glist_head<labs2exp> (ls2es)
    val ls2es = glist_tail<labs2exp> (ls2es)
    val l = ls2e.labs2exp_lab ()
    val name = ls2e.labs2exp_nam ()
    val s2e = ls2e.labs2exp_elt ()
    // end of [val]
    val isprf = s2exp_is_prf (s2e)
  in
    if isprf then
      labs2explst_tyer (loc0, flag, ls2es)
    else let
      val hse = s2exp_tyer (loc0, flag, s2e)
      val lhse = labhisexp_new (l, name, hse)
      val lhses = labs2explst_tyer (loc0, flag, ls2es)
    in
      glist_cons (lhse, lhses)
    end (* end of [if] *)
  end
else glist_nil ((*void*))
//
end // end of [labs2explst_tyer]

(* ****** ****** *)

implement
labs2explst_npf_tyer
  (loc0, flag, npf, ls2es) = let
in
//
if npf > 0 then let
  val ls2es = glist_tail_exn<labs2exp> (ls2es)
in
  labs2explst_npf_tyer (loc0, flag, npf-1, ls2es)
end else
  labs2explst_tyer (loc0, flag, ls2es)
// end of [if]
//
end // end of [labs2explst_npf_tyer]

(* ****** ****** *)

implement
s2explst_tyer_arglst
  (loc0, s2es) = let
in
//
if glist_is_cons (s2es) then let
    val s2e = glist_head<s2exp> (s2es)
    val s2es = glist_tail<s2exp> (s2es)
    val s2t = s2e.s2exp_srt ()
    val keep = s2rt_is_prgm (s2t)
    val keep = (
      if keep then true else s2rt_is_tkind (s2t)
    ) : bool // end of [val]
  in
    if keep then let
      val hse = s2exp_tyer_shallow (loc0, s2e)
      val hses = s2explst_tyer_arglst (loc0, s2es)
    in
      glist_cons (hse, hses)
    end else
      s2explst_tyer_arglst (loc0, s2es)
    // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [s2explst_tyer_arglst]

(* ****** ****** *)

implement
s2zexp_tyer
  (loc0, s2ze0) = let
//
in
//
case+ s2zexp_view (s2ze0) of
//
| ~S2ZEptr () => hisexp_tybox
//
| ~S2ZEcst (s2c) =>
    s2cst_tyer (loc0, 0(*flag*), s2c)
  // end of [S2ZEcst]
//
| ~S2ZEvar (s2v) => hisexp_tyvar (s2v)
//
| ~S2ZEapp (s2ze1, s2zes2) =>
    s2zexp_tyer_app (loc0, s2ze1, s2zes2)
//
| ~S2ZEtyrec (_, _) => s2zexp_tyer_tyrec (loc0, s2ze0)
//
// HX-2015-01-30:
// is this the right way to go?
| ~S2ZEVar (s2V) => hisexp_undefined
//
| v (* S2ZE-rest *) => (s2zexp_view_free (v); hisexp_s2zexp (s2ze0))
//
end // end of [s2zexp_tyer]

(* ****** ****** *)

implement
s2zexp_tyer_app
(
  loc0, s2ze1, s2zes2
) = let
//
val hse_fun =
  s2zexp_tyer (loc0, s2ze1)
val hses_arg =
  s2zexplst_tyer_arglst (loc0, s2zes2)
//
in
  hisexp_app (hse_fun, hses_arg)
end // end of [s2exp_tyer_app]

(* ****** ****** *)

implement
s2zexplst_tyer_arglst
  (loc0, s2zes) = let
in
//
if glist_is_cons (s2zes) then let
    val s2ze = glist_head<s2zexp> (s2zes)
    val s2zes = glist_tail<s2zexp> (s2zes)
  in
    if s2zexp_is_S2ZEprf (s2ze) then
      s2zexplst_tyer_arglst (loc0, s2zes)
    else (* non-proof *) let
      val hse = s2zexp_tyer (loc0, s2ze)
      val hses = s2zexplst_tyer_arglst (loc0, s2zes)
    in
      glist_cons (hse, hses)
    end // end of [_]
  end (* end of [list_cons] *)
else glist_nil ((*void*))
//
end // end of [s2zexplst_tyer_arglst]

(* ****** ****** *)

implement
s2zexp_tyer_tyrec
  (loc0, s2ze0) = let
//
val-~S2ZEtyrec
  (knd, ls2zes) = s2zexp_view (s2ze0)
//
val lhses = labs2zexplst_tyer (loc0, ls2zes)
//
in
//
if tyreckind_is_TYRECKINDbox (knd) then hisexp_tybox
else if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)
else ( (* TYRECKINDflt0/1 *)
  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))
    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))
    else hisexp_tyrec (knd, lhses) (* non-sing *)
) // end of [TYRECKINDflt0/1]
//
end // end of [s2exp_tyer_tyrec]

(* ****** ****** *)

implement
labs2zexplst_tyer
  (loc0, ls2zes) = let
in
//
if glist_is_cons (ls2zes) then let
    val ls2ze = glist_head<labs2zexp> (ls2zes)
    val ls2zes = glist_tail<labs2zexp> (ls2zes)
    val l = ls2ze.labs2zexp_lab ()
    val s2ze = ls2ze.labs2zexp_elt ()
  in
    if s2zexp_is_S2ZEprf (s2ze) then
        labs2zexplst_tyer (loc0, ls2zes)
    else (* non-proof *) let
        val hse = s2zexp_tyer (loc0, s2ze)
        val lhse = labhisexp_new (l, gopt_none ((*name*)), hse)
        val lhses = labs2zexplst_tyer (loc0, ls2zes)
      in
        glist_cons (lhse, lhses)
      end // end of [_]
  end (* end of [list_cons] *)
else glist_nil ((*void*))
//
end // end of [labs2zexplst_tyer]

(* ****** ****** *)

fun
t2mpmarg_tyer_aux (
  loc0: location, s2es: s2explst
) : hisexplst = let
in
//
if glist_is_cons (s2es) then let
    val s2e = glist_head<s2exp> (s2es)
    val s2es = glist_tail<s2exp> (s2es)
    val hse =
      s2exp_tyer_shallow (loc0, s2e)
    // end of [val]
  in
    glist_cons (hse, t2mpmarg_tyer_aux (loc0, s2es))
  end
else glist_nil ((*void*))
//
end // end of [t2mpmarg_tyer_aux]

implement
t2mpmarg_tyer (t2ma) = let
//
val loc0 = t2ma.t2mpmarg_loc ()
//
in
  t2mpmarg_tyer_aux (loc0, t2ma.t2mpmarg_arg ())
end // end of [t2mpmarg_tyer]

implement
t2mpmarglst_tyer (t2mas) = let
in
//
if glist_is_cons (t2mas) then let
  val t2ma = glist_head<t2mpmarg> (t2mas)
  val h2es = t2mpmarg_tyer (t2ma)
  val h2ess = t2mpmarglst_tyer (glist_tail<t2mpmarg> (t2mas))
in
  glist_cons (h2es, h2ess)
end else glist_nil ((*void*))
//
end // end of [t2mpmarglst_tyer]

(* ****** ****** *)

implement
t2mpmarg_mhnfize
  (t2ma) = let
  val loc = t2ma.t2mpmarg_loc ()
  val s2es = t2ma.t2mpmarg_arg ()
  val s2es = s2explst_mhnfize (s2es)
in
  t2mpmarg_make (loc, s2es)
end // end of [t2mpmarg_mhnfize]

implement
t2mpmarglst_mhnfize
  (t2mas) = let
in
//
if glist_is_cons (t2mas) then let
  val t2ma = glist_head<t2mpmarg> (t2mas)
  val t2ma2 = t2mpmarg_mhnfize (t2ma)
  val t2mas2 = t2mpmarglst_mhnfize (glist_tail<t2mpmarg> (t2mas))
in
  glist_cons (t2ma2, t2mas2)
end else glist_nil ((*void*))
//
end // end of [t2mpmarglst_mhnfize]

(* ****** ****** *)

(* end of [pats_typerase_staexp.dats] *)
