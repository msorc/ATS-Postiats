(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2015 Hongwei Xi, ATS Trustful Software, Inc.
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
// Authoremail: gmhwxiATgmailDOTcom
// Start Time: August, 2015
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_codegen2.dats, see PORTING.md, "Codegen2")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
//
(* ****** ****** *)
//
staload
S1E = "./pats_staexp1.sats"
//
(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_codegen2.sats"

(* ****** ****** *)

local

fun
auxerr_nil
(
  out: FILEref, d2c0: d2ecl
) : void =  {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = fprint_string (out, "(*\n")
val () = $LOC.fprint_location (out, loc0)
val () = fprint_string (out, ": error(codegen2): #codegen2()\n")
val () = fprint_string (out, "*)\n")
//
} (* end of [auxerr_nil] *)

fun
auxerr_cons
(
  out: FILEref
, d2c0: d2ecl, x: e1xp
) : void =  {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = fprint_string (out, "(*\n")
val () = $LOC.fprint_location (out, loc0)
val () = fprint_string (out, ": error(codegen2): #codegen2(")
val () = $S1E.fprint_e1xp (out, x)
val () = fprint_string (out, ", ...)\n")
val () = fprint_string (out, "*)\n")
//
} (* end of [auxerr_cons] *)

in (* in-of-local *)

implement
codegen2_process
  (out, d2c0) = let
//
(*
val () =
println!
  ("codegen2_process: d2c0 = ", d2c0)
*)
//
val xs =
(
case+ d2ecl_node_view(d2c0.d2ecl_node()) of
| ~D2Ccodegen(knd, xs) => xs
| v =>
  ( // HX: the MatchError of [val-D2Ccodegen(knd, xs)]
    d2ecl_node_view_free(v); assertloc(false); glist_nil((*void*))
  )
) : e1xplst
//
in
//
case+ glist_view(xs) of
//
| ~GLcons
    (x, xs) =>
  (
  if
  datcon_test_e1xp(x)
  then codegen2_datcon(out, d2c0, xs)
  else if
  datcontag_test_e1xp(x)
  then codegen2_datcontag(out, d2c0, xs)
//
  else if
  fprint_test_e1xp(x)
  then codegen2_fprint(out, d2c0, xs)
//
  else if
  absrec_test_e1xp(x)
  then codegen2_absrec(out, d2c0, xs)
//
  else (* unrecognized *) auxerr_cons(out, d2c0, x)
//
  ) (* GLcons *)
//
| ~GLnil((*void*)) => auxerr_nil(out, d2c0)
//
end // end of [codegen2_process]

end // end of [local]

(* ****** ****** *)

implement
d2eclist_codegen_out
  (out, d2cs) = let
//
(*
val () =
  println! ("d2eclist_codegen_out")
*)
//
fun
aux
(
  d2c0: d2ecl
) : void =
(
case+
d2ecl_node_view(d2c0.d2ecl_node())
of // case+
| ~D2Ccodegen
    (knd, _) =>
  (
    if knd <= 2
      then codegen2_process(out, d2c0) else ()
    // end of [if]
  ) (* D2Ccodegen *)
//
| ~D2Clist(d2cs) => auxlst (d2cs)
//
| ~D2Clocal(_, d2cs_body) => auxlst (d2cs_body)
//
| v (*rest-of-d2ecl*) => d2ecl_node_view_free(v)
)
//
and
auxlst
(
  d2cs: d2eclist
) : void =
(
//
case+ glist_view(d2cs) of
| ~GLnil() => ()
| ~GLcons(d2c, d2cs) => (aux(d2c); auxlst(d2cs))
//
) (* end of [auxlst] *)
//
in
  auxlst (d2cs)
end // end of [d2eclist_codegen_out]

(* ****** ****** *)

(* end of [pats_codegen2.dats] *)
