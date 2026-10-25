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
// HX-2026-10: no GC. Helpers shared by the pats_trans2_*.dats files
// (include this file after the staload of the arena and of [UN]).
//
(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"

(* ****** ****** *)

#include "./pats_trans1.hats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)
//
// HX: [val-list_cons (x, _) = xs] of ATS1 is the MatchError of an empty list
//
fn{a:t@ype}
glist_head_exn (xs: glist(a)): a =
  if glist_is_cons (xs) then glist_head<a> (xs) else $ERR.abort_interr<a> ((*MatchError*))
//
fun{a:t@ype}
glist_app_fun (xs: glist(a), f: a -> void): void =
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) => (f (x); glist_app_fun<a> (xs1, f))
  | ~GLnil () => ()
//
fun{a:t@ype}
glist_filter_loop
  (xs: glist(a), f: a -> bool, res: List0_vt(a)): List0_vt(a) =
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) =>
      if f (x)
        then glist_filter_loop<a> (xs1, f, list_vt_cons (x, res))
        else glist_filter_loop<a> (xs1, f, res)
  | ~GLnil () => list_vt_reverse (res)
//
// HX: [list_filter_fun] of ATS1 (the order is kept)
//
fun{a:t@ype}
glist_filter_fun
  (xs: glist(a), f: a -> bool): List0_vt(a) =
  glist_filter_loop<a> (xs, f, list_vt_nil ())
//
fun{a:t@ype}
glist_concat (xss: glist(glist(a))): glist(a) =
  case+ glist_view (xss) of
  | ~GLcons (xs, xss1) => glist_append<a> (xs, glist_concat<a> (xss1))
  | ~GLnil () => glist_nil{a} ()
//
fn{a:t@ype}
glist_tail_exn (xs: glist(a)): glist(a) =
  if glist_is_cons (xs) then glist_tail<a> (xs) else $ERR.abort_interr<glist(a)> ((*MatchError*))
//

(* ****** ****** *)

(* end of [pats_trans2.hats] *)
