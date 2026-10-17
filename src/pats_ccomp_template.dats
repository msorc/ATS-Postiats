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
// Start Time: November, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_template.dats, see PORTING.md, "ccomp group B")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload
LAB = "./pats_label.sats"
//
overload
= with $LAB.eq_label_label
//
(* ****** ****** *)
//
staload
"./pats_staexp2.sats"
staload
"./pats_dynexp2.sats"
//
staload
"./pats_staexp2_util.sats"
//
(* ****** ****** *)
//
staload
"./pats_trans2_env.sats"
//
(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)
//
// HX-2026-10: tmpvarmap_vt is not used here, but the
// tmpsub/tmpcstmat constructors are generated data of pats_ccomp.sats
//
(* ****** ****** *)
//
datavtype
impenv =
| IMPENVnil of ()
| IMPENVcons of
    (s2var, s2hnf, impenv)
  // (* IMPENVcons *)
// end of [impenv]
//
(* ****** ****** *)
//
extern
fun
print_impenv(env: !impenv): void
extern
fun
fprint_impenv(out: FILEref, env: !impenv): void
//
overload print with print_impenv
overload fprint with fprint_impenv
//
(* ****** ****** *)
//
extern
fun
impenv_find
  (env: !impenv, s2v: s2var): s2hnf
//
extern
fun
impenv_update
  (env: !impenv, s2v: s2var, s2f: s2hnf): bool(*updated*)
// end of [impenv_update]
//
(* ****** ****** *)
//
implement
print_impenv
  (env) =
  fprint_impenv(stdout_ref, env)
//
implement
fprint_impenv
  (out, env) = let
//
fun
loop
(
  out: FILEref, env: !impenv, i: int
) : void = let
in
//
case+ env of
| IMPENVnil
  (
  // argless
  ) => ((*nothing*))
  // end of [IMPENVnil]
| @IMPENVcons
  (
    s2v, s2f, env1
  ) => let
    val () =
    if i > 0 then
      fprint_string (out, "; ")
    // end of [if]
    val () = fprint_s2var (out, s2v)
    val () = fprint_string (out, " -> ")
    val () = fprint_s2hnf (out, s2f)
    val () = loop (out, env1, i+1)
    prval ((*folded*)) = fold@ (env)
  in
    // nothing
  end // end of [IMPENVcons]
//
end // end of [loop]
//
in
  loop (out, env, 0)
end // end of [fprint_impenv]
//
(* ****** ****** *)

implement
impenv_find
  (env, s2v) = let
in
//
case+ env of
| IMPENVnil
  ((*void*)) => let
    val s2t = s2var_get_srt(s2v)
  in
    s2exp2hnf_cast(s2exp_errexp(s2t))
  end // end of [IMPENVnil]
| @IMPENVcons
  (
    s2v1, s2f, env1
  ) => (
    if eq_s2var_s2var (s2v, s2v1) then let
      val s2f = s2f
      prval () = fold@ (env)
    in
      s2f
    end else let
      val s2f =
        impenv_find (env1, s2v)
      // end of [val]
      prval () = fold@ (env)
    in
      s2f
    end // end of [if]
  ) // end of [IMPENVcons]
//
end // end of [impenv_find]

(* ****** ****** *)
//
// HX-2026-10: the ATS1 [aux] was a cloref capturing [s2v] and [s2f]
//
fun
impenv_update_aux
(
  env: !impenv, s2v: s2var, s2f: s2hnf
) : bool =
//
case+ env of
| IMPENVnil
  (
    // argless
  ) => false // end of [IMPENVnil]
| @IMPENVcons
  (
    s2v1, s2f1, env1
  ) => (
    if (
    eq_s2var_s2var (s2v, s2v1)
    ) then let
      val () =
        (s2f1 := s2f)
      // end of [val]
      prval () = fold@ (env)
    in
      true
    end else let
      val ans = impenv_update_aux(env1, s2v, s2f)
      prval () = fold@(env) in ans
    end // end of [if]
  ) (* end of [IMPENVcons] *)
//
implement
impenv_update
  (env, s2v, s2f) = let
//
val
s2e = s2hnf2exp(s2f)
//
val
s2t = s2e.s2exp_srt ()
val
s2v_s2t = s2var_get_srt(s2v)
//
in
//
if
s2rt_ltmat1(s2t, s2v_s2t)
  then impenv_update_aux(env, s2v, s2f) else false
//
end // end of [impenv_update]

(* ****** ****** *)
//
extern
fun
s2hnf_is_err
  (s2f: s2hnf): bool
//
implement
s2hnf_is_err
  (s2f) = let
//
val s2e = s2hnf2exp(s2f)
//
in
//
s2exp_node_is_S2Eerrexp (s2e.s2exp_node ())
//
end // end of [s2hnf_is_err]
//
(* ****** ****** *)
//
extern
fun
impenv_make_nil
  ((*void*)): impenv
//
extern
fun
impenv_make_svarlst
  (s2vs: s2varlst): impenv
//
(* ****** ****** *)
//
implement
impenv_make_nil
  () = IMPENVnil()
//
implement
impenv_make_svarlst
  (s2vs) = let
in
//
if glist_is_cons (s2vs) then let
    val s2v = glist_head<s2var> (s2vs)
    val s2vs = glist_tail<s2var> (s2vs)
    val s2t =
      s2var_get_srt (s2v)
    // end of [val]
    val s2e = s2exp_errexp(s2t)
    val s2f = s2exp2hnf_cast(s2e)
    val env = impenv_make_svarlst(s2vs)
  in
    IMPENVcons(s2v, s2f, env)
  end // end of [list_cons]
else IMPENVnil()
//
end // end of [impenv_make_svarlst]
//
(* ****** ****** *)
//
extern
fun
impenv_free
  (env: impenv): void
//
implement
impenv_free(env) = let
//
in
//
case+ env of
| ~IMPENVnil() => ()
| ~IMPENVcons(_, _, env) => impenv_free(env)
//
end // end of [impenv_free]
//
(* ****** ****** *)
//
extern
fun
impenv2tmpsub
  (env: impenv): tmpsub
//
implement
impenv2tmpsub
  (env) = let
//
fun aux (
  env: impenv, tsub: tmpsub
) : tmpsub = let
in
//
case+ env of
| ~IMPENVnil
    ((*void*)) => tsub
| ~IMPENVcons
    (s2v, s2f, env) => let
    val s2e = s2hnf2exp (s2f)
    val tsub2 = aux (env, tsub)
  in
    tmpsub_TMPSUBcons(s2v, s2e, tsub2)
  end // end of [IMPENVcons]
//
end // end of [aux]
//
in
  aux (env, tmpsub_TMPSUBnil((*void*)))
end // end of [impenv2tmpsub]
//
(* ****** ****** *)

local

(* ****** ****** *)

fun
auxenv
(
  env: !s2varlst_vt, s2vs: s2varlst
) : s2varlst_vt = let
//
fun
loop
(
  s2vs: s2varlst, res: s2varlst_vt
) : s2varlst_vt =
  if glist_is_cons (s2vs) then let
    val s2v = glist_head<s2var> (s2vs)
    val s2vs = glist_tail<s2var> (s2vs)
  in
    loop (s2vs, list_vt_cons (s2v, res))
  end else res
//
val
env2 = list_vt_copy<s2var>(env)
//
in
  loop (s2vs, env2) // HX: list_reverse_append2_vt
end // end of [auxenv]

(* ****** ****** *)

fun
auxfvar
(
  env: !s2varlst_vt, s2v0: s2var
) : bool =
(
case+ env of
| list_vt_nil
    ((*void*)) =>
  true (* list_vt_nil *)
| @list_vt_cons
  (
    s2v, env1
  ) =>  (
    if eq_s2var_s2var (s2v, s2v0)
      then
      (
      fold@env;false
      )
      else ans where
      {
        val ans =
          auxfvar(env1, s2v0)
        // end of [val]
        prval ((*void*)) = fold@env
      } (* end of [else] *)
  ) (* end of [list_vt_cons] *)
) (* end of [auxfvar] *)

(* ****** ****** *)

fun
auxmat
(
  env: !impenv
, s2e0_pat: s2exp, s2e0_arg: s2exp
) : bool = ismatch where
{
//
val env_pat = list_vt_nil{s2var}()
and env_arg = list_vt_nil{s2var}()
//
val
ismatch =
auxmat_env
(
  env
, env_pat, env_arg
, s2e0_pat, s2e0_arg
) (* end of [val] *)
//
val ((*void*)) = list_vt_free<s2var>(env_pat)
val ((*void*)) = list_vt_free<s2var>(env_arg)
//
} (* end of [auxmat] *)

and
auxmatlst
(
  env: !impenv
, s2es_pat: s2explst, s2es_arg: s2explst
) : bool = ismatch where
{
//
val env_pat = list_vt_nil{s2var}()
and env_arg = list_vt_nil{s2var}()
//
val
ismatch =
auxmatlst_env
(
  env
, env_pat, env_arg
, s2es_pat, s2es_arg
) (* end of [val] *)
//
val ((*void*)) = list_vt_free<s2var>(env_pat)
val ((*void*)) = list_vt_free<s2var>(env_arg)
//
} (* end of [auxmatlst] *)

(* ****** ****** *)

and
auxmat_env
{m,n:nat}
(
  env: !impenv
, env_pat: !list_vt(s2var, m)
, env_arg: !list_vt(s2var, n)
, s2e0_pat: s2exp, s2e0_arg: s2exp
) : bool = let
//
val s2f0_pat = s2exp2hnf(s2e0_pat)
val s2f0_arg = s2exp2hnf(s2e0_arg)
val s2e0_pat = s2hnf2exp(s2f0_pat)
val s2e0_arg = s2hnf2exp(s2f0_arg)
val s2en_pat = s2e0_pat.s2exp_node ()
val s2en_arg = s2e0_arg.s2exp_node ()
//
in
//
case+
s2exp_node_view (s2en_pat) of
//
| ~S2Evar(s2v) => let
    val ans =
      auxfvar(env_pat, s2v)
    // end of [val]
  in
    case+ ans of
    | true => let
        val s2f =
          impenv_find(env, s2v)
        // end of [val]
        val iserr = s2hnf_is_err(s2f)
      in
        if
        iserr
        then let
        val
        upret =
        impenv_update
          (env, s2v, s2f0_arg)
        // end of [val]
        in
          if
          upret
          then true
          else let
(*
            // HX-2017-10-29:
            // [s2v] is not template
*)
            val
            s2f = s2f0_pat
          in
            s2hnf_syneq2(s2f, s2f0_arg)
          end // end of [if]
        end (* end of [then] *)
        // HX-2017-10-29: already in use
        else s2hnf_syneq2(s2f, s2f0_arg)
      end (* [true] *)
    | false =>
      s2hnf_syneq_env
        (env_pat, env_arg, s2f0_pat, s2f0_arg)
      // s2hnf_syneq_env
      (* end of [false] *)
  end // end of [S2Evar]
//
| ~S2Ecst(s2c) => let
  in
    if s2exp_node_is_S2Ecst (s2en_arg) then let
      val-~S2Ecst(s2c_arg) = s2exp_node_view (s2en_arg)
    in
      if eq_s2cst_s2cst (s2c, s2c_arg) then true else false
    end else false // non-S2Ecst
  end // end of [S2Ecst]
//
| ~S2Eapp
  (
    s2e_pat, s2es_pat
  ) => let
  in
    if s2exp_node_is_S2Eapp (s2en_arg) then let
        val-~S2Eapp
        (
          s2e_arg, s2es_arg
        ) = s2exp_node_view (s2en_arg)
        val
        ismatch =
        auxmat_env
          (env, env_pat, env_arg, s2e_pat, s2e_arg)
        // end of [val]
      in
        if ismatch
          then
          auxmatlst_env
            (env, env_pat, env_arg, s2es_pat, s2es_arg)
          // end of [then]
          else false
        // end of [if]
      end // end of [S2Eapp]
    else false // non-S2Eapp
  end // end of [S2Eapp]
//
| ~S2Etyrec
  (
    knd, npf, ls2es_pat
  ) => let
  in
    if s2exp_node_is_S2Etyrec (s2en_arg) then let
        val-~S2Etyrec
        (
          knd2, npf2, ls2es_arg
        ) = s2exp_node_view (s2en_arg)
      in (
        if knd = knd2
          then
          auxlabmatlst_env
            (env, env_pat, env_arg, ls2es_pat, ls2es_arg)
          // end of [then]
          else false
        // end of [if]
      ) end // end of [S2Etyrec]
    else false // non-S2Etyrec
  end // end of [S2Etyrec]
//
| ~S2Eexi
  (
    s2vs_pat, s2ps_pat, s2e_pat
  ) => let
  in
    if s2exp_node_is_S2Eexi (s2en_arg) then let
        val-~S2Eexi
        (
          s2vs_arg, s2ps_arg, s2e_arg
        ) = s2exp_node_view (s2en_arg)
        val
        env_pat = auxenv(env_pat, s2vs_pat)
        val
        env_arg = auxenv(env_arg, s2vs_arg)
        val
        syneq =
        s2explst_syneq_env
        (
          env_pat, env_arg, s2ps_pat, s2ps_arg
        ) (* end of [val] *)
        val
        ismatch =
        (
          if syneq
            then
            auxmat_env
              (env, env_pat, env_arg, s2e_pat, s2e_arg)
            // end of [then]
            else false
        ) : bool // end of [val]
        val () = list_vt_free<s2var>(env_pat)
        and () = list_vt_free<s2var>(env_arg)
      in
        ismatch
      end (* [S2Eexi] *)
    else false // non-S2Eexi
  end // end of [S2Eexi]
//
| v (* rest-of-s2exp *) => let
    val () = s2exp_node_view_free (v)
  in
    if
    s2hnf_syneq_env
      (env_pat, env_arg, s2f0_pat, s2f0_arg) then true
    else false
  end // end of [rest-of-s2exp]
//
end // end of [auxmat_env]

and
auxmatlst_env
{m,n:nat}
(
  env: !impenv
, env_pat: !list_vt(s2var, m)
, env_arg: !list_vt(s2var, n)
, s2es_pat: s2explst, s2es_arg: s2explst
) : bool = let
//
in
//
if glist_is_cons (s2es_pat) then let
    val s2e_pat = glist_head<s2exp> (s2es_pat)
    val s2es_pat = glist_tail<s2exp> (s2es_pat)
  in (
    if glist_is_cons (s2es_arg) then let
         val s2e_arg = glist_head<s2exp> (s2es_arg)
         val s2es_arg = glist_tail<s2exp> (s2es_arg)
         val ismatch =
           auxmat_env (env, env_pat, env_arg, s2e_pat, s2e_arg)
       in
         if ismatch
           then (
             auxmatlst_env (env, env_pat, env_arg, s2es_pat, s2es_arg)
           ) else false
       end // end of [list_cons]
     else true // HX: deadcode
  ) end // end of [list_cons]
else true // list_nil
//
end // end of [auxmatlst]

and
auxlabmatlst_env
{m,n:nat}
(
  env: !impenv
, env_pat: !list_vt(s2var, m), env_arg: !list_vt(s2var, n)
, ls2es_pat: labs2explst, ls2es_arg: labs2explst
) : bool = let
in
//
if glist_is_cons (ls2es_pat) then (
  if glist_is_cons (ls2es_arg) then let
      val lx1 = glist_head<labs2exp> (ls2es_pat)
      val ls2es_pat = glist_tail<labs2exp> (ls2es_pat)
      val lx2 = glist_head<labs2exp> (ls2es_arg)
      val ls2es_arg = glist_tail<labs2exp> (ls2es_arg)
      val l1 = lx1.labs2exp_lab ()
      val x1 = lx1.labs2exp_elt ()
      val l2 = lx2.labs2exp_lab ()
      val x2 = lx2.labs2exp_elt ()
      val
      ismatch =
      (
        if l1 = l2
          then (
            auxmat_env (env, env_pat, env_arg, x1, x2)
          ) else false
      ) : bool // end of [val]
    in
      if ismatch
        then
        auxlabmatlst_env
          (env, env_pat, env_arg, ls2es_pat, ls2es_arg)
        // end of [then]
        else false
    end // end of [list_cons]
  else false
) else (
  if glist_is_cons (ls2es_arg) then false else true
) (* end of [list_nil] *)
//
end // end of [auxlabmatlst_env]

(* ****** ****** *)

fun
auxmatlstlst
(
  env: !impenv
, s2ess: s2explstlst, t2mas: t2mpmarglst
) : bool = let
in
//
if glist_is_cons (s2ess) then let
    val s2es = glist_head<s2explst> (s2ess)
    val s2ess = glist_tail<s2explst> (s2ess)
  in (
    if glist_is_cons (t2mas) then let
        val t2ma = glist_head<t2mpmarg> (t2mas)
        val t2mas = glist_tail<t2mpmarg> (t2mas)
        val ans =
          auxmatlst (env, s2es, t2ma.t2mpmarg_arg ())
        // end of [val]
      in
        if ans then auxmatlstlst (env, s2ess, t2mas) else false
      end // end of [list_cons]
    else true // HX: deadcode
  ) end // end of [list_cons]
else true // list_nil
//
end // end of [auxmatlstlst]

(* ****** ****** *)

fun
auxbndlstlst
(
  s2vs: s2varlst, t2mas: t2mpmarglst
) : tmpsub = let
in
//
if glist_is_cons (t2mas) then let
  val t2ma = glist_head<t2mpmarg> (t2mas)
  val t2mas = glist_tail<t2mpmarg> (t2mas)
in
  auxbndlstlst2 (s2vs, t2ma.t2mpmarg_arg (), t2mas)
end else tmpsub_TMPSUBnil ()
//
end // end of [auxbndlstlst]

and
auxbndlstlst2
(
  s2vs: s2varlst, s2es: s2explst, t2mas: t2mpmarglst
) : tmpsub = let
in
//
if glist_is_cons (s2es) then let
    val s2e = glist_head<s2exp> (s2es)
    val s2es = glist_tail<s2exp> (s2es)
    val s2e = s2exp_hnfize (s2e)
    val s2v = glist_head<s2var> (s2vs) // HX: val-list_cons
    val s2vs = glist_tail<s2var> (s2vs)
    val tsub = auxbndlstlst2 (s2vs, s2es, t2mas)
  in
    tmpsub_TMPSUBcons (s2v, s2e, tsub)
  end // end of [list_cons]
else auxbndlstlst (s2vs, t2mas)
//
end // end of [auxbndlstlst2]

in (* in of [local] *)

(* ****** ****** *)

implement
funlab_tmparg_match
  (fl0, t2mas) = let
//
fun
loop
(
  xs: t2mpmarglst, res: s2explstlst
) : s2explstlst =
  if glist_is_cons (xs) then let
    val x = glist_head<t2mpmarg> (xs)
    val xs = glist_tail<t2mpmarg> (xs)
  in
    loop (xs, glist_cons<s2explst> (x.t2mpmarg_arg (), res))
  end else glist_reverse<s2explst> (res)
//
val env = impenv_make_nil ()
val xs0 = funlab_get_tmparg (fl0)
val s2ess = loop (xs0, glist_nil ()) // HX: list_map_fun
val ans = auxmatlstlst (env, s2ess, t2mas)
val ((*env*)) = impenv_free (env)
//
in
  ans
end // end of [funlab_tmparg_match]

(* ****** ****** *)

implement
hiimpdec_tmpcst_match
  (imp, d2c0, t2mas, knd) = let
//
val d2c1 = imp.hiimpdec_cst ()
//
in
//
if
d2c0=d2c1
then let
//
val env =
impenv_make_svarlst(imp.hiimpdec_imparg ())
val ans =
auxmatlstlst(env, imp.hiimpdec_tmparg (), t2mas)
//
in
//
if
(ans)
then let
  val tsub =
    impenv2tmpsub (env)
  // end of [val]
in
  tmpcstmat_TMPCSTMATsome(imp, tsub, knd)
end // end of [then]
else let
  val () = impenv_free(env) in tmpcstmat_TMPCSTMATnone()
end // end of [else]
//
end // end of [then]
else tmpcstmat_TMPCSTMATnone() // else
// end of [if]
//
end // end of [hiimpdec_tmpcst_match]

(* ****** ****** *)

implement
hiimpdec2_tmpcst_match
  (imp2, d2c0, t2mas, knd) = let
//
val imp = imp2.hiimpdec2_imp ()
val tsub0 = imp2.hiimpdec2_sub ()
val tmparg = imp2.hiimpdec2_arg ()
val d2c1 = imp.hiimpdec_cst ()
val imparg = imp.hiimpdec_imparg ()
//
in
//
if
d2c0=d2c1
then let
  val env =
    impenv_make_svarlst (imparg)
  // end of [val]
  val ans =
    auxmatlstlst (env, tmparg, t2mas)
  // end of [val]
in
//
if
(ans)
then let
  val tsub1 =
    impenv2tmpsub(env)
  val tsub01 =
    tmpsub_append(tsub0, tsub1)
  // end of [val]
in
  tmpcstmat_TMPCSTMATsome(imp, tsub01, knd)
end // end of [then]
else let
  val () = impenv_free(env) in tmpcstmat_TMPCSTMATnone()
end // end of [else]
//
end // end of [then]
else tmpcstmat_TMPCSTMATnone() // else
//
end // end of [hiimpdec2_tmpcst_match]

(* ****** ****** *)

implement
hiimpdeclst_tmpcst_match
  (imps, d2c0, t2mas, knd) = let
//
in
//
if glist_is_nil (imps) then tmpcstmat_TMPCSTMATnone()
else let
    val imp = glist_head<hiimpdec> (imps)
    val imps = glist_tail<hiimpdec> (imps)
    val opt =
      hiimpdec_tmpcst_match(imp, d2c0, t2mas, knd)
    // end of [val]
  in
    if tmpcstmat_is_TMPCSTMATnone (opt)
      then hiimpdeclst_tmpcst_match(imps, d2c0, t2mas, knd)
      else opt // TMPCSTMATsome, TMPCSTMATsome2
  end // end of [list_cons]
//
end // end of [hiimpdeclst_tmpcst_match]

(* ****** ****** *)

implement
tmpcstmat_tmpcst_match
  (mat, d2c0, t2mas) = let
//
var ans: bool = false
//
val-~TMPCSTMATsome2(d2c, s2ess, flab) = tmpcstmat_view (mat)
//
val () =
(
if
d2c=d2c0
then let
val
env = IMPENVnil()
//
val () =
ans :=
auxmatlstlst(env, s2ess, t2mas)
//
val ((*freed*)) = impenv_free(env)
//
in
  // nothing
end // end of [then]
else () // end of [else]
//
) : void // end of [val]
//
in
//
if ans then mat else tmpcstmat_TMPCSTMATnone()
//
end // end of [tmpcstmat_tmpcst_match]

(* ****** ****** *)

implement
hifundec2tmpvarmat
  (hfd, t2mas) = let
//
val s2vs = hfd.hifundec_imparg ()
val tsub = auxbndlstlst (s2vs, t2mas)
//
in
  tmpvarmat_TMPVARMATsome (hfd, tsub, 0(*local*))
end // end of [hifundec2tmpvarmat]

implement
hifundecopt2tmpvarmat
  (hfdopt, t2mas) = let
in
//
case hfdopt of
| ~None_vt() => tmpvarmat_TMPVARMATnone()
| ~Some_vt(hfd) => hifundec2tmpvarmat(hfd, t2mas)
//
end // end of [hifundecopt2tmpvarmat]

(* ****** ****** *)

implement
hifundec_tmpvar_match
  (hfd, d2v0, t2mas) = let
//
val d2v = hfd.hifundec_var ()
//
in
//
if d2v=d2v0
  then hifundec2tmpvarmat(hfd, t2mas) else tmpvarmat_TMPVARMATnone()
//
end // end of [hifundec_tmpvar_match]

(* ****** ****** *)

implement
hifundec2_tmpvar_match
  (hfd2, d2v0, t2mas) = let
//
val hfd = hfd2.hifundec2_hfd ()
val tsub0 = hfd2.hifundec2_sub ()
//
val d2v = hfd.hifundec_var ()
//
in
//
if
d2v=d2v0
then let
//
val s2vs = hfd.hifundec_imparg ()
val tsub1 = auxbndlstlst(s2vs, t2mas)
val tsub01 = tmpsub_append(tsub0, tsub1)
//
in
  tmpvarmat_TMPVARMATsome(hfd, tsub01, 0(*local*))
end // end of [then]
else tmpvarmat_TMPVARMATnone() // end of [else]
//
end // end of [hifundec2_tmpvar_match]

(* ****** ****** *)

implement
tmpvarmat_tmpvar_match
  (mat, d2v0, t2mas) = let
//
var ans: bool = false
//
val-~TMPVARMATsome2(d2v, s2ess, flab) = tmpvarmat_view (mat)
//
val () = (
//
if
d2v=d2v0
then let
val
env = IMPENVnil()
//
val () =
ans :=
auxmatlstlst(env, s2ess, t2mas)
//
val ((*freed*)) = impenv_free(env)
//
in
  // nothing
end // end of [if]
//
) (* end of [val] *)
//
in
//
if ans then mat else tmpvarmat_TMPVARMATnone()
//
end // end of [tmpvarmat_tmpvar_match]

end // end of [local]

(* ****** ****** *)
//
extern
fun
ccomp_funlab_tmpsubst
(
  env: !ccompenv
, loc0: loc_t, hse0: hisexp, fl: funlab, tsub: tmpsub
) : primval // end of [ccomp_funlab_tmpsubst]
//
extern
fun
ccomp_funlab_tmpsubst_none
(
  env: !ccompenv
, loc0: loc_t, hse0: hisexp, fl: funlab, tsub: tmpsub
) : primval // end of [ccomp_funlab_tmpsubst_none]
//
extern
fun
ccomp_funlab_tmpsubst_some
(
  env: !ccompenv
, loc0: loc_t, hse0: hisexp, fl: funlab, tsub: tmpsub, fent: funent
) : primval // end of [ccomp_funlab_tmpsubst_some]
//
(* ****** ****** *)

implement
ccomp_funlab_tmpsubst
  (env, loc0, hse0, flab, tsub) = let
//
val opt = funlab_get_funent(flab)
//
in
//
if gopt_is_none (opt) then
    ccomp_funlab_tmpsubst_none(env, loc0, hse0, flab, tsub)
  // end of [None]
else let
  val fent = gopt_unsome<funent> (opt)
in
    ccomp_funlab_tmpsubst_some(env, loc0, hse0, flab, tsub, fent)
end // end of [Some]
//
end // end of [ccomp_funlab_tmpsubst]

(* ****** ****** *)

implement
ccomp_funlab_tmpsubst_none
  (env, loc0, hse0, flab, tsub) = let
//
val t2mas = funlab_get_tmparg (flab)
//
in
//
if glist_is_nil (t2mas) then
    primval_make2_funlab (loc0, hse0, flab)
  // end of [list_nil]
else let
    val d2c = gopt_unsome<d2cst> (funlab_get_d2copt(flab))
    val t2mas = t2mpmarglst_tsubst(loc0, tsub, t2mas)
    val tmpmat = ccompenv_tmpcst_match(env, d2c, t2mas)
  in
    ccomp_tmpcstmat(env, loc0, hse0, d2c, t2mas, tmpmat)
  end (* end of [list_cons] *)
//
end // end of [ccomp_funlab_tmpsubst_none]

(* ****** ****** *)

implement
ccomp_funlab_tmpsubst_some
  (env, loc0, hse0, flab, tsub, fent) = let
//
val
sub = tmpsub2stasub(tsub)
val
sfx = funlab_incget_ncopy(flab)
//
val
flab2 = funlab_subst (sub, flab)
//
val () = funlab_set_suffix (flab2, sfx)
val () = the_funlablst_add (flab2)
//
val () = ccompenv_add_flabsetenv (env, flab2)
//
val (pfpush|()) = ccompenv_push (env)
//
val () = ccompenv_add_tmpsub (env, tsub)
val () = ccompenv_inc_tmprecdepth (env)
//
val
fent2 = funent_subst(env, sub, flab2, fent, sfx)
//
val () = ccompenv_dec_tmprecdepth (env)
//
val ((*popped*)) = ccompenv_pop (pfpush | env)
//
val () = funent_set_tmpsub (fent2, gopt_some<tmpsub> (tsub))
//
val () = funlab_set_funent (flab2, gopt_some<funent> (fent2))
//
val () = stasub_free (sub)
//
in
  primval_make2_funlab (loc0, hse0, flab2)
end // end of [ccomp_funlab_tmpsubst_some]

(* ****** ****** *)

extern
fun
ccomp_tmpcstmat_some
(
  env: !ccompenv, loc0: loc_t
, hse0: hisexp, d2c: d2cst, t2mas: t2mpmarglst, mat: tmpcstmat
) : primval // end of [ccomp_tmpcstmat_some]

(* ****** ****** *)

implement
ccomp_tmpcstmat
  (env, loc0, hse0, d2c, t2mas, mat) = let
//
in
//
case+ tmpcstmat_view (mat) of
| ~TMPCSTMATsome (_, _, _) =>
  ccomp_tmpcstmat_some
    (env, loc0, hse0, d2c, t2mas, mat)
  // end of [TMPCSTMATsome]
| ~TMPCSTMATsome2
    (d2c, s2ess, flab) =>
    primval_make2_funlab(loc0, hse0, flab)
| ~TMPCSTMATnone() =>
    primval_tmpltcstmat(loc0, hse0, d2c, t2mas, mat)
  // end of [TMPCSTMATnone]
//
end // end of [ccomp_tmpcstmat]

implement
ccomp_tmpcstmat_some
  (env, loc0, hse0, d2c, t2mas, mat) = let
//
val-~TMPCSTMATsome
(imp, tsub, knd) = tmpcstmat_view (mat)
//
val
lvl0 = the_d2varlev_save()
//
val () =
hiimpdec_ccomp_if
  (env, 0(*level*), imp, knd)
//
val () = the_d2varlev_restore(lvl0)
//
val flab = gopt_unsome<funlab> (hiimpdec_get_funlabopt(imp))
//
in
  ccomp_funlab_tmpsubst(env, loc0, hse0, flab, tsub)
end // end of [ccomp_tmpcstmat_some]

(* ****** ****** *)

extern
fun
ccomp_tmpvarmat_some
(
  env: !ccompenv
, loc0: loc_t
, hse0: hisexp, d2v: d2var, t2mas: t2mpmarglst, mat: tmpvarmat
) : primval // end of [ccomp_tmpvarmat_some]

(* ****** ****** *)

implement
ccomp_tmpvarmat
  (env, loc0, hse0, d2v, t2mas, mat) = let
//
in
//
case+ tmpvarmat_view (mat) of
| ~TMPVARMATsome (_, _, _) =>
  (
    ccomp_tmpvarmat_some
      (env, loc0, hse0, d2v, t2mas, mat)
    // end of [ccomp_tmpvarmat_some]
  ) // end of [TMPVARMATsome]
| ~TMPVARMATsome2
    (d2c, s2ess, flab) =>
    primval_make2_funlab (loc0, hse0, flab)
  // end of [TMPVARMATsome2]
| ~TMPVARMATnone() =>
    primval_tmpltvarmat (loc0, hse0, d2v, t2mas, mat)
  // end of [TMPVARMATnone]
//
end // end of [ccomp_tmpvarmat]

implement
ccomp_tmpvarmat_some
  (env, loc0, hse0, d2v, t2mas, mat) = let
//
val-~TMPVARMATsome
(hfd, tsub, _(*knd*)) = tmpvarmat_view (mat)
//
val opt =
  hifundec_get_funlabopt(hfd)
//
val ((*void*)) = (
//
if gopt_is_none (opt) then let
    val hdc0 =
      gopt_unsome<hidecl> (hifundec_get_hideclopt(hfd))
    // end of [val]
    val-~HIDfundecs
      (knd, decarg, hfds) = hidecl_node_view (hdc0.hidecl_node ())
    // end of [val]
  in
    hifundeclst_ccomp(env, 0(*lvl0*), knd, decarg, hfds)
  end // end of [None]
else ((*void*))
//
) (* end of [val] *)
//
val flab = gopt_unsome<funlab> (hifundec_get_funlabopt(hfd))
//
in
  ccomp_funlab_tmpsubst(env, loc0, hse0, flab, tsub)
end // end of [ccomp_tmpvarmat_some]

(* ****** ****** *)

(* end of [pats_ccomp_template.dats] *)
