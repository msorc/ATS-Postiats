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
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2_dcst.dats, see PORTING.md)
// The cell of ATS1 ([ref (d2cst_struct)]) is the record [d2cst] of pats_dynexp2.spec.
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

staload "./pats_basics.sats"

(* ****** ****** *)

staload
GLOB = "./pats_global.sats"

(* ****** ****** *)

staload
STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp
overload compare with $STMP.compare_stamp_stamp

(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
typedef symbolopt = $SYM.symbolopt
overload fprint with $SYM.fprint_symbol

(* ****** ****** *)

staload
SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload _(*avlmap*) = "./pats_avlmap.dats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

implement
d2cst_make
(
  id, loc, fil
, dck, decarg, artylst, typ, extdef
) = let
//
val pack = $GLOB.the_PACKNAME_get ()
//
val stamp = $STMP.d2cst_stamp_make ()
//
in
//
d2cst_new
(
  id, loc, fil, dck, decarg, artylst, typ
, gopt_none((*void*)) // hisexp
, gopt_none((*void*)) // funlab
, gopt_none((*void*)) // def
, pack, stamp, extdef
) (* end of [d2cst_new] *)
//
end // end of [d2cst_make]

(* ****** ****** *)

implement
d2cst_get_sym (d2c) = d2cst_sym (d2c)

implement
d2cst_get_loc (d2c) = d2cst_loc (d2c)

implement
d2cst_get_fil (d2c) = d2cst_fil (d2c)

implement
d2cst_get_kind (d2c) = d2cst_kind (d2c)

implement
d2cst_get_decarg (d2c) = d2cst_decarg (d2c)

implement
d2cst_get_artylst (d2c) = d2cst_artylst (d2c)

implement
d2cst_get_type (d2c) = d2cst_type (d2c)

(* ****** ****** *)

implement
d2cst_get_hisexp (d2c) = d2cst_hisexp (d2c)
implement
d2cst_set_hisexp (d2c, opt) = set_d2cst_hisexp (d2c, opt)

(* ****** ****** *)

implement
d2cst_get_funlab (d2c) = d2cst_funlab (d2c)
implement
d2cst_set_funlab (d2c, opt) = set_d2cst_funlab (d2c, opt)

(* ****** ****** *)

implement
d2cst_get_def (d2c) = d2cst_def (d2c)
implement
d2cst_set_def (d2c, def) = set_d2cst_def (d2c, def)

(* ****** ****** *)

implement
d2cst_get_pack (d2c) = d2cst_pack (d2c)

(* ****** ****** *)

implement
d2cst_get_extdef (d2c) = d2cst_extdef (d2c)

(* ****** ****** *)

implement
d2cst_get_stamp (d2c) = d2cst_stamp (d2c)

(* ****** ****** *)

implement
d2cst_get_name (d2c) =
  $SYM.symbol_get_name (d2cst_get_sym (d2c))
// end of [d2cst_get_name]

(* ****** ****** *)

implement
print_d2cst (x) = fprint_d2cst (stdout_ref, x)
implement
prerr_d2cst (x) = fprint_d2cst (stderr_ref, x)

implement
fprint_d2cst (out, x) =
  $SYM.fprint_symbol (out, d2cst_get_sym (x))
implement
fprint_d2cstlst (out, xs) =
  $UT.fprintlst<d2cst> (out, xs, ", ", fprint_d2cst)
// end of [fprint_d2cstlst]

(* ****** ****** *)

implement
d2cst_is_prf (d2c) = let
  val s2e = d2cst_get_type (d2c) in s2exp_is_prf (s2e)
end // end of [d2cst_is_prf]
implement
d2cst_is_nonprf (d2c) = let
  val s2e = d2cst_get_type (d2c) in s2exp_is_nonprf (s2e)
end // end of [d2cst_is_nonprf]

(* ****** ****** *)

implement
d2cst_is_mac (d2c) =
  $SYN.dcstextdef_is_mac (d2cst_get_extdef (d2c))
// end of [d2cst_is_mac]

(* ****** ****** *)

implement
d2cst_is_static (d2c) = let
  val extdef = d2cst_get_extdef (d2c)
in
  case+ $SYN.dcstextdef_view (extdef) of
  | ~$SYN.DCSTEXTDEFnone(k) => (k = 0)
  | ~$SYN.DCSTEXTDEFsome_sta _ => true
  | v => ($SYN.dcstextdef_view_free (v); false)
end // end of [d2cst_is_static]

(* ****** ****** *)

implement
d2cst_is_fundec (d2c) =
  dcstkind_is_fun(d2cst_get_kind(d2c))
// end of [d2cst_is_fundec]
implement
d2cst_is_valdec (d2c) =
  dcstkind_is_val(d2cst_get_kind(d2c))
// end of [d2cst_is_valdec]
implement
d2cst_is_castfn (d2c) =
  dcstkind_is_castfn(d2cst_get_kind(d2c))
// end of [d2cst_is_castfn]

(* ****** ****** *)
//
implement
d2cst_is_funcst (d2c) =
  glist_is_nil(d2cst_get_decarg(d2c))
implement
d2cst_is_tmpcst (d2c) =
  glist_is_cons(d2cst_get_decarg(d2c))
//
(* ****** ****** *)

implement
d2cst_is_mainats (d2c) =
  $SYN.dcstextdef_is_mainats (d2cst_get_extdef (d2c))
// end of [d2cst_is_mainats]

(* ****** ****** *)

implement
lt_d2cst_d2cst
  (x1, x2) = (compare_d2cst_d2cst (x1, x2) < 0)
// end of [lt_d2cst_d2cst]

implement
lte_d2cst_d2cst
  (x1, x2) = (compare_d2cst_d2cst (x1, x2) <= 0)
// end of [lte_d2cst_d2cst]

implement
eq_d2cst_d2cst
  (x1, x2) = (compare_d2cst_d2cst (x1, x2) = 0)
// end of [eq_d2cst_d2cst]

implement
neq_d2cst_d2cst
  (x1, x2) = (compare_d2cst_d2cst (x1, x2) != 0)
// end of [neq_d2cst_d2cst]

implement
compare_d2cst_d2cst (x1, x2) =
  $effmask_all (compare (d2cst_get_stamp (x1), d2cst_get_stamp (x2)))
// end of [compare_d2cst_d2cst]

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_d2cst_d2cst ($UN.cast{d2cst} (x1), $UN.cast{d2cst} (x2))
//
fn
ins (xs: avlmap, x: d2cst): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
//
in (* in-of-local *)

implement
d2cstset_nil
  ((*void*)) = $effmask_all ($UN.cast{d2cstset} (avlmap_nil ()))
//
implement
d2cstset_ismem
  (xs, x) = $effmask_all (avlmap_ismem ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), cmp))
//
implement
d2cstset_add
  (xs, x) = $effmask_all ($UN.cast{d2cstset} (ins ($UN.cast{avlmap} (xs), x)))
// end of [d2cstset_add]

(* ****** ****** *)

implement
d2cstset_vt_nil
  ((*void*)) = $effmask_all ($UN.castvwtp0{d2cstset_vt} (avlmap_nil ()))
//
implement
d2cstset_vt_add
  (xs, x) = $effmask_all ($UN.castvwtp0{d2cstset_vt}
  (ins ($UN.castvwtp0{avlmap} (xs), x)))
// end of [d2cstset_vt_add]
//
implement
d2cstset_vt_listize_free (xs) =
  $effmask_all ($UN.castvwtp0{d2cstlst_vt} (avlmap_keys ($UN.castvwtp0{avlmap} (xs))))

end // end of [local]

(* ****** ****** *)

implement
compare_d2cst_ptr (x1, x2) =
  compare_d2cst_d2cst ($UN.cast{d2cst} (x1), $UN.cast{d2cst} (x2))

implement{a}
d2cstmap_nil () = $effmask_all ($UN.cast{d2cstmap(a)} (avlmap_nil ()))

implement{a}
d2cstmap_search
  (map, d2c) = $effmask_all let
  var res: ptr?
  val found = avlmap_find ($UN.cast{avlmap} (map), $UN.cast{ptr} (d2c), compare_d2cst_ptr, res)
in
  if found then Some_vt ($UN.cast{a} (res)) else None_vt ((*empty*))
end // end of [d2cstmap_search]

implement{a}
d2cstmap_insert
  (map, d2c, x) = $effmask_all let
  val m = $UN.cast{avlmap} (map)
  val found = avlmap_ismem (m, $UN.cast{ptr} (d2c), compare_d2cst_ptr)
  val () = map := $UN.cast{d2cstmap(a)}
    (avlmap_insert (m, $UN.cast{ptr} (d2c), $UN.cast{ptr} (x), compare_d2cst_ptr))
in
  found
end // end of [d2cstmap_insert]

(* ****** ****** *)

(* end of [pats_dynexp2_dcst.dats] *)
