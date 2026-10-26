(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: a linter for ATS2 source files
//
// The text of a file is lexed by the lexer of the compiler
// (libatsynmark/libatsopt): its tokens tell which bytes are in
// a comment, a string or a char literal, or embedded C code, and
// the rules check the lines of the file with this knowledge.
//
(* ****** ****** *)
//
%{#
#include "utils/atslint/CATS/patslint.cats"
%}
//
(* ****** ****** *)
//
// the rules: an id is an index in the table of the rules
//
#define RULE_tab 0
#define RULE_trailing_ws 1
#define RULE_line_length 2
#define RULE_crlf 3
#define RULE_final_newline 4
#define RULE_blank_eof 5
#define RULE_indent 6
#define RULE_non_ascii 7
#define RULE_lex_error 8
//
// on the tokens (and the messages of the parser)
//
#define RULE_parse_error 9
#define RULE_footer 10
#define RULE_separator 11
#define RULE_comma_space 12
#define RULE_trailing_semicolon 13
//
// on the syntax tree (level 0)
//
#define RULE_staload_dup 14
#define RULE_staload_unused 15
#define RULE_let_empty 16
#define RULE_case_single 17
#define RULE_case_unchecked 18
#define RULE_end_comment 19
#define RULE_fnx_template 20
#define RULE_if_const 21
#define RULE_naming 22
//
// after the binding of the names (level 2, --semantic)
//
#define RULE_unused_var 23
#define RULE_unused_fun 24
#define RULE_unused_arg 25
#define RULE_shadow 26
#define RULE_nonexhaustive 27
//
#define NRULE 28
//
// the severities; a rule that is off has the severity SEV_off
//
#define SEV_off ~1
#define SEV_info 0
#define SEV_warning 1
#define SEV_error 2
//
(* ****** ****** *)
//
fun
rule_get_name (id: int): string = "ext#patslint_rule_name"
fun rule_get_descr (id: int): string
//
// the severity of a rule when it is enabled without a severity,
// and whether it is enabled by default
//
fun
rule_get_defsev (id: int): int = "ext#patslint_rule_defsev"
fun rule_is_defon (id: int): bool
//
// the rules that need [--semantic]
//
fun rule_is_semantic (id: int): bool
//
// the id of the rule of the given name, ~1 if there is none
//
fun
rule_find (name: string): int = "ext#patslint_rule_find"
//
fun
sev_get_name (sev: int): string = "ext#patslint_sev_name"
//
// the severity of the given name ("off" gives SEV_off),
// ~2 if there is none
//
fun
sev_find (name: string): int = "ext#patslint_sev_find"
//
(* ****** ****** *)
//
// the settings that apply to the current file (kept in C)
//
fun
the_rule_get_sev (id: int): int = "mac#patslint_rule_get_sev"
fun
the_rule_set_sev
  (id: int, sev: int): void = "mac#patslint_rule_set_sev"
//
fun the_maxcol_get (): int = "mac#patslint_maxcol_get"
fun the_maxcol_set (n: int): void = "mac#patslint_maxcol_set"
fun the_indent_get (): int = "mac#patslint_indent_get"
fun the_indent_set (n: int): void = "mac#patslint_indent_set"
//
// the default settings (every rule at its default)
//
fun the_settings_reset (): void
//
(* ****** ****** *)
//
// the options of the command line, kept to be replayed on
// the settings of each file (after its configuration file)
//
fun
the_cmdopt_rule_add
  (id: int, sev: int): void = "mac#patslint_cmdopt_rule_add"
fun the_cmdopt_maxcol_set (n: int): void = "mac#patslint_cmdopt_maxcol_set"
fun the_cmdopt_indent_set (n: int): void = "mac#patslint_cmdopt_indent_set"
//
fun the_cmdopt_apply (): void = "mac#patslint_cmdopt_apply"
//
// [--lines=N-M,...]: 0 if the ranges are not well-formed
//
fun
the_lines_set (spec: string): int = "mac#patslint_lines_set"
fun the_lines_clear (): void = "mac#patslint_lines_clear"
//
// whether a finding on this line is reported (no --lines: all)
//
fun the_lines_test (line: int): bool = "mac#patslint_lines_test"
//
(* ****** ****** *)
//
// the configuration file: the nearest [.patslint] in the
// directory of the file or in a parent directory. It returns
// 0 if there is none, 1 if it is read, ~1 if it has errors
// (they are reported to stderr), and 2 if the file is excluded.
//
fun
the_config_load (path: string): int = "mac#patslint_config_load"
//
// the number of errors in the configuration files (each file is
// counted once), and the release of the memory of their names
//
fun the_config_nerror (): int = "mac#patslint_config_nerror"
fun the_config_clear (): void = "mac#patslint_config_clear"
//
(* ****** ****** *)
//
// the text of a file: its bytes, and for each byte its kind
//
#define MASK_code 0
#define MASK_comment 1
#define MASK_string 2
#define MASK_extcode 3
//
absvtype textbuf = ptr
//
// [None_vt] if the file cannot be read
//
fun
textbuf_make_file (path: string): Option_vt (textbuf)
fun
textbuf_free (buf: textbuf): void = "mac#patslint_textbuf_free"
//
// a byte is in 0..255 (~1 out of the text)
//
fun
textbuf_get_size (buf: !textbuf): int = "mac#patslint_textbuf_size"
fun
textbuf_get_char
  (buf: !textbuf, i: int): int = "mac#patslint_textbuf_char"
fun
textbuf_get_mask
  (buf: !textbuf, i: int): int = "mac#patslint_textbuf_mask"
fun
textbuf_set_mask
  (buf: !textbuf, i: int, k: int): void = "mac#patslint_textbuf_set_mask"
//
// the comments of the form [lint: disable=RULE,...] (on a line
// or the line before) and [lint: disable-file=RULE,...]; they are
// read from the bytes masked as comments
//
fun
textbuf_directives
  (buf: !textbuf): void = "mac#patslint_textbuf_directives"
fun
textbuf_disabled
  (buf: !textbuf, line: int, rule: int): bool = "mac#patslint_textbuf_disabled"
//
// the line (from 1) and the column (from 1, in characters) of an
// offset; the offset of the start of a line
//
fun
textbuf_line_of
  (buf: !textbuf, off: int): int = "mac#patslint_textbuf_line"
fun
textbuf_col_of
  (buf: !textbuf, off: int): int = "mac#patslint_textbuf_col"
fun
textbuf_line_start
  (buf: !textbuf, line: int): int = "mac#patslint_textbuf_line_start"
fun
textbuf_get_nline (buf: !textbuf): int = "mac#patslint_textbuf_nline"
//
// the text as a list of chars (for the lexer of the compiler)
//
fun
textbuf_charlst (buf: !textbuf): List0_vt(char)
//
// the bytes [beg, end) are the string [s]; the offset of [s] in
// [beg, end) (~1 if it is not there); a copy of [beg, end) that
// lives until the next call
//
fun
textbuf_eq
(
  buf: !textbuf, beg: int, fin: int, s: string
) : bool = "mac#patslint_textbuf_eq"
fun
textbuf_find
(
  buf: !textbuf, beg: int, fin: int, s: string
) : int = "mac#patslint_textbuf_find"
fun
textbuf_substr
  (buf: !textbuf, beg: int, fin: int): string = "mac#patslint_textbuf_substr"
//
(* ****** ****** *)
//
// the tokens of the text (comments included): a kind and the
// offsets of the first byte and after the last one
//
#define TOK_other 0
#define TOK_comment 1
#define TOK_string 2
#define TOK_char 3
#define TOK_extcode 4
#define TOK_err 5
#define TOK_comma 6
#define TOK_semicolon 7
#define TOK_end 8
#define TOK_in 9
#define TOK_lparen 10
#define TOK_rparen 11
#define TOK_rbracket 12
#define TOK_rbrace 13
#define TOK_ident_dlr 14
#define TOK_lbracket 15
#define TOK_lbrace 16
//
fun
textbuf_tok_add
(
  buf: !textbuf, kind: int, beg: int, fin: int
) : void = "mac#patslint_textbuf_tok_add"
fun
textbuf_get_ntok (buf: !textbuf): int = "mac#patslint_textbuf_ntok"
fun
textbuf_tok_kind (buf: !textbuf, i: int): int = "mac#patslint_textbuf_tok_kind"
fun
textbuf_tok_beg (buf: !textbuf, i: int): int = "mac#patslint_textbuf_tok_beg"
fun
textbuf_tok_end (buf: !textbuf, i: int): int = "mac#patslint_textbuf_tok_end"
//
// the index of the first token that starts at [off] or after it
//
fun
textbuf_tok_index
  (buf: !textbuf, off: int): int = "mac#patslint_textbuf_tok_index"
//
(* ****** ****** *)
//
// the messages of the compiler (lexer, parser, ...): a memory stream
// is given to the printing function of the compiler, then each of its
// lines becomes a message of the text (an offset, a rule, a text)
//
fun
memout_open (): FILEref = "mac#patslint_memout_open"
fun
memout_close
  (buf: !textbuf, out: FILEref, rule: int): void = "mac#patslint_memout_close"
//
fun
textbuf_get_nerr (buf: !textbuf): int = "mac#patslint_textbuf_nerr"
fun
textbuf_err_off (buf: !textbuf, i: int): int = "mac#patslint_textbuf_err_off"
fun
textbuf_err_rule (buf: !textbuf, i: int): int = "mac#patslint_textbuf_err_rule"
fun
textbuf_err_msg (buf: !textbuf, i: int): string = "mac#patslint_textbuf_err_msg"
//
(* ****** ****** *)
//
// the output of the findings
//
#define FORMAT_text 0
#define FORMAT_json 1
//
fun the_format_get (): int = "mac#patslint_format_get"
fun the_format_set (fmt: int): void = "mac#patslint_format_set"
//
fun the_failon_get (): int = "mac#patslint_failon_get"
fun the_failon_set (sev: int): void = "mac#patslint_failon_set"
//
fun the_nfail_get (): int = "mac#patslint_nfail_get"
fun the_nfound_get (): int = "mac#patslint_nfound_get"
//
// a message formatted with two numbers (%d); it lives until the
// next call
//
fun
msg_format2
  (fmt: string, a: int, b: int): string = "mac#patslint_msg_format2"
fun
msg_format2s
  (fmt: string, a: string, b: string): string = "mac#patslint_msg_format2s"
//
// the findings of a file are kept by [finding_report], then sorted
// and printed by [findings_flush] (it returns their number); in the
// text format, each one is followed by its line and a caret under its
// column if --source is on (by default: if the output is a terminal)
//
fun
finding_report
(
  path: string
, line: int, col: int, rule: int, msg: string
) : void = "mac#patslint_finding_report"
fun
findings_flush
  (path: string, buf: !textbuf): int = "mac#patslint_findings_flush"
//
// --source (1), --no-source (0), the default (~1)
//
fun the_source_set (k: int): void = "mac#patslint_source_set"
//
(* ****** ****** *)
//
// reporting a finding at an offset of the text, if the rule is on
// on its line (the options, --lines, the comments that disable it)
//
fun
rule_is_active
  (buf: !textbuf, line: int, rule: int): bool
fun
report_at
(
  path: string, buf: !textbuf, off: int, rule: int, msg: string
) : void
//
// the rules on the tokens (patslint_token.dats) and on the syntax
// tree (patslint_tree.dats); [stadyn] is 0 for a .sats file
//
fun
patslint_tokens (path: string, buf: !textbuf): void
fun
patslint_tree (path: string, buf: !textbuf, stadyn: int): void
//
// --semantic: the rules after the binding of the names
// (patslint_sema.dats)
//
fun the_semantic_get (): bool = "mac#patslint_semantic_get"
//
// a memory stream whose text (on one line) is returned on its close;
// the text lives until the next close
//
fun memstr_open (): FILEref = "mac#patslint_memstr_open"
fun memstr_close (out: FILEref): string = "mac#patslint_memstr_close"
//
// what the compiler prints (to stderr, and to stdout for the #print
// of the code) is dropped between [stderr_off] and [stderr_on]
//
fun stderr_off (): void = "mac#patslint_stderr_off"
fun stderr_on (): void = "mac#patslint_stderr_on"
fun the_semantic_set (b: bool): void = "mac#patslint_semantic_set"
//
fun
patslint_sema (path: string, buf: !textbuf, stadyn: int): void
//
(* ****** ****** *)
//
// [--fix]: the fixed text is written to [path.patslint-fix]
// and renamed over [path] at the end; 0 if it fails
//
fun the_fix_get (): bool = "mac#patslint_fix_get"
fun the_fix_set (b: bool): void = "mac#patslint_fix_set"
//
fun fixout_open (path: string): int = "mac#patslint_fixout_open"
fun fixout_putc (c: int): void = "mac#patslint_fixout_putc"
fun fixout_close (path: string, commit: bool): int = "mac#patslint_fixout_close"
//
(* ****** ****** *)
//
// linting a file: the number of reported findings
//
fun patslint_file (path: string): int
//
(* ****** ****** *)

(* end of [patslint.sats] *)
