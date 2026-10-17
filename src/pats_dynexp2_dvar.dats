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
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2_dvar.dats, see PORTING.md)
// The cell of ATS1 ([ref (d2var_struct)]) is the record [d2var] of pats_dynexp2.spec (the field
// [d2var_view], [d2varopt2] in ATS1, is a plain [d2varopt]). The sets and the maps are
// persistent AVL trees of pats_avlmap.sats (nothing is freed).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload
STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
typedef symbolopt = $SYM.symbolopt

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

implement
d2var_make
  (loc, id) = let
//
val stamp = $STMP.d2var_stamp_make ()
//
in
//
d2var_new
(
  id, loc
, ~1 // level: toplevel is 0
, ~1 // linval: nonlinear (-1) and linear (>=0)
, false // isfix
, false // isprf
, glist_nil((*void*)) // decarg
, gopt_none((*void*)) // addr
, gopt_none((*void*)) // view
, d2vfin_D2VFINnone() // finknd
, gopt_none((*void*)) // type
, gopt_none((*void*)) // hisexp
, gopt_none((*void*)) // mastype
, 0 // utimes
, stamp
) (* end of [d2var_new] *)
//
end // end of [d2var_make]

(* ****** ****** *)

implement
d2var_make_any
  (loc) = d2var_make (loc, $SYM.symbol_UNDERSCORE)
// end of [d2var_make_any]

(* ****** ****** *)

implement
d2var_get_sym (d2v) = $effmask_all (d2var_sym (d2v))

implement
d2var_get_loc (d2v) = $effmask_all (d2var_loc (d2v))

implement
d2var_get_level (d2v) = $effmask_all (d2var_level (d2v))
implement
d2var_set_level (d2v, lev) = set_d2var_level (d2v, lev)

implement
d2var_get_linval (d2v) = $effmask_all (d2var_linval (d2v))
implement
d2var_set_linval (d2v, lin) = set_d2var_linval (d2v, lin)

implement
d2var_get_isfix (d2v) = $effmask_all (d2var_isfix (d2v))
implement
d2var_set_isfix (d2v, isfix) = set_d2var_isfix (d2v, isfix)

implement
d2var_get_isprf (d2v) = $effmask_all (d2var_isprf (d2v))
implement
d2var_set_isprf (d2v, isprf) = set_d2var_isprf (d2v, isprf)

implement
d2var_get_decarg (d2v) = $effmask_all (d2var_decarg (d2v))
implement
d2var_set_decarg (d2v, decarg) = set_d2var_decarg (d2v, decarg)

implement
d2var_get_addr (d2v) = $effmask_all (d2var_addr (d2v))
implement
d2var_set_addr (d2v, s2fopt) = set_d2var_addr (d2v, s2fopt)

implement
d2var_get_view (d2v) = $effmask_all (d2var_view (d2v))
implement
d2var_set_view (d2v, opt) = set_d2var_view (d2v, opt)

implement
d2var_get_finknd (d2v) = $effmask_all (d2var_finknd (d2v))
implement
d2var_set_finknd (d2v, knd) = set_d2var_finknd (d2v, knd)

(* ****** ****** *)

implement
d2var_get_type (d2v) = $effmask_all (d2var_type (d2v))
implement
d2var_set_type (d2v, opt) = set_d2var_type (d2v, opt)

(* ****** ****** *)

implement
d2var_get_mastype (d2v) = $effmask_all (d2var_mastype (d2v))
implement
d2var_set_mastype (d2v, opt) = set_d2var_mastype (d2v, opt)

(* ****** ****** *)

implement
d2var_get_hisexp (d2v) = $effmask_all (d2var_hisexp (d2v))
implement
d2var_set_hisexp (d2v, opt) = set_d2var_hisexp (d2v, opt)

(* ****** ****** *)

implement
d2var_get_utimes (d2v) = $effmask_all (d2var_utimes (d2v))
implement
d2var_set_utimes (d2v, nused) = $effmask_all (set_d2var_utimes (d2v, nused))

implement
d2var_get_stamp (d2v) = $effmask_all (d2var_stamp (d2v))

(* ****** ****** *)

implement
d2var_inc_linval (d2v) = let
  val lin = d2var_get_linval (d2v) in d2var_set_linval (d2v, lin+1)
end // end of [d2var_inc_linval]

implement
d2var_inc_utimes (d2v) = $effmask_all let
  val nused = d2var_get_utimes (d2v) in d2var_set_utimes (d2v, nused+1)
end // end of [d2var_inc_utimes]

(* ****** ****** *)
//
implement
d2var_is_linear (d2v) = (d2var_get_linval d2v >= 0)
implement
d2var_is_linprf (d2v) =
if d2var_get_isprf(d2v) then d2var_is_linear(d2v) else false
//
implement
d2var_is_mutabl (d2v) = gopt_is_some (d2var_get_view d2v)
// end of [d2var_is_mutabl]
//
(* ****** ****** *)

implement
eq_d2var_d2var (x1, x2) = (compare_d2var_d2var (x1, x2) = 0)
implement
neq_d2var_d2var (x1, x2) = (compare_d2var_d2var (x1, x2) != 0)

(* ****** ****** *)

implement
compare_d2var_d2var (x1, x2) =
  $effmask_all (compare (d2var_get_stamp (x1), d2var_get_stamp (x2)))
// end of [compare_d2var_d2var]

implement
compare_d2vsym_d2vsym
  (x1, x2) = $effmask_all (
  $SYM.compare_symbol_symbol (d2var_get_sym (x1), d2var_get_sym (x2))
) // end of [compare_d2vsym_d2vsym]

(* ****** ****** *)

implement
d2var_exch_type
  (d2v, _new) = _old where {
  val _old =
    d2var_get_type (d2v)
  // end of [val]
  val () = d2var_set_type (d2v, _new)
} // end of [d2var_exch_type]

(* ****** ****** *)

implement
d2var_ptr_viewat_make
  (ptr, opt) = d2vw where {
  val loc = d2var_get_loc (ptr)
  and sym = d2var_get_sym (ptr)
  val d2vw = (
    case+ gopt_view (opt) of
    | ~GOsome d2vw => d2vw
    | ~GOnone () => let
       val nam = $SYM.symbol_get_name (sym)
       val nam1 = string0_append (nam, "$view")
       val sym1 = $SYM.symbol_make_string ($UN.strptr2string (nam1))
       val () = strptr_free (nam1)
     in
       d2var_make (loc, sym1)
     end // end of [None]
  ) : d2var // end of [val]
//
  val () = d2var_set_linval (d2vw, 0)
  val () = d2var_set_addr (d2vw, d2var_get_addr ptr)
//
} // end of [d2var_ptr_viewat_make]

implement
d2var_ptr_viewat_make_none
  (d2v_ptr) = d2var_ptr_viewat_make (d2v_ptr, gopt_none((*void*)))
// end of [d2var_ptr_viewat_make_none]

(* ****** ****** *)

implement
print_d2var (d2v) = fprint_d2var (stdout_ref, d2v)
implement
prerr_d2var (d2v) = fprint_d2var (stderr_ref, d2v)

implement
fprint_d2var
  (out, d2v) = {
//
val () =
  $SYM.fprint_symbol (out, d2var_get_sym d2v)
//
val () = fprint_string (out, "$")
val () = $STMP.fprint_stamp (out, d2var_get_stamp d2v)
//
val () = fprint_string (out, "(")
val () = fprint_int (out, d2var_get_level d2v)
val () = fprint_string (out, ")")
//
} (* end of [fprint_d2var] *)

implement
fprint_d2varlst
  (out, d2vs) = $UT.fprintlst<d2var> (out, d2vs, ", ", fprint_d2var)
// end of [fprint_d2varlst]

(* ****** ****** *)

implement
print_d2vfin (x) = fprint_d2vfin (stdout_ref, x)
implement
prerr_d2vfin (x) = fprint_d2vfin (stderr_ref, x)

implement
fprint_d2vfin
  (out, d2vfin) = let
//
macdef
prstr (str) = fprint_string (out, ,(str))
//
in
//
case+ d2vfin_view (d2vfin) of
| ~D2VFINnone () =>
    prstr "D2VFINnone()"
| ~D2VFINsome (s2e) => {
    val () = prstr "D2VFINsome("
    val () = fprint_s2exp (out, s2e)
    val () = prstr ")"
  }
| ~D2VFINsome_lvar (s2e) => {
    val () = prstr "D2VFINsome_lvar("
    val () = fprint_s2exp (out, s2e)
    val () = prstr ")"
  }
| ~D2VFINsome_vbox (s2e) => {
    val () = prstr "D2VFINsome_vbox("
    val () = fprint_s2exp (out, s2e)
    val () = prstr ")"
  }
| ~D2VFINdone (d2vfin) => {
    val () = prstr "D2VFINdone("
    val () = fprint_d2vfin (out, d2vfin)
    val () = prstr ")"
  } (* end of [D2FINdone] *)
//
end // end of [fprint_d2vfin]

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_d2var_d2var ($UN.cast{d2var} (x1), $UN.cast{d2var} (x2))
//
fn
ins (xs: avlmap, x: d2var): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
//
in (* in-of-local *)

implement
d2varset_nil
  ((*void*)) = $effmask_all ($UN.cast{d2varset} (avlmap_nil ()))
//
implement
d2varset_ismem
  (xs, x) = $effmask_all (avlmap_ismem ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), cmp))
//
implement
d2varset_add
  (xs, x) = $effmask_all ($UN.cast{d2varset} (ins ($UN.cast{avlmap} (xs), x)))
// end of [d2varset_add]
//
implement
d2varset_listize (xs) =
  $effmask_all ($UN.castvwtp0{d2varlst_vt} (avlmap_keys ($UN.cast{avlmap} (xs))))

(* ****** ****** *)

implement
d2varset_vt_nil
  ((*void*)) = $effmask_all ($UN.castvwtp0{d2varset_vt} (avlmap_nil ()))
//
implement
d2varset_vt_free (xs) = $effmask_all (
  let val _ = $UN.castvwtp0{ptr} (xs) in () end
) (* end of [d2varset_vt_free] *)
//
implement
d2varset_vt_ismem
  (xs, x) = $effmask_all (
  avlmap_ismem ($UN.castvwtp1{avlmap} (xs), $UN.cast{ptr} (x), cmp)
) (* end of [d2varset_vt_ismem] *)
//
implement
d2varset_vt_add
  (xs, x) = $effmask_all ($UN.castvwtp0{d2varset_vt}
  (ins ($UN.castvwtp0{avlmap} (xs), x)))
// end of [d2varset_vt_add]
//
implement
d2varset_vt_listize (xs) =
  $effmask_all ($UN.castvwtp0{d2varlst_vt} (avlmap_keys ($UN.castvwtp1{avlmap} (xs))))
implement
d2varset_vt_listize_free (xs) =
  $effmask_all ($UN.castvwtp0{d2varlst_vt} (avlmap_keys ($UN.castvwtp0{avlmap} (xs))))

end // end of [local]

(* ****** ****** *)

implement
fprint_d2varset
  (out, d2vset) = {
//
val xs = d2varset_listize (d2vset)
val () = $UT.fprintlst<d2var> (out, glist_make_list_vt (xs), ", ", fprint_d2var)
//
} // end of [fprint_d2varset]

(* ****** ****** *)

implement
compare_d2var_ptr (x1, x2) =
  compare_d2var_d2var ($UN.cast{d2var} (x1), $UN.cast{d2var} (x2))

implement
d2varmap_zip_ptr (ks, vs) =
(
case+ ks of
| ~list_vt_cons (k, ks1) => (
  case+ vs of
  | ~list_vt_cons (v, vs1) =>
      list_vt_cons (@($UN.cast{d2var} (k), v), d2varmap_zip_ptr (ks1, vs1))
  | ~list_vt_nil () => (list_vt_free (ks1); list_vt_nil ())
  )
| ~list_vt_nil () => (list_vt_free (vs); list_vt_nil ())
) (* end of [d2varmap_zip_ptr] *)

(* ****** ****** *)

implement{a}
d2varmap_nil () = $effmask_all ($UN.cast{d2varmap(a)} (avlmap_nil ()))

implement{a}
d2varmap_search
  (map, d2v) = $effmask_all let
  var res: ptr?
  val found = avlmap_find ($UN.cast{avlmap} (map), $UN.cast{ptr} (d2v), compare_d2var_ptr, res)
in
  if found then Some_vt ($UN.cast{a} (res)) else None_vt ((*empty*))
end // end of [d2varmap_search]

implement{a}
d2varmap_insert
  (map, d2v, x) = $effmask_all let
  val m = $UN.cast{avlmap} (map)
  val found = avlmap_ismem (m, $UN.cast{ptr} (d2v), compare_d2var_ptr)
  val () = map := $UN.cast{d2varmap(a)}
    (avlmap_insert (m, $UN.cast{ptr} (d2v), $UN.cast{ptr} (x), compare_d2var_ptr))
in
  found
end // end of [d2varmap_insert]

implement{a}
d2varmap_listize (map) = $effmask_all let
  val m = $UN.cast{avlmap} (map)
in
  $UN.castvwtp0{List0_vt(@(d2var, a))} (d2varmap_zip_ptr (avlmap_keys (m), avlmap_vals (m)))
end // end of [d2varmap_listize]

(* ****** ****** *)

implement{a}
d2varmap_vt_nil () = $effmask_all ($UN.castvwtp0{d2varmap_vt(a)} (avlmap_nil ()))

implement{a}
d2varmap_vt_free (map) = $effmask_all (
  let val _ = $UN.castvwtp0{ptr} (map) in () end
) (* end of [d2varmap_vt_free] *)

implement{a}
d2varmap_vt_search
  (map, d2v) = $effmask_all let
  var res: ptr?
  val found = avlmap_find ($UN.castvwtp1{avlmap} (map), $UN.cast{ptr} (d2v), compare_d2var_ptr, res)
in
  if found then Some_vt ($UN.cast{a} (res)) else None_vt ((*empty*))
end // end of [d2varmap_vt_search]

implement{a}
d2varmap_vt_insert
  (map, d2v, x) = $effmask_all let
  val m = $UN.castvwtp0{avlmap} (map)
  val found = avlmap_ismem (m, $UN.cast{ptr} (d2v), compare_d2var_ptr)
  val () = map := $UN.castvwtp0{d2varmap_vt(a)}
    (avlmap_insert (m, $UN.cast{ptr} (d2v), $UN.cast{ptr} (x), compare_d2var_ptr))
in
  found
end // end of [d2varmap_vt_insert]

implement{a}
d2varmap_vt_remove
  (map, d2v) = $effmask_all let
  val m = $UN.castvwtp0{avlmap} (map)
  val found = avlmap_ismem (m, $UN.cast{ptr} (d2v), compare_d2var_ptr)
  val () = map := $UN.castvwtp0{d2varmap_vt(a)}
    (avlmap_remove (m, $UN.cast{ptr} (d2v), compare_d2var_ptr))
in
  found
end // end of [d2varmap_vt_remove]

implement{a}
d2varmap_vt_listize (map) = $effmask_all let
  val m = $UN.castvwtp1{avlmap} (map)
in
  $UN.castvwtp0{List0_vt(@(d2var, a))} (d2varmap_zip_ptr (avlmap_keys (m), avlmap_vals (m)))
end // end of [d2varmap_vt_listize]

(* ****** ****** *)
//
// HX: a map from d2var to a stack of items (the values of the avlmap are [glist(ptr)])
//
implement{a}
d2varmaplst_vt_nil () = $effmask_all ($UN.castvwtp0{d2varmaplst_vt(a)} (avlmap_nil ()))

implement{a}
d2varmaplst_vt_free (map) = $effmask_all (
  let val _ = $UN.castvwtp0{ptr} (map) in () end
) (* end of [d2varmaplst_vt_free] *)

implement{a}
d2varmaplst_vt_search
  (map, d2v) = $effmask_all let
  var res: ptr?
  val found = avlmap_find ($UN.castvwtp1{avlmap} (map), $UN.cast{ptr} (d2v), compare_d2var_ptr, res)
in
  if found then let
    val xs = $UN.cast{glist(ptr)} (res)
  in
    if glist_is_cons (xs)
      then Some_vt ($UN.cast{a} (glist_head<ptr> (xs))) else None_vt ()
  end else None_vt ((*empty*))
end // end of [d2varmaplst_vt_search]

implement{a}
d2varmaplst_vt_insert
  (map, d2v, x0) = $effmask_all let
  val m = $UN.castvwtp0{avlmap} (map)
  var res: ptr?
  val found = avlmap_find (m, $UN.cast{ptr} (d2v), compare_d2var_ptr, res)
  val xs = (
    if found then $UN.cast{glist(ptr)} (res) else glist_nil{ptr} ()
  ) : glist(ptr)
  val xs = glist_cons<ptr> ($UN.cast{ptr} (x0), xs)
  val () = map := $UN.castvwtp0{d2varmaplst_vt(a)}
    (avlmap_insert (m, $UN.cast{ptr} (d2v), $UN.cast{ptr} (xs), compare_d2var_ptr))
in
  found
end // end of [d2varmaplst_vt_insert]

implement{a}
d2varmaplst_vt_remove
  (map, d2v) = $effmask_all let
  val m = $UN.castvwtp0{avlmap} (map)
  var res: ptr?
  val found = avlmap_find (m, $UN.cast{ptr} (d2v), compare_d2var_ptr, res)
  val m = (
    if found then let
      val xs = $UN.cast{glist(ptr)} (res)
      val xs1 = glist_tail<ptr> (xs)
    in
      if glist_is_cons (xs1)
        then avlmap_insert (m, $UN.cast{ptr} (d2v), $UN.cast{ptr} (xs1), compare_d2var_ptr)
        else avlmap_remove (m, $UN.cast{ptr} (d2v), compare_d2var_ptr)
    end else m
  ) : avlmap
  val () = map := $UN.castvwtp0{d2varmaplst_vt(a)} (m)
in
  found
end // end of [d2varmaplst_vt_remove]

(* ****** ****** *)

(* end of [pats_dynexp2_dvar.dats] *)
