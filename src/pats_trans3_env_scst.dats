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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_scst.dats, see PORTING.md, "Type-checking environment (trans3_env)")
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

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_env_scst"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

local

typedef s2cstlst = glist (s2cst)
val the_s2cstlst = gcell_make<s2cstlst> (glist_nil ())
val the_s2cstlstlst = gcell_make<glist(s2cstlst)> (glist_nil ())

in // in of [local]

implement
the_s2cstbindlst_add (s2c) = let
//
val xs = gcell_get<s2cstlst> (the_s2cstlst)
//
in
  gcell_set<s2cstlst> (the_s2cstlst, glist_cons (s2c, xs))
end // end of [the_s2cstbindlst_add]

(* ****** ****** *)

implement
the_s2cstbindlst_addlst (s2cs) = let
//
val xs = gcell_get<s2cstlst> (the_s2cstlst)
//
in
  gcell_set<s2cstlst> (the_s2cstlst, glist_append (l2l(s2cs), xs)) // HX: not [reverse_append]!
end // end of [the_s2cstbindlst_add]

(* ****** ****** *)

implement
the_s2cstbindlst_bind_and_add
  (loc0, s2c, s2f) = let
//
val s2e = s2hnf2exp(s2f)
//
val
isasp = s2cst_get_isasp(s2c)
//
val () =
(
case+ gopt_view (isasp) of
| ~GOnone () => ()
| ~GOsome _ => () where
  {
    val () =
    prerr_warning3_loc(loc0)
    val () =
    (
      prerr ": the static constant ["; prerr_s2cst (s2c);
      prerr "] is not abstract at this point."; prerr_newline ()
    ) (* prerrln! *)
  } (* end of [if] // end of [val] *)
) (* end of [val] *)
//
val () = s2cst_set_def(s2c, gopt_some(s2e))
val () = s2cst_set_isasp(s2c, gopt_some(s2e))
//
in
  the_s2cstbindlst_add(s2c)
end // end of [the_s2cstbindlst_bind_and_add]

(* ****** ****** *)

implement
the_s2cstbindlst_pop
  ((*none*)) = let
//
  val
  s2cs2 = let
    val xss = gcell_get<glist(s2cstlst)> (the_s2cstlstlst)
  in
    case+ glist_view (xss) of
    |  ~GLnil() => glist_nil ()
    | ~GLcons(xs, xss) => let
        val () = gcell_set<glist(s2cstlst)> (the_s2cstlstlst, xss) in xs
      end
  end : s2cstlst // end of [val]
//
in
//
// HX:
// It is originally stored in the_s2cstlst
//
  let
    val s2cs1 = gcell_get<s2cstlst> (the_s2cstlst)
    val () = gcell_set<s2cstlst> (the_s2cstlst, s2cs2)
  in glist_listize (s2cs1) end
//
end // end of [the_s2cstbindlst_pop]

(* ****** ****** *)

fun
pop_and_unbind_loop
(
  s2cs: s2cstlst_vt
) : void = begin
  case+ s2cs of
  | ~list_vt_nil
      ((*void*)) => ()
  | ~list_vt_cons
      (s2c, s2cs) => let
      val () =
        s2cst_set_def(s2c, gopt_none())
      // end of [val]
    in
      pop_and_unbind_loop(s2cs)
    end // end of [S2CSTLSTcons]
end // end of [loop]

implement
the_s2cstbindlst_pop_and_unbind
  ((*none*)) = pop_and_unbind_loop (the_s2cstbindlst_pop ())
// end of [the_s2cstbindlst_pop_and_unbind]

(* ****** ****** *)

implement
the_s2cstbindlst_push
  ((*void*)) = let
  val
  s2cs = let
    val s2cs = gcell_get<s2cstlst> (the_s2cstlst)
    val () = gcell_set<s2cstlst> (the_s2cstlst, glist_nil ())
  in
    s2cs
  end // end of [val]
  val xss = gcell_get<glist(s2cstlst)> (the_s2cstlstlst)
in
  gcell_set<glist(s2cstlst)> (the_s2cstlstlst, glist_cons (s2cs, xss))
end // end of [the_s2cstbindlst_push]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_env_scst.dats] *)
