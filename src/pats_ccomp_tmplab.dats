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
// Start Time: October, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_tmplab.dats, see PORTING.md, "ccomp core modules")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload
STMP = "./pats_stamp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
tmplab_make (loc) = let
  val stamp = $STMP.tmplab_stamp_make ()
in
  tmplab_new (loc, stamp)
end // end of [tmplab_make]

implement
tmplab_get_loc (tl) = tmplab_loc (tl)
implement
tmplab_get_stamp (tl) = tmplab_stamp (tl)

(* ****** ****** *)

implement
fprint_tmplab (out, tl) =
{
  val stamp = tmplab_get_stamp (tl)
  val () = fprint_string (out, "tmplab(")
  val () = $STMP.fprint_stamp (out, stamp)
  val () = fprint_string (out, ")")
} (* end of [fprint_tmplab] *)

(* ****** ****** *)

(* end of [pats_ccomp_tmplab.dats] *)
