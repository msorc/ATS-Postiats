(* ATS1 driver of the test of codegen2 and patcst2: the same as cgdump.dats, for the ATS1 build of src/ (see cgdump.dats) *)
(* ****** ****** *)
#include "cgcase_pre1.hats"

%{^
#include "cgenv_def.cats"
%}

dynload "pats_error.dats"
dynload "pats_intinf.dats"
dynload "pats_counter.dats"
dynload "pats_utils.dats"
dynload "pats_global.dats"
dynload "pats_basics.dats"
dynload "pats_stamp.dats"
dynload "pats_symbol.dats"
dynload "pats_filename.dats"
dynload "pats_location.dats"
dynload "pats_errmsg.dats"
dynload "pats_label.dats"
dynload "pats_effect.dats"
dynload "pats_fixity_prec.dats"
dynload "pats_fixity_fxty.dats"
dynload "pats_reader.dats"
dynload "pats_lexbuf.dats"
dynload "pats_lexing.dats"
dynload "pats_lexing_error.dats"
dynload "pats_lexing_print.dats"
dynload "pats_lexing_token.dats"
dynload "pats_syntax.dats"
dynload "pats_syntax_print.dats"
dynload "pats_tokbuf.dats"
dynload "pats_parsing.dats"
dynload "pats_parsing_util.dats"
dynload "pats_parsing_error.dats"
dynload "pats_parsing_kwds.dats"
dynload "pats_parsing_base.dats"
dynload "pats_parsing_e0xp.dats"
dynload "pats_parsing_sort.dats"
dynload "pats_parsing_staexp.dats"
dynload "pats_parsing_p0at.dats"
dynload "pats_parsing_dynexp.dats"
dynload "pats_parsing_decl.dats"
dynload "pats_parsing_toplevel.dats"
dynload "pats_staexp1.dats"
dynload "pats_staexp1_print.dats"
dynload "pats_dynexp1.dats"
dynload "pats_dynexp1_print.dats"
dynload "pats_staexp2_sort.dats"
dynload "pats_staexp2.dats"
dynload "pats_stacst2.dats"
dynload "pats_staexp2_scst.dats"
dynload "pats_staexp2_svar.dats"
dynload "pats_staexp2_svvar.dats"
dynload "pats_staexp2_dcon.dats"
dynload "pats_staexp2_hole.dats"
dynload "pats_staexp2_ctxt.dats"
dynload "pats_staexp2_error.dats"
dynload "pats_staexp2_print.dats"
dynload "pats_staexp2_pprint.dats"
dynload "pats_staexp2_szexp.dats"
dynload "pats_staexp2_skexp.dats"
dynload "pats_staexp2_util1.dats"
dynload "pats_staexp2_util2.dats"
dynload "pats_staexp2_util3.dats"
dynload "pats_staexp2_solve.dats"
dynload "pats_namespace.dats"
dynload "pats_dynexp2.dats"
dynload "pats_dynexp2_dcst.dats"
dynload "pats_dynexp2_dmac.dats"
dynload "pats_dynexp2_dvar.dats"
dynload "pats_dynexp2_mapgen.dats"
dynload "pats_dynexp2_print.dats"
dynload "pats_dynexp2_util.dats"
dynload "pats_patcst2.dats"
dynload "pats_codegen2.dats"
dynload "pats_codegen2_util.dats"
dynload "pats_codegen2_datype.dats"
dynload "pats_codegen2_fprint.dats"
dynload "pats_codegen2_absrec.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

implement filenv_get_name (x) = $FIL.filename_dummy
staload "pats_trans3_env.sats"
#include "cgenv1.hats"

(* the environments of the tests: the table of cgenv.cats *)
implement the_s2expenv_find (id) = let
  val p = cg_env_get (0, $SYM.symbol_get_name (id))
in
  if ptr_is_null (p) then None_vt () else Some_vt ($UN.cast{s2itm} (p))
end
implement the_s2expenv_pervasive_find (id) = let
  val p = cg_env_get (2, $SYM.symbol_get_name (id))
in
  if ptr_is_null (p) then None_vt () else Some_vt ($UN.cast{s2itm} (p))
end
implement the_d2expenv_find (id) = let
  val p = cg_env_get (1, $SYM.symbol_get_name (id))
in
  if ptr_is_null (p) then None_vt () else Some_vt ($UN.cast{d2itm} (p))
end

#include "cgchunks1.hats"

implement main () = {
  val () = tc_all ()
  val () = dd_flush ()
}
