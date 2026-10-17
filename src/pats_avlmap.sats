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
// A persistent (functional) AVL tree in the global arena (never freed), keyed by
// pointers (any handle of the arena AST) with an explicit comparison function.
// It replaces the nonlinear [funset_avltree]/[funmap_avltree] of ATS1 that the
// static sets and maps of pats_staexp2 used (s2varset, s2Varset, s2cstset, d2conset,
// s2rtdatset, s2cstmap): a set is a map whose values are null. The nil map is the
// null pointer. A node is 5 words: height, key, value, left, right.
//
(* ****** ****** *)

abstype avlmap_type = ptr
typedef avlmap = avlmap_type

(* ****** ****** *)
//
// the comparison of keys: negative/zero/positive
//
typedef avlcmp = (ptr, ptr) -> int

(* ****** ****** *)

fun avlmap_nil (): avlmap
fun avlmap_is_nil (m: avlmap): bool

fun avlmap_size (m: avlmap): int
fun avlmap_height (m: avlmap): int

(* ****** ****** *)
//
// an existing equal key is replaced (the key and the value)
//
fun avlmap_insert (m: avlmap, k: ptr, v: ptr, cmp: avlcmp): avlmap
//
// the same map if the key is absent
//
fun avlmap_remove (m: avlmap, k: ptr, cmp: avlcmp): avlmap

fun avlmap_ismem (m: avlmap, k: ptr, cmp: avlcmp): bool
//
// true and the value found, or false and null
//
fun avlmap_find (m: avlmap, k: ptr, cmp: avlcmp, v: &ptr? >> ptr): bool
//
// the elements of the second map are inserted into the first
//
fun avlmap_union (m1: avlmap, m2: avlmap, cmp: avlcmp): avlmap

(* ****** ****** *)
//
// ascending (by the comparison function)
//
fun avlmap_keys (m: avlmap): List0_vt (ptr)
fun avlmap_vals (m: avlmap): List0_vt (ptr)

(* ****** ****** *)

(* end of [pats_avlmap.sats] *)
