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
// HX-2026-10: the part of libatsopt (utils/libatsopt/DATS/patsopt_ext.dats)
// that needs ATS: [patsopt_main_opt] catches the exceptions of the compiler
// (FatalErrorExn after an error report, the PATSOPT_*_EXN). The rest of the
// API is in libatsopt_ext.c.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

#define ATS_DYNLOADFLAG 0 // nothing to initialize: no dynload function
//
// HX: defines the flag of pats_main.dats ([libatsopt_dynloadall], PATSOPT_MAIN_NONE)
//
dynload "./pats_main.dats"

(* ****** ****** *)
//
extern
fun
patsopt_main
  (argc: int, argv: ptr): void = "ext#libatsopt_patsopt_main"
//
extern
fun
patsopt_main_opt
  (argc: int, argv: ptr): bool = "ext#libatsopt_patsopt_main_opt"
//
(* ****** ****** *)

implement
patsopt_main_opt
  (argc, argv) = let
//
fun
auxexn(exn: exn): bool = let
  val p0 = $UNSAFE.castvwtp0{ptr}(exn) in false
end // end of [auxexn]
//
in
//
try let
  val () = patsopt_main(argc, argv) in true
end with exn => auxexn(exn)
//
end // end of [patsopt_main_opt]

(* ****** ****** *)

(* end of [libatsopt_ext.dats] *)
