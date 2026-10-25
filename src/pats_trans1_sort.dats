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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_sort.dats).
// The closures given to the fixity resolution have no free variable
// (or only a location, kept in the [env] word): plain functions.
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
staload LOC = "./pats_location.sats"
overload + with $LOC.location_combine

staload SYM = "./pats_symbol.sats"
macdef BACKSLASH = $SYM.symbol_BACKSLASH
overload = with $SYM.eq_symbol_symbol

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_sort"

(* ****** ****** *)

staload "./pats_fixity.sats"
staload _(*anon*) = "./pats_fixity_fxty.dats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"
staload "./pats_trans1_env.sats"

(* ****** ****** *)
//
// HX: translation of sorts
//
typedef s1rtitm = fxitm (s1rt)
typedef s1rtitmlst = glist (s1rtitm)

(* ****** ****** *)

local

fn appf (
  env: ptr, _fun: s1rt, _arg: s1rt
) : s1rtitm = let
  val loc = _fun.s1rt_loc () + _arg.s1rt_loc ()
  val xs_arg = (
    case+ s1rt_node_view (_arg.s1rt_node ()) of
    | ~S1RTlist s1ts => s1ts
    | v => (s1rt_node_view_free (v); glist_sing (_arg))
  ) : s1rtlst // end of [val]
  val s1t_app = s1rt_app (loc, _fun, xs_arg)
in
  fxitm_FXITMatm<s1rt> (s1t_app)
end // end of [appf]

in // in of [local]

fn s1rtitm_app
  (loc: location): s1rtitm = fxitm_app<s1rt> (loc, @(the_null_ptr, appf))
// end of [s1rtitm_app]

end // end of [local]

(* ****** ****** *)

fn s1rt_get_loc (x: s1rt): location = x.s1rt_loc ()

fn s1rt_make_app
  (loc: location, x: s1rt, _: location, xs: s1rtlst): s1rt = s1rt_app (loc, x, xs)

fn s1rt_make_opr (
  opr: s1rt, f: fxty
) : s1rtitm = begin
  fxopr_make<s1rt> (
    s1rt_get_loc, s1rt_make_app, opr, f
  ) // end of [oper_make]
end // end of [s1rt_make_opr]

fn s1rtitm_backslash
  (loc_opr: location): s1rtitm = begin
  fxopr_make_backslash<s1rt> (
    s1rt_get_loc, s1rt_make_app, loc_opr
  ) // end of [oper_make_backslash]
end // end of [s1rtitm_backslash]

(* ****** ****** *)

local

fn s0rt_tr_errmsg_opr
  (s0t0: s0rt): s1rt = let
  val loc0 = s0t0.s0rt_loc ()
  val () = prerr_error1_loc (loc0)
  val () = prerr ": the operator needs to be applied."
  val () = prerr_newline ()
  val () = the_trans1errlst_add (trans1err_T1E_s0rt_tr (s0t0))
in
  s1rt_err (loc0)
end // end of [s0rt_tr_errmsg_opr]

in // in of [local]

implement s0rt_tr (s0t0) = let
//
fun aux_item
  (s0t0: s0rt): s1rtitm = let
  val loc0 = s0t0.s0rt_loc () in case+ s0rt_node_view (s0t0.s0rt_node ()) of
  | ~S0RTapp (_, _) => let
      val s1t0 = fixity_resolve<s1rt> (
        loc0, s1rt_get_loc, s1rtitm_app (loc0), aux_itemlst (s0t0)
      ) // end of [val]
    in
      fxitm_FXITMatm<s1rt> (s1t0)
    end // end of [S0RTapp]
  | ~S0RTide id =>
      if id = BACKSLASH then s1rtitm_backslash (loc0)
      else begin case+ the_fxtyenv_find id of
        | ~Some_vt f => s1rt_make_opr (s1rt_ide (loc0, id), f)
        | ~None_vt () => fxitm_FXITMatm<s1rt> (s1rt_ide (loc0, id))
      end // end of [S0RTide]
  | ~S0RTlist xs => fxitm_FXITMatm<s1rt> (s1rt_list (loc0, s0rtlst_tr xs))
  | ~S0RTqid (q, id) => fxitm_FXITMatm<s1rt> (s1rt_qid (loc0, q, id))
  | ~S0RTtype knd => fxitm_FXITMatm<s1rt> (s1rt_type (loc0, knd))
end // end of [aux_item]
//
and aux_itemlst
  (s0t0: s0rt): s1rtitmlst = let
  fun loop (
    s0t0: s0rt, res: s1rtitmlst
  ) : s1rtitmlst =
    case+ s0rt_node_view (s0t0.s0rt_node ()) of
    | ~S0RTapp (s0t1, s0t2) => let
        val res = glist_cons (aux_item s0t2, res) in loop (s0t1, res)
      end // end of [S0RTapp]
    | v => (s0rt_node_view_free (v); glist_cons (aux_item s0t0, res)) // end of [_]
  // end of [loop]
in
  loop (s0t0, glist_nil ())
end // end of [aux_itemlst]
//
in
//
case+ fxitm_view<s1rt> (aux_item s0t0) of
| ~FXITMatm (s1t) => s1t
| ~FXITMopr (loc, _) => s0rt_tr_errmsg_opr (s0t0)
// end of [case]
end // end of [s0rt_tr]

end // end of [local]

(* ****** ****** *)

implement
s0rtlst_tr (s0ts) = glist_map_fun<s0rt,s1rt> (s0ts, s0rt_tr)

implement
s0rtopt_tr (s0topt) =
  case+ gopt_view (s0topt) of
  | ~GOsome s0t => gopt_some (s0rt_tr s0t) | ~GOnone () => gopt_none ()
// end of [s0rtopt_tr]

(* ****** ****** *)

implement a0srt_tr (x) =
  a1srt_make (x.a0srt_loc (), x.a0srt_sym (), s0rt_tr (x.a0srt_srt ()))
// end of [a0srt_tr]

implement
a0msrt_tr (x) = let
  val arg = glist_map_fun<a0srt,a1srt> (x.a0msrt_arg (), a0srt_tr)
in
  a1msrt_make (x.a0msrt_loc (), arg)
end // end of [a0msrt_tr]

implement a0msrtlst_tr (xs) = glist_map_fun<a0msrt,a1msrt> (xs, a0msrt_tr)

(* ****** ****** *)

local

fn d0atsrtcon_tr
  (x: d0atsrtcon): d1atsrtcon = let
  val loc = x.d0atsrtcon_loc () and nam = x.d0atsrtcon_sym ()
  val s1ts = (
    case+ gopt_view (x.d0atsrtcon_arg ()) of
    | ~GOsome s0t => let
        val s1t = s0rt_tr s0t in
        case+ s1rt_node_view (s1t.s1rt_node ()) of
        | ~S1RTlist s1ts => s1ts
        | v => (s1rt_node_view_free (v); glist_cons (s1t, glist_nil ()))
      end // end of [Some]
    | ~GOnone () => glist_nil ()
  ) : s1rtlst // end of [val]
in
  d1atsrtcon_make (loc, nam, s1ts)
end // end of [d0atsrtcon_tr]

fn d0atsrtconlst_tr
  (xs: d0atsrtconlst): d1atsrtconlst =
  glist_map_fun<d0atsrtcon,d1atsrtcon> (xs, d0atsrtcon_tr)

in // in of [local]

implement
d0atsrtdec_tr (d) = let
  val loc = d.d0atsrtdec_loc ()
  val name = d.d0atsrtdec_sym ()
  val conlst = d0atsrtconlst_tr (d.d0atsrtdec_con ())
in
  d1atsrtdec_make (loc, name, conlst)
end // end of [d0atsrtdec_tr]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans1_sort.dats] *)
