(* ****** ****** *)
//
// HX-2026-10: no GC
//
// Included by [pats_syntax.dats] and [pats_syntax_print.dats]: what
// the ATS1 code did by [val-T_STRING(str) = tok.token_node] is a match
// on [token_node_view(tok.token_node())] here, and the (linear) view is
// freed by [token_node_view_free]. A token of another kind is a bug of
// the caller (the parser): [assertloc] fails (the MatchError of ATS1).
//
(* ****** ****** *)

fn
token_int_rep(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_INT(_, rep, _) => rep // [T_INT(base, rep, sfx)]
| v => (token_node_view_free(v); (assertloc(false); ""))
)

fn
token_float_rep(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_FLOAT(_, rep, _) => rep // [T_FLOAT(base, rep, sfx)]
| v => (token_node_view_free(v); (assertloc(false); ""))
)

fn
token_char_get(tok: token): char =
(
case+ token_node_view(tok.token_node()) of
| ~T_CHAR(c) => c
| v => (token_node_view_free(v); (assertloc(false); 'a'))
)

fn
token_string_get(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_STRING(str) => str
| v => (token_node_view_free(v); (assertloc(false); ""))
)

fn
token_ident_dlr_get(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_IDENT_dlr(name) => name
| v => (token_node_view_free(v); (assertloc(false); ""))
)

// [T_TYPE(knd)], [T_TYPEDEF(knd)], [T_IMPLEMENT(knd)] and [T_DOTINT(int)]
fn
token_knd_get(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_TYPE(knd) => knd
| ~T_TYPEDEF(knd) => knd
| ~T_IMPLEMENT(knd) => knd
| ~T_DOTINT(int) => int
| v => (token_node_view_free(v); (assertloc(false); 0))
)

fn
token_fixity_get(tok: token): fxtykind =
(
case+ token_node_view(tok.token_node()) of
| ~T_FIXITY(knd) => knd
| v => (token_node_view_free(v); (assertloc(false); FXK_infix))
)

fn
token_extcode_pos(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_EXTCODE(pos, _) => pos
| v => (token_node_view_free(v); (assertloc(false); 0))
)

fn
token_extcode_code(tok: token): string =
(
case+ token_node_view(tok.token_node()) of
| ~T_EXTCODE(_, code) => code
| v => (token_node_view_free(v); (assertloc(false); ""))
)

// 0/1/2: if/ifdef/ifndef for T_SRPIF, T_SRPIFDEF, T_SRPIFNDEF
fn
token_srpif_get(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_SRPIF() => 0
| ~T_SRPIFDEF() => 1
| ~T_SRPIFNDEF() => 2
| v => (token_node_view_free(v); (assertloc(false); 0))
)

// 0/1/2: elif/elifdef/elifndef for T_SRPELIF, T_SRPELIFDEF, T_SRPELIFNDEF
fn
token_srpelif_get(tok: token): int =
(
case+ token_node_view(tok.token_node()) of
| ~T_SRPELIF() => 0
| ~T_SRPELIFDEF() => 1
| ~T_SRPELIFNDEF() => 2
| v => (token_node_view_free(v); (assertloc(false); 0))
)

(* ****** ****** *)

(* end of [pats_syntax_token.hats] *)
