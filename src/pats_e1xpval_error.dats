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
// HX-2026-10: no GC (ATS2 port of src/pats_e1xpval_error.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload LOC = "./pats_location.sats"
staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_e1xpval.sats"

(* ****** ****** *)

implement
fprint_valerr
  (out, x) = let
  macdef prstr (x) = fprint_string (out, ,(x))
in
//
case+ valerr_view (x) of
| ~VE_valize (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression cannot be evaluated to a value."
    val () = fprint_newline (out)
  }
| ~VE_valize_defined (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression is expected to be an indentifer."
    val () = fprint_newline (out)
  }
| ~VE_valize_undefined (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression is expected to be an indentifer."
    val () = fprint_newline (out)
  }
| ~VE_maxlevel (lev, e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the maximal evaluation depth ("
    val () = fprint_int (out, lev)
    val () = prstr ") has been reached."
    val () = fprint_newline (out)
  }
| ~VE_opr_arglst (e0, id) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the operator ["
    val () = $SYM.fprint_symbol (out, id)
    val () = prstr "] cannot handle its argument(s)."
    val () = fprint_newline (out)
  }
| ~VE_E1XPide_unbound (e0) => {
    val loc0 = e0.e1xp_loc()
    val id = (
      case+ e1xp_node_view (e0.e1xp_node()) of
      | ~E1XPide (id) => id
      | v => (e1xp_node_view_free (v); assertloc (false); $SYM.symbol_make_string ("?"))
    ) : symbol // HX: [val-E1XPide (id) = e0.e1xp_node]
    val () = $LOC.fprint_location (out, loc0)
    val () = prstr ": error(1): the identifier ["
    val () = $SYM.fprint_symbol (out, id)
    val () = prstr "] is unbound."
    val () = fprint_newline (out)
  }
| ~VE_E1XPundef (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression cannot be evaluated as it is un-defined."
    val () = fprint_newline (out)
  }
| ~VE_E1XPlist (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression cannot be evaluated as it is a tuple."
    val () = fprint_newline (out)
  }
| ~VE_E1XPapp_fun (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the applied expression is required to be an identifier."
    val () = fprint_newline (out)
  }
| ~VE_E1XPappid_fun (e0, id) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the applied identifier ["
    val () = $SYM.fprint_symbol (out, id)
    val () = prstr "] does not refer to a function."
    val () = fprint_newline (out)
  }
| ~VE_E1XPappid_opr (e0, id) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the applied identifier ["
    val () = $SYM.fprint_symbol (out, id)
    val () = prstr "] does not refer to a supported operator."
    val () = fprint_newline (out)
  }
| ~VE_E1XPappid_arity (e0, id) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): arity mismatch for this function application."
    val () = fprint_newline (out)
  }
| ~VE_E1XPfun (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression cannot be evaluated as it is a function."
    val () = fprint_newline (out)
  }
| ~VE_E1XPerr (e0) => {
    val () = $LOC.fprint_location (out, e0.e1xp_loc())
    val () = prstr ": error(1): the expression cannot be evaluated as it indicates an error."
    val () = fprint_newline (out)
  }
//
end // end of [fprint_valerr]

(* ****** ****** *)
//
// HX-2026-10: the global list of the errors is kept in a cell of the global arena
//
fun{a:t@ype}
gcell_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [gcell_make]

local

val the_valerrlst = gcell_make<glist(valerr)> (glist_nil())

in // in of [local]

implement
the_valerrlst_add
  (x) = () where {
  val xs = $UN.ptr0_get<glist(valerr)> (the_valerrlst)
  val () = $UN.ptr0_set<glist(valerr)> (the_valerrlst, glist_cons (x, xs))
} // end of [the_valerrlst_add]

fn
the_valerrlst_get
  (): glist(valerr) = xs where {
  val xs = $UN.ptr0_get<glist(valerr)> (the_valerrlst)
  val () = $UN.ptr0_set<glist(valerr)> (the_valerrlst, glist_nil())
} // end of [the_valerrlst_get]

implement
fprint_the_valerrlst
  (out) = let
  val xs = the_valerrlst_get ()
  fun loop (
    out: FILEref, xs: glist(valerr)
  ) : void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => (
        fprint_valerr (out, x); loop (out, xs)
      ) // end of [list_vt_cons]
    | ~GLnil () => ()
  // end of [loop]
in
  loop (out, xs)
end // end of [fprint_the_valerrlst]

end // end of [local]

(* ****** ****** *)

(* end of [pats_e1xpval_error.dats] *)
