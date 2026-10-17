(*
##
## ATS-extsolve-smt2:
## Outputing ATS-constraints
## in the format of smt-lib2
##
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
** Start time: June, 2015
*)

(* ****** ****** *)
//
#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#define
PATSOLVE_targetloc "./../ATS-extsolve"
//
(* ****** ****** *)
//
#staload
"libats/SATS/arena.sats"
#staload
_(*anon*) = "libats/DATS/arena.dats"
//
#staload
"{$PATSOLVE}/SATS/patsolve_cnstrnt.sats"
#staload
"{$PATSOLVE}/SATS/patsolve_parsing.sats"
//
(* ****** ****** *)
//
#staload
"./../SATS/patsolve_smt2_commarg.sats"
#staload
"./../SATS/patsolve_smt2_solving.sats"
//
(* ****** ****** *)
//
implement
fprint_solvercmd
  (ar, out, x0) =
(
//
case+ x0 of
//
| SOLVERCMDpop() =>
    fprint! (out, "SOLVERCMDpop()")
| SOLVERCMDpush() =>
    fprint! (out, "SOLVERCMDpush()")
//
| SOLVERCMDassert(fml) =>
  (
    fprint(out, "SOLVERCMDassert(");
    fprint_form(ar, out, fml); fprint(out, ")")
  )
//
| SOLVERCMDchecksat() =>
    fprint! (out, "SOLVERCMDchecksat()")
//
| SOLVERCMDecholoc(loc) =>
  (
    fprint(out, "SOLVERCMDecholoc(");
    fprint_location(ar, out, loc); fprint(out, ")")
  )
//
| SOLVERCMDpopenv(s2vs) =>
  (
    fprint(out, "SOLVERCMDpopenv(");
    fprint_s2varlst(ar, out, s2vs); fprint(out, ")")
  )
| SOLVERCMDpushenv((*void*)) =>
    fprint! (out, "SOLVERCMDpushenv()")
//
| SOLVERCMDpopenv2() =>
    fprint! (out, "SOLVERCMDpopenv2()")
| SOLVERCMDpushenv2(s2vs) =>
  (
    fprint(out, "SOLVERCMDpushenv2(");
    fprint_s2varlst(ar, out, s2vs); fprint(out, ")")
  )
//
) (* end of [fprint_solvercmd] *)

(* ****** ****** *)

implement
solvercmdlst_reverse
  {l}(xs) = let
//
vtypedef xs = solvercmdlst(l)
//
fun
free
(
  ys: xs
) : void =
(
case+ ys of
| ~list_vt_nil() => ()
| ~list_vt_cons(y, ys) =>
  (
    case+ y of
    | ~SOLVERCMDpop() => free(ys)
    | ~SOLVERCMDpush() => free(ys)
    | ~SOLVERCMDassert _ => free(ys)
    | ~SOLVERCMDchecksat() => free(ys)
    | ~SOLVERCMDecholoc _ => free(ys)
    | ~SOLVERCMDpopenv _ => free(ys)
    | ~SOLVERCMDpushenv() => free(ys)
    | ~SOLVERCMDpopenv2() => free(ys)
    | ~SOLVERCMDpushenv2 _ => free(ys)
  )
) (* end of [free] *)
//
fun
loop
(
  xs: xs, ys: xs, res: xs
) : xs = (
//
case+ xs of
| ~list_vt_nil() => let
    val () = free(ys) in res
  end // end of [list_vt_nil]
| ~list_vt_cons(x, xs) =>
  (
    case+ x of
    | SOLVERCMDpopenv _ => let
        val ys = list_vt_cons(x, ys)
        val res = list_vt_cons(SOLVERCMDpopenv2(), res)
      in
        loop(xs, ys, res)
      end // end of [SOLVERCMDpopenv]
    | ~SOLVERCMDpushenv() => let
        val-~list_vt_cons(y, ys) = ys
        val-~SOLVERCMDpopenv(s2vs) = y
        val res = list_vt_cons(SOLVERCMDpushenv2(s2vs), res)
      in
        loop(xs, ys, res)
      end // end of [SOLVERCMDpushenv]
    | _(*rest-of-solvercmd*) => loop(xs, ys, list_vt_cons(x, res))
  )
//
) (* end of [loop] *)
in
  loop(xs, list_vt_nil(), list_vt_nil())
end // end of [solvercmdlst_reverse]

(* ****** ****** *)
//
extern
fun
c3nstr_solve_main{l:addr}
  (ar: !arena(l), env: !smtenv(l), c3t: c3nstr(l)): void
//
(* ****** ****** *)
//
extern
fun
c3nstr_solve_prop{l:addr}
(
  ar: !arena(l), env: !smtenv(l), loc0: loc_t(l), s2p: s2exp(l)
) : void // end-of-function
//
extern
fun
c3nstr_solve_itmlst{l:addr}
(
  ar: !arena(l), env: !smtenv(l), loc0: loc_t(l), s3is: s3itmlst(l)
) : void // end-of-function
//
extern
fun
c3nstr_solve_itmlst_cnstr{l:addr}
(
  ar: !arena(l), env: !smtenv(l)
, loc0: loc_t(l), s3is: s3itmlst(l), c3t: c3nstr(l)
) : void // end-of-function
//
extern
fun
c3nstr_solve_itmlst_disj{l:addr}
(
  ar: !arena(l), env: !smtenv(l)
, loc0: loc_t(l), s3is: s3itmlst(l), s3iss: s3itmlstlst(l)
) : void // end-of-function
//
extern
fun
c3nstr_solve_solverify{l:addr}
(
  ar: !arena(l), env: !smtenv(l), loc0: loc_t(l), s2e_prop: s2exp(l)
) : void // end-of-function
//
(* ****** ****** *)

implement
c3nstr_solve_prop
(
  ar, env, loc0, s2p0
) = let
//
val s2p0 =
  formula_make_s2exp (ar, env, s2p0)
//
in
  smtenv_solve_formula (ar, env, loc0, s2p0)
end // end of [c3nstr_solve_prop]

(* ****** ****** *)

implement
c3nstr_solve_itmlst
  (ar, env, loc0, s3is0) = let
in
//
if
alist_is_nil(s3is0)
then ()
else let
//
val s3i = alist_head(ar, s3is0)
val s3is = alist_tail(ar, s3is0)
//
in
//
case+
s3itm_view(ar, s3i)
of // case+
//
| ~S3ITMsvar(s2v) => let
    val () = smtenv_add_s2var(ar, env, s2v)
  in
    c3nstr_solve_itmlst(ar, env, loc0, s3is)
  end // end of [S3ITMsvar]
//
| ~S3ITMhypo(h3p) => let
    val () = smtenv_add_h3ypo(ar, env, h3p)
  in
    c3nstr_solve_itmlst(ar, env, loc0, s3is)
  end // end of [S3ITMhypo]
//
| ~S3ITMsVar(s2V) =>
    c3nstr_solve_itmlst(ar, env, loc0, s3is)
//
| ~S3ITMcnstr(c3t) =>
    c3nstr_solve_itmlst_cnstr(ar, env, loc0, s3is, c3t)
//
| ~S3ITMcnstr_ref
    (loc_ref, opt) =>
  (
    case+
    c3nstropt_view(ar, opt)
    of // case+
    | ~C3NSTRnone() => ()
    | ~C3NSTRsome(c3t) =>
        c3nstr_solve_itmlst_cnstr(ar, env, loc_ref, s3is, c3t)
      // end of [Some]
  ) (* end of [S3ITMcnstr_ref] *)
//
| ~S3ITMdisj(s3iss_disj) =>
  (
    c3nstr_solve_itmlst_disj(ar, env, loc0, s3is, s3iss_disj)
  ) (* end of [S3ITMdisj] *)
//
| ~S3ITMsolassert(s2e_prop) => let
    val () =
      smtenv_add_s2exp(ar, env, s2e_prop)
    // end of [val]
  in
    c3nstr_solve_itmlst(ar, env, loc0, s3is)
  end // end of [S3ITMsolassert]
//
end // end of [else]
//
end // end of [c3nstr_solve_itmlst]

(* ****** ****** *)

implement
c3nstr_solve_itmlst_cnstr
  (ar, env, loc0, s3is, c3t) = () where
{
//
val (pf|()) = smtenv_push (env)
//
val () = c3nstr_solve_main (ar, env, c3t)
//
val ((*void*)) = smtenv_pop (pf | ar, env)
//
val () = c3nstr_solve_itmlst (ar, env, loc0, s3is)
//
} (* end of [c3nstr_solve_itmlst_cnstr] *)

(* ****** ****** *)

implement
c3nstr_solve_itmlst_disj
(
  ar, env, loc0, s3is0, s3iss(*disj*)
) = let
in
//
if
alist_is_nil(s3iss)
then ()
else let
  val s3is = alist_head(ar, s3iss)
  val (pf|()) = smtenv_push (env)
  val s3is1 = alist_append (ar, s3is, s3is0)
  val () = c3nstr_solve_itmlst (ar, env, loc0, s3is1)
  val ((*void*)) = smtenv_pop (pf | ar, env)
in
  c3nstr_solve_itmlst_disj
    (ar, env, loc0, s3is0, alist_tail(ar, s3iss))
  // c3nstr_solve_itmlst_disj
end // end of [else]
//
end // end of [c3nstr_solve_itmlst_disj]

(* ****** ****** *)

implement
c3nstr_solve_solverify
  (ar, env, loc0, s2e_prop) = let
//
val s2e_prop =
  formula_make_s2exp (ar, env, s2e_prop)
//
in
  smtenv_solve_formula (ar, env, loc0, s2e_prop)
end // end of [c3nstr_solve_solverify]

(* ****** ****** *)

implement
c3nstr_solve_main
  (ar, env, c3t) = let
//
val
loc0 = c3nstr_get_loc(ar, c3t)
//
in
//
case+
c3nstr_node_view
  (ar, c3nstr_get_node(ar, c3t))
of (* case+ *)
//
| ~C3NSTRprop(s2p) =>
    c3nstr_solve_prop(ar, env, loc0, s2p)
//
| ~C3NSTRitmlst(s3is) =>
    c3nstr_solve_itmlst(ar, env, loc0, s3is)
//
| ~C3NSTRsolverify(s2e_prop) =>
    c3nstr_solve_solverify(ar, env, loc0, s2e_prop)
//
end // end of [c3nstr_solve_main]

(* ****** ****** *)

implement
c3nstr_smt2_solve
  (ar, tbls, out, c3t0) = () where
{
//
val env = smtenv_create()
//
val (pfpush|()) = smtenv_push(env)
val ((*solved*)) = c3nstr_solve_main(ar, env, c3t0)
val ((*popped*)) = smtenv_pop(pfpush | ar, env)
//
val cmds = smtenv_destroy(env)
val cmds = solvercmdlst_reverse(cmds)
//
val () =
emit_preamble(out)
val () =
(
if the_constraint_real() > 0
  then emit_preamble_real(out)
) (* end of [val] *)
//
val () = emit_the_s2cstmap(ar, tbls, out)
//
val () = fprintln! (out, ";;")
val () = fprintln! (out, ";;ATS-constraints")
val () = fprintln! (out, ";;generated during typechecking")
val () = fprintln! (out, ";;")
//
val () = emit_solvercmdlst (ar, out, cmds)
//
} (* end of [c3nstr_smt2_solve] *)

(* ****** ****** *)

#define PATSOLVE_SMT2_SOLVING 1

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_smt2_solving_ctx.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_smt2_solving_emit.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_smt2_solving_form.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_smt2_solving_smtenv.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_smt2_solving_interp.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

(* end of [patsolve_smt2_solving.dats] *)
