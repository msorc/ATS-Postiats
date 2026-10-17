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
// Start Time: April, 2011
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload
ERR = "./pats_error.sats"

(* ****** ****** *)

staload
LOC ="./pats_location.sats"
overload print with $LOC.print_location
overload prerr with $LOC.prerr_location

(* ****** ****** *)

staload "./pats_fixity.sats"

(* ****** ****** *)
//
// HX-2026-10: the arena encoding of fxty
//
#include "./pats_fixity_gen_dats.hats"
//
(* ****** ****** *)

implement
fprint_fxty
  (out, fxty) = let
  macdef prstr (x) = fprint_string (out, ,(x))
in
  case+ fxty_view (fxty) of
  | ~FXTYnon () => begin
      prstr ("FXTYnon()")
    end // end of [FXTYnon]
  | ~FXTYinf (p, a) => begin
      prstr "FXTYinf("; fprint_int (out, (int_of_prec)p); prstr ")"
    end // end of [FXTYinf]
  | ~FXTYpre (p) => begin
      prstr "FXTYpre("; fprint_int (out, (int_of_prec)p); prstr ")"
    end // end of [FXTYpre]
  | ~FXTYpos (p) => begin
      prstr "FXTYpos("; fprint_int (out, (int_of_prec)p); prstr ")"
    end // end of [FXTYpos]
end // end of [fprint_fxty]

implement print_fxty (x) = fprint_fxty (stdout_ref, x)
implement prerr_fxty (x) = fprint_fxty (stderr_ref, x)

(* ****** ****** *)

implement fxty_non = fxty_FXTYnon ()
implement fxty_inf (p, a) = fxty_FXTYinf (p, a)
implement fxty_pre (p) = fxty_FXTYpre p
implement fxty_pos (p) = fxty_FXTYpos p

(* ****** ****** *)

implement
selptr_fxty_dyn = fxty_FXTYinf (select_prec, ASSOClft)

implement deref_fxty_dyn = fxty_FXTYpre (deref_prec_dyn)

(* ****** ****** *)

implement
fxty_get_prec
  (fxty) = case+ fxty_view (fxty) of
  | ~FXTYnon () => None_vt ()
  | ~FXTYinf (p, _) => Some_vt (p)
  | ~FXTYpre p => Some_vt (p)
  | ~FXTYpos p => Some_vt (p)
// end of [fxty_get_prec]

(* ****** ****** *)
//
// HX-2026-10: the arena encoding of fxopr and fxitm
// (written by hand as they are polymorphic)
//
(* ****** ****** *)

implement{a}
fxopr_encode (v) = let
  val p = the_garena_alloc (i2sz(48))
in
  case+ v of
  | ~FXOPRinf (prec, assoc, f) => let
      val () = $UN.ptr0_set<int> (p, 0)
      val () = $UN.ptr0_set<prec> (ptr0_add_guint<byte> (p, i2sz(8)), prec)
      val () = $UN.ptr0_set<assoc> (ptr0_add_guint<byte> (p, i2sz(16)), assoc)
      val () = $UN.ptr0_set<fxfn2(a)> (ptr0_add_guint<byte> (p, i2sz(24)), f)
    in
      $UN.cast{fxopr(a)}(p)
    end // end of [FXOPRinf]
  | ~FXOPRpre (prec, f) => let
      val () = $UN.ptr0_set<int> (p, 1)
      val () = $UN.ptr0_set<prec> (ptr0_add_guint<byte> (p, i2sz(8)), prec)
      val () = $UN.ptr0_set<fxfn1(a)> (ptr0_add_guint<byte> (p, i2sz(24)), f)
    in
      $UN.cast{fxopr(a)}(p)
    end // end of [FXOPRpre]
  | ~FXOPRpos (prec, f) => let
      val () = $UN.ptr0_set<int> (p, 2)
      val () = $UN.ptr0_set<prec> (ptr0_add_guint<byte> (p, i2sz(8)), prec)
      val () = $UN.ptr0_set<fxfn1(a)> (ptr0_add_guint<byte> (p, i2sz(24)), f)
    in
      $UN.cast{fxopr(a)}(p)
    end // end of [FXOPRpos]
end // end of [fxopr_encode]

implement{a}
fxopr_view (x) = let
  val p = $UN.cast{ptr}(x)
  val tag = $UN.ptr0_get<int> (p)
  val prec = $UN.ptr0_get<prec> (ptr0_add_guint<byte> (p, i2sz(8)))
in
  if tag = 0 then let
    val asc = $UN.ptr0_get<assoc> (ptr0_add_guint<byte> (p, i2sz(16)))
    val f = $UN.ptr0_get<fxfn2(a)> (ptr0_add_guint<byte> (p, i2sz(24)))
  in
    FXOPRinf (prec, asc, f)
  end else let
    val f = $UN.ptr0_get<fxfn1(a)> (ptr0_add_guint<byte> (p, i2sz(24)))
  in
    if tag = 1 then FXOPRpre (prec, f) else FXOPRpos (prec, f)
  end // end of [else]
end // end of [fxopr_view]

implement{a}
fxopr_FXOPRinf (p, asc, f) = fxopr_encode<a> (FXOPRinf (p, asc, f))
implement{a}
fxopr_FXOPRpre (p, f) = fxopr_encode<a> (FXOPRpre (p, f))
implement{a}
fxopr_FXOPRpos (p, f) = fxopr_encode<a> (FXOPRpos (p, f))

(* ****** ****** *)

implement{a}
fxitm_encode (v) = let
  val p = the_garena_alloc (i2sz(24))
in
  case+ v of
  | ~FXITMatm (x) => let
      val () = $UN.ptr0_set<int> (p, 0)
      val () = $UN.ptr0_set<ptr> (ptr0_add_guint<byte> (p, i2sz(8)), $UN.cast{ptr}(x))
    in
      $UN.cast{fxitm(a)}(p)
    end // end of [FXITMatm]
  | ~FXITMopr (loc, opr) => let
      val () = $UN.ptr0_set<int> (p, 1)
      val () = $UN.ptr0_set<$LOC.location> (ptr0_add_guint<byte> (p, i2sz(8)), loc)
      val () = $UN.ptr0_set<ptr> (ptr0_add_guint<byte> (p, i2sz(16)), $UN.cast{ptr}(opr))
    in
      $UN.cast{fxitm(a)}(p)
    end // end of [FXITMopr]
end // end of [fxitm_encode]

implement{a}
fxitm_view (x) = let
  val p = $UN.cast{ptr}(x)
  val tag = $UN.ptr0_get<int> (p)
in
  if tag = 0 then
    FXITMatm ($UN.cast{a}($UN.ptr0_get<ptr> (ptr0_add_guint<byte> (p, i2sz(8)))))
  else let
    val loc = $UN.ptr0_get<$LOC.location> (ptr0_add_guint<byte> (p, i2sz(8)))
    val opr = $UN.ptr0_get<ptr> (ptr0_add_guint<byte> (p, i2sz(16)))
  in
    FXITMopr (loc, $UN.cast{fxopr(a)}(opr))
  end // end of [else]
end // end of [fxitm_view]

implement{a}
fxitm_FXITMatm (x) = fxitm_encode<a> (FXITMatm (x))
implement{a}
fxitm_FXITMopr (loc, opr) = fxitm_encode<a> (FXITMopr (loc, opr))

(* ****** ****** *)

fn{a:type}
fxfn1_app (f: fxfn1(a), x: a): fxitm(a) = let
  val @(env, fn1) = f in fn1 (env, x)
end // end of [fxfn1_app]

fn{a:type}
fxfn2_app (f: fxfn2(a), x1: a, x2: a): fxitm(a) = let
  val @(env, fn2) = f in fn2 (env, x1, x2)
end // end of [fxfn2_app]

(* ****** ****** *)

implement{a}
fxopr_associativity (x) = begin
  case+ fxopr_view<a> (x) of
  | ~FXOPRinf (_, a, _) => a
  | ~FXOPRpre _ => ASSOCnon ()
  | ~FXOPRpos _ => ASSOCnon ()
end // end of [fxopr_associativity]
        
implement{a}
fxopr_precedence (x) = begin case+ fxopr_view<a> (x) of
  | ~FXOPRinf (p, _, _) => p | ~FXOPRpre (p, _) => p | ~FXOPRpos (p, _) => p
end // end of [fxopr_precedence]

(* ****** ****** *)

local
//
macdef app_assoc = ASSOClft (* left association *)
//
in // in of [local]
//
implement{a}
fxitm_app (loc, f) =
  fxitm_FXITMopr<a> (loc, fxopr_FXOPRinf<a> (app_prec, app_assoc, f))
//
end // end of [local]

(* ****** ****** *)
//
// HX-2026-10: closure conversion (see pats_fixity.sats).
// The environments below are allocated in the global arena.
//
typedef
fxenv_make(a:type) =
  @(a -> $LOC.location, (location, a, location, glist(a)) -> a, a, location)
//
(* ****** ****** *)

implement{a}
fxopr_make (
  locf, appf, opr, fxty
) = let
//
  val loc_opr = locf opr
//
  // the environment: [locf, appf, opr, loc_opr]
  val env = the_garena_alloc (sizeof<fxenv_make(a)>)
  val () = $UN.ptr0_set<fxenv_make(a)> (env, @(locf, appf, opr, loc_opr))
//
  fn f_inf
    (env: ptr, x1: a, x2: a): fxitm a = let
    val ev = $UN.ptr0_get<fxenv_make(a)> (env)
    val locf = ev.0 and appf = ev.1 and opr = ev.2
    val loc = $LOC.location_combine (locf x1, locf x2)
  in
    fxitm_FXITMatm<a> (appf (loc, opr, loc, glist_cons (x1, glist_sing (x2))))
  end // end of [f_inf]
//
  fn f_pre
    (env: ptr, x: a): fxitm a = let
    val ev = $UN.ptr0_get<fxenv_make(a)> (env)
    val locf = ev.0 and appf = ev.1 and opr = ev.2 and loc_opr = ev.3
    val loc_x = locf x
    val loc = $LOC.location_combine (loc_opr, loc_x)
  in
    fxitm_FXITMatm<a> (appf (loc, opr, loc_x, glist_sing (x)))
  end // end of [f_pre]
//
  fn f_pos
    (env: ptr, x: a): fxitm a = let
    val ev = $UN.ptr0_get<fxenv_make(a)> (env)
    val locf = ev.0 and appf = ev.1 and opr = ev.2 and loc_opr = ev.3
    val loc_x = locf x
    val loc = $LOC.location_combine (loc_x, loc_opr)
  in
    fxitm_FXITMatm<a> (appf (loc, opr, loc_x, glist_sing (x)))
  end // end of [f_pos]
//
in 
//
case+ fxty_view (fxty) of
| ~FXTYnon () => fxitm_FXITMatm<a> (opr)
| ~FXTYinf (p, asc) =>
    fxitm_FXITMopr<a> (loc_opr, fxopr_FXOPRinf<a> (p, asc, @(env, f_inf)))
| ~FXTYpre p =>
    fxitm_FXITMopr<a> (loc_opr, fxopr_FXOPRpre<a> (p, @(env, f_pre)))
| ~FXTYpos p =>
    fxitm_FXITMopr<a> (loc_opr, fxopr_FXOPRpos<a> (p, @(env, f_pos)))
//
end // end of [fxopr_make]

(* ****** ****** *)

typedef
fxenv_backslash(a:type) =
  @(a -> $LOC.location, (location, a, location, glist(a)) -> a, location)
typedef
fxenv_backslash2(a:type) =
  @(a -> $LOC.location, (location, a, location, glist(a)) -> a, a)

implement{a}
fxopr_make_backslash
  (locf, appf, loc) = let
//
  fn f2
    (env: ptr, x1: a, x2: a): fxitm a = let
    val ev = $UN.ptr0_get<fxenv_backslash2(a)> (env)
    val locf = ev.0 and appf = ev.1 and x = ev.2
    val loc = $LOC.location_combine (locf x1, locf x2)
  in
    fxitm_FXITMatm<a> (appf (loc, x, loc, glist_cons (x1, glist_sing (x2))))
  end // end of [f2]
//
  fn f1
    (env: ptr, x: a): fxitm a = let
    val ev = $UN.ptr0_get<fxenv_backslash(a)> (env)
    val locf = ev.0 and appf = ev.1 and loc = ev.2
    val loc = $LOC.location_combine (loc, locf x)
    val env2 = the_garena_alloc (sizeof<fxenv_backslash2(a)>)
    val () = $UN.ptr0_set<fxenv_backslash2(a)> (env2, @(locf, appf, x))
  in
    fxitm_FXITMopr<a> (loc, fxopr_FXOPRinf<a> (infixtemp_prec, ASSOCnon, @(env2, f2)))
  end // end of [f1]
//
  val env = the_garena_alloc (sizeof<fxenv_backslash(a)>)
  val () = $UN.ptr0_set<fxenv_backslash(a)> (env, @(locf, appf, loc))
//
in
  fxitm_FXITMopr<a> (loc, fxopr_FXOPRpre<a> (backslash_prec, @(env, f1)))
end // end of [fxopr_make_backslahsh]

(* ****** ****** *)

(*
** HX-2011-04-10:
** this is some code I originally wrote in 1998
** for implementing DML; it has been a while :)
*)

implement{a}
fixity_resolve
  (loc0, locf, app, xs) = let
//
typedef I = fxitm a
typedef J = glist (I)
//
fn erropr (
  loc: location
) : a = let
  val () = prerr (loc)
  val () = prerr ": error(1)"
  val () = prerr ": operator fixity cannot be resolved."
  val () = prerr_newline ()
in
  $raise($ERR.PATSOPT_FIXITY_EXN(*void*))
end // end of [erropr]
//
fn errapp (
  locf: a -> location, m: fxitm a
) : a = let
  val-~FXITMatm (atm) = fxitm_view<a> (m)
  val () = prerr (locf(atm))
  val () = prerr ": error(1)"
  val () =
    prerr ": application fixity cannot be resolved."
  // end of [val]
  val () = prerr_newline((*void*))
in
  $raise($ERR.PATSOPT_FIXITY_EXN(*void*))
end // end of [errapp]
//
fn err_reduce (
  loc: location, ys: J
) : a = let
  val () = prerr (loc)
  val () = prerr ": error(1)"
  val () = prerr ": operator fixity cannot be resolved."
  val () = prerr_newline((*void*))
in
  $raise($ERR.PATSOPT_FIXITY_EXN(*void*))
end // end of [err]
//
fn is_atm (m: I): bool =
  (case+ fxitm_view<a> (m) of ~FXITMatm _ => true | ~FXITMopr (_, opr) => false)
//
(*
** HX: [fn*] for mutual tail-recursion
*)
fun process
(
  xs: J, ys: J
) : a =
(
  case+ glist_view (xs) of
  | ~GLnil () => let
      val onlyatm =
      (
        case+ glist_view (ys) of
        | ~GLnil () => false
        | ~GLcons (y, ys1) =>
            if is_atm (y) then glist_is_nil (ys1) else false
      ) : bool
    in
      if onlyatm
        then (
          case+ glist_view (ys) of
          | ~GLcons (y, _) => let
              val-~FXITMatm (t) = fxitm_view<a> (y) in t
            end
          | ~GLnil () => err_reduce (loc0, ys) // HX: deadcode
        ) else xreduce (glist_nil (), ys)
    end // end of [GLnil]
  | ~GLcons (x, xs) => resolve (xs, x, ys)
) (* end of [process] *)
//
and resolve
(
  xs: J, m: I, ys: J
) : a = case+ fxitm_view<a> (m) of
  | ~FXITMatm _ => (
    case+ glist_view (ys) of
    | ~GLcons (y, _) =>
        if is_atm (y)
          then resolve_app (xs, m, ys)
          else process (xs, glist_cons (m, ys))
    | ~GLnil () => process (xs, glist_cons (m, ys))
    ) // end of [_, FXITMatm, _]
  | ~FXITMopr (loc, opr) => resolve_opr (loc, opr, xs, m, ys)
(* end of [resolve] *)
//
and resolve_opr
(
  loc: location
, opr: fxopr a, xs: J, m: I, ys: J
) : a = let
  // HX: the second element of [ys], if any, is an operator [opr1]
  fn ys2_opr
    (ys: J): Option_vt(fxopr a) =
  (
    case+ glist_view (ys) of
    | ~GLnil () => None_vt ()
    | ~GLcons (_, ys1) => (
        case+ glist_view (ys1) of
        | ~GLnil () => None_vt ()
        | ~GLcons (y1, _) =>
            (case+ fxitm_view<a> (y1) of
             | ~FXITMatm _ => None_vt () | ~FXITMopr (_, opr1) => Some_vt (opr1))
      ) (* end of [GLcons] *)
  ) (* end of [ys2_opr] *)
  fn ys_sing (ys: J): bool =
  (
    case+ glist_view (ys) of
    | ~GLnil () => false
    | ~GLcons (_, ys1) => glist_is_nil (ys1)
  ) (* end of [ys_sing] *)
in
  case+ fxopr_view<a> (opr) of
  | ~FXOPRinf _ =>
    if ys_sing (ys)
      then process (xs, glist_cons (m, ys))
      else (
      case+ ys2_opr (ys) of
      | ~Some_vt (opr1) => let
          val p = fxopr_precedence<a> opr and p1 = fxopr_precedence<a> opr1
          val sgn = compare_prec_prec (p, p1)
        in
          if sgn > 0 then process (xs, glist_cons (m, ys))
          else if sgn < 0 then xreduce (glist_cons (m, xs), ys)
          else let
            val assoc = fxopr_associativity<a> opr
            and assoc1 = fxopr_associativity<a> opr1
          in
            case+ (assoc, assoc1) of
            | (ASSOClft (), ASSOClft ()) => xreduce (glist_cons (m, xs), ys)
            | (ASSOCrgt (), ASSOCrgt ()) => process (xs, glist_cons (m, ys))
            | (_, _) => erropr (loc)
          end // end of [else]
        end // end of [Some_vt]
      | ~None_vt () => erropr (loc)
      ) (* end of [else] *)
  | ~FXOPRpre _ => process (xs, glist_cons (m, ys))
  | ~FXOPRpos _ => (
      case+ ys2_opr (ys) of
      | ~Some_vt (opr1) => let
          val p = fxopr_precedence<a> opr and p1 = fxopr_precedence<a> opr1
          val sgn = compare_prec_prec (p, p1)
        in
          if sgn > 0 then xreduce (xs, glist_cons (m, ys))
          else if sgn < 0 then xreduce (glist_cons (m, xs), ys)
          else erropr (loc)
        end // end of [Some_vt]
      | ~None_vt () =>
          if ys_sing (ys) then xreduce (xs, glist_cons (m, ys)) else erropr (loc)
    ) (* end of [FXOPRpos] *)
end (* end of [resolve_opr] *)
//
and resolve_app (
  xs: J, m: I, ys: J
) : a = let
  fn ys2_opr
    (ys: J): Option_vt(fxopr a) =
  (
    case+ glist_view (ys) of
    | ~GLnil () => None_vt ()
    | ~GLcons (_, ys1) => (
        case+ glist_view (ys1) of
        | ~GLnil () => None_vt ()
        | ~GLcons (y1, _) =>
            (case+ fxitm_view<a> (y1) of
             | ~FXITMatm _ => None_vt () | ~FXITMopr (_, opr1) => Some_vt (opr1))
      ) (* end of [GLcons] *)
  ) (* end of [ys2_opr] *)
  fn ys_sing (ys: J): bool =
  (
    case+ glist_view (ys) of
    | ~GLnil () => false
    | ~GLcons (_, ys1) => glist_is_nil (ys1)
  ) (* end of [ys_sing] *)
in
  case+ ys2_opr (ys) of
  | ~Some_vt (opr1) => let
      val p1 = fxopr_precedence<a> opr1
      val sgn = compare_prec_prec (app_prec, p1): Sgn
    in
      if sgn > 0 then process (xs, glist_cons (m, glist_cons (app, ys)))
      else if sgn < 0 then xreduce (glist_cons (m, xs), ys)
      else let
        val assoc1 = fxopr_associativity<a> opr1 in
        case+ assoc1 of
        | ASSOClft () => xreduce (glist_cons (m, xs), ys)
        | _ => errapp (locf, m) // HX: [m] is FXITMatm
      end // end of [else]
    end // end of [Some_vt]
  | ~None_vt () =>
      if ys_sing (ys)
        then process (xs, glist_cons (m, glist_cons (app, ys)))
        else errapp (locf, m) // HX: [m] is FXITMatm
end (* end of [resolve_app] *)
//
and
xreduce
(
  xs: J, ys: J
) : a = let
  // HX: ys = y1 :: y2 :: ys2
  fn y3 (ys: J): Option_vt(@(I, I, J)) =
  (
    case+ glist_view (ys) of
    | ~GLnil () => None_vt ()
    | ~GLcons (y1, ys1) => (
      case+ glist_view (ys1) of
      | ~GLnil () => None_vt ()
      | ~GLcons (y2, ys2) => Some_vt (@(y1, y2, ys2))
      )
  ) (* end of [y3] *)
in
//
case+ glist_view (ys) of
| ~GLnil () => err_reduce (loc0, ys)
| ~GLcons (y1, ys1) => (
    case+ fxitm_view<a> (y1) of
    | ~FXITMatm (t1) => (
        case+ glist_view (ys1) of
        | ~GLnil () => err_reduce (loc0, ys)
        | ~GLcons (y2, ys2) => (
            case+ fxitm_view<a> (y2) of
            | ~FXITMopr (_, opr) => (
                case+ fxopr_view<a> (opr) of
                | ~FXOPRinf (_, _, f) => (
                    case+ glist_view (ys2) of
                    | ~GLcons (y3, ys3) => (
                        case+ fxitm_view<a> (y3) of
                        | ~FXITMatm (t2) =>
                            resolve (xs, fxfn2_app<a> (f, t2, t1), ys3)
                        | ~FXITMopr _ => err_reduce (loc0, ys)
                      )
                    | ~GLnil () => err_reduce (loc0, ys)
                  )
                | ~FXOPRpre (_, f) => resolve (xs, fxfn1_app<a> (f, t1), ys2)
                | ~FXOPRpos _ => err_reduce (loc0, ys)
              )
            | ~FXITMatm _ => err_reduce (loc0, ys)
          )
      )
    | ~FXITMopr (_, opr) => (
        case+ fxopr_view<a> (opr) of
        | ~FXOPRpos (_, f) => (
            case+ glist_view (ys1) of
            | ~GLcons (y2, ys2) => (
                case+ fxitm_view<a> (y2) of
                | ~FXITMatm (t1) => resolve (xs, fxfn1_app<a> (f, t1), ys2)
                | ~FXITMopr _ => err_reduce (loc0, ys)
              )
            | ~GLnil () => err_reduce (loc0, ys)
          )
        | ~FXOPRinf _ => err_reduce (loc0, ys)
        | ~FXOPRpre _ => err_reduce (loc0, ys)
      )
  ) (* end of [GLcons] *)
//
end (* end of [reduce] *)
//
in
//
  process(xs, glist_nil((*void*)))
//
end // end of [fixity_resolve]

(* ****** ****** *)

(* end of [pats_fixity_fxty.dats] *)
