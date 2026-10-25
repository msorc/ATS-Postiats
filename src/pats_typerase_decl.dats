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
// HX-2026-10: no GC (ATS2 port of src/pats_typerase_decl.dats, see PORTING.md, "Type erasure (typerase)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_typerase_decl"
//
(* ****** ****** *)

staload LOC = "./pats_location.sats"
overload print with $LOC.print_location

(* ****** ****** *)

staload FIL = "./pats_filename.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
staload "./pats_dynexp3.sats"

(* ****** ****** *)

staload TRENV2 = "./pats_trans2_env.sats"
staload TRENV3 = "./pats_trans3_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_typerase.sats"

(* ****** ****** *)

#include "./pats_typerase.hats"

(* ****** ****** *)

staload _ = "./pats_dynexp2_dcst.dats"
staload _ = "./pats_dynexp2_dvar.dats"

(* ****** ****** *)

extern
fun d3ecl_tyer_impdec (d3c0: d3ecl): hidecl
extern
fun d3ecl_tyer_fundecs (d3c0: d3ecl): hidecl
extern
fun d3ecl_tyer_valdecs (d3c0: d3ecl): hidecl
extern
fun d3ecl_tyer_valdecs_rec (d3c0: d3ecl): hidecl
extern
fun d3ecl_tyer_vardecs (d3c0: d3ecl): hidecl

(* ****** ****** *)

extern
fun tmpcstimpmap_make_hideclist (xs: hideclist): tmpcstimpmap
extern
fun tmpvardecmap_make_hideclist (xs: hideclist): tmpvardecmap

(* ****** ****** *)

implement
d3ecl_tyer
  (d3c0) = let
//
val loc0 = d3c0.d3ecl_loc ()
//
in
//
case+
d3ecl_node_view (d3c0.d3ecl_node ()) of
//
| ~D3Cnone() => hidecl_none(loc0)
//
| ~D3Clist(d3cs) => let
    val hids =
      d3eclist_tyer(d3cs) in hidecl_list(loc0, hids)
    // end of [val]
  end // end of [D3Clist]
//
| ~D3Csaspdec(d2c) => hidecl_saspdec(loc0, d2c)
  // end of [D3Csaspdec]
| ~D3Creassume(s2c) => hidecl_reassume(loc0, s2c)
  // end of [D3Creassume]
//
| ~D3Cextype
    (name, s2e_def) => let
    val hse_def =
      s2exp_tyer_deep(loc0, s2e_def)
    // end of [val]
  in
    hidecl_extype(loc0, name, hse_def)
  end // end of [D3Cextype]
| ~D3Cextvar
    (name, d3e_def) =>
  (
    hidecl_extvar(loc0, name, d3exp_tyer(d3e_def))
  ) (* end of [D3Cextvar] *)
//
| ~D3Cextcode
    (knd, pos, code) => hidecl_extcode(loc0, knd, pos, code)
  // end of [D3Cextcode]
//
| ~D3Cexndecs
    (d2cs) => hidecl_exndecs(loc0, d2cs)
| ~D3Cdatdecs
    (knd, s2cs) => hidecl_datdecs(loc0, knd, s2cs)
//
| ~D3Cdcstdecs
    (knd, dck, d2cs) => hidecl_dcstdecs(loc0, dck, d2cs)
//
| ~D3Cimpdec (_, _) => d3ecl_tyer_impdec(d3c0)
//
| ~D3Cfundecs (_, _, _) => d3ecl_tyer_fundecs(d3c0)
//
| ~D3Cvaldecs (_, _) => d3ecl_tyer_valdecs(d3c0)
| ~D3Cvaldecs_rec (_, _) => d3ecl_tyer_valdecs_rec(d3c0)
//
| ~D3Cvardecs (_) => d3ecl_tyer_vardecs(d3c0)
//
| ~D3Cprvardecs (_) => hidecl_none (loc0) // proof vars
//
| ~D3Cinclude (knd, d3cs) => let
    val hids = d3eclist_tyer (d3cs) in hidecl_include (loc0, knd, hids)
  end // end of [D3Cinclude]
//
| ~D3Cstaload
  (
    idopt, fname, flag, fenv, loaded
  ) => let
    val opt =
      $TRENV3.filenv_get_d3eclistopt (fenv)
    // end of [val]
    val () = assertloc (gopt_is_some (opt)) // HX: [val-Some (d3cs)]
    val d3cs = gopt_unsome (opt)
//
    val () = (
      if (loaded = 0) then let
        val hids = d3eclist_tyer (d3cs)
//
        val tcimap = tmpcstimpmap_make_hideclist (hids)
        val p = $TRENV2.filenv_getref_tmpcstimpmap (fenv)
        val () = $UN.ptr0_set<tmpcstimpmapopt> (p, gopt_some (tcimap))
//
        val tvdmap = tmpvardecmap_make_hideclist (hids)
        val p = $TRENV2.filenv_getref_tmpvardecmap (fenv)
        val () = $UN.ptr0_set<tmpvardecmapopt> (p, gopt_some (tvdmap))
//
      in
        // nothing
      end // end of [Some]
    ) : void // end of [val]
  in
    hidecl_staload (loc0, idopt, fname, flag, fenv, loaded)
  end // end of [D3Cstaload]
//
| ~D3Cstaloadloc
    (pfil, nspace, fenv) => let
    val opt =
      $TRENV3.filenv_get_d3eclistopt (fenv)
    val () = assertloc (gopt_is_some (opt)) // HX: [val-Some (d3cs)]
    val d3cs = gopt_unsome (opt)
    val hids = d3eclist_tyer (d3cs)
  in
    hidecl_staloadloc (loc0, pfil, nspace, hids)
  end // end of [D3Cstaloadloc]
//
| ~D3Cdynload (cfil) => hidecl_dynload (loc0, cfil)
//
| ~D3Clocal
    (d3cs_head, d3cs_body) => let
    val hids_head = d3eclist_tyer (d3cs_head)
    val hids_body = d3eclist_tyer (d3cs_body)
  in
    hidecl_local (loc0, hids_head, hids_body)
  end // end of [D3Clocal]
//
end // end of [d3ecl_tyer]

(* ****** ****** *)

implement
d3eclist_tyer
  (d3cs) = let
//
vtypedef res = List0_vt (hidecl)
//
fun loop
  (d3cs: d3eclist, res: res): res = let
in
//
if glist_is_cons (d3cs) then let
    val d3c = glist_head<d3ecl> (d3cs)
    val d3cs = glist_tail<d3ecl> (d3cs)
    val hid = d3ecl_tyer (d3c)
    val isemp = hidecl_is_empty (hid)
  in
    if isemp
      then loop (d3cs, res)
      else loop (d3cs, list_vt_cons (hid, res))
    // end of [if]
  end // end of [list_cons]
else res
//
end // end of [loop]
//
val hids = loop (d3cs, list_vt_nil ())
val hids = list_vt_reverse<hidecl> (hids)
//
in
  glist_make_list_vt (hids)
end // end of [d3eclist_tyer]

(* ****** ****** *)

implement
d3eclist_tyer_errck
  (d3cs) = hids where {
  val hids = d3eclist_tyer (d3cs)
  val () = the_trans4errlst_finalize ()
} // end of [d3eclist_tyer_errck]

(* ****** ****** *)

implement
d3ecl_tyer_impdec
  (d3c0) = let
//
val loc0 = d3c0.d3ecl_loc ()
val-~D3Cimpdec (knd, impdec) = d3ecl_node_view (d3c0.d3ecl_node ())
//
in
//
if
knd >= 0
then let
//
val loc = impdec.i3mpdec_loc ()
val d2c = impdec.i3mpdec_cst ()
val imparg = impdec.i3mpdec_imparg ()
val tmparg = impdec.i3mpdec_tmparg ()
val tmparg = s2explstlst_mhnfize (tmparg)
//
val d2c = d2cst_tyer (d2c)
val hse = d3exp_tyer (impdec.i3mpdec_def ())
val himp =
  hiimpdec_make (loc, knd, d2c, imparg, tmparg, hse)
// end of [val]
//
in
  hidecl_impdec (loc0, knd(*implmnt/implement*), himp)
end // end of [then]
else (
  hidecl_none (loc0)
) (* end of [else] *)
//
end // end of [d3ecl_tyer_impdec]

(* ****** ****** *)

implement
decarg2imparg (s2qs) = let
in
//
if glist_is_cons (s2qs) then let
    val s2q = glist_head<s2qua> (s2qs)
    val s2qs = glist_tail<s2qua> (s2qs)
  in
    glist_append<s2var> (s2q.s2qua_svs (), decarg2imparg (s2qs))
  end // end of [list_cons]
else glist_nil ((*void*))
//
end // end of [decarg2imparg]

(* ****** ****** *)

fun
f3undec_tyer
(
  imparg: s2varlst, f3d: f3undec
) : hifundec = let
//
val loc = f3d.f3undec_loc ()
//
val d2v_fun = f3d.f3undec_var ()
val d3e_def = f3d.f3undec_def ()
//
val isprf = d3exp_is_prf (d3e_def)
//
val () = (
//
if
isprf
then let
//
val () = prerr_error4_loc (loc)
val () = (
  prerr_string (": [fun] should be replaced with [prfun].");
  prerr_newline ()
) (* end of [val] *)
//
in
  the_trans4errlst_add (trans4err_T4E_d3exp_tyer_isprf (d3e_def))
end // end of [if]
//
) (* end of [val] *)
//
val d2v_fun = d2var_tyer (d2v_fun)
val hde_def = d3exp_tyer (d3e_def)
//
in
  hifundec_make (loc, d2v_fun, imparg, hde_def)
end // end of [f3undec_tyer]

fun
f3undeclst_tyer_map
(
  imparg: s2varlst, f3ds: f3undeclst
) : hifundeclst =
  if glist_is_cons (f3ds) then let
    val hfd = f3undec_tyer (imparg, glist_head<f3undec> (f3ds))
    val hfds = f3undeclst_tyer_map (imparg, glist_tail<f3undec> (f3ds))
  in
    glist_cons (hfd, hfds)
  end else glist_nil ((*void*))
// end of [f3undeclst_tyer_map]

fun
f3undeclst_tyer
(
  knd: funkind
, decarg: s2qualst, f3ds: f3undeclst
) : hifundeclst = let
  val isprf = funkind_is_proof (knd)
in
//
if
isprf
then glist_nil ((*void*)) // proofs are erased
else let
  val imparg = decarg2imparg (decarg)
in
  f3undeclst_tyer_map (imparg, f3ds)
end // end of [else]
//
end // end of [f3undeclst_tyer]

implement
d3ecl_tyer_fundecs
  (d3c0) = hdc0 where
{
//
val loc0 = d3c0.d3ecl_loc ()
//
val-~D3Cfundecs
  (knd, decarg, f3ds) = d3ecl_node_view (d3c0.d3ecl_node ())
//
val hfds = f3undeclst_tyer (knd, decarg, f3ds)
val hdc0 = hidecl_fundecs (loc0, knd, decarg, hfds)
//
val () = hifundeclst_set_hideclopt (hfds, gopt_some (hdc0))
//
} (* end of [d3ecl_tyer_fundecs] *)

(* ****** ****** *)

fun
v3aldec_tyer
(
  v3d: v3aldec
) : hivaldec = let
//
val loc = v3d.v3aldec_loc ()
val hip =
  p3at_tyer (v3d.v3aldec_pat ())
// end of [val]
val d3e_def = v3d.v3aldec_def ()
//
val isprf = d3exp_is_prf(d3e_def)
//
val () = (
if
isprf
then let
//
val () =
prerr_error4_loc (loc)
val () = (
  prerr_string (": [val] should be replaced with [prval].");
  prerr_newline ()
) (* end of [val] *)
//
in
  the_trans4errlst_add (trans4err_T4E_d3exp_tyer_isprf (d3e_def))
end // end of [if]
//
) (* end of [val] *)
//
val hde_def = d3exp_tyer (d3e_def)
//
in
  hivaldec_make (loc, hip, hde_def)
end // end of [v3aldec_tyer]

fun
v3aldeclst_tyer_map
  (v3ds: v3aldeclst): hivaldeclst =
  if glist_is_cons (v3ds) then let
    val hvd = v3aldec_tyer (glist_head<v3aldec> (v3ds))
    val hvds = v3aldeclst_tyer_map (glist_tail<v3aldec> (v3ds))
  in
    glist_cons (hvd, hvds)
  end else glist_nil ((*void*))
// end of [v3aldeclst_tyer_map]

fun
v3aldeclst_tyer
(
  knd: valkind, v3ds: v3aldeclst
) : hivaldeclst = let
  val isprf = valkind_is_proof (knd)
in
//
if isprf then
  glist_nil ((*void*)) // proofs are erased
else v3aldeclst_tyer_map (v3ds)
//
end // end of [v3aldeclst_tyer]

implement
d3ecl_tyer_valdecs (d3c0) = let
//
val loc0 = d3c0.d3ecl_loc ()
val-~D3Cvaldecs (knd, v3ds) = d3ecl_node_view (d3c0.d3ecl_node ())
val hvds = v3aldeclst_tyer (knd, v3ds)
//
in
  hidecl_valdecs (loc0, knd, hvds)
end // end of [d3ecl_tyer_valdecs]

implement
d3ecl_tyer_valdecs_rec (d3c0) = let
//
val loc0 = d3c0.d3ecl_loc ()
val-~D3Cvaldecs_rec (knd, v3ds) = d3ecl_node_view (d3c0.d3ecl_node ())
val hvds = v3aldeclst_tyer (knd, v3ds)
//
in
  hidecl_valdecs_rec (loc0, knd, hvds)
end // end of [d3ecl_tyer_valdecs_rec]

(* ****** ****** *)

fun
v3ardec_tyer
(
  v3d: v3ardec
) : hivardec = let
//
val loc = v3d.v3ardec_loc ()
val knd = v3d.v3ardec_knd ()
//
val d2v = v3d.v3ardec_dvar_var ()
val d2v = d2var_tyer (d2v)
//
val d2vw = v3d.v3ardec_dvar_view ()
//
val s2e = v3d.v3ardec_type ()
val hse = s2exp_tyer_shallow (loc, s2e)
//
val init = d3expopt_tyer (v3d.v3ardec_init ())
//
in
  hivardec_make (loc, knd, d2v, d2vw, hse, init)
end // end of [v3ardec_tyer]

fun
v3ardeclst_tyer_map
  (v3ds: v3ardeclst): hivardeclst =
  if glist_is_cons (v3ds) then let
    val hvd = v3ardec_tyer (glist_head<v3ardec> (v3ds))
    val hvds = v3ardeclst_tyer_map (glist_tail<v3ardec> (v3ds))
  in
    glist_cons (hvd, hvds)
  end else glist_nil ((*void*))
// end of [v3ardeclst_tyer_map]

implement
d3ecl_tyer_vardecs (d3c0) = let
//
val loc0 = d3c0.d3ecl_loc ()
val-~D3Cvardecs (v3ds) = d3ecl_node_view (d3c0.d3ecl_node ())
val hvds = v3ardeclst_tyer_map (v3ds)
//
in
  hidecl_vardecs (loc0, hvds)
end // end of [d3ecl_tyer_vardecs]

(* ****** ****** *)

fun
tmpcstimpmap_make_hideclist_aux
(
  map: &tmpcstimpmap, x: hidecl
) : void = let
in
//
case+ hidecl_node_view (x.hidecl_node ()) of
| ~HIDimpdec
    (knd, imp) => let
    val tmparg = imp.hiimpdec_tmparg ()
  in
    if glist_is_cons (tmparg) then tmpcstimpmap_insert (map, imp) else ()
  end // end of [HIDimpdec]
//
| ~HIDinclude
    (knd, xs_incl) => tmpcstimpmap_make_hideclist_auxlst (map, xs_incl)
  (* end of [HIDinclude] *)
//
| ~HIDlocal
    (xs_head, xs_body) =>
  (
    tmpcstimpmap_make_hideclist_auxlst (map, xs_head);
    tmpcstimpmap_make_hideclist_auxlst (map, xs_body)
  ) // end of [HIDlocal]
//
| v => hidecl_node_view_free (v)
//
end (* end of [aux] *)
//
and
tmpcstimpmap_make_hideclist_auxlst
(
  map: &tmpcstimpmap, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val () = tmpcstimpmap_make_hideclist_aux (map, x)
  in
    tmpcstimpmap_make_hideclist_auxlst (map, glist_tail<hidecl> (xs))
  end (* end of [list_cons] *)
else ()
//
end (* end of [auxlst] *)

implement
tmpcstimpmap_make_hideclist (xs) = let
//
var map
  : tmpcstimpmap = d2cstmap_nil<hiimpdeclst> ()
val () = tmpcstimpmap_make_hideclist_auxlst (map, xs)
//
in
  map
end // end of [tmpcstimpmap_make_hideclist]

(* ****** ****** *)

fun
tmpvardecmap_make_hideclist_aux
(
  map: &tmpvardecmap, x: hidecl
) : void = let
in
//
case+ hidecl_node_view (x.hidecl_node ()) of
| ~HIDfundecs
    (knd, s2qs, hfds) => let
  in
    if glist_is_cons (s2qs) then tmpvardecmap_inserts (map, hfds) else ()
  end // end of [HIDfundecs]
//
| ~HIDinclude
    (knd, xs_incl) => tmpvardecmap_make_hideclist_auxlst (map, xs_incl)
  (* end of [HIDinclude] *)
//
| ~HIDlocal
    (xs_head, xs_body) =>
  (
    tmpvardecmap_make_hideclist_auxlst (map, xs_head);
    tmpvardecmap_make_hideclist_auxlst (map, xs_body)
  ) // end of [HIDlocal]
//
| v => hidecl_node_view_free (v)
//
end (* end of [aux] *)
//
and
tmpvardecmap_make_hideclist_auxlst
(
  map: &tmpvardecmap, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val () = tmpvardecmap_make_hideclist_aux (map, x)
  in
    tmpvardecmap_make_hideclist_auxlst (map, glist_tail<hidecl> (xs))
  end (* end of [list_cons] *)
else ()
//
end (* end of [auxlst] *)

implement
tmpvardecmap_make_hideclist (xs) = let
//
var map
  : tmpvardecmap = d2varmap_nil<hifundec> ()
val () = tmpvardecmap_make_hideclist_auxlst (map, xs)
//
in
  map
end // end of [tmpvardecmap_make_hideclist]

(* ****** ****** *)

(* end of [pats_typerase_decl.dats] *)
