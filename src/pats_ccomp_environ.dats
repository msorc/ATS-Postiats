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
// Start Time: April, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_environ.dats, see PORTING.md,
// "ccomp group C1 (ccompenv/environ/caseof/looping/trywith/lazyeval)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload _(*anon*) = "./pats_dynexp2_dvar.dats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

vtypedef
funlablst2_vt = List0_vt (funlablst)

(* ****** ****** *)

overload fprint with fprint_vbindmap

(* ****** ****** *)
//
// HX-2026-10: the global map of the bindings of the function being emitted
// lives in a cell of the global arena; it is taken out and put back
//
fn
cell_make (x: ptr): ptr = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, x)
in
  p
end // end of [cell_make]
//
fn cell_get (p: ptr): ptr = $UN.ptr0_get<ptr> (p)
fn cell_set (p: ptr, x: ptr): void = $UN.ptr0_set<ptr> (p, x)
//
(* ****** ****** *)

local

fun
aux_funlab_get_flablst
(
  flab: funlab
) : funlablst = let
//
val-~GOsome(fent) =
  gopt_view(funlab_get_funent(flab))
//
in
  funent_get_flablst(fent)
end // end of [aux_funlab_get_flablst]

fun
auxtrclo
(
  flvl0: int
, xs: funlablst
, xss: funlablst2_vt
, res: funlabset_vt
) : funlabset_vt = let
in
//
case+ glist_view(xs) of
| ~GLcons
    (x, xs) => let
//
// HX-2013-04-12:
// Note that flvl <= flvl0 holds!
//
    val
    flvl = funlab_get_level(x)
  in
    if flvl >= flvl0 then let
      val
      ismem = funlabset_vt_ismem(res, x)
    in
      if ismem then
      (
        auxtrclo(flvl0, xs, xss, res)
      ) else let
        val res = funlabset_vt_add(res, x)
        val xs_new = aux_funlab_get_flablst(x)
      in
        auxtrclo(flvl0, xs_new, list_vt_cons(xs, xss), res)
      end (* end of [if] *)
    end else let // parent
      val res =
        funlabset_vt_add(res, x) in auxtrclo(flvl0, xs, xss, res)
      // end of [val]
    end (* end of [if] *)
  end // end of [list_vt_cons]
| ~GLnil((*void*)) =>
  (
    case+ xss of
    | ~list_vt_nil
        ((*void*)) => res
    | ~list_vt_cons
        (xs, xss) => auxtrclo(flvl0, xs, xss, res)
      // end of [list_vt_cons]
  ) (* end of [list_vt_nil] *)
//
end // end of [auxtrclo]

in (* in of [local] *)

implement
funent_eval_flablst
  (fent) = let
//
val opt = funent_get_flablst_fin(fent)
//
in
//
case+ gopt_view(opt) of
| ~GOsome(fls) => fls
| ~GOnone((*void*)) => fls where
  {
//
    val fl0 = funent_get_lab(fent)
    val flvl = funent_get_level(fent)
//
    val xs0 = funent_get_flablst(fent)
    val xss = list_vt_nil() // : funlablst2_vt
    val res = funlabset_vt_nil()
    val res = funlabset_vt_add(res, fl0)
    val res = auxtrclo(flvl, xs0, xss, res)
    val fls = funlabset_vt_listize_free(res)
    val fls = glist_make_list_vt<funlab>(fls)
    val ((*void*)) = funent_set_flablst_fin(fent, gopt_some<funlablst>(fls))
//
  } (* end of [None] *)
//
end // end of [funent_eval_flablst]

end // end of [local]

(* ****** ****** *)

local

fun
aux_funlab_get_d2envlst
  (flab: funlab): d2envlst = let
//
val-~GOsome(fent) = gopt_view(funlab_get_funent (flab))
val d2esopt = funent_get_d2envlst_fin (fent)
//
in
//
case+ gopt_view(d2esopt) of
| ~GOsome(d2es) => d2es
| ~GOnone((*void*)) =>
    funent_get_d2envlst (fent) (* HX-2013-10-09: error? *)
  // end of [None]
//
end // end of [aux_funlab_get_d2envlst]

fun
auxd2es
(
  d2es: d2envlst
, vbmap: vbindmap, res: d2envset_vt
) : d2envset_vt = let
in
//
case+ glist_view(d2es) of
//
| ~GLcons
    (d2e, d2es) => let
    val res = d2envset_vt_add (res, d2e)
  in
    auxd2es (d2es, vbmap, res)
  end (* end of [list_cons] *)
//
| ~GLnil () => res
//
end // end of [auxd2es]

(* ****** ****** *)
//
// HX-2013-04:
// [vbmap] is not actually used.
//
fun
auxtrclo
(
  fls: funlablst
, vbmap: vbindmap, res: d2envset_vt
) : d2envset_vt = let
in
//
case+ glist_view(fls) of
| ~GLnil () => res
| ~GLcons
    (fl, fls) => let
    val d2es =
      aux_funlab_get_d2envlst (fl)
    // end of [val]
    val res = auxd2es (d2es, vbmap, res)
  in
    auxtrclo (fls, vbmap, res)
  end (* end of [list_vt_cons] *)
//
end // end of [auxtrclo]

in (* in of [local] *)

implement
funent_eval_d2envlst
  (fent) = let
//
val opt = funent_get_d2envlst_fin (fent)
//
in
//
case+ gopt_view(opt) of
| ~GOsome (d2es) => d2es
| ~GOnone ((*void*)) => d2es where
  {
    val fls0 = funent_eval_flablst (fent)
    val vbmap = funent_get_vbindmap (fent)
    val d2es(*set*) = d2envset_vt_nil()
    val d2es(*set*) = auxtrclo (fls0, vbmap, d2es)
    val d2es(*list*) = d2envset_vt_listize_free (d2es)
    val d2es(*list*) = glist_make_list_vt<d2env>($UN.castvwtp0{List0_vt(d2env)}(d2es))
    val ((*void*)) = funent_set_d2envlst_fin (fent, gopt_some<d2envlst>(d2es))
  } (* end of [None] *)
//
end // end of [funent_eval_d2envlst]

end // end of [local]

(* ****** ****** *)

implement
funlab_is_envful
  (flab) = let
//
val opt = funlab_get_funent (flab)
val d2es =
(
case+ gopt_view(opt) of
| ~GOsome (fent) => funent_eval_d2envlst (fent) | ~GOnone () => glist_nil ()
) : d2envlst // end of [val]
//
in
  glist_is_cons (d2es)
end // end of [funlab_is_envful]

(* ****** ****** *)

implement
funlab_get_type_fullarg
  (flab) = let
//
fun aux
(
  d2es: d2envlst, hses: hisexplst
) : hisexplst = let
in
//
case+ glist_view(d2es) of
| ~GLcons
    (d2e, d2es) => let
    val hse = d2env_get_type (d2e)
  in
    glist_cons<hisexp>(hse, aux (d2es, hses))
  end // end of [list_cons]
| ~GLnil((*void*)) => hses
//
end (* end of [aux] *)
//
val opt = funlab_get_funent (flab)
val d2es =
(
case+ gopt_view(opt) of
| ~GOsome(fent) => funent_eval_d2envlst(fent) | ~GOnone() => glist_nil()
) : d2envlst // end of [val]
//
val hses = funlab_get_type_arg (flab)
//
in
  aux (d2es, hses)
end // end of [funlab_get_type_fullarg]

(* ****** ****** *)

local

(*
fun funent_varbindmap_initize (fent: funent): void
fun funent_varbindmap_initize2 (fent: funent): void
fun funent_varbindmap_uninitize (fent: funent): void
fun the_funent_varbindmap_find (d2v: d2var): Option_vt (primval)
*)

vtypedef
vbindlst_vt = List0_vt @(d2var, primval)
vtypedef
vbindmap_vt = d2varmap_vt (primval)

val the_vbmap =
  cell_make ($UN.castvwtp0{ptr}(d2varmap_vt_nil<primval> ()))

fn
vbmap_take (): vbindmap_vt = $UN.castvwtp0{vbindmap_vt}(cell_get (the_vbmap))
fn
vbmap_put (map: vbindmap_vt): void = cell_set (the_vbmap, $UN.castvwtp0{ptr}(map))

in (* in of [local] *)

implement
funent_varbindmap_initize
  (fent0) = let
//
fun
auxmap
(
  map: &vbindmap_vt, vbs: vbindlst_vt
) : void = let
in
//
case+ vbs of
| ~list_vt_cons
    (vb, vbs) => let
    val _ =
    ( // replaced
      d2varmap_vt_insert<primval> (map, vb.0, vb.1)
    ) (* end of [val] *)
  in
    auxmap (map, vbs)
  end (* end of [list_cons] *)
| ~list_vt_nil () => ()
//
end // end of [auxmap]
//
fun
auxenv
(
  map: &vbindmap_vt, loc0: loc_t, i: int, d2es: d2envlst
) : void = let
in
//
case+ glist_view(d2es) of
| ~GLnil
    ((*void*)) => ()
| ~GLcons
    (d2e, d2es) => let
    val d2v = d2env_get_var (d2e)
    val hse = d2env_get_type (d2e)
    val argenv = primval_argenv (loc0, hse, i)
    val _(*replaced*) = d2varmap_vt_insert<primval> (map, d2v, argenv)
  in
    auxenv (map, loc0, i+1, d2es)
  end (* end of [list_cons] *)
//
end // end of [auxenv]
//
val loc0 = funent_get_loc (fent0)
//
val vbmap = funent_get_vbindmap (fent0)
//
var map = vbmap_take ()
//
val () = auxmap (map, d2varmap_listize<primval> (vbmap))
val () = auxenv (map, loc0, 0, funent_eval_d2envlst(fent0))
//
val () = vbmap_put (map)
//
in
  (*nothing*)
end // end of [funent_varbindmap_initize]

(* ****** ****** *)

implement
funent_varbindmap_initize2
  (fent0) = let
//
fun
auxlst
(
  fls: funlablst
) : void =
(
case+ glist_view(fls) of
| ~GLnil () => ()
| ~GLcons (fl, fls) => let
    val opt = funlab_get_funent (fl)
    val ((*void*)) =
    (
      case+ gopt_view(opt) of
      | ~GOnone () => ()
      | ~GOsome (fent) =>
          funent_varbindmap_initize (fent)
        // end of [Some]
    ) : void // end of [val]
  in
    auxlst (fls)
  end // end of [list_cons]
)
//
val fls0 = funent_get_fnxlablst (fent0)
//
in
//
case+ glist_view(fls0) of
| ~GLnil () => ()
| ~GLcons (_, fls) => auxlst (fls)
//
end // end of [funent_varbindmap_initize2]

(* ****** ****** *)

implement
funent_varbindmap_uninitize
  (fent0) = let
//
val () = d2varmap_vt_free<primval> (vbmap_take ())
val () = vbmap_put (d2varmap_vt_nil<primval> ())
//
in
  // nothing
end // end of [the_funent_varbindmap_uninitize]

(* ****** ****** *)

implement
the_funent_varbindmap_find
  (d2v) = res where
{
//
val map = vbmap_take ()
val res = d2varmap_vt_search<primval> (map, d2v)
val () = vbmap_put (map)
//
} // end of [the_funent_varbindmap_find]

end // end of [local]

(* ****** ****** *)

(* end of [pats_ccomp_environ.dats] *)
