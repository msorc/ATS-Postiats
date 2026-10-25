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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_scst.dats, see PORTING.md)
// The cell of ATS1 ([ref (s2cst_struct)]) is the record [s2cst] of pats_staexp2.spec:
// the fields that are assigned later have a setter. Nothing is freed.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload
GLOB = "./pats_global.sats"

(* ****** ****** *)

staload
STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp

(* ****** ****** *)

staload FIL = "./pats_filename.sats"
staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
typedef symbolopt = $SYM.symbolopt

(* ****** ****** *)

staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

local
//
fun
s2rt_get_arylst
(
  s2t: s2rt
) : glist(int) =
(
case+ s2rt_viewof (s2t) of
| ~S2RTfun(s2ts, s2t) => let
    val n0 = glist_length(s2ts)
  in
    glist_cons(n0, s2rt_get_arylst(s2t))
  end (* end of [S2RTfun] *)
| v (*non-S2RTfun*) => (s2rt_view_free (v); glist_nil((*void*)))
) // end of [s2rt_get_arylst]

in (* in of [local] *)

implement
s2cst_make
(
  id
, loc, fil, s2t
, isabs, iscon, isrec, isasp, islst
, argsrtss, def
) = let
//
val pack = $GLOB.the_PACKNAME_get ()
val stamp = $STMP.s2cst_stamp_make ()
//
in
//
s2cst_new
(
  id, loc, fil, s2t
, def, pack
, isabs, iscon, isrec, isasp
, gopt_none() // iscpy
, islst
, s2rt_get_arylst(s2t)
, argsrtss
, gopt_none() // dconlst
, glist_nil() // sup
, glist_nil() // supcls
, s2Varset_nil() // sVarset
, (~1) // dstag: datasort
, stamp // unicity
, $SYN.scstextdef_SCSTEXTDEFnone()
) (* end of [s2cst_new] *)
//
end // end of [s2cst_make]

end // end of [local]

(* ****** ****** *)

implement
s2cst_get_sym(s2c) = s2cst_sym (s2c)
implement
s2cst_get_loc(s2c) = s2cst_loc (s2c)
implement
s2cst_get_fil(s2c) = s2cst_fil (s2c)
implement
s2cst_get_srt(s2c) = s2cst_srt (s2c)

(* ****** ****** *)

implement
s2cst_get_def(s2c) = s2cst_def (s2c)
implement
s2cst_set_def(s2c, opt) = set_s2cst_def (s2c, opt)

(* ****** ****** *)

implement
s2cst_get_pack(s2c) = s2cst_pack (s2c)

(* ****** ****** *)

implement
s2cst_get_isabs(s2c) = s2cst_isabs (s2c)

(* ****** ****** *)
//
// HX-2017-02-01:
// This one is for internal use!
//
extern
fun
s2cst_set_isabs
(
x0: s2cst, opt: s2expopt
) : void = "ext#patsopts2cst_set_isabs"
//
implement
s2cst_set_isabs(s2c, opt) =
  set_s2cst_isabs (s2c, gopt_some(opt))
//
(* ****** ****** *)

implement
s2cst_get_iscon(s2c) = s2cst_iscon (s2c)

implement
s2cst_get_isrec(s2c) = s2cst_isrec (s2c)

(* ****** ****** *)

implement
s2cst_get_isasp(s2c) = s2cst_isasp (s2c)
implement
s2cst_set_isasp(s2c, isasp) = set_s2cst_isasp (s2c, isasp)

(* ****** ****** *)

implement
s2cst_get_iscpy(s2c) = s2cst_iscpy (s2c)
implement
s2cst_set_iscpy(s2c, opt) = set_s2cst_iscpy (s2c, opt)

(* ****** ****** *)

implement
s2cst_get_arylst(s2c) = s2cst_arylst (s2c)

implement
s2cst_get_argsrtss(s2c) = s2cst_argsrtss (s2c)

(* ****** ****** *)

implement
s2cst_get_islst(s2c) = s2cst_islst (s2c)
implement
s2cst_set_islst(s2c, islst) = set_s2cst_islst (s2c, islst)

(* ****** ****** *)

implement
s2cst_get_dconlst(s2c) = s2cst_dconlst (s2c)
implement
s2cst_set_dconlst(s2c, d2cs) = set_s2cst_dconlst (s2c, d2cs)

(* ****** ****** *)

implement
s2cst_get_sup(s2c) = s2cst_sup (s2c)
implement
s2cst_add_sup(s2c, sup) =
  set_s2cst_sup (s2c, glist_cons(sup, s2cst_sup (s2c)))
// end of [s2cst_sup_add]

(* ****** ****** *)

implement
s2cst_get_supcls(s2c) = s2cst_supcls (s2c)
implement
s2cst_add_supcls(s2c, sup) =
  set_s2cst_supcls (s2c, glist_cons(sup, s2cst_supcls (s2c)))
// end of [s2cst_supcls_add]

(* ****** ****** *)

implement
s2cst_get_sVarset(s2c) = s2cst_sVarset (s2c)
implement
s2cst_set_sVarset(s2c, s2Vs) = set_s2cst_sVarset (s2c, s2Vs)

(* ****** ****** *)

implement
s2cst_get_dstag(s2c) = s2cst_dstag (s2c)
implement
s2cst_set_dstag(s2c, tag) = set_s2cst_dstag (s2c, tag)

(* ****** ****** *)

implement
s2cst_get_stamp(s2c) = s2cst_stamp (s2c)

(* ****** ****** *)

implement
s2cst_get_extdef(s2c) = s2cst_extdef (s2c)
implement
s2cst_set_extdef(s2c, xdef) = set_s2cst_extdef (s2c, xdef)

(* ****** ****** *)

implement
s2cst_get_name(s2c) =
  $SYM.symbol_get_name(s2cst_get_sym(s2c))
// end of [s2cst_get_name]

(* ****** ****** *)

implement
s2cst_make_dat
(
  id0, loc, s2tss_arg, s2t_res, argsrtss
) = let
//
fun aux (
  xs: s2rtlstlst, s2t: s2rt
) : s2rt =
(
  case+ glist_view (xs) of
  | ~GLcons
      (x, xs) => s2rt_fun(x, aux(xs, s2t))
    // list_cons
  | ~GLnil((*void*)) => s2t
) (* end of [aux] *)
//
val s2t_fun = aux(s2tss_arg, s2t_res)
//
in
//
s2cst_make
(
  id0 // name
, loc // location
, $FIL.filename_dummy
, s2t_fun // sort
, gopt_none () // isabs
, true // iscon
, false // isrec
, gopt_none () // isasp
, gopt_none () // islst
, argsrtss // argsortlstlst
, gopt_none () // definition
) (* end of [s2cst_make] *)
//
end // end of [s2cst_make_dat]

(* ****** ****** *)

implement
lt_s2cst_s2cst
  (x1, x2) = (compare_s2cst_s2cst(x1, x2) < 0)
// end of [lt_s2cst_s2cst]

implement
lte_s2cst_s2cst
  (x1, x2) = (compare_s2cst_s2cst(x1, x2) <= 0)
// end of [lte_s2cst_s2cst]

implement
eq_s2cst_s2cst
  (x1, x2) = (compare_s2cst_s2cst(x1, x2) = 0)
// end of [eq_s2cst_s2cst]

implement
neq_s2cst_s2cst
  (x1, x2) = (compare_s2cst_s2cst(x1, x2) != 0)
// end of [neq_s2cst_s2cst]

implement
compare_s2cst_s2cst(x1, x2) =
(
//
$effmask_all
(
  compare(s2cst_get_stamp(x1), s2cst_get_stamp(x2))
) (* $effmask_all *)
//
) (* end of [compare_s2cst_s2cst] *)

(* ****** ****** *)

implement
s2cst_is_def(x) = let
  val isdef = s2cst_get_def(x)
in
  gopt_is_some (isdef)
end // end of [s2cst_is_defined]

(* ****** ****** *)

implement
s2cst_is_abstr(x) = let
  val isabs = s2cst_get_isabs(x)
in
  gopt_is_some (isabs)
end // end of [s2cst_is_abstract]

(* ****** ****** *)

implement
s2cst_is_tkind(x) =
  s2rt_is_tkind_fun (s2cst_get_srt(x))
// end of [s2cst_is_tkind]

(* ****** ****** *)

implement
s2cst_is_tydef(s2c) =
(
//
if s2cst_is_def(s2c)
  then s2rt_is_prgm_fun(s2cst_get_srt(s2c)) else false
//
) (* end of [s2cst_is_tydef] *)

implement
s2cst_is_datype(s2c) =
(
//
if s2cst_is_abstr(s2c) then false else s2cst_get_iscon(s2c)
//
) (* end of [s2cst_is_datype] *)

(* ****** ****** *)

implement
s2cst_is_tagless(x) = (
  case+ 0 of
  | _ when s2cst_is_listlike(x) => true
  | _ when s2cst_is_singular(x) => true
  | _ (*non-listlist-singular*) => false
) // end of [s2cst_is_tagless]

implement
s2cst_is_listlike(x) = let
  val opt = s2cst_get_islst(x)
in
  gopt_is_some (opt)
end // end of [s2cst_is_listlike]

implement
s2cst_is_singular(s2c) = let
  val opt = s2cst_get_dconlst (s2c)
in
  case+ gopt_view (opt) of
  | ~GOsome d2cs => glist_is_sing<d2con> (d2cs) | ~GOnone() => false
end // end of [s2cst_is_singular]

implement
s2cst_is_binarian(s2c) = let
  val opt = s2cst_get_dconlst (s2c)
in
  case+ gopt_view (opt) of
  | ~GOsome d2cs => glist_is_pair<d2con> (d2cs) | ~GOnone() => false
end // end of [s2cst_is_binarian]

(* ****** ****** *)
//
implement
s2cst_is_linear(s2c) =
  s2rt_is_lin_fun(s2cst_get_srt(s2c))
//
implement
s2cst_is_nonlinear(s2c) =
  if s2cst_is_linear(s2c) then false else true
//
(* ****** ****** *)

implement
s2cst_subeq
  (s2c1, s2c2) = let
fun aux (
  s2c1: s2cst, s2c2: s2cst
) : bool =
  if s2c1 = s2c2 then
    true else auxlst (s2cst_get_sup (s2c1), s2c2)
  // end of [if]
and auxlst (
  s2cs1: s2cstlst, s2c2: s2cst
) : bool =
  case+ glist_view (s2cs1) of
  | ~GLcons
      (s2c1, s2cs1) =>
      if aux (s2c1, s2c2) then true else auxlst (s2cs1, s2c2)
  | ~GLnil ((*void*)) => false
// end of [auxlst]
//
val res = aux (s2c1, s2c2)
in
  res
end // end of [s2cst_subeq]

(* ****** ****** *)

implement
s2cst_lte_cls_cls
  (s2c1, s2c2) = let
fun
aux (
  s2c1: s2cst, s2c2: s2cst
) : bool = let
in
  if s2c1 = s2c2 then
    true else auxlst (s2cst_get_supcls (s2c1), s2c2)
  // end of [if]
end // end of [aux]
//
and
auxlst (
  s2es1: s2explst, s2c2: s2cst
) : bool = let
in
  case+ glist_view (s2es1) of
  | ~GLcons
      (s2e1, s2es1) =>
    (
      case+ s2exp_node_view (s2exp_node (s2e1)) of
      | ~S2Ecst (s2c1) =>
          if aux (s2c1, s2c2) then true else auxlst (s2es1, s2c2)
      | v (*nonconst*) => (s2exp_node_view_free (v); auxlst (s2es1, s2c2))
    ) (* end of list_cons *)
  | ~GLnil ((*void*)) => false
end // end of [auxlst]
//
val res = aux (s2c1, s2c2)
in
  res
end // end of [s2cst_lte_cls_cls]

(* ****** ****** *)

implement
fprint_s2cst
  (out, x) = let
  val sym = s2cst_get_sym (x)
in
  $SYM.fprint_symbol (out, sym)
end // end of [fprint_s2cst]

implement print_s2cst (x) = fprint_s2cst (stdout_ref, x)
implement prerr_s2cst (x) = fprint_s2cst (stderr_ref, x)

implement
fprint_s2cstlst
  (out, xs) = $UT.fprintlst<s2cst> (out, xs, ", ", fprint_s2cst)
// end of [fprint_s2cstlst]

implement
print_s2cstlst (xs) = fprint_s2cstlst (stdout_ref, xs)
implement
prerr_s2cstlst (xs) = fprint_s2cstlst (stderr_ref, xs)

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_s2cst_s2cst ($UN.cast{s2cst} (x1), $UN.cast{s2cst} (x2))
//
fn
ins (xs: avlmap, x: s2cst): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
//
in (* in-of-local *)

implement
s2cstset_nil
  ((*void*)) = $UN.cast{s2cstset} (avlmap_nil ())
//
implement
s2cstset_ismem
  (xs, x) = $effmask_all (avlmap_ismem ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), cmp))
//
implement
s2cstset_add
  (xs, x) = $UN.cast{s2cstset} (ins ($UN.cast{avlmap} (xs), x))
// end of [s2cstset_add]
//
implement
s2cstset_listize (xs) =
  $UN.castvwtp0{s2cstlst_vt} (avlmap_keys ($UN.cast{avlmap} (xs)))

(* ****** ****** *)

implement
s2cstset_vt_nil
  ((*void*)) = $UN.castvwtp0{s2cstset_vt} (avlmap_nil ())
//
implement
s2cstset_vt_ismem
  (xs, x) = $effmask_all (
  avlmap_ismem ($UN.castvwtp1{avlmap} (xs), $UN.cast{ptr} (x), cmp)
) (* end of [s2cstset_vt_ismem] *)
//
implement
s2cstset_vt_add
  (xs, x) = $UN.castvwtp0{s2cstset_vt}
  (ins ($UN.castvwtp0{avlmap} (xs), x))
// end of [s2cstset_vt_add]
//
implement
s2cstset_vt_listize_free (xs) =
  $UN.castvwtp0{s2cstlst_vt} (avlmap_keys ($UN.castvwtp0{avlmap} (xs)))

end // end of [local]

(* ****** ****** *)

implement
compare_s2cst_ptr (x1, x2) =
  compare_s2cst_s2cst ($UN.cast{s2cst} (x1), $UN.cast{s2cst} (x2))

implement{a}
s2cstmap_nil () = $UN.cast{s2cstmap(a)} (avlmap_nil ())

implement{a}
s2cstmap_add
  (map, s2c, itm) = $effmask_all (
  $UN.cast{s2cstmap(a)}
  (avlmap_insert ($UN.cast{avlmap} (map), $UN.cast{ptr} (s2c), $UN.cast{ptr} (itm), compare_s2cst_ptr))
) // end of [s2cstmap_add]

implement{a}
s2cstmap_find
  (map, s2c) = $effmask_all let
  var res: ptr?
  val found = avlmap_find ($UN.cast{avlmap} (map), $UN.cast{ptr} (s2c), compare_s2cst_ptr, res)
in
  if found then Some_vt ($UN.cast{a} (res)) else None_vt ((*empty*))
end // end of [s2cstmap_find]



(* ****** ****** *)

(* end of [pats_staexp2_scst.dats] *)
