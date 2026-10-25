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
// HX-2026-10: no GC (ATS2 port of src/pats_hidynexp.dats, see PORTING.md, "Erased trees (hidynexp)")
// The only .dats that includes [pats_hidynexp_gen_dats.hats]
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

staload
LAB = "./pats_label.sats"
typedef label = $LAB.label

(* ****** ****** *)
//
staload
S2E = "./pats_staexp2.sats"
typedef s2cst = $S2E.s2cst
//
staload
S2C = "./pats_stacst2.sats"
//
staload
D2E = "./pats_dynexp2.sats"
typedef d2cst = $D2E.d2cst
//
(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload _ = "./pats_dynexp2_dcst.dats"
staload _ = "./pats_dynexp2_dvar.dats"

(* ****** ****** *)

staload TRENV2 = "./pats_trans2_env.sats"

(* ****** ****** *)

#include "./pats_hidynexp_gen_dats.hats"

(* ****** ****** *)

implement
hipat_get_type (hip) = hip.hipat_type()

(* ****** ****** *)

implement
labhipatlst_is_unused
  (lhips) = let
//
fun f
(
  lhips: labhipatlst
) : bool =
  if glist_is_cons (lhips) then let
    val lhip = glist_head<labhipat> (lhips)
    val hip = lhip.labhipat_elt()
  in
    if hipat_node_is_HIPany (hip.hipat_node())
      then f (glist_tail<labhipat> (lhips)) else false
  end else true
//
in
  f (lhips)
end // end of [labhipatlst_is_unused]

(* ****** ****** *)

implement
hipat_make_node (
  loc, hse, node
) = hipat_new (loc, hse, node, gopt_none((*d2v*)))
// end of [hipat_make_node]

(* ****** ****** *)

implement
hipat_set_asvar (hip, opt) = set_hipat_asvar (hip, opt)

(* ****** ****** *)

fun
hipat_lst_aux
(
  loc: location
, hse_lst: hisexp, pck: pckind
, d2c_nil: d2con, d2c_cons: d2con, hse_sum: hisexp
, l0: label, l1: label, hips: hipatlst
) : hipat = let
in
//
if glist_is_cons (hips) then let
  val hip0 = glist_head<hipat> (hips)
  val hips = glist_tail<hipat> (hips)
  val hip1 =
    hipat_lst_aux (loc, hse_lst, pck, d2c_nil, d2c_cons, hse_sum, l0, l1, hips)
  val lhip0 = labhipat_new (l0, hip0)
  val lhip1 = labhipat_new (l1, hip1)
  val lhips_arg = glist_cons (lhip0, glist_sing (lhip1))
in
  hipat_con (loc, hse_lst, pck, d2c_cons, hse_sum, lhips_arg)
end else hipat_con_any (loc, hse_lst, pck, d2c_nil)
//
end // end of [hipat_lst_aux]

implement
hipat_any (loc, hse, d2v) =
  hipat_make_node (loc, hse, hipat_node_HIPany (d2v))
// end of [hipat_any]

implement
hipat_var (loc, hse, d2v) =
  hipat_make_node (loc, hse, hipat_node_HIPvar (d2v))
// end of [hipat_var]

(* ****** ****** *)

implement
hipat_con (
  loc, hse, pck, d2c, hse_sum, lhips
) = hipat_make_node
  (loc, hse, hipat_node_HIPcon (pck, d2c, hse_sum, lhips))
// end of [hipat_con]

implement
hipat_con_any
  (loc, hse, pck, d2c) =
  hipat_make_node (loc, hse, hipat_node_HIPcon_any (pck, d2c))
// end of [hipat_con_any]

(* ****** ****** *)

implement
hipat_int
  (loc, hse, i) =
  hipat_make_node (loc, hse, hipat_node_HIPint (i))
// end of [hipat_int]
implement
hipat_intrep
  (loc, hse, rep) =
  hipat_make_node (loc, hse, hipat_node_HIPintrep (rep))
// end of [hipat_intrep]

implement
hipat_bool
  (loc, hse, b) =
  hipat_make_node (loc, hse, hipat_node_HIPbool (b))
// end of [hipat_bool]

implement
hipat_char
  (loc, hse, c) =
  hipat_make_node (loc, hse, hipat_node_HIPchar (c))
// end of [hipat_char]

implement
hipat_float
  (loc, hse, rep) =
  hipat_make_node (loc, hse, hipat_node_HIPfloat (rep))
// end of [hipat_float]

implement
hipat_string
  (loc, hse, str) =
  hipat_make_node (loc, hse, hipat_node_HIPstring (str))
// end of [hipat_string]

(* ****** ****** *)

implement
hipat_i0nt
  (loc, hse, tok) =
  hipat_make_node (loc, hse, hipat_node_HIPi0nt (tok))
// end of [hipat_i0nt]

implement
hipat_f0loat
  (loc, hse, tok) =
  hipat_make_node (loc, hse, hipat_node_HIPf0loat (tok))
// end of [hipat_f0loat]

(* ****** ****** *)

implement
hipat_empty
  (loc, hse) =
  hipat_make_node (loc, hse, hipat_node_HIPempty ())
// end of [hipat_empty]

(* ****** ****** *)

(* ****** ****** *)

implement
hipat_lst
(
  loc
, lin, hse_lst, hse_elt, hips
) = let
//
//
// HX-2026-10: no GC: lists are linear
//
val s2c =
  $S2C.s2cstref_get_cst ($S2C.the_list_vt0ype_int_vtype)
// end of [val]
//
val xx = s2cst_get_islst (s2c)
val () = assertloc (gopt_is_some (xx)) // HX: [val-Some(xx)]
val xx = gopt_unsome (xx)
//
val d2c_nil = d2conpair_0 (xx) and d2c_cons = d2conpair_1 (xx)
//
val pck = (
  if lin = 0 then PCKcon() else PCKfree()
) : pckind
//
val l0 = $LAB.label_make_int (0)
val l1 = $LAB.label_make_int (1)
//
val lhse0 = labhisexp_new (l0, gopt_none (), hse_elt)
val lhse1 = labhisexp_new (l1, gopt_none (), hse_lst)
val lhses_arg = glist_cons (lhse0, glist_sing (lhse1))
val hse_sum = hisexp_tysum (d2c_cons, lhses_arg)
//
in
  hipat_lst_aux (loc, hse_lst, pck, d2c_nil, d2c_cons, hse_sum, l0, l1, hips)
end // end of [hipat_lst]

(* ****** ****** *)

implement
hipat_rec (
  loc, hse, knd, pck, lhips, hse_rec
) =
(
hipat_make_node
  (loc, hse, hipat_node_HIPrec(knd, pck, lhips, hse_rec))
) // end of [hipat_rec]

implement
hipat_rec2
(
  loc0, hse0, knd, pck, lhips, hse_rec
) = let
//
val isflt =
  (if knd = 0 then true else false): bool
//
in
//
if
isflt
then (
if glist_is_cons (lhips) andalso glist_is_nil (glist_tail<labhipat> (lhips))
  then let val lx = glist_head<labhipat> (lhips) in lx.labhipat_elt() end
  else hipat_rec(loc0, hse0, knd, pck, lhips, hse_rec)
) (* end of [then] *)
else (
  hipat_rec (loc0, hse0, knd, pck, lhips, hse_rec)
) (* end of [else] *)
//
end // end of [hipat_rec2]

(* ****** ****** *)

(* ****** ****** *)

implement
hipat_refas
  (loc, hse, d2v, hip) =
  hipat_make_node (loc, hse, hipat_node_HIPrefas (d2v, hip))
// end of [hipat_refas]

(* ****** ****** *)

implement
hipat_ann
  (loc, hse, hip, hse_ann) =
  hipat_make_node (loc, hse, hipat_node_HIPann (hip, hse_ann))
// end of [hipat_ann]

(* ****** ****** *)


(* ****** ****** *)

(* ****** ****** *)

implement
hidexp_get_type (hde) = hde.hidexp_type()
implement
hidexplst_get_type (hdes) =
  if glist_is_cons (hdes)
    then glist_cons (hidexp_get_type (glist_head<hidexp> (hdes)), hidexplst_get_type (glist_tail<hidexp> (hdes)))
    else glist_nil ((*void*))
// end of [hidexplst_get_type]

(* ****** ****** *)

implement
hidexp_make_node
  (loc, hse, node) = hidexp_new (loc, hse, node)
// end of [hidexp_make_node]

(* ****** ****** *)

implement
hidexp_cst
  (loc, hse, d2c) =
  hidexp_make_node (loc, hse, hidexp_node_HDEcst (d2c))
// end of [hidexp_cst]

implement
hidexp_var
  (loc, hse, d2v) =
  hidexp_make_node (loc, hse, hidexp_node_HDEvar (d2v))
// end of [hidexp_var]

(* ****** ****** *)

implement
hidexp_int
  (loc, hse, i) =
  hidexp_make_node (loc, hse, hidexp_node_HDEint (i))
// end of [hidexp_int]

implement
hidexp_intrep
  (loc, hse, rep) =
  hidexp_make_node (loc, hse, hidexp_node_HDEintrep (rep))
// end of [hidexp_intrep]

implement
hidexp_bool
  (loc, hse, b) =
  hidexp_make_node (loc, hse, hidexp_node_HDEbool (b))
// end of [hidexp_bool]

implement
hidexp_char
  (loc, hse, c) =
  hidexp_make_node (loc, hse, hidexp_node_HDEchar (c))
// end of [hidexp_char]

implement
hidexp_float
  (loc, hse, rep) =
  hidexp_make_node (loc, hse, hidexp_node_HDEfloat (rep))
// end of [hidexp_float]

implement
hidexp_string
  (loc, hse, str) =
  hidexp_make_node (loc, hse, hidexp_node_HDEstring (str))
// end of [hidexp_string]

(* ****** ****** *)

implement
hidexp_i0nt
  (loc, hse, tok) =
  hidexp_make_node (loc, hse, hidexp_node_HDEi0nt (tok))
// end of [hidexp_i0nt]

implement
hidexp_f0loat
  (loc, hse, tok) =
  hidexp_make_node (loc, hse, hidexp_node_HDEf0loat(tok))
// end of [hidexp_f0loat]

(* ****** ****** *)

implement
hidexp_cstsp
  (loc, hse, x) =
  hidexp_make_node (loc, hse, hidexp_node_HDEcstsp(x))
// end of [hidexp_cstsp]

(* ****** ****** *)

implement
hidexp_tyrep
  (loc, hse, x) =
  hidexp_make_node (loc, hse, hidexp_node_HDEtyrep(x))
// end of [hidexp_cstsp]

(* ****** ****** *)

implement
hidexp_top(loc, hse) =
  hidexp_make_node (loc, hse, hidexp_node_HDEtop())
// end of [hidexp_top]

implement
hidexp_empty(loc, hse) =
  hidexp_make_node (loc, hse, hidexp_node_HDEempty())
// end of [hidexp_empty]

implement
hidexp_ignore
  (loc, hse, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDEignore(hde))
// end of [hidexp_ignore]

(* ****** ****** *)

implement
hidexp_castfn
  (loc, hse, d2c, arg) =
  hidexp_make_node (loc, hse, hidexp_node_HDEcastfn(d2c, arg))
// end of [hidexp_castfn]

(* ****** ****** *)

implement
hidexp_extval
  (loc, hse, name) =
  hidexp_make_node (loc, hse, hidexp_node_HDEextval(name))
// end of [hidexp_extval]

implement
hidexp_extfcall
  (loc, hse, _fun, _arg) =
  hidexp_make_node (loc, hse, hidexp_node_HDEextfcall(_fun, _arg))
// end of [hidexp_extfcall]

implement
hidexp_extmcall
  (loc, hse, _obj, _mtd, _arg) =
  hidexp_make_node (loc, hse, hidexp_node_HDEextmcall(_obj, _mtd, _arg))
// end of [hidexp_extmcall]

(* ****** ****** *)
//
implement
hidexp_con (
  loc, hse, d2c, hse_sum, lhdes
) = hidexp_make_node(loc, hse, hidexp_node_HDEcon (d2c, hse_sum, lhdes))
//
(* ****** ****** *)

implement
hidexp_tmpcst
  (loc, hse, d2c, t2mas) =
  hidexp_make_node (loc, hse, hidexp_node_HDEtmpcst(d2c, t2mas))
// end of [hidexp_tmpcst]

implement
hidexp_tmpvar
  (loc, hse, d2v, t2mas) =
  hidexp_make_node (loc, hse, hidexp_node_HDEtmpvar(d2v, t2mas))
// end of [hidexp_tmpvar]

(* ****** ****** *)

implement
hidexp_foldat (loc, hse) =
  hidexp_make_node (loc, hse, hidexp_node_HDEfoldat())

implement
hidexp_freeat (loc, hse, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDEfreeat(hde))
// end of [hidexp_freeat]

(* ****** ****** *)

implement
hidexp_let (loc, hse, hids, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDElet(hids, hde))
// end of [hidexp_let]

(* ****** ****** *)

implement
hidexp_app
  (loc, hse, hse_fun, _fun, _arg) =
  hidexp_make_node (loc, hse, hidexp_node_HDEapp (_fun, hse_fun, _arg))
// end of [hidexp_app]


(* ****** ****** *)

implement
hidexp_app2 (
  loc0, hse, hse_fun, _fun, _arg
) = let
//
val isc = (
  if hidexp_node_is_HDEcst (_fun.hidexp_node()) then let
    val-~HDEcst (d2c) = hidexp_node_view (_fun.hidexp_node())
  in
    $D2E.d2cst_is_castfn (d2c)
  end else false
) : bool
//
in
//
if isc
  then let
    val-~HDEcst (d2c) = hidexp_node_view (_fun.hidexp_node())
    val hde = (
      if glist_is_cons (_arg)
        then glist_head<hidexp> (_arg)
        else let
          val loc = _fun.hidexp_loc()
        in
          hidexp_empty (loc, hisexp_void_t0ype())
        end // end of [list_nil]
    ) : hidexp // end of [val]
  in
    hidexp_castfn (loc0, hse, d2c, hde)
  end // end of [Some_vt]
  else hidexp_app (loc0, hse, hse_fun, _fun, _arg)
//
end // end of [hidexp_app2]

(* ****** ****** *)

implement
hidexp_rec2
(
  loc0, hse0, knd, lhdes, hse_rec
) = let
//
val isflt =
  (if knd = 0 then true else false): bool
//
in
//
if
isflt
then (
if glist_is_cons (lhdes) andalso glist_is_nil (glist_tail<labhidexp> (lhdes))
  then let val lhde = glist_head<labhidexp> (lhdes) in lhde.labhidexp_elt() end
  else hidexp_rec (loc0, hse0, knd, lhdes, hse_rec)
) (* end of [then] *)
else hidexp_rec (loc0, hse0, knd, lhdes, hse_rec)
//
end (* end of [hidexp_rec2] *)

(* ****** ****** *)

implement
hidexp_if
  (loc, hse, _cond, _then, _else) =
  hidexp_make_node (loc, hse, hidexp_node_HDEif (_cond, _then, _else))
// end of [hidexp_if]

implement
hidexp_sif
  (loc, hse, _cond, _then, _else) =
  hidexp_make_node (loc, hse, hidexp_node_HDEsif (_cond, _then, _else))
// end of [hidexp_sif]

(* ****** ****** *)

implement
hidexp_case
  (loc, hse, knd, hdes, hcls) =
  hidexp_make_node (loc, hse, hidexp_node_HDEcase (knd, hdes, hcls))
// end of [hidexp_case]

(* ****** ****** *)

implement
hidexp_lst
  (loc, hse, lin, hse_elt, hdes) =
  hidexp_make_node (loc, hse, hidexp_node_HDElst (lin, hse_elt, hdes))
// end of [hidexp_lst]

(* ****** ****** *)

implement
hidexp_rec
  (loc, hse, knd, lhdes, hse_rec) =
  hidexp_make_node (loc, hse, hidexp_node_HDErec (knd, lhdes, hse_rec))
// end of [hidexp_rec]

(* ****** ****** *)

implement
hidexp_seq
  (loc, hse, hdes) =
  hidexp_make_node (loc, hse, hidexp_node_HDEseq (hdes))
// end of [hidexp_seq]

(* ****** ****** *)

implement
hidexp_selab
  (loc, hse, hde, hse_flt, hils) =
  hidexp_make_node (loc, hse, hidexp_node_HDEselab (hde, hse_flt, hils))
// end of [hidexp_selab]

(* ****** ****** *)

implement
hidexp_ptrofvar
  (loc, hse, d2v) =
  hidexp_make_node (loc, hse, hidexp_node_HDEptrofvar (d2v))
// end of [hidexp_ptrofvar]

implement
hidexp_ptrofsel
  (loc, hse, hde, s2rt, hils) =
  hidexp_make_node (loc, hse, hidexp_node_HDEptrofsel (hde, s2rt, hils))
// end of [hidexp_ptrofsel]

(* ****** ****** *)

implement
hidexp_refarg
  (loc, hse, refval, freeknd, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDErefarg (refval, freeknd, hde))
// end of [hidexp_refarg]

(* ****** ****** *)

implement
hidexp_selvar
  (loc, hse, d2v, hse_rt, hils) =
  hidexp_make_node (loc, hse, hidexp_node_HDEselvar (d2v, hse_rt, hils))
// end of [hidexp_selvar]

implement
hidexp_selptr
  (loc, hse, hde, hse_rt, hils) =
  hidexp_make_node (loc, hse, hidexp_node_HDEselptr (hde, hse_rt, hils))
// end of [hidexp_selptr]

(* ****** ****** *)

implement
hidexp_assgn_var
  (loc, hse, d2v_l, hse_rt, hils, hde_r) =
  hidexp_make_node (loc, hse, hidexp_node_HDEassgn_var (d2v_l, hse_rt, hils, hde_r))
// end of [hidexp_assgn_var]

implement
hidexp_assgn_ptr
  (loc, hse, hde_l, hse_rt, hils, hde_r) =
  hidexp_make_node (loc, hse, hidexp_node_HDEassgn_ptr (hde_l, hse_rt, hils, hde_r))
// end of [hidexp_assgn_ptr]

(* ****** ****** *)

implement
hidexp_xchng_var
  (loc, hse, d2v_l, hse_rt, hils, hde_r) =
  hidexp_make_node (loc, hse, hidexp_node_HDExchng_var (d2v_l, hse_rt, hils, hde_r))
// end of [hidexp_xchng_var]

implement
hidexp_xchng_ptr
  (loc, hse, hde_l, hse_rt, hils, hde_r) =
  hidexp_make_node (loc, hse, hidexp_node_HDExchng_ptr (hde_l, hse_rt, hils, hde_r))
// end of [hidexp_xchng_ptr]

(* ****** ****** *)

implement
hidexp_arrpsz
(
  loc, hse, hse_elt, hdes_elt, asz
) = hidexp_make_node
  (loc, hse, hidexp_node_HDEarrpsz (hse_elt, hdes_elt, asz))
// end of [hidexp_arrpsz]

implement
hidexp_arrinit
(
  loc, hse, hse_elt, hde_asz, hdes_elt, asz
) = hidexp_make_node
  (loc, hse, hidexp_node_HDEarrinit (hse_elt, hde_asz, hdes_elt, asz))
// end of [hidexp_arrinit]

(* ****** ****** *)

implement
hidexp_raise
(loc, hse, hde_exn) =
hidexp_make_node(loc, hse, hidexp_node_HDEraise(hde_exn))
// end of [hidexp_raise]

(* ****** ****** *)
//
implement
hidexp_vararg
(loc, hse, hdes_arg) =
hidexp_make_node(loc, hse, hidexp_node_HDEvararg(hdes_arg))
//
(* ****** ****** *)
//
implement
hidexp_vcopyenv
  (loc, hse, d2v) =
  hidexp_make_node(loc, hse, hidexp_node_HDEvar(d2v))
//
(* ****** ****** *)
//
implement
hidexp_tempenver
  (loc, hse, d2vs) =
  hidexp_make_node(loc, hse, hidexp_node_HDEtempenver(d2vs))
//
(* ****** ****** *)

implement
hidexp_lam
(
  loc, hse, knd
, hips_arg, hde_body
) = hidexp_make_node
  (loc, hse, hidexp_node_HDElam (knd, hips_arg, hde_body))
// end of [hidexp_lam]

(* ****** ****** *)

implement
hidexp_fix
  (loc, hse, knd, f_d2v, hde_def) =
  hidexp_make_node (loc, hse, hidexp_node_HDEfix (knd, f_d2v, hde_def))
// end of [hidexp_fix]

(* ****** ****** *)
//
implement
hidexp_delay
  (loc, hse, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDEdelay (hde))
// end of [hidexp_delay]
implement
hidexp_ldelay
  (loc, hse, _eval, _free) =
  hidexp_make_node (loc, hse, hidexp_node_HDEldelay (_eval, _free))
// end of [hidexp_ldelay]
//
implement
hidexp_lazyeval
  (loc, hse, lin, hde) =
  hidexp_make_node (loc, hse, hidexp_node_HDElazyeval (lin, hde))
// end of [hidexp_lazyeval]
//
(* ****** ****** *)

implement
hidexp_loop
  (loc, hse, init, test, post, body) =
  hidexp_make_node (loc, hse, hidexp_node_HDEloop (init, test, post, body))
// end of [hidexp_loop]

implement
hidexp_loopexn
  (loc, hse, knd) =
  hidexp_make_node (loc, hse, hidexp_node_HDEloopexn (knd))
// end of [hidexp_loopexn]

(* ****** ****** *)

implement
hidexp_trywith
  (loc, hse, hde, hicls) =
  hidexp_make_node (loc, hse, hidexp_node_HDEtrywith (hde, hicls))
// end of [hidexp_trywith]

(* ****** ****** *)

implement
hidexp_errexp
  (loc, hse) = hidexp_make_node (loc, hse, hidexp_node_HDEerrexp ())
// end of [hidexp_errexp]

(* ****** ****** *)

(* ****** ****** *)

(* ****** ****** *)

(* ****** ****** *)



implement
hilab_lab (loc, lab) = hilab_new (loc, hilab_node_HILlab (lab))
implement
hilab_ind (loc, ind) = hilab_new (loc, hilab_node_HILind (ind))

(* ****** ****** *)

implement
higmat_make
  (loc, ghde, ghip) = higmat_new (loc, ghde, ghip)
// end of [higmat_make]

implement
hiclau_make
  (loc, hips, gua, seq, neg, body) =
  hiclau_new (loc, hips, gua, seq, neg, body)
// end of [hiclau_make]

(* ****** ****** *)

implement
hifundec_make
(
  loc, d2v, s2vs, def
) = hifundec_new (loc, d2v, s2vs, def, gopt_none (), gopt_none ())
// end of [hifundec_make]

(* ****** ****** *)

implement
hifundec_get_hideclopt (hfd) = hfd.hifundec_hidecl()

implement
hifundeclst_set_hideclopt
  (hfds, opt) = let
//
fun auxlst
(
  hfds: hifundeclst, opt: hideclopt
) : void =
  if glist_is_cons (hfds) then let
    val hfd = glist_head<hifundec> (hfds)
    val () = set_hifundec_hidecl (hfd, opt)
  in
    auxlst (glist_tail<hifundec> (hfds), opt)
  end else ()
//
in
  auxlst (hfds, opt)
end // end of [hifundeclst_set_hideclopt]

(* ****** ****** *)

implement
hivaldec_make
  (loc, pat, def) = hivaldec_new (loc, pat, def)
// end of [hivaldec_make]

implement
hivardec_make
(
  loc, knd
, d2v, d2vw, type, init
) = hivardec_new (loc, knd, d2v, d2vw, type, init)
// end of [hivardec_make]

(* ****** ****** *)

implement
hiimpdec_make
(
  loc, knd, d2c, imparg, tmparg, def
) = hiimpdec_new
  (loc, knd, d2c, imparg, tmparg, def, gopt_none (), gopt_none ())
// end of [hiimpdec_make]

(* ****** ****** *)

implement
hidecl_make_node
  (loc, node) = hidecl_new (loc, node)
// end of [hidecl_make_node]

implement
hidecl_none (loc) =
  hidecl_make_node (loc, hidecl_node_HIDnone())
// end of [hidecl_none]

implement
hidecl_list (loc, hids) =
  hidecl_make_node (loc, hidecl_node_HIDlist(hids))
// end of [hidecl_list]

(* ****** ****** *)
//
implement
hidecl_saspdec (loc, d2c) =
  hidecl_make_node (loc, hidecl_node_HIDsaspdec(d2c))
// end of [hidecl_saspdec]
implement
hidecl_reassume (loc, s2c) =
  hidecl_make_node (loc, hidecl_node_HIDreassume(s2c))
// end of [hidecl_reassume]
//
(* ****** ****** *)

implement
hidecl_extype
  (loc, name, hse_def) =
  hidecl_make_node (loc, hidecl_node_HIDextype(name, hse_def))
// end of [hidecl_extype]

implement
hidecl_extvar
  (loc, name, hde_def) =
  hidecl_make_node (loc, hidecl_node_HIDextvar(name, hde_def))
// end of [hidecl_extvar]

implement
hidecl_extcode
  (loc, knd, pos, code) =
  hidecl_make_node (loc, hidecl_node_HIDextcode(knd, pos, code))
// end of [hidecl_extcode]

(* ****** ****** *)

implement
hidecl_exndecs
  (loc, d2cs) =
  hidecl_make_node(loc, hidecl_node_HIDexndecs(d2cs))
// end of [hidecl_exndecs]

implement
hidecl_datdecs
  (loc, knd, s2cs) =
  hidecl_make_node(loc, hidecl_node_HIDdatdecs(knd, s2cs))
// end of [hidecl_datdecs]

(* ****** ****** *)

implement
hidecl_dcstdecs
  (loc, dck, d2cs) =
  hidecl_make_node (loc, hidecl_node_HIDdcstdecs (dck, d2cs))
// end of [hidecl_dcstdecs]

(* ****** ****** *)

implement
hidecl_impdec
  (loc, knd, himp) =
  hidecl_make_node (loc, hidecl_node_HIDimpdec (knd, himp))
// end of [hidecl_impdec]

(* ****** ****** *)

implement
hidecl_fundecs
  (loc, knd, decarg, hfds) =
  hidecl_make_node (loc, hidecl_node_HIDfundecs (knd, decarg, hfds))
// end of [hidecl_fundecs]

(* ****** ****** *)

implement
hidecl_valdecs (loc, knd, hvds) =
  hidecl_make_node (loc, hidecl_node_HIDvaldecs (knd, hvds))
// end of [hidecl_valdecs]

implement
hidecl_valdecs_rec (loc, knd, hvds) =
  hidecl_make_node (loc, hidecl_node_HIDvaldecs_rec (knd, hvds))
// end of [hidecl_valdecs_rec]

(* ****** ****** *)

implement
hidecl_vardecs (loc, hvds) =
  hidecl_make_node (loc, hidecl_node_HIDvardecs (hvds))
// end of [hidecl_vardecs]

(* ****** ****** *)

implement
hidecl_include
  (loc, knd, hids) =
  hidecl_make_node (loc, hidecl_node_HIDinclude (knd, hids))
// end of [hidecl_include]

(* ****** ****** *)

implement
hidecl_staload (
  loc, idopt, fname, flag, loaded, fenv
) = hidecl_make_node
  (loc, hidecl_node_HIDstaload (idopt, fname, flag, loaded, fenv))
// end of [hidecl_staload]

implement
hidecl_staloadloc
  (loc, pfil, nspace, hids) =
  hidecl_make_node (loc, hidecl_node_HIDstaloadloc (pfil, nspace, hids))
// end of [hidecl_staloadloc]

(* ****** ****** *)

implement
hidecl_dynload (loc, fil) =
  hidecl_make_node (loc, hidecl_node_HIDdynload (fil))
// end of [hidecl_dynload]

(* ****** ****** *)

implement
hidecl_local (loc, head, body) =
  hidecl_make_node (loc, hidecl_node_HIDlocal (head, body))
// end of [hidecl_local]

(* ****** ****** *)
//
// HX-2026-10: the address of a field of a record is the address of the
// cell plus 8 times its index in [pats_hidynexp.spec] (the cell is never moved)
//
implement
hifundec_getref_hideclopt (hfd) =
  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (hfd), i2sz(32)))
implement
hifundec_getref_funlabopt (hfd) =
  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (hfd), i2sz(40)))
implement
hiimpdec_getref_funlabopt (imp) =
  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (imp), i2sz(48)))
implement
hiimpdec_getref_instrlstopt (imp) =
  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (imp), i2sz(56)))

(* ****** ****** *)

implement
filenv_get_tmpcstimpmapopt (fenv) = let
  val p = $TRENV2.filenv_getref_tmpcstimpmap (fenv) in $UN.ptr0_get<tmpcstimpmapopt> (p)
end // end of [filenv_get_tmpcstimpmapopt]

implement
filenv_get_tmpvardecmapopt (fenv) = let
  val p = $TRENV2.filenv_getref_tmpvardecmap (fenv) in $UN.ptr0_get<tmpvardecmapopt> (p)
end // end of [filenv_get_tmpvardecmapopt]

(* ****** ****** *)

implement
tmpcstimpmap_find
  (map, d2c) = let
  val opt = d2cstmap_search<hiimpdeclst> (map, d2c)
in
//
case+ opt of
| ~Some_vt (imps) => imps | ~None_vt () => glist_nil ((*void*))
//
end // end of [tmpcstimpmap_find]

implement
tmpcstimpmap_insert
  (map, imp) = let
  val d2c = imp.hiimpdec_cst()
  val imps = tmpcstimpmap_find (map, d2c)
  val _(*found*) =
    d2cstmap_insert<hiimpdeclst> (map, d2c, glist_cons (imp, imps))
in
  // nothing
end // end of [tmpcstimpmap_insert]

(* ****** ****** *)

implement
tmpvardecmap_find
  (map, d2v) = d2varmap_search<hifundec> (map, d2v)
// end of [tmpvardecmap_find]

implement
tmpvardecmap_insert
  (map, hfd) = let
  val d2v = hfd.hifundec_var()
  val _(*found*) = d2varmap_insert<hifundec> (map, d2v, hfd)
in
  // nothing
end // end of [tmpvardecmap_insert]

implement
tmpvardecmap_inserts
  (map, hfds) = let
in
//
if glist_is_cons (hfds) then let
  val hfd = glist_head<hifundec> (hfds)
  val () = tmpvardecmap_insert (map, hfd)
in
  tmpvardecmap_inserts (map, glist_tail<hifundec> (hfds))
end else ()
//
end // end of [tmpvardecmap_inserts]

(* ****** ****** *)

(* end of [pats_hidynexp.dats] *)
