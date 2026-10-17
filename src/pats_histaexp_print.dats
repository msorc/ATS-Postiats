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
// Start Time: July, 2012
//
(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_histaexp_print.dats)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"
staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"

(* ****** ****** *)

extern
fun fprint_labhisexp (out: FILEref, x: labhisexp): void

(* ****** ****** *)

(*
** HX: [print_hitnam], [prerr_hitnam] and [fprint_hitnam] are declared in
** pats_histaexp.sats and implemented nowhere (neither in ATS1).
*)

(* ****** ****** *)

implement
fprint_hisexp
   (out, hse) = let
//
macdef prstr (s) = fprint_string (out, ,(s))
//
val nd = hse.hisexp_node()
//
in
//
case+
  hisexp_node_view(nd) of
//
| ~HSEfun (
    fc, _arg, _res
  ) => {
    val () = prstr "HSEfun("
    val () = fprint_funclo(out, fc)
    val () = prstr "; "
    val () = fprint_hisexplst(out, _arg)
    val () = prstr "; "
    val () = fprint_hisexp(out, _res)
    val () = prstr ")"
  } // end of [HSEfun]
//
| ~HSEcst (s2c) => {
    val () = prstr "HSEcst("
    val () = fprint_s2cst (out, s2c)
    val () = prstr ")"
  }
| ~HSEapp
    (_fun, _arg) => {
    val () = prstr "HSEapp("
    val () = fprint_hisexp (out, _fun)
    val () = prstr "; "
    val () = fprint_hisexplst (out, _arg)
    val () = prstr ")"
  } // end of [HSEapp]
//
| ~HSEextype
    (name, hsess) => {
    val () = prstr "HSEextype("
    val () = $UT.fprintlst<hisexplst> (out, hsess, "; ", fprint_hisexplst)
    val () = prstr ")"
  } // end of [HSEextype]
//
| ~HSErefarg
    (refval, hse) => {
    val () = prstr "HSErefarg("
    val () = fprint_int (out, refval)
    val () = prstr "; "
    val () = fprint_hisexp (out, hse)
    val () = prstr ")"
  } // end of [HSErefarg]
//
| ~HSEtyabs (sym) => {
    val () = prstr "HSEtyabs("
    val () = $SYM.fprint_symbol (out, sym)
    val () = prstr ")"
  } // end of [HSEtyabs]
| ~HSEtybox () => {
    val () = prstr "HSEtybox()"
  } // end of [HSEtybox]
//
| ~HSEtyarr
    (hse, dim) => {
    val () = prstr "HSEtyarr("
    val () = fprint_hisexp (out, hse)
    val () = prstr "; "
    val () = fpprint_s2explst (out, dim)
    val () = prstr ")"
  } // end of [HSEtyarr]
//
| ~HSEtyrec
    (recknd, lhses) => {
    val () = prstr "HSEtyrec("
    val () = fprint_tyreckind (out, recknd)
    val () = prstr "; "
    val () = $UT.fprintlst<labhisexp> (out, lhses, ", ", fprint_labhisexp)
    val () = prstr ")"
  } // end of [HSEtyrec]
| ~HSEtyrecsin
    (hse) => {
    val () = prstr "HSEtyrecsin("
    val () = fprint_labhisexp (out, hse)
    val () = prstr ")"
  }
//
| ~HSEtysum (d2c, lhses) => {
    val () = prstr "HSEtysum("
    val () = fprint_d2con (out, d2c)
    val () = prstr "; "
    val () = $UT.fprintlst<labhisexp> (out, lhses, ", ", fprint_labhisexp)
    val () = prstr ")"
  } // end of [HSEtysum]
//
| ~HSEtyvar (s2v) => {
    val () = prstr "HSEtyvar("
    val () = fprint_s2var (out, s2v)
    val () = prstr ")"
  }
//
| ~HSEtyclo (flab) => {
    val () = prstr "HSEtyclo("
    val () = fprint_funlab (out, flab)
    val () = prstr ")"
  } // end of [HSEtyclo]
//
| ~HSEvararg (s2e) => {
    val () = prstr "HSEvararg("
    val () = fpprint_s2exp (out, s2e)
    val () = prstr ")"
  }
//
| ~HSEs2exp (s2e) => {
    val () = prstr "HSEs2exp("
    val () = fpprint_s2exp (out, s2e)
    val () = prstr ")"
  }
//
| ~HSEs2zexp (s2ze) => {
    val () = prstr "HSEs2zexp("
    val () = fprint_s2zexp (out, s2ze)
    val () = prstr ")"
  }
//
end // end of [fprint_hisexp]

(* ****** ****** *)

implement
print_hisexp (pmv) = fprint_hisexp (stdout_ref, pmv)
implement
prerr_hisexp (pmv) = fprint_hisexp (stderr_ref, pmv)

(* ****** ****** *)

implement
fprint_labhisexp
  (out, lx) = let
  val l = lx.labhisexp_lab()
  val x = lx.labhisexp_elt()
  val () =
    $LAB.fprint_label (out, l)
  val () = fprint_string (out, "=")
  val () = fprint_hisexp (out, x)
in
  // nothing
end // end of [fprint_labhisexp]

(* ****** ****** *)

implement
fprint_hisexplst
  (out, xs) = $UT.fprintlst<hisexp> (out, xs, ", ", fprint_hisexp)
// end of [fprint_hisexplst]

(* ****** ****** *)

(* end of [pats_histaexp_print.dats] *)
