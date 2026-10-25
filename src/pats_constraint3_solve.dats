(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
**
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
**
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: February, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3_solve.dats, see PORTING.md, "Constraint solving (constraint3)")
// The kind of the integers of the solver (C3NSTRINTKND of pats_params.hats, or -DATS C3NSTRINTKND=intknd) is chosen
// by [pats_lintprgm_myint.dats], which is #include-d below (LP-1); this module staloads the templates and is dynloaded.
//
(* ****** ****** *)
//
#include "./pats_params.hats"
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> () = prerr "pats_constraint3_solve"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_patcst2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

staload "./pats_lintprgm.sats"
//
// HX: staloading a .dats opens the names of the .sats that it staloads, hence
// the order: the [s3exp] of pats_constraint3.sats must be the last one defined
//
staload _(*anon*) = "./pats_lintprgm.dats"
staload _(*anon*) = "./pats_lintprgm_print.dats"
//
#include "./pats_lintprgm_myint.dats"
//
// HX: [pats_lintprgm_solve.dats] is #include-d (its templates use functions that are
// local to it, and its indexset_* functions are defined in the object of this module)
//
#include "./pats_lintprgm_solve.dats"
//
(* ****** ****** *)

staload "./pats_constraint3.sats"
staload _(*anon*) = "./pats_constraint3_icnstr.dats"

(* ****** ****** *)

#include "./pats_constraint3.hats"

(* ****** ****** *)

local

fun{
a:t@ype
} indexset_make_s3exp
  {n:nat} (
  vim: !s2varindmap (n), s3e: s3exp
) : indexset (n+1) = let
  typedef res = indexset (n+1)
  vtypedef map = s2varindmap (n)
  fun loop (
    s2vs: s2varlst_vt, vim: !map, res: res
  ) : res =
    case+ s2vs of
    | ~list_vt_cons
        (s2v, s2vs) => let
        val ind = s2varindmap_find (vim, s2v)
        val res = (
          if ind > 0 then indexset_add{n+1} (res, ind) else res
        ) : res // end of [val]
      in
        loop (s2vs, vim, res)
      end // end of [list_vt_cons]
    | ~list_vt_nil () => res
  // end of [loop]
  val s2vs = s3exp_get_fvs (s3e)
  val s2vs = s2varset_vt_listize_free (s2vs)
in
  loop (s2vs, vim, indexset_nil{n+1} ())
end // end of [indexset_make_s3exp]

(* ****** ****** *)

fun{
a:t@ype
} auxsolve{n:nat}
(
  loc0: location
, vim: !s2varindmap (n), n: int n
, s3ps_asmp: !s3explst_vt, s3p_conc: s3exp
) : int(*~1/0*) = let
//
// HX: note that the order is reversed:
//
val
ics_asmp = let
//
vtypedef res = icnstrlst (a, n+1)
//
fun
loop
(
  loc0: location
, vim: !s2varindmap (n), n: int n, s3ps: !s3explst_vt
, res: res
) : res = let
in
  case+ s3ps of
  | @list_vt_nil
      ((*void*)) => (fold@ (s3ps); res)
  | @list_vt_cons
      (s3p, s3ps1) => let
      val ic =
        s3exp2icnstr<a> (loc0, vim, n, s3p)
      // end ofl[val]
      val res = loop (loc0, vim, n, s3ps1, list_vt_cons (ic, res))
    in
      fold@ (s3ps); res
    end // end of [list_cons]
end // end of [loop]
//
in
  loop (loc0, vim, n, s3ps_asmp, list_vt_nil)
end // end of [val]
//
val ic_conc =
  s3exp2icnstr<a> (loc0, vim, n, s3p_conc)
//
val ic_conc_neg = icnstr_negate<a> (ic_conc)
//
val iset = indexset_make_s3exp<a> (vim, s3p_conc)
//
// HX: this is the entire constraint matrix
var ics_all
  : icnstrlst (a, n+1) = list_vt_cons (ic_conc_neg, ics_asmp)
//
val ans =
  icnstrlst_solve<a> (iset, ics_all, n+1)
val () = icnstrlst_free<a> (ics_all, n+1)
//
in
//
ans // ~1: contradiction reached; 0: undecided yet
//
end // end of [auxsolve]

in (* in of [local] *)

implement
s3explst_solve_s2exp
  (loc0, env, s2p, err) = let
//
val s3p = s3exp_make (env, s2p)
val s3p =
(
  if s3exp_is_S3Eerr (s3p) then let
      val () = prerr_warning3_loc (loc0)
      val () = prerr ": the constraint ["
      val () = pprerr_s2exp (s2p)
      val () = prerr "] cannot be translated into a form accepted by the constraint solver."
      val () = prerr_newline ()
    in
      s3exp_false // HX: make it the worst scenario
    end // end of [S3Eerr]
  else s3p // end of [_]
) : s3exp // end of [val]
//
var status: int = 0
val () = (
  case+ s3exp_view (s3p) of
  | ~S3Ebool (b) => if b then status := ~1
  | v => s3exp_view_free (v)
) // end of [val]
//
val () = if status >= 0 then {
val s3p_conc =
  s3exp_lintize (env, s3p) // HX: processed for being turned into a vector
//
val @(s2vs, s3ps_asmp) = s2vbcfenv_extract (env)
//
val @(vim, n) = s2varindmap_make (s2vs)
//
// HX: [C3NSTRINTKND] defined in [pats_params.hats]
//
#if C3NSTRINTKND="intknd" #then
val ans = auxsolve<intknd> (loc0, vim, n, s3ps_asmp, s3p_conc)
#elif C3NSTRINTKND="gmpknd" #then
val ans = auxsolve<gmpknd> (loc0, vim, n, s3ps_asmp, s3p_conc)
#else
val () = assertloc (false)
val ans = 0 // HX: it is never executed at run-time
#endif // end of [#if]
//
val () = status := ans
//
val () = s2varindmap_free (vim)
val () = list_vt_free (s2vs)
and () = list_vt_free (s3ps_asmp)
//
} (* end of [status >= 0] *)
//
in
  status(*~1/0*)
end // end of [s3explst_solve_s2exp]

end // end of [local]

(* ****** ****** *)
//
// HX-2012-03:
// for errmsg reporting; the function returns 0
// normally; if it returns 1, then the reported
// error should be treated as a warning instead.
//
extern
fun
c3nstr_solve_errmsg(c3t: c3nstr, unsolved: uint): int
//
(* ****** ****** *)

extern
fun
c3nstr_solve_main
(
  env: &s2vbcfenv, c3t: c3nstr, unsolved: &uint, err: &int
) : int(*status*)
// end of [c3nstr_solve_main]

extern
fun
c3nstr_solve_prop
(
  loc0: location, env: &s2vbcfenv, s2p: s2exp, err: &int
) : int(*status*)
// end of [c3nstr_solve_prop]

extern
fun
c3nstr_solve_itmlst
(
  loc0: location
, env: &s2vbcfenv
, s3is: s3itmlst, unsolved: &uint, err: &int
) : int(*status*) // end of [c3nstr_solve_itmlst]

extern
fun
c3nstr_solve_itmlst_cnstr
(
  loc0: location
, env: &s2vbcfenv
, s3is: s3itmlst, c3t: c3nstr, unsolved: &uint, err: &int
) : int(*status*) // end of [c3nstr_solve_itmlst_cnstr]

extern
fun
c3nstr_solve_itmlst_disj
(
  loc0: location
, env: &s2vbcfenv
, s3is: s3itmlst, s3iss: s3itmlstlst, unsolved: &uint, err: &int
) : int(*status*) // end of [c3nstr_solve_itmlst_disj]

extern
fun
c3nstr_solve_solverify
(
  loc0: location, env: &s2vbcfenv, s2e_prop: s2exp, err: &int
) : int(*status*)
// end of [c3nstr_solve_solverify]

(* ****** ****** *)

extern
fun
prerr_case_exhaustiveness_errmsg
(
  loc0: location, casknd: caskind, p2tcs: p2atcstlst
) : void // end of [prerr_case_exhaustiveness_errmsg]
implement
prerr_case_exhaustiveness_errmsg
  (loc0, casknd, p2tcs) = let
//
fun prlst (
  p2tcs: p2atcstlst
) : void = let
in
  if glist_is_cons (p2tcs) then let
      val () =
        fprint_p2atcst (stderr_ref, glist_head<p2atcst> (p2tcs))
      // end of [val]
      val () = fprint_newline (stderr_ref)
    in
      prlst (glist_tail<p2atcst> (p2tcs))
    end // end of [list_cons]
  else ()
end // end of [prlst]
//
in
//
case+ casknd of
//
| CK_case_pos () => let
    val () = prerr_error3_loc (loc0)
    val () = prerr ": pattern match is nonexhaustive:\n";
  in
    prlst (p2tcs)
  end // end of [CK_case]
| CK_case_neg () => () // HX: ignored per the wish of the programmer
//
// HX: this case is *not* recommended for use
//
| CK_case () => let
    val () = prerr_warning3_loc (loc0)
    val () = prerr ": pattern match is nonexhaustive:\n";
  in
    prlst (p2tcs)
  end // end of [CK_case]
//
end // end of [prerr_case_exhaustiveness_errmsg]

(* ****** ****** *)

implement
c3nstr_solve_errmsg
  (c3t, unsolved) = let
//
val loc0 = c3t.c3nstr_loc ()
val c3tk = c3t.c3nstr_kind ()
//
fun
prerr_c3nstr_if
(
  unsolved: uint, c3t: c3nstr
) : void =
  if (unsolved = 0u) then (prerr ": "; prerr_c3nstr c3t)
// end of [prerr_c3nstr_if]
//
in
//
case+ c3nstrkind_view (c3tk) of
| ~C3TKmain((*void*)) =>
  (
    if unsolved = 0u
      then let
        val () =
        prerr_error3_loc (loc0)
        val () = prerr ": unsolved constraint: "
        val () = prerr_c3nstr (c3t)
        val () = prerr_newline ()
      in
        0 // this one is treated as an error
      end // end of [then]
      else 0 // this errmsg has already been reported
    // end of [if]
  ) (* end of [C3STRKmain] *)
| ~C3TKcase_exhaustiveness
    (casknd, p2tcs) => let
    val () =
    prerr_case_exhaustiveness_errmsg (loc0, casknd, p2tcs)
  in
    case+ casknd of
    | CK_case () => 1 (*warning*)
    | CK_case_pos () => 0 (*error*)
    | CK_case_neg () => 0 (*deadcode*)
  end // end of [C3TKcase_exhaustiveness]
//
| ~C3TKtermet_isnat
    () => 0 where {
    val () =
    prerr_error3_loc (loc0)
    val () = prerr
    (
      ": unsolved constraint for termetric being well-founded"
    ) (* end of [val] *)
    val () =
    prerr_c3nstr_if (unsolved, c3t)
    val () = prerr_newline ((*void*))
  } // end of [C3TKtermet_isnat]
| ~C3TKtermet_isdec
    () => 0 where {
    val () = prerr_error3_loc (loc0)
    val () = prerr
    (
      ": unsolved constraint for termetric being strictly decreasing"
    ) (* end of [val] *)
    val () =
    prerr_c3nstr_if (unsolved, c3t)
    val () = prerr_newline ((*void*))
  } // end of [C3STRKmetric_dec]
//
| ~C3TKsome_fin _ =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val ((*void*)) = (
      prerr ": unsolved constraint for var preservation"; prerr_newline ()
    )
  } (* end of [C3TKsome_fin] *)
| ~C3TKsome_lvar _ =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val ((*void*)) = (
      prerr ": unsolved constraint for lvar preservation"; prerr_newline ()
    )
  } (* end of [C3TKsome_lvar] *)
| ~C3TKsome_vbox _ =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val ((*void*)) = (
      prerr ": unsolved constraint for vbox preservation"; prerr_newline ()
    )
  } (* end of [C3TKsome_vbox] *)
//
| ~C3TKlstate
    () => 0 where {
    val () =
    prerr_error3_loc (loc0)
    val () = (
      prerr ": unsolved constraint for lstate merging"; prerr_newline ()
    )
  } // end of [C3TKlstate]
| ~C3TKlstate_var
    (d2v) => 0 where {
    val () =
    prerr_error3_loc (loc0)
    val () = prerr ": unsolved constraint for merging the lstate of ["
    val () = prerr_d2var (d2v)
    val () = prerr "]"
    val () = prerr_newline ()
  } // end of [C3TKlstate_var]
//
| ~C3TKloop(knd) =>
    (0) where {
    val () =
    prerr_error3_loc (loc0)
    val () =
    if knd < 0 then prerr ": unsolved constraint for loop(enter)"
    val () =
    if knd = 0 then prerr ": unsolved constraint for loop(break)"
    val () =
    if knd > 0 then prerr ": unsolved constraint for loop(continue)"
    val () = prerr_newline ((*void*))
  } (* end of [C3TKloop] *)
//
| ~C3TKsolverify() =>
    (0) where {
    val () =
    prerr_error3_loc (loc0)
    val () = (
      prerr ": the constraint is expected to be verified externally."; prerr_newline ()
    )
  } (* end of [C3TKsolver] *)
//
end // end of [c3nstr_solve_errmsg]

(* ****** ****** *)

implement
c3nstr_solve_main
(
  env, c3t, unsolved, err
) = let
//
val loc0 = c3t.c3nstr_loc ()
//
var
status: int = (
//
// ~1: solved; 0: unsolved
//
case+
c3nstr_node_view (c3t.c3nstr_node ())
of // case+
| ~C3NSTRprop s2p =>
    c3nstr_solve_prop (loc0, env, s2p, err)
  // end of [C3NSTRprop]
| ~C3NSTRitmlst(s3is) =>
    c3nstr_solve_itmlst (loc0, env, s3is, unsolved, err)
  // end of [C3NSTRitmlst]
//
| ~C3NSTRsolverify(s2e_prop) =>
    c3nstr_solve_solverify (loc0, env, s2e_prop, err)
//
) : int // end of [val]
//
val () =
if
status >= 0
then
{
  val iswarn =
    c3nstr_solve_errmsg(c3t, unsolved)
  // end of [val]
  val () = if iswarn > 0 then (status := ~1)
} (* end of [if] *)
//
val () =
  if status >= 0 then (unsolved := unsolved + 1u)
//
in
  status (* 0: unsolved; ~1: solved *)
end // end of [c3nstr_solve_main]

(* ****** ****** *)

implement
c3nstr_solve_prop
  (loc0, env, s2p, err) = (
  s3explst_solve_s2exp (loc0, env, s2p, err)
) // end of [c3nstr_solve_prop]

(* ****** ****** *)

implement
c3nstr_solve_itmlst
(
  loc0, env, s3is, unsolved, err
) = let
in
//
if glist_is_cons (s3is) then let
  val s3i = glist_head<s3itm> (s3is)
  val s3is = glist_tail<s3itm> (s3is)
in
  case+ s3itm_view (s3i) of
  | ~S3ITMsvar(s2v) => let
      val () = s2vbcfenv_add_svar (env, s2v)
    in
      c3nstr_solve_itmlst(loc0, env, s3is, unsolved, err)
    end // end of [S3ITMsvar]
  | ~S3ITMhypo(h3p) => let
      val s3p = s3exp_make_h3ypo (env, h3p)
      val () = (
        if s3exp_is_S3Eerr (s3p) then () // nothing
        else let
            val s3p = s3exp_lintize(env, s3p) in s2vbcfenv_add_sbexp (env, s3p)
          end // end of [_]
      ) : void // end of [val]
    in
      c3nstr_solve_itmlst(loc0, env, s3is, unsolved, err)
    end // end of [S3ITMhypo]
  | ~S3ITMsVar(s2V) =>
      c3nstr_solve_itmlst(loc0, env, s3is, unsolved, err)
  | ~S3ITMcnstr(c3t) =>
      c3nstr_solve_itmlst_cnstr(loc0, env, s3is, c3t, unsolved, err)
  | ~S3ITMcnstr_ref(ctr) => (
      case+ gopt_view (ctr.c3nstroptref_val ()) of
      | ~GOnone () => ~1(*solved*)
      | ~GOsome c3t =>
          c3nstr_solve_itmlst_cnstr(loc0, env, s3is, c3t, unsolved, err)
        // end of [Some]
    ) // end of [S3ITMcnstr_ref]
  | ~S3ITMdisj(s3iss_disj) =>
      c3nstr_solve_itmlst_disj(loc0, env, s3is, s3iss_disj, unsolved, err)
//
  | ~S3ITMsolassert(s2e_prop) =>
      c3nstr_solve_itmlst(loc0, env, s3is, unsolved, err)
//
end else ~1 (*list_nil*)
//
end // end of [c3nstr_solve_itmlst]

(* ****** ****** *)

implement
c3nstr_solve_itmlst_cnstr
(
  loc0, env, s3is, c3t, unsolved, err
) = let
  val () = s2vbcfenv_push (env)
  val () = the_s2varbindmap_push ()
  val ans1 =
    c3nstr_solve_main (env, c3t, unsolved, err)
  // end of [val]
  val () = the_s2varbindmap_pop ()
  val () = s2vbcfenv_pop (env)
  val ans2 =
    c3nstr_solve_itmlst (loc0, env, s3is, unsolved, err)
  // end of [val]
in
  if ans1 >= 0 then 0(*unsolved*) else ans2
end // end of [c3nstr_solve_itmlst_cnstr]

(* ****** ****** *)

implement
c3nstr_solve_itmlst_disj
(
  loc0, env, s3is0, s3iss(*disj*), unsolved, err
) = let
in
//
if glist_is_cons (s3iss) then let
    val s3is = glist_head<s3itmlst> (s3iss)
    val s3iss = glist_tail<s3itmlst> (s3iss)
    val () = s2vbcfenv_push (env)
    val () = the_s2varbindmap_push ()
    val s3is1 = glist_append<s3itm> (s3is, s3is0)
    val _(*ans*) = c3nstr_solve_itmlst (loc0, env, s3is1, unsolved, err)
    val ((*void*)) = the_s2varbindmap_pop ()
    val ((*void*)) = s2vbcfenv_pop (env)
  in
    c3nstr_solve_itmlst_disj (loc0, env, s3is0, s3iss, unsolved, err)
  end // end of [list_cons]
else ~1(*solved*) // end of [list_nil]
//
end // end of [c3nstr_solve_itmlst_disj]

(* ****** ****** *)

implement
c3nstr_solve_solverify
  (loc0, env, s2e_prop, err) = 0(*unsolved*)
// end of [c3nstr_solve_solverify]

(* ****** ****** *)

implement
c3nstr_ats2_solve (c3t) = let
//
var env: s2vbcfenv = s2vbcfenv_nil ()
//
// HX-2010-09-09: this is needed for solving
val () = the_s2varbindmap_freetop () // top-level constraints!!!
//
var
unsolved: uint = 0u
var err: int = 0
val _(*status*) = c3nstr_solve_main (env, c3t, unsolved, err)
val ((*freed*)) = s2vbcfenv_free (env)
//
in
//
if unsolved = 0u then () // nothing
else let (* unsolved > 0 *)
    val () = prerr "typechecking has failed"
    val () =
    if unsolved <= 1u
      then prerr ": there is one unsolved constraint"
    // end of [if]
    val () =
    if unsolved >= 2u
      then prerr ": there are some unsolved constraints"
    // end of [if]
    val () = prerr ": please inspect the above reported error message(s) for information."
    val () = prerr_newline ()
  in
    $ERR.abort<void>()
  end (* end of [_ when unsolved > 0] *)
//
end // end of [c3nstr_ats2_solve]

(* ****** ****** *)

(* end of [pats_constraint3_solve.dats] *)
