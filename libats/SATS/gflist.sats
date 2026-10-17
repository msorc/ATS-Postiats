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
// Authoremail: gmmhwxiATgmailDOTcom
// Time: October, 2010
//
(* ****** ****** *)
//
// HX: generic lists (fully indexed)
//
(* ****** ****** *)
//
// HX-2012-11-27:
// ported to ATS/Postiats from ATS/Anairiats
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// the nonlinear [gflist] is removed;
// only the linear [gflist_vt] remains
//
(* ****** ****** *)

#define
ATS_PACKNAME "ATSLIB.libats.gflist"

(* ****** ****** *)

staload "libats/SATS/ilist_prf.sats" // for intseqs

(* ****** ****** *)

datavtype
gflist_vt (
  a:vt@ype+, ilist(*ind*)
) =
  | gflist_vt_nil
      (a, ilist_nil) of ()
    // end of [gflis_vt_nil]
  | {x:int}
    {xs:ilist}
    gflist_vt_cons
      (a, ilist_cons (x, xs)) of (stamped_vt (a, x), gflist_vt (a, xs))
    // end of [gflist_vt_cons]
// end of [gflist_vt]

(* ****** ****** *)
//
#define
gflist_vt_sing(x) gflist_vt_cons(x, gflist_vt_nil())
//
(* ****** ****** *)

castfn
gflist2list_vt
  {a:vt@ype}{xs:ilist}
(
  gflist_vt(INV(a), xs)
) :<> [n:nat] (LENGTH (xs, n) | list_vt (a, n))
// end of [gflist2list_vt]

castfn
list2gflist_vt
  {a:vt@ype}{n:int}
(
  xs: list_vt(INV(a), n)
) :<> [xs:ilist] (LENGTH(xs, n) | gflist_vt (a, xs))
// end of [list2gflist_vt]

(* ****** ****** *)

(* end of [gflist.sats] *)
