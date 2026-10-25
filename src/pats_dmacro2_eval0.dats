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
// HX-2026-10: no GC (ATS2 port of src/pats_dmacro2_eval0.dats, see PORTING.md, "Macros (dmacro2)")
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

staload UT = "./pats_utils.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>() = prerr "pats_dmacro2_eval0"
//
(* ****** ****** *)
(*
** for T_* constructors
*)
staload LEX = "./pats_lexing.sats"
staload "./pats_lexing.sats"

(* ****** ****** *)
//
staload LOC = "./pats_location.sats"
//
staload SYM = "./pats_symbol.sats"
//
macdef symbol_ADD = $SYM.symbol_ADD
macdef symbol_SUB = $SYM.symbol_SUB
macdef symbol_MUL = $SYM.symbol_MUL
//
macdef symbol_LT = $SYM.symbol_LT
macdef symbol_LTEQ = $SYM.symbol_LTEQ
//
macdef symbol_GT = $SYM.symbol_GT
macdef symbol_GTEQ = $SYM.symbol_GTEQ
//
macdef symbol_EQ = $SYM.symbol_EQ
macdef symbol_LTGT = $SYM.symbol_LTGT
macdef symbol_BANGEQ = $SYM.symbol_BANGEQ
//
macdef symbol_CAR = $SYM.symbol_CAR
macdef symbol_CDR = $SYM.symbol_CDR
macdef symbol_ISNIL = $SYM.symbol_ISNIL
macdef symbol_ISCONS = $SYM.symbol_ISCONS
macdef symbol_ISLIST = $SYM.symbol_ISLIST
//
overload = with $SYM.eq_symbol_symbol
//
staload SYN = "./pats_syntax.sats"
staload "./pats_syntax.sats"
//
(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"

(* ****** ****** *)

staload "./pats_dmacro2.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

typedef loc_t = $LOC.location

(* ****** ****** *)
//
// HX: not qualified dynamic symbol
//
fn
d2sym_is_nonqua
  (d2s: d2sym): bool = let
  val q = d2s.d2sym_qua () in
  case+ $SYN.d0ynq_node_view (q.d0ynq_node ()) of
  | ~$SYN.D0YNQnone () => true
  | v => ($SYN.d0ynq_node_view_free (v); false)
end // end of [d2sym_is_nonqua]

(* ****** ****** *)
//
// the accessor of the macro values (the caller has tested the tag)
//
fn
m2val_int_get (x: m2val): int =
(
  case+ m2val_view (x) of
  | ~M2Vint (i) => i
  | v => (m2val_view_free (v); 0)
)
//
(* ****** ****** *)
//
// HX-2012-08:
// it is largely unclear how useful this feature is; so it is
// now only given a primitive implementation, which can be readily
// made more elaborate when a convincing need for it appears.
//
//
extern
fun
eval0_app_sym
(
  loc: loc_t
, sym: symbol
, ctx: !evalctx
, env: &alphenv, d2as: d2exparglst
) : m2val // end of [eval0_app_sym]

(* ****** ****** *)

local

(* ****** ****** *)

fn
eval0_app_add
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
in
//
if m2val_is_M2Vint (m2v1) then
(
  if m2val_is_M2Vint (m2v2)
    then m2val_M2Vint (m2val_int_get (m2v1) + m2val_int_get (m2v2))
    else m2val_M2Verr ()
) else m2val_M2Verr ((*void*))
//
end // end of [eval0_app_add]

fn
eval0_app_sub
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
in
//
if m2val_is_M2Vint (m2v1) then
(
  if m2val_is_M2Vint (m2v2)
    then m2val_M2Vint (m2val_int_get (m2v1) - m2val_int_get (m2v2))
    else m2val_M2Verr ()
) else m2val_M2Verr ((*void*))
//
end // end of [eval0_app_sub]

fn
eval0_app_mul
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
in
//
if m2val_is_M2Vint (m2v1) then
(
  if m2val_is_M2Vint (m2v2)
    then m2val_M2Vint (m2val_int_get (m2v1) * m2val_int_get (m2v2))
    else m2val_M2Verr ()
) else m2val_M2Verr ((*void*))
//
end // end of [eval0_app_mul]

(* ****** ****** *)

fn
eval0_app_cmp_int
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : int(*Sgn*) = let
//
fn
auxerr
(
  loc0: loc_t
, m2v1: m2val, m2v2: m2val
) : int = let
  val () =
  prerr_errmac_loc(loc0)
  val () =
  (
    prerr ": values are compared that do not support comparison.";
    prerr_newline ()
  )
  val () =
  the_trans3errlst_add(trans3err_T3E_dmacro_eval0_cmp(loc0, m2v1, m2v2))
in
  0(*meaningless*)
end // end of [auxerr]
//
in
//
if m2val_is_M2Vint (m2v1) then
(
  if m2val_is_M2Vint (m2v2) then let
    val i1 = m2val_int_get (m2v1) and i2 = m2val_int_get (m2v2)
  in
    if i1 < i2 then ~1 else (if i1 > i2 then 1 else 0)
  end else auxerr(loc0, m2v1, m2v2)
) else auxerr(loc0, m2v1, m2v2)
//
end // end of [eval0_app_cmp_int]

(* ****** ****** *)

fn
eval0_app_lt
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val sgn = eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn < 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_lt]

fn
eval0_app_lte
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val sgn = eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn <= 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_lte]

(* ****** ****** *)

fn
eval0_app_gt
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val sgn = eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn > 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_gt]

fn
eval0_app_gte
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val sgn = eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn >= 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_gte]

(* ****** ****** *)

fn
eval0_app_eq
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val
sgn = eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn = 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_eq]

fn
eval0_app_neq
(
  loc0: loc_t, m2v1: m2val, m2v2: m2val
) : m2val = let
//
val sgn= eval0_app_cmp_int(loc0, m2v1, m2v2)
//
in
  if sgn != 0 then m2val_true else m2val_false
end // end of [eval0_exp_app_neq]

(* ****** ****** *)

fn
d2exparg_get_d2explst
  (d2a: d2exparg): d2explst = let
in
  case+ d2exparg_view (d2a) of
  | ~D2EXPARGdyn
    (
      _(*npf*), _(*loc*), d2es
    ) => d2es
  | ~D2EXPARGsta (_, _) => glist_nil((*void*))
end // end of [d2exparg_get_d2explst]

(* ****** ****** *)

fn
eval0_d2exparg_1
(
  loc: loc_t
, ctx: !evalctx
, env: &alphenv, d2a: d2exparg
) : m2val = let
//
val
d2es = d2exparg_get_d2explst(d2a)
//
in
//
case+ glist_view (d2es) of
| ~GLnil
    () => m2val_M2Verr()
  // list_nil
| ~GLcons
    (d2e, _) =>
  (
    eval0_d2exp(loc, ctx, env, d2e)
  ) (* list_cons *)
//
end // end of [eval0_d2exparg_1]

fn
eval0_d2exparglst_1
(
  loc: loc_t
, ctx: !evalctx
, env: &alphenv, d2as: d2exparglst
) : m2val = (
//
case+ glist_view (d2as) of
| ~GLnil
    () => m2val_M2Verr()
  // list_nil
| ~GLcons
    (d2a, _) =>
  (
    eval0_d2exparg_1(loc, ctx, env, d2a)
  ) // end of [list_cons]
//
) // end of [eval0_d2exparglst_1]

(* ****** ****** *)

typedef m2val2 = @(m2val, m2val)

(* ****** ****** *)

fn
eval0_d2exparg_2
(
  loc: loc_t
, ctx: !evalctx
, env: &alphenv, d2a: d2exparg
) : m2val2 = let
  val d2es = d2exparg_get_d2explst(d2a)
in
//
case+ glist_view (d2es) of
| ~GLnil
    () => @(m2val_M2Verr(), m2val_M2Verr())
  // list_nil
| ~GLcons
    (d2e1, d2es) => let
    val m2v1 = eval0_d2exp(loc, ctx, env, d2e1)
  in
    case+ glist_view (d2es) of
    | ~GLnil() =>
      @(m2v1, m2val_M2Verr())
    | ~GLcons(d2e2, _) => let
        val m2v2 = eval0_d2exp(loc, ctx, env, d2e2)
      in
        @(m2v1, m2v2)
      end // end of [list_cons]
  end // end of [list_cons]
//
end // end of [eval0_d2exparg_2]

fn
eval0_d2exparglst_2
(
  loc: loc_t
, ctx: !evalctx
, env: &alphenv, d2as: d2exparglst
) : m2val2 = let
in
//
case+ glist_view (d2as) of
| ~GLnil() => @(m2val_M2Verr(), m2val_M2Verr())
| ~GLcons(d2a, _) =>
    eval0_d2exparg_2(loc, ctx, env, d2a)
  // end of [list_cons]
//
end // end of [eval0_d2exparglst_2]

(* ****** ****** *)

in (* in of [local] *)

implement
eval0_app_sym
(
  loc0, sym, ctx, env, d2as
) = let
in
//
if
  sym = symbol_ADD then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_add(loc0, m2v1, m2v2)
  end
else if
    sym = symbol_SUB then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_sub(loc0, m2v1, m2v2)
  end
else if
    sym = symbol_MUL then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_mul(loc0, m2v1, m2v2)
  end
//
else if
    sym = symbol_LT then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_lt (loc0, m2v1, m2v2)
  end
else if
    sym = symbol_LTEQ then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_lte(loc0, m2v1, m2v2)
  end
//
else if
    sym = symbol_GT then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_gt (loc0, m2v1, m2v2)
  end
else if
    sym = symbol_GTEQ then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_gte(loc0, m2v1, m2v2)
  end
//
else if
    sym = symbol_EQ then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_eq (loc0, m2v1, m2v2)
  end
else if
    sym = symbol_LTGT then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_neq(loc0, m2v1, m2v2)
  end
else if
    sym = symbol_BANGEQ then let
    val (m2v1, m2v2) =
      eval0_d2exparglst_2(loc0, ctx, env, d2as)
    // end of [val]
  in
    eval0_app_neq(loc0, m2v1, m2v2)
  end
//
else (*unrecognized-operator*) m2val_M2Verr((*void*))
//
end // end of [eval0_app_sym]

end // end of [local]

(* ****** ****** *)

fn
eval0_app_eval
(
  loc0: loc_t, m2v: m2val
) : m2val = let
//
fn
auxerr
(
  loc0: loc_t, m2v: m2val
) : m2val = m2val_M2Verr() where
{
  val () =
  prerr_errmac_loc(loc0)
  val () =
  (
    prerr ": evaluation is performed on a value not representing code.";
    prerr_newline ()
  ) (* println! *)
} (* end of [auxerr] *)
//
in
//
case+ m2val_view (m2v) of
| ~M2Vdcode(d2e) => let
    var ctx = evalctx_nil()
    var env = alphenv_nil()
    val m2v_res = eval0_d2exp(loc0, ctx, env, d2e)
    val () = alphenv_free(env)
    val () = evalctx_free(ctx)
  in
    m2v_res
  end // end of [V2ALcode]
| v (*M2Vdcode*) => let
    val () = m2val_view_free (v) in auxerr(loc0, m2v)
  end
//
end // end of [eval0_app_eval]

(* ****** ****** *)

fn
eval0_app_lift
(
  loc0: loc_t, m2v: m2val
) : m2val = let
  val d2e = liftval2dexp(loc0, m2v) in m2val_M2Vdcode(d2e)
end // end of [eval0_app_lift]

(* ****** ****** *)

fn eval0_car
  (m2vs: m2valist): m2val =
  case+ glist_view (m2vs) of
  | ~GLcons(m2v, _) =>
    (
    case+ m2val_view (m2v) of
    | ~M2Vlist (m2vs) =>
      (
      case+ glist_view (m2vs) of
      | ~GLcons(m2v, _) => m2v | ~GLnil() => m2val_M2Verr()
      )
    | v (*non-M2Vlist*) => (m2val_view_free (v); m2val_M2Verr())
    )
  | ~GLnil((*void*)) => m2val_M2Verr() // argumentless
// end of [eval0_car]

fn eval0_cdr
  (m2vs: m2valist): m2val =
  case+ glist_view (m2vs) of
  | ~GLcons(m2v, _) =>
    (
    case+ m2val_view (m2v) of
    | ~M2Vlist(m2vs) =>
      (
      case+ glist_view (m2vs) of
      | ~GLcons
          (_, m2vs) => m2val_M2Vlist(m2vs) | ~GLnil() => m2val_M2Verr()
        // list_cons
      )
    | v (*non-M2Vlist*) => (m2val_view_free (v); m2val_M2Verr())
    )
  | ~GLnil((*void*)) => m2val_M2Verr() // argumentless
// end of [eval0_cdr]

(* ****** ****** *)

fn
eval0_islist
  (m2vs: m2valist): m2val =
(
  case+ glist_view (m2vs) of
  | ~GLcons(m2v, _) =>
    (
    if m2val_is_M2Vlist (m2v)
      then m2val_M2Vbool(true) else m2val_M2Vbool(false)
    )
  | ~GLnil((*void*)) => m2val_M2Verr() // argumentless
) // end of [eval0_islist]

(* ****** ****** *)
//
fn
eval0_isnil
  (m2vs: m2valist): m2val =
(
  case+ glist_view (m2vs) of
  | ~GLcons(m2v, _) =>
    (
    case+ m2val_view (m2v) of
    | ~M2Vlist(m2vs) =>
      (
      if glist_is_cons (m2vs) then m2val_M2Vbool(false) else m2val_M2Vbool(true)
      )
    | v (*M2Vlist*) => (m2val_view_free (v); m2val_M2Verr())
    )
  | ~GLnil((*void*)) => m2val_M2Verr () // argumentless
) // end of [eval0_isnil]
//
fn
eval0_iscons
  (m2vs: m2valist): m2val =
(
  case+ glist_view (m2vs) of
  | ~GLcons(m2v, _) =>
    (
    case+ m2val_view (m2v) of
    | ~M2Vlist(m2vs) =>
      (
      if glist_is_cons (m2vs) then m2val_M2Vbool(true) else m2val_M2Vbool(false)
      )
    | v (*M2Vlist*) => (m2val_view_free (v); m2val_M2Verr())
    )
  | ~GLnil((*void*)) => m2val_M2Verr() // argumentless
) // end of [eval0_iscons]
//
(* ****** ****** *)

fn
eval0_d2var
(
  loc: loc_t
, ctx: !evalctx, d2v: d2var
) : m2val = let
//
fn
auxerr
(
  loc: loc_t, d2v: d2var
) : m2val = let
  val () =
  prerr_errmac_loc(loc)
  val () =
  (
    prerr ": the variable [";
    prerr_d2var(d2v); prerr "] is unbound."
  ) (* end of [val] *)
  val () = prerr_newline()
in
  m2val_M2Verr((*void*))
end (* end of [auxerr] *)
//
val opt = evalctx_dfind(ctx, d2v)
//
in
//
case+ opt of
| ~Some_vt(m2v) => m2v
| ~None_vt((*void*)) => auxerr(loc, d2v)
//
end (* end of [eval0_d2var] *)

(* ****** ****** *)
//
extern
fun
eval0_d2explst
(
  loc: loc_t
, ctx: !evalctx, env: &alphenv, d2es: d2explst
) : m2valist // end of [eval0_d2expopt]
implement
eval0_d2explst
  (loc, ctx, env, d2es) = let
in
  case+ glist_view (d2es) of
  | ~GLcons
      (d2e, d2es) => let
      val m2v = eval0_d2exp(loc, ctx, env, d2e)
      val m2vs = eval0_d2explst(loc, ctx, env, d2es)
    in
      glist_cons<m2val>(m2v, m2vs)
    end // end of [list_cons]
  | ~GLnil((*void*)) => glist_nil()
end // end of [eval0_d2explst]
//
(* ****** ****** *)
//
extern
fun
eval0_d2expopt
(
  loc: loc_t
, ctx: !evalctx, env: &alphenv, opt: d2expopt
) : m2val // end of [eval0_d2expopt]
implement
eval0_d2expopt
  (loc, ctx, env, opt) = let
in
  case+ gopt_view (opt) of
  | ~GOnone() => m2val_M2Vunit()
  | ~GOsome(d2e) => eval0_d2exp(loc, ctx, env, d2e)
end // end of [eval0_d2expopt]
//
(* ****** ****** *)

implement
eval0_d2exp
  (loc, ctx, env, d2e0) = let
//
macdef
eval0dexp(x) = eval0_d2exp(loc, ctx, env, ,(x))
macdef
eval0dexplst(x) = eval0_d2explst(loc, ctx, env, ,(x))
macdef
eval0dexpopt(x) = eval0_d2expopt(loc, ctx, env, ,(x))
//
in
//
case+
d2exp_node_view (d2e0.d2exp_node ())
of // case+
//
| ~D2Evar(d2v) =>
    m2v where {
    val m2v = eval0_d2var(loc, ctx, d2v)
  } (* end of [D2Evar] *)
//
| ~D2Eint(i) => m2val_M2Vint(i)
| ~D2Echar(c) => m2val_M2Vchar(c)
| ~D2Efloat(rep) => m2val_M2Vfloat(rep)
| ~D2Estring(str) => m2val_M2Vstring(str)
//
| ~D2Ei0nt(x) => let
    val rep = token_int_rep (x)
  in
    m2val_M2Vint($UN.cast{int}($UT.llint_make_string(rep)))
  end // end of [D2Ei0nt]
| ~D2Ec0har(x) => let
    val c = token_char_get (x) in m2val_M2Vchar(c)
    // end of [val]
  end // end of [D2Ec0har]
| ~D2Ef0loat(x) => let
    val rep = token_float_rep (x) in m2val_M2Vfloat(rep)
    // end of [val]
  end // end of [D2Ef0loat]
| ~D2Es0tring(x) => let
    val s = token_string_get (x) in m2val_M2Vstring(s)
  end // end of [D2Es0tring]
//
| ~D2Esing(d2e) => eval0dexp(d2e)
//
| ~D2Eapplst
    (d2e, d2as) => let
    fn auxerr (loc: loc_t, d2e: d2exp): m2val = let
      val () = prerr_errmac_loc(loc)
      val () = prerr ": the dynamic expression at ("
      val () = $LOC.prerr_location(d2e.d2exp_loc ())
      val () = prerr ") should be a macro but it is not."
      val () = prerr_newline((*void*))
    in
      m2val_M2Verr((*void*))
    end // end of [auxerr]
  in
  case+
  d2exp_node_view (d2e.d2exp_node ())
  of // case+
  | ~D2Emac(d2m) =>
    (
      // expanding a macro in long form
      eval0_app_mac_long (loc, d2m, ctx, env, d2as)
    ) // end of [D2Emac]
  | ~D2Esym(d2s) =>
    (
    if d2sym_is_nonqua d2s then
    (
      // evaluating a predefined function (e.g., +, -, etc.)
      eval0_app_sym (loc, d2s.d2sym_sym (), ctx, env, d2as)
    ) else auxerr (loc, d2e)
    ) // end of [D2Esym]
  | v => (d2exp_node_view_free (v); auxerr (loc, d2e))
  end // end of [D2Eapplst]
//
| ~D2Eifhead
  (
    i2nv, test, _then, _else
  ) => let
    val test = eval0dexp (test)
  in
    case+ m2val_view (test) of
    | ~M2Vbool (b) =>
        if b then eval0dexp (_then) else eval0dexpopt (_else)
      // end of [M2Vbool]
    | v => (m2val_view_free (v); m2val_M2Verr ())
  end // end of [D2Eifhead]
//
| ~D2Emac(d2m) => let
    val d2as = glist_nil() // argumentless
  in
    eval0_app_mac_long(loc, d2m, ctx, env, d2as)
  end // end of [D2Emac]
//
| ~D2Emacsyn(knd, d2e) =>
  (
  case+ knd of
  | $SYN.MSKencode() => let
      val d2e =
        eval1_d2exp(loc, ctx, env, d2e)
      // end of [val]
    in
      m2val_M2Vdcode (d2e)
    end // end of [MSKencode]
  | $SYN.MSKdecode() =>
      eval0_app_eval(loc, eval0dexp(d2e))
    // end of [MSKdecode]
  | $SYN.MSKxstage() => let
      val m2v_res =
        eval0_app_eval(loc, eval0dexp(d2e))
      // end of [val]
    in
      m2val_M2Vdcode(liftval2dexp (loc, m2v_res))
    end // end of [MSKxstage]
  ) // end of [D2Emacsyn]
//
| ~D2Emacfun(name, d2es) => let
    val m2vs = eval0dexplst(d2es)
  in
    if name = symbol_CAR then eval0_car (m2vs)
    else if name = symbol_CDR then eval0_cdr (m2vs)
    else if name = symbol_ISNIL then eval0_isnil (m2vs)
    else if name = symbol_ISCONS then eval0_iscons (m2vs)
    else if name = symbol_ISLIST then eval0_islist (m2vs)
    else m2val_M2Verr ()
  end // end of [D2Emacfun]
//
| v (*rest-of-d2exp*) => let
    val () = d2exp_node_view_free (v)
    val () =
    prerr_errmac_loc(loc)
    val () = prerr ": the form of dynamic expression ["
    val () = prerr_d2exp(d2e0)
    val () = prerr "] is unsupported for macro expansion."
    val () = prerr_newline((*void*))
    val () =
      the_trans3errlst_add (trans3err_T3E_dmacro_eval0_d2exp (loc, d2e0))
    // end of [val]
  in
    m2val_M2Verr((*void*))
  end // end of [rest-of-d2exp]
//
end // end of [eval0_d2exp]

(* ****** ****** *)

extern
fun
evalctx_extend_arg
(
  loc: loc_t
, d2m: d2mac
, knd: int (* 0/1: short/long *)
, ctx: !evalctx
, env: &alphenv
, arg: m2acarg
, d2a: d2exparg
, res: evalctx
) : evalctx // end-of-function

extern
fun
evalctx_extend_sarg
(
  loc: loc_t
, d2m: d2mac
, knd: int (* 0/1: short/long *)
, ctx: !evalctx
, env: &alphenv
, sarg: s2varlst, s2es: s2explst
, res: evalctx
) : evalctx // end-of-functio

extern
fun
evalctx_extend_darg
(
  loc: loc_t
, d2m: d2mac
, knd: int (* 0/1: short/long *)
, ctx: !evalctx
, env: &alphenv
, darg: d2varlst, d2es: d2explst
, res: evalctx
) : evalctx // end-of-function

extern
fun
evalctx_extend_arglst
(
  loc: loc_t
, d2m: d2mac
, knd: int (* 0/1: short/long *)
, ctx: !evalctx
, env: &alphenv
, args: m2acarglst
, d2as: d2exparglst
, res: evalctx
) : evalctx // end-of-function

(* ****** ****** *)

implement
evalctx_extend_sarg
(
  loc, d2m, knd, ctx, env, s2vs, s2es, res
) = let
//
fn
auxerr
(
  loc: loc_t, d2m: d2mac, sgn: int
) : void = let
  val () =
  prerr_errmac_loc(loc)
  val () = prerr ": some static argument group of the macro ["
  val () = prerr_d2mac(d2m)
  val () =
  if sgn < 0 then prerr "] is expected to contain more arguments."
  val () =
  if sgn > 0 then prerr "] is expected to contain fewer arguments."
  val () = prerr_newline((*void*))
in
  the_trans3errlst_add(trans3err_T3E_dmacro_evalctx_extend(loc, d2m))
end // end of [auxerr]
//
in
//
case+ glist_view (s2vs) of
| ~GLcons
    (s2v, s2vs) =>
  (
  case+ glist_view (s2es) of
  | ~GLcons
      (s2e, s2es) => let
      val res =
        evalctx_sadd(res, s2v, m2val_M2Vscode(s2e))
      // end of [val]
    in
      evalctx_extend_sarg
        (loc, d2m, knd, ctx, env, s2vs, s2es, res)
      // evalctx_extend_sarg
    end // end of [list_cons]
  | ~GLnil((*void*))=>
    let val () = auxerr(loc, d2m, 1) in res end
  )
| ~GLnil((*void*)) =>
  (
  case+ glist_view (s2es) of
  | ~GLcons (_, _) =>
    let val () = auxerr(loc, d2m, ~1) in res end
  | ~GLnil((*void*)) => res
  )
//
end // end of [evalctx_extend_sarg]

(* ****** ****** *)

implement
evalctx_extend_darg
(
  loc, d2m, knd
, ctx, env, d2vs, d2es, res
) = let
//
fn
auxerr
(
  loc: loc_t, d2m: d2mac, sgn: int
) : void = let
  val () =
  prerr_errmac_loc(loc)
  val () = prerr ": some dynamic argument group of the macro ["
  val () = prerr_d2mac (d2m)
  val () = if sgn < 0 then prerr "] is expected to contain more arguments."
  val () = if sgn > 0 then prerr "] is expected to contain fewer arguments."
  val () = prerr_newline((*void*))
in
  the_trans3errlst_add(trans3err_T3E_dmacro_evalctx_extend(loc, d2m))
end // end of [auxerr]
//
fn
auxexp
(
  loc: loc_t, knd: int
, ctx: !evalctx, env: &alphenv, d2e: d2exp
) : m2val = let
in
//
if knd >= 1 then
  eval0_d2exp(loc, ctx, env, d2e)
else let // short form
  val d2e =
    eval1_d2exp(loc, ctx, env, d2e) in m2val_M2Vdcode(d2e)
  // end of [val]
end // end of [if]
//
end // end of [auxexp]
//
fun
auxexplst
(
  loc: loc_t, knd: int
, ctx: !evalctx, env: &alphenv, d2es: d2explst
) : m2valist = let
in
//
case+ glist_view (d2es) of
| ~GLcons
    (d2e, d2es) => let
    val m2v = auxexp(loc, knd, ctx, env, d2e)
    val m2vs = auxexplst(loc, knd, ctx, env, d2es)
  in
    glist_cons<m2val>(m2v, m2vs)
  end // end of [list_cons]
| ~GLnil((*void*)) => glist_nil((*void*))
//
end // end of [auxexplst]
//
in
//
case+ glist_view (d2vs) of
| ~GLcons
    (d2v, d2vs1) =>
  (
  if glist_is_nil (d2vs1) then (
  case+ glist_view (d2es) of
  | ~GLcons
      (d2e, d2es1) =>
    (
    if glist_is_nil (d2es1) then let
      val m2v =
        auxexp(loc, knd, ctx, env, d2e)
      // end of [val]
    in
      evalctx_dadd(res, d2v, m2v)
    end // end of [list_sing]
    else let
      val m2vs =
        auxexplst(loc, knd, ctx, env, glist_cons<d2exp>(d2e, d2es1))
      // end of [val]
    in
      evalctx_dadd(res, d2v, m2val_M2Vlist (m2vs))
    end // end of [_]
    )
  | ~GLnil () => let
      val m2vs =
        auxexplst(loc, knd, ctx, env, glist_nil())
      // end of [val]
    in
      evalctx_dadd(res, d2v, m2val_M2Vlist (m2vs))
    end // end of [_]
  ) // end of [list_sing]
  else (
  case+ glist_view (d2es) of
  | ~GLcons
      (d2e, d2es) => let
      val m2v =
        auxexp(loc, knd, ctx, env, d2e)
      // end of [val]
      val res = evalctx_dadd(res, d2v, m2v)
    in
      evalctx_extend_darg
        (loc, d2m, knd, ctx, env, d2vs1, d2es, res)
      // evalctx_extend_darg
    end // end of [list_cons]
  | ~GLnil((*void*)) => let
      val () = auxerr(loc, d2m, 1) in res
    end // end of [_]
  )
  ) (* end of [GLcons] *)
| ~GLnil((*void*)) =>
  (
  case+ glist_view (d2es) of
  | ~GLcons (_, _) => let
      val () = auxerr(loc, d2m, ~1) in res
    end // end of [list_cons]
  | ~GLnil((*void*)) => res
  )
//
end // end of [evalctx_extend_darg]

(* ****** ****** *)

fun
s2exparglst_join
  (s2as: s2exparglst): s2explst = let
//
fn
auxwarn(loc: loc_t): void =
{
  val () =
  prerr_warning2_loc(loc)
  val () =
  (
    prerr (": the static macro argument is ignored."); prerr_newline ()
  )
} // end of [auxwarn]
//
in
//
case+ glist_view (s2as) of
| ~GLcons
    (s2a, s2as) => (
  case+
    s2exparg_node_view (s2a.s2exparg_node ()) of
  | ~S2EXPARGseq (s2es) => (
    if glist_is_cons (s2as) then let
        val s2es2 =
          s2exparglst_join (s2as) in glist_append<s2exp> (s2es, s2es2)
        // end of [val]
      end // end of [list_cons]
    else s2es // HX: this is most likely by far!
    )
  | ~S2EXPARGone () => let
      val () =
        auxwarn (s2a.s2exparg_loc ()) in s2exparglst_join (s2as)
      // end of [val]
    end // end of [S2EXPARGone]
  | ~S2EXPARGall () => let
      val () =
        auxwarn (s2a.s2exparg_loc ()) in s2exparglst_join (s2as)
      // end of [val]
    end // end of [S2EXPARGall]
  ) // end of [list_cons]
| ~GLnil () => glist_nil ()
//
end // end of [s2exparglst_join]

(* ****** ****** *)

implement
evalctx_extend_arg
(
  loc, d2m, knd
, ctx, env, arg, d2a, res
) = let
//
fn
auxerr
(
  loc: loc_t
, loca: loc_t, d2m: d2mac, stadyn: int
) : void = let
  val () =
  prerr_errmac_loc(loc)
  val () =
  prerr(": the macro argument at (")
  val () =
  $LOC.prerr_location(loca)
  val () =
  if (stadyn = 0) then prerr ") is expected to be static."
  val () =
  if (stadyn > 0) then prerr ") is expected to be dynamic."
  val () = prerr_newline((*void*))
in
  the_trans3errlst_add(trans3err_T3E_dmacro_evalctx_extend(loc, d2m))
end // end of [auxerr_dyn]
//
in
//
case+ m2acarg_view (arg) of
| ~M2ACARGsta(s2vs) =>
  (
  case+ d2exparg_view (d2a) of
  | ~D2EXPARGsta(loca, s2as) => let
      val s2es = s2exparglst_join(s2as)
    in
      evalctx_extend_sarg
        (loc, d2m, knd, ctx, env, s2vs, s2es, res)
      // evalctx_extend_sarg
    end // end of [D2EXPARGsta]
  | ~D2EXPARGdyn(npf, loca, _) => let
      val () = auxerr (loc, loca, d2m, 0(*sta*)) in res
    end // end of [D2EXPARGdyn]
  )
| ~M2ACARGdyn(d2vs) =>
  (
  case+ d2exparg_view (d2a) of
  | ~D2EXPARGdyn
      (npf, loca, d2es) =>
    (
      evalctx_extend_darg
        (loc, d2m, knd, ctx, env, d2vs, d2es, res)
      // evalctx_extend_darg
    )
  | ~D2EXPARGsta(loca, s2es) => let
      val () = auxerr(loc, loca, d2m, 1(*dyn*)) in res
    end // end of [D2EXPARGsta]
  )
//
end // end of [eval0ctx_extend_arg]

(* ****** ****** *)

implement
evalctx_extend_arglst
(
  loc, d2m, knd
, ctx, env, args, d2as, res) = let
in
//
case+ glist_view (args) of
| ~GLnil
    ((*void*)) => res
  // list_nil
| ~GLcons
    (arg, args) => let
    // HX: [val-list_cons(d2a, d2as) = d2as] (MatchError)
    val () = assertloc (glist_is_cons (d2as))
    val d2a = glist_head<d2exparg> (d2as)
    val d2as = glist_tail<d2exparg> (d2as)
    val res =
      evalctx_extend_arg(loc, d2m, knd, ctx, env, arg, d2a, res)
    // end of [val]
  in
    evalctx_extend_arglst(loc, d2m, knd, ctx, env, args, d2as, res)
  end // end of [list_cons]
//
end // end of [evalctx_extend_arglst]

(* ****** ****** *)
//
// HX: the first [n] elements and the others (list_split_at)
//
fun
d2exparglst_take
  (xs: d2exparglst, n: int): d2exparglst =
(
  if n <= 0 then glist_nil() else
  (
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => glist_cons<d2exparg> (x, d2exparglst_take (xs, n-1))
    | ~GLnil () => glist_nil()
  )
)
//
fun
d2exparglst_drop
  (xs: d2exparglst, n: int): d2exparglst =
(
  if n <= 0 then xs else
  (
    case+ glist_view (xs) of
    | ~GLcons (_, xs) => d2exparglst_drop (xs, n-1)
    | ~GLnil () => glist_nil()
  )
)
//
(* ****** ****** *)
//
// HX: expanding macros in long form
//
implement
eval0_app_mac_long
(
  loc, d2m, ctx, env, d2as
) = m2v where
{
//
val n0 = glist_length(d2as)
val args = d2mac_get_arglst(d2m)
val narg = glist_length(args)
//
val () = (
if
(n0 != narg)
then let
  val () =
  prerr_errmac_loc(loc)
  val () =
  prerr ": the macro function ["
  val () =
  prerr_d2mac(d2m)
  val () =
  if n0 > narg then prerr "] is overlly applied."
  val () =
  if n0 < narg then prerr "] is applied insufficiently."
  val () = prerr_newline((*void*))
in
  the_trans3errlst_add
    (trans3err_T3E_dmacro_eval0_app_mac_arity(loc, d2m, d2as))
  // the_trans3errlst_add
end // end of [if]
) : void // end of [val]
//
val
ctx_new =
evalctx_nil ()
val
ctx_new =
evalctx_extend_arglst
(
  loc, d2m, 1(*long*), ctx, env, args, d2as, ctx_new
) (* end of [val] *)
//
val d2e =
  d2mac_get_def(d2m)
val m2v =
  eval0_d2exp(loc, ctx_new, env, d2e)
//
val ((*void*)) = evalctx_free(ctx_new)
//
} (* end of [eval0_app_mac_long] *)

(* ****** ****** *)
//
// HX: expanding macros in short form
//
implement
eval0_app_mac_short
  (loc, d2m, ctx, env, d2as) = let
//
val n0 = glist_length(d2as)
val args = d2mac_get_arglst(d2m)
val narg = glist_length(args)
//
val () =
(
//
if
(n0 < narg)
then let
  val () =
  prerr_errmac_loc(loc)
  val () = prerr ": the macro function ["
  val () = prerr_d2mac(d2m)
  val () = prerr "] is applied insufficiently."
  val () = prerr_newline((*void*))
in
  the_trans3errlst_add
    (trans3err_T3E_dmacro_eval0_app_mac_arity(loc, d2m, d2as))
  // the_trans3errlst_add
end // end of [let] // end of [if]
//
) : void // end of [val]
//
val d2as1 =
(
if (n0 >= narg)
  then d2exparglst_take (d2as, narg) else d2as
) : d2exparglst
//
val d2as2 =
(
if (n0 >= narg)
  then d2exparglst_drop (d2as, narg) else glist_nil()
) : d2exparglst // end of [val]
//
val
ctx_new =
evalctx_extend_arglst
(
  loc, d2m, 0(*short*), ctx, env, args, d2as1, evalctx_nil()
) // end of [evalctx_extend_arglst]
//
val d2e =
eval1_d2exp
(
  loc, ctx_new, env, d2mac_get_def(d2m)
) (* end of [val] *)
//
val ((*freed*)) = evalctx_free(ctx_new)
//
in
//
if glist_is_nil (d2as2) then (d2e) else
(
  case+
  d2exp_node_view (d2e.d2exp_node ())
  of (* case+ *)
  | ~D2Eapplst
     (d2e_fun, d2as1) =>
   (
     d2exp_applst
       (loc, d2e_fun, glist_append<d2exparg> (d2as1, d2as2))
   ) // end of [D2Eapplst]
  | v (*non-D2Eapplst*) =>
    (d2exp_node_view_free (v); d2exp_applst(loc, d2e, d2as2))
) (* end of [list_cons] *)
//
end // end of [eval0_app_mac_short]

(* ****** ****** *)

(* end of [pats_dmacro2_eval0.dats] *)
