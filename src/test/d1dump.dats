(* ATS2 driver of the whole-file test of the level-1 translation (see PORTING.md, section Level 1 translation) *)
(* ****** ****** *)
//
// d1dump LIST [START [time]]: LIST is a file of lines "KIND<TAB>path" (KIND is FILEsta, FILEdyn, RAWsta or RAWdyn). For each file (from the
// line START on) the driver does what pats_main.dats does with the command line [patsopt -s/-d path]:
// parse_from_givename_toplevel, d0eclist_tr_errck, trans1_finalize (after the_prepathlst_push(PATSHOME),
// the_trans1_env_initialize and the_fixity_load), and dumps the d1eclist completely with the dumpers of
// deepdump.hats and deepdump_t1.hats (stdout). The errors go to stderr. A fatal error (an exception, an exit)
// ends the process after a marker line: the script d1files.sh restarts it with the next START.
// d1dump1.dats is the same driver for the ATS1 build of src/. The argument [time] translates without dumping.
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
staload UT = "../pats_utils.sats"
staload EFF = "../pats_effect.sats"
staload _ = "../pats_syntax.dats"
staload _ = "../pats_parsing_util.dats"
staload _ = "../pats_parsing.dats"
staload _ = "../pats_error.dats"
staload _ = "../pats_symmap.dats"

dynload "../pats_error.dats"
dynload "../pats_basics.dats"
dynload "../pats_utils.dats"
dynload "../pats_global.dats"
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

#include "deepdump.hats"
#include "deepdump_t1.hats"

fn ps (s: string): void = fprint_string (stdout_ref, s)
fn nl (): void = fprint_newline (stdout_ref)

fun pr_decls (ds: d1eclist): void = case+ glist_view (ds) of
  | ~GLcons (d, ds1) => (dd_d1ecl (d); nl (); pr_decls ds1)
  | ~GLnil () => ()

fn pr_stropt (opt: Stropt): void = $UT.fprint_stropt (stdout_ref, opt)

(* ****** ****** *)
//
// what pats_main.dats does (the_fixity_load)
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

(* ****** ****** *)

fn mark (idx: int, kind: string, path: string): void = {
  val () = (ps "BEGIN "; fprint_int (stdout_ref, idx); ps " "; ps kind; ps " "; ps path; nl ())
  val () = (prerr "BEGIN "; prerr idx; prerr " "; prerr kind; prerr " "; prerr path; prerr_newline ())
}

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
    with
    | ~$ERR.PATSOPT_FIXITY_EXN () => (ps "EXN PATSOPT_FIXITY_EXN"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.FatalErrorExn () => (ps "EXN FatalErrorExn"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.FatalErrorExn_interr () => (ps "EXN FatalErrorExn_interr"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.PATSOPT_FILENONE_EXN (fname) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname; nl (); d1dump_exit (3); glist_nil ())
  val () = $TRENV1.the_trans1_env_push ()
  // raw: d0eclist_tr without the final check of the errors (the d1eclist is dumped also when there are errors)
  val d1cs = try (if raw then d0eclist_tr (d0cs) else d0eclist_tr_errck (d0cs))
    with
    | ~$ERR.PATSOPT_FIXITY_EXN () => (ps "EXN PATSOPT_FIXITY_EXN"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.PATSOPT_TRANS1_EXN () => (ps "EXN PATSOPT_TRANS1_EXN"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.FatalErrorExn () => (ps "EXN FatalErrorExn"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.FatalErrorExn_interr () => (ps "EXN FatalErrorExn_interr"; nl (); d1dump_exit (3); glist_nil ())
    | ~$ERR.PATSOPT_FILENONE_EXN (fname) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname; nl (); d1dump_exit (3); glist_nil ())
  val () = try trans1_finalize ()
    with
    | ~$ERR.PATSOPT_FIXITY_EXN () => (ps "EXN PATSOPT_FIXITY_EXN"; nl (); d1dump_exit (3))
    | ~$ERR.PATSOPT_TRANS1_EXN () => (ps "EXN PATSOPT_TRANS1_EXN"; nl (); d1dump_exit (3))
    | ~$ERR.FatalErrorExn () => (ps "EXN FatalErrorExn"; nl (); d1dump_exit (3))
    | ~$ERR.FatalErrorExn_interr () => (ps "EXN FatalErrorExn_interr"; nl (); d1dump_exit (3))
    | ~$ERR.PATSOPT_FILENONE_EXN (fname) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname; nl (); d1dump_exit (3))
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
        with ~$ERR.PATSOPT_TRANS1_EXN () => (ps "EXN PATSOPT_TRANS1_EXN(raw)"; nl ())
    )
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
  val () = the_fixity_load (PATSHOME)
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
}
