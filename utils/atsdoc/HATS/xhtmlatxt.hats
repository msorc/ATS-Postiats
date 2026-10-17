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
// Start Time: September, 2011
//
(* ****** ****** *)

(*
** HX: help functions for writing xhtml documents via [atsdoc]
*)

(* ****** ****** *)

#ifndef ATSDOC_XHTMLATXT
#define ATSDOC_XHTMLATXT 1

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
#include "share/atspre_staload.hats"
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload TIME = "libats/libc/SATS/time.sats"
staload STDIO = "libats/libc/SATS/stdio.sats"
//
#ifndef ATSDOC_NO_DYNLOAD
dynload "libatsdoc/dynloadall.dats"
#endif // end of [ATSDOC_NO_DYNLOAD]
staload "libatsdoc/SATS/libatsdoc_atext.sats"
//
#include "utils/atsdoc/HATS/atsdoc_compat.hats"
//
(* ****** ****** *)

local
//
val LT = "<"
val LTSLASH = "</"
val GT = ">"
//
in

fun xmltagging (
  tag: string, x: string
) : atext = let
  val _opn = atext_appstr3 (LT, tag, GT)
  val _clo = atext_appstr3 (LTSLASH, tag, GT)
in
  atext_apptxt3 (_opn, atext_strsub(x), _clo)
end // end of [xmltagging]

end // end of [local]

(* ****** ****** *)

macdef head (x) = xmltagging ("head", ,(x))
macdef title (x) = xmltagging ("title", ,(x))
macdef body (x) = xmltagging ("body", ,(x))

(* ****** ****** *)

macdef H1 (x) = xmltagging ("h1", ,(x))
macdef H2 (x) = xmltagging ("h2", ,(x))
macdef H3 (x) = xmltagging ("h3", ,(x))
macdef H4 (x) = xmltagging ("h4", ,(x))

(* ****** ****** *)

local
//
val COMMENTopn = atext_strcst"<!--"
and COMMENTcls = atext_strcst("-->")
//
in

fun comment (x: string): atext =
  atext_apptxt3 (COMMENTopn, atext_strsub(x), COMMENTcls)
// end of [comment]

end // end of [local]

(* ****** ****** *)

fun ignore (x: string): atext = atext_nil ()
fun ignoretxt (x: atext): atext = atext_nil ()

(* ****** ****** *)

macdef
emph(x) = xmltagging ("em", ,(x))
macdef
emphasis(x) = xmltagging ("em", ,(x))

(* ****** ****** *)

macdef
strong(x) = xmltagging ("strong", ,(x))

(* ****** ****** *)

macdef
textpre(x) = xmltagging ("pre", ,(x)) // <pre> ... </pre>

(* ****** ****** *)

fn pcenter
  (x: string): atext = let
  val opn = atext_strcst"<p style=\"text-align: center;\">"
  val cls = atext_strcst"</p>"
in
  atext_apptxt3 (opn, atext_strsub(x), cls)
end // end of [pcenter]

(* ****** ****** *)

fun timestamp
  (): atext = let
  var time = $TIME.time_get ()
  val (fpf | x) = $TIME.ctime (time)
  val x1 = $UN.castvwtp1{string}(x)
  val x2 = string0_copy (x1)
  prval () = fpf (x)
in
  atext_strptr (x2)
end // end of [timestamp]

(* ****** ****** *)

#endif // end of [#ifndef(ATSDOC_XHTMLATXT)]

(* end of [xhtmlatxt.dats] *)
