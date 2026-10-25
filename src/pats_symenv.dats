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
#include "share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "./pats_symmap.sats"
staload _(*anon*) = "./pats_symmap.dats"
staload "./pats_symenv.sats"

(* ****** ****** *)

vtypedef
symmaplst (itm:type) = List0_vt (symmap itm)

(* ****** ****** *)

fun{itm:type}
symmaplst_free
  {n:nat} .<n>.
  (xs: list_vt (symmap itm, n)):<> void =
  case+ xs of
  | ~list_vt_cons (x, xs) => (symmap_free<itm> (x); symmaplst_free<itm> (xs))
  | ~list_vt_nil () => ()
// end of [symmaplst_free]

fun{itm:type}
symmaplst_search {n:nat} .<n>. (
  ms0: !list_vt (symmap itm, n), k: symbol
) :<> Option_vt itm = begin case+ ms0 of
  | @list_vt_cons (m, ms) => let
      val ans = symmap_search<itm> (m, k)
    in
      case+ ans of
      | ~Some_vt (x) => (fold@ ms0; Some_vt (x))
      | ~None_vt () => ans where {
          val ans = symmaplst_search<itm> (ms, k)
          val () = fold@ ms0
        } // end of [None_vt]
    end (* end of [list_vt_cons] *)
  | list_vt_nil () => None_vt ()
end // end of [symmaplst_search]

(* ****** ****** *)

fun{itm:type}
savedlst_free
  {n:nat} .<n>.
  (xs: list_vt (@(symmap itm, symmaplst itm), n)):<> void =
  case+ xs of
  | ~list_vt_cons (x, xs) => let
      val () = symmap_free<itm> (x.0)
      val () = symmaplst_free<itm> (x.1)
    in
      savedlst_free<itm> (xs)
    end
  | ~list_vt_nil () => ()
// end of [savedlst_free]

(* ****** ****** *)

assume
symenv_vt0ype
  (itm:type) = @{
  map= symmap (itm)
, maplst= symmaplst (itm)
, savedlst= List0_vt @(symmap itm, symmaplst itm)
, pervasive= symmap (itm)
} // end of [symenv_v0type]

(* ****** ****** *)

implement{itm}
symenv_make_nil
  () = let
  stadef T = symenv (itm)
  val (pfat, pfgc | p) = ptr_alloc<T> ()
  val () = p->map := symmap_make_nil<itm> ()
  val () = p->maplst := list_vt_nil ()
  val () = p->savedlst := list_vt_nil ()
  val () = p->pervasive := symmap_make_nil<itm> ()
  prval () = $UN.castview0{void}(pfgc) // HX: the memory is never freed
in
  (pfat | p)
end // end of [symenv_make_nil]

implement{itm}
symenv_free
  {l} (pf | p) = $effmask_wrt let
  prval pfgc = $UN.castview0{mfree_gc_v(l)}(0)
  val () = symmap_free<itm> (p->map)
  val () = symmaplst_free<itm> (p->maplst)
  val () = symmap_free<itm> (p->pervasive)
  val () = savedlst_free<itm> (p->savedlst)
  prval pf = $UN.castview0{(symenv(itm))? @ l}(pf)
in
  ptr_free (pfgc, pf | p)
end // end of [symenv_free]

(* ****** ****** *)

implement{itm}
symenv_search
  (env, k) = let
  val ans = symmap_search<itm> (env.map, k)
in
  case+ ans of
  | ~Some_vt (x) => Some_vt (x)
  | ~None_vt () => symmaplst_search<itm> (env.maplst, k)
end // end of [symenv_search]

(* ****** ****** *)

implement{itm}
symenv_insert
  (env, k, i) = symmap_insert<itm> (env.map, k, i)
// end of [symenv_insert]

(* ****** ****** *)

implement{itm}
symenv_pop
  (env) = $effmask_wrt ( map0 where {
  val map0 = env.map
  val-~list_vt_cons (map, maps) = env.maplst
  val () = env.map := map
  val () = env.maplst := maps
} )
// end of [symenv_pop]

implement{itm}
symenv_pop_free
  (env) = $effmask_wrt ( () where {
  val map = symenv_pop<itm> (env)
  val () = symmap_free<itm> (map)
} )
// end of [symmap_pop_free]

implement{itm}
symenv_push
  (env, map0) = $effmask_wrt ( () where {
  val () = env.maplst := list_vt_cons (env.map, env.maplst)
  val () = env.map := map0
} )
// end of [symenv_push]

implement{itm}
symenv_push_nil
  (env) = $effmask_wrt ( () where {
  val map = symmap_make_nil<itm> ()
  val () = symenv_push<itm> (env, map)
} )
// end of [symmap_push_nil]

(* ****** ****** *)

implement{itm}
symenv_top_clear
  (env) = $effmask_wrt ( () where {
//
val () = symmap_free<itm> (env.map)
val () = env.map := symmap_make_nil<itm> ()
//
} ) (* end of [symenv_top_clear] *)

(* ****** ****** *)

implement{itm}
symenv_savecur
  (env) = $effmask_wrt ( let
  val m = env.map
  val () = env.map := symmap_make_nil<itm> ()
  val ms = env.maplst
  val () = env.maplst := list_vt_nil ()
  val () = env.savedlst := list_vt_cons (@(m, ms), env.savedlst)
in
  // nothing
end )
// end of [symenv_savecur]

implement{itm}
symenv_restore
  (env) = $effmask_wrt ( let
  val top = env.map
  val () = symmaplst_free<itm> (env.maplst)
  val-~list_vt_cons (x, xs) = env.savedlst
  val () = env.savedlst := xs
  val () = env.map := x.0 and () = env.maplst := x.1
in
  top
end )
// end of [symenv_restore]

(* ****** ****** *)

implement{itm}
symenv_localjoin
  (env) = $effmask_wrt ( let
//
val ms = env.maplst
val-~list_vt_cons (m1, ms) = ms
val () = symmap_free<itm> (m1)
val-~list_vt_cons (m2, ms) = ms
val () = env.maplst := ms
//
// HX-2013-06:
// it is done in this way so that a binding
// in [map1] can replace another one in [map2]
// if they happen to be sharing the same key.
//
val m0 = env.map
val () = env.map := m2
val () = symmap_joinwth<itm>(env.map, m0)
val () = symmap_free<itm>(m0)
//
in
  // nothing
end )
// end of [symenv_localjoin]

(* ****** ****** *)

implement{itm}
symenv_pervasive_search
  (env, k) =
  symmap_search<itm> (env.pervasive, k)
// end of [symenv_pervasive_search]

implement{itm}
symenv_pervasive_insert
  (env, k, i) =
  symmap_insert<itm> (env.pervasive, k, i)
// end of [symenv_insert]

(* ****** ****** *)

implement{itm}
symenv_pervasive_joinwth0
  (env, map) = $effmask_wrt ( let
//
val () = symmap_joinwth<itm> (env.pervasive, map)
//
in
  symmap_free<itm> (map)
end )
// end of [symenv_pervasive_joinwth0]

implement{itm}
symenv_pervasive_joinwth1
  (env, map) = symmap_joinwth<itm> (env.pervasive, map)
// end of [symenv_pervasive_joinwth1]

(* ****** ****** *)

implement{itm}
fprint_symenv_map
  (out, env, f) = fprint_symmap<itm> (out, env.map, f)
// end of [fprint_symenv_map]

(* ****** ****** *)

(* end of [pats_symenv.dats] *)
