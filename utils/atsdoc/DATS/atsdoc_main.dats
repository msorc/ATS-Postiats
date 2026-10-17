(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(*                              Hongwei Xi                             *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
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
// Author: Hongwei Xi (gmhwxi AT gmail DOT com)
// Start Time: August, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file).
// The command line is processed by a loop over the arguments
// (the list of the arguments, which was a list_vt, is gone); the state
// ([waitkind], [ninputfile]) and the quirks are the ones of ATS1.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

%{^
#include "libatsdoc/CATS/libatsdoc_sbuf.cats"
%}

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

extern
fun fprint_newline_ne (out: FILEref): void = "mac#libatsdoc_fprint_newline"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./../SATS/atsdoc_translate.sats"

(* ****** ****** *)
//
// HX: the modules of src/ (symbols, filenames, locations, lexical buffers: they
// need most of the others for their initialization) are initialized by
// [libatsopt_dynloadall] of libatsopt.a
//
extern
fun libatsopt_dynloadall (): void = "ext#libatsopt_dynloadall"
//
dynload "./atsdoc_translate.dats"
dynload "./atsdoc_translate_error.dats"
dynload "./atsdoc_translate_item.dats"
//
(* ****** ****** *)

extern
fun comarg_nhyphen (s: string): int // the number of leading hyphens

implement
comarg_nhyphen (s) = let
  fun loop (p: ptr, i: int): int = let
    val c = $UN.ptr0_get<char> (p)
  in
    if c != '-' then i else loop (ptr0_succ<char> (p), i+1)
  end // end of [loop]
in
  loop ($UN.cast{ptr}(s), 0)
end // end of [comarg_nhyphen]

(* ****** ****** *)

fn comarg_warning
  (str: string) = {
  val () = prerr_string "waring(ATSDOC)"
  val () = prerr_string ": unrecognized command line argument ["
  val () = prerr_string str
  val () = prerr_string "] is ignored."
  val () = fprint_newline_ne (stderr_ref)
} // end of [comarg_warning]

(* ****** ****** *)

#define WTKnone 0
#define WTKinput 1 // -i ...
#define WTKoutcode 2 // --outcode ... // data
#define WTKoutdata 3 // --outdata ... // code
#define WTKprefix 4 // --prefix

(* ****** ****** *)
//
// HX: an output channel is a FILE and a flag: 1 if it is to be closed
// (cells of the global arena: [k] is 0 for outcode and 1 for outdata)
//
local

val the_ochans: ptr = let
  val p = the_garena_alloc (i2sz(4) * sizeof<ptr>)
  val () = $UN.ptr0_set<FILEref> (p, stdout_ref)
  val () = $UN.ptr0_set<int> (ptr0_add_guint<ptr> (p, i2sz(1)), 0)
  val () = $UN.ptr0_set<FILEref> (ptr0_add_guint<ptr> (p, i2sz(2)), stdout_ref)
  val () = $UN.ptr0_set<int> (ptr0_add_guint<ptr> (p, i2sz(3)), 0)
in p end

fn slot (k: int, j: int): ptr =
  ptr0_add_guint<ptr> (the_ochans, g0int2uint_int_size (2 * k + j))

in

fn ochan_get_fileref (k: int): FILEref = $UN.ptr0_get<FILEref> (slot (k, 0))
fn ochan_get_own (k: int): int = $UN.ptr0_get<int> (slot (k, 1))
fn ochan_set (k: int, filr: FILEref, own: int): void = {
  val () = $UN.ptr0_set<FILEref> (slot (k, 0), filr)
  val () = $UN.ptr0_set<int> (slot (k, 1), own)
}

end // end of [local]

extern
fun atsdoc_fclose_exn (filr: FILEref): void = "ext#atsdoc_fclose_exn"
extern
fun atsdoc_fopen_w (path: string): ptr = "ext#atsdoc_fopen_w"

fn ochan_close (k: int): void =
  if ochan_get_own (k) > 0 then atsdoc_fclose_exn (ochan_get_fileref (k))

(* ****** ****** *)

fn ochan_set_filename
  (k: int, path: string): void = let
  val filp = atsdoc_fopen_w (path)
  val () = ochan_close (k)
in
  if $UN.cast{lint}(filp) != 0L
    then ochan_set (k, $UN.cast{FILEref}(filp), 1)
    else ochan_set (k, stderr_ref, 0)
end // end of [ochan_set_filename]

(* ****** ****** *)

local

val argv0: ptr = let
  val p = the_garena_alloc (sizeof<string>)
  val () = $UN.ptr0_set<string> (p, "")
in p end

in // in of [local]

fn argv0_get (): string = $UN.ptr0_get<string> (argv0)
fn argv0_set (cmd: string): void = $UN.ptr0_set<string> (argv0, cmd)

end // end of [local]

fn atsdoc_usage (): void = {
  val cmd = argv0_get () // [argv0] is already set
  val out = stdout_ref
  val () = fprint_string (out, "usage: ")
  val () = fprint_string (out, cmd)
  val () = fprint_string (out, " <command> ... <command>\n\n")
  val () = fprint_string (out, "where each <command> is of one of the following forms:\n\n")
  val () = fprint_string (out, "  -i filenames (for taking input from <filenames>)\n")
  val () = fprint_string (out, "  --input filenames (for taking input from <filenames>)\n")
  val () = fprint_string (out, "  -oc filename (outputing texting code to <filename>)\n")
  val () = fprint_string (out, "  --outcode filename (outputing texting code to <filename>)\n")
  val () = fprint_string (out, "  -od filename (outputing texting data to <filename>)\n")
  val () = fprint_string (out, "  --outdata filename (outputing texting data to <filename>)\n")
  val () = fprint_string (out, "  -h (for printing out the usage)\n")
  val () = fprint_string (out, "  --help (for printing out the usage)\n")
  val () = fprint_string (out, "\n")
} // end of [atsdoc_usage]

(* ****** ****** *)

fn streq (x: string, y: string): bool = (compare (x, y) = 0)

(* ****** ****** *)

fun
process_cmdline (
  argc: int, argv: ptr, i: int, wk: &int, nif: &int
) : void = let
in
//
if i >= argc then (
  if nif = 0 then let
    val filr = ochan_get_fileref (1)
    val () = trans_top_from_stdin (filr)
    val filr = ochan_get_fileref (0)
    val () = fprint_the_tranitmlst (filr, "STDIN")
  in
    // nothing
  end // end of [if]
) else let
  val key = $UN.ptr0_get<string> (ptr0_add_gint<ptr> (argv, i))
  val nh = comarg_nhyphen (key)
in
//
if wk = WTKinput then let
//
// HX: the [WTKinput] state stays unchanged
//
  val nif0 = nif
in
  if nh = 1 andalso nif0 > 0 then
    process_cmdline2_COMARGkey1 (argc, argv, i, wk, nif, key)
  else if nh = 2 andalso nif0 > 0 then
    process_cmdline2_COMARGkey2 (argc, argv, i, wk, nif, key)
  else let
    val () = nif := nif + 1
    val filr = ochan_get_fileref (1)
    val () = trans_top_from_basename (filr, key)
    val filr = ochan_get_fileref (0)
    val () = fprint_the_tranitmlst (filr, key)
  in
    process_cmdline (argc, argv, i+1, wk, nif)
  end // end of [if]
end else if wk = WTKoutcode then let
  val () = wk := WTKnone
  val () = ochan_set_filename (0, key)
in
  process_cmdline (argc, argv, i+1, wk, nif)
end else if wk = WTKoutdata then let
  val () = wk := WTKnone
  val () = ochan_set_filename (1, key)
in
  process_cmdline (argc, argv, i+1, wk, nif)
end else if wk = WTKprefix then let
  val () = wk := WTKnone
  val () = funres_set_prfx (key) // HX: prefix for return names
in
  process_cmdline (argc, argv, i+1, wk, nif)
end else if nh = 1 then
  process_cmdline2_COMARGkey1 (argc, argv, i, wk, nif, key)
else if nh = 2 then
  process_cmdline2_COMARGkey2 (argc, argv, i, wk, nif, key)
else let
  val () = wk := WTKnone
  val () = comarg_warning (key)
in
  process_cmdline (argc, argv, i+1, wk, nif)
end // end of [if]
//
end // end of [if]
//
end // end of [process_cmdline]

and
process_cmdline2_COMARGkey1 (
  argc: int, argv: ptr, i: int, wk: &int, nif: &int, key: string
) : void = let
  val () = wk := WTKnone
  val () = (
    if streq (key, "-i") then {
        val () = nif := 0
        val () = wk := WTKinput
      }
    else if streq (key, "-oc") then {
        val () = nif := 0
        val () = wk := WTKoutcode
      }
    else if streq (key, "-od") then {
        val () = nif := 0
        val () = wk := WTKoutdata
      }
    else if streq (key, "-h") then {
        val () = wk := WTKnone
        val () = nif := nif + 1 // HX: cutting a corner!
        val () = atsdoc_usage () // print out usage
      }
    else comarg_warning (key)
  ) : void // end of [val]
in
  process_cmdline (argc, argv, i+1, wk, nif)
end // end of [process_cmdline2_COMARGkey1]

and
process_cmdline2_COMARGkey2 (
  argc: int, argv: ptr, i: int, wk: &int, nif: &int, key: string
) : void = let
  val () = wk := WTKnone
  val () = (
    if streq (key, "--input") then {
        val () = nif := 0
        val () = wk := WTKinput
      }
    else if streq (key, "--outcode") then {
        val () = wk := WTKoutcode
      }
    else if streq (key, "--outdata") then {
        val () = wk := WTKoutdata
      }
    else if streq (key, "--prefix") then {
        val () = wk := WTKprefix
      }
    else if streq (key, "--help") then {
        val () = wk := WTKnone
        val () = nif := nif + 1 // HX: cutting a corner!
        val () = atsdoc_usage () // print out usage
      }
    else comarg_warning (key)
  ) : void // end of [val]
in
  process_cmdline (argc, argv, i+1, wk, nif)
end // end of [process_cmdline2_COMARGkey2]

(* ****** ****** *)

implement
main0 (
  argc, argv
) = () where {
//
val () = libatsopt_dynloadall ()
//
val argvp = $UN.castvwtp1{ptr}(argv)
val () = argv0_set ($UN.ptr0_get<string> (argvp))
//
var wk: int = WTKnone
var nif: int = 0
//
val () = process_cmdline (argc, argvp, 1, wk, nif)
//
val () = ochan_close (0)
val () = ochan_close (1)
//
} // end of [main0]

(* ****** ****** *)

%{$
atstype_ptr
atsdoc_fopen_w (atstype_ptr path)
{
  return fopen ((char*)path, "w") ;
}

atstype_void
atsdoc_fclose_exn (atstype_ptr filr)
{
  int err = fclose ((FILE*)filr) ;
  if (err != 0) {
    perror ("fclose") ;
    fprintf (stderr, "exit(ATS): [fclose] failed\n") ;
    exit (1) ;
  }
  return ;
}
%}

(* end of [atsdoc_main.dats] *)
