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
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2_dmac.dats, see PORTING.md)
// The cell of ATS1 ([ref (d2mac_struct)]) is the record [d2mac] of pats_dynexp2.spec.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

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

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

implement
d2mac_make (
  loc, name, knd, xs, def
) = let
//
val stamp = $STMP.d2mac_stamp_make ()
//
in
  d2mac_new (loc, name, knd, xs, def, stamp)
end // end of [d2mac_make]

implement
d2mac_get_loc (d2m) = d2mac_loc (d2m)

implement
d2mac_get_sym (d2m) = d2mac_sym (d2m)

implement
d2mac_get_kind (d2m) = d2mac_kind (d2m)

implement
d2mac_get_arglst (d2m) = d2mac_arglst (d2m)

implement
d2mac_get_def (d2m) = d2mac_def (d2m)
implement
d2mac_set_def (d2m, def) = set_d2mac_def (d2m, def)

implement
d2mac_get_stamp (d2m) = d2mac_stamp (d2m)

(* ****** ****** *)

implement
fprint_m2acarg
  (out, x) = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
//
case+ m2acarg_view (x) of
| ~M2ACARGsta (s2vs) => (
    prstr "M2ACARGsta("; fprint_s2varlst (out, s2vs); prstr ")"
  ) // end of [M2ACARGsta]
| ~M2ACARGdyn (d2vs) => (
    prstr "M2ACARGdyn("; fprint_d2varlst (out, d2vs); prstr ")"
  ) // end of [M2ACARGdyn]
//
end // end of [fprint_m2acarg]

implement
fprint_m2acarglst
  (out, xs) = $UT.fprintlst<m2acarg> (out, xs, ", ", fprint_m2acarg)
// end of [fprint_m2acarglst]

(* ****** ****** *)

implement
fprint_d2mac (out, x) =
  $SYM.fprint_symbol (out, d2mac_get_sym (x))
// end of [fprint_d2mac]

implement print_d2mac (x) = fprint_d2mac (stdout_ref, x)
implement prerr_d2mac (x) = fprint_d2mac (stderr_ref, x)

(* ****** ****** *)

(* end of [pats_dynexp2_dmac.dats] *)
