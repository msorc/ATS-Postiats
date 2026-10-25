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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp1.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload LOC = "./pats_location.sats"
staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_effect.sats"
staload "./pats_lexing.sats"
staload "./pats_syntax_boundary.sats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

#include "./pats_staexp1_gen_dats.hats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

fn prerr_error1_loc
  (loc: location): void = (
  $LOC.prerr_location loc; prerr ": error(1)"
) // end of [prerr_error1_loc]

(* ****** ****** *)

implement
e1xp_make (loc, node) = e1xp_new(loc, node) // end of [e1xp_make]

implement
e1xp_ide (loc, id) = e1xp_make (loc, e1xp_node_E1XPide(id: symbol))

implement
e1xp_int (loc, i) =
  e1xp_make (loc, e1xp_node_E1XPint(i))
implement
e1xp_intrep (loc, rep) =
  e1xp_make (loc, e1xp_node_E1XPintrep(rep))
// end of [e1xp_intrep]
implement
e1xp_char (loc, c) = e1xp_make (loc, e1xp_node_E1XPchar(c: char))
implement
e1xp_string (loc, str) = e1xp_make (loc, e1xp_node_E1XPstring(str))
implement
e1xp_float (loc, rep) = e1xp_make (loc, e1xp_node_E1XPfloat(rep))

(* ****** ****** *)

implement
e1xp_i0nt
  (loc, x) = let
  val rep = token_int_rep (x)
in
  e1xp_intrep (loc, rep)
end // end of [e1xp_i0nt]
implement
e1xp_c0har (loc, x) = let
  val c = token_char_get (x) in e1xp_char (loc, c)
end // end of [e1xp_c0har]
implement
e1xp_s0tring (loc, x) = let
  val s = token_string_get (x) in e1xp_string (loc, s)
end // end of [e1xp_s0tring]
implement
e1xp_f0loat (loc, x) = let
  val rep = token_float_rep (x)
in
  e1xp_float (loc, rep)
end // end of [e1xp_s0tring]

(* ****** ****** *)
//
implement
e1xp_v1al
  (loc, v) = e1xp_make (loc, e1xp_node_E1XPv1al(v))
//
(* ****** ****** *)

implement
e1xp_none (loc) = e1xp_make (loc, e1xp_node_E1XPnone())
implement
e1xp_undef (loc) = e1xp_make (loc, e1xp_node_E1XPundef())

(* ****** ****** *)

implement
e1xp_app
(
  loc, e_fun, loc_arg, es_arg
) = e1xp_make (loc, e1xp_node_E1XPapp(e_fun, loc_arg, es_arg))

implement
e1xp_fun
  (loc, arg, body) = e1xp_make (loc, e1xp_node_E1XPfun(arg, body))
// end of [e1xp_fun]

(* ****** ****** *)
//
implement
e1xp_if (loc, _cond, _then, _else) =
  e1xp_make (loc, e1xp_node_E1XPif(_cond, _then, _else))
//
(* ****** ****** *)
//
implement
e1xp_eval (loc, e) = e1xp_make (loc, e1xp_node_E1XPeval(e: e1xp))
//
implement
e1xp_list (loc, es) = e1xp_make (loc, e1xp_node_E1XPlist(es: e1xplst))
//
(* ****** ****** *)

implement
e1xp_err (loc) = e1xp_make (loc, e1xp_node_E1XPerr())

(* ****** ****** *)

implement e1xp_true (loc) = e1xp_int (loc, 1)
implement e1xp_false (loc) = e1xp_int (loc, 0)

(* ****** ****** *)

implement v1al_true = v1al_V1ALint(1)
implement v1al_false = v1al_V1ALint(0)

(* ****** ****** *)

implement effcst_nil = effcst_EFFCSTnil()
implement effcst_all = effcst_EFFCSTall()
implement effcst_ntm = effcst_EFFCSTset(effset_ntm, glist_nil())
implement effcst_exn = effcst_EFFCSTset(effset_exn, glist_nil())
implement effcst_ref = effcst_EFFCSTset(effset_ref, glist_nil())
implement effcst_wrt = effcst_EFFCSTset(effset_wrt, glist_nil())

implement
effcst_contain
  (efc, eff) = case+ effcst_view(efc) of
  | ~EFFCSTall () => true
  | ~EFFCSTnil () => false
  | ~EFFCSTset (efs, evs)  => effset_ismem (efs, eff)
// end of [effcst_contain]

implement
effcst_contain_ntm (efc) = effcst_contain (efc, effect_ntm)

(* ****** ****** *)

(*
** HX: functions for constructing sorts
*)

macdef MINUSGT = $SYM.symbol_MINUSGT
overload = with $SYM.eq_symbol_symbol

fn s0rtq_is_none (q: s0rtq): bool =
  s0rtq_node_is_S0RTQnone (q.s0rtq_node())
// end of [s0rtq_is_none]

(* ****** ****** *)

implement
s1rt_arrow (loc) = let
  val q = s0rtq_none (loc) in s1rt_new(loc, s1rt_node_S1RTqid(q, MINUSGT)) end // end of [s1rt_arrow]

(* '->' is a special sort constructor *)
implement
s1rt_is_arrow (s1t) =
  case+ s1rt_node_view(s1t.s1rt_node()) of
  | ~S1RTqid (q, id) =>
      if s0rtq_is_none q then id = MINUSGT else false
    // end of [S1RTqid]
  | v => (s1rt_node_view_free (v); false) // end of [_]
// end of [s1rt_is_arrow]

(* ****** ****** *)

implement
s1rt_app (
  loc, s1t_fun, s1ts_arg
) = s1rt_new(loc, s1rt_node_S1RTapp(s1t_fun, s1ts_arg)) // end of [s1rt_app]

implement
s1rt_fun (loc, s1t1, s1t2) = let
  val s1ts = glist_cons(s1t1, glist_cons(s1t2, glist_nil()))
in s1rt_new(loc, s1rt_node_S1RTapp(s1rt_arrow (loc), s1ts)) end // end of [s1rt_fun]

implement
s1rt_ide (loc, id) = let
  val q = s0rtq_none (loc) in s1rt_new(loc, s1rt_node_S1RTqid(q, id)) end // end of [s1rt_ide]

implement
s1rt_list
  (loc, s1ts) = case+ glist_view(s1ts) of
  | ~GLcons (s1t, s1ts1) =>
      if glist_is_nil (s1ts1)
        then s1t // singleton elimination
        else s1rt_new(loc, s1rt_node_S1RTlist(s1ts))
      // end of [GLcons]
  | ~GLnil () => s1rt_new(loc, s1rt_node_S1RTlist(s1ts)) // end of [_]
// end of [s1rt_list]

implement
s1rt_qid (loc, q, id) = s1rt_new(loc, s1rt_node_S1RTqid(q, id)) // end of [s1rt_qid]

(*
implement
s1rt_tup (loc, s1ts) = '{
  s1rt_loc= loc, s1rt_node= S1RTtup s1ts
} // end of [s1rt_tup]
*)

implement
s1rt_type (loc, knd) = s1rt_new(loc, s1rt_node_S1RTtype(knd))

implement
s1rt_err (loc) = s1rt_new(loc, s1rt_node_S1RTerr())

(* ****** ****** *)

implement
s1rtpol_make (loc, s1t, pol) = s1rtpol_new(loc, s1t, pol) // end of [s1rtpol_make]

(* ****** ****** *)

implement
d1atsrtcon_make
  (loc, name, arg) = d1atsrtcon_new(loc, name, arg) // end of [d1atsrtcon_make]

implement
d1atsrtdec_make
  (loc, name, conlst) = d1atsrtdec_new(loc, name, conlst) // end of [d1atsrtdec_make]

(* ****** ****** *)

implement
s1arg_make (loc, sym, res) = s1arg_new(loc, sym, res)

implement
s1marg_make (loc, s1as) = s1marg_new(loc, s1as)

(* ****** ****** *)

implement
a1srt_make (loc, sym, srt) = a1srt_new(loc, sym, srt)
implement
a1msrt_make (loc, arg) = a1msrt_new(loc, arg)

(* ****** ****** *)

implement
sp1at_cstr
  (loc, q, id, arg) = sp1at_new(loc, sp1at_node_SP1Tcstr(q, id, arg)) // end of [sp1at_cstr]

(* ****** ****** *)

implement
s1exp_ide
  (loc, id) = s1exp_new(loc, s1exp_node_S1Eide(id)) (* end of [s1exp_ide] *)

implement
s1exp_sqid
  (loc, sq, id) = s1exp_new(loc, s1exp_node_S1Esqid(sq, id)) (* end of [s1exp_sqid] *)

(* ****** ****** *)

implement
s1exp_int
  (loc, int) = s1exp_new(loc, s1exp_node_S1Eint(int)) (* end of [s1exp_int] *)

implement
s1exp_intrep
  (loc, rep) = s1exp_new(loc, s1exp_node_S1Eintrep(rep)) (* end of [s1exp_intrep] *)

implement
s1exp_i0nt
  (loc, x) = let
  val rep = token_int_rep (x)
in
  s1exp_intrep (loc, rep)
end // end of [s1exp_i0nt]

(* ****** ****** *)

implement
s1exp_char (loc, c) = s1exp_new(loc, s1exp_node_S1Echar(c)) // end of [s1exp_char]
implement
s1exp_c0har (loc, x) = let
  val c = token_char_get (x)
in s1exp_new(loc, s1exp_node_S1Echar(c)) end // end of [s1exp_c0har]

(* ****** ****** *)

implement
s1exp_float (loc, x) = s1exp_new(loc, s1exp_node_S1Efloat(x)) (* end of [s1exp_float] *)
implement
s1exp_f0loat (loc, x) = let
  val rep = token_float_rep (x)
in s1exp_new(loc, s1exp_node_S1Efloat(rep)) end // end of [s1exp_f0loat]

(* ****** ****** *)

implement
s1exp_string (loc, x) = s1exp_new(loc, s1exp_node_S1Estring(x)) (* end of [s1exp_string] *)
implement
s1exp_s0tring (loc, x) = let
  val str = token_string_get (x)
in s1exp_new(loc, s1exp_node_S1Estring(str)) end // end of [s1exp_s0tring]

(* ****** ****** *)
//
implement
s1exp_extype
  (loc, name, arg) = s1exp_new(loc, s1exp_node_S1Eextype(name, arg))
//
implement
s1exp_extkind
  (loc, name, arg) = s1exp_new(loc, s1exp_node_S1Eextkind(name, arg))
//
(* ****** ****** *)

implement
s1exp_app (
  loc, _fun, loc_arg, _arg
) = s1exp_new(loc, s1exp_node_S1Eapp(_fun, loc_arg, _arg)) // end of [s1exp_app]

implement
s1exp_lam (
  loc, arg, res, body
) = s1exp_new(loc, s1exp_node_S1Elam(arg, res, body))

implement
s1exp_imp (
  loc, ft, is_lin, is_prf, efc
) = s1exp_new(loc, s1exp_node_S1Eimp(ft, is_lin, is_prf, efc))

(* ****** ****** *)

implement
s1exp_list
  (loc, s1es) =
(
case+ glist_view(s1es) of
//
// HX: singleton elimination is performed
//
| ~GLcons (s1e, s1es1) =>
    if glist_is_nil (s1es1)
      then s1e else s1exp_new(loc, s1exp_node_S1Elist(~1, s1es))
    // end of [GLcons]
| ~GLnil () (*non-sing*) => s1exp_new(loc, s1exp_node_S1Elist(~1, s1es)) // end of [non-sing]
) (* end of [s1exp_list] *)

implement
s1exp_list2
  (loc, s1es1, s1es2) =  let
  val npf = list_vt_length<s1exp> (s1es1)
  val s1es = list_vt_append<s1exp> (s1es1, s1es2)
  val s1es = l2l (s1es)
in s1exp_new(loc, s1exp_node_S1Elist(npf, s1es)) end // end of [s1exp_list2]

implement
s1exp_npf_list
  (loc, npf, s1es) =
(
//
if
npf >= 0
then s1exp_new(loc, s1exp_node_S1Elist(npf, s1es)) (* end of [then] *)
else s1exp_list (loc, s1es)
//
) // end of [s1exp_npf_list]

(* ****** ****** *)

implement
s1exp_top (loc, knd, s1e) = s1exp_new(loc, s1exp_node_S1Etop(knd, s1e))

(* ****** ****** *)
//
implement
s1exp_invar (loc, knd, s1e) = s1exp_new(loc, s1exp_node_S1Einvar(knd, s1e))
//
implement
s1exp_trans (loc, s1e1, s1e2) = s1exp_new(loc, s1exp_node_S1Etrans(s1e1, s1e2))
//
(* ****** ****** *)

implement
s1exp_tyarr
(
  loc, s1e_elt, s1es_dim
) = s1exp_new(loc, s1exp_node_S1Etyarr(s1e_elt, s1es_dim)) (* end of [s1exp_tyarr] *)

implement
s1exp_tytup
  (loc, knd, npf, s1es) = s1exp_new(loc, s1exp_node_S1Etytup(knd, npf, s1es))

(* ****** ****** *)

implement
s1exp_tyrec (
  loc, knd, npf, ls1es
) = s1exp_new(loc, s1exp_node_S1Etyrec(knd, npf, ls1es)) // end of [s1exp_tyrec]

implement
s1exp_tyrec_ext (
  loc, name, npf, ls1es
) = s1exp_new(loc, s1exp_node_S1Etyrec_ext(name, npf, ls1es)) // end of [s1exp_tyrec_ext]

(* ****** ****** *)
//
implement
s1exp_uni
(
  loc, s1qs, s1e
) = s1exp_new(loc, s1exp_node_S1Euni(s1qs, s1e)) (* end of [s1exp_uni] *)
//
implement
s1exp_exi
(
  loc, knd, s1qs, s1e
) = s1exp_new(loc, s1exp_node_S1Eexi(knd, s1qs, s1e)) (* end of [s1exp_exi] *)
//
(* ****** ****** *)

implement
s1exp_ann (loc, s1e, s1t) = s1exp_new(loc, s1exp_node_S1Eann(s1e, s1t))

(* ****** ****** *)

implement
s1exp_d2ctype (loc, d2ctp) = s1exp_new(loc, s1exp_node_S1Ed2ctype(d2ctp))

(* ****** ****** *)

implement
s1exp_err (loc) = s1exp_new(loc, s1exp_node_S1Eerr())

(* ****** ****** *)

implement
labs1exp_make
  (l, name, s1e) = labs1exp_new (l, name, s1e)
// end of [labs1exp_make]

(* ****** ****** *)

implement
s1rtext_srt (loc, s1t) = s1rtext_new(loc, s1rtext_node_S1TEsrt(s1t))

implement
s1rtext_sub (loc, sym, s1te, s1ps) = s1rtext_new(loc, s1rtext_node_S1TEsub(sym, s1te, s1ps))

(* ****** ****** *)

implement
s1qua_prop (loc, s1p) = s1qua_new(loc, s1qua_node_S1Qprop(s1p))

implement
s1qua_vars (loc, ids, s1te) = s1qua_new(loc, s1qua_node_S1Qvars(ids, s1te))

(* ****** ****** *)

implement
s1exp_make_v1al
  (loc0, v0) = let
in
//
case+ v1al_view(v0) of
//
| ~V1ALint(i) => s1exp_int (loc0, i)
//
| ~V1ALchar(c) => s1exp_char (loc0, c)
//
| ~V1ALstring(str) => s1exp_string (loc0, str)
//
| v (*unsupported*) => (v1al_view_free (v); s1exp_err (loc0))
//
end // end of [s1exp_make_v1al]

(* ****** ****** *)

//
// HX-2026-10: the closures [aux]/[auxlst] captured [loc0]: it is a parameter now
//
fun
s1exp_make_e1xp_aux
(
  loc0: location, e0: e1xp
) : s1exp = let
(*
  val () = (
    print "s1exp_make_e1xp: aux: e0 = "; print_e1xp (e0); print_newline ()
  ) // end of [val]
*)
in
  case+ e1xp_node_view(e0.e1xp_node()) of
//
  | ~E1XPapp
      (e1, loc_arg, es2) =>
      s1exp_app (loc0, s1exp_make_e1xp_aux (loc0, e1), loc_arg, s1exp_make_e1xp_auxlst (loc0, es2))
    // end of [E1XPapp]
//
  | ~E1XPide(id) => s1exp_ide (loc0, id)
//
  | ~E1XPint(int) => s1exp_int (loc0, int)
  | ~E1XPintrep(rep) => s1exp_intrep (loc0, rep)
//
  | ~E1XPchar(chr) => s1exp_char (loc0, chr)
//
  | ~E1XPfloat(rep) => s1exp_float (loc0, rep)
//
  | ~E1XPstring(str) => s1exp_string (loc0, str)
//
  | ~E1XPv1al(v1) => s1exp_make_v1al (loc0, v1)
//
  | ~E1XPlist(es) => s1exp_list (loc0, s1exp_make_e1xp_auxlst (loc0, es))
//
  | v (*rest-of-E1XP*) =>
      s1exp_err(loc0) where
    {
      val () = e1xp_node_view_free (v)
      val () =
      prerr_error1_loc (loc0)
      val () =
      prerrln! (
        ": the expression cannot be translated into a legal static expression."
      ) (* end of [val] *)
    } (* end of [rest-of-E1XP] *)
end (* end of [aux] *)
//
and
s1exp_make_e1xp_auxlst
(
  loc0: location, es0: e1xplst
) : s1explst = case+ glist_view(es0) of
  | ~GLcons(e, es) =>
      glist_cons(s1exp_make_e1xp_aux (loc0, e), s1exp_make_e1xp_auxlst (loc0, es))
  | ~GLnil() => glist_nil()
(* end of [auxlst] *)
//
implement
s1exp_make_e1xp (loc0, e0) = s1exp_make_e1xp_aux (loc0, e0)
// end of [s1exp_make_e1xp]

(* ****** ****** *)

fun
e1xp_make_s1exp_aux
(
  loc0: location, s1e0: s1exp
) : e1xp =
  case+ s1exp_node_view(s1e0.s1exp_node()) of
  | ~S1Eide (id) => e1xp_ide (loc0, id)
  | ~S1Eint (int) => e1xp_int (loc0, int)
  | ~S1Eintrep (rep) => e1xp_intrep (loc0, rep)
  | ~S1Echar (char) => e1xp_char (loc0, char)
  | ~S1Eapp (s1e_fun, _(*loc*), s1es_arg) => let
      val e_fun = e1xp_make_s1exp_aux (loc0, s1e_fun)
      val es_arg = e1xp_make_s1exp_auxlst (loc0, s1es_arg)
    in
      e1xp_app (loc0, e_fun, loc0, es_arg)
    end
  | ~S1Elist (_(*npf*), s1es) => e1xp_list (loc0, e1xp_make_s1exp_auxlst (loc0, s1es))
  | v => (s1exp_node_view_free (v); e1xp_err (loc0))
(* end of [aux] *)
//
and
e1xp_make_s1exp_auxlst
(
  loc0: location, s1es0: s1explst
) : e1xplst = case+ glist_view(s1es0) of
  | ~GLcons(s1e, s1es) =>
      glist_cons(e1xp_make_s1exp_aux (loc0, s1e), e1xp_make_s1exp_auxlst (loc0, s1es))
  | ~GLnil() => glist_nil()
(* end of [auxlst] *)
//
implement
e1xp_make_s1exp (loc0, s1e0) = e1xp_make_s1exp_aux (loc0, s1e0)
// end of [e1xp_make_s1exp]

(* ****** ****** *)

implement
wths1explst_is_none
  (wths1es) = case+ wths1explst_view(wths1es) of
  | ~WTHS1EXPLSTcons_some _ => false
  | ~WTHS1EXPLSTcons_none (wths1es) => wths1explst_is_none (wths1es)
  | ~WTHS1EXPLSTnil () => true
// end of [wths1explst_is_none]

implement
wths1explst_reverse (wths1es) = let
  fun loop (
    wths1es: wths1explst, res: wths1explst
  ) : wths1explst = case+ wths1explst_view(wths1es) of
    | ~WTHS1EXPLSTcons_some
        (knd, refval, s1e, wths1es) =>
        loop (wths1es, wths1explst_WTHS1EXPLSTcons_some(knd, refval, s1e, res))
    | ~WTHS1EXPLSTcons_none (wths1es) =>
        loop (wths1es, wths1explst_WTHS1EXPLSTcons_none (res))
    | ~WTHS1EXPLSTnil () => res // end of [WTHS1EXPLSTnil]
  // end of [loop]
in
  loop (wths1es, wths1explst_WTHS1EXPLSTnil())
end // end of [wths1explst_reverse]

(* ****** ****** *)

implement
q1marg_make
  (loc, arg) = q1marg_new(loc, arg) // end of [q1marg_make]

(* ****** ****** *)

implement
i1mparg_sarglst (xs) = i1mparg_I1MPARG_sarglst(xs)
implement
i1mparg_svararglst (xs) = i1mparg_I1MPARG_svararglst(xs)

(* ****** ****** *)

implement
t1mpmarg_make
  (loc, arg) = t1mpmarg_new(loc, arg) // end of [t1mpmarg_make]

(* ****** ****** *)

implement
s1exparg_one (loc) = s1exparg_new(loc, s1exparg_node_S1EXPARGone())
implement
s1exparg_all (loc) = s1exparg_new(loc, s1exparg_node_S1EXPARGall())
implement
s1exparg_seq (loc, xs) = s1exparg_new(loc, s1exparg_node_S1EXPARGseq(xs))

(* ****** ****** *)

implement
m1acarg_make_dyn (loc, darg) = m1acarg_new(loc, m1acarg_node_M1ACARGdyn(darg)) // end of [m1acarg_make_sta]

implement
m1acarg_make_sta (loc, sarg) = m1acarg_new(loc, m1acarg_node_M1ACARGsta(sarg)) // end of [m1acarg_make_sta]

(* ****** ****** *)

implement
s1rtdef_make (
  loc, sym, s1te
) = s1rtdef_new(loc, sym, s1te) // end of [s1rtdef_make]

(* ****** ****** *)

implement
s1tacst_make
(
  loc, fil, sym
, arg, res, extdef
) = s1tacst_new(loc, sym, fil, arg, res, extdef) // end of [s1tacst_make]

implement
s1tacon_make
(
  loc, fil, sym, arg, def
) = s1tacon_new(loc, sym, fil, arg, def) // end of [s1tacon_make]

(* ****** ****** *)

(*
//
// HX-2012-05-23: removed
//
implement
s1tavar_make (
  loc, sym, srt
) = '{
  s1tavar_loc= loc
, s1tavar_sym= sym
, s1tavar_srt= srt
} // end of [s1tavar_make]
*)

(* ****** ****** *)

implement
t1kindef_make (
  loc, id, loc_id, def
) = t1kindef_new(loc, id, loc_id, def) // end of [t1kindef_make]

(* ****** ****** *)

implement
s1expdef_make (
  loc, id, loc_id, arg, res, def
) = s1expdef_new(loc, id, loc_id, arg, res, def) // end of [s1expdef_make]

implement
s1aspdec_make (
  loc, qid, arg, res, def
) = s1aspdec_new(loc, qid, arg, res, def) // end of [s1aspdec_make]

(* ****** ****** *)

implement
d1atcon_make (
  loc, id, qua, npf, arg, ind
) = d1atcon_new(loc, id, qua, npf, arg, ind) // end of [d1atcon_make]

implement
d1atdec_make
(
  loc, fil
, id0, arg, con
) = d1atdec_new(loc, fil, id0, arg, con) (* end of [d1atdec_make] *)

implement
e1xndec_make
(
  loc, fil
, id0, qua, npf, arg
) = e1xndec_new(loc, fil, id0, qua, npf, arg) (* end of [e1xndec_make] *)

(* ****** ****** *)

implement
d1cstdec_make
(
  loc, fil
, id0, s1e, extdef
) = d1cstdec_new(loc, fil, id0, s1e, extdef) // end of [d1cstdec_make]

(* ****** ****** *)

(* end of [pats_staexp1.dats] *)
