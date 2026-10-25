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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_svar.dats, see PORTING.md)
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
//
staload
CNTR = "./pats_counter.sats"
//
staload SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
//
staload STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp
//
(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

val the_s2var_name_counter = $CNTR.counter_make ()

fn s2var_name_make
  (): symbol = let
  val n = $CNTR.counter_getinc (the_s2var_name_counter)
  val name = $CNTR.tostring_prefix_count ("$", n)
in
  $SYM.symbol_make_string (name)
end // end of [s2var_name_make]

fn s2var_name_make_prefix
  (pre: string): symbol = let
  val n = $CNTR.counter_getinc (the_s2var_name_counter)
  val name = $CNTR.tostring_prefix_count ("$", n)
  val name = string0_append (pre, name)
  val sym = $SYM.symbol_make_string ($UN.strptr2string (name))
  val () = strptr_free (name)
in
  sym
end // end of [s2var_name_make_prefix]

(* ****** ****** *)

implement
s2var_make_id_srt
  (id, s2t) = let
//
  val stamp = $STMP.s2var_stamp_make ()
//
in
  s2var_new (id, s2t, 0, s2Varset_nil (), stamp)
end // end of [s2var_make_id_srt]

implement
s2var_get_sym (s2v) = $effmask_all (s2var_sym (s2v))

implement
s2var_get_srt (s2v) = $effmask_all (s2var_srt (s2v))

implement
s2var_get_tmplev (s2v) = s2var_tmplev (s2v)
implement
s2var_set_tmplev (s2v, lev) = set_s2var_tmplev (s2v, lev)

implement
s2var_get_sVarset (s2v) = s2var_sVarset (s2v)
implement
s2var_set_sVarset (s2v, xs) = set_s2var_sVarset (s2v, xs)
implement
s2varlst_set_sVarset
  (s2vs, xs) = case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => (
      s2var_set_sVarset (s2v, xs); s2varlst_set_sVarset (s2vs, xs)
    ) // end of [list_cons]
  | ~GLnil () => ()
// end of [s2varlst_set_sVarset]

implement
s2var_get_stamp (s2v) = $effmask_all (s2var_stamp (s2v))

(* ****** ****** *)

implement
s2var_is_bool (s2v) = let
  val s2t = s2var_get_srt (s2v) in s2rt_is_bool (s2t)
end // end of [s2var_is_bool]

(* ****** ****** *)

implement
s2var_make_srt (s2t) = let
  val id = s2var_name_make () in s2var_make_id_srt (id, s2t)
end // end of [s2var_make_srt]

implement
s2var_dup (s2v0) = let
  val id0 = s2var_get_sym s2v0
  val s2t0 = s2var_get_srt s2v0
  val id_new = s2var_name_make_prefix ($SYM.symbol_get_name id0)
in
  s2var_make_id_srt (id_new, s2t0)
end // end of [s2var_dup]

(* ****** ****** *)

implement
lt_s2var_s2var
  (x1, x2) = (compare_s2var_s2var (x1, x2) < 0)
// end of [lt_s2var_s2var]

implement
lte_s2var_s2var
  (x1, x2) = (compare_s2var_s2var (x1, x2) <= 0)
// end of [lte_s2var_s2var]

implement
eq_s2var_s2var
  (x1, x2) = (compare_s2var_s2var (x1, x2) = 0)
// end of [eq_s2var_s2var]

implement
neq_s2var_s2var
  (x1, x2) = (compare_s2var_s2var (x1, x2) != 0)
// end of [neq_s2var_s2var]

implement
compare_s2var_s2var (x1, x2) =
  $effmask_all (compare (s2var_get_stamp (x1), s2var_get_stamp (x2)))
// end of [compare_s2var_s2var]

implement
compare_s2vsym_s2vsym
  (x1, x2) = (
  $effmask_all ($SYM.compare_symbol_symbol (s2var_get_sym (x1), s2var_get_sym (x2)))
) // end of [compare_s2vsym_s2vsym]

(* ****** ****** *)

implement
fprint_s2var (out, s2v) = let
  val () = $SYM.fprint_symbol (out, s2var_get_sym s2v)
  val () = fprint_string (out, "(")
  val () = $STMP.fprint_stamp (out, s2var_get_stamp s2v)
  val () = fprint_string (out, ")")
in
  // empty
end // end of [fprint_s2var]

implement print_s2var (x) = fprint_s2var (stdout_ref, x)
implement prerr_s2var (x) = fprint_s2var (stderr_ref, x)

implement
fprint_s2varlst (out, xs) =
  $UT.fprintlst<s2var> (out, xs, ", ", fprint_s2var)
// end of [fprint_s2varlst]

implement print_s2varlst (xs) = fprint_s2varlst (stdout_ref, xs)
implement prerr_s2varlst (xs) = fprint_s2varlst (stderr_ref, xs)

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_s2var_s2var ($UN.cast{s2var} (x1), $UN.cast{s2var} (x2))
//
fn
ins (xs: avlmap, x: s2var): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
fn
del (xs: avlmap, x: s2var): avlmap =
  avlmap_remove (xs, $UN.cast{ptr} (x), cmp)
//
in (* in-of-local *)

implement
s2varset_nil
  ((*void*)) = $UN.cast{s2varset} (avlmap_nil ())

implement
s2varset_add
  (xs, x) = $UN.cast{s2varset} (ins ($UN.cast{avlmap} (xs), x))
// end of [s2varset_add]

implement
s2varset_del
  (xs, x) = $UN.cast{s2varset} (del ($UN.cast{avlmap} (xs), x))
// end of [s2varset_del]

implement
s2varset_union
  (xs, ys) = $UN.cast{s2varset}
  (avlmap_union ($UN.cast{avlmap} (xs), $UN.cast{avlmap} (ys), cmp))
// end of [s2varset_union]

implement
s2varset_listize (xs) =
  $UN.castvwtp0{s2varlst_vt} (avlmap_keys ($UN.cast{avlmap} (xs)))

(* ****** ****** *)

implement
s2varset_vt_nil
  ((*void*)) = $UN.castvwtp0{s2varset_vt} (avlmap_nil ())

implement
s2varset_vt_add
  (xs, x) = $UN.castvwtp0{s2varset_vt} (ins ($UN.castvwtp0{avlmap} (xs), x))
// end of [s2varset_vt_add]

implement
s2varset_vt_del
  (xs, x) = $UN.castvwtp0{s2varset_vt} (del ($UN.castvwtp0{avlmap} (xs), x))
// end of [s2varset_vt_del]

implement
s2varset_vt_delist
  (xs1, xs2) = let
  fun loop (
    xs1: s2varset_vt, xs2: s2varlst
  ) : s2varset_vt =
    case+ glist_view (xs2) of
    | ~GLcons (x2, xs2) => loop (s2varset_vt_del (xs1, x2), xs2)
    | ~GLnil () => xs1
  // end of [loop]
in
  loop (xs1, xs2)
end // end of [s2varset_vt_delist]

implement
s2varset_vt_union (xs, ys) = $UN.castvwtp0{s2varset_vt}
  (avlmap_union ($UN.castvwtp0{avlmap} (xs), $UN.castvwtp0{avlmap} (ys), cmp))
// end of [s2varset_vt_union]

implement
s2varset_vt_free (xs) = let
  val _ = $UN.castvwtp0{avlmap} (xs) in (*nothing: the memory of the arena is never freed*)
end // end of [s2varset_vt_free]
implement
s2varset_vt_listize_free (xs) =
  $UN.castvwtp0{s2varlst_vt} (avlmap_keys ($UN.castvwtp0{avlmap} (xs)))
// end of [s2varset_vt_listize_free]

end // end of [local]

(* ****** ****** *)
//
// HX: the multiset: a list of (n, x) in the order of [cmp]: a node is 3 words (n, x, next)
//
local
//
// first-in-first-occur: the order of the elements in the list is the ascending order of stamps
//
fn
cmp (x1: ptr, x2: ptr): int =
  compare_s2var_s2var ($UN.cast{s2var} (x2), $UN.cast{s2var} (x1))
//
fn ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, 8 * k))
fn st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, 8 * k), x)
fn nn (p: ptr): int = $UN.cast{int} ($UN.cast{lint} (ld (p, 0)))
fn nx (p: ptr): ptr = ld (p, 1)
fn nt (p: ptr): ptr = ld (p, 2)
fn mknode (n: int, x: ptr, next: ptr): ptr = let
  val p = the_garena_alloc ($UN.cast{size_t} (24))
  val () = st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (n)))
  val () = st (p, 1, x)
  val () = st (p, 2, next)
in
  p
end // end of [mknode]
//
fn isnil (p: ptr): bool = ptr_is_null (p)
//
fun
ins (p: ptr, x0: ptr): ptr =
  if isnil (p) then mknode (1, x0, the_null_ptr)
  else let
    val sgn = cmp (x0, nx (p))
  in
    if sgn > 0 then mknode (1, x0, p)
    else if sgn < 0 then mknode (nn (p), nx (p), ins (nt (p), x0))
    else mknode (nn (p) + 1, nx (p), nt (p))
  end // end of [ins]
//
fun
rem (p: ptr, x0: ptr, flag: &int): ptr =
  if isnil (p) then p
  else let
    val sgn = cmp (x0, nx (p))
  in
    if sgn > 0 then p
    else if sgn < 0 then let
      val flag0 = flag
      val p1 = rem (nt (p), x0, flag)
    in
      if flag = flag0 then p else mknode (nn (p), nx (p), p1)
    end else let
      val n1 = nn (p) - 1
      val () = flag := flag + 1
    in
      if n1 > 0 then mknode (n1, nx (p), nt (p)) else nt (p)
    end // end of [else]
  end // end of [rem]
//
fun
uni (p1: ptr, p2: ptr): ptr =
  if isnil (p1) then p2
  else if isnil (p2) then p1
  else let
    val sgn = cmp (nx (p1), nx (p2))
  in
    if sgn > 0 then mknode (nn (p1), nx (p1), uni (nt (p1), p2))
    else if sgn < 0 then mknode (nn (p2), nx (p2), uni (p1, nt (p2)))
    else mknode (nn (p1) + nn (p2), nx (p1), uni (nt (p1), nt (p2)))
  end // end of [uni]
//
fun
equ (p1: ptr, p2: ptr): bool =
  if isnil (p1) then isnil (p2)
  else if isnil (p2) then false
  else let
    val sgn = cmp (nx (p1), nx (p2))
  in
    if sgn = 0 then (if nn (p1) = nn (p2) then equ (nt (p1), nt (p2)) else false)
    else false
  end // end of [equ]
//
fun
cmps (p1: ptr, p2: ptr): int =
  if isnil (p1) then (if isnil (p2) then 0 else ~1)
  else if isnil (p2) then 1
  else let
    val sgn = cmp (nx (p1), nx (p2))
  in
    if sgn > 0 then 1
    else if sgn < 0 then ~1
    else let
      val n1 = nn (p1) and n2 = nn (p2)
    in
      if n1 > n2 then 1
      else if n1 < n2 then ~1
      else cmps (nt (p1), nt (p2))
    end // end of [else]
  end // end of [cmps]
//
fun
listize (p: ptr, res: List0_vt (ptr)): List0_vt (ptr) =
  if isnil (p) then res
  else list_vt_cons (nx (p), listize (nt (p), res))
//
fun
rep (n: int, x: ptr, res: List0_vt (ptr)): List0_vt (ptr) =
  if n > 0 then list_vt_cons (x, rep (n-1, x, res)) else res
//
fun
mlistize (p: ptr, res: List0_vt (ptr)): List0_vt (ptr) =
  if isnil (p) then res
  else rep (nn (p), nx (p), mlistize (nt (p), res))
//
in // in of [local]

implement
s2varmset_nil () = $UN.cast{s2varmset} (the_null_ptr)
implement
s2varmset_sing (x) = $UN.cast{s2varmset} (mknode (1, $UN.cast{ptr} (x), the_null_ptr))
implement
s2varmset_pair
  (x1, x2) = let
  val x1 = $UN.cast{ptr} (x1) and x2 = $UN.cast{ptr} (x2)
  val sgn = cmp (x1, x2)
in
  if sgn > 0 then
    $UN.cast{s2varmset} (mknode (1, x1, mknode (1, x2, the_null_ptr)))
  else if sgn < 0 then
    $UN.cast{s2varmset} (mknode (1, x2, mknode (1, x1, the_null_ptr)))
  else $UN.cast{s2varmset} (mknode (2, x1, the_null_ptr))
end // end of [s2varmset_pair]

implement
s2varmset_gte
  (xs1, xs2) = (cmps ($UN.cast{ptr} (xs1), $UN.cast{ptr} (xs2)) >= 0)
// end of [s2varmset_gte]

implement
s2varmset_is_equal
  (xs1, xs2) = equ ($UN.cast{ptr} (xs1), $UN.cast{ptr} (xs2))
// end of [s2varmset_is_equal]

implement
s2varmset_add
  (xs, x) = $UN.cast{s2varmset} (ins ($UN.cast{ptr} (xs), $UN.cast{ptr} (x)))
// end of [s2varmset_add]

implement
s2varmset_del
  (xs, x) = let
  var flag: int = 0
in
  $UN.cast{s2varmset} (rem ($UN.cast{ptr} (xs), $UN.cast{ptr} (x), flag))
end // end of [s2varmset_del]

implement
s2varmset_union
  (xs1, xs2) = $UN.cast{s2varmset} (uni ($UN.cast{ptr} (xs1), $UN.cast{ptr} (xs2)))
// end of [s2varmset_union]

implement
s2varmset_listize (xs) =
  $UN.castvwtp0{s2varlst_vt} (listize ($UN.cast{ptr} (xs), list_vt_nil ()))

implement
fprint_s2varmset
  (out, xs) = let
//
val xs = mlistize ($UN.cast{ptr} (xs), list_vt_nil ())
val xs = $UN.castvwtp0{s2varlst_vt} (xs)
val () = fprint_s2varlst (out, l2l (xs))
//
in
end // end of [fprint_s2varmset]

end // end of [local]

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_s2var_s2var ($UN.cast{s2var} (x1), $UN.cast{s2var} (x2))
//
in // in of [local]
//
implement
s2varbindmap_make_nil
  ((*void*)) = $UN.castvwtp0{s2varbindmap} (avlmap_nil ())
//
implement
s2varbindmap_search
  (map, k) = let
//
var res: ptr?
val found =
  avlmap_find ($UN.castvwtp1{avlmap} (map), $UN.cast{ptr} (k), cmp, res)
//
in
//
if found then Some_vt ($UN.cast{s2exp} (res)) else None_vt ((*void*))
//
end (* end of [s2varbindmap_search] *)
//
implement
s2varbindmap_insert
  (map, k, x) = let
//
val x = s2hnf2exp (x)
val m = $UN.castvwtp0{avlmap} (map)
val m = avlmap_insert (m, $UN.cast{ptr} (k), $UN.cast{ptr} (x), cmp)
//
in
  map := $UN.castvwtp0{s2varbindmap} (m)
end // end of [s2varbindmap_insert]
//
implement
s2varbindmap_remove
  (map, k) = let
  val m = $UN.castvwtp0{avlmap} (map)
  val m = avlmap_remove (m, $UN.cast{ptr} (k), cmp)
in
  map := $UN.castvwtp0{s2varbindmap} (m)
end // end of [s2varbindmap_remove]
//
implement
s2varbindmap_listize (map) = let
//
fun
zip (
  ks: List0_vt (ptr), vs: List0_vt (ptr)
) : List0_vt (@(s2var, s2exp)) =
(
case+ ks of
| ~list_vt_cons (k, ks) => (
  case+ vs of
  | ~list_vt_cons (v, vs) =>
      list_vt_cons (@($UN.cast{s2var} (k), $UN.cast{s2exp} (v)), zip (ks, vs))
  | ~list_vt_nil () => (list_vt_free (ks); list_vt_nil ()) // HX: deadcode
  )
| ~list_vt_nil () => (list_vt_free (vs); list_vt_nil ())
)
//
val m = $UN.castvwtp1{avlmap} (map)
//
in
  zip (avlmap_keys (m), avlmap_vals (m))
end // end of [s2varbindmap_listize]
//
end // end of [local]

(* ****** ****** *)

(* end of [pats_staexp2_svar.dats] *)
