//
(* ATS1: the doubles of the functions of trans2_env (the cells of the file environments: cc1_stub.c) *)
implement filenv_get_name (x) = $FIL.filename_make ("g", "p", cc1_str4 ("fenv", fenv_id (x), 0, 0))
implement filenv_getref_tmpcstimpmap (fenv) = cc1_fenv_cell (fenv, 1)
implement filenv_getref_tmpvardecmap (fenv) = cc1_fenv_cell (fenv, 2)
extern prfun cc1_pf_make (): trans3_env_push_v
extern prfun cc1_pf_drop (pf: trans3_env_push_v): void
implement trans3_env_push () = (cc1_pf_make () | ())
implement trans3_env_pop_and_add_main (pf | loc) = let prval () = cc1_pf_drop (pf) in () end
