(*
** Calling the functions of the API of libatsynmark
**
** usage: test03 CMD STADYN FILE [NAMES]
**
** CMD is setcur (libatsynmark_filename_set_current of FILE, which may not exist), tok1/tok2/tok3 (the tokens of the file, read as a string, a FILEref
** and a list of chars), psm (the position-synmarks of the tokens and their split),
** lvl1s/lvl1c/lvl1f (lexbufobj_level1_psynmarkize), html (the four xxx_pats2xhtmlize_yyy),
** putc (fstring_putc and fhtml_putc), proc1/proc2/proc3 (the xxx_psynmarklstlst_process),
** decl (charlst_declitemize and d0eclreplst_find_synop for the NAMES, a string
** of symbols separated by spaces). STADYN is 0 (static) or 1 (dynamic).
** The output (the md5 of it) is the one of the ATS1 version of libatsynmark.
**
** HX-2026-10: no GC
*)
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload STDIO = "libats/libc/SATS/stdio.sats"
//
staload
"./../SATS/libatsynmark.sats"
staload _(*anon*) =
"./../DATS/libatsynmark_psynmark.dats"
//
staload SYM = "src/pats_symbol.sats"
//
(* ****** ****** *)
//
%{^
#include <stdio.h>
#include <stdlib.h>
static char*
test_read_file (char *path) {
  FILE *f = fopen(path, "rb"); long n = 0; char *b; size_t k;
  if (!f) { fprintf(stderr, "cannot open %s\n", path); exit(2); }
  fseek(f, 0, SEEK_END); n = ftell(f); fseek(f, 0, SEEK_SET);
  b = (char*)malloc(n + 1); k = fread(b, 1, n, f); b[k] = 0; fclose(f); return b;
}
static char*
test_word (char *s, int k) {
  int i = 0; char *p = s; char *q;
  while (1) {
    while (*p == ' ') p++ ;
    if (!*p) return 0 ;
    q = p ; while (*q && *q != ' ') q++ ;
    if (i == k) {
      char *r = (char*)malloc(q - p + 1); int j;
      for (j = 0; j < q - p; j++) r[j] = p[j] ;
      r[q-p] = 0 ; return r ;
    }
    i++ ; p = q ;
  }
}
static void
test_free (char *p) { free(p); }
static void*
test_open_file (char *path) { FILE *f = fopen(path, "rb"); if (!f) exit(2); return f; }
%}
//
extern fun test_read_file (path: string): string = "mac#test_read_file"
extern fun test_word (s: string, k: int): ptr = "mac#test_word"
extern fun test_free (s: string): void = "mac#test_free"
extern fun test_open_file (path: string): FILEref = "mac#test_open_file"
//
(* ****** ****** *)

macdef out = stdout_ref
fn ps (s: string): void = fprint_string (out, s)
fn nl (): void = fprint_newline (out)
fn pb (b: bool): void = ps (if b then "T" else "F")

(* ****** ****** *)

fun print_toks (xs: !tokenlst_vt): void =
  case+ xs of
  | @list_vt_cons (x, xs1) => let
      val () = fprint_token (out, x)
      val () = fprint_location (out, token_get_loc x)
      val () = ps " eof="; val () = pb (token_is_eof x)
      val () = ps " cmt="; val () = pb (token_is_comment x)
      val () = ps " ext="; val () = pb (token_is_extcode x)
      val () = ps " kw="; val () = pb (token_is_keyword x)
      val () = ps " int="; val () = pb (token_is_int x)
      val () = ps " chr="; val () = pb (token_is_char x)
      val () = ps " flt="; val () = pb (token_is_float x)
      val () = ps " str="; val () = pb (token_is_string x)
      val () = nl ()
      val () = print_toks (xs1)
    in fold@ (xs) end
  | list_vt_nil () => ()

fun print_psms (xs: !psynmarklst_vt): void =
  case+ xs of
  | @list_vt_cons (x, xs1) => let
      val () = fprint_psynmark (out, x) val () = nl () val () = print_psms (xs1)
    in fold@ (xs) end
  | list_vt_nil () => ()

fun print_psmss (xs: !psynmarklstlst_vt, i: int): void =
  case+ xs of
  | @list_vt_cons (x, xs1) => let
      val () = ps "LIST "; val () = fprint_int (out, i); val () = nl ()
      val () = print_psms (x)
      val () = print_psmss (xs1, i+1)
    in fold@ (xs) end
  | list_vt_nil () => ()

fun pstr (s: string): void = let val () = ps "[" val () = ps s val () = ps "]" in nl () end

fun pcs (cs: charlst): void = let
  fun loop (cs: charlst): void =
    case+ glist_view (cs) of
    | ~GLcons (c, cs) => (fprint_char (out, c); loop cs)
    | ~GLnil () => ()
  val () = ps "["; val () = loop cs; val () = ps "]"
in nl () end

fun dump_rep (ind: int, x: d0eclrep): void = let
  fun sp (i: int): void = if i > 0 then (ps "  "; sp (i-1))
  val () = sp ind
in
  case+ d0eclrep_view (x) of
  | ~D0ECLREPsing (d0c, cs) => (ps "SING "; pcs cs)
  | ~D0ECLREPinclude (d0c, cs, xs) => (ps "INCLUDE "; pcs cs; dump_lst (ind+1, xs))
  | ~D0ECLREPguadecl (g) => (ps "GUAD"; nl (); dump_gua (ind+1, g))
end
and dump_lst (ind: int, xs: d0eclreplst): void =
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => (dump_rep (ind, x); dump_lst (ind, xs)) | ~GLnil () => ()
and dump_gua (ind: int, g: guad0eclrep): void =
  case+ guad0eclrep_view (g) of
  | ~GUAD0ECLREPone (xs) => (ps "ONE"; nl (); dump_lst (ind+1, xs))
  | ~GUAD0ECLREPtwo (xs, ys) => (ps "TWO"; nl (); dump_lst (ind+1, xs); ps "--"; nl (); dump_lst (ind+1, ys))
  | ~GUAD0ECLREPcons (xs, g) => (ps "CONS"; nl (); dump_lst (ind+1, xs); dump_gua (ind+1, g))

fun str2cs (s: string): charlst_vt = let
  fun loop (p: ptr, res: charlst_vt): charlst_vt = let
    val c = $UN.ptr0_get<char> (p)
  in if c != '\000' then loop (ptr0_succ<char> (p), list_vt_cons (c, res)) else list_vt_reverse res end
in loop ($UN.cast{ptr} (s), list_vt_nil ()) end

fun cs2lst (cs: charlst_vt): charlst = glist_make_list_vt (cs)


(* ****** ****** *)

fun fputc_putc (env: ptr, c: char): int = $STDIO.fputc0_char (c, out)
fun fputc_b_putc (env: ptr, c: char): int = if c = 'b' then 1 else $STDIO.fputc0_char (c, out)

local
implement
psynmark_process<> (psm, putc) = psynmark_process_xhtml_bground (psm, putc)
in
fun proc1 (src: string, psmss: psynmarklstlst_vt, putc: putc_type): void =
  string_psynmarklstlst_process<> (src, psmss, putc)
fun proc2 (f: FILEref, psmss: psynmarklstlst_vt, putc: putc_type): void =
  fileref_psynmarklstlst_process<> (f, psmss, putc)
fun proc3 (cs: charlst_vt, psmss: psynmarklstlst_vt, putc: putc_type): void =
  charlst_psynmarklstlst_process<> (cs, psmss, putc)
end // end of [local]

fun html1 (stadyn: int, src: string): void = let
  val r1 = string_pats2xhtmlize_bground (stadyn, src) val () = pstr ($UN.castvwtp1 {string} (r1)) val () = strptr_free r1
  val r2 = string_pats2xhtmlize_embedded (stadyn, src) val () = pstr ($UN.castvwtp1 {string} (r2)) val () = strptr_free r2
  val r3 = charlst_pats2xhtmlize_bground (stadyn, cs2lst (str2cs src)) val () = pstr ($UN.castvwtp1 {string} (r3)) val () = strptr_free r3
  val r4 = charlst_pats2xhtmlize_embedded (stadyn, cs2lst (str2cs src)) val () = pstr ($UN.castvwtp1 {string} (r4)) val () = strptr_free r4
in end

fun synops (names: string, xs: d0eclreplst, i: int): void = let
  val w = test_word (names, i)
in
  if w != the_null_ptr then let
    val w = $UN.cast{string} (w)
    val sym = $SYM.symbol_make_string (w)
    val css = d0eclreplst_find_synop (xs, sym)
    val () = ps "SYNOP "; val () = ps w; val () = nl ()
    fun loop2 (css: List0_vt (charlst)): void =
      case+ css of
      | ~list_vt_cons (cs, css) => (pcs cs; loop2 css) | ~list_vt_nil () => ()
    val () = loop2 css
  in synops (names, xs, i+1) end else ()
end

(* ****** ****** *)

implement
main0 (argc, argv) = let
  val () = libatsynmark_dynloadall ()
in
if argc >= 4 then let
  val cmd = argv[1]
  val stadyn = (if argv[2] = "0" then 0 else 1): int
  val file = argv[3]
  val names = (if argc >= 5 then argv[4] else ""): string
  val src = (if cmd = "setcur" then "" else test_read_file file): string
  val () = libatsynmark_filename_set_current (file)
  val putc = putc_make (the_null_ptr, fputc_putc)
  val res = (
  if cmd = "setcur" then (ps "setcur"; nl ())
  else if cmd = "tok1" then let val lbf = lexbufobj_make_string src val toks = lexbufobj_get_tokenlst lbf val () = lexbufobj_free lbf val () = print_toks toks val () = list_vt_free toks in end
  else if cmd = "tok2" then let val lbf = lexbufobj_make_fileref (test_open_file file) val toks = lexbufobj_get_tokenlst lbf val () = lexbufobj_free lbf val () = print_toks toks val () = list_vt_free toks in end
  else if cmd = "tok3" then let val lbf = lexbufobj_make_charlst_vt (str2cs src) val toks = lexbufobj_get_tokenlst lbf val () = lexbufobj_free lbf val () = print_toks toks val () = list_vt_free toks in end
  else if cmd = "psm" then let
    val lbf = lexbufobj_make_string src val toks = lexbufobj_get_tokenlst lbf val () = lexbufobj_free lbf
    val psms = listize_token2psynmark toks val () = list_vt_free toks
    val () = print_psms psms
    val (b, e) = psynmarklst_split psms
    val () = ps "BEG"; val () = nl (); val () = print_psms b val () = ps "END" val () = nl () val () = print_psms e
    val () = list_vt_free b val () = list_vt_free e
  in end
  else if cmd = "lvl1s" then let val lbf = lexbufobj_make_string src val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf) val () = print_psmss (psmss, 0) val () = psynmarklstlst_free psmss in end
  else if cmd = "lvl1c" then let val lbf = lexbufobj_make_charlst_vt (str2cs src) val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf) val () = print_psmss (psmss, 0) val () = psynmarklstlst_free psmss in end
  else if cmd = "lvl1f" then let val lbf = lexbufobj_make_fileref (test_open_file file) val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf) val () = print_psmss (psmss, 0) val () = psynmarklstlst_free psmss in end
  else if cmd = "html" then html1 (stadyn, src)
  else if cmd = "putc" then let
    val n1 = fstring_putc (src, putc) val () = nl () val () = fprint_int (out, n1) val () = nl ()
    val n2 = fhtml_putc ('<', putc) val n3 = fhtml_putc ('>', putc) val n4 = fhtml_putc ('&', putc) val n5 = fhtml_putc ('x', putc)
    val () = nl () val () = fprint_int (out, n2+n3+n4+n5) val () = nl ()
    val n6 = fstring_putc ("a<b>&c", putc_make (the_null_ptr, fputc_b_putc))
    val () = nl () val () = fprint_int (out, n6) val () = nl ()
  in end
  else if cmd = "proc1" then let
    val lbf = lexbufobj_make_string src val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf)
  in proc1 (src, psmss, putc) end
  else if cmd = "proc2" then let
    val lbf = lexbufobj_make_string src val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf)
  in proc2 (test_open_file file, psmss, putc) end
  else if cmd = "proc3" then let
    val lbf = lexbufobj_make_string src val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf)
  in proc3 (str2cs src, psmss, putc) end
  else if cmd = "decl" then let
    val xs = charlst_declitemize (stadyn, str2cs src)
    val () = dump_lst (0, xs)
  in synops (names, xs, 0) end
  else (ps "unknown command"; nl ())
  ) : void
in
  if cmd != "setcur" then test_free (src)
end else ()
end // end of [main0]

(* ****** ****** *)

(* end of [test03.dats] *)
