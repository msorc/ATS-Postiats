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
// Start Time: May, 2011
//
(* ****** ****** *)

//
// HX-2026-10: no GC (ATS2 port of src/pats_stacst2.sats)
// [s2cstref] is a cell of the global arena (a symbol and the constant found so far, null if none);
// the values [the_xxx: s2cstref] have C names (they are made when the module is dynloaded).
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

abstype s2cstref_type = ptr // boxed
typedef s2cstref = s2cstref_type

(* ****** ****** *)
//
fun s2cstref_make(name: string): s2cstref
//
(* ****** ****** *)
//
fun s2cstref_get_cst(s2cr: s2cstref): s2cst
//
fun s2cstref_get_exp
   (s2cr: s2cstref, arg: Option_vt(s2explst)): s2exp
fun s2cstref_unget_exp
   (s2cr: s2cstref, s2e: s2exp): Option_vt(s2explst)
//
fun s2cstref_equ_cst(s2cr: s2cstref, s2c: s2cst): bool
fun s2cstref_equ_exp(s2cr: s2cstref, s2e: s2exp): bool
//
(* ****** ****** *)
//
val the_true_bool : s2cstref = "ext#patsopt_the_true_bool"
val the_false_bool : s2cstref = "ext#patsopt_the_false_bool"
//
val the_neg_bool : s2cstref = "ext#patsopt_the_neg_bool" // bool -> bool
val the_add_bool_bool : s2cstref = "ext#patsopt_the_add_bool_bool" // (bool, bool) -> bool
val the_mul_bool_bool : s2cstref = "ext#patsopt_the_mul_bool_bool" // (bool, bool) -> bool
val the_eq_bool_bool : s2cstref = "ext#patsopt_the_eq_bool_bool" // (bool, bool) -> bool
val the_neq_bool_bool : s2cstref = "ext#patsopt_the_neq_bool_bool" // (bool, bool) -> bool
//
val the_neg_int : s2cstref = "ext#patsopt_the_neg_int" // : (int) -> int
val the_add_int_int : s2cstref = "ext#patsopt_the_add_int_int" // : (int, int) -> int
val the_sub_int_int : s2cstref = "ext#patsopt_the_sub_int_int" // : (int, int) -> int
val the_mul_int_int : s2cstref = "ext#patsopt_the_mul_int_int" // : (int, int) -> int
val the_div_int_int : s2cstref = "ext#patsopt_the_div_int_int" // : (int, int) -> int
val the_ndiv_int_int : s2cstref = "ext#patsopt_the_ndiv_int_int" // : (int, int) -> int
val the_idiv_int_int : s2cstref = "ext#patsopt_the_idiv_int_int" // : (int, int) -> int
//
val the_lt_int_int : s2cstref = "ext#patsopt_the_lt_int_int" // : (int, int) -> bool
val the_lte_int_int : s2cstref = "ext#patsopt_the_lte_int_int" // : (int, int) -> bool
val the_gt_int_int : s2cstref = "ext#patsopt_the_gt_int_int" // : (int, int) -> bool
val the_gte_int_int : s2cstref = "ext#patsopt_the_gte_int_int" // : (int, int) -> bool
val the_eq_int_int : s2cstref = "ext#patsopt_the_eq_int_int" // : (int, int) -> bool
val the_neq_int_int : s2cstref = "ext#patsopt_the_neq_int_int" // : (int, int) -> bool
//
val the_abs_int : s2cstref = "ext#patsopt_the_abs_int" // (int) -> int
val the_absrel_int_int : s2cstref = "ext#patsopt_the_absrel_int_int" // : (int, int) -> bool
val the_sgn_int : s2cstref = "ext#patsopt_the_sgn_int" // (int) -> int
val the_sgnrel_int_int : s2cstref = "ext#patsopt_the_sgnrel_int_int" // : (int, int) -> bool
//
val the_max_int_int : s2cstref = "ext#patsopt_the_max_int_int" // : (int, int) -> int
val the_min_int_int : s2cstref = "ext#patsopt_the_min_int_int" // : (int, int) -> int
val the_maxrel_int_int_int : s2cstref = "ext#patsopt_the_maxrel_int_int_int" // : (int, int, int) -> bool
val the_minrel_int_int_int : s2cstref = "ext#patsopt_the_minrel_int_int_int" // : (int, int, int) -> bool
//
val the_ndivrel_int_int_int : s2cstref = "ext#patsopt_the_ndivrel_int_int_int" // : (int, int, int) -> bool
val the_idivrel_int_int_int : s2cstref = "ext#patsopt_the_idivrel_int_int_int" // : (int, int, int) -> bool
//
val the_ifint_bool_int_int : s2cstref = "ext#patsopt_the_ifint_bool_int_int" // : (bool, int, int) -> int
val the_ifintrel_bool_int_int_int : s2cstref = "ext#patsopt_the_ifintrel_bool_int_int_int" // : (bool, int, int, int) -> bool
//
(*
val the_int_of_bool : s2cstref = "ext#patsopt_the_int_of_bool" // : (bool) -> int
val the_bool_of_int : s2cstref = "ext#patsopt_the_bool_of_int" // : (int) -> bool
*)
(*
// HX: char equals int8
// HX-2012-06-12: removed
val the_int_of_char : s2cstref = "ext#patsopt_the_int_of_char" // : (char) -> int
val the_char_of_int : s2cstref = "ext#patsopt_the_char_of_int" // : (int) -> char
*)
(*
** HX: addr is treated as (signed) int
*)
val the_int_of_addr : s2cstref = "ext#patsopt_the_int_of_addr" // : (addr) -> int
val the_addr_of_int : s2cstref = "ext#patsopt_the_addr_of_int" // : (int) -> addr
//
val the_null_addr : s2cstref = "ext#patsopt_the_null_addr"
val the_lt_addr_addr : s2cstref = "ext#patsopt_the_lt_addr_addr" // : (addr, addr) -> bool
val the_lte_addr_addr : s2cstref = "ext#patsopt_the_lte_addr_addr" // : (addr, addr) -> bool
val the_gt_addr_addr : s2cstref = "ext#patsopt_the_gt_addr_addr" // : (addr, addr) -> bool
val the_gte_addr_addr : s2cstref = "ext#patsopt_the_gte_addr_addr" // : (addr, addr) -> bool
val the_eq_addr_addr : s2cstref = "ext#patsopt_the_eq_addr_addr" // : (addr, addr) -> bool
val the_neq_addr_addr : s2cstref = "ext#patsopt_the_neq_addr_addr" // : (addr, addr) -> bool
//
val the_add_addr_int : s2cstref = "ext#patsopt_the_add_addr_int" // (addr, int) -> addr
val the_sub_addr_int : s2cstref = "ext#patsopt_the_sub_addr_int" // (addr, int) -> addr
val the_sub_addr_addr : s2cstref = "ext#patsopt_the_sub_addr_addr" // (addr, addr) -> int
//
(* ****** ****** *)

val the_types_nil : s2cstref = "ext#patsopt_the_types_nil" // : types
val the_types_cons : s2cstref = "ext#patsopt_the_types_cons" // : (vt@ype, types) -> types

(* ****** ****** *)

val the_lte_cls_cls : s2cstref = "ext#patsopt_the_lte_cls_cls" // : (cls, cls) -> bool
val the_gte_cls_cls : s2cstref = "ext#patsopt_the_gte_cls_cls" // : (cls, cls) -> bool
val the_lterel_cls_cls : s2cstref = "ext#patsopt_the_lterel_cls_cls" // : (cls, cls, bool) -> bool
val the_gterel_cls_cls : s2cstref = "ext#patsopt_the_gterel_cls_cls" // : (cls, cls, bool) -> bool

(* ****** ****** *)

val the_atstkind_type : s2cstref = "ext#patsopt_the_atstkind_type"
val the_atstkind_t0ype : s2cstref = "ext#patsopt_the_atstkind_t0ype"

(* ****** ****** *)
//
val the_bool_t0ype : s2cstref = "ext#patsopt_the_bool_t0ype"
val the_bool_bool_t0ype : s2cstref = "ext#patsopt_the_bool_bool_t0ype"
//
(* ****** ****** *)
//
val the_int_kind : s2cstref = "ext#patsopt_the_int_kind"
val the_uint_kind : s2cstref = "ext#patsopt_the_uint_kind"
val the_lint_kind : s2cstref = "ext#patsopt_the_lint_kind"
val the_ulint_kind : s2cstref = "ext#patsopt_the_ulint_kind"
val the_llint_kind : s2cstref = "ext#patsopt_the_llint_kind"
val the_ullint_kind : s2cstref = "ext#patsopt_the_ullint_kind"
val the_size_kind : s2cstref = "ext#patsopt_the_size_kind"
val the_ssize_kind : s2cstref = "ext#patsopt_the_ssize_kind"
//
val the_g0int_t0ype : s2cstref = "ext#patsopt_the_g0int_t0ype"
val the_g1int_int_t0ype : s2cstref = "ext#patsopt_the_g1int_int_t0ype"
val the_g0uint_t0ype : s2cstref = "ext#patsopt_the_g0uint_t0ype"
val the_g1uint_int_t0ype : s2cstref = "ext#patsopt_the_g1uint_int_t0ype"
//
val the_char_t0ype : s2cstref = "ext#patsopt_the_char_t0ype"
val the_char_int_t0ype : s2cstref = "ext#patsopt_the_char_int_t0ype"
val the_schar_t0ype : s2cstref = "ext#patsopt_the_schar_t0ype"
val the_schar_int_t0ype : s2cstref = "ext#patsopt_the_schar_int_t0ype"
val the_uchar_t0ype : s2cstref = "ext#patsopt_the_uchar_t0ype"
val the_uchar_int_t0ype : s2cstref = "ext#patsopt_the_uchar_int_t0ype"
//
val the_float_kind : s2cstref = "ext#patsopt_the_float_kind"
val the_double_kind : s2cstref = "ext#patsopt_the_double_kind"
val the_ldouble_kind : s2cstref = "ext#patsopt_the_ldouble_kind"
val the_g0float_t0ype : s2cstref = "ext#patsopt_the_g0float_t0ype"
//
val the_string_type : s2cstref = "ext#patsopt_the_string_type"
val the_string_int_type : s2cstref = "ext#patsopt_the_string_int_type"
//
val the_literal_float : s2cstref = "ext#patsopt_the_literal_float"
val the_literal_string : s2cstref = "ext#patsopt_the_literal_string"
//
val the_ptr_type : s2cstref = "ext#patsopt_the_ptr_type"
val the_ptr_addr_type : s2cstref = "ext#patsopt_the_ptr_addr_type"
//
(*
val the_p2tr_vt0ype_addr_type : s2cstref = "ext#patsopt_the_p2tr_vt0ype_addr_type"
*)
//
val the_atsvoid_t0ype : s2cstref = "ext#patsopt_the_atsvoid_t0ype"
//
val the_unit_prop : s2cstref = "ext#patsopt_the_unit_prop"
val the_unit_view : s2cstref = "ext#patsopt_the_unit_view"
//
val the_exception_vtype : s2cstref = "ext#patsopt_the_exception_vtype"
//
val the_arrpsz_vt0ype_int_vt0ype : s2cstref = "ext#patsopt_the_arrpsz_vt0ype_int_vt0ype"
//
(*
val the_list0_t0ype_type : s2cstref = "ext#patsopt_the_list0_t0ype_type"
*)
//
val the_list_t0ype_int_type : s2cstref = "ext#patsopt_the_list_t0ype_int_type"
val the_list_vt0ype_int_vtype : s2cstref = "ext#patsopt_the_list_vt0ype_int_vtype"
//
val the_vbox_view_prop : s2cstref = "ext#patsopt_the_vbox_view_prop"
val the_ref_vt0ype_type : s2cstref = "ext#patsopt_the_ref_vt0ype_type"
//
val the_lazy_t0ype_type : s2cstref = "ext#patsopt_the_lazy_t0ype_type"
val the_lazy_vt0ype_vtype : s2cstref = "ext#patsopt_the_lazy_vt0ype_vtype"
//
val the_sizeof_t0ype_int : s2cstref = "ext#patsopt_the_sizeof_t0ype_int"
//
val the_at_vt0ype_addr_view : s2cstref = "ext#patsopt_the_at_vt0ype_addr_view"
//
val the_invar_prop_prop : s2cstref = "ext#patsopt_the_invar_prop_prop"
val the_invar_view_view : s2cstref = "ext#patsopt_the_invar_view_view"
val the_invar_t0ype_t0ype : s2cstref = "ext#patsopt_the_invar_t0ype_t0ype"
val the_invar_vt0ype_vt0ype : s2cstref = "ext#patsopt_the_invar_vt0ype_vt0ype"
//
(* ****** ****** *)

val the_vcopyenv_view_view : s2cstref = "ext#patsopt_the_vcopyenv_view_view"
val the_vcopyenv_vt0ype_vt0ype : s2cstref = "ext#patsopt_the_vcopyenv_vt0ype_vt0ype"

(* ****** ****** *)

val the_bottom_t0ype_uni : s2cstref = "ext#patsopt_the_bottom_t0ype_uni" // = {a:t@ype} (a)
val the_bottom_t0ype_exi : s2cstref = "ext#patsopt_the_bottom_t0ype_exi" // = [a:t@ype | false] (a)

val the_bottom_vt0ype_uni : s2cstref = "ext#patsopt_the_bottom_vt0ype_uni" // = {a:vt@ype} (a)
val the_bottom_vt0ype_exi : s2cstref = "ext#patsopt_the_bottom_vt0ype_exi" // = [a:vt@ype | false] (a)

(* ****** ****** *)
//
// HX: static boolean terms
//
fun s2exp_bool(b: bool): s2exp
//
fun s2exp_bool_t0ype((*void*)): s2exp // bool0
fun s2exp_bool_bool_t0ype(b: bool): s2exp // bool1(b)
//
fun s2exp_bool_index_t0ype(ind: s2exp): s2exp // bool1(ind)
//
fun un_s2exp_bool_index_t0ype(s2f: s2hnf): Option_vt(s2exp)
//
(* ****** ****** *)
//
fun s2exp_agtz (s2a: s2exp): s2exp
//
fun s2exp_bneg (s2p: s2exp): s2exp
//
fun
s2exp_badd
  (s2p1: s2exp, s2p2: s2exp): s2exp
//
fun
s2exp_bmul
  (s2p1: s2exp, s2p2: s2exp): s2exp
//
fun s2explst_badd (s2ps: s2explst): s2exp
fun s2explst_bmul (s2ps: s2explst): s2exp
//
(* ****** ****** *)
//
fun s2exp_ineg (s2i: s2exp): s2exp
//
fun s2exp_intlt (s2i1: s2exp, s2i2: s2exp): s2exp
fun s2exp_intgt (s2i1: s2exp, s2i2: s2exp): s2exp
fun s2exp_intlte (s2i1: s2exp, s2i2: s2exp): s2exp
fun s2exp_intgte (s2i1: s2exp, s2i2: s2exp): s2exp
fun s2exp_intneq (s2i1: s2exp, s2i2: s2exp): s2exp
//
(* ****** ****** *)

fun s2exp_igtez (s2i: s2exp): s2exp // s2i >= 0

(* ****** ****** *)

fun un_s2exp_intconst (s2i: s2exp): Option_vt(int)

(* ****** ****** *)
//
fun s2exp_int_t0ype (): s2exp // int0
fun s2exp_uint_t0ype (): s2exp // uint0
fun s2exp_lint_t0ype (): s2exp // int0
fun s2exp_ulint_t0ype (): s2exp // uint0
fun s2exp_llint_t0ype (): s2exp // lint0
fun s2exp_ullint_t0ype (): s2exp // ulint0
//
fun s2exp_int_int_t0ype (i: int): s2exp // int1(i)
fun s2exp_int_intinf_t0ype (inf: intinf): s2exp // int1(inf)
//
fun s2exp_uint_int_t0ype (i: int): s2exp // uint1(i)
fun s2exp_uint_intinf_t0ype (inf: intinf): s2exp // uint1(i)
//
fun s2exp_lint_intinf_t0ype (inf: intinf): s2exp // lint1(i)
fun s2exp_ulint_intinf_t0ype (inf: intinf): s2exp // ulint1(i)
fun s2exp_llint_intinf_t0ype (inf: intinf): s2exp // llint1(i)
fun s2exp_ullint_intinf_t0ype (inf: intinf): s2exp // ullint1(i)
//
fun s2exp_g0int_kind_t0ype (knd: s2exp): s2exp
fun s2exp_g1int_kind_index_t0ype (knd: s2exp, ind: s2exp): s2exp
fun s2exp_g0uint_kind_t0ype (knd: s2exp): s2exp
fun s2exp_g1uint_kind_index_t0ype (knd: s2exp, ind: s2exp): s2exp
//
fun un_s2exp_g1int_index_t0ype (s2f: s2hnf): Option_vt(s2exp)
fun un_s2exp_g1uint_index_t0ype (s2f: s2hnf): Option_vt(s2exp)
//
fun un_s2exp_g1size_index_t0ype (s2f: s2hnf): Option_vt(s2exp)
//
fun s2exp_int_index_t0ype (ind: s2exp): s2exp
fun s2exp_uint_index_t0ype (ind: s2exp): s2exp
//
(* ****** ****** *)
//
fun s2exp_char_t0ype (): s2exp // char0
fun s2exp_char_int_t0ype (c: int): s2exp // char1(c)
fun s2exp_char_index_t0ype (ind: s2exp): s2exp // char1(ind)
//
fun un_s2exp_char_index_t0ype (s2f: s2hnf): Option_vt(s2exp)
//
fun s2exp_schar_t0ype (): s2exp // schar0
fun s2exp_schar_int_t0ype (c: int): s2exp // schar1(c)
//
fun s2exp_uchar_t0ype (): s2exp // schar0
fun s2exp_uchar_int_t0ype (c: int): s2exp // uchar1(c)
//
(* ****** ****** *)
//
fun s2exp_float_t0ype (): s2exp // float
fun s2exp_double_t0ype (): s2exp // double
fun s2exp_ldouble_t0ype (): s2exp // ldouble
//
(* ****** ****** *)
//
fun s2exp_string_type (): s2exp // string0
fun s2exp_string_int_type (n: size_t): s2exp // string1
fun s2exp_string_index_type (ind: s2exp): s2exp // string1(ind)
//
(* ****** ****** *)

fun s2exp_literal_float (rep: string): s2exp
fun s2exp_literal_string (str: string): s2exp

(* ****** ****** *)

fun s2exp_ptr_type(): s2exp // ptr0

(* ****** ****** *)

fun
s2exp_ptr_addr_type(s2l: s2exp): s2exp // ptr1
fun
un_s2exp_ptr_addr_type(s2f: s2hnf): Option_vt(s2exp)

(* ****** ****** *)
(*
fun
s2exp_p2tr_vt0ype_addr_type(s2e: s2exp, s2l: s2exp): s2exp // p2tr
fun
un_s2exp_p2tr_vt0ype_addr_type(s2f: s2hnf): Option_vt@(s2exp, s2exp)
*)
(* ****** ****** *)

fun s2exp_void_t0ype(): s2exp // void

(* ****** ****** *)

fun s2exp_unit_prop (): s2exp // unit_p // how about uprop?
fun s2exp_unit_view (): s2exp // unit_v // how about uview?

(* ****** ****** *)

fun s2exp_exception_vtype (): s2exp

(* ****** ****** *)
//
fun
s2exp_arrpsz_vt0ype_int_vt0ype(s2e: s2exp, n: int): s2exp
//
(* ****** ****** *)
//
(*
fun
s2exp_list0_t0ype_type (s2e: s2exp): s2exp
*)
//
fun
s2exp_list_vt0ype_int_vtype(s2e: s2exp, n: int): s2exp
//
(* ****** ****** *)
//
fun s2exp_vbox_view_prop(s2e: s2exp): s2exp
fun un_s2exp_vbox_view_prop(s2f: s2hnf) : Option_vt(s2exp)
//
(* ****** ****** *)
//
fun s2exp_ref_vt0ype_type(s2e: s2exp): s2exp
fun un_s2exp_ref_vt0ype_type(s2f: s2hnf): Option_vt(s2exp)
//
(* ****** ****** *)

fun un_s2exp_lazy_t0ype_type(s2f: s2hnf): Option_vt(s2exp)

fun s2exp_lazy_vt0ype_vtype(s2e: s2exp): s2exp
fun un_s2exp_lazy_vt0ype_vtype(s2f: s2hnf): Option_vt(s2exp)

(* ****** ****** *)

fun s2exp_bottom_t0ype_uni(): s2exp // = {a:t@ype} (a)
fun s2exp_bottom_t0ype_exi(): s2exp // = [a:t@ype | false] (a)

fun s2exp_bottom_vt0ype_uni(): s2exp // = {a:vt@ype} (a)
fun s2exp_bottom_vt0ype_exi(): s2exp // = [a:vt@ype | false] (a)

(* ****** ****** *)
//
// HX-2017-11-08:
//
fun
s2exp_types_nil((*void*)): s2exp
//
fun
s2exp_types_cons
  (s2e1: s2exp, s2e2: s2exp): s2exp
(*
fun
s2exp_types_uncons
  (s2e0: &s2exp >> s2exp): Option_vt(s2exp)
*)
//
fun
s2exp_types_list(s2es: s2explst): s2exp
//
(* ****** ****** *)

fun s2exp_vcopyenv_v (s2e: s2exp): s2exp
fun s2exp_vcopyenv_vt (s2e: s2exp): s2exp

(* ****** ****** *)
//
// HX-2013-09:
// only for internal use!
//
val the_atstype_int : s2cstref = "ext#patsopt_the_atstype_int"
val the_atstype_bool : s2cstref = "ext#patsopt_the_atstype_bool"
val the_atstype_uint : s2cstref = "ext#patsopt_the_atstype_uint"
val the_atstype_size : s2cstref = "ext#patsopt_the_atstype_size"
val the_atstype_ssize : s2cstref = "ext#patsopt_the_atstype_ssize"
//
(* ****** ****** *)

val the_effnil : s2cstref = "ext#patsopt_the_effnil"
val the_effall : s2cstref = "ext#patsopt_the_effall"
val the_effntm : s2cstref = "ext#patsopt_the_effntm"
val the_effexn : s2cstref = "ext#patsopt_the_effexn"
val the_effref : s2cstref = "ext#patsopt_the_effref"
val the_effwrt : s2cstref = "ext#patsopt_the_effwrt"
val the_add_eff_eff : s2cstref = "ext#patsopt_the_add_eff_eff" // = add_eff_eff
val the_sub_eff_eff : s2cstref = "ext#patsopt_the_sub_eff_eff" // = sub_eff_eff

(* ****** ****** *)

fun s2eff_hnfize (s2fe: s2eff): s2eff

(* ****** ****** *)

fun stacst2_initialize ((*void*)): void

(* ****** ****** *)

(* end of [pats_stacst2.sats] *)
