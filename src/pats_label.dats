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
// Start Time: March, 2011
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_label.sats"

(* ****** ****** *)

#include "./pats_label_gen_dats.hats"

(* ****** ****** *)

implement
label_make_int (int) = label_LABint (int)
implement
label_make_sym (sym) = label_LABsym (sym)

(* ****** ****** *)

implement
label_make_string (str) = let
  val sym = $SYM.symbol_make_string (str) in label_LABsym (sym)
end // end of [label_make_string]

(* ****** ****** *)

implement
label_is_int (l) = label_is_LABint (l)
// end of [label_is_int]

implement
label_get_int (l) =
  case+ label_view (l) of ~LABint (x) => Some_vt (x) | ~LABsym _ => None_vt ()
// end of [label_get_int]

(* ****** ****** *)

implement
label_is_sym (l) = label_is_LABsym (l)
// end of [label_is_sym]

implement
label_get_sym (l) =
  case+ label_view (l) of ~LABsym (x) => Some_vt (x) | ~LABint _ => None_vt ()
// end of [label_get_sym]

(* ****** ****** *)

implement
label_dotize
  (l) = let
//
fun
dotname_make
  (name: string): string = let
  val dn = string0_append (".", name)
  val res = the_garena_strdup ($UN.strptr2string (dn))
  val ((*freed*)) = strptr_free (dn)
in
  res
end // end of [dotname_make]
//
val dotname = (
//
case+ label_view (l) of
| ~LABint (int) => let
    val str = tostrptr_int (int)
    val res = dotname_make ($UN.strptr2string (str))
    val ((*freed*)) = strptr_free (str)
  in
    res
  end // end of [LABint]
| ~LABsym (sym) => dotname_make ($SYM.symbol_get_name (sym))
  // end of [LABsym]
//
) : string // end of [val]
//
in
  $SYM.symbol_make_string (dotname)
end // end of [label_dotize]

(* ****** ****** *)

implement
eq_label_label
  (l1, l2) = compare_label_label (l1, l2) = 0
// end of [eq_label_label]
implement
neq_label_label
  (l1, l2) = compare_label_label (l1, l2) != 0
// end of [neq_label_label]

(* ****** ****** *)

implement
compare_label_label
  (l1, l2) = $effmask_all let
(*
val () =
println!
  ("compare_label_label: l1 = ", l1)
val () =
println!
  ("compare_label_label: l2 = ", l2)
*)
in
//
case+ label_view (l1) of
| ~LABint i1 => (
    case+ label_view (l2) of
    | ~LABint i2 =>
        (if i1 < i2 then ~1 else (if i1 > i2 then 1 else 0))
    | ~LABsym _ => ~1
  )
| ~LABsym s1 => (
    case+ label_view (l2) of
    | ~LABint _ => 1
    | ~LABsym s2 => $SYM.compare_symbol_symbol (s1, s2)
  )
//
end // end of [compare_label_label]

(* ****** ****** *)

implement
tostring_label
  (l) = let
in
//
case+ label_view (l) of
| ~LABint(int) => let
    val str = tostrptr_int(int)
    val res = the_garena_strdup ($UN.strptr2string (str))
    val ((*freed*)) = strptr_free (str)
  in
    res
  end // end of [LABint]
| ~LABsym(sym) => $SYM.symbol_get_name(sym)
//
end // end of [tostring_label]

(* ****** ****** *)
//
implement
print_label(x) = fprint_label(stdout_ref, x)
implement
prerr_label(x) = fprint_label(stderr_ref, x)
//
implement
fprint_label (out, x) =
(
  case+ label_view (x) of
  | ~LABint(int) => fprint_int(out, int)
  | ~LABsym(sym) => $SYM.fprint_symbol(out, sym)
) (* end of [fprint_label] *)
//
(* ****** ****** *)

(* end of [pats_label.dats] *)
