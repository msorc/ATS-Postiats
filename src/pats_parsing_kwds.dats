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
// HX-2026-10: no GC. [is_X(tnode)] tests the tag of a token node.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_symbol.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_lexing.sats" // for tokenizing
staload "./pats_tokbuf.sats" // for token buffering

(* ****** ****** *)

staload "./pats_parsing.sats"


(* ****** ****** *)

implement
is_AS (x) = token_node_is_T_AS (x)
implement
p_AS (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_AS, PE_AS)

(* ****** ****** *)

implement
is_AND (x) = token_node_is_T_AND (x)
implement
p_AND (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_AND, PE_AND)
implement
p_AND_test (buf) = ptoken_test_fun (buf, is_AND)

(* ****** ****** *)

implement
is_END (x) = token_node_is_T_END (x)
implement
p_END (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_END, PE_END)

(* ****** ****** *)

implement
is_OF (x) = token_node_is_T_OF (x)
implement
p_OF (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_OF, PE_OF)

implement
is_IN (x) = token_node_is_T_IN (x)
implement
p_IN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_IN, PE_IN)

(* ****** ****** *)

implement
is_IF (x) = token_node_is_T_IF (x)
implement
p_IF (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_IF, PE_IF)
implement
is_SIF (x) = token_node_is_T_SIF (x)
implement
p_SIF (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_SIF, PE_SIF)

(* ****** ****** *)

implement
is_CASE (x) = token_node_is_T_CASE (x)
implement
p_CASE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_CASE, PE_CASE)
implement
is_SCASE (x) = token_node_is_T_SCASE (x)
implement
p_SCASE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_SCASE, PE_SCASE)

(* ****** ****** *)

implement
is_IFCASE (x) = token_node_is_T_IFCASE (x)
implement
p_IFCASE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_IFCASE, PE_IFCASE)

(* ****** ****** *)

implement
is_THEN (x) = token_node_is_T_THEN (x)
implement
p_THEN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_THEN, PE_THEN)

implement
is_ELSE (x) = token_node_is_T_ELSE (x)
implement
p_ELSE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_ELSE, PE_ELSE)

(* ****** ****** *)

implement
is_REC (x) = token_node_is_T_REC (x)
implement
p_REC (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_REC, PE_REC)
implement
p_REC_test (buf) = ptoken_test_fun (buf, is_REC)

(* ****** ****** *)

implement
is_WITH (x) = token_node_is_T_WITH (x)
implement
p_WITH (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_WITH, PE_WITH)

implement
is_WHEN (x) = token_node_is_T_WHEN (x)
implement
p_WHEN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_WHEN, PE_WHEN)

(* ****** ****** *)

implement
is_FORSTAR (x) = token_node_is_T_FORSTAR (x)
implement
p_FORSTAR (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_FORSTAR, PE_FOR)

implement
is_WHILESTAR (x) = token_node_is_T_WHILESTAR (x)
implement
p_WHILESTAR (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_WHILESTAR, PE_WHILE)

implement
is_TRY (x) = token_node_is_T_TRY (x)
implement
p_TRY (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_TRY, PE_TRY)

(* ****** ****** *)

implement
is_BAR (x) = token_node_is_T_BAR (x)
implement
p_BAR (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_BAR, PE_BAR)
implement
p_BAR_test (buf) = ptoken_test_fun (buf, is_BAR)

implement
is_COLON (x) = token_node_is_T_COLON (x)
implement
p_COLON (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_COLON, PE_COLON)
implement
p_COLON_test (buf) = ptoken_test_fun (buf, is_COLON)

implement
is_COMMA (x) = token_node_is_T_COMMA (x)
implement
p_COMMA (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_COMMA, PE_COMMA)
implement
p_COMMA_test (buf) = ptoken_test_fun (buf, is_COMMA)

implement
is_SEMICOLON (x) = token_node_is_T_SEMICOLON (x)
implement
p_SEMICOLON (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_SEMICOLON, PE_SEMICOLON)
implement
p_SEMICOLON_test
  (buf) = ptoken_test_fun (buf, is_SEMICOLON)
// end of [p_SEMICOLON_test]

implement
is_BARSEMI (x) =
  token_node_is_T_BAR (x) || token_node_is_T_SEMICOLON (x)
implement
p_BARSEMI_test (buf) = ptoken_test_fun (buf, is_BARSEMI)

(* ****** ****** *)

implement
is_LPAREN (x) = token_node_is_T_LPAREN (x)
implement
p_LPAREN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_LPAREN, PE_LPAREN)

implement
is_RPAREN (x) = token_node_is_T_RPAREN (x)
implement
p_RPAREN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_RPAREN, PE_RPAREN)

(* ****** ****** *)

implement
is_LBRACKET (x) = token_node_is_T_LBRACKET (x)
implement
p_LBRACKET (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_LBRACKET, PE_LBRACKET)

implement
is_RBRACKET (x) = token_node_is_T_RBRACKET (x)
implement
p_RBRACKET (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_RBRACKET, PE_RBRACKET)

(* ****** ****** *)

implement
is_LBRACE (x) = token_node_is_T_LBRACE (x)
implement
p_LBRACE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_LBRACE, PE_LBRACE)

implement
is_RBRACE (x) = token_node_is_T_RBRACE (x)
implement
p_RBRACE (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_RBRACE, PE_RBRACE)

(* ****** ****** *)

implement
is_BANG (x) = token_node_is_T_BANG (x)
implement
p_BANG (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_BANG, PE_BANG)
// end of [p_BANG]

implement
is_DOT (x) = token_node_is_T_DOT (x)
implement
p_DOT (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_DOT, PE_DOT)
// end of [p_DOT]

implement
is_EQ (x) = token_node_is_T_EQ (x)
implement
p_EQ (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_EQ, PE_EQ)
// end of [p_EQ]

implement
is_EQGT (x) = token_node_is_T_EQGT (x)
// end of [is_EQGT]
implement
p_EQGT (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_EQGT, PE_EQGT)
// end of [p_EQGT]

implement
is_GT (x) = token_node_is_T_GT (x)
// end of [is_GT]
implement
p_GT (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_GT, PE_GT)
// end of [p_GT]

implement
is_GTDOT (x) = token_node_is_T_GTDOT (x)
// end of [is_GTDOT]
implement
p_GTDOT (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_GTDOT, PE_GTDOT)
// end of [p_GTDOT]

implement
is_GTLT (x) = token_node_is_T_GTLT (x)
// end of [is_GTLT]
implement
p_GTLT (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_GTLT, PE_GTLT)
// end of [p_GTLT]
implement
p_GTLT_test (buf) = ptoken_test_fun (buf, is_GTLT)

(* ****** ****** *)

implement
is_SRPTHEN (x) = token_node_is_T_SRPTHEN (x)
// end of [is_SRPTHEN]
implement
p_SRPTHEN (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_SRPTHEN, PE_SRPTHEN)
// end of [p_SRPTHEN]

implement
is_SRPENDIF (x) = token_node_is_T_SRPENDIF (x)
// end of [is_SRPENDIF]
implement
p_SRPENDIF (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_SRPENDIF, PE_SRPENDIF)
// end of [p_SRPENDIF]

(* ****** ****** *)

implement
is_EOF (x) = token_node_is_T_EOF (x)
// end of [is_EOF]
implement
p_EOF (buf, bt, err) =
  ptoken_fun (buf, bt, err, is_EOF, PE_EOF)
// end of [p_EOF]

(* ****** ****** *)

implement
is_ATLPAREN (x) = token_node_is_T_ATLPAREN (x)
// end of [is_ATLPAREN]
implement
is_LPAREN_deco (x) =
  token_node_is_T_ATLPAREN (x) || token_node_is_T_QUOTELPAREN (x)
// end of [is_LPAREN_deco]

implement
is_ATLBRACE (x) = token_node_is_T_ATLBRACE (x)
// end of [is_ATLBRACE]
implement
is_LBRACE_deco (x) =
  token_node_is_T_ATLBRACE (x) || token_node_is_T_QUOTELBRACE (x)
// end of [is_LBRACE_deco]

(* ****** ****** *)

(* end of [pats_parsing_kwds.dats] *)
