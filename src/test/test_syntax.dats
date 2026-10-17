//
// test of pats_syntax / pats_syntax_print: build some trees and print them
// (compare with test_syntax.expected, which is derived from the ATS1
// [src/pats_syntax_print.dats])
//
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/hashtbl_linprb.dats"
staload _ = "libats/DATS/hashfun.dats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload SYM = "../pats_symbol.sats"
staload LAB = "../pats_label.sats"
staload "../pats_basics.sats"
staload "../pats_lexing.sats"
staload "../pats_syntax_boundary.sats"
staload "../pats_syntax.sats"
dynload "../pats_basics.dats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_label.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
dynload "../pats_reader.dats"
dynload "../pats_lexbuf.dats"
dynload "../pats_lexing_token.dats"
dynload "../pats_lexing.dats"
dynload "../pats_lexing_error.dats"
dynload "../pats_lexing_print.dats"
dynload "../pats_tokbuf.dats"
dynload "../pats_syntax.dats"
dynload "../pats_syntax_print.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

(* ****** ****** *)
//
// tokens: the tokens of the lexer (pats_lexing), built by hand
//
fn tok_make (loc: location, node: token_node): token = token_TOKEN (loc, node)

implement parerr_p0at_as (loc) = fprint_string (stdout_ref, "parerr(p0at_as)\n")
implement parerr_add_ifunclosed (loc, name) = ()

(* ****** ****** *)

fn mkloc (i: int, j: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, g0int2int_int_lint(i), 0, i)
  val () = $LOC.position_init (p2, g0int2int_int_lint(j), 0, j)
  val fil = $FIL.filename_make ("./a.dats", "./a.dats", "/x/a.dats")
in $LOC.location_make_fil_pos_pos (fil, p1, p2) end

(* the i-th token, at the position i *)
fn tk (i: int, s: string): token = tok_make (mkloc (i, i+1), token_node_T_NONE ())
fn tint (i: int, s: string): token = tok_make (mkloc (i, i+1), token_node_T_INT (10, s, 0u))
fn tstr (i: int, s: string): token = tok_make (mkloc (i, i+1), token_node_T_STRING (s))
fn tki (i: int, k: int): token = tok_make (mkloc (i, i+1), token_node_T_DOTINT (k))
fn ttype (i: int, k: int): token = tok_make (mkloc (i, i+1), token_node_T_TYPEDEF (k))
fn tfix (i: int): token = tok_make (mkloc (i, i+1), token_node_T_FIXITY (FXK_infixl))
fn tcode (i: int, pos: int, code: string): token = tok_make (mkloc (i, i+1), token_node_T_EXTCODE (pos, code))
fn ide (i: int, s: string): i0de = i0de_make_string (mkloc (i, i+1), s)
fn sym (s: string) = $SYM.symbol_make_string (s)

implement main0 () = {
//
// e0xp
//
val ef = e0xp_i0de (ide (1, "f"))
val e3 = e0xp_i0nt (tint (2, "3"))
val () = fprint_e0xp (stdout_ref, ef); val () = print_newline ()
val () = fprint_e0xp (stdout_ref, e3); val () = print_newline ()
val eapp = e0xp_app (ef, e3)
val () = fprint_e0xp (stdout_ref, eapp); val () = print_newline ()
val xs = glist_cons (ef, glist_sing (e3))
val () = fprint_e0xp (stdout_ref, e0xp_list (tk (0, "("), xs, tk (5, ")"))); val () = print_newline ()
val () = fprint_e0xp (stdout_ref, e0xp_if (tk (0, "#if"), ef, e3, gopt_none ())); val () = print_newline ()
val () = fprint_e0xp (stdout_ref, e0xp_if (tk (0, "#if"), ef, e3, gopt_some (eapp))); val () = print_newline ()
val () = assertloc ($LOC.location_beg_ntot (eapp.e0xp_loc ()) = 1L)
val () = assertloc ($LOC.location_end_ntot (eapp.e0xp_loc ()) = 3L)
//
// s0exp
//
val sa = s0exp_i0de (ide (1, "a"))
val sb = s0exp_i0de (ide (2, "b"))
val sc = s0exp_i0nt (tint (3, "10"))
val () = fprint_s0exp (stdout_ref, s0exp_app (sa, sb)); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, sc); val () = print_newline ()
val sab = glist_cons (sa, glist_sing (sb))
val () = fprint_s0exp (stdout_ref, s0exp_list (tk (0, "("), sab, tk (4, ")"))); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_list2 (tk (0, "("), sab, glist_sing (sc), tk (4, ")"))); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_tytup (0, tk (0, "@("), ~1, sab, tk (4, ")"))); val () = print_newline ()
val lx = l0ab_make_label (mkloc (1, 2), $LAB.label_make_string "x")
val ly = l0ab_make_i0nt (tint (2, "7"))
val lr = glist_cons (labs0exp_make (lx, gopt_none (), sa), glist_sing (labs0exp_make (ly, gopt_none (), sb)))
val () = fprint_s0exp (stdout_ref, s0exp_tyrec (1, tk (0, "'("), ~1, lr, tk (4, ")"))); val () = print_newline ()
val srt = s0rt_i0de (ide (5, "int"))
val sq = s0qua_vars (ide (1, "n"), glist_nil (), s0rtext_srt (srt))
val sq2 = s0qua_prop (sa)
val () = fprint_s0exp (stdout_ref, s0exp_uni (tk (0, "["), glist_cons (sq, glist_sing (sq2)), tk (4, "]"))); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_exi (0, tk (0, "["), glist_sing (sq), tk (4, "]"))); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_ann (sa, srt)); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_extype (tk (0, "$extype"), tstr (1, "\"foo_t\""), sab)); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_sqid (s0taq_symdot (ide (1, "M"), tk (2, ".")), ide (3, "t"))); val () = print_newline ()
val () = fprint_s0exp (stdout_ref, s0exp_lams (tk (0, "lam"), glist_sing (s0marg_make_one (s0arg_make (ide (1, "x"), gopt_none ()))), gopt_none (), sa)); val () = print_newline ()
val sapp = s0exp_app (sa, sb)
val () = assertloc ($LOC.location_beg_ntot (sapp.s0exp_loc ()) = 1L)
//
// p0at
//
val px = p0at_i0de (ide (1, "x"))
val py = p0at_i0de (ide (2, "y"))
val pxy = glist_cons (px, glist_sing (py))
val () = fprint_p0at (stdout_ref, px); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_app (px, py)); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_list (tk (0, "("), ~1, pxy, tk (3, ")"))); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_tup (0, tk (0, "@("), ~1, pxy, tk (3, ")"))); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_lst (0, tk (0, "@["), pxy, tk (3, "]"))); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_ann (px, sa)); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_refas (px, py)); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_refas (p0at_app (px, py), py)); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_err (mkloc (0, 1))); val () = print_newline ()
val () = fprint_p0at (stdout_ref, p0at_rec (0, tk (0, "@{"), ~1, glist_sing (labp0at_norm (lx, px)), tk (3, "}"))); val () = print_newline ()
//
// d0exp
//
val df = d0exp_ide (ide (1, "f"))
val d1 = d0exp_i0nt (tint (2, "1"))
val dd = glist_cons (df, glist_sing (d1))
val () = fprint_d0exp (stdout_ref, df); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_app (df, d1)); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_list (tk (0, "("), ~1, dd, tk (3, ")"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_seq (tk (0, "("), dd, tk (3, ")"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_seq (tk (0, "("), glist_nil (), tk (3, ")"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_tup (1, tk (0, "'("), ~1, dd, tk (3, ")"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_ann (df, sa)); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_effmask_arg (1, tk (0, "$effmask_wrt"), df)); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_ptrof (tk (0, "addr@"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_delay (1, tk (0, "$ldelay"), df)); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_loopexn (1, tk (0, "continue"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_MYLOC (tk (0, "$mylocation"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_where (df, glist_nil (), tk (4, "end"))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_ifhead (ifhead_new (tk (0, "if"), i0nvresstate_make_none (mkloc (0, 1))), df, d1, gopt_some (df))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_sel_int (tki (3, 2))); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_sel_lab (s0elop_make_dot (tk (1, ".")), lx)); val () = print_newline ()
val () = fprint_d0exp (stdout_ref, d0exp_arrsub (dqi0de_make_none (ide (0, "A")), d0arrind_sing (dd, tk (5, "]")))); val () = print_newline ()
val dapp = d0exp_app (df, d1)
val () = assertloc ($LOC.location_beg_ntot (dapp.d0exp_loc ()) = 1L)
//
// d0ecl
//
val ids = glist_cons (ide (1, "plus"), glist_sing (ide (2, "minus")))
val () = fprint_d0ecl (stdout_ref, d0ecl_fixity (tfix (0), p0rec_emp (), ids)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_nonfix (tk (0, "nonfix"), ids)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_symintr (tk (0, "symintr"), ids)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_e0xpdef (tk (0, "#define"), ide (1, "N"), gopt_some (e3))); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_e0xpundef (tk (0, "#undef"), ide (1, "N"))); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_e0xpact_print (tk (0, "#print"), ef)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_codegen2 (tk (0, "#codegen2"), xs, tk (5, ")"))); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_local (tk (0, "local"), glist_nil (), glist_nil (), tk (9, "end"))); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_extype (tk (0, "extype"), tstr (1, "\"t\""), sa)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_extype2 (ttype (0, 1), tstr (1, "\"t\""), sa)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_extvar (tk (0, "extvar"), tstr (1, "\"v\""), df)); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_extcode (0, tcode (0, 0, "code"))); val () = print_newline ()
val () = fprint_d0ecl (stdout_ref, d0ecl_fundecs (FK_fun, tk (0, "fun"), glist_nil (), glist_nil ())); val () = print_newline ()
//
// misc
//
val () = assertloc (s0taq_is_none (the_s0taq_none) && d0ynq_is_none (the_d0ynq_none))
val () = assertloc (lamkind_isbox (0) = 1 && lamkind_islin (~1) = 0)
val () = assertloc (dcstextdef_is_ext (dcstextdef_DCSTEXTDEFsome_ext ("x")))
}
