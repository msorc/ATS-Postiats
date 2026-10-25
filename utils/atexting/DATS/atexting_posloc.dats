(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2016 Hongwei Xi, ATS Trustful Software, Inc.
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

(* Author: Hongwei Xi *)
(* Authoremail: gmhwxiATgmailDOTcom *)
(* Start time: January, 2016 *)

(* ****** ****** *)
//
#include
"share\
/atspre_staload.hats"
//
(* ****** ****** *)
//
staload
"./../SATS/atexting.sats"
//
#staload "libats/SATS/arena.sats" // HX-2026-10
#staload _ = "libats/DATS/arena.dats"
//
(* ****** ****** *)

implement
position_byrow(pos) =
{
//
val () = pos.pos_ntot := pos.pos_ntot + 1
val () = pos.pos_ncol := 0 (* beginning *)
val () = pos.pos_nrow := pos.pos_nrow + 1
//
} (* end of [position_byrow] *)

(* ****** ****** *)
//
implement
position_incby_1
  (pos) = pos.incby(1)
//
implement
position_incby_n
  (pos, n) = () where
{
//
val () = pos.pos_ntot := pos.pos_ntot + n
val () = pos.pos_ncol := pos.pos_ncol + n
//
} (* end of [position_incby_n] *)

(* ****** ****** *)

implement
position_decby_n(pos, n) =
{
//
val () = pos.pos_ntot := pos.pos_ntot - n
val () = pos.pos_ncol := pos.pos_ncol - n
//
} (* end of [position_decby_n] *)

(* ****** ****** *)

implement
position_incby_char
  (pos, c) = (
//
if
c >= 0
then
(
  if c = '\n'
    then position_byrow(pos)
    else position_incby_1(pos)
  // end of [if]
) (* then *)
else ((*void*))
//
) (* position_incby_char *)

(* ****** ****** *)

//
// HX-2026-10: no GC
// a location is a (flat) record in the global arena
//
typedef
locrec = @{
  fil= fil_t
, beg_ntot= int // beginning char position
, beg_nrow= int
, beg_ncol= int
, end_ntot= int // finishing char position
, end_nrow= int
, end_ncol= int
} (* end of [locrec] *)
//
assume location_type = ptr
//
extern
fun
location_make_rec(x: &locrec): loc_t
implement
location_make_rec
  (x) = p where
{
  val p = the_garena_alloc(sizeof<locrec>)
  val () = arena_store<locrec>(p, x)
} (* end of [location_make_rec] *)
//
macdef
LOC(loc) = arena_load<locrec>(,(loc))
//
(* ****** ****** *)

local
//
var
loc0: locrec
val () = loc0.fil := filename_dummy
val () = loc0.beg_ntot := ~1
val () = loc0.beg_nrow := ~1
val () = loc0.beg_ncol := ~1
val () = loc0.end_ntot := ~1
val () = loc0.end_nrow := ~1
val () = loc0.end_ncol := ~1
//
in (* in-of-local *)
//
implement
location_dummy = location_make_rec(loc0)
//
end // end of [local]

(* ****** ****** *)

implement
fprint_location
  (out, loc) = let
//
val fil = (LOC(loc)).fil
val ((*void*)) = fprint_filename(out, fil)
//
in
  fprint_string(out, ": "); fprint_locrange(out, loc)
end (* end of [fprint_location] *)

(* ****** ****** *)

implement
fprint_locrange
  (out, loc) = () where
{
//
val x = LOC(loc)
//
val () =
fprint!
( out
, x.beg_ntot+1
, "(line=", x.beg_nrow+1, ", offs=", x.beg_ncol+1, ")"
)
val () = fprint_string (out, " -- ")
val () =
fprint!
( out
, x.end_ntot+1
, "(line=", x.end_nrow+1, ", offs=", x.end_ncol+1, ")"
)
//
} (* end of [fprint_locrange] *)

(* ****** ****** *)

implement
location_is_atlnbeg
  (loc) = ((LOC(loc)).beg_ncol = 0)

(* ****** ****** *)

implement
location_make_pos_pos
  (pos1, pos2) = (
//
location_make_fil_pos_pos
  (the_filename_get(), pos1, pos2)
//
) (* end of [location_make_pos_pos] *)

(* ****** ****** *)

implement
location_make_fil_pos_pos
  (fil, p1, p2) = let
var x: locrec
val () = x.fil := fil
val () = x.beg_ntot := p1.pos_ntot
val () = x.beg_nrow := p1.pos_nrow
val () = x.beg_ncol := p1.pos_ncol
val () = x.end_ntot := p2.pos_ntot
val () = x.end_nrow := p2.pos_nrow
val () = x.end_ncol := p2.pos_ncol
in
  location_make_rec(x)
end (* end of [location_make_fil_pos_pos] *)

(* ****** ****** *)

implement
location_leftmost
  (loc) = let
var x: locrec = LOC(loc)
val () = x.end_ntot := x.beg_ntot
val () = x.end_nrow := x.beg_nrow
val () = x.end_ncol := x.beg_ncol
in
  location_make_rec(x)
end // end of [location_leftmost]

implement
location_rightmost
  (loc) = let
var x: locrec = LOC(loc)
val () = x.beg_ntot := x.end_ntot
val () = x.beg_nrow := x.end_nrow
val () = x.beg_ncol := x.end_ncol
in
  location_make_rec(x)
end // end of [location_rightmost]

(* ****** ****** *)

local

fun
is_none
(
  loc: loc_t
) : bool = ((LOC(loc)).beg_ntot < 0)

fun
auxmain
(
  loc1: loc_t, loc2: loc_t
) : loc_t = let
//
  val x1 = LOC(loc1) and x2 = LOC(loc2)
//
  var x: locrec = x1
//
  val () =
  if x1.beg_ntot > x2.beg_ntot
    then begin
      x.beg_ntot := x2.beg_ntot;
      x.beg_nrow := x2.beg_nrow; x.beg_ncol := x2.beg_ncol
    end // end of [then]
  // end of [if]
//
  val () =
  if x1.end_ntot < x2.end_ntot
    then begin
      x.end_ntot := x2.end_ntot;
      x.end_nrow := x2.end_nrow; x.end_ncol := x2.end_ncol
    end // end of [then]
  // end of [if]
//
in
  location_make_rec(x)
end // end of [auxmain]

in (* in of [local] *)

implement
location_combine
  (loc1, loc2) =
(
  case+ 0 of
  | _ when
      is_none (loc1) => loc2
  | _ when
      is_none (loc2) => loc1
  | _ => auxmain (loc1, loc2)
) (* end of [location_combine] *)

end // end of [local]

(* ****** ****** *)

(* end of [atexting_posloc.dats] *)
