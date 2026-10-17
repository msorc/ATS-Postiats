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

(* ****** ****** *)
//
// HX-2026-10: no GC
//
// The level-0 syntax tree of ATS. The ATS1 records '{x_loc=.., x_node=..}
// and datatypes x_node are stored in the global arena (see [pats_syntax.spec]
// and [utils/arenagen]); the ATS1 names of the fields and the constructors
// are kept (read PORTING.md, section "Arena AST"):
//
//   x.s0exp_loc()                 (* field access, was x.s0exp_loc *)
//   s0exp_new(loc, node)          (* was '{s0exp_loc= loc, s0exp_node= node} *)
//   s0exp_node_S0Eapp(a, b)       (* was S0Eapp(a, b) *)
//   case+ s0exp_node_view(x.s0exp_node()) of ~S0Eapp(a, b) => .. (* was case+ x.s0exp_node of *)
//
(* ****** ****** *)

staload "./pats_basics.sats"
staload "libats/SATS/arena.sats"

(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location
typedef location = $LOC.location
//
staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
typedef symbolist = $SYM.symbolist
typedef symbolopt = $SYM.symbolopt
//
staload
LAB = "./pats_label.sats"
typedef label = $LAB.label
//
staload
FIX = "./pats_fixity.sats"
typedef assoc = $FIX.assoc
//
staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename
//
(* ****** ****** *)
staload LEX = "./pats_lexing.sats"
typedef token = $LEX.token
typedef tokenopt = $LEX.tokenopt
//
(* ****** ****** *)
//
abstype synent_type = ptr // a boxed union
typedef synent = synent_type
//
castfn
synent_encode{a:type}(x: a): synent
castfn
synent_decode{a:type}(x: synent): (a)
//
fun{a:type} synent_null(): a // = null
fun{a:type} synent_is_null(x: a): bool
fun{a:type} synent_isnot_null(x: a): bool
//
(* ****** ****** *)
//
datatype
srpifkind =
  | SRPIFKINDif | SRPIFKINDifdef | SRPIFKINDifndef
//
datatype
macsynkind =
  | MSKencode
  | MSKdecode
  | MSKxstage // HX: cross-stage persistence: decode(lift(.))
//
fun print_macsynkind (x: macsynkind): void
fun prerr_macsynkind (x: macsynkind): void
fun fprint_macsynkind (out: FILEref, x: macsynkind): void
//
datatype
cstsp = // special constants
  | CSTSPmyfil (* the filename where $myfile appears *)
  | CSTSPmyloc (* the location where $mylocation appears *)
  | CSTSPmyfun (* the function name where $myfunction appears *)
//
datatype
e0xpactkind =
 | E0XPACTerror
 | E0XPACTprerr
 | E0XPACTprint
 | E0XPACTassert
//
fun fprint_e0xpactkind (out: FILEref, x: e0xpactkind): void
//
(* ****** ****** *)
//
typedef i0nt = token
typedef c0har = token
typedef f0loat = token
typedef s0tring = token
//
// HX-2015-08: for placeholding
//
abstype
S0Ed2ctype_type = ptr
typedef
S0Ed2ctype = S0Ed2ctype_type
//
(* ****** ****** *)
//
// the generated types: i0de, s0exp_node, s0exp, d0exp, d0ecl, ...
// and the typedefs of their lists and options
//
#include "./pats_syntax_gen.hats"
//
(* ****** ****** *)

(*
datatype lamkind =
  | LAMKINDlam of location
  | LAMKINDlamat of location
  | LAMKINDllam of location
  | LAMKINDllamat of location
  | LAMKINDfix of location
  | LAMKINDfixat of location
  | LAMKINDifix of (location) // HX: implicit FIX
*)
#define LAMKINDifix (~1)
fun lamkind_isbox (knd: int): int
fun lamkind_islin (knd: int): int

fun fprint_cstsp (out: FILEref, x: cstsp): void

fun i0nt2int (x: i0nt): int

fun fprint_i0nt (out: FILEref, x: i0nt): void
fun fprint_c0har (out: FILEref, x: c0har): void
fun fprint_f0loat (out: FILEref, x: f0loat): void
fun fprint_s0tring (out: FILEref, x: s0tring): void

fun e0fftag_i0de (_: i0de): e0fftag
fun e0fftag_i0nt (_: i0nt): e0fftag
fun e0fftag_cst (i: int, _: i0de): e0fftag
fun e0fftag_var_fun (t_fun: token): e0fftag

fun s0rtq_none (loc: location): s0rtq
fun s0rtq_symdot (ent1: i0de, tok2: token): s0rtq

fun print_s0rtq (x: s0rtq): void
fun prerr_s0rtq (x: s0rtq): void
fun fprint_s0rtq (out: FILEref, x: s0rtq): void

fun print_s0taq (x: s0taq): void
fun prerr_s0taq (x: s0taq): void
fun fprint_s0taq (out: FILEref, x: s0taq): void

fun sqi0de_make_none (ent: i0de): sqi0de
fun sqi0de_make_some (ent1: s0taq, ent2: i0de): sqi0de

fun fprint_sqi0de (out: FILEref, x: sqi0de): void

(* ****** ****** *)
//
val
the_d0ynq_none : d0ynq = "ext#patsopt_the_d0ynq_none"
fun
d0ynq_none(loc: location): d0ynq
//
fun d0ynq_symdot
  (ent1: i0de, tok2: token): d0ynq
//
(*
//
// HX-2017-01-24:
// removed due to no use
//
fun d0ynq_symcolon
  (ent1: i0de, tok2: token): d0ynq
fun d0ynq_symdotcolon
  (ent1: i0de, ent2: i0de, ent3: token): d0ynq
*)
//
fun d0ynq_is_none (q: d0ynq): bool
//
(* ****** ****** *)

fun print_d0ynq (x: d0ynq): void
fun prerr_d0ynq (x: d0ynq): void
fun fprint_d0ynq (out: FILEref, x: d0ynq): void

fun dqi0de_make_none (ent: i0de): dqi0de
fun dqi0de_make_some (ent1: d0ynq, ent2: i0de): dqi0de

fun print_dqi0de (x: dqi0de): void
fun prerr_dqi0de (x: dqi0de): void
fun fprint_dqi0de (out: FILEref, x: dqi0de): void

fun p0rec_emp (): p0rec
fun p0rec_i0de (x: i0de): p0rec
fun p0rec_i0de_adj (ide: i0de, opr: i0de, int: i0nt): p0rec
fun p0rec_i0nt (x: i0nt): p0rec

fun fprint_p0rec (out: FILEref, x: p0rec): void

fun fprint_f0xty (out: FILEref, x: f0xty): void

fun e0xp_i0nt (_: i0nt): e0xp
fun e0xp_c0har (_: c0har): e0xp
fun e0xp_f0loat (_: f0loat): e0xp
fun e0xp_s0tring (_: token): e0xp
//
fun e0xp_i0de (_: i0de): e0xp
fun e0xp_list (_1: token, _2: e0xplst, _3: token): e0xp
fun e0xp_app (_1: e0xp, _2: e0xp): e0xp
fun e0xp_eval (_1: token, _2: e0xp, _3: token): e0xp
//
fun e0xp_if (
  t_if: token, _cond: e0xp, _then: e0xp, _else: e0xpopt
) : e0xp // end of [e0xp_if]
//
fun e0xp_make_stringid (loc: location, id: string): e0xp
//
fun fprint_e0xp (out: FILEref, x: e0xp): void
fun fprint_e0xplst (out: FILEref, x: e0xplst): void

fun l0ab_make_label
  (loc: location, l: label): l0ab
fun l0ab_make_i0de (x: i0de): l0ab
fun l0ab_make_i0nt (x: i0nt): l0ab

fun fprint_l0ab (out: FILEref, x: l0ab): void

fun i0de_make_dotlab (t_dot: token, l0: l0ab): i0de

fun s0rt_i0de (_: i0de): s0rt
fun s0rt_qid (sq: s0rtq, id: i0de): s0rt
fun s0rt_app (_1: s0rt, _2: s0rt): s0rt
fun s0rt_list
  (t_beg: token, xs: s0rtlst, t_end: token): s0rt
// end of [s0rt_list]
fun s0rt_type (tok: token): s0rt // tok = T_TYPE (knd)

fun fprint_s0rt (out: FILEref, x: s0rt): void

fun d0atsrtcon_make (id: i0de, arg: s0rtopt): d0atsrtcon

fun d0atsrtdec_make
  (id: i0de, t_eq: token, xs: d0atsrtconlst): d0atsrtdec
// end of [d0atsrtdec_make]

fun fprint_d0atsrtdec (out: FILEref, x: d0atsrtdec): void

fun s0arg_make (id: i0de, _: s0rtopt): s0arg

fun s0marg_make_one (x: s0arg) : s0marg

fun s0marg_make_many (
  t_beg: token, xs: s0arglst, t_end: token
) : s0marg // end of [s0marg_make_many]

fun a0srt_make_none (_: s0rt): a0srt
fun a0srt_make_some (id: i0de, _: s0rt): a0srt

fun a0msrt_make (
  t_beg: token, xs: a0srtlst, t_end: token
) : a0msrt // end of [a0msrt_make]

fun sp0at_cstr
  (qid: sqi0de, xs: s0arglst, t_end: token): sp0at
// end of [sp0at_cstr]

fun s0arrdim_make
  (t_beg: token, ind: s0explst, t_end: token): s0arrdim
// end of [s0arrdim_make]

fun s0rtext_srt (_: s0rt): s0rtext
fun s0rtext_sub (
  t_beg: token, id: i0de, _: s0rtext, _fst: s0exp, _rst: s0explst, t_end: token
) : s0rtext // end of [s0rtext_sub]

fun fprint_s0rtext (out: FILEref, x: s0rtext): void

fun s0qua_prop (_: s0exp): s0qua
fun s0qua_vars (_fst: i0de, _rst: i0delst, _: s0rtext): s0qua

fun fprint_s0qua (out: FILEref, x: s0qua): void
fun fprint_s0qualst (out: FILEref, x: s0qualst): void

fun s0exp_i0de (_: i0de): s0exp
fun s0exp_sqid (sq: s0taq, id: i0de): s0exp
fun s0exp_opid (_1: token, _2: i0de): s0exp

(* ****** ****** *)
//
fun s0exp_i0nt (_: i0nt): s0exp
fun s0exp_c0har (_: c0har): s0exp
//
fun s0exp_f0loat (_: f0loat): s0exp
fun s0exp_s0tring (_: s0tring): s0exp
//
(* ****** ****** *)

fun s0exp_app (_1: s0exp, _2: s0exp): s0exp

fun
s0exp_imp
(
  t_beg: token, _: e0fftaglst, t_end: token
) : s0exp // end of [s0exp_imp]
fun
s0exp_imp_nil (tok: token): s0exp

fun s0exp_tkname (str: token): s0exp

fun s0exp_extype
  (_1: token, _2: token, xs: s0explst): s0exp
fun s0exp_extkind
  (_1: token, _2: token, xs: s0explst): s0exp

fun s0exp_lams (
  _1: token, _2: s0marglst, _3: s0rtopt, _4: s0exp
) : s0exp // end of [s0exp_lam]

fun s0exp_list (
  t_beg: token, xs: s0explst, t_end: token
) : s0exp // end of [s0exp_list]
fun s0exp_list2 (
  t_beg: token, xs1: s0explst, xs2: s0explst, t_end: token
) : s0exp // end of [s0exp_list2]

fun s0exp_tyarr
  (t_beg: token, elt: s0exp, ind: s0arrdim): s0exp
// end of [s0exp_tyarr]

fun
s0exp_tytup
(
  knd: int
, t_beg: token, npf: int, ent2: s0explst, t_end: token
) : s0exp // end of [s0exp_tytup]

fun
s0exp_tyrec
(
  knd: int
, t_beg: token, npf: int, ent2: labs0explst, t_end: token
) : s0exp // end of [s0exp_tyrec]

fun
s0exp_tyrec_ext
(
  name: string
, t_beg: token, npf: int, ent2: labs0explst, t_end: token
) : s0exp // end of [s0exp_tyrec_ext]

fun
s0exp_uni (
  t_beg: token, xs: s0qualst, t_end: token
) : s0exp // end of [s0exp_uni]
fun
s0exp_exi (
  funres: int, t_beg: token, xs: s0qualst, t_end: token
) : s0exp // end of [s0exp_uni]

fun s0exp_ann (s0e: s0exp, s0t: s0rt): s0exp

(* ****** ****** *)
//
fun
s0exp_d2ctype
  (t_beg: token, d2ctp: S0Ed2ctype, t_end: token): s0exp
//
(* ****** ****** *)

fun fprint_s0exp (out: FILEref, x: s0exp): void
fun fprint_s0explst (out: FILEref, x: s0explst): void
fun fprint_s0expopt (out: FILEref, x: s0expopt): void

fun labs0exp_make
  (lab: l0ab, name: s0tringopt, s0e: s0exp): labs0exp
// end of [labs0exp_make]

fun fprint_labs0exp (out: FILEref, x: labs0exp): void

fun q0marg_make
  (t_beg: token, xs: s0qualst, t_end: token): q0marg
// end of [q0marg]

fun fprint_q0marg (out: FILEref, x: q0marg): void
fun fprint_q0marglst (out: FILEref, x: q0marglst): void

fun d0cstarg_sta (
  t_beg: token, xs: s0qualst, t_end: token
) : d0cstarg // end of [d0cstarg_sta]

fun d0cstarg_dyn (
  npf: int, t_beg: token, xs: a0typlst, t_end: token
) : d0cstarg // end of [d0cstarg_dyn]

fun fprint_s0exparg (out: FILEref, x: s0exparg): void

fun m0acarg_dyn
  (t_beg: token, xs: i0delst, t_end: token): m0acarg
// end of [m0acarg_dyn]

fun m0acarg_sing (x: i0de): m0acarg

fun m0acarg_sta
  (t_beg: token, xs: s0arglst, t_end: token): m0acarg
// end of [m0acarg_sta]

fun s0rtdef_make (id: i0de, s0te: s0rtext): s0rtdef

fun t0kindef_make (id: i0de, def: s0tring): t0kindef

fun s0expdef_make
  (id: i0de, arg: s0marglst, res: s0rtopt, def: s0exp): s0expdef
// end of [s0expdef_make]

fun s0aspdec_make (
  sqid: sqi0de, arg: s0marglst, res: s0rtopt, def: s0exp
) : s0aspdec // end of [s0aspdec_make]

fun e0xndec_make
  (qua: q0marglst, id: i0de, arg: s0expopt): e0xndec
// end of [e0xndec_make]

fun
d0atcon_make
(
  qua: q0marglst
, id: i0de, ind: s0expopt, arg: s0expopt
) : d0atcon // end of [d0atcon_make]

fun
d0atdec_make
(
  id: i0de, arg: a0msrtlst, con: d0atconlst
) : d0atdec // end of [d0atdec_make]

fun d0cstdec_make
(
  ide: i0de
, arg: d0cstarglst
, eff: e0fftaglstopt
, res: s0exp // return type
, ext: s0tringopt (* optional external name *)
) : d0cstdec // end of [d0cstdec_make]

fun p0at_i0de (x: i0de): p0at
fun p0at_opid (_1: token, id: i0de): p0at
fun p0at_dqid (dq: d0ynq, id: i0de): p0at

fun p0at_i0nt (x: i0nt): p0at
fun p0at_c0har (x: c0har): p0at
fun p0at_f0loat (x: f0loat): p0at
fun p0at_s0tring (x: s0tring): p0at

fun p0at_app (x1: p0at, x2: p0at): p0at

fun p0at_list
  (t_beg: token, npf: int, xs: p0atlst, t_end: token): p0at
// end of [p0ats_list]

fun p0at_tup (
  knd: int, t_beg: token, npf: int, xs: p0atlst, t_end: token
) : p0at // end of [p0at_tup]
fun p0at_rec (
  knd: int, t_beg: token, npf: int, xs: labp0atlst, t_end: token
) : p0at // end of [p0at_rec]

fun
p0at_lst
(
  lin: int
, t_beg: token, p0ts: p0atlst, t_end: token
) : p0at // end of [p0at_lst]

fun p0at_exist (
  t_beg: token, qua: s0arglst, t_end: token
) : p0at // end of [p0at_exist]

fun p0at_svararg (
  t_beg: token, x: s0vararg, t_end: token
) : p0at // end of [p0at_svararg]

fun p0at_refas (id: p0at, pat: p0at): p0at

fun p0at_free (tok: token, p0t: p0at): p0at
fun p0at_unfold (tok: token, p0t: p0at): p0at

fun p0at_ann (p0t: p0at, ann: s0exp): p0at

fun p0at_err (loc: location): p0at // HX: indicating syntax-error

fun fprint_p0at (out: FILEref, x: p0at): void

(* ****** ****** *)
//
fun
labp0at_norm
  (lab: l0ab, p: p0at): labp0at
//
fun labp0at_omit (tok: token): labp0at
//
fun fprint_labp0at (out: FILEref, x: labp0at): void
//
(* ****** ****** *)

fun i0mparg_sarglst_none (): i0mparg

fun i0mparg_sarglst_some
(
  t_beg: token, arg: s0arglst, t_end: token
) : i0mparg // end of [i0mparg_sarglst_some]

fun i0mparg_svararglst (arg: s0vararglst): i0mparg

fun i0nvresstate_make_none (loc: location): i0nvresstate
fun i0nvresstate_make_some (
  t_beg: token, qua: s0qualstopt, arg: i0nvarglst, t_end: token
) : i0nvresstate // end of [i0nvresstate_make_some]

fun
loopi0nv_make
(
  qua: s0qualstopt
, met: s0explstopt
, arg: i0nvarglst
, res: i0nvresstate
) : loopi0nv // end of [loopi0nv_make]

fun d0exp_ide (id: i0de): d0exp
fun d0exp_opid (_: token, id: i0de): d0exp
fun d0exp_dqid (qid: dqi0de): d0exp

fun d0exp_idext (id: i0de): d0exp // external id

fun d0exp_i0nt (_: i0nt): d0exp
fun d0exp_c0har (_: c0har): d0exp
fun d0exp_s0tring (_: s0tring): d0exp
fun d0exp_f0loat (_: f0loat): d0exp

fun d0exp_empty (loc: location): d0exp

fun d0exp_MYFIL (tok: token): d0exp
fun d0exp_MYLOC (tok: token): d0exp
fun d0exp_MYFUN (tok: token): d0exp

(* ****** ****** *)
//
fun
d0exp_tyrep
(
  t_beg: token, s0e: s0exp, t_end: token
) : d0exp // end of [d0exp_tyrep]
//
(* ****** ****** *)
//
fun
d0exp_literal
(
  t_beg: token, lit: d0exp, t_end: token
) : d0exp // end of [d0exp_literal]
//
(* ****** ****** *)
//
fun d0exp_extval
(
  t_beg: token
, _type: s0exp, name: token
, t_end: token
) : d0exp // end of [d0exp_extval]
//
fun d0exp_extfcall
(
  t_beg: token
, _type: s0exp, _fun: token, _arg: d0explst
, t_end: token
) : d0exp // end of [d0exp_extfcall]
fun d0exp_extmcall
(
  t_beg: token
, _type: s0exp, _obj: d0exp, _mtd: token, _arg: d0explst
, t_end: token
) : d0exp // end of [d0exp_extmcall]
//
(* ****** ****** *)

fun d0exp_label_int (t_dot: token, lab: token): d0exp
fun d0exp_label_sym (t_dot: token, lab: token): d0exp

fun d0exp_foldat (t_foldat: token, _: d0explst): d0exp
fun d0exp_freeat (t_freeat: token, _: d0explst): d0exp

fun d0exp_tmpid (qid: dqi0de, arg: t0mpmarglst, t_gt: token): d0exp

fun
d0exp_let_seq
(
  t_let: token
, d0cs: d0eclist
, t_in: token
, d0e: d0explst
, t_end: token
) : d0exp // end of [d0exp_let_seq]

fun d0exp_declseq
  (t_beg: token, ds: d0eclist, t_end: token) : d0exp
// end of [d0exp_declseq]

fun d0exp_where
  (d0e: d0exp, d0cs: d0eclist, t_end: token) : d0exp
// end of [d0exp_where]

fun d0exp_app (_1: d0exp, _2: d0exp): d0exp

fun d0exp_list (
  t_beg: token, npf: int, xs: d0explst, t_end: token
) : d0exp // end of [d0exp_list]

(* ****** ****** *)
//
fun
d0exp_ifhead (
  hd: ifhead, cond: d0exp, _then: d0exp, _else: d0expopt
) : d0exp // end of [d0exp_ifhead]
fun
d0exp_sifhead (
  hd: sifhead, cond: s0exp, _then: d0exp, _else: d0exp
) : d0exp // end of [d0exp_sifhead]
//
(* ****** ****** *)
//
fun d0exp_ifcasehd (ifhd: ifhead, ifcls: i0fclist): d0exp
//
(* ****** ****** *)
//
fun
d0exp_casehead
  (hd: casehead, d0e: d0exp, t_of: token, c0ls: c0laulst): d0exp
// end of [d0exp_casehead]
fun
d0exp_scasehead
  (hd: scasehead, s0e: s0exp, t_of: token, c0ls: sc0laulst): d0exp
// end of [d0exp_scasehead]
//
(* ****** ****** *)

fun
d0exp_lst
( lin: int
, t_beg: token
, elt: s0expopt
, t_lp: token
, xs: d0explst // elements
, t_rp: token
) : d0exp // end of [d0exp_lst]

fun
d0exp_lst_quote
  (t_beg: token, elts: d0explst, t_end: token): d0exp
// end of [d0exp_lst_quote]

(* ****** ****** *)
//
fun
d0exp_tup
(
  knd: int, t_beg: token, npf: int, xs: d0explst, t_end: token
) : d0exp // end of [d0exp_tup]
//
fun
d0exp_rec
(
  knd: int, t_beg: token, npf: int, xs: labd0explst, t_end: token
) : d0exp // end of [d0exp_rec]
//
(* ****** ****** *)

fun d0exp_seq
  (t_beg: token, xs: d0explst, t_end: token): d0exp
// end of [d0exp_seq]

fun
d0exp_arrsub(qid: dqi0de, ind: d0arrind): d0exp

fun
d0exp_arrinit
(
  t_beg: token, elt: s0exp, dim: d0expopt, ini: d0explst, t_end: token
) : d0exp // end of [d0exp_arrinit]

fun
d0exp_arrpsz
(
  t_beg: token, elt: s0expopt, t_lp: token, elts: d0explst, t_rp: token
) : d0exp // end of [d0exp_arrpsz]

fun d0exp_ptrof (t_addrat: token): d0exp // addr@
fun d0exp_viewat (t_viewat: token): d0exp // view@

(* ****** ****** *)
//
fun
d0exp_sel_lab (sel: s0elop, lab: l0ab): d0exp
fun
d0exp_sel_ind (sel: s0elop, ind: d0arrind): d0exp
//
fun
d0exp_sel_int (tok: token): d0exp // tok=T_DOTINT(...)
//
(* ****** ****** *)
//
fun
d0exp_raise(tok: token, d0e: d0exp): d0exp
//
(* ****** ****** *)
//
fun
d0exp_effmask
  (tok: token, eff: e0fftaglst, d0e: d0exp): d0exp
//
fun
d0exp_effmask_arg
  (knd: int, tok: token, d0e: d0exp): d0exp
//
(* ****** ****** *)
//
fun
d0exp_vararg
(
  t_beg: token, d0es: d0explst, t_end: token
) : d0exp // end of [d0exp_vararg]
//
(* ****** ****** *)
//
fun
d0exp_vcopyenv
  (knd: int(*0/1*), tok: token, d0e: d0exp): d0exp
//
(* ****** ****** *)

fun d0exp_showtype(tok: token, d0e: d0exp): d0exp

fun d0exp_tempenver(tok: token, d0e: d0exp): d0exp

fun
d0exp_sexparg
  (t_beg: token, s0a: s0exparg, t_end: token): d0exp
// end of [d0exp_sexparg]

fun d0exp_exist (
  t_beg: token, s0a: s0exparg, t_bar: token, d0e: d0exp, t_end: token
) : d0exp // end of [d0exp_exist]

fun d0exp_ann (_1: d0exp, _2: s0exp): d0exp

fun
d0exp_lam
(
  knd: int
, t_lam: token
, arg: f0arglst
, res: s0expopt
, eff: e0fftaglstopt
, d0e: d0exp
) : d0exp // end of [d0exp_lam]

fun
d0exp_fix
(
  knd: int
, t_lam: token
, fid: i0de
, arg: f0arglst
, res: s0expopt
, eff: e0fftaglstopt
, d0e: d0exp
) : d0exp // end of [d0exp_fix]

fun d0exp_delay (knd: int, tok: token, body: d0exp): d0exp

fun d0exp_forhead (
  hd: loophead, itp: initestpost, body: d0exp
) : d0exp // end of [d0exp_forhead]

fun d0exp_whilehead
  (hd: loophead, test: d0exp, body: d0exp): d0exp
// end of [d0exp_whilehead]

fun d0exp_loopexn
  (knd: int, tok: token): d0exp // knd=0/1: brk/cont
// end of [d0exp_loopexn]

fun
d0exp_trywith_seq
(
  hd: tryhead
, d0es: d0explst, t_with: token, c0ls: c0laulst
) : d0exp // end of [d0exp_trywith_seq]

(* ****** ****** *)
//
fun d0exp_solassert (tok: token, d0e: d0exp): d0exp
fun d0exp_solverify (tok: token, s0e: s0exp): d0exp
//
(* ****** ****** *)

fun
d0exp_macsyn_decode
  (t_beg: token, _: d0exp, t_end: token): d0exp
// end of [d0exp_macsyn_decode]

fun
d0exp_macsyn_encode_seq
  (t_beg: token, _: d0explst, t_end: token): d0exp
// end of [d0exp_macsyn_encode_seq]

fun
d0exp_macsyn_cross
  (t_beg: token, _: d0exp, t_end: token): d0exp
// end of [d0exp_macsyn_cross]

fun
labd0exp_make (ent1: l0ab, ent2: d0exp): labd0exp

(* ****** ****** *)
//
fun fprint_d0exp (out: FILEref, x: d0exp): void
fun fprint_d0explst (out: FILEref, x: d0explst): void
fun fprint_d0expopt (out: FILEref, x: d0expopt): void
//
overload fprint with fprint_d0exp
overload fprint with fprint_d0explst
//
(* ****** ****** *)

fun fprint_labd0exp (out: FILEref, x: labd0exp): void

(* ****** ****** *)
//
(*
** HX: d0arrind_sing: tok is RBRACKET
*)
fun
d0arrind_sing (d0es: d0explst, tok: token): d0arrind
fun
d0arrind_cons (d0es: d0explst, ind: d0arrind): d0arrind
//
(* ****** ****** *)

fun
initestpost_make
(
  t_beg: token
, init: d0explst
, t_sep: token
, test: d0explst
, t_sep: token
, post: d0explst
, t_end: token
) : initestpost // end of [initestpost_make]

(* ****** ****** *)
//
fun
gm0at_make
  (d0e: d0exp, pat: p0atopt): gm0at
fun
guap0at_make
  (p0t: p0at, mat: gopt(gm0atlst)): guap0at
//
(* ****** ****** *)
//
fun
ifhead_make
  (t_if: token, invopt: gopt(i0nvresstate)): ifhead
fun
sifhead_make
  (t_sif: token, invopt: gopt(i0nvresstate)): sifhead
//
(* ****** ****** *)

fun
casehead_make
  (t_case: token, invopt: gopt(i0nvresstate)): casehead
fun
scasehead_make
  (t_scase: token, invopt: gopt(i0nvresstate)): scasehead

(* ****** ****** *)
//
fun
loophead_make_none
  (t_head: token): loophead
fun
loophead_make_some
(
  t_head: token, inv: loopi0nv, t_eqgt: token
) : loophead // end of [loophead_make_some]
//
(* ****** ****** *)

fun
tryhead_make
  (t_try: token, invopt: gopt(i0nvresstate)): tryhead
// end of [tryhead_make]

fun
i0fcl_make (test: d0exp, body: d0exp): i0fcl

fun
c0lau_make
(
  gp0t: guap0at, seq: int, neg: int, body: d0exp
) : c0lau // end of [c0lau_make]

fun
sc0lau_make (sp0t: sp0at, body: d0exp): sc0lau

fun
m0acdef_make
  (id: i0de, arg: m0acarglst, def: d0exp): m0acdef
// end of [m0acdef_make]

fun
v0aldec_make
  (p0t: p0at, def: d0exp, ann: witht0ype): v0aldec
// end of [v0aldec_make]

fun
f0undec_make
(
  fid: i0de
, arg: f0arglst
, eff: e0fftaglstopt, res: s0expopt
, def: d0exp
, ann: witht0ype
) : f0undec // end of [f0undec_make]

fun
v0ardec_make
(
  opt: tokenopt // optional BANG
, pid: i0de
, pfat: i0deopt // proof of at-view
, s0eopt: s0expopt // type annotation
, d0eopt: d0expopt // value for initialization
) : v0ardec // end of [v0ardec_make]

fun
i0mpdec_make
(
  qid: impqi0de
, arg: f0arglst, res: s0expopt, def: d0exp
) : i0mpdec // end of [i0mpdec_make]

(* ****** ****** *)
//
fun d0ecl_fixity
  (_1: token, _2: p0rec, _3: i0delst): d0ecl
// end of [d0ecl_fixity]
//
fun d0ecl_nonfix (_1: token, _2: i0delst): d0ecl
//
fun d0ecl_include (knd: int, _1: token, _2: token): d0ecl
//
fun d0ecl_symintr (_1: token, _2: i0delst): d0ecl
fun d0ecl_symelim (_1: token, _2: i0delst): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_e0xpdef
(
  _1: token, _2: i0de, _3: e0xpopt
) : d0ecl // HX: #define
//
fun
d0ecl_e0xpundef
  (_1: token, _2: i0de): d0ecl // HX: #undef
//
(* ****** ****** *)
//
fun
d0ecl_e0xpact_assert
  (_1: token, _2: e0xp): d0ecl // HX: #assert
//
fun d0ecl_e0xpact_error (_1: token, _2: e0xp): d0ecl
fun d0ecl_e0xpact_prerr (_1: token, _2: e0xp): d0ecl
fun d0ecl_e0xpact_print (_1: token, _2: e0xp): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_pragma
(
  tok_beg: token
, e0xplst: e0xplst
, tok_end: token
) : d0ecl // end-of-fun
//
fun
d0ecl_pragma_process(xs: e0xplst): void
//
(* ****** ****** *)
//
fun
d0ecl_codegen2
  (tok_beg: token, xs: e0xplst, tok_end: token): d0ecl
fun
d0ecl_codegen3
  (tok_beg: token, xs: e0xplst, tok_end: token): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_datsrts
  (_1: token, _2: d0atsrtdeclst): d0ecl
//
fun
d0ecl_srtdefs (_1: token, _2: s0rtdeflst): d0ecl
//
fun
d0ecl_stacons
  (knd: int, _1: token, _2: s0taconlst): d0ecl
//
fun
d0ecl_stacsts (_1: token, _2: s0tacstlst): d0ecl
//
(*
fun
d0ecl_stavars (_1: token, _2: s0tavarlst): d0ecl
*)
//
fun
d0ecl_tkindef (_1: token, _2: t0kindef): d0ecl
//
fun
d0ecl_sexpdefs
  (knd: int, _1: token, _2: s0expdeflst): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_saspdec(tok: token, d0: s0aspdec): d0ecl
fun
d0ecl_reassume(tok: token, qid: sqi0de): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_exndecs (tok: token, d0: e0xndeclst): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_datdecs_none
(
  knd: int
, tok: token, ds_dec: d0atdeclst
) : d0ecl // end-of-fun
fun
d0ecl_datdecs_some
(
  knd: int
, t1: token, ds_dec: d0atdeclst
, t2: token, ds_def: s0expdeflst
) : d0ecl // end of [d0ecl_datdecs_some]
//
(* ****** ****** *)
//
fun
d0ecl_macdefs
(
  knd: int, isrec: bool, t: token, defs: m0acdeflst
) : d0ecl // end of [d0ecl_macdefs]
//
fun
d0ecl_overload
(
  tok: token, id: i0de, dqid: dqi0de, opt: i0ntopt
) : d0ecl // end-of-fun
//
fun
d0ecl_classdec(t: token, id: i0de, sup: s0expopt): d0ecl
//
fun d0ecl_extype
  (tok: token, name: s0tring, s0e: s0exp): d0ecl
fun d0ecl_extype2
  (tok: token, name: s0tring, s0e: s0exp): d0ecl
//
fun d0ecl_extvar
  (tok: token, name: s0tring, d0e: d0exp): d0ecl
fun d0ecl_extvar2
  (tok: token, name: s0tring, d0e: d0exp): d0ecl
//
fun d0ecl_extcode (knd: int, tok(*string*): token): d0ecl
//
fun d0ecl_impdec
  (t_implement: token, imparg: i0mparg, d: i0mpdec): d0ecl
// end of [d0ecl_impdec]
//
(* ****** ****** *)
//
fun
d0ecl_fundecs
(
  knd: funkind, tok: token, arg: q0marglst, ds: f0undeclst
) : d0ecl // end of [d0ecl_fundecs]
fun
d0ecl_valdecs
(
  knd: valkind, isrec: bool, tok: token, ds: v0aldeclst
) : d0ecl // end of [d0ecl_valdecs]
fun
d0ecl_vardecs(knd: int, tok: token, ds: v0ardeclst): d0ecl
//
(* ****** ****** *)
//
fun
staloadarg_get_loc (arg: staloadarg): location
fun
staloadarg_declist
  (t_lbrace: token, ds: d0eclist, t_rbrace: token): staloadarg
//
fun
d0ecl_staload_fname (tok: token, tok2: token): d0ecl
fun
d0ecl_staload_nspace (tok: token, tok2: token): d0ecl
fun
d0ecl_staload_some_arg (tok: token, ent2: i0de, arg: staloadarg): d0ecl
//
(* ****** ****** *)
//
fun d0ecl_require (tok: token, ent2: token): d0ecl
//
fun d0ecl_dynload (tok: token, ent2: token): d0ecl
//
typedef
d0ecl_dcstdecs_type =
  (token, q0marglst, d0cstdeclst) -> d0ecl
//
fun d0ecl_dcstdecs : d0ecl_dcstdecs_type
fun d0ecl_dcstdecs_extern : d0ecl_dcstdecs_type
// HX: a static const is not exported
fun d0ecl_dcstdecs_static : d0ecl_dcstdecs_type
//
(* ****** ****** *)
//
fun
d0ecl_local
(
  t_beg: token
, ds_head: d0eclist, ds_body: d0eclist
, t_end: token
) : d0ecl // end of [d0ecl_local]
//
fun
d0ecl_guadecl
  (knd: token, gdc: guad0ecl): d0ecl
//
(* ****** ****** *)
//
fun
d0ecl_list
  (fil: filename, d0cs: d0eclist): d0ecl
fun
d0ecl_toplocal
  (fil: filename, d0cs: d0eclist): d0ecl
//
(* ****** ****** *)

fun guad0ecl_one
  (gua: e0xp, ds_then: d0eclist, t_endif: token): guad0ecl
// end of [guad0ecl_one]

fun guad0ecl_two (
  gua: e0xp, ds_then: d0eclist, ds_else: d0eclist, t_endif: token
) : guad0ecl // end of [guad0ecl_two]

fun guad0ecl_cons (
  gua: e0xp, ds: d0eclist, knd: token, rest: guad0ecl
) : guad0ecl // end of [guad0ecl_cons]

fun fprint_d0ecl (out: FILEref, x: d0ecl): void
fun fprint_d0eclist (out: FILEref, x: d0eclist): void

(* ****** ****** *)
//
// HX: the declarations that [mksats] missed
//
fun
i0de_make_sym(loc: location, sym: symbol): i0de
fun
i0de_make_string(loc: location, name: string): i0de
fun
i0de_make_lrbrackets (t_beg: token, t_end: token): i0de
//
fun print_i0de (x: i0de): void
fun prerr_i0de (x: i0de): void
fun fprint_i0de (out: FILEref, x: i0de): void
//
val the_s0taq_none : s0taq = "ext#patsopt_the_s0taq_none"
fun s0taq_none (loc: location): s0taq
fun s0taq_symdot (ent1: i0de, tok2: token): s0taq
fun s0taq_is_none (q: s0taq): bool
//
fun datsdef_make (id: i0de, opt: e0xpopt): datsdef
//
fun a0typ_make_none (_: s0exp): a0typ
fun a0typ_make_some (id: i0de, _: s0exp): a0typ
//
fun dcstextdef_sta (sym: symbol): dcstextdef
fun dcstextdef_is_ext (x: dcstextdef): bool
fun dcstextdef_is_mac (x: dcstextdef): bool
fun dcstextdef_is_sta (x: dcstextdef): bool
fun dcstextdef_is_mainats (x: dcstextdef): bool
//
fun f0arg_dyn (x: p0at): f0arg
fun f0arg_sta1 (t_beg: token, qua: s0qualst, t_end: token): f0arg
fun f0arg_sta2 (t_beg: token, arg: s0vararg, t_end: token): f0arg
fun f0arg_met (t_beg: token, xs: s0explst, t_end: token): f0arg
fun f0arg_met_nil (tok: token): f0arg
//
fun i0nvarg_make (id: i0de, opt: s0expopt): i0nvarg
//
fun impqi0de_make_none (qid: dqi0de): impqi0de
fun impqi0de_make_some (qid: dqi0de, args: t0mpmarglst, t_gt: token): impqi0de
//
fun s0elop_make_dot (tok: token): s0elop
fun s0elop_make_minusgt (tok: token): s0elop
//
fun s0tacst_make
  (id: i0de, arg: a0msrtlst, srt: s0rt, ext: s0tringopt): s0tacst
fun s0tacon_make (id: i0de, arg: a0msrtlst, def: s0expopt): s0tacon
//
fun t0mpmarg_make (tok: token, arg: s0explst): t0mpmarg
//

(* ****** ****** *)

(* end of [pats_syntax.sats] *)
