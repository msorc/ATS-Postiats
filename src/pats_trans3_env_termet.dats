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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_termet.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The stack of metrics is two parallel [glist]s in cells: the sets of stamps (a linear [stampset_vt] kept as a [ptr])
// and the metrics.
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

staload "./pats_stamp.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_stacst2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

fun
check_termet_loop (
  loc0: loc_t, s2es: s2explst
) : void = let
in
//
case+ glist_view (s2es) of
| ~GLcons
    (s2e, s2es) => let
    val isint = s2rt_is_int (s2e.s2exp_srt ())
    val () = if isint then
      trans3_env_add_cnstr (c3nstr_termet_isnat (loc0, s2e))
    // end of [val]
  in
    check_termet_loop (loc0, s2es)
  end // end of [list_cons]
| ~GLnil () => () // end of [list_nil]
//
end (* end of [check_termet_loop] *)

implement
s2explst_check_termet
  (loc0, s2es_met) = check_termet_loop (loc0, s2es_met)
// end of [s2explst_check_termet]

(* ****** ****** *)

local
//
val the_metstamps = gcell_make<glist(ptr)> (glist_nil ())
val the_metbinds = gcell_make<glist(s2explst)> (glist_nil ())
//
in // in of [local]

implement
termetenv_pop
  ((*none*)) = let
//
val xs = gcell_get<glist(ptr)> (the_metstamps)
val ys = gcell_get<glist(s2explst)> (the_metbinds)
//
val xs1 = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) => let
      val () = stampset_vt_free ($UN.castvwtp0{stampset_vt} (x)) in xs1
    end
  | ~GLnil () => glist_nil ()
) : glist(ptr)
val ys1 = (
  case+ glist_view (ys) of
  | ~GLcons (_, ys1) => ys1
  | ~GLnil () => glist_nil ()
) : glist(s2explst)
//
val () = gcell_set<glist(ptr)> (the_metstamps, xs1)
val () = gcell_set<glist(s2explst)> (the_metbinds, ys1)
//
in
  (*nothing*)
end // end of [termetenv_pop]

implement
termetenv_push
  (d2vs, s2es_met) = let
//
val xs = gcell_get<glist(ptr)> (the_metstamps)
val ys = gcell_get<glist(s2explst)> (the_metbinds)
val () = gcell_set<glist(ptr)> (the_metstamps, glist_cons ($UN.castvwtp0{ptr} (d2vs), xs))
val () = gcell_set<glist(s2explst)> (the_metbinds, glist_cons (s2es_met, ys))
//
in
  // nothing
end // end of [termetenv_push]

fun
push_dvarlst_loop
  (res: stampset_vt, d2vs: d2varlst): stampset_vt =
  case+ glist_view (d2vs) of
  | ~GLcons (d2v, d2vs) =>
      push_dvarlst_loop (stampset_vt_add (res, d2var_get_stamp (d2v)), d2vs)
  | ~GLnil () => res
// end of [push_dvarlst_loop]

implement
termetenv_push_dvarlst
  (d2vs, s2es_met) = let
  val res = stampset_vt_nil ()
  val res = push_dvarlst_loop (res, d2vs)
in
  termetenv_push (res, s2es_met)
end // end of [termetenv_push_dvarlst]

fn
stampset_ismem (x: ptr, st: stamp): bool = let
  val s = $UN.castvwtp0{stampset_vt} (x)
  val ans = stampset_vt_is_member (s, st)
  val _ = $UN.castvwtp0{ptr} (s)
in
  ans
end // end of [stampset_ismem]

fun
get_termet_loop
  (xs: glist(ptr), ys: glist(s2explst), d2v: stamp): Option_vt (s2explst) = let
in
//
case+ glist_view (xs) of
| ~GLcons (x, xs) => let
    val-~GLcons (y, ys) = glist_view (ys)
    val ismem = stampset_ismem (x, d2v)
  in
    if ismem then Some_vt (y) else get_termet_loop (xs, ys, d2v)
  end // end of [list_vt_cons]
| ~GLnil () => None_vt ()
//
end // end of [get_termet_loop]

implement
termetenv_get_termet
  (d2v) = get_termet_loop (
  gcell_get<glist(ptr)> (the_metstamps), gcell_get<glist(s2explst)> (the_metbinds), d2v
) // end of [termetenv_get_termet]

end // end of [local]

implement
s2exp_termet_instantiate
  (loc0, stamp, met) = let
//
val ans = termetenv_get_termet (stamp)
//
in
//
case+ ans of
| ~Some_vt (met_bound) => let
    val c3t = c3nstr_termet_isdec (loc0, met, met_bound)
  in
    trans3_env_add_cnstr (c3t)
  end // end of [Some_vt]
| ~None_vt () => let
    val s2p = s2exp_bool (false)
  in
    trans3_env_add_prop (loc0, s2p)
  end // end of [None_vt]
//
end // end of [s2exp_termet_instantiate]

(* ****** ****** *)

fun
metfun_srtlst (s2es: s2explst): s2rtlst =
  case+ glist_view (s2es) of
  | ~GLcons (s2e, s2es) => let
      val s2t = s2e.s2exp_srt ()
    in
      glist_cons (s2t, metfun_srtlst (s2es))
    end
  | ~GLnil () => glist_nil ()
// end of [metfun_srtlst]

fun
metfun_aux (
  s2e0: s2exp
, d2v0: d2var
, s2ts0: &s2rtlst >> _
) : Option_vt s2exp = let
  val s2f0 = s2exp2hnf (s2e0)
  val s2e0 = s2hnf2exp (s2f0)
in
//
case+ s2exp_node_view (s2e0.s2exp_node ()) of
| ~S2Efun (
    fc, lin, s2fe, npf, s2es, s2e
  ) => let
    val ans = metfun_aux (s2e, d2v0, s2ts0)
  in
    case ans of
    | ~Some_vt (s2e) => Some_vt (
        s2exp_fun_srt (s2e0.s2exp_srt (), fc, lin, s2fe, npf, s2es, s2e)
      ) // end of [Some_vt]
    | ~None_vt () => None_vt ()
  end // end of [S2Efun]
| ~S2Emetfun (
    _(*stampopt*), s2es, s2e
  ) => let
    val stamp = d2var_get_stamp (d2v0)
    val () = s2ts0 := metfun_srtlst (s2es)
  in
    Some_vt (s2exp_metfun (gopt_some (stamp), s2es, s2e))
  end // end of [S2Emetfun]
| ~S2Euni (
    s2vs, s2ps, s2e
  ) => let
    val ans = metfun_aux (s2e, d2v0, s2ts0)
  in
    case+ ans of
    | ~Some_vt s2e => Some_vt (s2exp_uni (s2vs, s2ps, s2e))
    | ~None_vt () => None_vt ()
  end // end of [S2Euni]
| v => (s2exp_node_view_free (v); None_vt ())
//
end // end of [metfun_aux]

implement
s2exp_metfun_load
  (s2e0, d2v0) = let
//
var s2ts: s2rtlst = glist_nil ()
//
in
//
case+ metfun_aux (s2e0, d2v0, s2ts) of
| ~Some_vt s2e => Some_vt @(s2e, s2ts) | ~None_vt () => None_vt ()
//
end // end of [s2exp_metfun_load]

(* ****** ****** *)

(* end of [pats_trans3_env_termet.dats] *)
