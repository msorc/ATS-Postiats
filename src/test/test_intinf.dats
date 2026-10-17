#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "../pats_intinf.sats"
staload UT = "../pats_utils.sats"
dynload "../pats_utils.dats"
dynload "../pats_intinf.dats"

implement main0 () = {
  val x = intinf_make_string ("0x10")
  val y = intinf_make_int (5)
  val z = x * y + intinf_make_size (i2sz(7))
  val () = fprint_intinf (stdout_ref, z); val () = print_newline ()
  val () = assertloc (z = intinf_make_int (87))
  val () = assertloc (~z < 0 && z > 86 && z != y)
  val s = intinfset_add (intinfset_add (intinfset_sing x, y), x)
  val () = assertloc (intinfset_is_member (s, y))
  val () = fprint_intinfset (stdout_ref, s); val () = print_newline ()
  val () = assertloc (intinf_get_int (z - x) = 71)
}
