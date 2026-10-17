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
// Start Time: February, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3_simplify.dats, see PORTING.md, "Constraint solving (constraint3)")
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

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_intinf.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_trans3_env.sats"
staload "./pats_constraint3.sats"

(* ****** ****** *)

#include "./pats_constraint3.hats"

(* ****** ****** *)

implement
s3exp_bneg (s3e0) = (
  case+ s3exp_view (s3e0) of
  | ~S3Ebool b => s3exp_S3Ebool (not b)
  | ~S3Ebneg (s3e) => s3e
  | ~S3Ebadd (s3e1, s3e2) => s3exp_S3Ebmul (s3exp_S3Ebneg s3e1, s3exp_S3Ebneg s3e2)
  | ~S3Ebmul (s3e1, s3e2) => s3exp_S3Ebadd (s3exp_S3Ebneg s3e1, s3exp_S3Ebneg s3e2)
  | ~S3Ebeq (s3e1, s3e2) => s3exp_S3Ebneq (s3e1, s3e2)
  | ~S3Ebneq (s3e1, s3e2) => s3exp_S3Ebeq (s3e1, s3e2)
  | ~S3Ebineq (knd, s3e) => s3exp_S3Ebineq (~knd, s3e)
  | v => (s3exp_view_free (v); s3exp_S3Ebneg (s3e0))
) // end of [s3exp_bneg]

(* ****** ****** *)

fn s3exp_unbool (x: s3exp): int = // 1/0: true/false; ~1: not a constant
  case+ s3exp_view (x) of
  | ~S3Ebool b => (if b then 1 else 0)
  | v => (s3exp_view_free (v); ~1)
// end of [s3exp_unbool]

implement
s3exp_badd
  (s3e1, s3e2) = let
  val b1 = s3exp_unbool (s3e1)
in
  if b1 >= 0 then (
    if b1 > 0 then s3exp_true else s3e2
  ) else let
    val b2 = s3exp_unbool (s3e2)
  in
    if b2 >= 0 then (
      if b2 > 0 then s3exp_true else s3e1
    ) else s3exp_S3Ebadd (s3e1, s3e2)
  end (* end of [_] *)
end // end of [s3exp_badd]

implement
s3exp_bmul
  (s3e1, s3e2) = let
  val b1 = s3exp_unbool (s3e1)
in
  if b1 >= 0 then (
    if b1 > 0 then s3e2 else s3exp_false
  ) else let
    val b2 = s3exp_unbool (s3e2)
  in
    if b2 >= 0 then (
      if b2 > 0 then s3e1 else s3exp_false
    ) else s3exp_S3Ebmul (s3e1, s3e2)
  end (* end of [_] *)
end // end of [s3exp_bmul]

(* ****** ****** *)

implement
s3exp_beq
  (s3e1, s3e2) = let
  val b1 = s3exp_unbool (s3e1)
in
  if b1 >= 0 then (
    if b1 > 0 then s3e2 else s3exp_bneg (s3e2)
  ) else let
    val b2 = s3exp_unbool (s3e2)
  in
    if b2 >= 0 then (
      if b2 > 0 then s3e1 else s3exp_bneg (s3e1)
    ) else s3exp_S3Ebeq (s3e1, s3e2)
  end (* end of [_] *)
end // end of [s3exp_beq]

implement
s3exp_bneq
  (s3e1, s3e2) = let
  val b1 = s3exp_unbool (s3e1)
in
  if b1 >= 0 then (
    if b1 > 0 then s3exp_bneg (s3e2) else s3e2
  ) else let
    val b2 = s3exp_unbool (s3e2)
  in
    if b2 >= 0 then (
      if b2 > 0 then s3exp_bneg (s3e1) else s3e1
    ) else s3exp_S3Ebneq (s3e1, s3e2)
  end (* end of [_] *)
end // end of [s3exp_bneq]

(* ****** ****** *)

fun
uns3exp_intinf
  (s3e: s3exp): Option_vt (intinf) =
  case+ s3exp_view (s3e) of
  | ~S3Enull () => Some_vt (intinf_0)
  | ~S3Eunit () => Some_vt (intinf_1)
  | ~S3Eicff (c, s3e) => let
      val opt = uns3exp_intinf (s3e)
    in
      case+ opt of
      | ~Some_vt (i) => Some_vt (c * i)
      | ~None_vt () => None_vt ()
    end // end of [S3Eicff]
  | v => (s3exp_view_free (v); None_vt ())
// end of [uns3exp_intinf]

implement
s3exp_bineq (knd, s3e) = let
  val opt = uns3exp_intinf (s3e)
in
  case+ opt of
  | ~Some_vt (i) => (
      if knd = 2 then s3exp_bool (i >= 0)
      else if knd = ~2 then s3exp_bool (i < 0)
      else if knd = 1 then s3exp_bool (i = 0)
      else if knd = ~1 then s3exp_bool (i != 0)
      else let
        val () = assertloc (false) in s3exp_false
      end // end of [_]
    ) // end of [Some_vt]
  | ~None_vt () => s3exp_S3Ebineq (knd, s3e)
end // end of [s3exp_bineq]

(* ****** ****** *)

implement
s3exp_ilt (s3e1, s3e2) =
  s3exp_bineq (~2(*lt*), s3exp_isub (s3e1, s3e2))
// end of [s3exp_ilt]

implement
s3exp_ilte (s3e1, s3e2) =
  s3exp_bineq (2(*gte*), s3exp_isub (s3e2, s3e1))
// end of [s3exp_ilte]

implement
s3exp_igt (s3e1, s3e2) =
  s3exp_bineq (~2(*lt*), s3exp_isub (s3e2, s3e1))
// end of [s3exp_igt]

implement
s3exp_igte (s3e1, s3e2) =
  s3exp_bineq (2(*gte*), s3exp_isub (s3e1, s3e2))
// end of [s3exp_igte]

implement
s3exp_ieq (s3e1, s3e2) =
  s3exp_bineq (1(*eq*), s3exp_isub (s3e1, s3e2))
// end of [s3exp_ieq]

implement
s3exp_ineq (s3e1, s3e2) =
  s3exp_bineq (~1(*neq*), s3exp_isub (s3e1, s3e2))
// end of [s3exp_ineq]

(* ****** ****** *)

implement
s3exp_int (i) = let
  val int = intinf_make_int (i) in s3exp_intinf (int)
end // end of [s3exp_int]

implement s3exp_intinf (int) = s3exp_icff (int, s3exp_1)

(* ****** ****** *)

implement
s3exp_icff (c, x) = let
in
if c = 1 then x
else if c = 0 then s3exp_0
else (
  case+ s3exp_view (x) of
  | ~S3Enull () => s3exp_0
  | ~S3Eicff
      (c1, x1) => s3exp_icff (c * c1, x1)
  | ~S3Eisum (xs) => let
      val cxs = s3explst_icff (c, xs) in s3exp_S3Eisum (l2l cxs)
    end // end of [S3Eisum]
  | v => (s3exp_view_free (v); s3exp_S3Eicff (c, x))
) // end of [_]
end // end of [s3exp_icff]

implement
s3explst_icff (c, xs) = (
  if glist_is_cons (xs) then let
    val x = glist_head<s3exp> (xs)
    val y = s3exp_icff (c, x)
    val ys = s3explst_icff (c, glist_tail<s3exp> (xs))
  in
    list_vt_cons (y, ys)
  end else list_vt_nil ()
) // end of [s3explst_icff]

implement
s3exp_ineg (x) = s3exp_icff (intinf_neg_1, x)

(* ****** ****** *)

implement
s3exp_isum (xs) = (
  if glist_is_cons (xs) then (
    if glist_is_cons (glist_tail<s3exp> (xs))
      then s3exp_S3Eisum (xs) else glist_head<s3exp> (xs)
  ) else s3exp_0
) // end of [s3exp_isum]

(* ****** ****** *)

implement
s3exp_isucc (s3e) = s3exp_iadd (s3e, s3exp_1)
implement
s3exp_ipred (s3e) = s3exp_iadd (s3e, s3exp_neg_1)

(* ****** ****** *)

implement
s3exp_isgte (x1, x2) = let
(*
// HX: for supporting S3Eisum
*)
in
//
case+ s3exp_view (x1) of
// nonlinear terms go first
| ~S3Eiatm
    (s2vs1) => (
  case+ s3exp_view (x2) of
  | ~S3Eiatm(s2vs2) =>
      s2varmset_gte (s2vs1, s2vs2)
    // end of [S3Eiatm]
  | v => (s3exp_view_free (v); true)
  ) (* end of [S3Eiatm] *)
| ~S3Evar(s2v1) => (
  case+ s3exp_view (x2) of
  | ~S3Eiatm _ => false
  | ~S3Evar s2v2 =>
      compare_s2var_s2var (s2v1, s2v2) <= 0 // HX: not [>=]!
    // end of [S3Ecst]
  | v => (s3exp_view_free (v); true)
  ) (* end of [S3Evar] *)
| ~S3Ecst(s2c1) => (
  case+ s3exp_view (x2) of
  | ~S3Eiatm _ => false
  | ~S3Evar s2v2 => false
  | ~S3Ecst s2c2 =>
      compare_s2cst_s2cst (s2c1, s2c2) <= 0 // HX: not [>=]!
    // end of [S3Ecst]
  | v => (s3exp_view_free (v); true)
  ) (* end of [S3Evar] *)
| ~S3Eunit((*void*)) => (
  case+ s3exp_view (x2) of
  | ~S3Eiatm _ => false
  | ~S3Evar s2v2 => false
  | ~S3Ecst s2c2 => false
  | ~S3Eunit () => true
  | v => (s3exp_view_free (v); true)
  ) (* end of [S3Eunit] *)
//
| v (*unrecognized*) => (s3exp_view_free (v); false)
//
end // end of [s3exp_isgte]

(* ****** ****** *)

local

fun uns3exp_icff
  (x: s3exp): s3exp =
  case+ s3exp_view (x) of
  | ~S3Eicff (c, x) => x
  | v => (s3exp_view_free (v); x)
// end of [uns3exp_icff]

(*
** HX: x1 and x2 are the same kind of term
*)
fun s3exp_icff_add
  (x1: s3exp, x2: s3exp): s3exp =
  if s3exp_is_S3Eicff (x1) then let
    val (c1, y1) = un_S3Eicff (x1)
  in
    if s3exp_is_S3Eicff (x2) then let
      val (c2, _) = un_S3Eicff (x2)
    in
      s3exp_icff (c1+c2, y1)
    end else s3exp_icff (c1+1, y1)
  end else (
    if s3exp_is_S3Eicff (x2) then let
      val (c2, y2) = un_S3Eicff (x2)
    in
      s3exp_icff (c2+1, y2)
    end else s3exp_icff (intinf_2, x1)
  )
// end of [s3exp_icff_add]

fun
s3exp_isum_pair (
  x1: s3exp, x2: s3exp
) : s3exp = let
  val y1 = uns3exp_icff (x1)
  and y2 = uns3exp_icff (x2)
  val gte12 = s3exp_isgte (y1, y2)
in
//
if gte12 then let
  val gte21 = s3exp_isgte (y2, y1)
in
  if gte21 then
    s3exp_icff_add (x1, x2) else s3exp_S3Eisum (glist_pair<s3exp> (x1, x2))
  // end of [if]
end else (
  s3exp_S3Eisum (glist_pair<s3exp> (x2, x1))
) (* end of [if] *)
//
end // end of [s3exp_isum_pair]

fun
s3exp_isum_list (
  xs1: s3explst, xs2: s3explst
) : s3explst_vt = let
//
fun aux (
  xs1: s3explst, xs2: s3explst
) : s3explst_vt =
  if glist_is_cons (xs1) then let
    val x1 = glist_head<s3exp> (xs1)
    val xs11 = glist_tail<s3exp> (xs1)
  in
    if glist_is_cons (xs2) then let
      val x2 = glist_head<s3exp> (xs2)
      val xs21 = glist_tail<s3exp> (xs2)
      val y1 = uns3exp_icff (x1)
      val y2 = uns3exp_icff (x2)
      val gte12 = s3exp_isgte (y1, y2)
    in
      if gte12 then let
        val gte21 = s3exp_isgte (y2, y1)
      in
        if gte21 then let
          val x12 = s3exp_icff_add (x1, x2)
        in
          if s3exp_is_S3Enull (x12)
            then aux (xs11, xs21)
            else let
              val rest = aux (xs11, xs21) in list_vt_cons (x12, rest)
            end // end of [_]
        end else let
          val rest = aux (xs11, xs2) in list_vt_cons (x1, rest)
        end // end of [if]
      end else let
        val rest = aux (xs1, xs21) in list_vt_cons (x2, rest)
      end // end of [if]
    end // end of [list_cons]
    else glist_listize<s3exp> (xs1)
  end // end of [list_cons]
  else glist_listize<s3exp> (xs2)
 // end of [aux]
in
  aux (xs1, xs2)
end // end of [s3exp_isum_list]

fun
s3exp_imul_list (
  xs1: s3explst, xs2: s3explst
) : s3explst_vt = let
//
fun mulmap
  (x1: s3exp, xs2: s3explst): s3explst_vt =
  if glist_is_cons (xs2) then let
    val y = s3exp_imul (x1, glist_head<s3exp> (xs2))
    val ys = mulmap (x1, glist_tail<s3exp> (xs2))
  in
    list_vt_cons (y, ys)
  end else list_vt_nil ()
//
in
//
if glist_is_cons (xs1) then let
    val x1 = glist_head<s3exp> (xs1)
    val x1xs2 = mulmap (x1, xs2)
    val xs1xs2 = s3exp_imul_list (glist_tail<s3exp> (xs1), xs2)
    val res = s3exp_isum_list (l2l x1xs2, l2l xs1xs2)
  in
    res
  end // end of [list_cons]
else list_vt_nil ()
//
end // end of [s3exp_imul_list]

in (* in of [local] *)

implement
s3exp_iadd
  (x1, x2) =
  if s3exp_is_S3Enull (x1) then x2
  else if s3exp_is_S3Enull (x2) then x1
  else if s3exp_is_S3Eisum (x1) then let
    val xs1 = un_S3Eisum (x1)
  in
    if s3exp_is_S3Eisum (x2) then let
      val xs2 = un_S3Eisum (x2)
      val xs = s3exp_isum_list (xs1, xs2)
    in
      s3exp_isum (l2l xs)
    end // end of [S3Eisum, S3Eisum]
    else let
      val xs = s3exp_isum_list (xs1, glist_sing<s3exp> (x2))
    in
      s3exp_isum (l2l xs)
    end // end of [S3Eisum, _]
  end else (
    if s3exp_is_S3Eisum (x2) then let
      val xs2 = un_S3Eisum (x2)
      val xs = s3exp_isum_list (glist_sing<s3exp> (x1), xs2)
    in
      s3exp_isum (l2l xs)
    end // end of [_, S3Eisum]
    else s3exp_isum_pair (x1, x2)
  ) (* end of [s3exp_iadd] *)

implement
s3exp_isub
  (x1, x2) =
  if s3exp_is_S3Enull (x1) then s3exp_ineg (x2)
  else if s3exp_is_S3Enull (x2) then x1
  else if s3exp_is_S3Eisum (x1) then let
    val xs1 = un_S3Eisum (x1)
  in
    if s3exp_is_S3Eisum (x2) then let
      val xs2 = un_S3Eisum (x2)
      val xs2 = l2l (s3explst_icff (intinf_neg_1, xs2))
      val xs = s3exp_isum_list (xs1, xs2)
    in
      s3exp_isum (l2l xs)
    end // end of [S3Eisum, S3Eisum]
    else let
      val xs2 = glist_sing<s3exp> (s3exp_ineg (x2))
      val xs = s3exp_isum_list (xs1, xs2)
    in
      s3exp_isum (l2l xs)
    end // end of [S3Eisum, _]
  end else (
    if s3exp_is_S3Eisum (x2) then let
      val xs1 = glist_sing<s3exp> (x1)
      val xs2 = un_S3Eisum (x2)
      val xs2 = l2l (s3explst_icff (intinf_neg_1, xs2))
      val xs = s3exp_isum_list (xs1, xs2)
    in
      s3exp_isum (l2l xs)
    end // end of [_, S3Eisum]
    else s3exp_isum_pair (x1, s3exp_ineg (x2))
  ) (* end of [s3exp_isub] *)

fun
s3explst_imul_map
  (x1: s3exp, xs2: s3explst): s3explst_vt =
  if glist_is_cons (xs2) then let
    val y = s3exp_imul (x1, glist_head<s3exp> (xs2))
    val ys = s3explst_imul_map (x1, glist_tail<s3exp> (xs2))
  in
    list_vt_cons (y, ys)
  end else list_vt_nil ()
//
fun
s3explst_imul_map2
  (xs1: s3explst, x2: s3exp): s3explst_vt =
  if glist_is_cons (xs1) then let
    val y = s3exp_imul (glist_head<s3exp> (xs1), x2)
    val ys = s3explst_imul_map2 (glist_tail<s3exp> (xs1), x2)
  in
    list_vt_cons (y, ys)
  end else list_vt_nil ()

fun
auxrest (x1: s3exp, x2: s3exp): s3exp =
  if s3exp_is_S3Eisum (x1) then let
    val xs1 = un_S3Eisum (x1)
  in
    if s3exp_is_S3Eisum (x2) then let
      val xs2 = un_S3Eisum (x2)
      val xs1xs2 = s3exp_imul_list (xs1, xs2)
    in
      s3exp_isum (l2l xs1xs2)
    end // end of [S3Eisum, S3Eisum]
    else let
      val ys1 = s3explst_imul_map2 (xs1, x2)
    in
      s3exp_S3Eisum (l2l ys1)
    end // end of [S3Eisum, _]
  end else (
    if s3exp_is_S3Eisum (x2) then let
      val xs2 = un_S3Eisum (x2)
      val ys2 = s3explst_imul_map (x1, xs2)
    in
      s3exp_S3Eisum (l2l ys2)
    end // end of [_, S3Eisum]
    else s3exp_S3Eimul (x1, x2)
  ) (* end of [auxrest] *)


implement
s3exp_imul
  (x1, x2) = let
in
//
if s3exp_is_S3Enull (x1) then s3exp_0
else if s3exp_is_S3Enull (x2) then s3exp_0
else if s3exp_is_S3Eunit (x1) then x2
else if s3exp_is_S3Eunit (x2) then x1
else if s3exp_is_S3Eicff (x1) then let
  val (c, y1) = un_S3Eicff (x1) in s3exp_icff (c, s3exp_imul (y1, x2))
end else if s3exp_is_S3Eicff (x2) then let
  val (c, y2) = un_S3Eicff (x2) in s3exp_icff (c, s3exp_imul (x1, y2))
end else if s3exp_is_S3Evar (x1) then (
  if s3exp_is_S3Evar (x2) then
    s3exp_S3Eiatm (s2varmset_pair (un_S3Evar (x1), un_S3Evar (x2)))
  else if s3exp_is_S3Eiatm (x2) then
    s3exp_S3Eiatm (s2varmset_add (un_S3Eiatm (x2), un_S3Evar (x1)))
  else auxrest (x1, x2)
) else if s3exp_is_S3Eiatm (x1) then (
  if s3exp_is_S3Evar (x2) then
    s3exp_S3Eiatm (s2varmset_add (un_S3Eiatm (x1), un_S3Evar (x2)))
  else if s3exp_is_S3Eiatm (x2) then
    s3exp_S3Eiatm (s2varmset_union (un_S3Eiatm (x1), un_S3Eiatm (x2)))
  else auxrest (x1, x2)
) else auxrest (x1, x2)
//
end // end of [s3exp_imul]


end // end of [local]

(* ****** ****** *)

extern
fun s3exp_lintize_flag (
  env: &s2vbcfenv, s3e: s3exp, flag: &int >> int
) : s3exp // end of [s3exp_lintize_flag]
extern
fun s3explst_lintize_flag (
  env: &s2vbcfenv, s3es: s3explst, flag: &int >> int
) : s3explst // end of [s3explst_lintize_flag]

(* ****** ****** *)

implement
s3exp_lintize
  (env, s3e) = let
var flag: int = 0
val s3e_res = s3exp_lintize_flag (env, s3e, flag)
//
in
  s3e_res
end // end of [s3exp_lintize]

(* ****** ****** *)

implement
s3exp_lintize_flag
(
  env, s3e0, flag
) = let
  val flag0 = flag
in
//
case+ s3exp_view (s3e0) of
//
| ~S3Evar _ => s3e0
| ~S3Ecst _ => let
    val () = flag := flag + 1
    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)
  in
    s3exp_var (s2v)
  end // end of [val]
| ~S3Enull _ => s3e0
| ~S3Eunit _ => s3e0
| ~S3Ebool _ => s3e0
//
| ~S3Ebvar _ => s3e0
| ~S3Ebneg (s3e) => let
    val s3e =
      s3exp_lintize_flag (env, s3e, flag)
    // end of [val]
  in
    if flag > flag0 then s3exp_S3Ebneg (s3e) else s3e0
  end // end of [S3Ebneg]
| ~S3Ebadd (s3e1, s3e2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3e2 = s3exp_lintize_flag (env, s3e2, flag)
  in
    if flag > flag0 then s3exp_S3Ebadd (s3e1, s3e2) else s3e0
  end // end of [S3Ebadd]
| ~S3Ebmul (s3e1, s3e2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3e2 = s3exp_lintize_flag (env, s3e2, flag)
  in
    if flag > flag0 then s3exp_S3Ebmul (s3e1, s3e2) else s3e0
  end // end of [S3Ebmul]
| ~S3Ebeq (s3e1, s3e2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3e2 = s3exp_lintize_flag (env, s3e2, flag)
  in
    if flag > flag0 then s3exp_S3Ebeq (s3e1, s3e2) else s3e0
  end // end of [S3Ebeq]
| ~S3Ebneq (s3e1, s3e2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3e2 = s3exp_lintize_flag (env, s3e2, flag)
  in
    if flag > flag0 then s3exp_S3Ebneq (s3e1, s3e2) else s3e0
  end // end of [S3Ebneq]
| ~S3Ebineq (knd, s3e) => let
    val s3e = s3exp_lintize_flag (env, s3e, flag)
  in
    if flag > flag0 then s3exp_S3Ebineq (knd, s3e) else s3e0
  end // end of [S3Ebineq]
//
| ~S3Ebdom _ => s3e0
//
| ~S3Eiatm _ => let
    val () = flag := flag + 1
    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)
  in
    s3exp_var (s2v)
  end // end of [val]
| ~S3Eicff
    (cff, s3e) => let
    val s3e = s3exp_lintize_flag (env, s3e, flag)
  in
    if flag > flag0 then s3exp_S3Eicff (cff, s3e) else s3e0
  end // end of [S3Eicff
//
| ~S3Eisum (s3es) => let
    val s3es =
      s3explst_lintize_flag (env, s3es, flag)
    // end of [s3es]
  in
    if flag > flag0 then s3exp_S3Eisum (s3es) else s3e0
  end // end of [S3Eisum]
| ~S3Eimul
    (s3e1, s3e2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3e2 = s3exp_lintize_flag (env, s3e2, flag)
    val s3e0 = (
      if flag > flag0 then s3exp_S3Eimul (s3e1, s3e2) else s3e0
    ) : s3exp // end of [val]
    val () = flag := flag + 1
    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)
  in
    s3exp_var (s2v)
  end // end of [S3Eimul]
//
| ~S3Esizeof _ => let
    val () = flag := flag + 1
    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)
  in
    s3exp_var (s2v)
  end // end of [val]
//
| ~S3Eapp
    (s3e1, s3es2) => let
    val s3e1 = s3exp_lintize_flag (env, s3e1, flag)
    val s3es2 = s3explst_lintize_flag (env, s3es2, flag)
    val s3e0 = (
      if flag > flag0 then s3exp_S3Eapp (s3e1, s3es2) else s3e0
    ) : s3exp // end of [val]
    val () = flag := flag + 1
    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)
  in
    s3exp_var (s2v)
  end // end of [S3Eapp]
//
| ~S3Eerr _(*ERROR*) => s3e0
//
end // end of [s3exp_lintize]

(* ****** ****** *)

implement
s3explst_lintize_flag
(
  env, s3es0, flag
) = let
  val flag0 = flag
in
//
if glist_is_cons (s3es0) then let
  val s3e = glist_head<s3exp> (s3es0)
  val s3es = glist_tail<s3exp> (s3es0)
  val s3e = s3exp_lintize_flag (env, s3e, flag)
  val s3es = s3explst_lintize_flag (env, s3es, flag)
in
  if flag > flag0 then glist_cons<s3exp> (s3e, s3es) else s3es0
end else glist_nil{s3exp} ((*void*))
//
end // end of [s3explst_lintize_flag]

(* ****** ****** *)

(* end of [pats_constraint3_simplify.dats] *)
