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
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

#staload UN = $UNSAFE

(* ****** ****** *)
//
local
#include "./myatscc_evaler.dats"
in (* nothing *) end // endlocal
//
local
#include "./myatscc_getdef.dats"
in (* nothing *) end // endlocal
//
(* ****** ****** *)
//
// HX: for libats (no need to link -latslib)
//
local
#include "prelude/DATS/filebas.dats"
in (* nothing *) end // endlocal
//
(* ****** ****** *)

#staload "./../SATS/myatscc.sats"

(* ****** ****** *)

fun
comarg_parse
(
  arg: string
) : int = let
//
fun
aux
(
 p: ptr, r: int
) : int = let
  val c = $UN.ptr0_get<char>(p)
in
//
if
isneqz(c)
then (
if c = '-'
  then aux(ptr0_succ<char>(p), r+1) else r
// end of [if]
) else (r)
// end of [if]
end // end of [aux]
//
in
  aux(string2ptr(arg), 0)
end // end of [comarg_parse]

(* ****** ****** *)
//
implement
myatscc_arglst
  {n}(argc, argv) = let
//
fun
loop
{i:nat | i <= n}
(
 i: int(i), argv: !argv(n), res: arglst
) : arglst =
(
if
(i < argc)
then let
  val arg = argv[i]
in
  if comarg_parse(arg) = 0
    then
    loop(i+1, argv, list_vt_cons(string0_copy(arg), res))
    else loop(i+1, argv, res)
  // end of [if]
end // end of [then]
else res (* end of [else] *)
)
//
val res =
list_vt_cons(string0_copy(argv[0]), list_vt_nil())
//
in
  list_vt_reverse(loop(1, argv, res))
end // end of [myatscc_arglst]
//
implement
myatscc_arglst_free
  (args) =
(
case+ args of
| ~list_vt_nil() => ()
| ~list_vt_cons(x, args) =>
    (strptr_free(x); myatscc_arglst_free(args))
  // end of [list_vt_cons]
) (* end of [myatscc_arglst_free] *)
//
(* ****** ****** *)
//
extern
fun
myatscc_usage
  {n:pos}
(
  argc: int(n), argv: !argv(n)
) : int // end-of-function
//
implement
myatscc_usage
  {n}(argc, argv) = let
//
fun
loop
{i:nat | i <= n}
(
 i: int(i), argv: !argv(n)
) : int =
(
if
(i=argc)
then (0)
else
(
case+ argv[i] of
| "-h" => usage()
| "--help" => usage()
| _(* rest *) => loop(i+1, argv)
)
)
//
and
usage(): int = 1 where
{
val () =
println!("Usage: myatscc [FLAG]... [FILE]...")
val () =
println!("\n\
By supporting embedding as comment some form of scripts\n\
for compilation inside the code to be compiled, [myatscc]\n\
is primarily for simplifying the compilation of ATS source.\n\
")
val () =
println!("The following options are supported:")
val () =
println!("  -h/--help: for printing the help message")
val () =
println!("  --dry/--dryrun: for command generation only")
}
//
in
  (if argc >= 2 then loop(1, argv) else usage())
end // end of [myatscc_usage]
//
(* ****** ****** *)

implement
main(argc, argv) = let
//
val done =
  myatscc_usage(argc, argv)
//
in
  if done > 0 then 0 else myatscc_main(argc, argv)
end (* end of [main] *)

(* ****** ****** *)

local
//
#staload
"libats/libc/SATS/stdlib.sats"
//
//
// HX-2026-10:
// [pfx] is a prefix of [str]
//
fun
string_is_prefix
(
  pfx: string, str: string
) : bool = let
//
fun
loop
(
  p1: ptr, p2: ptr
) : bool = let
  val c1 = $UN.ptr0_get<char>(p1)
in
  if
  isneqz(c1)
  then
  (
    if c1 = $UN.ptr0_get<char>(p2)
      then loop(ptr0_succ<char>(p1), ptr0_succ<char>(p2)) else false
    // end of [if]
  )
  else true
end // end of [loop]
//
in
  loop(string2ptr(pfx), string2ptr(str))
end // end of [string_is_prefix]
//
fun
dryrun_test
{n:int}
{i:nat|i <= n}
(
  i: int(i)
, argc: int(n)
, argv: !argv(n)
) : bool =
(
if
(i < argc)
then
(
if
string_is_prefix
("--dry", argv[i])
then true
else dryrun_test(i+1, argc, argv)
)
else false // end of [else]
)
//
in (* in-of-local *)

implement
myatscc_main
(
  argc, argv
) = res where {
//
val dryrun =
  dryrun_test(1, argc, argv)
//
val args =
  myatscc_arglst(argc, argv)
//
val def =
  myatscc_getdef(args)
val command =
  myatscc_evaldef($UN.strptr2string(def), args)
//
val command0 = $UN.strptr2string(command)
//
val res =
(
  if dryrun
    then (println!(command0); 0)
    else system(command0)
  // end of [if]
) : int // end of [val]
//
val () = strptr_free(command)
val () = strptr_free(def)
val () = myatscc_arglst_free(args)
//
} // end of [myatscc_main]

end // end of [local]

(* ****** ****** *)

(* end of [myatscc_main.dats] *)
