(*
** HX-2026-10: dump the tokens of a file (the validation driver for
** pats_reader, pats_lexbuf, pats_lexing, pats_tokbuf). The output has
** the format of the ATS1 reference driver (src/ + test/lexdump1.dats).
**
**   lexdump FILE        # FILE reader
**   lexdump -s FILE     # string reader
**   lexdump -g FILE     # getc closure reader
**   lexdump -c FILE     # char list reader
**   lexdump -t FILE     # through a tokbuf, comments skipped (tokbuf_get_token)
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/hashtbl_linprb.dats"
staload _ = "libats/DATS/hashfun.dats"
staload "libats/libc/SATS/stdio.sats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload LBF = "../pats_lexbuf.sats"
staload TBF = "../pats_tokbuf.sats"
staload "../pats_basics.sats"
staload "../pats_lexing.sats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
dynload "../pats_basics.dats"
dynload "../pats_reader.dats"
dynload "../pats_lexbuf.dats"
dynload "../pats_lexing_token.dats"
dynload "../pats_lexing.dats"
dynload "../pats_lexing_error.dats"
dynload "../pats_lexing_print.dats"
dynload "../pats_tokbuf.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

extern fun fopen_r (path: string): FILEref = "mac#patsopt_fopen_r"
%{^
#include <stdio.h>
#include <stdlib.h>
static FILE* patsopt_fopen_r (const char *path)
{ FILE *fp = fopen(path, "r") ; if (!fp) { perror(path) ; exit(1) ; } return fp ; }
%}

fn fxk_str (k: fxtykind): string =
  case+ k of
  | FXK_infix () => "infix" | FXK_infixl () => "infixl" | FXK_infixr () => "infixr"
  | FXK_prefix () => "prefix" | FXK_postfix () => "postfix"

fn dump_one (out: FILEref, tok: token): bool = let
  val () = $LOC.fprint_location (out, tok.token_loc())
  val () = fprint_string (out, " ")
  val () = fprint_token (out, tok)
  val () =
  (
  case+ token_node_view (tok.token_node()) of
  | ~T_CASE k => (fprint_string (out, " "); fprint_caskind (out, k))
  | ~T_FIXITY k => (fprint_string (out, " "); fprint_string (out, fxk_str k))
  | ~T_FUN k => (fprint_string (out, " "); fprint_funkind (out, k))
  | ~T_VAL k => (fprint_string (out, " "); fprint_valkind (out, k))
  | ~T_INT (_, _, sfx) => (fprint_string (out, " sfx="); fprint_uint (out, sfx))
  | ~T_FLOAT (_, _, sfx) => (fprint_string (out, " sfx="); fprint_uint (out, sfx))
  | ~T_CHAR c => (fprint_string (out, " code="); fprint_int (out, char2int0 c))
  | tn => token_node_view_free (tn)
  ) : void
  val () = fprint_newline (out)
in
  token_node_is_T_EOF (tok.token_node())
end

fun dump (out: FILEref, buf: &lexbuf): void = let
  val tok = lexing_next_token (buf)
in
  if dump_one (out, tok) then () else dump (out, buf)
end

fun dump_tbf (out: FILEref, buf: &$TBF.tokbuf): void = let
  val tok = $TBF.tokbuf_getinc_token (buf)
in
  if dump_one (out, tok) then () else dump_tbf (out, buf)
end

fun readall (path: string): string = let
  val fp = fopen_r (path)
  fun loop (fp: FILEref, cs: List0_vt(char)): List0_vt(char) = let
    val i = fgetc0 (fp)
  in
    if i >= 0 then loop (fp, list_vt_cons (int2char0 i, cs)) else cs
  end
  val cs = list_vt_reverse (loop (fp, list_vt_nil))
  val n = list_vt_length (cs)
  val p = the_garena_alloc (i2sz(n+1))
  fun fill (p: ptr, cs: List0_vt(char)): void =
    case+ cs of
    | ~list_vt_cons (c, cs) => (
        $UN.ptr0_set<char> (p, c); fill (ptr0_succ<char> (p), cs))
    | ~list_vt_nil () => $UN.ptr0_set<char> (p, '\000')
  val () = fill (p, cs)
  val () = fileref_close (fp)
in
  $UN.cast{string}(p)
end

fun readlst (path: string): List0_vt(char) = let
  val fp = fopen_r (path)
  fun loop (fp: FILEref, cs: List0_vt(char)): List0_vt(char) = let
    val i = fgetc0 (fp)
  in
    if i >= 0 then loop (fp, list_vt_cons (int2char0 i, cs)) else cs
  end
  val cs = list_vt_reverse (loop (fp, list_vt_nil))
  val () = fileref_close (fp)
in
  cs
end

fn fini (out: FILEref, buf: &$LBF.lexbuf >> $LBF.lexbuf?): void = {
  val () = dump (out, buf)
  val () = $LBF.lexbuf_uninitize (buf)
  val _ = fprint_the_lexerrlst (out)
}

fn run_filp (out: FILEref, path: string): void = {
  var buf: $LBF.lexbuf
  val () = $LBF.lexbuf_initize_filp (buf, fopen_r (path))
  val () = fini (out, buf)
}
fn run_string (out: FILEref, path: string): void = {
  var buf: $LBF.lexbuf
  val () = $LBF.lexbuf_initize_string (buf, readall (path))
  val () = fini (out, buf)
}
fn run_charlst (out: FILEref, path: string): void = {
  var buf: $LBF.lexbuf
  val () = $LBF.lexbuf_initize_charlst_vt (buf, readlst (path))
  val () = fini (out, buf)
}
fn run_getc (out: FILEref, path: string): void = {
  var buf: $LBF.lexbuf
  val fp = fopen_r (path)
  val getc = lam () : int =<lincloptr1> fgetc0 (fp)
  val () = $LBF.lexbuf_initize_getc (buf, getc)
  val () = fini (out, buf)
  val () = fileref_close (fp)
}
fn run_tokbuf (out: FILEref, path: string): void = {
  var tbuf: $TBF.tokbuf
  val () = $TBF.tokbuf_initize_filp (tbuf, fopen_r (path))
  val () = dump_tbf (out, tbuf)
  val () = $TBF.tokbuf_uninitize (tbuf)
  val _ = fprint_the_lexerrlst (out)
}

implement main0 (argc, argv) = let
  val out = stdout_ref
  val mode = (if argc >= 3 then argv[1] else "-f"): string
  val path = (if argc >= 3 then argv[2] else (if argc >= 2 then argv[1] else "")): string
in
  if mode = "-t" then run_tokbuf (out, path)
  else if mode = "-s" then run_string (out, path)
  else if mode = "-c" then run_charlst (out, path)
  else if mode = "-g" then run_getc (out, path)
  else run_filp (out, path)
end
