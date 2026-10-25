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
//
// HX-2026-10: no GC
// a filename is a string (kept in the global arena)
//
assume filename_type = string
//
(* ****** ****** *)
implement
filename_dummy = ""
implement
filename_stdin = "__STDIN__"
implement
filename_string = "__STRING__"
(* ****** ****** *)
implement
filename_make(path) = the_garena_strdup(path)
(* ****** ****** *)
implement
fprint_filename
  (out, fil) = fprint_string(out, fil)
(* ****** ****** *)
implement
strptr2gstring(x) = let
  val str =
  the_garena_strdup($UNSAFE.strptr2string(x))
in
  strptr_free(x); str
end // end of [strptr2gstring]
(* ****** ****** *)
(* end of [atexting_fname.dats] *)
