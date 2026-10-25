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
// HX-2026-10: no GC (see PORTING.md, section "Parser")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
#include "./pats_basics.hats"

(* ****** ****** *)

staload
LOC = "./pats_location.sats"
typedef location = $LOC.location

(* ****** ****** *)

staload "./pats_symbol.sats"
staload "./pats_lexing.sats"
staload "./pats_tokbuf.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_parsing.sats"

staload _(*templates*) = "./pats_syntax.dats"
staload _(*templates*) = "./pats_parsing_util.dats"

(* ****** ****** *)

#include "./pats_syntax_token.hats" // [token_string_get]
#include "./pats_parsing.hats" // [token_knd2_get], [token_ival_get]...

(* ****** ****** *)

#define l2l glist_make_list_vt
#define t2t gopt_make_option_vt


vtypedef p0atlst12 = list12 (p0at)
vtypedef labp0atlst12 = list12 (labp0at)

(* ****** ****** *)

fun
p0at_list12
(
  t_beg: token
, ent2: p0atlst12
, t_end: token
) : p0at =
  case+ ent2 of
  | ~LIST12one (xs) =>
      p0at_list (t_beg, ~1, l2l(xs), t_end)
  | ~LIST12two (xs1, xs2) => let
      val npf = list_vt_length (xs1)
      val xs12 = list_vt_append (xs1, xs2)
    in
      p0at_list (t_beg, npf, l2l(xs12), t_end)
    end (* end of [LIST12two] *)
// end of [p0at_list12]

(* ****** ****** *)

fun
p0at_tup12
(
  knd: int
, t_beg: token
, ent2: p0atlst12
, t_end: token
) : p0at =
  case+ ent2 of
  | ~LIST12one (xs) =>
      p0at_tup (knd, t_beg, ~1, l2l(xs), t_end)
  | ~LIST12two (xs1, xs2) => let
      val npf = list_vt_length (xs1)
      val xs12 = list_vt_append (xs1, xs2)
    in
      p0at_tup (knd, t_beg, npf, l2l(xs12), t_end)
    end (* end of [LIST12two] *)
// end of [p0at_tup12]

(* ****** ****** *)

fun
p0at_rec12
(
  knd: int
, t_beg: token, ent2: labp0atlst12, t_end: token
) : p0at =
  case+ ent2 of
  | ~LIST12one (xs) =>
      p0at_rec (knd, t_beg, ~1, l2l(xs), t_end)
  | ~LIST12two (xs1, xs2) => let
      val npf = list_vt_length (xs1)
      val xs12 = list_vt_append (xs1, xs2)
    in
      p0at_rec (knd, t_beg, npf, l2l(xs12), t_end)
    end
// end of [p0at_rec12]

(* ****** ****** *)

fun
p_p0atseq_BAR_p0atseq
(
  buf: &tokbuf, bt: int, err: &int
) : p0atlst12 =
  plist12_fun<p0at>(buf, bt, p_p0at)
// end of [p_p0atseq_BAR_p0atseq]

fun
p_labp0atseq_BAR_labp0atseq
(
  buf: &tokbuf, bt: int, err: &int
) : labp0atlst12 = let
  val _ = p_COMMA_test (buf) in
  plist12_fun<labp0at>(buf, bt, p_labp0at)
end // end of [p_labp0atseq_BAR_labp0atseq]

(* ****** ****** *)

implement
p_pi0de
  (buf, bt, err) = let
  val tok = tokbuf_get_token (buf)
  val loc = tok.token_loc()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if token_node_is_T_IDENT_alp(tnd) then (
let val x = token_sval_get(tok) in
 let
    val () = incby1 () in i0de_make_string (loc, x)
  end
end
)
else if token_node_is_T_IDENT_sym(tnd) then (
let val x = token_sval_get(tok) in
 let
    val () = incby1 () in i0de_make_string (loc, x)
  end
end
)
else (
 let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt (bt, loc, PE_pi0de)
  in
    synent_null<i0de>()
  end // end of [_]
)
end)end // end of [p_pi0de]

(* ****** ****** *)

(*
labp0at ::= l0ab EQ p0at | DOTDOTDOT
*)
implement
p_labp0at (
  buf, bt, err
) = let
  val err0 = err
  val tok = tokbuf_get_token (buf)
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if token_node_is_T_DOTDOTDOT(tnd) then (
 let
    val () = incby1 () in labp0at_omit (tok)
  end
)
else (
 let
    val ~SYNENT3 (ent1, ent2, ent3) =
      pseq3_fun<l0ab,token,p0at>(buf, bt, err, p_l0ab, p_EQ, p_p0at)
    // end of [val]
  in
    if (err = err0) then
      labp0at_norm (ent1, ent3) else let
      val () = the_parerrlst_add_ifnbt (bt, tok.token_loc(), PE_labp0at)
    in
      synent_null<labp0at>()
    end (* end of [if] *)
  end // end of [_]
//
)
end)end // end of [p_labp0at]

(* ****** ****** *)

(*
atmp0at ::=
  | LITERAL_char
  | LITERAL_int
  | LITERAL_float
  | LITERAL_string
  | pi0de
(*
  | BANG pi0de // HX-2012-05: removed
*)
  | OP pi0de
  | d0ynq pi0de
//
  | LPAREN p0atseq {BAR p0atseq} RPAREN
  | ATLPAREN p0atseq {BAR p0atseq} RPAREN
  | QUOTELPAREN p0atseq {BAR p0atseq} RPAREN
//
  | QUOTELBRACKET p0atseq RBRACKET // lists
//
  | ATLBRACE labp0atseq {BAR labp0atseq} RBRACE
  | QUOTELBRACE labp0atseq {BAR labp0atseq} RBRACE
//
  | LBRACKET s0argseq RBRACKET
*)
fun
p_atmp0at_tok (
  buf: &tokbuf, bt: int, err: &int, tok: token
) : p0at = let
  val err0 = err
  val loc = tok.token_loc()
  var ent: synent = synent_null<synent>()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if ptest_fun<i0de>(
    buf, p_pi0de, ent
  ) then (
 p0at_i0de (synent_decode (ent))
)
else if token_node_is_T_OP(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_pi0de (buf, bt, err)
  in
    if err = err0 then
      p0at_opid (tok, ent2) else synent_null<p0at>()
    // end of [if]
  end
)
else if token_node_is_T_INT(tnd) then (
 let
    val () = incby1 () in p0at_i0nt (tok)
  end
)
else if token_node_is_T_CHAR(tnd) then (
 let
    val () = incby1 () in p0at_c0har (tok)
  end
)
else if token_node_is_T_FLOAT(tnd) then (
 let
    val () = incby1 () in p0at_f0loat (tok)
  end
)
else if token_node_is_T_STRING(tnd) then (
 let
    val () = incby1 () in p0at_s0tring (tok)
  end
)
else if ptest_fun<d0ynq>(
    buf, p_d0ynq, ent
  ) then (
 let
    val bt = 0
    val ent1 = synent_decode {d0ynq} (ent)
    val ent2 = p_pi0de (buf, bt, err) // err = err0
  in
    if err = err0 then
      p0at_dqid (ent1, ent2) else synent_null<p0at>()
    // end of [if]
  end
//
)
else if token_node_is_T_LPAREN(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_p0atseq_BAR_p0atseq (buf, bt, err)
    val ent3 = p_RPAREN (buf, bt, err) // err = err0
  in
    if err = err0 then
      p0at_list12 (tok, ent2, ent3)
    else let
      val () = list12_free<p0at>(ent2) in synent_null<p0at>()
    end // end of [if]
  end
//
)
else if token_node_is_T_LBRACKET(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = pstar_fun0_COMMA<s0arg>(buf, bt, p_s0arg)
    val ent3 = p_RBRACKET (buf, bt, err) // HX: err = err0
  in
    if err = err0 then
      p0at_exist (tok, l2l(ent2), ent3)
    else let
      val () = list_vt_free (ent2) in synent_null<p0at>()
    end (* end of [if] *)
  end
//
)
else if is_LPAREN_deco (tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_p0atseq_BAR_p0atseq (buf, bt, err)
    val ent3 = p_RPAREN (buf, bt, err) // err = err0
  in
    if err = err0 then let
      val knd = (
        if is_ATLPAREN (tnd) then TYTUPKIND_flt else TYTUPKIND_box
      ) : int // end of [val]
    in
      p0at_tup12 (knd, tok, ent2, ent3)
    end else let
      val () = list12_free<p0at>(ent2) in synent_null<p0at>()
    end // end of [if]
  end
)
else if is_LBRACE_deco (tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_labp0atseq_BAR_labp0atseq (buf, bt, err)
    val ent3 = p_RBRACE (buf, bt, err) // err = err0
  in
    if err = err0 then let
      val knd = (
        if is_ATLBRACE (tnd) then TYRECKIND_flt else TYRECKIND_box
      ) : int // end of [val]
    in
      p0at_rec12 (knd, tok, ent2, ent3)
    end else let
      val () = list12_free<labp0at>(ent2) in synent_null<p0at>()
    end // end of [if]
  end
//
)
else if token_node_is_T_DLRLST(tnd) then (
let val lin = token_ival_get(tok) in
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_LPAREN (buf, bt, err)
    val ent3 = (
      if err = err0 then
        pstar_fun0_COMMA<p0at>(buf, bt, p_p0at) else list_vt_nil()
      // end of [if]
    ) : List0_vt(p0at) // end of [val]
    val ent4 = pif_fun<token>(buf, bt, err, p_RPAREN, err0)
  in
    if err = err0 then
      p0at_lst (lin, tok, l2l(ent3), ent4)
    else let
      val () = list_vt_free (ent3) in synent_null<p0at>()
    end (* end of [if] *)
  end
//
end
)
else if token_node_is_T_DLRTUP(tnd) then (
let val knd = token_ival_get(tok) in
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_LPAREN (buf, bt, err)
    val ent3 = p_p0atseq_BAR_p0atseq (buf, bt, err)
    val ent4 = p_RPAREN (buf, bt, err) // err = err0
  in
    if err = err0 then
      p0at_tup12 (knd, tok, ent3, ent4)
    else let
      val () = list12_free<p0at>(ent3) in synent_null<p0at>()
    end (* end of [if] *)
  end
//
end
)
else if token_node_is_T_DLRREC(tnd) then (
let val knd = token_ival_get(tok) in
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_LBRACE (buf, bt, err)
    val ent3 = p_labp0atseq_BAR_labp0atseq (buf, bt, err)
    val ent4 = p_RBRACE (buf, bt, err) // err = err0
  in
    if err = err0 then
      p0at_rec12 (knd, tok, ent3, ent4)
    else let
      val () = list12_free<labp0at>(ent3) in synent_null<p0at>()
    end (* end of [if] *)
  end
//
(*
//
// HX-2014-07:
// a list-pattern
// like '[x1, x2] is no longer supported
//
| T_QUOTELBRACKET () => let
    val bt = 0
    val () = incby1 ()
    val ent2 = pstar_fun0_COMMA {p0at} (buf, bt, p_p0at)
    val ent3 = p_RBRACKET (buf, bt, err)
  in
    if err = err0 then
      p0at_lst_quote (tok, (l2l)ent2, ent3)
    else let
      val () = list_vt_free (ent2) in synent_null()
    end (* end of [if] *)
  end
*)
//
end
)
else (
 let
    val () = err := err + 1 in synent_null<p0at>()
  end
//
)
end)end // end of [p_atmp0at_tok]

fun
p_atmp0at (
  buf: &tokbuf, bt: int, err: &int
) : p0at =
  ptokwrap_fun<p0at>(buf, bt, err, p_atmp0at_tok, PE_atmp0at)
// end of [p_atmp0at]

(* ****** ****** *)

(*
argp0at ::= atmp0at | LBRACE s0vararg RBRACE
*)
fun
p_argp0at (
  buf: &tokbuf, bt: int, err: &int
) : p0at = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val tok = tokbuf_get_token (buf)
  var ent: synent = synent_null<synent>()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if ptest_fun<p0at>(
    buf, p_atmp0at, ent
  ) then (
 synent_decode {p0at} (ent)
)
else if token_node_is_T_LBRACE(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0vararg (buf, bt, err)
    val ent3 = pif_fun<token>(buf, bt, err, p_RBRACE, err0)
  in
    if err = err0 then
      p0at_svararg (tok, ent2, ent3) else tokbuf_set_ntok_null<p0at>(buf, n0)
    // end of [if]
  end
)
else (
 let
    val () = err := err + 1 in synent_null<p0at>()
  end
//
)
end)end // end of [p_a0rgpat]

(* ****** ****** *)

fun
p_p0at0 (
  buf: &tokbuf, bt: int, err: &int
) : p0at = let
  val tok = tokbuf_get_token (buf)
  var ent: synent = synent_null<synent>()
in
//
(if ptest_fun<p0at>(
    buf, p_atmp0at, ent
  ) then (
 let
    val bt = 0
    val x0 = synent_decode {p0at} (ent)
    val xs = pstar_fun<p0at>(buf, bt, p_argp0at)
    fun loop (
      x0: p0at, xs: List0_vt(p0at)
    ) : p0at =
      case+ xs of
      | ~list_vt_cons (x, xs) => let
          val x0 = p0at_app (x0, x) in loop (x0, xs)
        end
      | ~list_vt_nil () => x0
    // end of [loop]
  in
    loop (x0, xs)
  end
)
else (
 let
    val () = err := err + 1 in synent_null<p0at>()
  end
))end // end of [p_p0at0]

(* ****** ****** *)

(*
p0at
  | p0at0
  | p0at0 AS p0at
  | p0at0 COLON s0exp
  | AT p0at // unfolded
  | TILDE p0at // freeed
*)
implement
p_p0at (buf, bt, err) = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val tok = tokbuf_get_token (buf)
  var ent: synent = synent_null<synent>()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if ptest_fun<p0at>(
    buf, p_p0at0, ent
  ) then (
 let
    val bt = 0
    val p0t = synent_decode {p0at} (ent)
    val tok2 = tokbuf_get_token (buf)
  in
    (let val tnd = tok2.token_node() in
if token_node_is_T_AS(tnd) then (
 let
        val () = incby1 ()
        val ent3 = p_p0at (buf, bt, err)
      in
        if err = err0 then
          p0at_refas (p0t, ent3) else tokbuf_set_ntok_null<p0at>(buf, n0)
        // end of [if]
      end

)
else if token_node_is_T_COLON(tnd) then (
 let
        val () = incby1 ()
        val ent3 = p_s0exp (buf, bt, err)
      in
        if err = err0 then
          p0at_ann (p0t, ent3) else tokbuf_set_ntok_null<p0at>(buf, n0)
        // end of [if]
      end

)
else (
 p0t

)
end)end
)
else if token_node_is_T_TILDE(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_p0at (buf, bt, err)
  in
    if err = err0 then
      p0at_free (tok, ent2) else tokbuf_set_ntok_null<p0at>(buf, n0)
    // end of [if]
  end
)
else if token_node_is_T_AT(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_p0at (buf, bt, err)
  in
    if err = err0 then
      p0at_unfold (tok, ent2) else tokbuf_set_ntok_null<p0at>(buf, n0)
    // end of [if]
  end
)
else (
 let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt (bt, tok.token_loc(), PE_p0at)
  in
    synent_null<p0at>()
  end
//
)
end)end // end of [p_p0at]

(* ****** ****** *)
//
(*
f0arg1 ::=
  | atmp0at | LBRACE s0quaseq RBRACE
  | DOTLT s0expseq GTDOT | DOTLTGTDOT
*)
//
implement
p_f0arg1
  (buf, bt, err) = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val tok = tokbuf_get_token (buf)
  var ent: synent = synent_null<synent>()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if ptest_fun<p0at>(
    buf, p_atmp0at, ent
  ) then (
 f0arg_dyn (synent_decode {p0at} (ent))
)
else if token_node_is_T_LBRACE(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0quaseq (buf, bt, err)
    val ent3 = p_RBRACE (buf, bt, err) // err = 0
  in
    if err = 0 then
      f0arg_sta1 (tok, ent2, ent3) else tokbuf_set_ntok_null<f0arg>(buf, n0)
    // end of [if]
  end
)
else if token_node_is_T_DOTLT(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = pstar_fun0_COMMA<s0exp>(buf, bt, p_s0exp)
    val ent3 = p_GTDOT (buf, bt, err) // err = 0
  in
    if err = err0 then
      f0arg_met (tok, l2l(ent2), ent3)
    else let
      val () = list_vt_free (ent2) in tokbuf_set_ntok_null<f0arg>(buf, n0)
    end (* end of [if] *)
  end
)
else if token_node_is_T_DOTLTGTDOT(tnd) then (
 let
    val () = incby1 () in f0arg_met_nil (tok)
  end // end of [T_DOTLTGTDOT]
)
else (
 let
    val () = err := err + 1 in synent_null<f0arg>()
  end
//
)
end)end // end of [p_f0arg1]

(*
f0arg2 ::= atmp0at | LBRACE s0argseq RBRACE
*)
implement
p_f0arg2
  (buf, bt, err) = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val tok = tokbuf_get_token (buf)
  var ent: synent = synent_null<synent>()
  macdef incby1 () = tokbuf_incby1 (buf)
in
//
(let val tnd = tok.token_node() in
if ptest_fun<p0at>(
    buf, p_atmp0at, ent
  ) then (
 f0arg_dyn (synent_decode {p0at} (ent))
)
else if token_node_is_T_LBRACE(tnd) then (
 let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0vararg (buf, bt, err)
    val ent3 = pif_fun<token>(buf, bt, err, p_RBRACE, err0)
  in
    if err = 0 then
      f0arg_sta2 (tok, ent2, ent3) else tokbuf_set_ntok_null<f0arg>(buf, n0)
    // end of [if]
  end
)
else (
 let
    val () = err := err + 1 in synent_null<f0arg>()
  end
//
)
end)end // end of [p_f0arg2]

(* ****** ****** *)
//
(*
gm0at
  : d0exp  { $$ = gm0at_make_none ($1) ; }
  | d0exp AS p0at  { $$ = gm0at_make_some ($1, $3) ; }
; /* gm0at */
*)
//
fun
p_gm0at
(
  buf: &tokbuf, bt: int, err: &int
) : gm0at = let
  val err0 = err
  val ent1 = p_d0exp (buf, bt, err)
in
//
if
err = err0
then let
  val ent2 =
    ptokentopt_fun<p0at>(buf, is_AS, p_p0at)
  // end of [val]
in
  gm0at_make (ent1, t2t(ent2))
end else let
  val tok = tokbuf_get_token (buf)
  val ((*void*)) =
    the_parerrlst_add_ifnbt (bt, tok.token_loc(), PE_gm0at)
  // end of [val]
in
  synent_null<gm0at>() // HX: [err] is already set
end // end of [if]
end // end of [p_gm0at]

fun
p_gm0atseq
(
  buf: &tokbuf, bt: int, err: &int
) : gm0atlst =
  l2l (pstar_fun1_AND<gm0at>(buf, bt, err, p_gm0at))
// end of [p_gm0atseq]

fun
p_guap0at
(
  buf: &tokbuf, bt: int, err: &int
) : guap0at = let
  val err0 = err
  val ent1 = p_p0at (buf, bt, err)
in
//
if
err = err0
then let
  val ent2 =
    ptokentopt_fun<gm0atlst>(buf, is_WHEN, p_gm0atseq)
  // end of [val]
in
  guap0at_make (ent1, t2t(ent2))
end else let
  val tok = tokbuf_get_token (buf)
  val ((*void*)) =
    the_parerrlst_add_ifnbt(bt, tok.token_loc(), PE_guap0at)
  // end of [val]
in
  synent_null<guap0at>() // HX: [err] is already set
end // end of [if]
end // end of [p_guap0at]

(* ****** ****** *)

(*
c0lau
  | guap0at EQGT d0exp
  | guap0at EQGTGT d0exp
  | guap0at EQSLASHEQGT d0exp
  | guap0at EQSLASHEQGTGT d0exp
*)
fun p_c0lau (
  buf: &tokbuf, bt: int, err: &int
) : c0lau = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val ent1 = p_guap0at (buf, bt, err)
  val bt = 0
  var seq: int = 0 and neg: int = 0
  val () = if
    err = err0 then let
    val tok2 = tokbuf_get_token (buf)
    val () = (
      (let val tnd = tok2.token_node() in
if token_node_is_T_EQGT(tnd) then ()
else if token_node_is_T_EQGTGT(tnd) then (
 seq := 1

)
else if token_node_is_T_EQSLASHEQGT(tnd) then (
 neg := 1

)
else if token_node_is_T_EQSLASHEQGTGT(tnd) then (
 (seq := 1; neg := 1)

)
else (
 (err := err + 1)

)
end)) : void // end of [val]
  in
    if err = err0 then tokbuf_incby1 (buf)
  end // end of [val]
  val ent3 = pif_fun<d0exp>(buf, bt, err, p_d0exp, err0)
in
//
if
err = err0
then
  c0lau_make(ent1, seq, neg, ent3)
else let
  val tok = tokbuf_get_token (buf)
  val ((*void*)) =
    the_parerrlst_add_ifnbt (bt, tok.token_loc(), PE_c0lau)
  // end of [val]
in
  tokbuf_set_ntok_null<c0lau>(buf, n0)
end // end of [if]
end // end of [p_c0lau]

(* ****** ****** *)
//
(*
sp0at ::= sqi0de LPAREN s0argseq RPAREN
*)
//
fun
p_sp0at
(
  buf: &tokbuf, bt: int, err: &int
) : sp0at = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val ent1 = p_sqi0de (buf, bt, err)
  val ent2 = pif_fun<token>(buf, bt, err, p_LPAREN, err0)
  val ent3 = (
    if err = err0 then
      pstar_fun0_COMMA<s0arg>(buf, bt, p_s0arg)
    else list_vt_nil ()
  ) : List0_vt(s0arg)
  val ent4 = pif_fun<token>(buf, bt, err, p_RPAREN, err0)
in
//
if
err = err0
then let
  val ent3 = l2l(ent3)
in
  sp0at_cstr(ent1, ent3, ent4)
end // end of [then]
else let
  val () = list_vt_free(ent3)
  val tok = tokbuf_get_token(buf)
  val () =
    the_parerrlst_add_ifnbt(bt, tok.token_loc(), PE_sc0lau)
  // end of [val]
in
  tokbuf_set_ntok_null<sp0at>(buf, n0)
end (* end of [if] *)
//
end // end of [p_sp0at]

fun
p_sc0lau
(
  buf: &tokbuf, bt: int, err: &int
) : sc0lau = let
  val err0 = err
  val ~SYNENT3(ent1, ent2, ent3) =
    pseq3_fun<sp0at,token,d0exp>(buf, bt, err, p_sp0at, p_EQGT, p_d0exp)
  // end of [val]
in
  if err = err0 then
    sc0lau_make (ent1, ent3) else synent_null<sc0lau>()
  // end of [if]
end // end of [p_sc0lau]

(* ****** ****** *)

implement
p_c0lauseq
  (buf, bt, err) = let
  val _ = p_BAR_test (buf) in l2l(pstar_fun0_BAR<c0lau>(buf, bt, p_c0lau))
end // end of [p_c0lauseq]

implement
p_sc0lauseq
  (buf, bt, err) = let
  val _ = p_BAR_test (buf) in l2l(pstar_fun0_BAR<sc0lau>(buf, bt, p_sc0lau))
end // end of [p_sc0lauseq]

(* ****** ****** *)

(* end of [pats_parsing_p0at.dats] *)
