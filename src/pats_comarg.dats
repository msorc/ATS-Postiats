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
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: April, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_comarg.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "libats/libc/SATS/string.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"
staload GLOB = "./pats_global.sats"

staload LOC = "./pats_location.sats"
staload FIL = "./pats_filename.sats"

staload SYM = "./pats_symbol.sats"
staload SYN = "./pats_syntax.sats"
staload _(*SYN*) = "./pats_syntax.dats"

(* ****** ****** *)

staload PAR = "./pats_parsing.sats"
staload _(*PAR*) = "./pats_parsing_util.dats"
staload _(*PAR*) = "./pats_parsing.dats"

(* ****** ****** *)

staload "./pats_staexp1.sats"
staload TRANS1 = "./pats_trans1.sats"
staload TRENV1 = "./pats_trans1_env.sats"

(* ****** ****** *)

staload "./pats_comarg.sats"

(* ****** ****** *)

%{^
//
extern char* patsopt_PATSRELOCROOT_get () ;
//
%} // end of [%{^]

(* ****** ****** *)
//
implement
print_comarg(x) =
fprint_comarg(stdout_ref, x)
//
implement
fprint_comarg(out, x) =
(
case+ x of
| @(i, k) =>
  (
    fprint_string(out, "COMARG(");
    fprint_int(out, i);
    fprint_string(out, ", ");
    fprint_string(out, k);
    fprint_string(out, ")")
  )
)
//
(* ****** ****** *)

implement
comarg_parse
  (str) = $effmask_all(let
//
fun
loop
(
  p: ptr, i: int
) : comarg = let
  val c = $UN.ptr0_get<char> (p)
in
  if c != '\000'
    then (
    if (c <> '-')
      then @(i, str) else loop (ptr0_succ<char> (p), i+1)
    ) else @(i, str)
end // end of [loop]
//
in
//
if
(str="-")
then
(
  @(0, str)
)
else
(
  loop($UN.cast{ptr}(str), 0)
)
//
end) // end of [comarg_parse]

(* ****** ****** *)

implement
comarglst_parse
  {n}(argc, argv) = $effmask_all(let
//
// HX: built from the back, so the order and the length are kept
//
fun
loop
{i:nat | i <= n}
(
  argv: &(@[string][n]), i: int i, acc: list_vt(comarg, n-i)
) : list_vt(comarg, n) =
(
//
if
i > 0
then let
  val x = comarg_parse (argv[i-1])
in
  loop (argv, i-1, list_vt_cons (x, acc))
end // end of [then]
else acc // end of [else]
//
) (* end of [loop] *)
//
in
  loop (argv, argc, list_vt_nil ())
end) // end of [comarglst_parse]

(* ****** ****** *)

implement
comarg_warning
  (str) = {
//
val () = prerr_string ("warning(ATS)")
val () = prerr_string (": unrecognized command line argument [")
val () = prerr_string (str)
val () = prerr_string ("] is ignored.")
val () = prerr_newline ((*void*))
//
} (* end of [comarg_warning] *)

(* ****** ****** *)

implement
is_DATS_flag (flag) = 
  if strncmp (flag, "-DATS", i2sz(5)) = 0 then true else false
// end of [is_DATS_flag]

implement
is_IATS_flag (flag) = 
  if strncmp (flag, "-IATS", i2sz(5)) = 0 then true else false
// end of [is_IATS_flag]

(* ****** ****** *)

local

fun
string_extract
(
  s: string
) : Stropt = let
  val k = 5 // HX: the length of -DATS and -IATS
  val n = $UN.cast{int}(string_length(s))
in
//
if n > k
  then let
    // HX: the substring is kept (never freed)
    val sub =
      the_garena_strdup
        ($UN.cast{string}(ptr0_add_guint<char>($UN.cast{ptr}(s), i2sz(5))))
  in
    stropt_some (sub)
  end // end of [then]
  else stropt_none ((*void*))
//
end // [string_extract]

in (* in-of-local *)
//
implement
DATS_extract
  (str: string) = string_extract(str)
//
implement
IATS_extract
  (str: string) = string_extract(str)
//
end // end of [local]

(* ****** ****** *)

implement
process_DATS_def
  (def) = let
//
val opt =
  $PAR.parse_from_string_parser<$SYN.datsdef>(def, $PAR.p_datsdef)
//
in
//
case+ opt of
| ~Some_vt(dd) => let
    val key = dd.datsdef_sym()
    val e1xp = (
      case+ gopt_view(dd.datsdef_opt()) of
      | ~GOsome v => $TRANS1.e0xp_tr (v)
      | ~GOnone () => e1xp_none ($LOC.location_dummy)
    ) : e1xp // end of [val]
  in
    $TRENV1.the_e1xpenv_addperv (key, e1xp)
  end // end of [Some_vt]
| ~None_vt((*void*)) => let
    val () =
    prerr_string ("patsopt: error(0)")
    val () = prerr_string (": the command-line argument [")
    val () = prerr_string (def)
    val () = prerr_string ("] cannot be properly parsed.")
    val () = prerr_newline ((*void*))
  in
    $ERR.abort<void> ((*reachable*))
  end // end of [None_vt]
//
end // end of [process_DATS_def]

(* ****** ****** *)
//
// HX: [ppush] means permanent push
//
implement
process_IATS_dir
  (dir) = let
//
val () = $FIL.the_pathlst_ppush(dir)
val () = $GLOB.the_IATS_dirlst_ppush(dir)
//
in
  // nothing
end (* end of [process_IATS_dir] *)

(* ****** ****** *)

local
//
extern
fun
getenv
(
  name: string
) : Stropt = "mac#getenv"
//
in (* in-of-local *)

implement
process_PATSRELOCROOT() = let
//
val
opt =
get() where
{
//
extern
fun
get
(
// argless
) : Stropt =
  "mac#patsopt_PATSRELOCROOT_get"
// end of [extern]
//
} (* where *) // end of [val]
val
issome = stropt_is_some (opt)
//
val def = (
//
if
issome
then
(
stropt_unsome(opt)
) (* end of [then] *)
else let
//
val
user = getenv("USER")
val
issome = stropt_is_some(user)
val
user = (
//
if issome
  then stropt_unsome(user) else "$USER"
//
) : string // end of [val]
val
PATSRELOCROOT =
  string0_append("/tmp/.PATSRELOCROOT-", user)
// end of [val]
//
val res = the_garena_strdup($UN.strptr2string(PATSRELOCROOT))
val ((*freed*)) = strptr_free(PATSRELOCROOT) // HX: copied into the arena
//
in
  res
end // end of [else]
//
) : string // end of [val]
//
val key =
  $SYM.symbol_PATSRELOCROOT
val e1xp =
  e1xp_string ($LOC.location_dummy, def)
//
in
  $TRENV1.the_e1xpenv_addperv (key, e1xp)
end // end of [process_PATSRELOCROOT]

end // end of [local]

(* ****** ****** *)

(* end of [pats_comarg.dats] *)
