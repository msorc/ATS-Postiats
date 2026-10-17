(*
##
## ATS-extsolve-z3:
## Solving ATS-constraints with Z3
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
PATSOLVE_targetloc
"./../ATS-extsolve"
//
#define
SMT_LIBZ3_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-smt-libz3"
//
(* ****** ****** *)
//
#staload "{$SMT_LIBZ3}/SATS/z3.sats"
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
#staload "./../SATS/patsolve_z3_solving.sats"
//
(* ****** ****** *)
//
extern
fun
c3nstr_solve_main{l:addr}
(
  ar: !arena(l), env: !smtenv(l)
, c3t: c3nstr(l), unsolved: &uint >> _, nerr: &int >> _
) : int(*status*) // end of [c3nstr_solve_main]
//
(* ****** ****** *)
//
extern
fun
c3nstr_solve_errmsg{l:addr}
  (ar: !arena(l), c3t: c3nstr(l), unsolved: uint): int
//
(* ****** ****** *)

implement 
c3nstr_solve_errmsg
  (ar, c3t, unsolved) = 0 where
{
//
val () = (
//
if
unsolved = 0u
then let
//
  val out = stderr_ref
  val loc = c3nstr_get_loc(ar, c3t)
  val c3tk = c3nstr_get_kind(ar, c3t)
//
  val () =
  (
    case+
    c3nstrkind_view(ar, c3tk)
    of // case+
    | ~C3TKmain() =>
        fprint(out, "UnsolvedConstraint(main)@")
    | ~C3TKtermet_isnat() =>
        fprint(out, "UnsolvedConstraint(termet_isnat)@")
    | ~C3TKtermet_isdec() =>
        fprint(out, "UnsolvedConstraint(termet_isdec)@")
    | v0(*rest-of-C3TK*) =>
      (
        c3nstrkind_view_free(v0);
        fprint(out, "UnsolvedConstraint(unclassified)@")
      )
  ) : void // end of [val]
//
in
  fprint_location(ar, out, loc);
  fprint(out, ":"); fprint_c3nstr(ar, out, c3t); fprint_newline(out)
end // end of [then]
//
) (* end of [val] *)
//
} (* end of [c3nstr_solve_errmsg] *)

(* ****** ****** *)
//
extern
fun
c3nstr_solve_prop{l:addr}
(
  loc0: loc_t(l)
, ar: !arena(l), env: !smtenv(l), s2p: s2exp(l), nerr: &int >> _
) : int (*status*) // end-of-function
//
extern
fun
c3nstr_solve_itmlst{l:addr}
(
  loc0: loc_t(l)
, ar: !arena(l), env: !smtenv(l)
, s3is: s3itmlst(l), unsolved: &uint >> _, nerr: &int >> _
) : int(*status*) // end-of-function
//
extern
fun
c3nstr_solve_itmlst_cnstr{l:addr}
(
  loc0: loc_t(l)
, ar: !arena(l), env: !smtenv(l)
, s3is: s3itmlst(l), c3t: c3nstr(l), unsolved: &uint >> _, nerr: &int >> _
) : int(*status*) // end-of-function
//
extern
fun
c3nstr_solve_itmlst_disj{l:addr}
(
  loc0: loc_t(l)
, ar: !arena(l), env: !smtenv(l)
, s3is: s3itmlst(l), s3iss: s3itmlstlst(l), unsolved: &uint >> _, nerr: &int >> _
) : int(*status*) // end-of-function
//
extern
fun
c3nstr_solve_solverify{l:addr}
(
  loc0: loc_t(l)
, ar: !arena(l), env: !smtenv(l), s2e_prop: s2exp(l), nerr: &int >> _
) : int (*status*) // end-of-function
//
(* ****** ****** *)

implement
c3nstr_solve_prop
(
  loc0, ar, env, s2p, nerr
) = let
//
val s2p =
  formula_make_s2exp (ar, env, s2p)
//
in
  smtenv_solve_formula (env, s2p)
end // end of [c3nstr_solve_prop]

(* ****** ****** *)

implement
c3nstr_solve_itmlst
(
  loc0, ar, env, s3is0, unsolved, nerr
) = let
in
//
if
alist_is_nil(s3is0)
then ~1(*solved*)
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
    c3nstr_solve_itmlst(loc0, ar, env, s3is, unsolved, nerr)
  end // end of [S3ITMsvar]
//
| ~S3ITMhypo(h3p) => let
    val () = smtenv_add_h3ypo(ar, env, h3p)
  in
    c3nstr_solve_itmlst(loc0, ar, env, s3is, unsolved, nerr)
  end // end of [S3ITMhypo]
//
| ~S3ITMsVar(s2V) =>
    c3nstr_solve_itmlst(loc0, ar, env, s3is, unsolved, nerr)
//
| ~S3ITMcnstr(c3t) =>
    c3nstr_solve_itmlst_cnstr(loc0, ar, env, s3is, c3t, unsolved, nerr)
//
| ~S3ITMcnstr_ref
    (loc_ref, opt) =>
  (
    case+
    c3nstropt_view(ar, opt)
    of // case+
    | ~C3NSTRnone() => ~1(*solved*)
    | ~C3NSTRsome(c3t) =>
        c3nstr_solve_itmlst_cnstr
          (loc_ref, ar, env, s3is, c3t, unsolved, nerr)
        // c3nstr_solve_itmlst_cnstr
  ) (* end of [S3ITMcnstr_ref] *)
//
| ~S3ITMdisj(s3iss_disj) =>
  (
    c3nstr_solve_itmlst_disj
      (loc0, ar, env, s3is, s3iss_disj, unsolved, nerr)
    // c3nstr_solve_itmlst_disj
  ) (* end of [S3ITMdisj] *)
//
| ~S3ITMsolassert
    (s2e_prop) => let
    val () = smtenv_add_s2exp(ar, env, s2e_prop)
  in
    c3nstr_solve_itmlst(loc0, ar, env, s3is, unsolved, nerr)
  end // end of [S3ITMsolassert]
//
end // end of [else]
//
end // end of [c3nstr_solve_itmlst]

(* ****** ****** *)

implement
c3nstr_solve_itmlst_cnstr
(
  loc0, ar, env, s3is, c3t, unsolved, nerr
) = let
//
val (pf|()) = smtenv_push (env)
//
val ans1 =
  c3nstr_solve_main (ar, env, c3t, unsolved, nerr)
//
val ((*void*)) = smtenv_pop (pf | ar, env)
//
val ans2 =
  c3nstr_solve_itmlst (loc0, ar, env, s3is, unsolved, nerr)
//
in
  if ans1 >= 0 then 0(*unsolved*) else ans2
end // end of [c3nstr_solve_itmlst_cnstr]

(* ****** ****** *)

implement
c3nstr_solve_itmlst_disj
(
  loc0, ar, env
, s3is0, s3iss(*disj*), unsolved, nerr
) = let
in
//
if
alist_is_nil(s3iss)
then ~1 (*solved*)
else let
  val s3is = alist_head(ar, s3iss)
  val (pf|()) = smtenv_push (env)
  val s3is1 = alist_append (ar, s3is, s3is0)
  val ans =
    c3nstr_solve_itmlst (loc0, ar, env, s3is1, unsolved, nerr)
  // end of [val]
  val ((*void*)) = smtenv_pop (pf | ar, env)
in
  c3nstr_solve_itmlst_disj
    (loc0, ar, env, s3is0, alist_tail(ar, s3iss), unsolved, nerr)
  // c3nstr_solve_itmlst_disj
end // end of [else]
//
end // end of [c3nstr_solve_itmlst_disj]

(* ****** ****** *)

implement
c3nstr_solve_solverify
(
  loc0, ar, env, s2e_prop, nerr
) = let
//
val
s2e_prop =
  formula_make_s2exp (ar, env, s2e_prop)
//
in
  smtenv_solve_formula (env, s2e_prop)
end // end of [c3nstr_solve_solverify]

(* ****** ****** *)

implement
c3nstr_solve_main
(
  ar, env, c3t, unsolved, nerr
) = let
//
val loc0 = c3nstr_get_loc(ar, c3t)
//
var status: int =
(
//
// ~1: solved; 0: unsolved
//
case+
c3nstr_node_view
  (ar, c3nstr_get_node(ar, c3t))
of // case+
| ~C3NSTRprop(s2p) =>
    c3nstr_solve_prop(loc0, ar, env, s2p, nerr)
  // end of [C3NSTRprop]
| ~C3NSTRitmlst(s3is) =>
    c3nstr_solve_itmlst(loc0, ar, env, s3is, unsolved, nerr)
  // end of [C3NSTRitmlst]
| ~C3NSTRsolverify(s2e_prop) =>
    c3nstr_solve_solverify(loc0, ar, env, s2e_prop, nerr)
//
) : int // end of [val]
//
val () = (
//
if
status >= 0
then {
  val iswarn =
    c3nstr_solve_errmsg (ar, c3t, unsolved)
  // end of [val]
  val () = if iswarn > 0 then (status := ~1)
} // end of [then]
//
) (* end of [val] *)
//
val () =
  if status >= 0 then (unsolved := unsolved + 1u)
//
in
  status (* ~1/0: solved/unsolved *)
end // end of [c3nstr_solve_main]

(* ****** ****** *)

implement
c3nstr_z3_solve
  (ar, c3t0) = let
//
val env = smtenv_create()
//
var unsolved: uint = 0u and err: int = 0
//
val _(*ans*) =
  c3nstr_solve_main (ar, env, c3t0, unsolved, err)
//
val ((*void*)) = smtenv_destroy (ar, env)
//
in
//
case+ 0 of
| _ when
    unsolved = 0u => let
    val () = (
      prerrln! "typechecking is finished successfully!"
    ) (* end of [val] *)
  in
    // nothing
  end // end of [unsolved = 0]
| _ (* unsolved > 0 *) =>
  {
    val () = prerr "typechecking has failed"
    val () =
    if unsolved <= 1u then prerr ": there is one unsolved constraint"
    val () =
    if unsolved >= 2u then prerr ": there are some unsolved constraints"
    val () = (
      prerrln! ": please inspect the above reported error message(s) for information."
    ) (* end of [val] *)
  } (* end of [_ when unsolved > 0] *)
//
end // end of [c3nstr_z3_solve]

(* ****** ****** *)

#define PATSOLVE_Z3_SOLVING 1

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_z3_solving_ctx.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_z3_solving_sort.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_z3_solving_form.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_z3_solving_smtenv.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

local
//
#include "./SOLVING/patsolve_z3_solving_interp.dats"
//
in
  // nothing
end // end of [local]

(* ****** ****** *)

(* end of [patsolve_z3_solving.dats] *)
