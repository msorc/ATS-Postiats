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
// Start Time: April, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_hole.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload
CNTR = "./pats_counter.sats"
staload STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

implement
s2hole_make_srt (s2t) = let
  val stamp = $STMP.s2hole_stamp_make ()
in
  s2hole_new (s2t, stamp)
end // end of [s2hole_make_srt]

implement
s2hole_get_srt (s2h) = $effmask_all (s2hole_srt (s2h))

implement
s2hole_get_stamp (s2h) = $effmask_all (s2hole_stamp (s2h))

(* ****** ****** *)

implement
fprint_s2hole
  (out, s2h) = let
  val stamp =
    s2hole_get_stamp (s2h)
  // end of [val]
in
  $STMP.fprint_stamp (out, stamp)
end // end of [fprint_s2hole]

(* ****** ****** *)

(* end of [pats_staexp2_hole.dats] *)
