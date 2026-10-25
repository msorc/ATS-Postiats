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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_sort.dats, see PORTING.md)
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
//
staload SYM = "./pats_symbol.sats"
overload = with $SYM.eq_symbol_symbol
//
(* ****** ****** *)
//
staload STMP = "./pats_stamp.sats"
//
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp
//
(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_staexp2.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)
//
fn
prerr_interror(): void =
  prerr "INTERROR(pats_staexp2_sort)"
//
(* ****** ****** *)

implement
s2rtdat_make (id) = let
//
val
stamp =
$STMP.s2rtdat_stamp_make()
//
in
  s2rtdat_new (id, glist_nil (), stamp)
end // end of [s2rtdat_make]

(* ****** ****** *)

implement
s2rtdat_get_sym (s2td) = s2rtdat_sym (s2td)
implement
s2rtdat_get_sconlst (s2td) = s2rtdat_sconlst (s2td)
implement
s2rtdat_set_sconlst (s2td, s2cs) = set_s2rtdat_sconlst (s2td, s2cs)
implement
s2rtdat_get_stamp (s2td) = s2rtdat_stamp (s2td)

(* ****** ****** *)
//
implement
eq_s2rtdat_s2rtdat
(
  x1, x2
) = (compare_s2rtdat_s2rtdat (x1, x2) = 0)
//
implement
compare_s2rtdat_s2rtdat
(
  x1, x2
) = let
  val sgn =
  $effmask_all
  (
    compare(s2rtdat_get_stamp(x1), s2rtdat_get_stamp(x2))
  ) (* $effmask_all *)
in
  g0ofg1 (sgn)
end (* end of [compare_s2rtdat_s2rtdat] *)
//
(* ****** ****** *)

local
//
val s2tb_int: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_INT)
val s2tb_addr: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_ADDR)
val s2tb_bool: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_BOOL)
//
val s2tb_real: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_REAL)
//
val s2tb_float: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_FLOAT)
val s2tb_string: s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_STRING)
//
val s2tb_cls
  : s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_CLS) // for nominal classes
//
val s2tb_eff
  : s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_EFF) // for sets of effects
//
val s2tb_tkind
  : s2rtbas = s2rtbas_S2RTBASpre($SYM.symbol_TKIND) // for template arguments
//
in // in of [local]
//
implement s2rt_int = s2rt_S2RTbas s2tb_int
implement s2rt_addr = s2rt_S2RTbas s2tb_addr
implement s2rt_bool = s2rt_S2RTbas s2tb_bool
//
implement s2rt_real = s2rt_S2RTbas s2tb_real
//
implement s2rt_float = s2rt_S2RTbas s2tb_float
implement s2rt_string = s2rt_S2RTbas s2tb_string
//
implement s2rt_cls = s2rt_S2RTbas s2tb_cls
//
implement s2rt_eff = s2rt_S2RTbas s2tb_eff
//
implement s2rt_tkind = s2rt_S2RTbas s2tb_tkind
//
end // end of [local]

(* ****** ****** *)

local
//
#include "./pats_basics.hats"
//
val s2tb_prop: s2rtbas = s2rtbas_S2RTBASimp(PROP_int, $SYM.symbol_PROP)
val s2tb_prop_pos: s2rtbas = s2rtbas_S2RTBASimp(PROP_pos_int, $SYM.symbol_PROP)
val s2tb_prop_neg: s2rtbas = s2rtbas_S2RTBASimp(PROP_neg_int, $SYM.symbol_PROP)
//
val s2tb_type: s2rtbas = s2rtbas_S2RTBASimp(TYPE_int, $SYM.symbol_TYPE)
val s2tb_type_pos: s2rtbas = s2rtbas_S2RTBASimp(TYPE_pos_int, $SYM.symbol_TYPE)
val s2tb_type_neg: s2rtbas = s2rtbas_S2RTBASimp(TYPE_neg_int, $SYM.symbol_TYPE)
//
val s2tb_t0ype: s2rtbas = s2rtbas_S2RTBASimp(T0YPE_int, $SYM.symbol_T0YPE)
val s2tb_t0ype_pos: s2rtbas = s2rtbas_S2RTBASimp(T0YPE_pos_int, $SYM.symbol_T0YPE)
val s2tb_t0ype_neg: s2rtbas = s2rtbas_S2RTBASimp(T0YPE_neg_int, $SYM.symbol_T0YPE)
//
val s2tb_types: s2rtbas = s2rtbas_S2RTBASimp(TYPES_int, $SYM.symbol_TYPES)
//
val s2tb_view: s2rtbas = s2rtbas_S2RTBASimp(VIEW_int, $SYM.symbol_VIEW)
val s2tb_view_pos: s2rtbas = s2rtbas_S2RTBASimp(VIEW_pos_int, $SYM.symbol_VIEW)
val s2tb_view_neg: s2rtbas = s2rtbas_S2RTBASimp(VIEW_neg_int, $SYM.symbol_VIEW)
//
val s2tb_vtype: s2rtbas = s2rtbas_S2RTBASimp(VIEWTYPE_int, $SYM.symbol_VIEWTYPE)
val s2tb_vtype_pos: s2rtbas = s2rtbas_S2RTBASimp(VIEWTYPE_pos_int, $SYM.symbol_VIEWTYPE)
val s2tb_vtype_neg: s2rtbas = s2rtbas_S2RTBASimp(VIEWTYPE_neg_int, $SYM.symbol_VIEWTYPE)
//
val s2tb_vt0ype: s2rtbas = s2rtbas_S2RTBASimp(VIEWT0YPE_int, $SYM.symbol_VIEWT0YPE)
val s2tb_vt0ype_pos: s2rtbas = s2rtbas_S2RTBASimp(VIEWT0YPE_pos_int, $SYM.symbol_VIEWT0YPE)
val s2tb_vt0ype_neg: s2rtbas = s2rtbas_S2RTBASimp(VIEWT0YPE_neg_int, $SYM.symbol_VIEWT0YPE)
//
in // in of [local]

implement s2rt_prop = s2rt_S2RTbas(s2tb_prop)
implement s2rt_prop_pos = s2rt_S2RTbas(s2tb_prop_pos)
implement s2rt_prop_neg = s2rt_S2RTbas(s2tb_prop_neg)

implement s2rt_type = s2rt_S2RTbas(s2tb_type)
implement s2rt_type_pos = s2rt_S2RTbas(s2tb_type_pos)
implement s2rt_type_neg = s2rt_S2RTbas(s2tb_type_neg)

implement s2rt_t0ype = s2rt_S2RTbas(s2tb_t0ype)
implement s2rt_t0ype_pos = s2rt_S2RTbas(s2tb_t0ype_pos)
implement s2rt_t0ype_neg = s2rt_S2RTbas(s2tb_t0ype_neg)

implement s2rt_types = s2rt_S2RTbas(s2tb_types)

implement s2rt_view = s2rt_S2RTbas(s2tb_view)
implement s2rt_view_pos = s2rt_S2RTbas(s2tb_view_pos)
implement s2rt_view_neg = s2rt_S2RTbas(s2tb_view_neg)

implement s2rt_vtype = s2rt_S2RTbas(s2tb_vtype)
implement s2rt_vtype_pos = s2rt_S2RTbas(s2tb_vtype_pos)
implement s2rt_vtype_neg = s2rt_S2RTbas(s2tb_vtype_neg)

implement s2rt_vt0ype = s2rt_S2RTbas(s2tb_vt0ype)
implement s2rt_vt0ype_pos = s2rt_S2RTbas(s2tb_vt0ype_pos)
implement s2rt_vt0ype_neg = s2rt_S2RTbas(s2tb_vt0ype_neg)

implement
s2rt_impred(knd) = let
//
in
//
case+ knd of
//
| PROP_int => s2rt_prop
| TYPE_int => s2rt_type
| T0YPE_int => s2rt_t0ype
| VIEW_int => s2rt_view
| VIEWTYPE_int => s2rt_vtype
| VIEWT0YPE_int => s2rt_vt0ype
//
| PROP_pos_int => s2rt_prop_pos
| PROP_neg_int => s2rt_prop_neg
| TYPE_pos_int => s2rt_type_pos
| TYPE_neg_int => s2rt_type_neg
| T0YPE_pos_int => s2rt_t0ype_pos
| T0YPE_neg_int => s2rt_t0ype_neg
| VIEW_pos_int => s2rt_view_pos
| VIEW_neg_int => s2rt_view_neg
| VIEWTYPE_pos_int => s2rt_vtype_pos
| VIEWTYPE_neg_int => s2rt_vtype_neg
| VIEWT0YPE_pos_int => s2rt_vt0ype_pos
| VIEWT0YPE_neg_int => s2rt_vt0ype_neg
//
| _ => let
//
    val () = prerr_interror ()
    val () = prerr ": s2rt_impred: knd = "
    val () = prerr_int (knd)
    val () = prerr_newline ()
    val () = assertloc (false)
  in
    s2rt_t0ype // HX: this should be deadcode!
  end // end of [_]
//
end // end of [s2rt_impred]

end // end of [local]

(* ****** ****** *)
//
// HX: the base sort of a sort, if it is a base sort: the test of the symbol
//
fn
s2rt_test_pre
  (s2t: s2rt, sym0: $SYM.symbol): bool =
(
case+ s2rt_viewof (s2t) of
| ~S2RTbas s2tb => (
  case+ s2rtbas_view (s2tb) of
  | ~S2RTBASpre (sym) => (sym = sym0)
  | v => (s2rtbas_view_free (v); false)
  ) // end of [S2RTbas]
| v => (s2rt_view_free (v); false)
) // end of [s2rt_test_pre]

fn
s2rt_test_imp
  (s2t: s2rt, f: int -> bool, dflt: bool): bool =
(
case+ s2rt_viewof (s2t) of
| ~S2RTbas s2tb => (
  case+ s2rtbas_view (s2tb) of
  | ~S2RTBASimp (knd, _) => f (knd)
  | v => (s2rtbas_view_free (v); dflt)
  ) // end of [S2RTbas]
| v => (s2rt_view_free (v); dflt)
) // end of [s2rt_test_imp]

fn not_test_linkind (knd: int): bool = not (test_linkind (knd))

(* ****** ****** *)

implement
s2rt_is_int (s2t) = s2rt_test_pre (s2t, $SYM.symbol_INT)
implement
s2rt_is_addr (s2t) = s2rt_test_pre (s2t, $SYM.symbol_ADDR)
implement
s2rt_is_bool (s2t) = s2rt_test_pre (s2t, $SYM.symbol_BOOL)

(* ****** ****** *)

implement
s2rt_is_float (s2t) = s2rt_test_pre (s2t, $SYM.symbol_FLOAT)

implement
s2rt_is_string (s2t) = s2rt_test_pre (s2t, $SYM.symbol_STRING)

(* ****** ****** *)

implement
s2rt_is_dat(s2t) =
(
case+ s2rt_viewof (s2t) of
| ~S2RTbas(s2tb) =>
  (
    case+ s2rtbas_view (s2tb) of
    | ~S2RTBASdef( _ ) => true
    | v => (s2rtbas_view_free (v); false)
  ) (* end of [S2RTbas] *)
| v => (s2rt_view_free (v); false)
) // end of [s2rt_is_dat]

(* ****** ****** *)

implement
s2rt_is_fun(s2t) = s2rt_is_S2RTfun (s2t)

implement
s2rt_is_prf(s2t) = s2rt_test_imp (s2t, test_prfkind, false)

(* ****** ****** *)

implement
s2rt_is_lin(s2t) = s2rt_test_imp (s2t, test_linkind, false)

implement
s2rt_is_nonlin(s2t) = s2rt_test_imp (s2t, not_test_linkind, false)

(* ****** ****** *)

implement
s2rt_is_flat(s2t) = s2rt_test_imp (s2t, test_fltkind, false)

implement
s2rt_is_boxed(s2t) = s2rt_test_imp (s2t, test_boxkind, false)

(* ****** ****** *)

implement
s2rt_is_tkind(s2t) = s2rt_test_pre (s2t, $SYM.symbol_TKIND)

(* ****** ****** *)

implement
s2rt_is_prgm(s2t) = s2rt_test_imp (s2t, test_prgmkind, false)

(* ****** ****** *)

fn s2rt_ret_true (knd: int): bool = true

implement
s2rt_is_impred (s2t) = s2rt_test_imp (s2t, s2rt_ret_true, false)

(* ****** ****** *)

local

fun
s2rt_test_fun
(
  s2t: s2rt, ft: s2rt -> bool
): bool = (
  case+ s2rt_viewof (s2t) of
  | ~S2RTfun(_, s2t) =>
      s2rt_test_fun(s2t, ft)
    // end of [S2RTfun]
  | v (*non-S2RTfun*) => (s2rt_view_free (v); ft(s2t))
) // end of [s2rt_test_fun]

in (* in-of-local *)
//
implement
s2rt_is_lin_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_lin)
//
implement
s2rt_is_flat_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_flat)
//
implement
s2rt_is_boxed_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_boxed)
//
implement
s2rt_is_tkind_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_tkind)
//
implement
s2rt_is_prgm_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_prgm)
implement
s2rt_is_impred_fun
  (s2t) = s2rt_test_fun(s2t, s2rt_is_impred)
//
end // end of [local]

(* ****** ****** *)

fn s2rt_ret_polkind (knd: int): int = test_polkind (knd)

implement
s2rt_get_pol(s2t) =
(
//
case+ s2rt_viewof (s2t) of
| ~S2RTbas(s2tb) =>
  (
  case+ s2rtbas_view (s2tb) of
  | ~S2RTBASimp(knd, _) => test_polkind(knd)
  | v => (s2rtbas_view_free (v); 0)
  ) (* end of [S2RTbas] *)
| v (* non-S2RTbas *) => (s2rt_view_free (v); 0) // 0: polarity is neutral
//
) (* end of [s2rt_get_pol] *)

(* ****** ****** *)
//
// HX: s2rtVar_srt is null if the variable is not yet assigned
//
fn s2rtnul_none (): s2rt = $UN.cast{s2rt} (the_null_ptr)
fn s2rtnul_some (x: s2rt): s2rt = x
fn s2rtnul_unsome (x: s2rt): s2rt = x
fn s2rtnul_is_null (x: s2rt): bool = ptr_is_null ($UN.cast{ptr} (x))
fn s2rtnul_isnot_null (x: s2rt): bool = ptr_isnot_null ($UN.cast{ptr} (x))

(* ****** ****** *)

implement
eq_s2rtVar_s2rtVar
  (x1, x2) = ptr_eq ($UN.cast{ptr} (x1), $UN.cast{ptr} (x2))
// end of [eq_s2rtVar_s2rtVar]

implement
compare_s2rtVar_s2rtVar
  (x1, x2) = let
  val sgn = ptr_cmp ($UN.cast{ptr} (x1), $UN.cast{ptr} (x2))
in
  $UN.cast{Sgn} (sgn)
end // end of [compare_s2rtVar_s2rtVar]

(* ****** ****** *)

implement
s2rtVar_make (loc) = let
  val nul = s2rtnul_none () in s2rtVar_new (nul)
end // end of [s2rtVar_make]

(* ****** ****** *)

implement
s2rt_delink (s2t0) = let
//
fun
aux
(
  s2t0: s2rt
) : s2rt =
(
case+ s2rt_viewof (s2t0) of
| ~S2RTVar ref => let
    val s2t = s2rtVar_srt (ref)
    val test =
      s2rtnul_isnot_null(s2t)
    // end of [val]
  in
    if test
      then let
        val s2t =
          s2rtnul_unsome(s2t)
        val s2t = aux (s2t)
        val ((*void*)) =
          set_s2rtVar_srt (ref, s2rtnul_some(s2t))
      in
        s2t
      end // end of [then]
      else s2t0 // end of [else]
    // end of [if]
  end (* S2RTVar *)
| v (*non-S2RTVar*) => (s2rt_view_free (v); s2t0)
) (* end of [aux] *)
//
in
  aux (s2t0)
end // end of [s2rt_delink]

implement
s2rt_delink_all
  (s2t0) = let
//
fun
aux (
  s2t0: s2rt, flag: &int
) : s2rt =
(
case+ s2rt_viewof (s2t0) of
| ~S2RTfun
    (s2ts, s2t) => let
    val
    flag0 = flag
    val s2t = aux(s2t, flag)
    val s2ts = auxlst(s2ts, flag)
  in
    if flag > flag0
      then s2rt_S2RTfun (s2ts, s2t) else s2t0
    // end of [if]
  end
| ~S2RTtup(s2ts) => let
    val
    flag0 = flag
    val s2ts = auxlst (s2ts, flag)
  in
    if flag > flag0 then s2rt_S2RTtup (s2ts) else s2t0
  end
| ~S2RTVar (ref) => let
    val s2t = s2rtVar_srt (ref)
    val isnotnull =
      s2rtnul_isnot_null (s2t)
    // end of [val]
  in
    if isnotnull
      then let
        val s2t =
          s2rtnul_unsome(s2t)
        val s2t = aux (s2t, flag)
        val ((*void*)) =
          set_s2rtVar_srt (ref, s2rtnul_some(s2t))
        // end of [val]
      in
        flag := flag + 1; s2t
      end // end of [then]
      else s2t0 // end of [else]
    // end of [if]
  end (* S2RTVar *)
| v (*rest-of-s2rt*) => (s2rt_view_free (v); s2t0)
) (* end of [aux] *)
//
and
auxlst
(
  s2ts0: s2rtlst, flag: &int
) : s2rtlst = (
//
case+ glist_view (s2ts0) of
| ~GLnil
    ((*void*)) => glist_nil()
| ~GLcons
    (s2t, s2ts) => let
    val
    flag0 = flag
    val s2t = aux (s2t, flag)
    val s2ts = auxlst (s2ts, flag)
  in
    if flag > flag0
      then glist_cons(s2t, s2ts) else s2ts0
    // end of [if]
  end // end of [list_cons]
//
) (* end if [auxlst] *)
//
var flag: int = 0
//
in
  aux (s2t0, flag)
end // end of [s2rt_delink_all]

(* ****** ****** *)

implement
s2rtVar_get_s2rt
  (s2tV) = let
  val s2t = s2rtVar_srt (s2tV)
  val isnot = s2rtnul_isnot_null(s2t)
in
//
if isnot then s2rtnul_unsome(s2t) else s2rt_S2RTerr()
//
end // end of [s2rtVar_set_s2rt]

implement
s2rtVar_set_s2rt
  (s2tV, s2t) = let
  val s2t = s2rtnul_some (s2t) in set_s2rtVar_srt (s2tV, s2t)
end // end of [s2rtVar_set_s2rt]

implement
s2rtVar_occurcheck
  (s2tV, s2t0) = let
//
fun aux (
  s2tV: s2rtVar, s2t0: s2rt
) : bool =
(
//
case+ s2rt_viewof (s2t0) of
//
| ~S2RTbas _ => false
//
| ~S2RTfun (s2ts, s2t) =>
  (
    if auxlst (s2tV, s2ts) then true else aux (s2tV, s2t)
  ) (* end of [S2RTfun] *)
//
| ~S2RTtup (s2ts) => auxlst (s2tV, s2ts)
//
| ~S2RTVar (s2tV1) =>
  (
    if s2tV = s2tV1
      then true else let
        val s2t1 = s2rtVar_srt (s2tV1)
        val isnot = s2rtnul_isnot_null(s2t1)
      in
        if isnot
          then aux (s2tV, s2rtnul_unsome(s2t1)) else false
        // end of [if]
      end // end of [else]
    // end of [if]
  ) (* end of [S2RTVar] *)
//
| ~S2RTerr ((*void*)) => false
//
) (* end of [aux] *)
//
and
auxlst
(
  s2tV: s2rtVar, s2ts: s2rtlst
) : bool =
(
//
case+ glist_view (s2ts) of
| ~GLnil () => false
| ~GLcons (s2t, s2ts) =>
    if aux (s2tV, s2t) then true else auxlst (s2tV, s2ts)
  // end of [list_cons]
//
) (* end of [auxlst] *)
//
in
  aux (s2tV, s2t0)
end // end of [s2rtVar_occurcheck]

(* ****** ****** *)

implement
s2rt_fun (_arg, _res) = s2rt_S2RTfun (_arg, _res)

implement
s2rt_tup (s2ts) = s2rt_S2RTtup (s2ts) // HX: tuple sort not yet supported

implement
s2rt_err () = s2rt_S2RTerr () // HX: error indication

(* ****** ****** *)
//
extern
fun
lte_s2rtbas_s2rtbas
  (s2tb1: s2rtbas, s2tb2: s2rtbas): bool
//
overload <= with lte_s2rtbas_s2rtbas
//
implement
lte_s2rtbas_s2rtbas
  (s2tb1, s2tb2) =
(
case+ s2rtbas_view (s2tb1) of
| ~S2RTBASpre id1 => (
  case+ s2rtbas_view (s2tb2) of
  | ~S2RTBASpre id2 => (id1 = id2)
  | v => (s2rtbas_view_free (v); false)
  )
| ~S2RTBASimp(knd1, id1) => (
  case+ s2rtbas_view (s2tb2) of
  | ~S2RTBASimp(knd2, id2) => lte_impkind_impkind(knd1, knd2)
  | v => (s2rtbas_view_free (v); false)
  )
| ~S2RTBASdef s2td1 => (
  case+ s2rtbas_view (s2tb2) of
  | ~S2RTBASdef s2td2 => (s2td1 = s2td2)
  | v => (s2rtbas_view_free (v); false)
  )
) (* end of [lte_s2rtbas_s2rtbas] *)
//
(* ****** ****** *)
//
(*
** HX: knd=0/1: dry-run / real-run
*)
extern
fun
s2rt_ltmat (knd: int, s2t1: s2rt, s2t2: s2rt): bool
extern
fun
s2rtlst_ltmat (knd: int, xs1: s2rtlst, xs2: s2rtlst): bool
//
implement
s2rt_ltmat
  (knd, s2t1, s2t2) = let
//
fun
auxVar
(
  knd: int
, s2tV: s2rtVar, s2t: s2rt
) : bool =
(
//
if
(knd > 0)
then let
  val
  test =
  s2rtVar_occurcheck(s2tV, s2t)
in
  if test
    then false else let
    val () = s2rtVar_set_s2rt(s2tV, s2t) in true
  end (* end of [if] *)
end else true // HX: a dry run always succeeds
//
) (* end of [auxVar] *)
//
val s2t1 = s2rt_delink(s2t1)
and s2t2 = s2rt_delink(s2t2)
//
in
//
case+ s2rt_viewof (s2t1) of
| ~S2RTbas
    (s2tb1) =>
  (
  case+ s2rt_viewof (s2t2) of
  | ~S2RTbas(s2tb2) => (s2tb1 <= s2tb2)
  | v => (s2rt_view_free (v); false)
  )
| ~S2RTfun
  (
    s2ts1, s2t1
  ) =>
  (
  case+ s2rt_viewof (s2t2) of
  | ~S2RTfun
    (
      s2ts2, s2t2
    ) =>
    if s2rtlst_ltmat(knd, s2ts2, s2ts1)
      then s2rt_ltmat(knd, s2t1, s2t2) else false
    // end of [if]
  | v (*non-S2RTfun*) => (s2rt_view_free (v); false)
  )
| ~S2RTtup(s2ts1) =>
  (
  case+ s2rt_viewof (s2t2) of
  | ~S2RTtup(s2ts2) => s2rtlst_ltmat(knd, s2ts1, s2ts2)
  | v => (s2rt_view_free (v); false)
  )
| ~S2RTVar(s2tV1) =>
  (
  case+ s2rt_viewof (s2t2) of
  | ~S2RTVar(s2tV2) =>
      if s2tV1 = s2tV2 then true else auxVar(knd, s2tV1, s2t2)
  | v => (s2rt_view_free (v); auxVar(knd, s2tV1, s2t2))
  )
//
| ~S2RTerr ((*void*)) => false
//
end // end of [s2rt_ltmat]
//
(* ****** ****** *)

implement
s2rtlst_ltmat
  (knd, xs1, xs2) =
(
  case+ glist_view (xs1) of
  | ~GLnil () => (
    case+ glist_view (xs2) of
    | ~GLnil () => true
    | ~GLcons (_, _) => false
    )
  | ~GLcons (x1, xs1) => (
    case+ glist_view (xs2) of
    | ~GLcons (x2, xs2) =>
      (
        if s2rt_ltmat (knd, x1, x2) then s2rtlst_ltmat (knd, xs1, xs2) else false
      )
    | ~GLnil () => false
    )
) (* end of [s2rtlst_ltmat] *)

(* ****** ****** *)

implement s2rt_ltmat0(x1, x2) = s2rt_ltmat(0, x1, x2)
implement s2rt_ltmat1(x1, x2) = s2rt_ltmat(1, x1, x2)

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_s2rtdat_s2rtdat ($UN.cast{s2rtdat} (x1), $UN.cast{s2rtdat} (x2))
//
in (* in-of-local *)

implement
s2rtdatset_nil
  ((*void*)) = $UN.cast{s2rtdatset} (avlmap_nil ())

implement
s2rtdatset_add
  (xs, x) = $UN.cast{s2rtdatset}
  (avlmap_insert ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), the_null_ptr, cmp))
// end of [s2rtdatset_add]

implement
s2rtdatset_listize (xs) =
  $UN.castvwtp0{List0_vt(s2rtdat)} (avlmap_keys ($UN.cast{avlmap} (xs)))

end // end of [local]

(* ****** ****** *)

(* end of [pats_staexp2_sort.dats] *)
