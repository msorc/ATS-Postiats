#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "../pats_symbol.sats"
dynload "../pats_symbol.dats"
implement main0 () = {
  val a = symbol_make_string "foo"
  val b = symbol_make_string "foo"
  val c = symbol_make_string "bar"
  val () = assertloc (a = b && ~(a = c))
  val () = assertloc (symbol_get_stamp (symbol_empty) = 0u)
  val () = assertloc (symbol_get_stamp (symbol_ADD) > 0u)
  val () = assertloc (symbol_make_string "+" = symbol_ADD)
  val () = fprint_symbol (stdout_ref, c); val () = print_newline ()
  val () = fprint_symbolopt (stdout_ref, gopt_some a); val () = print_newline ()
  val () = assertloc (compare_symbol_symbol (a, c) <= 0)
}
