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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_syndef.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef location = $LOC.location
staload
SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol
//
macdef symbol_CAR = $SYM.symbol_CAR
macdef symbol_CDR = $SYM.symbol_CDR
macdef symbol_ISNIL = $SYM.symbol_ISNIL
macdef symbol_ISCONS = $SYM.symbol_ISCONS
macdef symbol_ISLIST = $SYM.symbol_ISLIST
//
macdef symbol_TUPZ = $SYM.symbol_TUPZ
overload = with $SYM.eq_symbol_symbol
//
staload SYN = "./pats_syntax.sats"
//
(* ****** ****** *)

staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"

(* ****** ****** *)

macdef list_sing (x) = glist_sing (,(x))
macdef list_pair (x, y) = glist_cons (,(x), glist_sing (,(y)))

(* ****** ****** *)

extern
fun syndef_search_all (id: symbol): Option_vt (fsyndef)

(* ****** ****** *)

local

(* ****** ****** *)

fun
fsyndef_CAR
(
  loc0: location, d1es: d1explst
) : d1exp = d1exp_macfun (loc0, symbol_CAR, d1es)
fun
fsyndef_CDR
(
  loc0: location, d1es: d1explst
) : d1exp = d1exp_macfun (loc0, symbol_CDR, d1es)

fun
fsyndef_ISNIL
(
  loc0: location, d1es: d1explst
) : d1exp = d1exp_macfun (loc0, symbol_ISNIL, d1es)
fun
fsyndef_ISCONS
(
  loc0: location, d1es: d1explst
) : d1exp = d1exp_macfun (loc0, symbol_ISCONS, d1es)
fun
fsyndef_ISLIST
(
  loc0: location, d1es: d1explst
) : d1exp = d1exp_macfun (loc0, symbol_ISLIST, d1es)

(* ****** ****** *)
//
val symbol_PRINT = $SYM.symbol_make_string "print"
val symbol_PRINTLN = $SYM.symbol_make_string "println"
val symbol_PRINT_NEWLINE = $SYM.symbol_make_string "print_newline"
//
val symbol_PRERR = $SYM.symbol_make_string "prerr"
val symbol_PRERRLN = $SYM.symbol_make_string "prerrln"
val symbol_PRERR_NEWLINE = $SYM.symbol_make_string "prerr_newline"
//
(* ****** ****** *)

val symbol_FPRINT = $SYM.symbol_make_string "fprint"
val symbol_FPRINTLN = $SYM.symbol_make_string "fprintln"
val symbol_FPRINT_NEWLINE = $SYM.symbol_make_string "fprint_newline"

(* ****** ****** *)

val symbol_GPRINT = $SYM.symbol_make_string "gprint"
val symbol_GPRINTLN = $SYM.symbol_make_string "gprintln"
val symbol_GPRINT_NEWLINE = $SYM.symbol_make_string "gprint_newline"

(* ****** ****** *)

fun aux1
(
  loc0: location, fid: d1exp, d1e: d1exp
) : d1exp = let
in
  d1exp_app_dyn (loc0, fid, loc0, ~1(*npf*), list_sing (d1e))
end // end of [aux1]

fun aux1lst
(
  loc0: location, fid: d1exp, d1es: d1explst
) : d1explst = let
//
in
//
case+ glist_view (d1es) of
| ~GLnil () => glist_nil ()
| ~GLcons (d1e, d1es1) => let
    val d1e = aux1 (loc0, fid, d1e) in glist_cons (d1e, aux1lst (loc0, fid, d1es1))
  end // end of [GLcons]
//
end // end of [aux1lst]

(* ****** ****** *)

fun aux2
(
  loc0: location, fid: d1exp, d1e: d1exp
) : d1exp = let
in
  case+ d1exp_node_view (d1e.d1exp_node ()) of
  | ~D1Elist
      (npf, d1es) => d1exp_seq (loc0, aux1lst (loc0, fid, d1es))
    // end of [D1Elist]
  | v (*rest-of-d1exp*) => (d1exp_node_view_free (v); aux1 (loc0, fid, d1e))
end // end of [aux2]

fun aux2lst
(
  loc0: location, fid: d1exp, d1es: d1explst
) : d1explst = let
in
//
case+ glist_view (d1es) of
| ~GLnil () => glist_nil ()
| ~GLcons (d1e, d1es1) => let
    val d1e = aux2 (loc0, fid, d1e) in glist_cons (d1e, aux2lst (loc0, fid, d1es1))
  end // end of [GLcons]
//
end // end of [aux2lst]

(* ****** ****** *)

fun aux3
(
  loc0: location, fid: d1exp, d1e1: d1exp, d1e2: d1exp
) : d1exp = let
in
  d1exp_app_dyn (loc0, fid, loc0, ~1(*npf*), list_pair (d1e1, d1e2))
end // end of [aux3]

fun aux3lst
(
  loc0: location, fid: d1exp, d1e1: d1exp, d1es2: d1explst
) : d1explst = let
in
//
case+ glist_view (d1es2) of
| ~GLnil () => glist_nil ()
| ~GLcons (d1e2, d1es21) => let
    val d1e2 = aux3 (loc0, fid, d1e1, d1e2) in glist_cons (d1e2, aux3lst (loc0, fid, d1e1, d1es21))
  end // end of [GLcons]
//
end // end of [aux3lst]

(* ****** ****** *)

fun
fsyndef_TUPZ
(
  loc0: location, d1es: d1explst
) : d1exp =
(
  d1exp_list (loc0, ~1(*npf*), d1es)
) (* end of [fsyndef_TUPZ] *)

(* ****** ****** *)

local

fun
auxpr
(
  loc0: location
, d1es: d1explst, sym: symbol
) : d1exp = let
(*
//
val () =
println! ("auxpr: d1es = ", d1es)
//
*)
val dq = $SYN.d0ynq_none (loc0)
val fid = d1exp_dqid (loc0, dq, sym)
val d1e_res = aux2lst (loc0, fid, d1es)
//
in
  d1exp_seq (loc0, d1e_res)
end (* end of [auxpr] *)

fun
auxprln
(
  loc0: location
, d1es: d1explst, sym: symbol, sym2: symbol
) : d1exp = let
(*
//
val () =
println! ("auxprln: d1es = ", d1es)
//
*)
val d1e1_res = auxpr (loc0, d1es, sym)
//
val dq = $SYN.d0ynq_none (loc0)
val fid2 = d1exp_dqid (loc0, dq, sym2)
val d1e2_res =
  d1exp_app_dyn (loc0, fid2, loc0, ~1(*npf*), glist_nil ())
//
in
  d1exp_seq (loc0, list_pair (d1e1_res, d1e2_res))
end (* end of [auxprln] *)

(* ****** ****** *)

fun
auxfpr
(
  loc0: location
, d1es: d1explst, sym: symbol
) : d1exp = let
(*
//
val () =
println! ("auxfpr: d1es = ", d1es)
//
*)
in
//
case+ glist_view (d1es) of
| ~GLcons
    (d1e1, d1es2) => let
    val dq = $SYN.d0ynq_none (loc0)
    val fid = d1exp_dqid (loc0, dq, sym)
    val d1es_res = aux3lst (loc0, fid, d1e1, d1es2)
  in
    d1exp_seq (loc0, d1es_res)
  end (* end of [list_cons] *)
| ~GLnil () => d1exp_errexp (loc0)
//
end (* end of [auxfpr] *)

fun
auxfprln
(
  loc0: location
, d1es: d1explst, sym: symbol, sym2: symbol
) : d1exp = let
(*
//
val out = stdout_ref
//
val () =
fprintln! (out, "auxfprln: d1es = ", d1es)
//
*)
in
//
case+ glist_view (d1es) of
| ~GLnil
    ((*void*)) => d1exp_errexp(loc0)
  // list_nil
| ~GLcons
    (d1e1, d1es2) => let
    val dq = $SYN.d0ynq_none(loc0)
    val fid = d1exp_dqid(loc0, dq, sym)
    val d1e1_res = 
      d1exp_seq
        (loc0, aux3lst(loc0, fid, d1e1, d1es2))
      // d1exp_seq
    // end of [val]
    val fid2 = d1exp_dqid (loc0, dq, sym2)
    val d1e2_res =
      d1exp_app_dyn
        (loc0, fid2, loc0, ~1(*npf*), list_sing (d1e1))
      // d1exp_app_dyn
    // end of [val]
(*
    val () = fprintln! (out, "auxfprln: d1e1_res = ", d1e1_res)
    val () = fprintln! (out, "auxfprln: d1e2_res = ", d1e2_res)
*)
  in
    d1exp_seq(loc0, list_pair(d1e1_res, d1e2_res))
  end (* end of [list_cons] *)
//
end (* end of [auxfprln] *)

in (* in of [local] *)

(* ****** ****** *)
//
fun
fsyndef_PRINT
(
  loc0: location, d1es: d1explst
) : d1exp = auxpr (loc0, d1es, symbol_PRINT)
//
fun
fsyndef_PRINTLN
(
  loc0: location, d1es: d1explst
) : d1exp =
(
  auxprln (loc0, d1es, symbol_PRINT, symbol_PRINT_NEWLINE)
) (* end of [fsyndef_PRINTLN] *)
//
(* ****** ****** *)

fun
fsyndef_PRERR
(
  loc0: location, d1es: d1explst
) : d1exp = auxpr (loc0, d1es, symbol_PRERR)
fun
fsyndef_PRERRLN
(
  loc0: location, d1es: d1explst
) : d1exp =
(
  auxprln (loc0, d1es, symbol_PRERR, symbol_PRERR_NEWLINE)
) (* end of [fsyndef_PRERRLN] *)

(* ****** ****** *)

fun
fsyndef_FPRINT
(
  loc0: location, d1es: d1explst
) : d1exp = let
//
val sym = symbol_FPRINT
//
in
//
case+ glist_view (d1es) of
| ~GLnil
  (
    // argless
  ) => d1exp_errexp (loc0)
//
| ~GLcons
  (
    d1e, d1es_rest
  ) => (
    if glist_is_nil (d1es_rest) then (
    case+
      d1exp_node_view (d1e.d1exp_node ())
    of
    | ~D1Elist
        (npf, d1es) =>
      (
        auxfpr (loc0, d1es, sym)
      ) // end of [D1Elist]
    | v (*non-D1Elist*) =>
      (
        d1exp_node_view_free (v);
        auxfpr(loc0, list_sing(d1e), sym)
      ) (* end of [_] *)
    ) else auxfpr(loc0, d1es, sym)
  ) (* end of [list_cons] *)
//
//
end (* end of [fsyndef_FPRINT] *)

fun
fsyndef_FPRINTLN
(
  loc0: location, d1es: d1explst
) : d1exp = let
//
val sym = symbol_FPRINT
val sym2 = symbol_FPRINT_NEWLINE
//
(*
val
out = stdout_ref
//
val () =
fprintln!(out, "fsyndef_FPRINTLN: d1es = ", d1es)
*)
//
in
//
case+ glist_view (d1es) of
| ~GLnil
  (
    // argless
  ) => d1exp_errexp(loc0)
//
| ~GLcons
  (
    d1e, d1es_rest
  ) => (
    if glist_is_nil (d1es_rest) then (
    case+
      d1exp_node_view (d1e.d1exp_node ())
    of
    | ~D1Elist
        (npf, d1es) =>
      (
        auxfprln(loc0, d1es, sym, sym2)
      ) // end of [D1Elist]
    | v (*non-D1Elist*) =>
      (
        d1exp_node_view_free (v);
        auxfprln(loc0, list_sing(d1e), sym, sym2)
      ) (* end of [_] *)
    ) else auxfprln(loc0, d1es, sym, sym2)
  ) (* end of [list_cons] *)
//
//
end (* end of [fsyndef_FPRINTLN] *)

(* ****** ****** *)
//
fun
fsyndef_GPRINT
(
  loc0: location, d1es: d1explst
) : d1exp =
(
  auxpr(loc0, d1es, symbol_GPRINT)
)
//
fun
fsyndef_GPRINTLN
(
  loc0: location, d1es: d1explst
) : d1exp =
(
  auxprln(loc0, d1es, symbol_GPRINT, symbol_GPRINT_NEWLINE)
) (* end of [fsyndef_GPRINTLN] *)
//
(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

in (* in-of-local *)

(* ****** ****** *)

implement
syndef_search_all
  (id) = let
//
(*
val () =
println! ("syndef_search_all")
*)
//
in
//
if id = symbol_CAR then Some_vt{fsyndef}(fsyndef_CAR)
else if id = symbol_CDR then Some_vt{fsyndef}(fsyndef_CDR)
//
else if id = symbol_ISNIL then Some_vt{fsyndef}(fsyndef_ISNIL)
else if id = symbol_ISCONS then Some_vt{fsyndef}(fsyndef_ISCONS)
else if id = symbol_ISLIST then Some_vt{fsyndef}(fsyndef_ISLIST)
//
else if id = symbol_TUPZ then Some_vt{fsyndef}(fsyndef_TUPZ)
//
else if id = symbol_PRINT then Some_vt{fsyndef}(fsyndef_PRINT)
else if id = symbol_PRINTLN then Some_vt{fsyndef}(fsyndef_PRINTLN)
else if id = symbol_PRERR then Some_vt{fsyndef}(fsyndef_PRERR)
else if id = symbol_PRERRLN then Some_vt{fsyndef}(fsyndef_PRERRLN)
//
else if id = symbol_FPRINT then Some_vt{fsyndef}(fsyndef_FPRINT)
else if id = symbol_FPRINTLN then Some_vt{fsyndef}(fsyndef_FPRINTLN)
//
else if id = symbol_GPRINT then Some_vt{fsyndef}(fsyndef_GPRINT)
else if id = symbol_GPRINTLN then Some_vt{fsyndef}(fsyndef_GPRINTLN)
//
else None_vt{fsyndef}((*void*)) (* unsupported idext *)
//
end // end of [syndef_search_all]

end // end of [local]

(* ****** ****** *)

implement
d1exp_syndef_resolve
  (loc0, d1e) = let
//
(*
val () =
println! ("d1exp_syndef_resolve")
*)
//
in
//
case+
d1exp_node_view (d1e.d1exp_node ())
of // case+
//
| ~D1Eidextapp
    (id, d1es) => let
    val opt = syndef_search_all (id)
  in
    case+ opt of
    | ~None_vt() => d1e
    | ~Some_vt(f) => let
        val d1es = glist_reverse (d1es) in f (loc0, d1es)
      end // end of [Some_vt]
  end // end of [D1Eidextapp]
//
| v (* non-D1Eidextapp *) => (d1exp_node_view_free (v); d1e)
//
end (* end of [d1exp_syndef_resolve] *)

(* ****** ****** *)

(* end of [pats_trans1_syndef.dats] *)
