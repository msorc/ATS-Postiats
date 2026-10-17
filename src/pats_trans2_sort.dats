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
// Start Time: May, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans2_sort.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"
#include "./pats_trans1.hats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans2_sort.dats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"
typedef symbol = $SYM.symbol

(* ****** ****** *)

staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

staload "./pats_trans2.sats"
staload "./pats_trans2_env.sats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

extern
fun s1rt_tr_app (
  s1t0: s1rt, s1t_fun: s1rt, s1ts_arg: s1rtlst
) : s2rt // end of [s1rt_tr_app]

extern
fun s1rt_tr_qid
  (s1t0: s1rt, q: $SYN.s0rtq, id: symbol): s2rt
// end of [s1rt_tr_qid]

(* ****** ****** *)

fn s1rt_tr_app_arrow_err (loc0: location): s2rt = let
  val () =
  prerr_interror_loc (loc0)
  val () =
  prerrln! ": s1rt_tr_app: [->] is not an infix operator!"
in
  $ERR.abort_interr<s2rt>((*unreachable*))
end // end of [s1rt_tr_app_arrow_err]

(* ****** ****** *)

implement
s1rt_tr_app (
  s1t0, s1t_fun, s1ts_arg
) = let
  val loc0 = s1t0.s1rt_loc()
in
//
if s1rt_is_arrow (s1t_fun) then (
  case+ glist_view (s1ts_arg) of
  | ~GLcons (s1t1, s1ts_rest) => (
    case+ glist_view (s1ts_rest) of
    | ~GLcons (s1t2, s1ts_nil) => (
      if glist_is_nil (s1ts_nil) then let
      val s1ts1 = (case+ s1rt_node_view(s1t1.s1rt_node()) of
        | ~S1RTlist s1ts => s1ts
        | v => (s1rt_node_view_free (v); glist_sing(s1t1))
      ) : s1rtlst // end of [val]
      val s2ts1 = s1rtlst_tr (s1ts1) and s2t2 = s1rt_tr (s1t2)
    in
      s2rt_S2RTfun (s2ts1, s2t2)
    end else s1rt_tr_app_arrow_err (loc0)
    )
    | ~GLnil () => s1rt_tr_app_arrow_err (loc0)
    )
  | ~GLnil () => s1rt_tr_app_arrow_err (loc0)
  ) // end of [s1rt_is_arrow]
else s2rt_err () where {
    val () = prerr_error2_loc (s1t0.s1rt_loc())
    val () = filprerr_ifdebug ("s1rt_tr_app")
    val () = prerr ": sort application is not supported."
    val () = prerr_newline ()
    val () = the_trans2errlst_add (trans2err_T2E_s1rt_tr (s1t0))
  } // end of [_]
//
end // end of [s1rt_tr_app]

(* ****** ****** *)

implement
s1rt_tr_qid
  (s1t0, q, id) = let
  val loc0 = s1t0.s1rt_loc()
  val ans = the_s2rtenv_find_qua (q, id)
in
//
case+ ans of
| ~Some_vt (x) => (
  case+ s2rtext_view(x) of
  | ~S2TEsrt (s2t) => s2t
  | v => let
      val () = s2rtext_view_free (v)
      val () = prerr_error2_loc (loc0)
      val () = filprerr_ifdebug ("s1rt_tr_qid")
      val () = prerr ": the identifier ["
      val () = $SYM.prerr_symbol (id)
      val () = prerr "] is expected to refer to a sort (instead of a subset sort)." 
      val () = prerr_newline ()
      val () = the_trans2errlst_add (trans2err_T2E_s1rt_tr(s1t0))
    in
      s2rt_err ()
    end (* end of [_] *)
  ) // end of [Some_vt]
| ~None_vt () => let
    val () = prerr_error2_loc (loc0)
    val () = filprerr_ifdebug ("s1rt_tr_qid")
    val () = prerr ": the identifier ["
    val () = $SYM.prerr_symbol (id)
    val () = prerr "] does not refer to any recognized sort."
    val () = prerr_newline ()
    val () = the_trans2errlst_add (trans2err_T2E_s1rt_tr(s1t0))
  in
    s2rt_err ()
  end // end of [None_vt]
//
end // end of [s1rt_tr_qid]

(* ****** ****** *)

implement
s1rt_tr (s1t0) = let
  val loc0 = s1t0.s1rt_loc()
(*
  val () = (
    print loc0; print "s1rt_tr: S1RTapp: "; print_newline ()
  ) // end of [val]
*)
in
//
case+ s1rt_node_view(s1t0.s1rt_node()) of
| ~S1RTapp
  (
    s1t, s1ts
  ) => s1rt_tr_app (s1t0, s1t, s1ts)
| ~S1RTtype (impknd) => s2rt_impred (impknd)
| ~S1RTqid (q, id) => s1rt_tr_qid (s1t0, q, id)
| ~S1RTlist (s1ts) => s2rt_S2RTtup(s1rtlst_tr s1ts) 
| ~S1RTerr () => s2rt_err ()
//
end // end of [s1rt_tr]


(* ****** ****** *)

implement
s1rtlst_tr (xs) = glist_map_fun<s1rt,s2rt> (xs, s1rt_tr)

implement
s1rtopt_tr (opt) = (case+ gopt_view(opt) of
  | ~GOsome(x) => gopt_some(s1rt_tr x) | ~GOnone() => gopt_none()
) // end of [s1rtopt_tr]

(* ****** ****** *)

implement
a1srt_tr_srt (x) = s1rt_tr (x.a1srt_srt())
implement
a1msrt_tr_srt (x) = glist_map_fun<a1srt,s2rt> (x.a1msrt_arg(), a1srt_tr_srt)

(* ****** ****** *)

implement
a1srt_tr_symsrt (x) = let
  val sym = (case+ gopt_view(x.a1srt_sym()) of
    | ~GOnone() => $SYM.symbol_empty | ~GOsome(sym) => sym
  ) : symbol // end of [val]
  val s2t = s1rt_tr (x.a1srt_srt())
in
  syms2rt_new (sym, s2t)
end // end of [a1srt_tr_symsrt]
implement
a1msrt_tr_symsrt (x) = glist_map_fun<a1srt,syms2rt> (x.a1msrt_arg(), a1srt_tr_symsrt)

(* ****** ****** *)

(* end of [pats_trans2_sort.dats] *)
