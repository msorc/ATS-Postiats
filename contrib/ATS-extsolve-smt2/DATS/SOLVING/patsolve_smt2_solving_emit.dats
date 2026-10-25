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
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
//
(* ****** ****** *)

fun
emit_bool
(
  out: FILEref, b: bool
) : void = (
//
fprint_string
(
  out, if b then "true" else "false"
)
//
) (* end of [emit_bool] *)

(* ****** ****** *)

implement
emit_form
  (ar, out, fml) = let
in
//
case+
form_view(ar, fml)
of // case+
//
| ~FORMnot(fml) =>
  {
    val () =
      fprint(out, "(not ")
    // end of [val]
    val () = emit_form(ar, out, fml)
    val () = fprint! (out, ")")
  }
//
| ~FORMs2exp(s2e) =>
  {
    val () = emit_s2exp(ar, out, s2e)
  }
//
| v0 (*rest*) =>
  (
    form_view_free(v0); fprint_form(ar, out, fml)
  )
//
end // end of [emit_form]

(* ****** ****** *)

implement
emit_s2rt
  (ar, out, s2t0) = let
//
macdef
emit(x) = fprint(out, ,(x))
//
in
//
case+
s2rt_view(ar, s2t0)
of // case+
//
| ~S2RTint() => emit("s2rt_int")
| ~S2RTaddr() => emit("s2rt_addr")
| ~S2RTbool() => emit("s2rt_bool")
//
| ~S2RTreal() => emit("s2rt_real")
| ~S2RTfloat() => emit("s2rt_float")
| ~S2RTstring() => emit("s2rt_string")
//
| ~S2RTcls() => emit("s2rt_cls")
| ~S2RTeff() => emit("s2rt_eff")
| ~S2RTtup() => emit("s2rt_tup")
//
| ~S2RTtype() => emit("s2rt_type")
| ~S2RTvtype() => emit("s2rt_vtype")
| ~S2RTt0ype() => emit("s2rt_t0ype")
| ~S2RTvt0ype() => emit("s2rt_vt0ype")
//
| ~S2RTprop() => emit("s2rt_prop")
| ~S2RTview() => emit("s2rt_view")
//
| ~S2RTtkind() => emit("s2rt_tkind")
//
| ~S2RTfun
  (
    s2ts_arg, s2t_res
  ) =>
  {
    val () = emit("(")
    val () = emit("s2rt_fun")
    val () = emit(" ")
    val () =
      emit_s2rtlst(ar, out, s2ts_arg)
    // end of [val]
    val () = emit(" ")
    val () = emit_s2rt(ar, out, s2t_res)
    val () = emit(")")
  }
//
| ~S2RTnamed
    (name) => fprint_symbol(ar, out, name)
  // S2RTnamed
//
| ~S2RTerror() => emit("s2rt_error")
//
end // end of [emit_s2rt]

(* ****** ****** *)

implement
emit_s2rtlst
  {l}(ar, out, xs) = () where
{
//
fun
loop
(
  ar: !arena(l), xs: s2rtlst(l)
) : void =
(
if
alist_is_cons(xs)
then
(
  fprint(out, " ");
  emit_s2rt(ar, out, alist_head(ar, xs));
  loop(ar, alist_tail(ar, xs))
) (* end of [then] *)
) (* end of [loop] *)
//
val () = fprint(out, "(")
val () =
if
alist_is_cons(xs)
then
(
  emit_s2rt(ar, out, alist_head(ar, xs));
  loop(ar, alist_tail(ar, xs))
) (* end of [then] *)
val () = fprint(out, ")")
//
} (* end of [emit_s2rtlst] *)

(* ****** ****** *)
//
// HX: [name] or [extdef] or [name!stamp]
//
extern
fun
emit_s2cst_name{l:addr}
  (ar: !arena(l), out: FILEref, s2c0: s2cst(l)): void
//
implement
emit_s2cst_name
  (ar, out, s2c0) =
(
case+
s2cst_get_extdef(ar, s2c0)
of // case+
| ~Some_vt(name) =>
    astring_fprint(ar, out, name)
| ~None_vt((*void*)) =>
  (
    fprint_symbol(ar, out, s2cst_get_name(ar, s2c0));
    fprint(out, "!"); fprint_stamp(out, s2cst_get_stamp(ar, s2c0))
  )
) (* end of [emit_s2cst_name] *)
//
implement
emit_s2cst
  (ar, out, s2c0) =
(
if
s2cst_is_builtin(ar, s2c0)
then
fprint_symbol(ar, out, s2cst_get_name(ar, s2c0))
else emit_s2cst_name(ar, out, s2c0)
) (* end of [emit_s2cst] *)

(* ****** ****** *)

implement
emit_s2var
  (ar, out, s2v0) =
(
  fprint_symbol(ar, out, s2var_get_name(ar, s2v0));
  fprint(out, "!"); fprint_stamp(out, s2var_get_stamp(ar, s2v0))
) (* end of [emit_s2var] *)

(* ****** ****** *)

implement
emit_s2exp
  {l}(ar, out, s2e0) = let
//
fun
aux_lt
(
  ar: !arena(l)
, s2e1: s2exp(l), s2e2: s2exp(l)
) : void =
{
   val () =
     fprint(out, "(< ")
   // end of [val]
   val () = emit_s2exp(ar, out, s2e1)
   val () = fprint(out, " ")
   val () = emit_s2exp(ar, out, s2e2)
   val () = fprint(out, ")")
}
//
fun
aux_lte
(
  ar: !arena(l)
, s2e1: s2exp(l), s2e2: s2exp(l)
) : void =
{
   val () =
     fprint(out, "(<= ")
   // end of [val]
   val () = emit_s2exp(ar, out, s2e1)
   val () = fprint(out, " ")
   val () = emit_s2exp(ar, out, s2e2)
   val () = fprint(out, ")")
}
//
fun
aux_metdec
(
  ar: !arena(l)
, s2es1: s2explst(l), s2es2: s2explst(l)
) : void =
(
if
alist_is_nil(s2es1)
then emit_bool(out, false)
else let
  val s2e1 = alist_head(ar, s2es1)
  val s2e2 = alist_head(ar, s2es2)
  val s2es1 = alist_tail(ar, s2es1)
  val s2es2 = alist_tail(ar, s2es2)
in
  if
  alist_is_nil(s2es1)
  then aux_lt(ar, s2e1, s2e2)
  else {
    val () = fprint(out, "(or ")
    val () = aux_lt(ar, s2e1, s2e2)
    val () = fprint(out, " ")
    val () = fprint(out, "(and ")
    val () = aux_lte(ar, s2e1, s2e2)
    val () = fprint(out, " ")
    val () = aux_metdec(ar, s2es1, s2es2)
    val () = fprint(out, ")")
    val () = fprint(out, ")")
  } (* end of [else] *)
end // end of [else]
) (* end of [aux_metdec] *)
//
fun
auxsvs
(
  ar: !arena(l), s2vs: s2varlst(l)
) : void = let
//
fun
loop
(
  ar: !arena(l), s2vs: s2varlst(l)
) : void =
(
if
alist_is_cons(s2vs)
then let
  val s2v = alist_head(ar, s2vs)
  val () = fprint(out, "(")
  val () = emit_s2var(ar, out, s2v)
  val () = fprint(out, " ")
  val () = emit_s2rt(ar, out, s2var_get_srt(ar, s2v))
  val () = fprint(out, ")")
in
  loop(ar, alist_tail(ar, s2vs))
end // end of [then]
) (* end of [loop] *)
//
in
  fprint(out, "("); loop(ar, s2vs); fprint(out, ")")
end (* end of [auxsvs] *)
//
fun
auxsps
(
  ar: !arena(l), s2ps: s2explst(l)
) : void = let
//
fun
loop
(
  ar: !arena(l), s2ps: s2explst(l)
) : void =
(
if
alist_is_cons(s2ps)
then
(
  fprint(out, " ");
  emit_s2exp(ar, out, alist_head(ar, s2ps));
  loop(ar, alist_tail(ar, s2ps))
) (* end of [then] *)
) (* end of [loop] *)
//
in
//
if
alist_is_nil(s2ps)
then emit_bool(out, true)
else let
  val s2p = alist_head(ar, s2ps)
  val s2ps = alist_tail(ar, s2ps)
in
  if
  alist_is_nil(s2ps)
  then emit_s2exp(ar, out, s2p)
  else {
    val () =
      fprint(out, "(and ")
    // end of [val]
    val () = emit_s2exp(ar, out, s2p)
    val () = fprint(out, " ")
    val () = loop(ar, s2ps)
    val () = fprint(out, ")")
  } (* end of [else] *)
end // end of [else]
//
end (* end of [auxsps] *)
//
fun
auxquant
(
  ar: !arena(l)
, knd: int
, s2vs: s2varlst(l)
, s2ps: s2explst(l), s2e_body: s2exp(l)
) : void = let
//
val issvs = alist_is_cons(s2vs)
val issps = alist_is_cons(s2ps)
//
val () =
if issvs then
(
  if knd > 0
    then fprint(out, "(forall ")
    else fprint(out, "(exists ")
  // end of [if]
) (* end of [if] *)
val () = if issvs then auxsvs(ar, s2vs)
val () = if issvs then fprint(out, " ")
//
val () =
if issps then
(
  if knd > 0
    then fprint(out, "(=> ")
    else fprint(out, "(and ")
  // end of [if]
) (* end of [if] *)
val () = if issps then auxsps(ar, s2ps)
val () = if issps then fprint(out, " ")
//
val () = emit_s2exp(ar, out, s2e_body)
//
val () = if issps then fprint(out, ")")
val () = if issvs then fprint(out, ")")
//
in
  // nothing
end // end of [auxquant]
//
in
//
case+
s2exp_node_view
  (ar, s2exp_get_node(ar, s2e0))
of // case+
//
| ~S2Eint(int) => fprint(out, int)
| ~S2Eintinf(rep) => astring_fprint(ar, out, rep)
//
| ~S2Ecst(s2c) => emit_s2cst(ar, out, s2c)
| ~S2Evar(s2v) => emit_s2var(ar, out, s2v)
//
| ~S2Eeqeq
    (s2e1, s2e2) =>
  {
    val () =
    fprint
      (out, "(s2exp_eqeq (=")
    // end of [val]
    val () = fprint(out, " ")
    val () = emit_s2exp(ar, out, s2e1)
    val () = fprint(out, " ")
    val () = emit_s2exp(ar, out, s2e2)
    val () = fprint(out, "))")
  }
//
| ~S2Esizeof(s2e) =>
  {
    val () =
    fprint(out, "(s2exp_sizeof ")
    val () = emit_s2exp(ar, out, s2e)
    val () = fprintln! (out, ")")
  }
//
| ~S2Eapp
  (
    s2e_fun, s2es_arg
  ) =>
  {
    fun
    loop
    (
      ar: !arena(l), s2es: s2explst(l)
    ) : void =
    (
      if
      alist_is_cons(s2es)
      then
      (
        fprint(out, " ");
        emit_s2exp(ar, out, alist_head(ar, s2es));
        loop(ar, alist_tail(ar, s2es))
      ) (* end of [then] *)
    ) (* end of [loop] *)
    val () = fprint(out, "(")
    val () = emit_s2exp(ar, out, s2e_fun)
    val () = loop(ar, s2es_arg)
    val () = fprint(out, ")")
  } (* end of [S2Eapp] *)
//
| ~S2Emetdec
    (s2es1, s2es2) =>
  {
    val () = fprint(out, "(")
    val () =
      fprint(out, "s2exp_metdec")
    // end of [val]
    val () = fprint(out, " ")
    val () = aux_metdec(ar, s2es1, s2es2)
    val () = fprint(out, ")")
  }
//
| ~S2Etop(knd, s2e) => emit_s2exp(ar, out, s2e)
//
| ~S2Euni(s2vs, s2ps, s2e_body) =>
    auxquant(ar, 1(*uni*), s2vs, s2ps, s2e_body)
| ~S2Eexi(s2vs, s2ps, s2e_body) =>
    auxquant(ar, 0(*exi*), s2vs, s2ps, s2e_body)
//
| ~S2Efun
  (
    npf, s2es_arg, s2e_res
  ) => let
    val isarg =
      alist_is_cons(s2es_arg)
    // end of [val]
    val () =
      fprint(out, "(s2exp_fun ")
    // end of [val]
    val () =
      if isarg
        then fprint(out, "(=> ")
      // end of [if]
    val () =
      if isarg then auxsps(ar, s2es_arg)
    val () =
      if isarg then fprint(out, " ")
    val () = emit_s2exp(ar, out, s2e_res)
    val () =
      if isarg then fprint(out, ")")
    val ((*closed*)) = fprint(out, ")")
  in
    // nothing
  end // end of [S2Efun]
//
| v0(*rest-of-s2exp*) =>
  (
    s2exp_node_view_free(v0); fprint_s2exp(ar, out, s2e0)
  )
//
end // end of [emit_s2exp]

(* ****** ****** *)

implement
emit_decl_s2cst
  (ar, out, s2c) = let
//
fun
auxs2t
  {l:addr}
(
  ar: !arena(l), s2t: s2rt(l)
) : void =
(
case+
s2rt_view(ar, s2t)
of // case+
| ~S2RTfun
  (
    s2ts_arg, s2t_res
  ) =>
  {
    val () =
      emit_s2rtlst(ar, out, s2ts_arg)
    // end of [val]
    val () = fprint(out, " ")
    val () = emit_s2rt(ar, out, s2t_res)
  }
| v0(*non-fun*) =>
  (
    s2rt_view_free(v0);
    fprint(out, "() "); emit_s2rt(ar, out, s2t)
  )
) (* end of [auxs2t] *)
//
in
//
if
~s2cst_is_builtin(ar, s2c)
then
{
  val () =
    fprint(out, "(declare-fun ")
  val () = emit_s2cst_name(ar, out, s2c)
  val () = fprint(out, " ")
  val () = auxs2t(ar, s2cst_get_srt(ar, s2c))
  val () = fprintln! (out, ")")
} (* end of [then] *)
//
end // end of [emit_decl_s2cst]

(* ****** ****** *)

implement
emit_decl_s2var
  (ar, out, s2v) = {
//
val () =
fprint (
  out, "(declare-fun "
) (* fprint *)
val () = emit_s2var(ar, out, s2v)
val () = fprint (out, " () ")
val () = emit_s2rt(ar, out, s2var_get_srt(ar, s2v))
val () = fprintln! (out, ")")
//
} (* end of [decl_s2var] *)

(* ****** ****** *)

implement
emit_decl_s2varlst
  (ar, out, s2vs) =
(
if
alist_is_cons(s2vs)
then
(
  emit_decl_s2var(ar, out, alist_head(ar, s2vs));
  emit_decl_s2varlst(ar, out, alist_tail(ar, s2vs))
) (* end of [then] *)
) (* end of [emit_decl_s2varlst] *)

(* ****** ****** *)

implement
emit_solvercmd
  (ar, out, cmd) = let
in
//
case+ cmd of
//
| ~SOLVERCMDpop() => fprintln! (out, "(pop 1)")
| ~SOLVERCMDpush() => fprintln! (out, "(push 1)")
//
| ~SOLVERCMDassert(fml) =>
  {
    val () =
      fprint(out, "(assert ")
    // end of [val]
    val () = emit_form(ar, out, fml)
    val () = fprintln! (out, ")")
  } (* end of [SOLVERCMDassert] *)
//
| ~SOLVERCMDchecksat
    ((*void*)) => fprintln! (out, "(check-sat)")
//
| ~SOLVERCMDecholoc(loc) =>
  {
    val () = fprint(out, "(echo \"")
    val () = fprint_location(ar, out, loc)
    val () = fprintln! (out, "\")")
  }
//
| ~SOLVERCMDpopenv _ => () // removed
| ~SOLVERCMDpushenv _ => () // removed
//
| ~SOLVERCMDpopenv2 _ =>
  {
    val ((*void*)) = fprintln! (out, "(pop 1)")
  }
| ~SOLVERCMDpushenv2(s2vs) =>
  {
    val ((*void*)) = fprintln! (out, "(push 1)")
    val ((*void*)) = emit_decl_s2varlst(ar, out, s2vs)
  } (* SOLVERCMDpushenv2 *)
//
end // end of [emit_solvercmd]

(* ****** ****** *)

implement
emit_solvercmdlst
  (ar, out, cmds) =
(
case+ cmds of
| ~list_vt_nil() => ()
| ~list_vt_cons(cmd, cmds) =>
  {
    val () = emit_solvercmd(ar, out, cmd)
    val () = emit_solvercmdlst(ar, out, cmds)
  } (* end of [list_cons] *)
) (* end of [emit_solvercmdlst] *)

(* ****** ****** *)

implement
emit_preamble(out) = {
//
macdef
emitln(x) = fprintln! (out, ,(x))
//
val () = emitln(";;")
val () = emitln(";;By [patsolve_smt2]:")
val () = emitln(";;")
//
val () = emitln("(declare-sort s2rt_cls 0)")
val () = emitln("(declare-sort s2rt_eff 0)")
val () = emitln("(declare-sort s2rt_prop 0)")
val () = emitln("(declare-sort s2rt_t0ype 0)")
val () = emitln("(declare-sort s2rt_tkind 0)")
val () = emitln("(declare-sort s2rt_error 0)")
//
val () = emitln("(define-sort s2rt_int () Int)")
val () = emitln("(define-sort s2rt_addr () Int)")
val () = emitln("(define-sort s2rt_bool () Bool)")
//
val () = emitln("(define-sort file_mode () Int)")
//
val () = emitln("(define-sort s2rt_view () s2rt_prop)")
val () = emitln("(define-sort s2rt_type () s2rt_t0ype)")
val () = emitln("(define-sort s2rt_vtype () s2rt_t0ype)")
val () = emitln("(define-sort s2rt_vt0ype () s2rt_t0ype)")
//
val () = emitln("(define-fun unit_p () Bool true)")
//
val () = emitln("(define-fun s2exp_fun ((x Bool)) Bool x)")
val () = emitln("(define-fun s2exp_eqeq ((x Bool)) Bool x)")
val () = emitln("(define-fun s2exp_metdec ((x Bool)) Bool x)")
//
val () = emitln("(declare-fun s2exp_sizeof (s2rt_t0ype) Int)")
//
val () = emitln("(define-fun neg_int ((x Int)) Int (- x))")
val () = emitln("(define-fun abs_int ((x Int)) Int (abs x))")
val () = emitln("(define-fun add_int_int ((x Int) (y Int)) Int (+ x y))")
val () = emitln("(define-fun sub_int_int ((x Int) (y Int)) Int (- x y))")
val () = emitln("(define-fun mul_int_int ((x Int) (y Int)) Int (* x y))")
val () = emitln("(define-fun div_int_int ((x Int) (y Int)) Int (div x y))")
val () = emitln("(define-fun mod_int_int ((x Int) (y Int)) Int (mod x y))")
//
val () = emitln("(define-fun idiv_int_int ((x Int) (y Int)) Int (div x y))")
val () = emitln("(define-fun ndiv_int_int ((x Int) (y Int)) Int (div x y))")
//
val () = emitln("(define-fun eq_int_int ((x Int) (y Int)) Bool (= x y))")
val () = emitln("(define-fun lt_int_int ((x Int) (y Int)) Bool (< x y))")
val () = emitln("(define-fun gt_int_int ((x Int) (y Int)) Bool (> x y))")
val () = emitln("(define-fun lte_int_int ((x Int) (y Int)) Bool (<= x y))")
val () = emitln("(define-fun gte_int_int ((x Int) (y Int)) Bool (>= x y))")
val () = emitln("(define-fun neq_int_int ((x Int) (y Int)) Bool (not (= x y)))")
//
val () = emitln("(define-fun max_int_int ((x Int) (y Int)) Int (ite (>= x y) x y))")
val () = emitln("(define-fun min_int_int ((x Int) (y Int)) Int (ite (<= x y) x y))")
//
val () = emitln("(define-fun sgn_int ((x Int)) Int (ite (> x 0) 1 (ite (>= x 0) 0 (- 1))))")
//
val () = emitln("(define-fun null_addr () s2rt_addr 0)")
//
val () = emitln("(define-fun add_addr_int ((x s2rt_addr) (y Int)) s2rt_addr (+ x y))")
val () = emitln("(define-fun sub_addr_int ((x s2rt_addr) (y Int)) s2rt_addr (- x y))")
//
val () = emitln("(define-fun eq_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (= x y))")
val () = emitln("(define-fun lt_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (< x y))")
val () = emitln("(define-fun gt_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (> x y))")
val () = emitln("(define-fun lte_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (<= x y))")
val () = emitln("(define-fun gte_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (>= x y))")
val () = emitln("(define-fun neq_addr_addr ((x s2rt_addr) (y s2rt_addr)) Bool (not (= x y)))")
//
val () = emitln("(define-fun true_bool () Bool true)")
val () = emitln("(define-fun false_bool () Bool false)")
//
val () = emitln("(define-fun neg_bool ((x Bool)) Bool (not x))")
val () = emitln("(define-fun add_bool_bool ((x Bool) (y Bool)) Bool (or x y))")
val () = emitln("(define-fun mul_bool_bool ((x Bool) (y Bool)) Bool (and x y))")
//
val () = emitln("(define-fun eq_bool_bool ((x Bool) (y Bool)) Bool (= x y))")
val () = emitln("(define-fun lt_bool_bool ((x Bool) (y Bool)) Bool (and (not x) y))")
val () = emitln("(define-fun gt_bool_bool ((x Bool) (y Bool)) Bool (and x (not y)))")
val () = emitln("(define-fun neq_bool_bool ((x Bool) (y Bool)) Bool (not (= x y)))")
val () = emitln("(define-fun lte_bool_bool ((x Bool) (y Bool)) Bool (or (not x) y))")
val () = emitln("(define-fun gte_bool_bool ((x Bool) (y Bool)) Bool (or x (not y)))")
//
} (* end of [emit_preamble] *)

(* ****** ****** *)

implement
emit_preamble_real(out) = {
//
macdef
emitln(x) = fprintln! (out, ,(x))
//
val () = emitln(";;")
val () = emitln(";;emit_preamble_real()")
val () = emitln(";;")
//
val () = emitln("(define-sort s2rt_real () Real)")
//
val () = emitln("(define-fun int2real ((x Int)) Real (to_real x))")
val () = emitln("(define-fun floor_real ((x Real)) Int (to_int x))")
val () = emitln("(define-fun isint_real ((x Real)) Bool (is_int x))")
//
val () = emitln("(define-fun neg_real ((x Real)) Real (- x))")
val () = emitln("(define-fun abs_real ((x Real)) Real (ite (>= x 0.0) x (- x)))")
//
val () = emitln("(define-fun add_real_real ((x Real) (y Real)) Real (+ x y))")
val () = emitln("(define-fun sub_real_real ((x Real) (y Real)) Real (- x y))")
val () = emitln("(define-fun mul_real_real ((x Real) (y Real)) Real (* x y))")
val () = emitln("(define-fun div_real_real ((x Real) (y Real)) Real (/ x y))")
//
val () = emitln("(define-fun eq_real_real ((x Real) (y Real)) Bool (= x y))")
val () = emitln("(define-fun lt_real_real ((x Real) (y Real)) Bool (< x y))")
val () = emitln("(define-fun gt_real_real ((x Real) (y Real)) Bool (> x y))")
val () = emitln("(define-fun lte_real_real ((x Real) (y Real)) Bool (<= x y))")
val () = emitln("(define-fun gte_real_real ((x Real) (y Real)) Bool (>= x y))")
val () = emitln("(define-fun neq_real_real ((x Real) (y Real)) Bool (not (= x y)))")
//
val () = emitln("(define-fun max_real_real ((x Real) (y Real)) Real (ite (>= x y) x y))")
val () = emitln("(define-fun min_real_real ((x Real) (y Real)) Real (ite (<= x y) x y))")
//
val () = emitln("(define-fun sgn_real ((x Real)) Int (ite (> x 0.0) 1 (ite (>= x 0.0) 0 (- 1))))")
//
} (* end of [emit_preamble_real] *)

(* ****** ****** *)

implement
emit_the_s2cstmap
  {l}(ar, tbls, out) = () where
{
//
fun
auxlst
(
  ar: !arena(l), s2cs: s2cstlst_vt(l)
) : void =
(
case+ s2cs of
| ~list_vt_nil() => ()
| ~list_vt_cons(s2c, s2cs) => let
    val n0 = s2cst_get_nused(ar, s2c)
    val () =
      if n0 > 0 then emit_decl_s2cst(ar, out, s2c)
    // end of [val]
  in
    auxlst(ar, s2cs)
  end // end of [list_vt_cons]
) (* end of [auxlst] *)
//
val s2cs = the_s2cstmap_listize(ar, tbls)
//
val () = fprintln! (out, ";;")
val () = fprintln! (out, ";;emit_the_s2cstmap()")
val () = fprintln! (out, ";;")
//
val ((*void*)) = auxlst(ar, s2cs)
//
} (* end of [emit_the_s2cstmap] *)

(* ****** ****** *)

(* end of [patsolve_smt2_solving_emit.dats] *)
