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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_e0xp.dats)
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

#include "./mylibies.hats"
#include "./pats_trans1.hats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"
staload LOC = "./pats_location.sats"
overload + with $LOC.location_combine
//
staload SYM = "./pats_symbol.sats"
//
macdef BACKSLASH = $SYM.symbol_BACKSLASH
//
overload = with $SYM.eq_symbol_symbol
//
(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_e0xp"

(* ****** ****** *)

staload "./pats_lexing.sats"

(* ****** ****** *)

staload "./pats_fixity.sats"
staload _(*anon*) = "./pats_fixity_fxty.dats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"
staload "./pats_trans1_env.sats"

(* ****** ****** *)

staload "./pats_e1xpval.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

macdef list_sing (x) = glist_sing (,(x))

(* ****** ****** *)

fn do_exit (code: int): void = $extfcall (void, "exit", code)

(* ****** ****** *)

local

fun
do_e0xpact_fprint
(
  out: FILEref, v0: v1al
) : void =
(
//
case+ v1al_view (v0) of
//
| ~V1ALint i => fprint_int(out, i)
//
| ~V1ALchar c => fprint_char(out, c)
//
| ~V1ALfloat f => fprint_double(out, f)
//
| ~V1ALstring s => fprint_string(out, s)
//
| ~V1ALerr () => let
    val () = assertloc(false) in (*deadcode*)
  end (* end of [V1ALerr] *)
//
) (* end of [do_e0xpact_fprint] *)

in (* in-of-local *)

implement
do_e0xpact_prerr(v) = do_e0xpact_fprint(stderr_ref, v)
implement
do_e0xpact_print(v) = do_e0xpact_fprint(stdout_ref, v)

end // end of [local]

(* ****** ****** *)

implement
do_e0xpact_error
  (loc, v) = let
//
  val () = prerr_error1_loc (loc)
  val () = prerr ": [#error] directive is encountered: "
//
  val () = (case+ v1al_view (v) of
    | ~V1ALint i => prerr i
    | ~V1ALchar c => prerr c
    | ~V1ALstring s => prerr s
    | ~V1ALfloat f => prerr f
    | ~V1ALerr () => let
        val () = assertloc (false) in (*deadcode*)
      end (* end of [V1ALerr] *)
  ) : void // end of [val]
in
  do_exit (1)
end // end of [do_e0xpact_error]

(* ****** ****** *)

implement
do_e0xpact_assert
  (loc, v) = let
  val is_false = (
    case+ v1al_view (v) of
    | ~V1ALint i => i = 0
    | ~V1ALstring s => let
        val s = g1ofg0 s in string_is_empty s
      end // end of [V1ALstring]
    | ~V1ALfloat f => f = 0.0
    | ~V1ALchar c => c = '\000'
    | ~V1ALerr () => let
        val () = assertloc (false) in false // HX: this should be deadcode!
      end (* end of [V1ALerr] *)
  ) : bool // end of [val]
in
  if is_false then let
    val () = prerr_error1_loc loc
    val () = prerr ": [#assert] failed!"
    val () = prerr_newline ()
  in
    do_exit (1)
  end // end of [if]
end // end of [do_e0xpact_assert]

(* ****** ****** *)
//
// HX: translation of sorts
//
typedef e1xpitm = fxitm (e1xp)
typedef e1xpitmlst = glist (e1xpitm)

(* ****** ****** *)

local

fn appf (
  env: ptr, _fun: e1xp, _arg: e1xp
) : e1xpitm = let
  val loc_fun = _fun.e1xp_loc ()
  val loc_arg = _arg.e1xp_loc ()
  val loc = loc_fun + loc_arg
  val xs_arg = (
    case+ e1xp_node_view (_arg.e1xp_node ()) of
    | ~E1XPlist xs => xs | v => (e1xp_node_view_free (v); list_sing (_arg))
  ) : e1xplst // end of [val]
  val _app = e1xp_app (loc, _fun, loc_arg, xs_arg)
in
  fxitm_FXITMatm<e1xp> (_app)
end // end of [appf]

in (* in of [local] *)

fn e1xpitm_app
  (loc: location): e1xpitm = fxitm_app<e1xp> (loc, @(the_null_ptr, appf))
// end of [e1xpitm]

end // end of [local]

(* ****** ****** *)

fn e1xp_get_loc (x: e1xp): location = x.e1xp_loc ()

fn e1xp_make_app
  (loc: location, x: e1xp, loc_arg: location, xs: e1xplst): e1xp =
  e1xp_app (loc, x, loc_arg, xs)

fn e1xp_make_opr (
  opr: e1xp, f: fxty
) : e1xpitm = (
  fxopr_make<e1xp> (
    e1xp_get_loc, e1xp_make_app, opr, f
  ) // end of [e1xp_make_opr]
) (* end of [e1xp_make_opr] *)

fn e1xpitm_backslash
  (loc_opr: location): e1xpitm = (
  fxopr_make_backslash<e1xp> (
    e1xp_get_loc, e1xp_make_app, loc_opr
  ) // end of [fxopr_make_backslash]
) (* end of [e1xpitm_backslash] *)

(* ****** ****** *)

local

fn e0xp_tr_errmsg_opr
  (e0: e0xp): e1xp = let
  val loc0 = e0.e0xp_loc ()
  val () = prerr_error1_loc (loc0)
  val () = prerr ": the operator needs to be applied."
  val () = prerr_newline ()
  val () = the_trans1errlst_add (trans1err_T1E_e0xp_tr (e0))
in
  e1xp_err (loc0)
end // end of [e0xp_tr_errmsg_opr]

fn e0xp_tr_errmsg_float
  (e0: e0xp): void = let
  val () = prerr_error1_loc (e0.e0xp_loc ())
  val () = prerr ": the floating point number is required to be of base 10."
  val () = prerr_newline ()
  val () = the_trans1errlst_add (trans1err_T1E_e0xp_tr (e0))
in
  // nothing
end // end of [e0xp_tr_errmsg_float]

//
// HX: the payload of the tokens of an integer / a floating point number
//
fn token_int_rep (tok: token): string =
  case+ token_node_view (tok.token_node ()) of
  | ~T_INT (base, rep, sfx) => rep
  | v => (token_node_view_free (v); (assertloc(false); ""))
fn token_float_base (tok: token): int =
  case+ token_node_view (tok.token_node ()) of
  | ~T_FLOAT (base, rep, sfx) => base
  | v => (token_node_view_free (v); (assertloc(false); 0))
fn token_float_rep (tok: token): string =
  case+ token_node_view (tok.token_node ()) of
  | ~T_FLOAT (base, rep, sfx) => rep
  | v => (token_node_view_free (v); (assertloc(false); ""))

in (* in of [local] *)

implement e0xp_tr (e0) = let
//
fun aux_item (e0: e0xp): e1xpitm = let
  val loc0 = e0.e0xp_loc () in case+ e0xp_node_view (e0.e0xp_node ()) of
//
  | ~E0XPide id =>
    if id = BACKSLASH then e1xpitm_backslash (loc0)
    else let
      val opt = the_fxtyenv_find (id)
    in
      case+ opt of
      | ~None_vt () => fxitm_FXITMatm<e1xp> (e1xp_ide (loc0, id))
      | ~Some_vt (fxty) => let
          val e = e1xp_ide (loc0, id) in e1xp_make_opr (e, fxty)
        end // end of [Some_vt]
    end // E0XPide(non-backslash)
//
  | ~E0XPint (x) => let
      val rep = token_int_rep (x)
    in
      fxitm_FXITMatm<e1xp> (e1xp_intrep (loc0, rep))
    end // end of [E0XPint]
//
  | ~E0XPchar (x) => let
      val c = token_char_get (x)
    in
      fxitm_FXITMatm<e1xp> (e1xp_char (loc0, c))
    end // end of [E0XPchar]
//
  | ~E0XPstring (x) => let
      val str = token_string_get (x)
    in
      fxitm_FXITMatm<e1xp> (e1xp_string (loc0, str))
    end // end of [E0XPstring]
  | ~E0XPstringid (str) => fxitm_FXITMatm<e1xp> (e1xp_string (loc0, str))
//
  | ~E0XPfloat (x) => let
      val base = token_float_base (x)
      val rep = token_float_rep (x)
      val () = if base != 10 then e0xp_tr_errmsg_float (e0)
    in
      fxitm_FXITMatm<e1xp> (e1xp_float (loc0, rep))
    end // end of [E0XPfloat]
//
  | ~E0XPlist (es) =>
      fxitm_FXITMatm<e1xp> (e1xp_list (loc0, e0xplst_tr (es)))
//
  | ~E0XPapp (_, _) => let
      val e0_new =
      fixity_resolve<e1xp> (
        loc0, e1xp_get_loc, e1xpitm_app (loc0), aux_itemlst e0
      ) // end of [val]
    in
      fxitm_FXITMatm<e1xp> (e0_new)
    end // end of [E0XPapp]
//
  | ~E0XPfun (arg, body) =>
      fxitm_FXITMatm<e1xp> (e1xp_fun (loc0, arg, e0xp_tr (body)))
//
  | ~E0XPif (
      e0_cond, e0_then, e0_else
    ) => let
      val e1_cond = e0xp_tr (e0_cond)
      val e1_then = e0xp_tr (e0_then)
      val e1_else = (
        case+ gopt_view (e0_else) of ~GOsome x => e0xp_tr (x) | ~GOnone () => e1xp_none (loc0)
      ) : e1xp (* end of [val] *)
    in
      fxitm_FXITMatm<e1xp> (e1xp_if (loc0, e1_cond, e1_then, e1_else))
    end // end of [E0Xpif]
//
  | ~E0XPeval (e0) => let
      val e1 = e0xp_tr (e0)
      val v1 = e1xp_valize (e1)
    in
      fxitm_FXITMatm<e1xp> (e1xp_v1al (loc0, v1))
    end // end of [E0XPeval]
//
end // end of [aux_item]
//
and aux_itemlst
  (e0: e0xp): e1xpitmlst = let
  fun loop (
    e0: e0xp, res: e1xpitmlst
  ) : e1xpitmlst =
    case+ e0xp_node_view (e0.e0xp_node ()) of
    | ~E0XPapp (e1, e2) => let
        val res = glist_cons (aux_item e2, res) in loop (e1, res)
      end (* end of [E0XPapp] *)
    | v => (e0xp_node_view_free (v); glist_cons (aux_item e0, res))
  // end of [loop]
in
  loop (e0, glist_nil ())
end // end of [aux_itemlst]
//
in
//
case+
fxitm_view<e1xp> (aux_item(e0))
of // case+
| ~FXITMatm (e) => e
| ~FXITMopr _ => e0xp_tr_errmsg_opr (e0)
//
end // end of [e0xp_tr]

end // end of [local]

implement
e0xplst_tr (es) = glist_map_fun<e0xp,e1xp> (es, e0xp_tr)

(* ****** ****** *)

(* end of [pats_trans1_e0xp.dats] *)
