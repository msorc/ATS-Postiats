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
// HX-2026-10: no GC
// The level-1 static syntax (ATS2 port of src/pats_staexp1.sats). The records
// '{x_loc=.., x_node=..} and the datatypes of the ATS1 version are generated
// by arenagen (--global --compact) from [pats_staexp1.spec] into the global
// arena; the names of the fields and the constructors are unchanged (read
// PORTING.md, section "Arena AST"): [x.s1exp_node()], [s1exp_new(loc, node)],
// [s1exp_node_S1Eide(sym)], [case+ s1exp_node_view(..) of ~S1Eide(..) => ..].
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)
//
staload
INTINF = "./pats_intinf.sats"
typedef intinf = $INTINF.intinf
//
staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename
staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location
typedef location = $LOC.location
//
(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
typedef symbolist = $SYM.symbolist
typedef symbolopt = $SYM.symbolopt

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_effect.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)
//
typedef effvar = i0de
//
// HX-2015-08:
// for placeholding
//
abstype
S1Ed2ctype_type = ptr
typedef
S1Ed2ctype = S1Ed2ctype_type
//
(* ****** ****** *)
//
// the generated types: v1al, e1xp_node, e1xp, effcst, s1rt, s1exp, ...
// and the typedefs of their lists and options (see [pats_staexp1.spec])
//
#include "./pats_staexp1_gen.hats"
//
(* ****** ****** *)

val v1al_true : v1al = "ext#patsopt_v1al_true"
val v1al_false : v1al = "ext#patsopt_v1al_false"

fun print_v1al (x: v1al): void
fun prerr_v1al (x: v1al): void
fun fprint_v1al (out: FILEref, x: v1al): void

(* ****** ****** *)

(* ****** ****** *)
//
fun print_e1xp (_: e1xp): void
fun prerr_e1xp (_: e1xp): void
fun fprint_e1xp (out: FILEref, x: e1xp): void
//
overload print with print_e1xp
overload prerr with prerr_e1xp
overload fprint with fprint_e1xp
//
fun print_e1xplst (_: e1xplst): void
fun prerr_e1xplst (_: e1xplst): void
fun fprint_e1xplst (out: FILEref, x: e1xplst): void
//
overload print with print_e1xplst
overload prerr with prerr_e1xplst
overload fprint with fprint_e1xplst
//
(* ****** ****** *)
//
fun e1xp_make
  (loc: location, node: e1xp_node): e1xp
// end of [e1xp_make]
//
(* ****** ****** *)
//
fun e1xp_ide (loc: location, sym: symbol): e1xp
//
fun e1xp_int (loc: location, i: int): e1xp
fun e1xp_intrep (loc: location, rep: string): e1xp
//
fun e1xp_char (loc: location, c: char): e1xp
fun e1xp_float (loc: location, rep: string): e1xp
fun e1xp_string (loc: location, str: string): e1xp
//
fun e1xp_i0nt (loc: location, x: i0nt): e1xp
fun e1xp_c0har (loc: location, x: c0har): e1xp
fun e1xp_s0tring (loc: location, x: s0tring): e1xp
fun e1xp_f0loat (loc: location, x: f0loat): e1xp
//
fun e1xp_v1al (loc: location, v: v1al): e1xp
//
fun e1xp_none (loc: location): e1xp
fun e1xp_undef (loc: location): e1xp
//
fun
e1xp_app
(
  loc: location
, _fun: e1xp, loc_arg: location, _arg: e1xplst
) : e1xp // end of [e1xp_app]
//
fun
e1xp_fun
  (loc: location, arg: symbolist, body: e1xp): e1xp
// end of [e1xp_fun]
//
fun e1xp_if
(
  loc: location, _cond: e1xp, _then: e1xp, _else: e1xp
) : e1xp // end of [e1xp_if]
//
fun e1xp_eval (loc: location, e: e1xp): e1xp
fun e1xp_list (loc: location, es: e1xplst): e1xp
//
fun e1xp_err (loc: location): e1xp
//
fun e1xp_true (loc: location): e1xp
and e1xp_false (loc: location): e1xp
//
(* ****** ****** *)

val effcst_nil : effcst = "ext#patsopt_effcst_nil"
val effcst_all : effcst = "ext#patsopt_effcst_all"
val effcst_ntm : effcst = "ext#patsopt_effcst_ntm"
val effcst_exn : effcst = "ext#patsopt_effcst_exn"
val effcst_ref : effcst = "ext#patsopt_effcst_ref"
val effcst_wrt : effcst = "ext#patsopt_effcst_wrt"

fun effcst_contain
  (efc: effcst, eff: effect): bool
fun effcst_contain_ntm (efc: effcst): bool

fun fprint_effcst (out: FILEref, x: effcst): void

(* ****** ****** *)

(* ****** ****** *)

fun print_s1rt (_: s1rt): void
overload print with print_s1rt
fun prerr_s1rt (_: s1rt): void
overload prerr with prerr_s1rt
fun fprint_s1rt (out: FILEref, x: s1rt): void

fun print_s1rtlst (_: s1rtlst): void
overload print with print_s1rtlst
fun prerr_s1rtlst (_: s1rtlst): void
overload prerr with prerr_s1rtlst
fun fprint_s1rtlst (out: FILEref, x: s1rtlst): void

fun fprint_s1rtopt (out: FILEref, x: s1rtopt): void

fun fprint_s1rtlstlst (out: FILEref, x: s1rtlstlst): void

(* ****** ****** *)

(*
** HX: functions for constructing sorts
*)

fun s1rt_arrow (loc: location): s1rt

//
// HX: '->' is a special sort constructor
//
fun s1rt_is_arrow (s1t: s1rt): bool

fun s1rt_app (
  loc: location, _fun: s1rt, _arg: s1rtlst
) : s1rt // end of [s1rt_app]

fun s1rt_fun (
  loc: location, arg: s1rt, res: s1rt
) : s1rt // end of [s1rt_fun]

fun s1rt_ide (loc: location, sym: symbol): s1rt
fun s1rt_list (loc: location, s1ts: s1rtlst): s1rt
fun s1rt_qid (loc: location, q: s0rtq, id: symbol): s1rt
(*
fun s1rt_tup (loc: location, s1ts: s1rtlst): s1rt
*)
fun s1rt_type (loc: location, knd: int): s1rt

fun s1rt_err (loc: location): s1rt // HX: indicating an error

(* ****** ****** *)

fun s1rtpol_make (loc: location, s1t: s1rt, pol: int): s1rtpol

(* ****** ****** *)

fun d1atsrtcon_make (
  loc: location, name: symbol, arg: s1rtlst
) : d1atsrtcon // end of [d1atsrtcon_make]

fun fprint_d1atsrtcon (out: FILEref, x: d1atsrtcon): void

(* ****** ****** *)

fun
d1atsrtdec_make
(
  loc: location, name: symbol, conlst: d1atsrtconlst
) : d1atsrtdec // end of [d1atsrtdec]

fun fprint_d1atsrtdec (out: FILEref, x: d1atsrtdec): void

(* ****** ****** *)

fun
s1arg_make
(
  loc: location, sym: symbol, srtopt: s1rtopt
) : s1arg // end of [s1arg_make]

fun fprint_s1arg (out: FILEref, x: s1arg): void
fun fprint_s1arglst (out: FILEref, x: s1arglst): void

(* ****** ****** *)

fun s1marg_make (loc: location, s1as: s1arglst): s1marg

fun fprint_s1marg (out: FILEref, x: s1marg): void

(* ****** ****** *)

fun s1var_make (loc: location, sym: symbol, srt: s1rt): s1var

fun fprint_s1var (out: FILEref, x: s1var): void

(* ****** ****** *)

fun a1srt_make (
  loc: location, sym: symbolopt, srt: s1rt
) : a1srt // end of [a1srt_make]

fun fprint_a1srt (out: FILEref, x: a1srt): void
fun fprint_a1srtlst (out: FILEref, x: a1srtlst): void

fun a1msrt_make (loc: location, arg: a1srtlst): a1msrt

fun fprint_a1msrt (out: FILEref, x: a1msrt): void
fun fprint_a1msrtlst (out: FILEref, x: a1msrtlst): void

(* ****** ****** *)
//
fun sp1at_arg (loc: location, arg: s1arg): sp1at
fun sp1at_cstr
  (loc: location, q: s0taq, id: symbol, args: s1arglst): sp1at
// end of [sp1at_cstr]
//
(* ****** ****** *)
//
// HX-2015-08:
// for placeholding
//
(* ****** ****** *)

(* ****** ****** *)

fun s1exp_int
  (loc: location, i: int): s1exp
fun s1exp_intrep
  (loc: location, rep: string): s1exp
fun s1exp_i0nt
  (loc: location, x: i0nt): s1exp

fun s1exp_char (loc: location, c: char): s1exp
fun s1exp_c0har (loc: location, tok: c0har): s1exp

fun s1exp_float (loc: location, rep: string): s1exp
fun s1exp_f0loat (loc: location, tok: f0loat): s1exp

fun s1exp_string (loc: location, str: string): s1exp
fun s1exp_s0tring (loc: location, tok: s0tring): s1exp

(* ****** ****** *)

fun
s1exp_extype
(
  loc: location, name: string, arg: s1explstlst
) : s1exp // end of [s1exp_extype]
fun
s1exp_extkind
(
  loc: location, name: string, arg: s1explstlst
) : s1exp // end of [s1exp_extkind]

(* ****** ****** *)

fun s1exp_ide (loc: location, id: symbol): s1exp
fun s1exp_sqid (loc: location, sq: s0taq, id: symbol): s1exp

fun s1exp_app (
  loc: location, _fun: s1exp, loc_arg: location, _arg: s1explst
) : s1exp // end of [s1exp_app]
fun s1exp_lam (
  loc: location, arg: s1marg, res: s1rtopt, body: s1exp
) : s1exp // end of [s1exp_lam]
fun s1exp_imp (
  loc: location, fc: funclo, lin: int, prf: int, efc: effcstopt
) : s1exp // end of [s1exp_imp]

fun s1exp_list
  (loc: location, xs: s1explst): s1exp
fun s1exp_list2
  (loc: location, xs1: s1explst_vt, xs2: s1explst_vt): s1exp
fun s1exp_npf_list
  (loc: location, npf: int, xs: s1explst): s1exp
// end of [s1exp_npf_list]

fun s1exp_top (loc: location, knd: int, s1e: s1exp): s1exp

fun s1exp_invar (loc: location, knd: int, s1e: s1exp): s1exp
fun s1exp_trans (loc: location, s1e1: s1exp, s1e2: s1exp): s1exp

fun s1exp_tyarr (
  loc: location, elt: s1exp, dim: s1explst
) : s1exp // end of [s1exp_tyarr]
fun s1exp_tytup (
  loc: location, knd: int, npf: int, s1es: s1explst
) : s1exp // end of [s1exp_tytup]
fun s1exp_tyrec (
  loc: location, knd: int, npf: int, ls1es: labs1explst
) : s1exp // end of [s1exp_tyrec]
fun s1exp_tyrec_ext (
  loc: location, name: string, npf: int, ls1es: labs1explst
) : s1exp // end of [s1exp_tyrec_ext]

fun s1exp_uni
  (loc: location, qua: s1qualst, body: s1exp): s1exp
fun s1exp_exi
  (loc: location, knd: int, qua: s1qualst, body: s1exp): s1exp

fun s1exp_ann (loc: location, s1e: s1exp, s1t: s1rt): s1exp

fun s1exp_d2ctype (loc: location, d2ctp: S1Ed2ctype): s1exp

fun s1exp_err (loc: location): s1exp // HX: indication of error

(* ****** ****** *)

fun print_s1exp (x: s1exp): void
overload print with print_s1exp
fun prerr_s1exp (x: s1exp): void
overload prerr with prerr_s1exp
fun fprint_s1exp (out: FILEref, x: s1exp): void

fun fprint_s1explst (out: FILEref, x: s1explst): void
fun fprint_s1expopt (out: FILEref, x: s1expopt): void

(* ****** ****** *)

fun labs1exp_make
  (l: l0ab, name: s0tringopt, s1e: s1exp): labs1exp
// end of [labs1exp_make]

fun fprint_labs1exp (out: FILEref, x: labs1exp): void
fun fprint_labs1explst (out: FILEref, x: labs1explst): void

(* ****** ****** *)

fun s1rtext_srt (loc: location, s1t: s1rt): s1rtext
fun s1rtext_sub (
  loc: location, sym: symbol, s1te: s1rtext, s1ps: s1explst
) : s1rtext // end of [s1rtext_sub]

fun fprint_s1rtext (out: FILEref, x: s1rtext): void

(* ****** ****** *)

fun s1qua_prop (loc: location, s1p: s1exp): s1qua
fun s1qua_vars
  (loc: location, ids: i0delst, s1te: s1rtext): s1qua
// end of [s1qua_vars]

fun fprint_s1qua (out: FILEref, x: s1qua): void
fun fprint_s1qualst (out: FILEref, x: s1qualst): void

(* ****** ****** *)
//
fun s1exp_make_v1al (loc: location, v: v1al): s1exp
fun s1exp_make_e1xp (loc: location, e: e1xp): s1exp
//
fun e1xp_make_s1exp (loc: location, s1e: s1exp): e1xp
//
(* ****** ****** *)

fun wths1explst_is_none (wths1es: wths1explst): bool
fun wths1explst_reverse (wths1es: wths1explst): wths1explst

(* ****** ****** *)

fun print_s1vararg (x: s1vararg): void
fun prerr_s1vararg (x: s1vararg): void
fun fprint_s1vararg (out: FILEref, x: s1vararg): void

(* ****** ****** *)

fun s1exparg_one (loc: location): s1exparg
fun s1exparg_all (loc: location): s1exparg
fun s1exparg_seq (loc: location, xs: s1explst): s1exparg

fun fprint_s1exparg (out: FILEref, x: s1exparg): void
fun fprint_s1exparglst (out: FILEref, x: s1exparglst): void
overload fprint with fprint_s1exparg
overload fprint with fprint_s1exparglst

(* ****** ****** *)

fun m1acarg_make_dyn
  (loc: location, darg: i0delst): m1acarg
fun m1acarg_make_sta
  (loc: location, sarg: s1arglst): m1acarg

(* ****** ****** *)

(* ****** ****** *)

fun s1rtdef_make (loc: location, sym: symbol, s0te: s1rtext): s1rtdef

fun fprint_s1rtdef (out: FILEref, x: s1rtdef): void

(* ****** ****** *)
//
fun
s1tacst_make (
  loc: location
, fil: filename, sym: symbol
, arg: a1msrtlst, res: s1rt, extdef: scstextdef
) : s1tacst // end of [s1tacst_make]
//
fun fprint_s1tacst (out: FILEref, x: s1tacst): void
//
(* ****** ****** *)

fun
s1tacon_make (
  loc: location
, fil: filename, sym: symbol, arg: a1msrtlst, def: s1expopt
) : s1tacon // end of [s1tacon]

fun fprint_s1tacon (out: FILEref, x: s1tacon): void

(* ****** ****** *)

(*
//
// HX-2012-05-23: removed
//
fun s1tavar_make (loc: location, id: symbol, srt: s1rt): s1tavar

fun fprint_s1tavar (out: FILEref, x: s1tavar): void
*)

(* ****** ****** *)

fun t1kindef_make (
  loc: location, id: symbol, loc_id: location, def: s1exp
) : t1kindef // end of [t1kindef_make]

(* ****** ****** *)

fun s1expdef_make (
  loc: location
, id: symbol
, loc_id: location
, arg: s1marglst, res: s1rtopt, def: s1exp
) : s1expdef // end of [s1expdef_make]

fun fprint_s1expdef (out: FILEref, x: s1expdef): void

(* ****** ****** *)

fun s1aspdec_make (
  loc: location
, qid: sqi0de, arg: s1marglst, res: s1rtopt, def: s1exp
) : s1aspdec // end of [s1aspdec_make]

fun fprint_s1aspdec (out: FILEref, x: s1aspdec): void

(* ****** ****** *)

fun q1marg_make (loc: location, xs: s1qualst): q1marg

fun fprint_q1marg (out: FILEref, x: q1marg): void
fun fprint_q1marglst (out: FILEref, x: q1marglst): void

(* ****** ****** *)

fun i1mparg_sarglst (arg: s1arglst): i1mparg
fun i1mparg_svararglst (arg: s1vararglst): i1mparg

fun fprint_i1mparg (out: FILEref, x: i1mparg): void

(* ****** ****** *)
//
fun t1mpmarg_make (loc: location, arg: s1explst): t1mpmarg
//
(* ****** ****** *)

fun d1atcon_make (
  loc: location
, id: symbol
, qua: q1marglst
, npf: int, arg: s1explst
, ind: s1explstopt
) : d1atcon // end of [d1atcon_make]

fun fprint_d1atcon (out: FILEref, x: d1atcon): void

(* ****** ****** *)

fun d1atdec_make (
  loc: location
, fil: filename
, id: symbol
, arg: a1msrtlst
, con: d1atconlst
) : d1atdec // end of [d1atdec_make]

fun fprint_d1atdec (out: FILEref, x: d1atdec): void

(* ****** ****** *)

fun e1xndec_make (
  loc: location
, fil: filename
, id: symbol
, qua: q1marglst
, npf: int, arg: s1explst
) : e1xndec // end of [e1xndec_make]

fun fprint_e1xndec (out: FILEref, x: e1xndec): void

(* ****** ****** *)

fun
d1cstdec_make
(
  loc: location
, fil: filename
, sym: symbol, s1e: s1exp, extdef: dcstextdef
) : d1cstdec // end of [d1cstdec_make]

fun fprint_d1cstdec (out: FILEref, x: d1cstdec): void

(* ****** ****** *)

(* end of [pats_staexp1.sats] *)

