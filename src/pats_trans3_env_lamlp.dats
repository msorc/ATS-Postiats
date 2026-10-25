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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_lamlp.dats, see PORTING.md, "Type-checking environment (trans3_env)")
//

(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_env_lamlp"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

local

val the_lamlplst = gcell_make<lamlplst> (glist_nil ())

in // in of [local]

implement
the_lamlpenv_top
  ((*void*)) = let
  val xs = gcell_get<lamlplst> (the_lamlplst)
in
  case+ glist_view (xs) of
  | ~GLcons (x, _) => Some_vt x
  | ~GLnil () => None_vt ()
end // end of [the_lamlpenv_push_top]

(* ****** ****** *)

fun
get_funarg_loop (
  xs: lamlplst
) : Option_vt (p3atlst) = let
in
//
case+ glist_view (xs) of
| ~GLcons (x, xs) => (
  case+ lamlp_view (x) of
  | ~LAMLPlam (p3ts) => Some_vt (p3ts)
  | ~LAMLPloop0 _ => get_funarg_loop (xs)
  | ~LAMLPloop1 _ => get_funarg_loop (xs)
  ) // end of [list_vt_cons]
| ~GLnil () => None_vt ()
//
end // end of [get_funarg_loop]

implement
the_lamlpenv_get_funarg
  ((*void*)) = get_funarg_loop (gcell_get<lamlplst> (the_lamlplst))
// end of [the_lamlpenv_get_funarg]

(* ****** ****** *)

implement
the_lamlpenv_pop
  ((*none*)) = let
  val xs = gcell_get<lamlplst> (the_lamlplst)
  val () = assertloc (glist_is_cons (xs))
in
  gcell_set<lamlplst> (the_lamlplst, glist_tail (xs))
end // end of [the_lamlpenv_push_pop]

(* ****** ****** *)

implement
the_lamlpenv_push_lam (p3ts) =
  gcell_set<lamlplst> (the_lamlplst, glist_cons (lamlp_LAMLPlam (p3ts), gcell_get<lamlplst> (the_lamlplst)))
// end of [the_lamlpenv_push_lam]

(* ****** ****** *)

implement
the_lamlpenv_push_loop0 () =
  gcell_set<lamlplst> (the_lamlplst, glist_cons (lamlp_LAMLPloop0 (), gcell_get<lamlplst> (the_lamlplst)))
// end of [the_lamlpenv_push_loop0]

implement
the_lamlpenv_push_loop1
  (i2nv, lbis, post) =
  gcell_set<lamlplst> (the_lamlplst, glist_cons (lamlp_LAMLPloop1 (i2nv, lbis, post), gcell_get<lamlplst> (the_lamlplst)))
// end of [the_lamlpenv_push_loop1]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_env_lamlp.dats] *)
