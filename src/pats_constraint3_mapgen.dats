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
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3_mapgen.dats, see PORTING.md, "Constraint solving (constraint3)")
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

staload "./pats_jsonize.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload _(*anon*) = "./pats_staexp2.dats" // [synentlst_app]

(* ****** ****** *)

staload "./pats_trans3_env.sats"
staload "./pats_constraint3.sats"

(* ****** ****** *)

local
//
extern
fun s2cst_app (x: s2cst, env: !appenv): void
and s2var_app (x: s2var, env: !appenv): void
and s2Var_app (x: s2Var, env: !appenv): void
and d2con_app (x: d2con, env: !appenv): void
//
#include "./pats_staexp2_appenv.hats"
#include "./pats_constraint3_appenv.hats"
//
datavtype myenv =
  | MYENV of (s2cstset_vt, s2varset_vt, s2Varset_vt)
//
in
//
implement
s2cst_app
  (s2c, env) = let
//
val env2 =
  $UN.castvwtp1{myenv}(env)
val+@MYENV (s2cs, _, _) = env2
//
val ismem =
  s2cstset_vt_ismem (s2cs, s2c)
//
val () = (
if
(ismem)
then fold@ (env2)
else let
//
val () =
  s2cs :=
  s2cstset_vt_add(s2cs, s2c)
//
prval () = fold@ (env2)
//
in
  s2expopt_app (s2cst_get_def(s2c), env)
end // end of [else]
) (* end of [val] *)
//
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
val+@MYENV (_, s2vs, _) = env2
val ((*void*)) =
  s2vs := s2varset_vt_add(s2vs, s2v)
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
val+@MYENV (_, _, s2Vs) = env2
//
val ismem =
  s2Varset_vt_ismem (s2Vs, s2V)
//
val () =
if
(ismem)
then fold@ (env2)
else let
//
val () =
  s2Vs :=
  s2Varset_vt_add(s2Vs, s2V)
//
prval () = fold@ (env2)
//
val opt = s2Var_get_link (s2V)
val void = s2expopt_app (opt, env)
//
val s2ze = s2Var_get_szexp (s2V)
val ((*void*)) = s2zexp_app (s2ze, env)
//
in
  // nothing
end // end of [else]
//
val ((*void*)) = $UN.castvwtp0{void}(env2)
//
in
  // nothing
end // end of [s2Var_app]

implement d2con_app (s2v, env) = ()

(* ****** ****** *)

implement
c3nstr_mapgen_scst_svar
  (c3t) = let
//
val s2cs = s2cstset_vt_nil ()
val s2vs = s2varset_vt_nil ()
val s2Vs = s2Varset_vt_nil ()
//
val appenv =
  $UN.castvwtp0{appenv}(MYENV(s2cs, s2vs, s2Vs))
//
val ((*void*)) = c3nstr_app (c3t, appenv)
//
val+~MYENV(s2cs, s2vs, s2Vs) = $UN.castvwtp0{myenv}(appenv)
//
val ((*void*)) = s2Varset_vt_free (s2Vs)
//
in
  @(s2cs, s2vs)
end // end of [c3nstr_mapgen_scst_svar]

end // end of [local]

(* ****** ****** *)

(* end of [pats_constraint3_mapgen.dats] *)
