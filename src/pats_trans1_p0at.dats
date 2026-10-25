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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_p0at.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"
#include "./pats_trans1.hats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"
staload LOC = "./pats_location.sats"
overload + with $LOC.location_combine

staload SYM = "./pats_symbol.sats"
macdef BACKSLASH = $SYM.symbol_BACKSLASH
macdef UNDERSCORE = $SYM.symbol_UNDERSCORE
overload = with $SYM.eq_symbol_symbol

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_p0at"

(* ****** ****** *)

staload "./pats_fixity.sats"
staload _(*anon*) = "./pats_fixity_fxty.dats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"
staload "./pats_trans1_env.sats"

(* ****** ****** *)

macdef
list_sing (x) = glist_sing (,(x))

(* ****** ****** *)
//
// HX: translation of patterns
//
typedef p1atitm = fxitm (p1at)
typedef p1atitmlst = glist (p1atitm)
//
(* ****** ****** *)

local

fn appf (
  env: ptr, _fun: p1at, _arg: p1at
) : p1atitm = let
  val loc_arg = _arg.p1at_loc ()
  val loc = _fun.p1at_loc () + loc_arg
  val p1t_app = (
    case+ p1at_node_view (_arg.p1at_node ()) of
    | ~P1Tlist (npf, p1ts) =>
        p1at_app_dyn (loc, _fun, loc_arg, npf, p1ts)
      // end of [P1Tlist]
    | ~P1Tsvararg s1a => begin
      case+ p1at_node_view (_fun.p1at_node ()) of
      | ~P1Tapp_sta (p1t1, s1as) => let
          val s1as = glist_append (s1as, list_sing (s1a))
        in
          p1at_app_sta (loc, p1t1, s1as)
        end // end of [P1Tapp_sta]
      | v => (
          p1at_node_view_free (v);
          p1at_app_sta (loc, _fun, list_sing (s1a))
        ) // end of [_]
      end // end of [P1Tsvararg]
    | v => let
        val () = p1at_node_view_free (v)
        val p1ts = list_sing (_arg) in
        p1at_app_dyn (loc, _fun, loc_arg, ~1(*npf*), p1ts)
      end (* end of [_] *)
  ) : p1at // end of [val]
in
  fxitm_FXITMatm<p1at> (p1t_app)
end // end of [appf]

in (* in-of-local *)

fn p1atitm_app
  (loc: location): p1atitm = fxitm_app<p1at> (loc, @(the_null_ptr, appf))
// end of [p1atitm_app]

end // end of [local]

fn p1at_get_loc (x: p1at): location = x.p1at_loc ()

fn p1at_make_app
  (loc: location, x: p1at, loc_arg: location, xs: p1atlst): p1at =
  p1at_app_dyn (loc, x, loc_arg, ~1(*npf*), xs)

fn p1at_make_opr (
  opr: p1at, f: fxty
) : p1atitm = begin
  fxopr_make<p1at> (
    p1at_get_loc, p1at_make_app, opr, f
  ) // end of [oper_make]
end // end of [p1at_make_opr]

fn p1atitm_backslash
  (loc_opr: location): p1atitm = begin
  fxopr_make_backslash<p1at> (
    p1at_get_loc, p1at_make_app, loc_opr
  ) // end of [oper_make_backslash]
end // end of [p1atitm_backslash]

(* ****** ****** *)
//
typedef env_exist = @(location, s1arglst)
//
fn
fopr_exist (env: ptr, body: p1at): p1atitm = let
  val e = trans1_env_get<env_exist> (env)
  val loc0 = e.0 and s1as = e.1
  val loc = loc0 + body.p1at_loc ()
in
  fxitm_FXITMatm<p1at> (p1at_exist(loc, s1as, body))
end // end of [f]
//
(* ****** ****** *)

local

fn p0at_tr_errmsg_opr
  (p0t0: p0at): p1at = let
  val loc0 = p0t0.p0at_loc ()
  val () = prerr_error1_loc (loc0)
  val () = prerr ": the operator needs to be applied."
  val () = prerr_newline ()
  val () = the_trans1errlst_add (trans1err_T1E_p0at_tr (p0t0))
in
  p1at_errpat (loc0)
end // end of [p0at_tr_errmsg_opr]

in (* in-of-local *)

implement
p0at_tr (p0t0) = let
//
fun
aux_item (
  p0t0: p0at
) : p1atitm = let
//
val loc0 = p0t0.p0at_loc ()
//
in
//
case+
p0at_node_view (p0t0.p0at_node ())
of (* case+ *)
//
| ~P0Tide(id) =>
  (
    if
    (id=UNDERSCORE)
    then fxitm_FXITMatm<p1at>(p1at_any(loc0))
    else
    (
      if
      (id=BACKSLASH)
      then p1atitm_backslash(loc0)
      else let
        val p1t = p1at_ide(loc0, id)
        val opt = the_fxtyenv_find(id)
      in
        case+ opt of
        | ~None_vt() => fxitm_FXITMatm<p1at>(p1t)
        | ~Some_vt(f) => p1at_make_opr(p1t, f)
      end // end of [else]
    )
  ) (* end of [P0Tide] *)
//
| ~P0Tdqid
    (dq, id) =>
    fxitm_FXITMatm<p1at>(p1at_dqid(loc0, dq, id))
  // (* end of [P0Tdqid] *)
//
| ~P0Topid(id) => fxitm_FXITMatm<p1at>(p1at_ide(loc0, id))
//
| ~P0Tint (x) => fxitm_FXITMatm<p1at> (p1at_i0nt (loc0, x))
| ~P0Tchar (x) => fxitm_FXITMatm<p1at> (p1at_c0har (loc0, x))
| ~P0Tfloat (x) => fxitm_FXITMatm<p1at> (p1at_f0loat (loc0, x))
| ~P0Tstring (x) => fxitm_FXITMatm<p1at> (p1at_s0tring (loc0, x))
//
| ~P0Tapp (_, _) => let
    val p1t_app =
    fixity_resolve<p1at> (
      loc0, p1at_get_loc, p1atitm_app(loc0), aux_itemlst p0t0
    ) (* end of [val] *)
  in
    fxitm_FXITMatm<p1at> (p1t_app)
  end // end of [P0Tapp]
//
| ~P0Tlist(npf, p0ts) => let
    val p1ts =
    p0atlst_tr p0ts in fxitm_FXITMatm<p1at>(p1at_list(loc0, npf, p1ts))
  end // end of [[P0Tlist]
//
| ~P0Tlst (lin, p0ts) => let
    val p1ts =
    p0atlst_tr(p0ts) in fxitm_FXITMatm<p1at>(p1at_lst(loc0, lin, p1ts))
  end // end of [P1Tlst]
| ~P0Ttup (knd, npf, p0ts) => let
    val p1ts =
    p0atlst_tr(p0ts) in fxitm_FXITMatm<p1at>(p1at_tup(loc0, knd, npf, p1ts))
  end // end of [P1Ttup]
| ~P0Trec (knd, npf, lp0ts) => let
    val lp1ts =
    labp0atlst_tr(lp0ts) in fxitm_FXITMatm<p1at>(p1at_rec(loc0, knd, npf, lp1ts))
  end // end of [P0Trec]
//
| ~P0Tfree(p0t) => fxitm_FXITMatm<p1at>(p1at_free(loc0, p0at_tr(p0t)))
| ~P0Tunfold(p0t) => fxitm_FXITMatm<p1at>(p1at_unfold(loc0, p0at_tr(p0t)))
//
| ~P0Trefas(id, loc_id, p0t) =>
    fxitm_FXITMatm<p1at>(p1at_refas(loc0, id, loc_id, p0at_tr p0t))
//
| ~P0Texist(s0as) => let
    val s1as = s0arglst_tr (s0as)
    val env = trans1_env_make<env_exist> (@(loc0, s1as))
  in
    fxitm_FXITMopr<p1at>(loc0, fxopr_FXOPRpre<p1at>(exist_prec_dyn, @(env, fopr_exist)))
  end // end of [P0Texist]
//
| ~P0Tsvararg(s0a) =>
    fxitm_FXITMatm<p1at>(p1at_svararg(loc0, s0vararg_tr(s0a)))
  // end of [P0Tsvararg]
//
| ~P0Tann(p0t, s0e) => let
    val p1t = p0at_tr(p0t)
    val s1e = s0exp_tr(s0e)
  in
    fxitm_FXITMatm<p1at>(p1at_ann(loc0, p1t, s1e))
  end // end of [P0Tann]
//
| ~P0Terr((*erroneous*)) => let
    val () = prerr_interror_loc(loc0)
    val () = fprint_string (stderr_ref, ": p0at_tr: p0t0 = ")
    val () = fprint_p0at (stderr_ref, p0t0)
    val () = fprint_newline (stderr_ref)
  in
    $ERR.abort_interr<p1atitm>((*reachable*))
  end // end of [P0Terr]
//
end (* end of [aux_item] *)
//
and
aux_itemlst
  (p0t0: p0at): p1atitmlst = let
  fun loop (
    p0t0: p0at, res: p1atitmlst
  ) : p1atitmlst =
    case+ p0at_node_view (p0t0.p0at_node ()) of
    | ~P0Tapp (p0t1, p0t2) => let
        val res = glist_cons (aux_item p0t2, res) in loop (p0t1, res)
      end // end of [P0Tapp]
    | v => (p0at_node_view_free (v); glist_cons (aux_item (p0t0), res))
  // end of [loop]
in
  loop (p0t0, glist_nil ())
end // end of [aux_itemlist]
//
in
//
case+ fxitm_view<p1at> (aux_item (p0t0)) of
| ~FXITMatm (p1t) => p1t
| ~FXITMopr _ => p0at_tr_errmsg_opr (p0t0)
//
end // end of [p0at_tr]

end // end of [local]

implement
labp0at_tr
  (lp0t) = let
//
val loc0 = lp0t.labp0at_loc ()
//
in
//
case+ labp0at_node_view (lp0t.labp0at_node ()) of
| ~LABP0ATnorm (l, p0t) =>
    labp1at_norm (loc0, l, p0at_tr (p0t))
  | ~LABP0ATomit ((*void*)) => labp1at_omit (loc0)
//
end // end of [labp0at_tr]

(* ****** ****** *)
//
implement
p0atlst_tr (xs) = glist_map_fun<p0at,p1at> (xs, p0at_tr)
//
implement
labp0atlst_tr (lxs) = glist_map_fun<labp0at,labp1at> (lxs, labp0at_tr)
//
(* ****** ****** *)

(* end of [pats_trans1_p0at.dats] *)
