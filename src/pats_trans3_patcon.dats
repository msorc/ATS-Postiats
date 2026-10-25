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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_patcon.dats, see PORTING.md,
// "Level 3 translation, group 2 (dynexp_dn/appsym/caseof/patcon)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_patcon"

(* ****** ****** *)

staload LOC = "./pats_location.sats"

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

#define l2l glist_make_list_vt

(* ****** ****** *)
//
// HX-2026-10: ATS1 had [dataviewtype patcontrup = PATCONTRUP of (p2atlst, s2explst(*arg*), s2exp(*res*))]
// (a linear box that the caller consumed at once): a flat triple here
//
typedef
patcontrup = @(p2atlst, s2explst(*arg*), s2exp(*res*))

(* ****** ****** *)
//
// HX-2012-05:
// [patconknd]: nonlin/preserve/free/unfold: ~1/0/1/2
//
extern
fun p2at_trup_con (p2t0: p2at): patcontrup
implement
p2at_trup_con
  (p2t0) = let
//
val loc0 = p2t0.p2at_loc()
val-~P2Tcon (
  _(*pck*), d2c, s2qs, s2e_con, npf, p2ts_arg
) = p2at_node_view(p2t0.p2at_node())
//
val () = let
  fun loop (s2qs: s2qualst): void =
    case+ glist_view(s2qs) of
    | ~GLcons (s2q, s2qs) => let
        val () = trans3_env_add_svarlst (s2q.s2qua_svs())
      in
        loop (s2qs)
      end // end of [list_cons]
    | ~GLnil () => ()
  // end of [loop]
in
  loop (s2qs)
end // end of [val]
//
val () = let
  fun loop (
    loc0: $LOC.location, s2qs: s2qualst
  ) : void = case+ glist_view(s2qs) of
    | ~GLcons (s2q, s2qs) => let
        val () = trans3_env_hypadd_proplst (loc0, s2q.s2qua_sps())
      in
        loop (loc0, s2qs)
      end // end of [list_cons]
    | ~GLnil () => ()
  // end of [loop]
in
  loop (loc0, s2qs)
end // end of [val]
//
in
//
case+ s2exp_node_view(s2e_con.s2exp_node()) of
| ~S2Efun (
    fc, lin, s2fe, npf_con, s2es_arg, s2e_res
  ) => let
    val err = $SOL.pfarity_equal_solve (loc0, npf, npf_con)
    val () = if err > 0 then {
      val () = prerr_error3_loc (loc0)
      val () = filprerr_ifdebug "p2at_trup_con"
      val () = prerr_string ": proof arity mismatch: the constructor ["
      val () = prerr_d2con (d2c)
      val () = prerr_string "] requires ["
      val () = prerr_int (npf_con)
      val () = prerr_string "] arguments."
      val () = prerr_newline ()
      val () = prerr_the_staerrlst ()
      val () = the_trans3errlst_add (trans3err_T3E_p2at_trup_con (p2t0))
    } // end of [val]
  in
    @(p2ts_arg, s2es_arg, s2e_res)
  end // end of [S2Efun]
| v => let
    val () = s2exp_node_view_free (v)
    val () = prerr_error3_loc (loc0)
    val () = filprerr_ifdebug "p2at_trup_con"
    val () = prerr_string ": the constructor pattern is ill-typed."
    val () = prerr_newline ()
    val () = the_trans3errlst_add (trans3err_T3E_p2at_trup_con (p2t0))
    val s2es_arg =
      aux (p2ts_arg) where {
      fun aux (
        p2ts: p2atlst
      ) : s2explst =
        case+ glist_view(p2ts) of
        | ~GLcons (_, p2ts) => let
            val s2e = s2exp_t0ype_err () in glist_cons (s2e, aux p2ts)
          end // end of [list_cons]
        | ~GLnil () => glist_nil ()
      // end of [aux]
    } // end of [val]
    val s2e_res = s2exp_t0ype_err ()
  in
    @(p2ts_arg, s2es_arg, s2e_res)
  end // end of [_]
//
end // end of [p2at_trup_con]

(* ****** ****** *)

extern
fun p3at_lincon_update
(
  p3t0: p3at, d2c: d2con, p3ts_arg: p3atlst
) : void // end of [p3at_lincon_update]

(* ****** ****** *)

local

fun auxvar
  (d2v: d2var): void = let
//
val islin = d2var_is_linear (d2v)
//
in
//
if islin then let
  val-~GOsome
    (s2e) = gopt_view(d2var_get_mastype (d2v))
  // end of [val]
in
  d2var_set_finknd (d2v, d2vfin_D2VFINsome (s2e))
end // end of [if]
//
end // end of [auxvar]

fun auxpat
  (p3t: p3at): void = let
in
//
case+ p3at_node_view(p3t.p3at_node()) of
| ~P3Tvar (d2v) => auxvar (d2v)
| ~P3Trefas (d2v, _) => auxvar (d2v)
| v => p3at_node_view_free (v)
end // end of [auxpat]

// HX: [list_app_fun<p3at> (p3ts_arg, auxpat)]
fun auxpatlst
  (p3ts: p3atlst): void =
  case+ glist_view(p3ts) of
  | ~GLcons (p3t, p3ts) => (auxpat (p3t); auxpatlst (p3ts))
  | ~GLnil () => ()
// end of [auxpatlst]

in (* in of [local] *)

implement
p3at_lincon_update (
  p3t0, d2c, p3ts_arg
) = let
  val () = auxpatlst (p3ts_arg)
in
  p3at_set_type_left (p3t0, gopt_some (p3t0.p3at_type()))
end // end of [p3at_lincon_update]

end // end of [local]

(* ****** ****** *)

extern
fun p3at_free_update (
  p3t0: p3at, d2c: d2con, p3ts_arg: p3atlst
) : void // end of [p3at_free_update]

local

fun auxck (
  p3t: p3at
) : void = let
  val loc = p3t.p3at_loc()
  val opt = p3at_get_type_left (p3t)
in
//
case+ gopt_view(opt) of
| ~GOsome (s2e) => let
    val () = prerr_error3_loc (loc)
    val () = prerr_string ": a value matching this pattern may not be freed";
    val () = prerr_string ": it contains a linear component of the following type [";
    val () = pprerr_s2exp (s2e)
    val () = prerr_string "]."
    val () = prerr_newline ()
  in
    the_trans3errlst_add (trans3err_T3E_p2at_free_update (p3t))
  end (* end of [if] *)
| ~GOnone () => ()
end // end of [auxck]

// HX: [list_app_fun<p3at> (p3ts_arg, auxck)]
fun auxcklst
  (p3ts: p3atlst): void =
  case+ glist_view(p3ts) of
  | ~GLcons (p3t, p3ts) => (auxck (p3t); auxcklst (p3ts))
  | ~GLnil () => ()
// end of [auxcklst]

in (* in of [local] *)

implement
p3at_free_update
  (p3t0, d2c, p3ts_arg) =
  auxcklst (p3ts_arg)
// end of [p3at_free_update]

end // end of [local]

(* ****** ****** *)

extern
fun p3at_unfold_update (
  p3t0: p3at, d2c: d2con, p3ts_arg: p3atlst
) : void // end of [p3at_unfold_update]

local

fun auxpat1
  (p3t: p3at): d2var = let
in
//
case+ p3at_node_view(p3t.p3at_node()) of
| ~P3Tany (d2v) => let
    val opt = p3at_get_type_left (p3t)
    val opt = (
      if gopt_is_some (opt)
        then opt
        else gopt_some (s2exp_topize_1 (p3t.p3at_type()))
    ) : s2expopt // end of [val]
    val () = d2var_set_type (d2v, opt)
  in
    d2v
  end (* end of [P3Tany] *)
| ~P3Tvar (d2v) => d2v
| ~P3Trefas (d2v, _) => let
    val opt =
      p3at_get_type_left (p3t)
    // end of [val]
    val () = (
      if gopt_is_some (opt)
        then d2var_set_type (d2v, opt) else ()
    ) : void // end of [val]
  in
    d2v
  end // end of [P3Trefas]
| v => let
    val () = p3at_node_view_free (v)
    val d2v =
      d2var_make_any (p3t.p3at_loc())
    val () = p3at_set_dvaropt (p3t, gopt_some (d2v))
    val opt = p3at_get_type_left (p3t)
    val opt = (
      if gopt_is_some (opt)
        then opt
        else gopt_some (s2exp_topize_1 (p3t.p3at_type()))
    ) : s2expopt // end of [val]
    val () = d2var_set_type (d2v, opt)
  in
    d2v
  end (* end of [_] *)
//
end // end of [auxpat1]

fun auxpat2
  (p3t: p3at): s2exp = let
  val loc = p3t.p3at_loc()
  val d2v = auxpat1 (p3t)
  val-~GOsome (s2e) = gopt_view(d2var_get_type (d2v))
  val d2vw = d2var_mutablize_none (loc, d2v, s2e) // making [d2v] mutable
  val-~GOsome (s2l) = gopt_view(d2var_get_addr (d2v))
in
  s2l
end (* end of [auxpat2] *)

// HX: [list_map_fun<p3at> (p3ts_arg, auxpat2)] (head first)
fun auxpat2lst
  (p3ts: p3atlst, res: List0_vt(s2exp)): List0_vt(s2exp) =
  case+ glist_view(p3ts) of
  | ~GLcons (p3t, p3ts) => let
      val s2l = auxpat2 (p3t) in auxpat2lst (p3ts, list_vt_cons (s2l, res))
    end // end of [GLcons]
  | ~GLnil () => list_vt_reverse (res)
// end of [auxpat2lst]

fun s2dcp_make (
  d2c: d2con, arg: s2explst
) : s2exp = let
  val s2v = s2var_make_srt (s2rt_addr)
  val () = trans3_env_add_svar (s2v) // adding svar
  val rt = s2exp_var (s2v) // the root of datconptr
in
  s2exp_datconptr (d2c, rt, arg)
end // end of [s2dcp_make]

in (* in of [local] *)

implement
p3at_unfold_update
  (p3t0, d2c, p3ts_arg) = let
//
val s2ls =
  auxpat2lst (p3ts_arg, list_vt_nil ())
val s2dcp = s2dcp_make (d2c, l2l(s2ls))
//
in
  p3at_set_type_left (p3t0, gopt_some (s2dcp))
end // end of [p3at_unfold_update]

end // end of [local]

(* ****** ****** *)

local

fun
auxerr_arity
(
  p2t0: p2at, serr: int
) : void = let
  val loc0 = p2t0.p2at_loc()
  val () = prerr_error3_loc (loc0)
  val () = prerr_string ": constructor arity mismatch"
  val () = if serr < 0 then prerr_string ": more arguments are expected."
  val () = if serr > 0 then prerr_string ": fewer arguments are expected."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_p2at_trdn_con_arity (p2t0, serr))
end // end of [val]

in (* in of [local] *)

implement
p2at_trdn_con
  (p2t0, s2f0) = let
val loc0 = p2t0.p2at_loc()
val s2e0 = s2hnf2exp (s2f0)
val-~P2Tcon (
  pck, d2c, s2qs, s2e_con, npf, p2ts_arg
) = p2at_node_view(p2t0.p2at_node())
//
val s2c = d2con_get_scst (d2c)
val s2e = s2hnf_opnexi_and_add (loc0, s2f0)
val s2f = s2exp2hnf (s2e)
val s2e = s2hnf2exp (s2f)
val s2f_head = s2hnf_get_head (s2f)
val s2e_head = s2hnf2exp (s2f_head)
//
var flag: int = ~1 (*error*)
var s2es_arg_alt: s2explst = glist_nil ()
val () = (
case+ s2exp_node_view(s2e_head.s2exp_node()) of
| ~S2Ecst (s2c1) =>
    if eq_s2cst_s2cst (s2c, s2c1) then flag := 0
| ~S2Edatcontyp (d2c1, s2es) =>
    if eq_d2con_d2con (d2c, d2c1) then (flag := 1; s2es_arg_alt := s2es)
| v => (s2exp_node_view_free (v))
) // end of [val]
//
val () =
if (flag > 0) then
(
case+ pck of
| PCKfree () => let
    val (
    ) = prerr_error3_loc (loc0)
    val () = prerr_string ": the pattern decoration ~(freeing) is wrongly applied."
    val () = prerr_newline ((*void*))
  in
    the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))
  end // end of [PCKfree]
| PCKunfold () => let
    val (
    ) = prerr_error3_loc (loc0)
    val () = prerr_string ": the pattern decoration @(unfolding) is wrongly applied."
    val () = prerr_newline ((*void*))
  in
    the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))
  end // end of [PCKunfold]
| _ => ()
) // end of [if] // end of [val]
//
val () =
if (flag < 0) then let
  val (
  ) = prerr_error3_loc (loc0)
  val () = prerr_string ": the constructor pattern cannot be assigned the type ["
  val () = pprerr_s2exp (s2e)
  val () = prerr_string "]."
  val () = prerr_newline ((*void*))
in
  the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))
end (* end of [if] // end of [val] *)
//
val flag_vwtp =
(
  if flag > 0 then 1 else d2con_get_vwtp (d2c)
) : int // end of [val]
//
var pck: pckind = pck
val (
) = if pck = PCKcon then (if flag_vwtp > 0 then pck := PCKlincon)
//
val () =
if flag_vwtp = 0 then
(
case+ pck of
| PCKfree () => let
    val (
    ) = prerr_error3_loc (loc0)
    val () = prerr_string ": pattern decoration ~(freeing) cannot be applied."
    val () = prerr_newline ((*void*))
  in
    the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))
  end // end of [PCKfree]
| PCKunfold () => let
    val (
    ) = prerr_error3_loc (loc0)
    val () = prerr_string ": pattern decoration ~(unfolding) cannot be applied."
    val () = prerr_newline ((*void*))
  in
    the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))
  end // end of [PCKunfold]
| _ => ((*void*))
) (* end of [if] *) // end of [val]
//
val p3t0 =
(
if flag = 0 then let
    val @(p2ts, s2es_arg, s2e_res) = p2at_trup_con (p2t0)
    val () = $SOL.s2exp_hypequal_solve (loc0, s2e_res, s2e)
    var serr: int = 0
    val p3ts_arg = p2atlst_trdn (loc0, p2ts_arg, s2es_arg, serr)
    val () = if serr != 0 then auxerr_arity (p2t0, serr)
    val p3t0 = p3at_con (loc0, s2e, pck, d2c, npf, p3ts_arg)
//
    val () = (
      case+ pck of
      | PCKcon () => ()
      | PCKlincon () => p3at_lincon_update (p3t0, d2c, p3ts_arg)
      | PCKfree () => p3at_free_update (p3t0, d2c, p3ts_arg)
      | PCKunfold () => p3at_unfold_update (p3t0, d2c, p3ts_arg)
    ) : void // end of [val]
//
  in
    p3t0
  end // end of [flag=0]
else if flag > 0 then let
    var serr: int = 0
    val p3ts_arg =
      p2atlst_trdn (loc0, p2ts_arg, s2es_arg_alt, serr)
    val () = if serr != 0 then auxerr_arity (p2t0, serr)
    val p3t0 = p3at_con (loc0, s2e, pck, d2c, npf, p3ts_arg)
    val () = p3at_unfold_update (p3t0, d2c, p3ts_arg)
  in
    p3t0
  end // end of [flag>0]
else p3at_errpat (loc0, s2e) // HX: error already registered
) : p3at // end of [val]
//
in
  p3t0
end // end of [p2at_trdn_con]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_patcon.dats] *)
