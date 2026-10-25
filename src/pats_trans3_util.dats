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
// Start Time: October, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_util.dats, see PORTING.md,
// "Level 3 translation, group 1 (dynexp_up/util/syncst)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> () = prerr "pats_trans3_util"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"

(* ****** ****** *)

staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"

(* ****** ****** *)

staload "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans2.hats" // glist_map_fun & co.

(* ****** ****** *)
//
// HX: [list_last] of ATS1 (the list is not empty)
//
fun
d2explst_last (xs: d2explst): d2exp = let
  val x = glist_head (xs)
  val xs1 = glist_tail (xs)
in
  if glist_is_cons (xs1) then d2explst_last (xs1) else x
end // end of [d2explst_last]

(* ****** ****** *)

local

fun
fshowtype_d3exp
(
  knd: int, d3e: d3exp
) : void = let
//
val out = stdout_ref
//
val loc = d3e.d3exp_loc ()
val s2e = d3exp_get_type (d3e)
//
val () =
(
if
knd > 0
then fprint_string (out, "**SHOWTYPE[UP]**")
else fprint_string (out, "**SHOWTYPE[DN]**")
) (* end of [val] *)
//
val () = fprint_string (out, "(")
val () =
  $LOC.fprint_location (out, loc)
val () = fprint_string (out, ")")
//
val () = fprint_string (out, ": ")
val () = fpprint_s2exp (out, s2e)
//
val () = fprint_string (out, ": ")
val () = fprint_s2rt (out, s2e.s2exp_srt ())
//
val () = fprint_newline (out)
//
in
  // nothing
end // end of [fshowtype_d3exp]

in (* in-of-local *)

implement
fshowtype_d3exp_up (d3e) = fshowtype_d3exp (1, d3e)
implement
fshowtype_d3exp_dn (d3e) = fshowtype_d3exp (~1, d3e)

end // end of [local]

(* ****** ****** *)

implement
d2exp_funclo_of_d2exp
  (d2e0, fc0) =
  case+ d2exp_node_view (d2e0.d2exp_node ()) of
  | ~D2Eann_funclo (d2e, fc) =>
      let val () = fc0 := fc in d2e end
    // end of [D2Eann_funclo]
  | v => (d2exp_node_view_free (v); d2e0)
// end of [d2exp_funclo_of_d2exp]

(* ****** ****** *)

implement
d2exp_s2eff_of_d2exp
  (d2e0, s2fe0) =
  case+ d2exp_node_view (d2e0.d2exp_node ()) of
  | ~D2Elam_dyn _ =>
      (s2fe0 := s2eff_nil; d2e0)
  | ~D2Elaminit_dyn _ =>
      (s2fe0 := s2eff_nil; d2e0)
  | ~D2Elam_sta _ =>
      (s2fe0 := s2eff_nil; d2e0)
  | ~D2Eann_seff
      (d2e, s2fe) => let
      val () = s2fe0 := s2fe in d2e
    end // end of [D2Eann_seff]
  | v => let
      val () = d2exp_node_view_free (v)
      val () = s2fe0 := s2eff_all in d2e0
    end // end of [_]
// end of [d2exp_s2eff_of_d2exp]

(* ****** ****** *)
//
extern
fun
d2exp_syn_type_arg_body
(
  loc0: location
, fc0: funclo, lin: int, npf: int
, p2ts_arg: p2atlst, d2e_body: d2exp
) : s2exp // end of [d2exp_syn_type_arg_body]
//
implement
d2exp_syn_type_arg_body
(
  loc0, fc0, lin, npf, p2ts_arg, d2e_body
) = let
  var fc: funclo = fc0
  val s2es = p2atlst_syn_type (p2ts_arg)
  val s2e_res = d2exp_syn_type (d2e_body)
  val d2e_body = d2exp_funclo_of_d2exp (d2e_body, fc)
  val isprf = s2exp_is_prf (s2e_res)
  val islin = (if lin > 0 then true else false): bool
  var s2fe: s2eff
  val d2e_body = d2exp_s2eff_of_d2exp (d2e_body, s2fe)
  val s2t_fun = s2rt_prf_lin_fc (loc0, isprf, islin, fc)
in
  s2exp_fun_srt (s2t_fun, fc, lin, s2fe, npf, s2es, s2e_res)
end // end of [d2exp_syn_type_arg_body]
//
(* ****** ****** *)

implement
d2exp_syn_type
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc ()
//
val s2e0 =(
case+ d2exp_node_view (d2e0.d2exp_node ()) of
//
| ~D2Eint _ => s2exp_int_t0ype ()
| ~D2Ebool _ => s2exp_bool_t0ype ()
| ~D2Echar _ => s2exp_char_t0ype ()
| ~D2Estring _ => s2exp_string_type ()
| ~D2Efloat _ => s2exp_double_t0ype ()
//
| ~D2Ei0nt (x) => i0nt_syn_type (x)
| ~D2Ec0har _ => s2exp_char_t0ype ()
| ~D2Es0tring _ => s2exp_string_type ()
| ~D2Ef0loat (x) => f0loat_syn_type (x)
//
| ~D2Ecstsp (x) => cstsp_syn_type (d2e0, x)
//
| ~D2Eempty () => s2exp_void_t0ype ()
//
| ~D2Eextval (s2e, _(*name*)) => s2e
//
| ~D2Eassgn _ => s2exp_void_t0ype ()
//
| ~D2Elst (lin, opt, d2es) => let
    val s2e = (
      case+ gopt_view (opt) of
      | ~GOsome s2e => s2e
      | ~GOnone () => let
          val s2t = (
            if lin = 0 then s2rt_t0ype else s2rt_vt0ype
          ) : s2rt // end of [val]
        in
          s2exp_Var_make_srt (loc0, s2t)
        end // end of [None]
    ) : s2exp // end of [val]
    val n = glist_length (d2es)
  in
    s2exp_list_vt0ype_int_vtype (s2e, n) // HX-2026-10: no GC
  end // end of [D2Elst]
| ~D2Etup (knd, npf, d2es) => let
    val s2es = d2explst_syn_type (d2es)
  in
    s2exp_tytup (knd, npf, s2es)
  end // end of [D2Etup]
| ~D2Erec (knd, npf, ld2es) => let
    val ls2es = labd2explst_syn_type (ld2es)
  in
    s2exp_tyrec (knd, npf, ls2es)
  end // end of [D2Erec]
| ~D2Eseq (d2es) => (
  if glist_is_cons (d2es) then let
      val d2e = d2explst_last (d2es) in d2exp_syn_type (d2e)
    end
  else s2exp_void_t0ype ()
  ) // end of [D2Eseq]
//
| ~D2Earrpsz (opt, d2es) => let
    val s2e = (
      case+ gopt_view (opt) of
      | ~GOsome s2e => s2e
      | ~GOnone () => s2exp_Var_make_srt (loc0, s2rt_t0ype)
    ) : s2exp // end of [val]
    val n = glist_length (d2es)
  in
    s2exp_arrpsz_vt0ype_int_vt0ype (s2e, n)
  end // end of [D2Earrpsz]
//
| ~D2Elam_dyn
  (
    lin, npf, p2ts_arg, d2e_body
  ) => let
    val fc0 = FUNCLOfun () // HX: default
  in
    d2exp_syn_type_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
  end // end of [D2Elam_dyn]
//
| ~D2Elaminit_dyn
  (
    lin, npf, p2ts_arg, d2e_body
  ) => let
    val fc0 = FUNCLOclo (0) // HX: default
  in
    d2exp_syn_type_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
  end // end of [D2Elaminit_dyn]
//
| ~D2Elam_sta (s2vs, s2ps, d2e) => let
    val s2e = d2exp_syn_type (d2e) in s2exp_uni (s2vs, s2ps, s2e)
  end // end of [D2Elam_sta]
| ~D2Elam_met (_ref, met, d2e) => let
    val s2e = d2exp_syn_type (d2e) in s2exp_metfun (gopt_none ((*stamp*)), met, s2e)
  end // end of [D2Elam_met]
//
| ~D2Efix (knd, d2v, d2e) => d2exp_syn_type (d2e)
//
| ~D2Eann_type (_, s2e) => s2e
| ~D2Eann_seff (d2e, _) => d2exp_syn_type (d2e)
| ~D2Eann_funclo (d2e, _) => d2exp_syn_type (d2e)
//
| ~D2Eerrexp ((*void*)) => s2exp_t0ype_err ()
//
| v => let
    val () = d2exp_node_view_free (v)
    val s2e =
      s2exp_Var_make_srt (loc0, s2rt_t0ype)
    // end of [val]
  in
    s2e
  end // end of [_]
) : s2exp // end of [val]
in
  s2e0
end // end of [d2exp_syn_type]

implement
d2explst_syn_type
  (xs) = l2l (glist_map_loop<d2exp,s2exp> (xs, d2exp_syn_type, list_vt_nil ()))
// end of [d2explst_syn_type]

fun
labd2exp_syn_type
  (x: labd2exp): labs2exp = let
  val l0 = x.labd2exp_lab ()
  val d2e = x.labd2exp_elt ()
in
  labs2exp_new ($SYN.l0ab_lab (l0), gopt_none ((*none*)), d2exp_syn_type d2e)
end // end of [labd2exp_syn_type]

implement
labd2explst_syn_type (xs) =
  l2l (glist_map_loop<labd2exp,labs2exp> (xs, labd2exp_syn_type, list_vt_nil ()))
// end of [labd2explst_syn_type]

(* ****** ****** *)

implement
d23exp_free (x) = (
//
case+ x of
| ~D23Ed2exp (d2e) => () | ~D23Ed3exp (d3e) => ()
//
) (* end of [d23exp_free] *)

implement
d23explst_free (xs) = (
//
case+ xs of
| ~list_vt_nil () => ()
| ~list_vt_cons (x, xs) => (d23exp_free (x); d23explst_free (xs))
//
) (* end of [d23explst_free] *)

(* ****** ****** *)

implement
d3lablst_is_overld
  (d3ls) = (
//
case+ glist_view (d3ls) of
| ~GLnil () => false
| ~GLcons (d3l, d3ls) =>
  (
    case+ gopt_view (d3l.d3lab_overld ()) of
    | ~GOsome _ => true | ~GOnone () => d3lablst_is_overld (d3ls)
  ) (* end of [list_cons] *)
//
) (* end of [d3lablst_is_overld] *)
//
(* ****** ****** *)

local

fun
aux (
  d3e1: d3exp, s2f2: s2hnf
) : d3exp = d3e1 where
{
//
val loc = d3e1.d3exp_loc ()
val s2e1 = d3e1.d3exp_type ()
val s2f1 = s2exp2hnf (s2e1)
val s2e1 = s2hnf2exp (s2f1)
val s2e2 = s2hnf2exp (s2f2)
//
val err =
  $SOL.s2hnf_tyleq_solve(loc, s2f1, s2f2)
// end of [val]
val () =
if
(err != 0)
then let
  val () =
    prerr_error3_loc(loc)
  // end of [val]
  val () = filprerr_ifdebug "d3exp_trdn"
  val () = prerr ": the dynamic expression cannot be assigned the type ["
  val () = prerr_s2exp (s2e2)
  val () = prerr "]."
  val () = prerr_newline ()
  val () = prerr_the_staerrlst ()
//
in
  the_trans3errlst_add(trans3err_T3E_d3exp_trdn(d3e1, s2e2))
end // end of [if] // end of [val]
//
val ((*update*)) =
(
if
s2exp_node_is_S2EVar (s2e1.s2exp_node ())
then
  d3exp_set_type(d3e1, s2e2)
//
// HX-2016-12-21:
// Fixing bug-2016-06-26.dats
//
else ((*non-S2EVar: void*))
)
//
} (* end of [aux] *)

in (* in of [local] *)

implement
d3exp_trdn
  (d3e1, s2e2) = let
//
val s2f2 = s2exp2hnf (s2e2)
//
in
//
case+ s2exp_node_view (s2e2.s2exp_node ()) of
| ~S2Erefarg
    (_, s2e2) => d3exp_trdn (d3e1, s2e2)
| v => (s2exp_node_view_free (v); aux (d3e1, s2f2))
//
end (* end of [d3exp_trdn] *)

end // end of [local]

(* ****** ****** *)

implement
d3explst_trdn_arg
  (d3es, s2es) =
  case+ glist_view (d3es) of
  | ~GLcons (d3e, d3es) => (
    case+ glist_view (s2es) of
    | ~GLcons (s2e, s2es) => let
        val d3e = d3exp_trdn (d3e, s2e)
      in
        glist_cons (d3e, d3explst_trdn_arg (d3es, s2es))
      end // end of [list_cons]
    | ~GLnil () => glist_nil ()
    ) // end of [list_cons]
  | ~GLnil () => glist_nil ()
// end of [d3explst_trdn_arg]

(* ****** ****** *)

fun
d3exp_get_ind1
  (x: d3exp): s2exp = let
  val () = d3exp_open_and_add (x) in d3exp_get_type (x)
end // end of [d3exp_get_ind1]

implement
d3explst_get_ind (xs) =
  l2l (glist_map_loop<d3exp,s2exp> (xs, d3exp_get_ind1, list_vt_nil ()))
// end of [d3explst_get_ind]

(* ****** ****** *)

local

fun
s2exp_is_cloref
  (s2e: s2exp): bool =
(
case+ s2exp_node_view (s2e.s2exp_node ()) of
| ~S2Efun (
    fc, _, _, _, _, _
  ) => (
    // [FUNCLOclo (knd) => knd < 0 | FUNCLOfun () => false]
    funclo_get_clokind (fc) < 0
  ) // end of [S2Efun]
| ~S2Euni (_, _, s2e) => s2exp_is_cloref (s2e)
| ~S2Eexi (_, _, s2e) => s2exp_is_cloref (s2e)
| ~S2Emetfun (_, _, s2e) => s2exp_is_cloref (s2e)
| v (*rest-of-s2exp*) => (s2exp_node_view_free (v); false)
) // end of [s2exp_is_cloref]

//
// HX-2026-10:
// boxed tuples/records (linear or not) cannot be freed
// (destructuring them does not release the box), so they
// are all rejected unless they only contain proofs
//
fun
s2exp_is_boxed
  (s2e: s2exp): bool =
(
case+ s2exp_node_view (s2e.s2exp_node ()) of
| ~S2Etyrec (knd, _, _) =>
    if tyreckind_is_boxed (knd) then ~(s2exp_is_prf (s2e)) else false
| v (*rest-of-s2exp*) => (s2exp_node_view_free (v); false)
) // end of [s2exp_is_boxed]

fun
auxerr (
  d3e: d3exp, msg: string
) : void = let
  val loc = d3e.d3exp_loc ()
  val () = prerr_error3_loc (loc)
  val () = prerr ": nonlinear heap allocation is not supported (no GC): "
  val () = prerr (msg)
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d3exp_linheap (loc, d3e))
end // end of [auxerr]

in (* in-of-local *)

implement
d3exp_linheap_check
  (d3e) = let
  val s2e = d3exp_get_type (d3e)
  val () = (
    case+ d3exp_node_view (d3e.d3exp_node ()) of
    | ~D3Elam_dyn _ =>
        if s2exp_is_cloref (s2e) then
          auxerr (d3e, "a cloref closure is constructed; use a linear closure (cloptr) or a function instead.")
        // end of [if]
    | ~D3Etup _ =>
        if s2exp_is_boxed (s2e) then
          auxerr (d3e, "a boxed tuple is constructed (and could never be freed); use a flat tuple @(...) or a datavtype instead.")
        // end of [if]
    | ~D3Erec _ =>
        if s2exp_is_boxed (s2e) then
          auxerr (d3e, "a boxed record is constructed (and could never be freed); use a flat record @{...} or a datavtype instead.")
        // end of [if]
    | ~D3Edelay _ =>
        auxerr (d3e, "$delay constructs a nonlinear lazy value; use $ldelay instead.")
    | ~D3Elst (lin, _, _) =>
        if (lin >= 0 && ~test_linkind(lin)) then
          auxerr (d3e, "a nonlinear list is constructed; use $list(...) or $list_vt(...) instead.")
        // end of [if]
    | v (*rest-of-d3exp*) => d3exp_node_view_free (v)
  ) : void // end of [val]
in
  d3e
end // end of [d3exp_linheap_check]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_util.dats] *)
