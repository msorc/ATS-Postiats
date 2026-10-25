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
// HX-2026-10: no GC (ATS2 port of src/pats_e1xpval.dats, see PORTING.md)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload "./pats_basics.sats"
//
macdef isdebug () = (debug_flag_get () > 0)
//
(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload LOC = "./pats_location.sats"
macdef prerr_location = $LOC.prerr_location
staload SYM = "./pats_symbol.sats"
//
macdef NEG = $SYM.symbol_NEG
//
macdef ADD = $SYM.symbol_ADD
macdef SUB = $SYM.symbol_SUB
macdef MUL = $SYM.symbol_MUL
macdef DIV = $SYM.symbol_DIV
//
macdef LT = $SYM.symbol_LT
macdef LTEQ = $SYM.symbol_LTEQ
macdef GT = $SYM.symbol_GT
macdef GTEQ = $SYM.symbol_GTEQ
//
macdef EQ = $SYM.symbol_EQ
macdef EQEQ = $SYM.symbol_EQEQ
macdef LTGT = $SYM.symbol_LTGT
macdef BANGEQ = $SYM.symbol_BANGEQ
//
macdef LAND = $SYM.symbol_LAND
macdef LOR = $SYM.symbol_LOR
//
macdef LTLT = $SYM.symbol_LTLT
macdef GTGT = $SYM.symbol_GTGT
macdef DEFINED = $SYM.symbol_DEFINED
macdef UNDEFINED = $SYM.symbol_UNDEFINED
//
overload = with $SYM.eq_symbol_symbol

(* ****** ****** *)

staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_trans1_env.sats"
staload "./pats_e1xpval.sats"

(* ****** ****** *)

#include "./pats_e1xpval_gen_dats.hats"

(* ****** ****** *)

#define MAX_VALIZE_LEVEL 99
#define MAX_NORMAL_LEVEL 99

(* ****** ****** *)

fun
prerr_error1_loc
  (loc: location): void = (
  $LOC.prerr_location loc; prerr ": error(1)"
) // end of [prerr_error1_loc]

(* ****** ****** *)
//
// HX: a [v1al] is read through its tag (no linear view is made)
//
fn v1al_int_get (v: v1al): int =
  case+ v1al_view(v) of ~V1ALint(i) => i | v => (v1al_view_free(v); 0)
fn v1al_float_get (v: v1al): double =
  case+ v1al_view(v) of ~V1ALfloat(f) => f | v => (v1al_view_free(v); 0.0)
fn v1al_string_get (v: v1al): string =
  case+ v1al_view(v) of ~V1ALstring(s) => s | v => (v1al_view_free(v); "")
fn v1al_char_get (v: v1al): char =
  case+ v1al_view(v) of ~V1ALchar(c) => c | v => (v1al_view_free(v); '\000')

fn mkint (i: int): v1al = v1al_V1ALint (i)
fn mkerr (): v1al = v1al_V1ALerr ()

(* ****** ****** *)

implement
v1al_is_err (v) = v1al_is_V1ALerr (v)

implement
v1al_is_true (v) = let
in
//
if v1al_is_V1ALint (v) then (v1al_int_get (v) <> 0) // most common
else if v1al_is_V1ALchar (v) then (v1al_char_get (v) <> '\000')
else if v1al_is_V1ALstring (v) then string_isnot_empty (g1ofg0 (v1al_string_get (v))) // 2nd most common
else if v1al_is_V1ALfloat (v) then (v1al_float_get (v) <> 0.0)
else false // V1ALerr
//
end // end of [v1al_is_true]

implement v1al_is_false (v) = ~v1al_is_true(v)

(* ****** ****** *)
//
extern
fun e1xplev_valize (lev: int, e0: e1xp) : v1al
//
extern fun e1xp_valize_defined (e0: e1xp) : v1al
extern fun e1xp_valize_undefined (e0: e1xp) : v1al
//
(* ****** ****** *)

implement
e1xp_valize
  (e) = res where {
  val res = e1xplev_valize (0(*lev*), e)
  val ((*void*)) =
  (
    if v1al_is_V1ALerr (res) then {
      val () = fprint_the_valerrlst (stderr_ref)
      val () = $ERR.abort<void> ()
    } (* end of [V1ALerr] *)
  ) : void // end of [val]
} (* end of [e1xp_valize] *)

implement
e1xp_valize_if (knd, e) =
  case+ knd of
  | SRPIFKINDif () => e1xp_valize (e)
  | SRPIFKINDifdef () => e1xp_valize_defined (e)
  | SRPIFKINDifndef () => e1xp_valize_undefined (e)
// end of [e1xp_valize_if]

(* ****** ****** *)

implement
e1xp_valize_defined
  (e) = let
  val node = e.e1xp_node ()
in
  case+ e1xp_node_view (node) of
  | ~E1XPide id => mkint (i) where {
      val i = (case+ the_e1xpenv_find id of
        | ~Some_vt e => (
            if e1xp_node_is_E1XPundef (e.e1xp_node ()) then 0 else 1
          ) // end of [Some_vt]
        | ~None_vt () => 0
      ) : int // end of [val]
    } // end of [E1XPide]
  | v => mkerr () where {
      val () = e1xp_node_view_free (v)
      val () = the_valerrlst_add (valerr_VE_valize_defined (e))
    } // end of [_]
end // end of [e1xp_valize_defined]

implement
e1xp_valize_undefined
  (e) = let
  val node = e.e1xp_node ()
in
  case+ e1xp_node_view (node) of
  | ~E1XPide id => mkint (i) where {
      val i = (case+ the_e1xpenv_find id of
        | ~Some_vt e => (
            if e1xp_node_is_E1XPundef (e.e1xp_node ()) then 1 else 0
          ) // end of [Some_vt]
        | ~None_vt () => 1
      ) : int // end of [val]
    } // end of [E1XPide]
  | v => mkerr () where {
      val () = e1xp_node_view_free (v)
      val () = the_valerrlst_add (valerr_VE_valize_undefined (e))
    } // end of [_]
end // end of [e1xp_valize_undefined]

(* ****** ****** *)
//
// HX-2026-10: the local environments [lenv] (an abstract linear list in
// ATS1) are plain linear lists of pairs; the comparison closure of
// [list_assoc_fun] is the function [eq_symbol_symbol]
//
vtypedef lenv (a:type) = List0_vt (@(symbol, a))
//
fn{a:type}
lenvmake_nil (): lenv (a) = list_vt_nil ()
fn{a:type}
lenvfree (env: lenv (a)): void = list_vt_free<@(symbol, a)> (env)
//
fun{a:type}
lenvfind (env: !lenv (a), x: symbol): Option_vt (a) =
  case+ env of
  | @list_vt_cons (kv, env1) => let
      val k = kv.0 and v = kv.1
    in
      if $SYM.eq_symbol_symbol (k, x)
        then (fold@ env; Some_vt (v))
        else let
          val ans = lenvfind<a> (env1, x) in fold@ env; ans
        end // end of [else]
    end // end of [list_vt_cons]
  | list_vt_nil () => None_vt ()
// end of [lenvfind]
//
(* ****** ****** *)

vtypedef vlenv = lenv (v1al)

fun
lenvmake_v1alist
  (xs: symbolist, vs: !List0_vt (v1al)): vlenv =
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) => (
    case+ vs of
    | @list_vt_cons (v, vs1) => let
        val v0 = v
        val res = lenvmake_v1alist (xs1, vs1)
        prval () = fold@ (vs)
      in
        list_vt_cons ((x, v0), res)
      end // end of [list_vt_cons]
    | list_vt_nil () => let
        val v = mkint (0)
      in
        list_vt_cons ((x, v), lenvmake_v1alist (xs1, vs))
      end // end of [list_nil]
    ) (* end of [GLcons] *)
  | ~GLnil () => list_vt_nil ()
// end of [lenvmake_v1alist]

(* ****** ****** *)

vtypedef elenv = lenv (e1xp)

fun
lenvmake_e1xplst
  (lorg: location, xs: symbolist, es: e1xplst): elenv =
  case+ glist_view (xs) of
  | ~GLcons (x, xs1) => (
    case+ glist_view (es) of
    | ~GLcons (e, es1) =>
        list_vt_cons ((x, e), lenvmake_e1xplst (lorg, xs1, es1))
    | ~GLnil () => let
        val e = e1xp_none (lorg)
      in
        list_vt_cons ((x, e), lenvmake_e1xplst (lorg, xs1, es))
      end // end of [list_nil]
    ) (* end of [GLcons] *)
  | ~GLnil () => list_vt_nil ()
// end of [lenvmake_e1xplst]

(* ****** ****** *)

fn e1xp_valize_int
  (rep: string): int = let
  val x = $UT.llint_make_string (rep) in $UN.cast{int} (x)
end // end of [e1xp_valize_int]

(* ****** ****** *)

fn e1xplevenv_valize_ide (
  lev: int, env: !vlenv, e0: e1xp, x: symbol
) : v1al = let
  val ans = lenvfind<v1al> (env, x)
in
//
case+ ans of
| ~Some_vt v => v
| ~None_vt _ => (
  case+ the_e1xpenv_find (x) of
  | ~Some_vt e => e1xplev_valize (lev+1, e)
  | ~None_vt _ => mkerr () where {
      val () = the_valerrlst_add (valerr_VE_E1XPide_unbound (e0))
    } // end of [None_vt]
  ) (* end of [None_vt] *)
end // end of [e1xplevenv_valize_ide]

(* ****** ****** *)

extern
fun e1xplevenv_valize (lev: int, env: !vlenv, e0: e1xp): v1al
extern
fun e1xplevenv_valize_main (lev: int, env: !vlenv, e0: e1xp): v1al

(* ****** ****** *)

fun
e1xplstlevenv_valize
(
  lev: int, env: !vlenv, es: e1xplst
) : List0_vt (v1al) =
  case+ glist_view (es) of
  | ~GLcons (e, es) => let
      val v = e1xplevenv_valize (lev, env, e)
      val vs = e1xplstlevenv_valize (lev, env, es)
    in
      list_vt_cons (v, vs)
    end
  | ~GLnil () => list_vt_nil ()
// end of [e1xplstlevenv_valist]

(* ****** ****** *)

fun
e1xplevenv_valize_list
(
  lev: int, env: !vlenv, e0: e1xp, es: e1xplst
) : v1al = case+ glist_view (es) of
  | ~GLcons (e, es) => (
    if glist_is_nil (es)
      then e1xplevenv_valize (lev, env, e)
      else mkerr () where {
        val () = the_valerrlst_add (valerr_VE_E1XPlist (e0))
      } // end of [list_cons]
    ) (* end of [list_cons] *)
  | ~GLnil () => mkint (0)
// end of [e1xplevenv_valist_list]

(* ****** ****** *)

extern
fun
e1xplevenv_valize_delta
(
  lev: int, env: !vlenv, e0: e1xp, id: symbol, es: e1xplst
) : v1al // end of [e1xplevenv_valize_delta]

(* ****** ****** *)

fn
v1alist_exists_err (vs: !List0_vt (v1al)): bool = let
  fun loop (vs: !List0_vt (v1al)): bool =
    case+ vs of
    | @list_vt_cons (v, vs1) => let
        val iserr = v1al_is_err (v)
      in
        if iserr then (fold@ (vs); true)
        else let val res = loop (vs1) in fold@ (vs); res end
      end
    | list_vt_nil () => false
in
  loop (vs)
end // end of [v1alist_exists_err]

fun
e1xplevenv_valize_appid
(
  lev: int, env: !vlenv, e0: e1xp, id: symbol, es: e1xplst
) : v1al = let
  val opt = the_e1xpenv_find (id)
in
//
case+ opt of
| ~Some_vt e => (
  case+ e1xp_node_view (e.e1xp_node ()) of
//
  | ~E1XPide (id) =>
      e1xplevenv_valize_appid (lev+1, env, e, id, es)
    // end of [E1XPide]
//
  | ~E1XPfun (xs, body) => res where {
      val vs = e1xplstlevenv_valize (lev, env, es)
//
      val env1 = lenvmake_v1alist (xs, vs)
      val iserr = // HX: it is only need if err = 0 holds
        v1alist_exists_err (vs)
      // end of [val]
      val () = list_vt_free (vs)
//
      val res = (
        if iserr then
          mkerr () else e1xplevenv_valize (lev+1, env1, body)
        // end of [if]
      ) : v1al // end of [if]
//
      val () = lenvfree<v1al> (env1)
//
    } // end of [E1XPfun]
  | v => mkerr () where {
      val () = e1xp_node_view_free (v)
      val () = the_valerrlst_add (valerr_VE_E1XPappid_fun (e0, id))
    } // end of [_]
  ) (* end of [Some_vt] *)
| ~None_vt () => e1xplevenv_valize_delta (lev, env, e0, id, es)
//
end // end of [e1xplevenv_valize_appid]

(* ****** ****** *)

implement
e1xplev_valize
  (lev, e0) = res where {
  val env = lenvmake_nil<v1al> ()
  val res = e1xplevenv_valize (lev, env, e0)
  val () = lenvfree<v1al> (env)
} // end of [e1xplev_valize]

(* ****** ****** *)

implement
e1xplevenv_valize
  (lev, env, e0) = let
//
#define MAXLEV MAX_VALIZE_LEVEL
//
in
//
if lev <= MAXLEV then let
  val res = e1xplevenv_valize_main (lev, env, e0)
  val () = (
    if v1al_is_V1ALerr (res) then the_valerrlst_add (valerr_VE_valize (e0))
  ) : void // end of [val]
in
  res
end else let
  val () = the_valerrlst_add (valerr_VE_maxlevel (lev, e0))
in
  mkerr ()
end // end of [if]
//
end // end of [e1xplevenv_valize]

implement
e1xplevenv_valize_main
  (lev, env, e0) = let
  val loc0 = e0.e1xp_loc ()
in
//
case+ e1xp_node_view (e0.e1xp_node ()) of
| ~E1XPide (sym) =>
    e1xplevenv_valize_ide (lev, env, e0, sym)
//
| ~E1XPint (i) => mkint (i)
| ~E1XPintrep (rep) => let
    val v = e1xp_valize_int (rep) in mkint (v)
  end // end of [E1XPi0nt]
| ~E1XPchar (x) => v1al_V1ALchar (x)
| ~E1XPstring (x) => v1al_V1ALstring (x)
| ~E1XPfloat (x) => v1al_V1ALfloat (g0string2float_double (x))
//
| ~E1XPv1al (v) => v
//
| ~E1XPnone () => mkint (0)
//
| ~E1XPundef () => let
    val () =
      the_valerrlst_add (valerr_VE_E1XPundef (e0)) in mkerr ()
    // end of [val]
  end // end of [E1XPundef]
//
| ~E1XPapp
  (
    e_fun, _(*loc_arg*), es_arg
  ) => (
    case+
    e1xp_node_view (e_fun.e1xp_node ()) of
    | ~E1XPide id => (
        e1xplevenv_valize_appid (lev, env, e0, id, es_arg)
     ) // end of [E1XPide]
    | v (*non-ide*) => let
        val () = e1xp_node_view_free (v)
        val () =
          the_valerrlst_add (valerr_VE_E1XPapp_fun (e0)) in mkerr ()
        // end of [val]
      end (* end of [_] *)
  ) (* end of [E1XPapp] *)
//
| ~E1XPif (_cond, _then, _else) => let
    val _cond =
      e1xplevenv_valize (lev, env, _cond)
    // end of [val]
  in
    if v1al_is_V1ALerr (_cond) then mkerr ()
    else let
        val _taken = (
          if v1al_is_true (_cond) then _then else _else
        ) : e1xp // end of [val]
      in
        e1xplevenv_valize (lev, env, _taken)
      end (* end of [non-V1ALerr] *)
  end
//
| ~E1XPlist (es) =>
    e1xplevenv_valize_list (lev, env, e0, es)
  // end of [E1XPlist]
//
| ~E1XPeval (e1) => e1xplevenv_valize (lev, env, e1) // HX: right?
//
| ~E1XPfun _ => mkerr () where {
    val () = the_valerrlst_add (valerr_VE_E1XPfun (e0))
  }
//
| ~E1XPerr () => mkerr () where {
    val () = the_valerrlst_add (valerr_VE_E1XPerr (e0))
  }
//
end // end of [e1xplevenv_valize_main]

(* ****** ****** *)
//
// HX: the binary operators evaluate both arguments first
//
macdef oprerr (e0, id) = mkerr () where {
  val () = the_valerrlst_add (valerr_VE_opr_arglst (,(e0), ,(id)))
} // end of [oprerr]

fn
e1xplevenv_valize_neg
(
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
in
  if v1al_is_V1ALint (v1) then mkint (~(v1al_int_get (v1)))
  else if v1al_is_V1ALfloat (v1) then v1al_V1ALfloat (~(v1al_float_get (v1)))
  else oprerr (e0, id) // non-number
end // end of [e1xplevenv_valize_neg]

(* ****** ****** *)

fn
e1xplevenv_valize_add
(
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then mkint (v1al_int_get (v1) + v1al_int_get (v2))
  else if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then v1al_V1ALfloat (v1al_float_get (v1) + v1al_float_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then let
      val s12 = string0_append (v1al_string_get (v1), v1al_string_get (v2))
      val s12_ = the_garena_strdup ($UN.strptr2string (s12))
      val () = strptr_free (s12)
    in
      v1al_V1ALstring (s12_)
    end
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_add]

fn
e1xplevenv_valize_sub
(
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then mkint (v1al_int_get (v1) - v1al_int_get (v2))
  else if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then v1al_V1ALfloat (v1al_float_get (v1) - v1al_float_get (v2))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_sub]

fn
e1xplevenv_valize_mul
(
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then mkint (v1al_int_get (v1) * v1al_int_get (v2))
  else if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then v1al_V1ALfloat (v1al_float_get (v1) * v1al_float_get (v2))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_mul]

fn
e1xplevenv_valize_div
(
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then mkint (g0int_div (v1al_int_get (v1), v1al_int_get (v2)))
  else if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then v1al_V1ALfloat (v1al_float_get (v1) / v1al_float_get (v2))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_div]

(* ****** ****** *)

fn b2v (b: bool): v1al = if b then mkint (1) else mkint (0)

fn e1xplevenv_valize_lt (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then b2v (v1al_float_get (v1) < v1al_float_get (v2))
  else if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) < v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (lt_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_lt]

fn e1xplevenv_valize_lteq (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then b2v (v1al_float_get (v1) <= v1al_float_get (v2))
  else if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) <= v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (lte_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_lteq]

fn e1xplevenv_valize_gt (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then b2v (v1al_float_get (v1) > v1al_float_get (v2))
  else if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) > v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (gt_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_gt]

fn e1xplevenv_valize_gteq (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALfloat (v1) andalso v1al_is_V1ALfloat (v2)
    then b2v (v1al_float_get (v1) >= v1al_float_get (v2))
  else if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) >= v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (gte_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_gteq]

(* ****** ****** *)

fn e1xplevenv_valize_eq (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) = v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (eq_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_eq]

fn e1xplevenv_valize_neq (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2)
    then b2v (v1al_int_get (v1) <> v1al_int_get (v2))
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2)
    then b2v (neq_string_string (v1al_string_get (v1), v1al_string_get (v2)))
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_neq]

(* ****** ****** *)

fn e1xplevenv_valize_land (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2) then begin
      if v1al_int_get (v1) = 0 then mkint 0
      else if v1al_int_get (v2) = 0 then mkint 0
      else mkint 1
    end // end of [V1ALint, V1ALint]
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2) then let
      val s1 = v1al_string_get (v1) and s2 = v1al_string_get (v2)
    in
      if string_is_empty (g1ofg0 s1) then mkint (0)
      else if string_is_empty (g1ofg0 s1) then mkint (0) // HX: sic (see ATS1)
      else mkint 1
    end // end of [V1ALstring, V1ALstring]
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_land]

fn e1xplevenv_valize_lor (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2) then begin
      if v1al_int_get (v1) <> 0 then mkint 1
      else if v1al_int_get (v2) <> 0 then mkint 1
      else mkint 0
    end // end of [V1ALint, V1ALint]
  else if v1al_is_V1ALstring (v1) andalso v1al_is_V1ALstring (v2) then let
      val s1 = v1al_string_get (v1) and s2 = v1al_string_get (v2)
    in
      if string_isnot_empty (g1ofg0 s1) then mkint (1)
      else if string_isnot_empty (g1ofg0 s2) then mkint (1)
      else mkint 0
    end // end of [V1ALstring, V1ALstring]
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_lor]

(* ****** ****** *)

fn e1xplevenv_valize_asl (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2) then let
      val i1 = v1al_int_get (v1) and i2 = v1al_int_get (v2)
      val () = if (i2 < 0) then {
        val () = prerr_location (e0.e1xp_loc ())
//
        val () = if isdebug () then prerr ": e1xplevenv_valize_asl"
//
        val () = prerr ": the second argument of [<<] is required to be a natural number."
        val () = prerr_newline ()
        val () = $ERR.abort<void> ()
      } // end of [val]
    in
       mkint (g0int_asl (i1, $UN.cast{intGte(0)} (i2)))
    end // end of [(V1ALint _, V1ALint _)]
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_asl]

fn e1xplevenv_valize_asr (
  lev: int, env: !vlenv
, e0: e1xp, id: symbol, e1: e1xp, e2: e1xp
) : v1al = let
  val v1 = e1xplevenv_valize (lev, env, e1)
  val v2 = e1xplevenv_valize (lev, env, e2)
in
  if v1al_is_V1ALint (v1) andalso v1al_is_V1ALint (v2) then let
      val i1 = v1al_int_get (v1) and i2 = v1al_int_get (v2)
      val () = if (i2 < 0) then {
        val () = prerr_location (e0.e1xp_loc ())
//
        val () = if isdebug () then prerr ": e1xplevenv_valize_asl"
//
        val () = prerr ": the second argument of [>>] is required to be a natural number."
        val () = prerr_newline ()
        val () = $ERR.abort<void> ()
      } // end of [val]
    in
       mkint (g0int_asr (i1, $UN.cast{intGte(0)} (i2)))
    end // end of [(V1ALint _, V1ALint _)]
  else oprerr (e0, id)
end // end of [e1xplevenv_valize_asr]

(* ****** ****** *)

implement
e1xplevenv_valize_delta
  (lev, env, e0, id, es) = let
//
macdef
oprarity_err () = mkerr () where {
  val () = the_valerrlst_add (valerr_VE_E1XPappid_arity (e0, id))
} // end of [oprarity_err]
//
val n = glist_length (es)
//
in
//
if id = DEFINED then (
  if n = 1 then e1xp_valize_defined(glist_head (es)) else oprarity_err ()
) else if id = UNDEFINED then (
  if n = 1 then e1xp_valize_undefined(glist_head (es)) else oprarity_err ()
//
) else if id = NEG then (
  if n = 1 then e1xplevenv_valize_neg(lev, env, e0, id, glist_head (es))
  else oprarity_err ()
//
) else if id = ADD then (
  if n = 2 then e1xplevenv_valize_add(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = SUB then (
  if n = 2 then e1xplevenv_valize_sub(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = MUL then (
  if n = 2 then e1xplevenv_valize_mul(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = DIV then (
  if n = 2 then e1xplevenv_valize_div(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
//
) else if id = LT then (
  if n = 2 then e1xplevenv_valize_lt(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = LTEQ then (
  if n = 2 then e1xplevenv_valize_lteq(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = GT then (
  if n = 2 then e1xplevenv_valize_gt(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = GTEQ then (
  if n = 2 then e1xplevenv_valize_gteq(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
//
) else if (id = EQ orelse id = EQEQ) then (
  if n = 2 then e1xplevenv_valize_eq(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if (id = LTGT orelse id = BANGEQ) then (
  if n = 2 then e1xplevenv_valize_neq(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
//
) else if id = LAND then (
  if n = 2 then e1xplevenv_valize_land(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
) else if id = LOR then (
  if n = 2 then e1xplevenv_valize_lor(lev, env, e0, id, glist_head (es), glist_head (glist_tail (es)))
  else oprarity_err ()
//
) else mkerr () where {
    val () = the_valerrlst_add (valerr_VE_E1XPappid_opr (e0, id))
  } // end of [_]
//
end // end of [e1xplevenv_valize_delta]

(* ****** ****** *)

extern
fun e1xplev_normalize
  (lorg: location, lev: int, e0: e1xp): e1xp
// end of [e1xplev_normalize]
extern
fun e1xplevenv_normalize
  (lorg: location, lev: int, env: !elenv, e0: e1xp): e1xp
// end of [e1xplevenv_normalize]
extern
fun e1xplevenv_normalize_main
  (lorg: location, lev: int, env: !elenv, e0: e1xp): e1xp
// end of [e1xplevenv_normalize_main]

(* ****** ****** *)

implement
e1xp_normalize (e0) =
  e1xplev_normalize (e0.e1xp_loc (), 0(*lev*), e0)
// end of [e1xp_normalize]

implement
e1xplev_normalize
  (lorg, lev, e0) = res where {
  val env = lenvmake_nil<e1xp> ()
  val res = e1xplevenv_normalize (lorg, lev, env, e0)
  val () = lenvfree<e1xp> (env)
} // end of [e1xplev_normalize]

(* ****** ****** *)

fn e1xplevenv_normalize_ide (
  lorg: location
, lev: int, env: !elenv, e0: e1xp, x: symbol
) : e1xp = let
  val ans = lenvfind<e1xp> (env, x)
in
//
case+ ans of
| ~Some_vt e => e
| ~None_vt _ => (
  case+ the_e1xpenv_find (x) of
  | ~Some_vt e =>
      e1xplev_normalize (lorg, lev+1, e)
    // end of [Some_vt]
  | ~None_vt _ => e1xp_make (lorg, e0.e1xp_node ())
  ) // end of [None_vt]
end // end of [e1xplevenv_normalize_ide]

(* ****** ****** *)

fun e1xplstlevenv_normalize (
  lorg: location, lev: int, env: !elenv, es: e1xplst
) : e1xplst = case+ glist_view (es) of
  | ~GLcons (e, es) => let
      val e = e1xplevenv_normalize (lorg, lev, env, e)
      val es = e1xplstlevenv_normalize (lorg, lev, env, es)
    in
      glist_cons (e, es)
    end
  | ~GLnil () => glist_nil ()
// end of [e1xplstlevenv_normalize]

(* ****** ****** *)

(*
//
// HX-2011-04-29: this example works now:
// #define f(n, x) if n > 0 then x * f (n, x)
//
*)
implement
e1xplevenv_normalize
  (lorg, lev, env, e0) = let
//
#define MAXLEV MAX_NORMAL_LEVEL
//
in
  if lev <= MAXLEV then
    e1xplevenv_normalize_main (lorg, lev, env, e0)
  else let
    val () = prerr_error1_loc (lorg)
    val () = prerr ": the maximal normlization depth ("
    val () = prerr lev
    val () = prerr ") has been reached."
    val () = prerr_newline ()
  in
    e1xp_err (lorg)
  end (* end of [if] *)
end // end of [e1xplevenv_normalize]

implement
e1xplevenv_normalize_main
  (lorg, lev, env, e0) = let
  val node = e0.e1xp_node () in case+ e1xp_node_view (node) of
  | ~E1XPide id => e1xplevenv_normalize_ide (lorg, lev, env, e0, id)
//
  | ~E1XPint _ => e1xp_make (lorg, node)
  | ~E1XPintrep _ => e1xp_make (lorg, node)
  | ~E1XPchar _ => e1xp_make (lorg, node)
  | ~E1XPstring _ => e1xp_make (lorg, node)
  | ~E1XPfloat _ => e1xp_make (lorg, node)
//
  | ~E1XPv1al _ => e1xp_make (lorg, node)
//
  | ~E1XPnone () => e1xp_make (lorg, node)
  | ~E1XPundef () => e1xp_make (lorg, node)
//
  | ~E1XPlist es => let
      val es = e1xplstlevenv_normalize (lorg, lev, env, es)
    in
      e1xp_list (lorg, es)
    end
  | ~E1XPeval (e) => let
      val v =
      e1xp_valize (
        e1xplevenv_normalize (lorg, lev, env, e)
      ) // end of [val]
    in
      e1xp_v1al (lorg, v)
    end (* end of [E1XPeval] *)
//
  | ~E1XPapp (
      e_fun, _(*loc_arg*), es_arg
    ) => let
      val e_fun = e1xplevenv_normalize (lorg, lev, env, e_fun)
      val es_arg = e1xplstlevenv_normalize (lorg, lev, env, es_arg)
    in
      case+ e1xp_node_view (e_fun.e1xp_node ()) of
      | ~E1XPfun (xs, body) => res where {
          val env1 = lenvmake_e1xplst (lorg, xs, es_arg)
          val res = e1xplevenv_normalize (lorg, lev+1, env1, body)
          val ((*void*)) = lenvfree<e1xp> (env1)
        } (* end of [E1XPfun] *)
      | v => (e1xp_node_view_free (v); e1xp_app (lorg, e_fun, lorg, es_arg))
    end // end of [E1XPapp]
  | ~E1XPfun _ => e1xp_make (lorg, node)
//
  | ~E1XPif (
      _cond, _then, _else // HX: specially treated
    ) => let
      val v =
      e1xp_valize (
        e1xplevenv_normalize (lorg, lev, env, _cond)
      ) // end of [val]
      val istt = v1al_is_true (v)
    in
      if istt then
        e1xplevenv_normalize (lorg, lev, env, _then)
      else
        e1xplevenv_normalize (lorg, lev, env, _else)
      // end of [if]
    end (* end of [E1XPif] *)
//
  | ~E1XPerr _ => e1xp_make (lorg, node)
//
end // end of [e1xplevenv_normalize_main]

(* ****** ****** *)

(* end of [pats_e1xpval.dats] *)
