(* ATS1 reference of the whole-file test of the level-1 translation (see d1dump.dats and PORTING.md, section Level 1 translation) *)
(* ****** ****** *)
//
// The ATS1 version of d1dump.dats, linked with the ATS1 build of src/ (pats_trans1*.dats, ...).
//
(* ****** ****** *)
#define ATS_DYNLOADFLAG 0

staload "libc/SATS/stdio.sats"
staload UN = "prelude/SATS/unsafe.sats"
staload SYM = "pats_symbol.sats"
staload FIL = "pats_filename.sats"
staload LOC = "pats_location.sats"
staload LAB = "pats_label.sats"
staload ERR = "pats_error.sats"
staload GLOB = "pats_global.sats"
staload "pats_basics.sats"
staload "pats_lexing.sats"
staload "pats_syntax.sats"
staload "pats_fixity.sats"
staload "pats_tokbuf.sats"
staload "pats_parsing.sats"
staload "pats_effect.sats"
staload "pats_staexp1.sats"
staload "pats_dynexp1.sats"
staload "pats_trans1.sats"
staload TRENV1 = "pats_trans1_env.sats"
staload UT = "pats_utils.sats"
staload EFF = "pats_effect.sats"

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
dynload "pats_symmap.dats"
dynload "pats_symenv.dats"
dynload "pats_trans1_env.dats"
dynload "pats_e1xpval.dats"
dynload "pats_e1xpval_error.dats"
dynload "pats_trans1_e0xp.dats"
dynload "pats_trans1_error.dats"
dynload "pats_trans1_effect.dats"
dynload "pats_trans1_sort.dats"
dynload "pats_trans1_staexp.dats"
dynload "pats_trans1_p0at.dats"
dynload "pats_trans1_syndef.dats"
dynload "pats_trans1_dynexp.dats"
dynload "pats_trans1_decl.dats"
dynload "pats_filename_reloc.dats"

%{^
#include "d1dump.cats"
%}
extern fun pardump_load (path: string): void = "mac#pardump_load"
extern fun pardump_nextline (): ptr = "mac#pardump_nextline"
extern fun pardump_split (line: ptr): string = "mac#pardump_split"
extern fun d1dump_seen (s: string): int = "mac#d1dump_seen"
extern fun d1dump_flush (): void = "mac#d1dump_flush"
extern fun d1dump_exit (code: int): void = "mac#d1dump_exit"
extern fun d1dump_atoi (s: string): int = "mac#d1dump_atoi"
extern fun patsopt_PATSHOME_set (): void = "mac#patsopt_PATSHOME_set"
extern fun patsopt_PATSHOME_get (): Stropt = "mac#patsopt_PATSHOME_get"
extern fun patsopt_PATSCONTRIB_set (): void = "mac#patsopt_PATSCONTRIB_set"

(* ****** ****** *)

fn dd_staload_seen (fil: filename): bool =
  d1dump_seen ($SYM.symbol_get_name ($FIL.filename_get_fullname (fil))) > 0

#include "deepdump1.hats"
#include "deepdump1_t1.hats"

fn ps (s: string): void = fprint_string (stdout_ref, s)
fn nl (): void = fprint_newline (stdout_ref)

fun pr_decls (ds: d1eclist): void = case+ ds of
  | list_cons (d, ds1) => (dd_d1ecl d; nl (); pr_decls ds1)
  | list_nil () => ()

fn pr_stropt (opt: Stropt): void = $UT.fprint_stropt (stdout_ref, opt)

(* ****** ****** *)
//
// what pats_main.dats does (the_fixity_load)
//
fn the_fixity_load (PATSHOME: string): void = let
  val given = "prelude/fixity.ats"
  val fullname = $FIL.filename_dirbase (PATSHOME, given)
  val fullname = string_of_strptr (fullname)
  val filename = $FIL.filename_make (given, given, fullname)
  val (pffil | ()) = $FIL.the_filenamelst_push (filename)
  val d0cs = parse_from_filename_toplevel (0(*sta*), filename)
  val ((*popped*)) = $FIL.the_filenamelst_pop (pffil | (*none*))
  val (pfenv | ()) = $TRENV1.the_fxtyenv_push_nil ((*void*))
  val d1cs = d0eclist_tr_errck (d0cs)
  val fxtymap = $TRENV1.the_fxtyenv_pop (pfenv | (*none*))
  val ((*joined*)) = $TRENV1.the_fxtyenv_pervasive_joinwth (fxtymap)
in end

(* ****** ****** *)

fn mark (idx: int, kind: string, path: string): void = {
  val () = (ps "BEGIN "; fprint_int (stdout_ref, idx); ps " "; ps kind; ps " "; ps path; nl ())
  val () = (prerr "BEGIN "; prerr idx; prerr " "; prerr kind; prerr " "; prerr path; prerr_newline ())
}

fn exn_report_raw (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_TRANS1_EXN()) => (ps "EXN PATSOPT_TRANS1_EXN(raw)"; nl ())
  | exn => $raise(exn)

fn parse_file (stadyn: int, path: string): d0eclist = let
  var fil: filename
in
  parse_from_givename_toplevel (stadyn, path, fil)
end

fn exn_report (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_FIXITY_EXN()) => (ps "EXN PATSOPT_FIXITY_EXN"; nl ())
  | ~($ERR.PATSOPT_TRANS1_EXN()) => (ps "EXN PATSOPT_TRANS1_EXN"; nl ())
  | ~($ERR.FatalErrorExn()) => (ps "EXN FatalErrorExn"; nl ())
  | ~($ERR.FatalErrorExn_interr()) => (ps "EXN FatalErrorExn_interr"; nl ())
  | ~($ERR.PATSOPT_FILENONE_EXN(fname)) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname; nl ())
  | exn => $raise(exn)

fn parse_file (stadyn: int, path: string): d0eclist = let
  var fil: filename
in
  parse_from_givename_toplevel (stadyn, path, fil)
end

fn run_file (idx: int, kind: string, stadyn: int, path: string, dump: bool, raw: bool, rel: bool): void = let
  val () = mark (idx, kind, path)
  // rel: as the option --atsreloc of pats_main does
  val () = if rel then $GLOB.the_ATSRELOC_set (1)
  val d0cs = try parse_file (stadyn, path)
    with exn => (exn_report (exn); d1dump_exit (3); (list_nil ()): d0eclist)
  val (pfenv | ()) = $TRENV1.the_trans1_env_push ()
  // raw: d0eclist_tr without the final check of the errors (the d1eclist is dumped also when there are errors)
  val d1cs: d1eclist = try (if raw then d0eclist_tr (d0cs) else d0eclist_tr_errck (d0cs))
    with exn => (exn_report (exn); d1dump_exit (3); (list_nil ()): d1eclist)
  val () = try trans1_finalize () with exn => (exn_report (exn); d1dump_exit (3))
  val () =
    if dump then {
      val () = pr_decls (d1cs)
      val () = (ps "DYNLOADFLAG="; fprint_int (stdout_ref, $GLOB.the_DYNLOADFLAG_get ()); nl ())
      val () = (ps "DYNLOADNAME="; pr_stropt ($GLOB.the_DYNLOADNAME_get ()); nl ())
      val () = (ps "MAINATSFLAG="; fprint_int (stdout_ref, $GLOB.the_MAINATSFLAG_get ()); nl ())
      val () = (ps "STATIC_PREFIX="; pr_stropt ($GLOB.the_STATIC_PREFIX_get ()); nl ())
      val () = (ps "PACKNAME="; pr_stropt ($GLOB.the_PACKNAME_get ()); nl ())
      val () = (ps "END "; fprint_int (stdout_ref, idx); nl ())
    }
  val () = if rel then {
    val () = $TRENV1.fprint_atsrelocitmlst (stdout_ref, $TRENV1.the_atsrelocitmlst_get ())
    val () = $GLOB.the_ATSRELOC_set (0)
  }
  val () =
    if raw then (
      try the_trans1errlst_finalize ()
        with exn => (exn_report_raw (exn); ())
    )
  val () = $TRENV1.the_trans1_env_pop (pfenv | (*none*))
in end

implement main (argc, argv) = let
  val () = patsopt_PATSHOME_set ()
  val () = patsopt_PATSCONTRIB_set ()
  val opt = patsopt_PATSHOME_get ()
  val () = assertloc (stropt_is_some opt)
  val PATSHOME = stropt_unsome opt
  val () = $FIL.the_prepathlst_push (PATSHOME)
  val () = $TRENV1.the_trans1_env_initialize ()
  val () = the_fixity_load (PATSHOME)
  val () = assertloc (argc >= 2)
  val () = pardump_load (argv.[1])
  val start = (if argc >= 3 then d1dump_atoi (argv.[2]) else 1) : int
  val dump = (if argc >= 4 then false else true) : bool
  fun loop (idx: int, start: int, dump: bool): void = let
    val line = pardump_nextline ()
  in
    if ptr_isnot_null line then let
      val inp = pardump_split (line)
      val kind = $UN.cast{string} (line)
      val () =
        if idx >= start then (
          if kind = "FILEsta" then run_file (idx, kind, 0, inp, dump, false, false)
          else if kind = "FILEdyn" then run_file (idx, kind, 1, inp, dump, false, false)
          else if kind = "RAWsta" then run_file (idx, kind, 0, inp, dump, true, false)
          else if kind = "RAWdyn" then run_file (idx, kind, 1, inp, dump, true, false)
          else if kind = "RELsta" then run_file (idx, kind, 0, inp, dump, false, true)
          else if kind = "RELdyn" then run_file (idx, kind, 1, inp, dump, false, true)
          else ()
        ) // end of [if]
    in loop (idx + 1, start, dump) end else ()
  end
  val () = loop (1, start, dump)
  val () = (ps "FINISHED"; nl ())
  val () = d1dump_flush ()
in end
