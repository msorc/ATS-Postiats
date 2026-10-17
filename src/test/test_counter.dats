#include "share/atspre_staload.hats"
staload UNSAFE = "prelude/SATS/unsafe.sats"
staload "../pats_counter.sats"
dynload "../pats_counter.dats"
implement main0 () = {
  val c = counter_make ()
  val n0 = counter_getinc (c)
  val n1 = counter_incget (c)
  val () = assertloc (count_get_int (n0) = 0 && count_get_int (n1) = 2)
  val () = assertloc (n0 < n1 && compare_count_count (n1, n0) = 1)
  val () = println! (tostring_prefix_count ("tmp", n1), tostring_count (n0))
}
