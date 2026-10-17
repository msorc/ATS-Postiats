(* ATS1 part of the macro test that is not generated (m2_gen.py): the language specific helpers, before m2common.hats *)
(* ****** ****** *)
//
fun dd_m2val (x: m2val): void = (
  case+ x of
  | M2Vint (i) => (dd_ps "M2Vint("; dd_int i; dd_ps ")")
  | M2Vbool (b) => (dd_ps "M2Vbool("; dd_bool b; dd_ps ")")
  | M2Vchar (c) => (dd_ps "M2Vchar("; dd_char c; dd_ps ")")
  | M2Vfloat (s) => (dd_ps "M2Vfloat("; dd_string s; dd_ps ")")
  | M2Vstring (s) => (dd_ps "M2Vstring("; dd_string s; dd_ps ")")
  | M2Vunit () => dd_ps "M2Vunit()"
  | M2Vscode (e) => (dd_ps "M2Vscode("; dd_s2exp e; dd_ps ")")
  | M2Vdcode (e) => (dd_ps "M2Vdcode("; dd_d2exp e; dd_ps ")")
  | M2Vlist (xs) => (dd_ps "M2Vlist["; dd_m2valist xs; dd_ps "]")
  | M2Verr () => dd_ps "M2Verr()"
) and dd_m2valist (xs: m2valist): void = let
  fun loop (xs: m2valist, i: int): void =
    case+ xs of
    | list_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_m2val x; loop (xs, i+1))
    | list_nil () => ()
in
  loop (xs, 0)
end
//
fun K_M2Vint (i: int): m2val = M2Vint (i)
fun K_M2Vbool (b: bool): m2val = M2Vbool (b)
fun K_M2Vchar (c: char): m2val = M2Vchar (c)
fun K_M2Vfloat (s: string): m2val = M2Vfloat (s)
fun K_M2Vstring (s: string): m2val = M2Vstring (s)
fun K_M2Vunit (): m2val = M2Vunit ()
fun K_M2Vscode (e: s2exp): m2val = M2Vscode (e)
fun K_M2Vdcode (e: d2exp): m2val = M2Vdcode (e)
fun K_M2Vlist (xs: m2valist): m2val = M2Vlist (xs)
fun K_M2Verr (): m2val = M2Verr ()
fun LN_m2valist (): m2valist = list_nil ()
fun LC_m2valist (x: m2val, xs: m2valist): m2valist = list_cons (x, xs)
//
fun t3chk (): void = (
  try the_trans3errlst_finalize () with ~($ERR.PATSOPT_TRANS3_EXN ()) => dd_ps "[trans3 errors]\n"
)
//
fun mkdq1 (k: int): d0ynq = d0ynq_symdot (mki0de (k), token_make (mkloc (k), T_DOT))
//
fun t_listmap (loc0: location, ctx: !evalctx, env: &alphenv, xs: d2explst): d2explst =
  eval1_listmap {d2exp} (loc0, ctx, env, xs, eval1_d2exp)
//
fun mki0nt_rep (loc: location, rep: string): i0nt = token_make (loc, T_INT (10, rep, 0u))
//
%{^
#include <stdlib.h>
static int m2_exit_arg () { char *s = getenv ("M2EXIT"); return s ? atoi (s) : 0 ; }
%}
extern fun m2_exit_arg (): int = "mac#m2_exit_arg"
