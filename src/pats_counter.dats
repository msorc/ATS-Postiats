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
#include "share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload "./pats_counter.sats"

(* ****** ****** *)

assume count_t0ype = int
//
// HX: a counter is a cell in the global arena (never freed)
//
assume counter_type = ptr

(* ****** ****** *)

implement count_get_int (x) = x

(* ****** ****** *)

implement
lt_count_count (x1, x2) = g0int_lt_int (x1, x2)
implement
lte_count_count (x1, x2) = g0int_lte_int (x1, x2)

implement
gt_count_count (x1, x2) = g0int_gt_int (x1, x2)
implement
gte_count_count (x1, x2) = g0int_gte_int (x1, x2)

implement
eq_count_count (x1, x2) = g0int_eq_int (x1, x2)
implement
neq_count_count (x1, x2) = g0int_neq_int (x1, x2)

implement
compare_count_count (x1, x2) =
  if g0int_lt_int (x1, x2) then ~1 else (if g0int_gt_int (x1, x2) then 1 else 0)

(* ****** ****** *)

implement
fprint_count (out, x) = fprint_int (out, x)

(* ****** ****** *)

local

fn
strptr2gstring
  (str: Strptr1): string = let
  val res = the_garena_strdup ($UN.castvwtp1{string}(str))
  val ((*freed*)) = strptr_free (str)
in
  res
end // end of [strptr2gstring]

in (* in-of-local *)

implement
tostring_count (cnt) = strptr2gstring (tostrptr_int (cnt))

implement
tostring_prefix_count (pre, cnt) = let
  val str = tostrptr_int (cnt)
  val res =
    string0_append (pre, $UN.castvwtp1{string}(str))
  val ((*freed*)) = strptr_free (str)
in
  strptr2gstring (res)
end // end of [tostring_prefix_count]

end // end of [local]

(* ****** ****** *)
//
implement
counter_make () = let
  val p = the_garena_alloc (sizeof<count>)
  val () = $UN.ptr0_set<count> (p, 0)
in
  $UN.cast{counter}(p)
end // end of [counter_make]
//
implement
counter_inc (cntr) = let
  val p = $UN.cast{ptr}(cntr) in $UN.ptr0_set<count> (p, $UN.ptr0_get<count> (p) + 1)
end // end of [counter_inc]
implement counter_get (cntr) = $UN.ptr0_get<count> ($UN.cast{ptr}(cntr))
implement counter_set (cntr, cnt) = $UN.ptr0_set<count> ($UN.cast{ptr}(cntr), cnt)
implement counter_reset (cntr) = $UN.ptr0_set<count> ($UN.cast{ptr}(cntr), 0)
//
implement
counter_getinc
  (cntr) = n where {
  val n = counter_get (cntr) ; val () = counter_set (cntr, n + 1)
} // end of [counter_getinc]
//
implement
counter_incget
  (cntr) = n1 where {
  val n1 = counter_get (cntr) + 1; val () = counter_set (cntr, n1)
} // end of [counter_incget]
//
(* ****** ****** *)

(* end of [pats_counter.dats] *)
