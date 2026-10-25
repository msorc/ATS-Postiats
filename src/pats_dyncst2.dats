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
// Start Time: January, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_dyncst2.dats, see PORTING.md, "Level 2 translation (trans2)")
// A [d2cstref] is a cell of the global arena: the symbol (word 0) and the constant, null if not found yet (word 1).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)
//
staload SYM = "./pats_symbol.sats"
//
overload prerr with $SYM.prerr_symbol
//
(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_stacst2"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dyncst2.sats"

(* ****** ****** *)

staload "./pats_trans2_env.sats"

(* ****** ****** *)

assume d2cstref_type = ptr

(* ****** ****** *)
//
// the cell: the symbol (word 0) and the constant, null if not found yet (word 1)
//
fn d2cstref_get_sym
  (r: d2cstref): symbol = $UN.cast{symbol}($UN.ptr0_get<ptr>(r))
// end of [d2cstref_get_sym]

(* ****** ****** *)

fn d2cstref_get_cstnul
  (r: d2cstref): ptr = $UN.ptr0_get<ptr>(ptr0_add_guint<byte>(r, i2sz(8)))
fn d2cstref_set_cstnul
  (r: d2cstref, d2c: ptr): void = $UN.ptr0_set<ptr>(ptr0_add_guint<byte>(r, i2sz(8)), d2c)

(* ****** ****** *)

implement
d2cstref_make (name) = let
  val id = $SYM.symbol_make_string (name)
  val p = the_garena_alloc (i2sz(16))
  val () = $UN.ptr0_set<ptr> (p, $UN.cast{ptr}(id))
  val () = $UN.ptr0_set<ptr> (ptr0_add_guint<byte>(p, i2sz(8)), the_null_ptr)
in
  p
end  // end of [d2cstref_make]

(* ****** ****** *)

implement
d2cstref_get_cst (r) = let
//
fn auxerr
  (id: symbol): d2cst = let
  val () = prerr_interror ()
  val () = prerr ": d2cstref_get_cst"
  val () = prerrln! (": the pervasive dynamic constant [", id, "] is not available.")
in
  $ERR.abort_interr<d2cst>((*reachable*))
end (* end of [auxerr] *)
//
val d2c = d2cstref_get_cstnul (r)
val isnul = ptr_is_null (d2c)
//
in
//
if
isnul
then let
  val id = d2cstref_get_sym (r)
  val ans = the_d2expenv_pervasive_find (id)
in
//
case+ ans of
| ~Some_vt (s2i) => (
  case+ d2itm_view (s2i) of
  | ~D2ITMcst (d2c) => let
      val () = d2cstref_set_cstnul (r, $UN.cast{ptr}(d2c))
    in
      d2c
    end // end of [D2ITMcst]
  | v => (d2itm_view_free (v); auxerr (id))
  ) // end of [Some_vt]
| ~None_vt ((*void*)) => auxerr (id)
//
end // end of [then]
else $UN.cast{d2cst}(d2c)
//
end // end of [d2cstref_get_cst]

(* ****** ****** *)

implement
d2cstref_equ_cst (r, d2c) =
  eq_d2cst_d2cst (d2cstref_get_cst (r), d2c)
// end of [d2cstref_equ_cst]

(* ****** ****** *)

implement
the_sizeof_vt0ype_size = d2cstref_make ("sizeof")

(* ****** ****** *)

implement
d2cst_is_sizeof (d2c) =
  d2cstref_equ_cst (the_sizeof_vt0ype_size, d2c)
// end of [d2cst_is_sizeof]

(* ****** ****** *)

implement dyncst2_initialize () = ()

(* ****** ****** *)

(* end of [pats_dyncst2.dats] *)
