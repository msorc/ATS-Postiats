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
// HX-2026-10: no GC. The private type [effenvitm] of pats_trans3_env_effect.dats (generated from
// [pats_trans3_env_effect.spec]); see PORTING.md, "Type-checking environment (trans3_env)".
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

staload "./pats_basics.sats"

staload
EFF = "./pats_effect.sats"
typedef effset = $EFF.effset

staload "./pats_staexp2.sats"

(* ****** ****** *)

#include "./pats_trans3_env_effect_gen.hats"

(* ****** ****** *)

(* end of [pats_trans3_env_effect.sats] *)
