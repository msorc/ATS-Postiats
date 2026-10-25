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
// HX-2026-10: no GC (ATS2 port of src/pats_effect.dats)
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

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_effect.sats"

(* ****** ****** *)

assume effect_t0ype = uint

(* ****** ****** *)
//
#define EFFntm 0 // nonterm
#define EFFexn 1 // exception
#define EFFref 2 // reference
#define EFFwrt 3 // writeover
//
// HX-2012-03:
// the maximal numberof effect is required to
// strictly less than the size of unsigned int
// as one bit is needed for the-rest-of-effects
//
#define MAX_EFFECT_NUMBER 4
//
(* ****** ****** *)

fn effect_of_int (x: int): effect = $UN.cast{effect} (g0int2uint_int_uint(x))
fn int_of_effect (x: effect): int = g0uint2int_uint_int ($UN.cast{uint} (x))

(* ****** ****** *)

implement effect_ntm = effect_of_int (EFFntm)
implement effect_exn = effect_of_int (EFFexn)
implement effect_ref = effect_of_int (EFFref)
implement effect_wrt = effect_of_int (EFFwrt)

implement
effectlst_all =
  glist_cons (effect_ntm, glist_cons (effect_exn, glist_cons (effect_ref, glist_sing (effect_wrt))))
// end of [effectlst_all]

implement
eq_effect_effect (eff1, eff2) = g0uint_eq ($UN.cast{uint} (eff1), $UN.cast{uint} (eff2))

(* ****** ****** *)

implement
effect_get_name
  (eff) = let
//
val eff = int_of_effect (eff)
//
in
  case+ eff of
  | EFFntm => "ntm"
  | EFFexn => "exn"
  | EFFref => "ref"
  | EFFwrt => "wrt"
  | _ => let
      val () = assertloc (false) in $ERR.abort_interr<string>((*deadcode*))
    end // end of [_]
end // end of [effect_get_name]

(* ****** ****** *)

implement
fprint_effect (out, x) = fprint_string (out, effect_get_name (x))

implement
print_effect (x) = fprint_effect (stdout_ref, x)
implement
prerr_effect (x) = fprint_effect (stderr_ref, x)

implement
fprint_effectlst (out, xs) = let
  fun loop (out: FILEref, xs: glist(effect), i: int): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs1) => (
        (if i > 0 then fprint_string (out, ", ")); fprint_effect (out, x); loop (out, xs1, i+1)
      )
    | ~GLnil () => ()
in
  loop (out, xs, 0)
end // end of [fprint_effectlst]

(* ****** ****** *)

assume effset_t0ype = uint

(* ****** ****** *)

fn effset_of_uint (x: uint): effset = $UN.cast{effset} (x)
fn uint_of_effset (x: effset): uint = $UN.cast{uint} (x)

fn eff_bit (x: effect): uint = g0uint_lsl_uint (1u, $UN.cast{intGte(0)} (int_of_effect (x)))

(* ****** ****** *)

implement effset_nil = effset_of_uint (g0int2uint_int_uint (0)) // 0U
implement effset_all = effset_of_uint (g0uint_lnot_uint (g0int2uint_int_uint (0))) // 1...1U

implement effset_ntm = effset_of_uint (eff_bit (effect_ntm))
implement effset_exn = effset_of_uint (eff_bit (effect_exn))
implement effset_ref = effset_of_uint (eff_bit (effect_ref))
implement effset_wrt = effset_of_uint (eff_bit (effect_wrt))

implement effset_sing (x) = effset_of_uint (eff_bit (x))

implement
eq_effset_effset (efs1, efs2) = g0uint_eq (uint_of_effset (efs1), uint_of_effset (efs2))

(* ****** ****** *)

implement
effset_add (xs, x) = effset_of_uint (g0uint_lor_uint (uint_of_effset (xs), eff_bit (x)))
implement
effset_del (xs, x) =
  effset_of_uint (g0uint_land_uint (uint_of_effset (xs), g0uint_lnot_uint (eff_bit (x))))

(* ****** ****** *)

implement
effset_isnil (xs) = g0uint_eq (uint_of_effset (xs), g0int2uint_int_uint (0))
implement
effset_isall (xs) = g0uint_eq (uint_of_effset (xs), g0uint_lnot_uint (g0int2uint_int_uint (0)))

implement
effset_isfin (xs) = // finite
  g0uint_eq (g0uint_land_uint (uint_of_effset (xs), g0uint_lsl_uint (1u, MAX_EFFECT_NUMBER)), 0u)
// end of [effset_isfin]
implement
effset_iscof (xs) = // cofinite
  g0uint_lt (g0uint_land_uint (uint_of_effset (xs), g0uint_lsl_uint (1u, MAX_EFFECT_NUMBER)), 0u)
// end of [effset_iscof]

(* ****** ****** *)

implement
effset_ismem (xs, x) = g0uint_gt (g0uint_land_uint (uint_of_effset (xs), eff_bit (x)), 0u)

implement
effset_supset
  (xs1, xs2) = (
  g0uint_eq (g0uint_land_uint (g0uint_lnot_uint (uint_of_effset (xs1)), uint_of_effset (xs2)), 0u)
) // end of [effset_supset]

implement
effset_subset
  (xs1, xs2) = (
  g0uint_eq (g0uint_land_uint (uint_of_effset (xs1), g0uint_lnot_uint (uint_of_effset (xs2))), 0u)
) // end of [effset_subset]

implement
effset_is_inter (xs1, xs2) =
  ~effset_isnil (effset_inter (xs1, xs2))
// end of [effset_is_inter]

implement
effset_cmpl (xs) = effset_of_uint (g0uint_lnot_uint (uint_of_effset (xs)))
implement
effset_diff
  (xs1, xs2) = effset_inter (xs1, effset_cmpl (xs2))
// end of [effset_diff]

implement
effset_inter (xs1, xs2) = effset_of_uint (g0uint_land_uint (uint_of_effset (xs1), uint_of_effset (xs2)))
implement
effset_union (xs1, xs2) = effset_of_uint (g0uint_lor_uint (uint_of_effset (xs1), uint_of_effset (xs2)))

(* ****** ****** *)

implement
fprint_effset
  (out, efs) = let
//
fun loop (
  out: FILEref
, efs: effset, n: int, i: int, k: int
) : void = let
in
//
if i < n then let
  val eff = $UN.cast{effect} (g0int2uint_int_uint (i))
  val isint =
    effset_is_inter (efs, effset_sing (eff))
  val k1 = (
    if isint then let
      val () = if (k > 0) then fprint_string (out, ", ")
      val () = fprint_effect (out, eff)
    in k + 1 end else k
  ) : int
in
  loop (out, efs, n, i+1, k1)
end // end of [if]
//
end // end of [loop]
//
in
//
if effset_isnil(efs) then fprint_string (out, "0")
else if effset_isall(efs) then fprint_string (out, "1")
else (
  fprint_string (out, "[");
  loop (out, efs, MAX_EFFECT_NUMBER, 0, 0);
  fprint_string (out, "]");
) (* end of [if] *)
//
end // end of [fprint_effset]

implement
print_effset (x) = fprint_effset (stdout_ref, x)
implement
prerr_effset (x) = fprint_effset (stderr_ref, x)

(* ****** ****** *)

(* end of [pats_effect.dats] *)
