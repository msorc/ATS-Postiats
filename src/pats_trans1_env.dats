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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_env.dats).
// The environments are never freed symenvs kept as pointers.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_staexp"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"

(* ****** ****** *)

staload
FIL = "./pats_filename.sats"
staload FIX = "./pats_fixity.sats"
staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload LM = "libats/SATS/linmap_avltree.sats"
staload _(*anon*) = "libats/DATS/linmap_avltree.dats"

(* ****** ****** *)

staload "./pats_symmap.sats"
staload _(*anon*) = "./pats_symmap.dats"
staload "./pats_symenv.sats"
staload _(*anon*) = "./pats_symenv.dats"

(* ****** ****** *)

staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"
staload "./pats_trans1_env.sats"

(* ****** ****** *)

#include "./pats_trans1_env_gen_dats.hats"

(* ****** ****** *)
//
vtypedef e1xpenv = symenv (e1xp)
//
// HX: the (never freed) environment, kept as a pointer
//
val the_e1xpenv_ptr = let
  val (pf | p) = symenv_make_nil<e1xp> ()
  prval () = $UN.castview0{void}(pf)
in
  p
end // end of [val]
//
(* ****** ****** *)

implement
the_e1xpenv_add
  (k, i) = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val () = symenv_insert<e1xp> (!p0, k, i)
  prval () = fpf (pf)
} // end of [the_e1xpenv_add]

implement
the_e1xpenv_addperv
  (k, i) = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val () = symenv_pervasive_insert<e1xp> (!p0, k, i)
  prval () = fpf (pf)
} // end of [the_e1xpenv_addperv]

implement
the_e1xpenv_find (k) = ans where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val ans = symenv_search<e1xp> (!p0, k)
  val ans = (
    case+ ans of
    | ~Some_vt (e) => Some_vt (e)
    | ~None_vt () => symenv_pervasive_search<e1xp> (!p0, k)
  ) : Option_vt (e1xp)
  prval () = fpf (pf)
} // end of [the_e1xpenv_find]

implement
the_e1xpenv_pop
  ((*none*)) = map where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val map = symenv_pop<e1xp> (!p0)
  prval () = fpf (pf)
} // end of [the_e1xpenv_pop]

implement
the_e1xpenv_push_nil
  ((*none*)) = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val () = symenv_push_nil<e1xp> (!p0)
  prval () = fpf (pf)
} // end of [the_e1xpenv_push_nil]

fun
the_e1xpenv_localjoin
  ((*none*)): void = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val () = symenv_localjoin<e1xp> (!p0)
  prval () = fpf (pf)
} // end of [the_e1xpenv_localjoin]

fun
the_e1xpenv_save
  ((*none*)): void = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val () = symenv_savecur<e1xp> (!p0)
  prval () = fpf (pf)
} // end of [the_e1xpenv_save]

fun
the_e1xpenv_restore
  ((*none*)): void = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{e1xpenv}(the_e1xpenv_ptr)
  val map = symenv_restore<e1xp> (!p0)
  val () = symmap_free<e1xp> (map)
  prval () = fpf (pf)
} // end of [the_e1xpenv_restore]

(* ****** ****** *)

implement
the_EXTERN_PREFIX_get () = let
//
macdef
EXTPRFX =
  $SYM.symbol_ATS_EXTERN_PREFIX
//
val opt = the_e1xpenv_find (EXTPRFX)
//
in
//
case+ opt of
| ~Some_vt (e) => let
    val nd = e.e1xp_node ()
  in
    if e1xp_node_is_E1XPnone (nd) then stropt_none ()
    else (
      case+ e1xp_node_view (nd) of
      | ~E1XPstring (x) => stropt_some (x)
      | v => let
          val () = e1xp_node_view_free (v)
          val () = prerr_warning1_loc (e.e1xp_loc ())
          val () = prerr ": a string definition is required for [ATS_EXTERN_PREFIX]."
          val () = prerr_newline ()
        in
          stropt_none ()
        end // end of [_]
    ) (* end of [else] *)
  end // end of [Some_vt]
| ~None_vt () =>
    stropt_none () // HX: [%] is kept to indicate a likely error
  // end of [None_vt]
//
end // end of [the_EXTERN_PREFIX_get]

implement
the_EXTERN_PREFIX_set (prfx) = let
  val e1xp = e1xp_string ($LOC.location_dummy, prfx)
  val () = the_e1xpenv_add ($SYM.symbol_ATS_EXTERN_PREFIX, e1xp)
in
  // nothing
end // end of [the_EXTERN_PREFIX_set]

implement
the_EXTERN_PREFIX_set_none () = let
  val e1xp = e1xp_none ($LOC.location_dummy)
  val () = the_e1xpenv_add ($SYM.symbol_ATS_EXTERN_PREFIX, e1xp)
in
  // nothing
end // end of [the_EXTERN_PREFIX_set_none]

(* ****** ****** *)

vtypedef fxtyenv = symenv ($FIX.fxty)
val the_fxtyenv_ptr = let
  val (pf | p) = symenv_make_nil<$FIX.fxty> ()
  prval () = $UN.castview0{void}(pf)
in
  p
end // end of [val]

implement
the_fxtyenv_add
  (k, i) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = symenv_insert<$FIX.fxty> (!p0, k, i)
  prval () = fpf (pf)
} // end of [the_fxtyenv_add]

implement
the_fxtyenv_find (k) = ans where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val ans = symenv_search<$FIX.fxty> (!p0, k)
  val ans = (
    case+ ans of
    | ~Some_vt (e) => Some_vt (e)
    | ~None_vt () => symenv_pervasive_search<$FIX.fxty> (!p0, k)
  ) : Option_vt ($FIX.fxty)
  prval () = fpf (pf)
} // end of [the_fxtyenv_find]

(* ****** ****** *)

implement
fprint_the_fxtyenv (out) = {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = fprint_symenv_map<$FIX.fxty> (out, !p0, $FIX.fprint_fxty)
  prval () = fpf (pf)
} // end of [fprint_the_fxtyenv]

(* ****** ****** *)

implement
the_fxtyenv_pop
  ((*none*)) = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val map = symenv_pop<$FIX.fxty> (!p0)
  prval () = fpf (pf)
} // end of [the_fxtyenv_pop]

implement
the_fxtyenv_push_nil
  ((*none*)) = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = symenv_push_nil<$FIX.fxty> (!p0)
  prval () = fpf (pf)
} // end of [the_fxtyenv_push_nil]

fun
the_fxtyenv_localjoin
  ((*none*)): void = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = symenv_localjoin<$FIX.fxty> (!p0)
  prval () = fpf (pf)
} // end of [the_fxtyenv_localjoin]

(* ****** ****** *)

implement
the_fxtyenv_pervasive_joinwth (map) =
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = symenv_pervasive_joinwth0<$FIX.fxty> (!p0, map)
  prval () = fpf (pf)
} // end of [the_fxtyenv_pervasive_joinwth]

(* ****** ****** *)

fun
the_fxtyenv_save
  ((*none*)): void = () where
{
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val () = symenv_savecur<$FIX.fxty> (!p0)
  prval () = fpf (pf)
} // end of [the_fxtyenv_save]

fun the_fxtyenv_restore
  ((*none*)): void = {
  val (pf, fpf | p0) = $UN.ptr0_vtake{fxtyenv}(the_fxtyenv_ptr)
  val map = symenv_restore<$FIX.fxty> (!p0)
  val () = symmap_free<$FIX.fxty> (map)
  prval () = fpf (pf)
} // end of [the_fxtyenv_restore]

(* ****** ****** *)

implement
the_trans1_env_pop
  ((*none*)) = () where {
  val map = the_e1xpenv_pop ((*none*))
  val () = symmap_free<e1xp> (map)
  val map = the_fxtyenv_pop ((*none*))
  val () = symmap_free<$FIX.fxty> (map)
} // end of [the_trans1_env_pop]

implement
the_trans1_env_push
  ((*none*)) = () where {
  val () = the_e1xpenv_push_nil ()
  val () = the_fxtyenv_push_nil ()
} // end of [the_trans1_env_pop]

implement
the_trans1_env_localjoin
  ((*none*)) = () where {
  val () = the_e1xpenv_localjoin ((*none*))
  val () = the_fxtyenv_localjoin ((*none*))
} // end of [the_trans1_env_localjoin]

(* ****** ****** *)

implement
the_trans1_env_save
  ((*none*)) = () where {
  val () = the_e1xpenv_save ()
  val () = the_fxtyenv_save ()
} // end of [the_trans1_env_save]

implement
the_trans1_env_restore
  ((*none*)) = () where {
  val () = the_e1xpenv_restore ()
  val () = the_fxtyenv_restore ()
} // end of [the_trans1_env_restore]

(* ****** ****** *)

local
//
typedef key = uint
typedef itm = @(int, d1eclist)
vtypedef map = $LM.map (key, itm)
//
// HX: the (never freed) table of the staloaded files, kept as a pointer
//
val theStaloadMap = let
  val map = $LM.linmap_make_nil<> ()
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, $UN.castvwtp0{ptr}(map))
in
  p
end // end of [val]
//
in (* in of [local] *)

implement
staload_file_search
  (fil) = let
//
val fname =
  $FIL.filename_get_fullname(fil)
//
val k0 = $SYM.symbol_get_stamp(fname)
//
val (pf, fpf | p) = $UN.ptr0_vtake{map}(theStaloadMap)
//
val res = $LM.linmap_search_opt<key,itm>(!p, k0)
//
prval () = fpf (pf)
//
in
  res
end // end of [staload_file_search]

(* ****** ****** *)

implement
staload_file_insert
  (fil, ldflag, d1cs) = {
//
val fname =
  $FIL.filename_get_fullname (fil)
//
val k0 = $SYM.symbol_get_stamp (fname)
//
val x0: itm = @(ldflag, d1cs)
//
val (pf, fpf | p) = $UN.ptr0_vtake{map}(theStaloadMap)
//
var res: itm?
val _(*isexi*) = $LM.linmap_insert<key,itm> (!p, k0, x0, res)
prval () = opt_clear {itm} (res)
//
prval () = fpf (pf)
//
} // end of [staload_file_insert]

end // end of [local]

(* ****** ****** *)

implement
fprint_atsrelocitm
  (out, itm) = let
//
macdef
prstr(s) =
fprint_string(out, ,(s))
//
fun
auxpr
(
  out: FILEref, d0c: d0ecl
) : void = let
  val nd = d0c.d0ecl_node ()
in
  if d0ecl_node_is_D0Cinclude nd then fprint_string (out, "include")
  else if d0ecl_node_is_D0Cstaload nd then fprint_string (out, "staload")
  else if d0ecl_node_is_D0Crequire nd then fprint_string (out, "require")
  else if d0ecl_node_is_D0Cdynload nd then fprint_string (out, "dynload")
  else fprint_string (out, "*ERROR*")
end // end of [auxpr]
//
in
//
case+ atsrelocitm_view (itm) of
| ~ATSRELOCITM
    (d0c, given) =>
  {
    val () = prstr "{\n"
    val () = prstr "\"atsreloc_kind\": "
    val () = prstr "\""
    val () = auxpr (out, d0c)
    val () = prstr "\""
    val () = prstr "\n,\n"
    val () = prstr "\"atsreloc_given\": "
    val () = prstr "\""
    val () = fprint_string (out, given)
    val () = prstr "\""
    val () = prstr "\n}\n"
  }
| ~ATSRELOCITM2
    (d0c, source, target) =>
  {
    val () = prstr "{\n"
    val () = prstr "\"atsreloc_kind\": "
    val () = prstr "\""
    val () = auxpr (out, d0c)
    val () = prstr "\""
    val () = prstr "\n,\n"
    val () = prstr "\"atsreloc_target\": "
    val () = prstr "\""
    val () = fprint_string (out, target)
    val () = prstr "\""
    val () = prstr "\n,\n"
    val () = prstr "\"atsreloc_source\": "
    val () = prstr "\""
    val () = fprint_string (out, source)
    val () = prstr "\""
    val () = prstr "\n}\n"
  }
//
end // end of [fprint_atsrelocitm]

implement
fprint_atsrelocitmlst
  (out, xs) = let
in
//
case+ glist_view (xs) of
| ~GLnil () => ()
| ~GLcons (x, xs) => (
    fprint_atsrelocitm (out, x); fprint_atsrelocitmlst (out, xs)
  ) (* end of [GLcons] *)
//
end // end of [fprint_atsrelocitmlst]

(* ****** ****** *)

(* HX: the list of the items is kept (reversed) in a cell of the global arena *)

val the_itmlst = let
  val p = the_garena_alloc (sizeof<atsrelocitmlst>)
  val () = $UN.ptr0_set<atsrelocitmlst> (p, glist_nil ())
in
  p
end // end of [val]

implement
the_atsrelocitmlst_get () = let
  val xs = $UN.ptr0_get<atsrelocitmlst> (the_itmlst)
  val () = $UN.ptr0_set<atsrelocitmlst> (the_itmlst, glist_nil ())
in
  glist_reverse (xs)
end // end of [the_itmlst_get]

(* ****** ******* *)

implement
the_atsreloc_insert
  (d0c0, given) = let
//
val
loc0 = d0c0.d0ecl_loc ()
//
val itm =
atsrelocitm_ATSRELOCITM(d0c0, given)
val ((*void*)) =
$UN.ptr0_set<atsrelocitmlst> (the_itmlst, glist_cons (itm, $UN.ptr0_get<atsrelocitmlst> (the_itmlst)))
//
in
  // nothing
end // end of [the_atsreloc_insert]

implement
the_atsreloc_insert2
  (d0c0, given_s, given_t) = let
//
val
loc0 = d0c0.d0ecl_loc ()
//
val itm =
atsrelocitm_ATSRELOCITM2(d0c0, given_s, given_t)
//
val () =
$UN.ptr0_set<atsrelocitmlst> (the_itmlst, glist_cons (itm, $UN.ptr0_get<atsrelocitmlst> (the_itmlst)))
//
in
  // nothing
end // end of [the_atsreloc_insert2]

(* ****** ****** *)

%{^
//
extern
atstype_ptr patsopt_PATSHOME_get() ;
extern
atstype_ptr patsopt_PATSCONTRIB_get() ;
//
%} // end of [%{^]

implement
the_trans1_env_initialize
  ((*void*)) =
{
//
val
opt = get() where
{
  extern
  fun get(): Stropt = "mac#patsopt_PATSHOME_get"
} (* end of [val] *)
//
val
issome =
stropt_is_some(opt)
//
val () =
if issome then let
  val k = $SYM.symbol_PATSHOME
  val x = e1xp_string($LOC.location_dummy, stropt_unsome(opt))
in
  the_e1xpenv_addperv(k, x)
end // end of [if] // end of [val]
//
val opt = get() where
{
  extern fun get(): Stropt = "mac#patsopt_PATSCONTRIB_get"
} (* end of [val] *)
val issome = stropt_is_some (opt)
val () =
if issome then let
  val k = $SYM.symbol_PATSCONTRIB
  val x = e1xp_string($LOC.location_dummy, stropt_unsome(opt))
in
  the_e1xpenv_addperv(k, x)
end // end of [if] // end of [val]
//
} (* end of [the_trans1_env_initialize] *)

(* ****** ****** *)

(* end of [pats_trans1_env.dats] *)
