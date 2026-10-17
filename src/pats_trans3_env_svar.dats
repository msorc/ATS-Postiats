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
// Start Time: March, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_svar.dats, see PORTING.md, "Type-checking environment (trans3_env)")
//

(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

local
//
// HX: the map is a (persistent) linear value kept in a cell; [with_map] takes it out and puts it back
//
val the_s2varbindmap =
  gcell_make<ptr> ($UN.castvwtp0{ptr} (s2varbindmap_make_nil ()))
// end of [val]

typedef s2varlst = glist (s2var)
val the_s2varlst = gcell_make<s2varlst> (glist_nil ())
val the_s2varlstlst = gcell_make<glist(s2varlst)> (glist_nil ())

fun auxrmv (
  map: &s2varbindmap >> _, s2vs: s2varlst
) : void =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => let
      val () = s2varbindmap_remove (map, s2v) in auxrmv (map, s2vs)
    end // end of [GLcons]
  | ~GLnil () => ()
// end of [auxrmv]

in // in of [local]

implement
the_s2varbindmap_pop
  ((*nothing*)) = let
//
val s2vs = let
  val xss = gcell_get<glist(s2varlst)> (the_s2varlstlst)
in
  case+ glist_view (xss) of
  | ~GLcons (xs, xss) => let
      val () = gcell_set<glist(s2varlst)> (the_s2varlstlst, xss) in xs
    end
  | ~GLnil () => glist_nil ()
end : s2varlst
val s2vs = xs where {
  val xs = gcell_get<s2varlst> (the_s2varlst)
  val () = gcell_set<s2varlst> (the_s2varlst, s2vs)
} // end of [val]
val () = let
  var map = $UN.castvwtp0{s2varbindmap} (gcell_get<ptr> (the_s2varbindmap))
  val () = auxrmv (map, s2vs)
in
  gcell_set<ptr> (the_s2varbindmap, $UN.castvwtp0{ptr} (map))
end // end of [val]
//
in
  // nothing
end // end of [the_s2varbindmap_pop]

implement
the_s2varbindmap_push () = let
  val s2vs = s2vs where {
    val s2vs = gcell_get<s2varlst> (the_s2varlst)
    val () = gcell_set<s2varlst> (the_s2varlst, glist_nil ())
  } // end of [val]
  val xss = gcell_get<glist(s2varlst)> (the_s2varlstlst)
in
  gcell_set<glist(s2varlst)> (the_s2varlstlst, glist_cons (s2vs, xss))
end // end of [the_s2varbindmap_push]

fun
fprint_s2varbindmap_aux (
  out: FILEref, kis: List0_vt @(s2var, s2exp)
) : void =
  case+ kis of
  | ~list_vt_cons (ki, kis) => let
      val () = fprint_s2var (out, ki.0)
      val () = fprint_string (out, " -> ")
      val () = fprint_s2exp (out, ki.1)
      val () = fprint_newline (out)
    in
      fprint_s2varbindmap_aux (out, kis)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
// end of [fprint_s2varbindmap_aux]

implement
fprint_the_s2varbindmap (out) = let
  var map = $UN.castvwtp0{s2varbindmap} (gcell_get<ptr> (the_s2varbindmap))
  val kis = s2varbindmap_listize (map)
  val () = gcell_set<ptr> (the_s2varbindmap, $UN.castvwtp0{ptr} (map))
in
  fprint_s2varbindmap_aux (out, kis)
end // end of [fprint_the_s2varbindmap]

implement
the_s2varbindmap_search (s2v) = let
  var map = $UN.castvwtp0{s2varbindmap} (gcell_get<ptr> (the_s2varbindmap))
  val res = s2varbindmap_search (map, s2v)
  val () = gcell_set<ptr> (the_s2varbindmap, $UN.castvwtp0{ptr} (map))
in
  res
end // end of [the_s2varbindmap_search]

implement
the_s2varbindmap_insert (s2v, s2f) = let
//
val () = gcell_set<s2varlst> (the_s2varlst, glist_cons (s2v, gcell_get<s2varlst> (the_s2varlst)))
//
val () = let
  var map = $UN.castvwtp0{s2varbindmap} (gcell_get<ptr> (the_s2varbindmap))
  val () = s2varbindmap_insert (map, s2v, s2f)
in
  gcell_set<ptr> (the_s2varbindmap, $UN.castvwtp0{ptr} (map))
end // end of [val]
//
in
  (* nothing *)
end // end of [the_s2varbindmap_insert]

implement
the_s2varbindmap_freetop () = let
//
val s2vs = xs where {
  val xs = gcell_get<s2varlst> (the_s2varlst)
  val () = gcell_set<s2varlst> (the_s2varlst, glist_nil ())
} // end of [val]
//
val () = let
  var map = $UN.castvwtp0{s2varbindmap} (gcell_get<ptr> (the_s2varbindmap))
  val () = auxrmv (map, s2vs)
in
  gcell_set<ptr> (the_s2varbindmap, $UN.castvwtp0{ptr} (map))
end // end of [val]
//
in
  (*nothing*)
end // end of [the_s2varbindmap_freetop]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_env_svar.dats] *)
