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
// Start Time: November, 2011
//
(* ****** ****** *)
//
// HX-2011-11-17:
// for handling syntactic constants (int, bool, char, string, float) during
// translation of level 3
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans3_syncst.dats, see PORTING.md,
// "Level 3 translation, group 1 (dynexp_up/util/syncst)")
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

(* ****** ****** *)

staload INT = "./pats_intinf.sats"
stadef intinf = $INT.intinf // integers of infinite precision

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_syncst"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef loc_t = $LOC.location

(* ****** ****** *)

(*
** for T_* constructors
*)
staload "./pats_lexing.sats"

(* ****** ****** *)

staload SYN = "./pats_syntax.sats"

(* ****** ****** *)
//
staload "./pats_staexp2.sats"
staload "./pats_stacst2.sats"
//
staload "./pats_dynexp2.sats"
//
staload "./pats_dynexp3.sats"
//
(* ****** ****** *)

staload "./pats_trans3.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats" // [token_int_rep], [token_float_rep], ...

(* ****** ****** *)
//
// HX: [val-T_INT (base, rep, sfx) = x.token_node] and [val-T_FLOAT (base, rep, sfx) = ..]
// (a token of another kind is the MatchError of ATS1)
//
fn
token_int_get
  (tok: token): @(int, string, uint) =
(
case+ token_node_view (tok.token_node ()) of
| ~T_INT (base, rep, sfx) => @(base, rep, sfx)
| v => (token_node_view_free (v); (assertloc (false); @(0, "", 0u)))
) (* end of [token_int_get] *)
//
fn
token_float_get
  (tok: token): @(int, string, uint) =
(
case+ token_node_view (tok.token_node ()) of
| ~T_FLOAT (base, rep, sfx) => @(base, rep, sfx)
| v => (token_node_view_free (v); (assertloc (false); @(0, "", 0u)))
) (* end of [token_float_get] *)
//
(* ****** ****** *)

implement
d2exp_trup_int
  (d2e0, i) = let
  val loc0 = d2e0.d2exp_loc ()
  val s2f = s2exp_int_int_t0ype (i)
in
  d3exp_int (loc0, s2f, i)
end // end of [d2exp_trup_int]

(* ****** ****** *)

implement
d2exp_trup_intrep
  (d2e0, rep) = let
  val loc0 = d2e0.d2exp_loc ()
  val s2f = intrep_syn_type_ind (loc0, rep)
in
  d3exp_intrep (loc0, s2f, rep)
end // end of [d2exp_trup_intrep]

(* ****** ****** *)

implement
d2exp_trup_bool
  (d2e0, b) = let
  val
  loc0 = d2e0.d2exp_loc ()
  val s2f0 =
    s2exp_bool_bool_t0ype(b) in d3exp_bool(loc0, s2f0, b)
end // end of [d2exp_trup_bool]

(* ****** ****** *)

implement
d2exp_trup_char
  (d2e0, c) = let
  val
  loc0 = d2e0.d2exp_loc ()
  val i = char2int0 (c)
  val s2f0 = s2exp_char_int_t0ype(i) in d3exp_char(loc0, s2f0, c)
end // end of [d2exp_trup_char]

(* ****** ****** *)

implement
d2exp_trup_string
  (d2e0, str) = let
  val
  loc0 = d2e0.d2exp_loc ()
  val n = string0_length (str)
  val s2f = s2exp_string_int_type (n)
in
  d3exp_string (loc0, s2f, str)
end // end of [d2exp_trup_string]

(* ****** ****** *)
//
// HX: implemented in [pats_utils.dats]
//
extern
fun strcasecmp
  (x1: string, x2: string):<> int = "ext#patsopt_strcasecmp"
// end of [strcasecmp]

(* ****** ****** *)
//
// HX: the string that begins at the [sfx]-th character from the end of [rep]
// (the suffix of an integer or a floating point number)
//
fn
rep_get_sfx
  (rep: string, sfx: uint): string = let
  val n = string0_length (rep)
  val ln = n - $UN.cast{size_t}(sfx)
in
  $UN.cast{string}(ptr0_add_guint<char> ($UN.cast{ptr}(rep), ln))
end // end of [rep_get_sfx]

(* ****** ****** *)
//
// HX: [string_make_substring] of ATS1 ([atspre_string_make_substring], freed by [ats_free_gc]);
// the copy lives in the global arena (as in [pats_patcst2.dats])
//
fn
my_make_substring
(
  origin: string, start: size_t, length: size_t
) : string = let
  val p = the_garena_alloc (length + i2sz(1))
  val () = $extfcall (void, "memcpy", p, ptr0_add_guint<char> ($UN.cast{ptr}(origin), start), length)
  val () = $UN.ptr0_set<char> (ptr0_add_guint<char> (p, length), '\000')
in
  $UN.cast{string}(p)
end // end of [my_make_substring]

(* ****** ****** *)

local

datatype intknd =
  | IK_INT | IK_UINT | IK_LINT | IK_ULINT | IK_LLINT | IK_ULLINT | IK_ERROR
// end of [intknd]

fn
intknd_of_sfx
  (sfx: string): intknd =
(
if strcasecmp (sfx, "U") = 0 then IK_UINT
//
else if strcasecmp (sfx, "L") = 0 then IK_LINT
else if strcasecmp (sfx, "UL") = 0 then IK_ULINT
else if strcasecmp (sfx, "LU") = 0 then IK_ULINT
//
else if strcasecmp (sfx, "LL") = 0 then IK_LLINT
else if strcasecmp (sfx, "ULL") = 0 then IK_ULLINT
else if strcasecmp (sfx, "LLU") = 0 then IK_ULLINT
//
else IK_ERROR
) (* end of [intknd_of_sfx] *)

in (* in of [local] *)

fun
intrepsfx_syn_type
(
  loc0: loc_t
, rep: string, sfx: uint
) : s2exp = let
in
//
if sfx = 0u
  then s2exp_int_t0ype ()
  else let
    val sfx = rep_get_sfx (rep, sfx)
    val knd = intknd_of_sfx (sfx)
  in
    case+ knd of
    | IK_INT () => s2exp_int_t0ype ()
    | IK_UINT () => s2exp_uint_t0ype ()
    | IK_LINT () => s2exp_lint_t0ype ()
    | IK_ULINT () => s2exp_ulint_t0ype ()
    | IK_LLINT () => s2exp_llint_t0ype ()
    | IK_ULLINT () => s2exp_ullint_t0ype ()
    | _ => let
        val () = prerr_error3_loc (loc0)
        val () = filprerr_ifdebug "intrepsfx_syn_type"
        val () = prerr ": the suffix of the integer is not supported."
        val () = prerr_newline ((*void*))
        val () = the_trans3errlst_add (trans3err_T3E_intsp (loc0, rep))
      in
        s2exp_t0ype_err ()
      end // end of [_]
   end // end of [else]
// end of [if]
end // end of [intrepsfx_syn_type]

(* ****** ****** *)
//
// HX: [rep] without its suffix, converted to an integer of infinite precision
//
fn
intbaserep_make
  (base: int, rep: string): intinf = let
  val [n:int] rep1 = g1ofg0 (rep)
in
//
case+ base of
| 8 => let
    prval () = $UN.prop_assert{n >= 1} ()
  in
    $INT.intinf_make_base_string_ofs (8, rep1, 1(*0*))
  end // end of [8]
| 16 => let
    prval () = $UN.prop_assert{n >= 2} ()
  in
    $INT.intinf_make_base_string_ofs (16, rep1, 2(*0x*))
  end // end of [16]
| _ => // base=10 and ofs=0
    $INT.intinf_make_base_string_ofs (10, rep1, 0)
  // end of [_]
//
end // end of [intbaserep_make]

fun
intbaserepsfx_syn_type_ind
(
  loc0: loc_t
, base: int, rep: string, sfx: uint
) : s2exp = let
//
  val inf = (
    if sfx > 0u then let
      val n = string0_length (rep)
      val ln = n - $UN.cast{size_t}(sfx)
      val rep1 = my_make_substring (rep, i2sz(0), ln)
      val inf = intbaserep_make (base, rep1)
    in
      inf
    end else intbaserep_make (base, rep)
  ) : intinf // end of [val]
//
in
//
if sfx = 0u
  then s2exp_int_intinf_t0ype (inf)
  else let
    val sfx = rep_get_sfx (rep, sfx)
    val knd = intknd_of_sfx (sfx)
  in
    case+ knd of
    | IK_INT () => s2exp_int_intinf_t0ype (inf)
    | IK_UINT () => s2exp_uint_intinf_t0ype (inf)
    | IK_LINT () => s2exp_lint_intinf_t0ype (inf)
    | IK_ULINT () => s2exp_ulint_intinf_t0ype (inf)
    | IK_LLINT () => s2exp_llint_intinf_t0ype (inf)
    | IK_ULLINT () => s2exp_ullint_intinf_t0ype (inf)
    | _ => let
        val () = prerr_error3_loc (loc0)
        val () = filprerr_ifdebug "intbaserepsfx_syn_type_ind"
        val () = prerr ": the suffix of the integer is not supported."
        val () = prerr_newline ((*void*))
        val () = the_trans3errlst_add (trans3err_T3E_intsp (loc0, rep))
      in
        s2exp_t0ype_err ()
      end // end of [_]
  end // end of [else]
// end of [if]
//
end // end of [intbaserepsfx_syn_type_ind]

end // end of [local]

(* ****** ****** *)

implement
intrep_syn_type
  (loc0, rep) = let
  val sfx = $UT.intrep_get_nsfx (rep)
in
  intrepsfx_syn_type (loc0, rep, sfx)
end // end of [intrep_syn_type]

implement
intrep_syn_type_ind
  (loc0, rep) = let
  val base =
    $UT.intrep_get_base (rep)
  val sfx = $UT.intrep_get_nsfx (rep)
in
  intbaserepsfx_syn_type_ind (loc0, base, rep, sfx)
end // end of [intrep_syn_type_ind]

implement
i0nt_syn_type
  (x(*i0nt*)) = let
//
val loc0 = x.token_loc ()
val (base, rep, sfx) = token_int_get (x)
//
in
  intrepsfx_syn_type (loc0, rep, sfx)
end // end of [i0nt_syn_t0ype]

implement
i0nt_syn_type_ind
  (x(*i0nt*)) = let
//
val loc0 = x.token_loc ()
val (base, rep, sfx) = token_int_get (x)
//
in
  intbaserepsfx_syn_type_ind (loc0, base, rep, sfx)
end // end of [i0nt_syn_type_ind]

(* ****** ****** *)

implement
d2exp_trup_i0nt
  (d2e0, x(*i0nt*)) = let
  val loc0 = d2e0.d2exp_loc ()
  val s2e0 = i0nt_syn_type_ind (x)
in
  d3exp_i0nt (loc0, s2e0, x)
end // end of [d2exp_trup_i0nt]

(* ****** ****** *)

local

datatype fltknd =
  | FK_FLOAT | FK_DOUBLE | FK_LDOUBLE | FK_ERROR
// end of [fltknd]

in (* in of [local] *)

fun
floatsfx_syn_type
(
  loc0: loc_t, rep: string, sfx: uint
) : s2exp = (
if sfx = 0u
  then s2exp_double_t0ype ()
  else let (* sfx > 0 *)
    val sfx = rep_get_sfx (rep, sfx)
    val knd = (
      if strcasecmp (sfx, "F") = 0 then FK_FLOAT
(*
      else if strcasecmp (sfx, "D") = 0 then FK_DOUBLE
*)
      else if strcasecmp (sfx, "L") = 0 then FK_LDOUBLE
      else FK_ERROR
    ) : fltknd // end of [val]
  in
    case+ knd of
    | FK_FLOAT () => s2exp_float_t0ype ()
    | FK_DOUBLE () => s2exp_double_t0ype ()
    | FK_LDOUBLE () => s2exp_ldouble_t0ype ()
    | _ => let
        val () = prerr_error3_loc (loc0)
        val () = filprerr_ifdebug "f0loat_syn_type"
        val () = prerr ": the suffix of the floating point number is not supported."
        val () = prerr_newline ((*void*))
        val () = the_trans3errlst_add (trans3err_T3E_floatsp (loc0, rep))
      in
        s2exp_t0ype_err ()
      end // end of [_]
   end // end of [else]
) // end of [floatsfx_syn_type]

end // end of [local]

implement
float_syn_type
  (loc0, rep) = let
  val sfx = $UT.float_get_nsfx (rep)
in
  floatsfx_syn_type (loc0, rep, sfx)
end // end of [float_syn_type]

implement
f0loat_syn_type
  (x(*f0loat*)) = let
  val loc0 = x.token_loc ()
  val (base, rep, sfx) = token_float_get (x)
in
  floatsfx_syn_type (loc0, rep, sfx)
end // end of [f0loat_syn_type]

(* ****** ****** *)

implement
d2exp_trup_float
  (d2e0, rep) = let
  val loc0 = d2e0.d2exp_loc ()
  val s2f = float_syn_type (loc0, rep)
in
  d3exp_float (loc0, s2f, rep)
end // end of [d2exp_trup_float]

implement
d2exp_trup_f0loat
  (d2e0, x(*f0loat*)) = let
  val loc0 = d2e0.d2exp_loc ()
  val s2f = f0loat_syn_type (x)
  val (base, rep, sfx) = token_float_get (x)
in
  d3exp_f0loat (loc0, s2f, x)
end // end of [d2exp_trup_f0loat]

(* ****** ****** *)

implement
cstsp_syn_type
  (d2e0, csp) = let
in
//
case+ csp of
| $SYN.CSTSPmyfil () => s2exp_string_type ()
| $SYN.CSTSPmyloc () => s2exp_string_type ()
| $SYN.CSTSPmyfun () => s2exp_string_type ()
(*
| $SYN.CSTSPmylinecnt (int) => s2exp_int_t0ype ()
| $SYN.CSTSPmycharcnt (int) => s2exp_lint_t0ype ()
*)
//
end // end of [cstsp_syn_type]

implement
d2exp_trup_cstsp
  (d2e0, csp) = let
//
val s2f =
  cstsp_syn_type (d2e0, csp)
//
in
  d3exp_cstsp (d2e0.d2exp_loc (), s2f, csp)
end // end of [d2exp_trup_cstsp]

(* ****** ****** *)

implement
d2exp_trup_tyrep
  (d2e0, s2e_rep) = let
//
val
s2f =
s2exp_extype_srt
(
  s2rt_t0ype
, "atstype_tyrep", glist_nil((*s2ess*))
) (* s2exp_extype *)
//
in
  d3exp_tyrep(d2e0.d2exp_loc (), s2f, s2e_rep)
end // end of [d2exp_trup_tyrep]

(* ****** ****** *)

implement
d2exp_trup_literal
  (d2e0, d2e_lit) = let
//
val loc0 = d2e0.d2exp_loc ()
//
val ((*void*)) =
(
  print_string ("d2exp_trup_literal: d2e0 = ");
  print_d2exp (d2e0); print_newline ()
) (* end of [val] *)
//
in
//
case+ d2exp_node_view (d2e_lit.d2exp_node ()) of
//
| ~D2Efloat (rep) => let
    val d3e_lit =
      d2exp_trup_float (d2e_lit, rep)
    // end of [val]
    val s2e0 = s2exp_literal_float (rep)
  in
    d3exp_literal (loc0, s2e0, d3e_lit)
  end // end of [D2Efloat]
| ~D2Ef0loat (tok) => let
    val rep = token_float_rep (tok) // [val-T_FLOAT (_, rep, _) = tok.token_node]
    val d3e_lit =
      d2exp_trup_f0loat (d2e_lit, tok)
    // end of [val]
    val s2e0 = s2exp_literal_float (rep)
  in
    d3exp_literal (loc0, s2e0, d3e_lit)
  end // end of [D2Ef0loat]
//
| ~D2Estring (str) => let
    val d3e_lit =
      d2exp_trup_string (d2e_lit, str)
    // end of [val]
    val s2e0 = s2exp_literal_string (str)
  in
    d3exp_literal (loc0, s2e0, d3e_lit)
  end // end of [D2Estring]
| ~D2Es0tring (tok) => let
    val str = token_string_get (tok) // [val-T_STRING(str) = tok.token_node]
    val d3e_lit =
      d2exp_trup_string (d2e_lit, str)
    // end of [val]
    val s2e0 = s2exp_literal_string (str)
  in
    d3exp_literal (loc0, s2e0, d3e_lit)
  end // end of [D2Es0tring]
//
| v (* rest-of-D2E *) => (d2exp_node_view_free (v); d3exp_errexp (loc0))
//
end // end of [d2exp_trup_literal]

(* ****** ****** *)

(* end of [pats_trans3_syncst.dats] *)
