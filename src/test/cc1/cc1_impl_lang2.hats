//
(* ATS2: the doubles of the functions of trans2_env (the cells of the file environments: cc1_stub.c) *)
implement filenv_get_name (x) = $FIL.filename_make ("g", "p", cc1_str4 ("fenv", fenv_id (x), 0, 0))
implement filenv_getref_tmpcstimpmap (fenv) = cc1_fenv_cell (fenv, 1)
implement filenv_getref_tmpvardecmap (fenv) = cc1_fenv_cell (fenv, 2)
implement trans3_env_push () = ()
implement trans3_env_pop_and_add_main (loc) = ()
staload "../pats_syntax_boundary.sats"
implement parerr_p0at_as (loc) = ()
implement parerr_add_ifunclosed (loc, name) = ()
