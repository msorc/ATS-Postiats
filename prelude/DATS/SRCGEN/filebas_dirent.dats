(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2010-2013 Hongwei Xi, ATS Trustful Software, Inc.
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

(*
** Source:
** $PATSHOME/prelude/DATS/SRCGEN/filebas_dirent.atxt
** Time of generation: Wed Oct 21 23:29:34 2026
*)

(* ****** ****** *)

(* Author: Hongwei Xi *)
(* Authoremail: gmhwxiATgmailDOTcom *)
(* Start time: December, 2017 *)

(* ****** ****** *)

#define
ATS_DYNLOADFLAG 0 // no dynloading at run-time

(* ****** ****** *)

#staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

#staload
_(*INT*) = "prelude/DATS/integer.dats"

(* ****** ****** *)
//
#staload
DIR = "libats/libc/SATS/dirent.sats"
#staload
_(*DIR*) = "libats/libc/DATS/dirent.dats"
//
(* ****** ****** *)

vtypedef dirent = $DIR.dirent

(* ****** ****** *)

implement
{}(*tmp*)
streamize_dirname_fname
  (dirname) = let
//
val
dirp = $DIR.opendir(dirname)
//
val ents =
(
if
$DIR.DIRptr2ptr(dirp) > 0
then
$DIR.streamize_DIRptr_dirent<>(dirp)
else let
//
prval() =
$DIR.DIRptr_free_null(dirp) in stream_vt_make_nil()
//
end // end of [else]
) : stream_vt(dirent)
//
in
//
stream_vt_map_cloptr<dirent><Strptr1>
  (ents, lam(ent) => $DIR.dirent_get_d_name_gc<>(ent))
//
end // end of [streamize_dirname_fname]

(* ****** ****** *)

(* end of [filebas_dirent.dats] *)
