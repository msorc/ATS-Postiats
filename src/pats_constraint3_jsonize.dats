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
// Start Time: November, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3_jsonize.dats, see PORTING.md, "Constraint solving (constraint3)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_jsonize.sats"
staload
_(*anon*) = "./pats_jsonize.dats"
//
(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_patcst2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_jsonize_synent2.sats"

(* ****** ****** *)

staload "./pats_trans3_env.sats"
staload "./pats_constraint3.sats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)
//
macdef
jsonize_loc (x) = jsonize_location (,(x))
//
(* ****** ****** *)

(*
//
// HX-2013-12-24:
// this does not seem to be really useful
//
// HX-2015-06-06:
// Change-of-mind!
//
*)
extern
fun
jsonize_c3nstrkind
  (knd: c3nstrkind): jsonval
//
implement
jsonize_c3nstrkind (knd) = let
in
//
case+ c3nstrkind_view (knd) of
//
| ~C3TKmain() =>
    jsonval_conarg0 ("C3TKmain")
//
| ~C3TKcase_exhaustiveness
    (knd, p2tcss) => let
    val knd = jsonize_caskind (knd)
    val p2tcss = jsonize_ignored<p2atcstlst> (p2tcss)
  in
    jsonval_conarg2
      ("C3TKcase_exhaustiveness", knd, p2tcss)
    // end of [jsonval_conarg2]
  end // end of [C3TKcase_exhaustiveness]
//
| ~C3TKtermet_isnat() =>
    jsonval_conarg0 ("C3TKtermet_isnat")
| ~C3TKtermet_isdec() =>
    jsonval_conarg0 ("C3TKtermet_isdec")
//
| ~C3TKsome_fin
    (d2v, s2e1, s2e2) => let
    val d2v = jsonize_d2var (d2v)
    val s2e1 = jsonize1_s2exp (s2e1)
    val s2e2 = jsonize1_s2exp (s2e2)
  in
    jsonval_conarg3 ("C3TKsome_fin", d2v, s2e1, s2e2)
  end // end of [C3TKsome_fin]
| ~C3TKsome_lvar
    (d2v, s2e1, s2e2) => let
    val d2v = jsonize_d2var (d2v)
    val s2e1 = jsonize1_s2exp (s2e1)
    val s2e2 = jsonize1_s2exp (s2e2)
  in
    jsonval_conarg3 ("C3TKsome_lvar", d2v, s2e1, s2e2)
  end // end of [C3TKsome_lvar]
| ~C3TKsome_vbox
    (d2v, s2e1, s2e2) => let
    val d2v = jsonize_d2var (d2v)
    val s2e1 = jsonize1_s2exp (s2e1)
    val s2e2 = jsonize1_s2exp (s2e2)
  in
    jsonval_conarg3 ("C3TKsome_vbox", d2v, s2e1, s2e2)
  end // end of [C3TKsome_vbox]
//
| ~C3TKlstate() =>
    jsonval_conarg0 ("C3TKlstate")
| ~C3TKlstate_var(d2v) =>
    jsonval_conarg1 ("C3TKlstate_var", jsonize_d2var (d2v))
  // end of [C3TKlstate_var]
//
| ~C3TKloop(knd) =>
    jsonval_conarg1 ("C3TKloop", jsonval_int (knd))
  // end of [C3TKloop]
//
| ~C3TKsolverify() => jsonval_conarg0 ("C3TKsolverify")
//
end // end of [jsonize_c3nstrkind]

(* ****** ****** *)

extern
fun jsonize_s3itm (x: s3itm): jsonval
extern
fun jsonize_s3itmlst (x: s3itmlst): jsonval
extern
fun jsonize_s3itmlstlst (x: s3itmlstlst): jsonval

(* ****** ****** *)

extern fun jsonize_h3ypo (x: h3ypo): jsonval
extern fun jsonize_c3nstropt (x: c3nstropt): jsonval

(* ****** ****** *)

implement
jsonize_s3itm
  (s3i) = let
in
//
case+ s3itm_view (s3i) of
//
| ~S3ITMsvar(s2v) =>
    jsonval_conarg1 ("S3ITMsvar", jsonize_s2var(s2v))
  // end of [S3ITMsvar]
//
| ~S3ITMhypo(h3p) =>
    jsonval_conarg1 ("S3ITMhypo", jsonize_h3ypo(h3p))
  // end of [S3ITMhypo]
//
| ~S3ITMsVar(s2V) =>
    jsonval_conarg1 ("S3ITMsVar", jsonize_s2Var(s2V))
  // end of [S3ITMsVar]
//
| ~S3ITMcnstr(c3t) =>
    jsonval_conarg1 ("S3ITMcnstr", jsonize_c3nstr(c3t))
  // end of [S3ITMcnstr]
//
| ~S3ITMcnstr_ref(c3tr) => let
    val loc = c3tr.c3nstroptref_loc ()
    val opt = c3tr.c3nstroptref_val ()
    val loc = jsonize_location (loc)
    val opt = jsonize_c3nstropt (opt)
  in
    jsonval_conarg2 ("S3ITMcnstr_ref", loc, opt)
  end // end of [S3ITMcnstr_ref]
//
| ~S3ITMdisj(s3iss) =>
    jsonval_conarg1 ("S3ITMdisj", jsonize_s3itmlstlst(s3iss))
  // end of [S3ITMdisj]
//
| ~S3ITMsolassert(s2e_prop) =>
    jsonval_conarg1 ("S3ITMsolassert", jsonize1_s2exp(s2e_prop))
  // end of [S3ITMsolassert]
//
end // end of [jsonize_s3itm]

(* ****** ****** *)
//
implement
jsonize_s3itmlst
  (s3is) = jsonize_list_fun<s3itm>(s3is, jsonize_s3itm)
implement
jsonize_s3itmlstlst
  (s3iss) = jsonize_list_fun<s3itmlst>(s3iss, jsonize_s3itmlst)
//
(* ****** ****** *)

implement
jsonize_h3ypo
  (h3p0) = let
//
fun auxmain
  (h3p0: h3ypo): jsonval = let
in
//
case+
h3ypo_node_view (h3p0.h3ypo_node ()) of
//
| ~H3YPOprop (s2e) => let
(*
    val () =
    println! ("jsonize_h3ypo: H3YPOprop: s2e = ", s2e)
*)
  in
    jsonval_conarg1 ("H3YPOprop", jsonize1_s2exp (s2e))
  end // end of [H3YPOprop]
| ~H3YPObind (s2v1, s2e2) => let
(*
    val () =
    println! ("jsonize_h3ypo: H3YPObind: s2v1 = ", s2v1)
    val () =
    println! ("jsonize_h3ypo: H3YPObind: s2e2 = ", s2e2)
*)
  in
    jsonval_conarg2
      ("H3YPObind", jsonize_s2var(s2v1), jsonize1_s2exp(s2e2))
  end // end of [H3YPObind]
| ~H3YPOeqeq (s2e1, s2e2) => let
(*
    val () =
    println! ("jsonize_h3ypo: H3YPObind: s2e1 = ", s2e1)
    val () =
    println! ("jsonize_h3ypo: H3YPObind: s2e2 = ", s2e2)
*)
  in
    jsonval_conarg2
      ("H3YPOeqeq", jsonize1_s2exp(s2e1), jsonize1_s2exp(s2e2))
  end // end of [H3YPOeqeq]
//
end // end of [auxmain]
//
val loc0 = h3p0.h3ypo_loc ()
val loc0 = jsonize_loc (loc0)
val h3p0 = auxmain (h3p0)
//
in
  jsonval_labval2 ("h3ypo_loc", loc0, "h3ypo_node", h3p0)
end // end of [jsonize_h3ypo]

(* ****** ****** *)

implement
jsonize_c3nstr
  (c3t0) = let
//
fun auxmain
  (c3t0: c3nstr): jsonval = let
in
//
case+
c3nstr_node_view (c3t0.c3nstr_node ()) of
//
| ~C3NSTRprop(s2e) =>
    jsonval_conarg1 ("C3NSTRprop", jsonize1_s2exp (s2e))
  // end of [C3NSTRprop]
//
| ~C3NSTRitmlst(s3is) =>
    jsonval_conarg1 ("C3NSTRitmlst", jsonize_s3itmlst (s3is))
  // end of [C3NSTRitmlst]
//
| ~C3NSTRsolverify(s2e_prop) =>
    jsonval_conarg1 ("C3NSTRsolverify", jsonize1_s2exp(s2e_prop))
  // end of [C3NSTRsolverify]
//
end // end of [auxmain]
//
val loc0 = c3t0.c3nstr_loc ()
val loc0 = jsonize_loc (loc0)
//
val ctk0 = jsonize_c3nstrkind(c3t0.c3nstr_kind ())
//
val c3t0 = auxmain (c3t0)
//
in
//
jsonval_labval3
(
  "c3nstr_loc", loc0, "c3nstr_kind", ctk0, "c3nstr_node", c3t0
) (* jsonval_labval3 *)
//
end // end of [jsonize_c3nstr]

(* ****** ****** *)

implement
jsonize_c3nstropt
  (opt) = jsonize_option_fun<c3nstr>(opt, jsonize_c3nstr)
// end of [jsonize_c3nstropt]

(* ****** ****** *)

local
//
typedef s2tds = s2rtdatset
//
fun
aux_s2rt
(
  s2t0: s2rt, res: s2tds
) : s2tds =
(
case+ s2rt_viewof (s2t0) of
| ~S2RTbas(s2tb) => aux_s2rtbas(s2tb, res)
| ~S2RTfun(s2ts, s2t) => let
    val res = aux_s2rtlst(s2ts, res) in aux_s2rt(s2t, res)
  end // end of [S2RTfun]
| ~S2RTtup(s2ts) => aux_s2rtlst(s2ts, res)
| ~S2RTVar _ => res
| ~S2RTerr _ => res
)
//
and
aux_s2rtlst
(
  s2ts: s2rtlst, res: s2tds
) : s2tds =
(
if glist_is_cons (s2ts) then let
  val res = aux_s2rt(glist_head<s2rt> (s2ts), res)
in
  aux_s2rtlst(glist_tail<s2rt> (s2ts), res)
end else res
)
//
and
aux_s2rtbas
(
  s2tb: s2rtbas, res: s2tds
) : s2tds =
(
case+ s2rtbas_view (s2tb) of
| ~S2RTBASpre _ => res
| ~S2RTBASimp _ => res
| ~S2RTBASdef(s2td) => s2rtdatset_add(res, s2td)
)
//
fun
aux_s2cst
(
  s2c: s2cst, res: s2tds
) : s2tds =
(
  aux_s2rt(s2cst_get_srt(s2c), res)
)
fun
aux_s2cstlst
(
  s2cs: s2cstlst, res: s2tds
) : s2tds =
(
if glist_is_cons (s2cs) then
  aux_s2cstlst(glist_tail<s2cst> (s2cs), aux_s2cst(glist_head<s2cst> (s2cs), res))
else res
)
//
fun
aux_s2var
(
  s2v: s2var, res: s2tds
) : s2tds =
(
  aux_s2rt(s2var_get_srt(s2v), res)
)
fun
aux_s2varlst
(
  s2vs: s2varlst, res: s2tds
) : s2tds =
(
if glist_is_cons (s2vs) then
  aux_s2varlst(glist_tail<s2var> (s2vs), aux_s2var(glist_head<s2var> (s2vs), res))
else res
)
//
in (* in-of-local *)

fun
c3nstr_get_s2rtdatlst
(
  s2cs: s2cstlst, s2vs: s2varlst
) : List0_vt(s2rtdat) = let
  val res = s2rtdatset_nil()
  val res = aux_s2cstlst(s2cs, res)
  val res = aux_s2varlst(s2vs, res)
in
  s2rtdatset_listize(res)
end // end of [c3nstr_get_s2rtdatlst]

end // end of [local]

(* ****** ****** *)

implement
c3nstr_export
  (out, c3t0) = let
//
val
@(
  s2cs, s2vs
) = c3nstr_mapgen_scst_svar (c3t0)
//
val s2cs = l2l (s2cstset_vt_listize_free (s2cs))
val s2vs = l2l (s2varset_vt_listize_free (s2vs))
//
val
jsv_s2cs =
jsonize_list_fun<s2cst>(s2cs, jsonize_s2cst_long)
val
jsv_s2vs =
jsonize_list_fun<s2var>(s2vs, jsonize_s2var_long)
//
val
s2tds =
c3nstr_get_s2rtdatlst (s2cs, s2vs)
//
val
jsv_s2tds =
jsonize_list_fun<s2rtdat>(l2l (s2tds), jsonize_s2rtdat_long)
//
val jsv_c3t0 = jsonize_c3nstr (c3t0)
//
val () =
  fprint_string (out, "{\n\"s2cstmap\":\n")
//
val ((*void*)) = fprint_jsonval (out, jsv_s2cs)
val ((*void*)) = fprint_newline (out)
//
val () =
  fprint_string (out, ",\n\"s2varmap\":\n")
//
val ((*void*)) = fprint_jsonval (out, jsv_s2vs)
val ((*void*)) = fprint_newline (out)
//
val () =
  fprint_string (out, ",\n\"s2rtdatmap\":\n")
//
val ((*void*)) = fprint_jsonval (out, jsv_s2tds)
val ((*void*)) = fprint_newline (out)
//
val () =
  fprint_string (out, ",\n\"c3nstrbody\":\n")
//
val ((*void*)) = fprint_jsonval (out, jsv_c3t0)
val ((*void*)) = fprint_string (out, "\n}")
val ((*void*)) = fprint_newline (out)
//
in
  // nothing
end // end of [c3nstr_export]

(* ****** ****** *)

(* end of [pats_constraint3_jsonize.dats] *)
