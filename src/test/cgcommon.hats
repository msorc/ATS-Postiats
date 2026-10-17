(* the part of the test of codegen2/patcst2 (cgdump.dats, cgdump1.dats) that is written once for ATS1 and ATS2: the common subset;
   the including file provides the staloads, dd_out, the compat layers of the level-2 test and cgcompat(1)_hand.hats *)
(* ****** ****** *)
//
// the environment table (cgenv.cats): the items are s2itm (kind 0, the_s2expenv_find), d2itm (kind 1, the_d2expenv_find),
// s2itm of the pervasives (kind 2, the_s2expenv_pervasive_find); the key is the name
//
fun cg_add_s2cst (c: s2cst): void =
  cg_env_put (0, $SYM.symbol_get_name (s2cst_get_sym c), $UN.cast{ptr} (K_S2ITMcst (LC_s2cstlst (c, LN_s2cstlst ()))))
fun cg_add_s2cst_as (name: string, c: s2cst): void =
  cg_env_put (0, name, $UN.cast{ptr} (K_S2ITMcst (LC_s2cstlst (c, LN_s2cstlst ()))))
fun cg_add_s2cst2 (name: string, c1: s2cst, c2: s2cst): void =
  cg_env_put (0, name, $UN.cast{ptr} (K_S2ITMcst (LC_s2cstlst (c1, LC_s2cstlst (c2, LN_s2cstlst ())))))
fun cg_add_s2itm_nil (name: string): void =
  cg_env_put (0, name, $UN.cast{ptr} (K_S2ITMcst (LN_s2cstlst ())))
fun cg_add_s2itm_var (name: string, v: s2var): void =
  cg_env_put (0, name, $UN.cast{ptr} (K_S2ITMvar (v)))
fun cg_add_d2cst (c: d2cst): void =
  cg_env_put (1, $SYM.symbol_get_name (d2cst_get_sym c), $UN.cast{ptr} (K_D2ITMcst (c)))
fun cg_add_d2cst_as (name: string, c: d2cst): void =
  cg_env_put (1, name, $UN.cast{ptr} (K_D2ITMcst (c)))
fun cg_add_d2itm_var (name: string, v: d2var): void =
  cg_env_put (1, name, $UN.cast{ptr} (K_D2ITMvar (v)))
fun cg_add_pervasive (name: string, c: s2cst): void =
  cg_env_put (2, name, $UN.cast{ptr} (K_S2ITMcst (LC_s2cstlst (c, LN_s2cstlst ()))))
(* ****** ****** *)
//
fun dd_optvt_s2cst (x: Option_vt (s2cst)): void =
  case+ x of ~Some_vt (c) => (dd_ps "Some_vt("; dd_s2cst c; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_d2cst (x: Option_vt (d2cst)): void =
  case+ x of ~Some_vt (c) => (dd_ps "Some_vt("; dd_d2cst c; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
//
(* ****** ****** *)
//
// the universe of the patterns: the constant [list_vt0ype_int_vtype] that [p2atcst_lst] finds as a pervasive (pats_stacst2 keeps the
// first one it finds, so it is made once) and its constructors (kind 3)
//
fun cg_init_universe (): void = {
  val c = s2cst_make ($SYM.symbol_make_string "list_vt0ype_int_vtype", mkloc (0), mkfil (0), s2rt_vtype, ON_s2expoptopt (), true, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())
  val dnil = d2con_make (mkloc (0), mkfil (0), $SYM.symbol_make_string "list_vt_nil", c, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())
  val dcons = d2con_make (mkloc (0), mkfil (0), $SYM.symbol_make_string "list_vt_cons", c, 0, LN_s2qualst (), 0, LC_s2explst (s2exp_int (0), LC_s2explst (s2exp_int (1), LN_s2explst ())), ON_s2explstopt ())
  val () = d2con_set_tag (dnil, 0)
  val () = d2con_set_tag (dcons, 1)
  val () = s2cst_set_dconlst (c, OS_d2conlstopt (LC_d2conlst (dnil, LC_d2conlst (dcons, LN_d2conlst ()))))
  val () = s2cst_set_islst (c, OS_d2conpairopt (K_d2conpair (dnil, dcons)))
  val () = cg_env_put (2, "list_vt0ype_int_vtype", $UN.cast{ptr} (K_S2ITMcst (LC_s2cstlst (c, LN_s2cstlst ()))))
  val () = cg_env_put (3, "lnil", $UN.cast{ptr} (dnil))
  val () = cg_env_put (3, "lcons", $UN.cast{ptr} (dcons))
}
fun cg_lnil (): d2con = $UN.cast{d2con} (cg_env_get (3, "lnil"))
fun cg_lcons (): d2con = $UN.cast{d2con} (cg_env_get (3, "lcons"))
//
(* ****** ****** *)
//
// patcst2: the output of the linear results (they are freed here), and the case-checking loop of pats_trans3_caseof.dats
//
fun cg_pr_vt (xs: p2atcstlst_vt): void = (print_p2atcstlst_vt (xs); print_newline (); prerr_p2atcstlst_vt (xs); prerr_newline (); fprint_p2atcstlst (dd_out, cg_vt2lst (xs)); dd_nl (); list_vt_free (xs))
fun cg_pr_vtvt (xss: p2atcstlstlst_vt): void =
  (print_p2atcstlstlst_vt (xss); prerr_p2atcstlstlst_vt (xss); fprint_p2atcstlstlst (dd_out, cg_lstlst (xss)); p2atcstlstlst_vt_free (xss))
fun cg_pr_lvt (xs: labp2atcstlst_vt): void = (print_labp2atcstlst (cg_lvt2lst (xs)); print_newline (); fprint_labp2atcstlst (dd_out, cg_lvt2lst (xs)); dd_nl (); list_vt_free (xs))
fun cg_pr_lvtvt (xss: labp2atcstlstlst_vt): void =
  case+ xss of
  | ~list_vt_cons (xs, xss) => (cg_pr_lvt (xs); cg_pr_lvtvt (xss))
  | ~list_vt_nil () => dd_ps "--\n"
//
// the clauses [c2l1 .. c2ln] of a [case] (k = 0), [case+] (1) or [case-] (2)
//
fun cg_sim_first (k: int, c2l: c2lau): p2atcstlstlst_vt = let
  val cp2tcss = (if k = 2 then list_vt_nil () else c2lau_pat_comp (c2l)): p2atcstlstlst_vt
  val () = dd_ps "first: exhaustive="
  val () = dd_bool (list_vt_is_nil (cp2tcss))
  val () = dd_nl ()
  val () = print_p2atcstlstlst_vt (cp2tcss)
  val () = cg_pr_vtvt (c2lau_pat_any (c2l))
in
  cp2tcss
end
fun cg_sim_inter_loop (xss: p2atcstlstlst_vt, p2tcs: p2atcstlst, res: p2atcstlstlst_vt): p2atcstlstlst_vt =
  case+ xss of
  | ~list_vt_cons (xs, xss) => let
      val test = p2atcstlst_inter_test (cg_vt2lst (xs), p2tcs)
    in
      if test then cg_sim_inter_loop (xss, p2tcs, list_vt_cons (xs, res))
      else (list_vt_free (xs); cg_sim_inter_loop (xss, p2tcs, res))
    end
  | ~list_vt_nil () => list_vt_reverse (res)
fun cg_sim_inter (xss: p2atcstlstlst_vt, p2tcs: p2atcstlst): p2atcstlstlst_vt =
  cg_sim_inter_loop (xss, p2tcs, list_vt_nil ())
fun cg_sim_diff_loop (xss: p2atcstlstlst_vt, p2tcs: p2atcstlst, res: p2atcstlstlst_vt): p2atcstlstlst_vt =
  case+ xss of
  | ~list_vt_cons (xs, xss) => let
      val diff = p2atcstlst_diff (cg_vt2lst (xs), p2tcs)
      val () = list_vt_free (xs)
    in
      cg_sim_diff_loop (xss, p2tcs, list_vt_reverse_append (diff, res))
    end
  | ~list_vt_nil () => list_vt_reverse (res)
fun cg_sim_diff (xss: p2atcstlstlst_vt, p2tcs: p2atcstlst): p2atcstlstlst_vt =
  cg_sim_diff_loop (xss, p2tcs, list_vt_nil ())
fun cg_sim_next (k: int, cp2tcss: p2atcstlstlst_vt, c2l: c2lau): p2atcstlstlst_vt = let
  val p2tcs = p2at2cstlst (cg_c2lau_pat (c2l))
  val () = (dd_ps "next: p2tcs = "; print_p2atcstlst (p2tcs); dd_nl ())
  val inter = cg_sim_inter (p2atcstlstlst_vt_copy (cp2tcss), p2tcs)
  val () = (dd_ps "inter:\n"; print_p2atcstlstlst_vt (inter))
  val () = if list_vt_is_nil (inter) then (if k < 2 then dd_ps "redundant\n" else ())
  val () = p2atcstlstlst_vt_free (inter)
in
  if cg_c2lau_noguard (c2l) then cg_sim_diff (cp2tcss, p2tcs) else cp2tcss
end
fun cg_sim_end (cp2tcss: p2atcstlstlst_vt): void = {
  val () = (dd_ps "end: exhaustive="; dd_bool (list_vt_is_nil (cp2tcss)); dd_nl ())
  val () = cg_pr_vtvt (cp2tcss)
}
(* ****** ****** *)
//
fun cg_iset (i: int): intinfset = $INT.intinfset_sing ($INT.intinf_make_int (i))
fun cg_iset_add (s: intinfset, i: int): intinfset = $INT.intinfset_add (s, $INT.intinf_make_int (i))
fun cg_cset (c: char): charset = $UT.charset_sing (c)
fun cg_cset_add (s: charset, c: char): charset = $UT.charset_add (s, c)
fun cg_iset_up (i: int, n: int, s: intinfset): intinfset = if i > n then s else cg_iset_up (i+1, n, cg_iset_add (s, i))
fun cg_iset_n (n: int, s: intinfset): intinfset = cg_iset_up (1, n, s)
fun cg_cset_n (n: int, s: charset): charset = if n <= 0 then s else cg_cset_n (n-1, cg_cset_add (s, $UN.cast{char} (32 + n)))
fun cg_inf (i: int): intinf = $INT.intinf_make_int (i)
fun cg_inf_s (s: string): intinf = $INT.intinf_make_string (s)
(* ****** ****** *)
//
// the error tests (the environment variable CG_ERRTEST, see cgcmp.sh): the aborting paths
//
fun cg_errtest (n: int): void = {
  val () = dd_ps "errtest\n"
  val dv = d2var_make (mkloc (1), $SYM.symbol_make_string "x")
  val () = if n = 1 then dd_ps "errpat: "
  val () = if n = 1 then print_p2atcst (p2at2cst (p2at_errpat (mkloc (2))))
  val () = if n = 2 then print_p2atcst (p2at2cst (p2at_rec (mkloc (2), 0, 0, LC_labp2atlst (K_LABP2ATnorm (l0ab_make_label (mkloc (3), $LAB.label_make_int (0)), p2at_errpat (mkloc (4))), LN_labp2atlst ()))))
  val () = if n = 3 then print_p2atcst (p2at2cst (p2at_ann (mkloc (2), p2at_refas (mkloc (3), dv, p2at_vbox (mkloc (4), dv)), s2exp_int (1))))
  val () = dd_ps "not reached\n"
}
(* ****** ****** *)
