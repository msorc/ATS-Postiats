(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustworthy Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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
// Start Time: July, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file).
// What changed (see src/PORTING.md, "atsdoc and libatsdoc"):
//
// - [atext] is a handle into the global arena (libatsdoc_atext.spec,
//   arenagen --global): it is a nonlinear value, as in ATS1, and it is
//   never freed. Match on [atext_view(x)] with [~ATEXTnil()]...; the
//   functions below are the ATS1 ones (smart constructors).
// - [atextlst] is [glist(atext)] (the prelude has no nonlinear list);
//   [atext_concatxt_vt] and [atext_concatxtsep_vt] take (and free) a
//   [List0_vt(atext)].
// - the strings given to the constructors are copied into the arena
//   (the ones of [atext_strptr] and the like are kept: the [strptr]
//   is consumed); [theAtextMap_search] returns an [Option_vt].
// - [symbol] is the one of libatsdoc_symbol.sats (it does not need the
//   initialization of the symbols of src/: libatsdoc.a can be linked with
//   libatsopt.a, and it needs nothing but libats/arena).
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)

staload UNISTD = "libats/libc/SATS/unistd.sats"
stadef fildes_v = $UNISTD.fildes_v

(* ****** ****** *)

staload
SYM = "./libatsdoc_symbol.sats"
typedef symbol = $SYM.symbol

(* ****** ****** *)
//
// [atext_type], [atext], [atextlst], [atext_view] and the
// generated functions [atext_encode], [atext_view], [atext_tag],
// [atext_ATEXTnil], ... [atext_is_ATEXTnil]
//
#include "./libatsdoc_atext_gen.hats"
//
typedef atextopt = gopt(atext)
vtypedef atextlst_vt = List0_vt(atext)
vtypedef atextopt_vt = Option_vt(atext)

(* ****** ****** *)

fun atext_nil (): atext
fun atext_strcst (x: string): atext
fun atext_strsub (x: string): atext
fun atext_apptxt2 (x1: atext, x2: atext): atext
fun atext_appstr2 (x1: string, x2: string): atext
fun atext_apptxt3 (x1: atext, x2: atext, x3: atext): atext
fun atext_appstr3 (x1: string, x2: string, x3: string): atext
fun atext_concatxt (xs: atextlst): atext
fun atext_concatxtsep (xs: atextlst, sep: atext): atext

(* ****** ****** *)
//
fun atext_concatxt_vt (xs: atextlst_vt): atext
fun atext_concatxtsep_vt (xs: atextlst_vt, sep: atext): atext
//
(* ****** ****** *)

fun atext_newline ((*void*)): atext

(* ****** ****** *)
//
// HX: the string of [x] is kept (it is not freed)
//
fun atext_strptr (x: Strptr1): atext // atext_strcst of the string of x
fun atext_strptr0 (x: Strptr0): atext // atext_strptr or atext_nil
//
fun atext_strcstptr (x: Strptr1): atext // atext_strcst of the string of x
fun atext_strsubptr (x: Strptr1): atext // atext_strsub of the string of x
//
(* ****** ****** *)

fun atext_filepath (path: string): atext

(* ****** ****** *)

fun theAtextMap_search (s: symbol): atextopt_vt
fun theAtextMap_insert (s: symbol, txt: atext): void
fun theAtextMap_insert_str (s: string, txt: atext): void

(* ****** ****** *)

fun fprint_atext (out: FILEref, x: atext): void
fun fprint_atextlst (out: FILEref, xs: atextlst): void
fun fprint_atextlst_sep (out: FILEref, xs: atextlst, sep: atext): void

(* ****** ****** *)

fun fprint_strsub (out: FILEref, sub: string): void
fun fprint_filsub (out: FILEref, path: string): void

(* ****** ****** *)
//
// HX: [fd] is regular: no support for pipe
//
fun file2strptr {fd:int} (
  pf: !fildes_v fd  | fd: int fd
) : Strptr0 = "ext#libatsdoc_file2strptr" // end of [file2strptr]

(* ****** ****** *)
//
// HX: [prfx] is not used (a [tmpfile] holds the output)
//
fun{a:t@ype}
tostring_fprint
  (prfx: string, fpr: (FILEref, a) -> void, x: a): Strptr0
// end of [tostring_fprint]

fun tostring_strsub (sub: string): Strptr0 // HX: nullptr means error

(* ****** ****** *)

(* end of [libatsdoc_atext.sats] *)
