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
// Start Time: May, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_fldfrat.dats, see PORTING.md,
// "Level 3 translation, group 3 (p2at/selab/fldfrat/lvalres)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload GLOB = "./pats_global.sats"
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> ((*void*)) = prerr "pats_trans3_fldfrat"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location
staload SYM = "./pats_symbol.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_sprint.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

local

fun
auxck_free
(
  loc0: loc_t
, s2es: s2explst, nerr: int
) : int = let
in
//
case+ glist_view(s2es) of
//
| ~GLnil
    ((*void*)) => nerr
  // GLnil
//
| ~GLcons
    (s2e, s2es) => let
    var nerr: int = nerr
    val islin = s2exp_is_lin2 (s2e)
    val () = if islin then let
      val () = nerr := nerr + 1
      val () = prerr_error3_loc (loc0)
      val () =
      if $GLOB.the_LEGACYERRORS_get () > 0 then
        prerr ": [free@] operation cannot be performed" else
        prerr ": free@ operation cannot be performed" // HX-2026-10
      val () =
      if $GLOB.the_LEGACYERRORS_get () > 0 then {
        val () = prerr ": a linear component of the type ["
        val () = prerr_s2exp (s2e)
        val () = prerr "] may be abandoned."
      } else { // HX-2026-10: the surface syntax (pats_staexp2_sprint)
        val () = sprint_reset ()
        val () = prerr ": a linear component of the type "
        val () = prerr_s2exp_s (s2e)
        val () = prerr " may be abandoned."
      } (* end of [if] *)
      val () = prerr_newline ()
    in
      // nothing
    end // end of [val]
  in
    auxck_free (loc0, s2es, nerr)
  end // end of [GLcons]
//
end // end of [auxck_free]

fun
auxfind
(
  loc0: loc_t, s2ls: s2explst
) : s2explst = let
in
//
case+ glist_view(s2ls) of
| ~GLnil
    ((*void*)) => glist_nil()
  // end of [GLnil]
| ~GLcons
    (s2l, s2ls) => let
    val opt = pfobj_search_atview (s2l)
    val s2e_elt = (
      case+ opt of
      | ~Some_vt(pfobj) => let
          val ~PFOBJ
          (
            d2v, s2e_ctx, s2e_elt, _(*s2l*)
          ) = pfobj // end of [val]
          val () = d2var_set_type(d2v, gopt_none((*void*)))
        in
          s2e_elt
        end // end of [Some_vt]
      | ~None_vt ((*void*)) => s2exp_errexp(s2rt_t0ype)
    ) : s2exp // end of [val]
    val s2es_elt = auxfind (loc0, s2ls)
  in
    glist_cons (s2e_elt, s2es_elt)
  end // end of [GLcons]
//
end // end of [auxfind]

fun
auxmain
(
  loc0: loc_t
, opknd: int // 0/1 free/fold
, s2as: s2exparglst, d2e: d2exp
) : d3exp = let
  val loc = d2e.d2exp_loc()
  val d3e = d2exp_trup (d2e)
  val () = d3exp_open_and_add d3e
  val s2e_ptr = d3exp_get_type (d3e)
in
//
case+
s2exp_node_view(s2e_ptr.s2exp_node())
of (* case+ *)
| ~S2Edatconptr
    (d2c, _(*rt*), arg) => let
    val s2es_elt = auxfind (loc0, arg)
    val s2e_dcon = d2con_get_type (d2c)
    var err: int = 0
    val @(s2e_dcon, s2ps) =
      s2exp_uni_instantiate_sexparglst (s2e_dcon, s2as, err)
    // end of [val]
    val () = trans3_env_add_proplst_vt (loc0, s2ps)
    val locarg = $LOC.location_leftmost (loc)
    val @(s2e_dcon, s2ps) =
      s2exp_uni_instantiate_all (s2e_dcon, locarg, err)
    // HX: [err] is not used
    val () = trans3_env_add_proplst_vt (loc0, s2ps)
    val-~S2Efun (
      fc, lin, s2fe, nof, s2es_arg, s2e_res
    ) = s2exp_node_view(s2e_dcon.s2exp_node()) // end of [val]
//
    val () =
    if opknd = 0 then let
      val nerr = auxck_free(loc0, s2es_elt, 0(*nerr*))
    in
      if nerr > 0 then
        the_trans3errlst_add(trans3err_T3E_d3exp_freeat(loc0, d3e))
      // end of [if]
    end // end of [val]
//
    val () =
    if opknd > 0 then let
      var err: int = 0
      val () =
        $SOL.s2explst_tyleq_solve_err (loc0, s2es_elt, s2es_arg, err)
      // end of [val]
    in
      if err > 0 then let
        val () = prerr_error3_loc(loc)
        val () = prerr ": [fold@] operation cannot be formed"
        val () = prerr ": some argument types are mismatched."
        val () = prerr_newline ()
        val () = prerr_the_staerrlst()
      in
        the_trans3errlst_add(trans3err_T3E_d3exp_foldat(loc0, d3e))
      end // end of [if]
    end // end of [val]
    val () =
    if opknd > 0 then let
      var err: int = 0
      val ((*void*)) =
        d3lval_set_type_err(0(*refval*), d3e, s2e_res, err)
      // end of [val]
    in
      if err > 0 then let
        val () = prerr_error3_loc(loc)
        val () =
          prerr ": [fold@] operation cannot be formed"
        val () =
          prerr ": the type of the dynamic expression cannot be changed."
        val () = prerr_newline ()
      in
        the_trans3errlst_add(trans3err_T3E_d3exp_foldat(loc0, d3e))
      end (* end of [if] *)
    end // end of [val]
  in
    d3e
  end // end of [S2Edatconptr]
| v (*non-S2Edatconptr*) => let
    val () = s2exp_node_view_free (v)
    val () = prerr_error3_loc(loc)
    val () =
    if opknd = 0 then
      prerr ": [free@] operation cannot be performed"
    // end of [if]
    val () =
    if opknd > 0 then
      prerr ": [fold@] operation cannot be performed"
    // end of [if]
    val () = prerr ": unfolded datatype constructor is expected."
    val () = prerr_newline ()
  in
    d3exp_errexp (loc0)
  end // end of [non-S2Edatconptr]
//
end // end of [auxmain]

in (* in of [local] *)

implement
d2exp_trup_foldat
  (d2e0) = let
//
val
loc0 = d2e0.d2exp_loc()
val-~D2Efoldat(s2as, d2e) = d2exp_node_view(d2e0.d2exp_node())
//
val d3e = auxmain(loc0, 1(*opknd*), s2as, d2e)
//
in
  d3exp_foldat(loc0, d3e)
end // end of [d2exp_trup_foldat]

implement
d2exp_trup_freeat
  (d2e0) = let
//
val loc0 = d2e0.d2exp_loc()
val-~D2Efreeat(s2as, d2e) = d2exp_node_view(d2e0.d2exp_node())
//
val err =
the_effenv_check_wrt(loc0)
//
val () =
if (err > 0) then
(
the_trans3errlst_add(trans3err_T3E_d2exp_trup_wrt(loc0))
) // end of [if] // end of [val]
//
val d3e = auxmain(loc0, 0(*opknd*), s2as, d2e)
//
in
  d3exp_freeat(loc0, d3e)
end // end of [d2exp_trup_freeat]

end // end of [local]

(* ****** ****** *)
//
// HX-2026-10: fold on demand.
//
// An unfolded variable (its type is [S2Edatconptr (d2c, rt, [l_1..l_n])] and
// its fields are the views [T_i @ l_i]) is folded by the checker, as [fold@]
// does, at the points where a folded type is required: a use against a type
// that is not an unfolded one ([d2exp_trdn] of a variable), the end of the
// scope of the views of its fields ([the_d2varenv_check]) and its own end
// ([d2vfin_check] with [D2VFINsome]). There, every program that is accepted
// with explicit [fold@]s fails without them, so the programs that are accepted
// with the [fold@]s are checked as before. A try that fails reports nothing
// and changes nothing (the constraints are discarded); the reason is printed
// as a hint after the error that follows. [free@] is never implied.
//
// The table [the_afitms] maps the views of the fields of a pattern [@Con (..)]
// to the variable the pattern unfolds (registered by
// [d3lval_set_pat_type_left]); an entry is dropped when the scope of its view
// ends. [the_afowns] keeps the location of the pattern of each unfolded
// variable (for the hints).
//
(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

local

typedef
afitm = @{
  afitm_view= d2var, afitm_owner= d2var, afitm_root= s2exp
} (* end of [afitm] *)
typedef
afown = @{ afown_d2v= d2var, afown_loc= loc_t }

val the_afitms = gcell_make<glist(afitm)> (glist_nil ())
val the_afowns = gcell_make<glist(afown)> (glist_nil ())
fn afitms_get (): glist(afitm) = gcell_get<glist(afitm)> (the_afitms)

(*
** the reason of the last failed try: [the_afwhy] =
** 1: the view of field [the_afk] is not available;
** 2: field [the_afk] has the type [the_aft1]
**    but the constructor needs [the_aft2];
** 3: the constructor has no argument types
*)
val the_afwhy = gcell_make<int> (0)
val the_afk = gcell_make<int> (0)
val the_aft1 = gcell_make<s2exp> (s2exp_t0ype_err ())
val the_aft2 = gcell_make<s2exp> (s2exp_t0ype_err ())

(*
** the failed tries at the end of the scope that is being checked (knd = 0):
** the hints for the views of the fields (knd = 2) are printed with these
** reasons, as the check of a view consumes it
*)
typedef
affail = @{
  affail_d2v= d2var
, affail_why= int, affail_k= int, affail_t1= s2exp, affail_t2= s2exp
} (* end of [affail] *)
val the_affails = gcell_make<glist(affail)> (glist_nil ())

fn
affail_add
  (d2v: d2var): void = let
  val x = @{
    affail_d2v= d2v
  , affail_why= gcell_get<int> (the_afwhy), affail_k= gcell_get<int> (the_afk)
  , affail_t1= gcell_get<s2exp> (the_aft1)
  , affail_t2= gcell_get<s2exp> (the_aft2)
  } : affail // end of [val]
in
  gcell_set<glist(affail)>
    (the_affails, glist_cons (x, gcell_get<glist(affail)> (the_affails)))
end // end of [affail_add]

fun
affails_find
  (xs: glist(affail), d2v: d2var): bool =
(
  case+ glist_view (xs) of
  | ~GLnil () => false
  | ~GLcons (x, xs) =>
    if x.affail_d2v = d2v then let
      val () = gcell_set<int> (the_afwhy, x.affail_why)
      val () = gcell_set<int> (the_afk, x.affail_k)
      val () = gcell_set<s2exp> (the_aft1, x.affail_t1)
      val () = gcell_set<s2exp> (the_aft2, x.affail_t2)
    in
      true
    end else affails_find (xs, d2v)
) (* end of [affails_find] *)

fn
afwhy_set
  (why: int, k: int): void = {
  val () = gcell_set<int> (the_afwhy, why)
  val () = gcell_set<int> (the_afk, k)
} (* end of [afwhy_set] *)

(* ****** ****** *)
//
// HX: the at-view [s2e_ctx] found by [pfobj_search_atview] is a whole variable
// (and not a part of a bigger view)
//
fn
s2ctx_is_hole_at
  (s2e_ctx: s2exp): bool =
(
  case+ s2exp_node_view (s2e_ctx.s2exp_node ()) of
  | ~S2Eat (s2e1, _) => s2exp_node_is_S2Ehole (s2e1.s2exp_node ())
  | v => (s2exp_node_view_free (v); false)
) (* end of [s2ctx_is_hole_at] *)

fn
s2exp_is_datconptr
  (s2e: s2exp): bool = s2exp_node_is_S2Edatconptr (s2e.s2exp_node ())

(*
** @(knd, s2e_dcp, s2l):
** knd = 0: not unfolded;
** knd = 1: the (linear) variable has the type [s2e_dcp];
** knd = 2: the view at [s2l] is [s2e_dcp @ s2l]
**          (a mutable variable or its view)
*)
fun
autofold_owner_addr
  (s2l: s2exp): @(int, s2exp, s2exp) = let
  val opt = pfobj_search_atview (s2l)
in
//
case+ opt of
| ~Some_vt (pfobj) => let
    val ~PFOBJ (_(*d2v*), s2e_ctx, s2e_elt, _(*s2l*)) = pfobj
  in
    if s2ctx_is_hole_at (s2e_ctx)
      then (
        if s2exp_is_datconptr (s2e_elt)
          then @(2, s2e_elt, s2l) else @(0, s2e_elt, s2l)
      ) else @(0, s2e_elt, s2l)
    // end of [if]
  end // end of [Some_vt]
| ~None_vt ((*void*)) => @(0, s2l, s2l)
//
end // end of [autofold_owner_addr]

fun
autofold_owner
  (d2v: d2var): @(int, s2exp, s2exp) =
(
if d2var_is_mutabl (d2v) then (
  // HX: the view of the variable is checked first (no proof search
  // for a variable whose view does not hold an unfolded type)
  case+ gopt_view (d2var_get_view (d2v)) of
  | ~GOsome (d2vw) => autofold_owner (d2vw)
  | ~GOnone () => @(0, s2exp_t0ype_err (), s2exp_t0ype_err ())
) else (
  case+ gopt_view (d2var_get_type (d2v)) of
  | ~GOsome (s2e) =>
    (
      if s2exp_is_datconptr (s2e) then (
        if d2var_is_linear (d2v) then @(1, s2e, s2e) else @(0, s2e, s2e)
      ) else (
        case+ s2exp_node_view (s2e.s2exp_node ()) of
        | ~S2Eat (s2e1, s2l) =>
            if s2exp_is_datconptr (s2e1)
              then autofold_owner_addr (s2l) else @(0, s2e, s2e)
            // end of [if]
        | v => (s2exp_node_view_free (v); @(0, s2e, s2e))
      ) (* end of [if] *)
    ) (* end of [GOsome] *)
  | ~GOnone () => @(0, s2exp_t0ype_err (), s2exp_t0ype_err ())
) (* end of [if] *)
) (* end of [autofold_owner] *)

fn
autofold_owner_root
  (s2e_dcp: s2exp): s2exp =
(
  case+ s2exp_node_view (s2e_dcp.s2exp_node ()) of
  | ~S2Edatconptr (_, s2e_rt, _) => s2e_rt
  | v => (s2exp_node_view_free (v); s2exp_t0ype_err ())
) (* end of [autofold_owner_root] *)

(* ****** ****** *)

(*
** the views of the fields at [s2ls] (in reverse order); the result is 0 or
** the index (from 1) of the first field whose view is not available
*)
fun
autofold_views
(
  s2ls: s2explst, k: int
, d2vs: &glist(d2var) >> _, s2es: &glist(s2exp) >> _
) : int = let
in
//
case+ glist_view (s2ls) of
| ~GLnil () => 0
| ~GLcons (s2l, s2ls) => let
    val opt = pfobj_search_atview (s2l)
  in
    case+ opt of
    | ~Some_vt (pfobj) => let
        val ~PFOBJ (d2v, s2e_ctx, s2e_elt, _) = pfobj
      in
        if s2ctx_is_hole_at (s2e_ctx) then (
        // HX: [S2Ewithout]: the view has been taken out
        if s2exp_node_is_S2Ewithout (s2e_elt.s2exp_node ()) then k else let
          val () = d2vs := glist_cons (d2v, d2vs)
          val () = s2es := glist_cons (s2e_elt, s2es)
        in
          autofold_views (s2ls, k+1, d2vs, s2es)
        end // end of [if]
        ) else k // end of [if]
      end // end of [Some_vt]
    | ~None_vt () => k
  end // end of [GLcons]
//
end // end of [autofold_views]

(*
** the result is 0 or the index (from 1) of the first mismatched field
*)
fun
autofold_solve
(
  loc0: loc_t
, s2es1: s2explst, s2es2: s2explst, k: int
) : int = let
in
//
case+ glist_view (s2es1) of
| ~GLnil () => 0
| ~GLcons (s2e1, s2es1) => (
  case+ glist_view (s2es2) of
  | ~GLnil () => k
  | ~GLcons (s2e2, s2es2) => let
      val err = $SOL.s2exp_tyleq_solve (loc0, s2e1, s2e2)
    in
      if err > 0 then let
        val () = gcell_set<s2exp> (the_aft1, s2e1)
        val () = gcell_set<s2exp> (the_aft2, s2e2)
      in
        k
      end else autofold_solve (loc0, s2es1, s2es2, k+1)
    end // end of [GLcons]
  ) (* end of [GLcons] *)
//
end // end of [autofold_solve]

fn
autofold_discard (): void = {
  val s3is = trans3_env_pop ()
  val ((*freed*)) = list_vt_free (s3is)
  val () = the_staerrlst_clear ()
} (* end of [autofold_discard] *)

fun
autofold_consume
  (d2vs: glist(d2var)): void =
(
  case+ glist_view (d2vs) of
  | ~GLnil () => ()
  | ~GLcons (d2v, d2vs) =>
      (d2var_set_type (d2v, gopt_none ()); autofold_consume (d2vs))
) (* end of [autofold_consume] *)

(*
** the steps of [fold@ (d2v)] without static arguments: the result is
** 0: [d2v] is not unfolded; 1: folded (or foldable if [commit] is false);
** 2: [fold@] cannot be applied (the reason is in [the_afwhy];
**    nothing is changed)
*)
fun
autofold_try
(
  loc0: loc_t, d2v: d2var, commit: bool
) : int = let
  val @(knd, s2e_dcp, s2l) = autofold_owner (d2v)
in
//
if knd = 0 then 0 else let
  val-~S2Edatconptr
    (d2c, _(*rt*), s2ls) = s2exp_node_view (s2e_dcp.s2exp_node ())
  var d2vs: glist(d2var) = glist_nil ()
  var s2es: glist(s2exp) = glist_nil ()
  val k = autofold_views (s2ls, 1, d2vs, s2es)
in
//
if k > 0 then (afwhy_set (1, k); 2) else let
  val s2es_elt = glist_reverse (s2es)
  val () = trans3_env_push ()
  val s2e_dcon = d2con_get_type (d2c)
  var err: int = 0
  val @(s2e_dcon, s2ps) =
    s2exp_uni_instantiate_sexparglst (s2e_dcon, glist_nil (), err)
  val () = trans3_env_add_proplst_vt (loc0, s2ps)
  val @(s2e_dcon, s2ps) =
    s2exp_uni_instantiate_all (s2e_dcon, loc0, err)
  // HX: [err] is not used (as in [fold@])
  val () = trans3_env_add_proplst_vt (loc0, s2ps)
in
//
case+
s2exp_node_view (s2e_dcon.s2exp_node ())
of // case+
| ~S2Efun (
    _, _, _, _, s2es_arg, s2e_res
  ) => let
    val k = autofold_solve (loc0, s2es_elt, s2es_arg, 1)
  in
    if k > 0 then let
      val () = autofold_discard ()
    in
      afwhy_set (2, k); 2
    end else if ~(commit) then let
      val () = autofold_discard () in 1
    end else let
      val () = trans3_env_pop_and_add_main (loc0)
      val () = autofold_consume (d2vs)
      val () =
      if knd = 1
        then d2var_set_type (d2v, gopt_some (s2e_res))
        else {
          val _(*old*) = s2addr_exch_type (loc0, s2l, glist_nil (), s2e_res)
        } (* end of [else] *)
      // end of [if]
    in
      1
    end // end of [if]
  end // end of [S2Efun]
| v (*non-S2Efun*) => let
    val () = s2exp_node_view_free (v)
    val () = autofold_discard ()
  in
    afwhy_set (3, 0); 2
  end // end of [non-S2Efun]
//
end // end of [if]
//
end // end of [if]
//
end // end of [autofold_try]

(* ****** ****** *)

(*
** a variable checked against [s2e] is folded unless [s2e] is (or may be)
** an unfolded type itself
*)
fun
autofold_wanted
  (s2e: s2exp): bool = let
  val s2e = s2hnf2exp (s2exp2hnf (s2e))
in
//
case+ s2exp_node_view (s2e.s2exp_node ()) of
| ~S2Erefarg (_, s2e1) => autofold_wanted (s2e1)
| ~S2Einvar (s2e1) => autofold_wanted (s2e1)
| ~S2Eexi (_, _, s2e1) => autofold_wanted (s2e1)
| ~S2Euni (_, _, s2e1) => autofold_wanted (s2e1)
| ~S2Ewthtype (s2e1, _) => autofold_wanted (s2e1)
| ~S2Eat (s2e1, _) => autofold_wanted (s2e1)
| ~S2Edatconptr (_, _, _) => false
| ~S2EVar (_) => false
| ~S2Etop (_, _) => false
| ~S2Ehole (_) => false
| ~S2Eerrexp () => false
| v => (s2exp_node_view_free (v); true)
//
end // end of [autofold_wanted]

(* ****** ****** *)

fun
afitms_find
(
  xs: glist(afitm), d2v: d2var
) : Option_vt (afitm) =
(
  case+ glist_view (xs) of
  | ~GLnil () => None_vt ()
  | ~GLcons (x, xs) =>
      if x.afitm_view = d2v then Some_vt (x) else afitms_find (xs, d2v)
) (* end of [afitms_find] *)

fun
afitms_remove
(
  xs: glist(afitm), d2v: d2var
) : glist(afitm) =
(
  case+ glist_view (xs) of
  | ~GLnil () => glist_nil ()
  | ~GLcons (x, xs) =>
      if x.afitm_view = d2v
        then afitms_remove (xs, d2v)
        else glist_cons (x, afitms_remove (xs, d2v))
      // end of [if]
) (* end of [afitms_remove] *)

fun
afowns_find
(
  xs: glist(afown), d2v: d2var
) : Option_vt (loc_t) =
(
  case+ glist_view (xs) of
  | ~GLnil () => None_vt ()
  | ~GLcons (x, xs) =>
      if x.afown_d2v = d2v then Some_vt (x.afown_loc) else afowns_find (xs, d2v)
) (* end of [afowns_find] *)

(*
** HX: the views of the fields are those of the variables of the pattern
** (no proof search: it would make holes, and the stamps of the holes must
** stay as they are for the programs that do not need any folding)
*)
//
// HX: the variable of a field, as [auxpat1] of [p3at_unfold_update] finds it
//
fn
afitms_p3at_dvar
  (p3t: p3at): d2varopt =
(
  case+ p3at_node_view (p3t.p3at_node ()) of
  | ~P3Tany (d2v) => gopt_some (d2v)
  | ~P3Tvar (d2v) => gopt_some (d2v)
  | ~P3Trefas (d2v, _) => gopt_some (d2v)
  | v => (p3at_node_view_free (v); p3at_get_dvaropt (p3t))
) (* end of [afitms_p3at_dvar] *)

fun
afitms_register
(
  p3ts: p3atlst, d2v_owner: d2var, s2e_rt: s2exp
) : void =
(
  case+ glist_view (p3ts) of
  | ~GLnil () => ()
  | ~GLcons (p3t, p3ts) => let
      val () = (
        case+ gopt_view (afitms_p3at_dvar (p3t)) of
        | ~GOsome (d2v) => (
            case+ gopt_view (d2var_get_view (d2v)) of
            | ~GOsome (d2vw) => let
                val x = @{
                  afitm_view= d2vw, afitm_owner= d2v_owner, afitm_root= s2e_rt
                } : afitm // end of [val]
              in
                gcell_set<glist(afitm)>
                  (the_afitms, glist_cons (x, afitms_get ()))
              end // end of [GOsome]
            | ~GOnone () => ()
          ) (* end of [GOsome] *)
        | ~GOnone () => ()
      ) : void // end of [val]
    in
      afitms_register (p3ts, d2v_owner, s2e_rt)
    end // end of [GLcons]
) (* end of [afitms_register] *)

(* ****** ****** *)

fun
autofold_hint_print
  (d2v: d2var): void = let
//
val why = gcell_get<int> (the_afwhy)
val k = gcell_get<int> (the_afk)
//
val () = prerr "the variable "
val () = $SYM.prerr_symbol (d2var_get_sym (d2v))
val () = prerr " is unfolded"
val opt = afowns_find (gcell_get<glist(afown)> (the_afowns), d2v)
val () = (
  case+ opt of
  | ~Some_vt (ploc) => {
      val () = prerr " (pattern at "
      val () = $LOC.prerr_location (ploc)
      val () = prerr ")"
    } (* end of [Some_vt] *)
  | ~None_vt () => ()
) : void // end of [val]
val () = prerr " and fold@ "
val () = $SYM.prerr_symbol (d2var_get_sym (d2v))
val () = prerr " cannot be applied: "
val () =
if why = 1 then {
  val () = prerr "the view of field "
  val () = prerr_int (k)
  val () = prerr " is consumed"
} (* end of [if] *)
val () =
if why = 2 then {
  val () = prerr "field "
  val () = prerr_int (k)
  val () = prerr " has type ["
  val () = prerr_s2exp (gcell_get<s2exp> (the_aft1))
  val () = prerr "] but the constructor needs ["
  val () = prerr_s2exp (gcell_get<s2exp> (the_aft2))
  val () = prerr "]"
} (* end of [if] *)
val () =
if why = 3 then prerr "the constructor has no fields"
//
in
  prerr_newline ()
end // end of [autofold_hint_print]

(*
** the owner of the view [d2v] of a field, or [d2v] itself
*)
fn
autofold_owner_of
  (d2v: d2var): d2var = let
  val opt = afitms_find (gcell_get<glist(afitm)> (the_afitms), d2v)
in
  case+ opt of
  | ~Some_vt (x) => x.afitm_owner | ~None_vt () => d2v
end // end of [autofold_owner_of]

fun
autofold_hook
(
  knd: int, loc0: loc_t, d2v: d2var, s2e: s2exp
) : int = let
in
//
if knd = 0 then let // the end of the scope of [d2v]
  val opt = afitms_find (gcell_get<glist(afitm)> (the_afitms), d2v)
in
  case+ opt of
  | ~Some_vt (x) =>
    (
      if gopt_is_some (d2var_get_type (d2v)) then let
        val d2v_owner = x.afitm_owner
        val @(knd1, s2e_dcp, _) = autofold_owner (d2v_owner)
      in
        if knd1 > 0 then (
          if s2exp_syneq (autofold_owner_root (s2e_dcp), x.afitm_root)
            then let
              val ans = autofold_try (loc0, d2v_owner, true)
            in
              if ans = 2 then affail_add (d2v_owner); 0
            end else 0
          // end of [if]
        ) else 0 // end of [if]
      end else 0 // end of [if]
    ) (* end of [Some_vt] *)
  | ~None_vt () => 0
end // end of [knd = 0]
//
else if knd = 1 then let // the end of [d2v] itself
  // HX: [autofold_wanted] is only computed for an unfolded variable
  // (a head normal form may need fresh static variables)
  val @(knd1, _, _) = autofold_owner (d2v)
  val wanted = if knd1 = 0 then false else (
    case+ d2vfin_view (d2var_get_finknd (d2v)) of
    | ~D2VFINsome (s2e_fin) => autofold_wanted (s2e_fin)
    | ~D2VFINsome_lvar (s2e_fin) => (
        case+ s2exp_node_view (s2e_fin.s2exp_node ()) of
        | ~S2Eat (s2e1, _) => autofold_wanted (s2e1)
        | v => (s2exp_node_view_free (v); false)
      ) (* end of [D2VFINsome_lvar] *)
    | v => (d2vfin_view_free (v); false)
  ) : bool // end of [val]
in
  if wanted then autofold_try (loc0, d2v, true) else 0
end // end of [knd = 1]
//
else if knd = 2 then let // a hint after an error
  val d2v_owner = autofold_owner_of (d2v)
  val found =
    affails_find (gcell_get<glist(affail)> (the_affails), d2v_owner)
  val ans = (
    if found then 2 else autofold_try (loc0, d2v_owner, false)
  ) : int // end of [val]
in
  if ans = 2 then (autofold_hint_print (d2v_owner); 0) else 0
end // end of [knd = 2]
//
else if knd = 3 then let // a use against [s2e]
  val @(knd1, _, _) = autofold_owner (d2v)
in
  if knd1 = 0 then 0 else
  if autofold_wanted (s2e) then let
    val ans = autofold_try (loc0, d2v, true)
  in
    ans (* 0/1/2: nothing/folded/failed *)
  end else 0 // end of [if]
end (* end of [knd = 3] *)
//
else if knd = 4 then let // forget the view [d2v]
  val () = gcell_set<glist(affail)> (the_affails, glist_nil ())
  val xs = gcell_get<glist(afitm)> (the_afitms)
  val opt = afitms_find (xs, d2v)
in
  case+ opt of
  | ~Some_vt _ => let
      val () =
        gcell_set<glist(afitm)> (the_afitms, afitms_remove (xs, d2v))
    in
      0
    end // end of [Some_vt]
  | ~None_vt () => 0
end // end of [knd = 4]
//
else if knd = 5 then let // a hint after an error (the try has just failed)
  val () = autofold_hint_print (d2v) in 0
end // end of [knd = 5]
//
else 0 // end of [if]
//
end // end of [autofold_hook]

in (* in-of-local *)

implement
d2var_foldat_try
  (loc0, d2v) = autofold_try (loc0, d2v, true) = 1

implement
d3lval_autofold_register
  (d3e0, s2e, p3t) =
(
if s2exp_is_datconptr (s2e) then (
  case+ p3at_node_view (p3t.p3at_node ()) of
  | ~P3Tcon (_, _, _, p3ts) => (
    case+ d3exp_node_view (d3e0.d3exp_node ()) of
    | ~D3Evar (d2v) => let
        val s2e_rt = autofold_owner_root (s2e)
        val () = afitms_register (p3ts, d2v, s2e_rt)
        val x = @{ afown_d2v= d2v, afown_loc= p3t.p3at_loc () } : afown
      in
        gcell_set<glist(afown)>
          (the_afowns, glist_cons (x, gcell_get<glist(afown)> (the_afowns)))
      end // end of [D3Evar]
    | v => d3exp_node_view_free (v)
    ) (* end of [P3Tcon] *)
  | v => p3at_node_view_free (v)
) (* end of [if] *)
) (* end of [d3lval_autofold_register] *)

val () = the_d2varenv_set_autofold_hook (autofold_hook)

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_fldfrat.dats] *)
