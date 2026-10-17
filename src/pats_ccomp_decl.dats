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
// Start Time: October, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_decl.dats, see PORTING.md, "ccomp group C2")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload "./pats_basics.sats"
//
(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>() = prerr "pats_ccomp_decl"
//
(* ****** ****** *)
//
staload
GLOBAL = "./pats_global.sats"
//
(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
typedef location = $LOC.location
overload
print with $LOC.print_location
//
(* ****** ****** *)
//
staload "./pats_staexp2.sats"
//
staload D2E = "./pats_dynexp2.sats"
//
typedef d2cst = $D2E.d2cst
//
typedef
dynexp2_funlabopt = $D2E.funlabopt
//
overload print with $D2E.print_d2var
//
(* ****** ****** *)

staload "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_typerase.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

#include "./pats_typerase.hats"
#include "./pats_ccomp_c2.hats"

(* ****** ****** *)

extern
fun hisaspdec_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidsaspdec_ccomp]
extern
fun hireassume_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidreassume_ccomp]

extern
fun hiextvar_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidextvar_ccomp]

extern
fun hiextype_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidextype_ccomp]

extern
fun hiextcode_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidextcode_ccomp]

extern
fun hidatdecs_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hidatdecs_ccomp]
extern
fun hiexndecs_ccomp
  (env: !ccompenv, hid0: hidecl): primdec
// end of [hiexndecs_ccomp]

(* ****** ****** *)

extern
fun
hivaldeclst_ccomp
(
  env: !ccompenv
, lvl0: int, knd: valkind, hvds: hivaldeclst
) : instrlst // end of [hivaldeclst_ccomp]

extern
fun
hivaldeclst_ccomp_rec
(
  env: !ccompenv
, lvl0: int, knd: valkind, hvds: hivaldeclst
) : instrlst // end of [hivaldeclst_ccomp_rec]

extern
fun
hivardeclst_ccomp
  (env: !ccompenv, lvl0: int, hvds: hivardeclst): instrlst
// end of [hivardeclst_ccomp]

(* ****** ****** *)

implement
hidecl_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
//
in
//
case+ hidecl_node_view(hid0.hidecl_node()) of
//
| ~HIDnone () => primdec_none (loc0)
//
| ~HIDlist (hids) => let
    val pmds =
      hideclist_ccomp(env, hids) in primdec_list(loc0, pmds)
    // end of [val]
  end // end of [HIDlist]
//
| ~HIDsaspdec _ => hisaspdec_ccomp(env, hid0)
//
| ~HIDreassume _ => hireassume_ccomp(env, hid0)
//
| ~HIDextype _ => hiextype_ccomp (env, hid0)
| ~HIDextvar _ => hiextvar_ccomp (env, hid0)
| ~HIDextcode _ => hiextcode_ccomp (env, hid0)
//
| ~HIDdatdecs _ => hidatdecs_ccomp (env, hid0)
| ~HIDexndecs _ => hiexndecs_ccomp (env, hid0)
//
| ~HIDdcstdecs (_, _) => primdec_none (loc0)
//
| ~HIDimpdec
    (_(*knd*), imp) => let
    val d2c = imp.hiimpdec_cst()
    val lvl0 = the_d2varlev_get ()
    val ((*void*)) =
      hiimpdec_ccomp (env, lvl0, imp, 0(*local*))
    // end of [val]
  in
    primdec_impdec (loc0, imp)
  end // end of [HIDimpdec]
//
| ~HIDfundecs
    (knd, decarg, hfds) => let
//
    val
    lvl0 = the_d2varlev_get ()
    val ((*void*)) =
    hifundeclst_ccomp
      (env, lvl0, knd, decarg, hfds)
    // end of [val]
//
  in
    primdec_fundecs(loc0, knd, decarg, hfds)
  end // end of [HIDfundecs]
//
| ~HIDvaldecs
    (knd, hvds) => let
    val
    lvl0 = the_d2varlev_get()
    val
    inss = hivaldeclst_ccomp(env, lvl0, knd, hvds)
  in
    primdec_valdecs(loc0, knd, hvds, inss)
  end // end of [HIDvaldecs]
| ~HIDvaldecs_rec
    (knd, hvds) => let
//
    val
    lvl0 = the_d2varlev_get()
    val
    inss =
    hivaldeclst_ccomp_rec(env, lvl0, knd, hvds)
//
  in
    primdec_valdecs_rec (loc0, knd, hvds, inss)
  end // end of [HIDvaldecs_rec]
//
| ~HIDvardecs
    (hvds) => let
//
    val
    lvl0 = the_d2varlev_get()
    val
    inss = hivardeclst_ccomp(env, lvl0, hvds)
//
  in
    primdec_vardecs (loc0, hvds, inss)
  end // end of [HIDvardecs]
//
| ~HIDinclude
    (knd, hids) => let
(*
    val () =
    println!
      ("hidecl_ccomp: HIDinclude: loc0 = ", loc0)
    val () =
    println!
      ("hidecl_ccomp: HIDinclude: hid0 = ", hid0)
*)
    val
    pmds =
    hideclist_ccomp(env, hids)
  in
    primdec_include(loc0, knd, pmds)
  end // end of [HIDinclude]
//
| ~HIDstaload
  (
    idopt, cfil, flag, fenv, loaded
  ) => let
(*
    val () =
    println!
      ("hidecl_ccomp: HIDstaload: loc0 = ", loc0)
    val () =
    println!
      ("hidecl_ccomp: HIDstaload: hid0 = ", hid0)
*)
    val () = the_staloadlst_add(hid0)
    val () = ccompenv_add_staload(env, fenv)
  in
    primdec_staload (loc0, hid0)
  end // end of [HIDstaload]
//
| ~HIDstaloadloc
    (pfil, nspace, hids) => let
    val (pf | ()) = ccompenv_push (env)
    val pmds = hideclist_ccomp (env, hids)    
    val ((*void*)) = ccompenv_pop (pf | env)
  in
    primdec_staloadloc (loc0, pfil, nspace, pmds)
  end // end of [HIDtsaloadloc]
//
| ~HIDdynload _ => let
(*
    val () = println! ("hidecl_ccomp: HIDdynload: loc0 = ", loc0)
    val () = println! ("hidecl_ccomp: HIDdynload: hid0 = ", hid0)
*)
    val () = the_dynloadlst_add (hid0)
  in
    primdec_dynload (loc0, hid0)
  end // end of [HIDdynload]
//
| ~HIDlocal
  (
    hids_head, hids_body
  ) => let
//
// HX-2015-09-15:
// Note that locally defined templates can be
// accessed in template instances that are outside
// the local-scope, but local implements cannot.
// Please find the details in [ccompenv_localjoin].
//
    val (pf1|()) = ccompenv_push (env)
    val pmds_head = hideclist_ccomp (env, hids_head)
    val (pf2|()) = ccompenv_push (env)
    val pmds_body = hideclist_ccomp (env, hids_body)
    val ((*void*)) = ccompenv_localjoin (pf1, pf2 | env)
//
  in
    primdec_local (loc0, pmds_head, pmds_body)
  end // end of [HIDlocal]
//
(*
| _ => let
    val () = println! ("hidecl_ccomp: loc0 = ", loc0)
    val () = println! ("hidecl_ccomp: hid0 = ", hid0)
  in
    exitloc (1)
  end // end of [_]
*)
//
end // end of [hidecl_ccomp]

(* ****** ****** *)

implement
hideclist_ccomp
  (env, hids) = let
//
fun loop (
  env: !ccompenv
, hids: hideclist
, pmds: List0_vt(primdec)
) : primdeclst =
(
//
if glist_is_cons(hids) then let
  val pmd =
    hidecl_ccomp (env, glist_head<hidecl>(hids))
  // end of [val]
in
  loop (env, glist_tail<hidecl>(hids), list_vt_cons(pmd, pmds))
end else glist_ofrev_vt<primdec>(pmds, glist_nil((*void*)))
//
) (* end of [loop] *)
//
in
  loop (env, hids, list_vt_nil((*void*)))
end // end of [hideclist_ccomp]

(* ****** ****** *)

implement
hideclist_ccomp0
  (hids) = let
//
val env = ccompenv_make ()
val pmds = hideclist_ccomp (env, hids)
val () = ccompenv_free (env)
//
in
  pmds
end // end of [hideclist_ccomp0]

(* ****** ****** *)

implement
hisaspdec_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val-~HIDsaspdec(d2c) = hidecl_node_view(hid0.hidecl_node())
//
val ((*void*)) = the_saspdeclst_add(hid0)
//
in
  primdec_saspdec(loc0, d2c)
end // end of [hisaspdec_ccomp]

(* ****** ****** *)
//
implement
hireassume_ccomp
  (env, hid0) =
  primdec_none(hid0.hidecl_loc())
//
(* ****** ****** *)

implement
hiextype_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val-~HIDextype(name, hse_def) = hidecl_node_view(hid0.hidecl_node())
val _(*hit*) = hisexp_typize (0(*flag*), hse_def)
val () = the_extypelst_add (hid0)
//
in
  primdec_none (loc0)
end // end of [hiextype_ccomp]

(* ****** ****** *)

implement
hiextvar_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val-~HIDextvar(name, hde_def) = hidecl_node_view(hid0.hidecl_node())
val res = instrseq_make_nil()
val pmv_def = hidexp_ccomp (env, res, hde_def)
val () = instrseq_add_extvar (res, loc0, name, pmv_def)
val inss = instrseq_get_free (res)
//
(*
// HX-2014-09-09:
// [name] is assumed to
// have been declared externally
//
val () = the_extvarlst_add (hid0)
*)
//
in
  primdec_extvar (loc0, name, inss)
end // end of [hiextvar_ccomp]

(* ****** ****** *)

implement
hiextcode_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val () = the_extcodelst_add (hid0)
//
in
  primdec_none (loc0)
end // end of [hiextcode_ccomp]

(* ****** ****** *)

implement
hidatdecs_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val-~HIDdatdecs(knd, s2cs) = hidecl_node_view(hid0.hidecl_node())
val isprf = test_prfkind (knd)
//
in
//
if isprf
  then primdec_none (loc0)
  else primdec_datdecs (loc0, s2cs)
// end of [if]
//
end // end of [hidatdecs_ccomp]

(* ****** ****** *)

implement
hiexndecs_ccomp
  (env, hid0) = let
//
val loc0 = hid0.hidecl_loc()
val-~HIDexndecs(d2cs) = hidecl_node_view(hid0.hidecl_node())
//
val () = the_exndeclst_add (hid0)
//
in
  primdec_exndecs (loc0, d2cs)
end // end of [hiexndecs_ccomp]

(* ****** ****** *)

local

fun
auxinit
(
  env: !ccompenv, lvl0: int
, decarg: s2qualst, hfds: hifundeclst, i: int
) : funlablst = let
in
//
if glist_is_cons(hfds) then let
//
    val hfd = glist_head<hifundec>(hfds)
    val hfds = glist_tail<hifundec>(hfds)
//
    val loc = hfd.hifundec_loc()
    val d2v = hfd.hifundec_var()
//
(*
    val () =
    println! ("auxinit: loc = ", loc)
    val () =
    println! ("auxinit: d2v = ", d2v)
*)
//
    val () =
      $D2E.d2var_set_level(d2v, lvl0)
    // end of [val]
    val opt_hse = d2var_get2_hisexp(d2v)
    val () = assertloc (gopt_is_some(opt_hse)) // HX: [val-Some]
    val hse = gopt_unsome(opt_hse)
    val fcopt = None_vt() // HX: by [hse]
//
    val flab =
      funlab_make_dvar_type(d2v, hse, fcopt)
    // end of [val]
//
// HX: only the first fnx-decl is added!!!
//
    val () =
    (
    if i <= 1 then the_funlablst_add(flab)
    // end of [if]
    ) : void // end of [val]
//
    val tmplev = ccompenv_get_tmplevel(env)
//
    val pmv = (
      if tmplev = 0
        then primval_make_funlab(loc, flab)
        else primval_make_d2vfunlab(loc, d2v, flab)
      // end of [if]
    ) : primval // end of [val]
//
    val ((*void*)) =
      ccompenv_add_vbindmapenvall(env, d2v, pmv)
//
    val istmp = (
      if tmplev > 0
        then true else glist_is_cons(decarg)
      // end of [if]
    ) : bool // end of [val]
    val () = if istmp then funlab_set_tmpknd(flab, 1)
//
    val () = (
      if glist_is_cons(decarg)
        then ccompenv_add_fundec(env, hfd) else ()
      // end of [if]
    ) : void // end of [val]
//
    val i2 = (if i >= 1 then i + 1 else i): int
    val flabs = auxinit (env, lvl0, decarg, hfds, i2)
  in
    glist_cons(flab, flabs)
  end else glist_nil((*void*))
//
end // end of [auxinit]

(* ****** ****** *)

fun
auxmain
(
  env: !ccompenv, decarg: s2qualst
, hfds: hifundeclst, flabs: funlablst, i: int
) : void = let
in
//
if glist_is_cons(hfds) then let
    val hfd = glist_head<hifundec>(hfds)
    val hfds = glist_tail<hifundec>(hfds)
    val loc = hfd.hifundec_loc()
    val d2v = hfd.hifundec_var()
    val imparg = hfd.hifundec_imparg()
    val hde_def = hfd.hifundec_def()
//
// HX-2016-08-05:
// It may be a good idea to do this check earlier!!!
//
    val () =
    case+
    hidexp_node_view(hde_def.hidexp_node())
    of // case+
    | ~HDElam _ => ()
    | v(*non-HDElam*) =>
      {
        val () = hidexp_node_view_free (v)
        val () =
        prerr_errccomp_loc(loc)
        val () = prerr_string
        (
          ": non-lambda function definition is not supported."
        ) (* end of [prerr_string] *)
        val () = prerr_newline ()
        val () = (exitloc(1): void)
      } (* end of [non-HDElam] *)
//
    val-~HDElam
    (
    knd, hips_arg, hde_body
    ) = hidexp_node_view(hde_def.hidexp_node())
//
    val flab = glist_head_exn<funlab>(flabs)
    val flabs = glist_tail_exn<funlab>(flabs)
//
    val () = (
    if i = 0 then
      ccompenv_inc_tailcalenv(env, flab)
    // end of [if]
    ) // end of [val]
//
    val
    istmp = glist_is_cons(decarg)
    val () =
    if istmp then ccompenv_inc_tmplevel(env)
    // end of [val]
//
    val
    tmparg = glist_nil((*s2ess*)) // matching all?
    val
    prolog = glist_sing(instr_funlab (loc, flab))
//
    val fent =
    hidexp_ccomp_funlab_arg_body
    (
      env, flab
    , imparg, tmparg, prolog, loc, hips_arg, hde_body
    ) // end of [fcall] // end of [val]
//
    val () =
      if istmp then ccompenv_dec_tmplevel(env)
    val () =
      if i = 0 then ccompenv_dec_tailcalenv(env)
//
    val () =
      if i > 0 then
        tmpvar_inc_tailcal(funent_get_tmpret(fent))
      // end of [if]
    // end of [val]
//
    val () =
      hifundec_set_funlabopt(hfd, gopt_some(flab))
    // end of [val]
    val () = funlab_set_funent(flab, gopt_some(fent))
//
    val i2 = (if i >= 1 then i + 1 else i): int
//
  in
    auxmain(env, decarg, hfds, flabs, i2)
  end // end of [let] // end of [list_cons]
else () // HX: [flabs] is [list_nil] too
//
end // end of [auxmain]

in (* in of [local] *)

implement
hifundeclst_ccomp
(
  env, lvl0, knd, decarg, hfds
) = let
//
val
tlcalopt =
  $GLOBAL.the_CCOMPATS_tlcalopt_get()
val isfnx =
(
if tlcalopt > 0
  then funkind_is_mutailrec(knd) else false
) : bool // end of [val]
//
val i0 = (if isfnx then 1 else 0): int
//
val flabs =
  auxinit (env, lvl0, decarg, hfds, i0)
//
val () =
if isfnx then let
  val flabs = glist_listize<funlab>(flabs) // HX: [list_copy]
in
  ccompenv_inc_tailcalenv_fnx (env, flabs)
end // end of [if] // end of [val]
//
val () = auxmain (env, decarg, hfds, flabs, i0)
//
val () =
if isfnx then let
  val fl0 = glist_head_exn<funlab>(flabs)
  val opt_fent0 = funlab_get_funent (fl0)
  val () = assertloc (gopt_is_some(opt_fent0)) // HX: [val-Some]
  val fent0 = gopt_unsome(opt_fent0)
  val () = funent_set_fnxlablst (fent0, flabs)
in
  ccompenv_dec_tailcalenv (env)  
end // end of [if]
//
in
  // nothing
end // end of [hifundeclst_ccomp]

end // end of [local]

(* ****** ****** *)

local

fun aux
(
  env: !ccompenv
, res: !instrseq
, lvl0: int, knd: valkind, hvd: hivaldec
) : void = let
  val loc = hvd.hivaldec_loc()
  val hde_def = hvd.hivaldec_def()
  val pmv_def =
    hidexp_ccompv(env, res, hde_def) // non-lvalue
//
(*
  val () =
    println!
    (
      "hivaldeclst_ccomp: aux: pmv_def = ", pmv_def
    ) (* println! *)
*)
//
  val hip = hvd.hivaldec_pat()
  val fail = (
    case+ knd of
    | VK_val_pos() => patckont_PTCKNTnone() | _ => patckont_PTCKNTcaseof_fail(loc)
  ) : patckont // end of [val]
  val () = hipatck_ccomp(env, res, fail, hip, pmv_def)
  val () = himatch2_ccomp(env, res, lvl0, hip, pmv_def)
in
  // nothing
end // end of [aux]

fun auxlst
(
  env: !ccompenv
, res: !instrseq
, lvl0: int, knd: valkind, hvds: hivaldeclst
) : void = let
in
//
if glist_is_cons(hvds) then let
    val () = aux (env, res, lvl0, knd, glist_head<hivaldec>(hvds))
    val () = auxlst (env, res, lvl0, knd, glist_tail<hivaldec>(hvds))
  in
    // nothing
  end // end of [list_cons]
else ((*void*)) // end of [list_nil]
//
end // end of [auxlst]

in (* in of [local] *)

implement
hivaldeclst_ccomp
(
  env, lvl0, knd, hvds
) = let
//
val res =
  instrseq_make_nil((*void*))
val () =
  auxlst(env, res, lvl0, knd, hvds)
//
in
  instrseq_get_free(res)
end // end of [hivaldeclst_ccomp]

end // end of [local]

(* ****** ****** *)

local

fun
auxinit
(
  env: !ccompenv
, res: !instrseq
, lvl0: int
, hvds: hivaldeclst
) : glist(tmpvar) = let
in
//
if glist_is_cons(hvds) then let
    val hvd = glist_head<hivaldec>(hvds)
    val hvds = glist_tail<hivaldec>(hvds)
    val hip = hvd.hivaldec_pat()
    val loc = hip.hipat_loc()
    val hse = hip.hipat_type()
    val tmp = tmpvar_make(loc, hse)
    val () = instrseq_add_tmpdec(res, loc, tmp)
    val pmv = primval_tmp(loc, hse, tmp)
    val () = himatch2_ccomp(env, res, lvl0, hip, pmv)
    val tmps = auxinit(env, res, lvl0, hvds)
  in
    glist_cons (tmp, tmps)
  end else glist_nil((*void*)) // end of [list_cons]
//
end // end of [auxinit]

fun
auxmain
(
  env: !ccompenv
, res: !instrseq
, hvds: hivaldeclst
, tmps: glist(tmpvar)
) : void = let
in
//
if glist_is_cons(hvds) then let
    val hvd = glist_head<hivaldec>(hvds)
    val hvds = glist_tail<hivaldec>(hvds)
    val hde_def = hvd.hivaldec_def()
    val tmp = glist_head_exn<tmpvar>(tmps)
    val tmps = glist_tail_exn<tmpvar>(tmps)
    val ((*void*)) =
      hidexp_ccomp_ret(env, res, tmp, hde_def)
  in
    auxmain(env, res, hvds, tmps)
  end else () // end of [list_cons]
//
end // end of [auxmain]

in (* in of [local] *)

implement
hivaldeclst_ccomp_rec
  (env, lvl0, knd, hvds) = let
//
val res =
  instrseq_make_nil((*void*))
val tmps =
  auxinit(env, res, lvl0, hvds)
val ((*void*)) =
  auxmain (env, res, hvds, tmps)
//
in
  instrseq_get_free (res)
end // end of [hivaldeclst_ccomp_rec]

end // end of [local]

(* ****** ****** *)

local

fun aux
(
  env: !ccompenv
, res: !instrseq
, lvl0: int, hvd: hivardec
) : void = let
//
val loc = hvd.hivardec_loc()
val d2v = hvd.hivardec_dvar_ptr()
val d2vw = hvd.hivardec_dvar_view()
val loc_d2v =
  $D2E.d2var_get_loc (d2v)
val ((*void*)) =
  $D2E.d2var_set_level (d2v, lvl0)
val opt_s2at = $D2E.d2var_get_mastype (d2vw)
val () = assertloc (gopt_is_some(opt_s2at)) // HX: [val-Some]
val s2at = gopt_unsome(opt_s2at)
val-~S2Eat (s2e_elt, _) = s2exp_node_view(s2at.s2exp_node())
val hse_elt = s2exp_tyer_shallow (loc_d2v, s2e_elt)
val tmp = tmpvar_make_ref (loc_d2v, hse_elt)
//
val () = instrseq_add_tmpdec (res, loc_d2v, tmp)
//
val () = 
(
case+
gopt_view(hvd.hivardec_init()) of
| ~GOnone() => ()
| ~GOsome(hde) => hidexp_ccomp_ret (env, res, tmp, hde)
) : void // end of [val]
//
val pmv = primval_tmpref (loc, hse_elt, tmp)
val pmv_ref = primval_ptrof (loc, hisexp_typtr, pmv)
val () = ccompenv_add_vbindmapenvall (env, d2v, pmv_ref)
//
in
  // nothing
end // end of [aux]

fun auxlst
(
  env: !ccompenv
, res: !instrseq
, lvl0: int, hvds: hivardeclst
) : void = let
in
//
case+ glist_view(hvds) of
| ~GLcons(hvd, hvds) => let
    val () = aux (env, res, lvl0, hvd)
    val () = auxlst (env, res, lvl0, hvds)
  in
    // nothing
  end // end of [list_cons]
| ~GLnil() => ()
//
end // end of [auxlst]

in (* in of [local] *)

implement
hivardeclst_ccomp
  (env, lvl0, hvds) = let
//
val res = instrseq_make_nil ()
val () = auxlst (env, res, lvl0, hvds)
//
in
  instrseq_get_free (res)
end // end of [hivardeclst_ccomp]

end // end of [local]

(* ****** ****** *)

local

fun auxlam
(
  env: !ccompenv
, loc0: location
, d2c: d2cst, imparg: s2varlst, tmparg: s2explstlst
, hde_fun: hidexp
) : funlab = let
//
val hse_fun = hde_fun.hidexp_type()
val fcopt = d2cst_get2_funclo (d2c)
//
val flab =
  funlab_make_dcst_type (d2c, hse_fun, fcopt)
val () = the_funlablst_add (flab)
//
in
  auxlam2 (env, loc0, flab, imparg, tmparg, hde_fun)
end (* end of [auxlam2] *)

and auxlam2
(
  env: !ccompenv
, loc0: location
, flab: funlab, imparg: s2varlst, tmparg: s2explstlst
, hde_fun: hidexp
) : funlab = flab where
{
//
val () =
  ccompenv_inc_tailcalenv (env, flab)
//
val tmplev = ccompenv_get_tmplevel (env)
val () =
(
  if tmplev > 0 then funlab_set_tmpknd (flab, 1)
) (* end of [val] *)
//
val pmv_lam = primval_make_funlab (loc0, flab)
//
val loc_fun = hde_fun.hidexp_loc()
//
val-~HDElam(knd, hips_arg, hde_body) = hidexp_node_view(hde_fun.hidexp_node())
//
val fent = let
  val ins =
    instr_funlab (loc0, flab)
  // end of [val]
  val prolog = glist_sing(ins)
in
  hidexp_ccomp_funlab_arg_body
    (env, flab, imparg, tmparg, prolog, loc_fun, hips_arg, hde_body)
  // end of [hidexp_ccomp_funlab_arg_body]
end // end of [val]
//
val () =
  funlab_set_funent (flab, gopt_some(fent))
//
val () = ccompenv_dec_tailcalenv (env)
//
(*
val () = println! ("hiimpdec_ccomp: auxlam2: fent = ", fent)
*)
//
} (* end of [auxlam2] *)

(* ****** ****** *)

fun auxfix
(
  env: !ccompenv
, loc0: location
, d2c0: d2cst
, imparg: s2varlst
, tmparg: s2explstlst
, hde_fix: hidexp
) : funlab = let
//
val-~HDEfix(
  knd, f_d2v, hde_def
) = hidexp_node_view(hde_fix.hidexp_node())
//
val
fcopt =
d2cst_get2_funclo(d2c0)
val
hse_def = hde_def.hidexp_type()
//
val flab =
funlab_make_dcst_type
(
  d2c0, hse_def, fcopt
) (* end of [val] *)
//
val pmv0 =
  primval_make_funlab(loc0, flab)
//
val ((*added*)) = the_funlablst_add(flab)
//
// HX-2013-11-01:
// this seems to be correct as [f_d2v] is a fix-var
//
val ((*added*)) =
  ccompenv_add_vbindmapenvall(env, f_d2v, pmv0)
//
in
  auxlam2(env, loc0, flab, imparg, tmparg, hde_def)
end // end of [auxfix]

(* ****** ****** *)

fun auxmain
(
  env: !ccompenv
, loc0: location
, d2c: d2cst
, imparg: s2varlst
, tmparg: s2explstlst
, hde_def: hidexp
) : funlab = let
//
val
hse_def =
hde_def.hidexp_type()
//
in
//
case+
hidexp_node_view(hde_def.hidexp_node()) of // case+
//
| ~HDEcst(d2c) => let
    val () = the_dyncstlst_add (d2c)
    val fcopt = d2cst_get2_funclo (d2c)
  in
    funlab_make_dcst_type(d2c, hse_def, fcopt)
  end // end of [HDEcst]
| ~HDEvar(d2v) => let
    val fcopt = d2var_get2_funclo(d2v)
  in
    funlab_make_dvar_type(d2v, hse_def, fcopt)
  end // end of [HDEvar]
//
| ~HDEtmpcst(d2c, t2mas) => let
    val fcopt = d2cst_get2_funclo (d2c)
  in
    funlab_make_tmpcst_type(d2c, t2mas, hse_def, fcopt)
  end // end of [HDEtmpcst]
//
| ~HDElam _ =>
  (
    auxlam (env, loc0, d2c, imparg, tmparg, hde_def)
  ) (* end of [HDElam] *)
//
| ~HDEfix _ =>
  (
    auxfix (env, loc0, d2c, imparg, tmparg, hde_def)
  ) (* end of [HDEfix] *)
//
| v(*rest-of-hidecl*) =>
  let
    val () = hidexp_node_view_free (v)
    val () =
    println!
      ("hiimpdec_ccomp: auxmain: hde_def = ", hde_def)
    // end of [val]
  in
    exitloc(1) // exit with location information reported
  end (* end of [rest-of-hidecl] *)
//
end (* end of [auxmain] *)

in (* in of [local] *)

implement
hiimpdec_ccomp
(
  env, lvl0, imp, knd
) = let
//
val d2c = imp.hiimpdec_cst()
val dck = $D2E.d2cst_get_kind(d2c)
//
(*
val () =
  println! ("hiimpdec_ccomp: d2c = ", d2c)
*)
//
in
//
(*
if dcstkind_is_castfn dck then () else
*)
if dcstkind_is_fun(dck) then
  let
    val loc0 = imp.hiimpdec_loc()
    val imparg = imp.hiimpdec_imparg()
    val tmparg = imp.hiimpdec_tmparg()
    val hde_def = imp.hiimpdec_def()
//
(*
    val knd = imp.hiimpdec_knd
*)
    val istmp = glist_is_cons (tmparg)
//
(*
    val () =
      println! ("hiimpdec_ccomp: knd = ", knd)
    // end of [val]
*)
//
    val () =
      if istmp then ccompenv_inc_tmplevel(env)
    // end of [val]
    val flab =
      auxmain(env, loc0, d2c, imparg, tmparg, hde_def)
    // end of [val]
    val () =
      if istmp then ccompenv_dec_tmplevel(env)
    // end of [val]
//
    val () = (
      if knd = 0 then
        (if istmp then ccompenv_add_impdec(env, imp))
      // end of [if]
    ) (* end of [val] *)
//
    val opt = gopt_some(flab)
    val ((*void*)) = hiimpdec_set_funlabopt(imp, opt)
    val ((*void*)) =
    (
      if not(istmp) then
        $D2E.d2cst_set_funlab(d2c, $UN.cast{dynexp2_funlabopt}(opt))
      // end of [if]
    ) (* end of [val] *)
//
  in
    // nothing
  end // end of [if]
//
else let // non-fun
    val res = instrseq_make_nil()
    val pmv = hidexp_ccomp(env, res, imp.hiimpdec_def())
    val () = instrseq_add_dcstdef(res, imp.hiimpdec_loc(), d2c, pmv)
    val inss = instrseq_get_free(res)
    val () = hiimpdec_set_instrlstopt(imp, gopt_some(inss))
  in
    // nothing
  end // end of [non-fun]
//
end // end of [hiimpdec_ccomp]

end // end of [local]

(* ****** ****** *)

implement
hiimpdec_ccomp_if
  (env, lvl0, imp, knd) = let
//
val opt =
  hiimpdec_get_funlabopt (imp)
//
in
//
case+ gopt_view(opt) of
| ~GOsome(_) => ((*void*))
| ~GOnone() => hiimpdec_ccomp(env, lvl0, imp, knd)
//
end // end of [hiimpdec_ccomp_if]

(* ****** ****** *)

(* end of [pats_ccomp_decl.dats] *)
