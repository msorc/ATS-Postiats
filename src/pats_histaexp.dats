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
// HX-2026-10: no GC (ATS2 port of src/pats_histaexp.dats, see PORTING.md "Typerase trees (histaexp)")
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)
//
// HX-2026-10: not ported yet at the time of this file (the boundary of
// the tests is test/hstub/): the references to the constants of the prelude
//
staload S2C = "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"

(* ****** ****** *)
//
// HX-2026-10: the node/record constructors are generated (pats_histaexp_gen_dats.hats)
//
#include "./pats_histaexp_gen_dats.hats"
//
(* ****** ****** *)
//
#define ATSTYPE_BOXED "atstype_boxed"
#define ATSTYPE_UNBOXED "atstype_unboxed"
#define ATSTYPE_UNDEFINED "atstype_undefined"
//
(* ****** ****** *)
//
val
HITNAM_BOXED =
  hitnam_new(1(*ptr*), 1(*fin*), ATSTYPE_BOXED)
//
val
HITNAM_UNBOXED =
  hitnam_new(0(*non*), 1(*fin*), ATSTYPE_UNBOXED)
//
val
HITNAM_UNDEFINED =
  hitnam_new(0(*non*), 1(*fin*), ATSTYPE_UNDEFINED)
//
(* ****** ****** *)
//
val
HITNAM_FUNPTR =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_funptr")
val
HITNAM_CLOPTR =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_cloptr")
val
HITNAM_CLOTYP =
  hitnam_new(0(*non*), 1(*fin*), "atstype_clotyp")
//
val
HITNAM_ARRPTR =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_arrptr")
//
val
HITNAM_DATCONPTR =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_datconptr")
val
HITNAM_DATCONTYP =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_datcontyp")
//
val
HITNAM_EXNCONPTR =
  hitnam_new(1(*ptr*), 1(*fin*), "atstype_exnconptr")
//
(* ****** ****** *)
//
#define POSTIATS_TYABS "postiats_tyabs"
#define POSTIATS_TYPTR "postiats_typtr"
//
val
HITNAM_TYABS =
  hitnam_new(0(*non*), 0(*fin*), POSTIATS_TYABS)
val
HITNAM_TYPTR =
  hitnam_new(1(*ptr*), 1(*fin*), POSTIATS_TYPTR)
//
val
HITNAM_TYAPP =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyapp")
val
HITNAM_TYCLO =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyclo")
//
val
HITNAM_TYARR =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyarr")
val
HITNAM_TYREC =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyrec")
val
HITNAM_TYRECSIN =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyrecsin")
val
HITNAM_TYSUM =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tysum")
//
val
HITNAM_TYVAR =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyvar")
val
HITNAM_TYVARET =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_tyvaret")
//
val
HITNAM_VARARG =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_vararg")
//
val
HITNAM_S2EXP =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_s2exp")
val HITNAM_S2ZEXP =
  hitnam_new(0(*non*), 0(*tmp*), "postiats_s2zexp")
//
(* ****** ****** *)

implement
hisexp_get_boxknd
  (hse0) = let
  val nd = hse0.hisexp_node()
in
//
case+
hisexp_node_view(nd) of
//
| ~HSEtyrec(knd, _) =>
  if tyreckind_is_boxed(knd) then 1 else 0
//
| ~HSEtysum(d2c, _) => 0 // HX: it is not [1]!
//
| v (*non-rec-sum*) => (hisexp_node_view_free(v); ~1) // HX: meaningless
//
end // end of [hisexp_get_boxknd]

implement
hisexp_get_extknd
  (hse0) = let
  val nd = hse0.hisexp_node()
in
//
case+
hisexp_node_view(nd) of
//
| ~HSEtyrec (knd, _) =>
  if tyreckind_is_fltext(knd) then 1 else 0
//
| v (*non-HSEtyrec*) => (hisexp_node_view_free(v); ~1) // HX: meaningless
//
end // end of [hisexp_get_extknd]

(* ****** ****** *)

implement
hisexp_is_boxed(hse0) = let
  val hit = hse0.hisexp_name() in hit.hitnam_ptr() > 0
end // end of [hisexp_is_boxed]

(* ****** ****** *)

fn
s2cst_is_void
  (s2c: s2cst): bool =
  $S2C.s2cstref_equ_cst ($S2C.the_atsvoid_t0ype, s2c)
//
fn
s2exp_is_void
  (s2e0: s2exp): bool =
    $S2C.s2cstref_equ_exp ($S2C.the_atsvoid_t0ype, s2e0)
//
implement
hisexp_is_void
  (hse0) = let
  val nd = hse0.hisexp_node()
in
//
case+
hisexp_node_view(nd)
of // case+
//
| ~HSEcst(s2c) => s2cst_is_void(s2c)
//
| ~HSEtyrecsin
    (lhse) => let
    val hse = lhse.labhisexp_elt() in hisexp_is_void(hse)
  end
  // end of [HSEtyrecsin]
//
| ~HSEs2exp(s2e) => s2exp_is_void(s2e)
//
| v (*rest-of-hisexp*) => (hisexp_node_view_free(v); false)
//
end // end of [hisexp_is_void]

(* ****** ****** *)

implement
hisexp_fun_is_void
  (hse_fun) = let
  val nd = hse_fun.hisexp_node()
in
//
case+
hisexp_node_view(nd) of
//
| ~HSEfun
  (
    fc, _(*arg*), hse_res
  ) => hisexp_is_void(hse_res)
| v (*non-HSEfun*) => (hisexp_node_view_free(v); false)
//
end // end of [hisexp_fun_is_void]

(* ****** ****** *)

implement
hisexp_is_noret
  (hse0) = let
  val nd = hse0.hisexp_node()
in
//
case+
hisexp_node_view(nd) of
//
| ~HSEcst(s2c) =>
    $S2C.s2cstref_equ_cst($S2C.the_atsvoid_t0ype, s2c)
  // end of [HSEcst]
| ~HSEtyvar (s2v) => true
//
| ~HSEtyrecsin(lhse) =>
  let val hse = lhse.labhisexp_elt() in hisexp_is_noret(hse) end
//
| v(*rest-of-hisexp*) => (hisexp_node_view_free(v); false)
//
end // end of [hisexp_is_noret]

implement
hisexp_fun_is_noret
  (hse_fun) = let
  val nd = hse_fun.hisexp_node()
in
//
case+
hisexp_node_view(nd) of
| ~HSEfun (
    fc, _(*arg*), hse_res
  ) => hisexp_is_noret (hse_res)
| v(*non-HSEfun*) => (hisexp_node_view_free(v); false)
//
end // end of [hisexp_fun_is_void]

(* ****** ****** *)

implement
hisexp_is_tyarr
  (hse0) = hisexp_node_is_HSEtyarr(hse0.hisexp_node())
// end of [hisexp_is_tyarr]

implement
hisexp_is_tyrecsin
  (hse0) = hisexp_node_is_HSEtyrecsin(hse0.hisexp_node())
// end of [hisexp_is_tyrecsin]

(* ****** ****** *)

implement
labhisexp_get_elt (lhse) = lhse.labhisexp_elt()
// end of [labhisexp_get_elt]

(* ****** ****** *)

implement
hisexp_tybox =
  hisexp_new(HITNAM_BOXED, hisexp_node_HSEtybox())
// end of [hisexp_tybox]

implement
hisexp_typtr =
  hisexp_new(HITNAM_TYPTR, hisexp_node_HSEtybox())
// end of [hisexp_typtr]

(* ****** ****** *)

val ATSTYCLO_TOP =
  $SYM.symbol_make_string ("atstyclo_top")

implement
hisexp_clotyp = hisexp_new
(
  HITNAM_TYCLO, hisexp_node_HSEtyabs (ATSTYCLO_TOP)
) (* [hisexp_clotyp] *)

(* ****** ****** *)

implement
hisexp_funptr =
  hisexp_new(HITNAM_FUNPTR, hisexp_node_HSEtybox())
implement
hisexp_cloptr =
  hisexp_new(HITNAM_CLOPTR, hisexp_node_HSEtybox())

implement
hisexp_arrptr =
  hisexp_new(HITNAM_ARRPTR, hisexp_node_HSEtybox())
// end of [hisexp_arrptr]

(* ****** ****** *)

implement
hisexp_datconptr =
  hisexp_new(HITNAM_DATCONPTR, hisexp_node_HSEtybox())
// end of [hisexp_datconptr]
implement
hisexp_datcontyp =
  hisexp_new(HITNAM_DATCONTYP, hisexp_node_HSEtybox())
// end of [hisexp_datcontyp]

(* ****** ****** *)

implement
hisexp_exnconptr =
  hisexp_new(HITNAM_EXNCONPTR, hisexp_node_HSEtybox())
// end of [hisexp_exnconptr]

(* ****** ****** *)
//
val
ATSTYPE_UNDEFINED_SYM =
  $SYM.symbol_make_string(ATSTYPE_UNDEFINED)
//
implement
hisexp_undefined =
  hisexp_new(HITNAM_UNDEFINED, hisexp_node_HSEtyabs (ATSTYPE_UNDEFINED_SYM))
// end of [hisexp_undefined]
//
(* ****** ****** *)

implement
hisexp_int_t0ype () = let
//
val s2c =
  $S2C.s2cstref_get_cst ($S2C.the_atstype_int)
//
in
  hisexp_new(HITNAM_TYABS, hisexp_node_HSEcst (s2c))
end // end of [hisexp_int_t0ype]

(* ****** ****** *)

implement
hisexp_bool_t0ype () = let
//
val s2c =
  $S2C.s2cstref_get_cst ($S2C.the_atstype_bool)
//
in
  hisexp_new(HITNAM_TYABS, hisexp_node_HSEcst (s2c))
end // end of [hisexp_bool_t0ype]

(* ****** ****** *)

implement
hisexp_size_t0ype () = let
//
val s2c =
  $S2C.s2cstref_get_cst ($S2C.the_atstype_size)
//
in
  hisexp_new(HITNAM_TYABS, hisexp_node_HSEcst (s2c))
end // end of [hisexp_size_t0ype]

(* ****** ****** *)

implement
hisexp_void_t0ype () = let
//
val s2c =
  $S2C.s2cstref_get_cst ($S2C.the_atsvoid_t0ype)
//
in
  hisexp_new(HITNAM_TYABS, hisexp_node_HSEcst (s2c))
end // end of [hisexp_void_t0ype]

(* ****** ****** *)

fn
hisexp_make_node
(
  hit: hitnam, node: hisexp_node
) : hisexp = hisexp_new(hit, node)
// end of [hisexp_make_node]

(* ****** ****** *)
//
implement
hisexp_tyabs(sym) =
hisexp_make_node(HITNAM_TYABS, hisexp_node_HSEtyabs(sym))
//
(* ****** ****** *)

implement
hisexp_make_srt
  (s2t) = let
//
val isbox = s2rt_is_boxed_fun (s2t)
//
in
//
if
isbox
then hisexp_tybox
else let
val
sym = 
$SYM.symbol_make_string(ATSTYPE_UNBOXED)
//
in
  hisexp_tyabs (sym)
end // end of [else]
//
end // end of [hisexp_make_srt]

implement
hisexp_make_srtsym
  (s2t, sym) = let
//
val isbox = s2rt_is_boxed_fun (s2t)
//
in
  if isbox
    then hisexp_tybox else hisexp_tyabs (sym)
  // end of [if]
end // end of [hisexp_make_srtsym]

(* ****** ****** *)
//
implement
hisexp_cst (s2c) =
  hisexp_make_node (HITNAM_TYABS, hisexp_node_HSEcst (s2c))
//
(* ****** ****** *)

implement
hisexp_fun
(
  funclo, arg, res
) = let
//
val node = hisexp_node_HSEfun(funclo, arg, res)
//
in
//
case+ funclo of
| FUNCLOfun() =>
    hisexp_make_node(HITNAM_FUNPTR, node)
| FUNCLOclo0() =>
    hisexp_make_node(HITNAM_CLOTYP, node)
| FUNCLOcloptr() =>
    hisexp_make_node(HITNAM_CLOPTR, node)
| FUNCLOcloref() =>
    hisexp_make_node(HITNAM_CLOPTR, node)
//
end // end of [hisexp_fun]

(* ****** ****** *)

implement
hisexp_app
  (_fun, _arg) =
  hisexp_make_node (HITNAM_TYAPP, hisexp_node_HSEapp (_fun, _arg))
// end of [hisexp_app]

(* ****** ****** *)

implement
hisexp_extype
  (name, s2ess) = let
  val hit = hitnam_new(0(*non*), 1(*fin*), name)
in
  hisexp_make_node (hit, hisexp_node_HSEextype (name, s2ess))
end // end of [hisexp_extype]

(* ****** ****** *)

implement
hisexp_refarg
  (knd, arg) = let
//
val hitnam =
  hitnam_new (knd, 0(*fin*), "postiats_refarg")
//
in
  hisexp_new(hitnam, hisexp_node_HSErefarg (knd, arg))
end // end of [hisexp_refarg]

(* ****** ****** *)

implement
hisexp_tyarr (hse, dim) =
  hisexp_make_node (HITNAM_TYARR, hisexp_node_HSEtyarr (hse, dim))
// end of [hisexp_tyarr]

(* ****** ****** *)

implement
hisexp_tyrec (knd, lhses) =
  hisexp_make_node (HITNAM_TYREC, hisexp_node_HSEtyrec (knd, lhses))
// end of [hisexp_tyrec]

implement
hisexp_tyrecsin (lhse) =
  hisexp_make_node (HITNAM_TYRECSIN, hisexp_node_HSEtyrecsin (lhse))
// end of [hisexp_tyrecsin]

implement
hisexp_tyrec2
  (knd, lhses) = let
  val isflt = tyreckind_is_flted (knd)
in
//
if isflt then let
  // HX: the list has exactly one element
  val issin =
    (if glist_is_cons (lhses) then glist_is_nil (glist_tail<labhisexp> (lhses)) else false): bool
in
//
if issin then
  hisexp_tyrecsin (glist_head<labhisexp> (lhses))
else
  hisexp_tyrec (knd, lhses)
// end of [if]
//
end else
  hisexp_tyrec (knd, lhses)
// end of [if]
//
end // end of [hisexp_tyrec2]

(* ****** ****** *)

implement
hisexp_tysum (d2c, lhses) =
  hisexp_make_node (HITNAM_TYSUM, hisexp_node_HSEtysum (d2c, lhses))
// end of [hisexp_tysum]

(* ****** ****** *)

implement
hisexp_tyvar (s2v) = let
  val s2t = s2var_get_srt (s2v)
  val isbox = s2rt_is_boxed (s2t)
  val hit = (
    if isbox then HITNAM_BOXED else HITNAM_TYVAR
  ) : hitnam // end of [val]
in
  hisexp_make_node (hit, hisexp_node_HSEtyvar (s2v))
end // end of [hisexp_tyvar]

(* ****** ****** *)

implement
hisexp_tyclo (flab) =
  hisexp_make_node (HITNAM_TYCLO, hisexp_node_HSEtyclo (flab))
// end of [hisexp_tyclo]

(* ****** ****** *)

implement
hisexp_vararg (s2e) =
  hisexp_new(HITNAM_VARARG, hisexp_node_HSEvararg (s2e))
// end of [hisexp_vararg]

(* ****** ****** *)

implement
hisexp_s2exp (s2e) =
  hisexp_make_node (HITNAM_S2EXP, hisexp_node_HSEs2exp (s2e))
// end of [hisexp_s2exp]

implement
hisexp_s2zexp (s2ze) =
  hisexp_make_node (HITNAM_S2ZEXP, hisexp_node_HSEs2zexp (s2ze))
// end of [hisexp_s2zexp]

(* ****** ****** *)

fun
aux (
  sub: !stasub, hse0: hisexp, flag: &int
) : hisexp = let
  val nd = hse0.hisexp_node()
in
//
case+
  hisexp_node_view(nd)
of // of [case]
//
| ~HSEcst _ => hse0
//
| ~HSEtyabs _ => hse0
| ~HSEtybox () => hse0
//
| ~HSEapp (
    hse_fun, hses_arg
  ) => let
    val f0 = flag
    val hse_fun = aux (sub, hse_fun, flag)
    val hses_arg = auxlst (sub, hses_arg, flag)
  in
    if flag > f0
      then hisexp_app (hse_fun, hses_arg) else hse0
    // end of [if]
  end // end of [HSEapp]
//
| ~HSEextype (name, hsess) => let
    val f0 = flag
    val hsess = auxlstlst (sub, hsess, flag)
  in
    if flag > f0
      then hisexp_extype (name, hsess) else hse0
    // end of [if]
  end // end of [HSEextype]
//
| ~HSEfun (
    fc, hses_arg, hse_res
  ) => let
    val f0 = flag
    val hse_res = aux (sub, hse_res, flag)
    val hses_arg = auxlst (sub, hses_arg, flag)
  in
    if flag > f0
      then hisexp_fun (fc, hses_arg, hse_res) else hse0
    // end of [if]
  end // end of [HSEfun]
//
| ~HSErefarg
    (knd, hse) => let
    val f0 = flag
    val hse = aux (sub, hse, flag)
  in
    if flag > f0
      then hisexp_refarg (knd, hse) else hse0
    // end of [if]
  end // end of [HSErefarg]
//
| ~HSEtyarr
    (hse_elt, s2es) => let
    val f0 = flag
    val s2es = s2explst_subst_flag (sub, s2es, flag)
    val hse_elt = aux (sub, hse_elt, flag)
  in
    if flag > f0
      then hisexp_tyarr (hse_elt, s2es) else hse0
    // end of [if]
  end // end of [HSEtyarr]
| ~HSEtyrec (knd, lhses) => let
    val f0 = flag
    val lhses = auxlablst (sub, lhses, flag)
  in
    if flag > f0 then hisexp_tyrec (knd, lhses) else hse0
  end // end of [HSEtyrec]
| ~HSEtyrecsin (lhse) => let
    val f0 = flag
    val lhse = auxlab (sub, lhse, flag)
  in
    if flag > f0 then hisexp_tyrecsin (lhse) else hse0
  end // end of [HSEtyrecsin]
| ~HSEtysum (d2c, lhses) => let
    val f0 = flag
    val lhses = auxlablst (sub, lhses, flag)
  in
    if flag > f0 then hisexp_tysum (d2c, lhses) else hse0
  end // end of [HSEtysum]
//
| ~HSEtyvar (s2v) => let
    val ans = stasub_find (sub, s2v)
  in
    case+ ans of
    | ~Some_vt (s2e) => let
        val () = flag := flag + 1 in hisexp_s2exp (s2e)
      end // end of [Some_vt]
    | ~None_vt () => hse0
  end // end of [HSEtyvar]
//
| ~HSEtyclo (flab) => hse0
//
| ~HSEvararg (s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then hisexp_vararg (s2e) else hse0
  end // end of [HSEvararg]
//
| ~HSEs2exp (s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then hisexp_s2exp (s2e) else hse0
  end // end of [HSEs2exp]
//
| ~HSEs2zexp (s2ze) => let
    val f0 = flag
    val s2ze = s2zexp_subst_flag (sub, s2ze, flag)
  in
    if flag > f0 then hisexp_s2zexp (s2ze) else hse0
  end // end of [HSEs2zexp]
//
end // end of [aux]

and auxlab (
  sub: !stasub, lhse0: labhisexp, flag: &int
) : labhisexp = let
  val f0 = flag
  val lab = lhse0.labhisexp_lab()
  val opt = lhse0.labhisexp_opt()
  val hse = aux (sub, lhse0.labhisexp_elt(), flag)
in
  if flag > f0 then labhisexp_new (lab, opt, hse) else lhse0
end // end of [auxlab]

and auxlst (
  sub: !stasub, hses0: hisexplst, flag: &int
) : hisexplst = let
in
//
if glist_is_cons (hses0) then let
    val f0 = flag
    val hse = aux (sub, glist_head<hisexp> (hses0), flag)
    val hses = auxlst (sub, glist_tail<hisexp> (hses0), flag)
  in
    if flag > f0 then glist_cons (hse, hses) else hses0
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [auxlst]

and auxlablst (
  sub: !stasub, lhses0: labhisexplst, flag: &int
) : labhisexplst = let
in
//
if glist_is_cons (lhses0) then let
    val f0 = flag
    val lhse = auxlab (sub, glist_head<labhisexp> (lhses0), flag)
    val lhses = auxlablst (sub, glist_tail<labhisexp> (lhses0), flag)
  in
    if flag > f0 then glist_cons (lhse, lhses) else lhses0
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [auxlablst]

and auxlstlst (
  sub: !stasub, hsess0: hisexplstlst, flag: &int
) : hisexplstlst = let
in
//
if glist_is_cons (hsess0) then let
    val f0 = flag
    val hses = auxlst (sub, glist_head<hisexplst> (hsess0), flag)
    val hsess = auxlstlst (sub, glist_tail<hisexplst> (hsess0), flag)
  in
    if flag > f0 then glist_cons (hses, hsess) else hsess0
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [auxlstlst]

implement
hisexp_subst
  (sub, hse0) = let
  var flag: int = 0 in aux (sub, hse0, flag)
end // end of [hisexp_subst]

(* ****** ****** *)

(* end of [pats_histaexp.dats] *)
