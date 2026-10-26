(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the table of the rules
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)

implement
rule_get_name (id) =
(
case+ id of
| RULE_tab => "tab"
| RULE_trailing_ws => "trailing-ws"
| RULE_line_length => "line-length"
| RULE_crlf => "crlf"
| RULE_final_newline => "final-newline"
| RULE_blank_eof => "blank-eof"
| RULE_indent => "indent"
| RULE_non_ascii => "non-ascii"
| RULE_lex_error => "lex-error"
| RULE_parse_error => "parse-error"
| RULE_footer => "footer"
| RULE_separator => "separator"
| RULE_comma_space => "comma-space"
| RULE_trailing_semicolon => "trailing-semicolon"
| RULE_staload_dup => "staload-dup"
| RULE_staload_unused => "staload-unused"
| RULE_let_empty => "let-empty"
| RULE_case_single => "case-single"
| RULE_case_unchecked => "case-unchecked"
| RULE_end_comment => "end-comment"
| RULE_fnx_template => "fnx-template"
| RULE_if_const => "if-const"
| RULE_naming => "naming"
| RULE_unused_var => "unused-var"
| RULE_unused_fun => "unused-fun"
| RULE_unused_arg => "unused-arg"
| RULE_shadow => "shadow"
| RULE_nonexhaustive => "nonexhaustive"
| _ (*unknown*) => "unknown"
) (* end of [rule_get_name] *)

implement
rule_get_descr (id) =
(
case+ id of
| RULE_tab => "a tab character (outside strings)"
| RULE_trailing_ws => "white space at the end of a line"
| RULE_line_length => "a line longer than max-col"
| RULE_crlf => "CRLF line ends"
| RULE_final_newline => "no newline at the end of the file"
| RULE_blank_eof => "blank lines at the end of the file"
| RULE_indent => "an indentation that is not a multiple of indent-width"
| RULE_non_ascii => "a non-ASCII character outside comments and strings"
| RULE_lex_error => "an error of the lexer (an unclosed comment, string, ...)"
| RULE_parse_error => "the first error of the parser"
| RULE_footer => "a comment (* end of [NAME] *) that names another file"
| RULE_separator => "a separator comment that is not (* ****** ****** *)"
| RULE_comma_space => "no space after a comma"
| RULE_trailing_semicolon => "a semicolon before end, in, ), ] or }"
| RULE_staload_dup => "a file that is staloaded twice"
| RULE_staload_unused => "a named staload (X = ...) whose $X is never used"
| RULE_let_empty => "let in E end (no declarations)"
| RULE_case_single => "a case with one clause"
| RULE_case_unchecked => "a case that is not case+ or case-"
| RULE_end_comment => "an // end of [NAME] after a function named otherwise"
| RULE_fnx_template => "fnx on a template (it is treated as fun)"
| RULE_if_const => "an if on true or false"
| RULE_naming => "a linear type without _vt, a view without _v"
| RULE_unused_var => "a local val or var that is never used"
| RULE_unused_fun => "a local function that is never used"
| RULE_unused_arg => "an argument that is never used"
| RULE_shadow => "a local name that hides another local name"
| RULE_nonexhaustive => "a case+ or case whose clauses do not cover all values"
| _ (*unknown*) => ""
) (* end of [rule_get_descr] *)

(* ****** ****** *)

implement
rule_get_defsev (id) =
(
case+ id of
| RULE_indent => SEV_info
| RULE_lex_error => SEV_error
| RULE_parse_error => SEV_error
| RULE_separator => SEV_info
| RULE_comma_space => SEV_info
| RULE_trailing_semicolon => SEV_info
| RULE_let_empty => SEV_info
| RULE_case_single => SEV_info
| RULE_case_unchecked => SEV_info
| RULE_end_comment => SEV_info
| RULE_if_const => SEV_info
| RULE_naming => SEV_info
| RULE_unused_arg => SEV_info
| RULE_shadow => SEV_info
| _ (*rest*) => SEV_warning
) (* end of [rule_get_defsev] *)

implement
rule_is_defon (id) =
(
case+ id of
| RULE_indent => false
| RULE_non_ascii => false
| RULE_let_empty => false
| RULE_separator => false
| RULE_comma_space => false
| RULE_trailing_semicolon => false
| RULE_case_single => false
| RULE_case_unchecked => false
| RULE_naming => false
| RULE_unused_arg => false
| RULE_shadow => false
| _ (*rest*) => true
) (* end of [rule_is_defon] *)

implement
rule_is_semantic (id) =
  id >= RULE_unused_var && id <= RULE_nonexhaustive
// end of [rule_is_semantic]

(* ****** ****** *)

implement
rule_find (name) = let
//
fun loop
  (id: int): int =
  if id < NRULE then
    (if rule_get_name (id) = name then id else loop (id + 1))
  else ~1 // end of [if]
//
in
  loop (0)
end // end of [rule_find]

(* ****** ****** *)

implement
sev_get_name (sev) =
(
case+ sev of
| SEV_info => "info"
| SEV_warning => "warning"
| SEV_error => "error"
| _ (*off*) => "off"
) (* end of [sev_get_name] *)

implement
sev_find (name) =
(
if name = "off" then SEV_off
else if name = "info" then SEV_info
else if name = "warning" then SEV_warning
else if name = "error" then SEV_error
else ~2 // unknown
) (* end of [sev_find] *)

(* ****** ****** *)

implement
the_settings_reset () = let
//
fun loop
  (id: int): void =
  if id < NRULE then let
    val sev =
      (if rule_is_defon (id) then rule_get_defsev (id) else SEV_off): int
    val () = the_rule_set_sev (id, sev)
  in
    loop (id + 1)
  end // end of [if]
//
val () = loop (0)
val () = the_maxcol_set (80)
val () = the_indent_set (2)
//
in
  // nothing
end // end of [the_settings_reset]

(* ****** ****** *)

(* end of [patslint_rules.dats] *)
