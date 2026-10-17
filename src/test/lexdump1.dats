(* ATS1 reference: dump the tokens of the files given on the command line *)
#define ATS_DYNLOADFLAG 0

staload "libc/SATS/stdio.sats"
staload FIL = "pats_filename.sats"
staload LOC = "pats_location.sats"
staload LBF = "pats_lexbuf.sats"
staload "pats_basics.sats"
staload "pats_lexing.sats"

dynload "pats_error.dats"
dynload "pats_intinf.dats"
dynload "pats_counter.dats"
dynload "pats_utils.dats"
dynload "pats_global.dats"
dynload "pats_basics.dats"
dynload "pats_stamp.dats"
dynload "pats_symbol.dats"
dynload "pats_filename.dats"
dynload "pats_location.dats"
dynload "pats_reader.dats"
dynload "pats_lexbuf.dats"
dynload "pats_lexing.dats"
dynload "pats_lexing_error.dats"
dynload "pats_lexing_print.dats"
dynload "pats_lexing_token.dats"

fun fxk_str (k: fxtykind): string =
  case+ k of
  | FXK_infix () => "infix" | FXK_infixl () => "infixl" | FXK_infixr () => "infixr"
  | FXK_prefix () => "prefix" | FXK_postfix () => "postfix"

implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

fun dump (out: FILEref, buf: &lexbuf): void = let
  val tok = lexing_next_token (buf)
  val () = $LOC.fprint_location (out, tok.token_loc)
  val () = fprint_string (out, " ")
  val () = fprint_token (out, tok)
  val () = (case+ tok.token_node of
    | T_CASE k => (fprint_string (out, " "); fprint_caskind (out, k))
    | T_FIXITY k => (fprint_string (out, " "); fprint_string (out, fxk_str k))
    | T_FUN k => (fprint_string (out, " "); fprint_funkind (out, k))
    | T_VAL k => (fprint_string (out, " "); fprint_valkind (out, k))
    | T_INT (_, _, sfx) => (fprint_string (out, " sfx="); fprint_uint (out, sfx))
    | T_FLOAT (_, _, sfx) => (fprint_string (out, " sfx="); fprint_uint (out, sfx))
    | T_CHAR c => (fprint_string (out, " code="); fprint_int (out, int_of_char c))
    | _ => ())
  val () = fprint_newline (out)
in
  case+ tok.token_node of
  | T_EOF () => () | _ => dump (out, buf)
end

extern fun readall (path: string): string = "mac#slurp"
%{^
#include <stdio.h>
#include <stdlib.h>
static char *slurp (const char *path) {
  FILE *fp = fopen(path, "r"); size_t n = 0, cap = 1024; char *p = malloc(cap); int c;
  while ((c = fgetc(fp)) != EOF) { if (n+2 > cap) { cap *= 2; p = realloc(p, cap); } p[n++] = (char)c; }
  p[n] = 0; fclose(fp); return p;
}
%}

implement main (argc, argv) = if argc >= 2 then let
  val mode = (if argc >= 3 then argv.[1] else "-f"): string
  val path = (if argc >= 3 then argv.[2] else argv.[1]): string
in
  if mode = "-s" then let
    var buf: lexbuf
    val () = $LBF.lexbuf_initize_string (buf, readall path)
    val () = dump (stdout_ref, buf)
    val () = $LBF.lexbuf_uninitize (buf)
    val _ = fprint_the_lexerrlst (stdout_ref)
  in () end else let
    val (pffil | p) = fopen_exn (path, file_mode_r)
    var buf: lexbuf
    val () = $LBF.lexbuf_initize_filp (file_mode_lte_r_r, pffil | buf, p)
    val () = dump (stdout_ref, buf)
    val () = $LBF.lexbuf_uninitize (buf)
    val _ = fprint_the_lexerrlst (stdout_ref)
  in () end
end else ()
