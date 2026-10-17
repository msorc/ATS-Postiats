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
// Start Time: September, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_typerase_dynexp.dats, see PORTING.md, "Type erasure (typerase)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

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
prerr_FILENAME<> () = prerr "pats_typerase_dynexp"
//
(* ****** ****** *)

staload
LAB = "./pats_label.sats"

(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location
overload
print with $LOC.print_location
//
(* ****** ****** *)
//
staload
SYM = "./pats_symbol.sats"
overload
= with $SYM.eq_symbol_symbol
//
(* ****** ****** *)
//
staload
SYN = "./pats_syntax.sats"
//
(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_stacst2.sats"

(* ****** ****** *)

staload
S2UT = "./pats_staexp2_util.sats"

(* ****** ****** *)

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

implement
labhipatlst_get_type
  (lxs) = let
in
//
if glist_is_cons (lxs) then let
  val lx = glist_head<labhipat> (lxs)
  val x = lx.labhipat_elt ()
  val lhse =
    labhisexp_new
    (
      lx.labhipat_lab (), gopt_none ((*name*)), x.hipat_type ()
    ) (* labhisexp_new *)
in
  glist_cons (lhse, labhipatlst_get_type (glist_tail<labhipat> (lxs)))
end else glist_nil ((*void*))
//
end // end of [labhipatlst_get_type]

implement
labhidexplst_get_type
  (lxs) = let
in
//
if glist_is_cons (lxs) then let
  val lx = glist_head<labhidexp> (lxs)
  val x = lx.labhidexp_elt ()
  val lhse =
    labhisexp_new
    (
      lx.labhidexp_lab (), gopt_none ((*name*)), x.hidexp_type ()
    ) (* labhisexp_new *)
in
  glist_cons (lhse, labhidexplst_get_type (glist_tail<labhidexp> (lxs)))
end else glist_nil ((*void*))
//
end // end of [labhidexplst_get_type]

(* ****** ****** *)
//
extern
fun
p3at_tyer_con
(
  loc0: loc_t, hse0: hisexp
, pcknd: pckind, d2c: d2con, npf: int, p3ts: p3atlst
) : hipat // end of [p3at_tyer_con]
//
extern
fun
p3atlst_npf_tyer (npf: int, p3ts: p3atlst): hipatlst
extern
fun
p3atlst_npf_tyer_labize (npf: int, p3ts: p3atlst): labhipatlst
extern
fun
labp3atlst_npf_tyer (npf: int, lp3ts: labp3atlst): labhipatlst
//
(* ****** ****** *)

implement
d2var_tyer (d2v) = let
//
val opt = d2var_get_mastype (d2v)
//
in
//
if gopt_is_some (opt) then let
    val s2e = gopt_unsome (opt)
    val loc = d2var_get_loc (d2v)
    val hse = s2exp_tyer_deep (loc, s2e)
    val ((*void*)) = d2var_set2_hisexp (d2v, gopt_some (hse))
  in
    d2v
  end (* end of [Some] *)
else d2v
//
end // end of [d2var_tyer]

(* ****** ****** *)

implement
d2cst_tyer (d2c) = let
//
val opt = d2cst_get2_hisexp (d2c)
//
in
//
if gopt_is_some (opt) then d2c
else let
    val loc = d2cst_get_loc (d2c)
    val s2e = d2cst_get_type (d2c)
    val hse = s2exp_tyer_deep (loc, s2e)
    val ((*void*)) = d2cst_set2_hisexp (d2c, gopt_some (hse))
  in
    d2c
  end (* end of [None] *)
//
end // end of [d2cst_tyer]

(* ****** ****** *)

implement
p3at_tyer(p3t0) = let
//
val loc0 = p3t0.p3at_loc ()
val s2e0 = p3at_get_type(p3t0)
val hse0 = s2exp_tyer_shallow (loc0, s2e0)
//
in
//
case+
p3at_node_view (p3t0.p3at_node ()) of
//
| ~P3Tany(d2v) => let
    val d2v =
    d2var_tyer(d2v) in hipat_any(loc0, hse0, d2v)
  end (* end of [P3Tvar] *)
| ~P3Tvar(d2v) => let
    val d2v =
    d2var_tyer(d2v) in hipat_var(loc0, hse0, d2v)
  end (* end of [P3Tvar] *)
//
| ~P3Tcon
  (
    pck, d2c, npf, p3ts
  ) => (
  p3at_tyer_con(loc0, hse0, pck, d2c, npf, p3ts)
  ) (* end of [P3Tcon] *)
//
| ~P3Tint(i) => hipat_int(loc0, hse0, i)
| ~P3Tintrep(rep) => hipat_intrep(loc0, hse0, rep)
//
| ~P3Tbool(b) => hipat_bool(loc0, hse0, b)
| ~P3Tchar(c) => hipat_char(loc0, hse0, c)
| ~P3Tstring(str) => hipat_string(loc0, hse0, str)
//
| ~P3Ti0nt(tok) => hipat_i0nt(loc0, hse0, tok)
| ~P3Tf0loat(tok) => hipat_f0loat(loc0, hse0, tok)
//
| ~P3Tempty() => hipat_empty(loc0, hse0)
//
| ~P3Tlst
  (
    lin, s2e_elt, p3ts
  ) => let
    val hse_elt =
      s2exp_tyer_shallow (loc0, s2e_elt)
    val hips = p3atlst_tyer (p3ts)
  in
    hipat_lst (loc0, lin, hse0, hse_elt, hips)
  end // end of [P3Tlst]
//
| ~P3Trec
  (
    knd, npf, pck, lp3ts
  ) => let
    val lhips =
      labp3atlst_npf_tyer(npf, lp3ts)
    // end of [val]
    val lhses = labhipatlst_get_type(lhips)
    val recknd =
    (
      if knd > 0
        then tyreckind_TYRECKINDbox() else tyreckind_TYRECKINDflt0()
      // end of [if]
    ) : tyreckind // end of [val]
    val hse_rec = hisexp_tyrec2(recknd, lhses)
  in
    hipat_rec2(loc0, hse0, knd, pck, lhips, hse_rec)
  end // end of [P3Trec]
//
| ~P3Trefas
    (d2v, p3t_as) => let
    val d2v = d2var_tyer (d2v)
    val hip_as = p3at_tyer (p3t_as)
  in
    hipat_refas(loc0, hse0, d2v, hip_as)
  end // end of [P3Trefas]
//
| ~P3Texist
    (s2vs, p3t_scoop) => p3at_tyer(p3t_scoop)
//
| ~P3Tann
    (p3t, s2e_ann) => let
    val hip = p3at_tyer(p3t)
    val hse_ann = s2exp_tyer_shallow(loc0, s2e_ann)
  in
    hipat_ann(loc0, hse0, hip, hse_ann)
  end // end of [P3Tann]
//
| v (* rest-of-p3at *) =>
    exitloc(1) where
  {
    val () = p3at_node_view_free (v)
    val () = println! ("p3at_tyer: loc0 = ", loc0)
    val () = println! ("p3at_tyer: p3t0 = ", p3t0)
  } // end of [rest-of-p3at]
//
end // endof [p3at_tyer]

(* ****** ****** *)

fun
auxerr_if
(p3t: p3at): void = let
//
val
isful = p3at_is_full(p3t)
//
in
//
if
not(isful)
then let
//
val () = prerr_ERROR_beg()
//
val () =
prerr_error4_loc(p3t.p3at_loc ())
val () =
(
  prerr_string (": partial proof pattern [");
  prerr_p3at (p3t);
  prerr_string ("] is not allowed for erasure.");
  prerr_newline ()
) (* end of [val] *)
//
val () = prerr_ERROR_end()
//
in
  the_trans4errlst_add(trans4err_T4E_p3at_tyer_isprf(p3t))
end // end of [then]
//
end // end of [auxerr_if]

implement
p3atlst_tyer
  (p3ts) = let
in
//
if glist_is_cons (p3ts) then let
  //
    val p3t = glist_head<p3at> (p3ts)
    val p3ts = glist_tail<p3at> (p3ts)
  //
    val
    isprf = p3at_is_prf(p3t)
  //
  in
    if isprf
      then let
        val () = auxerr_if(p3t) in p3atlst_tyer(p3ts)
      end // end of [then]
      else let
        val hip = p3at_tyer(p3t)
        val hips = p3atlst_tyer(p3ts) in glist_cons(hip, hips)
      end // end of [else]
    // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [p3atlst_tyer]

(* ****** ****** *)

implement
p3atlst_tyer2
  (d3es, p3ts) = let
in
//
if glist_is_cons (p3ts) then let
  //
    val p3t = glist_head<p3at> (p3ts)
    val p3ts = glist_tail<p3at> (p3ts)
  //
    val d3e = glist_head_exn<d3exp> (d3es)
    val d3es = glist_tail_exn<d3exp> (d3es)
    val
    isprf = p3at_is_prf(p3t)
    val
    isprf =
    (
      if isprf then true else d3exp_is_prf(d3e)
    ) : bool // end of [val]
  //
  in
    if isprf
      then let
        val () = auxerr_if(p3t) in p3atlst_tyer2(d3es, p3ts)
      end // end of [then]
      else let
        val hip = p3at_tyer(p3t)
        val hips = p3atlst_tyer2(d3es, p3ts) in glist_cons(hip, hips)
        // end of [val]
      end // end of [else]
    // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [p3atlst_tyer2]

(* ****** ****** *)

implement
p3atlst_npf_tyer
  (npf, p3ts) = let
in
  if npf > 0 then let
    val p3ts = glist_tail_exn<p3at> (p3ts)
  in
    p3atlst_npf_tyer (npf-1, p3ts)
  end else
    p3atlst_tyer (p3ts)
  // end of [if]
end // end of [p3atlst_npf_tyer]

(* ****** ****** *)

fun
p3atlst_npf_tyer_labize_aux (
  npf: int, p3ts: p3atlst, i: int
) : labhipatlst = let
in
//
if npf > 0 then let
  val p3ts = glist_tail_exn<p3at> (p3ts)
in
  p3atlst_npf_tyer_labize_aux (npf-1, p3ts, i+1)
end else ( // HX-2013-01: npf <= 0
//
if glist_is_cons (p3ts) then let
    val p3t = glist_head<p3at> (p3ts)
    val p3ts = glist_tail<p3at> (p3ts)
    val isprf = p3at_is_prf (p3t)
  in
    if isprf then
      p3atlst_npf_tyer_labize_aux (npf, p3ts, i+1)  
    else let
      val lab =
        $LAB.label_make_int (i)
      val hip = p3at_tyer (p3t)
      val lhip = labhipat_new (lab, hip)
      val lhips = p3atlst_npf_tyer_labize_aux (npf, p3ts, i+1)
    in
      glist_cons (lhip, lhips)
    end // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
) // end of [if]
//
end // end of [p3atlst_npf_tyer_labize_aux]

implement
p3atlst_npf_tyer_labize
  (npf, p3ts) = p3atlst_npf_tyer_labize_aux (npf, p3ts, 0)
// end of [p3atlst_npf_tyer_labize]

(* ****** ****** *)
//
extern
fun
labp3atlst_tyer
  (lxs: labp3atlst): labhipatlst
//
implement
labp3atlst_tyer (lxs) = let
in
//
if glist_is_cons (lxs) then let
    val lx = glist_head<labp3at> (lxs)
    val lxs = glist_tail<labp3at> (lxs)
    val l = lx.labp3at_lab ()
    val x = lx.labp3at_elt ()
  in
    if p3at_is_prf(x)
      then labp3atlst_tyer (lxs)
      else let
        val hip = p3at_tyer (x)
        val lhip = labhipat_new (l, hip)
      in
        glist_cons (lhip, labp3atlst_tyer (lxs))
      end // end of [else]
    // end of [if]
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [labp3atlst_tyer]

(* ****** ****** *)

implement
labp3atlst_npf_tyer
  (npf, lp3ts) = let
in
//
if
npf > 0
then let
//
val lp3ts = glist_tail_exn<labp3at> (lp3ts)
//
in
//
labp3atlst_npf_tyer (npf-1, lp3ts)
//
end // end of [then]
else labp3atlst_tyer (lp3ts) // [else]
//
end // end of [labp3atlst_npf_tyer]

(* ****** ****** *)

implement
p3at_tyer_con
(
  loc0, hse0, pck, d2c, npf, p3ts
) = let
//
val lhips =
  p3atlst_npf_tyer_labize (npf, p3ts)
// end of [val]
val test = labhipatlst_is_unused (lhips)
//
in
//
if test then
    hipat_con_any(loc0, hse0, pck, d2c)
else let
    val lhses =
      labhipatlst_get_type (lhips)
    // end of [val]
    val hse_sum = hisexp_tysum (d2c, lhses)
  in
    hipat_con (loc0, hse0, pck, d2c, hse_sum, lhips)
  end // end of [_]
//
end // end of [p3at_tyer_con]

(* ****** ****** *)
//
extern
fun
gm3at_tyer(gm3t: gm3at): higmat
and
gm3atlst_tyer(gm3ts: gm3atlst): higmatlst
//
extern
fun c3lau_tyer(c3l: c3lau): hiclau
and c3laulst_tyer(c3ls: c3laulst): hiclaulst
//
extern
fun
c3lau_tyer2
  (d3es: d3explst, c3l: c3lau): hiclau
and
c3laulst_tyer2
  (d3es: d3explst, c3ls: c3laulst): hiclaulst
//
(* ****** ****** *)

extern
fun
d3exp_tyer_cst
  (loc0: loc_t, hse0: hisexp, d2c: d2cst): hidexp
// end of [d3exp_tyer_cst]

extern
fun
d3exp_tyer_tmpcst
(
  loc0: loc_t
, hse0: hisexp, d2c: d2cst, t2mas: t2mpmarglst
) : hidexp // end of [d3exp_tyer_tmpcst]
extern
fun
d3exp_tyer_tmpvar
(
  loc0: loc_t
, hse0: hisexp, d2v: d2var, t2mas: t2mpmarglst
) : hidexp // end of [d3exp_tyer_tmpvar]

(* ****** ****** *)
//
extern
fun
d3explst_npf_tyer (npf: int, d3es: d3explst): hidexplst
extern
fun
d3explst_npf_tyer_labize (npf: int, d3es: d3explst): labhidexplst
extern
fun
labd3explst_npf_tyer (npf: int, ld3es: labd3explst): labhidexplst
//
(* ****** ****** *)
//
fun
d3exp_tyer_type
  (d3e: d3exp): hisexp = let
//
val loc = d3e.d3exp_loc ()
val s2e = d3exp_get_type (d3e)
//
in
  s2exp_tyer_deep (loc, s2e)
end // end of [d3exp_tyer_type]
//
(* ****** ****** *)
//
// HX-2026-10: the closure [auxlst] of [D3Eifcase] is lambda-lifted
//
fun
d3exp_tyer_ifcase_aux
(
  knd: int, loc0: loc_t, hse0: hisexp
, x0: i3fcl, xs: i3fclist
) : hidexp =
(
  if glist_is_nil (xs) then
  (
  if knd > 0
    then (
      d3exp_tyer(x0.i3fcl_body ())
    ) else let
      val hde_cond =
        d3exp_tyer(x0.i3fcl_test ())
      val hde_then =
        d3exp_tyer(x0.i3fcl_body ())
      val hde_else = hidexp_empty(loc0, hse0)
    in
      hidexp_if(loc0, hse0, hde_cond, hde_then, hde_else)
    end // end of [else]
  // end of [if]
  ) (* end of [list_nil *)
  else let
      val x = glist_head<i3fcl> (xs)
      val xs = glist_tail<i3fcl> (xs)
      val hde_cond =
        d3exp_tyer(x0.i3fcl_test ())
      val hde_then =
        d3exp_tyer(x0.i3fcl_body ())
      val hde_else = d3exp_tyer_ifcase_aux(knd, loc0, hse0, x, xs)
    in
      hidexp_if(loc0, hse0, hde_cond, hde_then, hde_else)
    end // end of [list_cons]
) (* end of [d3exp_tyer_ifcase_aux] *)

(* ****** ****** *)

fun
d2varlst_inc_utimes
  (d2vs: d2varlst): void =
  if glist_is_cons (d2vs) then let
    val () = d2var_inc_utimes (glist_head<d2var> (d2vs))
  in
    d2varlst_inc_utimes (glist_tail<d2var> (d2vs))
  end else ()
// end of [d2varlst_inc_utimes]

fun
d3explst_tyer_map
  (d3es: d3explst): hidexplst =
  if glist_is_cons (d3es) then let
    val hde = d3exp_tyer (glist_head<d3exp> (d3es))
    val hdes = d3explst_tyer_map (glist_tail<d3exp> (d3es))
  in
    glist_cons (hde, hdes)
  end else glist_nil ((*void*))
// end of [d3explst_tyer_map]

(* ****** ****** *)

implement
d3exp_tyer
  (d3e0) = let
//
val loc0 = d3e0.d3exp_loc ()
//
val s2e0 = d3exp_get_type (d3e0)
val hse0 = s2exp_tyer_shallow (loc0, s2e0)
//
in
//
case+
d3exp_node_view (d3e0.d3exp_node ()) of
//
| ~D3Evar (d2v) => let
    val () =
      d2var_inc_utimes (d2v)
    // end of [val]
  in
    hidexp_var (loc0, hse0, d2v)
  end // end of [D3Evar]
//
| ~D3Ecst (d2c) =>
    d3exp_tyer_cst (loc0, hse0, d2c)
  // end of [D3Ecst]
//
| ~D3Eint (i) =>
    hidexp_int (loc0, hse0, i)
| ~D3Eintrep (rep) =>
    hidexp_intrep (loc0, hse0, rep)
| ~D3Ebool (b) =>
    hidexp_bool (loc0, hse0, b)
| ~D3Echar (c) =>
    hidexp_char (loc0, hse0, c)
| ~D3Estring (str) =>
    hidexp_string (loc0, hse0, str)
//
| ~D3Ei0nt (tok) =>
    hidexp_i0nt (loc0, hse0, tok)
| ~D3Ef0loat (tok) =>
    hidexp_f0loat (loc0, hse0, tok)
//
| ~D3Efloat (rep) =>
    hidexp_float (loc0, hse0, rep)
//
| ~D3Ecstsp (x) =>
    hidexp_cstsp (loc0, hse0, x)
//
| ~D3Etyrep (s2e) => let
    val
    hse =
    s2exp_tyer_shallow(loc0, s2e)
  in
    hidexp_tyrep (loc0, hse0, hse)
  end // end of [D3Etyrep]
//
| ~D3Etop () => hidexp_top (loc0, hse0)
| ~D3Eempty () => hidexp_empty (loc0, hse0)
//
| ~D3Eextval (name) =>
    hidexp_extval(loc0, hse0, name)
  // end of [D3Eextval]
//
| ~D3Eextfcall
    (_fun, _arg) => let
    val _arg = d3explst_tyer(_arg)
  in
    hidexp_extfcall(loc0, hse0, _fun, _arg)
  end // end of [D3Eextfcall]
| ~D3Eextmcall
    (_obj, _mtd, _arg) => let
    val _obj = d3exp_tyer (_obj)
    val _arg = d3explst_tyer (_arg)
  in
    hidexp_extmcall(loc0, hse0, _obj, _mtd, _arg)
  end // end of [D3Eextmcall]
//
| ~D3Econ (
    d2c, npf, d3es
  ) => let
    val lhdes =
      d3explst_npf_tyer_labize(npf, d3es)
    // end of [val]
    val lhses = labhidexplst_get_type(lhdes)
    val hse_sum = hisexp_tysum(d2c, lhses)
  in
    hidexp_con(loc0, hse0, d2c, hse_sum, lhdes)
  end // end of [D3Econ]
//
| ~D3Etmpcst(d2c, t2mas) =>
    d3exp_tyer_tmpcst (loc0, hse0, d2c, t2mas)
| ~D3Etmpvar(d2v, t2mas) =>
    d3exp_tyer_tmpvar (loc0, hse0, d2v, t2mas)
//
| ~D3Efoldat (_) =>
    hidexp_foldat (loc0, hse0)
  // end of [D3Efoldat]
| ~D3Efreeat (d3e) => let
    val hde = d3exp_tyer (d3e) in hidexp_freeat (loc0, hse0, hde)
  end // end of [D3Efreeat]
//
| ~D3Elet (
    d3cs, d3e_scope
  ) => let
    val hids = d3eclist_tyer (d3cs)
    val hde_scope = d3exp_tyer (d3e_scope)
  in
    hidexp_let_simplify (loc0, hse0, hids, hde_scope)
  end // end of [D3Elet]
//
| ~D3Eapp_dyn
  (
    d3e_fun, npf, d3es_arg
  ) => let
    val s2e_fun = d3exp_get_type (d3e_fun)
    val hse_fun = s2exp_tyer_deep (loc0, s2e_fun)
    val hde_fun = d3exp_tyer (d3e_fun)
    val hdes_arg = d3explst_npf_tyer (npf, d3es_arg)
  in
    hidexp_app2 (loc0, hse0, hse_fun, hde_fun, hdes_arg)
  end // end of [D3Eapp_dyn]
| ~D3Eapp_sta (d3e) => d3exp_tyer (d3e)
//
| ~D3Eif (
    _cond, _then, _else
  ) => let
    val hde_cond = d3exp_tyer (_cond)
    val hde_then = d3exp_tyer (_then)
    val hde_else = d3exp_tyer (_else)
  in
    hidexp_if (loc0, hse0, hde_cond, hde_then, hde_else)
  end // end of [D3Eif]
| ~D3Esif (
    s2e_cond, _then, _else
  ) => let
    val hde_then = d3exp_tyer (_then)
    val hde_else = d3exp_tyer (_else)
  in
    hidexp_sif (loc0, hse0, s2e_cond, hde_then, hde_else)
  end // end of [D3Esif]
//
| ~D3Eifcase
    (knd, ifcls) => let
  in
    if glist_is_nil (ifcls) then
        hidexp_empty (loc0, hse0)
      // list_nil
    else let
      val x0 = glist_head<i3fcl> (ifcls)
      val xs = glist_tail<i3fcl> (ifcls)
    in
      d3exp_tyer_ifcase_aux (knd, loc0, hse0, x0, xs)
    end // end of [list_cons]
  end // end of [D3Eifcase]
//
| ~D3Ecase (
    knd, d3es, c3ls
  ) => let
    val hdes = d3explst_tyer(d3es)
    val hcls = c3laulst_tyer2(d3es, c3ls)
  in
    hidexp_case (loc0, hse0, knd, hdes, hcls)
  end // end of [D3Ecase]
//
| ~D3Elst (
    lin, s2e_elt, d3es
  ) => let
    val hse_elt =
      s2exp_tyer_shallow (loc0, s2e_elt)
    val hdes = d3explst_tyer_map (d3es)
  in
    hidexp_lst (loc0, hse0, lin, hse_elt, hdes)
  end // end of [D3Elst]
| ~D3Etup (
    knd, npf, d3es
  ) => let
    val hse_rec =
       s2exp_tyer_deep (loc0, s2e0)
    // end of [val]
    val lhdes =
      d3explst_npf_tyer_labize (npf, d3es)
    // end of [val]
  in
    hidexp_rec2 (loc0, hse0, knd, lhdes, hse_rec)
  end // end of [D3Etup]
//
| ~D3Erec (
    knd, npf, ld3es
  ) => let
    val hse_rec =
       s2exp_tyer_deep (loc0, s2e0)
    // end of [val]
    val lhdes = labd3explst_npf_tyer (npf, ld3es)
  in
    hidexp_rec2 (loc0, hse0, knd, lhdes, hse_rec)
  end // end of [D3Erec]
//
| ~D3Eseq (d3es) => let
    val hdes =
      d3explst_tyer_map (d3es)
    // end of [val]
  in
    hidexp_seq_simplify(loc0, hse0, hdes)
  end // end of [D3Eseq]
//
| ~D3Eselab
    (d3e, d3ls) => let
    val hde = d3exp_tyer (d3e)
    val hse_flt = d3exp_tyer_type (d3e)
    val hils = d3lablst_tyer (d3ls)
  in
    hidexp_selab (loc0, hse0, hde, hse_flt, hils)
  end // end of [D3Eselab]
//
| ~D3Eptrofvar (d2v) => let
    val () = d2var_inc_utimes (d2v)
  in
    hidexp_ptrofvar (loc0, hse0, d2v)
  end // end of [D3Eptrofvar]
| ~D3Eptrofsel
    (d3e, s2rt, d3ls) => let
    val hde = d3exp_tyer (d3e)
    val hse_rt = s2exp_tyer_shallow (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
  in
    hidexp_ptrofsel (loc0, hse0, hde, hse_rt, hils)
  end // end of [D3Eptrofsel]
//
| ~D3Erefarg (
    refval, freeknd, d3e
  ) => let
    val hde = d3exp_tyer (d3e)
  in
    hidexp_refarg (loc0, hse0, refval, freeknd, hde)
  end // end of [D3Erefarg]
//
| ~D3Esel_var
    (d2v, s2rt, d3ls) => let
    val () = d2var_inc_utimes (d2v)
    val hse_rt = s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
  in
    hidexp_selvar (loc0, hse0, d2v, hse_rt, hils)
  end // end of [D3Esel_var]
| ~D3Esel_ptr
    (d3e, s2rt, d3ls) => let
    val hde = d3exp_tyer (d3e)
    val hse_rt =
      s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
  in
    hidexp_selptr (loc0, hse0, hde, hse_rt, hils)
  end // end of [D3Esel_ptr]
| ~D3Esel_ref
    (d3e, s2rt, d3ls) => let
    val hde = d3exp_tyer (d3e)
    val hse_rt =
      s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
  in
    hidexp_selptr (loc0, hse0, hde, hse_rt, hils)
  end // end of [D3Esel_ref]
//
| ~D3Eassgn_var
  (
    d2v_l, s2rt, d3ls, d3e_r
  ) =>
  (
    if d3exp_is_prf (d3e_r) then hidexp_empty (loc0, hse0)
    else let
    val () = d2var_inc_utimes (d2v_l)
    val hse_rt = s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_assgn_var (loc0, hse0, d2v_l, hse_rt, hils, hde_r)
  end
  ) (* end of [D3Eassgn_var] *)
//
| ~D3Eassgn_ptr
  (
    d3e_l, s2rt, d3ls, d3e_r
  ) =>
  (
    if d3exp_is_prf (d3e_r) then hidexp_empty (loc0, hse0)
    else let
    val hde_l = d3exp_tyer (d3e_l)
    val hse_rt = s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_assgn_ptr (loc0, hse0, hde_l, hse_rt, hils, hde_r)
  end
  ) (* end of [D3Eassgn_ptr] *)
//
| ~D3Eassgn_ref
  (
    d3e_l, s2rt, d3ls, d3e_r
  ) => let
    val hde_l = d3exp_tyer (d3e_l)
    val hse_rt = s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_assgn_ptr (loc0, hse0, hde_l, hse_rt, hils, hde_r)
  end // end of [D3Eassgn_ref]
//
| ~D3Exchng_var
  (
    d2v_l, s2rt, d3ls, d3e_r
  ) => let
    val () = d2var_inc_utimes (d2v_l)
    val hse_rt = s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_xchng_var (loc0, hse0, d2v_l, hse_rt, hils, hde_r)
  end // end of [D3Exchng_var]
| ~D3Exchng_ptr
  (
    d3e_l, s2rt, d3ls, d3e_r
  ) => let
    val hde_l = d3exp_tyer (d3e_l)
    val hse_rt =
      s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_xchng_ptr (loc0, hse0, hde_l, hse_rt, hils, hde_r)
  end // end of [D3Exchng_ptr]
| ~D3Exchng_ref
  (
    d3e_l, s2rt, d3ls, d3e_r
  ) => let
    val hde_l = d3exp_tyer (d3e_l)
    val hse_rt =
      s2exp_tyer_deep (loc0, s2rt)
    val hils = d3lablst_tyer (d3ls)
    val hde_r = d3exp_tyer (d3e_r)
  in
    hidexp_xchng_ptr (loc0, hse0, hde_l, hse_rt, hils, hde_r)
  end // end of [D3Exchng_ref]
//
| ~D3Eviewat_assgn (_, _, _) => hidexp_empty (loc0, hse0)
//
| ~D3Earrpsz
  (
    s2e_elt, d3es_elt, asz
  ) => let
    val hse_elt =
      s2exp_tyer_shallow (loc0, s2e_elt)
    // end of [val]
    val hdes_elt = d3explst_tyer_map (d3es_elt)
  in
    hidexp_arrpsz (loc0, hse0, hse_elt, hdes_elt, asz)
  end // end of [D3Earrpsz]
| ~D3Earrinit
  (
    s2e_elt, d3e_asz, d3es_elt
  ) => let
    val hse_elt =
      s2exp_tyer_shallow (loc0, s2e_elt)
    // end of [val]
//
    val hde_asz = d3exp_tyer (d3e_asz)
    val s2e_asz = d3exp_get_type (d3e_asz)
    val s2f_asz = $S2UT.s2exp2hnf (s2e_asz)
    val opt = un_s2exp_g1size_index_t0ype(s2f_asz)
    val s2i = (
      case+ opt of
      | ~Some_vt (s2i) => s2i
      | ~None_vt () => $ERR.abort_interr<s2exp> ((*MatchError*))
    ) : s2exp
//
    val opt =
      un_s2exp_intconst(s2i)
    // end of [opt]
    val asz =
    (
      case+ opt of
      | ~Some_vt(n) => n | ~None_vt() => ~1
    ) : int // end of [val]
//
    val
    hdes_elt =
    d3explst_tyer_map (d3es_elt)
//
  in
    hidexp_arrinit
      (loc0, hse0, hse_elt, hde_asz, hdes_elt, asz)
    // end of [hidexp_arrinit]
  end // end of [D3Earrinit]
//
| ~D3Eraise(d3e) => let
    val hde = d3exp_tyer(d3e)
  in
    hidexp_raise(loc0, hse0, hde)
  end // end of [D3Eraise]
//
| ~D3Eeffmask(s2fe, d3e) => d3exp_tyer(d3e)
//
| ~D3Evararg(d3es) => let
    val hdes = d3explst_tyer(d3es)
  in
    hidexp_vararg(loc0, hse0, hdes)
  end // end of [D3Evararg]
//
| ~D3Evcopyenv
    (knd, d2v) => let
//
// HX: hidexp_vcopyenv = hidexp_var
//
    val () =
      d2var_inc_utimes (d2v)
    // end of [val]
  in
    hidexp_vcopyenv (loc0, hse0, d2v)
  end // end of [D3Evcopyenv]
//
| ~D3Etempenver(d2vs) => let
    val () =
    d2varlst_inc_utimes (d2vs)
    // end of [val]
  in
    hidexp_tempenver (loc0, hse0, d2vs)
  end // end of [D3Etempenver]
//
| ~D3Eann_type(d3e, _(*ann*)) => d3exp_tyer (d3e)
//
| ~D3Elam_dyn
  (
    lin, npf, p3ts_arg, d3e_body
  ) => let
    val hse_fun = s2exp_tyer_deep (loc0, s2e0)
    val hips_arg = p3atlst_npf_tyer (npf, p3ts_arg)
    val hde_body = d3exp_tyer (d3e_body)
  in
    hidexp_lam (loc0, hse_fun, 1(*boxed*), hips_arg, hde_body)
  end // end of [D3Elam_dyn]
| ~D3Elaminit_dyn
  (
    lin, npf, p3ts_arg, d3e_body
  ) => let
    val hse_fun = s2exp_tyer_deep (loc0, s2e0)
    val hips_arg = p3atlst_npf_tyer (npf, p3ts_arg)
    val hde_body = d3exp_tyer (d3e_body)
  in
    hidexp_lam (loc0, hse_fun, 0(*unboxed*), hips_arg, hde_body)
  end // end of [D3Elaminit_dyn]
//
| ~D3Elam_sta
  (
    s2vs, s2ps, d3e_body
  ) => let
    val hde_body = d3exp_tyer (d3e_body)
    val isval = hidexp_is_value (hde_body)
    val () =
    if not(isval) then let
      val () = prerr_warning4_loc (loc0)
      val () = (
        prerr_string (": a non-value body for static lam-abstraction is not supported.");
        prerr_newline ()
      ) (* end of [val] *)
    in
    end (* end of [if] *)
  in
    hde_body
  end // end of [D3Elam_sta]
| ~D3Elam_met (_(*met*), d3e) => d3exp_tyer (d3e)
//
| ~D3Efix
  (
    knd, f_d2v, d3e_def
  ) => let
    val hde_def = d3exp_tyer (d3e_def)
  in
    hidexp_fix (loc0, hse0, knd, f_d2v, hde_def)
  end // end of [D3Efix]
//
| ~D3Edelay (d3e) => let
    val hde = d3exp_tyer (d3e)
  in
    hidexp_delay (loc0, hse0, hde)
  end // end of [D3Edelay]
| ~D3Eldelay (d3e1, d3e2) => let
    val hde1 = d3exp_tyer (d3e1)
    val hde2 = d3exp_tyer (d3e2)
  in
    hidexp_ldelay (loc0, hse0, hde1, hde2)
  end // end of [D3Eldelay]
| ~D3Elazyeval (lin, d3e) => let
    val hde = d3exp_tyer (d3e)
  in
    hidexp_lazyeval (loc0, hse0, lin, hde)
  end // end of [D3Elazyeval]
//
| ~D3Eloop
  (
    init, test, post, body
  ) => let
    val init =
      d3expopt_tyer(init)
    // end of [val]
    val test = d3exp_tyer(test)
    val post =
      d3expopt_tyer (post)
    // end of [val]
    val body = d3exp_tyer (body)
  in
    hidexp_loop(loc0, hse0, init, test, post, body)
  end // end of [D3Eloop]
| ~D3Eloopexn (knd) => hidexp_loopexn (loc0, hse0, knd)
//
| ~D3Etrywith
    (d3e_try, c3ls_with) => let
    val hde_try = d3exp_tyer (d3e_try)
    val hicls_with = c3laulst_tyer (c3ls_with)
  in
    hidexp_trywith(loc0, hse0, hde_try, hicls_with)
  end // end of [D3Etrywith]
//
| ~D3Esolverify (_) =>
    hidexp_empty(loc0, hisexp_void_t0ype((*void*)))
  // end of [D3Esolverify]
//
| ~D3Eerrexp() => hidexp_errexp (loc0, hse0)
//
| v (*unspported*) => let
    val () = d3exp_node_view_free (v)
    val () = prerr_interror_loc(loc0)
    val () = (
      prerr_string (": d3exp_tyer: d3e0 = "); prerr_d3exp (d3e0); prerr_newline ()
    ) in exitloc(1)
    // end of [val]
  end (*  end of [_(*unsupported*)] *)
//
end // end of [let] // end of [d3exp_tyer]

(* ****** ****** *)

implement
d3explst_tyer
  (d3es) = let
in
//
if glist_is_cons (d3es) then let
    val d3e = glist_head<d3exp> (d3es)
    val d3es = glist_tail<d3exp> (d3es)
    val isprf =
      d3exp_is_prf (d3e)
    // end of [val]
  in
    if isprf then
      d3explst_tyer (d3es)
    else let
      val hde = d3exp_tyer (d3e)
    in
      glist_cons (hde, d3explst_tyer (d3es))
    end // end of [if]
  end
else glist_nil ((*void*))
//
end // end of [d3explst_tyer]

implement
d3explst_npf_tyer
  (npf, d3es) = let
in
//
if
npf > 0
then let
//
val d3es = glist_tail_exn<d3exp> (d3es)
//
in
//
d3explst_npf_tyer(npf-1, d3es)
//
end // end of [then]
else d3explst_tyer(d3es) // [else]
//
end // end of [d3explst_npf_tyer]

fun
d3explst_npf_tyer_labize_aux1
(
  npf: int, d3es: d3explst
) : d3explst =
  if npf > 0 then let
    val d3es = glist_tail_exn<d3exp> (d3es) in d3explst_npf_tyer_labize_aux1 (npf-1, d3es)
  end else d3es // end of [aux1]
//
fun
d3explst_npf_tyer_labize_aux2
(
  i: int, d3es: d3explst
) : labhidexplst = let
in
//
if glist_is_cons (d3es) then let
    val d3e = glist_head<d3exp> (d3es)
    val d3es = glist_tail<d3exp> (d3es)
    val isprf = d3exp_is_prf (d3e)
  in
    if isprf then
      d3explst_npf_tyer_labize_aux2 (i+1, d3es)
    else let
      val l =
        $LAB.label_make_int (i)
      val hde = d3exp_tyer (d3e)
      val lhde = labhidexp_new (l, hde)
    in
      glist_cons (lhde, d3explst_npf_tyer_labize_aux2 (i+1, d3es))
    end // end of [if]
  end
else glist_nil ((*void*))
//
end // end of [aux2]

implement
d3explst_npf_tyer_labize
  (npf, d3es) = let
//
val i0 = (if npf >= 0 then npf else 0): int
//
in
  d3explst_npf_tyer_labize_aux2 (i0, d3explst_npf_tyer_labize_aux1 (npf, d3es))
end // end of [d3explst_npf_tyer_labize]

(* ****** ****** *)

implement
d3expopt_tyer (opt) = (
  if gopt_is_some (opt)
    then gopt_some (d3exp_tyer (gopt_unsome (opt))) else gopt_none ((*void*))
) // end of [d3expopt_tyer]

(* ****** ****** *)

extern
fun labd3explst_tyer (lxs: labd3explst): labhidexplst
implement
labd3explst_tyer
  (lxs) = let
in
//
if glist_is_cons (lxs) then let
    val lx = glist_head<labd3exp> (lxs)
    val lxs = glist_tail<labd3exp> (lxs)
    val l0 = lx.labd3exp_lab ()
    val x = lx.labd3exp_elt ()
  in
    if d3exp_is_prf (x) then
      labd3explst_tyer (lxs)
    else let
      val hde = d3exp_tyer (x)
      val lhde = labhidexp_new ($SYN.l0ab_lab (l0), hde)
    in
      glist_cons (lhde, labd3explst_tyer (lxs))
    end // end of [if]
  end
else glist_nil ((*void*))
//
end // end of [labd3explst_tyer]

implement
labd3explst_npf_tyer
  (npf, lxs) = let
in
//
if npf > 0 then let
  val lxs = glist_tail_exn<labd3exp> (lxs)
in
  labd3explst_npf_tyer (npf-1, lxs)
end else
  labd3explst_tyer (lxs)
// end of [if]
//
end // end of [labd3explst_npf_tyer]

(* ****** ****** *)

implement
d3lab_tyer
  (d3l) = let
//
val loc0 = d3l.d3lab_loc ()
//
in
//
case+
d3lab_node_view (d3l.d3lab_node ())
of // case+
| ~D3LABlab (l) =>
    hilab_lab (loc0, l)
  // end of [D3LABlab]
| ~D3LABind (d3es_ind) => let
    val hdes_ind =
      d3explst_tyer_map (d3es_ind)
    // end of [val]
  in
    hilab_ind (loc0, hdes_ind)
  end // end of [D3LABind]
//
end // end of [d3lab_tyer]

implement
d3lablst_tyer(d3ls) =
(
  if glist_is_cons (d3ls) then let
    val hil = d3lab_tyer (glist_head<d3lab> (d3ls))
    val hils = d3lablst_tyer (glist_tail<d3lab> (d3ls))
  in
    glist_cons (hil, hils)
  end else glist_nil ((*void*))
) (* end of [d3lablst_tyer] *)

(* ****** ****** *)

implement
d3exp_tyer_cst
  (loc0, hse0, d2c) = let
//
val sym = d2cst_get_sym (d2c)
//
in
//
if sym =
    $SYM.symbol_TRUE_BOOL then
    hidexp_bool (loc0, hse0, true)
else if sym =
    $SYM.symbol_FALSE_BOOL then
    hidexp_bool (loc0, hse0, false)
else let
    val d2c = d2cst_tyer (d2c) in hidexp_cst (loc0, hse0, d2c)
  end // end of [_]
//
end // end of [d3exp_tyer_cst]

(* ****** ****** *)

implement
d3exp_tyer_tmpcst
(
  loc0, hse0, d2c, t2mas
) = let
  val t2mas2 =
    t2mpmarglst_mhnfize (t2mas)
  // end of [val]
in
  hidexp_tmpcst (loc0, hse0, d2c, t2mas2)
end (* end of [d3exp_tyer_tmpcst] *)

implement
d3exp_tyer_tmpvar
(
  loc0, hse0, d2v, t2mas
) = let
  val t2mas2 =
    t2mpmarglst_mhnfize (t2mas)
  // end of [val]
in
  hidexp_tmpvar (loc0, hse0, d2v, t2mas2)
end (* end of [d3exp_tyer_tmpvar] *)

(* ****** ****** *)

implement
gm3at_tyer
  (gm3t) = let
//
val loc = gm3t.gm3at_loc ()
//
val hde =
  d3exp_tyer(gm3t.gm3at_exp ())
//
val opt = (
  let val p3to = gm3t.gm3at_pat () in
    if gopt_is_some (p3to)
      then gopt_some (p3at_tyer (gopt_unsome (p3to))) else gopt_none ((*void*))
  end
) : hipatopt // end of [val]
//
in
  higmat_make (loc, hde, opt)
end (* end of [gm3at_tyer] *)

implement
gm3atlst_tyer(gm3ts) =
  if glist_is_cons (gm3ts) then let
    val hgmat = gm3at_tyer (glist_head<gm3at> (gm3ts))
    val hgmats = gm3atlst_tyer (glist_tail<gm3at> (gm3ts))
  in
    glist_cons (hgmat, hgmats)
  end else glist_nil ((*void*))
// end of [gm3atlst_tyer]

(* ****** ****** *)

implement
c3lau_tyer(c3l) = let
//
val loc = c3l.c3lau_loc ()
val hips =
  p3atlst_tyer (c3l.c3lau_pat ())
// end of [val]
val gua =
  gm3atlst_tyer (c3l.c3lau_gua ())
//
val seq = c3l.c3lau_seq ()
val neg = c3l.c3lau_neg ()
val body = d3exp_tyer (c3l.c3lau_body ())
//
in
  hiclau_make (loc, hips, gua, seq, neg, body)
end // end of [c3lau_tyer]

implement
c3laulst_tyer(c3ls) =
  if glist_is_cons (c3ls) then let
    val hcl = c3lau_tyer (glist_head<c3lau> (c3ls))
    val hcls = c3laulst_tyer (glist_tail<c3lau> (c3ls))
  in
    glist_cons (hcl, hcls)
  end else glist_nil ((*void*))
// end of [c3laulst_tyer]

(* ****** ****** *)

implement
c3lau_tyer2
  (d3es, c3l) = let
//
val loc = c3l.c3lau_loc ()
//
val hips =
  p3atlst_tyer2(d3es, c3l.c3lau_pat ())
//
val gua = gm3atlst_tyer (c3l.c3lau_gua ())
//
val seq = c3l.c3lau_seq ()
val neg = c3l.c3lau_neg ()
val body = d3exp_tyer (c3l.c3lau_body ())
//
in
  hiclau_make (loc, hips, gua, seq, neg, body)
end // end of [c3lau_tyer2]

implement
c3laulst_tyer2
  (d3es, c3ls) = let
in
//
if glist_is_nil (c3ls)
  then glist_nil ((*void*))
  else let
    val c3l = glist_head<c3lau> (c3ls)
    val c3ls = glist_tail<c3lau> (c3ls)
    val hcl = c3lau_tyer2 (d3es, c3l)
    val hcls = c3laulst_tyer2 (d3es, c3ls)
  in
    glist_cons (hcl, hcls)
  end // end of [list_cons]
//
end // end of [c3laulst_tyer2]

(* ****** ****** *)

(* end of [pats_typerase_dynexp.dats] *)
