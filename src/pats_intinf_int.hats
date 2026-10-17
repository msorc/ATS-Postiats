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
// Authoremail: gmhwxiATgmailDOTcom
// Start Time: May, 2014
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_intinf.sats"

(* ****** ****** *)
//
// HX: an intinf is a [llint] stored in the global arena
//
assume intinf_type = ptr

(* ****** ****** *)
//
fn
INTINF (i: llint):<> intinf = $effmask_all let
  val p = the_garena_alloc (sizeof<llint>)
  val () = arena_store<llint> (p, i)
in
  $UN.cast{intinf}(p)
end // end of [INTINF]
//
fn un
(
  intinf: intinf
) :<> llint = $effmask_all (arena_load<llint> ($UN.cast{ptr}(intinf)))
//
(* ****** ****** *)

implement
intinf_make_int (i) = INTINF ($UN.cast{llint}(i))
implement
intinf_make_size (sz) = INTINF ($UN.cast{llint}(sz))

(* ****** ****** *)
//
(*
** HX: [rep] is unsigned!
*)
implement
intinf_make_string (rep) = let
  val i = $UT.llint_make_string (rep) in INTINF (i)
end // end of [intinf_make_string]
//
(* ****** ****** *)

local

extern
fun
strtoll_c
  (nptr: string, endptr: ptr, base: int): llint = "mac#strtoll"

in (* in-of-local *)

implement
intinf_make_base_string_ofs
  (base, rep, ofs) = let
//
  val rep_ofs =
    $UN.cast{string}(ptr0_add_guint<char>($UN.cast{ptr}(rep), i2sz(ofs)))
//
val x = strtoll_c (rep_ofs, the_null_ptr, base)
//
in
  INTINF (x)
end // end of [intinf_make_base_string_ofs]

end // end of [local]

(* ****** ****** *)

implement
fprint_intinf (out, x) = fprint_llint (out, un(x))

(* ****** ****** *)

implement intinf_get_int (x) = $UN.cast{int}(un(x))

(* ****** ****** *)

implement
lt_intinf_int (x1, x2) = compare_intinf_int (x1, x2) < 0
implement
lte_intinf_int (x1, x2) = compare_intinf_int (x1, x2) <= 0
implement
gt_intinf_int (x1, x2) = compare_intinf_int (x1, x2) > 0
implement
gte_intinf_int (x1, x2) = compare_intinf_int (x1, x2) >= 0

(* ****** ****** *)

implement
eq_intinf_int (x1, x2) = compare_intinf_int (x1, x2) = 0
implement
eq_int_intinf (x1, x2) = compare_intinf_int (x2, x1) = 0
implement
eq_intinf_intinf (x1, x2) = compare_intinf_intinf (x1, x2) = 0

(* ****** ****** *)

implement
neq_intinf_int (x1, x2) = compare_intinf_int (x1, x2) != 0
implement
neq_int_intinf (x1, x2) = compare_intinf_int (x2, x1) != 0
implement
neq_intinf_intinf (x1, x2) = compare_intinf_intinf (x1, x2) != 0

(* ****** ****** *)
//
implement
compare_intinf_int
  (x1, x2) = let
  val i1 = un (x1)
  val i2 = g0int2int_int_llint (x2)
in
  compare (i1, i2)
end // end of [compare_intinf_int]
//
implement
compare_intinf_intinf
  (x1, x2) = compare (un(x1), un(x2))
//
(* ****** ****** *)
//
implement neg_intinf (x) = INTINF (~(un(x)))
//
(* ****** ****** *)
//
implement
add_intinf_int
  (x1, x2) = INTINF (un(x1) + g0int2int_int_llint (x2))
implement
add_int_intinf
  (x1, x2) = INTINF (g0int2int_int_llint (x1) + un(x2))
//
implement
add_intinf_intinf (x1, x2) = INTINF (un(x1) + un(x2))
//
(* ****** ****** *)

implement
sub_intinf_intinf (x1, x2) = INTINF (un(x1) - un(x2))

(* ****** ****** *)
//
implement
mul_intinf_int
  (x1, x2) = INTINF (un(x1) * g0int2int_int_llint (x2))
implement
mul_int_intinf
  (x1, x2) = INTINF (g0int2int_int_llint (x1) * un(x2))
//
implement
mul_intinf_intinf (x1, x2) = INTINF (un(x1) * un(x2))
//
(* ****** ****** *)

local
//
// HX: an intinfset is a list in DESCENDING order (and duplicate-free), like [funset_listord] of ATS1:
// [intinfset_listize] (and [fprint_intinfset]) give the largest element first
//
assume intinfset_type = glist(intinf)
//
in (*in-of-local*)

implement
intinfset_sing (x) = glist_sing (x)

implement
intinfset_is_member
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => false
| ~GLcons (x1, xs1) => let
    val sgn = compare_intinf_intinf (x1, x)
  in
    if sgn > 0
      then intinfset_is_member (xs1, x) else (sgn = 0)
    // end of [if]
  end (* end of [GLcons] *)
//
) (* end of [intinfset_is_member] *)

implement
intinfset_add
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => glist_sing (x)
| ~GLcons (x1, xs1) => let
    val sgn = compare_intinf_intinf (x1, x)
  in
    if sgn > 0
      then glist_cons (x1, intinfset_add (xs1, x))
      else (if sgn = 0 then xs else glist_cons (x, xs))
    // end of [if]
  end (* end of [GLcons] *)
//
) (* end of [intinfset_add] *)

implement
intinfset_listize (xs) = glist_listize (xs)

end // end of [local]

(* ****** ****** *)

implement
fprint_intinfset
  (out, xs) = $UT.fprintlst<intinf>
  (out, $UN.cast{glist(intinf)}(xs), ", ", fprint_intinf)
// end of [fprint_intinfset]

(* ****** ****** *)

(* end of [pats_intinf_int.hats] *)
