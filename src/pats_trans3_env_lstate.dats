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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_lstate.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The linear state [lstaftc3nstr] is a handle ([ptr]) of an arena record with [mut] fields (pats_trans3_env_lstate.spec).
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

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement
prerr_FILENAME<> () = prerr "pats_trans3_lstate"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_error.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "./pats_staexp2_solve.sats"

(* ****** ****** *)

staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"
staload "./pats_trans3_env_lstate.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

#include "./pats_trans3_env_lstate_gen_dats.hats"

(* ****** ****** *)

implement
lstbefitm_make
  (d2v, linval) = let
  val opt = d2var_get_type (d2v) in lstbefitm_new (d2v, linval, opt)
end // end of [lstbefitm_make]

(* ****** ****** *)

implement
fprint_lstbefitm (out, x) = let
//
macdef
  prstr (s) = fprint_string (out, ,(s))
// end of [macdef]
val () = prstr "lstbefitm("
val () = fprint_d2var (out, x.lstbefitm_var ())
val () = prstr ", "
val () = fprint_int (out, x.lstbefitm_linval ())
val () = prstr ", "
val opt = x.lstbefitm_type ()
val () = (
  case+ gopt_view (opt) of
  | ~GOsome (s2e) =>
      (prstr "Some("; fprint_s2exp (out, s2e); prstr ")")
  | ~GOnone () => prstr "None()"
) : void // end of [val]
val () = prstr ")" // end of [val]
//
in
  // nothing
end // end of [fprint_lstbefitm]

implement
fprint_lstbefitmlst
  (out, xs) = $UT.fprintlst<lstbefitm> (out, xs, ", ", fprint_lstbefitm)
// end of [fprint_lstbefitmlst]

(* ****** ****** *)

implement
lstbefitmlst_restore_type
  (xs) = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => (
      d2var_set_type (x.lstbefitm_var (), x.lstbefitm_type ());
      lstbefitmlst_restore_type (xs)
    )
  | ~GLnil () => ()
) // end of [lstbefitmlst_restore_type]

implement
lstbefitmlst_restore_linval_type
  (xs) = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => let
      val d2v = x.lstbefitm_var ()
      val () =
        d2var_set_linval (d2v, x.lstbefitm_linval ())
      val () = d2var_set_type (d2v, x.lstbefitm_type ())
    in
      lstbefitmlst_restore_linval_type (xs)
    end // end of [f]
  | ~GLnil () => ()
) // end of [lstbefitmlst_restore_linval_type]

(* ****** ****** *)

fun
fprint_saityp (out: FILEref, x: s2expopt): void = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
  case+ gopt_view (x) of
  | ~GOsome (s2e) =>
      (prstr "Some("; fpprint_s2exp (out, s2e); prstr ")")
  | ~GOnone () => prstr "None()"
end // end of [fprint_saityp]

fun
fprint_saityplst
  (out: FILEref, xs: saityplst): void = $UT.fprintlst<s2expopt> (out, xs, ", ", fprint_saityp)
// end of [fprint_saityplst]

(* ****** ****** *)

fun
saityplst_check_auxlst (
  s2e0: s2exp, xs: saityplst
) : int = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => (
    case+ gopt_view (x) of
    | ~GOsome (s2e) => let
        val iseq = s2exp_refeq (s2e0, s2e)
      in
        if iseq then saityplst_check_auxlst (s2e0, xs) else 1(*merge*)
      end // end of [SAITYPsome]
    | ~GOnone () => saityplst_check_auxlst (s2e0, xs)
    ) // end of [list_cons]
  | ~GLnil () => 0 (*skip*)
) // end of [auxlst_check]

// HX: 0/1: skip/merge
fun
saityplst_check
  (d2v: d2var, xs: saityplst): int = let
  val-~GLcons (x, xs) = glist_view (xs)
in
//
case+ gopt_view (x) of
| ~GOsome (s2e0) => let
    val () = d2var_set_type (d2v, gopt_some s2e0)
  in
    saityplst_check_auxlst (s2e0, xs)
  end // end of [None]
| ~GOnone () => let
    val () = d2var_set_type (d2v, gopt_none ()) in 0(*skip*)
  end // end of [None]
//
end // end of [saityplst_check]

(* ****** ****** *)

fun
fprint_lstaftitm
  (out: FILEref, x: lstaftitm): void = let
  macdef prstr (s) =
    fprint_string (out, ,(s))
  val () = prstr "LSTAFTITM(\n"
  val () = fprint_d2var (out, x.lstaftitm_var ())
  val () = prstr "\n"
  val () = fprint_int (out, x.lstaftitm_knd ())
  val () = prstr "\n"
  val () = fprint_s2expopt (out, x.lstaftitm_type ())
  val () = prstr "\n"
  val () = fprint_saityplst (out, x.lstaftitm_saits ())
  val () = prstr "\n)"
in
  // nothing
end // end of [fprint_lstaftitm]

fun
fprint_lstaftitmlst
  (out: FILEref, xs: lstaftitmlst): void = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) => let
      val () = fprint_lstaftitm (out, x)
      val () = fprint_newline (out)
      val () = fprint_lstaftitmlst (out, xs1)
    in
      // nothing
    end // end of [list_vt_cons]
  | ~GLnil () => ()
) // end of [fprint_lstaftitmlst]

fun
lstaftitmlst_free (xs: lstaftitmlst): void = (
  case+ glist_view (xs) of
  | ~GLcons
      (x, xs) => let
      val () = assertloc (glist_is_nil (x.lstaftitm_saits ()))
    in
      lstaftitmlst_free (xs)
    end // end of [list_vt_cons]
  | ~GLnil () => ()
) // end of [lstaftitmlst_free]

(* ****** ****** *)

fun
lstaftitmlst_make
  (xs: lstbefitmlst): lstaftitmlst = (
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => let
      val d2v = x.lstbefitm_var ()
      val item = lstaftitm_new (d2v, 0(*default*), gopt_none() (*default*), glist_nil ())
    in
      glist_cons (item, lstaftitmlst_make (xs))
    end
  | ~GLnil () => glist_nil ()
) // end of [lstaftitmlst_make]

(* ****** ****** *)

fun
lstaftitmlst_update (xs: lstaftitmlst): void =
(
//
case+ glist_view (xs) of
| ~GLcons (x, xs1) => let
    val d2v = x.lstaftitm_var ()
    val sait = d2var_get_type (d2v)
    val saits = x.lstaftitm_saits ()
    val () = set_lstaftitm_saits (x, glist_cons (sait, saits))
  in
    lstaftitmlst_update (xs1)
  end // end of [list_vt_cons]
| ~GLnil () => ()
//
) // end of [lstaftitmlst_update]

(* ****** ****** *)

fun
lstaftitmlst_reverse
  (xs: lstaftitmlst): void = // reverse saityplst
(
//
case+ glist_view (xs) of
| ~GLcons (x, xs1) => let
    val saits = x.lstaftitm_saits ()
    val () = set_lstaftitm_saits (x, glist_reverse (saits))
  in
    lstaftitmlst_reverse (xs1)
  end // end of [list_vt_cons]
| ~GLnil () => ()
//
) // end of [lstaftitmlst_reverse]

(* ****** ****** *)

assume lstaftc3nstr_vtype = ptr

fn
lsaft_get (x: !lstaftc3nstr): lstaftc3nstr_rec = $UN.castvwtp1{lstaftc3nstr_rec}(x)

(* ****** ****** *)

implement
fprint_lstaftc3nstr
  (out, x) = let
//
val rc = lsaft_get (x)
val () = fprint_lstaftitmlst (out, rc.lstaftc3nstr_rec_lsais ())
//
in
  // nothing
end // end of [fprint_lstaftc3nstr]

(* ****** ****** *)

implement
lstaftc3nstr_initize
  (lsbis) = let
//
val lsais = lstaftitmlst_make (lsbis)
val ctrs = glist_nil ()
//
in
  $UN.castvwtp0{lstaftc3nstr} (lstaftc3nstr_rec_new (lsais, ctrs))
end // end of [lstaftc3nstr_initize]

(* ****** ****** *)

implement
lstaftc3nstr_update
  (lsaft, ctr) = let
//
val rc = lsaft_get (lsaft)
val () = lstaftitmlst_update (rc.lstaftc3nstr_rec_lsais ())
val () = set_lstaftc3nstr_rec_ctrs (rc, glist_cons (ctr, rc.lstaftc3nstr_rec_ctrs ()))
//
in
  // nothing
end // end of [lstaftc3nstr_update]

(* ****** ****** *)

implement
lstaftc3nstr_finalize
  (lsaft) = let
//
val rc = $UN.castvwtp0{lstaftc3nstr_rec} (lsaft)
val () = lstaftitmlst_free (rc.lstaftc3nstr_rec_lsais ())
val () = assertloc (glist_is_nil (rc.lstaftc3nstr_rec_ctrs ())) // HX: [ctrs] should be nil!
//
in
  // nothing
end // end of [lstaftc3nstr_finalize]

(* ****** ****** *)

fun
d2var_is_done
  (d2v: d2var): bool = let
  val opt = d2var_get_finknd (d2v)
in
  d2vfin_is_D2VFINdone (opt)
end // end of [d2var_is_done]

fun
lstaftc3nstr_check_aux1
  (xs: lstaftitmlst): d2varlst_vt =
(
//
case+ glist_view (xs) of
| ~GLcons (x, xs1) => let
    val d2v = x.lstaftitm_var ()
    val ans = let
      val isdone = d2var_is_done (d2v)
    in
      if isdone then 0 else let
        val saits = x.lstaftitm_saits ()
      in
        saityplst_check (d2v, saits)
      end // end of [if]
    end : int // end of [val]
    val d2vs = lstaftc3nstr_check_aux1 (xs1)
  in
    if ans(*merge*) > 0 then list_vt_cons (d2v, d2vs) else d2vs
  end // end of [list_vt_cons]
| ~GLnil () => list_vt_nil ()
//
) // end of [aux1]

fun
lstaftc3nstr_check_aux2
(
  d2v0: d2var, d2vs: d2varlst, k: &int >> _
) : s2expopt =
(
//
case+ glist_view (d2vs) of
| ~GLcons
    (d2v, d2vs) => let
    val sgn = compare (d2v0, d2v)
  in
    if sgn = 0 then let
      val opt = d2var_get_mastype (d2v) in (k := 1; opt)
    end else
      lstaftc3nstr_check_aux2 (d2v0, d2vs, k)
    // end of [if]
  end // end of [list_cons]
| ~GLnil () => gopt_none ()
//
) // end of [aux2]

fun
lstaftc3nstr_check_aux3
(
  d2v0: d2var
, args: i2nvarglst, d2vs: d2varlst, k: &int >> _
) : s2expopt =
(
//
case+ glist_view (args) of
| ~GLcons
    (arg, args) => let
    val d2v =
      i2nvarg_get_var (arg)
    // end of [val]
    val sgn = compare (d2v0, d2v)
  in
    if sgn = 0 then let
      val () = k := 2 in i2nvarg_get_type (arg)
    end else
      lstaftc3nstr_check_aux3 (d2v0, args, d2vs, k)
    // end of [if]
  end // end of [list_cons]
| ~GLnil () => lstaftc3nstr_check_aux2 (d2v0, d2vs, k)
//
) // end of [aux3]

fun
lstaftc3nstr_check_auxlst
(
  xs: lstaftitmlst, args: i2nvarglst, d2vs: d2varlst
) : void = let
in
//
case+ glist_view (xs) of
| ~GLcons (x, xs1) => let
    val d2v0 = x.lstaftitm_var ()
    var knd: int = 0
    val opt = lstaftc3nstr_check_aux3 (d2v0, args, d2vs, knd)
    val () = set_lstaftitm_knd (x, knd)
    val () = set_lstaftitm_type (x, opt)
    val () = if knd > 0 then d2var_set_type (d2v0, opt)
  in
    lstaftc3nstr_check_auxlst (xs1, args, d2vs)
  end // end of [list_vt_cons]
| ~GLnil () => ()
//
end // end of [auxlst]

fun
lstaftc3nstr_check
  (lsaft: !lstaftc3nstr, invres: i2nvresstate): void = let
//
val rc = lsaft_get (lsaft)
val lsais = rc.lstaftc3nstr_rec_lsais ()
//
val d2vs = lstaftc3nstr_check_aux1 (lsais)
//
val () = let
  val args = invres.i2nvresstate_arg ()
  val d2vs1 = glist_make_list_vt (list_vt_copy (d2vs))
in
  lstaftc3nstr_check_auxlst (lsais, args, d2vs1)
end // end of [val]
//
val () = list_vt_free (d2vs)
//
in
  // nothing
end // end of [lstaftc3nstr_check]

(* ****** ****** *)

fun
lstaftc3nstr_auxerr_some
(
  loc: loc_t, d2v: d2var, s2e0: s2exp
) : void = let
  val () = prerr_error3_loc (loc)
  val () = prerr ": the dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] is consumed but it should be retained with the type ["
  val () = prerr_s2exp (s2e0)
  val () = prerr "] instead."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d2var_some (loc, d2v, s2e0))
end // end of [auxerr_some]

fun
lstaftc3nstr_auxerr_none
(
  loc: loc_t, d2v: d2var, s2e: s2exp
) : void = let
  val () = prerr_error3_loc (loc)
  val () = prerr ": the dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] is retained with the type ["
  val () = prerr_s2exp (s2e)
  val () = prerr "] but it should be consumed instead."
  val () = prerr_newline ()
in
  the_trans3errlst_add (trans3err_T3E_d2var_some (loc, d2v, s2e))
end // end of [auxerr_none]

fun
lstaftc3nstr_auxerr_some2
(
  loc: loc_t, d2v: d2var, s2e0: s2exp, s2e: s2exp
) : void = let
  val () = prerr_error3_loc (loc)
  val () = prerr ": the dynamic variable ["
  val () = prerr_d2var (d2v)
  val () = prerr "] is retained but with a type that fails to merge."
  val () = prerr_newline ()
  val () = prerr_the_staerrlst ()
in
  the_trans3errlst_add (trans3err_T3E_d2var_some2 (loc, d2v, s2e0, s2e))
end // end of [auxerr_some2]

fun
lstaftc3nstr_auxsait
(
  loc: loc_t
, d2v: d2var (* perform merge for [d2v] *)
, knd: int // HX: 0/1/2 : skip/merge/sub+merge
, sub: !stasub
, sait0: s2expopt, sait: s2expopt
) : void = let
in
//
case+ gopt_view (sait0) of
| ~GOsome(s2e0) => (
  case+ gopt_view (sait) of
  | ~GOsome(s2e) => (
    if knd >= 1 then let
        val
        s2e0 = (
          if knd >= 2
            then s2exp_subst (sub, s2e0) else s2e0
          // end of [if]
        ) : s2exp // end of [val]
//
        val () = trans3_env_push()
        val err = $SOL.s2exp_tyleq_solve (loc, s2e, s2e0)
        val knd = c3nstrkind_C3TKlstate_var (d2v)
        val ((*void*)) = trans3_env_pop_and_add (loc, knd)
//
        val () =
        if (err > 0) then {
          val () = prerr_the_staerrlst ()
          val () = lstaftc3nstr_auxerr_some2 (loc, d2v, s2e0, s2e)
        } (* end of [if] *) // end of [val]
      in
        // nothing
      end else () (* knd = 0 *)
    ) // end of [Some]
  | ~GOnone ((*void*)) => lstaftc3nstr_auxerr_some (loc, d2v, s2e0)
  )
| ~GOnone((*void*)) =>
  (
    case+ gopt_view (sait) of
    | ~GOsome(s2e) => lstaftc3nstr_auxerr_none (loc, d2v, s2e) | ~GOnone() => ()
  ) (* end of [None] *)
//
end // end of [auxsait]

fun
lstaftc3nstr_auxmain
(
  xs: lstaftitmlst
, ctr: c3nstroptref, sub: !stasub
) : void = (
  case+ glist_view (xs) of
  | ~GLcons
      (x, xs1) => let
      val d2v = x.lstaftitm_var ()
      val knd = x.lstaftitm_knd ()
      val sait0 = d2var_get_type (d2v)
      val saits = x.lstaftitm_saits ()
      val-~GLcons (sait, saits) = glist_view (saits)
      val () = set_lstaftitm_saits (x, saits)
      val ctrloc = ctr.c3nstroptref_loc ()
      val () = lstaftc3nstr_auxsait (ctrloc, d2v, knd, sub, sait0, sait)
    in
      lstaftc3nstr_auxmain (xs1, ctr, sub)
    end // end of [list_vt_cons]
  | ~GLnil () => ()
) // end of [auxmain]

fun
lstaftc3nstr_auxmainlst
(
  xs: lstaftitmlst
, ctrs: c3nstroptreflst, invres: i2nvresstate
) : void = let
in
//
case+ glist_view (ctrs) of
| ~GLcons
    (ctr, ctrs) => let
    val ctrloc = ctr.c3nstroptref_loc ()
    val sub =
      stasub_make_svarlst (ctrloc, invres.i2nvresstate_svs ())
    val s2ps = s2explst_subst_vt (sub, invres.i2nvresstate_gua ())
//
    val () = trans3_env_push()
//
    val () = trans3_env_add_proplst_vt (ctrloc, s2ps)
    val () = lstaftc3nstr_auxmain (xs, ctr, sub)
//
    val s3is = trans3_env_pop ()
    val c3t0 =
      c3nstr_itmlst (ctrloc, c3nstrkind_C3TKlstate(), l2l(s3is))
    val () = set_c3nstroptref_val (ctr, gopt_some (c3t0))
//
    val () = stasub_free (sub)
  in
    lstaftc3nstr_auxmainlst (xs, ctrs, invres)
  end // end of [list_vt_cons]
//
| ~GLnil((*void*)) => ()
//
end // end of [auxmainlst]

implement
lstaftc3nstr_process
  (lsaft, invres) = let
//
val () =
  lstaftc3nstr_check (lsaft, invres)
//
val rc = lsaft_get (lsaft)
//
val ctrs = rc.lstaftc3nstr_rec_ctrs ()
val () = set_lstaftc3nstr_rec_ctrs (rc, glist_nil ())
val () = lstaftc3nstr_auxmainlst (rc.lstaftc3nstr_rec_lsais (), ctrs, invres)
//
in
  // nothing
end // end of [lstaftc3nstr_process]

(* ****** ****** *)

implement
i2nvarglst_update
  (loc, args) = let
in
//
case+ glist_view (args) of
| ~GLcons
    (arg, args) => let
//
    val d2v = i2nvarg_get_var (arg)
    val opt = i2nvarg_get_type (arg)
    val () =
      d2var_inc_linval (d2v)
    // end of [val]
//
    val () = d2var_set_type (d2v, opt)
//
  in
    i2nvarglst_update (loc, args)
  end // end of [list_cons]
| ~GLnil () => ()
//
end // end of [i2nvarglst_update]

(* ****** ****** *)

implement
i2nvresstate_update
  (loc, invres) = let
//
val () =
  trans3_env_add_svarlst (invres.i2nvresstate_svs ())
val () =
  trans3_env_hypadd_proplst (loc, invres.i2nvresstate_gua ())
//
in
//
// HX-2012-08:
// updating is already done during merge but this is
  i2nvarglst_update (loc, invres.i2nvresstate_arg ()) // more appropriate
//
end // end of [i2nvresstate_update]

(* ****** ****** *)

(* end of [pats_trans3_lstate.dats] *)
