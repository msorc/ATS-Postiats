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
// Time: February 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_lintprgm_print.dats)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./pats_lintprgm.sats"

(* ****** ****** *)

implement{a}
fprint_myintvec
  (out, iv, n) = let
//
  prval () =
    lemma_myintvec_params (iv)
  // end of [prval]
//
  vtypedef x = myint(a)
//
  fun loop
    {n:nat}{l:addr} .<n>.
  (
    pf: !array_v (x, l, n) | out: FILEref, p: ptr l, n: int n, i: int
  ) : void =
    if n > 0 then let
      prval (pf1, pf2) = array_v_uncons {x} (pf)
      val () = if i > 0 then fprint_string (out, ", ")
      val () = fprint_myint<a> (out, !p)
      val () = loop (pf2 | out, ptr_succ<x> (p), n-1, i+1)
      prval () = pf := array_v_cons {x} (pf1, pf2)
    in
      // nothing
    end // end of [if]
//
  val (pf | p) = myintvec_takeout (iv)
  val () = loop (pf | out, p, n, 0)
  prval () = myintvecout_addback (pf | iv)
in
  (*nothing*)
end // end of [fprint_intvec]

implement{a}
print_myintvec
  (x, n) = fprint_myintvec<a> (stdout_ref, x, n)
// end of [print_myintvec]

(* ****** ****** *)

implement{a}
fprint_myintveclst
  (out, xs, n) =
  case+ xs of
  | @list_vt_cons
      (x, xs1) => let
      val () = fprint_myintvec<a> (out, x, n)
      val () = fprint_newline (out)
      val () = fprint_myintveclst<a> (out, xs1, n)
    in
      ()
    end // end of [list_vt]
  | list_vt_nil () => ()
// end of [fprint_myintveclst]

implement{a}
print_myintveclst
  (xs, n) = fprint_myintveclst<a> (stdout_ref, xs, n)
// end of [print_myintveclst]

(* ****** ****** *)

implement{a}
fprint_icnstr
  (out, ic, n) = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
//
case+ ic of
| @ICvec
    (knd, ivec) => let
    val () = prstr "ICvec("
    val knd1 = knd
    val () = (
      if knd1 = 1 then prstr "=="
      else if knd1 = ~1 then prstr "!="
      else if knd1 = 2 then prstr ">="
      else if knd1 = ~2 then prstr "<<"
      else fprint_int (out, knd1)
    ) : void // end of [val]
    val () = prstr "; "
    val () = fprint_myintvec<a> (out, ivec, n)
    val () = prstr ")"
  in
    ()
  end // end of [ICvec]
| @ICveclst
    (knd, ics1) => let
    val () = prstr "ICveclst("
    val knd1 = knd
    val () = (
      if knd1 = 0 then prstr "conj"
      else if knd1 = 1 then prstr "disj"
      else fprint_int (out, knd1)
    ) : void // end of [val]
    val () = prstr ";"
    val () = prstr "\n"
    val () = fprint_icnstrlst<a> (out, ics1, n)
    val () = prstr ")"
  in
    ()
  end // end of [ICveclst]
//
  | @ICerr _ => let
      val () = prstr "ICerr("
      val () = fprint_string (out, "...")
      val () = prstr ")"
    in
      ()
    end // end of [ICerr]
//
end // end of [fprint_icnstr]

implement{a}
print_icnstr
  (x, n) = fprint_icnstr<a> (stdout_ref, x, n)
// end of [print_icnstr]

(* ****** ****** *)

implement{a}
fprint_icnstrlst
  (out, ics, n) = (
  case+ ics of
  | @list_vt_cons
      (ic, ics1) => let
      val () = fprint_icnstr<a> (out, ic, n)
      val () = fprint_newline (out)
      val () = fprint_icnstrlst<a> (out, ics1, n)
    in
      ()
    end // end of [list_vt_cons]
  | list_vt_nil () => ()
) // end of [fprint_icnstrlst]

implement{a}
print_icnstrlst
  (xs, n) = fprint_icnstrlst<a> (stdout_ref, xs, n)
// end of [print_icnstrlst]

(* ****** ****** *)

(* end of [pats_lintprgm_print.dats] *)
