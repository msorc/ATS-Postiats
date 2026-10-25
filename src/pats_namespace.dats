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
// HX-2026-10: no GC (ATS2 port of src/pats_namespace.dats, see PORTING.md)
// The four lists (the current file environments, the stack of the saved ones, and the
// list of the saved pairs, as two parallel lists) are immutable [glist]s in cells of the
// global arena; nothing is freed.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_namespace.sats"

(* ****** ****** *)
//
typedef
fenvlst = glist (filenv)
typedef
fenvlstlst = glist (fenvlst)
typedef
fenvlstsaved = glist (fenvlst) // HX: the first components of the saved pairs
typedef
fenvlstlstsaved = glist (fenvlstlst) // HX: the second components
//
(* ****** ****** *)

local

val the_fenvlst = let
  val p = the_garena_alloc (sizeof<fenvlst>)
  val () = $UN.ptr0_set<fenvlst> (p, glist_nil ())
in p end // end of [val]
val the_fenvlstlst = let
  val p = the_garena_alloc (sizeof<fenvlstlst>)
  val () = $UN.ptr0_set<fenvlstlst> (p, glist_nil ())
in p end // end of [val]
val the_savedlst_1 = let
  val p = the_garena_alloc (sizeof<fenvlstsaved>)
  val () = $UN.ptr0_set<fenvlstsaved> (p, glist_nil ())
in p end // end of [val]
val the_savedlst_2 = let
  val p = the_garena_alloc (sizeof<fenvlstlstsaved>)
  val () = $UN.ptr0_set<fenvlstlstsaved> (p, glist_nil ())
in p end // end of [val]

in (* in of [local] *)

implement
the_namespace_get_fenvlst () = $UN.ptr0_get<fenvlst> (the_fenvlst)
implement
the_namespace_get_fenvlstlst () = $UN.ptr0_get<fenvlstlst> (the_fenvlstlst)

implement
the_namespace_add
  (x) = () where {
  val xs = $UN.ptr0_get<fenvlst> (the_fenvlst)
  val () = $UN.ptr0_set<fenvlst> (the_fenvlst, glist_cons (x, xs))
} // end of [the_namespace_add]

(* ****** ****** *)

implement
{a}(*tmp*)
the_namespace_search
  (env, f) = let
//
fun auxlst (
  env: ptr
, f: (ptr, filenv) -> Option_vt a, ns: fenvlst
) : Option_vt a =
(
  case+ glist_view (ns) of
  | ~GLcons (n, ns) => (
      case+ f (env, n) of ~None_vt () => auxlst (env, f, ns) | ans => ans
    ) // end of [list_cons]
  | ~GLnil ((*void*)) => None_vt ()
) (* end of [auxlst] *)
//
fun auxlstlst (
  env: ptr
, f: (ptr, filenv) -> Option_vt a, nss: fenvlstlst
) : Option_vt a =
(
  case+ glist_view (nss) of
  | ~GLcons
      (ns, nss) => (
      case+ auxlst (env, f, ns) of
      | ~None_vt () => auxlstlst (env, f, nss) | ans => ans
    ) // end of [list_cons]
  | ~GLnil () => None_vt () // end of [list_nil]
) (* end of [auxlstlst] *)
//
val ns = the_namespace_get_fenvlst ()
val nss = the_namespace_get_fenvlstlst ()
//
in
//
case+ auxlst (env, f, ns) of
| ~None_vt () => auxlstlst (env, f, nss) | ans => ans
//
end // end of [the_namespace_search]

(* ****** ****** *)

implement
the_namespace_pop () = let
  val nss = $UN.ptr0_get<fenvlstlst> (the_fenvlstlst)
  val ns = glist_head (nss) // HX: val-~list_vt_cons (ns, nss) = !p
  val () = $UN.ptr0_set<fenvlstlst> (the_fenvlstlst, glist_tail (nss))
  val () = $UN.ptr0_set<fenvlst> (the_fenvlst, ns)
in
  // nothing
end // end of [the_namespace_pop]

(* ****** ****** *)

implement
the_namespace_push () = let
//
  val ns = $UN.ptr0_get<fenvlst> (the_fenvlst)
  val () = $UN.ptr0_set<fenvlst> (the_fenvlst, glist_nil ())
//
  val nss = $UN.ptr0_get<fenvlstlst> (the_fenvlstlst)
  val () = $UN.ptr0_set<fenvlstlst> (the_fenvlstlst, glist_cons (ns, nss))
//
in
  // nothing
end // end of [the_namespace_push]

(* ****** ****** *)

implement
the_namespace_localjoin () = let
//
  val nss = $UN.ptr0_get<fenvlstlst> (the_fenvlstlst)
  val ns1 = glist_head (nss) // HX: freed in ATS1
  val nss = glist_tail (nss)
  val ns2 = glist_head (nss)
  val nss = glist_tail (nss)
  val () = $UN.ptr0_set<fenvlstlst> (the_fenvlstlst, nss)
//
  val ns = $UN.ptr0_get<fenvlst> (the_fenvlst)
  val () = $UN.ptr0_set<fenvlst> (the_fenvlst, glist_append<filenv> (ns, ns2))
//
in
  // nothing
end // end of [the_namespace_localjoin]

(* ****** ****** *)

implement
the_namespace_save
  () = () where {
//
val x = $UN.ptr0_get<fenvlst> (the_fenvlst)
val () = $UN.ptr0_set<fenvlst> (the_fenvlst, glist_nil ())
//
val xs = $UN.ptr0_get<fenvlstlst> (the_fenvlstlst)
val () = $UN.ptr0_set<fenvlstlst> (the_fenvlstlst, glist_nil ())
//
val saved1 = $UN.ptr0_get<fenvlstsaved> (the_savedlst_1)
val saved2 = $UN.ptr0_get<fenvlstlstsaved> (the_savedlst_2)
val () = $UN.ptr0_set<fenvlstsaved> (the_savedlst_1, glist_cons (x, saved1))
val () = $UN.ptr0_set<fenvlstlstsaved> (the_savedlst_2, glist_cons (xs, saved2))
//
} (* end of [the_namespace_save] *)

(* ****** ****** *)

implement
the_namespace_restore
  () = () where {
//
val saved1 = $UN.ptr0_get<fenvlstsaved> (the_savedlst_1)
val saved2 = $UN.ptr0_get<fenvlstlstsaved> (the_savedlst_2)
val x0 = glist_head (saved1)
val x1 = glist_head (saved2)
val () = $UN.ptr0_set<fenvlstsaved> (the_savedlst_1, glist_tail (saved1))
val () = $UN.ptr0_set<fenvlstlstsaved> (the_savedlst_2, glist_tail (saved2))
//
val () = $UN.ptr0_set<fenvlst> (the_fenvlst, x0)
val () = $UN.ptr0_set<fenvlstlst> (the_fenvlstlst, x1)
//
} (* end of [the_namespace_restore] *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_namespace.dats] *)
