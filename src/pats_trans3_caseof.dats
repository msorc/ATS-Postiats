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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_caseof.dats, see PORTING.md,
// "Level 3 translation, group 2 (dynexp_dn/appsym/caseof/patcon)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_trans3_caseof"
//
(* ****** ****** *)

staload LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"

(* ****** ****** *)

staload "./pats_stacst2.sats"
staload "./pats_patcst2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

fn
gm2at_trup
(
  gm2t: gm2at
) : gm3at = let
  val loc0 = gm2t.gm2at_loc()
  val d2e = gm2t.gm2at_exp()
  val d3e = d2exp_trup (d2e)
  val s2e = d3exp_get_type (d3e)
  val op2t = gm2t.gm2at_pat() 
  val op3t = (
    case+ gopt_view(op2t) of
    | ~GOsome p2t => let
        val p3t = p2at_trdn (p2t, s2e)
      in
        gopt_some (p3t)
      end // end of [Some]
    | ~GOnone () => let
        val () = guard_trdn (loc0, true(*gval*), s2e)
      in
        gopt_none ()
      end // end of [None]
  ) : p3atopt // end of [val]
in
  gm3at_make (loc0, d3e, op3t)
end // end of [gm2at_tr_up]

// HX: [list_map_fun (gm2ts, gm2at_trup)] (head first)
fun
gm2atlst_trup_loop
(
  gm2ts: gm2atlst, res: List0_vt(gm3at)
) : List0_vt(gm3at) =
(
  case+ glist_view(gm2ts) of
  | ~GLnil () => list_vt_reverse (res)
  | ~GLcons (gm2t, gm2ts) => let
      val gm3t = gm2at_trup (gm2t)
    in
      gm2atlst_trup_loop (gm2ts, list_vt_cons (gm3t, res))
    end // end of [GLcons]
) (* end of [gm2atlst_trup_loop] *)

fn
gm2atlst_trup (
  gm2ts: gm2atlst
) : gm3atlst = let
  val m3ats = gm2atlst_trup_loop (gm2ts, list_vt_nil ())
in
  l2l (m3ats)
end // end of [gm2atlst_trup]

(* ****** ****** *)
//
// HX-2026-10: the (linear) matrix of the complement of the patterns is a list of
// linear lists of the (shared) constraints, as in ATS1; a borrowed element is a [ptr]
// that is cast back with [$UN.castvwtp1] (the technique of pats_patcst2.dats)
//
fn
cp2tcss_ptrs (xss: !p2atcstlstlst_vt): List0_vt (ptr) = let
  val ps = $UN.castvwtp1{List0_vt(ptr)} (xss)
  val res = list_vt_copy<ptr> (ps)
  val ((*dropped*)) = $UN.castvwtp0{void} (ps)
in
  res
end // end of [cp2tcss_ptrs]

(* ****** ****** *)

extern
fun
c2lau_trdn
(
  casknd: caskind
, c2l: c2lau
, ctr: c3nstroptref
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
, cp2tss: p2atcstlstlst_vt
) : c3lau // end of [c2lau_trdn]

(* ****** ****** *)

implement
c2lau_trdn (
  casknd, c2l, ctr, d3es, s2es_pat, s2e_res, cp2tcss
) = let
//
val loc0 = c2l.c2lau_loc()
val p2ts = c2l.c2lau_pat()
//
val () = trans3_env_push ()
//
val seq = c2l.c2lau_seq()
and neg = c2l.c2lau_neg()
//
val () =
if seq > 0 then let
  val cp2tcss = p2atcstlstlst_vt_copy (cp2tcss)
in
  trans3_env_hypadd_patcstlstlst (loc0, cp2tcss, s2es_pat)
end // end of [val]
var serr: int = 0
val p3ts = p2atlst_trdn (loc0, p2ts, s2es_pat, serr)
val () =
if (serr != 0) then
{
  val () = the_trans3errlst_add (trans3err_T3E_c2lau_trdn_arity (c2l, s2es_pat))
} (* end of [val] *)
//
val () = the_d2varenv_push_let ()
val () = the_d2varenv_add_p3atlst (p3ts)
val () = the_pfmanenv_push_let ()
val () = the_pfmanenv_add_p3atlst (p3ts)
//
val gua = gm2atlst_trup (c2l.c2lau_gua())
//
// HX-2012-05:
// if p3t is a PCKlincon, it is assumed read-only!
//
val () = d3lvalist_set_pat_type_left (d3es, p3ts)
val s2e_res = (
  if neg > 0 then s2exp_bottom_t0ype_exi () else s2e_res
) : s2exp // end of [val]
val d3e_body = d2exp_trdn (c2l.c2lau_body(), s2e_res)
//
val () = the_d2varenv_check (loc0)
//
val () = p2atcstlstlst_vt_free (cp2tcss)
//
val () = the_d2varenv_pop ()
val () = the_pfmanenv_pop ()
//
val () = trans3_env_add_cnstr_ref (ctr)
val () = trans3_env_pop_and_add_main (loc0)
//
in
  c3lau_make (loc0, p3ts, gua, seq, neg, d3e_body)
end // end of [c2lau_trdn]

(* ****** ****** *)

fun
c2laulst0_trdn
(
  loc0: $LOC.location
, casknd: caskind
, s2es_pat: s2explst
, s2e_res: s2exp
) : void = let
in
//
case+ casknd of
| CK_case () => let
    val () = prerr_warning3_loc (loc0)
    val () = prerr_string ": a case-expression is expected to have at least one match clause."
    val () = prerr_newline ()
    val _(*err*) = the_effenv_check_exn (loc0) // HX: handling potential match failure
  in
    // nothing
  end // end of [CK_case]
| CK_case_pos () => let
    val () = prerr_error3_loc (loc0)
    val () = prerr_string ": a case+-expression is required to have at least one match clause."
    val () = prerr_newline ()
  in
    the_trans3errlst_add (trans3err_T3E_c2laulst0_trdn_noclause (loc0))
  end // end of [CK_case_pos]
| CK_case_neg () => ()
//
end // end of [c2laulst0_trdn]

(* ****** ****** *)

fun
c2laulst1_trdn
(
  loc0: $LOC.location
, casknd: caskind
, invres: i2nvresstate
, c2l: c2lau
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
) : c3lau = let
//
val cp2tcss =
(
  case+ casknd of
  | CK_case () => c2lau_pat_comp (c2l)
  | CK_case_pos () => c2lau_pat_comp (c2l)
  | CK_case_neg () => list_vt_nil ()
) : p2atcstlstlst_vt // end of [val]
//
val lsbis =
  the_d2varenv_save_lstbefitmlst ()
val lsaft = lstaftc3nstr_initize (lsbis)
//
val ctr =
  c3nstroptref_make_none (c2l.c2lau_loc())
val c3l = let
  val cp2tcss1 = c2lau_pat_any (c2l) in
  c2lau_trdn (casknd, c2l, ctr, d3es, s2es_pat, s2e_res, cp2tcss1)
end // end of [val]
val () = lstaftc3nstr_update (lsaft, ctr)
//
val
isexhaust = (
//
// HX: true for [case-]
//
  if list_vt_is_nil (cp2tcss) then true else false
) : bool // end of [val]
val () =
if ~isexhaust then let
  val cp2tcss = p2atcstlstlst_vt_copy (cp2tcss) in
  trans3_env_add_patcstlstlst_false (loc0, casknd, cp2tcss, s2es_pat)
end // end of [if] // end of [val]
//
val () = p2atcstlstlst_vt_free (cp2tcss)
//
val () = lstaftc3nstr_process (lsaft, invres)
val () = lstaftc3nstr_finalize (lsaft) // HX: it must be processed
//
val () = if ~isexhaust then {
  val _(*err*) = the_effenv_caskind_check_exn (loc0, casknd)
} // end of [if] // end of [val]
//
in
  c3l (* single-clause expression *)
end // end of [c2laulst1_trdn]

(* ****** ****** *)
//
extern
fun
c2laulst2_trdn
(
  loc0: $LOC.location
, casknd: caskind
, invres: i2nvresstate
, c2l_fst: c2lau
, c2ls_rest: c2laulst
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
) : c3laulst
//
extern
fun
c2laulst2_trdn_rest
(
  loc0: $LOC.location
, casknd: caskind
, invres: i2nvresstate
, c3l_fst: c3lau
, lsbis: lstbefitmlst
, lsaft: !lstaftc3nstr
, c2ls_rest: c2laulst
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
, cp2tcss: &p2atcstlstlst_vt >> p2atcstlstlst_vt
) : c3laulst
//
(* ****** ****** *)

implement
c2laulst2_trdn
(
  loc0
, casknd, invres
, c2l_fst, c2ls_rest
, d3es, s2es_pat, s2e_res
) = let
//
val cp2tcss0 = (
  case+ casknd of
  | CK_case () => c2lau_pat_comp (c2l_fst)
  | CK_case_pos () => c2lau_pat_comp (c2l_fst)
  | CK_case_neg () => list_vt_nil ()
) : p2atcstlstlst_vt // end of [val]
var cp2tcss: p2atcstlstlst_vt = cp2tcss0
//
val lsbis =
  the_d2varenv_save_lstbefitmlst ()
val lsaft = lstaftc3nstr_initize (lsbis)
//
val loc_fst = c2l_fst.c2lau_loc()
val ctr = c3nstroptref_make_none (loc_fst)
val c3l_fst = let
  val cp2tcss1 = c2lau_pat_any (c2l_fst) in
  c2lau_trdn (casknd, c2l_fst, ctr, d3es, s2es_pat, s2e_res, cp2tcss1)
end // end of [val]
val () = lstaftc3nstr_update (lsaft, ctr)
//
val c3ls_all =
  c2laulst2_trdn_rest (
  loc0, casknd, invres, c3l_fst, lsbis, lsaft
, c2ls_rest, d3es, s2es_pat, s2e_res, cp2tcss
) (* end of [c3ls_all] *)
//
val isexhaust = ( // HX: always true for [case-]
  if list_vt_is_nil (cp2tcss) then true else false
) : bool // end of [val]
val () = if ~isexhaust then let
  val cp2tcss = p2atcstlstlst_vt_copy (cp2tcss) in
  trans3_env_add_patcstlstlst_false (loc0, casknd, cp2tcss, s2es_pat)
end // end of [if] // end of [val]
//
val () = p2atcstlstlst_vt_free (cp2tcss)
//
val () = lstaftc3nstr_process (lsaft, invres)
val () = lstaftc3nstr_finalize (lsaft) // HX: it must be processed
//
val () = if ~isexhaust then let
  val _(*err*) = the_effenv_caskind_check_exn (loc0, casknd)
in
  // nothing
end // end of [if] // end of [val]
//
in
  c3ls_all
end (* end of [c2laulst2_trdn] *)

(* ****** ****** *)
//
// HX-2026-10: the closures [auxred], [auxmain], [aux] of ATS1 are lambda-lifted
// (their free variables are arguments); the two recursions [aux] over the matrix
// are loops with an accumulator (the matrix can have 10^5 rows: PORTING.md, PC-3)
//
fun
c2laulst2_auxerr
(
  loc0: $LOC.location
, c2l: c2lau, xss: !p2atcstlstlst_vt
) : void = let
  val isnil = list_vt_is_nil (xss)
  val () =
  if isnil then {
    val () = prerr_error3_loc (c2l.c2lau_loc())
    val () = prerr_string ": this pattern match clause is redundant."
    val () = prerr_newline ()
    val () = the_trans3errlst_add (trans3err_T3E_c2laulst2_trdn_redundant (loc0, c2l))
  } (* end of [val] *)
in
  // nothing
end // end of [c2laulst2_auxerr]

fun
c2laulst2_auxred
(
  loc0: $LOC.location
, casknd: caskind
, c2l: c2lau, cp2tcss_inter: !p2atcstlstlst_vt
) : void = let
in
//
case+ casknd of
| CK_case () => c2laulst2_auxerr (loc0, c2l, cp2tcss_inter)
| CK_case_pos () => c2laulst2_auxerr (loc0, c2l, cp2tcss_inter)
| CK_case_neg () => ()
//
end // end of [c2laulst2_auxred]

// HX: the rows of [cp2tcss] that intersect [p2tcs_c2l] (copies, same order)
fun
c2laulst2_inter_loop
(
  ps: List0_vt (ptr)
, p2tcs_c2l: p2atcstlst, res: p2atcstlstlst_vt
) : p2atcstlstlst_vt =
(
case+ ps of
| ~list_vt_cons (p, ps) => let
    val xs = $UN.castvwtp1{p2atcstlst_vt} (p)
    val test =
      p2atcstlst_inter_test (p2atcstlst_of_vt (xs), p2tcs_c2l)
    // end of [val]
    val res =
    (
      if test
        then list_vt_cons (list_vt_copy<p2atcst> (xs), res) else res
    ) : p2atcstlstlst_vt
    val ((*dropped*)) = $UN.castvwtp0{void} (xs)
  in
    c2laulst2_inter_loop (ps, p2tcs_c2l, res)
  end // end of [list_vt_cons]
| ~list_vt_nil () => list_vt_reverse (res)
) (* end of [c2laulst2_inter_loop] *)

// HX: [diff] of every row, the results are appended in the order of the rows
fun
c2laulst2_diff_loop
(
  xss: p2atcstlstlst_vt
, p2tcs_c2l: p2atcstlst, res: p2atcstlstlst_vt
) : p2atcstlstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val diff = p2atcstlst_diff
      (p2atcstlst_of_vt (xs), p2tcs_c2l)
    val () = list_vt_free (xs)
  in
    c2laulst2_diff_loop (xss, p2tcs_c2l, list_vt_reverse_append (diff, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => list_vt_reverse (res)
) (* end of [c2laulst2_diff_loop] *)

fun
c2laulst2_auxmain
(
  loc0: $LOC.location
, casknd: caskind
, invres: i2nvresstate
, c2ls: c2laulst
, lsbis: lstbefitmlst
, lsaft: !lstaftc3nstr
, c3ls: c3laulst_vt
, d3es: d3explst
, s2es_pat: s2explst
, s2e_res: s2exp
, cp2tcss: &p2atcstlstlst_vt >> p2atcstlstlst_vt
) : c3laulst = let
in
case+ glist_view(c2ls) of
| ~GLcons
    (c2l, c2ls) => let
    val p2tcs_c2l = p2at2cstlst (c2l.c2lau_pat())
    val cp2tcss_inter =
      c2laulst2_inter_loop
        (cp2tcss_ptrs (cp2tcss), p2tcs_c2l, list_vt_nil ())
    // end of [val]
    val () = c2laulst2_auxred (loc0, casknd, c2l, cp2tcss_inter) // HX: redundancy checking
//
    val () = lstbefitmlst_restore_type (lsbis)
    val ctr = c3nstroptref_make_none (c2l.c2lau_loc())
    val c3l = c2lau_trdn (casknd, c2l, ctr, d3es, s2es_pat, s2e_res, cp2tcss_inter)
    val () = lstaftc3nstr_update (lsaft, ctr)
//
    val () = let
      val gua = c2l.c2lau_gua()
    in
      if glist_is_nil (gua)
        then let
          val cp2tcss0 = cp2tcss
        in
          cp2tcss := c2laulst2_diff_loop (cp2tcss0, p2tcs_c2l, list_vt_nil ())
        end // end of [nil]
        else ()
      // end of [if]
    end // end of [val]
    val c3ls = list_vt_cons (c3l, c3ls)
  in
    c2laulst2_auxmain
      (loc0, casknd, invres, c2ls, lsbis, lsaft, c3ls, d3es, s2es_pat, s2e_res, cp2tcss)
  end // end of [list_cons]
| ~GLnil () => let
    val c3ls = list_vt_reverse (c3ls) in l2l (c3ls)
  end // end of [list_nil]
end (* end of [c2laulst2_auxmain] *)

implement
c2laulst2_trdn_rest
(
  loc0
, casknd
, invres
, c3l_fst
, lsbis // : lstbefitmlst
, lsaft // : lstaftc3nstr // linear
, c2ls_rest
, d3es
, s2es_pat, s2e_res
, cp2tcss // : &patcstlstlst_vt
) = let
//
val c3ls_rest =
  c2laulst2_auxmain
    (loc0, casknd, invres, c2ls_rest, lsbis, lsaft, list_vt_nil (), d3es, s2es_pat, s2e_res, cp2tcss)
// end of [val]
in
  glist_cons (c3l_fst, c3ls_rest)
end // end of [c2laulst2_trdn_rest]

(* ****** ****** *)

implement
c2laulst_trdn
(
  loc0, casknd, invres, c2ls, d3es, s2es_pat, s2e_res
) = let
in
//
case+ glist_view(c2ls) of
| ~GLnil () => let
    val () = c2laulst0_trdn (loc0, casknd, s2es_pat, s2e_res)
  in
    glist_nil ()
  end // end of [list_nil]
| ~GLcons (c2l, c2ls) => (
    case+ glist_view(c2ls) of
    | ~GLnil () => let
        val c3l =
          c2laulst1_trdn (loc0, casknd, invres, c2l, d3es, s2es_pat, s2e_res)
        // end of [val]
      in
        glist_sing (c3l)
      end // end of [list_nil]
    | ~GLcons (c2l2, c2ls2) =>
        c2laulst2_trdn
          (loc0, casknd, invres, c2l, glist_cons (c2l2, c2ls2), d3es, s2es_pat, s2e_res)
        // end of [c2laulst2_trdn]
  ) // end of [list_cons]
//
end // end of [c2laulst_trdn]

(* ****** ****** *)

// HX: [list_map_fun (d3es, d3exp_get_type)] (head first)
fun
d3explst_get_type_loop
(
  d3es: d3explst, res: List0_vt(s2exp)
) : List0_vt(s2exp) =
(
  case+ glist_view(d3es) of
  | ~GLnil () => list_vt_reverse (res)
  | ~GLcons (d3e, d3es) => let
      val s2e = d3exp_get_type (d3e)
    in
      d3explst_get_type_loop (d3es, list_vt_cons (s2e, res))
    end // end of [GLcons]
) (* end of [d3explst_get_type_loop] *)

implement
d2exp_trdn_casehead
  (d2e0, s2f0) = let
val loc0 = d2e0.d2exp_loc()
val-~D2Ecasehead (casknd, invres, d2es, c2ls) = d2exp_node_view(d2e0.d2exp_node())
val s2e0 = s2hnf2exp (s2f0)
//
val d3es = d2explst_trup (d2es)
val _(*void*) = d3explst_open_and_add (d3es)
val s2es_pat = l2l (d3explst_get_type_loop (d3es, list_vt_nil ()))
val c3ls =
  c2laulst_trdn (loc0, casknd, invres, c2ls, d3es, s2es_pat, s2e0)
//
val () = i2nvresstate_update (loc0, invres)
//
in
  d3exp_case (loc0, s2e0, casknd, d3es, c3ls)
end (* end of [d2exp_trdn_casehead] *)

(* ****** ****** *)

implement
d2exp_trdn_scasehead
  (d2e0, s2f0) = let
//
val loc0 = d2e0.d2exp_loc()
val-~D2Escasehead (invres, s2e_val, sc2ls) = d2exp_node_view(d2e0.d2exp_node())
val s2e0 = s2hnf2exp (s2f0)
//
val lsbis =
  the_d2varenv_save_lstbefitmlst ()
val lsaft = lstaftc3nstr_initize (lsbis)
//
fun auxscl (
  sc2l: sc2lau
, s2e_val: s2exp
, s2e_res: s2exp
, isfst: bool
, lsbis: lstbefitmlst
, lsaft: !lstaftc3nstr
) : sc3lau = let
  val loc0 = sc2l.sc2lau_loc()
  val () =
    if not(isfst) then lstbefitmlst_restore_type (lsbis)
  // end of [val]
  val ctr = c3nstroptref_make_none (loc0)
  val sp2t = sc2l.sc2lau_pat()
  val d2e_body = sc2l.sc2lau_body()
  val () = trans3_env_push ()
  val () = trans3_env_add_sp2at (sp2t)
  val () = $SOL.s2exp_hypequal_solve (sp2t.sp2at_loc(), s2e_val, sp2t.sp2at_exp())
  val d3e_body = d2exp_trdn (d2e_body, s2e_res)
  val () = trans3_env_add_cnstr_ref (ctr)
  val () = trans3_env_pop_and_add_main (loc0)
  val () = lstaftc3nstr_update (lsaft, ctr)
in
  sc3lau_make (loc0, sp2t, d3e_body)
end // end of [auxscl]
//
fun auxsclist (
  sc2ls: sc2laulst
, s2e_val: s2exp
, s2e_res: s2exp
, isfst: bool
, lsbis: lstbefitmlst
, lsaft: !lstaftc3nstr
) : sc3laulst =
  case+ glist_view(sc2ls) of
  | ~GLcons
      (sc2l, sc2ls) => let
      val sc3l = auxscl (
        sc2l, s2e_val, s2e_res, isfst, lsbis, lsaft
      ) // end of [val]
      val sc3ls = auxsclist (
        sc2ls, s2e_val, s2e_res, false(*isfst*), lsbis, lsaft
      ) // end of [val]
    in
      glist_cons (sc3l, sc3ls)
    end // end of [list_cons]
  | ~GLnil () => glist_nil ()
// end of [auxsclist]
//
val sc3ls = auxsclist
  (sc2ls, s2e_val, s2e0, true(*isfst*), lsbis, lsaft)
//
val () = lstaftc3nstr_process (lsaft, invres)
val () = lstaftc3nstr_finalize (lsaft) // HX: it must be processed
//
val () = i2nvresstate_update (loc0, invres)
//
in
  d3exp_scase (loc0, s2e0, s2e_val, sc3ls)
end // end of [d2exp_trdn_scasehead]

(* ****** ****** *)

(* end of [pats_trans3_caseof.dats] *)
