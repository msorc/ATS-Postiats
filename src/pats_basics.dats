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

staload "./pats_basics.sats"

(* ****** ****** *)

#include "./pats_basics.hats"

(* ****** ****** *)

implement VIEWT0YPE_knd_get () = VIEWT0YPE_int

(* ****** ****** *)

implement
test_fltkind(knd) = let
  val knd = g0int2uint_int_uint(knd)
  val fltflag = g0int2uint_int_uint(FLTFLAG)
in
  g0uint_gt_uint (g0uint_land_uint (knd, fltflag), 0u)
end // end of [test_fltkind]

implement
test_boxkind(knd) =
  if test_fltkind (knd) then false else true
// end of [test_boxkind]

implement
test_linkind(knd) = let
  val knd = g0int2uint_int_uint(knd)
  val linflag = g0int2uint_int_uint(LINFLAG)
in
  g0uint_gt_uint (g0uint_land_uint (knd, linflag), 0u)
end // end of [test_linkind]

implement
test_prfkind(knd) = let
  val knd = g0int2uint_int_uint(knd)
  val prfflag = g0int2uint_int_uint(PRFFLAG)
in
  g0uint_gt_uint (g0uint_land_uint (knd, prfflag), 0u)
end // end of [test_prfkind]

implement
test_prgmkind(knd) = let
  val knd = g0int2uint_int_uint(knd)
  val prfflag = g0int2uint_int_uint(PRFFLAG)
in
  g0uint_eq_uint (g0uint_land_uint (knd, prfflag), 0u)
end // end of [test_prgmkind]

implement
test_polkind (knd) = let
  val knd = g0int2uint_int_uint(knd)
  val polflag = g0int2uint_int_uint(POLFLAG)
  val knd = g0uint_land_uint (knd, polflag)
in
//
if
g0uint_eq_uint (knd, 0u)
then 0 else (if g0uint_lt_uint (knd, polflag) then 1 else ~1)
// end of [if]
//
end // end of [test_polkind]

(* ****** ****** *)

implement
impkind_linearize(knd) = let
  val linflag = g0int2uint_int_uint(LINFLAG)
  val knd = g0uint_lor_uint (g0int2uint_int_uint(knd), linflag)
in
  g0uint2int_uint_int(knd)
end // end of [impkind_linearize]

implement
impkind_neutralize(knd) = let
  val polflag = g0int2uint_int_uint(POLFLAG)
  val knd = g0uint_land_uint (g0int2uint_int_uint(knd), g0uint_lnot_uint(polflag))
in
  g0uint2int_uint_int(knd)
end // end of [impkind_neutralize]

(* ****** ****** *)

implement
lte_impkind_impkind(k1, k2) = let
//
  val
  polflag =
  g0int2uint_int_uint(POLFLAG)
  val
  polmask = g0uint_lnot_uint(polflag)
//
  val k1 = g0uint_land_uint (g0int2uint_int_uint(k1), polmask)
  val k2 = g0uint_land_uint (g0int2uint_int_uint(k2), polmask)
//
in
  g0uint_eq_uint (g0uint_land_uint (k1, g0uint_lnot_uint(k2)), 0u)
end // end of [lte_impkind_impkind]

(* ****** ****** *)

implement
fprint_caskind
  (out, knd) = (
  case+ knd of
  | CK_case () => fprint_string (out, "case")
  | CK_case_pos () => fprint_string (out, "case+")
  | CK_case_neg () => fprint_string (out, "case-")
) // end of [fprint_caskind]

(* ****** ****** *)

implement
funkind_is_proof
  (fk) = let
in
//
case+ fk of
| FK_prfn () => true
| FK_prfun () => true
| FK_praxi () => true
| _ (*non-proof*) => false
//
end // end of [funkind_is_proof]

implement
funkind_is_recursive
  (fk) = let
in
//
case+ fk of
//
| FK_fun () => true
| FK_fnx () => true
//
| FK_prfun () => true
| FK_praxi () => true // HX: praxi=prfun
//
| FK_castfn () => true
//
| _ (*non-recursive*) => false
//
end // end of [funkind_is_recursive]

(* ****** ****** *)

implement
funkind_is_mutailrec
  (fk) = (
//
case+ fk of FK_fnx () => true | _ => false
//
) (* end of [funkind_is_mutailrec] *)

(* ****** ****** *)

implement
fprint_funkind
  (out, fk) = let
in
//
case+ fk of
//
  | FK_fn () => fprint_string (out, "fn")
  | FK_fnx () => fprint_string (out, "fnx")
  | FK_fun () => fprint_string (out, "fun")
//
  | FK_prfn () => fprint_string (out, "prfn")
  | FK_prfun () => fprint_string (out, "prfun")
//
  | FK_praxi () => fprint_string (out, "praxi")
//
  | FK_castfn () => fprint_string (out, "castfn")
//
end // end of [fprint_funkind]

(* ****** ****** *)

(*
implement
valkind_is_model (vk) =
  case+ vk of VK_mcval () => true | _ => false
// end of [valkind_is_model]
*)

implement
valkind_is_proof (vk) =
  case+ vk of VK_prval () => true | _ => false
// end of [valkind_is_proof]

(* ****** ****** *)

implement
fprint_valkind
  (out, vk) = let
in
//
case+ vk of
| VK_val () => fprint_string (out, "val")
| VK_val_pos () => fprint_string (out, "val+")
| VK_val_neg () => fprint_string (out, "val-")
| VK_prval () => fprint_string (out, "prval")
//
end (* end of [fprint_valkind] *)

(* ****** ****** *)

implement
valkind2caskind
  (vk) = let
in
//
case+ vk of
| VK_val () => CK_case ()
| VK_prval () => CK_case_pos () // = val+
| VK_val_pos () => CK_case_pos () // val+
| VK_val_neg () => CK_case_neg () // val-
//
end // end of [valkind2caskind]

(* ****** ****** *)

implement
dcstkind_is_fun (x) =
  case+ x of DCKfun () => true | _ => false
// end of [dcstkind_is_fun]

implement
dcstkind_is_val (x) =
  case+ x of DCKval () => true | _ => false
// end of [dcstkind_is_val]

implement
dcstkind_is_prfun (x) =
  case+ x of DCKprfun () => true | _ => false
// end of [dcstkind_is_prfun]

implement
dcstkind_is_prval (x) =
  case+ x of DCKprval () => true | _ => false
// end of [dcstkind_is_prval]

(* ****** ****** *)

implement
dcstkind_is_proof
  (dk) = let
in
//
case+ dk of
| DCKpraxi () => true
| DCKprfun () => true
| DCKprval () => true
| _ (*non-proof*) => false
//
end // end of [dcstkind_is_proof]

implement
dcstkind_is_castfn (dk) =
  case+ dk of DCKcastfn () => true | _ => false
// end of [dcstkind_is_castfn]

(* ****** ****** *)

implement
fprint_dcstkind
  (out, dk) = let
in
//
case+ dk of
| DCKfun () => fprint_string (out, "DCKfun()")
| DCKval () => fprint_string (out, "DCKval()")
| DCKpraxi () => fprint_string (out, "DCKpraxi()")
| DCKprfun () => fprint_string (out, "DCKprfun()")
| DCKprval () => fprint_string (out, "DCKprval()")
| DCKcastfn () => fprint_string (out, "DCKcastfn()")
//
end // end of [fprint_dcstkind]

(* ****** ****** *)

fun funclo_tag (fc: funclo): int =
  case+ fc of
  | FUNCLOfun () => 0
  | FUNCLOcloptr () => 1
  | FUNCLOclo0 () => 2
  | FUNCLOcloref () => 3
// end of [funclo_tag]

implement
FUNCLOclo (knd) =
  if knd > 0 then FUNCLOcloptr () else (if knd < 0 then FUNCLOcloref () else FUNCLOclo0 ())
// end of [FUNCLOclo]

implement
funclo_get_clokind (fc) =
  case+ fc of
  | FUNCLOfun () => 0
  | FUNCLOcloptr () => 1
  | FUNCLOclo0 () => 0
  | FUNCLOcloref () => ~1
// end of [funclo_get_clokind]

(* ****** ****** *)

implement
funclo_is_clo (fc) =
  case+ fc of FUNCLOfun () => false | _ => true
// end of [funclo_is_clo]

(* ****** ****** *)

implement
funclo_is_ptr (fc) =
  case+ fc of FUNCLOclo0 () => false | _ => true
// end of [funclo_is_ptr]

implement
funclo_is_cloptr (fc) =
  case+ fc of
  | FUNCLOcloptr () => true | FUNCLOcloref () => true | _ => false
// end of [funclo_is_cloptr]

(* ****** ****** *)

implement
eq_funclo_funclo
  (fc1, fc2) =
  (funclo_tag (fc1) = funclo_tag (fc2))
// end of [eq_funclo_funclo]

implement
neq_funclo_funclo (fc1, fc2) = ~eq_funclo_funclo (fc1, fc2)

(* ****** ****** *)

implement
fprint_funclo
  (out, fc) =
(
  case+ fc of
  | FUNCLOfun () => fprint_string (out, "FUN")
  | _ (*closure*) => let
      val () = fprint_string (out, "CLO(")
      val () = fprint_int (out, funclo_get_clokind (fc))
    in
      fprint_string (out, ")")
    end // end of [closure]
) (* end of [fprint_funclo] *)

implement print_funclo (fc) = fprint_funclo (stdout_ref, fc)
implement prerr_funclo (fc) = fprint_funclo (stderr_ref, fc)

(* ****** ****** *)

local
//
var the_flag: int = 0 // 1
//
val the_flag_ref =
  ref_make_viewptr{int}(view@ the_flag | addr@ the_flag)
//
in (* in-of-local *)

implement
debug_flag_get () = ref_get_elt (the_flag_ref)

implement
debug_flag_set (x) = ref_set_elt (the_flag_ref, x)

end // end of [local]

(* ****** ****** *)

%{$

atstype_void
patsopt_vfprintf_ifdebug (
  atstype_ptr out
, atstype_ptr fmt
, va_list ap // variadic arguments
) {
//
  if (patsopt_debug_flag_get () > 0) {
    (void)vfprintf((FILE*)out, (char*)fmt, ap) ;
  } // end of [if]
//
  return ;
} // end of [patsopt_debug_printf]

atstype_void
patsopt_prerrf_ifdebug (
  atstype_ptr fmt, ...
) {
  va_list ap ;
  va_start(ap, fmt) ;
  patsopt_vfprintf_ifdebug(stderr, (char*)fmt, ap) ;
  va_end(ap) ;
  return ;
} // end of [patsopt_debug_prerrf]

%} // end of [%{$]

(* ****** ****** *)

(* end of [pats_basics.dats] *)
