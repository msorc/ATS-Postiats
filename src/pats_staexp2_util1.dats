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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_util1.dats, see PORTING.md)
// [s2hnf2exp] and [s2exp2hnf_cast] (two casts, ATS1: pats_staexp2_util2.dats) are here:
// the printers and [s2varbindmap_insert] need them.
// [s2exp_is_lin2], [s2eff_contain_set] and [s2eff_contain_exp] call [s2exp_hnfize],
// [s2exp2hnf] and [s2exp_syneq] of pats_staexp2_util2.dats (the next slice).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"
staload LOC = "./pats_location.sats"
staload EFF = "./pats_effect.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"
overload = with $SYM.eq_symbol_symbol

(* ****** ****** *)

staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

fn prerr_error2_loc
  (loc: location): void = (
  $LOC.prerr_location loc; prerr ": error(2)"
) // end of [prerr_error2_loc]

(* ****** ****** *)

implement s2hnf2exp (s2f) = $UN.cast{s2exp}(s2f)
implement s2exp2hnf_cast (s2e) = $UN.cast{s2hnf}(s2e)

(* ****** ****** *)

local

fn impname_linearize
  (name: $SYM.symbol): $SYM.symbol = let
in
//
if name = $SYM.symbol_PROP then $SYM.symbol_VIEW
else if name = $SYM.symbol_TYPE then $SYM.symbol_VIEWTYPE
else if name = $SYM.symbol_T0YPE then $SYM.symbol_VIEWT0YPE
else name
//
end // end of [impname_linearize]

in (* in of [local] *)

implement
s2rt_linearize
  (s2t) = let
  var err: int = 0
  var s2t: s2rt = s2t
  val () = (
    case+ s2rt_viewof(s2t) of
    | ~S2RTbas s2tb =>
      (
      case+ s2rtbas_view(s2tb) of
      | ~S2RTBASimp (knd, name) => let
          val knd = impkind_linearize (knd)
          val name = impname_linearize (name)
        in
          s2t := s2rt_S2RTbas(s2rtbas_S2RTBASimp(knd, name))
        end // end of [S2RTBASimp]
      | v => (s2rtbas_view_free (v); err := 1)
      ) // end of [S2RTbas]
    | v (*non-S2RTbas*) => (s2rt_view_free (v); err := 1)
  ) : void // end of [val]
in
  s2t
end // end of [s2rt_linearize]

end // end of [local]

(* ****** ****** *)

implement
s2rt_prf_lin_fc
(
  loc0, isprf, islin, fc
) = begin
if
isprf
then (
  if islin
    then s2rt_view else s2rt_prop
  // end of [if]
) else begin
  if islin then
    ( case+ fc of
      | FUNCLOclo0() => (* CLO(0) *)
          s2rt_vt0ype
      | FUNCLOcloptr() => (* CLOPTR(1) *)
          s2rt_vtype(*ptr*)
      | FUNCLOcloref() => (* CLOREF *)
          s2rt_err() where
        {
          val () =
          prerr_error2_loc(loc0)
          val () =
          prerr_string(": a closure reference cannot be linear.")
          val () = prerr_newline()
        } // end of [_]
      | FUNCLOfun((*void*)) => s2rt_vtype
    ) (* end of [islin] *)
  else
    ( case+ fc of
      | FUNCLOclo0() => s2rt_t0ype
      | FUNCLOcloptr() => s2rt_vtype(*ptr*)
      | FUNCLOcloref() => s2rt_type(*ref*)
      | FUNCLOfun((*void*)) => s2rt_type
    ) (* end of [~islin] *)
  (* end of [if] *)
end (* end of [if] *)
end // end of [s2rt_prf_lin_fc]

(* ****** ****** *)

(*
** HX: this function is called only when prgm = 0
*)
implement
s2rt_npf_lin_prf_boxed
  (npf, lin, prf, boxed) = (
//
if
(npf >= 0)
then (
if
(lin = 0)
then
  if boxed > 0 then s2rt_type else s2rt_t0ype
else
  if boxed > 0 then s2rt_vtype else s2rt_vt0ype
// end of [if]
) else (
//
if
(prf = 0)
then (
if
(lin = 0)
then
  if boxed > 0 then s2rt_type else s2rt_t0ype
else
  if boxed > 0 then s2rt_vtype else s2rt_vt0ype
// end of [if]
) else (
if
(lin = 0)
then
  if boxed > 0 then s2rt_type else s2rt_prop
else
  if boxed > 0 then s2rt_vtype else s2rt_view
// end of [if]
) (* end of [else] *)
//
) (* end of [else] *)
//
) (* end of [s2rt_lin_prf_boxed] *)

(* ****** ****** *)

implement
s2rt_npf_lin_prf_prgm_boxed_labs2explst
  (npf, lin, prf, prgm, boxed, ls2es) = let
//
fun aux // HX: only when prgm = 1
(
  npf: int, lin: int, xs: labs2explst
) : s2rt = let
in
//
if
(npf > 0)
then let
  val xs = glist_tail (xs) // HX: val-list_cons(_, xs) = xs
in
  aux (npf-1, lin, xs)
end else let
  val x = glist_head (xs) // HX: val-list_cons(x, xs) = xs
  val xs = glist_tail (xs)
  val s2e = labs2exp_elt (x)
  val s2t = s2exp_srt (s2e)
in
//
if
s2rt_is_prf(s2t)
then (
  aux (0(*npf*), lin, xs) // HX: [xs] not nil
) else (
  (if lin = 0 then s2t else s2rt_linearize(s2t))
) (* end of [if] *)
//
end (* end of [else] *)
//
end // end of [aux]
//
in
//
if
(prgm = 0)
then (
  s2rt_npf_lin_prf_boxed (npf, lin, prf, boxed)
) else (
//
if
(prgm = 1)
then (
  if boxed > 0 then
    if lin = 0 then s2rt_type else s2rt_vtype
  else aux (npf, lin, ls2es)
) else ( // HX: prgm >= 2
  if lin = 0 then
    if boxed > 0 then s2rt_type else s2rt_t0ype
  else
    if boxed > 0 then s2rt_vtype else s2rt_vt0ype
  // end of [if]
) // end of [if]
//
) (* end of [else] *)
//
end // end of [s2rt_npf_lin_prf_prgm_boxed_labs2explst]

(* ****** ****** *)

implement
s2exp_tytup
(
  knd, npf, s2es
) = let
//
fun aux
(
  i: int, s2es: s2explst
) : labs2explst = let
in
//
case+ glist_view(s2es) of
//
| ~GLnil
    ((*void*)) => glist_nil()
  // list_nil
//
| ~GLcons(s2e, s2es) => let
    val lab =
      $LAB.label_make_int(i)
    // end of [val]
    val ls2e = labs2exp_new(lab, gopt_none((*name*)), s2e)
    val ls2es = aux(i+1, s2es)
  in
    glist_cons(ls2e, ls2es)
  end // end of [list_cons]
//
end // end of [aux]
//
val ls2es = aux(0, s2es)
//
in
  s2exp_tyrec(knd, npf, ls2es)
end // end of [s2exp_tytup]

(* ****** ****** *)

implement
s2exp_tyrec
(
  knd, npf, ls2es
) = let
//
fun aux01
(
  i: int
, npf: int, ls2es: labs2explst
, lin: &int
, prf: &int
, prgm: &int
) : void = let
in
//
case+ glist_view(ls2es) of
| ~GLnil
    ((*void*)) => ()
  // end of [list_nil]
| ~GLcons(ls2e, ls2es) => let
//
    val s2e = labs2exp_elt (ls2e)
//
    val s2t = s2exp_srt (s2e)
    val () =
    if s2rt_is_lin(s2t) then (lin := lin+1)
    val () =
    if s2rt_is_prf(s2t)
      then (prf := prf+1) else (if i >= npf then prgm := prgm+1)
    // end of [if] // end of [val]
  in
    aux01(i+1, npf, ls2es, lin, prf, prgm)
  end // end of [list_cons]
//
end // end of [aux01]
//
var lin: int = 0
var prf: int = 0 and prgm: int = 0
val () = aux01(0, npf, ls2es, lin, prf, prgm)
val boxed = knd // 0/1
val tyrecknd =
(
  case+ knd of
  | 0 => tyreckind_TYRECKINDflt0()
  | 1 => tyreckind_TYRECKINDbox() | 2 => tyreckind_TYRECKINDbox()
  | _ => tyreckind_TYRECKINDbox_lin()
) : tyreckind // end of [val]
//
val s2t_rec =
(
if (knd >= 3)
  then s2rt_vtype
  else s2rt_npf_lin_prf_prgm_boxed_labs2explst(npf, lin, prf, prgm, boxed, ls2es)
// end of [if]
) : s2rt // end of [val]
//
in
  s2exp_tyrec_srt (s2t_rec, tyrecknd, npf, ls2es)
end // end of [s2exp_tyrec]

(* ****** ****** *)

implement
s2cst_select_locs2explstlst
  (s2cs, xss) = let
//
  fun test1 (
    xs: locs2explst, s2ts: s2rtlst
  ) : bool =
    case+ glist_view(xs) of
    | ~GLcons(x, xs) => (case+ glist_view(s2ts) of
      | ~GLcons(s2t, s2ts) => let
          val s2e = locs2exp_exp (x) in
          if s2rt_ltmat0 (s2exp_srt (s2e), s2t) then test1 (xs, s2ts) else false
        end // end of [list_cons]
      | ~GLnil() => false
      ) // end of [list_cons]
    | ~GLnil() => (case+ glist_view(s2ts) of
      | ~GLcons(_, _) => false | ~GLnil() => true
      ) // end of [list_nil]
  (* end of [test1] *)
//
  fun test2 (
    s2t: s2rt, xss: locs2explstlst
  ) : bool =
    case+ glist_view(xss) of
    | ~GLcons(xs, xss) => (
        if s2rt_is_fun (s2t) then let
          val- ~S2RTfun(s2ts_arg, s2t_res) = s2rt_viewof (s2t)
        in
          if test1 (xs, s2ts_arg) then test2 (s2t_res, xss) else false
        end else false
      ) // end of [list_cons]
    | ~GLnil() => true
  (* end of [test2] *)
//
  fun filter (
    s2cs: s2cstlst, xss: locs2explstlst
  ) : s2cstlst =
    case+ glist_view(s2cs) of
    | ~GLcons(s2c, s2cs) => let
        val s2t = s2cst_get_srt (s2c)
      in
        if test2 (s2t, xss) then
          glist_cons(s2c, filter (s2cs, xss)) else filter (s2cs, xss)
        // end of [if]
      end // end of [S2CSTLSTcons]
    | ~GLnil() => glist_nil()
  (* end of [filter] *)
//
in
  if glist_is_sing<s2cst> (s2cs)
    then s2cs else filter (s2cs, xss)
  // end of [if]
end // end of [s2cst_select_locs2explstlst]

(* ****** ****** *)

implement
s2exp_is_nonvar(s2e) = $effmask_all
(
case+
s2exp_node_view(s2exp_node(s2e)) of // case+
| ~S2Evar _ => false | v (*non-S2Evar*) => (s2exp_node_view_free (v); true)
) (* end of [s2exp_is_nonvar] *)

(* ****** ****** *)

implement
s2exp_is_wthtype(s2e) = $effmask_all
(
case+
s2exp_node_view(s2exp_node(s2e)) of (*case+*)
| ~S2Ewthtype _ => true
| ~S2Eexi(s2vs, s2ps, s2e) => s2exp_is_wthtype (s2e)
| v (*rest-of-s2exp*) => (s2exp_node_view_free (v); false)
) (* end of [s2exp_is_wthtype] *)

(* ****** ****** *)
//
extern
fun
labs2explst_is_without
  (xs: labs2explst):<> bool
//
implement
s2exp_is_without(s2e) = $effmask_all
(
case+
s2exp_node_view(s2exp_node(s2e)) of // case+
| ~S2Ewithout _ => true
| ~S2Etyrec(knd, npf, ls2es) => labs2explst_is_without (ls2es)
| v (*rest-of-s2exp*) => (s2exp_node_view_free (v); false)
) (* end of [s2exp_is_without] *)
//
implement
labs2explst_is_without
  (xs) = $effmask_all (
//
case+ glist_view(xs) of
| ~GLnil() => true
| ~GLcons(x, xs) => let
    val s2e = labs2exp_elt (x)
  in
    if s2exp_is_without(s2e)
      then labs2explst_is_without(xs) else false
    // end of [if]
  end // end of [list_cons]
) (* end of [labs2explst_is_without] *)
//
(* ****** ****** *)
//
extern
fun
labs2explst_is_lin2
  (xs: labs2explst): bool
//
implement
s2exp_is_lin2
  (s2e) = let
  val s2e = s2exp_hnfize (s2e)
  val islin = s2exp_is_lin (s2e)
in
//
if
islin
then (
case+
s2exp_node_view(s2exp_node(s2e))
of (* case+ *)
| ~S2Eat(s2e1, _) =>
    if s2exp_is_without(s2e1) then false else true
| ~S2Etyrec
    (knd, npf, ls2es) =>
  (
    if tyreckind_is_boxed(knd) then true else labs2explst_is_lin2(ls2es)
  ) // end of [S2Etyrec]
| v (*rest-of-s2exp*) => (s2exp_node_view_free (v); true)
) else false // end of [if]
//
end // end of [s2exp_is_lin2]
//
implement
labs2explst_is_lin2
  (xs) = (
//
case+ glist_view(xs) of
| ~GLnil() => false
| ~GLcons (x, xs) => let
    val s2e = labs2exp_elt (x)
  in
    if s2exp_is_lin2 (s2e) then true else labs2explst_is_lin2 (xs)
  end // end of [list_cons]
) (* end of [labs2explst_is_lin2] *)
//
(* ****** ****** *)

implement
s2hnf_get_head
  (s2f) = let
//
fun
loop(s2e: s2exp): s2exp =
(
case+
s2exp_node_view(s2exp_node(s2e))
of (* case+ *)
| ~S2Eapp(s2e, _) => loop s2e
| v => (s2exp_node_view_free (v); s2e)
) (* end of [loop] *)
//
val s2e = s2hnf2exp(s2f)
//
in
  s2exp2hnf_cast(loop(s2e))
end // end of [s2hnf_get_head]

(* ****** ****** *)

implement
s2hnf_is_abscon
  (s2f) = let
//
fun loop (
  s2e: s2exp
) : bool =
  case+ s2exp_node_view(s2exp_node(s2e)) of
  | ~S2Ecst s2c => (
      if s2cst_is_abstr (s2c) then true
      else if s2cst_is_tkind (s2c) then true
      else s2cst_get_iscon (s2c)
    ) // end of [S2Ecst]
  | ~S2Eapp (s2e, _) => loop (s2e)
  | v => (s2exp_node_view_free (v); false)
// end of [loop]
val s2e = s2hnf2exp (s2f)
in
  loop (s2e)
end // end of [s2hnf_is_abscon]

(* ****** ****** *)

implement
s2eff_add_set
  (s2fe, efs) = (
  if $EFF.effset_isnil (efs) then s2fe
  else if $EFF.effset_isall (efs) then s2eff_all
  else let
      val s2fe2 = s2eff_effset (efs) in s2eff_add (s2fe, s2fe2)
    end // end of [_]
) // end of [s2eff_add_set]

(* ****** ****** *)

implement
s2eff_contain_set
  (s2fe, efs0) = let
//
fun aux (
  s2e: s2exp, efs0: effset
) : bool = let
  val s2f = s2exp2hnf (s2e)
  val s2e = s2hnf2exp (s2f)
in
  false // HX: case+ s2e.s2exp_node of _ => false
end // end of [aux]
//
in
//
case+ s2eff_view (s2fe) of
| ~S2EFFset (efs) =>
    $EFF.effset_supset (efs, efs0)
| ~S2EFFexp (s2e) => aux (s2e, efs0)
| ~S2EFFadd (s2fe1, s2fe2) => let
    val ans = s2eff_contain_set (s2fe1, efs0)
  in
    if ans then true else s2eff_contain_set (s2fe2, efs0)
  end // end of [S2EFFadd]
//
end // end of [s2eff_contain_set]

(* ****** ****** *)

implement
s2eff_contain_exp
  (s2fe, s2e0) = let
in
//
case+ s2eff_view (s2fe) of
| ~S2EFFset (efs) =>
    if $EFF.effset_isall (efs) then true else false
| ~S2EFFexp (s2e) => s2exp_syneq (s2e0, s2e)
| ~S2EFFadd (s2fe1, s2fe2) => let
    val ans = s2eff_contain_exp (s2fe1, s2e0)
  in
    if ans then true else s2eff_contain_exp (s2fe2, s2e0)
  end // end of [S2EFFadd]
//
end // end of [s2eff_contain_exp]

(* ****** ****** *)

local

assume stasub_vtype = List0_vt @(s2var, s2exp)

in (* in of [local] *)

implement
stasub_make_nil () = list_vt_nil ()
implement
stasub_copy (sub) = list_vt_copy<@(s2var, s2exp)> (sub)
implement
stasub_free (sub) = list_vt_free<@(s2var, s2exp)> (sub)

(* ****** ****** *)

implement
fprint_stasub
  (out, sub) = let
//
fun loop
(
  out: FILEref, xs: !List0_vt @(s2var, s2exp), i: int
) : void = let
in
//
case+ xs of
| @list_vt_cons
    (x, xs1) => let
    val () =
    if i > 0
      then fprint_string (out, ", ")
    // end of [val]
    val () = fprint_s2var (out, x.0)
    val () = fprint_string (out, "->")
    val () = fprint_s2exp (out, x.1)
    val () = loop (out, xs1, i+1)
    prval () = fold@ (xs)
  in
    // nothing
  end // end of [list_vt_cons]
| list_vt_nil () => ()
//
end // end of [loop]
//
in
  loop (out, sub, 0)
end // end of [fprint_stasub]

(* ****** ****** *)

implement
stasub_add
  (sub, s2v, s2f) = let
  val xs = sub in sub := list_vt_cons (@(s2v, s2f), xs)
end
// end of [stasub_add]

implement
stasub_addlst
  (sub, s2vs, s2fs) = let
  fun loop (
    sub: &stasub >> _, s2vs: s2varlst, s2fs: s2explst
  ) : int =
    case+ glist_view(s2vs) of
    | ~GLcons
        (s2v, s2vs) => (
      case+ glist_view(s2fs) of
      | ~GLcons (s2f, s2fs) => let
          val () = stasub_add (sub, s2v, s2f) in loop (sub, s2vs, s2fs)
        end // end of [list_cons]
      | ~GLnil () => 1
      ) // end of [list_cons]
    | ~GLnil () => (
      case+ glist_view(s2fs) of
      | ~GLcons (_, _) => ~1 | ~GLnil () => 0
      ) // end of [list_nil]
  // end of [loop]
in
  loop (sub, s2vs, s2fs)
end // end of [stasub_addlst]

(* ****** ****** *)

implement
stasub_find (sub, s2v) = let
//
fun loop
(
  xs: !List0_vt @(s2var, s2exp), s2v: s2var
) : Option_vt (s2exp) =
(
case+ xs of
| @list_vt_cons (x, xs1) =>
    if eq_s2var_s2var (x.0, s2v) then let
      val res = x.1
      prval () = fold@ (xs)
    in
      Some_vt (res)
    end else let
      val ans = loop (xs1, s2v)
      prval () = fold@ (xs)
    in
      ans
    end // end of [list_vt_cons]
| list_vt_nil () => None_vt ()
)
//
in
  loop (sub, s2v)
end // end of [stasub_find]

(* ****** ****** *)

implement
stasub_occurcheck
  (sub, s2V) = let
//
fun loop
(
  xs: !List0_vt @(s2var, s2exp), s2V: s2Var
) : bool =
(
case+ xs of
| @list_vt_cons (x, xs1) => let
    val s2Vs = s2var_get_sVarset (x.0)
    val ismem = s2Varset_ismem (s2Vs, s2V)
  in
    if ismem then let
      prval () = fold@ (xs) in true
    end else let
      val ans = loop (xs1, s2V)
      prval () = fold@ (xs)
    in
      ans
    end (* end of [if] *)
  end // end of [list_vt_cons]
| list_vt_nil () => false
)
//
in
  loop (sub, s2V)
end // end of [stasub_occurcheck]

end // end of [local]

(* ****** ****** *)

implement
stasub_extend_svarlst (sub, s2vs) = let
//
fun loop (
  sub: &stasub >> _, s2vs: s2varlst, s2vs1: s2varlst_vt
) : s2varlst_vt =
  case+ glist_view(s2vs) of
  | ~GLcons (s2v, s2vs) => let
      val s2v1 = s2var_dup (s2v)
      val s2e1 = s2exp_var (s2v1)
      val () = stasub_add (sub, s2v, s2e1)
      val s2vs1 = list_vt_cons (s2v1, s2vs1)
    in
      loop (sub, s2vs, s2vs1)
    end // end of [list_cons]
  | ~GLnil () => s2vs1
// end of [loop]
//
val s2vs1 = loop (sub, s2vs, list_vt_nil ())
//
in
//
list_vt_reverse (s2vs1)
//
end // end of [stasub_extend_svarlst]

(* ****** ****** *)

extern
fun s2explstlst_subst_flag
  (sub: !stasub, s2ess0: s2explstlst, flag: &int): s2explstlst
// end of [s2explstlst_subst_flag]

extern
fun labs2explst_subst_flag
  (sub: !stasub, ls2es0: labs2explst, flag: &int): labs2explst
// end of [labs2explst_subst_flag]

extern
fun wths2explst_subst_flag
  (sub: !stasub, wths2es0: wths2explst, flag: &int): wths2explst
// end of [wths2explst_subst_flag]

extern
fun s2lab_subst_flag
  (sub: !stasub, s2l0: s2lab, flag: &int): s2lab
// end of [s2lab_subst_flag]
extern
fun s2lablst_subst_flag
  (sub: !stasub, s2ls0: s2lablst, flag: &int): s2lablst
// end of [s2lablst_subst_flag]

extern
fun s2eff_subst_flag
  (sub: !stasub, s2fe0: s2eff, flag: &int): s2eff
// end of [s2eff_subst_flag]

(* ****** ****** *)

extern
fun s2zexplst_subst_flag
  (sub: !stasub, s2zes0: s2zexplst, flag: &int): s2zexplst
// end of [s2zexplst_subst_flag]
extern
fun labs2zexplst_subst_flag
  (sub: !stasub, ls2zes0: labs2zexplst, flag: &int): labs2zexplst
// end of [labs2zexplst_subst_flag]

(* ****** ****** *)

fun
s2var_subst_flag (
  sub: !stasub
, s2e0: s2exp, flag: &int, s2v: s2var
) : s2exp = let
  val ans = stasub_find (sub, s2v)
in
  case+ ans of
  | ~Some_vt (s2e) => let
      val () = flag := flag + 1 in s2e
    end // end of [Some_vt]
  | ~None_vt () => s2e0
end // end of [s2var_subst_flag]

fun
s2Var_subst_flag (
  sub: !stasub
, s2e0: s2exp, flag: &int, s2V: s2Var
) : s2exp = let
  val opt = s2Var_get_link (s2V)
in
//
case+ gopt_view(opt) of
| ~GOsome(s2f) => let
    val () = flag := flag + 1
  in
    s2exp_subst_flag (sub, s2f, flag)
  end // end of [Some]
| ~GOnone() => let
    val isfound =
      stasub_occurcheck (sub, s2V)
    // end of [val]
    val () = if isfound then flag := flag + 1
  in
    if ~isfound
      then s2e0 else s2exp_errexp(s2e0.s2exp_srt())
    // end of [if]
  end // end of [None]
//
end // end of [s2Var_subst_flag]

fun
s2exp_subst_flag_exiuni (
  knd: int
, sub: !stasub, s2e0: s2exp, flag: &int
, s2vs: s2varlst, s2ps: s2explst, s2e: s2exp
) : s2exp = let
  val f0 = flag
  var sub1 = stasub_copy (sub)
  val s2vs = stasub_extend_svarlst (sub1, s2vs)
  val s2ps = s2explst_subst_flag (sub1, s2ps, flag)
  val s2e = s2exp_subst_flag (sub1, s2e, flag)
  val () = stasub_free (sub1)
in
  if flag > f0 then let
    val s2vs = l2l (s2vs)
    val s2f_res = s2exp_exiuni (knd, s2vs, s2ps, s2e)
  in
    s2f_res
  end else let
    val () = list_vt_free (s2vs) in s2e0
  end (* end of [if] *)
end // end of [s2exp_subst_flag_exiuni]

(* ****** ****** *)

implement
s2exp_subst_flag
  (sub, s2e0, flag) = let
  val s2t0 = s2e0.s2exp_srt()
in
//
case+ s2exp_node_view(s2e0.s2exp_node()) of
//
| ~S2Eint _ => s2e0
| ~S2Eintinf _ => s2e0
//
| ~S2Efloat _ => s2e0
| ~S2Estring _ => s2e0
//
| ~S2Ecst _ => s2e0
//
| ~S2Eextype
    (name, s2ess) => let
    val f0 = flag
    val s2ess = s2explstlst_subst_flag (sub, s2ess, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_extype_srt (s2t0, name, s2ess) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Eextype]
| ~S2Eextkind
    (name, s2ess) => let
    val f0 = flag
    val s2ess = s2explstlst_subst_flag (sub, s2ess, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_extkind_srt (s2t0, name, s2ess) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Eextkind]
//
| ~S2Evar (s2v) => s2var_subst_flag (sub, s2e0, flag, s2v)
| ~S2EVar (s2V) => s2Var_subst_flag (sub, s2e0, flag, s2V)
//
| ~S2Ehole _ => s2e0
//
| ~S2Edatcontyp (d2c, arg) => let
    val f0 = flag
    val arg = s2explst_subst_flag (sub, arg, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_datcontyp (d2c, arg) in s2e_res
    end else s2e0
  end // end of [S2Edatcontyp]
| ~S2Edatconptr (d2c, rt, arg) => let
    val f0 = flag
    val rt = s2exp_subst_flag (sub, rt, flag)
    val arg = s2explst_subst_flag (sub, arg, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_datconptr (d2c, rt, arg) in s2e_res
    end else s2e0
  end // end of [S2Edatconptr]
//
| ~S2Eat (s2e1, s2e2) => let
    val f0 = flag
    val s2e1 = s2exp_subst_flag (sub, s2e1, flag)
    val s2e2 = s2exp_subst_flag (sub, s2e2, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_at (s2e1, s2e2) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Eat]
//
| ~S2Esizeof (s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_sizeof (s2e) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Esizeof]
//
| ~S2Eeff (s2fe) => let
    val f0 = flag
    val s2fe = s2eff_subst_flag (sub, s2fe, flag)
  in
    if flag > f0 then s2exp_eff (s2fe) else s2e0
  end // end of [S2Eeff]
| ~S2Eeqeq (s2e1, s2e2) => let
    val f0 = flag
    val s2e1 = s2exp_subst_flag (sub, s2e1, flag)
    val s2e2 = s2exp_subst_flag (sub, s2e2, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_eqeq (s2e1, s2e2) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Eeqeq]
| ~S2Eproj (s2ae, s2te, s2ls) => let
    val f0 = flag
    val s2ae = s2exp_subst_flag (sub, s2ae, flag)
    val s2te = s2exp_subst_flag (sub, s2te, flag)
    val s2ls = s2lablst_subst_flag (sub, s2ls, flag)
  in
    if flag > f0
      then s2exp_proj (s2ae, s2te, s2ls) else s2e0
    // end of [if]
  end // end of [S2Eproj]
//
| ~S2Eapp (s2e_fun, s2es_arg) => let
    val f0 = flag
    val s2e_fun = s2exp_subst_flag (sub, s2e_fun, flag)
    val s2es_arg = s2explst_subst_flag (sub, s2es_arg, flag)
  in
    if flag > f0
      then s2exp_app_srt (s2t0, s2e_fun, s2es_arg) else s2e0
    // end of [if]
  end // end of [S2Eapp]
| ~S2Elam (s2vs, s2e) => let
    val f0 = flag
    var sub1 = stasub_copy (sub)
    val s2vs = stasub_extend_svarlst (sub1, s2vs)
    val s2e = s2exp_subst_flag (sub1, s2e, flag)
    val () = stasub_free (sub1)
  in
    if flag > f0 then
      s2exp_lam_srt (s2t0, l2l(s2vs), s2e)
    else let
      val () = list_vt_free (s2vs) in s2e0
    end (* end of [if] *)
  end // end of [S2Elam]
| ~S2Efun (
    fc, lin, s2fe, npf, s2es_arg, s2e_res
  ) => let
    val f0 = flag
    val s2fe = s2eff_subst_flag (sub, s2fe, flag)
    val s2es_arg = s2explst_subst_flag (sub, s2es_arg, flag)
    val s2e_res = s2exp_subst_flag (sub, s2e_res, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_fun_srt
        (s2t0, fc, lin, s2fe, npf, s2es_arg, s2e_res) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Efun]
| ~S2Emetfun
    (opt(*stamp*), s2es_met, s2e_body) => let
    val f0 = flag
    val s2es_met = s2explst_subst_flag (sub, s2es_met, flag)
    val s2e_body = s2exp_subst_flag (sub, s2e_body, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_metfun (opt, s2es_met, s2e_body) in s2e_res
    end else s2e0 // end of [if]
  end // end of [S2Emetfun]
//
| ~S2Emetdec(s2es1, s2es2) => let
    val f0 = flag
    val s2es1 = s2explst_subst_flag (sub, s2es1, flag)
    val s2es2 = s2explst_subst_flag (sub, s2es2, flag)
  in
    if flag > f0 then s2exp_metdec (s2es1, s2es2) else s2e0
  end // end of [S2Emetdec]
//
| ~S2Etop(knd, s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then s2exp_top_srt (s2t0, knd, s2e) else s2e0
  end // end of [S2Etop]
| ~S2Ewithout(s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then s2exp_without (s2e) else s2e0
  end // end of [S2Ewithout]
//
| ~S2Etyarr(s2e_elt, s2es_int) => let
    val f0 = flag
    val s2e_elt = s2exp_subst_flag (sub, s2e_elt, flag)
    val s2es_int = s2explst_subst_flag (sub, s2es_int, flag)
  in
    if flag > f0 then let
      val s2e_res = s2exp_tyarr (s2e_elt, s2es_int) in s2e_res
    end else s2e0
  end // end of [S2Etyarr]
//
| ~S2Etyrec(knd, npf, ls2es) => let
    val f0 = flag
    val ls2es = labs2explst_subst_flag (sub, ls2es, flag)
  in
    if flag > f0 then let
      val s2e_res =
        s2exp_tyrec_srt (s2t0, knd, npf, ls2es) in s2e_res
      // end of [val]
    end else s2e0 // end of [if]
  end // end of [S2Etyrec]
//
| ~S2Einvar(s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then s2exp_invar (s2e) else s2e0
  end // end of [S2Etyvarknd]
//
| ~S2Erefarg(knd, s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then s2exp_refarg (knd, s2e) else s2e0
  end // end of [S2Erefarg]
//
| ~S2Eexi(s2vs, s2ps, s2e) =>
    s2exp_subst_flag_exiuni (0(*exi*), sub, s2e0, flag, s2vs, s2ps, s2e)
  // end of [S2Eexi]
| ~S2Euni(s2vs, s2ps, s2e) =>
    s2exp_subst_flag_exiuni (1(*uni*), sub, s2e0, flag, s2vs, s2ps, s2e)
  // end of [S2Euni]
//
| ~S2Evararg(s2e) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
  in
    if flag > f0 then s2exp_vararg (s2e) else s2e0
  end // end of [S2Evararg]
//
| ~S2Ewthtype(s2e, ws2es) => let
    val f0 = flag
    val s2e = s2exp_subst_flag (sub, s2e, flag)
    val ws2es = wths2explst_subst_flag (sub, ws2es, flag)
  in
    if flag > f0 then s2exp_wthtype (s2e, ws2es) else s2e0
  end // end of [S2Ewth]
//
| ~S2Eerrexp((*void*)) => s2e0
// end of [case]
end // end of [s2exp_subst_flag]

(* ****** ****** *)

implement
s2explst_subst_flag
  (sub, s2es0, flag) =
  case+ glist_view(s2es0) of
  | ~GLcons(s2e, s2es) => let
      val f0 = flag
      val s2e = s2exp_subst_flag (sub, s2e, flag)
      val s2es = s2explst_subst_flag (sub, s2es, flag)
    in
      if flag > f0 then glist_cons(s2e, s2es) else s2es0
    end (* end of [list_cons] *)
  | ~GLnil() => glist_nil()
// end of [s2explst_subst_flag]

implement
s2explstlst_subst_flag
  (sub, s2ess0, flag) =
  case+ glist_view(s2ess0) of
  | ~GLcons(s2es, s2ess) => let
      val f0 = flag
      val s2es = s2explst_subst_flag (sub, s2es, flag)
      val s2ess = s2explstlst_subst_flag (sub, s2ess, flag)
    in
      if flag > f0 then glist_cons(s2es, s2ess) else s2ess0
    end // end of [list_cons]
  | ~GLnil() => glist_nil()
// end of [s2explstlst_subst_flag]

(* ****** ****** *)

implement
labs2explst_subst_flag
  (sub, ls2es0, flag) =
(
  case+ glist_view(ls2es0) of
  | ~GLnil
     ((*void*)) => glist_nil()
    // end of [list_nil]
  | ~GLcons(ls2e, ls2es) => let
      val l = labs2exp_lab (ls2e) and name = labs2exp_nam (ls2e) and s2e = labs2exp_elt (ls2e)
      val f0 = flag
      val s2e = s2exp_subst_flag (sub, s2e, flag)
      val ls2es = labs2explst_subst_flag (sub, ls2es, flag)
    in
      if flag > f0 then let
        val ls2e = labs2exp_new(l, name, s2e) in glist_cons(ls2e, ls2es)
      end else ls2es0 // end of [if]
    end // end of [LABS2EXPLSTcons]
) (* end of [labs2explst_subst_flag] *)

(* ****** ****** *)

implement
wths2explst_subst_flag
  (sub, ws2es0, flag) =
(
//
case+ wths2explst_view(ws2es0) of
| ~WTHS2EXPLSTnil
    ((*void*)) => wths2explst_WTHS2EXPLSTnil()
  // end of [WTHS2EXPLSTnil]
| ~WTHS2EXPLSTcons_invar
    (knd, s2e, ws2es) => let
    val f0 = flag
    val s2e =
      s2exp_subst_flag(sub, s2e, flag)
    val ws2es =
      wths2explst_subst_flag(sub, ws2es, flag)
  in
    if flag > f0
      then wths2explst_WTHS2EXPLSTcons_invar(knd, s2e, ws2es) else ws2es0
    // end of [if]
  end // end of [WTHS2EXPLSTcons_invar]
| ~WTHS2EXPLSTcons_trans
    (knd, s2e, ws2es) => let
    val f0 = flag
    val s2e =
      s2exp_subst_flag(sub, s2e, flag)
    val ws2es =
      wths2explst_subst_flag(sub, ws2es, flag)
  in
    if flag > f0
      then wths2explst_WTHS2EXPLSTcons_trans(knd, s2e, ws2es) else ws2es0
    // end of [if]
  end // end of [WTHS2EXPLSTcons_trans]
| ~WTHS2EXPLSTcons_none (ws2es) => let
    val f0 = flag
    val ws2es =
      wths2explst_subst_flag(sub, ws2es, flag)
    // end of [val]
  in
    if flag > f0 then wths2explst_WTHS2EXPLSTcons_none(ws2es) else ws2es0
  end // end of [WTHS2EXPLSTcons_none]
//
) (* end of [wths2explst_subst_flag] *)

(* ****** ****** *)

implement
s2lab_subst_flag
(
  sub, s2l0, flag
) = (
//
case+ s2lab_view(s2l0) of
| ~S2LABlab _ => s2l0
| ~S2LABind(s2es) => let
    val f0 = flag
    val s2es =
      s2explst_subst_flag (sub, s2es, flag)
    // end of [val]
  in
    if flag > f0 then s2lab_S2LABind(s2es) else s2l0
  end // end of [S2LABind]
//
) (* end of [s2lab_subst_flag] *)

implement
s2lablst_subst_flag
(
  sub, s2ls0, flag
) = (
//
case+ glist_view(s2ls0) of
| ~GLnil
    ((*void*)) => glist_nil()
  // end of [list_nil]
| ~GLcons(s2l, s2ls) => let
    val f0 = flag
    val s2l =
      s2lab_subst_flag(sub, s2l, flag)
    val s2ls =
      s2lablst_subst_flag(sub, s2ls, flag)
  in
    if flag > f0 then glist_cons(s2l, s2ls) else s2ls0
  end // end of [list_cons]
//
) (* end of [s2lablst_subst_flag] *)

(* ****** ****** *)

implement
s2eff_subst_flag
  (sub, s2fe0, flag) = (
  case+ s2eff_view(s2fe0) of
  | ~S2EFFset (efs) => s2fe0
  | ~S2EFFexp (s2e) => let
      val f0 = flag
      val s2e = s2exp_subst_flag (sub, s2e, flag)
    in
      if flag > f0 then s2eff_S2EFFexp(s2e) else s2fe0
    end // end of [S2EFFexp]
  | ~S2EFFadd (s2fe1, s2fe2) => let
      val f0 = flag
      val s2fe1 = s2eff_subst_flag (sub, s2fe1, flag)
      val s2fe2 = s2eff_subst_flag (sub, s2fe2, flag)
    in
      if flag > f0 then s2eff_S2EFFadd(s2fe1, s2fe2) else s2fe0
    end // end of [S2EFFadd]
) // end of s2eff_subst_flag

(* ****** ****** *)

implement
s2zexp_subst_flag
  (sub, s2ze0, flag) = let
in
//
case+ s2zexp_view(s2ze0) of
//
| ~S2ZEprf _ => s2ze0
| ~S2ZEptr _ => s2ze0
//
| ~S2ZEcst _ => s2ze0
//
| ~S2ZEvar (s2v) => let
    val f0 = flag
    val ans = stasub_find (sub, s2v)
  in
    case+ ans of
    | ~Some_vt (s2e) => let
        val () = flag := f0 + 1 in s2zexp_make_s2exp (s2e)
      end // end of [Some_vt]
    | ~None_vt ((*void*)) => s2ze0
  end // end of [S2ZEvar]
//
| ~S2ZEVar (s2V) => s2ze where
  {
    val f0 = flag
    val s2ze = s2Var_get_szexp (s2V)
    val s2ze = s2zexp_subst_flag (sub, s2ze, flag)
    val () = flag := f0 + 1
  } (* end of [S2ZEVar] *)
//
| ~S2ZEextype _ => s2ze0
| ~S2ZEextkind _ => s2ze0
//
| ~S2ZEapp
    (s2ze1, s2zes2) => let
    val f0 = flag
    val s2ze1 =
      s2zexp_subst_flag (sub, s2ze1, flag)
    val s2zes2 =
      s2zexplst_subst_flag (sub, s2zes2, flag)
  in
    if flag > f0
      then s2zexp_S2ZEapp(s2ze1, s2zes2) else s2ze0
    // end of [if]
  end // end of [S2ZEapp]
//
| ~S2ZEtyarr
    (s2ze_elt, s2es_dim) => let
    val f0 = flag
    val s2ze_elt =
      s2zexp_subst_flag (sub, s2ze_elt, flag)
    val s2es_dim =
      s2explst_subst_flag (sub, s2es_dim, flag)
  in
    if flag > f0
      then s2zexp_S2ZEtyarr(s2ze_elt, s2es_dim) else s2ze0
    // end of [if]
  end // end of [S2ZEtyarr]
//
| ~S2ZEtyrec
    (knd, ls2zes) => let
    val f0 = flag
    val ls2zes =
      labs2zexplst_subst_flag (sub, ls2zes, flag)
    // end of [val]
  in
    if flag > f0 then s2zexp_S2ZEtyrec(knd, ls2zes) else s2ze0
  end // end of [S2ZEtyrec]
//
| ~S2ZEclo _ => s2ze0
//
| ~S2ZEbot _ => s2ze0
//
end // end of [s2zexp_subst_flag]

(* ****** ****** *)

implement
s2zexplst_subst_flag
  (sub, s2zes0, flag) =
  case+ glist_view(s2zes0) of
  | ~GLcons(s2ze, s2zes) => let
      val f0 = flag
      val s2e = s2zexp_subst_flag (sub, s2ze, flag)
      val s2es = s2zexplst_subst_flag (sub, s2zes, flag)
    in
      if flag > f0 then glist_cons(s2ze, s2zes) else s2zes0
    end (* end of [list_cons] *)
  | ~GLnil() => glist_nil()
// end of [s2zexplst_subst_flag]

(* ****** ****** *)

implement
labs2zexplst_subst_flag
  (sub, ls2zes0, flag) =
  case+ glist_view(ls2zes0) of
  | ~GLcons(ls2ze, ls2zes) => let
      val l = labs2zexp_lab (ls2ze) and s2ze = labs2zexp_elt (ls2ze)
      val f0 = flag
      val s2ze = s2zexp_subst_flag (sub, s2ze, flag)
      val ls2zes = labs2zexplst_subst_flag (sub, ls2zes, flag)
    in
      if flag > f0 then let
        val ls2ze = labs2zexp_new (l, s2ze) in glist_cons(ls2ze, ls2zes)
      end else ls2zes0 // end of [if]
    end // end of [LABS2ZEXPLSTcons]
  | ~GLnil ((*void*)) => glist_nil()
// end of [labs2zexplst_subst_flag]

(* ****** ****** *)

implement
s2exp_subst (sub, s2e) = let
  var flag: int = 0 in s2exp_subst_flag (sub, s2e, flag)
end // end of [s2exp_subst]

(* ****** ****** *)

implement
s2explst_subst (sub, s2es) = let
  var flag: int = 0 in s2explst_subst_flag (sub, s2es, flag)
end // end of [s2explst_subst]

implement
s2explst_subst_vt
  (sub, s2es) = case+ glist_view(s2es) of
  | ~GLcons(s2e, s2es) => let
      val s2e = s2exp_subst (sub, s2e)
      val s2es = s2explst_subst_vt (sub, s2es)
    in
      list_vt_cons (s2e, s2es)
    end // end of [list_cons]
  | ~GLnil() => list_vt_nil ()
// end of [s2explst_subst_vt]

implement
s2explstlst_subst
  (sub, s2ess) = let
  var flag: int = 0 in s2explstlst_subst_flag (sub, s2ess, flag)
end // end of [s2explstlst_subst]

(* ****** ****** *)

implement
s2expopt_subst
  (sub, opt) =
  case+ gopt_view(opt) of
  | ~GOsome(s2e) => let
      var flag: int = 0
      val s2e = s2exp_subst_flag (sub, s2e, flag)
    in
      if flag > 0 then gopt_some(s2e) else opt
    end // end of [Some]
  | ~GOnone() => opt
// end of [s2expopt_subst]

(* ****** ****** *)

implement
s2exp_alpha
  (s2v, s2v_new, s2e) = let
  var sub = stasub_make_nil ()
  val () = stasub_add (sub, s2v, s2exp_var (s2v_new))
  val s2e_new = s2exp_subst (sub, s2e)
  val () = stasub_free (sub)
in
  s2e_new
end // end of [s2exp_alpha]

implement
s2explst_alpha
  (s2v, s2v_new, s2es) = let
  fun aux (
    s2v: s2var, s2v_new: s2var, s2es0: s2explst
  ) : s2explst =
    case+ glist_view(s2es0) of
    | ~GLcons(s2e, s2es) => let
        var flag: int = 0
        val s2e_new = s2exp_alpha (s2v, s2v_new, s2e)
        val () = if not (ptr_eq ($UN.cast{ptr} (s2e), $UN.cast{ptr} (s2e_new))) then flag := flag + 1
        val s2es_new = aux (s2v, s2v_new, s2es)
        val () = if not (ptr_eq ($UN.cast{ptr} (s2es), $UN.cast{ptr} (s2es_new))) then flag := flag + 1
      in
        if flag > 0 then glist_cons(s2e_new, s2es_new) else s2es0
      end // end of [list_cons]
    | ~GLnil() => s2es0
  // end of [aux]
in
  aux (s2v, s2v_new, s2es)
end // end of [s2explst_alpha]

(* ****** ****** *)

(* end of [pats_staexp2_util1.dats] *)
