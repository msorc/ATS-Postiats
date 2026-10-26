(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the command line
//
// patslint [option | file] ...
//
// The exit status is 0 if no finding has a severity of at least
// the one of [--fail-on] (warning by default), 1 if one has, and
// 2 if an option is wrong or a file cannot be read.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
LSYNMK =
"utils/libatsynmark/SATS/libatsynmark.sats"
//
(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)

#define PATSLINT_USAGE "\
usage: patslint [option | file] ...\n\
\n\
Check the style of ATS source files (.sats, .dats, .hats).\n\
\n\
options (an option applies to the files that follow it):\n\
  -h, --help           print this help\n\
  --list-rules         print the rules and their default severities\n\
  --enable=RULE,...    turn rules on (at their default severity)\n\
  --disable=RULE,...   turn rules off\n\
  --severity=RULE:SEV  set the severity of a rule\n\
                       (off, info, warning, error)\n\
  --max-col=N          the maximal length of a line (default 80)\n\
  --indent-width=N     the unit of indentation (default 2)\n\
  --lines=N-M,...      report only the findings on these lines\n\
  --all-lines          report the findings on all the lines (default)\n\
  --fail-on=SEV        the least severity that makes the exit status 1\n\
                       (default warning)\n\
  --format=text|json   the output: one finding per line, text or JSON\n\
  --source             (text) each finding is followed by its line and\n\
                       a caret under its column (the default when the\n\
                       output is a terminal)\n\
  --no-source          (text) the findings only\n\
  --fix                fix trailing-ws, crlf, final-newline, blank-eof\n\
                       and the tabs of indentations in place\n\
  --semantic           also the rules after the binding of the names\n\
                       (unused-var, ...; slower: the prelude is loaded)\n\
\n\
The nearest .patslint file in the directory of a file or above it\n\
configures its check (lines of the form KEY = VALUE, # for comments):\n\
  RULE = off | on | info | warning | error\n\
  max-col = N\n\
  indent-width = N\n\
  exclude = GLOB       (relative to the directory of .patslint)\n\
The options of the command line take precedence over it.\n\
A comment [lint: disable=RULE,...] disables rules on its line and the\n\
next one, [lint: disable-file=RULE,...] in the whole file (RULE can\n\
be [all]).\n\
" // end of [PATSLINT_USAGE]

fn
patslint_usage
  (out: FILEref): void = fprint_string (out, PATSLINT_USAGE)

(* ****** ****** *)

fn
patslint_list_rules
  ((*void*)): void = let
//
fun loop
  (id: int): void =
  if id < NRULE then let
    val sev =
      (if rule_is_defon (id) then rule_get_defsev (id) else SEV_off): int
    val () = print! (rule_get_name (id))
    val () = print! (" (", sev_get_name (sev))
    val () = if rule_is_semantic (id) then print! (", --semantic")
    val () = print! ("): ")
    val () = println! (rule_get_descr (id))
  in
    loop (id + 1)
  end // end of [if]
//
in
  loop (0)
end // end of [patslint_list_rules]

(* ****** ****** *)
//
// the helpers of the options (C)
//
%{^
#include <string.h>
#include <stdlib.h>
/* [arg] starts with [key]: the rest, or NULL */
static
void *patslint_opt_value(void *arg, void *key)
{
  size_t n = strlen((char *)key);
  return strncmp((char *)arg, (char *)key, n) == 0 ? (char *)arg + n : NULL;
}
/* a positive number, or -1 */
static
int patslint_opt_posint(void *s)
{
  char *e;
  long n = strtol((char *)s, &e, 10);
  return (e != (char *)s && *e == '\0' && n > 0 && n < 100000) ? (int)n : -1;
}
/* the word of [s] that starts at [i] and ends at [sep] or at the end */
static char patslint_word_buf[256];
static
void *patslint_opt_word(void *s, int i, int sep, int *next)
{
  const char *p = (char *)s + i, *q = p;
  size_t k;
  while (*q && *q != sep) q += 1;
  k = (size_t)(q - p);
  if (k >= sizeof(patslint_word_buf)) k = sizeof(patslint_word_buf) - 1;
  memcpy(patslint_word_buf, p, k); patslint_word_buf[k] = '\0';
  *next = *q ? (int)(q - (char *)s) + 1 : -1;
  return patslint_word_buf;
}
%}
//
extern
fun
opt_value
  (arg: string, key: string): Stropt0 = "mac#patslint_opt_value"
extern
fun
opt_posint (s: string): int = "mac#patslint_opt_posint"
extern
fun
opt_word
(
  s: string, i: int, sep: int, next: &int? >> int
) : string = "mac#patslint_opt_word"
//
(* ****** ****** *)

fn
error_option
  (arg: string, msg: string): void =
  prerrln! ("error(patslint): ", msg, ": [", arg, "]")
// end of [error_option]

(* ****** ****** *)
//
// [--enable=a,b] and [--disable=a,b]: the number of errors
//
fun
opt_rulelist
(
  arg: string, rules: string, i: int, on: bool
) : int = let
  var next: int
  val name = opt_word (rules, i, 44(*comma*), next)
  val next = next
  val id = rule_find (name)
  val nerr =
  (
    if id >= 0 then let
      val () =
        the_cmdopt_rule_add (id, if on then rule_get_defsev (id) else SEV_off)
      // end of [val]
    in
      0
    end else let
      val () = error_option (arg, "unknown rule") in 1
    end
  ) : int
in
  if next >= 0
    then nerr + opt_rulelist (arg, rules, next, on) else nerr
  // end of [if]
end // end of [opt_rulelist]

(* ****** ****** *)
//
// [--severity=RULE:SEV]: the number of errors
//
fn
opt_severity
  (arg: string, spec: string): int = let
  var next: int
  val name = opt_word (spec, 0, 58(*colon*), next)
  val id = rule_find (name)
  val next = next
in
  if id < 0 || next < 0 then let
    val () = error_option (arg, "expected RULE:SEV") in 1
  end else let
    var next2: int
    val sev = sev_find (opt_word (spec, next, 0, next2))
  in
    if sev < SEV_off then let
      val () = error_option (arg, "unknown severity") in 1
    end else let
      val () = the_cmdopt_rule_add (id, sev) in 0
    end
  end
end // end of [opt_severity]

(* ****** ****** *)

typedef
cmdstate = @{
  nerror= int // the number of errors (options, files)
, nfile= int // the number of checked files
, stop= bool // after --help or --list-rules
} (* end of [cmdstate] *)

(* ****** ****** *)
//
// an option: the number of errors
//
fn
process_option
(
  state: &cmdstate, arg: string
) : int = let
//
macdef
value(key) = opt_value (arg, ,(key))
//
val v_enable = value ("--enable=")
val v_disable = value ("--disable=")
val v_severity = value ("--severity=")
val v_maxcol = value ("--max-col=")
val v_indent = value ("--indent-width=")
val v_lines = value ("--lines=")
val v_failon = value ("--fail-on=")
val v_format = value ("--format=")
//
in
//
if arg = "-h" || arg = "--help" then let
  val () = patslint_usage (stdout_ref)
  val () = state.stop := true
in
  0
end else if arg = "--list-rules" then let
  val () = patslint_list_rules ()
  val () = state.stop := true
in
  0
end else if arg = "--fix" then let
  val () = the_fix_set (true) in 0
end else if arg = "--semantic" then let
  val () = the_semantic_set (true) in 0
end else if arg = "--source" then let
  val () = the_source_set (1) in 0
end else if arg = "--no-source" then let
  val () = the_source_set (0) in 0
end else if arg = "--all-lines" then let
  val () = the_lines_clear () in 0
end else if stropt_is_some (v_enable) then
  opt_rulelist (arg, stropt_unsome (v_enable), 0, true)
else if stropt_is_some (v_disable) then
  opt_rulelist (arg, stropt_unsome (v_disable), 0, false)
else if stropt_is_some (v_severity) then
  opt_severity (arg, stropt_unsome (v_severity))
else if stropt_is_some (v_maxcol) then let
  val n = opt_posint (stropt_unsome (v_maxcol))
in
  if n > 0
    then (the_cmdopt_maxcol_set (n); 0)
    else (error_option (arg, "expected a positive number"); 1)
end else if stropt_is_some (v_indent) then let
  val n = opt_posint (stropt_unsome (v_indent))
in
  if n > 0
    then (the_cmdopt_indent_set (n); 0)
    else (error_option (arg, "expected a positive number"); 1)
end else if stropt_is_some (v_lines) then
(
  if the_lines_set (stropt_unsome (v_lines)) > 0
    then 0 else (error_option (arg, "expected N-M,..."); 1)
) else if stropt_is_some (v_failon) then let
  val sev = sev_find (stropt_unsome (v_failon))
in
  if sev >= SEV_info
    then (the_failon_set (sev); 0)
    else (error_option (arg, "expected info, warning or error"); 1)
end else if stropt_is_some (v_format) then let
  val fmt = stropt_unsome (v_format)
in
  if fmt = "text" then (the_format_set (FORMAT_text); 0)
  else if fmt = "json" then (the_format_set (FORMAT_json); 0)
  else (error_option (arg, "expected text or json"); 1)
end else let
  val () = error_option (arg, "unknown option") in 1
end // end of [if]
//
end // end of [process_option]

(* ****** ****** *)

fun
process_args
  {n:int}
(
  state: &cmdstate
, argc: int(n), argv: !argv(n), i: intGte(0)
) : void =
  if i < argc then let
    val arg = argv[i]
    val isopt =
      stropt_is_some (opt_value (arg, "-")) && arg != "-"
    val () =
      if isopt then
        state.nerror := state.nerror + process_option (state, arg)
      else let
        val () = state.nfile := state.nfile + 1
        val res = patslint_file (arg)
      in
        if res < 0 then state.nerror := state.nerror + 1
      end // end of [if]
  in
    process_args (state, argc, argv, i + 1)
  end // end of [if]
// end of [process_args]

(* ****** ****** *)

implement
main0 (argc, argv) = let
//
val () = $LSYNMK.libatsynmark_dynloadall ()
//
var state: cmdstate
val () = state.nerror := 0
val () = state.nfile := 0
val () = state.stop := false
//
val () = process_args (state, argc, argv, 1)
//
val () =
  if state.nfile = 0 && ~state.stop && state.nerror = 0 then
    patslint_usage (stderr_ref)
  // end of [if]
//
val () = the_lines_clear ()
val nerror = state.nerror + the_config_nerror ()
val () = the_config_clear ()
//
in
  if nerror > 0 then exit (2)
  else if state.nfile = 0 && ~state.stop then exit (2)
  else if the_nfail_get () > 0 then exit (1)
  else ()
end // end of [main0]

(* ****** ****** *)

(* end of [patslint_main.dats] *)
