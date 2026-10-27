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
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp1.dats, see PORTING.md)
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

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_lexing.sats"
staload "./pats_syntax_boundary.sats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

#include "./pats_basics.hats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

#include "./pats_dynexp1_gen_dats.hats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)
//
// HX: from [pats_staexp1.dats]
//
fn prerr_error1_loc
  (loc: location): void = (
  $LOC.prerr_errloc loc; prerr ": error(1)"
) // end of [prerr_error1_loc]

(* ****** ****** *)

implement
p1at_make (loc, node) = p1at_new(loc, node)

implement
p1at_any (loc) = p1at_new(loc, p1at_node_P1Tany())
implement
p1at_any2 (loc) = p1at_new(loc, p1at_node_P1Tany2())

(* ****** ****** *)

implement
p1at_ide (loc, id) = p1at_new(loc, p1at_node_P1Tide(id))
implement
p1at_dqid (loc, dq, id) = p1at_new(loc, p1at_node_P1Tdqid(dq, id))

(* ****** ****** *)

implement
p1at_int (loc, i) = p1at_new(loc, p1at_node_P1Tint(i))
implement
p1at_intrep (loc, rep) = p1at_new(loc, p1at_node_P1Tintrep(rep))
implement
p1at_char (loc, c) = p1at_new(loc, p1at_node_P1Tchar(c: char))
implement
p1at_float (loc, rep) = p1at_new(loc, p1at_node_P1Tfloat(rep))
implement
p1at_string (loc, str) = p1at_new(loc, p1at_node_P1Tstring(str))

(* ****** ****** *)

implement
p1at_i0nt
  (loc, x) = p1at_new(loc, p1at_node_P1Ti0nt(x)) // end of [p1at_i0nt]

implement
p1at_c0har (loc, x) = let
  val c = token_char_get (x)
in
  p1at_char (loc, c)
end // end of [p1at_c0har]

implement
p1at_f0loat (loc, x) = p1at_new(loc, p1at_node_P1Tf0loat(x)) // end of [p1at_f0loat]

implement
p1at_s0tring (loc, x) = let
  val str = token_string_get (x)
in
  p1at_string (loc, str)
end // end of [p1at_s0tring]

(* ****** ****** *)

implement
p1at_empty (loc) = p1at_new(loc, p1at_node_P1Tempty())

implement
p1at_app_dyn (
  loc, _fun, loc_arg, npf, _arg
) = p1at_new(loc, p1at_node_P1Tapp_dyn(_fun, loc_arg, npf, _arg)) // end of [p1at_app_dyn]

implement
p1at_app_sta
  (loc, _fun, _arg) = p1at_new(loc, p1at_node_P1Tapp_sta(_fun, _arg)) // end of [p1at_app_sta]

(* ****** ****** *)

(*
implement
p1at_list (
  loc, npf, p1ts
) = let
in
//
if npf >= 0 then
  p1at_make (loc, P1Tlist (npf, p1ts))
else (case+ p1ts of
  | list_cons (p1t, list_nil ()) => p1t
  | _ => p1at_make (loc, P1Tlist (npf, p1ts))
) // end of [if]
//
end // end of [p1at_list]
*)
implement
p1at_list
  (loc, npf, p1ts) = let
//
fun aux_ifany
  (p1t: p1at): p1at = let
in
//
case+ p1at_node_view(p1t.p1at_node()) of
| ~P1Tany () => p1at_any2 (p1t.p1at_loc()) | v => (p1at_node_view_free (v); p1t)
end // end of [aux_ifany]
//
in
//
if npf >= 0 then
  p1at_make (loc, p1at_node_P1Tlist(npf, p1ts))
else (case+ glist_view(p1ts) of
  | ~GLcons (p1t, p1ts1) =>
    if glist_is_nil (p1ts1) then (
    case+ p1at_node_view(p1t.p1at_node()) of
    | ~P1Tlist (npf, d1es) => let
        val knd = TYTUPKIND_flt in p1at_tup (loc, knd, npf, p1ts)
      end // end of [P1Tlist]
    | v => (p1at_node_view_free (v); aux_ifany (p1t))
    ) else p1at_make (loc, p1at_node_P1Tlist(npf, p1ts)) // end of [list_cons]
  | ~GLnil () => p1at_make (loc, p1at_node_P1Tlist(npf, p1ts))
) // end of [if]
//
end // end of [p1at_list]

(* ****** ****** *)

implement
p1at_tup (loc, knd, npf, p1ts) = p1at_new(loc, p1at_node_P1Ttup(knd, npf, p1ts))
implement
p1at_rec (loc, knd, npf, lp1ts) = p1at_new(loc, p1at_node_P1Trec(knd, npf, lp1ts))
implement
p1at_lst (loc, lin, p1ts) = p1at_new(loc, p1at_node_P1Tlst(lin, p1ts))

implement
p1at_free (loc, p1t) = p1at_new(loc, p1at_node_P1Tfree(p1t))
implement
p1at_unfold (loc, p1t) = p1at_new(loc, p1at_node_P1Tunfold(p1t))

implement
p1at_refas (loc, id, locid, p1t) = p1at_new(loc, p1at_node_P1Trefas(id, locid, p1t))

implement
p1at_exist
  (loc, arg, p1t) = p1at_new(loc, p1at_node_P1Texist(arg, p1t))

implement
p1at_svararg (loc, arg) = p1at_new(loc, p1at_node_P1Tsvararg(arg))

implement
p1at_ann
  (loc, p1t, ann) = p1at_make (loc, p1at_node_P1Tann(p1t, ann))
// end of [p1at_ann]

implement
p1at_errpat (loc) = p1at_make (loc, p1at_node_P1Terrpat())

(* ****** ****** *)

implement
labp1at_norm (loc, l, p1t) = labp1at_new(loc, labp1at_node_LABP1ATnorm(l, p1t))

implement
labp1at_omit (loc) = labp1at_new(loc, labp1at_node_LABP1ATomit())

(* ****** ****** *)

//
// HX-2026-10: the closures [aux]/[auxlst] captured [loc0]: it is a parameter now
//
fun
p1at_make_e1xp_aux
(
  loc0: location, e0: e1xp
) : p1at = let
(*
//
val () =
println!
  ("p1at_make_e1xp: aux: e0 = ", e0))
//
*)
in
//
case+
e1xp_node_view(e0.e1xp_node()) of
//
| ~E1XPide(id) => p1at_ide (loc0, id)
//
| ~E1XPint(int) => p1at_int (loc0, int)
| ~E1XPintrep(rep) => p1at_intrep (loc0, rep)
//
| ~E1XPchar(chr) => p1at_char (loc0, chr)
//
| ~E1XPfloat(rep) => p1at_float (loc0, rep)
| ~E1XPstring(str) => p1at_string (loc0, str)
//
| ~E1XPapp(
    e1, loc_arg, es2
  ) => let
    val p1t1 = p1at_make_e1xp_aux (loc0, e1)
    val p1ts2 = p1at_make_e1xp_auxlst (loc0, es2)
  in
    p1at_app_dyn
      (loc0, p1t1, loc0, ~1(*npf*), p1ts2)
    // p1at_app_dyn
  end (* end of [E1XPapp] *)
//
| ~E1XPlist (es) =>
    p1at_list (loc0, ~1(*npf*), p1at_make_e1xp_auxlst (loc0, es))
  // end of [E1XPlist]
| ~E1XPv1al (v1) => p1at_make_v1al (loc0, v1)
| ~E1XPnone ((*void*)) => p1at_empty (loc0)
| v (*rest*) => let
    val () = e1xp_node_view_free (v)
    val () =
    prerr_error1_loc (loc0)
    val () = prerr (": the expression [")
    val () = prerr_e1xp (e0)
    val () = prerrln! ("] cannot be translated into a legal pattern.")
  in
    p1at_errpat (loc0)
  end // end of [rest]
//
end // end of [aux]

and
p1at_make_e1xp_auxlst
(
  loc0: location, es: e1xplst
) : p1atlst = case+ glist_view(es) of
  | ~GLcons(e, es) => glist_cons(p1at_make_e1xp_aux (loc0, e), p1at_make_e1xp_auxlst (loc0, es))
  | ~GLnil() => glist_nil()
// end of [auxlst]

implement
p1at_make_e1xp (loc0, e0) = p1at_make_e1xp_aux (loc0, e0)
// end of [p1at_make_e1xp]

(* ****** ****** *)

implement
p1at_make_v1al
  (loc0, v0) = let
in
//
case+ v1al_view(v0) of
| ~V1ALint (i) => p1at_int (loc0, i)
| ~V1ALchar (c) => p1at_char (loc0, c)
| ~V1ALstring (str) => p1at_string (loc0, str)
| v (*unsupported*) => (v1al_view_free (v); p1at_errpat (loc0))
//
end // end of [p1at_make_v1al]

(* ****** ****** *)

fun
e1xp_make_p1at_aux
(
  loc0: location, p1t0: p1at
) : e1xp =
  case+ p1at_node_view(p1t0.p1at_node()) of
  | ~P1Tide (id) => e1xp_ide (loc0, id)
  | ~P1Tint (int) => e1xp_int (loc0, int)
  | ~P1Tintrep (rep) => e1xp_intrep (loc0, rep)
  | ~P1Tchar (char) => e1xp_char (loc0, char)
  | ~P1Tapp_dyn (p1t_fun, _(*loc*), npf, p1ts_arg) => let
      val e_fun = e1xp_make_p1at_aux (loc0, p1t_fun)
      val es_arg = e1xp_make_p1at_auxlst (loc0, p1ts_arg)
    in
      e1xp_app (loc0, e_fun, loc0, es_arg)
    end
  | ~P1Tlist (_(*npf*), s1es) => e1xp_list (loc0, e1xp_make_p1at_auxlst (loc0, s1es))
  | v => (p1at_node_view_free (v); e1xp_err (loc0))
(* end of [aux] *)
//
and
e1xp_make_p1at_auxlst
(
  loc0: location, p1ts0: p1atlst
) : e1xplst = case+ glist_view(p1ts0) of
  | ~GLcons(p1t, p1ts) =>
      glist_cons(e1xp_make_p1at_aux (loc0, p1t), e1xp_make_p1at_auxlst (loc0, p1ts))
  | ~GLnil() => glist_nil()
(* end of [auxlst] *)
//
implement
e1xp_make_p1at (loc0, p1t0) = e1xp_make_p1at_aux (loc0, p1t0)
// end of [e1xp_make_p1at]

(* ****** ****** *)

implement
i1nvarg_make (
  loc, id, os1e
) = i1nvarg_new(loc, id, os1e) // end of [i1nvarg_make]

implement
i1nvresstate_make
  (s1qs, arg) = i1nvresstate_new(s1qs, arg)

implement
i1nvresstate_nil =
  i1nvresstate_make (glist_nil(), glist_nil())
// end of [i1nvresstate_nil]

(* ****** ****** *)

implement
loopi1nv_make (
  loc, qua, met, arg, res
) = loopi1nv_new(loc, qua, met, arg, res) // end of [loopi1nv_make]

implement
loopi1nv_nil
  (loc) = let
  val qua = glist_nil()
  val met = gopt_none()
  val arg = glist_nil()
in
//
loopi1nv_make
  (loc, qua, met, arg, i1nvresstate_nil)
//
end // end of [loopi1nv_nil]

(* ****** ****** *)

implement
i1fcl_make
  (loc, test, body) = i1fcl_new(loc, test, body) (* end of [i1fcl_make] *)

(* ****** ****** *)

implement
gm1at_make
  (loc, d1e, op1t) = gm1at_new(loc, d1e, op1t) // end of [gm1at_make]

implement
c1lau_make (
  loc, p1ts, gua, seq, neg, body
) = c1lau_new(loc, p1ts, gua, seq, neg, body) // end of [c1lau_make]

implement
sc1lau_make (loc, sp1t, body) = sc1lau_new(loc, sp1t, body)

(* ****** ****** *)
//
// HX: dynamic expressions
//
(* ****** ****** *)

implement
d1exp_make (loc, node) = d1exp_new(loc, node) // end of [d1exp_make]

(* ****** ****** *)

implement
d1exp_ide (loc, id) = d1exp_make (loc, d1exp_node_D1Eide(id))
implement d1exp_opid (loc, id) = d1exp_ide (loc, id)
implement
d1exp_dqid
  (loc, dq, id) = d1exp_make (loc, d1exp_node_D1Edqid(dq, id))
// end of [d1exp_dqid]

(* ****** ****** *)

implement
d1exp_idext
  (loc, id) = d1exp_idextapp (loc, id, glist_nil())
implement
d1exp_idextapp
  (loc, id, arg) = d1exp_make (loc, d1exp_node_D1Eidextapp(id, arg))
// end of [d1exp_idexpapp]

(* ****** ****** *)

implement
d1exp_int (loc, i) = d1exp_make (loc, d1exp_node_D1Eint(i:int))
implement
d1exp_intrep (loc, rep) = d1exp_make (loc, d1exp_node_D1Eintrep(rep))
implement
d1exp_char (loc, c) = d1exp_make (loc, d1exp_node_D1Echar(c:char))
implement
d1exp_float (loc, rep) = d1exp_make (loc, d1exp_node_D1Efloat(rep))
implement
d1exp_string (loc, str) = d1exp_make (loc, d1exp_node_D1Estring(str))

(* ****** ****** *)

implement
d1exp_i0nt (loc, x) = d1exp_make (loc, d1exp_node_D1Ei0nt(x))
implement
d1exp_c0har (loc, x) = d1exp_make (loc, d1exp_node_D1Ec0har(x))
implement
d1exp_f0loat (loc, x) = d1exp_make (loc, d1exp_node_D1Ef0loat(x))
implement
d1exp_s0tring (loc, x) = d1exp_make (loc, d1exp_node_D1Es0tring(x))

(* ****** ****** *)
//
implement
d1exp_cstsp
  (loc, x) = d1exp_make(loc, d1exp_node_D1Ecstsp(x))
//
(* ****** ****** *)
//
implement
d1exp_tyrep
  (loc, s1e) = d1exp_make(loc, d1exp_node_D1Etyrep(s1e))
//
(* ****** ****** *)
//
implement
d1exp_literal
  (loc, lit) = d1exp_make(loc, d1exp_node_D1Eliteral(lit))
//
(* ****** ****** *)
//
implement
d1exp_top(loc) = d1exp_make (loc, d1exp_node_D1Etop())
//
implement
d1exp_empty(loc) = d1exp_make (loc, d1exp_node_D1Eempty())
//
(* ****** ****** *)
//
implement
d1exp_extval (loc, _type, name) =
  d1exp_make (loc, d1exp_node_D1Eextval(_type, name))
//
implement
d1exp_extfcall (loc, _type, _fun, _arg) =
  d1exp_make (loc, d1exp_node_D1Eextfcall(_type, _fun, _arg))
//
implement
d1exp_extmcall (loc, _type, _obj, _mtd, _arg) =
  d1exp_make (loc, d1exp_node_D1Eextmcall(_type, _obj, _mtd, _arg))
//
(* ****** ****** *)

implement
d1exp_foldat (loc, s1as, d1e) =
  d1exp_make (loc, d1exp_node_D1Efoldat(s1as, d1e))
implement
d1exp_freeat (loc, s1as, d1e) =
  d1exp_make (loc, d1exp_node_D1Efreeat(s1as, d1e))

(* ****** ****** *)

implement
d1exp_tmpid (loc, qid, tmparg) =
  d1exp_make (loc, d1exp_node_D1Etmpid(qid, tmparg))
// end of [d1exp_tmpid]

(* ****** ****** *)
//
implement
d1exp_let (loc, d1cs, body) =
  d1exp_make (loc, d1exp_node_D1Elet(d1cs, body))
//
implement
d1exp_where (loc, body, d1cs) =
  d1exp_make (loc, d1exp_node_D1Ewhere(body, d1cs))
//
(* ****** ****** *)

implement
d1exp_app_sta (loc, d1e, s1as) =
  d1exp_make (loc, d1exp_node_D1Eapp_sta(d1e, s1as))
// end of [d1exp_app_sta]

implement
d1exp_app_dyn
  (loc, d1e, loc_arg, npf, d1es) =
  d1exp_make (loc, d1exp_node_D1Eapp_dyn(d1e, loc_arg, npf, d1es))
// end of [d1exp_app_dyn]

(* ****** ****** *)
//
implement
d1exp_sing
  (loc, d1e) =
(
case+
d1exp_node_view(d1e.d1exp_node()) of
| ~D1Eide _ => d1e
| v (*non-D1Eide*) => (d1exp_node_view_free (v); d1exp_make (loc, d1exp_node_D1Esing(d1e)))
) (* end of [d1exp_sing] *)
//
(* ****** ****** *)

implement
d1exp_list
  (loc, npf, d1es) = let
in
//
if
npf >= 0
then (
  d1exp_make (loc, d1exp_node_D1Elist(npf, d1es))
) else (
  case+ glist_view(d1es) of
  | ~GLcons (d1e, d1es1) =>
    if glist_is_nil (d1es1) then (
      case+ d1exp_node_view(d1e.d1exp_node()) of
      | ~D1Elist
          (npf, d1es) => let
          val knd = TYTUPKIND_flt
        in
          d1exp_tup(loc, knd, npf, d1es)
        end // end of [D1Elist]
      | v (*non-list*) => (d1exp_node_view_free (v); d1exp_sing(loc, d1e))
    ) else d1exp_make (loc, d1exp_node_D1Elist(npf, d1es)) (* end of [list_sing] *)
  | ~GLnil () (*non-list-sing*) => d1exp_make (loc, d1exp_node_D1Elist(npf, d1es))
) (* end of [if] *)
//
end // end of [d1exp_list]

(* ****** ****** *)

implement
d1exp_ifhead
  (loc, inv, _cond, _then, _else) =
  d1exp_make (loc, d1exp_node_D1Eifhead(inv, _cond, _then, _else))
// end of [d1exp_ifhead]

implement
d1exp_sifhead
  (loc, inv, _cond, _then, _else) =
  d1exp_make (loc, d1exp_node_D1Esifhead(inv, _cond, _then, _else))
// end of [d1exp_sifhead]

(* ****** ****** *)

implement
d1exp_ifcasehd
  (loc, inv, ifcls) =
  d1exp_make (loc, d1exp_node_D1Eifcasehd(inv, ifcls))
// end of [d1exp_ifcasehd]

(* ****** ****** *)

implement
d1exp_casehead
  (loc, knd, inv, d1es, c1las) =
  d1exp_make (loc, d1exp_node_D1Ecasehead(knd, inv, d1es, c1las))
// end of [d1exp_casehead]

implement
d1exp_scasehead
  (loc, inv, s1e, c1las) =
  d1exp_make (loc, d1exp_node_D1Escasehead(inv, s1e, c1las))
// end of [d1exp_scasehead]

(* ****** ****** *)

implement
d1exp_lst (loc, knd, elt, d1es) =
  d1exp_make (loc, d1exp_node_D1Elst(knd, elt, d1es))

implement
d1exp_tup (loc, knd, npf, d1es) =
  d1exp_make (loc, d1exp_node_D1Etup(knd, npf, d1es))

implement
d1exp_rec (loc, knd, npf, ld1es) =
  d1exp_make (loc, d1exp_node_D1Erec(knd, npf, ld1es))

implement
d1exp_seq (loc, d1es) = d1exp_make (loc, d1exp_node_D1Eseq(d1es))

(* ****** ****** *)

implement
d1exp_arrsub
  (loc, arr, loc_ind, ind) =
  d1exp_make (loc, d1exp_node_D1Earrsub(arr, loc_ind, ind))
// end of [d1exp_arrsub]

implement
d1exp_arrpsz
  (loc, elt, ini) =
  d1exp_make (loc, d1exp_node_D1Earrpsz(elt, ini))
// end of [d1exp_arrpsz]

implement
d1exp_arrinit
  (loc, elt, asz, ini) =
  d1exp_make (loc, d1exp_node_D1Earrinit(elt, asz, ini))
// end of [d1exp_arrinit]

(* ****** ****** *)

implement
d1exp_selab
  (loc, knd, d1e, d1l) =
(
  d1exp_make (loc, d1exp_node_D1Eselab(knd, d1e, d1l))
) // end of [d1exp_selab]

(* ****** ****** *)
//
implement
d1exp_ptrof
  (loc, d1e) = d1exp_make (loc, d1exp_node_D1Eptrof(d1e))
implement
d1exp_viewat
  (loc, d1e) = d1exp_make (loc, d1exp_node_D1Eviewat(d1e))
//
(* ****** ****** *)
//
implement
d1exp_raise
  (loc, d1e) = d1exp_make (loc, d1exp_node_D1Eraise(d1e))
//
(* ****** ****** *)
//
implement
d1exp_effmask
  (loc, efc, d1e) = let
//
val node =
  d1exp_node_D1Eeffmask(efc, d1e)
//
in
  d1exp_make (loc, node)
end (* end of [d1exp_effmask] *)
//
implement
d1exp_effmask_arg
  (loc, knd, d1e) = let
//
val efc = (
  case+ knd of
  | 0 => effcst_ntm
  | 1 => effcst_exn
  | 2 => effcst_ref
  | 3 => effcst_wrt
  | _ => effcst_all
) : effcst // end of [val]
//
in
  d1exp_effmask (loc, efc, d1e)
end // end of [d1exp_effmask_arg]
//
(* ****** ****** *)
//
implement
d1exp_vararg
  (loc, d1es) =
  d1exp_make(loc, d1exp_node_D1Evararg(d1es))
//
(* ****** ****** *)
//
implement
d1exp_vcopyenv
  (loc, knd, d1e) =
  d1exp_make(loc, d1exp_node_D1Evcopyenv(knd, d1e))
//
(* ****** ****** *)
//
implement
d1exp_showtype
  (loc, d1e) =
  d1exp_make(loc, d1exp_node_D1Eshowtype(d1e))
//
(* ****** ****** *)
//
implement
d1exp_tempenver
  (loc, d1e) =
  d1exp_make(loc, d1exp_node_D1Etempenver(d1e))
//
(* ****** ****** *)

implement
d1exp_sexparg
  (loc, s1a) = d1exp_make(loc, d1exp_node_D1Esexparg(s1a))
// end of [d1exp_sexparg]

implement
d1exp_exist
  (loc, s1a, d1e) = d1exp_make(loc, d1exp_node_D1Eexist(s1a, d1e))
// end of [d1exp_exist]

(* ****** ****** *)
//
implement
d1exp_lam_dyn
  (loc, lin, p1t, d1e) =
  d1exp_make (loc, d1exp_node_D1Elam_dyn(lin, p1t, d1e))
//
implement
d1exp_laminit_dyn
  (loc, lin, p1t, d1e) =
  d1exp_make (loc, d1exp_node_D1Elaminit_dyn(lin, p1t, d1e))
//
implement
d1exp_lam_met
  (loc, loc_arg, s1es, d1e) =
  d1exp_make (loc, d1exp_node_D1Elam_met(loc_arg, s1es, d1e))
//
implement
d1exp_lam_sta_ana
  (loc, loc_arg, s1v, d1e) =
  d1exp_make (loc, d1exp_node_D1Elam_sta_ana(loc_arg, s1v, d1e))
//
implement
d1exp_lam_sta_syn
  (loc, loc_arg, s1qs, d1e) =
  d1exp_make (loc, d1exp_node_D1Elam_sta_syn(loc_arg, s1qs, d1e))
//
(* ****** ****** *)
//
implement
d1exp_fix
  (loc, knd, id, d1e) =
  d1exp_make(loc, d1exp_node_D1Efix(knd, id, d1e))
//
(* ****** ****** *)
//
implement
d1exp_delay
  (loc, knd, d1e_body) =
  d1exp_make (loc, d1exp_node_D1Edelay(knd, d1e_body))
//
(* ****** ****** *)

implement
d1exp_for
(
  loc, inv
, ini, test, post, body
) = (
//
d1exp_make
  (loc, d1exp_node_D1Efor(inv, ini, test, post, body))
//
) (* end of [d1exp_for] *)

implement
d1exp_while
(
  loc, inv, test, body
) =
  d1exp_make (loc, d1exp_node_D1Ewhile(inv, test, body))
// end of [d1exp_while]

implement
d1exp_loopexn
  (loc, knd) = d1exp_make (loc, d1exp_node_D1Eloopexn(knd))
// end of [d1exp_loopexn]

(* ****** ****** *)

implement
d1exp_trywith
  (loc, inv, d1e, c1las) =
  d1exp_make (loc, d1exp_node_D1Etrywith(inv, d1e, c1las))
// end of [d1exp_trywith]

(* ****** ****** *)
//
implement
d1exp_ann_type
  (loc, d1e, s1e) =
  d1exp_make (loc, d1exp_node_D1Eann_type(d1e, s1e))
// end of [d1exp_ann_type]
//
implement
d1exp_ann_effc
  (loc, d1e, efc) =
  d1exp_make (loc, d1exp_node_D1Eann_effc(d1e, efc))
//
implement
d1exp_ann_funclo
  (loc, d1e, fc0) =
  d1exp_make (loc, d1exp_node_D1Eann_funclo(d1e, fc0))
//
implement
d1exp_ann_funclo_opt
  (loc, d1e, fc0) = (
//
case+
d1exp_node_view(d1e.d1exp_node()) of // case+
| ~D1Eann_funclo _ => d1e
| v (*non-D1Eann_funclo*) => (d1exp_node_view_free (v); d1exp_ann_funclo (loc, d1e, fc0))
//
) (* end of [d1exp_ann_funclo_opt] *)
//
(* ****** ****** *)
//
implement
d1exp_macsyn
  (loc, knd, d1e) =
  d1exp_make (loc, d1exp_node_D1Emacsyn(knd, d1e))
//
implement
d1exp_macfun
  (loc, name, d1es) =
  d1exp_make (loc, d1exp_node_D1Emacfun(name, d1es))
//
(* ****** ****** *)
//
implement
d1exp_solassert
  (loc, d1e) = d1exp_make(loc, d1exp_node_D1Esolassert(d1e))
//
implement
d1exp_solverify
  (loc, s1e) = d1exp_make(loc, d1exp_node_D1Esolverify(s1e))
//
(* ****** ****** *)

implement
d1exp_errexp (loc) = d1exp_make (loc, d1exp_node_D1Eerrexp())

(* ****** ****** *)

implement labd1exp_make (l, d1e) = labd1exp_new (l, d1e)

(* ****** ****** *)

implement
d1exp_is_metric
  (d1e) = let
in
//
case+
d1exp_node_view(d1e.d1exp_node()) of
| ~D1Elam_met _ => true
| ~D1Elam_dyn (_, _, d1e) => d1exp_is_metric (d1e)
| ~D1Elam_sta_ana (_, _, d1e) => d1exp_is_metric (d1e)
| ~D1Elam_sta_syn (_, _, d1e) => d1exp_is_metric (d1e)
| v (*non-D1Elam_...*) => (d1exp_node_view_free (v); false)
//
end // end of [d1exp_is_metric]

(* ****** ****** *)

fun
d1exp_make_e1xp_aux
(
  loc0: location, e0: e1xp
) : d1exp = let
(*
  val () = begin
    print "d1exp_make_e1xp: aux: e0 = "; print_e1xp (e0); print_newline ()
  end // end of [val]
*)
in
//
case+
e1xp_node_view(e0.e1xp_node()) of
//
| ~E1XPide(id) => d1exp_ide (loc0, id)
//
| ~E1XPint(int) => d1exp_int (loc0, int)
| ~E1XPintrep(rep) => d1exp_intrep (loc0, rep)
//
| ~E1XPchar(chr) => d1exp_char (loc0, chr)
//
| ~E1XPfloat(rep) => d1exp_float (loc0, rep)
//
| ~E1XPstring(str) => d1exp_string (loc0, str)
//
| ~E1XPapp
  (
    e1, loc_arg, es2
  ) => let
    val d1e1 = d1exp_make_e1xp_aux (loc0, e1)
    val d1es2 = d1exp_make_e1xp_auxlst (loc0, es2)
  in
    d1exp_app_dyn
      (loc0, d1e1, loc0, ~1(*npf*), d1es2)
    // d1exp_app_dyn
  end // end of [E1XPapp]
//
| ~E1XPlist(es) => let
    val d1es = d1exp_make_e1xp_auxlst (loc0, es)
  in
    d1exp_list(loc0, ~1(*npf*), d1es)
  end // end of [E1XPlist]
//
| ~E1XPv1al(v1) => d1exp_make_v1al (loc0, v1)
//
| ~E1XPnone((*void*)) => d1exp_empty (loc0) // HX: ?
//
| v (*rest-of-e1xp*) => let
    val () = e1xp_node_view_free (v)
    val () =
    prerr_error1_loc(loc0)
    val () = prerr ": the expression ["
    val () = prerr_e1xp (e0)
    val () = prerrln! "] cannot be translated into a legal dynamic expression."
  in
    d1exp_errexp (loc0)
  end // end of [rest-of-e1xp]
//
end // end of [aux]

and
d1exp_make_e1xp_auxlst
(
  loc0: location, es: e1xplst
) : d1explst = case+ glist_view(es) of
  | ~GLcons(e, es) => glist_cons(d1exp_make_e1xp_aux (loc0, e), d1exp_make_e1xp_auxlst (loc0, es))
  | ~GLnil() => glist_nil()
// end of [auxlst]

implement
d1exp_make_e1xp (loc0, e0) = d1exp_make_e1xp_aux (loc0, e0)
// end of [d1exp_make_e1xp]

(* ****** ****** *)

implement
d1exp_make_v1al
  (loc0, v0) = let
in
//
case+ v1al_view(v0) of
| ~V1ALint (i) => d1exp_int (loc0, i)
| ~V1ALchar (c) => d1exp_char (loc0, c)
| ~V1ALstring (str) => d1exp_string (loc0, str)
| v (*unsupported*) => (v1al_view_free (v); d1exp_errexp (loc0))
//
end // end of [d1exp_make_v1al]

(* ****** ****** *)

fun
e1xp_make_d1exp_aux
(
  loc0: location, d1e0: d1exp
) : e1xp =
  case+ d1exp_node_view(d1e0.d1exp_node()) of
  | ~D1Eide (id) => e1xp_ide (loc0, id)
//
  | ~D1Eint (i) => e1xp_int (loc0, i)
  | ~D1Echar (c) => e1xp_char (loc0, c)
  | ~D1Estring (str) => e1xp_string (loc0, str)
  | ~D1Efloat (rep) => e1xp_float (loc0, rep)
//
  | ~D1Ei0nt (tok) => e1xp_i0nt (loc0, tok)
  | ~D1Ec0har (tok) => e1xp_c0har (loc0, tok)
  | ~D1Es0tring (tok) => e1xp_s0tring (loc0, tok)
  | ~D1Ef0loat (tok) => e1xp_f0loat (loc0, tok)
//
  | ~D1Eapp_dyn (d1e_fun, _(*loc*), npf, d1es_arg) => let
      val e_fun = e1xp_make_d1exp_aux (loc0, d1e_fun)
      val es_arg = e1xp_make_d1exp_auxlst (loc0, d1es_arg)
    in
      e1xp_app (loc0, e_fun, loc0, es_arg)
    end
  | ~D1Esing (d1e) => e1xp_make_d1exp_aux (loc0, d1e)
  | ~D1Elist (_(*npf*), d1es) => e1xp_list (loc0, e1xp_make_d1exp_auxlst (loc0, d1es))
  | v (*rest-of-d1exp*) => (d1exp_node_view_free (v); e1xp_err (loc0))
(* end of [aux] *)
//
and
e1xp_make_d1exp_auxlst
(
  loc0: location, d1es0: d1explst
) : e1xplst = case+ glist_view(d1es0) of
  | ~GLcons(d1e, d1es) =>
      glist_cons(e1xp_make_d1exp_aux (loc0, d1e), e1xp_make_d1exp_auxlst (loc0, d1es))
  | ~GLnil() => glist_nil()
(* end of [auxlst] *)
//
implement
e1xp_make_d1exp (loc0, d1e0) = e1xp_make_d1exp_aux (loc0, d1e0)
// end of [e1xp_make_d1exp]

(* ****** ****** *)

implement d1lab_lab (loc, lab) = d1lab_new(loc, d1lab_node_D1LABlab(lab))
implement d1lab_ind (loc, ind) = d1lab_new(loc, d1lab_node_D1LABind(ind))

(* ****** ****** *)
//
// HX: declarations
//
(* ****** ****** *)

implement
m1acdef_make
  (loc, id, arg, def) = m1acdef_new(loc, id, arg, def) // end of [m1acdef_make]

(* ****** ****** *)

implement
i1mpdec_make (
  loc, qid, tmparg, def
) = i1mpdec_new(loc, qid, tmparg, def) // end of [i1mpdec_make]

(* ****** ****** *)

implement
f1undec_make
  (loc, id, loc_id, d1e, ann) = f1undec_new(loc, id, loc_id, d1e, ann) // end of [f1undec_make]

implement
v1aldec_make
  (loc, p1t, d1e, ann) = v1aldec_new(loc, p1t, d1e, ann) // end of [v1aldec_make]

implement
v1ardec_make
(
  loc, knd, id, loc_id, pfat, s1eopt, init
) = v1ardec_new(loc, knd, id, loc_id, pfat, s1eopt, init) (* end of [v1ardec_make] *)

(* ****** ****** *)
//
extern
fun
d1ecl_make_node
(
  loc: location, node: d1ecl_node
) : d1ecl // end-of-function
implement
d1ecl_make_node
  (loc, node) = d1ecl_new(loc, node)
//
(* ****** ****** *)
//
implement
d1ecl_none
  (loc) = d1ecl_make_node(loc, d1ecl_node_D1Cnone())
//
implement
d1ecl_list
  (loc, ds) = d1ecl_make_node(loc, d1ecl_node_D1Clist(ds))
//
(* ****** ****** *)

implement
d1ecl_packname(opt) =
  d1ecl_make_node ($LOC.location_dummy, d1ecl_node_D1Cpackname(opt))
// end of [d1ecl_packname]

(* ****** ****** *)
//
implement
d1ecl_symintr(loc, ids) =
  d1ecl_make_node(loc, d1ecl_node_D1Csymintr(ids))
//
implement
d1ecl_symelim(loc, ids) =
  d1ecl_make_node(loc, d1ecl_node_D1Csymelim(ids))
//
implement
d1ecl_overload(loc, id, qid, pval) =
  d1ecl_make_node(loc, d1ecl_node_D1Coverload(id, qid, pval))
//
(* ****** ****** *)
//
implement
d1ecl_e1xpdef(loc, id, def) =
  d1ecl_make_node(loc, d1ecl_node_D1Ce1xpdef(id, def))
implement
d1ecl_e1xpundef(loc, id, def) =
  d1ecl_make_node(loc, d1ecl_node_D1Ce1xpundef(id, def))
//
(* ****** ****** *)
//
implement
d1ecl_pragma(loc, e1xps) =
  d1ecl_make_node(loc, d1ecl_node_D1Cpragma(e1xps))
//
implement
d1ecl_codegen(loc, knd, xs) =
  d1ecl_make_node(loc, d1ecl_node_D1Ccodegen(knd, xs))
//
(* ****** ****** *)
//
implement
d1ecl_datsrts
  (loc, xs) = d1ecl_make_node(loc, d1ecl_node_D1Cdatsrts(xs))
//
implement
d1ecl_srtdefs
  (loc, xs) = d1ecl_make_node(loc, d1ecl_node_D1Csrtdefs(xs))
//
(* ****** ****** *)
//
implement
d1ecl_stacsts
  (loc, xs) = d1ecl_make_node(loc, d1ecl_node_D1Cstacsts(xs))
implement
d1ecl_stacons
  (loc, knd, xs) = d1ecl_make_node(loc, d1ecl_node_D1Cstacons(knd, xs))
//
(* ****** ****** *)

(*
//
// HX-2012-05-23: removed
//
implement
d1ecl_stavars (loc, xs) =
  d1ecl_make_node (loc, D1Cstavars (xs))
*)

(* ****** ****** *)
//
implement
d1ecl_tkindef(loc, x) =
  d1ecl_make_node (loc, d1ecl_node_D1Ctkindef(x))
//
(* ****** ****** *)
//
implement
d1ecl_sexpdefs(loc, knd, xs) =
  d1ecl_make_node(loc, d1ecl_node_D1Csexpdefs(knd, xs))
//
(* ****** ****** *)
//
implement
d1ecl_saspdec(loc, x) =
  d1ecl_make_node(loc, d1ecl_node_D1Csaspdec(x))
//
//
implement
d1ecl_reassume(loc, x) =
  d1ecl_make_node(loc, d1ecl_node_D1Creassume(x))
//
(* ****** ****** *)
//
implement
d1ecl_exndecs(loc, d1cs) =
  d1ecl_make_node(loc, d1ecl_node_D1Cexndecs(d1cs))
// end of [d1ecl_exndecs]
//
implement
d1ecl_datdecs
  (loc, knd, _datdec, _sexpdef) =
  d1ecl_make_node(loc, d1ecl_node_D1Cdatdecs(knd, _datdec, _sexpdef))
// end of [d1ecl_datdec]
//
(* ****** ****** *)
//
implement
d1ecl_classdec (loc, id, sup) =
  d1ecl_make_node(loc, d1ecl_node_D1Cclassdec(id, sup))
//
(* ****** ****** *)

implement
d1ecl_extype (loc, name, def) =
  d1ecl_make_node (loc, d1ecl_node_D1Cextype(name, def))

implement
d1ecl_extype2 (loc, knd, name, def) =
  d1ecl_make_node (loc, d1ecl_node_D1Cextype2(knd, name, def))

(* ****** ****** *)
//
implement
d1ecl_extvar (loc, name, def) =
  d1ecl_make_node (loc, d1ecl_node_D1Cextvar(name, def))
//
implement
d1ecl_extcode (loc, knd, pos, code) =
  d1ecl_make_node (loc, d1ecl_node_D1Cextcode(knd, pos, code))
//
(* ****** ****** *)

implement
d1ecl_dcstdecs (loc, knd, dck, qarg, ds) =
  d1ecl_make_node (loc, d1ecl_node_D1Cdcstdecs(knd, dck, qarg, ds))

(* ****** ****** *)

implement
d1ecl_macdefs (loc, knd, isrec, ds) =
  d1ecl_make_node (loc, d1ecl_node_D1Cmacdefs(knd, isrec, ds))

(* ****** ****** *)

implement
d1ecl_impdec (loc, knd, imparg, d1c) =
  d1ecl_make_node (loc, d1ecl_node_D1Cimpdec(knd, imparg, d1c))

(* ****** ****** *)

implement
d1ecl_valdecs (loc, knd, isrec, ds) =
  d1ecl_make_node (loc, d1ecl_node_D1Cvaldecs(knd, isrec, ds))

implement
d1ecl_fundecs (loc, knd, qarg, ds) =
  d1ecl_make_node (loc, d1ecl_node_D1Cfundecs(knd, qarg, ds))

implement
d1ecl_vardecs
  (loc, knd, ds) = d1ecl_make_node (loc, d1ecl_node_D1Cvardecs(knd, ds))
// end of [d1ecl_vardecs]

(* ****** ****** *)

implement
d1ecl_include
  (loc, knd, ds) = d1ecl_make_node (loc, d1ecl_node_D1Cinclude(knd, ds))
// end of [d1ecl_include]

(* ****** ****** *)

implement
d1ecl_staload
(
  loc, idopt, fil, ldflag, d1cs
) = d1ecl_make_node
  (loc, d1ecl_node_D1Cstaload(idopt, fil, ldflag, d1cs))
// end of [d1ecl_staload]

implement
d1ecl_staloadnm
(
  loc, alias, nspace
) = d1ecl_make_node (loc, d1ecl_node_D1Cstaloadnm(alias, nspace))

implement
d1ecl_staloadloc
(
  loc, pfil, nspace, d1cs
) = d1ecl_make_node (loc, d1ecl_node_D1Cstaloadloc(pfil, nspace, d1cs))

(* ****** ****** *)
//
implement
d1ecl_dynload
  (loc, fil) = d1ecl_make_node (loc, d1ecl_node_D1Cdynload(fil))
//
(* ****** ****** *)
//
implement
d1ecl_local
(
  loc, ds_head, ds_body
) = d1ecl_make_node (loc, d1ecl_node_D1Clocal(ds_head, ds_body))
//
(* ****** ****** *)

(* end of [pats_dynexp1.dats] *)
