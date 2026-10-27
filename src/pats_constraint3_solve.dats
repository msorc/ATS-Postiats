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

staload LOC = "./pats_location.sats"
staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload GLOB = "./pats_global.sats"
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> () = prerr "pats_constraint3_solve"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_sprint.sats"
staload "./pats_staexp2_util.sats"
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
// HX-2026-10: the text of ATS1 (the_LEGACYERRORS_get () > 0)
//
extern
fun
c3nstr_solve_errmsg_legacy(c3t: c3nstr, unsolved: uint): int
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

(* ****** ****** *)
//
// HX-2026-10: the hypotheses of the constraint being solved (the
// [S3ITMsvar] and [S3ITMhypo] items in scope, the newest first), kept
// by [c3nstr_solve_itmlst] for the error messages
//
%{^
static void *patsopt_c3nstr_hypctx = 0 ;
ATSinline()
atstype_ptr
patsopt_c3nstr_hypctx_get () { return patsopt_c3nstr_hypctx ; }
ATSinline()
atsvoid_t0ype
patsopt_c3nstr_hypctx_set
  (atstype_ptr x) { patsopt_c3nstr_hypctx = x ; return ; }
%}
//
extern
fun hypctx_get (): glist(s3itm) = "mac#patsopt_c3nstr_hypctx_get"
extern
fun hypctx_set (x: glist(s3itm)): void = "mac#patsopt_c3nstr_hypctx_set"
//
fn hypctx_push (s3i: s3itm): void =
  hypctx_set (glist_cons<s3itm> (s3i, hypctx_get ()))
//
(* ****** ****** *)

local

#define MAXHYPO 12

fn s2var_eq
  (x: s2var, y: s2var): bool = ($UN.cast{ptr} (x) = $UN.cast{ptr} (y))

fn svars_mem
  (xs: glist(s2var), x: s2var): bool = let
  fun loop (xs: glist(s2var)): bool =
    case+ glist_view (xs) of
    | ~GLnil () => false
    | ~GLcons (y, xs) => if s2var_eq (x, y) then true else loop (xs)
in
  loop (xs)
end // end of [svars_mem]

fn svars_add
  (xs: glist(s2var), x: s2var): glist(s2var) =
  if svars_mem (xs, x) then xs else glist_cons<s2var> (x, xs)

(*
** the elements of [ys] (oldest first) that are not in [xs] (newest first)
** are added to it
*)
fun svars_union
  (xs: glist(s2var), ys: glist(s2var)): glist(s2var) =
  case+ glist_view (ys) of
  | ~GLnil () => xs
  | ~GLcons (y, ys) => svars_union (svars_add (xs, y), ys)

fun svars_meet
  (xs: glist(s2var), ys: glist(s2var)): bool =
  case+ glist_view (ys) of
  | ~GLnil () => false
  | ~GLcons (y, ys) => if svars_mem (xs, y) then true else svars_meet (xs, ys)

(* the variables of [h3p] (oldest first) *)
fn h3ypo_svars
  (h3p: h3ypo): glist(s2var) = let
  val res =
  (
    case+ h3ypo_node_view (h3p.h3ypo_node ()) of
    | ~H3YPOprop (s2p) => s2exp_sprint_svars (s2p, glist_nil ())
    | ~H3YPObind (s2v, s2e) => s2exp_sprint_svars (s2e, glist_sing<s2var> (s2v))
    | ~H3YPOeqeq (s2e1, s2e2) =>
        s2exp_sprint_svars (s2e2, s2exp_sprint_svars (s2e1, glist_nil ()))
  ) : glist(s2var)
in
  glist_reverse<s2var> (res)
end // end of [h3ypo_svars]

(* the hypotheses in scope, oldest first *)
fn hypctx_hypos (): glist(h3ypo) = let
  fun loop (xs: glist(s3itm), res: glist(h3ypo)): glist(h3ypo) =
    case+ glist_view (xs) of
    | ~GLnil () => res
    | ~GLcons (x, xs) => (
        case+ s3itm_view (x) of
        | ~S3ITMhypo (h3p) => loop (xs, glist_cons<h3ypo> (h3p, res))
        | v => (s3itm_view_free (v); loop (xs, res))
      ) // end of [GLcons]
in
  loop (hypctx_get (), glist_nil ())
end // end of [hypctx_hypos]

(*
** one step of the closure over the bindings: [v == e] with [v] relevant
** makes the variables of [e] relevant
*)
fun close_step
  (hs: glist(h3ypo), rel: glist(s2var), changed: &bool): glist(s2var) =
  case+ glist_view (hs) of
  | ~GLnil () => rel
  | ~GLcons (h3p, hs) => let
      val rel = (
        case+ h3ypo_node_view (h3p.h3ypo_node ()) of
        | ~H3YPObind (s2v, s2e) =>
            if svars_mem (rel, s2v) then let
              val ys = s2exp_sprint_svars (s2e, glist_nil ())
              val ys = glist_reverse<s2var> (ys)
              val () = if ~(svars_meet_all (rel, ys)) then changed := true
            in
              svars_union (rel, ys)
            end else rel
        | v => (h3ypo_node_view_free (v); rel)
      ) : glist(s2var)
    in
      close_step (hs, rel, changed)
    end // end of [GLcons]

(* all the elements of [ys] are in [xs] *)
and svars_meet_all
  (xs: glist(s2var), ys: glist(s2var)): bool =
  case+ glist_view (ys) of
  | ~GLnil () => true
  | ~GLcons (y, ys) =>
      if svars_mem (xs, y) then svars_meet_all (xs, ys) else false

fun close_loop
  (hs: glist(h3ypo), rel: glist(s2var), n: int): glist(s2var) =
  if n <= 0 then rel else let
    var changed: bool = false
    val rel = close_step (hs, rel, changed)
  in
    if changed then close_loop (hs, rel, n-1) else rel
  end // end of [close_loop]

fun select
  (hs: glist(h3ypo), rel: glist(s2var), res: glist(h3ypo)): glist(h3ypo) =
  case+ glist_view (hs) of
  | ~GLnil () => glist_reverse<h3ypo> (res)
  | ~GLcons (h3p, hs) =>
      if svars_meet (rel, h3ypo_svars (h3p))
        then select (hs, rel, glist_cons<h3ypo> (h3p, res))
        else select (hs, rel, res)

fn prerr_h3ypo_s
  (h3p: h3ypo): void =
  case+ h3ypo_node_view (h3p.h3ypo_node ()) of
  | ~H3YPOprop (s2p) => prerr_s2exp_s (s2p)
  | ~H3YPObind (s2v, s2e) => (
      prerr_s2var_s (s2v); prerr " == "; fsprint_s2exp_ctx (stderr_ref, s2e, 31)
    ) // end of [H3YPObind]
  | ~H3YPOeqeq (s2e1, s2e2) => (
      fsprint_s2exp_ctx (stderr_ref, s2e1, 31); prerr " == ";
      fsprint_s2exp_ctx (stderr_ref, s2e2, 31)
    ) // end of [H3YPOeqeq]

(*
** the variables printed so far that are in [fvs], added to [res] in the
** order of their first occurrence
*)
fun seen_filter
  (xs: List0_vt(s2var), fvs: glist(s2var), res: glist(s2var)): glist(s2var) =
  case+ xs of
  | ~list_vt_cons (x, xs) =>
      if svars_mem (fvs, x)
        then seen_filter (xs, fvs, svars_add (res, x))
        else seen_filter (xs, fvs, res)
  | ~list_vt_nil () => res

in (* in-of-local *)

(*
** HX-2026-10: the lines [  where n: int] and [  assuming: n >= 0, ...]
** after an unsolved [s2p]: the variables of [s2p] (closed over the
** bindings of the hypotheses) and the hypotheses that mention them
*)
fn prerr_c3nstr_where
  (s2p: s2exp): void = let
//
val fvs = glist_reverse<s2var> (s2exp_sprint_svars (s2p, glist_nil ()))
val rel = seen_filter (sprint_s2vars_seen (), fvs, glist_nil ())
val rel = svars_union (rel, fvs)
val hs = hypctx_hypos ()
val rel = close_loop (hs, rel, 8)
val sel = select (hs, rel, glist_nil ())
//
fun allvars (hs: glist(h3ypo), res: glist(s2var)): glist(s2var) =
  case+ glist_view (hs) of
  | ~GLnil () => res
  | ~GLcons (h3p, hs) => allvars (hs, svars_union (res, h3ypo_svars (h3p)))
//
fun prvars (xs: glist(s2var), i: int): void =
  case+ glist_view (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs) => let
      val () = if i > 0 then prerr ", "
      val () = prerr_s2var_s (x)
      val () = prerr ": "
      val () = prerr_s2rt_s (s2var_get_srt (x))
    in
      prvars (xs, i+1)
    end // end of [GLcons]
//
fun prhypos (hs: glist(h3ypo), i: int): void =
  case+ glist_view (hs) of
  | ~GLnil () => ()
  | ~GLcons (h3p, hs) =>
      if i >= MAXHYPO then prerr ", ..." else let
        val () = if i > 0 then prerr ", "
        val () = prerr_h3ypo_s (h3p)
      in
        prhypos (hs, i+1)
      end // end of [if]
//
(* the sets are kept the newest first: they are reversed for printing *)
val ws = allvars (sel, rel)
//
in
//
if glist_is_cons (ws) then (
  prerr "  where "; prvars (glist_reverse<s2var> (ws), 0); prerr_newline ()
);
if glist_is_cons (sel) then (
  prerr "  assuming: "; prhypos (sel, 0); prerr_newline ()
)
//
end // end of [prerr_c3nstr_where]

end // end of [local]

(*
** HX-2026-10: [pre] and the unsolved proposition of [c3t], then its
** variables and hypotheses
*)
fn prerr_c3nstr_unsolved
  (pre: string, c3t: c3nstr): void =
(
case+
c3nstr_node_view (c3t.c3nstr_node ())
of // case+
| ~C3NSTRprop (s2p) => (
    prerr pre; prerr_s2exp_s (s2p); prerr_newline (); prerr_c3nstr_where (s2p)
  ) // end of [C3NSTRprop]
| ~C3NSTRsolverify (s2p) => (
    prerr pre; prerr_s2exp_s (s2p); prerr_newline (); prerr_c3nstr_where (s2p)
  ) // end of [C3NSTRsolverify]
| ~C3NSTRitmlst _ => (prerr pre; prerr_c3nstr (c3t); prerr_newline ())
) (* end of [prerr_c3nstr_unsolved] *)

(*
** HX-2026-10: the new text of the messages (the_LEGACYERRORS_get () = 0)
*)
fn c3nstr_solve_errmsg_new
  (c3t: c3nstr, unsolved: uint): int = let
//
val loc0 = c3t.c3nstr_loc ()
val c3tk = c3t.c3nstr_kind ()
val () = sprint_reset ()
//
fn tail
  (unsolved: uint, c3t: c3nstr): void =
  if (unsolved = 0u)
    then prerr_c3nstr_unsolved (": unsolved ", c3t) else prerr_newline ()
//
in
//
case+ c3nstrkind_view (c3tk) of
| ~C3TKmain((*void*)) =>
  (
    if unsolved = 0u
      then let
        val () = prerr_error3_loc (loc0)
        val () = prerr_c3nstr_unsolved (": unsolved constraint: ", c3t)
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
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the termination metric"
    val () = (
      case+
      c3nstr_node_view (c3t.c3nstr_node ())
      of // case+
      | ~C3NSTRprop (s2p) => let
          var s2c: s2cst
          var s2es: s2explst
          val ok = s2exp_sprint_head (s2p, s2c, s2es)
        in
          if ok then (
            if glist_is_cons (s2es) then (
              prerr " "; prerr_s2exp_s (glist_head<s2exp> (s2es))
            ) (* end of [if] *)
          ) // end of [if]
        end // end of [C3NSTRprop]
      | v => c3nstr_node_view_free (v)
    ) : void // end of [val]
    val () = prerr " must be a natural number"
    val () = tail (unsolved, c3t)
  } // end of [C3TKtermet_isnat]
| ~C3TKtermet_isdec
    () => 0 where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the termination metric must decrease"
    val () = tail (unsolved, c3t)
  } // end of [C3STRKmetric_dec]
//
| ~C3TKsome_fin (d2v, s2e_fin, _) =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " must have the type "
    val () = prerr_s2exp_s (s2e_fin)
    val () = prerr " at the end of its scope"
    val () = tail (unsolved, c3t)
  } (* end of [C3TKsome_fin] *)
| ~C3TKsome_lvar (d2v, s2e_fin, _) =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " must have the type "
    val () = prerr_s2exp_s (s2e_fin)
    val () = prerr " at the end of its scope"
    val () = tail (unsolved, c3t)
  } (* end of [C3TKsome_lvar] *)
| ~C3TKsome_vbox (d2v, s2e_box, _) =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " must have the type "
    val () = prerr_s2exp_s (s2e_box)
    val () = prerr " to be returned to its vbox"
    val () = tail (unsolved, c3t)
  } (* end of [C3TKsome_vbox] *)
//
| ~C3TKlstate
    () => 0 where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the linear state of the branches cannot be merged"
    val () = tail (unsolved, c3t)
  } // end of [C3TKlstate]
| ~C3TKlstate_var
    (d2v) => 0 where {
    val () = prerr_error3_loc (loc0)
    val () = prerr ": the branches leave the linear variable "
    val () = prerr_d2var_s (d2v)
    val () = prerr " with types that cannot be merged"
    val () = tail (unsolved, c3t)
  } // end of [C3TKlstate_var]
//
| ~C3TKloop(knd) =>
    (0) where {
    val () = prerr_error3_loc (loc0)
    val () =
    if knd < 0
      then prerr ": the loop invariant does not hold at the entry of the loop"
    val () =
    if knd = 0 then prerr ": the loop invariant does not hold at a break"
    val () =
    if knd > 0 then prerr ": the loop invariant does not hold at a continue"
    val () = tail (unsolved, c3t)
  } (* end of [C3TKloop] *)
//
| ~C3TKsolverify() =>
    (0) where {
    val () =
    prerr_error3_loc (loc0)
    val () = prerr ": the constraint is expected to be verified externally."
    val () = prerr_newline ()
  } (* end of [C3TKsolver] *)
//
end // end of [c3nstr_solve_errmsg_new]

implement
c3nstr_solve_errmsg
  (c3t, unsolved) =
  if $GLOB.the_LEGACYERRORS_get () > 0
    then c3nstr_solve_errmsg_legacy (c3t, unsolved)
    else c3nstr_solve_errmsg_new (c3t, unsolved)
// end of [c3nstr_solve_errmsg]

implement
c3nstr_solve_errmsg_legacy
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
end // end of [c3nstr_solve_errmsg_legacy]

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
      val () = hypctx_push (s3i)
      val () = s2vbcfenv_add_svar (env, s2v)
    in
      c3nstr_solve_itmlst(loc0, env, s3is, unsolved, err)
    end // end of [S3ITMsvar]
  | ~S3ITMhypo(h3p) => let
      val () = hypctx_push (s3i)
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
  val ctx = hypctx_get ()
  val () = s2vbcfenv_push (env)
  val () = the_s2varbindmap_push ()
  val ans1 =
    c3nstr_solve_main (env, c3t, unsolved, err)
  // end of [val]
  val () = the_s2varbindmap_pop ()
  val () = s2vbcfenv_pop (env)
  val () = hypctx_set (ctx)
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
    val ctx = hypctx_get ()
    val _(*ans*) = c3nstr_solve_itmlst (loc0, env, s3is1, unsolved, err)
    val ((*void*)) = hypctx_set (ctx)
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
val () = hypctx_set (glist_nil ())
val _(*status*) = c3nstr_solve_main (env, c3t, unsolved, err)
val ((*freed*)) = s2vbcfenv_free (env)
//
in
//
if unsolved = 0u then () // nothing
else let (* unsolved > 0 *)
    val () = $LOC.prerr_errloc_flush ()
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
