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
// Start Time: December, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_staexp2_szexp.dats, see PORTING.md)
// It needs [s2exp_hnfize], [s2exp2hnf] and [s2explst_syneq] of pats_staexp2_util2.dats.
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

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_staexp2_szexp"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"
overload = with $LAB.eq_label_label

(* ****** ****** *)

staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

extern
fun fprint_labs2zexp (out: FILEref, x: labs2zexp): void

implement
fprint_s2zexp (out, x) = let
  macdef prstr (x) = fprint_string (out, ,(x))
in
//
case+ s2zexp_view (x) of
//
| ~S2ZEprf () => prstr "S2ZEprf()"
//
| ~S2ZEptr () => prstr "S2ZEptr()"
//
| ~S2ZEcst (s2c) => {
    val () = prstr "S2ZEcst("
    val () = fprint_s2cst (out, s2c)
    val () = prstr ")"
  }
| ~S2ZEvar (s2v) => {
    val () = prstr "S2ZEvar("
    val () = fprint_s2var (out, s2v)
    val () = prstr ")"
  }
//
| ~S2ZEVar (s2V) => {
    val () = prstr "S2ZE("
    val () = fprint_s2Var (out, s2V)
    val () = prstr ")"
  }
//
| ~S2ZEextype
    (name, _arg) => {
    val () = prstr "S2ZEextype("
    val () = fprint_string (out, name)
    val () = prstr ")"
  } // end of [S2ZEextype]
| ~S2ZEextkind
    (name, _arg) => {
    val () = prstr "S2ZEextkind("
    val () = fprint_string (out, name)
    val () = prstr ")"
  } // end of [S2ZEextkind]
//
| ~S2ZEapp (_fun, _arg) => {
    val () = prstr "S2ZEapp("
    val () = fprint_s2zexp (out, _fun)
    val () = prstr "; "
    val () = $UT.fprintlst<s2zexp> (out, _arg, ", ", fprint_s2zexp)
    val () = prstr ")"
  } // end of [S2ZEapp]
//
| ~S2ZEtyarr(_elt, _dim) => {
    val () = prstr "S2ZEtyarr("
    val () = fprint_s2zexp (out, _elt)
    val () = prstr "; "
    val () = fprint_s2explst (out, _dim)
    val () = prstr ")"
  } // end of [S2ZEtyarr]
| ~S2ZEtyrec(knd, ls2zes) => {
    val () = prstr "S2ZEtyrec("
    val () = $UT.fprintlst<labs2zexp> (out, ls2zes, ", ", fprint_labs2zexp)
    val () = prstr ")"
  } // end of [S2ZEtyrec]
//
| ~S2ZEclo () => prstr "S2ZEclo()"
//
| ~S2ZEbot () => prstr "S2ZEbot()"
//
end // end of [fprint_s2zexp]

implement
print_s2zexp (x) = fprint_s2zexp (stdout_ref, x)
implement
prerr_s2zexp (x) = fprint_s2zexp (stderr_ref, x)

implement
fprint_labs2zexp
  (out, x) = let
  val l = labs2zexp_lab (x)
  val s2ze = labs2zexp_elt (x)
  val () = $LAB.fprint_label (out, l)
  val () = fprint_string (out, "=")
  val () = fprint_s2zexp (out, s2ze)
in
  // nothing
end // end of [fprint_labs2zexp]

(* ****** ****** *)

implement
s2zexp_is_bot (x) = s2zexp_is_S2ZEbot (x)
// end of [s2zexp_is_bot]

(* ****** ****** *)

extern
fun s2zexp_make_s2cst (s2c: s2cst): s2zexp
implement s2zexp_make_s2cst (s2c) = s2zexp_S2ZEcst s2c

(* ****** ****** *)

(*
** HX: the environment is the stack of the lists of the bound variables:
** an immutable [glist] (it was a linear list that was freed at the end)
*)
typedef env = s2varlstlst
//
fn szenv_make_nil (): env = glist_nil ()
fn szenv_pop (env: &env >> _): void =
  if glist_is_cons (env) then env := glist_tail (env)
fn szenv_push (env: &env >> _, s2vs: s2varlst): void = env := glist_cons (s2vs, env)
fn szenv_free (env: env): void = ()
fun szenv_find (env: &env >> _, x0: s2var): bool = let
  fun loop1 (s2vs: s2varlst, x0: s2var): bool =
    case+ glist_view (s2vs) of
    | ~GLcons (s2v, s2vs) =>
        if x0 = s2v then true else loop1 (s2vs, x0)
    | ~GLnil () => false
  // end of [loop1]
  fun loop2 (s2vss: s2varlstlst, x0: s2var): bool =
    case+ glist_view (s2vss) of
    | ~GLcons (s2vs, s2vss) =>
        if loop1 (s2vs, x0) then true else loop2 (s2vss, x0)
    | ~GLnil () => false
  // end of [loop2]
in
  loop2 (env, x0)
end // end of [szenv_find]

(* ****** ****** *)

local

fun
s2zexp_tyrec
(
  knd: tyreckind, lxs: labs2zexplst
) : s2zexp = let
//
val isflt = 
(
  if tyreckind_is_TYRECKINDflt0 (knd) then true
  else if tyreckind_is_TYRECKINDflt1 (knd) then true
  else false (* non-flt01 *)
)
in
//
if
isflt
then (
  case+ glist_view (lxs) of
  | ~GLcons
    (
      lx, lxs2
    ) => // list_cons
    if glist_is_nil (lxs2)
      then labs2zexp_elt (lx) else s2zexp_S2ZEtyrec(knd, lxs)
  | ~GLnil () => s2zexp_S2ZEtyrec(knd, lxs)
) else s2zexp_S2ZEtyrec(knd, lxs)
//
end // end of [s2zexp_tyrec]

fun
aux_s2exp
(
  env: &env >> _, s2e0: s2exp
) : s2zexp = let
//
val
s2f0 = s2exp_hnfize(s2e0)
//
val s2t0 = s2exp_srt (s2f0)
//
in
//
if
s2rt_is_prf(s2t0) then s2zexp_S2ZEprf()
else if
s2rt_is_boxed(s2t0) then s2zexp_S2ZEptr()
else
(
case+
s2exp_node_view (s2exp_node (s2f0))
of (* case+ *)
//
| ~S2Ecst(s2c) => let
    val isabs = s2cst_get_isabs(s2c)
  in
    case+ gopt_view (isabs) of
    | ~GOsome (opt) => (
      case+ gopt_view (opt) of
      | ~GOsome (s2e) => aux_s2exp(env, s2e)
      | ~GOnone () => s2zexp_make_s2cst(s2c)
      )
    | ~GOnone () => s2zexp_make_s2cst(s2c)
  end // end of [S2Ecst]
//
| ~S2Evar(s2v) => let
    val isexi = szenv_find(env, s2v)
  in
    if isexi
      then s2zexp_S2ZEbot() else s2zexp_S2ZEvar(s2v)
    // end of [if]
  end // end of [S2Evar]
//
| ~S2EVar(s2V) => let
    val s2ze = s2Var_get_szexp(s2V) in s2ze
  end // end of [S2EVar]
//
| ~S2Eextype (name, _arg) =>
    s2zexp_S2ZEextype (name, aux_arglstlst (env, _arg))
| ~S2Eextkind(name, _arg) =>
    s2zexp_S2ZEextkind (name, aux_arglstlst (env, _arg))
//
| ~S2Eapp(s2e_fun, s2es_arg) =>
    aux_s2exp_app (env, s2exp_srt (s2f0), s2e_fun, s2es_arg)
  // end of [S2Eapp]
//
| ~S2Efun (_, _, _, _, _, _) => s2zexp_S2ZEclo () // HX: it is unboxed
//
| ~S2Etop(knd, s2e) => aux_s2exp (env, s2e)
//
| ~S2Etyarr(_elt, _dim) => let
    val _elt = aux_s2exp (env, _elt) in s2zexp_S2ZEtyarr(_elt, _dim)
  end // end of [S2Etyarr]
| ~S2Etyrec(knd, npf, ls2es) => let
    val ls2zes =
      aux_labs2explst(env, npf, ls2es) in s2zexp_tyrec(knd, ls2zes)
    // end of [val]
  end // end of [S2Etyrec]
//
| ~S2Eexi (
    s2vs, _(*s2ps*), s2e
  ) => let
    val () = szenv_push(env, s2vs)
    val s2ze = aux_s2exp (env, s2e)
    val ((*popped*)) = szenv_pop(env)
  in
    s2ze
  end // end of [S2Eexi]
| ~S2Euni (
    s2vs, _(*s2ps*), s2e
  ) => let
    val () = szenv_push(env, s2vs)
    val s2ze = aux_s2exp(env, s2e)
    val ((*popped*)) = szenv_pop(env)
  in
    s2ze
  end // end of [S2Eexi]
//
| ~S2Einvar(s2e) => aux_s2exp(env, s2e)
//
| ~S2Evararg _ => s2zexp_S2ZEbot() // HX: no info
//
| ~S2Ewthtype(s2e, _) => aux_s2exp(env, s2e)
//
| v (*rest-of-s2zexp*) => (s2exp_node_view_free (v); s2zexp_S2ZEbot()) // HX: no info
) (* end of [else] *)
end // end of [aux_s2exp]

and
aux_s2exp_app
(
  env: &env >> _
, s2t: s2rt, s2e_fun: s2exp, s2es_arg: s2explst
) : s2zexp = let
  val s2f_fun = s2exp_hnfize (s2e_fun)
in
  case+ s2exp_node_view (s2exp_node (s2f_fun)) of
  | ~S2Ecst s2c => let
      val isabs = s2cst_get_isabs (s2c)
    in
      case+ gopt_view (isabs) of
      | ~GOsome (opt) => (
        case+ gopt_view (opt) of
        | ~GOsome (s2e_fun) => let
            val s2e = s2exp_app_srt (s2t, s2e_fun, s2es_arg)
          in
            aux_s2exp (env, s2e)
          end // end of [Some]
        | ~GOnone () => aux_s2exp_app_dflt (env, s2c, s2es_arg)
        )
      | ~GOnone () => aux_s2exp_app_dflt (env, s2c, s2es_arg)
    end (* end of [S2Ecst] *)
  | v => (s2exp_node_view_free (v); s2zexp_S2ZEbot ()) (* HX: really??? *)
end // end of [aux_s2exp_app]

and
aux_s2exp_app_dflt
(
  env: &env >> _, s2c: s2cst, s2es_arg: s2explst
) : s2zexp = let
  val s2ze_fun = s2zexp_make_s2cst (s2c)
in
  s2zexp_S2ZEapp (s2ze_fun, aux_arglst (env, s2es_arg))
end // HX: can be incorrect for certain constructors

and
aux_arglst (
  env: &env >> _, s2es: s2explst
) : s2zexplst =
  case+ glist_view (s2es) of
  | ~GLcons
      (s2e, s2es) => let
      val s2t = s2exp_srt (s2e)
      val keep = (
        if s2rt_is_prgm (s2t) then true else s2rt_is_tkind (s2t)
      ) : bool // end of [val]
    in
      if keep then let
        val x = aux_s2exp (env, s2e)
      in
        glist_cons (x, aux_arglst (env, s2es))
      end else
        aux_arglst (env, s2es) // HX: non-types are all discarded
      // end of [if]
    end // end of [list_cons]
  | ~GLnil () => glist_nil ()
// end of [aux_arglst]

and
aux_arglstlst (
  env: &env >> _, s2ess: s2explstlst
) : s2zexplstlst =
  case+ glist_view (s2ess) of
  | ~GLcons (s2es, s2ess) => let
      val x = aux_arglst (env, s2es)
    in
      glist_cons (x, aux_arglstlst (env, s2ess))
    end
    // end of [list_cons]
  | ~GLnil () => glist_nil ()
// end of [aux_arglstlst]

and
aux_labs2explst
(
  env: &env >> _, npf: int, ls2es: labs2explst
) : labs2zexplst =
  case+ glist_view (ls2es) of
  | ~GLcons (ls2e, ls2es) =>
      if npf > 0 then
        aux_labs2explst (env, npf-1, ls2es)
      else let
        val l = labs2exp_lab (ls2e)
        val s2e = labs2exp_elt (ls2e)
        val s2ze = aux_s2exp (env, s2e)
        val ls2ze = labs2zexp_new (l, s2ze)
      in
        glist_cons (ls2ze, aux_labs2explst (env, npf, ls2es))
      end (* end of [if] *)
    // end of [list_cons]
  | ~GLnil () => glist_nil ()
// end of [aux_labs2explst]

in // in of [local]

implement
s2zexp_make_s2exp
  (s2e0) = s2ze where
{
//
var env = szenv_make_nil()
val s2ze = aux_s2exp(env, s2e0)
val ((*void*)) = szenv_free(env)
//
} // end of [s2zexp_make_s2exp]

end // end of [local]

(* ****** ****** *)

exception S2ZEXPMERGEexn of ()

extern
fun s2zexp_merge_exn
  (x1: s2zexp, x2: s2zexp): s2zexp
// end of [s2zexp_merge_exn]
extern
fun s2zexplst_merge_exn
  (xs1: s2zexplst, xs2: s2zexplst): s2zexplst
// end of [s2zexplst_merge_exn]
extern
fun s2zexplstlst_merge_exn
  (xss1: s2zexplstlst, xss2: s2zexplstlst): s2zexplstlst
// end of [s2zexplstlst_merge_exn]
extern
fun labs2zexplst_merge_exn
  (lxs1: labs2zexplst, lxs2: labs2zexplst): labs2zexplst
// end of [labs2zexplst_merge_exn]

(* ****** ****** *)

fun
s2zexp_linkrem
  (x: s2zexp): s2zexp = case+ s2zexp_view (x) of
  | ~S2ZEVar (s2V) => s2Var_get_szexp (s2V)
  | v => (s2zexp_view_free (v); x)
// end of [s2zexp_linkrem]

(* ****** ****** *)

fun
s2zexp_merge_abort
(
// argless
) : s2zexp = $raise S2ZEXPMERGEexn()

fn
s2zexp_getVar (x: s2zexp): s2Var =
(
case+ s2zexp_view (x) of
| ~S2ZEVar (s2V) => s2V
| v => (s2zexp_view_free (v); $UN.cast{s2Var} (the_null_ptr)) // HX: deadcode
) // end of [s2zexp_getVar]

implement
s2zexp_merge_exn
  (x1, x2) = let
//
val s2ze1 = s2zexp_linkrem (x1)
val s2ze2 = s2zexp_linkrem (x2)
//
in
//
if s2zexp_is_S2ZEbot (s2ze1) then s2zexp_merge_abort ()
else if s2zexp_is_S2ZEbot (s2ze2) then s2zexp_merge_abort ()
else if s2zexp_is_S2ZEVar (s2ze1) then let
  val s2V1 = s2zexp_getVar (s2ze1)
  val () = s2Var_set_szexp (s2V1, s2ze2) in s2ze2
end // end of [S2ZEVar, _]
else if s2zexp_is_S2ZEVar (s2ze2) then let
  val s2V2 = s2zexp_getVar (s2ze2)
  val () = s2Var_set_szexp (s2V2, s2ze1) in s2ze1
end // end of [_, S2ZEVar]
else
(
case+ s2zexp_view (s2ze1) of
//
| ~S2ZEprf () => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEprf () => s2ze1
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| ~S2ZEptr () => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEptr () => s2ze1
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| ~S2ZEcst (s2c1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEcst (s2c2) =>
      if s2c1 = s2c2 then s2ze1 else s2zexp_merge_abort()
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
| ~S2ZEvar (s2v1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEvar (s2v2) =>
      if s2v1 = s2v2 then s2ze1 else s2zexp_merge_abort()
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| ~S2ZEextype(name1, _arg1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEextype(name2, _arg2) =>
    if name1 = name2 then let
      val _arg =
        s2zexplstlst_merge_exn (_arg1, _arg2)
      // end of [val]
    in
      s2zexp_S2ZEextype (name1, _arg)
    end else s2zexp_merge_abort () // end of [if]
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
| ~S2ZEextkind(name1, _arg1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEextkind(name2, _arg2) =>
    if name1 = name2 then let
      val _arg =
        s2zexplstlst_merge_exn(_arg1, _arg2)
      // end of [val]
    in
      s2zexp_S2ZEextkind(name1, _arg)
    end else s2zexp_merge_abort() // end of [if]
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| ~S2ZEapp(s2ze11, s2zes12) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEapp(s2ze21, s2zes22) => let
      val s2ze =
        s2zexp_merge_exn(s2ze11, s2ze21)
      val s2zes =
        s2zexplst_merge_exn(s2zes12, s2zes22)
    in
      s2zexp_S2ZEapp(s2ze, s2zes)
    end
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| ~S2ZEtyarr(elt1, dim1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEtyarr(elt2, dim2) => let
      val elt = s2zexp_merge_exn(elt1, elt2)
    in
      if s2explst_syneq(dim1, dim2)
        then s2zexp_S2ZEtyarr(elt, dim1) else s2zexp_merge_abort()
      // end of [if]
    end
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
| ~S2ZEtyrec(knd1, ls2zes1) => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEtyrec(knd2, ls2zes2) =>
    if knd1 = knd2 then
      s2zexp_S2ZEtyrec
      ( knd1
      , labs2zexplst_merge_exn (ls2zes1, ls2zes2)
      ) (* S2ZEtyrec *)
    else $raise S2ZEXPMERGEexn() // end of [if]
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
// HX-2012-06: this holds as flat closures
| ~S2ZEclo() => (
  case+ s2zexp_view (s2ze2) of
  | ~S2ZEclo() => s2zexp_S2ZEclo() // are immovable
  | v => (s2zexp_view_free (v); s2zexp_merge_abort ())
  )
//
| v (*rest-of-s2zexp*) => (s2zexp_view_free (v); s2zexp_merge_abort())
//
) (* end of [else] *)
//
end // end of [s2zexp]

implement
s2zexplst_merge_exn
  (xs1, xs2) = (
  case+ glist_view (xs1) of
  | ~GLcons(x1, xs1) => (
    case+ glist_view (xs2) of
    | ~GLcons(x2, xs2) => let
        val x12 = s2zexp_merge_exn (x1, x2)
      in
        glist_cons(x12, s2zexplst_merge_exn(xs1, xs2))
      end // end of [cons, cons]
    | ~GLnil () => $raise S2ZEXPMERGEexn()
    )
  | ~GLnil () => (
    case+ glist_view (xs2) of
    | ~GLnil () => glist_nil ()
    | ~GLcons (_, _) => $raise S2ZEXPMERGEexn()
    )
) (* end of [s2zexplst_merge_exn] *)

implement
s2zexplstlst_merge_exn
  (xss1, xss2) = (
  case+ glist_view (xss1) of
  | ~GLcons (xs1, xss1) => (
    case+ glist_view (xss2) of
    | ~GLcons (xs2, xss2) => let
        val xs12 = s2zexplst_merge_exn (xs1, xs2)
      in
        glist_cons (xs12, s2zexplstlst_merge_exn (xss1, xss2))
      end // end of [cons, cons]
    | ~GLnil () => $raise S2ZEXPMERGEexn()
    )
  | ~GLnil () => (
    case+ glist_view (xss2) of
    | ~GLnil () => glist_nil ()
    | ~GLcons (_, _) => $raise S2ZEXPMERGEexn()
    )
) (* end of [s2zexplstlst_merge_exn] *)

implement
labs2zexplst_merge_exn
  (lxs1, lxs2) = let
in
  case+ glist_view (lxs1) of
  | ~GLcons (lx1, lxs1) => (
    case+ glist_view (lxs2) of
    | ~GLcons (lx2, lxs2) => let
        val l1 = labs2zexp_lab (lx1) and x1 = labs2zexp_elt (lx1)
        val l2 = labs2zexp_lab (lx2) and x2 = labs2zexp_elt (lx2)
      in
        if l1 = l2 then let
          val x12 = s2zexp_merge_exn (x1, x2)
          val lx = labs2zexp_new (l1, x12)
          val lxs = labs2zexplst_merge_exn (lxs1, lxs2)
        in
          glist_cons (lx, lxs)
        end else
          $raise S2ZEXPMERGEexn()
        // end of [if]
      end // end of [cons, cons]
    | ~GLnil () => $raise S2ZEXPMERGEexn()
    )
  | ~GLnil () => (
    case+ glist_view (lxs2) of
    | ~GLnil () => glist_nil ()
    | ~GLcons (_, _) => $raise S2ZEXPMERGEexn()
    )
end // end of [labs2zexplst_ismat_exn]

(* ****** ****** *)

(*
** HX: this one is declared in [pats_staexp2_util.sats]
*)
implement
s2zexp_merge
  (x1, x2) = try
  s2zexp_merge_exn (x1, x2)
with
  | ~S2ZEXPMERGEexn () => s2zexp_S2ZEbot () // HX: indication of error!
// end of [s2zexp_merge]

(* ****** ****** *)

implement
s2zexp_syneq
  (x1, x2) = let
  val x12 = s2zexp_merge (x1, x2)
in
  if s2zexp_is_bot (x12) then false else true
end // end of [s2zexp_syneq]

(* ****** ****** *)

implement
s2hnf_tszeq
  (s2f1, s2f2) = let
//
val s2e1 = s2hnf2exp (s2f1)
and s2e2 = s2hnf2exp (s2f2)
//
val s2ze1 = s2zexp_make_s2exp (s2e1)
and s2ze2 = s2zexp_make_s2exp (s2e2)
//
in
  s2zexp_syneq (s2ze1, s2ze2)
end // end of [s2hnf_tszeq]

(* ****** ****** *)
//
implement
s2exp_tszeq(s2e1, s2e2) =
(
  s2hnf_tszeq(s2exp2hnf(s2e1), s2exp2hnf(s2e2))
) (* end of [s2exp_tszeq] *)
//
(* ****** ****** *)

(* end of [pats_staexp2_szexp.dats] *)
