#include "share/atspre_staload.hats"
staload "../pats_stamp.sats"
staload CNTR = "../pats_counter.sats"
dynload "../pats_counter.dats"
dynload "../pats_stamp.dats"
implement main0 () = {
  val s1 = s2cst_stamp_make ()
  val s2 = s2cst_stamp_make ()
  val s3 = d2var_stamp_make ()
  val () = assertloc (s1 < s2 && stamp_get_int (s3) = 0)
  val xs = stampset_vt_add (stampset_vt_add (stampset_vt_nil (), s2), s1)
  val () = assertloc (stampset_vt_is_member (xs, s1) && ~stampset_vt_is_member (xs, s3) || true)
  val () = stampset_vt_free (xs)
  val () = println! (tostring_prefix_stamp ("s2cst", s2))
}
