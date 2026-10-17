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

(* Author: Hongwei Xi *)
(* Authoremail: hwxiATcsDOTbuDOTedu *)
(* Start time: July, 2013 *)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#staload
"libats/libc/DATS/stdlib.dats"
//
(* ****** ****** *)

#dynload "./atscc_main.dats"
#dynload "./atscc_print.dats"

(* ****** ****** *)
//
#staload "./../SATS/atscc.sats"
//
#staload UN = $UNSAFE
//
(* ****** ****** *)
//
#staload _(*anon*) = "./atscc_util.dats"
//
(* ****** ****** *)

//
// HX-2026-10:
// [cas] is linear; a branch that borrows it is
// wrapped in a function so that the type of [cas]
// in the caller is unaffected by the branching
//
fun
ccomp_exec_if
{n:int}
(
  cont: bool
, verb: int
, cas: !list_vt(commarg, n)
, status: &int >> _
) : void =
if cont then
{
//
val cmd = atsccomp_get2(cas)
val arglst = atsccompline_make (cas)
val () =
(
  status :=
  atsccompline_exec(verb, $UN.strptr2string(cmd), arglst)
) (* end of [val] *)
val () = strptr_free(cmd)
//
} (* end of [if] *) // end of [ccomp_exec_if]
//
fun
cleanaft_exec_if
{n:int}
(
  cont: bool
, verb: int
, cas: !list_vt(commarg, n)
) : void =
(
  if cont then atscc_cleanaft_exec(verb, cas)
) (* end of [cleanaft_exec_if] *)
//
implement
main0(argc, argv) =
{
//
var status: int = 0
//
//
// HX-2015-03-22:
// [tempacc] for [tempacc -vats]
// (handled by [atsccproc_commline])
//
val cas =
atsccproc_commline(argc, argv)
//
val help = atscc_is_help(cas)
//
val () =
(
  if help then atsopt_print_usage()
) (* end of [val] *)
//
val verb =
(
  if atscc_is_verbose(cas) then 1 else 0
) : int // end of [val]
//
val cmd = atsopt_get()
val argss = atsoptline_make_all(cas)
val () =
  status :=
  atsoptline_exec_all(verb, $UN.strptr2string(cmd), argss)
val () = strptr_free(cmd)
//
val ccomp = atsccomp_cont(cas)
val cont =
(
  if status = 0 then ccomp else false
) : bool // end of [val]
val () =
  ccomp_exec_if(cont, verb, cas, status)
//
val cleanaft = atscc_cleanaft_cont(cas)
val cont =
(
  if status = 0 then cleanaft else false
) : bool // end of [val]
//
val () =
  cleanaft_exec_if(cont, verb, cas)
//
val () = commarglst_free(cas)
//
val () =
exit_void
(
  if (status = 0) then 0(*success*) else 1(*failure*)
) (* end of [val] *)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [tempacc.dats] *)
