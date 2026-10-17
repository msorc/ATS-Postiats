(* ATS2 test doubles of the functions of pats_trans2_env.dats / pats_trans3_env.dats (not ported yet) that the real pats_stacst2,
   pats_staexp2_util2/util3/solve need to link (the same role as ../s2env2.hats).  The only one the histaexp cases reach is
   [the_s2expenv_pervasive_find]: pats_stacst2.dats looks the pervasive constants (atstype_int, ...) up with it; the double makes
   a constant of the name on demand (a table in hs_stub.c).  The others are never called by the cases: they abort. *)
%{^
extern void *hs_tbl_find (const char*) ;
extern void hs_tbl_set (const char*, void*) ;
%}
extern fun hs_tbl_find (name: string): ptr = "mac#hs_tbl_find"
extern fun hs_tbl_set (name: string, c: ptr): void = "mac#hs_tbl_set"
implement the_s2expenv_pervasive_find (id) = let
  val name = $SYM.symbol_get_name (id)
  val p = hs_tbl_find (name)
  val c = (
    if ptr_isnot_null (p) then $UN.cast{s2cst} (p) else let
      val c = hs_cst_named (id, s2rt_t0ype)
      val () = hs_tbl_set (name, $UN.cast{ptr} (c))
    in
      c
    end
  ) : s2cst
in
  Some_vt (s2itm_S2ITMcst (glist_cons<s2cst> (c, glist_nil ())))
end
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = s2e0
implement s2var_occurcheck_s2exp (s2v0, s2e) = $ERR.abort<bool> ()
implement s2exp_exi_instantiate_all (s2e0, locarg, err) = $ERR.abort<(s2exp, s2explst_vt)> ()
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = $ERR.abort<(s2exp, s2explst_vt)> ()
implement trans3_env_push () = $ERR.abort<void> ()
implement trans3_env_pop_and_add_main (loc) = $ERR.abort<void> ()
implement trans3_env_add_proplst_vt (loc, s2ps) = (list_vt_free (s2ps); $ERR.abort<void> ())
implement trans3_env_add_eqeq (loc, e1, e2) = $ERR.abort<void> ()
implement trans3_env_hypadd_prop (loc, e) = $ERR.abort<void> ()
implement trans3_env_hypadd_bind (loc, v, f) = $ERR.abort<void> ()
implement trans3_env_hypadd_eqeq (loc, f1, f2) = $ERR.abort<void> ()
implement s2hnf_absuni_and_add (loc, s2f) = $ERR.abort<s2exp> ()
implement s2hnf_opnexi_and_add (loc, s2f) = $ERR.abort<s2exp> ()
