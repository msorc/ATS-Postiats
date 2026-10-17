(* ATS2 driver of the test of the level-3 translation, group 3 (see PORTING.md, "Level 3 translation, group 3", and t3g3_gen.py): the driver of t3dump.dats
   with the modules of group 3 dynloaded and the test doubles of the functions of the other groups *)
(* ****** ****** *)
//
// Runs the generated cases (t3cases_*.hats) and prints their results with the complete dumpers (t3compat_gen.hats).
// t3dump1.dats is the same driver for the ATS1 build of src/: the two outputs (stdout and stderr) must be identical.
//
(* ****** ****** *)
#include "t3g3case_pre.hats"

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
dynload "../pats_patcst2.dats"
dynload "../pats_trans3_error.dats"
dynload "../pats_dynexp3.dats"
dynload "../pats_dynexp3_print.dats"
dynload "../pats_trans3_env.dats"
dynload "../pats_trans3_env_svar.dats"
dynload "../pats_trans3_env_scst.dats"
dynload "../pats_trans3_env_termet.dats"
dynload "../pats_trans3_env_effect.dats"
dynload "../pats_trans3_env_lamlp.dats"
dynload "../pats_trans3_env_print.dats"
dynload "../pats_trans3_env_pfman.dats"
dynload "../pats_trans3_env_dvar.dats"
dynload "../pats_trans3_env_lstate.dats"
dynload "../pats_trans3_p2at.dats"
dynload "../pats_trans3_selab.dats"
dynload "../pats_trans3_fldfrat.dats"
dynload "../pats_trans3_lvalres.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given
staload "../pats_syntax_boundary.sats"
implement parerr_p0at_as (loc) = ()
implement parerr_add_ifunclosed (loc, name) = ()
implement filenv_get_name (x) = $FIL.filename_dummy
implement filenv_get_d3eclistopt (x) = gopt_none ()
#include "t3env.hats"
#include "t3g3env.hats"
#include "t3g3chunks.hats"
implement main0 () = {
  val () = t3g3tc_all ()
  val () = dd_flush ()
}
