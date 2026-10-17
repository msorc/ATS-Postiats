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
// Start Time: March, 2011
//

(* ****** ****** *)
//
// HX-2026-10: no GC (see PORTING.md, section "Parser").
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
#include "./pats_parsing.hats" // [token_knd2_get]

(* ****** ****** *)

#define l2l glist_make_list_vt
#define t2t gopt_make_option_vt

(* ****** ****** *)

vtypedef s0explst12 = list12 (s0exp)
vtypedef labs0explst12 = list12 (labs0exp)

(* ****** ****** *)

fun
s0exp_list12
(
  t_beg: token, ent2: s0explst12, t_end: token
) : s0exp = (
//
case+ ent2 of
| ~LIST12one(xs) =>
    s0exp_list(t_beg, l2l(xs), t_end)
| ~LIST12two(xs1, xs2) =>
    s0exp_list2(t_beg, l2l(xs1), l2l(xs2), t_end)
//
) (* end of [s0exp_list12] *)

(* ****** ****** *)

fun
s0exp_tytup12
(
  knd: int
, t_beg: token, ent2: s0explst12, t_end: token
) : s0exp = (
//
case+ ent2 of
| ~LIST12one(xs) =>
    s0exp_tytup(knd, t_beg, ~1, l2l(xs), t_end)
| ~LIST12two(xs1, xs2) => let
    val npf = list_vt_length (xs1)
    val xs12 = list_vt_append (xs1, xs2)
  in
    s0exp_tytup(knd, t_beg, npf, l2l(xs12), t_end)
  end // end of [LIST12two]
//
) (* end of [s0exp_tytup12] *)

(* ****** ****** *)

fun
s0exp_tyrec12
(
  knd: int
, t_beg: token, ent2: labs0explst12, t_end: token
) : s0exp = (
//
case+ ent2 of
| ~LIST12one(xs) =>
    s0exp_tyrec(knd, t_beg, ~1, l2l(xs), t_end)
| ~LIST12two(xs1, xs2) => let
    val npf = list_vt_length (xs1)
    val xs12 = list_vt_append (xs1, xs2)
  in
    s0exp_tyrec(knd, t_beg, npf, l2l(xs12), t_end)
  end // end of [LIST12two]
//
) (* end of [s0exp_tyrec12] *)

(* ****** ****** *)

fun
s0exp_tyrec12_ext
(
  name: string
, t_beg: token, ent2: labs0explst12, t_end: token
) : s0exp = (
//
case+ ent2 of
| ~LIST12one(xs) =>
    s0exp_tyrec_ext(name, t_beg, ~1, l2l(xs), t_end)
| ~LIST12two(xs1, xs2) => let
    val npf = list_vt_length (xs1)
    val xs12 = list_vt_append (xs1, xs2)
  in
    s0exp_tyrec_ext(name, t_beg, npf, l2l(xs12), t_end)
  end // end of [LIST12two]
//
) (* end of [s0exp_tyrec12_ext] *)

(* ****** ****** *)

fun
p_s0expseq_BAR_s0expseq
(
  buf: &tokbuf, bt: int, err: &int
) : s0explst12 =
  plist12_fun<s0exp> (buf, bt, p_s0exp)
// end of [p_s0expseq_BAR_s0expseq]

fun
p_labs0expseq_BAR_labs0expseq
(
  buf: &tokbuf, bt: int, err: &int
) : labs0explst12 = let
  val _ = p_COMMA_test (buf) in
  plist12_fun<labs0exp> (buf, bt, p_labs0exp)
end // end of [p_labs0expseq_BAR_labs0expseq]

(* ****** ****** *)

(*
si0de
  | IDENTIFIER_alp
  | IDENTIFIER_sym
(*
  | R0EAD // this one is removed in Postiats
*)
  | AT
  | BANG
  | LT
  | GT
  | AMPERSAND
  | BACKSLASH
  | TILDE
  | MINUSGT
//
  | REFAT // ref@ for flatten ref in a record
//
*)

implement
p_si0de
  (buf, bt, err) = let
//
val tok =
  tokbuf_get_token(buf)
//
val loc = tok.token_loc()
//
macdef incby1() = tokbuf_incby1(buf)
//
in
//
case+
token_node_view(tok.token_node())
of // case+
//
| ~T_IDENT_alp(x) =>
  let
    val () = incby1() in i0de_make_string(loc, x)
  end
| ~T_IDENT_sym(x) =>
  let
    val () = incby1() in i0de_make_string(loc, x)
  end
//
| ~T_AT() =>
  let
    val () = incby1() in i0de_make_sym(loc, symbol_AT)
  end
| ~T_BANG() => let
    val () = incby1() in i0de_make_sym(loc, symbol_BANG)
  end
//
| ~T_LT() => let
    val () = incby1() in i0de_make_sym(loc, symbol_LT)
  end
| ~T_GT() => let
    val () = incby1() in i0de_make_sym(loc, symbol_GT)
  end
//
| ~T_TILDE() => let
    val () = incby1() in i0de_make_sym(loc, symbol_TILDE)
  end
//
| ~T_MINUSGT() => let
    val () = incby1() in i0de_make_sym(loc, symbol_MINUSGT)
  end
//
| ~T_BACKSLASH() => let
    val () = incby1() in i0de_make_sym(loc, symbol_BACKSLASH)
  end
//
(*
//
// HX-2015-12-10:
// 'ref@' is removed
//
| T_REFAT() => let
    val () = incby1() in i0de_make_sym(loc, symbol_REFAT)
  end // end of [T_REFAT]
*)
//
| v (*rest*) => let
    val () = token_node_view_free(v)
    val () =
      err := err + 1
    val () =
      the_parerrlst_add_ifnbt(bt, loc, PE_si0de) in synent_null<i0de>()
    // end of [val]
  end // end of [_]
//
end // end of [p_si0de]

(* ****** ****** *)

(*
s0taq
  | /*empty*/
  | i0de_dlr DOT
  | i0de_dlr COLON
/*
  | DOLLAR LITERAL_string DOT // this one is removed
*/
*)

implement
p_s0taq
  (buf, bt, err) = let
//
val n0 =
  tokbuf_get_ntok (buf)
//
val tok =
  tokbuf_get_token (buf)
//
val loc = tok.token_loc()
//
var ent: synent = synent_null<synent> ()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
ptest_fun<i0de> (
  buf, p_i0de_dlr, ent
) then let
    val bt = 0
    val ent1 =
      synent_decode{i0de}(ent)
    // end of [val]
    val tok2 = tokbuf_get_token (buf)
  in
    if token_node_is_T_DOT (tok2.token_node()) then let
        val () = incby1 () in s0taq_symdot (ent1, tok2)
      end
(*
//
// HX-2017-01-24:
// it is never in use
//
    | T_COLON () => let
        val () = incby1 () in s0taq_symcolon (ent1, tok2)
      end
*)
    else (*non-DOT-COLON*) let
        val () = the_parerrlst_add_ifnbt (bt, loc, PE_s0taq)
      in
        tokbuf_set_ntok_null<s0taq> (buf, n0)
      end // end of [_]
  end (* end of [_ when ...] *)
else (*rest*) let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt (bt, loc, PE_s0taq)
  in
    synent_null<s0taq> ()
  end (* end of [_] *)
//
end // end of [p_s0taq]

(* ****** ****** *)
//
(*
sqi0de := si0de | s0taq si0de
*)
//
implement
p_sqi0de
  (buf, bt, err) = let
//
val err0 = err
var ent: synent = synent_null<synent> ()
//
val n0 = tokbuf_get_ntok (buf)
//
in
//
if
ptest_fun<i0de> (
  buf, p_si0de, ent
) then
    sqi0de_make_none (synent_decode{i0de}(ent))
  // end of [_ when ...]
else let
    val ent1 = p_s0taq (buf, bt, err)
    val ent2 = pif_fun<i0de> (buf, bt, err, p_si0de, err0)
  in
    if err = err0 then
      sqi0de_make_some (ent1, ent2) else tokbuf_set_ntok_null<sqi0de> (buf, n0)
    // end of [if]
  end // end of [_]
//
end // end of [p_sqi0de]

(* ****** ****** *)

extern
fun
p_asnameopt
  : parser (s0tringopt) // COLON s0rt
// end of [p_asnameopt]

implement
p_asnameopt
  (buf, bt, err) =
  t2t (ptokentopt_fun<s0tring> (buf, is_AS, p_s0tring))
// end of [p_colons0rtopt]

(* ****** ****** *)
(*
//
// HX-2011-10-15:
// labs0exp ::= l0ab [AS string] EQ s0exp
//
typedef foo =
$extype_struct
"foo_struct" of
{
  in_ as "in" = int // the C-name of the field is "in"
} (* end of [foo] *)
*)
implement
p_labs0exp (
  buf, bt, err
) = let
  val err0 = err
  val tok =
    tokbuf_get_token(buf)
  // end of [val]
  val ent1 = p_l0ab(buf, bt, err)
  val ent2 =
    pif_fun<s0tringopt>(buf, bt, err, p_asnameopt, err0)
  // end of [val]
  val bt = 0
  val ent3 = pif_fun<token>(buf, bt, err, p_EQ, err0)
  val ent4 = pif_fun<s0exp>(buf, bt, err, p_s0exp, err0)
in
//
if (err = err0) then
  labs0exp_make(ent1, ent2, ent4)
else let
  val () =
    the_parerrlst_add_ifnbt(bt, tok.token_loc(), PE_labs0exp)
  // end of [val]
in
  synent_null<labs0exp>((*void*))
end (* end of [if] *)
//
end // end of [p_labs0exp]

(* ****** ****** *)
//
(*
s0arrdim
  | LBRACKET s0expseq RBRACKET
*)
//
fun
p_s0arrdim
(
  buf: &tokbuf, bt: int, err: &int
) : s0arrdim = let
  val err0 = err
  val n0 = tokbuf_get_ntok (buf)
  val ent1 = p_LBRACKET (buf, bt, err)
  val bt = 0
  val ent2 = (
    if err = err0
      then (
        pstar_fun0_COMMA<s0exp>(buf, bt, p_s0exp)
      ) else list_vt_nil((*void*))
    // end of [if]
  ) : List0_vt(s0exp) // end-of-val
  val ent3 = pif_fun<token>(buf, bt, err, p_RBRACKET, err0)
in
  if err = err0 then
    s0arrdim_make(ent1, l2l(ent2), ent3)
  else let
    val () = list_vt_free(ent2) in tokbuf_set_ntok_null<s0arrdim>(buf, n0)
  end // end of [if]
end (* end of [s0arrdim_make] *)
//
(* ****** ****** *)

(*
atms0exp
  | i0nt
  | LITERAL_char
//
  | si0de
  | s0taq i0de
  | OP si0de
//
  | LPAREN s0expseq [BAR s0expseq] RPAREN
//
  | ATLPAREN s0expseq [BAR s0expseq] RPAREN // knd = 0
  | QUOTELPAREN s0expseq [BAR s0expseq] RPAREN // knd = 1
//
  | ATLBRACE labs0expseq [BAR labs0expseq] RBRACE // knd = 0
  | QUOTELBRACE labs0expseq [BAR labs0expseq] RBRACE // knd = 1
//
  | ATLBRACKET s0exp RBRACKET s0arrind // for instance: @[a][n]
//
// HX: boxed types
//
  | DLRTUP_T LPAREN s0expseq RPAREN
  | DLRTUP_T LPAREN s0expseq BAR s0expseq RPAREN
  | DLRTUP_VT LPAREN s0expseq RPAREN
  | DLRTUP_VT LPAREN s0expseq BAR s0expseq RPAREN
  | DLRREC_T LBRACE labs0expseq RBRACE
  | DLRREC_T LBRACE labs0expseq BAR labs0expseq RBRACE
  | DLRREC_VT LBRACE labs0expseq RBRACE
  | DLRREC_VT LBRACE labs0expseq BAR labs0expseq RBRACE
//
// HX: unboxed external struct types
//
  | DLREXTYPE_STRUCT LITERAL_string OF LBRACE labs0expseq RBRACE
//
  | MINUSLT e0fftagseq GT
  | MINUSLTGT
//
  | LBRACE s0quaseq RBRACE
//
  | LBRACKET s0quaseq RBRACKET
  | HASHLBRACKET s0quaseq RBRACKET
//
  | DLRD2CTYPE LPAREN S0Ed2ctype RPAREN
//
*)

(* ****** ****** *)
//
extern
fun
p_atms0exp_tok
(
  buf: &tokbuf
, bt: int, err: &int, tok: token
) : s0exp // end-of-fun
//
implement
p_atms0exp
  (buf, bt, err) =
(
  ptokwrap_fun<s0exp>
    (buf, bt, err, p_atms0exp_tok, PE_atms0exp)
) (* end of [p_atms0exp] *)
//
implement
p_atms0exp_tok
(
  buf, bt, err, tok
) = let
//
val err0 = err
var ent: synent = synent_null<synent> ()
//
val tnd = tok.token_node()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
ptest_fun<i0de> (buf, p_si0de, ent)
  then s0exp_i0de (synent_decode{i0de}(ent))
//
else if token_node_is_T_INT (tnd) then let
    val () = incby1 () in s0exp_i0nt(tok)
  end // end of [T_INT]
//
else if token_node_is_T_CHAR (tnd) then let
    val () = incby1 () in s0exp_c0har(tok)
  end // end of [T_CHAR]
//
else if token_node_is_T_FLOAT (tnd) then let
    val () = incby1 () in s0exp_f0loat(tok)
  end // end of [T_FLOAT]
//
else if token_node_is_T_STRING (tnd) then let
    val () = incby1 () in s0exp_s0tring(tok)
  end // end of [T_STRING]
//
else if token_node_is_T_OP (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_si0de (buf, bt, err)
  in
    if err = err0 then
      s0exp_opid (tok, ent2) else synent_null<s0exp> ()
    // end of [if]
  end
//
else if
ptest_fun<s0taq> (buf, p_s0taq, ent) then let
    val bt = 0
    val ent1 = synent_decode {s0taq} (ent)
    val ent2 = p_si0de (buf, bt, err) // err=err0
  in
    if err = err0 then
      s0exp_sqid (ent1, ent2) else synent_null<s0exp> ()
    // end of [if]
  end
//
else if token_node_is_T_LPAREN (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      p_s0expseq_BAR_s0expseq(buf, bt, err)
    val ent3 = p_RPAREN (buf, bt, err) // err=err0
  in
    if err = err0 then
      s0exp_list12 (tok, ent2, ent3)
    else let
      val () = list12_free<s0exp> (ent2) in synent_null<s0exp>()
    end // end of [if]
  end
//
else if
is_LPAREN_deco (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      p_s0expseq_BAR_s0expseq(buf, bt, err)
    val ent3 = p_RPAREN (buf, bt, err) // err=err0
  in
    if err = err0
      then let
        val knd = (
          if is_ATLPAREN(tnd)
            then TYTUPKIND_flt else TYTUPKIND_box
          // end of [if]
        ) : int // end of [val]
      in
        s0exp_tytup12 (knd, tok, ent2, ent3)
      end // end of [then]
      else let
        val () = list12_free<s0exp> (ent2) in synent_null<s0exp>()
      end // end of [else]
    // end of [if]
  end
else if
is_LBRACE_deco (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      p_labs0expseq_BAR_labs0expseq (buf, bt, err)
    // end of [val]
    val ent3 = p_RBRACE (buf, bt, err) // err=err0
  in
    if err = err0
      then let
        val knd =
        (
          if is_ATLBRACE(tnd)
            then TYRECKIND_flt else TYRECKIND_box
          // end of [if]
        ) : int // end of [val]
      in
        s0exp_tyrec12 (knd, tok, ent2, ent3)
      end // end of [then]
      else let
        val () = list12_free<labs0exp> (ent2) in synent_null<s0exp>()
      end // end of [else]
    // end of [if]
  end
//
else if token_node_is_T_ATLBRACKET (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0exp (buf, bt, err)
    val ent3 = pif_fun<token> (buf, bt, err, p_RBRACKET, err0)
    val ent4 = pif_fun<s0arrdim> (buf, bt, err, p_s0arrdim, err0)
  in
    if err = err0 then
      s0exp_tyarr (tok, ent2, ent4) else synent_null<s0exp>()
    // end of [if]
  end
//
else if token_node_is_T_DLRTUP (tnd) then let
    val knd = token_knd2_get (tok)
    val bt = 0
    val () = incby1 ()
    val ent2 = p_LPAREN (buf, bt, err)
  in
    if err = err0
      then let
        val ent3 =
          p_s0expseq_BAR_s0expseq (buf, bt, err)
        // end of [val]
        val ent4 = p_RPAREN (buf, bt, err) // err=err0
      in
        if err = err0
          then s0exp_tytup12 (knd, tok, ent3, ent4)
          else let
            val () = list12_free<s0exp> (ent3) in synent_null<s0exp>()
          end (* end of [else] *)
        // end of [if]
      end // end of [then]
      else synent_null<s0exp>((*error*))
    // end of [if]
  end
else if token_node_is_T_DLRREC (tnd) then let
    val knd = token_knd2_get (tok)
    val bt = 0
    val () = incby1 ()
    val ent2 = p_LBRACE (buf, bt, err)
  in
    if err = err0 then let
      val ent3 =
        p_labs0expseq_BAR_labs0expseq(buf, bt, err)
      // end of [val]
      val ent4 = p_RBRACE (buf, bt, err) // err=err0
    in
      if err = err0 then
        s0exp_tyrec12 (knd, tok, ent3, ent4)
      else let
        val () = list12_free<labs0exp> (ent3) in synent_null<s0exp>()
      end (* end of [if] *)
    end else
      synent_null<s0exp> ()
    // end of [if]
  end
//
else if token_node_is_T_DLREXTYPE_STRUCT (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0tring (buf, bt, err)
    val ent3 = pif_fun<token> (buf, bt, err, p_OF, err0)
    val ent4 = pif_fun<token> (buf, bt, err, p_LBRACE, err0)
  in
    if err = err0
      then let
        val ent5 =
          p_labs0expseq_BAR_labs0expseq(buf, bt, err)
        // end of [val]
        val ent6 = p_RBRACE (buf, bt, err) // err=err0
      in
        if err = err0
          then let
            val name = token_string_get (ent2)
          in
            s0exp_tyrec12_ext (name, tok, ent5, ent6)
          end // end of [then]
          else let
            val () = list12_free<labs0exp> (ent5) in synent_null<s0exp>()
          end (* end of [else] *)
        // end of [if]
      end // end of [then]
      else synent_null<s0exp>((*void*)) // end of [else]
    // end of [if]
  end
//
else if token_node_is_T_MINUSLT (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_e0fftaglst (buf, bt, err)
    val ent3 = p_GT (buf, bt, err) // err=err0
  in
    if err = err0
      then s0exp_imp (tok, ent2, ent3) else synent_null<s0exp>()
    (* end of [if] *)
  end
else if token_node_is_T_MINUSLTGT (tnd) then
    let val () = incby1 () in s0exp_imp_nil(tok) end
  // end of [T_MINUSLTGT]
//
else if token_node_is_T_LBRACE (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0quaseq (buf, bt, err)
    val ent3 = p_RBRACE (buf, bt, err) // err=err0
  in
    if err = err0
      then s0exp_uni (tok, ent2, ent3)
      else synent_null<s0exp>()
    // (* end of [if] *)
  end
//
else if token_node_is_T_LBRACKET (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0quaseq (buf, bt, err)
    val ent3 = p_RBRACKET (buf, bt, err) // err=err0
  in
    if err = err0
      then s0exp_exi (0(*funres*), tok, ent2, ent3)
      else synent_null<s0exp>()
    // end of [if]
  end
else if token_node_is_T_HASHLBRACKET (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0quaseq (buf, bt, err)
    val ent3 = p_RBRACKET (buf, bt, err) // err=err0
  in
    if err = err0
      then s0exp_exi (1(*funres*), tok, ent2, ent3)
      else synent_null<s0exp>()
    // end of [if]
  end
//
else if token_node_is_T_DLRD2CTYPE (tnd) then let
    val bt = 0
    val () = incby1 ()
//
    val ent2 = p_LPAREN (buf, bt, err)
    val ent3 =
      pif_fun<d0exp>(buf, bt, err, p_S0Ed2ctype, err0)
    val ent3 = $UN.cast{S0Ed2ctype}(ent3)
    val ent4 = pif_fun<token> (buf, bt, err, p_RPAREN, err0)
//
  in
    if err = err0
      then s0exp_d2ctype(tok, ent3, ent4) else synent_null<s0exp>()
    // end of [if]
  end
//
else
    let val () = err := err + 1 in synent_null<s0exp>() end
(*rest-of-tokens*)
//
end // end of [p_atms0exp_tok]

(* ****** ****** *)
//
(*
apps0exp := {atms0exp}+
*)
//
fun
p_apps0exp (
  buf: &tokbuf, bt: int, err: &int
) : s0exp = let
//
fun loop (
  x0: s0exp, xs1: List0_vt(s0exp)
) : s0exp = (
  case+ xs1 of
  | ~list_vt_cons
      (x1, xs1) => let
      val x0 = s0exp_app (x0, x1) in loop (x0, xs1)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => x0
) (* end of [loop] *)
//
val xs = pstar1_fun<s0exp> (buf, bt, err, p_atms0exp)
//
in
//
case+ xs of
| ~list_vt_cons (x, xs) => loop (x, xs)
| ~list_vt_nil () => synent_null<s0exp> () // HX: [err] changed
//
end // end of [p_apps0exp]
//
(* ****** ****** *)
//
(*
exts0exp :=
  | DLREXTYPE LITERAL_string {atms0exp}* // eg: $extype"list" (int)
  | DLREXTKIND LITERAL_string {atms0exp}* // eg: $extkind"atstype_int64"
*)
//
fun
p_exts0exp (
  buf: &tokbuf, bt: int, err: &int
) : s0exp = let
//
val err0 = err
val n0 = tokbuf_get_ntok (buf)
val tok = tokbuf_get_token (buf)
val loc = tok.token_loc()
val tnd = tok.token_node()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if token_node_is_T_DLREXTYPE (tnd) then let
    val bt = 0
    val () = incby1 ()
    val str = p_s0tring (buf, bt, err)
  in
    if err = err0 then let
      val arg = pstar_fun<s0exp> (buf, bt, p_atms0exp)
      val arg = l2l (arg) // nonlinization
    in
      s0exp_extype (tok, str, arg)
    end else tokbuf_set_ntok_null<s0exp> (buf, n0) // endif
  end // end of [T_DLREXTYPE]
else if token_node_is_T_DLREXTKIND (tnd) then let
    val bt = 0
    val () = incby1 ()
    val str = p_s0tring (buf, bt, err)
  in
    if err = err0 then let
      val arg = pstar_fun<s0exp> (buf, bt, p_atms0exp)
      val arg = l2l (arg) // nonlinization
    in
      s0exp_extkind (tok, str, arg)
    end else tokbuf_set_ntok_null<s0exp> (buf, n0) // endif
  end // end of [T_DLREXTKIND]
else let
    val () = err := err + 1
(*
    val () = the_parerrlst_add_ifnbt (bt, loc, PE_exts0exp)
*)
  in
    synent_null<s0exp> ()
  end (* end of [_] *)
//
end // end of [p_exts0exp]
//
(* ****** ****** *)
//
(*
s0exp0 ::= apps0exp | exts0exp
*)
//
fun
p_s0exp0 ( // no annotation
  buf: &tokbuf, bt: int, err: &int
) : s0exp = let
//
var ent: synent = synent_null<synent> ()
//
in
//
if
ptest_fun<s0exp> (
  buf, p_apps0exp, ent
) then synent_decode {s0exp} (ent)
else if
ptest_fun<s0exp> (
  buf, p_exts0exp, ent
) then synent_decode {s0exp} (ent)
else let
  val () = err := err + 1 in synent_null<s0exp> ()
end (* end of [_] *)
//
end // end of [p_s0exp0]
//
(* ****** ****** *)
//
(*
s0exp ::=
  | s0exp0 [COLON s0rt]
  | LAM s0margseq colons0rtopt EQGT s0exp // COLON > LAM
*)
//
fun
s0exp_annopt
(
  ent1: s0exp, ent2: s0rtopt
) : s0exp = (
  case+ gopt_view ent2 of
  | ~GOsome s0t => s0exp_ann (ent1, s0t) | ~GOnone () => ent1
) (* end of [s0exp_annopt] *)
//
(* ****** ****** *)
//
extern
fun
p_s0exp_tok ( // no annotation
  buf: &tokbuf
, bt: int, err: &int, tok: token
) : s0exp
//
implement
p_s0exp
  (buf, bt, err) = 
(
  ptokwrap_fun<s0exp>
    (buf, bt, err, p_s0exp_tok, PE_s0exp)
) (* end of [p_s0exp] *)
//
implement
p_s0exp_tok
(
  buf, bt, err, tok
) = let
//
val err0 = err
var ent: synent = synent_null<synent> ()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
ptest_fun<s0exp> (
  buf, p_s0exp0, ent
) then let
    val bt = 0
    val ent1 = synent_decode {s0exp} (ent)
    val ent2 = p_colons0rtopt (buf, bt, err)
  in
    if err = err0 then
      s0exp_annopt (ent1, ent2) else synent_null<s0exp> ((*dangling COLON*))
    // end of [if]
  end
else if token_node_is_T_LAM (tok.token_node()) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = pstar_fun<s0marg> (buf, bt, p_s0marg)
    val ent3 = p_colons0rtopt (buf, bt, err) // err = err0
    val ent4 = pif_fun<token> (buf, bt, err, p_EQGT, err0)
    val ent5 = pif_fun<s0exp> (buf, bt, err, p_s0exp, err0)
  in
    if err = err0 then
      s0exp_lams (tok, l2l(ent2), ent3, ent5)
    else let
      val () = list_vt_free (ent2) in synent_null<s0exp> ()
    end // end of [if]
  end
else let
    val () = err := err + 1 in synent_null<s0exp> ()
  end (* end of [_] *)
//
end // end of [p_s0exp_tok]
//
(* ****** ****** *)
//
(*
s0rtext
  | s0rt
  | LBRACE si0de COLON s0rt BAR s0exp barsemis0expseq RBRACE
*)
//
implement
p_s0rtext
  (buf, bt, err) = let
//
val err0 = err
var ent: synent = synent_null<synent> ()
//
val n0 = tokbuf_get_ntok (buf)
val tok = tokbuf_get_token (buf)
val loc = tok.token_loc()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
ptest_fun<s0rt> (buf, p_s0rt, ent)
  then s0rtext_srt (synent_decode {s0rt} (ent))
//
else if token_node_is_T_LBRACE (tok.token_node()) then let
    val bt = 0
    val () = incby1 ()
    val ent2 = p_si0de (buf, bt, err)
    val ent3 = pif_fun<token> (buf, bt, err, p_COLON, err0)
    val ent4 = pif_fun<s0rtext> (buf, bt, err, p_s0rtext, err0)
    val ent5 = pif_fun<token> (buf, bt, err, p_BAR, err0)
    val ent6 = pif_fun<s0exp> (buf, bt, err, p_s0exp, err0)
    val ent7 = (
      if err = err0 then
        pstar_sep_fun<s0exp> (buf, bt, p_BARSEMI_test, p_s0exp)
      else list_vt_nil ()
    ) : List0_vt(s0exp)
    val ent8 = pif_fun<token> (buf, bt, err, p_RBRACE, err0)
  in
    if err = err0 then
      s0rtext_sub (tok, ent2, ent4, ent6, l2l(ent7), ent8)
    else let
      val () = list_vt_free (ent7)
      val () = the_parerrlst_add_ifnbt (bt, loc, PE_s0rtext)
    in
      tokbuf_set_ntok_null<s0rtext> (buf, n0)
    end (* end of [if] *)
  end
//
else (*error*) let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt (bt, loc, PE_s0rtext)
  in
    synent_null<s0rtext> ()
  end // end of [_]
//
end // end of [p_s0rtext]
//
(* ****** ****** *)
//
(*
s0qua
  | apps0exp
  | si0de commasi0deseq COLON s0rtext
*)
//
fun
p_s0qua_rule2 (
  buf: &tokbuf, bt: int, err: &int
) : s0qua = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok (buf)
//
val ent1 = p_si0de (buf, bt, err)
(*
val bt = 0 // HX: too many false positives
*)
val ent2 =
(
  if err = err0
    then pstar_sep_fun<i0de>(buf, bt, p_COMMA_test, p_si0de)
    else list_vt_nil((*void*))
  // end of [if]
) : List0_vt (i0de)
//
val ent3 = pif_fun<token> (buf, bt, err, p_COLON, err0)
val ent4 = pif_fun<s0rtext> (buf, bt, err, p_s0rtext, err0)
//
in
//
if
err = err0
then let
  val ent2 = l2l(ent2)
in
  s0qua_vars(ent1, ent2, ent4)
end // end of [then]
else let
  val () = list_vt_free (ent2)
in
  tokbuf_set_ntok_null<s0qua> (buf, n0)
end (* end of [else] *)
//
end // end of [p_s0qua_rule2]
//
implement
p_s0qua
  (buf, bt, err) = let
//
var ent: synent = synent_null<synent> ()
//
val tok =
  tokbuf_get_token(buf)
//
val loc = tok.token_loc()
//
in
//
if
ptest_fun<s0qua> (
  buf, p_s0qua_rule2, ent
) then synent_decode {s0qua} (ent)
else if
ptest_fun<s0exp>(buf, p_apps0exp, ent)
  then s0qua_prop(synent_decode{s0exp}(ent))
else (*rest*) let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt(bt, loc, PE_s0qua)
  in
    synent_null<s0qua> ()
  end
//
end // end of [p_s0qua]

implement
p_s0quaseq
  (buf, bt, err) =
  l2l(pstar_fun0_BARSEMI<s0qua>(buf, bt, p_s0qua))
// end of [p_s0quaseq]

(* ****** ****** *)

implement
p_eqs0expopt
  (buf, bt, err) =
  t2t(ptokentopt_fun<s0exp>(buf, is_EQ, p_s0exp))
// end of [p_eqs0expopt]

implement
p_ofs0expopt
  (buf, bt, err) =
  t2t(ptokentopt_fun<s0exp>(buf, is_OF, p_s0exp))
// end of [p_ofs0expopt]

implement
p_colons0expopt
  (buf, bt, err) =
  t2t(ptokentopt_fun<s0exp>(buf, is_COLON, p_s0exp))
// end of [p_colons0expopt]

(* ****** ****** *)

(*
q0marg ::= LBRACE s0quaseq RBRACE
*)
implement
p_q0marg (
  buf, bt, err
) : q0marg = let
//
val
err0 = err
//
val n0 =
  tokbuf_get_ntok(buf)
val tok =
  tokbuf_get_token(buf)
//
val loc = tok.token_loc()
//
macdef incby1 () = tokbuf_incby1(buf)
//
in
//
if
token_node_is_T_LBRACE (tok.token_node()) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      p_s0quaseq(buf, bt, err)
    // end of [val]
    val ent3 = p_RBRACE(buf, bt, err)
  in
    if err = err0
      then q0marg_make(tok, ent2, ent3)
      else let
        val () =
          the_parerrlst_add_ifnbt(bt, loc, PE_q0marg)
        // end of [val]
      in
        tokbuf_set_ntok_null<q0marg> (buf, n0)
      end // end of [else]
    // end of [if]
  end
else let
    val () = err := err + 1
    val () = the_parerrlst_add_ifnbt(bt, loc, PE_q0marg)
  in
    synent_null<q0marg> ()
  end
//
end // end of [p_q0marg]

implement
p_q0margseq
  (buf, bt, err) = l2l(pstar_fun<q0marg>(buf, bt, p_q0marg))
// end of [p_q0margseq]

(* ****** ****** *)

(*
cona0rgopt ::= | /*(empty)*/ | OF s0exp
*)
fun
p_cona0rgopt (
  buf: &tokbuf, bt: int, err: &int  
) : s0expopt = p_ofs0expopt (buf, bt, err)

(*
coni0ndopt ::= /*(empty)*/ | LPAREN s0expseq RPAREN
*)
fun
p_coni0ndopt (
  buf: &tokbuf, bt: int, err: &int  
) : s0expopt = let
//
val
err0 = err
//
val n0 =
  tokbuf_get_ntok(buf)
//
val tok =
  tokbuf_get_token(buf)
//
val loc = tok.token_loc()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
token_node_is_T_LPAREN (tok.token_node()) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      pstar_fun0_COMMA<s0exp>(buf, bt, p_s0exp)
    // end of [val]
    val ent3 = p_RPAREN(buf, bt, err)
  in
    if err = err0
      then let
        val ent2 = l2l(ent2)
        val s0e = s0exp_list (tok, ent2, ent3) in gopt_some (s0e)
      end // end of [then]
      else let
        val () = list_vt_free(ent2)
(*
        val () = the_parerrlst_add_ifnbt(bt, tok.i0de_loc, PE_coni0nd)
*)
      in
        tokbuf_set_ntok_null<s0expopt> (buf, n0) // HX: missing RPAREN
      end // end of [else]
    // end of [if]
  end
else gopt_none((*void*)) (*non-LPAREN*) // HX: there is no error
//
end // end of [p_coni0ndopt]

(* ****** ****** *)

(*
e0xndec ::= conq0uaseq di0de cona0rgopt
*)
implement
p_e0xndec
  (buf, bt, err) = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok (buf)
//
val ent1 =
  pstar_fun<q0marg>(buf, bt, p_q0marg)
//
val ent2 = p_di0de(buf, bt, err) // err=err0
//
val bt = 0
val ent3 = (
  if err = err0 then p_cona0rgopt(buf, bt, err) else gopt_none()
) : s0expopt // end of [val]
//
in
//
if
err = err0
then let
  val ent1 = l2l(ent1)
in
  e0xndec_make (ent1, ent2, ent3)
end // end of [then]
else let
  val () = list_vt_free(ent1) in tokbuf_set_ntok_null<e0xndec>(buf, n0)
end // end of [else]
//
end // end of [p_e0xndec]

(* ****** ****** *)
//
(*
d0atcon ::=
conq0uaseq di0de coni0ndopt cona0rgopt
*)
//
fun
p_d0atcon (
  buf: &tokbuf, bt: int, err: &int  
) : d0atcon = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok(buf)
//
val ent1 = pstar_fun<q0marg>(buf, bt, p_q0marg)
val ent2 = p_di0de(buf, bt, err) // err = err0
//
val bt = 0
val ent3 = (
  if err = err0 then p_coni0ndopt(buf, bt, err) else gopt_none()
) : s0expopt // end of [val]
val ent4 = (
  if err = err0 then p_cona0rgopt(buf, bt, err) else gopt_none()
) : s0expopt // end of [val]
//
in
//
if
err = err0
then let
  val ent1 = l2l(ent1)
in
  d0atcon_make (ent1, ent2, ent3, ent4)
end // end of [then]
else let
  val () = list_vt_free(ent1) in tokbuf_set_ntok_null<d0atcon>(buf, n0)
end // end of [else]
//
end // end of [p_d0atcon]
//
implement
p_d0atconseq
  (buf, bt, err) = let
  val _ = p_BAR_test(buf) in l2l(pstar_fun0_BAR<d0atcon> (buf, bt, p_d0atcon))
end // end of [p_d0atconseq]
//
(* ****** ****** *)

(*
//
a0typ ::=
  | s0exp0
  | pi0de COLON s0exp0
//
// s0exp0: annotation-free
//
*)
implement
p_a0typ
  (buf, bt, err) = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok (buf)
//
val
tok = tokbuf_get_token (buf)
val () = tokbuf_incby1 (buf)
//
val
tok2 = tokbuf_get_token (buf)
val () = tokbuf_set_ntok (buf, n0)
//
in
//
if
token_node_is_T_COLON (tok2.token_node()) then let
//
    val ent1 = p_pi0de(buf, bt, err)
//
    val bt = 0
    val ent2 = pif_fun<token>(buf, bt, err, p_COLON, err0)
    val ent3 = pif_fun<s0exp>(buf, bt, err, p_s0exp0, err0)
//
  in
    if err = err0
      then a0typ_make_some(ent1, ent3)
      else let
(*
        val () = the_parerrlst_add_ifnbt(bt, tok.token_loc, PE_a0typ)
*)
      in
        tokbuf_set_ntok_null<a0typ> (buf, n0)
      end (* end of [else] *)
    // end of [if]
  end
else (*non-COLON*) let
    val ent1 = p_s0exp0 (buf, bt, err)
  in
    if err = err0
      then a0typ_make_none (ent1)
      else let
(*
        val () = the_parerrlst_add_ifnbt(bt, tok.token_loc, PE_a0typ)
*)
      in
        tokbuf_set_ntok_null<a0typ> (buf, n0)
      end (* end of [else] *)
    // end of [if]
  end
//
end // end of [p_a0typ]

(* ****** ****** *)
//
vtypedef
a0typlst12 = list12 (a0typ)
//
fun
d0cstarg_atyplst12
(
  t_beg: token, ent2: a0typlst12, t_end: token
) : d0cstarg = (
  case+ ent2 of
  | ~LIST12one (xs) =>
      d0cstarg_dyn (~1, t_beg, l2l(xs), t_end)
  | ~LIST12two (xs1, xs2) => let
      val npf = list_vt_length (xs1)
      val xs12 = list_vt_append (xs1, xs2)
    in
      d0cstarg_dyn (npf, t_beg, l2l(xs12), t_end)
    end
) (* end of [d0cstarg_amtyp12] *)
//
implement
p_d0cstarg
  (buf, bt, err) = let
//
val err0 = err
var ent: synent = synent_null<synent> ()
//
val n0 = tokbuf_get_ntok (buf)
val tok = tokbuf_get_token (buf)
val tnd = tok.token_node()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if token_node_is_T_LBRACE (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      p_s0quaseq (buf, bt, err)
    // end of [val]
    val ent3 = p_RBRACE (buf, bt, err)
  in
    if err = err0
      then d0cstarg_sta (tok, ent2, ent3)
      else tokbuf_set_ntok_null<d0cstarg> (buf, n0)
    // end of [if]
  end
else if token_node_is_T_LPAREN (tnd) then let
    val bt = 0
    val () = incby1 ()
    val ent2 =
      plist12_fun<a0typ> (buf, bt, p_a0typ)
    // end of [val]
    val ent3 = p_RPAREN (buf, bt, err)
  in
    if err = err0 then
      d0cstarg_atyplst12 (tok, ent2, ent3)
    else let
      val () = list12_free<a0typ> (ent2) in tokbuf_set_ntok_null<d0cstarg>(buf, n0)
    end // end of [if]
  end
else (*error*) let
    val () = err := err + 1 in synent_null<d0cstarg> ()
  end // end of [_]
//
end // end of [p_d0cstarg]
//
(* ****** ****** *)

(*
s0vararg ::= DOTDOT | DOTDOTDOT | s0argseq
*)

fun
s0arglst_last
  (x: s0arg, xs: s0arglst): s0arg =
(
  case+ glist_view(xs) of
  | ~GLnil() => x
  | ~GLcons(x1, xs1) => s0arglst_last(x1, xs1)
) (* end of [s0arglst_last] *)

implement
p_s0vararg
  (buf, bt, err) = let
//
val tok = tokbuf_get_token (buf)
val tnd = tok.token_node()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if token_node_is_T_DOTDOT (tnd) then let
    val () = incby1 () in s0vararg_S0VARARGone(tok)
   end
else if token_node_is_T_DOTDOTDOT (tnd) then let
    val () = incby1 () in s0vararg_S0VARARGall(tok)
  end
else (*rest*) let
    val xs =
      pstar_fun0_COMMA<s0arg>(buf, bt, p_s0arg)
    // end of [val]
    val xs = l2l (xs)
    val loc = (
      case+ glist_view(xs) of
      | ~GLcons
          (x0, xs1) => let
          val x0 = x0: s0arg
        in
          if glist_is_cons(xs1)
            then let
              val x1 = s0arglst_last(x0, xs1) // HX: the last one
            in
              $LOC.location_combine (x0.s0arg_loc(), x1.s0arg_loc())
            end
            else x0.s0arg_loc()
        end // end of [GLcons]
      | ~GLnil () => tok.token_loc()
    ) : location // end of [val]
  in
    s0vararg_S0VARARGseq (loc, xs)
  end (* end of [_] *)
//
end // end of [p_s0vararg]

(*
s0exparg ::= DOTDOT | DOTDOTDOT | s0expseq
*)
implement
p_s0exparg
  (buf, bt, err) = let
//
val tok = tokbuf_get_token (buf)
val tnd = tok.token_node()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if token_node_is_T_DOTDOT (tnd) then let
    val () = incby1 () in s0exparg_S0EXPARGone()
   end
else if token_node_is_T_DOTDOTDOT (tnd) then let
    val () = incby1 () in s0exparg_S0EXPARGall()
  end
else (*rest-of-tokens*) let
    val xs =
    pstar_fun0_COMMA<s0exp>(buf, bt, p_s0exp) in s0exparg_S0EXPARGseq(l2l(xs))
  end
//
end // end of [p_s0exparg]

(* ****** ****** *)

(*
witht0ype ::= [WITHTYPE s0exp]
*)

implement
p_witht0ype
  (buf, bt, err) = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok (buf)
val tok = tokbuf_get_token (buf)
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if token_node_is_T_WITHTYPE (tok.token_node()) then let
    val knd = token_knd2_get (tok)
    val bt = 0
    val () = incby1 ()
    val ent2 = p_s0exp (buf, bt, err)
  in
    if err = err0 then
      witht0ype_WITHT0YPEsome (knd, ent2)
    else
      tokbuf_set_ntok_null<witht0ype> (buf, n0) // HX: [err] is set
    // end of [if]
  end
else witht0ype_WITHT0YPEnone () (*non-WITHTYPE*)
//
end // end of [p_witht0ype]

(* ****** ****** *)

fun
p_atms0exp_ngt
(
  buf: &tokbuf, bt: int, err: &int
) : s0exp = let
  val tok = tokbuf_get_token (buf)
in
//
if token_node_is_T_GT (tok.token_node())
  then let
    val () = err := err + 1 in synent_null<s0exp>()
  end // end of [T_GT]
  else p_atms0exp (buf, bt, err) (* non-GT *)
//
end // end of [p_atms0exp_ngt]

(* ****** ****** *)

fun
p_tmps0exp
(
  buf: &tokbuf, bt: int, err: &int
) : s0exp = let
//
fun loop
(
  x0: s0exp, xs: List0_vt(s0exp)
) : s0exp = let
in
//
case+ xs of
| ~list_vt_nil() => x0
| ~list_vt_cons(x, xs) =>
    let val x0 = s0exp_app (x0, x) in loop(x0, xs) end
  // end of [list_vt_cons]
//
end // end of [loop]
//
val xs = pstar1_fun<s0exp>(buf, bt, err, p_atms0exp_ngt)
//
in
//
case+ xs of
| ~list_vt_cons
    (x, xs) => loop(x, xs)
  // end of [cons]
| ~list_vt_nil((*void*)) => synent_null<s0exp>() // [err] is set
//
end // end of [p_tmps0exp]

implement
p_tmps0expseq
  (buf, bt, err) = let
//
val tok = tokbuf_get_token (buf)
val s0es = pstar_fun0_COMMA<s0exp>(buf, bt, p_tmps0exp)
//
in
  t0mpmarg_make (tok, l2l(s0es))
end // end of [p_tmps0expseq]

(* ****** ****** *)

implement
p_S0Ed2ctype
  (buf, bt, err) = let
//
val
err0 = err
//
val n0 = tokbuf_get_ntok (buf)
val tok = tokbuf_get_token (buf)
//
var ent: synent = synent_null<synent> ()
//
macdef incby1 () = tokbuf_incby1 (buf)
//
in
//
if
ptest_fun<i0de> (buf, p_di0de, ent)
  then d0exp_ide (synent_decode{i0de}(ent))
//
else if
ptest_fun<dqi0de> (buf, p_dqi0de, ent)
  then d0exp_dqid (synent_decode{dqi0de}(ent))
//
else if
ptest_fun<dqi0de> (
  buf, p_tmpqi0de, ent
) then let
    val bt = 0
    val ent1 = synent_decode{dqi0de}(ent)
    val ent2 = pstar_fun1_sep<t0mpmarg>(buf, bt, err, p_tmps0expseq, p_GTLT_test)
    val ent3 = pif_fun<token> (buf, bt, err, p_GT, err0)
  in
    if err = err0
      then let
        val ent2 = l2l(ent2)
      in
        d0exp_tmpid (ent1, ent2, ent3)
      end // end of [then]
      else let
        val () = list_vt_free(ent2) in synent_null<d0exp>()
      end (* end of [else] *)
    // end of [if]
  end
//
else (*rest-of-tokens*) let
    val () = err := err + 1 in synent_null<d0exp>((*error*))
  end
//
end // end of [p_S0Ed2ctype]

(* ****** ****** *)

(* end of [pats_parsing_staexp.dats] *)
