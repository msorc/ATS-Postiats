#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
#include "../mylibies.hats"
staload SYM = "../pats_symbol.sats"
staload "../pats_symmap.sats"
staload _ = "../pats_symmap.dats"
staload "../pats_symenv.sats"
staload _ = "../pats_symenv.dats"
dynload "../pats_symbol.dats"
dynload "../pats_symmap.dats"
dynload "../pats_symenv.dats"
fn pr (out: FILEref, s: string): void = fprint_string (out, s)
fn look (env: &symenv string, k: $SYM.symbol): void =
  case+ symenv_search<string> (env, k) of
  | ~Some_vt s => println! (s) | ~None_vt () => println! ("none")
implement main0 () = {
  val a = $SYM.symbol_make_string "a" and b = $SYM.symbol_make_string "b"
  val (pf | p) = symenv_make_nil<string> ()
  val () = symenv_insert<string> (!p, a, "A1")
  val () = symenv_push_nil<string> (!p)
  val () = symenv_push_nil<string> (!p)
  val () = symenv_insert<string> (!p, a, "A2")
  val () = symenv_insert<string> (!p, b, "B2")
  val () = look (!p, a)
  val () = symenv_localjoin<string> (!p) // pops two maps?
  val () = look (!p, b)
  val () = symenv_pervasive_insert<string> (!p, b, "BP")
  val () = (case+ symenv_pervasive_search<string> (!p, b) of ~Some_vt s => println! (s) | ~None_vt () => println! ("none"))
  val () = fprint_symenv_map<string> (stdout_ref, !p, pr)
  prval () = $UN.castview0{void}(pf)
}
