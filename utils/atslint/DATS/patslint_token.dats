(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the rules on the tokens
//
// footer: a comment (* end of [NAME] *) whose NAME, a file name,
//   is not the name of the file
// separator: a comment of stars only that is not (* ****** ****** *)
// comma-space: a comma followed by a token on the same line with no
//   space between them (a closing parenthesis, bracket or brace aside)
// trailing-semicolon: a semicolon right before end, in, ), ] or }
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)
//
// the name of the file of a path (after its last slash)
//
fn
path_basename
  (path: string): string = let
  extern fun
  basename (path: string): string = "mac#patslint_basename"
in
  basename (path)
end // end of [path_basename]

(* ****** ****** *)

fn
is_space
  (c: int): bool = c = 32 || c = 9 || c = 13 || c = 10

(* ****** ****** *)
//
// [beg, end) is a block comment of stars and spaces only
// with at least three stars inside: a separator
//
fun
textbuf_is_separator
(
  buf: !textbuf, beg: int, fin: int
) : bool = let
//
fun loop
  (buf: !textbuf, i: int, e: int, nstar: int): bool =
  if i < e then let
    val c = textbuf_get_char (buf, i)
  in
    if c = 42(*star*) then loop (buf, i + 1, e, nstar + 1)
    else if c = 32 then loop (buf, i + 1, e, nstar)
    else false
  end else nstar >= 3
//
in
  fin - beg >= 4
  && textbuf_get_char (buf, beg) = 40(*lparen*)
  && textbuf_get_char (buf, beg + 1) = 42(*star*)
  && textbuf_get_char (buf, fin - 2) = 42(*star*)
  && textbuf_get_char (buf, fin - 1) = 41(*rparen*)
  && loop (buf, beg + 2, fin - 2, 0)
end // end of [textbuf_is_separator]

(* ****** ****** *)
//
// the comment [beg, end) holds [end of [NAME]] with a NAME of a
// file (.sats, .dats, .hats or .cats): the offsets of NAME, or ~1
//
fn
textbuf_footer_name
(
  buf: !textbuf, beg: int, fin: int
) : @(int, int) = let
  val i = textbuf_find (buf, beg, fin, "end of [")
in
  if i < 0 then @(~1, ~1) else let
    val b = i + 8
    val e = textbuf_find (buf, b, fin, "]")
  in
    if e < b + 5 then @(~1, ~1)
    else if textbuf_eq (buf, e - 5, e - 4, ".")
       && (textbuf_eq (buf, e - 4, e, "sats")
           || textbuf_eq (buf, e - 4, e, "dats")
           || textbuf_eq (buf, e - 4, e, "hats")
           || textbuf_eq (buf, e - 4, e, "cats"))
      then @(b, e) else @(~1, ~1)
  end
end // end of [textbuf_footer_name]

(* ****** ****** *)
//
// the index of the next token after [i] that is not a comment
//
fun
textbuf_next_code
  (buf: !textbuf, i: int): int =
  if i < textbuf_get_ntok (buf) then
  (
    if textbuf_tok_kind (buf, i) = TOK_comment
      then textbuf_next_code (buf, i + 1) else i
  ) else i
// end of [textbuf_next_code]

(* ****** ****** *)

implement
patslint_tokens
  (path, buf) = let
//
val base = path_basename (path)
val ntok = textbuf_get_ntok (buf)
//
fun loop
  (buf: !textbuf, i: int): void =
  if i < ntok then let
    val knd = textbuf_tok_kind (buf, i)
    val beg = textbuf_tok_beg (buf, i)
    val fin = textbuf_tok_end (buf, i)
    val () =
    (
    case+ knd of
    | TOK_comment => let
        val nm = textbuf_footer_name (buf, beg, fin)
        val () =
          if nm.0 >= 0
             && ~textbuf_eq (buf, nm.0, nm.1, base) then let
            val name = textbuf_substr (buf, nm.0, nm.1)
            val () =
              report_at
              ( path, buf, nm.0, RULE_footer
              , msg_format2s ("the footer names [%s], not [%s]", name, base)
              ) (* end of [report_at] *)
          in
            // nothing
          end // end of [if]
        val () =
          if textbuf_is_separator (buf, beg, fin)
             && ~textbuf_eq (buf, beg, fin, "(* ****** ****** *)") then
            report_at
            ( path, buf, beg, RULE_separator
            , "a separator that is not (* ****** ****** *)"
            ) (* end of [report_at] *)
          // end of [if]
      in
        // nothing
      end // end of [TOK_comment]
    | TOK_comma => let
        val j = i + 1
        val knd2 = textbuf_tok_kind (buf, j)
        val beg2 = textbuf_tok_beg (buf, j)
      in
        if j < ntok
           && beg2 = fin
           && knd2 != TOK_rparen && knd2 != TOK_rbracket
           && knd2 != TOK_rbrace && knd2 != TOK_comma then
          report_at
          ( path, buf, beg, RULE_comma_space
          , "no space after the comma"
          ) (* end of [report_at] *)
        // end of [if]
      end // end of [TOK_comma]
    | TOK_semicolon => let
        val j = textbuf_next_code (buf, i + 1)
        val knd2 = textbuf_tok_kind (buf, j)
      in
        if knd2 = TOK_end || knd2 = TOK_in
           || knd2 = TOK_rparen || knd2 = TOK_rbracket
           || knd2 = TOK_rbrace then
          report_at
          ( path, buf, beg, RULE_trailing_semicolon
          , "a semicolon before the end of the block"
          ) (* end of [report_at] *)
        // end of [if]
      end // end of [TOK_semicolon]
    | _ (*rest*) => ()
    ) : void // end of [val]
  in
    loop (buf, i + 1)
  end // end of [if]
//
in
  loop (buf, 0)
end // end of [patslint_tokens]

(* ****** ****** *)

(* end of [patslint_token.dats] *)
