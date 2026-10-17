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
UN =
"prelude/SATS/unsafe.sats"
//
#staload "./patsolve_z3_solving_ctx.dats"
//
(* ****** ****** *)

assume form_vtype = Z3_ast
assume func_decl_vtype = Z3_func_decl

(* ****** ****** *)

implement
formula_decref
  (ast) = () where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val () = Z3_dec_ref(ctx, ast)
  prval ((*void*)) = fpf(ctx)
}

(* ****** ****** *)

implement
formula_incref
  (ast) = ast2 where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val ast2 = Z3_inc_ref(ctx, ast)
  prval ((*void*)) = fpf(ctx)
}

(* ****** ****** *)
//
implement
formula_null
  ((*void*)) = formula_int(0)
//
(* ****** ****** *)

implement
formula_true() = tt where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val tt = Z3_mk_true(ctx)
  prval ((*void*)) = fpf(ctx)
}

implement
formula_false() = ff where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val ff = Z3_mk_false(ctx)
  prval ((*void*)) = fpf(ctx)
}

(* ****** ****** *)

implement
formula_int(i) = i2 where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val ty = Z3_mk_int_sort(ctx)
  val i2 = Z3_mk_int(ctx, i, ty)
  val () = Z3_sort_dec_ref(ctx, ty)
  prval ((*void*)) = fpf(ctx)
}
  
(* ****** ****** *)

implement
formula_intrep(rep) = i2 where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val ty = Z3_mk_int_sort(ctx)
  val i2 = Z3_mk_numeral(ctx, rep, ty)
  val () = Z3_sort_dec_ref(ctx, ty)
  prval ((*void*)) = fpf(ctx)
}
  
(* ****** ****** *)

implement
formula_not
  (s2e1) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_not (ctx, s2e1)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_not] *)

(* ****** ****** *)

implement
formula_conj
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_and2 (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_conj] *)

(* ****** ****** *)

implement
formula_disj
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_or2 (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_disj] *)

(* ****** ****** *)

implement
formula_impl
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_implies (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_impl] *)

(* ****** ****** *)

implement
formula_conj_list
  (s2es) = let
//
fun
aux
(
  s2e0: form, s2es: formlst
) : form = (
//
case+ s2es of
| ~list_vt_nil
    ((*void*)) => s2e0
| ~list_vt_cons
    (s2e1, s2es2) =>
    aux(formula_conj(s2e0, s2e1), s2es2)
//
) (* end of [aux] *)
//
in
//
case+ s2es of
| ~list_vt_nil() => formula_true()
| ~list_vt_cons(s2e, s2es) => aux(s2e, s2es)
//
end // end of [formula_conj_list]

(* ****** ****** *)

implement
formula_conj_list1
  (s2es_arg, s2e_res) = let
in
//
case+ s2es_arg of
| ~list_vt_nil() => s2e_res
| list_vt_cons _ =>
    formula_conj(formula_conj_list(s2es_arg), s2e_res)
  // end of [list_vt_cons]
//
end // end of [formula_conj_list1]

implement
formula_impl_list1
  (s2es_arg, s2e_res) = let
in
//
case+ s2es_arg of
| ~list_vt_nil() => s2e_res
| list_vt_cons _ =>
    formula_impl(formula_conj_list(s2es_arg), s2e_res)
  // end of [list_vt_cons]
//
end // end of [formula_impl_list1]

(* ****** ****** *)

implement
formula_ineg
  (s2e1) = res where
{
//
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
  Z3_mk_unary_minus (ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e1)
  prval ((*void*)) = fpf(ctx)
//
} (* end of [formula_ineg] *)

(* ****** ****** *)

implement
formula_iadd
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_add2 (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_iadd] *)

(* ****** ****** *)

implement
formula_isub
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_sub2 (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_isub] *)

(* ****** ****** *)

implement
formula_imul
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_mul2 (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_imul] *)

(* ****** ****** *)
//
implement
formula_idiv
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_div (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_idiv] *)
//
implement
formula_ndiv
  (s2e1, s2e2) = formula_idiv(s2e1, s2e2)
//
(* ****** ****** *)

implement
formula_ilt
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_lt (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_ilt] *)

implement
formula_ilte
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_lte (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_ilte] *)

(* ****** ****** *)

implement
formula_igt
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_gt (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_igt] *)

implement
formula_igte
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_gte (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_igte] *)

(* ****** ****** *)

implement
formula_ieq
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_eq (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_ieq] *)

(* ****** ****** *)
//
implement
formula_ineq
  (s2e1, s2e2) =
  formula_not(formula_ieq(s2e1, s2e2))
//
(* ****** ****** *)

implement
formula_iabs
  (s2e) = let
  val _0_ = formula_int(0)
  val s2e_1 = formula_incref(s2e)
  val s2e_2 = formula_ineg(formula_incref(s2e))
in
  formula_cond(formula_igte(s2e, _0_), s2e_1, s2e_2)
end // end of [formula_iabs]

(* ****** ****** *)

implement
formula_isgn
  (s2e) = let
  val s2e_ = formula_incref(s2e)
  val s2e_gtz = formula_igt(s2e, formula_int(0))
  val s2e_ltz = formula_ilt(s2e_, formula_int(0))
in
//
formula_cond
(
  s2e_gtz, formula_int(1), formula_cond(s2e_ltz, formula_int(~1), formula_int(0))
)
//
end // end of [formula_isgn]

(* ****** ****** *)

implement
formula_imax
  (s2e1, s2e2) = let
  val s2e1_ = formula_incref(s2e1)
  val s2e2_ = formula_incref(s2e2)
in
  formula_cond(formula_igte(s2e1, s2e2), s2e1_, s2e2_)
end // end of [formula_imax]

implement
formula_imin
  (s2e1, s2e2) = let
  val s2e1_ = formula_incref(s2e1)
  val s2e2_ = formula_incref(s2e2)
in
  formula_cond(formula_ilte(s2e1, s2e2), s2e1_, s2e2_)
end // end of [formula_imin]

(* ****** ****** *)
//
implement
formula_bneg(s2e) = formula_not(s2e)
//
implement
formula_badd
  (s2e1, s2e2) = formula_disj(s2e1, s2e2)
//
implement
formula_bmul
  (s2e1, s2e2) = formula_conj(s2e1, s2e2)
//
(* ****** ****** *)
//
implement
formula_blt
  (s2e1, s2e2) =
  formula_conj(formula_not(s2e1), s2e2)
//
implement
formula_blte
  (s2e1, s2e2) = formula_impl(s2e1, s2e2)
//
implement
formula_bgt
  (s2e1, s2e2) =
  formula_conj(s2e1, formula_not(s2e2))
//
implement
formula_bgte
  (s2e1, s2e2) = formula_impl(s2e2, s2e1)
//
(* ****** ****** *)

implement
formula_beq
  (s2e1, s2e2) = res where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_eq (ctx, s2e1, s2e2)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  val () = Z3_dec_ref(ctx, s2e2)
  prval ((*void*)) = fpf(ctx)
} (* end of [formula_beq] *)

(* ****** ****** *)
//
implement
formula_bneq
  (s2e1, s2e2) =
  formula_not(formula_beq(s2e1, s2e2))
//
(* ****** ****** *)
//
implement
formula_real(p, q) = pq where
{
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val pq = Z3_mk_real(ctx, p, q)
  prval ((*void*)) = fpf(ctx)
}
//
implement
formula_int2real
  (s2e1) = res where
{
//
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_int2real(ctx, s2e1)
  // end of [val]
  val () = Z3_dec_ref(ctx, s2e1)
  prval ((*void*)) = fpf(ctx)
//
} // end of [formula_int2real]
//
implement
formula_neg_real
  (s2e1) = formula_ineg(s2e1)
//
implement
formula_abs_real
  (s2e) = let
  val _0_ = formula_real(0, 1)
  val s2e_1 = formula_incref(s2e)
  val s2e_2 = formula_neg_real(formula_incref(s2e))
in
  formula_cond(formula_gte_real_real(s2e, _0_), s2e_1, s2e_2)
end // end of [formula_iabs]
//
implement
formula_add_real_real
  (s2e1, s2e2) = formula_iadd(s2e1, s2e2)
implement
formula_sub_real_real
  (s2e1, s2e2) = formula_isub(s2e1, s2e2)
implement
formula_mul_real_real
  (s2e1, s2e2) = formula_imul(s2e1, s2e2)
implement
formula_div_real_real
  (s2e1, s2e2) = formula_idiv(s2e1, s2e2)
//
implement
formula_lt_real_real
  (s2e1, s2e2) = formula_ilt(s2e1, s2e2)
implement
formula_lte_real_real
  (s2e1, s2e2) = formula_ilte(s2e1, s2e2)
implement
formula_gt_real_real
  (s2e1, s2e2) = formula_igt(s2e1, s2e2)
implement
formula_gte_real_real
  (s2e1, s2e2) = formula_igte(s2e1, s2e2)
//
implement
formula_eq_real_real
  (s2e1, s2e2) = formula_ieq(s2e1, s2e2)
implement
formula_neq_real_real
  (s2e1, s2e2) = formula_ineq(s2e1, s2e2)
//
(* ****** ****** *)
(*
implement
formula_add_int_real
  (s2e1, s2e2) =
(
  formula_add_real_real(formula_int2real(s2e1), s2e2)
) (* end of [formula_add_int_real] *)
implement
formula_add_real_int
  (s2e1, s2e2) =
(
  formula_add_real_real(s2e1, formula_int2real(s2e2))
) (* end of [formula_add_real_int] *)
//
implement
formula_sub_int_real
  (s2e1, s2e2) =
(
  formula_sub_real_real(formula_int2real(s2e1), s2e2)
) (* end of [formula_sub_int_real] *)
implement
formula_sub_real_int
  (s2e1, s2e2) =
(
  formula_sub_real_real(s2e1, formula_int2real(s2e2))
) (* end of [formula_sub_real_int] *)
//
implement
formula_mul_int_real
  (s2e1, s2e2) =
(
  formula_mul_real_real(formula_int2real(s2e1), s2e2)
) (* end of [formula_mul_int_real] *)
implement
formula_div_real_int
  (s2e1, s2e2) =
(
  formula_div_real_real(s2e1, formula_int2real(s2e2))
) (* end of [formula_div_real_int] *)
*)
//
(*
implement
formula_lt_real_int
  (s2e1, s2e2) = formula_ilt(s2e1, formula_int2real(s2e2))
implement
formula_lte_real_int
  (s2e1, s2e2) = formula_ilte(s2e1, formula_int2real(s2e2))
implement
formula_gt_real_int
  (s2e1, s2e2) = formula_igt(s2e1, formula_int2real(s2e2))
implement
formula_gte_real_int
  (s2e1, s2e2) = formula_igte(s2e1, formula_int2real(s2e2))
implement
formula_eq_real_int
  (s2e1, s2e2) = formula_ieq(s2e1, formula_int2real(s2e2))
implement
formula_neq_real_int
  (s2e1, s2e2) = formula_ineq(s2e1, formula_int2real(s2e2))
*)
//
(* ****** ****** *)

implement
formula_cond
(
  s2e0, s2e1, s2e2
) = res where
{
//
  val (fpf | ctx) =
    the_Z3_context_vget()
  // end of [val]
  val res =
    Z3_mk_ite (ctx, s2e0, s2e1, s2e2)
  // end of [val]
//
  val ((*freed*)) = Z3_dec_ref(ctx, s2e0)
  val ((*freed*)) = Z3_dec_ref(ctx, s2e1)
  val ((*freed*)) = Z3_dec_ref(ctx, s2e2)
//
  prval ((*void*)) = fpf(ctx)
//
} (* end of [formula_cond] *)

(* ****** ****** *)

implement
formula_eqeq
  (s2e1, s2e2) = res where
{
//
(*
val () = println! ("formula_eqeq: enter")
*)
//
val (fpf | ctx) =
  the_Z3_context_vget()
// end of [val]
val res =
  Z3_mk_eq (ctx, s2e1, s2e2)
// end of [val]
val () = Z3_dec_ref(ctx, s2e1)
val () = Z3_dec_ref(ctx, s2e2)
prval ((*void*)) = fpf(ctx)
//
(*
val () = println! ("formula_eqeq: leave")
*)
//
} (* end of [formula_eqeq] *)

(* ****** ****** *)

implement
formula_sizeof_t0ype
  (s2e) = let
//
val r = sort_int()
val a = sort_mk_t0ype()
//
val fd =
  func_decl_1("sizeof_t0ype", a, r)
//
in
  formula_fdapp_1(fd, s2e)
end // end of [formula_sizeof]

(* ****** ****** *)

implement
func_decl_1
  (name, arg, res) = let
//
val (fpf | ctx) =
  the_Z3_context_vget()
// end of [val]
//
val
sym =
Z3_mk_string_symbol(ctx, name)
//
val arg = $UN.castvwtp0{Z3_sort}(arg)
val res = $UN.castvwtp0{Z3_sort}(res)
//
val
fd1 =
Z3_mk_func_decl_1(ctx, sym, arg, res)
//
val ((*void*)) = Z3_sort_dec_ref(ctx, res)
val ((*void*)) = Z3_sort_dec_ref(ctx, arg)
//
prval ((*void*)) = fpf(ctx)
//
in
  fd1
end // end of [func_decl_1]

(* ****** ****** *)

implement
formula_fdapp_1
  (fd, arg) = res where
{
//
val (fpf | ctx) =
  the_Z3_context_vget()
// end of [val]
//
val res = Z3_mk_app_1 (ctx, fd, arg)
//
val () =
  Z3_func_decl_dec_ref(ctx, fd)
//
val ((*void*)) = Z3_dec_ref(ctx, arg)
//
prval ((*void*)) = fpf(ctx)
//
} (* end of [formula_fdapp_1] *)

(* ****** ****** *)

fun
Z3_dec_ref_arrayptr
  {n:int}
(
  ctx: !Z3_context
, args: arrayptr(Z3_ast, n), n: int(n)
) : void = let
//
fun
loop
(
  ctx: !Z3_context, p: ptr, i: int
) : void = (
//
if
i < n
then let
//
val () =
Z3_dec_ref
  (ctx, $UN.ptr0_get<Z3_ast>(p))
//
in
  loop (ctx, ptr0_succ<Z3_ast>(p), i+1)
end // end of [then]
else () // end of [else]
//
) (* end of [loop] *)
//
val () = loop(ctx, ptrcast(args), 0)
//
in
  arrayptr_free($UN.castvwtp0{arrayptr(ptr, n)}(args))
end // end of [Z3_dec_ref_arrayptr]

(* ****** ****** *)

implement
func_decl_list
  (name, args, res) = let
//
val n = length(args)
//
prval
[n:int] EQINT() = eqint_make_gint(n)
//
val args =
  arrayptr_make_list_vt(n, args)
//
val res =
  $UN.castvwtp0{Z3_sort}(res)
val args =
  $UN.castvwtp0{arrayptr(Z3_sort, n)}(args)
//
val
( pfarr
| p_args) =
  arrayptr_takeout_viewptr(args)
//
val (fpf | ctx) =
  the_Z3_context_vget()
// end of [val]
val
sym = Z3_mk_string_symbol(ctx, name)
val
fdl = Z3_mk_func_decl(ctx, sym, n, !p_args, res)
//
prval () = arrayptr_addback(pfarr | args)
//
val res = $UN.castvwtp0{Z3_ast}(res)
val args = $UN.castvwtp0{arrayptr(Z3_ast, n)}(args)
//
val ((*void*)) = Z3_dec_ref(ctx, res)
val ((*void*)) = Z3_dec_ref_arrayptr(ctx, args, n)
//
prval ((*void*)) = fpf(ctx)
//
in
  fdl
end // end of [func_decl_list]

(* ****** ****** *)

implement
formula_fdapp_list
  (fd, args) = res where
{
//
val n = length(args)
val args =
  arrayptr_make_list_vt(n, args)
//
val
( pfarr
| p_args) =
  arrayptr_takeout_viewptr(args)
//
val (fpf | ctx) =
  the_Z3_context_vget()
// end of [val]
//
val res = Z3_mk_app (ctx, fd, n, !p_args)
//
val () =
  Z3_func_decl_dec_ref(ctx, fd)
//
prval () = arrayptr_addback(pfarr | args)
//
val ((*void*)) = Z3_dec_ref_arrayptr(ctx, args, n)
//
prval ((*void*)) = fpf(ctx)
//
} (* end of [formula_fdapp_list] *)

(* ****** ****** *)

implement
formula_error_s2cst
  (ar, s2c0) = res where
{
//
val () =
prerr("formula_error: s2c0 = ")
val () =
fprint_s2cst(ar, stderr_ref, s2c0)
val () = prerr_newline()
//
val () = assertloc(false)
val res = formula_error_s2cst(ar, s2c0)
//
} (* end of [formula_error_s2cst] *)

implement
formula_error_s2exp
  (ar, s2e0) = res where
{
//
val () =
prerr("formula_error: s2e0 = ")
val () =
fprint_s2exp(ar, stderr_ref, s2e0)
val () = prerr_newline()
//
val () = assertloc(false)
val res = formula_error_s2exp(ar, s2e0)
//
} (* end of [formula_error_s2exp] *)

(* ****** ****** *)
//
// HX: [name(stamp)]
//
extern
fun
Z3_mk_name_stamp_symbol
(
  ctx: !Z3_context, name: string, stamp: stamp
) : Z3_symbol // end-of-function
//
implement
Z3_mk_name_stamp_symbol
  (ctx, name, stamp) = sym0 where
{
//
val stamp =
  g0int2string(stamp_get_int(stamp))
//
var
strarr =
@[string](
  name, "(", $UN.strptr2string(stamp), ")"
) (* var *)
//
val name2 = stringarr_concat(strarr, i2sz(4))
//
val () = strptr_free(stamp)
//
val sym0 =
  Z3_mk_string_symbol(ctx, $UN.strptr2string(name2))
//
val ((*freed*)) = strptr_free(name2)
//
} (* end of [Z3_mk_name_stamp_symbol] *)
//
extern
fun
Z3_mk_s2cst_symbol{l:addr}
  (ar: !arena(l), ctx: !Z3_context, s2c: s2cst(l)): Z3_symbol
extern
fun
Z3_mk_s2var_symbol{l:addr}
  (ar: !arena(l), ctx: !Z3_context, s2v: s2var(l)): Z3_symbol
//
implement
Z3_mk_s2cst_symbol
  (ar, ctx, s2c0) =
Z3_mk_name_stamp_symbol
(
  ctx
, $UN.cast{string}(symbol_get_name(ar, s2cst_get_name(ar, s2c0)))
, s2cst_get_stamp(ar, s2c0)
) (* end of [Z3_mk_s2cst_symbol] *)
//
implement
Z3_mk_s2var_symbol
  (ar, ctx, s2v0) =
Z3_mk_name_stamp_symbol
(
  ctx
, $UN.cast{string}(symbol_get_name(ar, s2var_get_name(ar, s2v0)))
, s2var_get_stamp(ar, s2v0)
) (* end of [Z3_mk_s2var_symbol] *)
//
(* ****** ****** *)

implement
formula_make_s2cst
  (ar, env, s2c0) = let
//
val s2ci = s2cst_get_s2cinterp(ar, s2c0)
//
in
//
case+
s2cinterp_view(ar, s2ci)
of // case+
| ~S2CINTnone() => let
    val s2e = 
    formula_make_s2cst_fresh(ar, env, s2c0)
    val s2e_ = formula_incref(s2e)
    val s2ci =
    s2cinterp_S2CINTsome
      (ar, $UN.castvwtp0{ptr}(s2e))
    val ((*void*)) =
      s2cst_set_payload(ar, s2c0, $UN.cast{ptr}(s2ci))
    // end of [val]
  in
    s2e_
  end // end of [S2CINTnone]
| ~S2CINTsome(ptr) => let
    val s2e =
      $UN.castvwtp0{form}(ptr)
    // end of [val]
    val s2e_ = formula_incref(s2e)
    prval () = $UN.cast2void(s2e)
  in
    s2e_
  end // end of [S2CINTsome]
| ~S2CINTbuiltin_0(f) => f((*void*))
| v0(*rest-of-S2CINT*) =>
    (s2cinterp_view_free(v0); formula_error(ar, s2c0))
//
end // end of [formula_make_s2cst]

(* ****** ****** *)

implement
formula_make_s2cst_fresh
  (ar, env, s2c0) = ast0 where
{
//
val ty0 =
sort_make_s2rt
  (ar, s2cst_get_srt(ar, s2c0))
val ty0 =
  $UN.castvwtp0{Z3_sort}(ty0)
//
val
(fpf|ctx) =
  the_Z3_context_vget((*void*))
//
val name =
  Z3_mk_s2cst_symbol(ar, ctx, s2c0)
//
val ast0 = Z3_mk_const(ctx, name, ty0)
//
val ((*freed*)) = Z3_sort_dec_ref(ctx, ty0)
//
prval ((*returned*)) = fpf(ctx)
//
} (* end of [formula_make_s2cst_fresh] *)

(* ****** ****** *)

implement
formula_make_s2var
  (ar, env, s2v0) = let
//
val
ptr =
s2var_get_payload(ar, s2v0)
//
in
//
if
ptr > 0
then s2var_top_payload(ar, s2v0)
else formula_make_s2var_fresh(ar, env, s2v0)
//
end // end of [formula_make_s2var]

(* ****** ****** *)

implement
formula_make_s2var_fresh
  (ar, env, s2v0) = ast0 where
{
//
val ty0 =
sort_make_s2rt
  (ar, s2var_get_srt(ar, s2v0))
val ty0 =
  $UN.castvwtp0{Z3_sort}(ty0)
//
val
(fpf|ctx) =
  the_Z3_context_vget((*void*))
//
val name =
  Z3_mk_s2var_symbol(ar, ctx, s2v0)
//
val ast0 = Z3_mk_const(ctx, name, ty0)
//
val ((*freed*)) = Z3_sort_dec_ref(ctx, ty0)
//
prval ((*returned*)) = fpf(ctx)
//
} (* end of [formula_make_s2var_fresh] *)

(* ****** ****** *)

implement
formula_make_s2Var_fresh
  (ar, env, s2V0, s2t0) = ast where
{
//
val stamp =
  stamp_get_int(s2Var_get_stamp(ar, s2V0))
val stamp = g0int2string(stamp)
//
val
name2 =
string0_append
  ("s2Var$", $UN.strptr2string(stamp))
//
val () = strptr_free(stamp)
//
val ty = sort_make_s2rt(ar, s2t0)
val ty = $UN.castvwtp0{Z3_sort}(ty)
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val
sym =
Z3_mk_string_symbol
  (ctx, $UN.strptr2string(name2))
//
val ast = Z3_mk_const(ctx, sym, ty)
//
val ((*freed*)) = Z3_sort_dec_ref(ctx, ty)
//
prval ((*void*)) = fpf(ctx)
//
val () = strptr_free(name2)
//
} (* end of [formula_make_s2Var_fresh] *)

(* ****** ****** *)

implement
s2cfun_initize_s2cinterp
  (ar, s2c0) =
(
  s2cst_set_payload
    (ar, s2c0, $UN.cast{ptr}(s2cinterp_S2CINTbuiltin_list(ar)))
  // s2cst_set_payload
) (* end of [s2cfun_initize_s2cinterp] *)

(* ****** ****** *)
//
// HX-2026-10:
// applying an uninterpreted function
// (whose declaration is made from the sort of [s2c0])
//
extern
fun
formula_s2cfun_app{l:addr}
(
  ar: !arena(l), s2c0: s2cst(l), xs: formlst
) : form // end-of-function
//
implement
formula_s2cfun_app
  {l}(ar, s2c0, xs) = let
//
val name =
  symbol_get_name(ar, s2cst_get_name(ar, s2c0))
//
fun
auxlst
(
  ar: !arena(l), s2ts: s2rtlst(l)
) : sortlst =
(
if
alist_is_cons(s2ts)
then let
  val s2t = sort_make_s2rt(ar, alist_head(ar, s2ts))
in
  list_vt_cons(s2t, auxlst(ar, alist_tail(ar, s2ts)))
end // end of [then]
else list_vt_nil()
) (* end of [auxlst] *)
//
in
//
case+
s2rt_view(ar, s2cst_get_srt(ar, s2c0))
of // case+
| ~S2RTfun(s2ts_arg, s2t_res) => let
    val range = sort_make_s2rt(ar, s2t_res)
    val domain = auxlst(ar, s2ts_arg)
    val fd0 =
    func_decl_list
      ($UN.cast{string}(name), domain, range)
    // end of [val]
  in
    formula_fdapp_list(fd0, xs)
  end // end of [S2RTfun]
| v0(*non-S2RTfun*) => let
    val () = s2rt_view_free(v0)
    val () = formula_decref(formula_conj_list(xs))
  in
    formula_error(ar, s2c0)
  end // end of [non-S2RTfun]
//
end // end of [formula_s2cfun_app]

(* ****** ****** *)

local

fun
aux_S2Eapp
  {l:addr}
(
  ar: !arena(l)
, env: !smtenv(l)
, s2e0: s2exp(l)
, s2e_fun: s2exp(l), s2es_arg: s2explst(l)
) : form =
(
case+
s2exp_node_view
  (ar, s2exp_get_node(ar, s2e_fun))
of // case+
| ~S2Ecst(s2c) =>
    aux_S2Eapp_cst(ar, env, s2e0, s2c, s2es_arg)
| v0(*non-S2Ecst*) =>
    (s2exp_node_view_free(v0); formula_error(ar, s2e0))
) (* end of [aux_S2Eapp] *)

and
aux_S2Eapp_cst
  {l:addr}
(
  ar: !arena(l)
, env: !smtenv(l)
, s2e0: s2exp(l)
, s2c: s2cst(l), s2es_arg: s2explst(l)
) : form = let
//
val s2ci = s2cst_get_s2cinterp(ar, s2c)
//
in
//
case+
s2cinterp_view(ar, s2ci)
of // case+
| ~S2CINTbuiltin_0(f) => f()
| ~S2CINTbuiltin_1(f) => let
    val s2e1 = alist_head(ar, s2es_arg)
    val s2e1 = formula_make_s2exp(ar, env, s2e1)
  in
    f(s2e1)
  end // end of [S2CINTbuiltin_1]
| ~S2CINTbuiltin_2(f) => let
    val s2e1 = alist_head(ar, s2es_arg)
    val s2e2 = alist_head(ar, alist_tail(ar, s2es_arg))
    val s2e1 = formula_make_s2exp(ar, env, s2e1)
    val s2e2 = formula_make_s2exp(ar, env, s2e2)
  in
    f(s2e1, s2e2)
  end // end of [S2CINTbuiltin_2]
| ~S2CINTbuiltin_list() =>
    formula_s2cfun_app
      (ar, s2c, formulas_make_s2explst(ar, env, s2es_arg))
    // formula_s2cfun_app
| ~S2CINTsome _ => formula_error(ar, s2e0)
| ~S2CINTnone() => let
    val () =
      s2cfun_initize_s2cinterp(ar, s2c)
    // end of [val]
  in
    aux_S2Eapp_cst(ar, env, s2e0, s2c, s2es_arg)
  end // end of [S2CINTnone]
//
end // end of [aux_S2Eapp_cst]

(* ****** ****** *)

fun
aux_S2Emetdec
  {l:addr}
(
  ar: !arena(l)
, env: !smtenv(l)
, s2es10: s2explst(l)
, s2es20: s2explst(l)
) : form =
(
if
alist_is_nil(s2es10)
then formula_false()
else let
//
val s2es1 = alist_tail(ar, s2es10)
val s2es2 = alist_tail(ar, s2es20)
//
val s2e1 =
  formula_make_s2exp(ar, env, alist_head(ar, s2es10))
val s2e2 =
  formula_make_s2exp(ar, env, alist_head(ar, s2es20))
//
in
//
if
alist_is_nil(s2es1)
then formula_ilt(s2e1, s2e2)
else let
  val s2e1_ = formula_incref (s2e1)
  val s2e2_ = formula_incref (s2e2)
  val s2e_ilt = formula_ilt(s2e1, s2e2) 
  val s2e_ilte = formula_ilte(s2e1_, s2e2_)
in
  formula_disj
  (
    s2e_ilt
  , formula_conj(s2e_ilte, aux_S2Emetdec(ar, env, s2es1, s2es2))
  ) (* formula_disj *)
end // end of [else]
//
end // end of [else]
) (* end of [aux_S2Emetdec] *)

(* ****** ****** *)

vtypedef
Z3_symlst = List0_vt(Z3_symbol)
vtypedef
Z3_sortlst = List0_vt (Z3_sort)

(* ****** ****** *)

extern
fun
formula_quant
(
  knd: int
, syms: Z3_symlst
, s2ts: Z3_sortlst
, s2ps: formlst, s2e_body: form
) : form // end-of-function

implement
formula_quant
(
  knd, syms, s2ts, s2ps, s2e_body
) = let
//
val npat = 0
val ndec = list_vt_length (syms)
//
fun
auxtylst_free
(
  ctx: !Z3_context, s2ts: Z3_sortlst
) : void = (
//
case+ s2ts of
| ~list_vt_nil() => ()
| ~list_vt_cons(s2t, s2ts) =>
    (Z3_sort_dec_ref(ctx, s2t); auxtylst_free(ctx, s2ts))
  // end of [list_vt_cons]
//
) (* end of [auxtylst_free] *)
//
fun
auxtylst_init
(
  ctx: !Z3_context, s2ts: !Z3_sortlst, pz: ptr
) : void = (
//
case+ s2ts of
| list_vt_nil() => ()
| list_vt_cons(s2t, s2ts) => let
    val pz = ptr_pred<Z3_sort>(pz)
    val () =
      $UN.ptr0_set<Z3_sort>(pz, Z3_sort_inc_ref(ctx, s2t))
    // end of [val]
  in
    auxtylst_init(ctx, s2ts, pz)
  end // end of [list_vt_cons]
//
) (* end of [auxtylst_init] *)
//
val
( pf_s2ts2
, fpf_s2ts2 | p_s2ts2
) = array_ptr_alloc<Z3_symbol>(i2sz(ndec))
val
( pf_syms2
, fpf_syms2 | p_syms2
) = array_ptr_alloc<Z3_symbol>(i2sz(ndec))
//
val () =
array_initize_rlist_vt<Z3_symbol>(!p_syms2, ndec, syms)
//
//
val (fpf | ctx) = the_Z3_context_vget()
val ((*initized*)) =
  auxtylst_init(ctx, s2ts, ptr_add<Z3_sort>(p_s2ts2, ndec))
//
val
s2e_body = (
//
if
knd > 0
then formula_impl_list1(s2ps, s2e_body)
else formula_conj_list1(s2ps, s2e_body)
//
) : form // end of [val]
//
prval
[n:int]
EQINT() = eqint_make_gint(ndec)
//
val (
  pf2, fpf2 | p2
) = $UN.ptr0_vtake{array(Z3_sort,n)}(p_s2ts2)
//
val s2e0 =
Z3_mk_quantifier_nwp
  (ctx, knd > 0, ndec, !p2, !p_syms2, s2e_body)
//
prval () = fpf2(pf2)
//
val () = array_ptr_free(pf_s2ts2, fpf_s2ts2 | p_s2ts2)
val () = array_ptr_free(pf_syms2, fpf_syms2 | p_syms2)
//
val () =
  Z3_dec_ref(ctx, s2e_body)
//
val () = auxtylst_free(ctx, s2ts)
//
prval ((*void*)) = fpf(ctx)
//
in
  $UN.castvwtp0{form}(s2e0)
end // end of [formula_quant]

(* ****** ****** *)

fun
aux_quant
  {l:addr}
(
  knd: int
, ar: !arena(l)
, env: !smtenv(l)
, s2vs: s2varlst(l)
, s2ps: s2explst(l), s2e_body: s2exp(l)
) : form =
(
if
alist_is_nil(s2vs)
then let
  val s2ps =
    formulas_make_s2explst(ar, env, s2ps)
  val s2e_body =
    formula_make_s2exp(ar, env, s2e_body)
in
  if knd > 0
    then formula_impl_list1(s2ps, s2e_body)
    else formula_conj_list1(s2ps, s2e_body)
  // end of [if]
end // end of [then]
else aux_quant2(knd, ar, env, s2vs, s2ps, s2e_body)
) (* end of [aux_quant] *)

and
aux_quant2
  {l:addr}
(
  knd: int
, ar: !arena(l)
, env: !smtenv(l)
, s2vs: s2varlst(l)
, s2ps: s2explst(l), s2e_body: s2exp(l)
) : form = let
//
fun
auxlst1
(
  ar: !arena(l)
, ctx: !Z3_context, s2vs: s2varlst(l)
) : Z3_symlst =
(
if
alist_is_cons(s2vs)
then let
  val sym =
    Z3_mk_s2var_symbol(ar, ctx, alist_head(ar, s2vs))
  // end of [val]
in
  list_vt_cons(sym, auxlst1(ar, ctx, alist_tail(ar, s2vs)))
end // end of [then]
else list_vt_nil()
) (* end of [auxlst1] *)
//
fun
auxlst2
(
  ar: !arena(l)
, ctx: !Z3_context
, s2vs: s2varlst(l), index: intGte(0)
) : Z3_sortlst =
(
if
alist_is_cons(s2vs)
then let
  val s2v = alist_head(ar, s2vs)
  val s2t =
    sort_make_s2rt(ar, s2var_get_srt(ar, s2v))
  // end of [val]
  val s2t =
    $UN.castvwtp0{Z3_sort}(s2t)
  // end of [val]
  val x0 = Z3_mk_bound(ctx, index, s2t)
  val () =
    s2var_push_payload(ar, s2v, $UN.castvwtp0{form}(x0))
  // end of [val]
in
  list_vt_cons(s2t, auxlst2(ar, ctx, alist_tail(ar, s2vs), index+1))
end // end of [then]
else list_vt_nil()
) (* end of [auxlst2] *)
//
fun
auxlst3
(
  ar: !arena(l), s2vs: s2varlst(l)
) : void =
(
if
alist_is_cons(s2vs)
then
(
  formula_decref(s2var_pop_payload(ar, alist_head(ar, s2vs)));
  auxlst3(ar, alist_tail(ar, s2vs))
) (* end of [then] *)
) (* end of [auxlst3] *)
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val syms = auxlst1 (ar, ctx, s2vs)
val s2ts = auxlst2 (ar, ctx, s2vs, 0(*index*))
//
prval ((*void*)) = fpf(ctx)
//
val s2ps = formulas_make_s2explst (ar, env, s2ps)
val s2e_body = formula_make_s2exp (ar, env, s2e_body)
//
val ((*void*)) = auxlst3(ar, s2vs)
//
in
  formula_quant(knd, syms, s2ts, s2ps, s2e_body)
end // end of [aux_quant2]

in (* in-of-local *)

implement
formula_make_s2exp
  (ar, env, s2e0) = let
//
(*
val () =
println!
  ("formula_make_s2exp: s2e0 = ", s2e0)
*)
//
val s2t0 = s2exp_get_srt(ar, s2e0)
//
in
//
case+
s2exp_node_view
  (ar, s2exp_get_node(ar, s2e0))
of // case+
//
| ~S2Eint(i) => formula_int(i)
| ~S2Eintinf(rep) =>
    formula_intrep($UN.cast{string}(rep))
//
| ~S2Ecst(s2c) =>
    formula_make_s2cst(ar, env, s2c)
| ~S2Evar(s2v) =>
    formula_make_s2var(ar, env, s2v)
| ~S2EVar(s2V) =>
    formula_make_s2Var_fresh(ar, env, s2V, s2t0)
//
| ~S2Eeqeq(s2e1, s2e2) => let
    val s2e1 = formula_make_s2exp(ar, env, s2e1)
    val s2e2 = formula_make_s2exp(ar, env, s2e2)
  in
    formula_eqeq (s2e1, s2e2)
  end // end of [S2Eeqeq]
//
| ~S2Eapp(s2e_fun, s2es_arg) =>
    aux_S2Eapp(ar, env, s2e0, s2e_fun, s2es_arg)
//
| ~S2Emetdec(s2es_met, s2es_bnd) =>
    aux_S2Emetdec(ar, env, s2es_met, s2es_bnd)
//
| ~S2Etop(_, s2e) => formula_make_s2exp(ar, env, s2e)
| ~S2Einvar(s2e) => formula_make_s2exp(ar, env, s2e)
//
| ~S2Esizeof(s2e) =>
    formula_sizeof_t0ype(formula_make_s2exp(ar, env, s2e))
//
| ~S2Efun(npf, s2es, s2e_res) =>
  (
    if
    s2rt_is_S2RTprop(ar, s2t0)
    then let
      val s2es =
        formulas_make_s2explst(ar, env, s2es)
      val s2e_res =
        formula_make_s2exp(ar, env, s2e_res)
    in
      formula_impl_list1 (s2es, s2e_res)
    end // end of [then]
    else formula_error_s2exp(ar, s2e0)
  ) (* end of [S2Efun] *)
//
| ~S2Euni(s2vs, s2ps, s2e) =>
  (
    if
    s2rt_is_S2RTprop(ar, s2t0)
    then aux_quant(1(*uni*), ar, env, s2vs, s2ps, s2e)
    else formula_error_s2exp(ar, s2e0)
  ) (* end of [S2Euni] *)
| ~S2Eexi(s2vs, s2ps, s2e) =>
  (
    if
    s2rt_is_S2RTprop(ar, s2t0)
    then aux_quant(0(*exi*), ar, env, s2vs, s2ps, s2e)
    else formula_error_s2exp(ar, s2e0)
  ) (* end of [S2Eexi] *)
//
| ~S2Etyrec(knd, npf, ls2es) =>
  (
    if
    s2rt_is_S2RTprop(ar, s2t0)
    then
    formula_conj_list
      (formulas_make_labs2explst(ar, env, ls2es))
    else formula_error_s2exp(ar, s2e0)
  ) (* end of [S2Etyrec] *)
//
| v0 (*unrecognized*) =>
    (s2exp_node_view_free(v0); formula_error(ar, s2e0))
//
end // end of [formula_make_s2exp]

end // end of [local]

(* ****** ****** *)

implement
formulas_make_s2explst
  (ar, env, s2es) =
(
if
alist_is_cons(s2es)
then let
  val s2e =
    formula_make_s2exp(ar, env, alist_head(ar, s2es))
  val s2es =
    formulas_make_s2explst(ar, env, alist_tail(ar, s2es))
in
  list_vt_cons(s2e, s2es)
end // end of [then]
else list_vt_nil()
) (* end of [formulas_make_s2explst] *)

(* ****** ****** *)

implement
formulas_make_labs2explst
  (ar, env, ls2es) =
(
if
alist_is_cons(ls2es)
then let
  val ls2e = alist_head(ar, ls2es)
  val s2e =
    formula_make_s2exp(ar, env, labs2exp_get_exp(ar, ls2e))
  val s2es =
    formulas_make_labs2explst(ar, env, alist_tail(ar, ls2es))
in
  list_vt_cons(s2e, s2es)
end // end of [then]
else list_vt_nil()
) (* end of [formulas_make_labs2explst] *)

(* ****** ****** *)

(* end of [patsolve_z3_solving_form.dats] *)
