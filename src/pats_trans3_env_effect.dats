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
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_env_effect.dats, see PORTING.md, "Type-checking environment (trans3_env)")
// The stack of effects is a [glist] of items in a cell (see [pats_trans3_env_effect.spec]); a mark is an item.
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
implement prerr_FILENAME<> () = prerr "pats_trans3_env_effect"

(* ****** ****** *)

staload "./pats_effect.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_stacst2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"
staload "./pats_trans3.sats"
staload "./pats_trans3_env.sats"

(* ****** ****** *)

#include "./pats_trans3_env.hats"

(* ****** ****** *)

staload "./pats_trans3_env_effect.sats"
#include "./pats_trans3_env_effect_gen_dats.hats"

(* ****** ****** *)

typedef effenvitmlst = glist (effenvitm)

(* ****** ****** *)

fun
efilst_unmark (
  xs: effenvitmlst
) : effenvitmlst =
  case+ glist_view (xs) of
  | ~GLcons (efi, xs) => (
    case+ effenvitm_view (efi) of
    | ~EFFENVITMeff _ => efilst_unmark (xs)
    | ~EFFENVITMeffmask _ => efilst_unmark (xs)
    | ~EFFENVITMmark (_(*knd*)) => xs
    )
  | ~GLnil () => glist_nil ()
// end of [efilst_unmark]

(* ****** ****** *)

extern
fun effset_diff_s2eff
  (efs0: effset, s2fe: s2eff): effset
implement
effset_diff_s2eff
  (efs0, s2fe) = (
  case+ s2eff_view (s2fe) of
  | ~S2EFFset (efs) => effset_diff (efs0, efs)
  | ~S2EFFexp (exp) => efs0 (* conservative estimation *)
  | ~S2EFFadd (s2fe1, s2fe2) => (
      effset_diff_s2eff (effset_diff_s2eff (efs0, s2fe1), s2fe2)
    ) // end of [S2EFFadd]
) // end of [effset_diff_s2eff]

extern
fun effset_union_s2eff
  (efs0: effset, s2fe: s2eff): effset
implement
effset_union_s2eff
  (efs0, s2fe) = (
  case+ s2eff_view (s2fe) of
  | ~S2EFFset (efs) => effset_union (efs0, efs)
  | ~S2EFFexp (exp) => efs0 (* conservative estimation *)
  | ~S2EFFadd (s2fe1, s2fe2) => (
      effset_union_s2eff (effset_union_s2eff (efs0, s2fe1), s2fe2)
    ) // end of [S2EFFadd]
) // end of [effset_union_s2eff]

(* ****** ****** *)

local

val the_efis = gcell_make<effenvitmlst> (glist_nil ())

fn
efis_get (): effenvitmlst = gcell_get<effenvitmlst> (the_efis)
fn
efis_set (xs: effenvitmlst): void = gcell_set<effenvitmlst> (the_efis, xs)

in (* in of [local] *)

implement
the_effenv_add_eff
  (eff) = let
  val efs = effset_sing (eff)
  val efi = effenvitm_EFFENVITMeff (efs)
in
  efis_set (glist_cons (efi, efis_get ()))
end // end of [the_effenv_add_eff]

(* ****** ****** *)

implement
the_effenv_pop
  ((*none*)) = efis_set (efilst_unmark (efis_get ()))
// end of [the_effenv_pop]

implement
the_effenv_pop_if
  (test) = if test then the_effenv_pop () else ()
// end of [the_effenv_pop_if]

(* ****** ****** *)

implement
the_effenv_push () =
  efis_set (glist_cons (effenvitm_EFFENVITMmark (0(*soft*)), efis_get ()))
// end of [the_effenv_push]

implement
the_effenv_push_lam
  (s2fe) = let
//
val efi = effenvitm_EFFENVITMeffmask (s2fe)
val efis = glist_cons (effenvitm_EFFENVITMmark (1(*hard*)), efis_get ())
//
in
  efis_set (glist_cons (efi, efis))
end // end of [the_effenv_push_lam]

(* ****** ****** *)

implement
the_effenv_push_set (efs) = let
//
val efi = effenvitm_EFFENVITMeff (efs)
val efis = glist_cons (effenvitm_EFFENVITMmark (0(*soft*)), efis_get ())
//
in
  efis_set (glist_cons (efi, efis))
end // end of [the_effenv_push_set]

implement
the_effenv_push_set_if
  (test, efs) = if test then the_effenv_push_set (efs) else ()
// end of [the_effenv_push_set_if]

(* ****** ****** *)

implement
the_effenv_push_effmask (s2fe) = let
//
val efi = effenvitm_EFFENVITMeffmask (s2fe)
val efis = glist_cons (effenvitm_EFFENVITMmark (0(*soft*)), efis_get ())
//
in
  efis_set (glist_cons (efi, efis))
end // end of [the_effenv_push_effmask]

(* ****** ****** *)

fun
check_set_auxerr (
  loc0: loc_t, efs0: effset, efs: effset
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = filprerr_ifdebug "the_effenv_check_set"
  val () = (prerr ": some disallowed effects may be incurred: "; prerr_effset (efs); prerr_newline ())
in
  the_trans3errlst_add (trans3err_T3E_effenv_check_set (loc0, efs0))
end (* end of [check_set_auxerr] *)

fun
check_set_auxcheck
(
  loc0: loc_t, efs00: effset
, efis: effenvitmlst, efs0: effset(*isnotnil*)
) : int =
  case+ glist_view (efis) of
  | ~GLcons (efi, efis) => (
    case+ effenvitm_view (efi) of
    | ~EFFENVITMeff (efs) => let
        val efs =
          effset_inter (efs0, efs)
        // end of [val]
        val isnil = effset_isnil (efs)
        val ans = (
          if isnil then check_set_auxcheck (loc0, efs00, efis, efs0) else 1(*fail*)
        ) : int // end of [val]
        val () = if ans > 0 then check_set_auxerr (loc0, efs00, efs)
      in
        ans
      end // end of [EFFENVITEMeff]
    | ~EFFENVITMeffmask (s2fe) => let
        val efs0 =
          effset_diff_s2eff (efs0, s2fe) // conservative
        val isnil = effset_isnil (efs0)
        val ans = (
          if isnil then 0(*succ*) else check_set_auxcheck (loc0, efs00, efis, efs0)
        ) : int // end of [val]
      in
        ans
      end // end of [EFFENVITEMeffmask]
    | ~EFFENVITMmark (knd) => let
        val ans = ( // HX: note that [efs0] is not nil
          if knd > 0 then 1(*fail*) else check_set_auxcheck (loc0, efs00, efis, efs0)
        ) : int // end of [val]
        val () = if knd > 0 then (if ans > 0 then check_set_auxerr (loc0, efs00, efs0))
      in
        ans
      end // end of [EFILSTmark]
    ) // end of [EFILSTcons]
//
// HX: effects are all considered to be masked at the end
//
  | ~GLnil () => 0
// end of [check_set_auxcheck]

implement
the_effenv_check_set
  (loc0, efs0) = let
//
val isnil = effset_isnil (efs0)
//
in
//
if isnil then 0 else check_set_auxcheck (loc0, efs0, efis_get (), efs0)
//
end // end of [the_effenv_check_set]

(* ****** ****** *)

implement
the_effenv_check_eff
  (loc0, eff) = (
  the_effenv_check_set (loc0, effset_sing (eff))
) // end of [the_effenv_check_eff]

implement
the_effenv_check_exn
  (loc0) = the_effenv_check_set (loc0, effset_exn)
// end of [the_effenv_check_exn]

implement
the_effenv_check_ntm
  (loc0) = the_effenv_check_set (loc0, effset_ntm)
// end of [the_effenv_check_ntm]

implement
the_effenv_check_ref
  (loc0) = the_effenv_check_set (loc0, effset_ref)
// end of [the_effenv_check_ref]

implement
the_effenv_check_wrt
  (loc0) = the_effenv_check_set (loc0, effset_wrt)
// end of [the_effenv_check_wrt]

(* ****** ****** *)

implement
the_effenv_caskind_check_exn
  (loc0, casknd) = (case+ casknd of
  | CK_case () => the_effenv_check_exn (loc0)
  | CK_case_pos () => 0 // HX: a type error is to be reported
  | CK_case_neg () => 0 // HX: per the wish of the programmer
) // end of [the_effenv_caskind_check_exn]

(* ****** ****** *)

fun
check_sexp_auxerr (
  loc0: loc_t, s2e0: s2exp
) : void = let
  val () = prerr_error3_loc (loc0)
  val () = filprerr_ifdebug "the_effenv_check_sexp"
  val () = (prerr ": some disallowed effects may be incurred: "; prerr_s2exp (s2e0); prerr_newline ())
in
  the_trans3errlst_add (trans3err_T3E_effenv_check_sexp (loc0, s2e0))
end (* end of [check_sexp_auxerr] *)
//
fun
check_sexp_auxcheck (
  loc0: loc_t, efis: effenvitmlst, mefs: effset, s2e0: s2exp
) : int =
  case+ glist_view (efis) of
  | ~GLcons (efi, efis) => (
    case+ effenvitm_view (efi) of
    | ~EFFENVITMeff efs => let
        val issup = effset_supset (mefs, efs)
        val ans = (if issup then 0 else 1): int
        val () = if ans > 0 then check_sexp_auxerr (loc0, s2e0)
      in
        ans
      end // end of [EFFENVITMeff]
    | ~EFFENVITMeffmask s2fe => let
        val isnil = s2eff_contain_exp (s2fe, s2e0) // conservative
        val ans = (
          if isnil then 0(*succ*) else let
            val mefs = effset_union_s2eff (mefs, s2fe) // conservative
          in
            check_sexp_auxcheck (loc0, efis, mefs, s2e0)
          end (* end of [if] *)
        ) : int // end of [val]
      in
        ans
      end // end of [EFFENVITEMeffmask]
    | ~EFFENVITMmark (knd) => let
        val ans = ( // HX: assuming [s2e0] is not nil
          if knd > 0 then 1(*fail*) else check_sexp_auxcheck (loc0, efis, mefs, s2e0)
        ) : int // end of [val]
        val () = if ans > 0 then check_sexp_auxerr (loc0, s2e0)
      in
        ans
      end // end of [EFILSTmark]
    ) // end of [EFILSTcons]
  | ~GLnil () => 0(*succ*)
// end of [check_sexp_auxcheck]

implement
the_effenv_check_sexp
  (loc0, s2e0) =
  check_sexp_auxcheck (loc0, efis_get (), effset_nil, s2e0)
// end of [the_effenv_check_sexp]

(* ****** ****** *)

implement
the_effenv_check_s2eff
  (loc0, s2fe0) = let
//
val s2fe0 = s2eff_hnfize (s2fe0)
//
in
//
case+ s2eff_view (s2fe0) of
| ~S2EFFset (efs0) =>
    the_effenv_check_set (loc0, efs0)
| ~S2EFFexp (s2e) => let
    val s2f = s2exp2hnf (s2e)
    val s2e = s2hnf2exp (s2f)
  in
    the_effenv_check_sexp (loc0, s2e)
  end // end of [S2EFFexp]
| ~S2EFFadd (s2fe1, s2fe2) => let
    val ans = the_effenv_check_s2eff (loc0, s2fe1)
  in
    if ans > 0 then 1 else the_effenv_check_s2eff (loc0, s2fe2)
  end // end of [S2EFFadd]
//
end // end of [the_effenv_check_s2eff]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans3_env_effect.dats] *)
