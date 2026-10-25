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
// Start Time: September, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_hidynexp_util.dats, see PORTING.md, "Erased trees (hidynexp)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
  ((*void*)) = prerr "pats_hidynexp_util"
//
(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"
overload = with $LAB.eq_label_label

(* ****** ****** *)

staload LOC = "./pats_location.sats"
overload print with $LOC.print_location

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload S2E = "./pats_staexp2.sats"
staload D2E = "./pats_dynexp2.sats"
overload = with $S2E.eq_d2con_d2con
overload = with $D2E.eq_d2var_d2var

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)
//
implement
d2cst_get2_hisexp (d2c) =
  $UN.cast{hisexpopt}($D2E.d2cst_get_hisexp(d2c))
implement
d2cst_set2_hisexp (d2c, opt) =
  $D2E.d2cst_set_hisexp (d2c, $UN.cast{$D2E.hisexpopt}(opt))
//
(* ****** ****** *)

implement
$D2E.d2cst_is_fun
  (d2c) = let
//
val opt = d2cst_get2_hisexp (d2c)
val () = assertloc (gopt_is_some (opt)) // HX: [val-Some (hse)]
val hse = gopt_unsome (opt)
//
in
//
case+
  hisexp_node_view (hse.hisexp_node()) of
| ~HSEfun (fc, _arg, _res) =>
  (
    case+ fc of FUNCLOfun () => true | _ => false
  ) // end of [HSEfun]
| v => (hisexp_node_view_free (v); false) // end of [_]
//
end // end of [$D2E.d2cst_is_fun]

(* ****** ****** *)

implement
d2cst_get2_type_arg
  (d2c) = let
//
val opt = d2cst_get2_hisexp (d2c)
val () = assertloc (gopt_is_some (opt)) // HX: [val-Some (hse)]
val hse = gopt_unsome (opt)
//
in
//
case+ hisexp_node_view (hse.hisexp_node()) of
| ~HSEfun (
    _(*fc*), _arg, _(*res*)
  ) => _arg
| v => let
    val () = hisexp_node_view_free (v)
    val () = prerr_interror ()
    val () = prerr_string (": d2cst_get_type_arg: hse = ")
    val () = prerr_hisexp (hse)
    val () = prerr_newline ()
    val () = assertloc (false)
  in
    $ERR.abort_interr<hisexplst> () // HX: this is deadcode
  end (* end of [_] *)
//
end // end of [d2cst_get2_type_arg]

implement
d2cst_get2_type_res
  (d2c) = let
//
val opt = d2cst_get2_hisexp (d2c)
val () = assertloc (gopt_is_some (opt)) // HX: [val-Some (hse)]
val hse = gopt_unsome (opt)
//
in
//
case+
  hisexp_node_view (hse.hisexp_node()) of
| ~HSEfun (
    _(*fc*), _(*arg*), _res
  ) => _res
| v => let
    val () = hisexp_node_view_free (v)
    val () = prerr_interror ()
    val () = prerr_string (": d2cst_get_type_arg: hse = ")
    val () = prerr_hisexp (hse)
    val () = prerr_newline ()
    val () = assertloc (false)
  in
    $ERR.abort_interr<hisexp> () // HX: this is deadcode
  end (* end of [_] *)
//
end // end of [d2cst_get_type_res]

(* ****** ****** *)
//
implement
d2var_get2_hisexp (d2v) =
  $UN.cast{hisexpopt}($D2E.d2var_get_hisexp(d2v))
implement
d2var_set2_hisexp (d2v, opt) =
  $D2E.d2var_set_hisexp (d2v, $UN.cast{$D2E.hisexpopt}(opt))
//
(* ****** ****** *)

implement
d2cst_get2_funclo (d2c) = let
  val opt = d2cst_get2_hisexp (d2c)
in
//
if gopt_is_some (opt) then let
  val hse = gopt_unsome (opt)
in
  case+ hisexp_node_view (hse.hisexp_node()) of
  | ~HSEfun (fc, _, _) => Some_vt (fc)
  | v => (hisexp_node_view_free (v); None_vt ())
end else None_vt ()
//
end // end of [d2cst_get2_funclo]

(* ****** ****** *)

implement
d2var_get2_funclo (d2v) = let
  val opt = d2var_get2_hisexp (d2v)
in
//
if gopt_is_some (opt) then let
  val hse = gopt_unsome (opt)
in
  case+ hisexp_node_view (hse.hisexp_node()) of
  | ~HSEfun (fc, _, _) => Some_vt (fc)
  | v => (hisexp_node_view_free (v); None_vt ())
end else None_vt ()
//
end // end of [d2var_get2_funclo]

(* ****** ****** *)

fun
hipatlst_forall_wild
  (hips: hipatlst): bool =
  if glist_is_cons (hips)
    then (
      if hipat_is_wild (glist_head<hipat> (hips))
        then hipatlst_forall_wild (glist_tail<hipat> (hips)) else false
    ) else true
// end of [hipatlst_forall_wild]

implement
hipat_is_wild
  (hip) = let
//
val nd = hip.hipat_node()
//
in
//
if hipat_node_is_HIPany (nd) then true
else if hipat_node_is_HIPvar (nd) then true
else if hipat_node_is_HIPann (nd) then let
  val-~HIPann (hip, _) = hipat_node_view (nd) in hipat_is_wild (hip)
end else if hipat_node_is_HIPrefas (nd) then let
  val-~HIPrefas (_, hip) = hipat_node_view (nd) in hipat_is_wild (hip)
end else false
//
end // end of [hipat_is_wild]

implement
hipatlst_is_wild
  (hips) = hipatlst_forall_wild (hips)
// end of [hipatlst_is_wild]

implement
labhipatlst_is_wild
  (lhips) = let
//
fun labhipat_is_wild
  (lhip: labhipat): bool = hipat_is_wild (lhip.labhipat_elt())
// end of [labhipat_is_wild]
//
fun loop
  (lhips: labhipatlst): bool =
  if glist_is_cons (lhips)
    then (
      if labhipat_is_wild (glist_head<labhipat> (lhips))
        then loop (glist_tail<labhipat> (lhips)) else false
    ) else true
//
in
  loop (lhips)
end // end of [labhipatlst_is_wild]

(* ****** ****** *)

implement
hipat_subtest
  (hip1, hip2) = let
//
val hipn1 = hip1.hipat_node()
val hipn2 = hip2.hipat_node()
//
in
//
if hipat_node_is_HIPany (hipn2) then true
else if hipat_node_is_HIPvar (hipn2) then true
else if hipat_node_is_HIPann (hipn2) then let
  val-~HIPann (hip2, _) = hipat_node_view (hipn2) in hipat_subtest (hip1, hip2)
end else if hipat_node_is_HIPrefas (hipn2) then let
  val-~HIPrefas (_, hip2) = hipat_node_view (hipn2) in hipat_subtest (hip1, hip2)
end else if hipat_node_is_HIPann (hipn1) then let
  val-~HIPann (hip1, _) = hipat_node_view (hipn1) in hipat_subtest (hip1, hip2)
end else if hipat_node_is_HIPrefas (hipn1) then let
  val-~HIPrefas (_, hip1) = hipat_node_view (hipn1) in hipat_subtest (hip1, hip2)
end else if hipat_node_is_HIPcon (hipn1) then let
  val-~HIPcon (_, d2c1, _, lxs1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPcon (hipn2) then let
    val-~HIPcon (_, d2c2, _, lxs2) = hipat_node_view (hipn2)
  in
    if d2c1 = d2c2
      then labhipatlst_subtest (lxs1, lxs2) else false
    // end of [if]
  end else if hipat_node_is_HIPcon_any (hipn2) then let
    val-~HIPcon_any (_, d2c2) = hipat_node_view (hipn2) in d2c1 = d2c2
  end else false (* non-HIPcon *)
end else if hipat_node_is_HIPcon_any (hipn1) then let
  val-~HIPcon_any (_, d2c1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPcon (hipn2) then let
    val-~HIPcon (_, d2c2, _, lxs2) = hipat_node_view (hipn2)
  in
    if d2c1 = d2c2 then labhipatlst_is_wild (lxs2) else false
  end else if hipat_node_is_HIPcon_any (hipn2) then let
    val-~HIPcon_any (_, d2c2) = hipat_node_view (hipn2) in d2c1 = d2c2
  end else false (* non-HIPcon *)
end else if hipat_node_is_HIPint (hipn1) then let
  val-~HIPint (i1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPint (hipn2) then let
    val-~HIPint (i2) = hipat_node_view (hipn2) in i1 = i2
  end else false
end else if hipat_node_is_HIPbool (hipn1) then let
  val-~HIPbool (b1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPbool (hipn2) then let
    val-~HIPbool (b2) = hipat_node_view (hipn2) in b1 = b2
  end else false
end else if hipat_node_is_HIPchar (hipn1) then let
  val-~HIPchar (c1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPchar (hipn2) then let
    val-~HIPchar (c2) = hipat_node_view (hipn2) in c1 = c2
  end else false
end else if hipat_node_is_HIPstring (hipn1) then let
  val-~HIPstring (str1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPstring (hipn2) then let
    val-~HIPstring (str2) = hipat_node_view (hipn2) in str1 = str2
  end else false
end else if hipat_node_is_HIPfloat (hipn1) then let
  val-~HIPfloat (f1) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPfloat (hipn2) then let
    val-~HIPfloat (f2) = hipat_node_view (hipn2) in f1 = f2
  end else false
end else if hipat_node_is_HIPempty (hipn1) then
  hipat_node_is_HIPempty (hipn2)
else if hipat_node_is_HIPrec (hipn1) then let
  val-~HIPrec (_, _, lxs1, _) = hipat_node_view (hipn1)
in
  if hipat_node_is_HIPrec (hipn2) then let
    val-~HIPrec (_, _, lxs2, _) = hipat_node_view (hipn2)
  in
    labhipatlst_subtest (lxs1, lxs2)
  end else false
end else false (* rest-of-hipat-hipat *)
//
end // end of [hipat_subtest]

(* ****** ****** *)

implement
hipatlst_subtest
  (xs1, xs2) = let
in
//
if glist_is_cons (xs1) then (
  if glist_is_cons (xs2) then (
    if hipat_subtest (glist_head<hipat> (xs1), glist_head<hipat> (xs2))
      then hipatlst_subtest (glist_tail<hipat> (xs1), glist_tail<hipat> (xs2)) else false
    // end of [if]
  ) else false
) else (
  if glist_is_cons (xs2) then false else true
)
//
end // end of [hipatlst_subtest]

(* ****** ****** *)

fun labhipat_subtest
(
  lx1: labhipat, lx2: labhipat
) : bool = let
//
val l1 = lx1.labhipat_lab() and x1 = lx1.labhipat_elt()
val l2 = lx2.labhipat_lab() and x2 = lx2.labhipat_elt()
//
in
  if l1 = l2 then hipat_subtest (x1, x2) else false
end // end of [labhipat_subtest]

implement
labhipatlst_subtest
  (lxs1, lxs2) = let
in
//
if glist_is_cons (lxs1) then (
  if glist_is_cons (lxs2) then (
    if labhipat_subtest (glist_head<labhipat> (lxs1), glist_head<labhipat> (lxs2))
      then labhipatlst_subtest (glist_tail<labhipat> (lxs1), glist_tail<labhipat> (lxs2)) else false
    // end of [if]
  ) else false
) else (
  if glist_is_cons (lxs2) then false else true
)
//
end // end of [labhipatlst_subtest]

(* ****** ****** *)
//
implement
hidexp_is_empty
  (x0) = let
//
val nd = x0.hidexp_node()
//
in
//
if hidexp_node_is_HDEempty (nd) then true
else if hidexp_node_is_HDEfoldat (nd) then true
else if hidexp_node_is_HDEseq (nd) then let
  val-~HDEseq (hdes) = hidexp_node_view (nd) in hidexplst_isall_empty (hdes)
end else false (* rest-of-hidexp *)
//
end // end of [hidexp_is_empty]
//
implement
hidexplst_isall_empty
  (xs) =
  if glist_is_cons (xs)
    then (
      if hidexp_is_empty (glist_head<hidexp> (xs))
        then hidexplst_isall_empty (glist_tail<hidexp> (xs)) else false
    ) else true
implement
hidexplst_isexi_empty
  (xs) =
  if glist_is_cons (xs)
    then (
      if hidexp_is_empty (glist_head<hidexp> (xs))
        then true else hidexplst_isexi_empty (glist_tail<hidexp> (xs))
    ) else false
//
(* ****** ****** *)

fun
hidexplst_is_value
  (xs: hidexplst): bool =
  if glist_is_cons (xs)
    then (
      if hidexp_is_value (glist_head<hidexp> (xs))
        then hidexplst_is_value (glist_tail<hidexp> (xs)) else false
    ) else true
// end of [hidexplst_is_value]

fun
labhidexplst_is_value
  (lxs: labhidexplst): bool =
  if glist_is_cons (lxs)
    then let
      val lx = glist_head<labhidexp> (lxs)
    in
      if hidexp_is_value (lx.labhidexp_elt())
        then labhidexplst_is_value (glist_tail<labhidexp> (lxs)) else false
    end else true
// end of [labhidexplst_is_value]

fun
hidecl_is_value
  (hid0: hidecl): bool = let
//
val nd = hid0.hidecl_node()
//
in
//
if hidecl_node_is_HIDnone (nd) then true
else if hidecl_node_is_HIDlist (nd) then let
  val-~HIDlist (hids) = hidecl_node_view (nd) in hideclist_is_value (hids)
end else if hidecl_node_is_HIDfundecs (nd) then true
else if hidecl_node_is_HIDvaldecs (nd) then let
  val-~HIDvaldecs (_, hvds) = hidecl_node_view (nd) in hivaldecs_is_value (hvds)
end else false (* rest-of-hidecl *)
//
end // end of [hidecl_is_value]

and
hideclist_is_value
  (hids: hideclist): bool =
  if glist_is_cons (hids)
    then (
      if hidecl_is_value (glist_head<hidecl> (hids))
        then hideclist_is_value (glist_tail<hidecl> (hids)) else false
    ) else true
// end of [hideclist_is_value]

and
hivaldec_is_value
  (hvd: hivaldec): bool =
  hidexp_is_value(hvd.hivaldec_def())
//
and
hivaldecs_is_value
  (hvds: hivaldeclst): bool =
  if glist_is_cons (hvds)
    then (
      if hivaldec_is_value (glist_head<hivaldec> (hvds))
        then hivaldecs_is_value (glist_tail<hivaldec> (hvds)) else false
    ) else true

implement
hidexp_is_value
  (hde0) = let
//
val nd = hde0.hidexp_node()
//
in
//
if hidexp_node_is_HDEvar (nd) then true
else if hidexp_node_is_HDEcst (nd) then true
else if hidexp_node_is_HDEbool (nd) then true
else if hidexp_node_is_HDEchar (nd) then true
else if hidexp_node_is_HDEstring (nd) then true
else if hidexp_node_is_HDEi0nt (nd) then true
else if hidexp_node_is_HDEf0loat (nd) then true
else if hidexp_node_is_HDEextval (nd) then true
else if hidexp_node_is_HDElam (nd) then true
else if hidexp_node_is_HDErec (nd) then let
  val-~HDErec (_, lhdes, _) = hidexp_node_view (nd) in labhidexplst_is_value (lhdes)
end else if hidexp_node_is_HDEtmpcst (nd) then true
else if hidexp_node_is_HDEtmpvar (nd) then true
else if hidexp_node_is_HDElet (nd) then let
  val-~HDElet (hids, hde) = hidexp_node_view (nd)
in
  if hideclist_is_value(hids) then hidexp_is_value(hde) else false
end else false (* rest-of-hidexp *)
//
end // end of [hidexp_is_value]

(* ****** ****** *)

fun
auxseq
(
  hde: hidexp, hdes: hidexplst
) : bool =
(
  if glist_is_cons (hdes)
    then auxseq (glist_head<hidexp> (hdes), glist_tail<hidexp> (hdes))
    else hidexp_is_lvalue (hde)
) (* end of [auxseq] *)

implement
hidexp_is_lvalue
  (hde0) = let
//
val nd = hde0.hidexp_node()
//
in
//
if hidexp_node_is_HDEvar (nd) then let
  val-~HDEvar (d2v) = hidexp_node_view (nd) in $D2E.d2var_is_mutabl (d2v)
end else if hidexp_node_is_HDEselvar (nd) then let
  val-~HDEselvar (d2v, _, _) = hidexp_node_view (nd) in $D2E.d2var_is_mutabl (d2v)
end else if hidexp_node_is_HDEselptr (nd) then true
else if hidexp_node_is_HDEseq (nd) then let
  val-~HDEseq (hdes) = hidexp_node_view (nd)
in
  if glist_is_cons (hdes)
    then auxseq (glist_head<hidexp> (hdes), glist_tail<hidexp> (hdes)) else false
end else false (* non-lvalue *)
//
end // end of [hidexp_is_lvalue]

(* ****** ****** *)

implement
hidecl_is_empty (hid) = let
//
val nd = hid.hidecl_node()
//
in
//
if hidecl_node_is_HIDnone (nd) then true
else if hidecl_node_is_HIDlist (nd) then let
  val-~HIDlist (xs) = hidecl_node_view (nd) in glist_is_nil (xs)
end else if hidecl_node_is_HIDfundecs (nd) then let
  val-~HIDfundecs (_, _, xs) = hidecl_node_view (nd) in glist_is_nil (xs)
end else if hidecl_node_is_HIDvaldecs (nd) then let
  val-~HIDvaldecs (_, xs) = hidecl_node_view (nd) in glist_is_nil (xs)
end else if hidecl_node_is_HIDvaldecs_rec (nd) then let
  val-~HIDvaldecs_rec (_, xs) = hidecl_node_view (nd) in glist_is_nil (xs)
end else false (* rest-of-hidecl *)
//
end // end of [hidecl_is_empty]

(* ****** ****** *)

fun
hidexplst_filter_nonempty
  (xs: hidexplst): hidexplst =
  if glist_is_cons (xs) then let
    val x = glist_head<hidexp> (xs)
    val isemp = hidexp_is_empty (x)
    val xs1 = hidexplst_filter_nonempty (glist_tail<hidexp> (xs))
  in
    if isemp then xs1 else glist_cons (x, xs1)
  end else glist_nil ((*void*))
// end of [hidexplst_filter_nonempty]

implement
hidexp_seq_simplify
  (loc, hse0, hdes) = let
//
val isexi =
  hidexplst_isexi_empty(hdes)
//
val hdes = (
//
if
isexi
then hidexplst_filter_nonempty (hdes)
else hdes // end of [else]
//
) : hidexplst // end of [val]
//
in
  if glist_is_cons (hdes) andalso glist_is_nil (glist_tail<hidexp> (hdes))
    then glist_head<hidexp> (hdes) // list_sing
    else hidexp_seq(loc, hse0, hdes) (* non-singleton *)
end // end of [hidexp_seq_simplify]

(* ****** ****** *)

typedef d2var = $D2E.d2var

datavtype
hdevaremp =
  | HDEVEnone of ()
  | HDEVEsome_var of (d2var)
  | HDEVEsome_emp of ((*void*))
// end of [hdevaremp]

fun hidexp_is_varemp
  (hde0: hidexp): hdevaremp = let
//
val nd = hde0.hidexp_node()
//
in
//
if hidexp_node_is_HDEvar (nd) then let
  val-~HDEvar (d2v) = hidexp_node_view (nd) in HDEVEsome_var (d2v)
end else if hidexp_node_is_HDEempty (nd) then HDEVEsome_emp ((*void*))
else if hidexp_node_is_HDEfoldat (nd) then HDEVEsome_emp ((*void*))
else if hidexp_node_is_HDErec (nd) then let
  val-~HDErec (knd, lhdes, _) = hidexp_node_view (nd)
in
  if knd = 0 then (
    if glist_is_cons (lhdes) andalso glist_is_nil (glist_tail<labhidexp> (lhdes))
      then let
        val lhde = glist_head<labhidexp> (lhdes)
      in
        hidexp_is_varemp (lhde.labhidexp_elt())
      end  // end of [list_cons (_, list_nil)]
      else HDEVEnone ()
  ) else HDEVEnone () // end of [if]
end (* end of [HIErec] *)
else HDEVEnone ((*void*))
//
end // end of [hidexp_is_varemp]

datavtype
hianybind =
  | HABNDnone of ()
  | HABNDsome_any of hidexp
  | HABNDsome_var of (d2var, hidexp)
  | HABNDsome_emp of hidexp

fun hidecl_is_anybind_aux
(
  hip0: hipat, hde: hidexp
) : hianybind = let
//
val nd = hip0.hipat_node()
//
in
//
if hipat_node_is_HIPany (nd) then HABNDsome_any (hde)
else if hipat_node_is_HIPvar (nd) then let
  val-~HIPvar (d2v) = hipat_node_view (nd) in HABNDsome_var(d2v, hde)
end else if hipat_node_is_HIPempty (nd) then HABNDsome_emp(hde)
else if hipat_node_is_HIPrec (nd) then let
  val-~HIPrec (knd, pck, lhips, hse_rec) = hipat_node_view (nd)
in
  if knd = 0 then
  (
  if glist_is_cons (lhips) andalso glist_is_nil (glist_tail<labhipat> (lhips))
    then let
      val lhip = glist_head<labhipat> (lhips)
    in
      hidecl_is_anybind_aux (lhip.labhipat_elt(), hde)
    end
    else HABNDnone () (* non-list_sing *)
  ) else HABNDnone () // end of [if]
end (* end of [HIPrec] *)
else HABNDnone ((*void*)) (* rest-of-hipat *)
//
end // end of [hidecl_is_anybind_aux]

fun hidecl_is_anybind
  (hid0: hidecl): hianybind = let
//
val nd = hid0.hidecl_node()
//
in
//
if hidecl_node_is_HIDvaldecs (nd) then let
  val-~HIDvaldecs (_, hvds) = hidecl_node_view (nd)
in
  if glist_is_cons (hvds) andalso glist_is_nil (glist_tail<hivaldec> (hvds))
    then let
      val hvd = glist_head<hivaldec> (hvds)
    in
      hidecl_is_anybind_aux (hvd.hivaldec_pat(), hvd.hivaldec_def())
    end
    else HABNDnone ((*void*)) (* non-list_sing*)
end else HABNDnone((*void*)) (* non-HIDvaldecs*)
//
end // end of [hidecl_is_anybind]

fun hideclist_last
  (xs: hideclist): hidecl = let
  val x = glist_head<hidecl> (xs)
  val xs1 = glist_tail<hidecl> (xs)
in
  if glist_is_cons (xs1) then hideclist_last (xs1) else x
end // end of [hideclist_last]

fun dropz
(
  xs: hideclist
) : hideclist = let
//
val x = glist_head<hidecl> (xs)
val xs1 = glist_tail<hidecl> (xs)
//
in
//
if glist_is_cons (xs1)
  then glist_cons (x, dropz (xs1)) else glist_nil ()
//
end // end of [dropz]

implement
hidexp_let_simplify
  (loc, hse, hids, hde) = let
//
in
//
if glist_is_cons (hids) then let
    val opt = hidexp_is_varemp (hde)
  in
    case+ opt of
    | ~HDEVEsome_var (d2v) => let
        val hid = hideclist_last (hids)
        val opt2 = hidecl_is_anybind (hid)
      in
        case+ opt2 of
        | ~HABNDnone () =>
            hidexp_let (loc, hse, hids, hde)
        | ~HABNDsome_var
            (d2v2, hde2) =>
            if not(d2v=d2v2)
              then hidexp_let (loc, hse, hids, hde)
              else hidexp_let (loc, hse, dropz(hids), hde2)
            // end of [if]
        | ~HABNDsome_any _ => hidexp_let (loc, hse, hids, hde)
        | ~HABNDsome_emp _ => hidexp_let (loc, hse, hids, hde)
      end // end of [HDEVEsome_var]
    | ~HDEVEsome_emp ((*void*)) => let
        val hid = hideclist_last (hids)
        val opt2 = hidecl_is_anybind (hid)
      in
        case+ opt2 of
        | ~HABNDnone () =>
            hidexp_let (loc, hse, hids, hde)
        | ~HABNDsome_emp (hde2) =>
            hidexp_let (loc, hse, dropz (hids), hde2)
          // end of [HABNDsome_emp]
        | ~HABNDsome_any _ => hidexp_let (loc, hse, hids, hde)
        | ~HABNDsome_var _ => hidexp_let (loc, hse, hids, hde)
      end // end of [HDEVEsome_emp]
    | ~HDEVEnone () => hidexp_let (loc, hse, hids, hde)
  end // end of [list_cons]
//
else hde (* list_nil *)
//
end // end of [hidexp_let_simplify]

(* ****** ****** *)

(* end of [pats_hidynexp_util.dats] *)
