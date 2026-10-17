(* ATS2 part of the macro test that is not generated (m2_gen.py): the language specific helpers, before m2common.hats *)
(* ****** ****** *)
//
// the dumper of the macro values (independent of fprint_m2val of the module under test)
//
fun dd_m2val (x: m2val): void = (
  case+ m2val_view (x) of
  | ~M2Vint (i) => (dd_ps "M2Vint("; dd_int i; dd_ps ")")
  | ~M2Vbool (b) => (dd_ps "M2Vbool("; dd_bool b; dd_ps ")")
  | ~M2Vchar (c) => (dd_ps "M2Vchar("; dd_char c; dd_ps ")")
  | ~M2Vfloat (s) => (dd_ps "M2Vfloat("; dd_string s; dd_ps ")")
  | ~M2Vstring (s) => (dd_ps "M2Vstring("; dd_string s; dd_ps ")")
  | ~M2Vunit () => dd_ps "M2Vunit()"
  | ~M2Vscode (e) => (dd_ps "M2Vscode("; dd_s2exp e; dd_ps ")")
  | ~M2Vdcode (e) => (dd_ps "M2Vdcode("; dd_d2exp e; dd_ps ")")
  | ~M2Vlist (xs) => (dd_ps "M2Vlist["; dd_m2valist xs; dd_ps "]")
  | ~M2Verr () => dd_ps "M2Verr()"
) and dd_m2valist (xs: m2valist): void = let
  fun loop (xs: m2valist, i: int): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => ((if i > 0 then dd_ps ","); dd_m2val x; loop (xs, i+1))
    | ~GLnil () => ()
in
  loop (xs, 0)
end
//
fun K_M2Vint (i: int): m2val = m2val_M2Vint (i)
fun K_M2Vbool (b: bool): m2val = m2val_M2Vbool (b)
fun K_M2Vchar (c: char): m2val = m2val_M2Vchar (c)
fun K_M2Vfloat (s: string): m2val = m2val_M2Vfloat (s)
fun K_M2Vstring (s: string): m2val = m2val_M2Vstring (s)
fun K_M2Vunit (): m2val = m2val_M2Vunit ()
fun K_M2Vscode (e: s2exp): m2val = m2val_M2Vscode (e)
fun K_M2Vdcode (e: d2exp): m2val = m2val_M2Vdcode (e)
fun K_M2Vlist (xs: m2valist): m2val = m2val_M2Vlist (xs)
fun K_M2Verr (): m2val = m2val_M2Verr ()
fun LN_m2valist (): m2valist = glist_nil ()
fun LC_m2valist (x: m2val, xs: m2valist): m2valist = glist_cons<m2val> (x, xs)
//
// the errors of the evaluator (the module keeps the list of the errors; only the count is observable): check and clear
fun t3chk (): void = (
  try the_trans3errlst_finalize () with | ~$ERR.PATSOPT_TRANS3_EXN () => dd_ps "[trans3 errors]\n"
)
//
fun mkdq1 (k: int): d0ynq = d0ynq_symdot (mki0de (k), token_make (mkloc (k), DOT))
//
fun t_listmap (loc0: location, ctx: !evalctx, env: &alphenv, xs: d2explst): d2explst =
  eval1_listmap<d2exp> (loc0, ctx, env, xs, eval1_d2exp)
//
fun mki0nt_rep (loc: location, rep: string): i0nt = token_make (loc, token_node_T_INT (10, rep, 0u))
//
%{^
#include <stdlib.h>
static int m2_exit_arg () { char *s = getenv ("M2EXIT"); return s ? atoi (s) : 0 ; }
%}
extern fun m2_exit_arg (): int = "mac#m2_exit_arg"
