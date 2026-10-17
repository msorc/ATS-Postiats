(*
##
## ATS-extsolve-smt2:
## Outputing ATS-constraints
## in the format of smt-lib2
##
*)

(* ****** ****** *)
//
#ifndef
PATSOLVE_SMT2_SOLVING
#include "./myheader.hats"
#endif // end of [ifndef]
//
(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

//
// HX-2026-10:
// the constants defined in the preamble (by name);
// this used to be a (GC-managed) hashtable
//
extern
fun
s2cinterp_is_builtin(name: string): bool
//
implement
s2cinterp_is_builtin
  (name) =
(
case+ name of
| "unit_p" => true
| "neg_int" => true
| "abs_int" => true
| "sgn_int" => true
| "add_int_int" => true
| "sub_int_int" => true
| "mul_int_int" => true
| "div_int_int" => true
| "mod_int_int" => true
| "idiv_int_int" => true
| "ndiv_int_int" => true
| "eq_int_int" => true
| "lt_int_int" => true
| "gt_int_int" => true
| "lte_int_int" => true
| "gte_int_int" => true
| "neq_int_int" => true
| "max_int_int" => true
| "min_int_int" => true
| "null_addr" => true
| "add_addr_int" => true
| "sub_addr_int" => true
| "lt_addr_addr" => true
| "gt_addr_addr" => true
| "lte_addr_addr" => true
| "gte_addr_addr" => true
| "eq_addr_addr" => true
| "neq_addr_addr" => true
| "true_bool" => true
| "false_bool" => true
| "neg_bool" => true
| "add_bool_bool" => true
| "mul_bool_bool" => true
| "eq_bool_bool" => true
| "lt_bool_bool" => true
| "gt_bool_bool" => true
| "lte_bool_bool" => true
| "gte_bool_bool" => true
| "neq_bool_bool" => true
| "int2real" => true
| "neg_real" => true
| "abs_real" => true
| "sgn_real" => true
| "floor_real" => true
| "add_real_real" => true
| "sub_real_real" => true
| "mul_real_real" => true
| "div_real_real" => true
| "mod_real_real" => true
| "eq_real_real" => true
| "lt_real_real" => true
| "gt_real_real" => true
| "lte_real_real" => true
| "gte_real_real" => true
| "neq_real_real" => true
| "max_real_real" => true
| "min_real_real" => true
| _(*rest*) => false
) (* end of [s2cinterp_is_builtin] *)
//
(* ****** ****** *)
//
// HX:
// the payload caches the answer:
// 1: not builtin; 2: builtin
//
implement
s2cst_is_builtin
  (ar, s2c) = let
//
val ptr = s2cst_get_payload(ar, s2c)
//
in
//
if
ptr > 0
then ($UN.cast{intptr}(ptr) = $UN.cast{intptr}(2))
else let
//
val key =
  symbol_get_name(ar, s2cst_get_name(ar, s2c))
val ans =
  s2cinterp_is_builtin($UN.cast{string}(key))
//
val () =
s2cst_set_payload
  (ar, s2c, $UN.cast{ptr}(if ans then 2 else 1))
//
in
  ans
end // end of [else]
//
end // end of [s2cst_is_builtin]

(* ****** ****** *)

(* end of [patsolve_smt2_solving_interp.dats] *)
