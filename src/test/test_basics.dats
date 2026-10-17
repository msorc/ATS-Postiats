#include "share/atspre_staload.hats"
staload "../pats_basics.sats"
dynload "../pats_basics.dats"

implement main0 () = {
  val () = assertloc (test_linkind (2))
  val () = assertloc (~test_linkind (1))
  val () = assertloc (test_polkind (24) = ~1)
  val () = fprint_funclo (stdout_ref, FUNCLOclo (~1))
  val () = fprint_funclo (stdout_ref, FUNCLOfun)
  val () = assertloc (FUNCLOclo (1) = FUNCLOcloptr)
  val () = fprint_valkind (stdout_ref, VK_prval)
  val () = debug_flag_set (1)
  val () = assertloc (debug_flag_get () = 1)
  val () = filprerr_ifdebug ("hello")
  val () = print_newline ()
}
