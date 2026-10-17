(* the part of the level-3 translation test, group 2 (g2dump.dats, g2dump1.dats) that is written once for ATS1 and ATS2 (after the layers of the level-3 and
   the codegen2/patcst2 tests) *)
(* ****** ****** *)
//
// the universe of the patterns: the constant [list_vt0ype_int_vtype] that [p2atcst_lst] finds as a pervasive (pats_stacst2 keeps the first one it finds,
// so it is made once, after the pervasive constants of the setup scenario, and in front of them in the table) and its constructors (cg_lnil, cg_lcons)
//
fun g2_init_universe (): void = {
  val c = s2cst_make ($SYM.symbol_make_string "list_vt0ype_int_vtype", mkloc (0), mkfil (0), s2rt_vtype, ON_s2expoptopt (), true, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())
  val dnil = d2con_make (mkloc (0), mkfil (0), $SYM.symbol_make_string "list_vt_nil", c, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())
  val dcons = d2con_make (mkloc (0), mkfil (0), $SYM.symbol_make_string "list_vt_cons", c, 0, LN_s2qualst (), 0, LC_s2explst (s2exp_int (0), LC_s2explst (s2exp_int (1), LN_s2explst ())), ON_s2explstopt ())
  val () = d2con_set_tag (dnil, 0)
  val () = d2con_set_tag (dcons, 1)
  val () = s2cst_set_dconlst (c, OS_d2conlstopt (LC_d2conlst (dnil, LC_d2conlst (dcons, LN_d2conlst ()))))
  val () = s2cst_set_islst (c, OS_d2conpairopt (K_d2conpair (dnil, dcons)))
  val () = t_penv_add (mksymname ("list_vt0ype_int_vtype"), K_S2ITMcst (LC_s2cstlst (c, LN_s2cstlst ())))
  val () = cg_env_put (3, "lnil", $UN.cast{ptr} (dnil))
  val () = cg_env_put (3, "lcons", $UN.cast{ptr} (dcons))
}

//
// the items of the environment that a pop returns, dumped completely (with the locations of the constraints) and freed
//
fun g2_dd_items (xs: List0_vt (s3itm)): void = let
  fun loop (xs: List0_vt (s3itm), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s3itm x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [g2_dd_items]
