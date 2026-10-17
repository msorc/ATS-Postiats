(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2017 Hongwei Xi, ATS Trustful Software, Inc.
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
(* Start time: April, 2017 *)
(* Authoremail: gmhwxiATgmailDOTcom *)

(* ****** ****** *)
//
#define
MYATSCCDEF_key "##myatsccdef="
//
(*
HX-2017-04-22:
This is the default used by [myatscc]
*)
//
#define
MYATSCCDEF_def
"patscc -cleanaft \
-D_GNU_SOURCE -DATS_MEMALLOC_LIBC \
-I${PATSHOME}/contrib -o $fname($1)_$fname_ext($1) $1 -latslib"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// [myatscc] used to be implemented on top of
// a parser-combinator library (closures and lazy
// streams); it is now a direct expander that only
// manipulates linear values
//
(* ****** ****** *)
//
// The arguments for $1, $2, ...: argv[0] and
// the command-line arguments not starting with '-'
//
vtypedef arglst = List0_vt(Strptr1)
//
fun
myatscc_arglst
  {n:pos}
  (argc: int(n), argv: !argv(n)): arglst
//
fun
myatscc_arglst_free(args: arglst): void
//
(* ****** ****** *)
//
// HX: the definition found in the file
// given by $1 or the default [MYATSCCDEF_def]
//
fun
myatscc_getdef{n:int}
  (args: !list_vt(Strptr1, n)): Strptr1
//
// HX: expanding $N, $f(...) and \c in [def]
//
fun
myatscc_evaldef{n:int}
  (def: string, args: !list_vt(Strptr1, n)): Strptr1
//
fun
myatscc_main
  {n:pos}
  (argc: int(n), argv: !argv(n)): int
//
(* ****** ****** *)

(* end of [myatscc.sats] *)
