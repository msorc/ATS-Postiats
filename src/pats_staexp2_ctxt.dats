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
// Start Time: May, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_ctxt.dats, see PORTING.md)
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
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

implement
s2ctxt_make (s2e, s2h) = s2ctxt_new (s2e, s2h)

(* ****** ****** *)

extern
fun
s2exp_hrepl_flag
  (s2e0: s2exp, repl: s2exp, flag: &int): s2exp
// end of [s2exp_hrepl_flag]
extern
fun
labs2explst_hrepl_flag
  (ls2es: labs2explst, repl: s2exp, flag: &int): labs2explst
// end of [labs2explst_hrepl_flag]

implement
s2exp_hrepl_flag
(
  s2e0, repl, flag
) = let
in
//
case+
s2exp_node_view (s2exp_node (s2e0)) of
//
| ~S2Ehole _ => let
    val () = flag := flag + 1 in repl
  end // end of [S2Ehole]
//
| ~S2Eat (s2e, s2a) => let
    val flag0 = flag
    val s2e = s2exp_hrepl_flag (s2e, repl, flag)
  in
    if flag > flag0 then s2exp_at (s2e, s2a) else s2e0
  end // end of [S2Eat]
| ~S2Etyrec (knd, npf, ls2es) => let
    val flag0 = flag
    val ls2es =
      labs2explst_hrepl_flag (ls2es, repl, flag)
    // end of [val]
  in
    if flag > flag0 then let
      val s2t = (
      if s2exp_is_lin(repl)
        then s2rt_linearize(s2exp_srt (s2e0)) else s2exp_srt (s2e0)
      ) : s2rt // end of [val]
    in
      s2exp_tyrec_srt (s2t, knd, npf, ls2es)
    end else s2e0 // end of [if]
  end // end of [S2Etyrec]
//
| v (* rest-of-s2exp*) => (s2exp_node_view_free (v); s2e0)
//
end // end of [s2exp_hrepl_flag]

implement
labs2explst_hrepl_flag
  (ls2es0, repl, flag) = let
in
//
case+ glist_view (ls2es0) of
| ~GLcons (ls2e, ls2es) => let
    val flag0 = flag
    val l = labs2exp_lab (ls2e)
    val name = labs2exp_nam (ls2e)
    val s2e = labs2exp_elt (ls2e)
    val s2e = s2exp_hrepl_flag (s2e, repl, flag)
  in
    if flag > flag0 then let
      val ls2e = labs2exp_new (l, name, s2e)
    in
      glist_cons (ls2e, ls2es)
    end else let
      val ls2es = labs2explst_hrepl_flag (ls2es, repl, flag)
    in
      if flag > flag0 then glist_cons (ls2e, ls2es) else ls2es0
    end (* end of [if] *)
  end // end of [list_cons]
| ~GLnil () => glist_nil ()
//
end // end of [labs2explst_hrepl_flag]

(* ****** ****** *)

implement
s2exp_hrepl
  (s2e, repl) = let
  var flag: int = 0
in
  s2exp_hrepl_flag (s2e, repl, flag)
end // end of [s2exp_hrepl]

(* ****** ****** *)

implement
s2ctxt_hrepl
  (ctxt, repl) = let
  var flag: int = 0
  val s2e_ctx = s2ctxt_exp (ctxt)
  val s2h = s2ctxt_hole (ctxt)
  val s2e = s2exp_hrepl_flag (s2e_ctx, repl, flag)
in
  s2e
end // end of [s2ctxt_hrepl]

implement
s2ctxtopt_hrepl
  (opt, repl) = (
  case+ gopt_view (opt) of
  | ~GOsome ctxt =>
      gopt_some (s2ctxt_hrepl (ctxt, repl))
  | ~GOnone () => gopt_none ()
) // end of [s2ctxtopt_hrepl]

(* ****** ****** *)

(* end of [pats_staexp2_ctxt.dats] *)
