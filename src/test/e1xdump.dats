(* ATS2 driver of the e1xp evaluator (see PORTING.md, section Level 1) *)
(* ****** ****** *)
//
// Reads a file of "KIND<TAB>text" lines (KIND: TOPsta, TOPdyn, FILEsta, FILEdyn), parses the text
// (or the file) with the toplevel parser, and plays the directives of the declarations with the
// evaluator of pats_e1xpval.dats: #define / #undef (the definition is translated to an e1xp, added to
// the environment, printed, evaluated and normalized), #print/#prerr/#error/#assert (the argument
// is evaluated and printed), #if/#ifdef/#ifndef/#elif/#else (the condition is evaluated and the
// declarations of the chosen branch are played). The translation e0xp -> e1xp is a version of
// [e0xp_tr] of src/pats_trans1_e0xp.dats with a precedence climbing for a fixed table of operators
// in place of the fixity environment. e1xdump1.dats is the same driver for the ATS1 build of src/.
//
(* ****** ****** *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
#include "../mylibies.hats"
staload SYM = "../pats_symbol.sats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload ERR = "../pats_error.sats"
staload "../pats_basics.sats"
staload "../pats_lexing.sats"
staload "../pats_tokbuf.sats"
staload "../pats_syntax.sats"
staload "../pats_parsing.sats"
staload "../pats_effect.sats"
staload "../pats_staexp1.sats"
staload "../pats_e1xpval.sats"
staload "../pats_trans1_env.sats"
staload "../pats_symmap.sats"
staload _ = "../pats_symmap.dats"
staload _ = "../pats_syntax.dats"
staload _ = "../pats_parsing_util.dats"
staload _ = "../pats_parsing.dats"
staload _ = "../pats_error.dats"

dynload "../pats_error.dats"
dynload "../pats_basics.dats"
dynload "../pats_utils.dats"
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
dynload "../pats_trans1_env.dats"
dynload "../pats_e1xpval.dats"
dynload "../pats_e1xpval_error.dats"
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
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

%{^
#include "pardump.cats"
#include "e1xdump.cats"
%}
extern fun pardump_load (path: string): void = "mac#pardump_load"
extern fun pardump_nextline (): ptr = "mac#pardump_nextline"
extern fun pardump_split (line: ptr): string = "mac#pardump_split"
extern fun pardump_readfile (path: string): string = "mac#pardump_readfile"
extern fun e1xd_it_push (e: ptr, prec: int): int = "mac#e1xd_it_push"
extern fun e1xd_it_count (): int = "mac#e1xd_it_count"
extern fun e1xd_it_gete (i: int): ptr = "mac#e1xd_it_gete"
extern fun e1xd_it_getp (i: int): int = "mac#e1xd_it_getp"
extern fun e1xd_it_truncate (n: int): void = "mac#e1xd_it_truncate"
extern fun e1xd_it_cur_get (): int = "mac#e1xd_it_cur_get"
extern fun e1xd_it_cur_set (i: int): void = "mac#e1xd_it_cur_set"
extern fun e1xd_oprec (name: string): int = "mac#e1xd_oprec"
extern fun e1xd_flush (): void = "mac#e1xd_flush"

macdef out = stdout_ref
fn ps (s: string): void = fprint_string (out, s)
fn nl (): void = (fprint_newline (out); e1xd_flush ())
fn psym (x: symbol): void = $SYM.fprint_symbol (out, x)

overload + with $LOC.location_combine

(* ****** ****** *)

fn e1xp_e2p (e: e1xp): ptr = $UN.cast{ptr} (e)
fn e1xp_p2e (p: ptr): e1xp = $UN.cast{e1xp} (p)

fn mk_args (x: e1xp): e1xplst =
  case+ e1xp_node_view (x.e1xp_node ()) of
  | ~E1XPlist xs => xs
  | v => (e1xp_node_view_free (v); glist_sing (x))

fn mk_app1 (f: e1xp, x: e1xp): e1xp = let
  val loc_f = f.e1xp_loc () and loc_x = x.e1xp_loc ()
in
  e1xp_app (loc_f + loc_x, f, loc_x, mk_args (x))
end // end of [mk_app1]

fn mk_app2 (f: e1xp, x: e1xp, y: e1xp): e1xp = let
  val loc_x = x.e1xp_loc () and loc_y = y.e1xp_loc ()
in
  e1xp_app (loc_x + loc_y, f, loc_y, glist_cons (x, glist_sing (y)))
end // end of [mk_app2]

(* ****** ****** *)

// the evaluation of an expression that may abort
fn valize_if_try (knd: srpifkind, e: e1xp): v1al =
  try e1xp_valize_if (knd, e) with
  | ~$ERR.FatalErrorExn () => (ps "ABORT"; nl (); v1al_V1ALerr ())

fn normalize_try (e: e1xp): e1xp =
  try e1xp_normalize (e) with
  | ~$ERR.FatalErrorExn () => (ps "ABORT"; nl (); e1xp_err (e.e1xp_loc ()))

(* ****** ****** *)

fun e0xp_tr (e0: e0xp): e1xp = let
  val loc0 = e0.e0xp_loc ()
in
  case+ e0xp_node_view (e0.e0xp_node ()) of
  | ~E0XPide id => e1xp_ide (loc0, id)
  | ~E0XPint x => e1xp_i0nt (loc0, x)
  | ~E0XPchar x => e1xp_c0har (loc0, x)
  | ~E0XPstring x => e1xp_s0tring (loc0, x)
  | ~E0XPstringid str => e1xp_string (loc0, str)
  | ~E0XPfloat x => e1xp_f0loat (loc0, x)
  | ~E0XPlist es => e1xp_list (loc0, e0xplst_tr (es))
  | ~E0XPapp (e1, e2) => let
      val save = e1xd_it_cur_get ()
      val base = e1xd_it_count ()
      val () = push_item (e1)
      val () = push_item (e2)
      val n = e1xd_it_count ()
      val () = e1xd_it_cur_set (base)
      val res = parse_bin (loc0, n, 1)
      val () = e1xd_it_truncate (base)
      val () = e1xd_it_cur_set (save)
    in
      res
    end // end of [E0XPapp]
  | ~E0XPfun (arg, body) => e1xp_fun (loc0, arg, e0xp_tr (body))
  | ~E0XPif (e0_cond, e0_then, e0_else) => let
      val e1_cond = e0xp_tr (e0_cond)
      val e1_then = e0xp_tr (e0_then)
      val e1_else = (
        case+ gopt_view (e0_else) of ~GOsome x => e0xp_tr (x) | ~GOnone () => e1xp_none (loc0)
      ) : e1xp
    in
      e1xp_if (loc0, e1_cond, e1_then, e1_else)
    end
  | ~E0XPeval (e0) => let
      val e1 = e0xp_tr (e0)
      val v1 = (
        try e1xp_valize (e1) with
        | ~$ERR.FatalErrorExn () => (ps "ABORT"; nl (); v1al_V1ALerr ())
      ) : v1al
    in
      e1xp_v1al (loc0, v1)
    end
end // end of [e0xp_tr]

// the atoms of a (left-nested) application chain, left to right
and push_item (e: e0xp): void =
  case+ e0xp_node_view (e.e0xp_node ()) of
  | ~E0XPapp (e1, e2) => (push_item (e1); push_item (e2))
  | ~E0XPide id => let
      val prec = e1xd_oprec ($SYM.symbol_get_name (id))
      val _ = e1xd_it_push (e1xp_e2p (e1xp_ide (e.e0xp_loc (), id)), prec)
    in () end
  | v => let
      val () = e0xp_node_view_free (v)
      val _ = e1xd_it_push (e1xp_e2p (e0xp_tr (e)), 0)
    in () end

and e0xplst_tr (es: e0xplst): e1xplst =
  case+ glist_view (es) of
  | ~GLcons (e, es1) => let
      val x = e0xp_tr (e) in glist_cons (x, e0xplst_tr (es1))
    end
  | ~GLnil () => glist_nil ()

// a sequence of atoms (a prefix [~] operator applies to the sequence that follows)
and parse_seq (loc0: location, n: int): e1xp = let
  val i = e1xd_it_cur_get ()
in
  if i >= n then e1xp_err (loc0)
  else let
    val prec = e1xd_it_getp (i)
    val a = e1xp_p2e (e1xd_it_gete (i))
    val () = e1xd_it_cur_set (i+1)
  in
    if prec < 0 then let
      val x = parse_seq (loc0, n) in mk_app1 (a, x)
    end else if prec > 0 then e1xp_err (a.e1xp_loc ()) // an infix operator in the place of an operand
    else parse_args (a, n)
  end
end // end of [parse_seq]

and parse_args (f: e1xp, n: int): e1xp = let
  val i = e1xd_it_cur_get ()
in
  if i < n then (
    if e1xd_it_getp (i) = 0 then let
      val x = e1xp_p2e (e1xd_it_gete (i))
      val () = e1xd_it_cur_set (i+1)
    in
      parse_args (mk_app1 (f, x), n)
    end else f
  ) else f
end // end of [parse_args]

and parse_bin (loc0: location, n: int, minp: int): e1xp = let
  val lhs = parse_seq (loc0, n)
in
  parse_bin_loop (loc0, n, minp, lhs)
end // end of [parse_bin]

and parse_bin_loop (loc0: location, n: int, minp: int, lhs: e1xp): e1xp = let
  val i = e1xd_it_cur_get ()
in
  if i < n then let
    val prec = e1xd_it_getp (i)
  in
    if prec > 0 andalso prec >= minp then let
      val opr = e1xp_p2e (e1xd_it_gete (i))
      val () = e1xd_it_cur_set (i+1)
      val rhs = parse_bin (loc0, n, prec+1)
    in
      parse_bin_loop (loc0, n, minp, mk_app2 (opr, lhs, rhs))
    end else lhs
  end else lhs
end // end of [parse_bin_loop]

(* ****** ****** *)

fn pr_knd (knd: srpifkind): void =
  case+ knd of
  | SRPIFKINDif () => ps "if" | SRPIFKINDifdef () => ps "ifdef" | SRPIFKINDifndef () => ps "ifndef"

fn pr_val (v: v1al): void = (fprint_v1al (out, v); nl ())

fn do_def (loc0: location, id: symbol, def: e1xp): void = let
  val () = the_e1xpenv_add (id, def)
  val () = (ps "DEF "; psym id; ps " = "; fprint_e1xp (out, def); nl ())
  val () = (ps "VAL "; pr_val (valize_if_try (SRPIFKINDif (), def)))
  val () = (ps "NORM "; fprint_e1xp (out, normalize_try (def)); nl ())
in end

fun proc_decls (ds: d0eclist): void =
  case+ glist_view (ds) of
  | ~GLcons (d, ds1) => (proc_decl (d); proc_decls (ds1))
  | ~GLnil () => ()

and proc_decl (d: d0ecl): void = let
  val loc0 = d.d0ecl_loc ()
in
  case+ d0ecl_node_view (d.d0ecl_node ()) of
  | ~D0Ce0xpdef (id, opt) => let
      val def = (
        case+ gopt_view (opt) of ~GOsome e => e0xp_tr (e) | ~GOnone () => e1xp_none (loc0)
      ) : e1xp
    in do_def (loc0, id, def) end
  | ~D0Ce0xpundef (id) => let
      val def = e1xp_undef (loc0)
      val () = the_e1xpenv_add (id, def)
    in (ps "UNDEF "; psym id; nl ()) end
  | ~D0Ce0xpact (knd, e0) => let
      val e1 = e0xp_tr (e0)
      val () = (ps "ACT "; fprint_e0xpactkind (out, knd); ps " "; fprint_e1xp (out, e1); nl ())
    in
      pr_val (valize_if_try (SRPIFKINDif (), e1))
    end
  | ~D0Cguadecl (knd, gd) => proc_guad (knd, gd.guad0ecl_node ())
  | ~D0Clocal (ds1, ds2) => (proc_decls (ds1); proc_decls (ds2))
  | ~D0Cstaloadloc (_, _, ds) => proc_decls (ds)
  | v => d0ecl_node_view_free (v)
end // end of [proc_decl]

and proc_guad (knd: srpifkind, gdn: guad0ecl_node): void =
  case+ guad0ecl_node_view (gdn) of
  | ~GD0Cone (e0, ds) => let
      val e1 = e0xp_tr (e0)
      val () = (ps "COND "; pr_knd knd; ps " "; fprint_e1xp (out, e1); nl ())
      val v = valize_if_try (knd, e1)
      val () = pr_val (v)
    in
      if v1al_is_true (v) then proc_decls (ds) else ()
    end
  | ~GD0Ctwo (e0, ds_then, ds_else) => let
      val e1 = e0xp_tr (e0)
      val () = (ps "COND "; pr_knd knd; ps " "; fprint_e1xp (out, e1); nl ())
      val v = valize_if_try (knd, e1)
      val () = pr_val (v)
    in
      if v1al_is_true (v) then proc_decls (ds_then) else proc_decls (ds_else)
    end
  | ~GD0Ccons (e0, ds_then, knd_elif, gdn_else) => let
      val e1 = e0xp_tr (e0)
      val () = (ps "COND "; pr_knd knd; ps " "; fprint_e1xp (out, e1); nl ())
      val v = valize_if_try (knd, e1)
      val () = pr_val (v)
    in
      if v1al_is_true (v) then proc_decls (ds_then) else proc_guad (knd_elif, gdn_else)
    end

(* ****** ****** *)

fun run_top (stadyn: int, inp: string): void = let
  var buf: tokbuf
  val () = tokbuf_initize_string (buf, inp)
  var nerr: int
  val ds = (if stadyn = 0 then p_toplevel_sta (buf, nerr) else p_toplevel_dyn (buf, nerr)) : d0eclist
  val () = tokbuf_uninitize (buf)
  val () = proc_decls (ds)
  val () = (ps "nerr="; fprint_int (out, nerr); nl ())
in end

fun dispatch (kind: string, inp: string): void =
  if kind = "TOPsta" then run_top (0, inp) else
  if kind = "TOPdyn" then run_top (1, inp) else
  if kind = "FILEsta" then run_top (0, pardump_readfile inp) else
  if kind = "FILEdyn" then run_top (1, pardump_readfile inp) else
  (ps "UNKNOWN KIND"; nl ())

fun run_case (kind: string, inp: string): void = let
  val () = the_lexerrlst_clear ()
  val () = the_parerrlst_clear ()
  val () = ps kind
  val () = ps ": "
  val () = ps inp
  val () = nl ()
  val () = the_e1xpenv_push_nil () // a fresh scope for each case
  val () = dispatch (kind, inp)
  val () = symmap_free<e1xp> (the_e1xpenv_pop ())
  val _ = fprint_the_lexerrlst (out)
  val _ = fprint_the_parerrlst (out)
in
end

fun loop (): void = let
  val p = pardump_nextline ()
in
  if ptr_isnot_null p then let
    val inp = pardump_split (p)
    val kind = $UN.cast{string} (p)
    val () = run_case (kind, inp)
  in loop () end else ()
end

implement main0 (argc, argv) = if argc >= 2 then let
  val () = pardump_load (argv[1])
in loop () end else ()
