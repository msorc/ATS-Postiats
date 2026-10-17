(*
**
** Some utility functions
** for manipulating the syntax of ATS2
**
** Contributed by Hongwei Xi (gmhwxiATgmailDOTcom)
**
** Start Time: June, 2012
**
*)

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload
STDIO = "libats/libc/SATS/stdio.sats"

(* ****** ****** *)

staload "src/pats_lexing.sats"
staload "src/pats_syntax.sats"
staload _(*templates*) = "src/pats_error.dats"

(* ****** ****** *)

staload "./../SATS/libatsynmark.sats"

(* ****** ****** *)

#include "./libatsynmark_gen_dats.hats"

(* ****** ****** *)

implement
libatsynmark_filename_set_current
  (name) = let
//
val opt =
  $FIL.filenameopt_make_local (name)
//
in
//
case+ opt of
| ~Some_vt
    (fil) => $FIL.the_filenamelst_ppush (fil)
  // end of [Some_vt]
| ~None_vt () => let
    val () = prerr_string ": warning(libatsynmark)"
    val () = prerrln! (": the file [", name, "] is not available.")
  in
    $ERR.abort<void> ()
  end // end of [None_vt]
//
end // end of [libatsynmark_filename_set_current]

(* ****** ****** *)

implement
libatsynmark_char_list_vt_make_file
  (inp) = let
//
fun loop
(
  inp: FILEref, res: charlst_vt
) : charlst_vt = let
  val i = $STDIO.fgetc0 (inp)
in
  if i >= 0
    then loop (inp, list_vt_cons ($UN.cast{char} (i), res))
    else list_vt_reverse (res)
  // end of [if]
end // end of [loop]
//
in
  loop (inp, list_vt_nil ())
end // end of [libatsynmark_char_list_vt_make_file]

(* ****** ****** *)

implement
putc_make (env, f) = @(env, f)

implement
putc_call (putc, c) = putc.1 (putc.0, c)

(* ****** ****** *)

implement
fhtml_putc
  (c, putc) = let
  macdef fpr (s) = fstring_putc (,(s), putc)
in
  case+ c of
  | '<' => fpr ("&lt;")
  | '>' => fpr ("&gt;")
  | '&' => fpr ("&amp;")
  | _ => putc_call (putc, c)
end // end of [fhtml_putc]

(* ****** ****** *)

implement
fstring_putc
  (x, putc) = let
//
fun loop
(
  p: ptr, putc: putc_type, nerr: int
) : int(*nerr*) = let
  val c = $UN.ptr0_get<char> (p)
in
//
if c != '\000' then let
  val err = putc_call (putc, c)
  val nerr = (if err != 0 then nerr + 1 else nerr): int
in
  loop (ptr0_succ<char> (p), putc, nerr)
end else nerr // end of [if]
//
end // end of [loop]
//
in
  loop ($UN.cast{ptr} (x), putc, 0)
end // end of [fstring_putc]

(* ****** ****** *)

implement
fprint_position
  (out, x) = $LOC.fprint_position (out, x)
// end of [fprint_position]

implement
fprint_location
  (out, x) = $LOC.fprint_location (out, x)
// end of [fprint_location]

(* ****** ****** *)

implement
token_get_loc (x) = x.token_loc ()

(* ****** ****** *)

implement
token_is_eof (x) = token_node_is_T_EOF (x.token_node ())

(* ****** ****** *)

implement
token_is_comment (x) = let
  val tnd = x.token_node ()
in
  token_node_is_T_COMMENT_line (tnd)
  || token_node_is_T_COMMENT_block (tnd)
  || token_node_is_T_COMMENT_rest (tnd)
end // end of [token_is_comment]

implement
token_is_extcode (x) =
  token_node_is_T_EXTCODE (x.token_node ())
// end of [token_is_extcode]

(* ****** ****** *)

implement
token_is_keyword
  (x) = let
//
(*
** HX-2016-02-22:
** token_is_keyword
*)
//
val tnd = x.token_node ()
//
macdef is (c) = ,(c) (tnd)
//
in
//
if token_node_is_T_NONE (tnd) then false
//
else if token_node_is_T_IDENT_alp (tnd) then false
else if token_node_is_T_IDENT_sym (tnd) then false
else if token_node_is_T_IDENT_arr (tnd) then false
else if token_node_is_T_IDENT_tmp (tnd) then false
else if token_node_is_T_IDENT_dlr (tnd) then false
else if token_node_is_T_IDENT_srp (tnd) then false
else if token_node_is_T_IDENT_ext (tnd) then false
//
else if token_node_is_T_CHAR (tnd) then false
else if token_node_is_T_INT (tnd) then false
else if token_node_is_T_FLOAT (tnd) then false
else if token_node_is_T_STRING (tnd) then false
//
else if token_node_is_T_EXTCODE (tnd) then false
//
else if token_node_is_T_COMMENT_line (tnd) then false
else if token_node_is_T_COMMENT_block (tnd) then false
else if token_node_is_T_COMMENT_rest (tnd) then false
//
else if token_node_is_T_ERR (tnd) then false
//
else if token_node_is_T_EOF (tnd) then false
//
else true (* rest-of-token *)
//
end // end of [token_is_keyword]

(* ****** ****** *)

implement
token_is_int (x) = token_node_is_T_INT (x.token_node ())
implement
token_is_char (x) = token_node_is_T_CHAR (x.token_node ())
implement
token_is_float (x) = token_node_is_T_FLOAT (x.token_node ())
implement
token_is_string (x) = token_node_is_T_STRING (x.token_node ())

(* ****** ****** *)

implement
fprint_token
  (out, x) = $LEX.fprint_token (out, x)
// end of [fprint_token]

(* ****** ****** *)

staload
LBF = "src/pats_lexbuf.sats"
stadef lexbuf = $LBF.lexbuf

(* ****** ****** *)
//
// HX-2026-10:
// a lexbufobj is a lexbuf in the C heap: it is
// allocated by [ptr_alloc] and freed by [lexbufobj_free]
//
extern
castfn
lexbufobj_of_ptr
  {l:addr}
(
  pf1: mfree_gc_v (l), pf2: lexbuf @ l | p: ptr l
) : lexbufobj
extern
castfn
lexbufobj_to_ptr
  (lbf: lexbufobj)
  : [l:addr] (mfree_gc_v (l), lexbuf @ l | ptr l)
//
extern
castfn
lexbufobj_takeout
  (lbf: !lexbufobj)
  : [l:addr] (lexbuf @ l, lexbuf @ l -<lin,prf> void | ptr l)
//
(* ****** ****** *)

implement
lexbufobj_make_string
  (inp) = let
  val [l:addr]
    (pfat, pfgc | p) = ptr_alloc<lexbuf> ()
  val () = $LBF.lexbuf_initize_string (!p, inp)
in
  lexbufobj_of_ptr (pfgc, pfat | p)
end // end of [lexbufobj_make_string]

(* ****** ****** *)

implement
lexbufobj_make_charlst_vt
  (inp) = let
//
val
[l:addr]
  (pfat, pfgc | p) = ptr_alloc<lexbuf> ()
//
val () = $LBF.lexbuf_initize_charlst_vt (!p, inp)
//
in
  lexbufobj_of_ptr (pfgc, pfat | p)
end // end of [lexbufobj_make_charlst_vt]

(* ****** ****** *)

implement
lexbufobj_make_fileref
  (inp) = let
//
val
[l:addr]
  (pfat, pfgc | p) = ptr_alloc<lexbuf> ()
//
val () =
  $LBF.lexbuf_initize_getc (!p, llam () => $STDIO.fgetc0 (inp))
//
in
  lexbufobj_of_ptr (pfgc, pfat | p)
end // end of [lexbufobj_make_fileref]

(* ****** ****** *)

implement
lexbufobj_free (lbf) = let
//
val (pfgc, pfat | p) = lexbufobj_to_ptr (lbf)
//
val ((*cleared*)) = $LBF.lexbuf_uninitize (!p)
//
in
  ptr_free (pfgc, pfat | p)
end // end of [lexbufobj_free]

(* ****** ****** *)

implement
lexbufobj_get_tokenlst
  (lbf) = let
//
vtypedef res = tokenlst_vt
vtypedef lexbuf = $LEX.lexbuf
//
fun loop
(
  buf: &lexbuf, res: res
) : res = let
  val tok =
    lexing_next_token (buf)
  val iseof = token_is_eof (tok)
in
//
if iseof
  then list_vt_reverse (res)
  else loop (buf, list_vt_cons (tok, res))
//
end (* end of [loop] *)
//
val (pf, fpf | p) = lexbufobj_takeout (lbf)
//
val res = loop (!p, list_vt_nil ())
//
prval ((*rtrned*)) = fpf (pf)
//
in
  res
end // end of [lexbuf_get_tokenlst]

(* ****** ****** *)

staload
TBF = "src/pats_tokbuf.sats"
stadef tokbuf = $TBF.tokbuf

(* ****** ****** *)

extern
castfn
tokbufobj_of_ptr
  {l:addr}
(
  pf1: mfree_gc_v (l), pf2: tokbuf @ l | p: ptr l
) : tokbufobj
extern
castfn
tokbufobj_to_ptr
  (tbf: tokbufobj)
  : [l:addr] (mfree_gc_v (l), tokbuf @ l | ptr l)
extern
castfn
tokbufobj_takeout
  (tbf: !tokbufobj)
  : [l:addr] (tokbuf @ l, tokbuf @ l -<lin,prf> void | ptr l)

(* ****** ****** *)

implement
tokbufobj_make_lexbufobj
  (lbf) = let
//
val (pfgc1, pfat1 | p1) = lexbufobj_to_ptr (lbf)
//
val
[l2:addr]
  (pfat2, pfgc2 | p2) = ptr_alloc<tokbuf> ()
//
val () = $TBF.tokbuf_initize_lexbuf (!p2, !p1)
//
val ((*void*)) = ptr_free (pfgc1, pfat1 | p1)
//
in
  tokbufobj_of_ptr (pfgc2, pfat2 | p2)
end // end of [tokbufobj_make_lexbufobj]

(* ****** ****** *)

implement
tokbufobj_free (tbf) = let
//
val (pfgc, pfat | p) = tokbufobj_to_ptr (tbf)
//
val () = $TBF.tokbuf_uninitize (!p)
//
in
  ptr_free (pfgc, pfat | p)
end // end of [tokbufobj_free]

(* ****** ****** *)

implement
tokbufobj_unget_token
  (tbf, tok) = let
//
val (pf, fpf | p) = tokbufobj_takeout (tbf)
//
val () = $TBF.tokbuf_unget_token (!p, tok)
//
prval () = fpf (pf)
//
in
  // nothing
end // end of [tokbufobj_unget_token]

(* ****** ****** *)
//
staload SYM = "src/pats_symbol.sats"
//
(* ****** ****** *)

staload SYN = "src/pats_syntax.sats"

(* ****** ****** *)

fn
eq_symbol (x: symbol, y: symbol): bool = $SYM.eq_symbol_symbol (x, y)

(* ****** ****** *)

implement
test_symbol_p0at
  (sym, p0t) = let
in
//
case+ p0at_node_view (p0t.p0at_node ()) of
| ~P0Tide (sym1) => eq_symbol (sym, sym1)
| v (* rest-of-p0at *) => (p0at_node_view_free (v); false)
//
end // end of [test_symbol_p0at]

(* ****** ****** *)

local

fun
s0taconlst_test
(
  sym: symbol
, xs0: s0taconlst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val sym1 = x.s0tacon_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else s0taconlst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [s0taconlst_test]

fun
s0expdeflst_test
(
  sym: symbol
, xs0: s0expdeflst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val sym1 = x.s0expdef_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else s0expdeflst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [s0expdeflst_test]

fun
e0xndeclst_test
(
  sym: symbol, xs0: e0xndeclst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val sym1 = x.e0xndec_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else e0xndeclst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [e0xndeclst_test]

fun
d0atdeclst_test
(
  sym: symbol
, xs1: d0atdeclst, xs2: s0expdeflst
) : bool = let
//
fun loop1
(
  sym: symbol, xs0: d0atdeclst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) =>
  (
    if eq_symbol (sym, x.d0atdec_sym ())
      then true else loop1 (sym, xs)
  ) (* end of [GLcons] *)
//
end // end of [loop1]
//
in
  loop1 (sym, xs1)
end // end of [d0atdeclst_test]

fun
d0cstdeclst_test
(
  sym: symbol, xs0: d0cstdeclst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLcons (x, xs) => let
    val sym1 = x.d0cstdec_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else d0cstdeclst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
| ~GLnil () => false
//
end // end of [d0cstdeclst_test]

fun
m0acdeflst_test
(
  sym: symbol, xs0: m0acdeflst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val sym1 = x.m0acdef_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else m0acdeflst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [m0acdeflst_test]

fun
f0undeclst_test
(
  sym: symbol, xs0: f0undeclst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val sym1 = x.f0undec_sym ()
  in
    if eq_symbol (sym, sym1)
      then true else f0undeclst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [f0undeclst_test]

fun
v0aldeclst_test
(
  sym: symbol, xs0: v0aldeclst
) : bool = let
in
//
case+ glist_view (xs0) of
| ~GLnil () => false
| ~GLcons (x, xs) => let
    val p0t = x.v0aldec_pat ()
  in
    if test_symbol_p0at (sym, p0t)
      then true else v0aldeclst_test (sym, xs)
    // end of [if]
  end // end of [GLcons]
//
end // end of [v0aldeclst_test]

in (* in of [local] *)

implement
test_symbol_d0ecl
  (sym, d0c) = let
in
//
case+ d0ecl_node_view (d0c.d0ecl_node ()) of
//
| ~D0Coverload
    (id, dqid, pval) =>
  (
    if eq_symbol (id.i0de_sym (), sym) then true else false
  )
//
| ~D0Cstacons
    (_, xs) => s0taconlst_test (sym, xs)
| ~D0Csexpdefs
    (_, xs) => s0expdeflst_test (sym, xs)
//
| ~D0Cexndecs
    (xs0) => e0xndeclst_test (sym, xs0)
//
| ~D0Cdatdecs
    (knd, xs1, xs2) => d0atdeclst_test (sym, xs1, xs2)
//
| ~D0Cdcstdecs
    (_, _, _, xs) => d0cstdeclst_test (sym, xs)
//
| ~D0Cmacdefs(_, _, xs) => m0acdeflst_test (sym, xs)
| ~D0Cfundecs(_, _, xs) => f0undeclst_test (sym, xs)
| ~D0Cvaldecs(_, _, xs) => v0aldeclst_test (sym, xs)
//
| v (* rest-of-d0ecl *) => (d0ecl_node_view_free (v); false)
//
end // end of [test_symbol_d0ecl]

end // end of [local]

(* ****** ****** *)
//
staload PAR = "src/pats_parsing.sats"
//
(* ****** ****** *)

local

typedef d0eclist = d0eclist

(* ****** ****** *)
//
// HX-2013-07:
// for getting the last
// position of the current line
//
fun EOLgetpos
(
  inp: !charlst_vt, pos1: lint, pos2: lint
) : lint = let
in
//
if pos1 < pos2 then
(
  case+ inp of
  | @list_vt_cons (_, cs) => let
      val pos2 = EOLgetpos (cs, pos1+1L, pos2)
      prval () = fold@ (inp)
    in
      pos2
    end // end of [list_vt_cons]
  | list_vt_nil () => pos2
) else
  EOLgetpos2 (inp, pos2)
// end of [if]
//
end // end of [EOLgetpos]

and EOLgetpos2
(
  inp: !charlst_vt, pos2: lint
) : lint = let
in
//
case+ inp of
| @list_vt_cons (c, cs) =>
  (
    if c != '\n' then let
      val pos2 = EOLgetpos2 (cs, pos2+1L)
      prval () = fold@ (inp)
    in
      pos2
    end else let
      prval () = fold@ (inp) in pos2
    end // end of [if]
  )
| list_vt_nil () => pos2
//
end // end of [EOLgetpos2]

(* ****** ****** *)

fun drop
(
  inp: &charlst_vt >> charlst_vt, pos1: lint, pos2: lint
) : void = let
in
//
if pos1 < pos2 then
(
  case+ inp of
  | ~list_vt_cons (_, cs) => let
      val () = inp := cs in drop (inp, pos1+1L, pos2)
    end // end of [list_vt_cons]
  | list_vt_nil () => ()
) else ((*void*)) // end of [if]
//
end // end of [drop]

(* ****** ****** *)

fun take
(
  inp: &charlst_vt >> charlst_vt, pos1: lint, pos2: lint, res: charlst_vt
) : charlst_vt = let
in
//
if pos1 < pos2 then
(
  case+ inp of
  | ~list_vt_cons (c, cs) => let
      val () = inp := cs
    in
      take (inp, pos1+1L, pos2, list_vt_cons (c, res))
    end // end of [list_vt_cons]
  | list_vt_nil () =>
      list_vt_reverse (res)
) else list_vt_reverse (res)
//
end // end of [take]

(* ****** ****** *)

fun
i0nclude_declitemize
(
  loc0: location
, stadyn: int, path: string
) : d0eclreplst = let
//
var path2 : string (* uninitized *)
//
val filopt =
  $FIL.filenameopt_make_relative(path, path2)
//
val fil = (
  case+ filopt of
  | ~Some_vt filename => filename
  | ~None_vt () => let
      val () = $LOC.prerr_location (loc0)
      val () = prerr_string ": error(libatsynmark)"
      val () = prerrln! (": the file [", path2, "] is not available for inclusion.")
      val () = $ERR.abort<void> ()
    in
      $FIL.filename_dummy
    end // end of [None_vt]
) : $FIL.filename // end of [val]
//
val fsym =
  $FIL.filename_get_fullname (fil)
val fname = $SYM.symbol_get_name (fsym)
val inp = libatsynmark_fopen_exn (fname, "r")
val cs = libatsynmark_char_list_vt_make_file (inp)
val ((*closed*)) = fileref_close (inp)
//
val (pfpush | ()) = $FIL.the_filenamelst_push (fil)
val res(*d0eclreplst*) = charlst_declitemize (stadyn, cs)
val () = $FIL.the_filenamelst_pop (pfpush | (*none*))
//
in
  res
end // end of [i0nclude_declitemize]

in (* in of [local] *)

implement
charlst_declitemize
  (stadyn, inp) = let
//
val inp1 = list_vt_copy (inp)
val lbf =
  lexbufobj_make_charlst_vt (inp1)
val tbf = tokbufobj_make_lexbufobj (lbf)
//
val (pf, fpf | p) = tokbufobj_takeout (tbf)
val d0cs = $PAR.parse_from_tokbuf_toplevel (stadyn, !p)
prval () = fpf (pf)
val ((*void*)) = tokbufobj_free (tbf)
//
fun d0eclrep_make
(
  d0c: d0ecl, inp: charlst_vt, pos: lint
) : d0eclrep = let
in
//
case+
  d0ecl_node_view (d0c.d0ecl_node ()) of
| ~D0Cinclude
    (pfil, stadyn, path) => let
    val (
      pfpush | ()
    ) = $FIL.the_filenamelst_push (pfil)
    val replst = i0nclude_declitemize (d0c.d0ecl_loc (), stadyn, path)
    val () = $FIL.the_filenamelst_pop (pfpush | (*none*))
    val cs = glist_make_list_vt (inp)
  in
    d0eclrep_D0ECLREPinclude (d0c, cs, replst)
  end // end of [D0Cinclude]
| ~D0Cguadecl (knd, gd0c) => let
    val gd0c =
      guad0eclrep_make (gd0c.guad0ecl_node (), inp, pos)
  in
    d0eclrep_D0ECLREPguadecl (gd0c)
  end // end of [D0Cguadecl]
| v (* rest-of-d0ecl *) => let
    val () = d0ecl_node_view_free (v)
    val cs = glist_make_list_vt (inp) in d0eclrep_D0ECLREPsing (d0c, cs)
  end // end of [_]
//
end (* end of [d0eclrep_make] *)
//
and guad0eclrep_make
(
  gnode: guad0ecl_node, inp: charlst_vt, pos: lint
) : guad0eclrep = let
in
//
case+ guad0ecl_node_view (gnode) of
| ~GD0Cone
    (e0xp, d0cs) => let
    var inp = inp
    var pos = pos
    val d0cs = traverse (d0cs, inp, pos, list_vt_nil ())
    val ((*freed*)) = list_vt_free (inp)
  in
    guad0eclrep_GUAD0ECLREPone (d0cs)
  end // end of [GD0Cone]
| ~GD0Ctwo
    (e0xp, d0cs1, d0cs2) => let
    var inp = inp
    var pos = pos
    val d0cs1 = traverse (d0cs1, inp, pos, list_vt_nil ())
    val d0cs2 = traverse (d0cs2, inp, pos, list_vt_nil ())
    val ((*freed*)) = list_vt_free (inp)
  in
    guad0eclrep_GUAD0ECLREPtwo (d0cs1, d0cs2)
  end // end of [GD0Ctwo]
| ~GD0Ccons
    (e0xp, d0cs1, knd, gnode2) => let
    var inp = inp
    var pos = pos
    val d0cs1 = traverse (d0cs1, inp, pos, list_vt_nil ())
    val gd0c2 =
      guad0eclrep_make (gnode2, inp, pos)
  in
    guad0eclrep_GUAD0ECLREPcons (d0cs1, gd0c2)
  end // end of [GD0Ccons]
//
end // end of [guad0eclrep_make]
//
and traverse
(
  d0cs: d0eclist
, inp: &charlst_vt >> charlst_vt, pos: &lint
, res: List0_vt (d0eclrep)
) : d0eclreplst = let
in
//
case+ glist_view (d0cs) of
| ~GLnil
    ((*void*)) =>
    glist_make_list_vt (list_vt_reverse (res))
  // GLnil
| ~GLcons
    (d0c, d0cs) => let
//
    val loc = d0c.d0ecl_loc ()
//
    val pos0 = pos
    val pos1 = $LOC.location_beg_ntot (loc)
    val pos2 = $LOC.location_end_ntot (loc)
//
    val () = drop (inp, pos0, pos1)
//
    val pos2 = EOLgetpos (inp, pos1, pos2)
//
    val inp_cs = take (inp, pos1, pos2, list_vt_nil ())
//
    val x = d0eclrep_make (d0c, inp_cs, pos1)
//
    val () = pos := pos2
//
  in
    traverse (d0cs, inp, pos, list_vt_cons (x, res))
  end // end of [GLcons]
//
end (* end of [traverse] *)
//
var inp = inp
var pos: lint = 0L
//
val res =
  traverse (d0cs, inp, pos, list_vt_nil ())
//
val ((*freed*)) = list_vt_free (inp)
//
in
  res
end // end of [charlst_declitemize]

end // end of [local]

(* ****** ****** *)
//
implement
d0eclreplst_find_synop
  (d0cs, sym) = let
//
vtypedef res_vt = List0_vt (charlst)
//
fun aux
(
  d0c: d0eclrep, sym: symbol, res: res_vt
) : res_vt = let
in
//
case+ d0eclrep_view (d0c) of
| ~D0ECLREPsing (d0c, cs) => let
    val found = test_symbol_d0ecl (sym, d0c)
  in
    if found then list_vt_cons (cs, res) else res
  end // end of [D0ECLREPsing]
| ~D0ECLREPinclude (d0c, cs, d0cs2) => auxlst (d0cs2, sym, res)
| ~D0ECLREPguadecl (gd0c) => auxgua (gd0c, sym, res)
//
end // end of [aux]

and auxlst
(
  d0cs: d0eclreplst, sym: symbol, res: res_vt
) : res_vt = let
in
//
case+ glist_view (d0cs) of
| ~GLcons
    (d0c, d0cs) => let
    val res = aux (d0c, sym, res) in auxlst (d0cs, sym, res)
  end // end of [GLcons]
| ~GLnil () => res
//
end // end of [auxlst]
//
and auxgua
(
  gd0c: guad0eclrep, sym: symbol, res: res_vt
) : res_vt = let
in
//
case+ guad0eclrep_view (gd0c) of
| ~GUAD0ECLREPone
    (d0cs) => auxlst (d0cs, sym, res)
| ~GUAD0ECLREPtwo
    (d0cs1, d0cs2) =>
  (
    auxlst (d0cs2, sym, auxlst(d0cs1, sym, res))
  ) // end of [GUAD0ECLREPtwo]
| ~GUAD0ECLREPcons
    (d0cs1, gd0c2) =>
  (
    auxgua (gd0c2, sym, auxlst(d0cs1, sym, res))
  ) // end of [GUAD0ECLREPcons]
//
end // end of [auxgua]
//
//
in
  list_vt_reverse(auxlst(d0cs, sym, list_vt_nil(*void*)))
end // end of [d0eclreplst_find_synop]

(* ****** ****** *)

implement
libatsynmark_strptr_make_charlst
  (cs) = let
//
fun loop
(
  env: ptr, cs: charlst
) : void =
(
  case+ glist_view (cs) of
  | ~GLnil () => ()
  | ~GLcons (c, cs) => let
      val _(*err*) = libatsynmark_sbuf_putc (env, c) in loop (env, cs)
    end // end of [GLcons]
) (* end of [loop] *)
//
val env = libatsynmark_sbuf_make ()
val ((*void*)) = loop (env, cs)
//
in
  libatsynmark_sbuf_takeout (env)
end // end of [libatsynmark_strptr_make_charlst]

(* ****** ****** *)

%{$
#include <stdio.h>
#include <stdlib.h>
void*
libatsynmark_fopen_exn (void *name0, void *mode0)
{
  const char *name = (const char*)name0 ; const char *mode = (const char*)mode0 ;
  FILE *fil = fopen(name, mode) ;
  if (!fil) {
    perror ("fopen") ;
    fprintf (stderr, "exit(ATS): [fopen(\"%s\", \"%s\")] failed\n", name, mode) ;
    exit (1) ;
  } // end of [if]
  return fil ;
}
typedef struct {
  char *buf ; size_t len ; size_t cap ;
} libatsynmark_sbuf_struct ;
void*
libatsynmark_sbuf_make (void)
{
  libatsynmark_sbuf_struct *p =
    (libatsynmark_sbuf_struct*)malloc(sizeof(libatsynmark_sbuf_struct)) ;
  p->cap = 256 ; p->len = 0 ;
  p->buf = (char*)malloc(p->cap) ;
  return p ;
}
int
libatsynmark_sbuf_putc (void *env, char c)
{
  libatsynmark_sbuf_struct *p = (libatsynmark_sbuf_struct*)env ;
  if (p->len + 1 >= p->cap) {
    p->cap = 2 * p->cap ; p->buf = (char*)realloc(p->buf, p->cap) ;
  }
  p->buf[p->len++] = c ;
  return 0 ;
}
void*
libatsynmark_sbuf_takeout (void *env)
{
  libatsynmark_sbuf_struct *p = (libatsynmark_sbuf_struct*)env ;
  char *res = p->buf ;
  res[p->len] = '\000' ;
  free(p) ;
  return res ;
}
%}

(* ****** ****** *)

(* end of [libatsynmark.dats] *)
