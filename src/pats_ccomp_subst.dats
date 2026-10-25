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
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_subst.dats, see PORTING.md, "ccomp group B")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
  ((*void*)) = prerr "pats_ccomp_subst"
//
(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload GLOB = "./pats_global.sats"

(* ****** ****** *)

staload STMP = "./pats_stamp.sats"

(* ****** ****** *)

staload LOC = "./pats_location.sats"
overload print with $LOC.print_location

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)
//
// HX-2026-10: the templates of the avl maps (d2varmap, tmpvarmap_vt)
//
staload _(*anon*) = "./pats_dynexp2_dvar.dats"
staload _(*anon*) = "./pats_ccomp_tmpvar.dats"
#include "./mylibies.hats" // the libats templates that tmpvarmap_vt_* instantiate
//
// HX-2026-10: the comparison of the keys of a tmpvarmap_vt is implemented by pats_ccomp_tmpvar.dats inside a [local]:
// the instances of the avl templates made here need it too (see PORTING.md, "ccomp group B")
//
staload LM = "libats/SATS/linmap_avltree.sats"
implement $LM.compare_key_key<tmpvar> (tmp1, tmp2) = compare_tmpvar_tmpvar (tmp1, tmp2)
//
(* ****** ****** *)

local

fun auxlst
(
  loc0: location
, sub: !stasub, xs: t2mpmarglst
) : t2mpmarglst = let
in
//
if glist_is_cons (xs) then let
//
    val x = glist_head<t2mpmarg> (xs)
    val xs = glist_tail<t2mpmarg> (xs)
//
    val s2es = x.t2mpmarg_arg ()
    val s2es2 = s2explst_subst (sub, s2es)
//
    val x2 = t2mpmarg_make (loc0, s2es2)
//
    val xs2 = auxlst (loc0, sub, xs)
//
  in
    glist_cons<t2mpmarg> (x2, xs2)
  end // end of [list_cons]
else glist_nil ()
//
end // end of [auxlst]

in (* in of [local] *)

implement
t2mpmarglst_subst
  (loc0, sub, t2mas) = let
//
in
  auxlst (loc0, sub, t2mas)
end // end of [t2mpmarglst_subst]

end // end of [local]

(* ****** ****** *)

implement
t2mpmarglst_tsubst
  (loc0, tsub, t2mas) = let
//
val sub = tmpsub2stasub (tsub)
val t2mas2 = t2mpmarglst_subst (loc0, sub, t2mas)
val () = stasub_free (sub)
in
  t2mas2
end // end of [t2mpmarglst_tsubst]

(* ****** ****** *)
//
extern
fun
tmpvar_subst
  (sub: !stasub, tmp: tmpvar, sfx: int): tmpvar
extern
fun
tmpvarlst_subst
  (sub: !stasub, tmplst: tmpvarlst, sfx: int): tmpvarlst
//
(* ****** ****** *)

implement
tmpvar_subst
  (sub, tmp, sfx) = let
  val loc = tmpvar_get_loc (tmp)
  val hse = tmpvar_get_type (tmp)
  val hse = hisexp_subst (sub, hse)
  val tmp2 = tmpvar_make (loc, hse)
  val () =
    if tmpvar_isref(tmp) then tmpvar_set_ref (tmp2, 1)
  // end of [val]
  val () =
    if tmpvar_isret(tmp) then tmpvar_set_ret (tmp2, 1)
  // end of [val]
  val () =
    tmpvar_set_origin (tmp2, gopt_some<tmpvar>(tmp))
  // end of [val]
  val () = tmpvar_set_suffix (tmp2, sfx)
in
  tmp2
end // end of [tmpvar_subst]

(* ****** ****** *)

implement
tmpvarlst_subst
  (sub, tmplst, sfx) = let
//
fun loop
(
  sub: !stasub
, xs: tmpvarlst, sfx: int, ys: tmpvarlst
) : tmpvarlst = let
//
in
//
if glist_is_cons (xs) then let
    val x = glist_head<tmpvar> (xs)
    val xs = glist_tail<tmpvar> (xs)
    val y = tmpvar_subst (sub, x, sfx)
  in
    loop (sub, xs, sfx, glist_cons<tmpvar> (y, ys))
  end // end of [list_cons]
else ys
//
end // end of [loop]
//
val tmplst2 =
  loop (sub, tmplst, sfx, glist_nil ())
//
in
  glist_reverse<tmpvar> (tmplst2)
end // end of [tmpvarlst_subst]

(* ****** ****** *)

vtypedef tmpmap = tmpvarmap_vt (tmpvar)

(* ****** ****** *)
//
extern
fun
primval_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pmv: primval, sfx: int
) : primval // end of [primval_subst]
extern
fun
primvalist_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pmvs: primvalist, sfx: int
) : primvalist // end of [primvalist_subst]
//
extern
fun
primlab_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pml: primlab, sfx: int
) : primlab // end of [primlab_subst]
extern
fun
primlablst_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pmls: primlablst, sfx: int
) : primlablst // end of [primlablst_subst]
//
extern
fun
labprimval_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, lpmv: labprimval, sfx: int
) : labprimval // end of [labprimval_subst]
extern
fun
labprimvalist_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, lpmvs: labprimvalist, sfx: int
) : labprimvalist // end of [labprimvalist_subst]
//
extern
fun
tmprimval_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, tpmv: tmprimval, sfx: int
) : tmprimval // end of [tmprimval_subst]
extern
fun
tmpmovlst_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, tmvlst: tmpmovlst, sfx: int
) : tmpmovlst // end of [tmpmovlst_subst]
//
extern
fun
patckont_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, kont: patckont, sfx: int
) : patckont // end of [patckont_subst]
//
extern
fun
primdec_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pmd: primdec, sfx: int
) : primdec // end of [primdec_subst]
extern
fun
primdeclst_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, pmds: primdeclst, sfx: int
) : primdeclst // end of [primdeclst_subst]
//
extern
fun
vbindmap_subst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, vbmap: vbindmap, sfx: int
) : vbindmap // end of [vbindmap_subst]
//
(* ****** ****** *)
//
extern
fun
instr_subst
(
  env: !ccompenv, map: !tmpmap, sub: !stasub, ins: instr, sfx: int
) : instr // end of [instr_subst]
extern
fun
instrlst_subst
(
  env: !ccompenv, map: !tmpmap, sub: !stasub, inss: instrlst, sfx: int
) : instrlst // end of [instrlst_subst]
//
extern
fun
ibranchlst_subst
(
  env: !ccompenv, map: !tmpmap, sub: !stasub, ibrs: ibranchlst, sfx: int
) : ibranchlst // end of [ibranchlst_subst]
//
(* ****** ****** *)
//
extern
fun
primval_lamfix_subst
  (env: !ccompenv, sub: !stasub, pmv: primval): primval
// end of [primval_lamfix_subst]
//
(* ****** ****** *)

extern
fun
ccompenv_add_fundecsloc_subst
( env: !ccompenv
, sub: !stasub, knd: funkind, decarg: s2qualst, hfds: hifundeclst
) : void // end of [ccompenv_add_fundecsloc_subst]

(* ****** ****** *)

implement
d2envlst_subst
  (sub, d2es) = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val d2v = d2env_get_var (d2e)
    val hse = d2env_get_type (d2e)
    val hse2 = hisexp_subst (sub, hse)
    val d2e2 = d2env_make (d2v, hse2)
    val d2es2 = d2envlst_subst (sub, d2es)
  in
    list_vt_cons (d2e2, d2es2)
  end // end of [list_cons]
else list_vt_nil ()
//
end // end of [d2envlst_subst]

(* ****** ****** *)

implement
funlab_subst
  (sub, flab) = flab2 where
{
//
val name = funlab_get_name (flab)
val flvl2 = the_d2varlev_get ()
val hse = funlab_get_type (flab)
val hse2 = hisexp_subst (sub, hse)
val fc = funlab_get_funclo (flab)
val qopt = funlab_get_d2copt (flab)
val sopt = funlab_get_d2vopt (flab)
val t2mas = funlab_get_tmparg (flab)
val stamp = $STMP.funlab_stamp_make ()
//
val flab2 =
funlab_make
(
  name, flvl2, hse2, Some_vt(fc), qopt, sopt, t2mas, stamp
) (* end of [val] *)
//
val () = funlab_set_origin (flab2, gopt_some<funlab> (flab))
//
} // end of [funlab_subst]

(* ****** ****** *)

extern
fun tmpmap_make
  (xs: tmpvarlst): tmpmap
implement
tmpmap_make (xs) = let
//
fun loop (
  xs: tmpvarlst, res: &tmpmap
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<tmpvar> (xs)
    val xs = glist_tail<tmpvar> (xs)
    val xp = gopt_unsome<tmpvar> (tmpvar_get_origin (x))
    val _(*replaced*) = tmpvarmap_vt_insert<tmpvar> (res, xp, x)
  in
    loop (xs, res)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
var res
  : tmpmap = tmpvarmap_vt_nil<tmpvar> ()
val () = loop (xs, res)
//
in
  res
end // end of [tmpmap_make]

(* ****** ****** *)

extern
fun
tmpvar2var
  (map: !tmpmap, tmp: tmpvar): tmpvar
implement
tmpvar2var (map, tmp) = let
  val opt = tmpvarmap_vt_search<tmpvar> (map, tmp)
in
//
case+ opt of
| ~Some_vt
    (tmp2) => tmp2
  // Some_vt
| ~None_vt () => let
//
    val
    loc = tmpvar_get_loc (tmp)
//
    val () =
    prerr_warnccomp_loc (loc)
    val () =
    prerrln! (": referencing toplevel code in a template may be problematic.")
//
  in
    tmpvar_copy_err (tmp)
  end // end of [None_vt]
//
end // end of [tmpvar2var]

(* ****** ****** *)
//
extern
fun
funent_funlablst_update
(
  env: !ccompenv, fls: funlablst
) : funlablst_vt // end-of-fun
//
implement
funent_funlablst_update
  (env, fls) = let
//
fun aux
(
  env: !ccompenv, fl: funlab
) : funlab = let
//
val d2vopt = funlab_get_d2vopt (fl)
//
in
//
if gopt_is_some (d2vopt) then let
    val d2v = gopt_unsome<d2var> (d2vopt)
    val pmvopt =
      ccompenv_find_vbindmapall(env, d2v)
    // end of [val]
  in
    case+
    pmvopt of
    | ~Some_vt(pmv) => let
        val pnd = pmv.primval_node ()
      in
        if primval_node_is_PMVfunlab (pnd) then let
          val-~PMVfunlab(fl2) = primval_node_view (pnd) in fl2
        end else if primval_node_is_PMVcfunlab (pnd) then let
          val-~PMVcfunlab(knd, fl2) = primval_node_view (pnd) in fl2
        end else fl
      end (* end of [Some_vt] *)
    | ~None_vt((*void*)) => fl(*error?*) where
      {
//
// HX-2015-09-10: can this actually be happening?
//
        val () =
        prerr_interror_loc(d2var_get_loc(d2v))
        val () =
        prerr! (": unbound variable [", d2v, "]")
        val () =
        prerrln! (
          ": appearance is likely during compilation of template instances."
        ) (* end of [val] *)
//
      } (* end of [None_vt] *)
  end // end of [Some]
else fl(*error?*) // HX-2013-06-28: is this actually possible?
//
end // end of [aux]
//
fun auxlst
(
  env: !ccompenv, fls: funlablst
) : funlablst_vt = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val fl2 = aux(env, fl)
    val fls2 = auxlst(env, fls)
  in
    list_vt_cons(fl2, fls2)
  end // end of [list_cons]
else list_vt_nil()
//
end // end of [auxlst]
//
in
  auxlst(env, fls)
end // end of [funent_funlablst_update]

(* ****** ****** *)

implement
funent_subst
  (env, sub, flab2, fent, sfx) = let
//
val loc = funent_get_loc(fent)
val flab = funent_get_lab(fent)
//
val imparg = funent_get_imparg(fent)
//
val tmparg = funent_get_tmparg(fent)
val tmparg2 = s2explstlst_subst(sub, tmparg)
//
val tmpret = funent_get_tmpret(fent)
//
val vbmap = funent_get_vbindmap(fent)
val inss_body = funent_get_instrlst(fent)
//
val tmplst =
  funent_get_tmpvarlst(fent)
val tmplst2 =
  tmpvarlst_subst(sub, tmplst, sfx)
val tmpmap2 = tmpmap_make(tmplst2)
//
val tmpret2 = tmpvar2var(tmpmap2, tmpret)
//
val () = let
  val opt = funlab_get_d2copt(flab)
in
//
if gopt_is_some (opt) then let
  val d2c = gopt_unsome<d2cst> (opt)
in
  ccompenv_add_tmpcstmat(env, tmpcstmat_TMPCSTMATsome2(d2c, tmparg2, flab2))
end else ()
//
end // end of [val]
//
val () = let
  val opt = funlab_get_d2vopt(flab)
in
//
if gopt_is_some (opt) then let
  val d2v = gopt_unsome<d2var> (opt)
in
  ccompenv_add_tmpvarmat(env, tmpvarmat_TMPVARMATsome2(d2v, tmparg2, flab2))
end else ()
//
end // end of [val]
//
val flvl2 = funlab_get_level(flab2)
//
val () = the_d2varlev_inc()
//
val d2es = funent_get_d2envlst(fent)
val d2es2 = d2envlst_subst(sub, d2es)
val () = ccompenv_inc_flabsetenv(env)
val d2es2g = glist_make_list_vt<d2env> (list_vt_copy<d2env> (d2es2))
val () = ccompenv_incwth_dvarsetenv(env, d2es2g)
val ((*freed*)) = list_vt_free<d2env>(d2es2)
//
val
inss2_body =
instrlst_subst(env, tmpmap2, sub, inss_body, sfx)
//
val
fls0_tmp =
ccompenv_getdec_flabsetenv(env)
val
fls0_tmp =
funlabset_vt_listize_free(fls0_tmp)
val
fls0_tmp =
ccompenv_addlst_flabsetenv_ifmap(env, flvl2, vbmap, fls0_tmp)
//
val fls0 = funent_get_flablst(fent)
val fls0 = funent_funlablst_update(env, fls0)
val fls02 = list_vt_append<funlab>(fls0, fls0_tmp)
//
val d2es2 = ccompenv_getdec_dvarsetenv(env)
val d2es2 = ccompenv_dvarsetenv_add_tempenver(env, d2es2)
val d2es2(*d2env-list*) = d2envset_vt_listize_free(d2es2)
//
val () = the_d2varlev_dec ()
//
val vbmap2 = vbindmap_subst (env, tmpmap2, sub, vbmap, sfx)
//
val () = tmpvarmap_vt_free<tmpvar> (tmpmap2)
//
val
fent2 =
funent_make (
  loc, flab2
, imparg, tmparg, gopt_none ((*tmpsub*)), tmpret2
, glist_make_list_vt<funlab> (fls02)
, glist_make_list_vt<d2env> ($UN.castvwtp0{List0_vt(d2env)}(d2es2))
, vbmap2, inss2_body, tmplst2
) (* end of [val] *)
//
in
  fent2
end // end of [funent_subst]

(* ****** ****** *)

implement
primval_subst
(
  env, map, sub, pmv0, sfx
) = let
//
val loc0 = pmv0.primval_loc ()
val hse0 = pmv0.primval_type ()
val hse0 = hisexp_subst(sub, hse0)
//
macdef ftmp(x) = tmpvar2var(map, ,(x))
//
macdef fpmv(x) = primval_subst(env, map, sub, ,(x), sfx)
macdef fpmvlst(xs) = primvalist_subst(env, map, sub, ,(xs), sfx)
//
macdef fpml(x) = primlab_subst(env, map, sub, ,(x), sfx)
macdef fpmlist(x) = primlablst_subst(env, map, sub, ,(x), sfx)
//
in
//
case+
primval_node_view (pmv0.primval_node ()) of
//
| ~PMVtmp(tmp) => let
    val tmp = ftmp(tmp) in primval_tmp(loc0, hse0, tmp)
  end // end of [PMVtmp]
| ~PMVtmpref(tmp) => let
    val tmp = ftmp(tmp) in primval_tmpref(loc0, hse0, tmp)
  end // end of [PMVtmpref]
//
| ~PMVarg(n) => primval_arg (loc0, hse0, n)
| ~PMVargref(n) => primval_argref (loc0, hse0, n)
| ~PMVargenv(n) => primval_argenv (loc0, hse0, n)
//
| ~PMVtop() => primval_top (loc0, hse0)
| ~PMVempty() => primval_empty (loc0, hse0)
//
| ~PMVextval (name) => primval_extval (loc0, hse0, name)
//
| ~PMVcastfn
    (d2c, pmv) => let
    val pmv = fpmv (pmv)
  in
    primval_castfn (loc0, hse0, d2c, pmv)
  end // end of [PMVcastfn]
//
| ~PMVtyrep(hse) => let
    val hse_sub =
      hisexp_subst (sub, hse)
    // end of [val]
  in
    primval_tyrep (loc0, hse0, hse_sub)
  end // end of [PMVtyrep]
//
| ~PMVsizeof(hse) => let
    val hse_sub =
      hisexp_subst (sub, hse)
    // end of [val]
  in
    primval_sizeof (loc0, hse0, hse_sub)
  end // end of [PMVsizeof]
//
| ~PMVselcon
  (
    pmv, hse_sum, lab
  ) => let
    val pmv = fpmv (pmv)
    val hse_sum = hisexp_subst (sub, hse_sum)
  in
    primval_selcon (loc0, hse0, pmv, hse_sum, lab)
  end // end of [PMVselcon]
//
| ~PMVselect
  (
    pmv, hse_rt, pml
  ) => let
    val pmv = fpmv(pmv)
    val hse_rt =
      hisexp_subst (sub, hse_rt)
    val pml = fpml(pml)
  in
    primval_select(loc0, hse0, pmv, hse_rt, pml)
  end // end of [PMVselect]
| ~PMVselect2
  (
    pmv, hse_rt, pmls
  ) => let
    val pmv = fpmv(pmv)
    val hse_rt =
      hisexp_subst (sub, hse_rt)
    val pmls = fpmlist (pmls)
  in
    primval_select2(loc0, hse0, pmv, hse_rt, pmls)
  end // end of [PMVselect2]
//
| ~PMVselptr
  (
    pmv, hse_rt, pmls
  ) => let
    val pmv = fpmv(pmv)
    val hse_rt =
      hisexp_subst (sub, hse_rt)
    val pmls = fpmlist(pmls)
  in
    primval_selptr(loc0, hse0, pmv, hse_rt, pmls)
  end // end of [PMVselptr]
//
| ~PMVptrof
    (pmv) => let
    val pmv = fpmv(pmv)
  in
    primval_ptrof(loc0, hse0, pmv)
  end // end of [PMVptrof]
| ~PMVptrofsel
  (
    pmv, hse_rt, pmls
  ) => let
    val pmv = fpmv(pmv)
    val hse_rt =
      hisexp_subst(sub, hse_rt)
    val pmls = fpmlist(pmls)
  in
    primval_ptrofsel(loc0, hse0, pmv, hse_rt, pmls)
  end // end of [PMVptrof]
//
| ~PMVrefarg
  (
    knd, freeknd, pmv
  ) => let
    val pmv = fpmv (pmv)
  in
    primval_refarg (loc0, hse0, knd, freeknd, pmv)
  end // of [PMVrefarg]
//
| ~PMVfunlab
    (flab) => primval_funlab(loc0, hse0, flab)
| ~PMVcfunlab
    (knd, flab) => primval_cfunlab(loc0, hse0, knd, flab)
//
| ~PMVd2vfunlab
    (d2v, flab) => let
    val opt = ccompenv_find_vbindmapall(env, d2v)
  in
    case+ opt of
    | ~Some_vt(pmv_flab) => pmv_flab
    | ~None_vt((*void*)) => primval_d2vfunlab(loc0, hse0, d2v, flab)
  end // end of [PMVd2vfunlab]
//
| ~PMVlamfix (_, _) => primval_lamfix_subst(env, sub, pmv0)
//
| ~PMVtmpltcst
    (d2c, t2mas) => let
    val trd = ccompenv_get_tmprecdepth (env)
    val mtrd = $GLOB.the_CCOMPENV_maxtmprecdepth_get ()
  in
    if trd < mtrd then let
      val t2mas = t2mpmarglst_subst (loc0, sub, t2mas)
      val tmpmat = ccompenv_tmpcst_match (env, d2c, t2mas)
    in
      ccomp_tmpcstmat (env, loc0, hse0, d2c, t2mas, tmpmat)
    end else
      pmv0 // HX-2013-01: maximal tmprecdepth has been reached!
    // end of [if]
  end // end of [PMVtmpltcst]
//
| ~PMVtmpltvar
    (d2v, t2mas) => let
    val trd = ccompenv_get_tmprecdepth (env)
    val mtrd = $GLOB.the_CCOMPENV_maxtmprecdepth_get ()
  in
    if trd < mtrd then let
      val t2mas = t2mpmarglst_subst (loc0, sub, t2mas)
      val tmpmat = ccompenv_tmpvar_match (env, d2v, t2mas)
    in
      ccomp_tmpvarmat (env, loc0, hse0, d2v, t2mas, tmpmat)
    end else
      pmv0 // HX-2013-01: maximal tmprecdepth is reached!
    // end of [if]
  end // end of [PMVtmpltvar]
//
| v (* rest-of-primval *) => (primval_node_view_free (v); pmv0)
//
end // end of [primval_subst]

(* ****** ****** *)

implement
primvalist_subst
(
  env, map, sub, pmvs, sfx
) = let
in
//
if glist_is_cons (pmvs) then let
    val pmv = glist_head<primval> (pmvs)
    val pmvs = glist_tail<primval> (pmvs)
    val pmv = primval_subst (env, map, sub, pmv, sfx)
    val pmvs = primvalist_subst (env, map, sub, pmvs, sfx)
  in
    glist_cons<primval> (pmv, pmvs)
  end // end of [list_cons]
else glist_nil()
//
end // end of [primvalist_subst]

(* ****** ****** *)

implement
primlab_subst
(
  env, map, sub, pml0, sfx
) = let
in
//
if primlab_node_is_PMLlab (pml0.primlab_node ()) then pml0
else let
    val-~PMLind (pmvs) = primlab_node_view (pml0.primlab_node ())
    val loc0 = pml0.primlab_loc ()
    val pmvs =
      primvalist_subst (env, map, sub, pmvs, sfx)
    // end of [val]
  in
    primlab_ind (loc0, pmvs)
  end (* end of [PMVind] *)
//
end (* end of [primlab_subst] *)

(* ****** ****** *)

implement
primlablst_subst
(
  env, map, sub, pmls, sfx
) = let
in
//
if glist_is_cons (pmls) then let
    val pml = glist_head<primlab> (pmls)
    val pmls = glist_tail<primlab> (pmls)
    val pml = primlab_subst (env, map, sub, pml, sfx)
    val pmls = primlablst_subst (env, map, sub, pmls, sfx)
  in
    glist_cons<primlab> (pml, pmls)
  end // end of [list_cons]
else glist_nil ()
//
end // end of [primlablst_subst]

(* ****** ****** *)

implement
labprimval_subst
(
  env, map, sub, lpmv, sfx
) = let
//
val lab = lpmv.labprimval_lab ()
val pmv = lpmv.labprimval_elt ()
val pmv = primval_subst (env, map, sub, pmv, sfx)
//
in
  labprimval_new (lab, pmv)
end // end of [labprimval_subst]

(* ****** ****** *)

implement
labprimvalist_subst
(
  env, map, sub, lpmvs, sfx
) = let
in
//
if glist_is_cons (lpmvs) then let
    val lpmv = glist_head<labprimval> (lpmvs)
    val lpmvs = glist_tail<labprimval> (lpmvs)
    val lpmv = labprimval_subst (env, map, sub, lpmv, sfx)
    val lpmvs = labprimvalist_subst (env, map, sub, lpmvs, sfx)
  in
    glist_cons<labprimval> (lpmv, lpmvs)
  end // end of [list_cons]
else glist_nil ()
//
end // end of [primvalist_subst]

(* ****** ****** *)

implement
tmprimval_subst
(
  env, map, sub, tpmv, sfx
) = let
//
macdef ftmp (x) = tmpvar2var (map, ,(x))
macdef fpmv (x) = primval_subst (env, map, sub, ,(x), sfx)
//
in
//
case+ tmprimval_view (tpmv) of
| ~TPMVnone (pmv) => let
    val pmv2 = fpmv(pmv) in tmprimval_TPMVnone (pmv2)
  end
| ~TPMVsome (tmp, pmv) => let
    val tmp2 = ftmp(tmp)
    val pmv2 = fpmv(pmv)
  in
    tmprimval_TPMVsome (tmp2, pmv2)
  end
//
end // end of [tmprimval_subst]

(* ****** ****** *)

implement
tmpmovlst_subst
(
  env, map, sub, tmvs, sfx
) = let
//
macdef ftmp (x) = tmpvar2var (map, ,(x))
macdef ftpmv (x) = tmprimval_subst (env, map, sub, ,(x), sfx)
in
//
if glist_is_cons (tmvs) then let
    val tmv = glist_head<tmpmov> (tmvs)
    val tmvs = glist_tail<tmpmov> (tmvs)
    val tpmv2 = ftpmv(tmv.tmpmov_src ())
    val tmp2 = ftmp(tmv.tmpmov_dst ())
    val tmv = tmpmov_new (tpmv2, tmp2)
    val tmvs = tmpmovlst_subst (env, map, sub, tmvs, sfx)
  in
    glist_cons<tmpmov> (tmv, tmvs)
  end // end of [list_cons]
else glist_nil ()
//
end // end of [tmpmovlst_subst]

(* ****** ****** *)

implement
patckont_subst
(
  env, map, sub, kont, sfx
) = let
//
macdef ftmp (x) = tmpvar2var (map, ,(x))
macdef fpmv (x) = primval_subst (env, map, sub, ,(x), sfx)
macdef ftmvlst (xs) = tmpmovlst_subst (env, map, sub, ,(xs), sfx)
//
in
//
case+ patckont_view (kont) of
| ~PTCKNTtmplabmov
    (tl, xs) => let
    val xs2 = ftmvlst (xs) in patckont_PTCKNTtmplabmov (tl, xs2)
  end
| ~PTCKNTraise (tmp, pmv) => let
    val tmp2 = ftmp(tmp)
    val pmv2 = fpmv(pmv)
  in
    patckont_PTCKNTraise (tmp2, pmv2)
  end
| v => (patckont_view_free (v); kont)
//
end // end of [patckont_subst]

(* ****** ****** *)

implement
primdec_subst
(
  env, map, sub, pmd0, sfx
) = let
//
val loc0 = pmd0.primdec_loc ()
//
in
//
case+
primdec_node_view (pmd0.primdec_node ())
of (* case+ *)
//
| ~PMDnone () => pmd0
//
| ~PMDlist
    (pmds) => let
    val
    pmds =
    primdeclst_subst
      (env, map, sub, pmds, sfx)
    // end of [val]
  in
    primdec_list (loc0, pmds)
  end // end of [PMDlist]
//
| ~PMDsaspdec _ => pmd0
//
| ~PMDextvar
    (name, inss) => let
    val
    inss =
    instrlst_subst
      (env, map, sub, inss, sfx)
    // end of [val]
  in
    primdec_extvar (loc0, name, inss)
  end // end of [PMDextvar]
//
| ~PMDdatdecs _ => pmd0
| ~PMDexndecs _ => pmd0
//
| ~PMDimpdec (imp) => let
    val () =
      ccompenv_add_impdecloc(env, sub, imp) in pmd0
    // end of [val]
  end // end of [PMDimpdec]
//
| ~PMDfundecs
    (knd, decarg, hfds) => let
    val () =
    ccompenv_add_fundecsloc
      (env, sub, knd, decarg, hfds)
    // end of [val]
    val () =
    ccompenv_add_fundecsloc_subst
      (env, sub, knd, decarg, hfds)
    // end of [val]
  in
    pmd0
  end // end of [PMDfundecs]
//
| ~PMDvaldecs
    (knd, hvds, inss) => let
    val
    inss =
    instrlst_subst
      (env, map, sub, inss, sfx)
    // end of [val]
  in
    primdec_valdecs(loc0, knd, hvds, inss)
  end // end of [PMDvaldecs]
| ~PMDvaldecs_rec
    (knd, hvds, inss) => let
    val
    inss =
    instrlst_subst
      (env, map, sub, inss, sfx)
    // end of [val]
  in
    primdec_valdecs_rec(loc0, knd, hvds, inss)
  end // end of [PMDvaldecs_rec]
//
| ~PMDvardecs
    (hvds, inss) => let
    val
    inss =
    instrlst_subst
      (env, map, sub, inss, sfx)
    // end of [val]
  in
    primdec_vardecs(loc0, hvds, inss)
  end // end of [PMDvardecs]
//
| ~PMDinclude
    (stadyn, pmds) => let
    val
    pmds =
    primdeclst_subst
      (env, map, sub, pmds, sfx)
    // end of [val]
  in
    primdec_include(loc0, stadyn, pmds)
  end // end of [PMDinclude]
//
| ~PMDstaload
    (hid) => pmd0 where
  {
    val-~HIDstaload
      (_, _, _, fenv, loaded) = hidecl_node_view (hid.hidecl_node ())
    val ((*void*)) = ccompenv_add_staload(env, fenv)
  } (* end of [PMDstaload] *)
//
| ~PMDstaloadloc
  (
    pfil, nspace, pmds
  ) => pmd0 (*sanctuary*)
//
| ~PMDdynload(hid) => pmd0
//
| ~PMDlocal
  (
    pmds_head, pmds_body
  ) => let
    val (pf | ()) = ccompenv_push(env)
    val
    pmds_head =
    primdeclst_subst
      (env, map, sub, pmds_head, sfx)
    // end of [val]
    val (pf2 | ()) = ccompenv_push (env)
    val
    pmds_body =
    primdeclst_subst
      (env, map, sub, pmds_body, sfx)
    // end of [val]
    val ((*void*)) =
      ccompenv_localjoin(pf, pf2 | env)
    // end of [val]
  in
    primdec_local(loc0, pmds_head, pmds_body)
  end // end of [PMDlocal]
//
end // end of [primdec_subst]

(* ****** ****** *)

implement
primdeclst_subst
(
  env, map, sub, pmds, sfx
) = let
in
//
if glist_is_cons (pmds) then let
    val pmd = glist_head<primdec> (pmds)
    val pmds = glist_tail<primdec> (pmds)
    val pmd = primdec_subst(env, map, sub, pmd, sfx)
    val pmds = primdeclst_subst(env, map, sub, pmds, sfx)
  in
    glist_cons<primdec> (pmd, pmds)
  end // end of [list_cons]
else glist_nil()
//
end // end of [primdeclst_subst]

(* ****** ****** *)

local

vtypedef
vbindlst_vt = List0_vt @(d2var, primval)

fun auxlst
(
  env: !ccompenv
, map: !tmpmap, sub: !stasub, vbs: vbindlst_vt, sfx: int
, res: &vbindmap
) : void = let
in
//
case+ vbs of
| ~list_vt_cons
    (vb, vbs) => let
    val pmv2 = primval_subst (env, map, sub, vb.1, sfx)
    val _(*replaced*) = d2varmap_insert<primval> (res, vb.0, pmv2)
  in
    auxlst (env, map, sub, vbs, sfx, res)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
//
end (* end of [auxlst] *)

in (* in of [local] *)

implement
vbindmap_subst
(
  env, map, sub, vbmap, sfx
) = res where {
//
var res: vbindmap = d2varmap_nil<primval> ()
val vblst = d2varmap_listize<primval> (vbmap)
val () = auxlst (env, map, sub, vblst, sfx, res)
//
} // end of [vbindmap_subst]

end (* end of [local] *)

(* ****** ****** *)

implement
instr_subst
(
  env, map, sub, ins0, sfx
) = let
//
val loc0 = ins0.instr_loc ()
//
macdef ftmp(x) = tmpvar2var(map, ,(x))
macdef fpmv(x) = primval_subst(env, map, sub, ,(x), sfx)
macdef flabpmv(lx) = labprimval_subst(env, map, sub, ,(lx), sfx)
macdef fpmvlst(xs) = primvalist_subst(env, map, sub, ,(xs), sfx)
macdef flabpmvlst(lxs) = labprimvalist_subst(env, map, sub, ,(lxs), sfx)
//
macdef fkont(x) = patckont_subst(env, map, sub, ,(x), sfx)
//
macdef fpmd(x) = primdec_subst(env, map, sub, ,(x), sfx)
macdef fpmdlst(xs) = primdeclst_subst(env, map, sub, ,(xs), sfx)
//
macdef finstrlst(inss) = instrlst_subst(env, map, sub, ,(inss), sfx)
macdef fibranchlst(inss) = ibranchlst_subst(env, map, sub, ,(inss), sfx)
//
in (* in-of-let *)
//
case+
instr_node_view (ins0.instr_node ())
of (* case+ *)
//
| ~INSfunlab _ => ins0
| ~INStmplab _ => ins0
//
| ~INScomment _ => ins0
//
| ~INSmove_val
    (tmp, pmv) => let
    val tmp = ftmp(tmp)
    val pmv = fpmv(pmv)
  in
    instr_move_val(loc0, tmp, pmv)
  end // end of [INSmove_val]
//
| ~INSpmove_val
    (tmp, pmv) => let
    val tmp = ftmp(tmp)
    val pmv = fpmv(pmv)
  in
    instr_pmove_val(loc0, tmp, pmv)
  end // end of [INSpmove_val]
//
| ~INSmove_arg_val
    (narg, pmv) => let
    val pmv = fpmv(pmv)
  in
    instr_move_arg_val(loc0, narg, pmv)
  end // end of [INSmove_arg_val]
//
| ~INSfcall
    (tmp, _fun, hse, _arg) => let
    val tmp = ftmp(tmp)
    val _fun = fpmv(_fun)
    val hse = hisexp_subst (sub, hse)
    val _arg = fpmvlst(_arg)
  in
    instr_fcall(loc0, tmp, _fun, hse, _arg)
  end // end of [INSfcall]
//
| ~INSfcall2
    (tmp, flab, ntl, hse, _arg) => let
    val tmp = ftmp(tmp)
    val () =
      tmpvar_inc_tailcal(tmp)
    // end of [val]
    val hse = hisexp_subst(sub, hse)
    val _arg = fpmvlst(_arg)
  in
    instr_fcall2(loc0, tmp, flab, ntl, hse, _arg)
  end // end of [INSfcall2]
//
| ~INSextfcall
    (tmp, _fun, _arg) => let
    val tmp = ftmp(tmp)
    val _arg = fpmvlst(_arg)
  in
    instr_extfcall(loc0, tmp, _fun, _arg)
  end // end of [INSextfcall]
//
| ~INSextmcall
    (tmp, _obj, _mtd, _arg) => let
    val tmp = ftmp(tmp)
    val _obj = fpmv(_obj)
    val _arg = fpmvlst(_arg)
  in
    instr_extmcall(loc0, tmp, _obj, _mtd, _arg)
  end // end of [INSextmcall]
//
| ~INScond
  (
    pmv, _then, _else
  ) => let
    val pmv = fpmv(pmv)
    val _then = finstrlst(_then)
    val _else = finstrlst(_else)
  in
    instr_cond(loc0, pmv, _then, _else)
  end // end of [INScond]
//
| ~INSfreecon(pmv) => let
    val pmv = fpmv(pmv) in instr_freecon(loc0, pmv)
  end // end of [INSfreecon]
//
| ~INSloop
  (
    tlab_init, tlab_fini, tlab_cont
  , inss_init, pmv_test, inss_test, inss_post, inss_body
  ) => let
    val inss_init = finstrlst (inss_init)
    val pmv_test = fpmv (pmv_test)
    val inss_test = finstrlst (inss_test)
    val inss_post = finstrlst (inss_post)
    val inss_body = finstrlst (inss_body)
  in
    instr_loop
    (
      loc0, tlab_init, tlab_fini, tlab_cont
    , inss_init, pmv_test, inss_test, inss_post, inss_body
    ) // endfun
  end
| ~INSloopexn _ => ins0
//
| ~INScaseof (ibrs) => let
    val ibrs = fibranchlst (ibrs) in instr_caseof (loc0, ibrs)
  end // end of [INScaseof]
//
| ~INSletpop () => let
    prval pfpush = __assert () where
    {
      extern praxi __assert (): ccompenv_push_v
    } // end of [prval]
    val () = ccompenv_pop (pfpush | env)
  in
    ins0
  end // end of [INSletpop]
//
| ~INSletpush (pmds) => let
    val (pfpush | ()) = ccompenv_push (env)
    prval () = __assert (pfpush) where {
      extern praxi __assert (pf: ccompenv_push_v): void
    } // end of [prval]
    val pmds = fpmdlst (pmds)
  in
    instr_letpush (loc0, pmds)
  end // end of [INSletpush]
//
| ~INSmove_con
  (
    tmp, d2c, hse_sum, lpmvs
  ) => let
    val tmp = ftmp (tmp)
    val hse_sum = hisexp_subst (sub, hse_sum)
    val lpmvs = flabpmvlst (lpmvs)
  in
    instr_move_con (loc0, tmp, d2c, hse_sum, lpmvs)
  end // end of [INSmove_con]
//
| ~INSmove_ref
    (tmp, pmv) => let
    val tmp = ftmp (tmp)
    val pmv = fpmv (pmv)
  in
    instr_move_ref (loc0, tmp, pmv)
  end // end of [INSmove_ref]
//
| ~INSmove_boxrec
  (
    tmp, lpmvs, hse_rec
  ) => let
    val tmp = ftmp (tmp)
    val hse_rec = hisexp_subst (sub, hse_rec)
    val lpmvs = flabpmvlst (lpmvs)
  in
    instr_move_boxrec (loc0, tmp, lpmvs, hse_rec)
  end // end of [INSmove_boxrec]
| ~INSmove_fltrec
  (
    tmp, lpmvs, hse_rec
  ) => let
    val tmp = ftmp (tmp)
    val hse_rec = hisexp_subst (sub, hse_rec)
    val lpmvs = flabpmvlst (lpmvs)
  in
    instr_move_fltrec (loc0, tmp, lpmvs, hse_rec)
  end // end of [INSmove_fltrec]
//
| ~INSpatck
  (
    pmv, pck, kont
  ) => let
    val pmv = fpmv (pmv)
    val kont = fkont (kont)
  in
    instr_patck (loc0, pmv, pck, kont)
  end // end of [INSpatck]
//
| ~INSmove_ptrofsel
  (
    tmp, pmv, hse_rt, pmls
  ) => let
    val tmp = ftmp (tmp)
    val pmv = fpmv (pmv)
    val hse_rt = hisexp_subst (sub, hse_rt)
  in
    instr_move_ptrofsel(loc0, tmp, pmv, hse_rt, pmls)
  end // end of [INSmove_ptrofsel]
//
| ~INSstore_ptrofs
  (
    pmv_l, hse_rt, pmls, pmv_r
  ) => let
    val pmv_l = fpmv (pmv_l)
    val hse_rt = hisexp_subst (sub, hse_rt)
    val pmv_r = fpmv (pmv_r)
  in
    instr_store_ptrofs (loc0, pmv_l, hse_rt, pmls, pmv_r)
  end // end of [INSstore_ptrofs]
//
| ~INSxstore_ptrofs
  (
    tmp, pmv_l, hse_rt, pmls, pmv_r
  ) => let
    val tmp = ftmp (tmp)
    val pmv_l = fpmv (pmv_l)
    val hse_rt = hisexp_subst (sub, hse_rt)
    val pmv_r = fpmv (pmv_r)
  in
    instr_xstore_ptrofs (loc0, tmp, pmv_l, hse_rt, pmls, pmv_r)
  end // end of [INSxstore_ptrofs]
//
| ~INSmove_delay
  (
    tmp, lin, hse, pmv_thunk
  ) => let
    val tmp = ftmp (tmp)
    val hse = hisexp_subst (sub, hse)
    val pmv_thunk = fpmv (pmv_thunk)
  in
    instr_move_delay (loc0, tmp, lin, hse, pmv_thunk)
  end // end of [INSmove_delay]
| ~INSmove_lazyeval
  (
    tmp, lin, hse, pmv_lazyval
  ) => let
    val tmp = ftmp (tmp)
    val hse = hisexp_subst (sub, hse)
    val pmv_lazyval = fpmv (pmv_lazyval)
  in
    instr_move_lazyeval (loc0, tmp, lin, hse, pmv_lazyval)
  end // end of [INSmove_lazyeval]
//
| ~INSraise
    (tmp, pmv_exn) => let
    val tmp = ftmp (tmp)
    val pmv_exn = fpmv (pmv_exn)
  in
    instr_raise (loc0, tmp, pmv_exn)
  end // end of [INSraise]
//
| ~INStrywith
  (
    tmpexn, inss_try, ibrs_with
  ) => let
    val tmpexn = ftmp (tmpexn)
    val inss_try = finstrlst (inss_try)
    val ibrs_with = fibranchlst (ibrs_with)
  in
    instr_trywith (loc0, tmpexn, inss_try, ibrs_with)
  end // end of [INStrywith]
//
| ~INSmove_list_nil
    (tmp) => let
    val tmp = ftmp(tmp)
  in
    instr_move_list_nil (loc0, tmp)
  end // end of [INSmove_list_nil]
//
| ~INSpmove_list_nil
    (tmp) => let
    val tmp = ftmp (tmp)
  in
    instr_pmove_list_nil (loc0, tmp)
  end // end of [INSpmove_list_nil]
| ~INSpmove_list_cons
    (tmp, hse) => let
    val tmp = ftmp (tmp)
    val hse = hisexp_subst (sub, hse)
  in
    instr_pmove_list_cons (loc0, tmp, hse)
  end // end of [INSpmove_list_cons]
//
| ~INSmove_list_phead
    (tmp_hd, tmp_tl, hse) => let
    val tmp_hd = ftmp (tmp_hd)
    val tmp_tl = ftmp (tmp_tl)
    val hse = hisexp_subst (sub, hse)
  in
    instr_move_list_phead (loc0, tmp_hd, tmp_tl, hse)
  end // end of [INSmove_list_phead]
| ~INSmove_list_ptail
    (tmp_new, tmp_old, hse) => let
    val tmp_new = ftmp(tmp_new)
    val tmp_old = ftmp(tmp_old)
    val hse = hisexp_subst(sub, hse)
  in
    instr_move_list_ptail(loc0, tmp_new, tmp_old, hse)
  end // end of [INSmove_list_ptail]
//
| ~INSmove_arrpsz_ptr
    (tmp1, tmp2) => let
    val tmp1 = ftmp (tmp1)
    val tmp2 = ftmp (tmp2)
  in
    instr_move_arrpsz_ptr (loc0, tmp1, tmp2)
  end // end of [INSmove_arrpsz_ptr]
//
| ~INSstore_arrpsz_asz
    (tmp, asz) => let
    val tmp = ftmp(tmp)
  in
    instr_store_arrpsz_asz(loc0, tmp, asz)
  end // end of [INSstore_arrpsz_asz]
//
| ~INSstore_arrpsz_ptr
  (
    tmp, hse_elt, asz
  ) => let
    val tmp = ftmp(tmp)
    val hse_elt =
      hisexp_subst(sub, hse_elt)
    // end of [val]
  in
    instr_store_arrpsz_ptr(loc0, tmp, hse_elt, asz)
  end // end of [INSstore_arrpsz_ptr]
//
| ~INSupdate_ptrinc
    (tmp, hse_elt) => let
    val tmp = ftmp(tmp)
    val hse_elt =
      hisexp_subst(sub, hse_elt)
  in
    instr_update_ptrinc(loc0, tmp, hse_elt)
  end // end of [INSupdate_ptrinc]
| ~INSupdate_ptrdec
    (tmp, hse_elt) => let
    val tmp = ftmp(tmp)
    val hse_elt =
      hisexp_subst(sub, hse_elt)
  in
    instr_update_ptrdec(loc0, tmp, hse_elt)
  end // end of [INSupdate_ptrdec]
//
| ~INSclosure_initize
    (tmpret, knd, flab) => let
//
    val sfx = funlab_incget_ncopy(flab)
//
    val flab2 = funlab_subst(sub, flab)
    val () = funlab_set_suffix(flab2, sfx)
//
    val () = the_funlablst_add(flab2)
    val () = ccompenv_add_flabsetenv(env, flab2)
//
    val
    pmv_fun =
    primval_make_funlab(loc0, flab2)
    val () = (
      if gopt_is_some (knd) then let
        val d2v = gopt_unsome<d2var> (knd)
      in
        ccompenv_add_vbindmapenvall(env, d2v, pmv_fun)
      end else ()
    ) : void // end of [val]
//
    val fent = gopt_unsome<funent> (funlab_get_funent(flab))
//
    val fent2 = funent_subst(env, sub, flab2, fent, sfx)
    val ((*void*)) = funlab_set_funent(flab2, gopt_some<funent>(fent2))
//
    val tmpret2 = ftmp(tmpret)
    val ((*void*)) = tmpvar_set_tyclo(tmpret2, flab2)
//
  in
    instr_closure_initize(loc0, tmpret2, knd, flab2)
  end // end of [INSclosure_initize]
//
| ~INStmpdec _ => ins0
//
| ~INSextvar(name, pmv) => let
    val pmv2 = fpmv(pmv) in instr_extvar(loc0, name, pmv2)
  end
| ~INSdcstdef(d2c0, pmv) => let
    val pmv2 = fpmv(pmv) in instr_dcstdef(loc0, d2c0, pmv2)
  end
//
| ~INStempenver(d2vs) => ins0 where
  {
//
    val () =
    ccompenv_add_tempenver(env, d2vs)
//
  } (* end of [INStempenver] *)
//
end // end of [instr_subst]

(* ****** ****** *)

implement
instrlst_subst
  (env, map, sub, inss, sfx) = let
//
fun loop
(
  env: !ccompenv
, map: !tmpmap
, sub: !stasub
, inss: instrlst
, sfx: int
, res: instrlst
) : instrlst = let
in
//
if glist_is_cons (inss) then let
    val ins = glist_head<instr> (inss)
    val inss = glist_tail<instr> (inss)
    val ins =
      instr_subst (env, map, sub, ins, sfx)
    // end of [val]
  in
    loop (env, map, sub, inss, sfx, glist_cons<instr> (ins, res))
  end // end of [list_cons]
else res
//
end // end of [loop]
//
in
  glist_reverse<instr> (loop (env, map, sub, inss, sfx, glist_nil ()))
end // end of [instrlst_subst]

(* ****** ****** *)

implement
ibranchlst_subst
  (env, map, sub, ibrs, sfx) = let
in
//
if glist_is_cons (ibrs) then let
    val ibr = glist_head<ibranch> (ibrs)
    val ibrs = glist_tail<ibranch> (ibrs)
    val loc = ibr.ibranch_loc ()
    val inss = ibr.ibranch_inslst ()
    val inss = instrlst_subst (env, map, sub, inss, sfx)
    val ibr = ibranch_make (loc, inss)
    val ibrs = ibranchlst_subst (env, map, sub, ibrs, sfx)
  in
    glist_cons<ibranch> (ibr, ibrs)
  end // end of [list_cons]
else glist_nil ()
//
end (* end of [ibranchlst_subst] *)

(* ****** ****** *)

implement
primval_lamfix_subst
  (env, sub, pmv0) = let
//
val-~PMVlamfix
(
  knd, pmv
) = primval_node_view (pmv0.primval_node ())
//
val loc = pmv.primval_loc ()
val hse = pmv.primval_type ()
//
val pnd = pmv.primval_node ()
//
val fl = (
//
if primval_node_is_PMVfunlab (pnd) then let
  val-~PMVfunlab (fl) = primval_node_view (pnd) in fl
end else if primval_node_is_PMVcfunlab (pnd) then let
  val-~PMVcfunlab (knd, fl) = primval_node_view (pnd) in fl
end else let
  val-~PMVd2vfunlab (d2v, fl) = primval_node_view (pnd) in fl
end // case- (the MatchError is the assertion above)
//
) : funlab // end of [val]
//
val sfx = funlab_incget_ncopy(fl)
//
val flab2 = funlab_subst(sub, fl)
val ((*void*)) = funlab_set_suffix(flab2, sfx)
//
val ((*void*)) = the_funlablst_add(flab2)
val ((*void*)) = ccompenv_add_flabsetenv(env, flab2)
//
val pmv_fun = primval_make_funlab(loc, flab2)
//
val () =
(
if gopt_is_some (knd) then let
  val d2v = gopt_unsome<d2var> (knd)
in
  ccompenv_add_vbindmapenvall(env, d2v, pmv_fun)
end else ()
) : void // end of [val]
//
val fent = gopt_unsome<funent> (funlab_get_funent(fl))
//
val fent2 = funent_subst(env, sub, flab2, fent, sfx)
val ((*void*)) = funlab_set_funent(flab2, gopt_some<funent>(fent2))
//
in
  primval_lamfix(knd, pmv_fun)
end // end of [primval_lamfix_subst]

(* ****** ****** *)

local

fun
auxinit
(
  env: !ccompenv
, sub: !stasub, hfds: hifundeclst, i: int
) : funlablst = let
in
//
if glist_is_cons (hfds) then let
//
    val hfd = glist_head<hifundec> (hfds)
    val hfds = glist_tail<hifundec> (hfds)
//
    val fl =
      gopt_unsome<funlab> (hifundec_get_funlabopt(hfd))
    // end of [val]
//
    val sfx = funlab_incget_ncopy(fl)
//
    val flab2 = funlab_subst(sub, fl)
    val ((*void*)) = funlab_set_suffix(flab2, sfx)
//
// HX: only the first fnx-decl is added!
//
    val () = (
      if i <= 1 then the_funlablst_add(flab2)
    ) (* end of [val] *)
//
    val () = ccompenv_add_flabsetenv(env, flab2)
//
    val loc = hfd.hifundec_loc ()
    val d2v = hfd.hifundec_var ()
    val pmv = primval_make_funlab(loc, flab2)
//
    val () = ccompenv_add_vbindmapenvall(env, d2v, pmv)
//
    val i2 = (if i >= 1 then i+1 else i): int
    val fls2 = auxinit (env, sub, hfds, i2)
  in
    glist_cons<funlab> (flab2, fls2)
  end (* end of [list_cons] *)
else glist_nil ()
//
end // end of [auxinit]

fun
auxmain
(
  env: !ccompenv, sub: !stasub
, hfds: hifundeclst, fls2: funlablst
) : void = let
in
//
if glist_is_cons (hfds) then let
    val hfds = glist_tail<hifundec> (hfds)
    val fl2 = glist_head<funlab> (fls2)
    val fls2 = glist_tail<funlab> (fls2)
    val fl = gopt_unsome<funlab> (funlab_get_origin (fl2))
    val fent = gopt_unsome<funent> (funlab_get_funent (fl))
    val sfx = funlab_get_suffix (fl2)
    val fent2 = funent_subst (env, sub, fl2, fent, sfx)
    val () = funlab_set_funent (fl2, gopt_some<funent> (fent2))
  in
    auxmain (env, sub, hfds, fls2)
  end // end of [list_cons]
else ((*nothing*))
//
end // end of [auxmain]

fun
auxfnxset
(
  fls: funlablst
) : void = let
//
val fl0 = glist_head<funlab> (fls)
//
val fent0 =
  gopt_unsome<funent> (funlab_get_funent(fl0))
//
val ((*void*)) =
  funent_set_fnxlablst(fent0, fls)
//
fun
fwork
(
  fl: funlab
) : void = let
  val fent = gopt_unsome<funent> (funlab_get_funent(fl))
in
  tmpvar_inc_tailcal(funent_get_tmpret(fent))
end // end of [fwork]
//
fun
floop
(
  fls: funlablst
) : void =
  if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val () = fwork (fl)
  in
    floop (fls)
  end else ()
//
val ((*void*)) = floop (fls)
//
in
  // nothing
end // end of [auxfnxset]

in (* in of [local] *)

implement
ccompenv_add_fundecsloc_subst
  (env, sub, knd, decarg, hfds) = let
in
//
if glist_is_cons (decarg) then ()
else let
//
    val
    tlcalopt =
      $GLOB.the_CCOMPATS_tlcalopt_get()
    val isfnx =
    (
      if tlcalopt > 0
      then funkind_is_mutailrec(knd) else false
    ) : bool // end of [val]
//
    val i0 = (if isfnx then 1 else 0): int
    val fls = auxinit (env, sub, hfds, i0)
    val ((*void*)) = auxmain (env, sub, hfds, fls)
    val ((*void*)) = if isfnx then auxfnxset (fls)
  in
    // nothing
  end // end of [list_nil]
//
end // end of [ccompenv_add_fundecsloc_subst]

end // end of [local]

(* ****** ****** *)

(* end of [pats_ccomp_subst.dats] *)
