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
// Start Time: August, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_global.dats)
// The state is kept in cells of the global arena (never freed)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#include "./pats_params.hats"

(* ****** ****** *)
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload "./pats_global.sats"

(* ****** ****** *)
//
fn cell_make_int (x: int): ptr = let
  val p = the_garena_alloc (sizeof<int>)
  val () = $UN.ptr0_set<int> (p, x)
in p end
fn cell_make_ptr (x: ptr): ptr = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, x)
in p end
//
fn cell_get_int (p: ptr): int = $UN.ptr0_get<int> (p)
fn cell_set_int (p: ptr, x: int): void = $UN.ptr0_set<int> (p, x)
fn cell_get_ptr (p: ptr): ptr = $UN.ptr0_get<ptr> (p)
fn cell_set_ptr (p: ptr, x: ptr): void = $UN.ptr0_set<ptr> (p, x)
//
fn cell_get_stropt (p: ptr): Stropt = $UN.ptr0_get<Stropt> (p)
fn cell_set_stropt (p: ptr, x: Stropt): void = $UN.ptr0_set<Stropt> (p, x)
//
(* ****** ****** *)

val the_PACKNAME = cell_make_ptr ($UN.cast{ptr}(stropt_none ()))

implement
the_PACKNAME_get() = $UN.cast{Stropt}(cell_get_ptr (the_PACKNAME))
implement
the_PACKNAME_set (opt) = cell_set_ptr (the_PACKNAME, $UN.cast{ptr}(opt))

implement
the_PACKNAME_set_name
  (ns) = the_PACKNAME_set(stropt_some(ns))
// end of [the_PACKNAME_set]
implement
the_PACKNAME_set_none
  ((*none*)) = the_PACKNAME_set(stropt_none())
// end of [the_PACKNAME_set_none]

(* ****** ****** *)

val the_ATSRELOC = cell_make_int (0)
val the_ATSRELOC_decl = cell_make_ptr (the_null_ptr)

implement
the_ATSRELOC_get() = cell_get_int (the_ATSRELOC)
implement
the_ATSRELOC_set(flag) = cell_set_int (the_ATSRELOC, flag)
//
implement
the_ATSRELOC_get_decl() = let
  val d0c = cell_get_ptr (the_ATSRELOC_decl)
  val ((*void*)) = cell_set_ptr (the_ATSRELOC_decl, the_null_ptr)
in d0c end // end of [the_ATSRELOC_get_decl]
//
implement
the_ATSRELOC_set_decl(d0c) = cell_set_ptr (the_ATSRELOC_decl, d0c)

(* ****** ****** *)

val the_DYNLOADFLAG = cell_make_int (0)

implement
the_DYNLOADFLAG_get() = cell_get_int (the_DYNLOADFLAG)
implement
the_DYNLOADFLAG_set(flag) = cell_set_int (the_DYNLOADFLAG, flag)

(* ****** ****** *)

val the_DYNLOADNAME = cell_make_ptr ($UN.cast{ptr}(stropt_none ()))

implement
the_DYNLOADNAME_get() = $UN.cast{Stropt}(cell_get_ptr (the_DYNLOADNAME))
implement
the_DYNLOADNAME_set_none
  () = cell_set_ptr (the_DYNLOADNAME, $UN.cast{ptr}(stropt_none ()))
implement
the_DYNLOADNAME_set_name
  (name) = cell_set_ptr (the_DYNLOADNAME, $UN.cast{ptr}(stropt_some (name)))

(* ****** ****** *)

val the_MAINATSFLAG = cell_make_int (0)

implement
the_MAINATSFLAG_get() = cell_get_int (the_MAINATSFLAG)
implement
the_MAINATSFLAG_set(flag) = cell_set_int (the_MAINATSFLAG, flag)

(* ****** ****** *)

val the_STATIC_PREFIX = cell_make_ptr ($UN.cast{ptr}(stropt_none ()))

implement
the_STATIC_PREFIX_get() = $UN.cast{Stropt}(cell_get_ptr (the_STATIC_PREFIX))
implement
the_STATIC_PREFIX_set_none
  () = cell_set_ptr (the_STATIC_PREFIX, $UN.cast{ptr}(stropt_none ()))
implement
the_STATIC_PREFIX_set_name
  (x) = cell_set_ptr (the_STATIC_PREFIX, $UN.cast{ptr}(stropt_some (x)))

(* ****** ****** *)
//
val the_IATS_dirlst = cell_make_ptr ($UN.cast{ptr}(glist_nil{string}()))
//
implement
the_IATS_dirlst_get
  () = $UN.cast{glist(string)}(cell_get_ptr (the_IATS_dirlst))
//
implement
the_IATS_dirlst_ppush
  (dir) = let
  val dirs = the_IATS_dirlst_get ()
in
  cell_set_ptr (the_IATS_dirlst, $UN.cast{ptr}(glist_cons (dir, dirs)))
end // end of [the_IATS_dirlst_ppush]
//
(* ****** ****** *)

val the_DEBUGATS_dbgflag = cell_make_int (0)

implement
the_DEBUGATS_dbgflag_get() = cell_get_int (the_DEBUGATS_dbgflag)
implement
the_DEBUGATS_dbgflag_set(flag) = cell_set_int (the_DEBUGATS_dbgflag, flag)

(* ****** ****** *)

val the_DEBUGATS_dbgline = cell_make_int (0)

implement
the_DEBUGATS_dbgline_get() = cell_get_int (the_DEBUGATS_dbgline)
implement
the_DEBUGATS_dbgline_set(flag) = cell_set_int (the_DEBUGATS_dbgline, flag)

(* ****** ****** *)

val the_LEGACYERRORS = cell_make_int (0)

implement
the_LEGACYERRORS_get() = cell_get_int (the_LEGACYERRORS)
implement
the_LEGACYERRORS_set(flag) = cell_set_int (the_LEGACYERRORS, flag)

(* ****** ****** *)

val the_CCOMPATS_tlcalopt = cell_make_int (1)

implement
the_CCOMPATS_tlcalopt_get() = cell_get_int (the_CCOMPATS_tlcalopt)
implement
the_CCOMPATS_tlcalopt_set(flag) = cell_set_int (the_CCOMPATS_tlcalopt, flag)

(* ****** ****** *)

val the_CCOMPENV_maxtmprecdepth = cell_make_int (CCOMPENV_MAXTMPRECDEPTH)

implement
the_CCOMPENV_maxtmprecdepth_get() = cell_get_int (the_CCOMPENV_maxtmprecdepth)
implement
the_CCOMPENV_maxtmprecdepth_set(mtd) = cell_set_int (the_CCOMPENV_maxtmprecdepth, mtd)

(* ****** ****** *)

(* end of [pats_global.dats] *)
