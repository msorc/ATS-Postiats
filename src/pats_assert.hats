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
// HX-2026-10:
// [assertloc] and [exitloc] of the compiler print the text of ATS1:
//   exit(ATS): [assert] failed: <loc>      (ATS1 adds an empty line after <loc>)
//   <loc>                                  (exitloc: the ATS2 prelude adds "exit(ATS): ")
// The macros shadow those of prelude/macrodef.sats (include this file
// right after "share/atspre_staload.hats").
//
macdef
assertloc (tf) =
  assert_errmsg2 (,(tf), "exit(ATS): [assert] failed: ", $mylocation)
macdef
exitloc (x) = (prerr_string ($mylocation); prerr_newline (); exit (,(x)))
//
(* ****** ****** *)

(* end of [pats_assert.hats] *)
