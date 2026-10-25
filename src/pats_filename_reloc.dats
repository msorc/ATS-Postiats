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
// Start Time: September, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_filename_reloc.dats)
// The strings that are made here are kept forever (copies in the global arena).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"

(* ****** ****** *)

staload GLOB = "./pats_global.sats"

(* ****** ****** *)

staload FIL = "./pats_filename.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload SYN = "./pats_syntax.sats"
typedef d0ecl = $SYN.d0ecl

(* ****** ****** *)
//
staload "./pats_staexp1.sats"
//
(* ****** ****** *)

staload TRENV1 = "./pats_trans1_env.sats"

(* ****** ****** *)

local
//
fn
my_copy_string
(
  origin: string
) : string = the_garena_strdup (origin)
//
fn
my_make_substring
(
  origin: string, start: size_t, length: size_t
) : string = let
  val p = the_garena_alloc (length + i2sz(1))
  val () = $extfcall (void, "memcpy", p, ptr0_add_guint<char> ($UN.cast{ptr}(origin), start), length)
  val () = $UN.ptr0_set<char> (ptr0_add_guint<char> (p, length), '\000')
in
  $UN.cast{string}(p)
end // end of [my_make_substring]
//
fn
strptr2gstring
  (str: Strptr1): string = let
  val res = the_garena_strdup ($UN.castvwtp1{string}(str))
  val ((*freed*)) = strptr_free (str)
in
  res
end // end of [strptr2gstring]
//
in (* in-of-local *)

(* ****** ****** *)
//
fn
pkgsrcname_get_gurl0
  (given: string, ngurl: int): string = let
//
val start = $UN.cast{size_t}(1)
val length = $UN.cast{size_t}(ngurl - 2)
//
in
  my_make_substring (given, start, length)
end // end of [pkgsrcname_get_gurl0]
//
(* ****** ****** *)
//
fn
pkgsrcname_get_gurl1
  (given: string, ngurl: int): string = my_copy_string("$PATSRELOCROOT")
//
(* ****** ****** *)

fn
pkgsrcname_get2_gurl0
  (given: string, ngurl: int): string = let
//
val p0 = $UN.cast{ptr}(given)
val c1 = $UN.ptr0_get<char>(ptr0_succ<char>(p0))
//
in
//
if
c1 = '$' then let
    val start = $UN.cast{size_t}(2)
    val length = $UN.cast{size_t}(ngurl - 3)
//
    val key =
      my_make_substring(given, start, length)
    val key2 =
      string0_append(key, "_sourceloc")
    // end of [val]
//
    val key2 = strptr2gstring(key2)
    val key2 = $SYM.symbol_make_string(key2)
    val opt2 = $TRENV1.the_e1xpenv_find(key2)
  in
    case+ opt2 of
    | ~None_vt() =>
        pkgsrcname_get_gurl0(given, ngurl)
      // end of [None_vt]
    | ~Some_vt(e) => (
        case+ e1xp_node_view (e.e1xp_node ()) of
        | ~(E1XPstring(x)) => my_copy_string(x)
        | v (*non-E1XPstring*) => (
            e1xp_node_view_free (v); pkgsrcname_get_gurl0(given, ngurl)
          )
      ) (* end of [Some_vt] *)
  end // end of [variable]
//
else (*nonvariable*) pkgsrcname_get_gurl0 (given, ngurl)
//
end // end of [pkgsrcname_get2_gurl0]

(* ****** ****** *)

fn
pkgsrcname_get2_gurl1
  (given: string, ngurl: int): string = let
//
val p0 = $UN.cast{ptr} (given)
val c1 = $UN.ptr0_get<char> (ptr0_succ<char>(p0))
//
in
//
if
c1 = '$' then let
    val start = $UN.cast{size_t}(2)
    val length = $UN.cast{size_t}(ngurl - 3)
    val key = my_make_substring(given, start, length)
    val key2 =
      string0_append(key, "_targetloc")
    // end of [val]
    val key2 = strptr2gstring(key2)
    val key2 = $SYM.symbol_make_string(key2)
    val opt2 = $TRENV1.the_e1xpenv_find(key2)
  in
    case+ opt2 of
    | ~None_vt() =>
        pkgsrcname_get_gurl1(given, ngurl)
      // end of [None_vt]
    | ~Some_vt(e) => (
        case+ e1xp_node_view (e.e1xp_node ()) of
        | ~(E1XPstring(x)) => my_copy_string(x)
        | v (*non-E1XPstring*) => (
            e1xp_node_view_free (v); pkgsrcname_get_gurl1(given, ngurl)
          )
      ) (* end of [Some_vt] *)
  end // end of [variable]
//
else (*nonvariable*) pkgsrcname_get_gurl1(given, ngurl)
//
end // end of [pkgsrcname_get2_gurl1]

(* ****** ****** *)
//
fn
pkgsrcname_eval
  (given: string): string = let
//
#define NDEPTH 100
//
fn isalnum_ (c: char): bool =
  if isalnum_char(c) then true else (c = '_')
//
fun
auxtrav
(
  p0: ptr, n: int
) : int = let
  val c0 = $UN.ptr0_get<char>(p0)
in
//
if
isalnum_(c0)
then
(
  auxtrav(ptr0_succ<char>(p0), n+1)
) else (n) // end of [if]
//
end (* end of [auxtrav] *)
//
fun
auxeval0
(
  given: string, ndepth: int
) : string =
(
  if ndepth < NDEPTH
    then auxeval1(given, ndepth) else given
) (* end of [auxeval0] *)
//
and
auxeval1
(
  given: string, ndepth: int
) : string = let
//
val p0 = $UN.cast{ptr}(given)
val c0 = $UN.ptr0_get<char>(p0)
//
in
//
if
c0 = '$' then let
    val p1 = ptr0_succ<char>(p0)
    val nk = auxtrav(p1, 0(*n*))
    val st0 = $UN.cast{size_t}(1)
    val len = $UN.cast{size_t}(nk)
    val key =
      my_make_substring(given, st0, len)
    // end of [val]
    val key = $SYM.symbol_make_string(key)
    val opt = $TRENV1.the_e1xpenv_find(key)
//
  in
    case+ opt of
    | ~None_vt() =>
      (
        given
      ) (* end of [None_vt] *)
    | ~Some_vt(e) =>
      (
        case+ e1xp_node_view (e.e1xp_node ()) of
        | ~(E1XPstring(x)) => let
            val
            pnk = ptr0_add_gint<char>(p1, nk)
            val
            given2 =
            string0_append(x, $UN.cast{string}(pnk))
          in
            auxeval0(strptr2gstring(given2), ndepth+1)
          end (* end of [E1XPstring] *)
        | v (*non-E1XPstring*) => (
            e1xp_node_view_free (v); given
          )
      ) (* end of [Some_vt] *)
  end // end of [variable]
else (*nonvariable*) given
//
end // end of [auxeval1]
//
in
  auxeval0(given, 0(*ndepth*))
end // end of [pkgsrcname_eval]

(* ****** ****** *)

implement
$FIL.pkgsrcname_relocatize
  (given, ngurl) = let
//
val
srcd0c =
$GLOB.the_ATSRELOC_get_decl()
//
in
//
if
(ngurl < 0)
then let
//
val ((*void*)) =
if ptr_isnot_null(srcd0c) then
{
  val srcd0c =
    $UN.cast{$SYN.d0ecl}(srcd0c)
  val ((*void*)) =
    $TRENV1.the_atsreloc_insert(srcd0c, given)
} (* end of [if] *) // end of [val]
//
in
  given // target
end // end of [then]
else let
//
val p0 = $UN.cast{ptr}(given)
val p_ngurl = ptr0_add_gint<char>(p0, ngurl)
val p_ngurl = $UN.cast{string}(p_ngurl)
//
val dirsep = $FIL.theDirSep_get ()
//
val gurl_t = // target
  pkgsrcname_get2_gurl1(given, ngurl)
//
val given2_t =
  $UT.dirpath_append(gurl_t, p_ngurl, dirsep)
//
val given2_t = pkgsrcname_eval(strptr2gstring(given2_t))
//
val () =
if
ptr_isnot_null(srcd0c)
then
{
//
val gurl_s = // source
  pkgsrcname_get2_gurl0(given, ngurl)
//
val given2_s =
  $UT.dirpath_append(gurl_s, p_ngurl, dirsep)
//
val given2_s = pkgsrcname_eval(strptr2gstring(given2_s))
//
val srcd0c = $UN.cast{$SYN.d0ecl}(srcd0c)
val ((*void*)) = $TRENV1.the_atsreloc_insert2(srcd0c, given2_s, given2_t)
//
} (* end of [if] *) // end of [val]
//
in
  given2_t // target
end // end of [else]
//
end // end of [pkgsrcname_relocatize]

end // end of [local]

(* ****** ****** *)

(* end of [pats_filename_reloc.dats] *)
