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
** Start time: June, 2016
*)

(* ****** ****** *)
//
#define
ATS_PACKNAME
"PATSOLVE_SMT2_SOLVING"
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
"{$PATSOLVE}/SATS/patsolve_cnstrnt.sats"
#staload
"{$PATSOLVE}/SATS/patsolve_parsing.sats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// The constraints and the formulas are kept in an
// arena (see ATS-extsolve); every function that looks into
// them takes the arena borrowed (ar: !arena(l)).
//
(* ****** ****** *)
//
fun
c3nstr_smt2_solve{l:addr}
(
  ar: !arena(l), tbls: ptables(l), out: FILEref, c3t0: c3nstr(l)
) : void // end-of-function
//
(* ****** ****** *)
//
#include "./patsolve_smt2_solving_gen.hats"
//
typedef formlst(l:addr) = alist(l, form(l))
//
(* ****** ****** *)
//
fun
fprint_form{l:addr}
  (ar: !arena(l), out: FILEref, x: form(l)): void
//
(* ****** ****** *)
//
fun
formula_null{l:addr}(ar: !arena(l)): form(l)
fun
formula_true{l:addr}(ar: !arena(l)): form(l)
fun
formula_false{l:addr}(ar: !arena(l)): form(l)
//
fun
formula_int{l:addr}(ar: !arena(l), i: int): form(l)
fun
formula_intrep{l:addr}(ar: !arena(l), rep: astring(l)): form(l)
//
fun
formula_not{l:addr}(ar: !arena(l), x: form(l)): form(l)
//
fun
formula_conj_list{l:addr}
  (ar: !arena(l), xs: formlst(l)): form(l)
fun
formula_conj_list1{l:addr}
  (ar: !arena(l), xs: formlst(l), x: form(l)): form(l)
fun
formula_impl_list1{l:addr}
  (ar: !arena(l), xs: formlst(l), x: form(l)): form(l)
//
(* ****** ****** *)
//
datavtype
solvercmd(l:addr) =
//
| SOLVERCMDpop of ()
| SOLVERCMDpush of ()
//
| SOLVERCMDassert of (form(l))
//
| SOLVERCMDchecksat of ()
//
| SOLVERCMDecholoc of (loc_t(l))
//
| SOLVERCMDpopenv of (s2varlst(l))
| SOLVERCMDpushenv of ((*void*))
//
| SOLVERCMDpopenv2 of ((*void*))
| SOLVERCMDpushenv2 of (s2varlst(l))
//
// end of [solvercmd]
//
vtypedef
solvercmdlst(l:addr) = List0_vt(solvercmd(l))
//
(* ****** ****** *)
//
fun
fprint_solvercmd{l:addr}
  (ar: !arena(l), out: FILEref, x: !solvercmd(l)): void
//
(* ****** ****** *)
//
// HX:
// popenv/pushenv pairs are turned into
// pushenv2/popenv2 pairs while the list is reversed
//
fun
solvercmdlst_reverse
  {l:addr}(xs: solvercmdlst(l)): solvercmdlst(l)
//
(* ****** ****** *)
//
absvtype
smtenv_vtype(l:addr) = ptr
vtypedef
smtenv(l:addr) = smtenv_vtype(l)
//
(* ****** ****** *)
//
fun
smtenv_create{l:addr}(): smtenv(l)
//
fun
smtenv_destroy
  {l:addr}(env: smtenv(l)): solvercmdlst(l)
//
(* ****** ****** *)
//
fun
smtenv_add_s2var{l:addr}
  (ar: !arena(l), env: !smtenv(l), s2v: s2var(l)): void
fun
smtenv_add_s2exp{l:addr}
  (ar: !arena(l), env: !smtenv(l), s2e: s2exp(l)): void
fun
smtenv_add_h3ypo{l:addr}
  (ar: !arena(l), env: !smtenv(l), h3p: h3ypo(l)): void
//
(* ****** ****** *)
//
fun
formula_make_s2cst{l:addr}
  (ar: !arena(l), env: !smtenv(l), s2c: s2cst(l)): form(l)
fun
formula_make_s2var{l:addr}
  (ar: !arena(l), env: !smtenv(l), s2v: s2var(l)): form(l)
fun
formula_make_s2exp{l:addr}
  (ar: !arena(l), env: !smtenv(l), s2e: s2exp(l)): form(l)
//
(* ****** ****** *)
//
// HX: whether [s2c] is interpreted by the preamble
//
fun
s2cst_is_builtin
  {l:addr}(ar: !arena(l), s2c: s2cst(l)): bool
//
(* ****** ****** *)
//
absview smtenv_push_v
//
fun
smtenv_pop{l:addr}
  (pf: smtenv_push_v | ar: !arena(l), env: !smtenv(l)): void
//
fun
smtenv_push{l:addr}(env: !smtenv(l)): (smtenv_push_v | void)
//
(* ****** ****** *)
//
fun
smtenv_solve_formula{l:addr}
(
  ar: !arena(l), env: !smtenv(l), loc0: loc_t(l), fml: form(l)
) : void // end-of-function
//
(* ****** ****** *)
//
fun
emit_form{l:addr}
  (ar: !arena(l), out: FILEref, fml: form(l)): void
//
fun
emit_s2rt{l:addr}
  (ar: !arena(l), out: FILEref, s2t: s2rt(l)): void
fun
emit_s2rtlst{l:addr}
  (ar: !arena(l), out: FILEref, s2ts: s2rtlst(l)): void
//
fun
emit_s2cst{l:addr}
  (ar: !arena(l), out: FILEref, s2c: s2cst(l)): void
fun
emit_s2var{l:addr}
  (ar: !arena(l), out: FILEref, s2v: s2var(l)): void
//
fun
emit_s2exp{l:addr}
  (ar: !arena(l), out: FILEref, s2e: s2exp(l)): void
//
fun
emit_decl_s2cst{l:addr}
  (ar: !arena(l), out: FILEref, s2c: s2cst(l)): void
fun
emit_decl_s2var{l:addr}
  (ar: !arena(l), out: FILEref, s2v: s2var(l)): void
fun
emit_decl_s2varlst{l:addr}
  (ar: !arena(l), out: FILEref, s2vs: s2varlst(l)): void
//
// HX: the commands are consumed
//
fun
emit_solvercmd{l:addr}
  (ar: !arena(l), out: FILEref, cmd: solvercmd(l)): void
fun
emit_solvercmdlst{l:addr}
  (ar: !arena(l), out: FILEref, cmds: solvercmdlst(l)): void
//
(* ****** ****** *)
//
fun emit_preamble(FILEref): void
fun emit_preamble_real(FILEref): void
//
fun
emit_the_s2cstmap{l:addr}
  (ar: !arena(l), tbls: ptables(l), out: FILEref): void
//
(* ****** ****** *)

(* end of [patsolve_smt2_solving.sats] *)
