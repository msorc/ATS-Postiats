(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: no GC
** Helpers shared by the .dats files of pats_staexp2*, pats_namespace (#include them
** after the staload of "libats/SATS/arena.sats" and "prelude/SATS/unsafe.sats").
** See PORTING.md, section "Level 2".
*)
//
#define l2l glist_make_list_vt
//
// the identity (the address) of an arena cell; the order is the order of the addresses
//
fn ptr_eq (p: ptr, q: ptr): bool = ($UN.cast{lint} (p) = $UN.cast{lint} (q))
fn ptr_cmp (p: ptr, q: ptr): int = let
  val p = $UN.cast{lint} (p) and q = $UN.cast{lint} (q)
in
  if p < q then ~1 else (if p > q then 1 else 0)
end // end of [ptr_cmp]
//
// the null pointer as a handle (s2rtVar_srt: not yet assigned)
//
fn ptr_isnot_null (p: ptr): bool = ~(ptr_is_null (p))
//
//
fn{a:t@ype}
glist_is_sing (xs: glist(a)): bool =
  if glist_is_cons (xs) then glist_is_nil (glist_tail<a> (xs)) else false
fn{a:t@ype}
glist_is_pair (xs: glist(a)): bool =
  if glist_is_cons (xs) then glist_is_sing<a> (glist_tail<a> (xs)) else false
//
//
fn{a:t@ype}
glist_pair (x1: a, x2: a): glist(a) = glist_cons<a> (x1, glist_sing<a> (x2))
//
