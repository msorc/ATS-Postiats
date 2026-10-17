(* ATS2 driver of the test of the erased trees and of the type erasure (see PORTING.md, "Erased trees (hidynexp)", "Type erasure (typerase)", and hd_gen.py) *)
(* ****** ****** *)
//
// Runs the generated cases (hd_cases_*.hats) and prints their results with the complete dumpers (hd_compat2.hats).
// hddump1.dats is the same driver for the ATS1 build of src/: the two outputs (stdout and stderr) must be identical.
//
(* ****** ****** *)
#include "ca_pre.hats"

dynload "../pats_error.dats"
dynload "../pats_basics.dats"
dynload "../pats_utils.dats"
dynload "../pats_global.dats"
dynload "../pats_intinf.dats"
dynload "../pats_counter.dats"
dynload "../pats_stamp.dats"
dynload "../pats_errmsg.dats"
dynload "../pats_symbol.dats"
dynload "../pats_label.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
dynload "../pats_effect.dats"
dynload "../pats_reader.dats"
dynload "../pats_lexbuf.dats"
dynload "../pats_lexing_token.dats"
dynload "../pats_lexing.dats"
dynload "../pats_lexing_error.dats"
dynload "../pats_lexing_print.dats"
dynload "../pats_tokbuf.dats"
dynload "../pats_syntax.dats"
dynload "../pats_syntax_print.dats"
dynload "../pats_staexp1.dats"
dynload "../pats_staexp1_print.dats"
dynload "../pats_dynexp1.dats"
dynload "../pats_dynexp1_print.dats"
dynload "../pats_avlmap.dats"
dynload "../pats_staexp2_sort.dats"
dynload "../pats_staexp2.dats"
dynload "../pats_stacst2.dats"
dynload "../pats_staexp2_scst.dats"
dynload "../pats_staexp2_svar.dats"
dynload "../pats_staexp2_svvar.dats"
dynload "../pats_staexp2_dcon.dats"
dynload "../pats_staexp2_hole.dats"
dynload "../pats_staexp2_ctxt.dats"
dynload "../pats_staexp2_error.dats"
dynload "../pats_staexp2_solve.dats"
dynload "../pats_staexp2_print.dats"
dynload "../pats_staexp2_pprint.dats"
dynload "../pats_staexp2_szexp.dats"
dynload "../pats_staexp2_skexp.dats"
dynload "../pats_staexp2_util1.dats"
dynload "../pats_staexp2_util2.dats"
dynload "../pats_staexp2_util3.dats"
dynload "../pats_namespace.dats"
dynload "../pats_dynexp2.dats"
dynload "../pats_dynexp2_dcst.dats"
dynload "../pats_dynexp2_dmac.dats"
dynload "../pats_dynexp2_dvar.dats"
dynload "../pats_dynexp2_mapgen.dats"
dynload "../pats_dynexp2_print.dats"
dynload "../pats_dynexp2_util.dats"
dynload "../pats_dynexp3.dats"
dynload "../pats_dynexp3_print.dats"
dynload "../pats_histaexp.dats"
dynload "../pats_histaexp_print.dats"
dynload "../pats_histaexp_funlab.dats"
dynload "../pats_hidynexp.dats"
dynload "../pats_hidynexp_print.dats"
dynload "../pats_hidynexp_util.dats"
dynload "../pats_ccomp_emit.dats"
dynload "../pats_ccomp_emit2.dats"
dynload "../pats_ccomp_emit3.dats"
dynload "ca_dbl.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

staload "../pats_syntax_boundary.sats"
implement parerr_p0at_as (loc) = ()
implement parerr_add_ifunclosed (loc, name) = ()
implement filenv_get_name (x) = $FIL.filename_dummy
// (called by pats_hidynexp.dats; the cases never call them)
implement $TRENV2.filenv_getref_tmpcstimpmap (fenv) = $UN.cast{Ptr1} (1)
implement $TRENV2.filenv_getref_tmpvardecmap (fenv) = $UN.cast{Ptr1} (1)
staload "../pats_trans2_env.sats"
#include "s2env2.hats"
#include "ca_chunks.hats"
#include "ca_exit.hats"
implement main0 () = {
  val k = H_getexit ()
  val () = if k > 0 then ca_exit (k) else tc_all ()
  val () = dd_flush ()
}
