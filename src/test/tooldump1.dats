(* ATS1 reference of the differential tests of pats_depgen, pats_taggen and pats_jsonize (see tooldump.dats and PORTING.md, section Tools) *)
(* ****** ****** *)
#include "toolmods1.hats"

%{^
#include "tooldump.cats"
%}
extern fun pardump_load (path: string): void = "mac#pardump_load"
extern fun pardump_nextline (): ptr = "mac#pardump_nextline"
extern fun pardump_split (line: ptr): string = "mac#pardump_split"
extern fun tooldump_flush (): void = "mac#tooldump_flush"
extern fun tooldump_exit (code: int): void = "mac#tooldump_exit"
extern fun tooldump_atoi (s: string): int = "mac#tooldump_atoi"
extern fun patsopt_PATSHOME_set (): void = "mac#patsopt_PATSHOME_set"
extern fun patsopt_PATSHOME_get (): Stropt = "mac#patsopt_PATSHOME_get"
extern fun patsopt_PATSCONTRIB_set (): void = "mac#patsopt_PATSCONTRIB_set"
extern fun jz_pool_reset (): void = "mac#jz_pool_reset"
extern fun jz_tmp_begin (): FILEref = "mac#jz_tmp_begin"
extern fun jz_tmp_end (f: FILEref): string = "mac#jz_tmp_end"
extern fun jz_mkstr (lo: int, hi: int): string = "mac#jz_mkstr"
extern fun jz_double (k: int): double = "mac#jz_double"
extern fun tooldump_iats_once (): int = "mac#tooldump_iats_once"
extern fun tooldump_path (a: string, b: string): string = "mac#tooldump_path"

fn ps (s: string): void = fprint_string (stdout_ref, s)
fn nl (): void = fprint_newline (stdout_ref)

fn jz_tok (x: token): jsonval = let
  val f = jz_tmp_begin ()
  val () = fprint_token (f, x)
in jsonval_string (jz_tmp_end (f)) end

fn jz_ignored3 (): jsonval = jsonize_ignored ("ignored")
fn jz_null (): jsonval = JSONnul ()
fn jz_ints (): List (int) = list_cons (1, list_cons (2, list_cons (3, list_nil ())))
fn jz_nil_ints (): List (int) = list_nil ()
fn jz_some7 (): Option (int) = Some (7)
fn jz_none7 (): Option (int) = None ()
fn jz_symopt_none (): symbolopt = None ()
fn jz_symopt_some (s: symbol): symbolopt = Some (s)
fn jz_enums (): jsonval = let
  val xs = list_cons (
    jsonize_funclo (FUNCLOfun ()), list_cons (jsonize_funclo (FUNCLOclo (1)), list_cons (jsonize_funclo (FUNCLOclo (0)), list_cons (jsonize_funclo (FUNCLOclo (~1)),
    list_cons (jsonize_caskind (CK_case ()), list_cons (jsonize_caskind (CK_case_pos ()), list_cons (jsonize_caskind (CK_case_neg ()),
    list_cons (jsonize_funkind (FK_fn ()), list_cons (jsonize_funkind (FK_fnx ()), list_cons (jsonize_funkind (FK_fun ()), list_cons (jsonize_funkind (FK_prfn ()), list_cons (jsonize_funkind (FK_prfun ()),
    list_cons (jsonize_funkind (FK_praxi ()), list_cons (jsonize_funkind (FK_castfn ()),
    list_cons (jsonize_valkind (VK_val ()), list_cons (jsonize_valkind (VK_prval ()), list_cons (jsonize_valkind (VK_val_pos ()), list_cons (jsonize_valkind (VK_val_neg ()),
    list_cons (jsonize_dcstkind (DCKfun ()), list_cons (jsonize_dcstkind (DCKval ()), list_cons (jsonize_dcstkind (DCKpraxi ()), list_cons (jsonize_dcstkind (DCKprfun ()),
    list_cons (jsonize_dcstkind (DCKprval ()), list_cons (jsonize_dcstkind (DCKcastfn ()), list_nil ()))))))))))))))))))))))))
in JSONlist (xs) end

#include "jzdump1.hats"
#include "tooldump_api.hats"

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

fn mark (idx: int, kind: string, path: string): void = {
  val () = (ps "BEGIN "; fprint_int (stdout_ref, idx); ps " "; ps kind; ps " "; ps path; nl ())
  val () = (prerr "BEGIN "; prerr idx; prerr " "; prerr kind; prerr " "; prerr path; prerr_newline ())
}

fn parse_file (stadyn: int, path: string): d0eclist = let
  var fil: filename
in
  parse_from_givename_toplevel (stadyn, path, fil)
end

fn iats_setup (PATSHOME: string): void =
  if tooldump_iats_once () > 0 then {
    val () = process_IATS_dir (PATSHOME)
    val () = process_IATS_dir (tooldump_path (PATSHOME, "/prelude"))
    val () = process_IATS_dir (tooldump_path (PATSHOME, "/src"))
  }

fn exn_report (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_FIXITY_EXN()) => (ps "EXN PATSOPT_FIXITY_EXN")
  | ~($ERR.FatalErrorExn()) => (ps "EXN FatalErrorExn")
  | ~($ERR.FatalErrorExn_interr()) => (ps "EXN FatalErrorExn_interr")
  | ~($ERR.PATSOPT_FILENONE_EXN(fname)) => (ps "EXN PATSOPT_FILENONE_EXN "; ps fname)
  | exn => $raise(exn)

fn exn_end (): void = (nl (); tooldump_exit (3))

// mode: 0 depgen, 1 taggen, 2 jsonize
fn run_file (idx: int, kind: string, mode: int, stadyn: int, path: string): void = let
  val () = mark (idx, kind, path)
  val d0cs = try parse_file (stadyn, path) with exn => (exn_report (exn); exn_end (); (list_nil ()): d0eclist)
  val () =
    if mode = 0 then let
      val ents = $DEPGEN.depgen_eval (d0cs)
      val ((*popped*)) = $FIL.the_filenamelst_ppop ()
    in $DEPGEN.fprint_entlst (stdout_ref, path, ents) end
    else if mode = 1 then let
      val ents = $TAGGEN.taggen_proc (d0cs)
      val ((*popped*)) = $FIL.the_filenamelst_ppop ()
    in $TAGGEN.fprint_entlst (stdout_ref, path, ents) end
    else let
      val jv = jz_d0eclist (d0cs)
      val () = fprint_jsonval (stdout_ref, jv)
      val () = nl ()
      val () = jz_pool_reset ()
    in () end
  val () = (ps "END "; fprint_int (stdout_ref, idx); nl ())
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
  val start = (if argc >= 3 then tooldump_atoi (argv.[2]) else 1) : int
  fun loop (idx: int, start: int, PATSHOME: string): void = let
    val line = pardump_nextline ()
  in
    if ptr_isnot_null line then let
      val inp = pardump_split (line)
      val kind = $UN.cast{string} (line)
      val () =
        if idx >= start then (
          if kind = "DEPsta" then run_file (idx, kind, 0, 0, inp)
          else if kind = "DEPdyn" then run_file (idx, kind, 0, 1, inp)
          else if kind = "DEPIsta" then (iats_setup (PATSHOME); run_file (idx, kind, 0, 0, inp))
          else if kind = "DEPIdyn" then (iats_setup (PATSHOME); run_file (idx, kind, 0, 1, inp))
          else if kind = "TAGsta" then run_file (idx, kind, 1, 0, inp)
          else if kind = "TAGdyn" then run_file (idx, kind, 1, 1, inp)
          else if kind = "JSNsta" then run_file (idx, kind, 2, 0, inp)
          else if kind = "JSNdyn" then run_file (idx, kind, 2, 1, inp)
          else if kind = "API" then (mark (idx, kind, inp); api_run (); jz_pool_reset (); ps "END "; fprint_int (stdout_ref, idx); nl ())
          else ()
        ) // end of [if]
    in loop (idx + 1, start, PATSHOME) end else ()
  end
  val () = loop (1, start, PATSHOME)
  val () = (ps "FINISHED"; nl ())
  val () = tooldump_flush ()
in end
