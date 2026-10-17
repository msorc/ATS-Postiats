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
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_dcon.dats, see PORTING.md)
// The cell [ref (d2con_struct)] of ATS1 is the record [d2con] (the field d2con_tag has a setter).
// [d2con_make_list_nil/cons] are declared (and never implemented) in ATS1; neither here.
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

staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol

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

implement
d2con_make
(
  loc, fil
, id, s2c, vwtp, qua, npf, arg, ind
) = let
//
val arity_real = let
  fun aux1 (
    i: int, s2es: s2explst
  ) : s2explst = case+ glist_view (s2es) of
    | ~GLcons (_, s2es1) => if i > 0 then aux1 (i-1, s2es1) else s2es
    | ~GLnil () => glist_nil ()
  // end of [aux1]
  fun aux2 (
    i: int, s2es: s2explst
  ) : int = case+ glist_view (s2es) of
    | ~GLcons (s2e, s2es1) =>
        if s2rt_is_prf (s2exp_srt (s2e)) then aux2 (i, s2es1) else aux2 (i+1, s2es1)
      // end of [list_cons]
    | ~GLnil () => i // end of [list_nil]
  // end of [aux2]
in
  aux2 (0, aux1 (npf, arg))
end // end of [val]
//
val arity_full = glist_length (arg)
//
val d2c_type = let
//
  fun aux
  (
    s2f: s2exp, s2qs: s2qualst
  ) : s2exp = (
    case+ glist_view (s2qs) of
    | ~GLnil () => (s2f)
    | ~GLcons
        (s2q, s2qs) => let
        val s2f = aux (s2f, s2qs)
        val s2f_uni =
          s2exp_uni (s2qua_svs (s2q), s2qua_sps (s2q), s2f)
        // end of [val]
      in
        s2f_uni
      end // end of [list_cons]
  ) (* end of [aux] *)
//
  val s2e_res =
  (
    case+ gopt_view (ind) of
    | ~GOsome s2es => s2exp_cstapp (s2c, s2es) | ~GOnone () => s2exp_cst (s2c)
  ) : s2exp // end of [val]
  val s2e_res = s2exp_confun (npf, arg, s2e_res)
//
in
  aux (s2e_res, qua)
end : s2exp // end of [val]
//
val pack = $GLOB.the_PACKNAME_get ()
//
val stamp = $STMP.d2con_stamp_make ()
//
in
//
d2con_new
(
  id, loc, fil, s2c, npf, vwtp, qua, arg
, arity_full, arity_real, ind, d2c_type, ~1(*tag*), pack, stamp
) (* end of [d2con_new] *)
//
end // end of [d2con_make]

(* ****** ****** *)

implement
d2con_get_sym (d2c) = $effmask_all (d2con_sym (d2c))
implement
d2con_get_loc (d2c) = $effmask_all (d2con_loc (d2c))
implement
d2con_get_fil (d2c) = $effmask_all (d2con_fil (d2c))
implement
d2con_get_scst (d2c) = $effmask_all (d2con_scst (d2c))
implement
d2con_get_npf (d2c) = $effmask_all (d2con_npf (d2c))
implement
d2con_get_vwtp (d2c) = $effmask_all (d2con_vwtp (d2c))

(* ****** ****** *)

implement
d2con_get_qua (d2c) = $effmask_all (d2con_qua (d2c))
implement
d2con_get_arg (d2c) = $effmask_all (d2con_arg (d2c))
implement
d2con_get_arity_full (d2c) = $effmask_all (d2con_arity_full (d2c))
implement
d2con_get_arity_real (d2c) = $effmask_all (d2con_arity_real (d2c))
implement
d2con_get_ind (d2c) = $effmask_all (d2con_ind (d2c))
implement
d2con_get_type (d2c) = $effmask_all (d2con_type (d2c))

(* ****** ****** *)

implement
d2con_get_tag (d2c) = d2con_tag (d2c)
implement
d2con_set_tag (d2c, tag) = set_d2con_tag (d2c, tag)

(* ****** ****** *)

implement
d2con_get_pack
  (d2c) = $effmask_all (d2con_pack (d2c))

implement
d2con_get_stamp
  (d2c) = $effmask_all (d2con_stamp (d2c))

(* ****** ****** *)

implement
d2con_get_name (d2c) = $effmask_all (
  $SYM.symbol_get_name (d2con_get_sym (d2c))
) (* end of [d2cin_get_name] *)

(* ****** ****** *)

implement
d2con_is_nullary (d2c) =
  d2con_get_arity_real (d2c) = 0
// end of [d2con_is_nullay]

implement
d2con_is_tagless (d2c) =
  s2cst_is_tagless (d2con_get_scst (d2c))
// end of [d2con_is_tagless]

(* ****** ****** *)

implement
d2con_is_listnil (d2c) = let
//
val s2c = d2con_get_scst (d2c)
val opt = s2cst_get_islst (s2c)
//
in
  case+ gopt_view (opt) of
  | ~GOsome (x) =>
      if d2c = d2conpair_0 (x) then true else false
  | ~GOnone ( ) => false
end // end of [d2con_is_listnil]

implement
d2con_is_listcons (d2c) = let
//
val s2c = d2con_get_scst (d2c)
val opt = s2cst_get_islst (s2c)
//
in
  case+ gopt_view (opt) of
  | ~GOsome (x) =>
      if d2c = d2conpair_1 (x) then true else false
  | ~GOnone ( ) => false
end // end of [d2con_is_listcons]

implement
d2con_is_listlike (d2c) =
  s2cst_is_listlike (d2con_get_scst (d2c))
// end of [d2con_is_listlike]

(* ****** ****** *)

implement
d2con_is_singular (d2c) =
  s2cst_is_singular (d2con_get_scst (d2c))
// end of [d2con_is_singular]

(* ****** ****** *)

implement
d2con_is_binarian (d2c) =
  s2cst_is_binarian (d2con_get_scst (d2c))
// end of [d2con_is_binarian]

(* ****** ****** *)
//
implement
d2con_is_linear
  (d2c) = s2cst_is_linear(d2con_get_scst(d2c))
implement
d2con_is_nonlinear
  (d2c) = s2cst_is_nonlinear(d2con_get_scst(d2c))
//
(* ****** ****** *)

implement
eq_d2con_d2con
  (x1, x2) = (compare_d2con_d2con (x1, x2) = 0)
// end of [eq_d2con_d2con]

implement
neq_d2con_d2con
  (x1, x2) = (compare_d2con_d2con (x1, x2) != 0)
// end of [neq_d2con_d2con]

implement
compare_d2con_d2con (x1, x2) =
  $effmask_all (compare (d2con_get_stamp (x1), d2con_get_stamp (x2)))
// end of [compare_d2con_d2con]

(* ****** ****** *)

#define D2CON_TAG_EXN ~1

implement
d2con_is_con (d2c) =
(
  if d2con_get_tag (d2c) >= 0 then true else false
) // end of [d2con_is_con]

implement
d2con_is_exn (d2c) = let
  val tag = d2con_get_tag (d2c) in tag = D2CON_TAG_EXN
end // end of [d2con_is_exn]

(* ****** ****** *)

implement
fprint_d2con (out, x) = let
  val sym = d2con_get_sym (x) in $SYM.fprint_symbol (out, sym)
end // end of [fprint_d2con]

implement
print_d2con (x) = fprint_d2con (stdout_ref, x)
implement
prerr_d2con (x) = fprint_d2con (stderr_ref, x)

(* ****** ****** *)

implement
fprint_d2conlst
  (out, xs) = $UT.fprintlst<d2con> (out, xs, ", ", fprint_d2con)
// end of [fprint_d2conlst]

implement
print_d2conlst (xs) = fprint_d2conlst (stdout_ref, xs)
implement
prerr_d2conlst (xs) = fprint_d2conlst (stderr_ref, xs)

(* ****** ****** *)

local
//
fun
cmp (x1: ptr, x2: ptr): int =
  compare_d2con_d2con ($UN.cast{d2con} (x1), $UN.cast{d2con} (x2))
//
fn
ins (xs: avlmap, x: d2con): avlmap =
  avlmap_insert (xs, $UN.cast{ptr} (x), the_null_ptr, cmp)
//
in (* in of [local] *)

implement
d2conset_nil () = $effmask_all ($UN.cast{d2conset} (avlmap_nil ()))

implement
d2conset_ismem
  (xs, x) = $effmask_all (avlmap_ismem ($UN.cast{avlmap} (xs), $UN.cast{ptr} (x), cmp))
// end of [d2conset_ismem]

implement
d2conset_add
  (xs, x) = $effmask_all ($UN.cast{d2conset} (ins ($UN.cast{avlmap} (xs), x)))
// end of [d2conset_add]

(* ****** ****** *)

implement
d2conset_vt_nil () = $effmask_all ($UN.castvwtp0{d2conset_vt} (avlmap_nil ()))

implement
d2conset_vt_add
  (xs, x) = $effmask_all ($UN.castvwtp0{d2conset_vt} (ins ($UN.castvwtp0{avlmap} (xs), x)))
// end of [d2conset_vt_add]

implement
d2conset_vt_listize_free (xs) =
  $effmask_all ($UN.castvwtp0{d2conlst_vt} (avlmap_keys ($UN.castvwtp0{avlmap} (xs))))

end // end of [local]

(* ****** ****** *)

(* end of [pats_staexp2_dcon.dats] *)
