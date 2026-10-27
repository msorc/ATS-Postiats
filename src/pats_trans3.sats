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
// Start Time: April, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC. The interface of the whole type checker (the four groups of the port integrated, one declaration per function; see
// PORTING.md, "Level 3 translation, group 1..4" and "Level 3 integration"). [trans3err] (pats_trans3.spec: trans3err_T3E_xxx (..),
// trans3err_view) and the error list are first, then the blocks of the groups in the order of the integration.
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

staload "./pats_basics.sats"

staload
LOC = "./pats_location.sats"

staload
EFF = "./pats_effect.sats"
typedef effset = $EFF.effset

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dmacro2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)
//
#include "./pats_trans3_gen.hats"
//
(* ****** ****** *)

fun the_trans3errlst_add (x: trans3err): void
// HX-2026-10: the number of the errors added so far
// (for the hints of fold on demand)
fun the_trans3errlst_count ((*void*)): int
fun the_trans3errlst_finalize ((*void*)): void // cleanup all the errors

(* ****** ****** *)
//
// HX-2026-10: declared here because pats_trans3_env_dvar.dats ([d2var_mutablize]) calls it;
// implemented by the trans3 port proper (src/pats_trans3_dynexp_up.dats), by the test drivers until then
//
fun d2var_get_type_some
  (loc: $LOC.location, d2v: d2var): s2exp
// end of [d2var_get_type_some]

(* ****** ****** *)
//
// ===== BEGIN of group 2 (pats_trans3_dynexp_dn, _appsym, _caseof, _patcon) =====
// The declarations of src/pats_trans3.sats that these four modules implement,
// with the types of the arena port: [list (x, n)] is [glist (x)] (the index is dropped, D3-3),
// [list_vt] results are [glist]s too. See PORTING.md, "Level 3 translation, group 2".
//
fun d2exp_trdn (d2e: d2exp, s2e: s2exp): d3exp
fun d2explst_trdn_elt (d2es: d2explst, s2e: s2exp): d3explst
fun d2expopt_trdn_elt (od2e: d2expopt, s2e: s2exp): d3expopt
//
fun d2exp_trdn_rest (d2e: d2exp, s2f: s2hnf): d3exp
//
fun d2exp_trdn_ifhead (d2e: d2exp, s2f: s2hnf): d3exp
fun d2exp_trdn_sifhead (d2e: d2exp, s2f: s2hnf): d3exp
fun d2exp_trdn_ifcasehd (d2e: d2exp, s2f: s2hnf): d3exp
//
fun
c2laulst_trdn
(
  loc0: $LOC.location
, casknd: caskind
, invres: i2nvresstate
, c2ls: c2laulst
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
) : c3laulst // end of [c2laulst_trdn]
fun d2exp_trdn_casehead (d2e: d2exp, s2f: s2hnf): d3exp
fun d2exp_trdn_scasehead (d2e: d2exp, s2f: s2hnf): d3exp
//
fun d2exp_trdn_letwhere
(
  d2e0: d2exp, s2f0: s2hnf, d2cs: d2eclist, d2e_scope: d2exp
) : d3exp // end of [d2exp_trdn_letwhere]
//
fun
d2exp_trup_applst_sym
  (d2e0: d2exp, d2s: d2sym, _arg: d2exparglst): d3exp
fun
d2exp_trup_applst_tmpsym
(
  d2e0: d2exp, d2s: d2sym, t2mas: t2mpmarglst, _arg: d2exparglst
) : d3exp // end of [d2exp_trup_applst_tmpsym]
fun
d2exp_trup_applst_seloverld
  (d2e0: d2exp, _fun: d2exp, d2s: d2sym, _arg: d2exparglst): d3exp
//
fun p2at_trdn_con (p2t: p2at, s2f: s2hnf): p3at
//
// ===== END of group 2 =====

(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: ==== BEGIN group 1 of the trans3 port (pats_trans3_{dynexp_up,util,syncst}.dats) ====
// The declarations of src/pats_trans3.sats that these modules implement (names and order of the
// arguments as in ATS1; the proofs, the list indices and the closures are gone, see PORTING.md,
// "Level 3 translation, group 1 (dynexp_up/util/syncst)"). [d2var_get_type_some] is above.
//
(* ****** ****** *)

fun d3exp_linheap_check (d3e: d3exp): d3exp

(* ****** ****** *)

fun
d2exp_funclo_of_d2exp
  (d2e0: d2exp, fc0: &funclo): d2exp
// end of [d2exp_funclo_of_d2exp]

fun
d2exp_s2eff_of_d2exp
  (d2e0: d2exp, s2fe0: &s2eff? >> s2eff): d2exp
// end of [d2exp_s2eff_of_d2exp]

(* ****** ****** *)

fun d2exp_syn_type (d2e: d2exp): s2exp
fun d2explst_syn_type (d2es: d2explst): s2explst
fun labd2explst_syn_type (ld2es: labd2explst): labs2explst

(* ****** ****** *)

fun fshowtype_d3exp_up (d3e: d3exp): void
fun fshowtype_d3exp_dn (d3e: d3exp): void

(* ****** ****** *)

fun d3lablst_is_overld (d3ls: d3lablst): bool

(* ****** ****** *)

datavtype d23exp =
  | D23Ed2exp of d2exp | D23Ed3exp of d3exp
vtypedef d23explst = List0_vt (d23exp)

fun d23exp_free (x: d23exp): void
fun d23explst_free (xs: d23explst): void

fun d3exp_trdn (d3e: d3exp, s2f: s2exp): d3exp

fun d3explst_trdn_arg
  (d3es: d3explst, s2es: s2explst): d3explst
// end of [d3explst_trdn_arg]

(* ****** ****** *)
//
// HX-2026-10: proof-argument elision (pats_trans3_dynexp_up.dats):
// a call with no proof arguments of a function whose [npf] proof
// parameters are all preserved at-views (!T @ l)
//
// 0 if the first [npf] parameters are all preserved at-views;
// otherwise the position (1-based) of the first that is not
// (~1: elision unavailable, the test doubles of src/test)
fun s2explst_elide_test (npf: int, s2es: s2explst): int
// the parameters after the first [npf] ones
fun s2explst_elide_drop (npf: int, s2es: s2explst): s2explst
// the proofs found at the addresses of the first [npf] parameters
// (once the other arguments are checked: they determine the addresses)
fun d3explst_elide_proofs
  (locarg: $LOC.location, npf: int, s2es: s2explst): d3explst
//

(* ****** ****** *)
//
fun d2exp_trup_int (d2e0: d2exp, i: int): d3exp
//
fun intrep_syn_type // for dyn-patterns
  (loc0: loc_t, rep: string): s2exp // g0int
fun intrep_syn_type_ind // for dyn-expressions
  (loc0: loc_t, rep: string): s2exp // g1int
fun d2exp_trup_intrep (d2e0: d2exp, rep: string): d3exp
//
fun d2exp_trup_bool (d2e0: d2exp, b: bool): d3exp
fun d2exp_trup_char (d2e0: d2exp, c: char): d3exp
fun d2exp_trup_string (d2e0: d2exp, str: string): d3exp
//
fun float_syn_type
  (loc0: loc_t, rep: string): s2exp
fun d2exp_trup_float (d2e0: d2exp, rep: string): d3exp
//
fun i0nt_syn_type (x: i0nt): s2exp // g0int ...
fun i0nt_syn_type_ind (x: i0nt): s2exp // g1int ...
fun d2exp_trup_i0nt (d2e0: d2exp, x: i0nt): d3exp
//
fun f0loat_syn_type (x: f0loat): s2exp
fun d2exp_trup_f0loat (d2e0: d2exp, x: f0loat): d3exp
//
(* ****** ****** *)

fun cstsp_syn_type
  (d2e0: d2exp, x: cstsp): s2exp
fun d2exp_trup_cstsp
  (d2e0: d2exp, x: cstsp): d3exp
// end of [d2exp_trup_cstsp]

(* ****** ****** *)
//
fun d2exp_trup_tyrep
  (d2e0: d2exp, s2e_rep: s2exp): d3exp
//
(* ****** ****** *)
//
fun d2exp_trup_literal
  (d2e0: d2exp, d2e_lit: d2exp): d3exp
//
(* ****** ****** *)

fun d2exp_trup_cst (loc: loc_t, d2c: d2cst): d3exp
fun d2exp_trup_var (loc: loc_t, d2v: d2var): d3exp
fun d2exp_trup_var_mutabl (loc: loc_t, d2v: d2var): d3exp
fun d2exp_trup_var_nonmut (loc: loc_t, d2v: d2var): d3exp

(* ****** ****** *)

fun d2exp_trup_tmpcst
  (loc0: loc_t, d2c: d2cst, t2mas: t2mpmarglst): d3exp
// end of [d2exp_trup_tmpcst]

fun d2exp_trup_tmpvar
  (loc0: loc_t, d2v: d2var, t2mas: t2mpmarglst): d3exp
// end of [d2exp_trup_tmpvar]

(* ****** ****** *)

fun d2exp_trup_applst
  (d2e0: d2exp, _fun: d2exp, _arg: d2exparglst): d3exp
// end of [d2exp_trup_applst]

fun d23exp_trup_applst
  (d2e0: d2exp, _fun: d3exp, _arg: d2exparglst): d3exp
// end of [d23exp_trup_applst]

(* ****** ****** *)

fun d3explst_get_ind (d3es: d3explst): s2explst

(* ****** ****** *)

fun d2exp_trup (d2e: d2exp): d3exp
fun d2explst_trup (d2es: d2explst): d3explst

(* ****** ****** *)

fun
funarg_patck_exhaust
(
  loc0: location, p2ts_arg: p2atlst, s2es_arg: s2explst
) : void // end of [funarg_patck_exhaust]

(* ****** ****** *)
//
// HX-2026-10: ==== END group 1 ====
//

(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: BEGIN of the declarations of GROUP 3 of the trans3 port
// (pats_trans3_p2at, _selab, _fldfrat, _lvalres), see PORTING.md,
// "Level 3 translation, group 3 (p2at/selab/fldfrat/lvalres)".
// The lists carry no length index (D3-3): [list (T, n)] of src/pats_trans3.sats is [glist (T)].
//
(* ****** ****** *)

fun p2at_syn_type (p2t: p2at): s2exp
fun p2atlst_syn_type (p2ts: p2atlst): s2explst

(* ****** ****** *)
//
fun p2at_trup_arg (p2t: p2at): p3at
fun p2atlst_trup_arg
  (npf: int, p2ts: p2atlst): p3atlst
//
fun p2at_trdn_arg (p2t: p2at, s2e: s2exp): p3at
fun p2atlst_trdn_arg (
  loc: $LOC.location, npf: int
, p2ts: p2atlst, s2es: s2explst, serr: &int
) : p3atlst // end of [p2atlst_trdn_arg]
//
fun p2at_trdn (p2t: p2at, s2e: s2exp): p3at
fun p2atlst_trdn (
  loc: $LOC.location
, p2ts: p2atlst, s2es: s2explst, serr: &int
) : p3atlst // end of [p2atlst_trdn]
//
fun guard_trdn
  (loc: $LOC.location, gval: bool, gtyp: s2exp): void
// end of [guard_trdn]

(* ****** ****** *)

fun d2lab_trup (d2l: d2lab) : d3lab
fun d2lablst_trup (d2ls: d2lablst) : d3lablst

(* ****** ****** *)

fun s2exp_get_dlablst_linrest_sharing
(
  loc0: $LOC.location, s2e: s2exp, d3ls: d3lablst, linrest: &int, sharing: &int
) : @(s2exp, s2explst_vt) // end of [fun]

fun d2exp_trup_selab
  (loc0: $LOC.location, tup: d2exp, labs: d2lablst): d3exp
// end of [d2exp_trup_selab]

(* ****** ****** *)

fun d2exp_trup_foldat (d2e0: d2exp): d3exp
fun d2exp_trup_freeat (d2e0: d2exp): d3exp
//
// HX-2026-10: fold on demand: [d2var_foldat_try (loc0, d2v)] folds the
// unfolded variable [d2v] as [fold@ (d2v)] would; if [fold@] cannot be
// applied, it reports nothing and leaves the state unchanged (the result:
// false)
//
fun d2var_foldat_try (loc0: $LOC.location, d2v: d2var): bool
//
// HX-2026-10: [d3e0] has been given the unfolded type [s2e] by the pattern
// [p3t]: the views of the fields are registered with [d3e0] (a variable)
//
fun d3lval_autofold_register
  (d3e0: d3exp, s2e: s2exp, p3t: p3at): void

(* ****** ****** *)

fun
s2exp_get_dlablst_context
(
  loc0: $LOC.location, s2e: s2exp, d3ls: d3lablst, context: &s2ctxtopt
) : s2exp (*selected*) // endfun

fun
s2exp_get_dlablst_context_check
(
  loc0: $LOC.location, s2e: s2exp, d3ls: d3lablst, context: &s2ctxtopt
) : @(s2exp, s2explst_vt) // endfun

(* ****** ****** *)

fun
s2addr_exch_type
(
  loc0: $LOC.location
, s2l: s2exp, d3ls: d3lablst, s2e_new: s2exp
) : s2exp(*old*) // end of [s2addr_exch_type]

(* ****** ****** *)

fun d3lval_set_type_err (
  refval: int, d3e: d3exp, s2e: s2exp, err: &int
) : void // end of [d3lval_set_type_err]

fun d3lval_set_pat_type_left
  (d3e0: d3exp, p3t: p3at): void // end of [fun]
fun d3lvalist_set_pat_type_left
  (d3es: d3explst, p3ts: p3atlst): void // end of [fun]

(* ****** ****** *)

fun d3lval_arg_set_type
  (refval: int, d3e0: d3exp, s2e: s2exp): int (*freeknd*)
// end of [d3lval_arg_set_type]

(* ****** ****** *)

fun d3exp_fun_restore (fc: funclo, d3e_fun: d3exp): d3exp

fun d3explst_arg_restore (
  d3es: d3explst, s2es_arg: s2explst, wths2es: wths2explst
) : d3explst // end of [d3explst_arg_restore]

(* ****** ****** *)
//
// HX-2026-10: END of the declarations of GROUP 3
//
(* ****** ****** *)

(* ****** ****** *)
//
// ==== BEGIN group 4 of the trans3 port (decl, looping, assgn, deref, ptrof, viewat, xchng) ====
// The exports of pats_trans3_{decl,looping,assgn,deref,ptrof,viewat,xchng}.dats, with the names and the argument
// orders of src/pats_trans3.sats (PORTING.md, "Level 3 translation, group 4"). No proofs, flat tuples,
// [glist] for the lists of the trees; an uninitialized [&s2exp? >> s2exp] stays as it is.
//
(* ****** ****** *)

fun d2ecl_tr (d2c: d2ecl): d3ecl
fun d2eclist_tr (d2cs: d2eclist): d3eclist

fun d2eclist_tr_errck (d2cs: d2eclist): d3eclist

(* ****** ****** *)

fun
d2exp_trup_loop
(
  loc: location
, inv: loopi2nv
, init: d2expopt, test: d2exp, post: d2expopt, body: d2exp
) : d3exp // end of [d2exp_trup_loop]

fun d2exp_trup_loopexn (loc: location, knd: int): d3exp

(* ****** ****** *)

fun d2exp_trup_assgn (d2e0: d2exp): d3exp

fun d2exp_trup_assgn_deref
(
  loc0: location, d2e_l: d2exp, d2ls: d2lablst, d2e_r: d2exp
) : d3exp // end of [d2exp_trup_assgn_deref]

fun
s2addr_assgn_deref
(
  loc0: location
, s2l: s2exp, d3ls: d3lablst, d3e_r: d3exp, s2rt: &s2exp? >> s2exp
) : d3exp(*rval*) // end of [s2addr_assgn_deref]

(* ****** ****** *)

fun
d2exp_trup_deref
(
  loc0: location, d2s: d2sym, d2e: d2exp, d2ls: d2lablst
) : d3exp // end of [d2exp_trup_deref]

fun s2addr_deref
(
  loc0: location, s2l: s2exp, d3ls: d3lablst, s2rt: &s2exp? >> s2exp
) : s2exp(*selected elt*) // end of [s2addr_deref]

(* ****** ****** *)

fun d2exp_trup_ptrof (d2e0: d2exp): d3exp

(* ****** ****** *)

fun d2exp_trup_xchng (d2e0: d2exp): d3exp

fun
d2exp_trup_xchng_deref
(
  loc0: location, d2e_l: d2exp, d2ls: d2lablst, d2e_r: d2exp
) : d3exp // end of [d2exp_trup_xchng_deref]

fun
s2addr_xchng_deref
(
  loc0: location
, s2l: s2exp, d3ls: d3lablst, d2e_r: d2exp, s2rt: &s2exp? >> s2exp
) : d3exp(*rval*) // end of [s2addr_xchng_deref]

fun d2exp_trdn_xchng
  (loc0: location, d2e: d2exp, s2f: s2hnf): d3exp
fun d2exp_trdn_xchng_deref
(
  loc0: location, loc: location, d2e: d2exp, d2ls: d2lablst, s2f: s2hnf
) : d3exp // end of [d2exp_trdn_xchng_deref]

fun s2addr_xchng_check
(
  loc0: location, loc: location(*right*)
, s2l: s2exp, d3ls: d3lablst, s2f: s2hnf, s2rt: &s2exp? >> s2exp
) : s2exp // end of [s2addr_xchng_check]

(* ****** ****** *)

fun d2exp_trup_viewat (d2e0: d2exp): d3exp
fun d2exp_trup_viewat_assgn (d2e0: d2exp): d3exp

fun s2addr_viewat_deref
  (loc0: location, s2l: s2exp, d3ls: d3lablst): s2exp(*atview*)
// end of [s2addr_viewat_deref]

fun s2addr_set_viewat
(
  loc0: location
, s2l: s2exp, d3ls: d3lablst, s2at_new: s2exp
) : void // end of [s2addr_set_viewat]
fun s2addr_set_viewat_check
(
  loc0: location
, s2l: s2exp, d3ls: d3lablst, s2at_new: s2exp
, s2e_old: s2exp, s2e_new: s2exp, s2l_new: s2exp
) : void // end of [s2addr_set_viewat_check]

(* ****** ****** *)
//
// ==== END group 4 ====
//
(* ****** ****** *)

(* end of [pats_trans3.sats] *)
