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
// Start Time: March, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_pfman.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The marked list is a [glist] of records in a cell (see [pats_trans3_env_pfman.spec]).
//

(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_env_pfman"

(* ****** ****** *)

staload
LAB = "./pats_label.sats"
typedef label = $LAB.label

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"
staload "./pats_trans3_env_pfman.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

#include "./pats_trans3_env_pfman_gen_dats.hats"

(* ****** ****** *)

typedef d2varmrklst = glist (d2vmrk)

(* ****** ****** *)

local

val
the_d2varmrklst = gcell_make<d2varmrklst> (glist_nil ())
// end of [val]

fn
mrklst_get (): d2varmrklst = gcell_get<d2varmrklst> (the_d2varmrklst)
fn
mrklst_set (xs: d2varmrklst): void = gcell_set<d2varmrklst> (the_d2varmrklst, xs)

fn
mrklst_add_dvar (d2v: d2var): void =
  mrklst_set (glist_cons (d2vmrk_new (0, gopt_some (d2v), 0), mrklst_get ()))
// end of [mrklst_add_dvar]

fn
pushenv
  (knd: int): void =
  mrklst_set (glist_cons (d2vmrk_new (1, gopt_none (), knd), mrklst_get ()))
// end of [pushenv]

in // in of [local]

(* ****** ****** *)

fun
fprint_pfmanenv_loop (
  out: FILEref, xs: d2varmrklst
) : void =
  if glist_is_cons (xs) then let
    val x = glist_head (xs)
    val xs1 = glist_tail (xs)
    val () = (
      if x.d2vmrk_knd () = 0 then let
        val-~GOsome (d2v) = gopt_view (x.d2vmrk_d2v ())
        val () = fprint_d2var (out, d2v)
      in
        fprint_newline (out)
      end else let
        val () = fprint_string (out, "D2VMRKLSTmark(")
        val () = fprint_int (out, x.d2vmrk_mrk ())
        val () = fprint_string (out, ")")
      in
        fprint_newline (out)
      end // end of [if]
    ) : void
  in
    fprint_pfmanenv_loop (out, xs1)
  end else ()
// end of [fprint_pfmanenv_loop]

implement
fprint_the_pfmanenv (out) = let
  val () = fprint_string
    (out, "the current pfmanenv is:\n")
in
  fprint_pfmanenv_loop (out, mrklst_get ())
end // end of [fprint_the_pfmanenv]

(* ****** ****** *)

fun
pop_loop (
  xs: d2varmrklst
) : d2varmrklst =
  if glist_is_cons (xs) then let
    val x = glist_head (xs)
  in
    if x.d2vmrk_knd () = 0 then pop_loop (glist_tail (xs)) else glist_tail (xs)
  end else glist_nil ()
// end of [pop_loop]

implement
the_pfmanenv_pop
  ((*void*)) = mrklst_set (pop_loop (mrklst_get ()))
// end of [the_pfmanenv_pop]

(* ****** ****** *)

#define PUSH_LET 1 // continue
#define PUSH_LAM ~1 // stopping
#define PUSH_LLAM 0 // flexible
#define PUSH_TRY ~1 // stopping

implement
the_pfmanenv_push_let () = pushenv (PUSH_LET)
implement
the_pfmanenv_push_lam
  (lin: int) = pushenv (if lin = 0 then PUSH_LAM else PUSH_LLAM)
implement
the_pfmanenv_push_try () = pushenv (PUSH_TRY)

(* ****** ****** *)

implement
the_pfmanenv_add_dvar
  (d2v) = let
//
val islin =
  d2var_is_linear (d2v)
val () = if islin then mrklst_add_dvar (d2v)
//
val ismut =
  d2var_is_mutabl (d2v)
val () = if ismut then let
  val-~GOsome (d2vw) = gopt_view (d2var_get_view (d2v))
in
  mrklst_add_dvar (d2vw)
end // end of [if]
//
in
  // nothing
end // end of [the_pfmanenv_add_dvar]

(* ****** ****** *)

fun
add_dvarlst_loop (d2vs: d2varlst): void =
  case+ glist_view (d2vs) of
  | ~GLcons (d2v, d2vs) => (the_pfmanenv_add_dvar (d2v); add_dvarlst_loop (d2vs))
  | ~GLnil () => ()
// end of [add_dvarlst_loop]

implement
the_pfmanenv_add_dvarlst
  (d2vs) = add_dvarlst_loop (d2vs)
// end of [the_pfmanenv_add_dvarlst]

implement
the_pfmanenv_add_dvaropt
  (opt) = (
  case+ gopt_view (opt) of
  | ~GOsome (d2v) => the_pfmanenv_add_dvar (d2v)
  | ~GOnone () => ()
) // end of [the_pfmanenv_add_dvaropt]

(* ****** ****** *)

fun
d2var_search
  (d2v: d2var, s2l: s2exp, res: &s2exp >> _): Option_vt (s2exp) = let
//
val opt = d2var_get_type (d2v)
//
in
//
case+ gopt_view (opt) of
| ~GOsome s2e =>
    d2var_search_sexp (d2v, s2l, s2e, res)
| ~GOnone () => None_vt ()
//
end // end of [d2var_search]

and
d2var_search_sexp
  (d2v: d2var, s2l: s2exp, s2e: s2exp, res: &s2exp >> _): Option_vt (s2exp) = let
  val s2e = s2exp_hnfize (s2e)
in
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Eat _ =>
      d2var_search_sexp_at (d2v, s2l, s2e, res)
    // end of [S2Eat]
  | ~S2Etyrec _ =>
      d2var_search_sexp_tyrec (d2v, s2l, s2e, res)
    // end of [S2Etyrec]
  | v => (s2exp_node_view_free (v); None_vt ())
end // end of [d2var_search_sexp]

and
d2var_search_labsexplst
  (d2v: d2var, s2l: s2exp, ls2es: labs2explst, res: &s2exp >> _): Option_vt (labs2explst) =
  case+ glist_view (ls2es) of
  | ~GLcons (ls2e, ls2es) => let
      val l = ls2e.labs2exp_lab ()
      and name = ls2e.labs2exp_nam ()
      and s2e = ls2e.labs2exp_elt ()
      val opt =
        d2var_search_sexp(d2v, s2l, s2e, res)
      // end of [val]
    in
      case+ opt of
      | ~None_vt() => let
           val opt =
           (
             d2var_search_labsexplst
               (d2v, s2l, ls2es, res)
             // d2var_search_labsexplst
           ) (* end of [val] *)
         in
           case+ opt of
           | ~None_vt
               ((*void*)) => None_vt()
             // end of [None_vt]
           | ~Some_vt(ls2es_ctx) =>
               Some_vt (glist_cons(ls2e, ls2es_ctx))
             // end of [Some_vt]
         end // end of [None_vt]
      | ~Some_vt(s2e_ctx) =>
         (
          Some_vt(glist_cons(labs2exp_new(l, name, s2e_ctx), ls2es))
         ) (* en dof [Some_vt] *)
      // end of [case]
    end // end of [list_cons]
  | ~GLnil () => None_vt ()
// end of [d2var_search_labsexplst]

and
d2var_search_sexp_at
  (d2v: d2var, s2l: s2exp, s2e: s2exp, res: &s2exp >> _): Option_vt (s2exp) = let
//
val-~S2Eat(s2e1,s2e2) = s2exp_node_view (s2e.s2exp_node ())
//
val iseq = s2exp_syneq(s2l, s2e2)
//
in
//
if
iseq
then let
  val () = res := s2e1
  val s2t1 = s2e1.s2exp_srt ()
  val s2h1 = s2hole_make_srt(s2t1)
  val s2e1 = s2exp_hole(s2h1)
  val s2e_ctx = s2exp_at(s2e1, s2e2)
in
  Some_vt(s2e_ctx)
end else let
  val opt =
    d2var_search_sexp
      (d2v, s2l, s2e1, res)
    // d2var_search_sexp
  // end of [opt]
in
//
case+ opt of
| ~None_vt() => None_vt(*void*)
| ~Some_vt(s2e_ctx) => Some_vt(s2exp_at(s2e_ctx, s2e2))
  // end of [Some_vt]
//
end // end of [if]
//
end // end of [d2var_search_sexp_at]

and
d2var_search_sexp_tyrec
  (d2v: d2var, s2l: s2exp, s2e: s2exp, res: &s2exp >> _): Option_vt (s2exp) = let
//
val-~S2Etyrec(knd, npf, ls2es) = s2exp_node_view (s2e.s2exp_node ())
//
val opt = d2var_search_labsexplst(d2v, s2l, ls2es, res)
//
in
//
case+ opt of
| ~None_vt
    ((*void*)) => None_vt ()
  // end of [None_vt]
| ~Some_vt
    (ls2es_ctx) => let
    val s2t = s2e.s2exp_srt ()
  in
    Some_vt(s2exp_tyrec_srt(s2t, knd, npf, ls2es_ctx))
  end // end of [Some_vt]
//
end // end of [d2var_search_sexp_tyrec]

(* ****** ****** *)

fun
pfobj_search_loop (
  xs: d2varmrklst
, s2l0: s2exp, res: &s2exp >> _
) : Option_vt @(d2var, s2exp) = let
in
//
if glist_is_cons (xs) then let
  val x = glist_head (xs)
  val xs1 = glist_tail (xs)
in
  if x.d2vmrk_knd () = 0 then let
    val-~GOsome (d2v) = gopt_view (x.d2vmrk_d2v ())
    val opt =
      d2var_search(d2v, s2l0, res)
    // end of [val]
  in
    case+ opt of
    | ~Some_vt
        (s2e_ctx) =>
      (
        Some_vt @(d2v, s2e_ctx)
      ) // end of [Some_vt]
    | ~None_vt () => pfobj_search_loop(xs1, s2l0, res)
  end else let
    // HX-2015-01-12:
    // searching is only blocked by [lam]
    val knd = x.d2vmrk_mrk ()
  in
    if knd > 0 then pfobj_search_loop (xs1, s2l0, res) else None_vt ()
  end // end of [if]
end else None_vt ()
//
end // end of [pfobj_search_loop]

implement
pfobj_search_atview
  (s2l0) = let
//
var
res: s2exp =
  s2exp_t0ype_err()
//
val opt = pfobj_search_loop (mrklst_get (), s2l0, res)
//
in
//
case+ opt of
//
| ~None_vt
    ((*void*)) => None_vt()
  // end of [None_vt]
//
| ~Some_vt(x) => let
    val obj = PFOBJ(x.0, x.1, res, s2l0) in Some_vt(obj)
  end // end of [Some_vt]
//
end // end of [pfobj_search_atview]

end // end of [local]

(* ****** ****** *)

extern
fun the_pfmanenv_add_labp3atlst (xs: labp3atlst): void

implement
the_pfmanenv_add_p3at
  (p3t) = let
//
val opt = p3at_get_dvaropt (p3t)
val () = the_pfmanenv_add_dvaropt (opt)
//
in
//
case+ p3at_node_view (p3t.p3at_node ()) of
//
| ~P3Tany (d2v) => the_pfmanenv_add_dvar (d2v)
| ~P3Tvar (d2v) => the_pfmanenv_add_dvar (d2v)
//
| ~P3Tcon (
    _(*pck*), d2c, npf, p3ts
  ) => the_pfmanenv_add_p3atlst (p3ts)
//
| ~P3Tann (p3t, s2e) => the_pfmanenv_add_p3at (p3t)
//
| ~P3Tint _ => ()
| ~P3Tintrep _ => ()
//
| ~P3Tbool _ => ()
| ~P3Tchar _ => ()
| ~P3Tfloat _ => ()
| ~P3Tstring _ => ()
//
| ~P3Ti0nt _ => ()
| ~P3Tf0loat _ => ()
//
| ~P3Tempty _ => ()
//
| ~P3Trec (
    knd, npf, pck, lp3ts
  ) =>
    the_pfmanenv_add_labp3atlst(lp3ts)
  // end of [P3Trec]
| ~P3Tlst (
    lin, s2e_elt, p3ts
  ) => the_pfmanenv_add_p3atlst( p3ts )
//
| ~P3Trefas
    (d2v, p3t) => {
    val () = the_pfmanenv_add_dvar(d2v)
    val () = the_pfmanenv_add_p3at(p3t)
  } // end of [P3Trefas]
//
| ~P3Texist
    (s2vs, p3t) => the_pfmanenv_add_p3at(p3t)
  // P3Texist
//
| ~P3Tvbox(d2v) => the_pfmanenv_add_dvar(d2v)
//
| ~P3Terrpat ((*void*)) => ((*ignore*))
//
end // end of [the_pfmanenv_add_p3at]

implement
the_pfmanenv_add_p3atlst
  (p3ts) =
  case+ glist_view (p3ts) of
  | ~GLcons (p3t, p3ts) => (the_pfmanenv_add_p3at (p3t); the_pfmanenv_add_p3atlst (p3ts))
  | ~GLnil () => ()
// end of [the_pfmanenv_add_p3atlst]

implement
the_pfmanenv_add_labp3atlst
  (xs) = loop (xs) where {
  fun loop (
    xs: labp3atlst
  ) : void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => let
        val p3t = x.labp3at_elt ()
        val () = the_pfmanenv_add_p3at (p3t)
      in
        loop (xs)
      end // end of [list_cons]
    | ~GLnil () => ()
  // end of [loop]
} // end of [the_pfmanenv_add_labp3atlst]

(* end of [pats_trans3_env_pfman.dats] *)
