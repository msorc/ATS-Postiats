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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_staexp.dats).
// A closure that is stored in a fixity operator is closure-converted:
// a function that takes its environment (a location, or a cell of
// the global arena) as its first argument (see pats_fixity.sats).
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
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_staexp"

(* ****** ****** *)

staload FIL = "./pats_filename.sats"

(* ****** ****** *)

staload LOC = "./pats_location.sats"
overload + with $LOC.location_combine

staload SYM = "./pats_symbol.sats"
//
(*
fun f (x: &int): void // read-only
fun f (x: &?int): void // write-only
fun f (x: &?!int): void // allowing both read and write
*)
macdef AMPERSAND = $SYM.symbol_AMPERSAND // & (r)
macdef AMPERBANG = $SYM.symbol_AMPERBANG // &! (rw)
macdef AMPERQMARK = $SYM.symbol_AMPERQMARK // &? (w)
//
macdef BACKSLASH = $SYM.symbol_BACKSLASH
macdef BANG = $SYM.symbol_BANG
macdef QMARK = $SYM.symbol_QMARK
macdef QMARKBANG = $SYM.symbol_QMARKBANG
macdef GTGT = $SYM.symbol_GTGT
macdef MINUSGT = $SYM.symbol_MINUSGT
//
overload = with $SYM.eq_symbol_symbol
//
macdef fprint_symbol = $SYM.fprint_symbol
//
macdef symbol_get_name = $SYM.symbol_get_name
//
(* ****** ****** *)

staload "./pats_lexing.sats"

(* ****** ****** *)

staload "./pats_effect.sats"
staload "./pats_fixity.sats"
staload _(*anon*) = "./pats_fixity_fxty.dats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"
staload "./pats_trans1_env.sats"
staload "./pats_e1xpval.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

macdef
list_sing(x) = glist_sing(,(x))

(* ****** ****** *)

local
//
fun
extprfx_add
(
  sym: symbol, pext: ptr
) : string = let
//
val ext2 =
  $UN.cast{string}(ptr0_succ<char>(pext))
val ext2 = (
  if string_is_empty(g1ofg0(ext2))
    then symbol_get_name (sym) else ext2
  // end of [if]
) : string // end of [val]
//
val opt =
  the_EXTERN_PREFIX_get()
// end of [val]
val
issome = stropt_is_some(opt)
//
in
//
if
issome
then let
  val prfx =
    stropt_unsome(opt)
  val prfxext2 =
    string0_append (prfx, ext2)
  // end of [val]
in
  trans1_strptr2gstring(prfxext2)
end // end of [then]
else let
(*
// HX-2015-05:
// Should a warning/error be reported?
*)
  val prfxext2 =
    string0_append ("__ATS_EXTERN_PREFIX__", ext2)
  // end of [val]
in
  trans1_strptr2gstring(prfxext2)
end // end of [else]
//
end // end of [extprfx_add]

in (* in of [local] *)

implement
proc_extdef
  (sym, ext) = let
//
#define NUL '\000'
//
fun isemp
  (p: ptr): bool = $UN.ptr0_get<char> (p) = NUL
fun isperc
  (p: ptr): bool = $UN.ptr0_get<char> (p) = '%'
//
val pext = $UN.cast{ptr} (ext)
//
in
//
if isemp(pext) then symbol_get_name(sym)
else if isperc(pext) then extprfx_add(sym, pext)
else ext // HX: no processing
//
end // end of [proc_extdef]

end // end of [local]

(* ****** ****** *)

local
//
// HX: [ext] begins with [c0 c1 c2 #]: the rest is copied
//
fn
extnam_is
(
  c0: char, c1: char, c2: char
, ext: string, ext_new: &string >> _
) : bool = let
  val p = $UN.cast{ptr}(ext)
  fn ch (k: int): char = $UN.ptr0_get<char> (ptr0_add_gint<char> (p, k))
in
  if ch(0) = c0 then
  (
    if ch(1) = c1 then
    (
      if ch(2) = c2 then
      (
        if ch(3) = '#' then let
          val () = ext_new := the_garena_strdup ($UN.cast{string}(ptr0_add_gint<char> (p, 4)))
        in
          true
        end else false
      ) else false
    ) else false
  ) else false
end // end of [extnam_is]
//
fn
ismac
(
  ext: string, ext_new: &string >> _
) : bool = extnam_is ('m', 'a', 'c', ext, ext_new)
fn
issta
(
  ext: string, ext_new: &string >> _
) : bool = extnam_is ('s', 't', 'a', ext, ext_new)
fn
isext
(
  ext: string, ext_new: &string >> _
) : bool = extnam_is ('e', 'x', 't', ext, ext_new)
//
in (* in of [local] *)

implement
scstextdef_tr
  (s0c, sym, extopt) = let
//
macdef f(x) =
  proc_extdef(sym, ,(x))
//
in
//
case+ gopt_view (extopt) of
//
| ~GOnone () => scstextdef_SCSTEXTDEFnone()
//
| ~GOsome (s0) => let
    val ext = token_string_get (s0)
    var ext2: string = (ext) // removing mac#, ext#, sta#
    val _(*isext*) = isext(ext, ext2)
  in
    scstextdef_SCSTEXTDEFsome(f(ext2)) // no (recognized) prefix is also fine
  end // end of [_ when ...]
//
end // end of [scstextdef_tr]

implement
dcstextdef_tr
  (d0c, sym, extopt) = let
//
macdef f(x) =
  proc_extdef(sym, ,(x))
//
in
//
case+ gopt_view (extopt) of
//
| ~GOnone () => dcstextdef_DCSTEXTDEFnone(1) // extern
//
| ~GOsome (s0) => let
    val ext = token_string_get (s0)
    var ext2: string = (ext) // removing mac#, ext#, sta#
  in
    if ismac(ext, ext2) then dcstextdef_DCSTEXTDEFsome_mac(f(ext2))
    else if issta(ext, ext2) then dcstextdef_DCSTEXTDEFsome_sta(f(ext2))
    else if isext(ext, ext2) then dcstextdef_DCSTEXTDEFsome_ext(f(ext2))
    else dcstextdef_DCSTEXTDEFsome_ext(f(ext2)) // no (recognized) prefix
  end // end of [_ when ...]
//
end // end of [dcstextdef_tr]

end // end of [local]

(* ****** ****** *)

implement
s0arg_tr (x) = let
  val res = s0rtopt_tr (x.s0arg_srt ())
in
  s1arg_make (x.s0arg_loc (), x.s0arg_sym (), res)
end // end of [s0arg_tr]

implement
s0arglst_tr (xs) =  glist_map_fun<s0arg,s1arg> (xs, s0arg_tr)

implement
s0marg_tr (x) = let
  val loc = x.s0marg_loc ()
  val arg = s0arglst_tr (x.s0marg_arg ())
in
  s1marg_make (loc, arg)
end // end of [s0marg_tr]

implement
s0marglst_tr (xss) = glist_map_fun<s0marg,s1marg> (xss, s0marg_tr)

(* ****** ****** *)

implement
s0vararg_tr
  (s0v) = case+ s0vararg_view (s0v) of
  | ~S0VARARGseq
      (loc, s0as) => s1vararg_S1VARARGseq (loc, s0arglst_tr s0as)
  | ~S0VARARGone (tok) => s1vararg_S1VARARGone (tok.token_loc ())
  | ~S0VARARGall (tok) => s1vararg_S1VARARGall (tok.token_loc ())
// end of [s0vararg_tr]

implement
s0vararglst_tr (s0vs) = glist_map_fun<s0vararg,s1vararg> (s0vs, s0vararg_tr)

(* ****** ****** *)
//
// HX: translation of static expressions
//
typedef s1expitm = fxitm (s1exp)
typedef s1expitmlst = glist (s1expitm)

(* ****** ****** *)

local

fn appf (
  env: ptr, _fun: s1exp, _arg: s1exp
) : s1expitm = let
  val loc_arg = _arg.s1exp_loc ()
  val loc = _fun.s1exp_loc () + loc_arg
  val xs_arg = (
    case+ s1exp_node_view (_arg.s1exp_node ()) of
    | ~S1Elist(npf, s1es) => s1es // HX: should npf <= 0 be enforced?
    | v => (s1exp_node_view_free (v); list_sing (_arg)) // HX: non-S1Elist
  ) : s1explst // end of [val]
  val s1e_app = s1exp_app (loc, _fun, loc_arg, xs_arg)
in
  fxitm_FXITMatm<s1exp> (s1e_app)
end // end of [appf]

in (* in of [local] *)

fn s1expitm_app
  (loc: location): s1expitm = fxitm_app<s1exp> (loc, @(the_null_ptr, appf))
// end of [s1expitm_app]

end // end of [local]

fn s1exp_get_loc (x: s1exp): location = x.s1exp_loc ()

fn s1exp_make_app
  (loc: location, x: s1exp, loc_arg: location, xs: s1explst): s1exp =
  s1exp_app (loc, x, loc_arg, xs)

fn s1exp_make_opr (
  opr: s1exp, f: fxty
) : s1expitm = begin
  fxopr_make<s1exp> (
    s1exp_get_loc, s1exp_make_app, opr, f
  ) // end of [oper_make]
end // end of [s1exp_make_opr]

fn s1expitm_backslash
  (loc_opr: location): s1expitm = begin
  fxopr_make_backslash<s1exp> (
    s1exp_get_loc, s1exp_make_app, loc_opr
  ) // end of [oper_make_backslash]
end // end of [s1expitm_backslash]

(* ****** ****** *)

fn s0qua_tr
  (s0q: s0qua): s1qua =
  case+ s0qua_node_view (s0q.s0qua_node ()) of
  | ~S0QUAprop (s0p) =>
      s1qua_prop (s0q.s0qua_loc (), s0exp_tr s0p)
  | ~S0QUAvars (
      id, ids, s0te
    ) => (
      s1qua_vars (s0q.s0qua_loc (), glist_cons (id, ids), s0rtext_tr s0te)
    ) // end of [S0QUAvars]
// end of [s0qua_tr]

implement
s0qualst_tr (xs) = glist_map_fun<s0qua,s1qua> (xs, s0qua_tr)
implement
s0qualstlst_tr (xss) = glist_map_fun<s0qualst,s1qualst> (xss, s0qualst_tr)

(* ****** ****** *)
//
// HX: the closures of the prefix/postfix/infix operators of the static
// expressions: the environment is the location [loc0] of the operator
// (and some more data), see [aux_item] below
//
fn
f_invar (knd: int, env: ptr, s1e: s1exp): s1expitm = let
  val loc0 = $UN.cast{location}(env)
  val loc = loc0 + s1e.s1exp_loc ()
in
  fxitm_FXITMatm<s1exp> (s1exp_invar (loc, knd, s1e))
end // end of [f_invar]
//
fn f_invar_ref_r (env: ptr, s1e: s1exp): s1expitm = f_invar (1(*ref:r*), env, s1e)
fn f_invar_ref_w (env: ptr, s1e: s1exp): s1expitm = f_invar (2(*ref:w*), env, s1e)
fn f_invar_ref_rw (env: ptr, s1e: s1exp): s1expitm = f_invar (3(*ref:rw*), env, s1e)
fn f_invar_val (env: ptr, s1e: s1exp): s1expitm = f_invar (0(*val*), env, s1e)
//
fn
f_top (knd: int, env: ptr, s1e: s1exp): s1expitm = let
  val loc0 = $UN.cast{location}(env)
  val loc = s1e.s1exp_loc () + loc0
in
  fxitm_FXITMatm<s1exp> (s1exp_top (loc0, knd, s1e))
end // end of [f_top]
//
fn f_top_0 (env: ptr, s1e: s1exp): s1expitm = f_top (0(*knd*), env, s1e)
fn f_top_1 (env: ptr, s1e: s1exp): s1expitm = f_top (1(*knd*), env, s1e)
//
fn
f_trans (env: ptr, s1e1: s1exp, s1e2: s1exp): s1expitm = let
  val loc = s1e1.s1exp_loc () + s1e2.s1exp_loc ()
in
  fxitm_FXITMatm<s1exp> (s1exp_trans (loc, s1e1, s1e2))
end // end of [f_trans]
//
typedef env_uni = @(location, s1qualst)
//
fn
f_uni (env: ptr, body: s1exp): s1expitm = let
  val e = trans1_env_get<env_uni> (env)
  val loc0 = e.0 and s1qs = e.1
  val loc1 = loc0 + body.s1exp_loc ()
in
  fxitm_FXITMatm<s1exp> (s1exp_uni (loc1, s1qs, body))
end // end of [f_uni]
//
typedef env_exi = @(location, int, s1qualst)
//
fn
f_exi (env: ptr, body: s1exp): s1expitm = let
  val e = trans1_env_get<env_exi> (env)
  val loc0 = e.0 and knd = e.1 and s1qs = e.2
  val loc1 = loc0 + body.s1exp_loc ()
in
  fxitm_FXITMatm<s1exp> (s1exp_exi (loc1, knd, s1qs, body))
end // end of [f_exi]

(* ****** ****** *)

local

fn s0exp_tr_errmsg_opr
  (s0e0: s0exp): s1exp = let
  val loc0 = s0e0.s0exp_loc ()
  val () = prerr_error1_loc (loc0)
  val () = prerrln! (": the operator needs to be applied.")
  val () = the_trans1errlst_add (trans1err_T1E_s0exp_tr(s0e0))
in
  s1exp_err (loc0)
end // end of [s0exp_tr_errmsg_opr]

fn aux_extarg
  (s0e: s0exp): s1explst = let
  val s1e = s0exp_tr (s0e) in
  case+ s1exp_node_view (s1e.s1exp_node ()) of
  | ~S1Elist (_(*npf*), s1es) => s1es
  | v => (s1exp_node_view_free (v); list_sing (s1e))
end // end of [aux_extarg]

in (* in of [local] *)

implement
s0exp_tr s0e0 = let
//
fun
aux_item (
  s0e0: s0exp
) : s1expitm = let
//
val loc0 = s0e0.s0exp_loc ()
//
in
//
case+
s0exp_node_view (s0e0.s0exp_node ())
of (* case+ *)
//
  | ~S0Eide (id) =>
    if id = AMPERSAND then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (invar_prec_sta, @($UN.cast{ptr}(loc0), f_invar_ref_r)))
    else if id = AMPERQMARK then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (invar_prec_sta, @($UN.cast{ptr}(loc0), f_invar_ref_w)))
    else if id = AMPERBANG then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (invar_prec_sta, @($UN.cast{ptr}(loc0), f_invar_ref_rw)))
    else if id = BACKSLASH then s1expitm_backslash (loc0)
    else if id = BANG then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (invar_prec_sta, @($UN.cast{ptr}(loc0), f_invar_val)))
    else if id = QMARK then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpos<s1exp> (qmark_prec_sta, @($UN.cast{ptr}(loc0), f_top_0)))
    else if id = QMARKBANG then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpos<s1exp> (qmarkbang_prec_sta, @($UN.cast{ptr}(loc0), f_top_1)))
    else if id = GTGT then
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRinf<s1exp> (trans_prec_sta, ASSOCnon, @($UN.cast{ptr}(loc0), f_trans)))
    else let
      val s1e =
        s1exp_ide (loc0, id)
      // end of [val]
    in
      case+ the_fxtyenv_find id of
      | ~Some_vt f => s1exp_make_opr (s1e, f)
      | ~None_vt () => fxitm_FXITMatm<s1exp> (s1e)
      // end of [case]
    end // end of [S0Eide]
//
  | ~S0Eopid (id) => fxitm_FXITMatm<s1exp> (s1exp_ide (loc0, id))
  | ~S0Esqid (sq, id) => fxitm_FXITMatm<s1exp> (s1exp_sqid (loc0, sq, id))
//
  | ~S0Eint (int) => fxitm_FXITMatm<s1exp> (s1exp_i0nt (loc0, int))
  | ~S0Echar (char) => fxitm_FXITMatm<s1exp> (s1exp_c0har (loc0, char))
//
  | ~S0Efloat (ftok) => fxitm_FXITMatm<s1exp> (s1exp_f0loat (loc0, ftok))
  | ~S0Estring (stok) => fxitm_FXITMatm<s1exp> (s1exp_s0tring (loc0, stok))
//
  | ~S0Eextype
      (name, s0es) => let
      val s1ess = glist_map_fun<s0exp,s1explst> (s0es, aux_extarg)
    in
      fxitm_FXITMatm<s1exp> (s1exp_extype (loc0, name, s1ess))
    end // end of [S0Eextype]
//
  | ~S0Eextkind
      (name, s0es) => let
      val s1ess = glist_map_fun<s0exp,s1explst> (s0es, aux_extarg)
    in
      fxitm_FXITMatm<s1exp> (s1exp_extkind (loc0, name, s1ess))
    end // end of [S0Eextkind]
//
  | ~S0Eapp (_, _) => let 
      val s1e_app = fixity_resolve<s1exp> (
        loc0, s1exp_get_loc, s1expitm_app (loc0), aux_itemlst s0e0
      ) // end of [val]
    in
      fxitm_FXITMatm<s1exp> (s1e_app)
    end // end of [S0Eapp]
  | ~S0Elam (arg, res, body) => let
      val arg = s0marg_tr arg
      val res = s0rtopt_tr res
      val body = s0exp_tr body
      val s1e_lam = s1exp_lam (loc0, arg, res, body)
    in
      fxitm_FXITMatm<s1exp> (s1e_lam)
    end // end of [S0Elam]
  | ~S0Eimp tags => let
      val
      (
        ofc, lin, prf, efc
      ) = e0fftaglst_tr (tags)
//
      val fc =
      (
        case+ ofc of
        | ~Some_vt(fc) => fc | ~None_vt() => FUNCLOfun () // default is [function]
      ) : funclo // end of [val]
//
      val-
      ~Some_vt(f) =
      the_fxtyenv_find(MINUSGT)
      val s1e_imp = s1exp_imp(loc0, fc, lin, prf, gopt_some efc)
//
    in
      s1exp_make_opr(s1e_imp, f)
    end // end of [S0Eimp]
//
  | ~S0Elist (s0es) => let
      val s1es = s0explst_tr s0es in fxitm_FXITMatm<s1exp> (s1exp_list (loc0, s1es))
    end // end of [S0Elist]
  | ~S0Elist2 (s0es1, s0es2) => let
      val s1es1 = glist_map_loop<s0exp,s1exp> (s0es1, s0exp_tr, list_vt_nil ())
      val s1es2 = glist_map_loop<s0exp,s1exp> (s0es2, s0exp_tr, list_vt_nil ())
    in
      fxitm_FXITMatm<s1exp> (s1exp_list2 (loc0, s1es1, s1es2))
    end // end of [S0Elist2]
//
  | ~S0Etyarr (s0e_elt, s0es_dim) => let
      val s1e_elt = s0exp_tr (s0e_elt)
      val s1es_dim = s0explst_tr (s0es_dim)
    in
      fxitm_FXITMatm<s1exp> (s1exp_tyarr (loc0, s1e_elt, s1es_dim))
    end // end of [S0Etyarr]
  | ~S0Etytup (knd, npf, s0es) => let
      val s1es = s0explst_tr (s0es)
    in
      fxitm_FXITMatm<s1exp> (s1exp_tytup (loc0, knd, npf, s1es))
    end // end of [S0Etytup]
  | ~S0Etyrec (knd, npf, ls0es) => let
      val ls1es = glist_map_fun<labs0exp,labs1exp> (ls0es, labs0exp_tr)
    in
      fxitm_FXITMatm<s1exp> (s1exp_tyrec (loc0, knd, npf, ls1es))
    end // end of [S0Etyrec]
  | ~S0Etyrec_ext (name, npf, ls0es) => let
      val ls1es = glist_map_fun<labs0exp,labs1exp> (ls0es, labs0exp_tr)
    in
      fxitm_FXITMatm<s1exp> (s1exp_tyrec_ext (loc0, name, npf, ls1es))
    end // end of [S0Etyrec]
//
  | ~S0Euni (s0qs) => let
      val s1qs = s0qualst_tr s0qs
      val env = trans1_env_make<env_uni> (@(loc0, s1qs))
    in
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (uni_prec_sta, @(env, f_uni)))
    end // end of [S0Euni]
  | ~S0Eexi
    (
      knd(*funres*), s0qs
    ) => let
      val s1qs = s0qualst_tr s0qs
      val env = trans1_env_make<env_exi> (@(loc0, knd, s1qs))
    in
      fxitm_FXITMopr<s1exp> (loc0, fxopr_FXOPRpre<s1exp> (exi_prec_sta, @(env, f_exi)))
    end // end of [S0Eexi]
//
  | ~S0Eann (s0e, s0t) => let
      val s1t = s0rt_tr (s0t)
      val s1e = s0exp_tr (s0e)
    in
      fxitm_FXITMatm<s1exp> (s1exp_ann (loc0, s1e, s1t))
    end // end of [S0Eann]
//
  | ~S0Ed2ctype (d2ctp) => let
      val d2ctp = S0Ed2ctype_tr(d2ctp)
    in
      fxitm_FXITMatm<s1exp> (s1exp_d2ctype(loc0, d2ctp))
    end // end of [S0Ed2ctype]
//
end // end of [aux_item]
//
and aux_itemlst
  (s0e0: s0exp): s1expitmlst = let
  fun loop (s0e0: s0exp, res: s1expitmlst): s1expitmlst =
    case+ s0exp_node_view (s0e0.s0exp_node ()) of
    | ~S0Eapp (s0e1, s0e2) => let
        val res = glist_cons (aux_item s0e2, res) in loop (s0e1, res)
      end // end of [S0Eapp]
    | v => (s0exp_node_view_free (v); glist_cons (aux_item s0e0, res))
  // end of [loop]
in
  loop (s0e0, glist_nil ())
end // end of [aux_itemlist]
//
in
//
case+ fxitm_view<s1exp> (aux_item (s0e0)) of
| ~FXITMatm (s1e) => s1e
| ~FXITMopr _ => s0exp_tr_errmsg_opr (s0e0)
//
end // end of [s0exp_tr]

end // end of [local]

(* ****** ****** *)

implement
s0explst_tr (xs) = glist_map_fun<s0exp,s1exp> (xs, s0exp_tr)

implement
s0expopt_tr (opt) = case+ gopt_view (opt) of
  | ~GOsome x => gopt_some (s0exp_tr (x)) | ~GOnone () => gopt_none ()
// end of [s0expopt_tr]

(* ****** ****** *)

implement
labs0exp_tr (x) = let
  val l = x.labs0exp_lab () and name = x.labs0exp_nam () and s0e = x.labs0exp_elt ()
in
  labs1exp_make (l, name, s0exp_tr (s0e))
end // end of [labs0exp_tr]

(* ****** ****** *)

implement
s0rtext_tr (s0te) = let
  val loc = s0te.s0rtext_loc () in
//
case+ s0rtext_node_view (s0te.s0rtext_node ()) of
| ~S0TEsrt s0t => s1rtext_srt (loc, s0rt_tr s0t)
| ~S0TEsub (id, s0te, s0p, s0ps) => let
    val s1te = s0rtext_tr s0te
    val s1p = s0exp_tr s0p and s1ps = s0explst_tr s0ps
  in
    s1rtext_sub (loc, id.i0de_sym (), s1te, glist_cons (s1p, s1ps))
  end
//
end // end of [s0rtext_tr]

(* ****** ****** *)

implement
witht0ype_tr (x) = case+ witht0ype_view (x) of
  | ~WITHT0YPEsome (knd, s0e) => witht1ype_WITHT1YPEsome (knd, s0exp_tr (s0e))
  | ~WITHT0YPEnone () => witht1ype_WITHT1YPEnone ()
// end of [witht0ype_tr]

(* ****** ****** *)

implement
q0marg_tr (x) =
  q1marg_make (x.q0marg_loc (), s0qualst_tr (x.q0marg_arg ()))
// end of [q0marg_tr]

implement q0marglst_tr (xs) = glist_map_fun<q0marg,q1marg> (xs, q0marg_tr)

(* ****** ****** *)

implement
i0mparg_tr (x) = case+ i0mparg_view (x) of
  | ~I0MPARG_sarglst (s0as) => i1mparg_sarglst (s0arglst_tr s0as)
  | ~I0MPARG_svararglst (s0vs) => i1mparg_svararglst (s0vararglst_tr s0vs)
// end of [i0mparg_tr]

(* ****** ****** *)

implement
t0mpmarg_tr (x) =
  t1mpmarg_make (x.t0mpmarg_loc (), s0explst_tr (x.t0mpmarg_arg ()))
// end of [t0mpmarg_tr]

(* ****** ****** *)
//
implement
a0typ_tr(x) = let
//
val opt = x.a0typ_sym ()
val s1e = s0exp_tr(x.a0typ_typ ())
//
in
//
case+ gopt_view (opt) of
| ~GOnone() => s1e
| ~GOsome(id) =>
  (
    case+
    s1exp_node_view (s1e.s1exp_node ())
    of (* case+ *)
    | ~S1Elist(npf, s1es) =>
      s1exp_tytup(s1e.s1exp_loc (), 0(*knd*), npf, s1es)
    | v (* non-S1Elist *) => (s1exp_node_view_free (v); s1e)
  )
//
end // end of [a0typ_tr]
//
implement
a0typlst_tr(xs) = glist_map_fun<a0typ,s1exp> (xs, a0typ_tr)
//
(* ****** ****** *)

implement
sp0at_tr (sp0t) = (
  case+ sp0at_node_view (sp0t.sp0at_node ()) of
  | ~SP0Tcstr (qid, s0as) => let
      val s1as = s0arglst_tr s0as in
      sp1at_cstr (sp0t.sp0at_loc (), qid.sqi0de_qua (), qid.sqi0de_sym (), s1as)
    end // end of [SP0Tcon]
) // end of [sp0at_tr]

(* ****** ****** *)

implement
s0exparg_tr
  (loc, s0a) = case+ s0exparg_view (s0a) of
  | ~S0EXPARGone () => s1exparg_one (loc)
  | ~S0EXPARGall () => s1exparg_all (loc)
  | ~S0EXPARGseq (s0as) => s1exparg_seq (loc, s0explst_tr s0as)
// end of [s0exparg_tr]

(* ****** ****** *)
//
// HX: two or more groups of static arguments are merged into one
//
implement
m0acarglst_tr
  (m0as) = let
in
//
case+ glist_view (m0as) of
| ~GLcons
    (m0a, m0as) => let
    val loc = m0a.m0acarg_loc ()
    val m1a = (
      case+ m0acarg_node_view (m0a.m0acarg_node ()) of
      | ~M0ACARGdyn (ids) => m1acarg_make_dyn (loc, ids)
      | ~M0ACARGsta (s0as) => let
          val s1as = s0arglst_tr (s0as) in m1acarg_make_sta (loc, s1as)
        end // end of [M0ACARGsta]
    ) : m1acarg // end of [val]
    val m1as = m0acarglst_tr (m0as)
  in
    case+ m1acarg_node_view (m1a.m1acarg_node ()) of
    | ~M1ACARGdyn _ => glist_cons (m1a, m1as)
    | ~M1ACARGsta (s1as) => (
      case+ glist_view (m1as) of
      | ~GLcons
          (m1a2, m1as2) => (
        case+ m1acarg_node_view (m1a2.m1acarg_node ()) of
        | ~M1ACARGsta (s1as2) => let
            val s1as = glist_append (s1as, s1as2)
            val loc = $LOC.location_combine (loc, m1a2.m1acarg_loc ())
            val m1a = m1acarg_make_sta (loc, s1as)
          in
            glist_cons (m1a, m1as2)
          end // end of [M1ACARGsta]
        | v => (m1acarg_node_view_free (v); glist_cons (m1a, glist_cons (m1a2, m1as2)))
        ) // end of [GLcons]
      | ~GLnil () => list_sing (m1a)
      )
  end // end of [GLcons]
| ~GLnil () => glist_nil ()
//
end // end of [m0acarglst_tr]

(* ****** ****** *)

implement
d0atcon_tr(d0c) = let
//
val sym = d0c.d0atcon_sym ()
val qua = d0c.d0atcon_qua ()
val qua = q0marglst_tr (qua)
//
var npf0: int = ~1 // HX: default
val arg = (
//
case+
gopt_view (d0c.d0atcon_arg ())
of // case+
//
| ~GOsome s0e => let
    val s1e = s0exp_tr s0e
  in
    case+
    s1exp_node_view (s1e.s1exp_node ())
    of // case+
    | ~S1Elist(npf, s1es) => (npf0 := npf; s1es)
    | v (* non-S1Elist *) => (s1exp_node_view_free (v); glist_cons(s1e, glist_nil()))
  end // end of [Some]
//
| ~GOnone((*void*)) => glist_nil()
//
) : s1explst
//
val ind = d0c.d0atcon_ind ()
val ind = (
  case+ gopt_view (ind) of
  | ~GOsome s0e => let
      val s1es = (
        case+ s0exp_node_view (s0e.s0exp_node ()) of
        | ~S0Elist (s0es) => s0explst_tr (s0es)
        | v (*non-S0Elist*) => let
            val () = s0exp_node_view_free (v)
            val () =
              prerr_interror()
            // end of [val]
            val () =
              prerrln!(": d0atcon_tr: index is required to be a list.")
            // end of [val]
          in
            $ERR.abort_interr<s1explst>((*reachable*))
          end // end of [_]
      ) : s1explst // end of [val]
    in
      gopt_some s1es
    end // end of [Some]
  | ~GOnone () => gopt_none () // end of [None]
) : s1explstopt // end of [val]
//
in
  d1atcon_make(d0c.d0atcon_loc (), sym, qua, npf0, arg, ind)
end // end of [d0atcon_tr]

(* ****** ****** *)

local
//
// defining [d0cstdec_tr]
//
fun aux1
(
  d0c: d0cstdec
, fc: funclo, lin: int, prf: int
, efcopt: effcstopt
, fst: int, lst: &int
, xs: d0cstarglst
, s1e_res: s1exp
) : s1exp = begin case+ glist_view (xs) of
  | ~GLcons (x, xs) => begin case+ d0cstarg_node_view (x.d0cstarg_node ()) of
    | ~D0CSTARGdyn
        (npf, ys) => let
        val loc_x = x.d0cstarg_loc ()
        val s1e_arg = s1exp_npf_list (loc_x, npf, a0typlst_tr ys)
        val s1e_res = aux1 (d0c, fc, lin, prf, efcopt, fst+1, lst, xs, s1e_res)
        val loc_res = s1e_res.s1exp_loc ()
        val loc = loc_x + loc_res
        val fc = (if fst > 0 then FUNCLOcloref else fc): funclo
        val imp = (
          if lst > 0 then begin
            s1exp_imp (loc_res, fc, 0, 0, gopt_none ())
          end else begin
            s1exp_imp (loc_res, fc, lin, prf, efcopt)
          end // end of [if]
        ) : s1exp // end of [val]
        val () = lst := lst + 1
      in
        s1exp_app (loc, imp, loc, glist_cons (s1e_arg, glist_cons (s1e_res, glist_nil ())))
      end // end of [D0CSTARGdyn2]
    | ~D0CSTARGsta (s0qs) => let
        val loc_x = x.d0cstarg_loc ()
        val s1qs = s0qualst_tr s0qs
        val s1e_res = aux1 (d0c, fc, lin, prf, efcopt, fst, lst, xs, s1e_res)
        val loc_res = s1e_res.s1exp_loc ()
        val loc = loc_x + loc_res
//
        var err: int = 0
        val () = (if gopt_is_some (efcopt) then
          (if lst = 0 then (err := err + 1))
        ) : void // end of [val]
        val () = if err > 0 then let
          val () = prerr_error1_loc (loc)
          val () = prerrln! (": illegal use of effect annotation")
          val () = the_trans1errlst_add (trans1err_T1E_d0cstdec_tr(d0c))
        in
          // nothing
        end // end of [val]
//
      in
        s1exp_uni (loc, s1qs, s1e_res)
      end (* end of [D0CSTARGsta] *)
    end (* end of [::] *)
  | ~GLnil () => s1e_res // end of [nil]
end // end of [aux1]
//
fun aux2 (
    d0c: d0cstdec
  , isfun: bool
  , isprf: bool
  , xs: d0cstarglst
  , otags: gopt(e0fftaglst)
  , s1e_res: s1exp
  ) : s1exp = let
  var fc: funclo = FUNCLOfun ()
  var lin: int = 0 and prf: int = (if isprf then 1 else 0): int
  var efcopt: effcstopt = gopt_none ()
  val () = case+ gopt_view (otags) of
    | ~GOsome tags => let
        val (ofc1, lin1, prf1, efc1) = e0fftaglst_tr (tags)
        val () = case+ ofc1 of
          | ~Some_vt fc1 => fc := fc1 | ~None_vt () => ()
        // end of [val]
      in
        lin := lin1; prf := prf + prf1; efcopt := gopt_some efc1
      end // end of [Some]
    | ~GOnone () => () // end of [None]
  // end of [val]
  val () = (if funclo_is_clo (fc) then let
        val knd = funclo_get_clokind (fc)
      in
        if knd <> CLOREF then let
//
          val loc0 = d0c.d0cstdec_loc ()
          val () = prerr_error1_loc (loc0)
          val () =
          if knd = 0 then {
            val () = prerr ": a closure struct is not allowed at the toplevel."
          } // end of [val]
          val () =
          if knd = 1 then {
            val () = prerr ": a closure pointer is not allowed at the toplevel."
          } // end of [val]
          val () = prerr_newline ()
          val () = the_trans1errlst_add (trans1err_T1E_d0cstdec_tr (d0c))
//
        in
          // nothing
        end // end of [if]
      end // end of [FUNCLOclo]
  ) : void
  var lst: int = 0
in
  aux1 (d0c, fc, lin, prf, efcopt, 0, lst, xs, s1e_res)
end // end of [aux2]
//
fn d0cstdec_tr
(
  isfun: bool, isprf: bool, d0c: d0cstdec
) : d1cstdec = let
  val loc = d0c.d0cstdec_loc ()
//
// HX; [fil] should be the includer instead of includee
//
  val sym = d0c.d0cstdec_sym ()
  val fil = $FIL.filename_get_current ()
  val s1e_res = s0exp_tr (d0c.d0cstdec_res ())
  val arg = d0c.d0cstdec_arg () and eff = d0c.d0cstdec_eff ()
  val s1e = aux2 (d0c, isfun, isprf, arg, eff, s1e_res)
  val extdef = dcstextdef_tr (d0c, sym, d0c.d0cstdec_extopt ())
in
  d1cstdec_make (loc, fil, sym, s1e, extdef)
end // end of [d0cstdec_tr]
//
in (* in of [local] *)

implement
d0cstdeclst_tr
(
  isfun, isprf, ds
) = case+ glist_view (ds) of
  | ~GLnil () =>
    glist_nil ()
  | ~GLcons (d, ds) => let
      val d = d0cstdec_tr (isfun, isprf, d)
      val ds = d0cstdeclst_tr (isfun, isprf, ds)
    in
      glist_cons (d, ds)
    end // end of [list_cons]
// end of [d0cstdeclst_tr]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans1_staexp.dats] *)
