#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload SYM = "../pats_symbol.sats"
staload "../pats_symmap.sats"
staload _ = "../pats_symmap.dats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/linmap_avltree.dats"
dynload "../pats_symbol.dats"
dynload "../pats_symmap.dats"
fn pr (out: FILEref, s: string): void = fprint_string (out, s)
implement main0 () = {
  val a = $SYM.symbol_make_string "a" and b = $SYM.symbol_make_string "b" and c = $SYM.symbol_make_string "c"
  var m1 = symmap_make_nil<string> ()
  val () = symmap_insert<string> (m1, a, "A")
  val () = symmap_insert<string> (m1, b, "B")
  var m2 = symmap_make_nil<string> ()
  val () = symmap_insert<string> (m2, c, "C")
  val () = symmap_insert<string> (m2, a, "A2")
  val () = symmap_joinwth<string> (m1, m2)
  val () = (case+ symmap_search<string> (m1, a) of ~Some_vt s => println! (s) | ~None_vt () => assertloc (false))
  val () = (case+ symmap_search<string> (m1, c) of ~Some_vt s => println! (s) | ~None_vt () => assertloc (false))
  val () = fprint_symmap<string> (stdout_ref, m1, pr)
  val () = symmap_free<string> (m1)
  val () = symmap_free<string> (m2)
}
