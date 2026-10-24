(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(* ****** ****** *)
//
// HX-2026-10: no GC
//
// Included by the .dats files of the parser: what the ATS1 code did by
// [case+ tok.token_node of T_DLRTUP(knd) => ..] with the payload of a token
// is a call of a helper here (a wrong token is a bug of the caller:
// [assertloc] fails). Add the helpers that the parsers of dynamic
// expressions, patterns and declarations need here too.
// (The helpers of [pats_syntax_token.hats] -- [token_string_get],
// [token_knd_get]... -- are included by the .dats files that need them.)
//
(* ****** ****** *)

// the [int] of [T_DLRTUP(knd)], [T_DLRREC(knd)] and [T_WITHTYPE(knd)]
fn
token_knd2_get(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_DLRTUP(knd) => knd
| ~T_DLRREC(knd) => knd
| ~T_WITHTYPE(knd) => knd
| v => (token_node_view_free(v); (assertloc(false); 0))
)

(* ****** ****** *)
//
// the payloads used by the parsers of dynamic expressions, patterns
// and declarations (a wrong token is a bug of the caller)
//
// the [int] of the tokens: T_DLRLST, T_DLRTUP, T_DLRREC, T_ABSTYPE, T_MACDEF, T_TYPEDEF,
// T_DATATYPE, T_VAR, T_IMPLEMENT, T_LAM, T_FIX, T_DLRVCOPYENV, T_DLRDELAY, T_DLREFFMASK_ARG
fn
token_ival_get(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_DLRLST(x) => x
| ~T_DLRTUP(x) => x
| ~T_DLRREC(x) => x
| ~T_ABSTYPE(x) => x
| ~T_MACDEF(x) => x
| ~T_TYPEDEF(x) => x
| ~T_DATATYPE(x) => x
| ~T_VAR(x) => x
| ~T_IMPLEMENT(x) => x
| ~T_LAM(x) => x
| ~T_FIX(x) => x
| ~T_DLRVCOPYENV(x) => x
| ~T_DLRDELAY(x) => x
| ~T_DLREFFMASK_ARG(x) => x
| v => (token_node_view_free(v); (assertloc(false); 0))
)

// the [string] of T_IDENT_alp, T_IDENT_sym, T_IDENT_arr, T_IDENT_tmp, T_IDENT_dlr, T_STRING
fn
token_sval_get(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_IDENT_alp(x) => x
| ~T_IDENT_sym(x) => x
| ~T_IDENT_arr(x) => x
| ~T_IDENT_tmp(x) => x
| ~T_IDENT_dlr(x) => x
| ~T_STRING(x) => x
| v => (token_node_view_free(v); (assertloc(false); ""))
)

fn
token_fun_get(tok: token): funkind =
(
case+ token_node_view(tok.token_node()) of
| ~T_FUN(x) => x
| v => (token_node_view_free(v); (assertloc(false); FK_fn))
)

fn
token_val_get(tok: token): valkind =
(
case+ token_node_view(tok.token_node()) of
| ~T_VAL(x) => x
| v => (token_node_view_free(v); (assertloc(false); VK_val))
)

(* ****** ****** *)

(* end of [pats_parsing.hats] *)
