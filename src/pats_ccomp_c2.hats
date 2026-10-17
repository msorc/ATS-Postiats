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
// HX-2026-10: no GC
//
// Helpers shared by pats_ccomp_{dynexp,decl,claulst}.dats (group C2, see
// PORTING.md, "ccomp group C2"). The ATS1 loops built a [list_vt] in place
// and converted it with [list_of_list_vt]; here the elements are consed on a
// [List0_vt] accumulator (the order of the calls is the one of ATS1) and
// [glist_ofrev_vt] turns it, last element first, into a [glist] with one
// arena cell per element.
//
(* ****** ****** *)

fun{a:t@ype}
glist_ofrev_vt
  (xs: List0_vt(a), res: glist(a)): glist(a) =
(
//
case+ xs of
| ~list_vt_nil() => res
| ~list_vt_cons(x, xs) => glist_ofrev_vt<a>(xs, glist_cons<a>(x, res))
//
) (* end of [glist_ofrev_vt] *)

(* ****** ****** *)

(* end of [pats_ccomp_c2.hats] *)
