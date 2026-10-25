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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_svvar.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload
CNTR = "./pats_counter.sats"
staload STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

val the_s2Var_name_counter = $CNTR.counter_make ()

(* ****** ****** *)

implement
s2Var_make_srt (loc, s2t) = let
//
val cnt =
$CNTR.counter_getinc (the_s2Var_name_counter)
//
val stamp = $STMP.s2Var_stamp_make ((*void*))
//
// HX: [s2Var_szexp] is initially S2ZEVar(itself)
//
val s2V =
s2Var_new (
  loc, cnt, s2t
, gopt_none () // link
, $UN.cast{s2zexp} (the_null_ptr) // szexp
, glist_nil () // sVarlst
, glist_nil () // lbs
, glist_nil () // ubs
, stamp
) (* end of [s2Var_new] *)
//
val () = set_s2Var_szexp (s2V, s2zexp_S2ZEVar (s2V))
//
in
  s2V
end // end of [s2Var_make_srt]

implement s2Var_make_var (loc, s2v) = let
//
val cnt = $CNTR.counter_getinc (the_s2Var_name_counter)
val stamp = $STMP.s2Var_stamp_make ()
val s2t = s2var_get_srt s2v
//
val s2V =
s2Var_new (
  loc, cnt, s2t
, gopt_none () // link
, $UN.cast{s2zexp} (the_null_ptr) // szexp
, glist_nil () // sVarlst
, glist_nil () // lbs
, glist_nil () // ubs
, stamp
) (* end of [s2Var_new] *)
//
val () = set_s2Var_szexp (s2V, s2zexp_S2ZEVar (s2V))
//
in
  s2V
end // end of [s2Var_make_var]

(* ****** ****** *)

implement
s2Var_get_cnt (s2V) = $effmask_all (s2Var_cnt (s2V))

implement
s2Var_get_srt (s2V) = $effmask_all (s2Var_srt (s2V))

implement
s2Var_get_link (s2V) = s2Var_link (s2V)
implement
s2Var_set_link (s2V, link) = set_s2Var_link (s2V, link)

implement
s2Var_get_szexp (s2V) = s2Var_szexp (s2V)
implement
s2Var_set_szexp (s2V, s2ze) = set_s2Var_szexp (s2V, s2ze)

implement
s2Var_get_sVarlst (s2V) = s2Var_sVarlst (s2V)
implement
s2Var_add_sVarlst (s2V, s2V2) =
  set_s2Var_sVarlst (s2V, glist_cons (s2V2, s2Var_sVarlst (s2V)))

implement
s2Var_get_lbs (s2V) = s2Var_lbs (s2V)
implement
s2Var_set_lbs (s2V, lbs) = set_s2Var_lbs (s2V, lbs)
implement
s2Var_get_ubs (s2V) = s2Var_ubs (s2V)
implement
s2Var_set_ubs (s2V, ubs) = set_s2Var_ubs (s2V, ubs)

implement
s2Var_get_stamp (s2V) = $effmask_all (s2Var_stamp (s2V))

(* ****** ****** *)

implement
s2Varlst_add_sVarlst
  (s2Vs, s2V2) = let
in
//
case+ glist_view (s2Vs) of
| ~GLnil () => ()
| ~GLcons
    (s2V, s2Vs) => let
    val () =
      s2Var_add_sVarlst (s2V, s2V2)
    // end of [val]
  in
    s2Varlst_add_sVarlst (s2Vs, s2V2)
  end // end of [list_cons]
//
end // end of [s2Varlst_add_sVarlst]

(* ****** ****** *)

implement
s2VarBound_make
  (loc, s2f) = s2VarBound_new (loc, s2f)
// end of [s2VarBound_make]

implement s2VarBound_get_loc (x) = s2VarBound_loc (x)
implement s2VarBound_get_val (x) = s2VarBound_val (x)

(* ****** ****** *)

implement
s2Var_lb_insert
  (loc, s2V, s2e) = let
//
fun
auxins
(
  loc: location, s2V: s2Var, s2e: s2exp
) : void = let
  val lb = s2VarBound_make(loc, s2e)
in
//
s2Var_set_lbs
  (s2V, glist_cons(lb, s2Var_get_lbs(s2V)))
//
end // end of [auxins]
//
in
//
case+
s2exp_node_view (s2exp_node (s2e))
of (* case+ *)
| ~S2EVar(s2V2) =>
  if (s2V = s2V2) then () else auxins(loc, s2V, s2e)
| v (*non-S2EVar*) => (s2exp_node_view_free (v); auxins(loc, s2V, s2e))
//
end // end of [s2Var_lb_insert]

implement
s2Var_ub_insert
  (loc, s2V, s2e) = let
//
fun
auxins
(
  loc: location, s2V: s2Var, s2e: s2exp
) : void = let
  val ub = s2VarBound_make(loc, s2e)
in
//
s2Var_set_ubs
  (s2V, glist_cons(ub, s2Var_get_ubs(s2V)))
//
end // end of [auxins]
//
in
//
case+
s2exp_node_view (s2exp_node (s2e))
of (* case+ *)
| ~S2EVar(s2V2) =>
  if (s2V = s2V2) then () else auxins(loc, s2V, s2e)
| v (*non-S2EVar*) => (s2exp_node_view_free (v); auxins(loc, s2V, s2e))
//
end // end of [s2Var_ub_insert]

(* ****** ****** *)
//
implement
lt_s2Var_s2Var(x1, x2) = (compare_s2Var_s2Var (x1, x2) < 0)
implement
lte_s2Var_s2Var(x1, x2) = (compare_s2Var_s2Var (x1, x2) <= 0)
//
implement
eq_s2Var_s2Var(x1, x2) = (compare_s2Var_s2Var (x1, x2) = 0)
implement
neq_s2Var_s2Var(x1, x2) = (compare_s2Var_s2Var (x1, x2) != 0)
//
implement
compare_s2Var_s2Var (x1, x2) =
  $effmask_all (compare (s2Var_get_stamp (x1), s2Var_get_stamp (x2)))
// end of [compare_s2Var_s2Var]
//
(* ****** ****** *)

implement
fprint_s2Var (out, s2V) = let
  val () = $CNTR.fprint_count (out, s2Var_get_cnt s2V)
in
  // empty
end // end of [fprint_s2Var]

implement
print_s2Var (s2V) = fprint_s2Var (stdout_ref, s2V)
implement
prerr_s2Var (s2V) = fprint_s2Var (stderr_ref, s2V)

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_s2Var_s2Var ($UN.cast{s2Var} (x1), $UN.cast{s2Var} (x2))
//
fn
ins (xs: avlmap, x: s2Var): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
//
in (* in of [local] *)

implement
s2Varset_nil () = $UN.cast{s2Varset} (avlmap_nil ())

implement
s2Varset_add
  (xs, x) = $UN.cast{s2Varset} (ins ($UN.cast{avlmap} (xs), x))
// end of [s2Varset_add]

implement
s2Varset_ismem
  (xs, x) = avlmap_ismem ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), cmp)
// end of [s2Varset_is_member]

implement
s2Varset_listize (xs) =
  $UN.castvwtp0{List0_vt(s2Var)} (avlmap_keys ($UN.cast{avlmap} (xs)))

(* ****** ****** *)

implement
s2Varset_vt_nil () = $UN.castvwtp0{s2Varset_vt} (avlmap_nil ())

implement
s2Varset_vt_add
  (xs, x) = $UN.castvwtp0{s2Varset_vt} (ins ($UN.castvwtp0{avlmap} (xs), x))
// end of [s2Varset_vt_add]

implement
s2Varset_vt_ismem
  (xs, x) = $effmask_all (
  avlmap_ismem ($UN.castvwtp1{avlmap} (xs), $UN.cast{ptr} (x), cmp)
) // end of [s2Varset_vt_ismem]

implement
s2Varset_vt_free(xs) = let
  val _ = $UN.castvwtp0{avlmap} (xs) in (*nothing: the memory of the arena is never freed*)
end // end of [s2Varset_vt_free]

implement
s2Varset_vt_listize_free
  (xs) = $UN.castvwtp0{List0_vt(s2Var)} (avlmap_keys ($UN.castvwtp0{avlmap} (xs)))
// end of [s2Varset_vt_listize_free]

end // end of [local]

(* ****** ****** *)

implement
print_s2Varlst (xs) = fprint_s2Varlst (stdout_ref, xs)
implement
prerr_s2Varlst (xs) = fprint_s2Varlst (stderr_ref, xs)

implement
fprint_s2Varlst
  (out, xs) = $UT.fprintlst<s2Var> (out, xs, ", ", fprint_s2Var)
// end of [fprint_s2Varlst]

(* ****** ****** *)

implement
print_s2Varset (xs) = fprint_s2Varset (stdout_ref, xs)
implement
prerr_s2Varset (xs) = fprint_s2Varset (stderr_ref, xs)

implement
fprint_s2Varset
  (out, xs) = () where {
  val xs = $UN.castvwtp0{List0_vt(s2Var)} (s2Varset_listize (xs))
  val () = fprint_string (out, "[")
  val () = fprint_s2Varlst (out, l2l (xs))
  val () = fprint_string (out, "]")
} // end of [fprint_s2Varset]

(* ****** ****** *)

(* end of [pats_staexp2_svvar.dats] *)
