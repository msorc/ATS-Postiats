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
// HX-2026-10: no GC (see pats_avlmap.sats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_avlmap.sats"

(* ****** ****** *)
//
// a node: word 0 = height, 1 = key, 2 = value, 3 = left, 4 = right
//
fn ld (p: ptr, k: int): ptr =
  $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, 8 * k))
fn st (p: ptr, k: int, x: ptr): void =
  $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, 8 * k), x)

fn isnil (t: ptr): bool = ptr_is_null (t)
fn hgt (t: ptr): int =
  if isnil (t) then 0 else $UN.cast{int} ($UN.cast{lint} (ld (t, 0)))
fn key (t: ptr): ptr = ld (t, 1)
fn vl (t: ptr): ptr = ld (t, 2)
fn lft (t: ptr): ptr = ld (t, 3)
fn rgt (t: ptr): ptr = ld (t, 4)

fn max2 (a: int, b: int): int = if a >= b then a else b

fn mk (k: ptr, v: ptr, l: ptr, r: ptr): ptr = let
  val p = the_garena_alloc ($UN.cast{size_t} (40))
  val hl = hgt (l) and hr = hgt (r)
  val h: int = max2 (hl, hr) + 1
  val () = st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (h)))
  val () = st (p, 1, k)
  val () = st (p, 2, v)
  val () = st (p, 3, l)
  val () = st (p, 4, r)
in
  p
end // end of [mk]

(* ****** ****** *)
//
// rebalance: the heights of [l] and [r] differ by at most 2
//
fn bal (k: ptr, v: ptr, l: ptr, r: ptr): ptr = let
  val hl = hgt (l) and hr = hgt (r)
in
  if hl > hr + 1 then let
    // l is not nil
    val ll = lft (l) and lr = rgt (l)
  in
    if hgt (ll) >= hgt (lr) then
      mk (key (l), vl (l), ll, mk (k, v, lr, r))
    else // lr is not nil
      mk (key (lr), vl (lr), mk (key (l), vl (l), ll, lft (lr)), mk (k, v, rgt (lr), r))
  end else if hr > hl + 1 then let
    val rl = lft (r) and rr = rgt (r)
  in
    if hgt (rr) >= hgt (rl) then
      mk (key (r), vl (r), mk (k, v, l, rl), rr)
    else
      mk (key (rl), vl (rl), mk (k, v, l, lft (rl)), mk (key (r), vl (r), rgt (rl), rr))
  end else mk (k, v, l, r)
end // end of [bal]

(* ****** ****** *)

implement avlmap_nil () = $UN.cast{avlmap} (the_null_ptr)
implement avlmap_is_nil (m) = isnil ($UN.cast{ptr} (m))

implement
avlmap_size (m) = let
  fun aux (t: ptr): int =
    if isnil (t) then 0 else aux (lft (t)) + 1 + aux (rgt (t))
in
  aux ($UN.cast{ptr} (m))
end // end of [avlmap_size]

implement avlmap_height (m) = hgt ($UN.cast{ptr} (m))

(* ****** ****** *)

implement
avlmap_insert (m, k0, v0, cmp) = let
  fun ins (t: ptr, k0: ptr, v0: ptr, cmp: avlcmp): ptr =
    if isnil (t) then mk (k0, v0, the_null_ptr, the_null_ptr)
    else let
      val sgn = cmp (k0, key (t))
    in
      if sgn < 0 then bal (key (t), vl (t), ins (lft (t), k0, v0, cmp), rgt (t))
      else if sgn > 0 then bal (key (t), vl (t), lft (t), ins (rgt (t), k0, v0, cmp))
      else mk (k0, v0, lft (t), rgt (t))
    end // end of [else]
in
  $UN.cast{avlmap} (ins ($UN.cast{ptr} (m), k0, v0, cmp))
end // end of [avlmap_insert]

(* ****** ****** *)
//
// remove the minimum: returns the tree without it; the key/value in the refs
//
fun
takemin (t: ptr, rk: &ptr? >> ptr, rv: &ptr? >> ptr): ptr =
  if isnil (lft (t)) then (rk := key (t); rv := vl (t); rgt (t))
  else let
    val l1 = takemin (lft (t), rk, rv)
  in
    bal (key (t), vl (t), l1, rgt (t))
  end // end of [takemin]

implement
avlmap_remove (m, k0, cmp) = let
  fun del (t: ptr, k0: ptr, cmp: avlcmp, flag: &int): ptr =
    if isnil (t) then t
    else let
      val sgn = cmp (k0, key (t))
    in
      if sgn < 0 then let
        val l1 = del (lft (t), k0, cmp, flag)
      in
        if flag > 0 then bal (key (t), vl (t), l1, rgt (t)) else t
      end else if sgn > 0 then let
        val r1 = del (rgt (t), k0, cmp, flag)
      in
        if flag > 0 then bal (key (t), vl (t), lft (t), r1) else t
      end else let
        val () = flag := 1
      in
        if isnil (lft (t)) then rgt (t)
        else if isnil (rgt (t)) then lft (t)
        else let
          var rk: ptr? and rv: ptr?
          val r1 = takemin (rgt (t), rk, rv)
        in
          bal (rk, rv, lft (t), r1)
        end // end of [else]
      end // end of [else]
    end // end of [else]
  var flag: int = 0
in
  $UN.cast{avlmap} (del ($UN.cast{ptr} (m), k0, cmp, flag))
end // end of [avlmap_remove]

(* ****** ****** *)

implement
avlmap_ismem (m, k0, cmp) = let
  fun aux (t: ptr, k0: ptr, cmp: avlcmp): bool =
    if isnil (t) then false
    else let
      val sgn = cmp (k0, key (t))
    in
      if sgn < 0 then aux (lft (t), k0, cmp)
      else if sgn > 0 then aux (rgt (t), k0, cmp) else true
    end // end of [else]
in
  aux ($UN.cast{ptr} (m), k0, cmp)
end // end of [avlmap_ismem]

implement
avlmap_find (m, k0, cmp, v) = let
  fun aux (t: ptr, k0: ptr, cmp: avlcmp, v: &ptr? >> ptr): bool =
    if isnil (t) then (v := the_null_ptr; false)
    else let
      val sgn = cmp (k0, key (t))
    in
      if sgn < 0 then aux (lft (t), k0, cmp, v)
      else if sgn > 0 then aux (rgt (t), k0, cmp, v)
      else (v := vl (t); true)
    end // end of [else]
in
  aux ($UN.cast{ptr} (m), k0, cmp, v)
end // end of [avlmap_find]

(* ****** ****** *)

implement
avlmap_union (m1, m2, cmp) = let
  fun aux (t2: ptr, m: avlmap, cmp: avlcmp): avlmap =
    if isnil (t2) then m
    else let
      val m = aux (lft (t2), m, cmp)
      val m = avlmap_insert (m, key (t2), vl (t2), cmp)
    in
      aux (rgt (t2), m, cmp)
    end // end of [else]
in
  aux ($UN.cast{ptr} (m2), m1, cmp)
end // end of [avlmap_union]

(* ****** ****** *)

implement
avlmap_keys (m) = let
  // right to left, consing: the result is ascending
  fun aux (t: ptr, res: List0_vt (ptr)): List0_vt (ptr) =
    if isnil (t) then res
    else aux (lft (t), list_vt_cons (key (t), aux (rgt (t), res)))
in
  aux ($UN.cast{ptr} (m), list_vt_nil ())
end // end of [avlmap_keys]

implement
avlmap_vals (m) = let
  fun aux (t: ptr, res: List0_vt (ptr)): List0_vt (ptr) =
    if isnil (t) then res
    else aux (lft (t), list_vt_cons (vl (t), aux (rgt (t), res)))
in
  aux ($UN.cast{ptr} (m), list_vt_nil ())
end // end of [avlmap_vals]

(* ****** ****** *)

(* end of [pats_avlmap.dats] *)
