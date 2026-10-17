(* ATS1 reference of the differential test of pats_comarg (see comdump.dats and PORTING.md, section Tools) *)
(* ****** ****** *)
#include "toolmods1.hats"

%{^
#include "comdump.cats"
%}
extern fun tooldump_flush (): void = "mac#tooldump_flush"
extern fun tooldump_exit (code: int): void = "mac#tooldump_exit"
extern fun patsopt_PATSHOME_set (): void = "mac#patsopt_PATSHOME_set"
extern fun patsopt_PATSHOME_get (): Stropt = "mac#patsopt_PATSHOME_get"
extern fun patsopt_PATSCONTRIB_set (): void = "mac#patsopt_PATSCONTRIB_set"
extern fun patsopt_PATSRELOCROOT_set (): void = "mac#patsopt_PATSRELOCROOT_set"
extern fun cm_push (k: int, s: string): void = "mac#cm_push"
extern fun cm_run (i: int): void = "mac#cm_run"
extern fun cm_state (): void = "mac#cm_state"
extern fun cm_nprobes_get (): int = "mac#cm_nprobes_get"
extern fun cm_probe_get (i: int): string = "mac#cm_probe_get"
extern fun cm_call (which: int, arg: ptr): ptr = "cm_call"

(* ****** ****** *)

fn ps (s: string): void = fprint_string (stdout_ref, s)
fn nl (): void = fprint_newline (stdout_ref)
fn pr_stropt (opt: Stropt): void = $UT.fprint_stropt (stdout_ref, opt)

implement cm_call (which, arg) = let
  val s = $UN.cast{string} (arg)
  fn ofbool (b: bool): ptr = if b then $UN.cast{ptr} (1) else null
  fn ofopt (o: Stropt): ptr = if stropt_is_some (o) then $UN.cast{ptr} (stropt_unsome (o)) else null
in
  case+ which of
  | 1 => ofbool (is_DATS_flag (s))
  | 2 => ofbool (is_IATS_flag (s))
  | 3 => ofopt (DATS_extract (s))
  | 4 => ofopt (IATS_extract (s))
  | 5 => (process_DATS_def (s); null)
  | 6 => (process_IATS_dir (s); null)
  | _ => (comarg_warning (s); null)
end

(* ****** ****** *)

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

fn exn_report (exn: exn): void =
  case+ exn of
  | ~($ERR.PATSOPT_FIXITY_EXN()) => (ps "EXN PATSOPT_FIXITY_EXN"; nl ())
  | ~($ERR.PATSOPT_TRANS1_EXN()) => (ps "EXN PATSOPT_TRANS1_EXN"; nl ())
  | ~($ERR.FatalErrorExn()) => (ps "EXN FatalErrorExn"; nl ())
  | ~($ERR.FatalErrorExn_interr()) => (ps "EXN FatalErrorExn_interr"; nl ())
  | exn => $raise(exn)

fun pr_dirs (xs: List (string), i: int): void =
  case+ xs of
  | list_cons (x, xs1) => (ps "IATSDIR "; fprint_int (stdout_ref, i); ps " "; ps x; nl (); pr_dirs (xs1, i+1))
  | list_nil () => ()

fun pr_probes (i: int, n: int): void =
  if i < n then let
    val name = cm_probe_get (i)
    val sym = $SYM.symbol_make_string (name)
    val () = (ps "PROBE "; ps name; ps " = ")
    val () =
      case+ $TRENV1.the_e1xpenv_find (sym) of
      | ~Some_vt (x) => fprint_e1xp (stdout_ref, x)
      | ~None_vt () => ps "(none)"
    val () = nl ()
  in pr_probes (i+1, n) end

implement main (argc, argv) = let
  val () = patsopt_PATSHOME_set ()
  val () = patsopt_PATSCONTRIB_set ()
  val () = patsopt_PATSRELOCROOT_set ()
  val opt = patsopt_PATSHOME_get ()
  val () = assertloc (stropt_is_some opt)
  val PATSHOME = stropt_unsome opt
  val () = $FIL.the_prepathlst_push (PATSHOME)
  val () = $TRENV1.the_trans1_env_initialize ()
  val () = the_fixity_load (PATSHOME)
  val () = process_PATSRELOCROOT ()
  //
  val arglst = comarglst_parse (argc, argv)
  //
  val+ ~list_vt_cons (arg0, arglst) = arglst
  val () = (ps "ARG0 "; print_comarg (arg0); nl ())
  fun loop {n:nat} (xs: list_vt (comarg, n)): void =
    case+ xs of
    | ~list_vt_nil () => ()
    | ~list_vt_cons (x, xs1) => let
        val () = (ps "ARG "; print_comarg (x); nl ())
        val+ COMARG (k, s) = x
        val () = cm_push (k, s)
      in loop (xs1) end
  val () = loop (arglst)
  val () = try cm_run (0) with exn => (exn_report (exn); tooldump_exit (3))
  val () = cm_state ()
  val () = pr_dirs ($GLOB.the_IATS_dirlst_get (), 0)
  val () = pr_probes (0, cm_nprobes_get ())
  val () = ps "PROBE PATSRELOCROOT = "
  val () = (
    case+ $TRENV1.the_e1xpenv_find ($SYM.symbol_PATSRELOCROOT) of
      | ~Some_vt (x) => fprint_e1xp (stdout_ref, x)
      | ~None_vt () => ps "(none)"
  ) : void
  val () = nl ()
  val () = ps "DONE"
  val () = nl ()
  val () = tooldump_flush ()
in end
