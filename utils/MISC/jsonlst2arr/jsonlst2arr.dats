(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2014 Hongwei Xi, ATS Trustful Software, Inc.
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
// HX-2013-07:
// [jsonlst2arr] turns a list of json-objects into a json-array of these
// objects. This code sets up an example that shows a way to implement a
// command to be used in a command-line.
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/libc/SATS/string.sats"

(* ****** ****** *)
//
#define
JSONC_targetloc
"$PATSHOME/contrib/atscntrb/atscntrb-hx-libjson-c"
//
(* ****** ****** *)

staload "{$JSONC}/SATS/json.sats"
staload _(*anon*) = "{$JSONC}/DATS/json.dats"

(* ****** ****** *)

fun
jsonlst2arr_usage
(
  out: FILEref, arg0: string
) : void = let
//
in
//
fprintln! (out, "usage: ", arg0, " <command> ... <command>\n");
fprintln! (out, "where a <command> is of one of the following forms:\n");
//
fprintln! (out, "  -h (for printing out this help usage)");
fprintln! (out, "  --help (for printing out this help usage)");
//
fprintln! (out, "  -i <filenames> (for processing (many) static <filenames>)");
fprintln! (out, "  --input <filenames> (for processing (many) static <filenames>)");
//
fprintln! (out, "  -o <filename> (output into <filename>)");
fprintln! (out, "  --output <filename> (output into <filename>)");
//
fprintln! (out, "  --delim <string> (for setting delimiter to <string>)");
//
end // end of [jsonlst2arr]

(* ****** ****** *)

extern
fun
jsonlst2arr_main
  (out: FILEref, inp: FILEref, delim: string, n: int): int
// end of [jsonlst2arr_main]

(* ****** ****** *)

implement
jsonlst2arr_main
  (out, inp, delim, n) = let
//
vtypedef jobj = json_object0
//
fun
auxlst
(
  xs: List_vt (jobj), n: int
) : int = let
in
//
case+ xs of
| ~list_vt_cons
    (x, xs) => let
//
    val () =
      if n > 0 then fprint (out, ",\n")
    // end of [val]
//
    val () =
    (
      fprint_json_object (out, x); fprint (out, "\n")
    ) (* end of [val] *)
//
    val _(*freed*) = json_object_put (x)
//
  in
    auxlst (xs, n+1)
  end // end of [list_vt_cons]
| ~list_vt_nil((*void*)) => (n)
//
end // end of [auxlst]
//
val cs =
  fileref_get_file_string (inp)
//
val xs =
  json_tokener_parse_list_delim ($UN.strptr2string(cs), delim)
//
val ((*void*)) = strptr_free (cs)
//
in
  auxlst (xs, n)
end // end of [jsonlst2arr_main]

(* ****** ****** *)

//
// HX-2026-10: no GC
// a command-line argument is a flat pair
// of a tag and an optional string (from argv)
//
typedef
commarg = @(int, stropt)
//
#define CAhelp 0
#define CAinput 1
#define CAoutput 2
#define CAdelim 3
#define CAgitem 4
//

(* ****** ****** *)
//
vtypedef commarglst = List0_vt(commarg)
//
vtypedef commarglst_vt = List0_vt(commarg)
//
(* ****** ****** *)

macdef
unsome(opt) = stropt_unsome(,(opt))
macdef
issome(opt) = stropt_is_some(,(opt))

(* ****** ****** *)

fun{
} argv_getopt_at
  {n:int}{i:nat}
(
  n: int n, argv: !argv(n), i: int i
) : stropt =
(
  if i < n then stropt_some (argv[i]) else stropt_none ()
) (* end of [argv_getopt_at] *)

(* ****** ****** *)
//
extern
fun jsonlst2arr_cmdline
  {n:int} (argc: int n, argv: !argv(n)): commarglst
// 
(* ****** ****** *)

local

fun aux0
  {n:int}
  {i:nat | i <= n}
  .<3*(n-i)+2>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt =
(
  if i < n then aux1 (n, argv, i, res) else res
) // end of [aux0]

and aux1
  {n:int}
  {i:nat | i < n}
  .<3*(n-i)+1>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt = let
//
val str0 = argv[i]
//
in
//
case+ 0 of
//
| _ when (str0="-h") =>
    aux1_help (n, argv, i, res)
| _ when (str0="--help") =>
    aux1_help (n, argv, i, res)
//
| _ when (str0="-i") =>
    aux1_input (n, argv, i, res)
| _ when (str0="--input") =>
    aux1_input (n, argv, i, res)
//
| _ when (str0="-o") =>
    aux1_output (n, argv, i+1, res)
| _ when (str0="--output") =>
    aux1_output (n, argv, i+1, res)
//
| _ when (str0="--delim") =>
    aux1_delim (n, argv, i+1, res)
//
| _ => let
    val res =
      list_vt_cons{commarg}(@(CAgitem, stropt_some(str0)), res)
    // end of [val]
  in
    aux0 (n, argv, i+1, res)
  end // end of [_]
//
end // end of [aux1]

and
aux1_help
  {n:int}
  {i:nat | i < n}
  .<3*(n-i)+0>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt = let
  val res =
    list_vt_cons{commarg}(@(CAhelp, stropt_none()), res)
  // end of [val]
in
  aux0 (n, argv, i+1, res)
end // end of [aux1_help]

and
aux1_input
  {n:int}
  {i:nat | i < n}
  .<3*(n-i)+0>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt = let
  val res =
    list_vt_cons{commarg}(@(CAinput, stropt_none()), res)
  // end of [val]
in
  aux0 (n, argv, i+1, res)
end // end of [aux1_input]

and
aux1_output
  {n:int}
  {i:nat | i <= n}
  .<3*(n-i)+0>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt = let
//
val opt =
  argv_getopt_at (n, argv, i)
//
val res =
  list_vt_cons{commarg}(@(CAoutput, opt), res)
//
in
  if i < n then aux0(n, argv, i+1, res) else res
end // end of [aux1_output]

and
aux1_delim
  {n:int}
  {i:nat | i <= n}
  .<3*(n-i)+0>.
(
  n: int n
, argv: !argv(n)
, i: int i
, res: commarglst_vt
) : commarglst_vt = let
//
val opt =
  argv_getopt_at(n, argv, i)
val res =
  list_vt_cons{commarg}(@(CAdelim, opt), res)
//
in
  if i < n then aux0(n, argv, i+1, res) else res
end // end of [aux1_delim]

in (* in of [local] *)

implement
jsonlst2arr_cmdline
  (argc, argv) = let
//
prval (
) = lemma_argv_param (argv)
//
val res =
  list_vt_nil{commarg}()
//
val res = aux0(argc, argv, 0, res)
val res = list_vt_reverse(res)
//
in
  res
end // end of [jsonlst2arr_cmdline]

end // end of [local]

(* ****** ****** *)
//
extern
fun
jsonlst2arr_exec
(
  out: stropt
, inplst: stringlst_vt, delim: stropt
) : void // end of [jsonlst2arr_exec]
//
implement
jsonlst2arr_exec
(
  out, inplst, delim
) = let
//
var flag: int = 0
var out2: FILEref = stdout_ref
val ()  = (
//
if
issome(out)
then let
//
val opt =
  fileref_open_opt (unsome(out), file_mode_w)
//
in
//
case+ opt of
| ~Some_vt (x) => (flag := 1; out2 := x)
| ~None_vt ((*void*)) => out2 := stderr_ref
//
end // end of [then]
else () // end of [else]
//
) : void // end of [val]
//
val
out2 = out2
//
val
delim2 = (
//
if issome(delim) then unsome(delim) else ""
//
) : string // end of [val]
//
fun
auxlst
(
  inplst: stringlst_vt, n: int
) : int = let
//
in
//
case+ inplst of
//
| ~list_vt_cons
    (inp, inplst) => let
    val opt =
      fileref_open_opt (inp, file_mode_r)
    // end of [val]
  in
    case+ opt of
    | ~Some_vt (x) => let
        val n = jsonlst2arr_main(out2, x, delim2, n) in auxlst (inplst, n)
      end // end of [Some_vt]
    | ~None_vt ((*void*)) => auxlst (inplst, n)
  end // end of [list_vt_cons] 
//
| ~list_vt_nil((*void*)) => (n)
//
end // end of [auxlst]
//
val () = fprint (out2, "[\n")
//
val nent = (
case+ inplst of
| list_vt_cons _ => auxlst (inplst, 0)
| ~list_vt_nil() =>
    jsonlst2arr_main(out2, stdin_ref, delim2, 0)
  // end of [list_vt_nil]
) : int // end of [val]
//
val () = fprint (out2, "]\n")
//
val () = if flag > 0 then fileref_close(out2)
//
in
  // nothing
end // end of [jsonlst2arr_exec]
//
(* ****** ****** *)
//
extern
fun
jsonlst2arr_proc
  (arg0: string, cas: commarglst): void
//
(* ****** ****** *)

implement
jsonlst2arr_proc (arg0, cas) = let
//
fun auxexec
(
  out: stropt
, inplst: &stringlst_vt >> stringlst_vt
, delim: stropt
, nexec: &int >> int
) : void = let
//
val nexec0 = nexec
val () = nexec := nexec0 + 1
val xs = list_vt_reverse (inplst)
val () = inplst := list_vt_nil ()
//
in
//
case+ xs of
| list_vt_cons _ =>
    jsonlst2arr_exec (out, xs, delim)
| ~list_vt_nil () =>
    if nexec0 = 0 then jsonlst2arr_exec (out, list_vt_nil, delim) else ()
  // end of [list_nil]
//
end // end of [auxexec]
//
var out: stropt = stropt_none ()
var delim: stropt = stropt_none ()
var nexec: int = 0
var inplst: stringlst_vt = list_vt_nil ()
//
fun auxlst
(
  cas0: commarglst
, out: &stropt, delim: &stropt
, inplst: &stringlst_vt >> stringlst_vt, nexec: &int
, input: bool
) : void = let
in
//
case+ cas0 of
| ~list_vt_cons
    (ca, cas) => let
    val tag = ca.0
  in
    if input && tag = CAgitem
      then let
        val opt = ca.1
        val str =
        (
          if issome(opt) then unsome(opt) else ""
        ) : string // end of [val]
        val () =
        inplst := list_vt_cons{string}(str, inplst)
      in
        auxlst (cas, out, delim, inplst, nexec, true)
      end // end of [then]
      else let
        val () =
          if input then auxexec (out, inplst, delim, nexec)
        // end of [val]
        val () =
        (
          case+ tag of
          | CAhelp => let
              val () =
                jsonlst2arr_usage (stdout_ref, arg0)
              // end of [val]
            in
              nexec := nexec + 1
            end // end of [CAhelp]
          | CAoutput => out := ca.1
          | CAdelim => delim := ca.1
          | _ (*CAinput/CAgitem*) => ()
        ) : void // end of [val]
      in
        auxlst (cas, out, delim, inplst, nexec, tag = CAinput)
      end // end of [else]
  end // end of [list_vt_cons]
| ~list_vt_nil () => auxexec (out, inplst, delim, nexec)
//
end // end of [auxlst]
//
val () = auxlst (cas, out, delim, inplst, nexec, false)
val () = list_vt_free (inplst)
//
in
  // nothing
end // end of [jsonlst2arr_proc]

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
val cas =
  jsonlst2arr_cmdline (argc, argv)
val-~list_vt_cons (_, cas) = cas
//
val ((*void*)) = jsonlst2arr_proc (argv[0], cas)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [jsonlst2arr.dats] *)
