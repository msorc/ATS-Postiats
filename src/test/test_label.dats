#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload SYM = "../pats_symbol.sats"
staload "../pats_label.sats"
dynload "../pats_symbol.dats"
dynload "../pats_label.dats"
implement main0 () = {
  val l1 = label_make_int 3
  val l2 = label_make_string "foo"
  val l3 = label_make_int 3
  val () = assertloc (l1 = l3 && l1 != l2 && compare (l1, l2) = ~1 && compare (l2, l1) = 1)
  val () = assertloc (label_is_int l1 && label_is_sym l2)
  val () = (case+ label_get_int l1 of ~Some_vt i => assertloc (i = 3) | ~None_vt () => assertloc (false))
  val () = (case+ label_get_sym l1 of ~Some_vt _ => assertloc (false) | ~None_vt () => ())
  val () = print_label l1; val () = print_label l2; val () = print_newline ()
  val () = println! (tostring_label l1, tostring_label l2, $SYM.symbol_get_name (label_dotize l1), $SYM.symbol_get_name (label_dotize l2))
  val x : labeled(int) = @(l2, 5)
}
