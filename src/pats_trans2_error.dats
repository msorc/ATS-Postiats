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
// HX-2026-10: no GC (ATS2 port of src/pats_trans2_error.dats).
// The errors are kept in a cell of the global arena as a [glist].
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef location = $LOC.location

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_trans2.sats"

(* ****** ****** *)

#include "./pats_trans2_gen_dats.hats"

(* ****** ****** *)
//
typedef
trans2errlst = glist (trans2err)
//
(* ****** ****** *)

local

val the_trans2errlst = let
  val p = the_garena_alloc (sizeof<trans2errlst>)
  val () = $UN.ptr0_set<trans2errlst> (p, glist_nil ())
in
  p
end // end of [val]

fun
the_trans2errlst_get
(
// argumentless
) : trans2errlst = let
  val xs = $UN.ptr0_get<trans2errlst> (the_trans2errlst)
  val () = $UN.ptr0_set<trans2errlst> (the_trans2errlst, glist_nil ())
in
  xs
end // end of [the_trans2errlst_get]

in (* in-of-local *)

implement
the_trans2errlst_add
  (x) = () where {
  val xs = $UN.ptr0_get<trans2errlst> (the_trans2errlst)
  val () = $UN.ptr0_set<trans2errlst> (the_trans2errlst, glist_cons (x, xs))
} (* end of [the_trans2errlst_add] *)

implement
the_trans2errlst_finalize () =
{
  val xs =
    the_trans2errlst_get ()
  // end of [val]
  val nxs = glist_length (xs)
  val () =
  if nxs > 0 then {
    val err = stderr_ref
    val () = fprint_string (err, "patsopt(TRANS2): there are [")
    val () = fprint_int (err, nxs)
    val () = fprint_string (err, "] errors in total.\n")
  } (* end of [if] *) // end of [val]
  val () =
  if nxs > 0
    then $raise($ERR.PATSOPT_TRANS2_EXN())
  // end of [if]
} (* end of [the_trans2errlst_finalize] *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans2_error.dats] *)
