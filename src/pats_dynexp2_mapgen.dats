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
// Authoremail: gmhwxiATgmailDOTcom
// Start Time: December, 2014
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2_mapgen.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2.dats" // [synentlst_app]

(* ****** ****** *)

staload "./pats_dynexp2.sats"

(* ****** ****** *)

local
//
extern
fun s2cst_app (x: s2cst, env: !appenv): void
and s2var_app (x: s2var, env: !appenv): void
and s2Var_app (x: s2Var, env: !appenv): void
and d2con_app (x: d2con, env: !appenv): void
//
extern
fun d2cst_app (x: d2cst, env: !appenv): void
and d2var_app (x: d2var, env: !appenv): void
and d2sym_app (x: d2sym, env: !appenv): void
//
#include "./pats_staexp2_appenv.hats"
#include "./pats_dynexp2_appenv.hats"
//
datavtype
myenv =
MYENV of (
  s2cstset_vt
, s2varset_vt
, s2Varset_vt
, d2conset_vt
, d2cstset_vt
, d2varset_vt
) (* end of [MYENV] *)
//
in
//
implement
s2cst_app
  (s2c, env) = let
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (s2cs, _, _, _, _, _) = env2
val ((*void*)) = s2cs := s2cstset_vt_add(s2cs, s2c)
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [s2cst_app]

implement
s2var_app
  (s2v, env) = let
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (_, s2vs, _, _, _, _) = env2
val ((*void*)) = s2vs := s2varset_vt_add(s2vs, s2v)
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [s2var_app]

implement
s2Var_app
  (s2V, env) = let
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (_, _, s2Vs, _, _, _) = env2
val ((*void*)) = s2Vs := s2Varset_vt_add(s2Vs, s2V)
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [s2Var_app]

implement
d2con_app
  (d2c, env) = let
//
val s2c =
  d2con_get_scst(d2c)
val ((*void*)) =
  s2cst_app(s2c, env)
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (_, _, _, d2cs, _, _) = env2
val ((*void*)) = d2cs := d2conset_vt_add(d2cs, d2c)
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [d2con_app]

implement
d2cst_app
  (d2c, env) = let
//
val s2e =
  d2cst_get_type(d2c)
val ((*void*)) =
  s2exp_app(s2e, env)
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (_, _, _, _, d2cs, _) = env2
//
val ((*void*)) =
  d2cs := d2cstset_vt_add(d2cs, d2c)
//
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [d2cst_app]

implement
d2var_app
  (d2v, env) = let
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV
  (_, _, _, _, _, d2vs) = env2
//
val ((*void*)) =
  d2vs := d2varset_vt_add(d2vs, d2v)
//
prval ((*void*)) = fold@ (env2)
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [d2var_app]

implement d2sym_app (d2s, env) = ()

(* ****** ****** *)

implement
d2eclist_mapgen_all
  (d2cls) = let
//
val s2cs = s2cstset_vt_nil ()
val s2vs = s2varset_vt_nil ()
val s2Vs = s2Varset_vt_nil ()
//
val d2cons = d2conset_vt_nil ()
val d2csts = d2cstset_vt_nil ()
val d2vars = d2varset_vt_nil ()
//
val appenv =
$UN.castvwtp0{appenv}(MYENV(s2cs, s2vs, s2Vs, d2cons, d2csts, d2vars))
//
val ((*void*)) = d2eclist_app (d2cls, appenv)
//
val+~MYENV(s2cs, s2vs, s2Vs, d2cons, d2csts, d2vars) = $UN.castvwtp0{myenv}(appenv)
//
in
//
@(
  s2cs
, s2vs
, s2Vs
, d2cons
, d2csts
, d2vars
)
//
end // end of [d2eclist_mapgen_all]

end // end of [local]

(* ****** ****** *)

(* end of [pats_dynexp2_mapgen.dats] *)
