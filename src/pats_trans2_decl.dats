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
// HX-2026-10: no GC (ATS2 port of src/pats_trans2_decl.dats, see PORTING.md, "Level 2 translation (trans2)")
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
#include "./pats_trans2.hats"
#include "./pats_staexp2.hats"

(* ****** ****** *)

macdef castvwtp1 = $UN.castvwtp1

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"
staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"
staload GLOB = "./pats_global.sats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_trans2_decl"
//
(* ****** ****** *)
//
staload
FIL = "./pats_filename.sats"
//
overload
print with $FIL.print_filename_full
//
(* ****** ****** *)

staload
SYM = "./pats_symbol.sats"
//
macdef EQEQ = $SYM.symbol_EQEQ
//
overload = with $SYM.eq_symbol_symbol
overload != with $SYM.neq_symbol_symbol
//
overload print with $SYM.print_symbol
//
(* ****** ****** *)

staload
SYN = "./pats_syntax.sats"
typedef i0de = $SYN.i0de
typedef i0delst = $SYN.i0delst
typedef s0taq = $SYN.s0taq
typedef d0ynq = $SYN.d0ynq
typedef sqi0de = $SYN.sqi0de
typedef dqi0de = $SYN.dqi0de
typedef impqi0de = $SYN.impqi0de
typedef dcstextdef = $SYN.dcstextdef

(* ****** ****** *)

overload print with $SYN.print_i0de
overload print with $SYN.print_dqi0de

(* ****** ****** *)

macdef
prerr_dqid (dq, id) =
  ($SYN.prerr_d0ynq ,(dq); $SYM.prerr_symbol ,(id))
// end of [prerr_dqid]

(* ****** ****** *)

staload NS = "./pats_namespace.sats"

(* ****** ****** *)

staload "./pats_lexing.sats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"
staload "./pats_staexp2.sats"
staload "./pats_stacst2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_sprint.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_trans2.sats"
staload "./pats_trans2_env.sats"

(* ****** ****** *)


(* ****** ****** *)

fn
s2rt_unfun (s2t: s2rt): @(s2rtlst, s2rt) =
(
  case+ s2rt_viewof (s2t) of
  | ~S2RTfun (s2ts, s2t) => @(s2ts, s2t)
  | v => (s2rt_view_free (v); $ERR.abort_interr<@(s2rtlst, s2rt)> ((*MatchError*)))
) // end of [s2rt_unfun]

fn syms2rt_get_srt (x: syms2rt): s2rt = x.syms2rt_srt()

fun
symintr_tr
  (ids: i0delst): void = let
//
fun aux
  (ids: i0delst): void = let
in
  case+ glist_view(ids) of
  | ~GLcons(id, ids) => let
      val sym = id.i0de_sym()
      val () =
        the_d2expenv_add (sym, d2itm_D2ITMsymdef(sym, glist_nil()))
      // end of [val]
    in
      aux (ids)
    end // end of [list_cons]
  | ~GLnil() => () // end of [list_nil]
end // end of [aux]
//
in
  aux ids
end // end of [symintr_tr]

(* ****** ****** *)

fun
symelim_tr
  (ids: i0delst): void = let
//
fun
fproc
  (id: i0de): void = let
  val sym = id.i0de_sym()
  val ans = the_d2expenv_find (sym)
in
//
  case+ ans of
  | ~Some_vt (d2i) =>
    (
      case+ d2itm_view(d2i) of
      | ~D2ITMsymdef _ =>
          the_d2expenv_add (sym, d2itm_D2ITMsymdef(sym, glist_nil()))
        // end of [D2ITMsymdef]
      | v => (d2itm_view_free (v); ()) // HX: should a warning be reported?
    ) // end of [Some_vt]
  | ~None_vt ((*void*)) => ()
//
end // end of [fproc]
//
in
  glist_app_fun (ids, fproc)
end // end of [symelim_tr]

(* ****** ****** *)
//
extern
fun overload_tr
(
  d1c0: d1ecl, id: i0de, dqid: dqi0de, pval: int
) : d2itmopt // end of [overload_tr]
//
extern
fun overload_tr_def
  (loc0: location, id: i0de, pval: int, def: d2itm): void
// end of [overload_tr_def]
//
extern fun overload_tr_d2eclist (d2cs: d2eclist): void
//
(* ****** ****** *)

implement
overload_tr
(
  d1c0, id, dqid, pval
) = let
//
val loc0 = d1c0.d1ecl_loc()
//
(*
val () =
{
  val () = println! ("overload_tr: id = ", id)
  val () = println! ("overload_tr: dqid = ", dqid)
} (* end of [val] *)
*)
//
fun
auxerr (
  d1c0: d1ecl, dqid: $SYN.dqi0de
) : void = let
  val loc = dqid.dqi0de_loc()
  val () = prerr_error2_loc (loc)
  val () = filprerr_ifdebug "overload_tr"
  val () = prerr ": the dynamic identifier ["
  val () = $SYN.prerr_dqi0de (dqid)
  val () = prerr "] is unrecognized."
  val () = prerr_newline ()
in
  the_trans2errlst_add (trans2err_T2E_d1ecl_tr_overload(d1c0))
end (* end of [auxerr] *)
//
val qua = dqid.dqi0de_qua()
and sym = dqid.dqi0de_sym()
val ans = the_d2expenv_find_qua (qua, sym)
//
val ans = gopt_make_option_vt (ans)
val () = (
  case+ gopt_view(ans) of
  | ~GOsome(d2i) =>
      overload_tr_def (loc0, id, pval, d2i)
  | ~GOnone() => auxerr (d1c0, dqid)
) (* end of [val] *)
//
in
  ans
end // end of [overload_tr]

implement
overload_tr_def
  (loc0, id, pval, def) = let
//
  var err: int = 0
//
fun
auxerr1
(
  loc0: location, id: i0de, err: &int
) : void = let
  val () = err := err + 1
  val () = prerr_error2_loc (id.i0de_loc())
  val () = filprerr_ifdebug ("overload_tr_def")
  val () = prerr ": the overloaded identifier ["
  val () = $SYN.prerr_i0de (id)
  val () = prerr "] should refer to a symbol but it does not."
  val () = prerr_newline ()
in
  the_trans2errlst_add (trans2err_T2E_d1ecl_tr_overload_def(loc0))
end // end of [auxerr1]
//
fun
auxerr2
(
  loc0: location, id: i0de, err: &int
) : void = let
  val () = err := err + 1
  val () = prerr_error2_loc (id.i0de_loc())
  val () = filprerr_ifdebug "overload_tr_def"
  val () = prerr ": the overloaded identifier ["
  val () = $SYN.prerr_i0de (id)
  val () = prerr "] is unrecognized."
  val () = prerr_newline ()
in
//
the_trans2errlst_add(trans2err_T2E_d1ecl_tr_overload_def(loc0))
//
end // end of [auxerr2]
//
val sym = id.i0de_sym()
val ans = ans where {
  val ans = the_d2expenv_current_find(sym)
  val ans = (
    case+ ans of
    | ~Some_vt (d2i) => Some_vt (d2i)
    | ~None_vt () => the_d2expenv_pervasive_find(sym)
  ) : d2itmopt_vt
} // end of [where] // end of [val]
val d2pis = (
  case+ ans of
  | ~Some_vt
      (d2i) => (
      case+ d2itm_view(d2i) of
      | ~D2ITMsymdef
          (sym, d2pis) => d2pis
        // D2ITMsymdef
      | v => (d2itm_view_free (v); let
          val () = auxerr1(loc0, id, err) in glist_nil()
        end) // end of [_]
    ) // end of [Some_vt]
  | ~None_vt() =>
      d2pis where
    {
      val d2pis = glist_nil()
      val () =
        the_d2expenv_add(sym, d2itm_D2ITMsymdef(sym, d2pis))
      // end of [val]
    } // end of [None_vt]
) : d2pitmlst // end of [val]
in
//
if err = 0 then let
  val d2pi = d2pitm_D2PITM(pval, def)
  val d2pis_new = glist_cons(d2pi, d2pis)
in
  the_d2expenv_add (sym, d2itm_D2ITMsymdef(sym, d2pis_new))
end // end of [if]
//
end (* end of [overload_tr_def] *)

(* ****** ****** *)

fun
d1atsrtdec_tr
(
  res: s2rt, d1c: d1atsrtdec
) : s2cstlst = let
//
fun aux .<>.
(
  i: int
, res: s2rt, d1c: d1atsrtcon
) : s2cst = s2c where
{
//
val id = d1c.d1atsrtcon_sym()
val loc = d1c.d1atsrtcon_loc()
val arg = s1rtlst_tr (d1c.d1atsrtcon_arg())
val s2t = s2rt_fun (arg, res)
//
val s2c =
s2cst_make (
  id // sym
, loc // location
, $FIL.filename_dummy
, s2t // srt
, gopt_none() // isabs
, true // iscon
, false // isrec
, gopt_none() // isasp
, gopt_none() // islst
, glist_nil() // argvarlst
, gopt_none() // def
) (* end of [s2cst_make] *)
//
val () = s2cst_set_dstag (s2c, i)
//
val () = the_s2expenv_add_scst (s2c)
//
} (* end of [aux] *)
//
fun auxlst
(
  i: int, res: s2rt, d1cs: d1atsrtconlst
) : s2cstlst = let
in
//
case+ glist_view(d1cs) of
| ~GLcons(d1c, d1cs) => (
    glist_cons(aux (i, res, d1c), auxlst (i+1, res, d1cs))
  ) // end of [cons]
| ~GLnil() => glist_nil()
//
end // end of [auxlst]
//
in
  auxlst (0, res, d1c.d1atsrtdec_con())
end // end of [d1atsrtdec_tr]

fun
d1atsrtdeclst_tr
  (d1cs: d1atsrtdeclst) = let
//
typedef T = @(d1atsrtdec, s2rtdat, s2rt)
//
fun loop1 (
  xs0: List0_vt (T)
) : void = let
in
  case+ xs0 of
  | ~list_vt_cons (x, xs) => let
      val s2cs = d1atsrtdec_tr (x.2, x.0)
      val () = s2rtdat_set_sconlst (x.1, s2cs)
    in
      loop1 (xs)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
end // end of [loop1]
//
fun loop2 (
  d1cs: d1atsrtdeclst, res: List0_vt (T)
) : void = let
in
//
case+ glist_view(d1cs) of
| ~GLcons(d1c, d1cs) => let
//
    val loc = d1c.d1atsrtdec_loc()
    val sym = d1c.d1atsrtdec_sym()
    val s2td = s2rtdat_make (sym)
    val s2t = s2rt_S2RTbas(s2rtbas_S2RTBASdef s2td)
//
    val
    s2t_eqeq =
    s2rt_fun (glist_pair<s2rt> (s2t, s2t), s2rt_bool)
//
    val
    s2c_eqeq =
    s2cst_make (
      EQEQ // sym
    , loc // location
    , $FIL.filename_dummy
    , s2t_eqeq // srt
    , gopt_none() // isabs
    , false // iscon
    , false // isrec
    , gopt_none() // isasp
    , gopt_none() // islst
    , glist_nil() // argvarlst
    , gopt_none() // def
    ) (* end of [s2cst_make] *)
//
    val () = the_s2expenv_add_scst (s2c_eqeq)
//
    val () = the_s2rtenv_add (sym, s2rtext_S2TEsrt s2t)
  in
    loop2 (d1cs, list_vt_cons ( @(d1c, s2td, s2t), res ))
  end // end of [list_cons]
//
| ~GLnil() => loop1 (res)
//
end // end of [loop2]
//
in
  loop2 (d1cs, list_vt_nil ())
end // end of [d1atsrtdeclst_tr]

(* ****** ****** *)

fun
s1rtdef_tr
  (d: s1rtdef): void = let
  val id = d.s1rtdef_sym()
  val s2te = s1rtext_tr (d.s1rtdef_def())
in
  the_s2rtenv_add (id, s2te)
end // end of [s1rtdef_tr]

fun
s1rtdeflst_tr
  (ds: s1rtdeflst): void = glist_app_fun (ds, s1rtdef_tr)
// end of [s1rtdeflst_tr]

(* ****** ****** *)

fun
s1tacst_tr
(
  d0: s1tacst
) : s2cst = let
//
fun
aux
(
  xs: a1msrtlst, res: s2rt
) : s2rt =
  case+ glist_view(xs) of
  | ~GLcons(x, xs) =>
      s2rt_fun (a1msrt_tr_srt (x), aux (xs, res))
    // end of [list_cons]
  | ~GLnil() => res
// end of [aux]
//
val id0 = d0.s1tacst_sym()
val loc = d0.s1tacst_loc()
val fil = d0.s1tacst_fil()
//
val
s2t_res =
  s1rt_tr(d0.s1tacst_res())
//
val
s2cs2t = aux(d0.s1tacst_arg(), s2t_res)
//
val
s2c0 =
s2cst_make
(
  id0 // sym
, loc // location
, fil // filename
, s2cs2t // srt
, gopt_none() // isabs
, false  // iscon
, false  // isrec
, gopt_none()  // isasp
, gopt_none() // islst
, glist_nil() // argvarlst
, gopt_none((*void*)) // s2cstdef
) (* end of [s2cst_make] *)
//
val () =
s2cst_set_extdef
  (s2c0, d0.s1tacst_extdef())
//
in
  the_s2expenv_add_scst(s2c0); s2c0
end // end of [s1tacst_tr]

fun
s1tacstlst_tr
  (ds: s1tacstlst): s2cstlst =
(
  glist_map_fun<s1tacst,s2cst> (ds, s1tacst_tr)
) (* end of [s1tacstlst_tr] *)

(* ****** ****** *)

fun
s1tacon_tr
(
  s2t_res: s2rt, d0: s1tacon
) : s2cst = let
//
val id0 = d0.s1tacon_sym()
val loc = d0.s1tacon_loc()
val fil = d0.s1tacon_fil()
//
val
argvars =
(
  glist_map_fun<a1msrt,syms2rtlst>
  (
    d0.s1tacon_arg(), a1msrt_tr_symsrt
  ) (* list_map_fun *)
) (* end of [val] *)
//
val
s2t_fun = let
//
  fun aux (
    s2t_res: s2rt, xss: syms2rtlstlst
  ) : s2rt =
  (
    case+ glist_view(xss) of
    | ~GLnil() => s2t_res
      // list_nil
    | ~GLcons(xs0, xss) => let
//
        val
        s2ts_arg =
        (
          glist_map_fun<syms2rt,s2rt>
            (xs0, syms2rt_get_srt)
        ) (* s2ts_arg *)
//
      in
        s2rt_fun(s2ts_arg, aux(s2t_res, xss))
      end (* end of [list_cons] *)
  ) (* end of [aux] *)
in
  aux(s2t_res, argvars)
end : s2rt // end of [val]
//
(*
val () = (
//
print "s1tacon_tr: sym = "; $SYM.print_symbol(id0); print_newline();
print "s1tacon_tr: s2t_fun = "; print_s2rt(s2t_fun); print_newline();
//
) (* end of [val] *)
*)
//
val () = the_s2expenv_push_nil ()
//
val s2vss = let
  fun f1(x: syms2rt): s2var =
    if x.syms2rt_sym() = $SYM.symbol_empty
      then s2var_make_srt(x.syms2rt_srt())
      else s2var_make_id_srt(x.syms2rt_sym(), x.syms2rt_srt())
    // end of [if]
  fun f2
  (
    xs: syms2rtlst
  ) : s2varlst = let
    val s2vs =
      glist_map_fun<syms2rt,s2var> (xs, f1)
    // end of [val]
    val ((*void*)) =
      the_s2expenv_add_svarlst(s2vs)
    // end of [val]
  in
    s2vs
  end // end of [f2]
  val s2vss = glist_map_fun<syms2rtlst,s2varlst> (argvars, f2)
//
in
  s2vss
end : s2varlstlst // end of [val]
//
val def = let
//
  fun aux
  (
    s2t_fun: s2rt, s2vss: s2varlstlst, s2e: s2exp
  ) : s2exp =
  (
    case+ glist_view(s2vss) of
    | ~GLcons(s2vs, s2vss) => let
        val s2t1_fun = (s2rt_unfun (s2t_fun)).1
        val s2e = aux(s2t1_fun, s2vss, s2e)
        val s2e_lam = s2exp_lam_srt(s2t_fun, s2vs, s2e)
      in
        s2e_lam
      end // end of [list_cons]
    | ~GLnil() => s2e
  ) (* end of [aux] *)
//
  val def = d0.s1tacon_def ((* : s1expopt *))
//
in
  case+ gopt_view(def) of
  | ~GOsome(s1e) => let
      val s2e =
        s1exp_trdn(s1e, s2t_res)
      // end of [val]
      val s2e_def = aux(s2t_fun, s2vss, s2e)
    in
      gopt_some(s2e_def)
    end // end of [Some]
  | ~GOnone() => gopt_none()
end : s2expopt // end of [val]
//
val () = the_s2expenv_pop_free ((*none*))
//
val
s2c0 =
s2cst_make
(
  id0 // sym
, loc // location
, fil // filename
, s2t_fun // srt
, gopt_some(def) // isabs
, true // iscon
, false // isrec
, gopt_none() // isasp
, gopt_none() // islst
, argvars // argvarlst
, gopt_none() // definition
) (* s2cst_make *)
//
in
  the_s2expenv_add_scst(s2c0); s2c0
end // end of [s1tacon_tr]

fun
s1taconlst_tr
(
  knd: int, ds: s1taconlst
) : s2cstlst = let
//
fun
auxlst
(
  s2t: s2rt, ds: s1taconlst
) : s2cstlst = (
//
case+ glist_view(ds) of
| ~GLcons(d, ds) => let
    val s2c =
      s1tacon_tr(s2t, d)
    // end of [val]
  in
    glist_cons(s2c, auxlst(s2t, ds))
    // list_cons
  end // end of [list_cons]
| ~GLnil() => glist_nil()
//
) (* end of [aux] *)
//
in
  auxlst(s2rt_impred(knd), ds)
end // end of [s1taconlst_tr]

(* ****** ****** *)

(* ****** ****** *)

fun
t1kindef_tr
(
  d: t1kindef
) : void = let
//
val sym = d.t1kindef_sym()
val loc_id = d.t1kindef_loc_id()
//
val def = s1exp_trup (d.t1kindef_def())
//
val
s2c =
s2cst_make (
  sym // name
, loc_id // location
, $FIL.filename_dummy
, s2rt_tkind // tkind constant
, gopt_none() // isabs
, false // iscon
, false // isrec
, gopt_none() // isasp
, gopt_none() // islst
, glist_nil() // argvar
, gopt_some(def) // definition
) (* end of [s2cst_make] *)
//
// HX-2026-10: the alias for the error messages (pats_staexp2_sprint)
val () = if the_d2varlev_get () = 0 then sprint_alias_add_tkind (s2c)
//
in
  the_s2expenv_add_scst (s2c)
end // end of [t1kindef_tr]

(* ****** ****** *)

local

fun
s1expdef_tr_arg
(
  xs: s1marglst
) : s2varlstlst = let
//
fun
fproc (
  x: s1marg
) : s2varlst = s2vs where {
  val s2vs = s1arglst_trup (x.s1marg_arg())
  val () = the_s2expenv_add_svarlst (s2vs)
} // end of [fproc]
//
in
  glist_map_fun<s1marg,s2varlst> (xs, fproc)
end // end of [s1expdef_tr_arg]

fun
s1expdef_tr_def
(
  xs: s1marglst, res: s2rtopt, def: s1exp
) : s2exp = let
//
val () = the_s2expenv_push_nil ()
//
val s2vss = s1expdef_tr_arg (xs)
//
val s2e_body =
(
case+ gopt_view(res) of
| ~GOsome(s2t) => s1exp_trdn (def, s2t)
| ~GOnone() => s1exp_trup (def)
) : s2exp // end of [val]
//
val () = the_s2expenv_pop_free ((*none*))
//
val s2e_def = s2exp_lamlst (s2vss, s2e_body)
//
in
  s2e_def
end // end of [s1expdef_tr_def]

in (* in-of-local *)

fun
s1expdef_tr
(
  res: s2rtopt, d: s1expdef
) : s2cst = let
//
fun
auxerr
  (d: s1expdef): void = let
//
val (
) = prerr_error2_loc (d.s1expdef_loc())
val () = filprerr_ifdebug ("s1expdef_tr")
val (
) = prerr "\
: the sort for the static definition does not
match the one assigned to the static constant [\
" // end of [val]
val () = $SYM.prerr_symbol (d.s1expdef_sym())
val () = prerr "]."
val () = prerr_newline ()
//
in
  the_trans2errlst_add (trans2err_T2E_s1expdef_tr(d))
end // end of [auxerr]
//
val sym = d.s1expdef_sym()
and loc_id = d.s1expdef_loc_id()
and arg = d.s1expdef_arg()
and def = d.s1expdef_def()
val res1 = s1rtopt_tr (d.s1expdef_res())
//
val res2 =
(
case+ gopt_view(res) of
| ~GOsome(s2t) => (
  case+ gopt_view(res1) of
  | ~GOsome(s2t1) => let
      val test = s2rt_ltmat1 (s2t1, s2t)
    in
      if test then res1 else (auxerr (d); res)
    end // end of [Some]
  | ~GOnone() => res
  ) // end of [Some]
| ~GOnone() => res1
) : s2rtopt // end of [val]
//
val def2 = s1expdef_tr_def (arg, res2, def)
//
val s2c =
s2cst_make
(
  sym // name
, loc_id // location
, $FIL.filename_dummy
, def2.s2exp_srt() // srt
, gopt_none() // isabs
, false // iscon
, false // isrec
, gopt_none() // isasp
, gopt_none() // islst
, glist_nil() // argvar
, gopt_some(def2) // definition
) (* end of [s2cst_make] *)
//
// HX-2026-10: the alias for the error messages (pats_staexp2_sprint);
// the local ones of the functions and implementations are not used
val () = if the_d2varlev_get () = 0 then sprint_alias_add_s2cst (s2c)
//
in
  s2c
end // end of [s1expdef_tr]

fun
s1expdeflst_tr
  (knd: int, ds: s1expdeflst): void = let
//
val res =
(
  if knd >= 0 then gopt_some(s2rt_impred(knd)) else gopt_none()
) : s2rtopt
//
val s2cs = let
  fun aux (
    ds: s1expdeflst
  ) : List0_vt (s2cst) =
  (
    case+ glist_view(ds) of
    | ~GLcons(d, ds) => let
        val s2c = s1expdef_tr (res, d) in list_vt_cons (s2c, aux ds)
      end // end of [list_cons]
    | ~GLnil() => list_vt_nil ()
  ) // end of [aux]
in
  aux (ds)
end // end of [val]
//
val () = let
//
  fun loop
  (
    s2cs: List0_vt (s2cst)
  ) : void =
  (
    case+ s2cs of
    | ~list_vt_nil
        ((*void*)) => ()
    | ~list_vt_cons
        (s2c, s2cs) => let
        val () = the_s2expenv_add_scst(s2c) in loop(s2cs)
      end // end of [list_vt_cons]
  ) (* end of [loop] *)
//
in
  loop(s2cs)
end // end of [val]
//
in
  // nothing
end // end of [s1expdeflst_tr]

end // end of [local]

(* ****** ****** *)

local

fun
s1aspdec_tr_arg
(
d0: s1aspdec,
xs: s1marglst, s2t_fun: &s2rt
) : List0_vt (s2varlst) = let
//
fun
auxerr
(
d0: s1aspdec, x: s1marg
) : void = let
  val () = prerr_error2_loc(x.s1marg_loc())
  val () = filprerr_ifdebug("s1aspdec_tr_arg")
  val () = prerr ": too many arguments for the assumed static constant."
  val () = prerr_newline((*void*))
in
  the_trans2errlst_add(trans2err_T2E_s1aspdec_tr_arg(d0, x))
end // end of [auxerr]
//
in (* in-of-let *)
//
case+ glist_view(xs) of
| ~GLnil() => list_vt_nil()
  // end of [list_nil]
| ~GLcons(x, xs) => (
  case+ s2rt_viewof(s2t_fun) of
  | ~S2RTfun
     (s2ts_arg, s2t_res) => let
      val () = s2t_fun := s2t_res
      val s2vs = s1marg_trdn (x, s2ts_arg)
      val () = the_s2expenv_add_svarlst (s2vs)
    in
      list_vt_cons(s2vs, s1aspdec_tr_arg(d0, xs, s2t_fun))
    end // end of [S2RTfun]
  | v => (s2rt_view_free (v); let
      val () = auxerr (d0, x) in list_vt_nil((*void*))
    end (* end of [_] *))
  ) (* end of [list_cons] *)
//
end // end of [s1aspdec_tr_arg]

fun
s1aspdec_tr_res
(
d0: s1aspdec, s2t_res: s2rt
) : s2rt = let
//
fun
auxerr
(
d0: s1aspdec, s2t1: s2rt, s2t2: s2rt
) : void =
{
//
  val () =
  prerr_error2_loc(d0.s1aspdec_loc())
  val () =
  filprerr_ifdebug("s1aspdec_tr_res")
//
  val () =
  if $GLOB.the_LEGACYERRORS_get () > 0 then {
    val () =
    prerr(": the static assumption is given the sort [")
    val () = prerr_s2rt(s2t1)
    val () = prerr "] but it is expected to be of the sort ["
    val () = prerr_s2rt(s2t2)
    val () = prerr "]."
  } else { // HX-2026-10: the surface syntax (pats_staexp2_sprint)
    val () = sprint_reset ()
    val () =
    prerr(": the static assumption is given the sort ")
    val () = prerr_s2rt_s(s2t1)
    val () = prerr " but it is expected to be of the sort "
    val () = prerr_s2rt_s(s2t2)
    val () = prerr "."
  } (* end of [if] *)
  val () = prerr_newline((*void*))
//
  val () = the_trans2errlst_add(trans2err_T2E_s1aspdec_tr_res(d0, s2t1, s2t2))
} // end of [auxerr]
//
in // in of [let]
//
case+
gopt_view(d0.s1aspdec_res()) of // case+
| ~GOsome(s1t) => let
    val s2t = s1rt_tr(s1t)
    val test = s2rt_ltmat1(s2t, s2t_res)
  in
    if test
    then s2t else let
      val () = auxerr(d0, s2t, s2t_res) in s2t
    end (* end of [if] *)
  end // end of [Some]
| ~GOnone() => s2t_res
//
end // end of [s1aspdec_tr_res]

vtypedef
s2aspdecopt_vt = Option_vt (s2aspdec)

in (* in-of-local *)

fun
s1aspdec_tr
(
  d1c: s1aspdec
) : s2aspdecopt_vt = let
//
fun
auxerr1
(
d0: s1aspdec, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(d0.s1aspdec_loc())
  // end of [val]
  val () =
    filprerr_ifdebug( "s1aspdec_tr" )
  // end of [val]
  val () = prerr(": the static constant [")
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] is not abstract.")
in
  the_trans2errlst_add(trans2err_T2E_s1aspdec_tr(d0))
end // end of [auxerr1]
//
fun
auxerr2
(
d0: s1aspdec, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(d0.s1aspdec_loc())
  // end of [val]
  val () =
    filprerr_ifdebug( "s1aspdec_tr" )
  // end of [val]
  val () = prerr(": the identifier [")
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] does not refer to a static constant.")
in
  the_trans2errlst_add(trans2err_T2E_s1aspdec_tr(d0))
end // end of [auxerr2]
//
fun
auxerr3
(
d0: s1aspdec, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(d0.s1aspdec_loc())
  // end of [val]
  val () = prerr ": the identifier ["
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] is unrecognized.")
in
  the_trans2errlst_add(trans2err_T2E_s1aspdec_tr(d0))
end // end of [auxerr3]
//
  val loc = d1c.s1aspdec_loc()
  val qid = d1c.s1aspdec_qid()
//
  val q0 = qid.sqi0de_qua()
  and id = qid.sqi0de_sym()
//
  val ans = the_s2expenv_find_qua(q0, id)
//
in
//
case+ ans of
| ~Some_vt(s2i) =>
  (
  case+ s2itm_view(s2i) of
  | ~S2ITMcst(s2cs) => let
//
      val
      s2cs =
      glist_filter_fun<s2cst>(s2cs, s2cst_is_abstr)
//
    in
      case+ s2cs of
      | ~list_vt_nil
          ((*void*)) => let
          val () = auxerr1(d1c, q0, id) in None_vt()
        end // end of [list_vt_nil]
      | ~list_vt_cons
          (s2c, s2cs) => let
//
          val ((*freed*)) = list_vt_free(s2cs)
//
          val () =
            the_s2expenv_push_nil((*pushed*))
          // end of [val]
//
          var s2t_fun = s2cst_get_srt(s2c)
//
          val s2vss =
            s1aspdec_tr_arg(d1c, d1c.s1aspdec_arg(), s2t_fun)
          // end of [val]
//
          val s2t_res = s1aspdec_tr_res(d1c, s2t_fun)
          val s2e_body = s1exp_trdn(d1c.s1aspdec_def(), s2t_res)
//
          val ((*popped*)) =
            the_s2expenv_pop_free ((*none*))
          // end of [val]
//
          val s2e_def = s2exp_lamlst(glist_make_list_vt(s2vss), s2e_body)
//
(*
          // HX: definition binding is to be done in [pats_trans3_decl.dats]
*)
//
        in
          Some_vt(s2aspdec_make(loc, s2c, s2e_def))
        end // end of [list_vt_cons]
    end // end of [S2ITEMcst]
  | v => (s2itm_view_free (v);
    (
      let val () = auxerr2(d1c, q0, id) in None_vt((*void*)) end
    ) (* end of [non-S2ITMcst] *))
  ) (* end of [Some_vt] *)
| ~None_vt() => let
    val () = auxerr3(d1c, q0, id) in None_vt()
  end // end of [None_vt]
//
end // end of [s1aspdec_tr]

end // end of [local]

(* ****** ****** *)

fun
re1assume_tr
(
  qid: sqi0de
) : Option_vt(s2cst) = let
//
fun
auxerr1
(
  qid: sqi0de, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(qid.sqi0de_loc())
  // end of [val]
  val () =
    filprerr_ifdebug( "re1assume_tr" )
  // end of [val]
  val () = prerr(": the static constant [")
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] is not abstract.")
in
  the_trans2errlst_add(trans2err_T2E_re1assume_tr(qid))
end // end of [auxerr1]
//
fun
auxerr2
(
  qid: sqi0de, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(qid.sqi0de_loc())
  // end of [val]
  val () =
    filprerr_ifdebug( "re1assume_tr" )
  // end of [val]
  val () = prerr(": the identifier [")
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] does not refer to a static constant.")
in
  the_trans2errlst_add(trans2err_T2E_re1assume_tr(qid))
end // end of [auxerr2]
//
fun
auxerr3
(
  qid: sqi0de, q: s0taq, id: symbol
) : void = let
  val () =
    prerr_error2_loc(qid.sqi0de_loc())
  // end of [val]
  val () = prerr ": the identifier ["
  val () =
    ($SYN.prerr_s0taq(q); $SYM.prerr_symbol(id))
  val () = prerrln! ("] is unrecognized.")
in
  the_trans2errlst_add(trans2err_T2E_re1assume_tr(qid))
end // end of [auxerr3]
//
val q0 = qid.sqi0de_qua()
and id = qid.sqi0de_sym()
//
val ans = the_s2expenv_find_qua(q0, id)
//
in
//
case+ ans of
| ~Some_vt(s2i) =>
  (
  case+ s2itm_view(s2i) of
  | ~S2ITMcst(s2cs) => let
//
      val
      s2cs =
      glist_filter_fun<s2cst>(s2cs, s2cst_is_abstr)
//
    in
      case+ s2cs of
      | ~list_vt_nil
          ((*void*)) => let
          val () = auxerr1(qid, q0, id) in None_vt()
        end // end of [list_vt_nil]
      | ~list_vt_cons
          (s2c, s2cs) =>
          Some_vt(s2c) where
        {
          val ((*freed*)) = list_vt_free(s2cs)
        } (* end of [list_vt_cons] *)
    end // end of [S2ITMcst]
  | v => (s2itm_view_free (v);
    let val () = auxerr2(qid, q0, id) in None_vt((*void*)) end)
  ) (* end of [Some_vt] *)
//
| ~None_vt() => let
    val () = auxerr3(qid, q0, id) in None_vt()
  end // end of [None_vt]
//
end // end of [re1assume_tr]

(* ****** ****** *)

local

fun
d1atconlst_tr
(
  s2c: s2cst
, islin: bool
, isprf: bool
, s2vss0: s2varlstlst
, fil: filename
, d1cs: d1atconlst
) : d2conlst = (
//
case+ glist_view(d1cs) of
| ~GLnil() => glist_nil()
| ~GLcons(d1c, d1cs) => let
    val d2c = d1atcon_tr (s2c, islin, isprf, s2vss0, fil, d1c)
    val d2cs = d1atconlst_tr (s2c, islin, isprf, s2vss0, fil, d1cs)
  in
    glist_cons(d2c, d2cs)
  end // end of [cons]
//
) (* end of [d1atconlst_tr] *)

in (* in of [local] *)

fun
d1atdec_tr
(
  s2c: s2cst, s2vss0: s2varlstlst, d1c: d1atdec
) : void = let
//
val () = let
  val n = glist_length (s2vss0) in
  if n >= 2 then {
    val () = prerr_error2_loc (d1c.d1atdec_loc())
    val () = filprerr_ifdebug "d1atdec_tr" // for debugging
    val () = prerr ": the declared type constructor is overly applied."
    val () = prerr_newline ()
    val () = the_trans2errlst_add (trans2err_T2E_d1atdec_tr(d1c))
  } // end of [if]
end // end of [val]
//
val
s2t_fun = s2cst_get_srt (s2c)
val
s2t_res =
(
  case+ s2rt_viewof(s2t_fun) of
  | ~S2RTfun (_, s2t) => s2t
  | v => (s2rt_view_free (v); s2t_fun)
) : s2rt (* end of [val] *)
//
val
islin = s2rt_is_lin s2t_res and isprf = s2rt_is_prf s2t_res
//
val d2cs =
d1atconlst_tr
(
  s2c, islin, isprf
, s2vss0, d1c.d1atdec_fil(), d1c.d1atdec_con()
) (* end of [val] *)
//
val () = let
//
// HX:
// Assigning tags to
// dynamic constructors
//
  fun aux (
    i: int, d2cs: d2conlst
  ) : void =
  (
    case+ glist_view(d2cs) of
    | ~GLnil() => ()
      // end of [list_nil]
    | ~GLcons(d2c, d2cs) => let
        val () = d2con_set_tag (d2c, i) in aux (i+1, d2cs)
      end // end of [list_cons]
  ) (* end of [aux] *)
in
  aux (0, d2cs)
end // end of [let] // end of [val]
//
// HX-2026-10: no GC
// a nonlinear datatype may only have nullary
// constructors (which are not heap-allocated);
// use [datavtype] for heap-allocated values
//
val () =
if ~islin && ~isprf then let
  fun auxck
    (d2cs: d2conlst): bool =
  (
    case+ glist_view(d2cs) of
    | ~GLnil() => false
    | ~GLcons(d2c, d2cs) =>
        if d2con_get_arity_real (d2c) > 0 then true else auxck (d2cs)
      // end of [list_cons]
  ) (* end of [auxck] *)
in
  if auxck (d2cs) then {
    val () = prerr_error2_loc (d1c.d1atdec_loc())
    val () = filprerr_ifdebug "d1atdec_tr" // for debugging
    val () = prerr ": nonlinear heap allocation is not supported (no GC): "
    val () = prerr "the datatype ["
    val () = $SYM.prerr_symbol (d1c.d1atdec_sym())
    val () = prerr "] has a non-nullary constructor; use [datavtype] instead."
    val () = prerr_newline ()
    val () = the_trans2errlst_add (trans2err_T2E_d1atdec_tr(d1c))
  } // end of [if]
end // end of [if] // end of [val]
//
val
islst = (
//
if glist_is_pair<d2con> (d2cs) then let
    val d2c1 = glist_head<d2con> (d2cs)
    val d2c2 = glist_head<d2con> (glist_tail<d2con> (d2cs))
  in
    if d2con_get_arity_real(d2c1) = 0
      then (
        if d2con_get_arity_real(d2c2) > 0 then gopt_some(d2conpair_new(d2c1, d2c2)) else gopt_none()
      ) else (
        if d2con_get_arity_real(d2c2) = 0 then gopt_some(d2conpair_new(d2c2, d2c1)) else gopt_none()
      ) (* end of [if] *)
  end (* end of [cons(cons(nil))] *)
else gopt_none() (* it-is-not-list-like *)
//
) : d2conpairopt
//
val () = s2cst_set_islst (s2c, islst)
val () = s2cst_set_dconlst (s2c, gopt_some d2cs)
//
in
  // nothing
end // end of [d1atdec_tr]

end // end of [local]

(* ****** ****** *)

extern
fun
d1atdeclst_tr
(
  datknd: int
, d1cs_dat: d1atdeclst
, d1cs_def: s1expdeflst
) : s2cstlst // end-of-fun
implement
d1atdeclst_tr
(
  datknd, d1cs_dat, d1cs_def
) = let
//
typedef
T = @(d1atdec, s2cst, s2varlstlst)
typedef Tlst = glist (T)
//
val s2t_res = s2rt_impred (datknd)
//
val d1cs2cs2vsslst = let
//
  var res
    : Tlst = glist_nil()
  // end of [var]
//
  fun aux
  (
    d1c: d1atdec, res: &Tlst
  ) : void = let
    val argvar =
      glist_map_fun<a1msrt,syms2rtlst>
        (d1c.d1atdec_arg(), a1msrt_tr_symsrt)
    // glist_map_fun
    val s2vss = let
      fun f (
        xs: syms2rtlst
      ) : s2varlst =
        case+ glist_view(xs) of
        | ~GLnil() =>
          glist_nil()
        | ~GLcons(x, xs) => let
            val isnamed =
            (x.syms2rt_sym() != $SYM.symbol_empty)
          in
            if isnamed then let
              val s2v =
              s2var_make_id_srt(x.syms2rt_sym(), x.syms2rt_srt()) in glist_cons(s2v, f(xs))
            end else f (xs) // end of [if]
          end // end of [list_cons]
      // end of [f]
      fun ff (
        xss: syms2rtlstlst
      ) : s2varlstlst =
        case+ glist_view(xss) of
        | ~GLnil() => glist_nil()
        | ~GLcons(xs, xss) => let
             val s2vs = f(xs) and s2vss = ff(xss)
           in
             if glist_is_cons(s2vs) then glist_cons(s2vs, s2vss) else s2vss
           end // end of [list_vt_cons]
      // end of [ff]
    in
      ff (argvar)
    end : s2varlstlst
//
    val s2tss_arg = let
      fun fopr
        (xs: syms2rtlst): s2rtlst =
        case+ glist_view(xs) of
        | ~GLnil() => glist_nil()
        | ~GLcons(x, xs) => glist_cons(x.syms2rt_srt(), fopr(xs))
      // end of []
    in
      glist_map_fun<syms2rtlst,s2rtlst> (argvar, fopr)
    end : s2rtlstlst
//
    val s2c =
    s2cst_make_dat
    (
      d1c.d1atdec_sym(), d1c.d1atdec_loc(), s2tss_arg, s2t_res, argvar
    ) (* end of [val] *)
    val () = the_s2expenv_add_scst (s2c)
//
  in
    res := glist_cons<T> (@(d1c, s2c, s2vss), res)
  end // end of [val]
//
  fun auxlst (
    d1cs: d1atdeclst, res: &Tlst
  ) : void =
  (
    case+ glist_view(d1cs) of
    | ~GLnil() => ()
    | ~GLcons(d1c, d1cs) => let
        val () = aux (d1c, res) in auxlst (d1cs, res)
      end // end of [list_cons]
  ) (* end of [auxlst] *)
//
in
  auxlst (d1cs_dat, res); res
end : Tlst // end of [d1cs2cs2vsslst]
//
fun aux2 (
  d1cs: s1expdeflst
) : void = (
  case+ glist_view(d1cs) of
  | ~GLnil() => ()
  | ~GLcons(d1c, d1cs) => let
      val s2c = s1expdef_tr (gopt_none(), d1c)
      val () = the_s2expenv_add_scst (s2c)
    in
      aux2 (d1cs)
    end // end of [cons]
) (* end of [aux2] *)
//
val () = aux2 (d1cs_def)
//
fun auxlst2 (
  xs: Tlst
) : s2cstlst = case+ glist_view(xs) of
  | ~GLcons(x, xs) => let
      val () = d1atdec_tr (x.1, x.2, x.0) in glist_cons(x.1, auxlst2 xs)
    end // end of [list_cons]
  | ~GLnil() => glist_nil()
// end of [auxlst2]
in
//
auxlst2 (d1cs2cs2vsslst)
//
end // end of [d1atdeclst_tr]

(* ****** ****** *)
//
// HX: [exn] is considered a viewtype constructor
//
fun
e1xndec_tr (
  s2c: s2cst, d1c: e1xndec
) : d2con = let
  val loc = d1c.e1xndec_loc()
  val fil = d1c.e1xndec_fil() and id = d1c.e1xndec_sym()
  val () = the_s2expenv_push_nil ()
  val s2qs = glist_map_fun<q1marg,s2qua> (d1c.e1xndec_qua(), q1marg_tr)
  val npf = d1c.e1xndec_npf()
  val s1es_arg = d1c.e1xndec_arg()
  val s2es_arg = s1explst_trdn_vt0ype (s1es_arg)
  val () = the_s2expenv_pop_free ((*none*))
  val d2c = d2con_make
    (loc, fil, id, s2c, 1(*vwtp*), s2qs, npf, s2es_arg, gopt_none(*ind*)())
  val () = d2con_set_tag (d2c, ~1)
  val () = the_d2expenv_add_dcon (d2c)
in
  d2c (* HX: the defined exception constructor *)
end // end of [e1xndec_tr]

(* ****** ****** *)
//
extern
fun
e1xndeclst_tr
  (d1cs: e1xndeclst): d2conlst
//
implement
e1xndeclst_tr
  (d1cs) = let
//
fun
aux (
  s2c: s2cst, d1cs: e1xndeclst
) : d2conlst =
(
  case+ glist_view(d1cs) of
  | ~GLnil() => glist_nil()
  | ~GLcons(d1c, d1cs) => let
      val d2c = e1xndec_tr (s2c, d1c)
    in
      glist_cons(d2c, aux (s2c, d1cs))
    end // end of [list_cons]
  // end of [aux]
) (* end of [aux] *)
//
val
s2c =
s2cstref_get_cst
  (the_exception_vtype)
//
val d2cs = aux (s2c, d1cs)
//
val d2cs0 =
(
//
case+
gopt_view(s2cst_get_dconlst (s2c)) of // case+
| ~GOnone() => d2cs
| ~GOsome(d2cs0) => glist_append<d2con> (d2cs, d2cs0)
//
) : d2conlst // end of [val]
//
val () = s2cst_set_dconlst (s2c, gopt_some(d2cs0))
//
in
  d2cs (*d2conlst*)
end // end of [e1xndeclst_tr]
//
(* ****** ****** *)

fun
c1lassdec_tr
(
  id: i0de
, sup: s1expopt
) : void = () where
{
//
val sym = id.i0de_sym()
val loc = id.i0de_loc()
//
val s2c =
s2cst_make
(
  sym // sym
, loc // location
, $FIL.filename_dummy
, s2rt_cls // sort for nominal classes
, gopt_none(*isabs*)()
, false(*iscon*)
, false(*isrec*)
, gopt_none((*isasp*))
, gopt_none((*listlike*))
, glist_nil{syms2rtlst}((*argvar*))
, gopt_none((*s2expopt*))
) (* end of [s2cst_make] *)
//
val () = (
//
case+ gopt_view(sup) of
| ~GOnone() => ()
| ~GOsome(s1e) => {
    val s2e =
      s1exp_trdn (s1e, s2rt_cls)
    // end of [val]
    val ((*void*)) =
      s2cst_add_supcls (s2c, s2exp_hnfize(s2e))
    // end of [val]
  } (* end of [Some] *)
//
) (* end of [val] *)
//
val () = the_s2expenv_add_scst (s2c)
//
} (* end of [c1lassdec_tr] *)

(* ****** ****** *)

local

fun
dckfun_check
(
  d1c: d1cstdec
, dck: dcstkind, s2e_cst: s2exp
) : void = (
//
case+ dck of
//
| DCKfun () => let
    val isfun =
      s2exp_is_FUNCLOfun (s2e_cst)
    // end of [val]
  in
    if not(isfun) then
    {
//
      val () = prerr_ERROR_beg()
      val () =
        prerr_error2_loc (d1c.d1cstdec_loc())
      // end of [val]
      val () = filprerr_ifdebug "d1cstdec_tr" // for debugging
      val () =
        prerrln!(": the function may need to be declared as a value")
      val () = prerr_ERROR_end()
//
      val () = the_trans2errlst_add (trans2err_T2E_d1cstdec_tr(d1c))
//
    } (* end of [if] *)
  end (* end of [DCKfun] *)
//
| _(*rest*) => ((*void*))
//
) (* end of [dckfun_check] *)

fun
s2exp_get_arylst
  (s2e: s2exp): intlst =
(
//
case+
s2exp_node_view(s2e.s2exp_node()) of
//
| ~S2Efun
  (
    _, _, _, _, s2es, s2e
  ) => let
    val n = glist_length (s2es)
  in
    glist_cons(n, s2exp_get_arylst(s2e))
  end // end of [S2Efun]
//
| ~S2Eexi (_, _, s2e) => s2exp_get_arylst(s2e)
| ~S2Euni (_, _, s2e) => s2exp_get_arylst(s2e)
//
| ~S2Emetfun (_, _, s2e) => s2exp_get_arylst(s2e)
//
| v => (s2exp_node_view_free (v); glist_nil{int} ((*void*)))
//
) (* end of [s2exp_get_arylst] *)

in (* in of [local] *)

fun
d1cstdec_tr
(
  knd: int
, dck: dcstkind, s2qs: s2qualst, d1c: d1cstdec
) : d2cst = d2c where
{
//
  val loc = d1c.d1cstdec_loc()
  val fil = d1c.d1cstdec_fil()
  val sym = d1c.d1cstdec_sym()
//
(*
  val () = println! ("d1cstdec_tr: fil = ", fil)
  val () = println! ("d1cstdec_tr: sym = ", sym)
*)
//
// HX-2012:
// it is either prop or t@ype; it cannot be linear
//
  val isprf =
    dcstkind_is_proof (dck)
  val s2t_cst =
    (if isprf then s2rt_prop else s2rt_t0ype): s2rt
//
  val s1e_cst = d1c.d1cstdec_type()
  val s2e_cst = s1exp_trdn (s1e_cst, s2t_cst)
  val s2e_cst = s2exp_hnfize (s2e_cst)
  val ((*void*)) = dckfun_check (d1c, dck, s2e_cst)
//
  val arylst = s2exp_get_arylst (s2e_cst)
//
  var extdef
    : dcstextdef = d1c.d1cstdec_extdef()
  val () = (
    if $SYN.dcstextdef_is_DCSTEXTDEFnone (extdef) then
        (if knd = 0 then (extdef := $SYN.dcstextdef_DCSTEXTDEFnone(0)))
    else ()
  ) : void // end of [val]
//
  val d2c =
    d2cst_make (sym, loc, fil, dck, s2qs, arylst, s2e_cst, extdef)
  // end of [val]
//
  val ((*void*)) = the_d2expenv_add_dcst (d2c)
//
} (* end of [d1cstdec_tr] *)

end // end of [local]

(* ****** ****** *)

fun d1cstdeclst_tr
(
  knd: int
, dck: dcstkind
, s2qs: s2qualst
, d1cs: d1cstdeclst
) : d2cstlst = let
in
  case+ glist_view(d1cs) of
  | ~GLcons(d1c, d1cs) => let
      val d2c = d1cstdec_tr (knd, dck, s2qs, d1c)
    in
      glist_cons(d2c, d1cstdeclst_tr (knd, dck, s2qs, d1cs))
    end // end of [cons]
  | ~GLnil() => glist_nil()
end // end of [d1cstdeclst_tr]

(* ****** ****** *)

local

fun trans2_env_add_m2acarg
  (x: m2acarg): void = let
in
  case+ m2acarg_view(x) of
  | ~M2ACARGsta (s2vs) =>
      the_s2expenv_add_svarlst (s2vs)
    // end of [M2ACARGsta]
  | ~M2ACARGdyn (d2vs) =>
      the_d2expenv_add_dmacvarlst (d2vs)
    // end of [M2ACARGdyn]
end // end of [trans2_env_add_m2acarg]
fun trans2_env_add_m2acarglst
  (xs: m2acarglst): void = glist_app_fun (xs, trans2_env_add_m2acarg)
// end of [trans2_env_add_m2acarglst]

in (* in of [local] *)

fun
m1acdef_tr (
  knd: int, d2m: d2mac, d1c: m1acdef
) : void = let
//
val loc = d1c.m1acdef_loc()
and sym = d1c.m1acdef_sym()
val () = the_trans2_env_push ()
val arglst = d2mac_get_arglst (d2m)
//
//
val () = trans2_env_add_m2acarglst (arglst)
val () = the_macdeflev_inc ()
val () = if knd >= 1 then the_maclev_dec (loc)
val def = d1exp_tr (d1c.m1acdef_def())
val () = if knd >= 1 then the_maclev_inc (loc)
val () = the_macdeflev_dec ()
val () = the_trans2_env_pop ((*none*))
val () = d2mac_set_def (d2m, def)
//
in
  // empty
end // end of [m1acdef_tr]

end // end of [local]

local

fun m1acarg_tr
  (x: m1acarg): m2acarg = let
in
  case+ m1acarg_node_view(x.m1acarg_node()) of
  | ~M1ACARGdyn (ids) => let
      fun f (x: i0de): d2var =
        d2var_make (x.i0de_loc(), x.i0de_sym())
      val d2vs = glist_map_fun<i0de,d2var> (ids, f)
    in
      m2acarg_M2ACARGdyn(d2vs)
    end
  | ~M1ACARGsta (s1as) => let
      fun f (s1a: s1arg): s2var = let
        val s2t = (
          case+ gopt_view(s1a.s1arg_srt()) of
          | ~GOsome(s1t) => s1rt_tr (s1t) | ~GOnone() => s2rt_t0ype
        ) : s2rt // end of [val]
      in
        s2var_make_id_srt (s1a.s1arg_sym(), s2t)
      end // end of [f]
      val s2vs = glist_map_fun<s1arg,s2var> (s1as, f)
    in
      m2acarg_M2ACARGsta(s2vs)
    end
end // end of [m1acarg_tr]

fun m1acarglst_tr
  (m1as: m1acarglst): m2acarglst = let
  val m2as = glist_map_fun<m1acarg,m2acarg> (m1as, m1acarg_tr) in m2as
end // end of [m1acarglst_tr]

in (* in of [local] *)

fun m1acdeflst_tr (
  knd: int, d1cs: m1acdeflst
) : void = let
//
// knd: 0/1/2 => short/long/longrec
//
fun aux1 (
  knd: int, d1cs: m1acdeflst
) : d2maclst = let
in
//
case+ glist_view(d1cs) of
| ~GLcons(d1c, d1cs) => let
    val loc = d1c.m1acdef_loc()
    val sym = d1c.m1acdef_sym()
    val def = d2exp_empty (loc)
    val args = m1acarglst_tr (d1c.m1acdef_arg())
    val d2m = d2mac_make (loc, sym, knd, args, def)
    val () = if knd >= 2 then the_d2expenv_add_dmacdef (d2m)
    val d2ms = aux1 (knd, d1cs)
  in
    glist_cons(d2m, d2ms)
  end // end of [aux1]
| ~GLnil() => glist_nil()
//
end // end of [aux1]
val d2ms = aux1 (knd, d1cs)
//
fun loop2 (
  d2ms: d2maclst, d1cs: m1acdeflst
) : void = let
in
  case+ glist_view(d2ms) of
  | ~GLcons(d2m, d2ms) => let
      val d1c = glist_head_exn<m1acdef> (d1cs)
      val d1cs = glist_tail_exn<m1acdef> (d1cs)
      val knd = d2mac_get_kind (d2m)
      val d2c = m1acdef_tr (knd, d2m, d1c)
      val () = if knd <= 1 then the_d2expenv_add_dmacdef (d2m)
    in
      loop2 (d2ms, d1cs)
    end // end of [list_cons]
  | ~GLnil() => ()
end // end of [loop2]
val () = loop2 (d2ms, d1cs)
//
in
  // nothing
end // end of [m1acdeflst_tr]

end // end of [local]

(* ****** ****** *)

fun
f1undec_tr
(
  decarg: s2qualst
, d2v: d2var, f1d: f1undec
) : f2undec = let
  val () =
    d2var_set_decarg (d2v, decarg)
  // end of [val]
  val def = d1exp_tr (f1d.f1undec_def())
  val isnot = not (d2exp_is_lam (def))
//
  val () =
  if isnot then let
    val () =
    prerr_error2_loc (def.d2exp_loc())
    val () = filprerr_ifdebug "f1undec_tr"
    val () =
    prerrln! ": function definition is required to be lam-abstract."
  in
    the_trans2errlst_add (trans2err_T2E_f1undec_tr(f1d))
  end // end of [if] // end of [val]
//
  val ann = witht1ype_tr (f1d.f1undec_ann())
//
in
  f2undec_make (f1d.f1undec_loc(), d2v, def, ann)
end // end of [f1undec_tr]

fun
f1undeclst_tr
(
  knd: funkind
, decarg: s2qualst, f1ds: f1undeclst
) : f2undeclst = let
//
  val isprf = funkind_is_proof (knd)
  val isrec = funkind_is_recursive (knd)
//
  val d2vs = let
    fun aux1
    (
      isprf: bool
    , f1ds: f1undeclst
    ) : d2varlst =
      case+ glist_view(f1ds) of
      | ~GLcons(f1d, f1ds) => let
          val sym = f1d.f1undec_sym()
          val loc = f1d.f1undec_sym_loc()
          val d2v = d2var_make (loc, sym)
          val () = d2var_set_isfix (d2v, true)
          val () = d2var_set_isprf (d2v, isprf)
        in
          glist_cons(d2v, aux1 (isprf, f1ds))
        end // end of [list_cons]
      | ~GLnil() => glist_nil()
    // end of [aux1]
  in
    aux1 (isprf, f1ds)
  end // end of [val]
//
  val () = (
    if isrec then the_d2expenv_add_dvarlst (d2vs) else ()
  ) : void // end of [val]
//
  val f2ds = let
    fun aux2
    (
      decarg: s2qualst
    , d2vs: d2varlst
    , f1ds: f1undeclst
    ) : f2undeclst =
      case+ glist_view(d2vs) of
      | ~GLcons(d2v, d2vs) => let
          val f1d = glist_head_exn<f1undec> (f1ds)
          val f1ds = glist_tail_exn<f1undec> (f1ds)
          val f2d = f1undec_tr (decarg, d2v, f1d)
          val f2ds = aux2 (decarg, d2vs, f1ds)
        in
          glist_cons(f2d, f2ds)
        end // end of [list_cons]
      | ~GLnil() => glist_nil()
    // end of [aux2]
  in
    aux2 (decarg, d2vs, f1ds)
  end // end of [val]
//
  val () = (
    if isrec then () else the_d2expenv_add_dvarlst (d2vs)
  ) : void // end of [val]
//
in
  f2ds
end // end of [f1undeclst_tr]

(* ****** ****** *)

fun
v1aldec_tr
(
  v1d: v1aldec, p2t: p2at
) : v2aldec = let
  val loc = v1d.v1aldec_loc()
  val def = d1exp_tr (v1d.v1aldec_def())
  val ann = witht1ype_tr (v1d.v1aldec_ann())
in
  v2aldec_make (loc, p2t, def, ann)
end // end of [v1aldec_tr]

fun
v1aldec_pat_tr (v1d: v1aldec): p2at = p1at_tr (v1d.v1aldec_pat())

fun
v1aldeclst_map2
(
  v1ds: v1aldeclst, p2ts: p2atlst
) : v2aldeclst =
(
  case+ glist_view (v1ds) of
  | ~GLcons (v1d, v1ds) => let
      val p2t = glist_head_exn<p2at> (p2ts)
      val p2ts = glist_tail_exn<p2at> (p2ts)
      val v2d = v1aldec_tr (v1d, p2t)
    in
      glist_cons (v2d, v1aldeclst_map2 (v1ds, p2ts))
    end // end of [GLcons]
  | ~GLnil () => glist_nil ()
) // end of [v1aldeclst_map2]

fun
v1aldeclst_tr
(
  isrec: bool, v1ds: v1aldeclst
) : v2aldeclst = let
  val p2ts = glist_map_fun<v1aldec,p2at> (v1ds, v1aldec_pat_tr)
  val s2vs = $UT.lstord2list (p2atlst_svs_union p2ts)
  val d2vs = $UT.lstord2list (p2atlst_dvs_union p2ts)
in
  if not(isrec) then let
    val v2ds = v1aldeclst_map2 (v1ds, p2ts)
    val () = the_s2expenv_add_svarlst s2vs
    val () = the_d2expenv_add_dvarlst d2vs
  in
    v2ds
  end else let
    val () = the_d2expenv_add_dvarlst (d2vs)
    val v2ds = v1aldeclst_map2 (v1ds, p2ts)
    val () = the_s2expenv_add_svarlst (s2vs)
  in
    v2ds
  end // end of [if]
end (* end of [v1aldeclst_tr] *)

(* ****** ****** *)

fun
v1ardec_tr
(
  v1d: v1ardec
) : v2ardec = let
(*
// HX: toplevel stack allocation is supported.
*)
val loc = v1d.v1ardec_loc()
val knd = v1d.v1ardec_knd()
val sym = v1d.v1ardec_sym()
val loc_sym = v1d.v1ardec_sym_loc()
//
val d2v = d2var_make (loc_sym, sym)
//
val d2vopt =
(
if knd > 0 then let
  val d2v = d2var_make (loc_sym, sym) in gopt_some(d2v)
end else gopt_none((*void*))
) : d2varopt // end of [val]
//
// HX-2013:
// [s2v_addr] is introduced as a static variable of the
val s2v_addr = s2var_make_id_srt (sym, s2rt_addr) // same name
//
val s2e_addr = s2exp_var (s2v_addr)
val ((*void*)) = d2var_set_addr (d2v, gopt_some(s2e_addr))
//
val pfat =
(
case+
gopt_view(v1d.v1ardec_pfat()) of
//
| ~GOnone() => gopt_none()
| ~GOsome(i0de) => let
    val d2v = d2var_make (i0de.i0de_loc(), i0de.i0de_sym())
  in
    gopt_some(d2v)
  end // end of [Some]
) : d2varopt // end of [val]
//
val s2eopt =
(
  case+
    gopt_view(v1d.v1ardec_type()) of
  | ~GOnone() => gopt_none((*void*))
  | ~GOsome(s1e) =>
      let val s2e = s1exp_trdn_impred (s1e) in gopt_some(s2e) end
    // end of [Some]
) : s2expopt // end of [val]
//
val init = d1expopt_tr (v1d.v1ardec_init())
//
in
//
v2ardec_make
(
  loc, knd, s2v_addr, d2v, pfat, s2eopt, init, d2vopt
) (* end of [v2ardec_make] *)
//
end // end of [v1ardec_tr]

fun
v1ardeclst_tr
(
  v1ds: v1ardeclst
) : v2ardeclst = v2ds where
{
val v2ds =
  glist_map_fun<v1ardec,v2ardec> (v1ds, v1ardec_tr)
//
val () =
  glist_app_fun (v2ds, f) where
{
  fn f (v2d: v2ardec): void = let
    val () = the_s2expenv_add_svar (v2d.v2ardec_svar())
    val () = the_d2expenv_add_dvar (v2d.v2ardec_dvar())
//
// HX-2013-09:
// if added, this one shadows the previously added d2var
//
    val () = the_d2expenv_add_dvaropt (v2d.v2ardec_dvaropt())
  in
    case+ gopt_view(v2d.v2ardec_pfat()) of
      ~GOsome(d2v) => the_d2expenv_add_dvar (d2v) | ~GOnone() => ()
  end // end of [f]
} (* end of [val] *)
//
} (* end of [v1ardeclst_tr] *)

(* ****** ****** *)

local

fun
auxkndck
(
  v1d: v1ardec
) : void = let
  val stadyn = v1d.v1ardec_knd()
in
//
if stadyn > 0 then let
  val () =
    prerr_warning2_loc (v1d.v1ardec_loc())
  // end of [val]
  val () = filprerr_ifdebug "prv1ardec_tr"
  val () = prerr ": the dynalloc mark (!) is ignored."
  val () = prerr_newline ()
in
(*
  the_trans2errlst_add (T2E_prv1ardec_tr (v1d))
*)
end // end of [if]
//
end // end of [auxkndck]

fun
auxwthck
(
  v1d: v1ardec
) : void = let
  val idopt = v1d.v1ardec_pfat()
in
  case+ gopt_view(idopt) of
  | ~GOsome(id) => let
      val () =
        prerr_warning2_loc (v1d.v1ardec_loc())
      // end of [val]
      val () = filprerr_ifdebug "prv1ardec_tr"
      val () = prerr ": the dynamic identifier ["
      val () = $SYN.prerr_i0de (id)
      val () = prerr "] is ignored."
      val () = prerr_newline ((*void*))
    in
(*
      the_trans2errlst_add (T2E_prv1ardec_tr (v1d))
*)
    end // end of [Some]
  | ~GOnone() => ()
end // end of [auxwthck]

in (* in of [local] *)

fun
prv1ardec_tr
(
  v1d: v1ardec
) : prv2ardec = let
//
val () = auxkndck (v1d)
val () = auxwthck (v1d)
//
val sym = v1d.v1ardec_sym()
val loc_sym = v1d.v1ardec_sym_loc()
val d2v = d2var_make (loc_sym, sym)
val s2eopt = (
  case+ gopt_view(v1d.v1ardec_type()) of
  | ~GOsome(s1e) => let
      val s2e = s1exp_trdn_impred (s1e) in gopt_some(s2e)
    end // end of [Some]
  | ~GOnone() => gopt_none()
) : s2expopt // end of [val]
//
val d2eopt = d1expopt_tr (v1d.v1ardec_init())
//
in
  prv2ardec_make (v1d.v1ardec_loc(), d2v, s2eopt, d2eopt)
end // end of [prv1ardec_tr]

end // end of [local]

fun
prv1ardeclst_tr
(
  v1ds: v1ardeclst
) : prv2ardeclst = v2ds where {
  val v2ds =
    glist_map_fun<v1ardec,prv2ardec> (v1ds, prv1ardec_tr)
  // end of [val]
  val () =
  glist_app_fun (v2ds, f) where {
    fn f (v2d: prv2ardec): void = the_d2expenv_add_dvar (v2d.prv2ardec_dvar())
  } (* end of [where] *) // end of [val]
} (* end of [prv1ardeclst_tr] *)

(* ****** ****** *)

(* ****** ****** *)
//
extern
fun
s1taload_tr
(
  loc0: location
, idopt: symbolopt
, fil: filename, ldflag: int, d1cs: d1eclist
) : @(filenv, int(*loaded*)) // end-of-fun
//
implement
s1taload_tr
(
  loc0, idopt
, fil, ldflag, d1cs
) = let
(*
val () =
print "s1taload_tr: staid = "
val () = (
case+ idopt of
| Some id => $SYM.print_symbol (id) | ~GOnone() => print "(*none*)"
) : void // end of [val]
val () = print_newline ()
val () = begin
  print "s1taload_tr: filename = "; $FIL.print_filename_full fil; print_newline ()
end // end of [val]
*)
//
val fsym =
  $FIL.filename_get_fullname(fil)
val () = the_staload_level_push ()
val ans = the_filenvmap_find(fsym)
//
val
fenv_loaded = (
case+ ans of
| ~Some_vt
  (
    fenv
  ) => @(fenv, 1)
  // end of [Some_vt]
| ~None_vt() => let
    val () = the_trans2_env_save()
//
    val opt = $GLOB.the_PACKNAME_get()
    val d2cs = d1eclist_tr(d1cs) // HX: may set PACKNAME
    val ((*void*)) = $GLOB.the_PACKNAME_set(opt)
//
    val @(m0, m1, m2) =
      the_trans2_env_restore((*none*))
    val fenv = filenv_make(fil, m0, m1, m2, d2cs)
    val ((*void*)) = the_filenvmap_add (fsym, fenv)
  in
    @(fenv, 0)
  end // end of [None_vt]
) : @(filenv, int) // end of [val]
val fenv = fenv_loaded.0 and loaded = fenv_loaded.1
//
val () = (
case+ gopt_view(idopt) of
| ~GOsome(id) =>
    the_s2expenv_add (id, s2itm_S2ITMfilenv(fenv))
| ~GOnone() =>
    $NS.the_namespace_add (fenv) // opening file
) : void // end of [val]
//
val () = the_staload_level_pop ((*none*))
//
in
  @(fenv, loaded)
end // end of [s1taload_tr]
//
(* ****** ****** *)
//
fn
d1ecl_unstaloadnm
  (d1c: d1ecl): @(symbolopt, symbol) =
(
  case+ d1ecl_node_view (d1c.d1ecl_node()) of
  | ~D1Cstaloadnm (idopt, nspace) => @(idopt, nspace)
  | v => (d1ecl_node_view_free (v); $ERR.abort_interr<@(symbolopt, symbol)> ((*MatchError*)))
) // end of [d1ecl_unstaloadnm]

extern
fun
s1taloadnm_tr
(
  d1c0: d1ecl
) : void // end-of-fun
//
implement
s1taloadnm_tr(d1c0) = let
//
fun
auxerr
(
  d1c0: d1ecl, name: symbol
) : void = let
  val () =
    prerr_error2_loc (d1c0.d1ecl_loc())
  // end of [val]
  val () = filprerr_ifdebug "s1taloadnm_tr"
//
  val () = prerr ": the name ["
  val () = $SYM.prerr_symbol(name)
  val () = prerr "] does not refer to a namespace."
  val () = prerr_newline((*void*))
//
in
  the_trans2errlst_add(trans2err_T2E_d1ecl_tr_staloadnm(d1c0))
end (* end of [auxerr] *)
//
val idopt_nspace = d1ecl_unstaloadnm (d1c0)
val idopt = idopt_nspace.0 and nspace = idopt_nspace.1
//
val ans = the_s2expenv_find(nspace)
//
in
//
case+ ans of
| ~None_vt
    ((*void*)) => auxerr(d1c0, nspace)
  // end of [None_vt]
| ~Some_vt(s2i) =>
  (
  case+ s2itm_view(s2i) of
  | ~S2ITMfilenv(fenv) =>
    (
      case+ gopt_view(idopt) of
      | ~GOsome(id) => () where
        {
          val () = the_s2expenv_add(id, s2i)
        }
      | ~GOnone() => () where
        {
          val () = $NS.the_namespace_add(fenv)
//
// HX-2017-01-30:
// Overloading declarations needs to be added
//
          val d2cs = filenv_get_d2eclist(fenv)
          val ((*void*)) = overload_tr_d2eclist(d2cs)
//
        } (* end of [None] *)
    ) (* end of [S2ITMfi1lenv] *)
  | v (*non-S2ITMfilenv*) => (s2itm_view_free (v); auxerr(d1c0, nspace))
  ) (* end of [Some_vt] *)
//
end // end of [s1taloadnm_tr]

(* ****** ****** *)

implement
overload_tr_d2eclist
  (d2cs) = let
in
//
case+ glist_view(d2cs) of
| ~GLnil() => ()
| ~GLcons(d2c, d2cs) => let
    val () = (
      case+ d2ecl_node_view(d2c.d2ecl_node()) of
//
      | ~D2Csymintr ids => symintr_tr (ids)
(*
      | D2Csymelim ids => symelim_tr (ids) // HX: is this really needed?
*)
      | ~D2Coverload
          (id, pval, opt) => let
          val loc = d2c.d2ecl_loc() in
          case+ gopt_view(opt) of
          | ~GOsome(d2i) => overload_tr_def (loc, id, pval, d2i) | ~GOnone() => ()
        end (* end of [D2Coverload] *)
//
      | ~D2Cinclude (knd, d2cs2) => overload_tr_d2eclist (d2cs2)
//
      | v => (d2ecl_node_view_free (v); ())
//
    ) : void // end of [val]
  in
    overload_tr_d2eclist (d2cs)
  end // end of [list_cons]
//
end // end of [overload_tr_d2eclist]

(* ****** ****** *)

implement
d1ecl_tr(d1c0) = let
//
val loc0 = d1c0.d1ecl_loc()
//
(*
val () = begin
  print "d1ecl_tr: d1c0 = "; print_d1ecl d1c0; print_newline ()
end // end of [val]
*)
//
fun
auxcheck_impdec
(
  d1c0: d1ecl, knd: int, impdec: i2mpdec
) : void = let
  val d2c = impdec.i2mpdec_cst()
  val okay = (
    if knd < 0 then d2cst_is_prf (d2c) else d2cst_is_nonprf (d2c)
  ) : bool // end of [val]
  val () = if ~okay then let
    val () = prerr_error2_loc (d1c0.d1ecl_loc())
    val () = filprerr_ifdebug "d1ecl_tr: auxcheck_impdec" // for debugging
    val () = if knd < 0 then
      prerr ": the implemented dynamic constant is required to be proof."
    val () = if knd >= 0 then
      prerr ": the implemented dynamic constant is required to be non-proof."
    val () = prerr_newline ()
  in
    the_trans2errlst_add (trans2err_T2E_d1ecl_tr_impdec(d1c0))
  end // end of [if] // end of [val]
in
  // nothing
end // end of [auxcheck_impdec]
//
in
//
case+
d1ecl_node_view(d1c0.d1ecl_node()) of // case+
//
| ~D1Cnone() => d2ecl_none(loc0)
//
| ~D1Clist(ds) => let
    val ds = glist_map_fun<d1ecl,d2ecl> (ds, d1ecl_tr)
  in
    d2ecl_list(loc0, ds)
  end // end of [D1Clist]
//
| ~D1Cpackname(opt) => let
    val () =
      $GLOB.the_PACKNAME_set(opt) in d2ecl_none(loc0)
    // end of [D1Cpackname]
  end (* end of [D1Cpackname] *)
//
| ~D1Csymintr (ids) => let
    val () = symintr_tr (ids) in d2ecl_symintr (loc0, ids)
  end // end of [D1Csymintr]
| ~D1Csymelim (ids) => let
    val () = symelim_tr (ids) in d2ecl_symelim (loc0, ids)
  end // end of [D1Csymelim]
//
| ~D1Coverload
    (id, dqid, pval) => let
    val d2iopt =
      overload_tr (d1c0, id, dqid, pval)
    // end of [val]
  in
    d2ecl_overload (loc0, id, pval, d2iopt)
  end // end of [D1Coverload]
//
| ~D1Ce1xpdef
    (id, def) => let
    val () = the_s2expenv_add (id, s2itm_S2ITMe1xp def)
    val () = the_d2expenv_add (id, d2itm_D2ITMe1xp def)
  in
    d2ecl_none (loc0)
  end // end of [D1Ce1xpdef]
| ~D1Ce1xpundef
    (id, def) => let
    val () = the_s2expenv_add (id, s2itm_S2ITMe1xp def)
    val () = the_d2expenv_add (id, d2itm_D2ITMe1xp def)
  in
    d2ecl_none (loc0)
  end // end of [D0Ce0xpundef]
//
| ~D1Cpragma
    (e1xps) => d2ecl_pragma(loc0, e1xps)
| ~D1Ccodegen
    (knd, e1xps) => d2ecl_codegen(loc0, knd, e1xps)
//
| ~D1Cdatsrts(ds) => let
    val () =
      d1atsrtdeclst_tr(ds) in d2ecl_none(loc0)
    // end of [val]
  end // end of [D1Cdatsrts]
//
| ~D1Csrtdefs(ds) => let
    val () = s1rtdeflst_tr(ds) in d2ecl_none(loc0)
  end // end of [D1Csrtdefs]
//
| ~D1Cstacsts(ds) => let
    val s2cs =
      s1tacstlst_tr (ds) in d2ecl_stacsts(loc0, s2cs)
    // end of [val]
  end // end of [D1Cstacsts]
| ~D1Cstacons(knd, ds) => let
    val s2cs =
      s1taconlst_tr (knd, ds) in d2ecl_stacons(loc0, knd, s2cs)
    // end of [val]
  end // end of [D1Cstacons]
//
| ~D1Ctkindef(d) => let
    val () = t1kindef_tr (d) in d2ecl_none (loc0)
  end // end of [D1Ckindef]
//
| ~D1Csexpdefs(knd, ds) => let
    val () =
      s1expdeflst_tr (knd, ds) in d2ecl_none (loc0)
    // end of [val]
  end // end of [D1Csexpdefs]
//
| ~D1Csaspdec(d1c) => let
    val opt = s1aspdec_tr(d1c)
  in
    case+ opt of
    | ~Some_vt(d2c) =>
        d2ecl_saspdec(loc0, d2c)
      // end of [Some_vt]
(*
//
// HX: error is already reported
//
*)
    | ~None_vt((*void*)) => d2ecl_none(loc0)
    // end of [case]
  end // end of [D1Csaspdec]
| ~D1Creassume(qid) => let
    val opt = re1assume_tr(qid)
  in
    case+ opt of
    | ~Some_vt(s2c) =>
      (
        d2ecl_reassume(loc0, s2c)
      ) (* end of [Some_vt] *)
(*
//
// HX: error is already reported
//
*)
    | ~None_vt((*void*)) => d2ecl_none(loc0)
  end // end of [D1Creassume] *)
//
| ~D1Cexndecs(d1cs) =>
  (
    d2ecl_exndecs(loc0, e1xndeclst_tr(d1cs))
  ) (* end of [D1Cexndecs] *)
//
| ~D1Cdatdecs
  (
    knd, d1cs_dat, d1cs_def
  ) => let
    val s2cs =
      d1atdeclst_tr(knd, d1cs_dat, d1cs_def)
    // end of [val]
  in
    d2ecl_datdecs (loc0, knd, s2cs)
  end // end of [D1Cdatdecs]
//
| ~D1Cclassdec(id, sup) => let
    val () = c1lassdec_tr(id, sup) in d2ecl_none(loc0)
  end // end of [D1Cclassdec]
//
| ~D1Cextype
  (
    name, s1e_def // arity=2
  ) => let
    val s2e_def =
      s1exp_trdn_impred (s1e_def)
    // end of [val]
  in
    d2ecl_extype (loc0, name, s2e_def)
  end // end of [D1Cextype]
| ~D1Cextype2
  (
    knd, name, s1e_def // arity=3
  ) => let
    val s2t_def =
      s2rt_impred (knd)
    val s2e_def =
      s1exp_trdn (s1e_def, s2t_def)
    // end of [val]
  in
    d2ecl_extype (loc0, name, s2e_def)
  end // end of [D1Cextype]
//
| ~D1Cextvar
    (name, def) => let
    val def = d1exp_tr (def)
  in
    d2ecl_extvar (loc0, name, def)
  end // end of [D1Cextvar]
| ~D1Cextcode
    (knd, pos, code) =>
    d2ecl_extcode (loc0, knd, pos, code)
  // end of [D1Cextcode]
//
| ~D1Cdcstdecs
  (
    knd, dck, decarg, d1cs
  ) => let
    val () = the_s2expenv_push_nil ()
    val s2qs = glist_map_fun<q1marg,s2qua> (decarg, q1marg_tr_dec)
    val d2cs = d1cstdeclst_tr (knd, dck, s2qs, d1cs)
    val ((*void*)) = the_s2expenv_pop_free ((*none*))
  in
    d2ecl_dcstdecs (loc0, knd, dck, d2cs)
  end // end of [D1Cdcstdecs]
//
| ~D1Cmacdefs
  (
    knd, isrec, d1cs
  ) => let
    val knd = (
      if isrec then (if knd = 0 then 0 else 2) else knd
    ) : int // end of [val]
    val () = m1acdeflst_tr (knd, d1cs) in d2ecl_none (loc0)
  end // end of [D1Cmacdefs]
//
| ~D1Cimpdec
  (
    knd, _arg, _dec
  ) => let
    val d2copt = i1mpdec_tr (d1c0)
  in
    case+ d2copt of
    | ~Some_vt (impdec) => let
        val () =
          auxcheck_impdec (d1c0, knd, impdec)
        // end of [val]
      in
        d2ecl_impdec (loc0, knd, impdec)
      end // end of [Some_vt]
//
// HX: the error is already reported
//
    | ~None_vt ((*void*)) => d2ecl_none (loc0)
  end // end of [D1Cimpdec]
//
| ~D1Cfundecs
  (
    fk0, decarg, f1ds
  ) => let
//
    val
    istmp = glist_is_cons(decarg)
    val
    ismtr = funkind_is_mutailrec(fk0)
//
    var fk0: funkind = fk0
//
    val () =
    if (istmp && ismtr)
      then let
        val () = fk0 := FK_fun()
        val () = prerr_warning2_loc(loc0)
      in
        prerrln! (": [fnx] is treated as [fun] for initiating function templates!")
      end (* end of [then] *)
//
    val () = if istmp then the_tmplev_inc()
//
    val () = the_trans2_env_push ()
//
    val
    tmplev = the_tmplev_get()
//
    val s2qs =
    glist_map_fun<q1marg,s2qua>
      (decarg, q1marg_tr_dec)
    // end of [val]
    val ((*void*)) =
      s2qualstlst_set_tmplev(s2qs, tmplev)
    // end of [val]
//
    val f2ds =
      f1undeclst_tr(fk0, s2qs, f1ds)
    // end of [val]
//
    val () = if istmp then the_tmplev_dec()
//
    val () = the_trans2_env_pop ((*none*))
//
    val () = the_d2expenv_add_fundeclst(fk0, f2ds)
//
  in
    d2ecl_fundecs(loc0, fk0, s2qs, f2ds)
  end // end of [D1Cfundecs]
//
| ~D1Cvaldecs
  (
    knd, isrec, v1ds
  ) => let
    val v2ds = v1aldeclst_tr(isrec, v1ds)
  in
    if not(isrec)
      then d2ecl_valdecs(loc0, knd, v2ds)
      else d2ecl_valdecs_rec(loc0, knd, v2ds)
    // end of [if]
  end // end of [D1Cvaldecs]
//
| ~D1Cvardecs
    (knd, v1ds) => (
    if knd = 0 then let
      val v2ds = v1ardeclst_tr (v1ds) in d2ecl_vardecs(loc0, v2ds)
    end else let // knd = 1
      val v2ds = prv1ardeclst_tr (v1ds) in d2ecl_prvardecs(loc0, v2ds)
    end // end of [if]
  ) // end of [D1Cvardecs]
//
| ~D1Cinclude
    (knd, d1cs) => let
    val d2cs = d1eclist_tr (d1cs) in d2ecl_include (loc0, knd, d2cs)
  end // end of [D1Cinclude]
//
| ~D1Cstaload
  (
    idopt, fil, ldflag, d1cs
  ) => let
    val @(fenv, loaded) =
    s1taload_tr
      (loc0, idopt, fil, ldflag, d1cs)
    // end of [val]
//
// HX-2013-10-30:
// Overloading declarations
// is not allowed to permeate a NAMED namespace!!!
//
    val () =
    (
    case+ gopt_view(idopt) of
    | ~GOnone() => {
        val d2cs = filenv_get_d2eclist(fenv)
        val ((*void*)) = overload_tr_d2eclist(d2cs)
      } (* end of [None] *)
    | ~GOsome(id) => ((*void*))
    ) (* end of [val] *)
//
  in
    d2ecl_staload(loc0, idopt, fil, ldflag, fenv, loaded)
  end // end of [D1Cstaload]
//
| ~D1Cstaloadnm _ => let
    val () = s1taloadnm_tr(d1c0) in d2ecl_none(loc0)
  end // end of [D1Cstaloadnm]
//
| ~D1Cstaloadloc
  (
    pfil, nspace, d1cs_loc
  ) => let
//
    val () = the_trans2_env_save()
//
    val opt = $GLOB.the_PACKNAME_get ()
    val d2cs_loc = d1eclist_tr (d1cs_loc) // local declarations
    val ((*void*)) = $GLOB.the_PACKNAME_set (opt)
//
    val @(m0, m1, m2) = the_trans2_env_restore ((*void*))
    val fenv = filenv_make (pfil, m0, m1, m2, d2cs_loc)
    val ((*void*)) = the_s2expenv_add (nspace, s2itm_S2ITMfilenv(fenv))
  in
    d2ecl_staloadloc (loc0, pfil, nspace, fenv)
  end // end of [D1Cstaloadloc]
//
| ~D1Cdynload(fil) => d2ecl_dynload(loc0, fil)
//
| ~D1Clocal
  (
    d1cs_head, d1cs_body
  ) => let
    val () = the_trans2_env_push ()
    val d2cs_head = d1eclist_tr (d1cs_head)
    val () = the_trans2_env_push ()
    val d2cs_body = d1eclist_tr (d1cs_body)
    val () = the_trans2_env_localjoin ((*none*))
  in
    d2ecl_local (loc0, d2cs_head, d2cs_body)
  end // end of [D1Clocal]
//
//
end // end of [d1ecl_tr]

(* ****** ****** *)

implement
d1eclist_tr(d1cs) =
  glist_map_fun_g<d1ecl,d2ecl> (d1cs, d1ecl_tr)
// end of [d1eclist_tr]

(* ****** ****** *)

implement
d1eclist_tr_errck
  (d1cs) = d2cs where
{
//
  val d2cs = d1eclist_tr(d1cs)
//
  val ((*void*)) = the_trans2errlst_finalize()
//
} // end of [d1eclist_tr_errck]

(* ****** ****** *)

(* end of [pats_trans2_decl.dats] *)
