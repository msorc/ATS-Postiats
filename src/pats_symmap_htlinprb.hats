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
// Start Time: April, 2011
//
(* ****** ****** *)

//
// HX-2026-10: port of src/pats_symmap_htlinprb.hats (a disabled experiment:
// like in ATS1 nothing includes it; src/pats_symmap.dats includes the
// avltree version). It is ported against libats/hashtbl_linprb of ATS2
// and typechecks when included (see src/symmap_htlinprb_check.dats).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "libats/SATS/hashtbl_linprb.sats"
staload _(*anon*) = "libats/DATS/hashtbl_linprb.dats"

(* ****** ****** *)

staload "./pats_symmap.sats"

(* ****** ****** *)

%{^
static inline
atstype_ulint
patsopt_hashint_jenkin32 (atstype_uint x) {
  uint32_t a = x ;
  a = (a+0x7ed55d16) + (a<<12);
  a = (a^0xc761c23c) ^ (a>>19);
  a = (a+0x165667b1) + (a<<5);
  a = (a+0xd3a2646c) ^ (a<<9);
  a = (a+0xfd7046c5) + (a<<3);
  a = (a^0xb55a4f09) ^ (a>>16);
  return a;
} // end of [hashint_jenkin32]
%}
extern
fun hashint_jenkin32
  (x: uint):<> ulint = "mac#patsopt_hashint_jenkin32"
(* end of [hashint_jenkin32] *)

(* ****** ****** *)
//
typedef key = uint
typedef itm = ptr
//
assume
symmap_vtype (itm:type) = hashtbl (key, itm)
//
implement
hash_key<key> (x) = hashint_jenkin32 (x)
implement
equal_key_key<key> (x1, x2) = (x1 = x2)
//
// HX: a stamp is positive, so key 0 marks an empty slot (nullize of
// hashtbl_linprb zeroes the slot)
//
implement(itm)
hashtbl_linprb_keyitm_is_null<key,itm> (ki) = (ki.0 = 0u)
//
(* ****** ****** *)

#define HASHTBLSZ 97

implement{itm}
symmap_make_nil () =
  $effmask_all (hashtbl_make_nil<key,itm> (i2sz(HASHTBLSZ)))
// end of [symmap_make_nil]

implement{itm}
symmap_free (map) = $effmask_all (hashtbl_free<key,itm> (map))

(* ****** ****** *)

implement{itm}
symmap_search
  (map, sym) = $effmask_all let
  val k = $SYM.symbol_get_stamp (sym)
in
  hashtbl_search_opt<key,itm> (map, k)
end // end of [symmap_search]

implement{itm}
symmap_insert
  (map, sym, i) = $effmask_all {
  val k = $SYM.symbol_get_stamp (sym)
  var res: itm?
  val _exist = hashtbl_insert<key,itm> (map, k, i, res)
  prval () = opt_clear (res)
} // end of [symmap_insert]

(* ****** ****** *)

implement{itm}
symmap_joinwth
  (map1, map2) = $effmask_all let
//
typedef keyitm = (key, itm)
//
fun loop
(
  map: !symmap (itm), kis: List0_vt (keyitm)
) : void = let
in
//
case+ kis of
| ~list_vt_cons
    (ki, kis1) => let
    var res: itm?
    val _exist = hashtbl_insert<key,itm> (map, ki.0, ki.1, res)
    prval () = opt_clear (res)
  in
    loop (map, kis1)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
//
end // end of [loop]
//
val kis = hashtbl_listize1<key,itm> (map2)
//
in
  loop (map1, kis)
end // end of [symmap_joinwth]

(* ****** ****** *)

local
//
typedef fenv (itm:type) = @(FILEref, (FILEref, itm) -> void)
//
in (* in-of-local *)

implement{itm}
fprint_symmap (out, map, f) = let
//
implement
hashtbl_foreach$fwork<key,itm><fenv(itm)>
  (k, i, env) = {
  val () = fprint (env.0, k)
  val () = fprint (env.0, " -> ")
  val () = env.1 (env.0, i)
  val () = fprint_newline (env.0)
} (* end of [hashtbl_foreach$fwork] *)
//
var env: fenv(itm) = @(out, f)
//
in
  hashtbl_foreach_env<key,itm><fenv(itm)> (map, env)
end // end of [fprint_symmap]

end // end of [local]

(* ****** ****** *)

(* end of [pats_symmap_htlinprb.hats] *)
