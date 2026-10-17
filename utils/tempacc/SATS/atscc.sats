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
(* Authoremail: hwxi AT cs DOT bu DOT edu *)
(* Start time: July, 2013 *)

(* ****** ****** *)

//
// HX-2026-10: no GC
// command-line arguments are kept in linear lists;
// the strings stored in [commarg] values are taken
// from [argv] and are never freed
//
datavtype commarg =
//
  | CAhats of () // -hats: patsopt --help
  | CAvats of () // -vats: patsopt --version 
//
  | CAccats of () // -ccats: compilation only
  | CAtcats of () // -tcats: typechecking only
//
  | CAhelp of () // --help: usage information
  | CAgline of () // --gline: line programa info
//
  | CAverbose of () // -verbose: verbosity
  | CAcleanaft of () // -cleanaft: cleaning up *_?ats.c files
//
  | CAatsccomp of (stropt) // -atsccomp 'gcc ...'
//
  | CAdats of (int(*knd*), stropt) // knd=0/1:-DATS/-DDATS
  | CAiats of (int(*knd*), stropt) // knd=0/1:-IATS/-IIATS
//
  | CAfilats of (int(*knd*), stropt) // knd=0/1:-fsats/-fdats
//
  | CA_tlcalopt_disable // --tlcalopt-disable
  | CA_constraint_ignore // --constraint-ignore
//
  | CA_CCOMPitm of string // any generic item is passed to $(CCOMP)
// end of [commarg]

(* ****** ****** *)
//
vtypedef
commarglst = List0_vt(commarg)
//
fun
commarg_copy(ca: !commarg): commarg
fun
commarg_free(ca: commarg): void
fun
commarglst_free(cas: commarglst): void
//
(* ****** ****** *)
//
// HX-2026-10:
// each argument of a command-line is owned
//
vtypedef arglst = List0_vt(Strptr1)
//
fun arglst_free(args: arglst): void
//
(* ****** ****** *)
//
fun
fprint_commarg(out: FILEref, ca: !commarg): void
fun
fprint_commarglst{n:int}(out: FILEref, cas: !list_vt(commarg, n)): void
//
overload fprint with fprint_commarg of 0
overload fprint with fprint_commarglst of 10
//
(* ****** ****** *)
//
fun{} atsopt_get(): Strptr1
fun{} atsopt_print_usage(): void
//
(* ****** ****** *)
//
fun{} atsccomp_get(): Strptr1
fun{} atsccomp_get2{n:int}(cas: !list_vt(commarg, n)): Strptr1
//
(* ****** ****** *)
//
// HX: flag=0/1:static/dynamic
//
fun atscc_outname(flag: int, path: string): Strptr1
//
(* ****** ****** *)

fun atsccproc_commline{n:int}(int n, !argv(n)): commarglst

(* ****** ****** *)
//
fun
fprint_atsoptline{n:int}
(
  out: FILEref, cas: !list_vt(commarg, n), ca0: !commarg
) : void // end of [fprint_atsoptline]
//
fun
fprint_atsoptline_all{n:int}(FILEref, !list_vt(commarg, n)): void
//
(* ****** ****** *)

fun
fprint_atsccompline{n:int}(out: FILEref, cas: !list_vt(commarg, n)): void

(* ****** ****** *)
//
fun
atsoptline_make{n:int}
  (cas: !list_vt(commarg, n), ca0: !commarg): arglst
//
fun
atsoptline_make_all{n:int}(cas: !list_vt(commarg, n)): List0_vt(arglst)
//
(* ****** ****** *)

fun atsccompline_make{n:int}(cas: !list_vt(commarg, n)): arglst

(* ****** ****** *)
//
fun
atsoptline_exec
( flag: int
, atsopt: string, args: arglst): int(*status*)
fun
atsoptline_exec_all
( flag: int
, atsopt: string, args: List0_vt(arglst)): int(*status*)
//
(* ****** ****** *)
//
fun
atsccomp_cont{n:int}(cas: !list_vt(commarg, n)): bool
//
fun
atsccompline_exec
  (flag: int, atsccomp: string, args: arglst): int(*status*)
//
(* ****** ****** *)

fun atscc_is_help{n:int}(cas: !list_vt(commarg, n)): bool
fun atscc_is_verbose{n:int}(cas: !list_vt(commarg, n)): bool

(* ****** ****** *)

fun atscc_cleanaft_cont{n:int}(cas: !list_vt(commarg, n)): bool
fun atscc_cleanaft_exec{n:int}(flag: int, cas: !list_vt(commarg, n)): void

(* ****** ****** *)

(* end of [atscc.sats] *)
