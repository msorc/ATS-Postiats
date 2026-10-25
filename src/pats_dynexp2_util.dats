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
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2_util.dats, see PORTING.md)
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
//
staload
LAB = "./pats_label.sats"
//
(* ****** ****** *)
//
staload
LOC =
"./pats_location.sats"
//
overload + with $LOC.location_combine
//
(* ****** ****** *)
//
staload
SYN = "./pats_syntax.sats"
//
(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

implement
p2atlst_tupize
  (p2ts) = let
//
fun
auxlst
(
  p2ts: p2atlst, n: int
) : labp2atlst =
  case+ glist_view(p2ts) of
  | ~GLnil
      ((*void*)) => glist_nil()
    // end of [GLnil]
  | ~GLcons
      (p2t, p2ts) => let
      val loc = p2t.p2at_loc()
      val l = $LAB.label_make_int(n)
      val l0 = $SYN.l0ab_make_label(loc, l)
      val lp2t = labp2at_LABP2ATnorm(l0, p2t)
    in
      glist_cons(lp2t, auxlst(p2ts, n+1))
    end // end of [GLcons]
// end of [aux]
//
in
  auxlst(p2ts, 0)
end // end of [p2atlst_tupize]

(* ****** ****** *)

implement
d2exp_is_lam
  (d2e0) = let
//
fun
aux
(
  d2e0: d2exp
) : bool = let
in
//
case+
d2exp_node_view(d2e0.d2exp_node())
of // case+
| ~D2Elam_dyn _ => true
//
| ~D2Elam_sta
    (_, _, d2e) => aux(d2e)
//
| ~D2Elam_met
    (_, _, d2e) => aux(d2e)
//
| ~D2Efix(_, _, d2e) => aux(d2e)
//
| ~D2Esing(d2e) => aux(d2e)
//
| ~D2Eann_type (d2e, _) => aux(d2e)
| ~D2Eann_seff (d2e, _) => aux(d2e)
| ~D2Eann_funclo (d2e, _) => aux(d2e)
//
| v (*rest-of-d2exp*) => (d2exp_node_view_free(v); false)
//
end // end of [aux]
//
in
  aux(d2e0)
end // end of [d2exp_is_lam]

(* ****** ****** *)

implement
d2exp_is_varlamcst
  (d2e0) = let
//
fun
aux
(
  d2e0: d2exp
) : bool = let
in
//
case+
d2exp_node_view(d2e0.d2exp_node())
of // case+
//
| ~D2Evar d2v =>
  (
    if d2var_is_mutabl(d2v) then false else true
  ) // end of [D2Evar]
//
| ~D2Elam_dyn _ => true
//
| ~D2Elam_sta _ => true
| ~D2Elam_met _ => true
(*
//
// HX: not good for typechecking
//
| D2Elam_sta (_, _, d2e) => aux(d2e)
| D2Elam_met (_, _, d2e) => aux(d2e)
*)
//
| ~D2Efix _ => true
//
| ~D2Eint _ => true
| ~D2Ebool _ => true
| ~D2Echar _ => true
| ~D2Estring _ => true
| ~D2Ei0nt _ => true
| ~D2Ec0har _ => true
| ~D2Es0tring _ => true
//
| ~D2Etop() => true
//
| ~D2Esing(d2e) => aux(d2e)
//
| ~D2Etup(knd, npf, d2es) => auxlst(d2es)
| ~D2Erec(knd, npf, ld2es) => auxlablst(ld2es)
//
| ~D2Eexist(s2as, d2e) => aux (d2e)
//
| v (*rest-of-d2exp*) => (d2exp_node_view_free(v); false)
//
end // end of [aux]
//
and
auxlst
(
  d2es: d2explst
) : bool =
(
case+ glist_view(d2es) of
| ~GLnil() => true
| ~GLcons(d2e, d2es) =>
    if aux(d2e) then auxlst(d2es) else false
  // end of [GLcons]
)
//
and
auxlablst
(
  ld2es: labd2explst
) : bool =
(
case+ glist_view(ld2es) of
| ~GLnil
    ((*void*)) => true
  // GLnil
| ~GLcons
    (ld2e, ld2es) => let
//
    val d2e = ld2e.labd2exp_elt()
//
  in
    if aux(d2e) then auxlablst(ld2es) else false
  end // end of [GLcons]
)
//
in
  aux(d2e0)
end // end of [d2exp_is_varlamcst]

(* ****** ****** *)

implement
d2con_select_arity
  (d2cs, n) = let
//
val nd2cs = glist_length(d2cs)
//
fun
filt (d2cs: d2conlst, n: int): d2conlst =
(
  case+ glist_view(d2cs) of
  | ~GLnil() => glist_nil()
  | ~GLcons(d2c, d2cs) =>
    if d2con_get_arity_full(d2c) = n
      then glist_cons(d2c, filt(d2cs, n)) else filt(d2cs, n)
    // end of [if]
) (* end of [filt] *)
//
in
//
if
nd2cs >= 2
then let
//
val d2cs2 = filt(d2cs, n)
//
in
  if glist_is_cons(d2cs2) then d2cs2 else d2cs
end // end of [then]
else d2cs // end of [else]
//
end // end of [d2con_select_arity]

(* ****** ****** *)

local

fun
d2exp_d2var_lvalize
(
  d2e0: d2exp, d2v: d2var, d2ls: d2lablst
) : d2lval =
(
//
// HX-2020-10-04:
// [d2v] needs to be a PROOF.
// Please see bug-2020-10-04.dats
//
if
d2var_is_linear(d2v)
then d2lval_D2LVALvar_lin(d2v, d2ls)
else (
  if
  d2var_is_mutabl(d2v)
  then d2lval_D2LVALvar_mut(d2v, d2ls)
  else d2lval_D2LVALnone(d2e0) // rest-of-d2var
) (* end of [else] *)
) (* end of [d2var_lvalize] *)

in (* in-of-local *)

implement
d2exp_lvalize
  (d2e0) = let
(*
val () = (
  println! ("d2exp_lvalize: d2e0 = ", d2e0)
) (* end of [val] *)
*)
in
//
case+
d2exp_node_view(d2e0.d2exp_node())
of // case+
//
| ~D2Evar(d2v) =>
  d2exp_d2var_lvalize(d2e0, d2v, glist_nil())
//
| ~D2Ederef
    (_(*!*), d2e) => d2lval_D2LVALderef(d2e, glist_nil())
  // end of [D2Ederef]
//
| ~D2Eselab
  (
    d2e, d2ls
  ) => (
  case+
  d2exp_node_view(d2e.d2exp_node())
  of (* case+ *)
  | ~D2Evar(d2v) =>
      d2exp_d2var_lvalize(d2e0, d2v, d2ls)
    // end of [D2Evar]
  | ~D2Ederef(_(*!*), d2e) => d2lval_D2LVALderef(d2e, d2ls)
  | v (*rest-of-d2exp*) => (d2exp_node_view_free(v); d2lval_D2LVALnone (d2e0))
  ) (* end of [D2Esel] *)
//
| ~D2Eviewat (d2e) => d2lval_D2LVALviewat (d2e)
//
| ~D2Earrsub (
    d2s, arr, loc_ind, ind
  ) => d2lval_D2LVALarrsub (d2s, arr, loc_ind, ind)
//
| ~D2Esing (d2e) => d2exp_lvalize (d2e)
//
| v (*rest-of-d2exp*) => (d2exp_node_view_free(v); d2lval_D2LVALnone (d2e0))
//
end // end of [d2exp_lvalize]

end // end of [val]

(* ****** ****** *)

local

fn p1at_arity
  (p1t: p1at): int =
(
  case+ p1at_node_view(p1t.p1at_node()) of
  | ~P1Tlist (npf, p1ts) => glist_length (p1ts)
  | v => (p1at_node_view_free(v); 1)
) (* end of [p1at_arity] *)

fn aritest
  (d1e: d1exp, ns: intlst): bool = let
  fun loop1
  (
    d1e: d1exp, ns: intlst
  ) : bool =
    case+ glist_view(ns) of
    | ~GLnil () => true
    | ~GLcons (n, ns) => loop2 (d1e, n, ns)
  // end of [loop1]
  and loop2
  (
    d1e: d1exp, n: int, ns: intlst
  ) : bool =
    case+ d1exp_node_view(d1e.d1exp_node()) of
    | ~D1Elam_dyn
        (_(*lin*), p1t, d1e) =>
      (
        if n = p1at_arity (p1t) then loop1 (d1e, ns) else false
      )
    | ~D1Elam_met (_, _, d1e) => loop2 (d1e, n, ns)
    | ~D1Elam_sta_ana (_, _, d1e) => loop2 (d1e, n, ns)
    | ~D1Elam_sta_syn (_, _, d1e) => loop2 (d1e, n, ns)
    | v (*non-D1Elam*) => (d1exp_node_view_free(v); false)
  // end of [loop2]
in
  loop1 (d1e, ns)
end // end of [aritest]

in (* in-of-local *)

implement
d2cst_match_def
  (d2c, def) = let
  val ns = d2cst_get_artylst (d2c) in aritest (def, ns)
end // end of [d2cst_match_def]

end // end of [local]

(* ****** ****** *)

implement
d2exp_get_seloverld
  (d2e0) = let
//
fun aux
  (d2ls: d2lablst): d2symopt =
(
  case+ glist_view(d2ls) of
  | ~GLnil () => gopt_none((*void*))
  | ~GLcons (d2l, d2ls) => aux2 (d2l, d2ls)
) (* end of [aux] *)
//
and aux2
(
  d2l: d2lab, d2ls: d2lablst
) : d2symopt =
(
case+ glist_view(d2ls) of
| ~GLnil () => d2l.d2lab_overld()
| ~GLcons (d2l, d2ls) => aux2 (d2l, d2ls)
) (* end of [aux2] *)
//
in
//
case+ d2exp_node_view(d2e0.d2exp_node()) of
| ~D2Eselab (d2e, d2ls) => aux (d2ls)
| v => (d2exp_node_view_free(v); gopt_none())
//
end // end of [d2exp_get_seloverld]

(* ****** ****** *)

implement
d2exp_get_seloverld_root
  (d2e0) = let
//
fun aux
(
  d2e: d2exp
, d2l1: d2lab
, d2l2: d2lab
, d2ls: d2lablst
, res: d2lablst
) : d2exp =
(
case+ glist_view(d2ls) of
| ~GLnil () => let
    val loc =
      d2e.d2exp_loc() + d2l1.d2lab_loc()
    // end of [val]
    val res = glist_cons (d2l1, res)
  in
    d2exp_selab (loc, d2e, glist_reverse<d2lab>(res))
  end // end of [GLnil]
| ~GLcons (d2l3, d2ls) =>
  (
    aux (d2e, d2l2, d2l3, d2ls, glist_cons (d2l1, res))
  ) (* end of [GLcons] *)
)
//
in
//
case+ d2exp_node_view(d2e0.d2exp_node()) of
| ~D2Eselab (d2e, d2ls) => (
  case+ glist_view(d2ls) of
  | ~GLcons (d2l1, d2ls) => (
    case+ glist_view(d2ls) of
    | ~GLnil () => d2e
    | ~GLcons (d2l2, d2ls) =>
      (
        aux (d2e, d2l1, d2l2, d2ls, glist_nil())
      ) (* end of [GLcons] *)
    ) (* end of [GLcons] *)
  | ~GLnil () => (assertloc(false); d2e0) // HX: the MatchError of [val-list_cons]
  ) (* end of [D2Eselab] *)
| v => (d2exp_node_view_free(v); assertloc(false); d2e0) // HX: the MatchError of [val-D2Eselab]
//
end // end of [d2exp_get_seloverld_root]

(* ****** ****** *)

(* end of [pats_dynexp2_util.dats] *)
