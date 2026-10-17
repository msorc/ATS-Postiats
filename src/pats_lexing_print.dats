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

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"

(* ****** ****** *)

staload "./pats_lexing.sats"

(* ****** ****** *)

implement
fprint_token
  (out, tok) = case+ token_node_view (tok.token_node()) of
//
  | ~T_AT () => fprint_string(out, "AT()")
  | ~T_BACKSLASH () => fprint_string(out, "BACKSLASH()")
  | ~T_BANG () => fprint_string(out, "BANG()")
  | ~T_BAR () => fprint_string(out, "BAR()")
  | ~T_BQUOTE () => fprint_string(out, "BQUOTE()")
  | ~T_COLON () => fprint_string(out, "COLON()")
  | ~T_DOLLAR () => fprint_string(out, "DOLLAR()")
  | ~T_DOT () => fprint_string(out, "DOT()")
  | ~T_EQ () => fprint_string(out, "EQ()")
  | ~T_HASH () => fprint_string(out, "HASH()")
  | ~T_TILDE () => fprint_string(out, "TILDE()")
  | ~T_DOTINT (x) => (fprint_string(out, "DOTINT("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_DOTDOT () => fprint_string(out, "DOTDOT()")
  | ~T_DOTDOTDOT () => fprint_string(out, "DOTDOTDOT()")
  | ~T_EQGT () => fprint_string(out, "EQGT()")
  | ~T_EQLT () => fprint_string(out, "EQLT()")
  | ~T_EQLTGT () => fprint_string(out, "EQLTGT()")
  | ~T_EQSLASHEQGT () => fprint_string(out, "EQSLASHEQGT()")
  | ~T_EQGTGT () => fprint_string(out, "EQGTGT()")
  | ~T_EQSLASHEQGTGT () => fprint_string(out, "EQSLASHEQGTGT()")
//
  | ~T_LT () => fprint_string(out, "LT()")
  | ~T_GT () => fprint_string(out, "GT()")
  | ~T_GTLT () => fprint_string(out, "GTLT()")
//
  | ~T_DOTLT () => fprint_string(out, "DOTLT()")
  | ~T_GTDOT () => fprint_string(out, "GTDOT()")
//
  | ~T_DOTLTGTDOT () =>
      fprint_string(out, "DOTLTGTDOT()")
  | ~T_MINUSGT () => fprint_string(out, "MINUSGT()")
  | ~T_MINUSLT () => fprint_string(out, "MINUSLT()")
  | ~T_MINUSLTGT () => fprint_string(out, "MINUSLTGT()")
  | ~T_COLONLT () => fprint_string(out, "COLONLT()")
//
  | ~T_ABSTYPE (x) =>
      (fprint_string(out, "ABSTYPE("); fprint_int(out, x); fprint_string(out, ")"))
    // end of [T_ABSTYPE]
//
  | ~T_ASSUME () => fprint_string(out, "ASSUME()")
  | ~T_REASSUME () => fprint_string(out, "REASSUME()")
//
  | ~T_AS () => fprint_string(out, "AS()")
  | ~T_AND () => fprint_string(out, "AND()")
  | ~T_BEGIN () => fprint_string(out, "BEGIN()")
  | ~T_CASE (x) => fprint_string(out, "CASE(...)")
  | ~T_CLASSDEC () => fprint_string(out, "CLASSDEC()")
  | ~T_DATASORT () => fprint_string(out, "DATASORT()")
  | ~T_DATATYPE (x) => (fprint_string(out, "DATATYPE("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_DO () => fprint_string(out, "DO()")
  | ~T_ELSE () => fprint_string(out, "ELSE()")
  | ~T_END () => fprint_string(out, "END()")
  | ~T_EXCEPTION () => fprint_string(out, "EXCEPTION()")
  | ~T_EXTERN () => fprint_string(out, "EXTERN()")
  | ~T_EXTYPE () => fprint_string(out, "EXTYPE()")
  | ~T_EXTVAR () => fprint_string(out, "EXTVAR()")
//
  | ~T_FIX (x) => (fprint_string(out, "FIX("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_FIXITY (x) => fprint_string(out, "FIXITY(...)")
  | ~T_FOR () => fprint_string(out, "FOR()")
  | ~T_FORSTAR () => fprint_string(out, "FORSTAR()")
  | ~T_FUN (x) => fprint_string(out, "FUN(...)")
//
  | ~T_IF () => fprint_string(out, "IF()")
  | ~T_IFCASE () => fprint_string(out, "IFCASE()")
//
  | ~T_IMPLEMENT (k) => (fprint_string(out, "IMPLEMENT("); fprint_int(out, k); fprint_string(out, ")"))
  | ~T_IMPORT () => fprint_string(out, "IMPORT()")
  | ~T_IN () => fprint_string(out, "IN()")
  | ~T_LAM (x) => (fprint_string(out, "LAM("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_LET () => fprint_string(out, "LET()")
  | ~T_LOCAL () => fprint_string(out, "LOCAL()")
  | ~T_MACDEF (x) => (fprint_string(out, "MACDEF("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_NONFIX () => fprint_string(out, "NONFIX()")
  | ~T_OF () => fprint_string(out, "OF()")
  | ~T_OP () => fprint_string(out, "OP()")
  | ~T_REC () => fprint_string(out, "REC()")
(*
  | ~T_REFAT () => fprint_string(out, "REFAT()")
*)
  | ~T_SIF () => fprint_string(out, "SIF()")
  | ~T_SCASE () => fprint_string(out, "SCASE()")
  | ~T_SORTDEF () => fprint_string(out, "SORTDEF()")
  | ~T_STACST () => fprint_string(out, "STACST()")
  | ~T_STADEF () => fprint_string(out, "STADEF()")
  | ~T_STATIC () => fprint_string(out, "STATIC()")
(*
  | ~T_STAVAR () => fprint_string(out, "STAVAR()")
*)
//
  | ~T_SYMELIM () => fprint_string(out, "SYMELIM()")
  | ~T_SYMINTR () => fprint_string(out, "SYMINTR()")
  | ~T_SYMLOAD () => fprint_string(out, "SYMLOAD()")
//
  | ~T_THEN () => fprint_string(out, "THEN()")
  | ~T_TKINDEF () =>  fprint_string(out, "TKINDEF()")
  | ~T_TRY () => fprint_string(out, "TRY()")
  | ~T_TYPE (x) => (fprint_string(out, "TYPE("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_TYPEDEF (x) => (fprint_string(out, "TYPEDEF("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_VAL (x) => fprint_string(out, "VAL(...)")
  | ~T_VAR (x) => (fprint_string(out, "VAR("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_WHEN () => fprint_string(out, "WHEN()")
  | ~T_WHERE () => fprint_string(out, "WHERE()")
  | ~T_WHILE () => fprint_string(out, "WHILE()")
  | ~T_WHILESTAR () => fprint_string(out, "WHILESTAR()")
  | ~T_WITH () => fprint_string(out, "WITH()")
  | ~T_WITHTYPE (x) => (fprint_string(out, "WITHTYPE("); fprint_int(out, x); fprint_string(out, ")"))
//
  | ~T_ADDRAT () => fprint_string(out, "ADDRAT()") // addr@
  | ~T_FOLDAT () => fprint_string(out, "FOLDAT()") // fold@
  | ~T_FREEAT () => fprint_string(out, "FREEAT()") // free@
  | ~T_VIEWAT () => fprint_string(out, "VIEWAT()") // view@
//
  | ~T_DLRDELAY (x) => (fprint_string(out, "DLRDELAY("); fprint_int(out, x); fprint_string(out, ")"))
//
  | ~T_DLRARRPSZ () => fprint_string(out, "DLRARRPSZ()")
//
  | ~T_DLRTYREP () => fprint_string(out, "DLRTYREP()")
  | ~T_DLRD2CTYPE () => fprint_string(out, "DLRD2CTYPE()")
//
  | ~T_DLREFFMASK () => fprint_string(out, "DLREFFMASK()")
  | ~T_DLREFFMASK_ARG (x) => (fprint_string(out, "DLREFFMASK("); fprint_int(out, x); fprint_string(out, ")"))
//
  | ~T_DLREXTERN () => fprint_string(out, "DLREXTERN()")
  | ~T_DLREXTKIND () => fprint_string(out, "DLREXTKIND()")
  | ~T_DLREXTYPE () => fprint_string(out, "DLREXTYPE()")
  | ~T_DLREXTYPE_STRUCT () => fprint_string(out, "DLREXTYPE_STRUCT()")
//
  | ~T_DLREXTVAL () => fprint_string(out, "DLREXTVAL()")
  | ~T_DLREXTFCALL () => fprint_string(out, "DLREXTFCALL()")
  | ~T_DLREXTMCALL () => fprint_string(out, "DLREXTMCALL()")
//
  | ~T_DLRLITERAL () => fprint_string(out, "DLRLITERAL()")
//
  | ~T_DLRMYFILENAME () => fprint_string(out, "DLRMYFILENAME()")
  | ~T_DLRMYLOCATION () => fprint_string(out, "DLRMYLOCATION()")
  | ~T_DLRMYFUNCTION () => fprint_string(out, "DLRMYFUNCTION()")
//
  | ~T_DLRLST (x) => (fprint_string(out, "DLRLST("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_DLRREC (x) => (fprint_string(out, "DLRREC("); fprint_int(out, x); fprint_string(out, ")"))
  | ~T_DLRTUP (x) => (fprint_string(out, "DLRTUP("); fprint_int(out, x); fprint_string(out, ")"))
//
  | ~T_DLRBREAK () => fprint_string(out, "DLRBREAK()")
  | ~T_DLRCONTINUE () => fprint_string(out, "DLRCONTINUE()")
//
  | ~T_DLRRAISE () => fprint_string(out, "DLRRAISE()")
//
  | ~T_DLRVARARG () => fprint_string(out, "DLRVARARG()")
//
  | ~T_DLRVCOPYENV (x) => (fprint_string(out, "DLRVCOPYENV("); fprint_int(out, x); fprint_string(out, ")"))
//
  | ~T_DLRSHOWTYPE () => fprint_string(out, "DLRSHOWTYPE()")
//
  | ~T_DLRTEMPENVER () => fprint_string(out, "DLRTEMPENVER()")
//
  | ~T_DLRSOLASSERT () => fprint_string(out, "DLRSOLASSERT()")
  | ~T_DLRSOLVERIFY () => fprint_string(out, "DLRSOLVERIFY()")
//
  | ~T_SRPIF () => fprint_string(out, "SRPIF()")
  | ~T_SRPIFDEF () => fprint_string(out, "SRPIFDEF()")
  | ~T_SRPIFNDEF () => fprint_string(out, "SRPIFNDEF()")
  | ~T_SRPTHEN () => fprint_string(out, "SRPTHEN()")
  | ~T_SRPELSE () => fprint_string(out, "SRPELSE()")
  | ~T_SRPELIF () => fprint_string(out, "SRPELIF()")
  | ~T_SRPELIFDEF () => fprint_string(out, "SRPELIFDEF()")
  | ~T_SRPELIFNDEF () => fprint_string(out, "SRPELIFNDEF()")
  | ~T_SRPENDIF () => fprint_string(out, "SRPENDIF()")
//
  | ~T_SRPERROR () => fprint_string(out, "SRPERROR()")
  | ~T_SRPPRERR () => fprint_string(out, "SRPPRERR()")
  | ~T_SRPPRINT () => fprint_string(out, "SRPPRINT()")
//
  | ~T_SRPASSERT () => fprint_string(out, "SRPASSERT()")
//
  | ~T_SRPUNDEF () => fprint_string(out, "SRPUNDEF()")
  | ~T_SRPDEFINE () => fprint_string(out, "SRPDEFINE()")
//
  | ~T_SRPINCLUDE () => fprint_string(out, "SRPINCLUDE()")
//
  | ~T_SRPSTALOAD () => fprint_string(out, "SRPSTALOAD()")
  | ~T_SRPDYNLOAD () => fprint_string(out, "SRPDYNLOAD()")
//
  | ~T_SRPREQUIRE () => fprint_string(out, "SRPREQUIRE()")
//
  | ~T_SRPPRAGMA () => fprint_string(out, "SRPPRAGMA()")
  | ~T_SRPCODEGEN2 () => fprint_string(out, "SRPCODEGEN2()")
  | ~T_SRPCODEGEN3 () => fprint_string(out, "SRPCODEGEN3()")
//
  | ~T_IDENT_alp (x) => (fprint_string(out, "IDENT_alp("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_sym (x) => (fprint_string(out, "IDENT_sym("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_arr (x) => (fprint_string(out, "IDENT_arr("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_tmp (x) => (fprint_string(out, "IDENT_tmp("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_dlr (x) => (fprint_string(out, "IDENT_dlr("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_srp (x) => (fprint_string(out, "IDENT_srp("); fprint_string(out, x); fprint_string(out, ")"))
  | ~T_IDENT_ext (x) => (fprint_string(out, "IDENT_ext("); fprint_string(out, x); fprint_string(out, ")"))
//
  | ~T_INT (base, rep, sfx) =>
      (fprint_string(out, "INT("); fprint_int(out, base); fprint_string(out, "; "); fprint_string(out, rep); fprint_string(out, ")"))
  | ~T_CHAR (x) => (fprint_string(out, "CHAR("); fprint_char(out, x); fprint_string(out, ")"))
  | ~T_FLOAT (base, rep, sfx) =>
      (fprint_string(out, "FLOAT("); fprint_int(out, base); fprint_string(out, "; "); fprint_string(out, rep); fprint_string(out, ")"))
//
  | ~T_CDATA _ => fprint_string(out, "CDATA(...)")
  | ~T_STRING (x) => (fprint_string(out, "STRING("); fprint_string(out, x); fprint_string(out, ")"))
//
(*
  | ~T_LABEL (knd, x) => (fprint_string(out, "LABEL("); fprint_int(out, knd); fprint_string(out, "; "); fprint_string(out, x); fprint_string(out, ")"))
*)
//
  | ~T_COMMA () => fprint_string(out, "COMMA()")
  | ~T_SEMICOLON () => fprint_string(out, "SEMICOLON()")
//
  | ~T_LPAREN () => fprint_string(out, "LPAREN()")
  | ~T_RPAREN () => fprint_string(out, "RPAREN()")
  | ~T_LBRACKET () => fprint_string(out, "LBRACKET()")
  | ~T_RBRACKET () => fprint_string(out, "RBRACKET()")
  | ~T_LBRACE () => fprint_string(out, "LBRACE()")
  | ~T_RBRACE () => fprint_string(out, "RBRACE()")
//
  | ~T_ATLPAREN () => fprint_string(out, "ATLPAREN()")
  | ~T_QUOTELPAREN () => fprint_string(out, "QUOTELPAREN()")
  | ~T_ATLBRACKET () => fprint_string(out, "ATLBRACKET()")
  | ~T_QUOTELBRACKET () => fprint_string(out, "QUOTELBRACKET()")
  | ~T_HASHLBRACKET () => fprint_string(out, "HASHLBRACKET()")
  | ~T_ATLBRACE () => fprint_string(out, "ATLBRACE()")
  | ~T_QUOTELBRACE () => fprint_string(out, "QUOTELBRACE()")
//
  | ~T_BQUOTELPAREN () => fprint_string(out, "BQUOTELPAREN()")
  | ~T_COMMALPAREN () => fprint_string(out, "COMMALPAREN()")
  | ~T_PERCENTLPAREN () => fprint_string(out, "PERCENTLPAREN()")
//
  | ~T_EXTCODE (knd, x) => (fprint_string(out, "EXTCODE("); fprint_int(out, knd); fprint_string(out, ", "); fprint_string(out, x); fprint_string(out, ")"))
//
  | ~T_COMMENT_line () => fprint_string(out, "COMMENT_line()")
  | ~T_COMMENT_block () => fprint_string(out, "COMMENT_block()")
  | ~T_COMMENT_rest () => fprint_string(out, "COMMENT_rest()")
//
  | ~T_ERR () => fprint_string(out, "ERR()")
  | ~T_EOF () => fprint_string(out, "EOF()")
//
  | ~T_NONE () => fprint_string(out, "NONE()")
(*
  | _ => fprint_string(out, "TOKEN()")
*)
//
(* end of [fprint_token] *)

implement print_token (tok) = fprint_token (stdout_ref, tok)
implement prerr_token (tok) = fprint_token (stderr_ref, tok)

(* ****** ****** *)

(* end of [pats_lexing_print.dats] *)
