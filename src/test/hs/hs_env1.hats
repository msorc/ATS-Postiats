(* ATS1 counterpart of hs_env2.hats (test doubles of pats_trans2_env.dats / pats_trans3_env.dats for the ATS1-built util2/util3/solve/stacst2) *)
staload _(*list_vt*) = "prelude/DATS/list_vt.dats"
extern fun hs_tbl_find (name: string): ptr = "hs_tbl_find"
extern fun hs_tbl_set (name: string, c: ptr): void = "hs_tbl_set"
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
  Some_vt (S2ITMcst (list_cons (c, list_nil ())))
end
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = s2e0
implement s2var_occurcheck_s2exp (s2v0, s2e) = $ERR.abort ()
implement s2exp_exi_instantiate_all (s2e0, locarg, err) = $ERR.abort ()
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = $ERR.abort ()
implement trans3_env_push () = $ERR.abort ()
implement trans3_env_pop_and_add_main (pf | loc) = let prval () = hs_pf_free (pf) in $ERR.abort () end
implement trans3_env_add_proplst_vt (loc, s2ps) = (list_vt_free (s2ps); $ERR.abort ())
implement trans3_env_add_eqeq (loc, e1, e2) = $ERR.abort ()
implement trans3_env_hypadd_prop (loc, e) = $ERR.abort ()
implement trans3_env_hypadd_bind (loc, v, f) = $ERR.abort ()
implement trans3_env_hypadd_eqeq (loc, f1, f2) = $ERR.abort ()
implement s2hnf_absuni_and_add (loc, s2f) = $ERR.abort ()
implement s2hnf_opnexi_and_add (loc, s2f) = $ERR.abort ()
