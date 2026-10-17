(* ATS2 driver of the whole-file test of the type checker (see PORTING.md, "Level 3 integration") *)
(* ****** ****** *)
//
// f3dump LIST [START [time]]: LIST is a file of lines "KIND<TAB>path" (KIND is FILEsta, FILEdyn, RAWsta or RAWdyn). The driver does what
// pats_main.dats does for `patsopt -s/-d path` up to the level 3: the_trans1_env_initialize, the_trans2_env_initialize, the_prelude_load
// (the_fixity_load and pervasive_load of the files of the prelude, stacst2_initialize), the_trans3_env_initialize, then for each file (from the
// line START on) parse_from_givename_toplevel, d0eclist_tr_errck, trans1_finalize, d1eclist_tr_errck, d2eclist_tr_errck (RAW: d1eclist_tr and
// d2eclist_tr, the errors are counted after the dump), the_trans3_finget_constraint (what pats_main hands to the constraint solver), and dumps the
// d3eclist and the c3nstr completely (f3dd.hats). The errors go to stderr. A fatal error (an exception, an exit) ends the process after a
// marker line, as does the alarm of 60 s of a file (the ATS1 hang of p2at_trdn_exist): f3chunk.sh restarts it with the next START.
// f3dump1.dats is the same driver for the ATS1 build of src/.
//
(* ****** ****** *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
#include "../mylibies.hats"
staload SYM = "../pats_symbol.sats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload LAB = "../pats_label.sats"
staload ERR = "../pats_error.sats"
staload GLOB = "../pats_global.sats"
staload INT = "../pats_intinf.sats"
staload CNTR = "../pats_counter.sats"
staload STMP = "../pats_stamp.sats"
staload "../pats_basics.sats"
staload "../pats_lexing.sats"
staload "../pats_tokbuf.sats"
staload "../pats_syntax.sats"
staload "../pats_parsing.sats"
staload "../pats_effect.sats"
staload "../pats_fixity.sats"
staload "../pats_symmap.sats"
staload "../pats_staexp1.sats"
staload "../pats_dynexp1.sats"
staload "../pats_trans1.sats"
staload TRENV1 = "../pats_trans1_env.sats"
staload "../pats_staexp2.sats"
staload "../pats_staexp2_util.sats"
staload "../pats_stacst2.sats"
staload "../pats_dynexp2.sats"
staload "../pats_trans2.sats"
staload TRENV2 = "../pats_trans2_env.sats"
staload "../pats_trans2_env.sats"
staload "../pats_patcst2.sats"
staload "../pats_dynexp3.sats"
staload "../pats_trans3.sats"
staload TRENV3 = "../pats_trans3_env.sats"
staload "../pats_trans3_env.sats"
staload UT = "../pats_utils.sats"
staload EFF = "../pats_effect.sats"
staload _ = "../pats_syntax.dats"
staload _ = "../pats_parsing_util.dats"
staload _ = "../pats_parsing.dats"
staload _ = "../pats_error.dats"
staload _ = "../pats_symmap.dats"
staload _ = "../pats_utils.dats"
staload _ = "../pats_avlmap.dats"
staload _ = "../pats_staexp2_scst.dats"
staload _ = "../pats_dynexp2_dcst.dats"
staload _ = "../pats_dynexp2_dvar.dats"
staload _ = "../pats_namespace.dats"
staload "../pats_errmsg.sats"
staload _ = "../pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_env"

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
dynload "../pats_fixity_prec.dats"
dynload "../pats_fixity_fxty.dats"
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
dynload "../pats_symmap.dats"
dynload "../pats_symenv.dats"
dynload "../pats_parsing.dats"
dynload "../pats_parsing_util.dats"
dynload "../pats_parsing_error.dats"
dynload "../pats_parsing_kwds.dats"
dynload "../pats_parsing_base.dats"
dynload "../pats_parsing_e0xp.dats"
dynload "../pats_parsing_sort.dats"
dynload "../pats_parsing_staexp.dats"
dynload "../pats_parsing_p0at.dats"
dynload "../pats_parsing_dynexp.dats"
dynload "../pats_parsing_decl.dats"
dynload "../pats_parsing_toplevel.dats"
dynload "../pats_trans1_env.dats"
dynload "../pats_e1xpval.dats"
dynload "../pats_e1xpval_error.dats"
dynload "../pats_trans1_e0xp.dats"
dynload "../pats_trans1_error.dats"
dynload "../pats_trans1_effect.dats"
dynload "../pats_trans1_sort.dats"
dynload "../pats_trans1_staexp.dats"
dynload "../pats_trans1_p0at.dats"
dynload "../pats_trans1_syndef.dats"
dynload "../pats_trans1_dynexp.dats"
dynload "../pats_trans1_decl.dats"
dynload "../pats_filename_reloc.dats"
dynload "../pats_avlmap.dats"
dynload "../pats_staexp2_sort.dats"
dynload "../pats_staexp2.dats"
dynload "../pats_staexp2_scst.dats"
dynload "../pats_staexp2_svar.dats"
dynload "../pats_staexp2_svvar.dats"
dynload "../pats_staexp2_dcon.dats"
dynload "../pats_staexp2_hole.dats"
dynload "../pats_staexp2_ctxt.dats"
dynload "../pats_staexp2_error.dats"
dynload "../pats_staexp2_print.dats"
dynload "../pats_staexp2_pprint.dats"
dynload "../pats_staexp2_szexp.dats"
dynload "../pats_staexp2_skexp.dats"
dynload "../pats_staexp2_util1.dats"
dynload "../pats_staexp2_util2.dats"
dynload "../pats_staexp2_util3.dats"
dynload "../pats_stacst2.dats"
dynload "../pats_namespace.dats"
dynload "../pats_dynexp2.dats"
dynload "../pats_dyncst2.dats"
dynload "../pats_dynexp2_dcst.dats"
dynload "../pats_dynexp2_dmac.dats"
dynload "../pats_dynexp2_dvar.dats"
dynload "../pats_dynexp2_print.dats"
dynload "../pats_dynexp2_util.dats"
dynload "../pats_trans2_env.dats"
dynload "../pats_trans2_error.dats"
dynload "../pats_trans2_sort.dats"
dynload "../pats_trans2_staexp.dats"
dynload "../pats_trans2_p1at.dats"
dynload "../pats_trans2_dynexp.dats"
dynload "../pats_trans2_impdec.dats"
dynload "../pats_trans2_decl.dats"
dynload "../pats_staexp2_solve.dats"
dynload "../pats_dynexp2_mapgen.dats"
dynload "../pats_patcst2.dats"
dynload "../pats_dmacro2.dats"
dynload "../pats_dmacro2_eval0.dats"
dynload "../pats_dmacro2_eval1.dats"
dynload "../pats_dmacro2_print.dats"
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
dynload "../pats_trans3_syncst.dats"
dynload "../pats_trans3_util.dats"
dynload "../pats_trans3_dynexp_up.dats"
dynload "../pats_trans3_dynexp_dn.dats"
dynload "../pats_trans3_appsym.dats"
dynload "../pats_trans3_caseof.dats"
dynload "../pats_trans3_patcon.dats"
dynload "../pats_trans3_p2at.dats"
dynload "../pats_trans3_selab.dats"
dynload "../pats_trans3_fldfrat.dats"
dynload "../pats_trans3_lvalres.dats"
dynload "../pats_trans3_ptrof.dats"
dynload "../pats_trans3_viewat.dats"
dynload "../pats_trans3_deref.dats"
dynload "../pats_trans3_assgn.dats"
dynload "../pats_trans3_xchng.dats"
dynload "../pats_trans3_looping.dats"
dynload "../pats_trans3_decl.dats"

%{^
#include "f3dump.cats"
%}
extern fun pardump_load (path: string): void = "mac#pardump_load"
extern fun pardump_nextline (): ptr = "mac#pardump_nextline"
extern fun pardump_split (line: ptr): string = "mac#pardump_split"
extern fun d1dump_flush (): void = "mac#d1dump_flush"
extern fun d1dump_exit (code: int): void = "mac#d1dump_exit"
extern fun f3dump_alarm (n: int): void = "mac#f3dump_alarm"
extern fun d1dump_atoi (s: string): int = "mac#d1dump_atoi"
extern fun patsopt_PATSHOME_set (): void = "mac#patsopt_PATSHOME_set"
extern fun patsopt_PATSHOME_get (): Stropt = "mac#patsopt_PATSHOME_get"
extern fun patsopt_PATSCONTRIB_set (): void = "mac#patsopt_PATSCONTRIB_set"

(* ****** ****** *)
val dd_out = stdout_ref
#include "t2dd_common.hats"
#include "t2dd_lang2.hats"
fun dd_p2atcstlst (x: p2atcstlst): void = fprint_p2atcstlst (dd_out, x)
#include "f3dd.hats"

fn ps (s: string): void = fprint_string (stdout_ref, s)
fn nl (): void = fprint_newline (stdout_ref)

fun pr_decls (ds: d3eclist): void = case+ glist_view (ds) of
  | ~GLcons (d, ds1) => (dd_d3ecl (d); nl (); pr_decls ds1)
  | ~GLnil () => ()

(* ****** ****** *)

fn exn_report (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_FIXITY_EXN()) => (ps "EXN PATSOPT_FIXITY_EXN"; nl ())
  | ~($ERR.PATSOPT_TRANS1_EXN()) => (ps "EXN PATSOPT_TRANS1_EXN"; nl ())
  | ~($ERR.PATSOPT_TRANS2_EXN()) => (ps "EXN PATSOPT_TRANS2_EXN"; nl ())
  | ~($ERR.PATSOPT_TRANS3_EXN()) => (ps "EXN PATSOPT_TRANS3_EXN"; nl ())
  | ~($ERR.FatalErrorExn()) => (ps "EXN FatalErrorExn"; nl ())
  | ~($ERR.FatalErrorExn_interr()) => (ps "EXN FatalErrorExn_interr"; nl ())
  | ~($ERR.PATSOPT_FILENONE_EXN(fname)) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname; nl ())
  | exn => $raise(exn)

fn exn_report_raw (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_TRANS2_EXN()) => (ps "EXN PATSOPT_TRANS2_EXN(raw)"; nl ())
  | ~($ERR.PATSOPT_TRANS3_EXN()) => (ps "EXN PATSOPT_TRANS3_EXN(raw)"; nl ())
  | exn => $raise(exn)

(* ****** ****** *)
//
// what pats_main.dats does (the_fixity_load, pervasive_load, the_prelude_load)
//
fn the_fixity_load (PATSHOME: string): void = let
  val given = "prelude/fixity.ats"
  val fullname = $FIL.filename_dirbase (PATSHOME, given)
  val fullname_s = the_garena_strdup ($UN.castvwtp1{string} (fullname))
  val () = strptr_free (fullname)
  val filename = $FIL.filename_make (given, given, fullname_s)
  val (pffil | ()) = $FIL.the_filenamelst_push (filename)
  val d0cs = parse_from_filename_toplevel (0(*sta*), filename)
  val ((*popped*)) = $FIL.the_filenamelst_pop (pffil | (*none*))
  val () = $TRENV1.the_fxtyenv_push_nil ((*void*))
  val d1cs = d0eclist_tr_errck (d0cs)
  val fxtymap = $TRENV1.the_fxtyenv_pop ((*none*))
  val ((*joined*)) = $TRENV1.the_fxtyenv_pervasive_joinwth (fxtymap)
in end

fn pervasive_load (PATSHOME: string, given: string): void = let
  val fullname = $FIL.filename_dirbase (PATSHOME, given)
  val fullname_s = the_garena_strdup ($UN.castvwtp1{string} (fullname))
  val () = strptr_free (fullname)
  val filename = $FIL.filename_make (given, given, fullname_s)
  val (pfpush | ()) = $FIL.the_filenamelst_push (filename)
  val d0cs = parse_from_filename_toplevel (0(*sta*), filename)
  val ((*popped*)) = $FIL.the_filenamelst_pop (pfpush | (*none*))
  val PACKNAME = "ATSLIB.prelude"
  val ((*default*)) = $GLOB.the_PACKNAME_set_name (PACKNAME)
  val ((*default*)) = $TRENV1.the_EXTERN_PREFIX_set ("atspre_")
  val () = $TRENV1.the_trans1_env_push ((*void*))
  val d1cs = d0eclist_tr_errck (d0cs)
  val ((*popped*)) = $TRENV1.the_trans1_env_pop ((*none*))
  val () = $TRENV2.the_trans2_env_push ((*void*))
  val d2cs = d1eclist_tr_errck (d1cs)
  val ((*joined*)) = $TRENV2.the_trans2_env_pervasive_joinwth1 (filename, d2cs)
  val ((*reset*)) = $GLOB.the_PACKNAME_set_none ()
  val ((*reset*)) = $TRENV1.the_EXTERN_PREFIX_set_none ()
in end

fn the_prelude_load (PATSHOME: string): void = {
  val () = the_fixity_load (PATSHOME)
  val () = pervasive_load (PATSHOME, "prelude/basics_pre.sats")
  val () = pervasive_load (PATSHOME, "prelude/basics_sta.sats")
  val () = pervasive_load (PATSHOME, "prelude/basics_dyn.sats")
  val () = pervasive_load (PATSHOME, "prelude/basics_gen.sats")
  val () = pervasive_load (PATSHOME, "prelude/macrodef.sats")
  val () = stacst2_initialize () // internalizing some static consts
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/pointer.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/arith_prf.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer_long.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer_size.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer_short.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/bool.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/char.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/float.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/string.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/strptr.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer_ptr.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/integer_fixed.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/tuple.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/memory.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/reference.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/filebas.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/intrange.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/gorder.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/gnumber.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/grandom.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/checkast.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/list_vt.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/option_vt.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/array.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/array_prf.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/arrayptr.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/matrix.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/matrixptr.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/stream_vt.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/gprint.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/tostring.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/parray.sats")
  val () = pervasive_load (PATSHOME, "prelude/SATS/extern.sats")
}

(* ****** ****** *)

fn mark (idx: int, kind: string, path: string): void = {
  val () = (ps "BEGIN "; fprint_int (stdout_ref, idx); ps " "; ps kind; ps " "; ps path; nl ())
  val () = (prerr "BEGIN "; prerr idx; prerr " "; prerr kind; prerr " "; prerr path; prerr_newline ())
  val () = d1dump_flush ()
  val () = f3dump_alarm (60)
}

fn parse_file (stadyn: int, path: string): d0eclist = let
  var fil: filename
in
  parse_from_givename_toplevel (stadyn, path, fil)
end

fn pr_stropt (opt: Stropt): void = $UT.fprint_stropt (stdout_ref, opt)

fn run_file (idx: int, kind: string, stadyn: int, path: string, dump: bool, raw: bool): void = let
  val () = mark (idx, kind, path)
  val () = if stadyn >= 1 then $GLOB.the_DYNLOADFLAG_set (1)
  val d0cs = try parse_file (stadyn, path)
    with exn => (exn_report (exn); d1dump_exit (3); (glist_nil ()): d0eclist)
  val () = $TRENV1.the_trans1_env_push ()
  val () = $TRENV2.the_trans2_env_push ()
  val d1cs: d1eclist = try d0eclist_tr_errck (d0cs)
    with exn => (exn_report (exn); d1dump_exit (3); (glist_nil ()): d1eclist)
  val () = try trans1_finalize () with exn => (exn_report (exn); d1dump_exit (3))
  // raw: d1eclist_tr and d2eclist_tr without the final check of the errors (the trees are dumped also when there are errors)
  val d2cs: d2eclist = try (if raw then d1eclist_tr (d1cs) else d1eclist_tr_errck (d1cs))
    with exn => (exn_report (exn); d1dump_exit (3); (glist_nil ()): d2eclist)
  val d3cs: d3eclist = try (if raw then d2eclist_tr (d2cs) else d2eclist_tr_errck (d2cs))
    with exn => (exn_report (exn); d1dump_exit (3); (glist_nil ()): d3eclist)
  val c3t = $TRENV3.the_trans3_finget_constraint ()
  val () =
    if dump then {
      val () = pr_decls (d3cs)
      val () = (ps "CNSTR "; dd_c3nstr c3t; nl ())
      val () = (ps "END "; fprint_int (stdout_ref, idx); nl ())
    }
  val () =
    if raw then (
      (try the_trans2errlst_finalize () with exn => (exn_report_raw (exn); ());
       try the_trans3errlst_finalize () with exn => (exn_report_raw (exn); ()))
    )
  val () = d1dump_flush ()
  val () = $TRENV2.the_trans2_env_pop ()
  val () = $TRENV1.the_trans1_env_pop ()
in end

implement main0 (argc, argv) = {
  val () = patsopt_PATSHOME_set ()
  val () = patsopt_PATSCONTRIB_set ()
  val opt = patsopt_PATSHOME_get ()
  val () = assertloc (stropt_is_some opt)
  val PATSHOME = stropt_unsome opt
  val () = $FIL.the_prepathlst_push (PATSHOME)
  val () = $TRENV1.the_trans1_env_initialize ()
  val () = $TRENV2.the_trans2_env_initialize ()
  val () = the_prelude_load (PATSHOME)
  val () = $TRENV3.the_trans3_env_initialize ()
  val () = assertloc (argc >= 2)
  val () = pardump_load (argv[1])
  val start = (if argc >= 3 then d1dump_atoi (argv[2]) else 1) : int
  val dump = (if argc >= 4 then false else true) : bool
  fun loop (idx: int, start: int, dump: bool): void = let
    val line = pardump_nextline ()
  in
    if ptr_isnot_null line then let
      val inp = pardump_split (line)
      val kind = $UN.cast{string} (line)
      val () =
        if idx >= start then (
          if kind = "FILEsta" then run_file (idx, kind, 0, inp, dump, false)
          else if kind = "FILEdyn" then run_file (idx, kind, 1, inp, dump, false)
          else if kind = "RAWsta" then run_file (idx, kind, 0, inp, dump, true)
          else if kind = "RAWdyn" then run_file (idx, kind, 1, inp, dump, true)
          else ()
        ) // end of [if]
    in loop (idx + 1, start, dump) end else ()
  end
  val () = loop (1, start, dump)
  val () = (ps "FINISHED"; nl ())
  val () = d1dump_flush ()
}
