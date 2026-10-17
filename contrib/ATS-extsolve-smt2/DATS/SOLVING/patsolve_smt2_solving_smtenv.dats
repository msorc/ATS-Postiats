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
staload "./patsolve_smt2_solving_ctx.dats"
//
(* ****** ****** *)
//
//
// HX-2026-10:
// the commands are accumulated (in reverse order)
// in a linear list
//
vtypedef
SMT2_solver(l:addr) = solvercmdlst(l)
//
fun
SMT2_solver_add
  {l:addr}
(
  solver: &SMT2_solver(l) >> _, cmd: solvercmd(l)
) : void = (solver := list_vt_cons(cmd, solver))
//
(* ****** ****** *)
//
// HX-2026-10:
// [smtenv] is indexed by the arena
// (the s2vars are kept in arena lists)
//
datavtype
smtenv(l:addr) =
SMTENV of
(
  smtenv_struct(l)
) where
smtenv_struct(l:addr) = @{
//
smtenv_solver= SMT2_solver(l)
,
smtenv_s2varlst = s2varlst(l)
,
smtenv_s2varlstlst = List0_vt(s2varlst(l))
//
} (* end of [smtenv_struct] *)
//
(* ****** ****** *)
//
assume smtenv_vtype(l:addr) = smtenv(l)
assume smtenv_push_v = unit_v
//
(* ****** ****** *)

implement
smtenv_create
  {l}() = env where
{
//
val env = SMTENV{l}(_)
val+SMTENV(env_s) = env
//
val () = env_s.smtenv_solver := list_vt_nil()
val () = env_s.smtenv_s2varlst := alist_nil()
val () = env_s.smtenv_s2varlstlst := list_vt_nil()
//
prval () = fold@(env)
//
} (* end of [smtenv_create] *)

(* ****** ****** *)

implement
smtenv_destroy
  (env) = xs where
{
//
val+~SMTENV(env_s) = env
//
val xs = env_s.smtenv_solver
//
val () = list_vt_free(env_s.smtenv_s2varlstlst)
//
} (* end of [smtenv_destroy] *)

(* ****** ****** *)

implement
smtenv_pop
  (pf | ar, env) = let
//
prval
unit_v((*void*)) = pf
//
val+@SMTENV(env_s) = env
//
val s2vs =
  alist_reverse(ar, env_s.smtenv_s2varlst)
//
val ((*void*)) =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDpopenv(s2vs))
//
val s2vss = env_s.smtenv_s2varlstlst
val-~list_vt_cons(s2vs, s2vss) = s2vss
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
val ((*void*)) =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDpushenv())
//
val s2vs = env_s.smtenv_s2varlst
val s2vss = env_s.smtenv_s2varlstlst
//
val ((*void*)) =
  env_s.smtenv_s2varlst := alist_nil()
val ((*void*)) =
  env_s.smtenv_s2varlstlst := list_vt_cons(s2vs, s2vss)
//
prval ((*folded*)) = fold@(env)
//
in
  (unit_v() | ())
end // end of [smtenv_push]

(* ****** ****** *)

implement
smtenv_add_s2var
  (ar, env, s2v0) = () where
{
//
val+@SMTENV(env_s) = env
//
val s2vs = env_s.smtenv_s2varlst
//
val ((*void*)) =
  env_s.smtenv_s2varlst := alist_cons(ar, s2v0, s2vs)
//
prval ((*void*)) = fold@(env)
//
} (* end of [smtenv_add_s2var] *)

(* ****** ****** *)

implement
smtenv_add_s2exp
  (ar, env, s2p0) =
{
//
val
s2p0 =
formula_make_s2exp
  (ar, env, s2p0)
//
val+
@SMTENV(env_s) = env
//
val ((*void*)) =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDassert(s2p0))
//
prval ((*folded*)) = fold@(env)
//
} (* end of [smtenv_add_s2exp] *)

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
  (ar, env, loc0, s2p0) =
{
//
val+
@SMTENV(env_s) = env
//
val () =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDpush())
val () =
SMT2_solver_add
(
  env_s.smtenv_solver
, SOLVERCMDassert(formula_not(ar, s2p0))
) (* end of [val] *)
val () =
SMT2_solver_add
(
  env_s.smtenv_solver, SOLVERCMDecholoc(loc0)
) (* end of [val] *)
val () =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDchecksat())
val () =
SMT2_solver_add
  (env_s.smtenv_solver, SOLVERCMDpop())
//
prval ((*void*)) = fold@(env)
//
} (* end of [smtenv_solve_formula] *)

(* ****** ****** *)

(* end of [patsolve_smt2_solving_smtenv.dats] *)
