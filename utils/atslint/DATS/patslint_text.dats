(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the rules on the text of a file
//
// The tokens of the lexer of the compiler mark the bytes that are
// in comments, strings and chars, and embedded C code; then each
// line is checked. With [--fix], the lines are written out with
// the fixable findings (trailing-ws, crlf, final-newline, blank-eof,
// the tabs of an indentation) fixed instead of reported.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
LOC = "src/pats_location.sats"
staload "src/pats_lexing.sats"
//
staload
"utils/libatsynmark/SATS/libatsynmark.sats"
//
(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)
//
#define TABSTOP 8
//
(* ****** ****** *)

fn
token_get_kind
  (x: token): int = let
  val tnd = x.token_node ()
in
  if token_is_comment (x) then TOK_comment
  else if token_is_string (x) then TOK_string
  else if token_is_char (x) then TOK_char
  else if token_is_extcode (x) then TOK_extcode
  else if token_node_is_T_ERR (tnd) then TOK_err
  else if token_node_is_T_COMMA (tnd) then TOK_comma
  else if token_node_is_T_SEMICOLON (tnd) then TOK_semicolon
  else if token_node_is_T_END (tnd) then TOK_end
  else if token_node_is_T_IN (tnd) then TOK_in
  else if token_node_is_T_LPAREN (tnd) then TOK_lparen
  else if token_node_is_T_RPAREN (tnd) then TOK_rparen
  else if token_node_is_T_LBRACKET (tnd) then TOK_lbracket
  else if token_node_is_T_RBRACKET (tnd) then TOK_rbracket
  else if token_node_is_T_LBRACE (tnd) then TOK_lbrace
  else if token_node_is_T_RBRACE (tnd) then TOK_rbrace
  else if token_node_is_T_IDENT_dlr (tnd) then TOK_ident_dlr
  else TOK_other
end // end of [token_get_kind]

(* ****** ****** *)

fun
textbuf_mask_range
(
  buf: !textbuf, i: int, j: int, k: int
) : void =
  if i < j then let
    val () = textbuf_set_mask (buf, i, k)
  in
    textbuf_mask_range (buf, i + 1, j, k)
  end // end of [if]
// end of [textbuf_mask_range]

(* ****** ****** *)
//
// the text as a list of chars (a NUL byte would end a string)
//
implement
textbuf_charlst
  (buf) = let
//
fun loop
  (buf: !textbuf, i: int, cs: charlst_vt): charlst_vt =
  if i > 0 then let
    val c = int2char0 (textbuf_get_char (buf, i - 1))
  in
    loop (buf, i - 1, list_vt_cons (c, cs))
  end else cs
//
in
  loop (buf, textbuf_get_size (buf), list_vt_nil ())
end // end of [textbuf_charlst]

(* ****** ****** *)
//
// the tokens of the text are recorded, the bytes of the comments,
// strings and chars, and embedded C code are marked, and the
// messages of the lexer are recorded (rule lex-error)
//
fun
textbuf_mask_tokens
  (buf: !textbuf): void = let
//
val () = the_lexerrlst_clear ()
val lbf = lexbufobj_make_charlst_vt (textbuf_charlst (buf))
val toks = lexbufobj_get_tokenlst (lbf)
val () = lexbufobj_free (lbf)
//
fun loop
  (buf: !textbuf, toks: tokenlst_vt): void =
(
case+ toks of
| ~list_vt_cons
    (tok, toks) => let
    val loc = token_get_loc (tok)
    val i = g0int2int_lint_int ($LOC.location_beg_ntot (loc))
    val j = g0int2int_lint_int ($LOC.location_end_ntot (loc))
    val knd = token_get_kind (tok)
    val () = textbuf_tok_add (buf, knd, i, j)
    val k =
    (
      case+ knd of
      | TOK_comment => MASK_comment
      | TOK_string => MASK_string
      | TOK_char => MASK_string
      | TOK_extcode => MASK_extcode
      | TOK_err => let
          val c0 = textbuf_get_char (buf, i)
          val c1 = textbuf_get_char (buf, i + 1)
        in
          if (c0 = 40(*lparen*) || c0 = 47(*slash*)) && c1 = 42(*star*)
            then MASK_comment
          else if c0 = 34(*dquote*) || c0 = 39(*squote*) then MASK_string
          else if c0 = 37(*percent*) && c1 = 123(*lbrace*) then MASK_extcode
          else MASK_code
        end // end of [TOK_err]
      | _ (*rest*) => MASK_code
    ) : int
    val () =
      if k != MASK_code then textbuf_mask_range (buf, i, j, k)
  in
    loop (buf, toks)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
) (* end of [loop] *)
//
val () = loop (buf, toks)
//
val out = memout_open ()
val _(*nerr*) = fprint_the_lexerrlst (out)
val () = memout_close (buf, out, RULE_lex_error)
//
in
  // nothing
end // end of [textbuf_mask_tokens]

(* ****** ****** *)
//
// the state of the check of a file
//
typedef
linstate = @{
  path= string
, blankfrom= int // the first line of the blank lines at the end
, ncrlf= int // the number of the reported CRLF line ends
, nfixed= int // the number of the fixed findings
} (* end of [linstate] *)

(* ****** ****** *)

fn
is_utf8_cont
  (c: int): bool = c >= 128 && c < 192

fn
is_blank
  (c: int): bool = c = 32 || c = 9

(* ****** ****** *)
//
// a rule is active on a line if it is on, the line is one of the
// lines of [--lines], and no comment disables it
//
implement
rule_is_active
  (buf, line, rule) =
  the_rule_get_sev (rule) >= SEV_info
  && (~rule_is_semantic (rule) || the_semantic_get ())
  && the_lines_test (line)
  && ~textbuf_disabled (buf, line, rule)
// end of [rule_is_active]

implement
report_at
  (path, buf, off, rule, msg) = let
  val line = textbuf_line_of (buf, off)
in
  if rule_is_active (buf, line, rule) then
    finding_report (path, line, textbuf_col_of (buf, off), rule, msg)
  // end of [if]
end // end of [report_at]

fn
report
(
  st: &linstate, buf: !textbuf
, line: int, col: int, rule: int, msg: string
) : void =
  if rule_is_active (buf, line, rule) then
    finding_report (st.path, line, col, rule, msg)
  // end of [if]
// end of [report]

fn
fixing
(
  buf: !textbuf, line: int, rule: int
) : bool = the_fix_get () && rule_is_active (buf, line, rule)

(* ****** ****** *)
//
// the column (from 1) of the byte [j] of the line that starts at [s]
//
fun
textbuf_col
(
  buf: !textbuf, s: int, j: int
) : int = let
//
fun loop
  (buf: !textbuf, i: int, col: int): int =
  if i < j then let
    val c = textbuf_get_char (buf, i)
  in
    loop (buf, i + 1, if is_utf8_cont (c) then col else col + 1)
  end else col
//
in
  loop (buf, s, 1)
end // end of [textbuf_col]
//
// the width of the bytes [s, e) (a tab goes to the next tab stop)
//
fun
textbuf_width
(
  buf: !textbuf, s: int, e: int
) : int = let
//
fun loop
  (buf: !textbuf, i: int, w: int): int =
  if i < e then let
    val c = textbuf_get_char (buf, i)
  in
    if c = 9 then
      loop (buf, i + 1, w + TABSTOP - w mod TABSTOP)
    else
      loop (buf, i + 1, if is_utf8_cont (c) then w else w + 1)
  end else w
//
in
  loop (buf, s, 0)
end // end of [textbuf_width]

(* ****** ****** *)
//
// the first byte in [i, e) that satisfies a test, or ~1
//
fun
textbuf_find_tab
  (buf: !textbuf, i: int, e: int): int =
  if i < e then
  (
    if textbuf_get_char (buf, i) = 9
       && textbuf_get_mask (buf, i) != MASK_string
      then i else textbuf_find_tab (buf, i + 1, e)
  ) else ~1
// end of [textbuf_find_tab]

fun
textbuf_find_nonascii
  (buf: !textbuf, i: int, e: int): int =
  if i < e then
  (
    if textbuf_get_char (buf, i) >= 128
       && textbuf_get_mask (buf, i) = MASK_code
      then i else textbuf_find_nonascii (buf, i + 1, e)
  ) else ~1
// end of [textbuf_find_nonascii]

fun
textbuf_skip_blank
  (buf: !textbuf, i: int, e: int): int =
  if i < e then
  (
    if is_blank (textbuf_get_char (buf, i))
      then textbuf_skip_blank (buf, i + 1, e) else i
  ) else e
// end of [textbuf_skip_blank]

(* ****** ****** *)
//
// a long line is not reported if it cannot be broken: it is one
// word (a long string or name) or it holds a URL
//
fun
textbuf_unbreakable
(
  buf: !textbuf, s: int, e: int
) : bool = let
//
fun has_space
  (buf: !textbuf, i: int): bool =
  if i < e then
  (
    if is_blank (textbuf_get_char (buf, i))
      then true else has_space (buf, i + 1)
  ) // end of [then]
  else false
//
fun has_url
  (buf: !textbuf, i: int): bool =
  if i + 2 < e then
  (
    if textbuf_get_char (buf, i) = 58(*colon*)
       && textbuf_get_char (buf, i + 1) = 47(*slash*)
       && textbuf_get_char (buf, i + 2) = 47(*slash*)
      then true else has_url (buf, i + 1)
  ) else false
//
val b = textbuf_skip_blank (buf, s, e)
//
in
  ~has_space (buf, b) || has_url (buf, b)
end // end of [textbuf_unbreakable]

(* ****** ****** *)
//
// the end of the line that starts at [s]: the index of its '\n'
// (or the size of the text)
//
fun
textbuf_line_end
  (buf: !textbuf, s: int): int = let
  val n = textbuf_get_size (buf)
in
  if s < n then
  (
    if textbuf_get_char (buf, s) = 10
      then s else textbuf_line_end (buf, s + 1)
  ) else n
end // end of [textbuf_line_end]

(* ****** ****** *)
//
// the first of the blank lines at the end of the text (the line
// after the last one if there is none); [nline] is the number of
// the lines (a last line without newline counts)
//
fun
textbuf_blankfrom
  (buf: !textbuf): int = let
//
val n = textbuf_get_size (buf)
//
fun loop
(
  buf: !textbuf
, s: int, line: int, from: int
) : int =
  if s < n then let
    val e = textbuf_line_end (buf, s)
    val b = textbuf_skip_blank (buf, s, e)
    val blank =
      b = e || (b + 1 = e && textbuf_get_char (buf, b) = 13)
    val from =
      (if blank then (if from > 0 then from else line) else 0): int
  in
    loop (buf, e + 1, line + 1, from)
  end else (if from > 0 then from else line)
//
in
  loop (buf, 0, 1, 0)
end // end of [textbuf_blankfrom]

(* ****** ****** *)
//
// the output of the bytes [i, e) of a line for [--fix]; the tabs
// of the indentation (the bytes before [b]) become spaces if
// [expand] holds
//
fun
fixout_range
(
  buf: !textbuf, i: int, e: int
) : void =
  if i < e then let
    val () = fixout_putc (textbuf_get_char (buf, i))
  in
    fixout_range (buf, i + 1, e)
  end // end of [if]
// end of [fixout_range]

fun
fixout_indent
(
  buf: !textbuf, i: int, b: int, w: int
) : void =
  if i < b then let
    val c = textbuf_get_char (buf, i)
  in
    if c = 9 then let
      val w2 = w + TABSTOP - w mod TABSTOP
      val () = fixout_spaces (w2 - w)
    in
      fixout_indent (buf, i + 1, b, w2)
    end else let
      val () = fixout_putc (c)
    in
      fixout_indent (buf, i + 1, b, w + 1)
    end
  end // end of [if]
// end of [fixout_indent]

and
fixout_spaces
  (k: int): void =
  if k > 0 then (fixout_putc (32); fixout_spaces (k - 1))
// end of [fixout_spaces]

(* ****** ****** *)
//
// the check of the line [line] that starts at [s]
//
fun
lint_line
(
  st: &linstate, buf: !textbuf, s: int, line: int
) : int(*the start of the next line*) = let
//
val n = textbuf_get_size (buf)
val e = textbuf_line_end (buf, s)
val hasnl = e < n
//
// [ce]: the end of the content (before a CR)
//
val iscr =
  e > s && textbuf_get_char (buf, e - 1) = 13
val ce = (if iscr then e - 1 else e): int
//
// [t]: the end of the content without trailing white space
// (white space in a string that goes on is kept)
//
fun trim
  (buf: !textbuf, t: int): int =
  if t > s then let
    val c = textbuf_get_char (buf, t - 1)
  in
    if is_blank (c)
       && textbuf_get_mask (buf, t - 1) != MASK_string
      then trim (buf, t - 1) else t
  end else t
//
val t = trim (buf, ce)
//
// [b]: the end of the indentation
//
val b = textbuf_skip_blank (buf, s, t)
//
val dropline =
  line >= st.blankfrom && fixing (buf, st.blankfrom, RULE_blank_eof)
//
// tabs: those of the indentation are fixed by [--fix]
//
val fixtab = fixing (buf, line, RULE_tab)
val j = textbuf_find_tab (buf, (if fixtab then b else s), t)
val () =
  if j >= 0 then
    report (st, buf, line, textbuf_col (buf, s, j), RULE_tab, "a tab character")
  // end of [if]
val () =
  if fixtab && textbuf_find_tab (buf, s, b) >= 0
    then st.nfixed := st.nfixed + 1
  // end of [if]
//
// the length of the line
//
val maxcol = the_maxcol_get ()
val width = textbuf_width (buf, s, ce)
val () =
  if width > maxcol
     && ~textbuf_unbreakable (buf, s, ce) then
    report
    ( st, buf, line, maxcol + 1, RULE_line_length
    , msg_format2 ("the line is %d columns long (max-col is %d)", width, maxcol)
    ) (* end of [report] *)
  // end of [if]
//
// trailing white space
//
val fixtws = fixing (buf, line, RULE_trailing_ws)
val () =
  if t < ce then
  (
    if fixtws
      then st.nfixed := st.nfixed + 1
      else report
      ( st, buf, line
      , textbuf_col (buf, s, t), RULE_trailing_ws, "trailing white space"
      ) (* end of [report] *)
  ) (* end of [if] *)
//
// the indentation
//
val indent = the_indent_get ()
val () =
  if b < t
     && textbuf_get_mask (buf, b) = MASK_code
     && textbuf_find_tab (buf, s, b) < 0
     && (b - s) mod indent != 0 then
    report
    ( st, buf, line, 1, RULE_indent
    , msg_format2
      ("the indentation (%d) is not a multiple of %d", b - s, indent)
    ) (* end of [report] *)
  // end of [if]
//
// non-ASCII characters in code
//
val j = textbuf_find_nonascii (buf, s, ce)
val () =
  if j >= 0 then
    report
    ( st, buf, line, textbuf_col (buf, s, j)
    , RULE_non_ascii, "a non-ASCII character outside comments and strings"
    ) (* end of [report] *)
  // end of [if]
//
// CRLF (reported once in a file)
//
val fixcr = fixing (buf, line, RULE_crlf)
val () =
  if iscr then
  (
    if fixcr then st.nfixed := st.nfixed + 1
    else if st.ncrlf = 0 && rule_is_active (buf, line, RULE_crlf) then let
      val () = st.ncrlf := 1
    in
      report
      ( st, buf, line
      , textbuf_col (buf, s, ce), RULE_crlf, "a CRLF line end"
      ) (* end of [report] *)
    end
  ) (* end of [if] *)
//
// the blank lines at the end
//
val () =
  if line = st.blankfrom && s < n then
  (
    if dropline
      then st.nfixed := st.nfixed + 1
      else report
      ( st, buf, line, 1, RULE_blank_eof, "blank lines at the end of the file" )
  ) (* end of [if] *)
//
// no newline at the end
//
val fixnl = fixing (buf, line, RULE_final_newline)
val () =
  if ~hasnl && s < e then
  (
    if fixnl
      then st.nfixed := st.nfixed + 1
      else report
      ( st, buf, line
      , textbuf_col (buf, s, e)
      , RULE_final_newline, "no newline at the end of the file"
      ) (* end of [report] *)
  ) (* end of [if] *)
//
// the fixed line
//
val () =
  if the_fix_get () && ~dropline then let
    val () =
      if fixtab then fixout_indent (buf, s, b, 0) else fixout_range (buf, s, b)
    val () = fixout_range (buf, b, (if fixtws then t else ce))
    val () =
      if iscr && ~fixcr then fixout_putc (13)
    val () =
      if hasnl || (s < e && fixnl) then fixout_putc (10)
  in
    // nothing
  end // end of [if]
//
in
  e + 1
end // end of [lint_line]

(* ****** ****** *)

fun
lint_lines
(
  st: &linstate, buf: !textbuf, s: int, line: int
) : void =
  if s < textbuf_get_size (buf) then let
    val s2 = lint_line (st, buf, s, line)
  in
    lint_lines (st, buf, s2, line + 1)
  end // end of [if]
// end of [lint_lines]

(* ****** ****** *)

//
// the messages of the lexer from the [i]-th one on: one for a line
// (a non-ASCII character gives one for each of its bytes)
//
fun
report_errs
(
  path: string, buf: !textbuf, i: int, last: int
) : void =
  if i < textbuf_get_nerr (buf) then let
    val off = textbuf_err_off (buf, i)
    val line = textbuf_line_of (buf, off)
    val () =
      if line != last then
        report_at
        ( path, buf, off, textbuf_err_rule (buf, i)
        , textbuf_err_msg (buf, i)
        ) (* end of [report_at] *)
      // end of [if]
  in
    report_errs (path, buf, i + 1, line)
  end // end of [if]
// end of [report_errs]

fn
path_has_ext
  (path: string, ext: string): bool = let
  val n = g0uint2int_size_int (string_length (path))
  extern fun
  strcmp_at (s: string, i: int, t: string): int = "mac#patslint_strcmp_at"
in
  n >= 5 && strcmp_at (path, n - 5, ext) = 0
end // end of [path_has_ext]

fn
path_is_ats
  (path: string): bool =
  path_has_ext (path, ".sats")
  || path_has_ext (path, ".dats") || path_has_ext (path, ".hats")
// end of [path_is_ats]

implement
patslint_file
  (path) = let
//
val () = the_settings_reset ()
val cfg = the_config_load (path)
val () = the_cmdopt_apply ()
//
in
//
if cfg = 2 then 0 (* excluded *) else let
  val opt = textbuf_make_file (path)
in
//
case+ opt of
| ~None_vt () => let
    val () = prerrln! ("error(patslint): cannot read the file [", path, "]")
  in
    ~1
  end // end of [None_vt]
| ~Some_vt (buf) => let
    //
    // only an ATS file (.sats, .dats, .hats) is lexed and parsed:
    // the text rules alone apply to the others (.cats, ...)
    //
    val isats = path_is_ats (path)
    val () = if isats then textbuf_mask_tokens (buf)
    val () = textbuf_directives (buf)
    var st: linstate
    val () = st.path := path
    val () = st.blankfrom := textbuf_blankfrom (buf)
    val () = st.ncrlf := 0
    val () = st.nfixed := 0
    val dofix = the_fix_get ()
    val fixok = (if dofix then fixout_open (path) > 0 else true): bool
    val () = if ~fixok then the_fix_set (false)
    val () = lint_lines (st, buf, 0, 1)
    val () =
      if dofix && fixok then let
        val _(*ok*) = fixout_close (path, st.nfixed > 0)
        val () = the_fix_set (true)
      in
        // nothing
      end // end of [if]
    //
    // the messages of the lexer, the rules on the tokens, on the
    // syntax tree and, with --semantic, after the binding of names
    //
    val () = report_errs (path, buf, 0, 0)
    val stadyn = (if path_has_ext (path, ".sats") then 0 else 1): int
    val () = if isats then patslint_tokens (path, buf)
    val () = if isats then patslint_tree (path, buf, stadyn)
    val () =
      if isats && the_semantic_get ()
        then patslint_sema (path, buf, stadyn)
      // end of [if]
    val nfound = findings_flush (path, buf)
    val () = textbuf_free (buf)
  in
    if fixok then nfound else ~1
  end // end of [Some_vt]
//
end // end of [else]
//
end // end of [patslint_file]

(* ****** ****** *)

(* end of [patslint_text.dats] *)
