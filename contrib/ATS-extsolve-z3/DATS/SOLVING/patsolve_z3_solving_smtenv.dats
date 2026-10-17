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
#staload "./patsolve_z3_solving_ctx.dats"
//
(* ****** ****** *)

implement
s2var_pop_payload
  (ar, s2v0) = ast where
{
//
val asts =
  s2var_get_payload(ar, s2v0)
val asts =
  $UN.castvwtp0{List1_vt(form)}(asts)
//
val+~list_vt_cons(ast, asts) = asts
//
val ((*void*)) =
  s2var_set_payload(ar, s2v0, $UN.castvwtp0{ptr}(asts))
//
} (* end of [s2var_pop_payload] *)

implement
s2var_top_payload
  (ar, s2v0) = let
//
val asts =
  s2var_get_payload(ar, s2v0)
val asts =
  $UN.castvwtp0{List1_vt(Z3_ast)}(asts)
//
val+list_vt_cons(ast, _) = asts
//
val (
  fpf | ctx
) = the_Z3_context_vget()
val ast2 = Z3_inc_ref(ctx, ast)
prval ((*void*)) = fpf(ctx)
//
prval ((*void*)) = $UN.cast2void(asts)
//
in
  $UN.castvwtp0{form}(ast2)
end // end of [s2var_top_payload]

implement
s2var_push_payload
  (ar, s2v0, ast) = let
//
val asts =
  s2var_get_payload(ar, s2v0)
val asts =
  list_vt_cons(ast, $UN.castvwtp0{formlst}(asts))
//
in
  s2var_set_payload(ar, s2v0, $UN.castvwtp0{ptr}(asts))
end (* end of [s2var_push_payload] *)

(* ****** ****** *)
//
// HX-2026-10:
// the s2vars are kept as pointers
// (so that [smtenv] need not be indexed)
//
datavtype
smtenv =
SMTENV of (smtenv_struct)
//
where
smtenv_struct = @{
//
smtenv_solver= Z3_solver
,
smtenv_s2varlst = List0_vt(ptr)
,
smtenv_s2varlstlst = List0_vt(List0_vt(ptr))
//
} (* end of [smtenv_struct] *)
//
(* ****** ****** *)
//
extern
fun
smtenv_s2varlst_vt_free
  {l:addr}(ar: !arena(l), s2vs: List0_vt(ptr)): void
//
extern
fun
smtenv_s2varlstlst_vt_free
  {l:addr}(ar: !arena(l), xss: List0_vt(List0_vt(ptr))): void
//
implement
smtenv_s2varlst_vt_free
  {l}(ar, s2vs) =
(
case+ s2vs of
| ~list_vt_nil
    ((*void*)) => ()
| ~list_vt_cons
    (s2v, s2vs) => let
    val ast =
      s2var_pop_payload(ar, $UN.cast{s2var(l)}(s2v))
    val ast = $UN.castvwtp0{Z3_ast}(ast)
    val (fpf | ctx) = the_Z3_context_vget()
    val ((*freed*)) = Z3_dec_ref(ctx, ast)
    prval ((*void*)) = fpf(ctx)
  in
    smtenv_s2varlst_vt_free(ar, s2vs)
  end // end of [list_vt_cons]
) (* end of [smtenv_s2varlst_vt_free] *)
//
implement
smtenv_s2varlstlst_vt_free
  (ar, xss) =
(
case+ xss of
| ~list_vt_nil() => ()
| ~list_vt_cons(xs, xss) =>
  (
    smtenv_s2varlst_vt_free(ar, xs);
    smtenv_s2varlstlst_vt_free(ar, xss)
  )
) (* smtenv_s2varlstlst_vt_free *)
//
(* ****** ****** *)

assume smtenv_vtype(l:addr) = smtenv
assume smtenv_push_v = unit_v

(* ****** ****** *)

implement
smtenv_create
  () = env where
{
//
val env = SMTENV(_)
val+SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val
solver = Z3_mk_solver(ctx)
//
prval ((*void*)) = fpf(ctx)
//
val () = env_s.smtenv_solver := solver
val () = env_s.smtenv_s2varlst := nil_vt()
val () = env_s.smtenv_s2varlstlst := nil_vt()
//
prval () = fold@(env)
//
} (* end of [smtenv_create] *)

(* ****** ****** *)

implement
smtenv_destroy
  (ar, env) = let
//
val+~SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val () = Z3_solver_dec_ref(ctx, env_s.smtenv_solver)
//
prval ((*void*)) = fpf(ctx)
//
val () =
  smtenv_s2varlst_vt_free(ar, env_s.smtenv_s2varlst)
val () =
  smtenv_s2varlstlst_vt_free(ar, env_s.smtenv_s2varlstlst)
//
in
  // nothing
end // end of [smtenv_destroy]

(* ****** ****** *)

implement
smtenv_pop
  (pf | ar, env) = let
//
prval unit_v() = pf
//
val+@SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val ((*void*)) =
  Z3_solver_pop (ctx, env_s.smtenv_solver, 1u)
//
prval ((*void*)) = fpf(ctx)
//
val s2vs = env_s.smtenv_s2varlst
val ((*void*)) = smtenv_s2varlst_vt_free(ar, s2vs)
val-~list_vt_cons(s2vs, s2vss) = env_s.smtenv_s2varlstlst
val ((*void*)) = env_s.smtenv_s2varlst := s2vs
val ((*void*)) = env_s.smtenv_s2varlstlst := s2vss
//
prval ((*folded*)) = fold@(env)
//
in
  // nothing
end // end of [smtenv_pop]

(* ****** ****** *)

implement
smtenv_push
  (env) = let
//
val+@SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val ((*void*)) =
  Z3_solver_push (ctx, env_s.smtenv_solver)
//
prval ((*void*)) = fpf(ctx)
//
val s2vs = env_s.smtenv_s2varlst
val s2vss = env_s.smtenv_s2varlstlst
val ((*void*)) = env_s.smtenv_s2varlst := nil_vt()
val ((*void*)) = env_s.smtenv_s2varlstlst := cons_vt(s2vs, s2vss)
//
prval ((*folded*)) = fold@(env)
//
in
  (unit_v() | ())
end // end of [smtenv_push]

(* ****** ****** *)

implement
smtenv_add_s2var
  (ar, env, s2v0) = let
//
val+@SMTENV(env_s) = env
//
val s2vs =
  env_s.smtenv_s2varlst
val ((*void*)) =
  env_s.smtenv_s2varlst := cons_vt($UN.cast{ptr}(s2v0), s2vs)
//
prval ((*void*)) = fold@(env)
//
val ast0 = formula_make_s2var_fresh(ar, env, s2v0)
//
in
  s2var_push_payload(ar, s2v0, ast0)
end // end of [smtenv_add_s2var]

(* ****** ****** *)

implement
smtenv_add_s2exp
  (ar, env, s2p0) = let
//
val s2p0 =
  formula_make_s2exp(ar, env, s2p0)
//
val s2p0 = $UN.castvwtp0{Z3_ast}(s2p0)
//
val+@SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
val ((*void*)) =
  Z3_solver_assert(ctx, env_s.smtenv_solver, s2p0)
//
prval ((*void*)) = fpf(ctx)
//
prval ((*void*)) = fold@(env)
//
val (fpf | ctx) =
  the_Z3_context_vget()
val () = Z3_dec_ref(ctx, s2p0)
prval ((*void*)) = fpf(ctx)
//
in
  // nothing
end // end of [smtenv_add_s2exp]

(* ****** ****** *)

implement
smtenv_add_h3ypo
  (ar, env, h3p0) = let
in
//
case+
h3ypo_node_view
  (ar, h3ypo_get_node(ar, h3p0))
of (* case+ *)
//
| ~H3YPOprop s2p =>
    smtenv_add_s2exp(ar, env, s2p)
  // end of [H3YPOprop]
//
| ~H3YPObind
    (s2v1, s2e2) => let
  in
    if s2var_is_impred(ar, s2v1)
      then ()
      else let
        val s2p =
        s2exp_eqeq
          (ar, s2exp_var(ar, s2v1), s2e2)
        // end of [val]
      in
        smtenv_add_s2exp(ar, env, s2p)
      end // end of [else]
  end // end of [H3YPObind]
//
| ~H3YPOeqeq
    (s2e1, s2e2) =>
  (
    smtenv_add_s2exp(ar, env, s2exp_eqeq(ar, s2e1, s2e2))
  ) (* end of [H3YPOeqeq] *)
//
end // end of [smtenv_add_h3ypo]

(* ****** ****** *)

implement
smtenv_solve_formula
  (env, s2p0) = let
//
val+@SMTENV(env_s) = env
//
val (fpf | ctx) =
  the_Z3_context_vget()
//
val () =
Z3_solver_push
  (ctx, env_s.smtenv_solver)
//
val s2p1 = formula_not(s2p0)
val s2p1 = $UN.castvwtp0{Z3_ast}(s2p1)
//
val () =
Z3_solver_assert
  (ctx, env_s.smtenv_solver, s2p1)
//
val ans =
Z3_solver_check(ctx, env_s.smtenv_solver)
//
val ((*freed*)) = Z3_dec_ref(ctx, s2p1)
//
val () =
Z3_solver_pop
  (ctx, env_s.smtenv_solver, 1u)
//
prval ((*void*)) = fpf(ctx)
//
prval ((*void*)) = fold@(env)
//
in
//
case+ 0 of
| _ when ans = Z3_L_TRUE => 1
| _ when ans = Z3_L_FALSE => ~1
| _ (*when ans = Z3_L_UNDEF*) => 0
//
end (* end of [smtenv_solve_formula] *)

(* ****** ****** *)

(* end of [patsolve_z3_solving_smtenv.dats] *)
