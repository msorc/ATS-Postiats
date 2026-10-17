(* the ATS2 test doubles of the functions of the modules that are not ported yet (pats_trans2_env.dats, pats_trans3_env.dats) that the REAL
   pats_staexp2_util2/util3/solve/stacst2 call: the macro test never reaches the solver, so the doubles are the empty pervasive environment,
   no bindings of static variables, and a loud failure for the rest. m2env1.hats is the same for ATS1. Included by m2dump.dats. *)
(* ****** ****** *)
fun m2_unreach (nm: string): void = (prerrln! ("m2: unexpected call of the double ", nm); exit (1))
implement the_s2expenv_pervasive_find (id) = None_vt ()
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = s2e0
implement s2var_occurcheck_s2exp (s2v0, s2e) = (m2_unreach ("s2var_occurcheck_s2exp"); false)
implement trans3_env_push () = m2_unreach ("trans3_env_push")
implement trans3_env_pop_and_add_main (loc) = m2_unreach ("trans3_env_pop_and_add_main")
implement trans3_env_add_proplst_vt (loc, s2ps) = (list_vt_free (s2ps); m2_unreach ("trans3_env_add_proplst_vt"))
implement trans3_env_add_eqeq (loc, e1, e2) = m2_unreach ("trans3_env_add_eqeq")
implement trans3_env_hypadd_prop (loc, e) = m2_unreach ("trans3_env_hypadd_prop")
implement trans3_env_hypadd_bind (loc, v, f) = m2_unreach ("trans3_env_hypadd_bind")
implement trans3_env_hypadd_eqeq (loc, f1, f2) = m2_unreach ("trans3_env_hypadd_eqeq")
implement s2exp_exi_instantiate_all (s2e0, locarg, err) = (m2_unreach ("s2exp_exi_instantiate_all"); @(s2e0, list_vt_nil ()))
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = (m2_unreach ("s2exp_uni_instantiate_all"); @(s2e0, list_vt_nil ()))
implement s2hnf_absuni_and_add (loc, s2f) = (m2_unreach ("s2hnf_absuni_and_add"); s2hnf2exp s2f)
implement s2hnf_opnexi_and_add (loc, s2f) = (m2_unreach ("s2hnf_opnexi_and_add"); s2hnf2exp s2f)
