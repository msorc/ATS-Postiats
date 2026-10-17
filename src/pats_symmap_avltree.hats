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

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "libats/SATS/linmap_avltree.sats"
staload _(*anon*) = "libats/DATS/linmap_avltree.dats"

(* ****** ****** *)

staload "./pats_symmap.sats"

(* ****** ****** *)
//
typedef key = uint
//
assume
symmap_vtype (itm:type) = map (key, itm)

(* ****** ****** *)
//
implement
compare_key_key<key> (x1, x2) =
  if x1 < x2 then ~1 else (if x1 > x2 then 1 else 0)
//
(* ****** ****** *)

implement{itm}
symmap_make_nil () = $effmask_wrt (linmap_make_nil<> ())
implement{itm}
symmap_free (map) = $effmask_wrt (linmap_free<key,itm> (map))

(* ****** ****** *)

implement{itm}
symmap_search
  (map, sym) = $effmask_all let
  val k = $SYM.symbol_get_stamp (sym)
in
  linmap_search_opt<key,itm> (map, k)
end // end of [symmap_search]

(* ****** ****** *)

implement{itm}
symmap_insert
  (map, sym, i) = $effmask_all {
  val k = $SYM.symbol_get_stamp (sym)
  var res: itm?
  val _exist = linmap_insert<key,itm> (map, k, i, res)
  prval () = opt_clear (res)
} (* end of [symmap_insert] *)

(* ****** ****** *)

implement{itm}
symmap_joinwth
  (map1, map2) = $effmask_all let
//
typedef keyitm = (key, itm)
//
fun loop
(
  map: &symmap (itm) >> _, kis: List0_vt (keyitm)
) : void = let
in
//
case+ kis of
| ~list_vt_cons
    (ki, kis1) => let
    var res: itm?
    val _exist = linmap_insert<key,itm> (map, ki.0, ki.1, res)
    prval () = opt_clear (res)
  in
    loop (map, kis1)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
//
end // end of [loop]
//
val kis = linmap_listize1<key,itm> (map2)
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
linmap_foreach$fwork<key,itm><fenv(itm)>
  (k, i, env) = {
  val () = fprint (env.0, k)
  val () = fprint (env.0, " -> ")
  val () = env.1 (env.0, i)
  val () = fprint_newline (env.0)
} (* end of [linmap_foreach$fwork] *)
//
var env: fenv(itm) = @(out, f)
//
in
  linmap_foreach_env<key,itm><fenv(itm)> (map, env)
end // end of [fprint_symmap]

end // end of [local]

(* ****** ****** *)

(* end of [pats_symmap_avltree.hats] *)
