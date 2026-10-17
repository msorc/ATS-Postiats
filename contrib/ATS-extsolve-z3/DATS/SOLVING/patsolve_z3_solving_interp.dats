(*
##
## ATS-extsolve-z3:
## Solving ATS-constraints with Z3
##
*)

(* ****** ****** *)
//
#ifdef
PATSOLVE_Z3_SOLVING
#then
#else
#include "./myheader.hats"
#endif // ifdef(PATSOLVE_Z3_SOLVING)
//
(* ****** ****** *)
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#include "./patsolve_z3_solving_gen.hats"

(* ****** ****** *)

implement
fprint_s2cinterp
  (ar, out, x) = let
in
//
case+
s2cinterp_view(ar, x)
of // case+
| ~S2CINTnone() => fprint! (out, "S2CINTnone()")
| ~S2CINTsome _ => fprint! (out, "S2CINTsome(...)")
| ~S2CINTbuiltin_0 _ => fprint! (out, "S2CINTbuiltin_0(...)")
| ~S2CINTbuiltin_1 _ => fprint! (out, "S2CINTbuiltin_1(...)")
| ~S2CINTbuiltin_2 _ => fprint! (out, "S2CINTbuiltin_2(...)")
| ~S2CINTbuiltin_list() => fprint! (out, "S2CINTbuiltin_list(...)")
//
end // end of [fprint_s2cinterp]

(* ****** ****** *)
//
// HX-2026-10:
// the builtin interpretations (by name);
// this used to be a (GC-managed) hashtable
//
extern
fun
s2cinterp_builtin{l:addr}
  (ar: !arena(l), name: string): s2cinterp(l)
//
implement
s2cinterp_builtin
  (ar, name) =
(
case+ name of
| "unit_p" => s2cinterp_S2CINTbuiltin_0(ar, formula_true)
| "null_addr" => s2cinterp_S2CINTbuiltin_0(ar, formula_null)
| "true_bool" => s2cinterp_S2CINTbuiltin_0(ar, formula_true)
| "false_bool" => s2cinterp_S2CINTbuiltin_0(ar, formula_false)
| "neg_int" => s2cinterp_S2CINTbuiltin_1(ar, formula_ineg)
| "add_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_iadd)
| "sub_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_isub)
| "mul_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_imul)
| "div_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_idiv)
| "idiv_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_idiv)
| "ndiv_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_ndiv)
| "lt_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_ilt)
| "lte_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_ilte)
| "gt_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_igt)
| "gte_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_igte)
| "eq_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_ieq)
| "neq_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_ineq)
| "abs_int" => s2cinterp_S2CINTbuiltin_1(ar, formula_iabs)
| "sgn_int" => s2cinterp_S2CINTbuiltin_1(ar, formula_isgn)
| "max_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_imax)
| "min_int_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_imin)
| "neg_bool" => s2cinterp_S2CINTbuiltin_1(ar, formula_bneg)
| "add_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_badd)
| "mul_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_bmul)
| "lt_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_blt)
| "lte_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_blte)
| "gt_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_bgt)
| "gte_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_bgte)
| "eq_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_beq)
| "neq_bool_bool" => s2cinterp_S2CINTbuiltin_2(ar, formula_bneq)
| "add_addr_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_iadd)
| "sub_addr_int" => s2cinterp_S2CINTbuiltin_2(ar, formula_isub)
| "sub_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_isub)
| "lt_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_ilt)
| "lte_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_ilte)
| "gt_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_igt)
| "gte_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_igte)
| "eq_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_ieq)
| "neq_addr_addr" => s2cinterp_S2CINTbuiltin_2(ar, formula_ineq)
| "int2real" => s2cinterp_S2CINTbuiltin_1(ar, formula_int2real)
| "neg_real" => s2cinterp_S2CINTbuiltin_1(ar, formula_neg_real)
| "abs_real" => s2cinterp_S2CINTbuiltin_1(ar, formula_abs_real)
| "add_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_add_real_real)
| "sub_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_sub_real_real)
| "mul_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_mul_real_real)
| "div_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_div_real_real)
| "lt_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_lt_real_real)
| "lte_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_lte_real_real)
| "gt_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_gt_real_real)
| "gte_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_gte_real_real)
| "eq_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_eq_real_real)
| "neq_real_real" => s2cinterp_S2CINTbuiltin_2(ar, formula_neq_real_real)
| _(*rest*) => s2cinterp_S2CINTnone(ar)
) (* end of [s2cinterp_builtin] *)
//
(* ****** ****** *)

implement
s2cst_get_s2cinterp
  {l}(ar, s2c) = let
//
val ptr = s2cst_get_payload(ar, s2c)
//
in
//
if
ptr > 0
then $UN.cast{s2cinterp(l)}(ptr)
else let
//
val key =
  symbol_get_name(ar, s2cst_get_name(ar, s2c))
val itm =
  s2cinterp_builtin(ar, $UN.cast{string}(key))
//
val () = s2cst_set_payload(ar, s2c, $UN.cast{ptr}(itm))
//
in
  itm
end // end of [else]
//
end // end of [s2cst_get_s2cinterp]

(* ****** ****** *)

(* end of [patsolve_z3_solving_interp.dats] *)
