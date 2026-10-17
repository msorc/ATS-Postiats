(* ATS2 driver of the test of the core modules of ccomp (see PORTING.md, "ccomp core modules", and cc_gen.py) *)
(* ****** ****** *)
//
// Runs the generated cases (hd_cases_*.hats) and prints their results with the complete dumpers (hd_compat2.hats).
// hddump1.dats is the same driver for the ATS1 build of src/: the two outputs (stdout and stderr) must be identical.
//
(* ****** ****** *)
#include "cc_pre.hats"

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
dynload "../pats_typerase_error.dats"
dynload "../pats_typerase_staexp.dats"
dynload "../pats_typerase_dynexp.dats"
dynload "../pats_typerase_decl.dats"
dynload "../pats_ccomp.dats"
dynload "../pats_ccomp_print.dats"
dynload "../pats_ccomp_tmplab.dats"
dynload "../pats_ccomp_tmpvar.dats"
dynload "../pats_ccomp_d2env.dats"
dynload "../pats_ccomp_funlab.dats"
dynload "../pats_ccomp_funent.dats"
dynload "../pats_ccomp_util.dats"
dynload "../pats_ccomp_instrseq.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

staload "../pats_syntax_boundary.sats"
implement parerr_p0at_as (loc) = ()
implement parerr_add_ifunclosed (loc, name) = ()
implement filenv_get_name (x) = $FIL.filename_dummy
implement filenv_getref_d3eclistopt (fenv) = hd_fenv_cell (fenv, 0)
implement filenv_getref_tmpcstimpmap (fenv) = hd_fenv_cell (fenv, 1)
implement filenv_getref_tmpvardecmap (fenv) = hd_fenv_cell (fenv, 2)
implement filenv_get_d3eclistopt (fenv) = $UN.ptr0_get<d3eclistopt> (filenv_getref_d3eclistopt (fenv))
#include "s2env2.hats"
implement the_d2varlev_get () = cc_lev_get ()
implement fprint_tmprimval (out, x) = (
  case+ tmprimval_view (x) of
  | ~TPMVnone (pmv) => (fprint_string (out, "TPMVnone("); fprint_primval (out, pmv); fprint_string (out, ")"))
  | ~TPMVsome (tmp, pmv) => (fprint_string (out, "TPMVsome("); fprint_tmpvar (out, tmp); fprint_string (out, "<-"); fprint_primval (out, pmv); fprint_string (out, ")"))
)
#include "cc_chunks.hats"
#include "cc_exit.hats"
extern fun cc_getexit (): int = "mac#cc_getexit"
%{^
extern int cc_getexit (void) ;
%}
implement main0 () = {
  val k = cc_getexit ()
  val () = if k > 0 then cc_exit (k) else tc_all ()
  val () = dd_flush ()
}
