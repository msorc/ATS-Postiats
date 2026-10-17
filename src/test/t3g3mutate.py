#!/usr/bin/env python3
# usage: python3 t3g3mutate.py REF.out REF.err [WHAT...]   (the stdout and stderr of t3g3dump1, the ATS1 reference)
#
# Mutation test of the test of the level-3 translation, group 3 (t3g3dump): each mutation is a deliberate bug that is put in a module of group 3 (the file is
# restored afterwards), t3g3dump is rebuilt and its outputs are compared with the ATS1 reference: every mutation must change an output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
P = 'pats_trans3_p2at.dats'; S = 'pats_trans3_selab.dats'; F = 'pats_trans3_fldfrat.dats'; L = 'pats_trans3_lvalres.dats'
MUT = [
 # ---- pats_trans3_p2at.dats
 (P, 'the variables of a proof argument are not proofs', '(d2var_set_isprf (d2v, true); p2at_proofize_loop (d2vs))', '(d2var_set_isprf (d2v, false); p2at_proofize_loop (d2vs))'),
 (P, 'trup_arg: the proof arguments start one later', 'if npf > 0\n      then p2at_proofize(p2t)', 'if npf > 1\n      then p2at_proofize(p2t)'),
 (P, 'trup_arg: the count of proofs is not decremented', 'loop(npf-1, p2ts, list_vt_cons (p3t, res))', 'loop(npf, p2ts, list_vt_cons (p3t, res))'),
 (P, 'trup_arg: the list is not reversed', 'GLnil() => list_vt_reverse (res)', 'GLnil() => (res)'),
 (P, 'a reference argument is a value', 'if refknd = 0 then let // call-by-value', 'if refknd = 1 then let // call-by-value'),
 (P, 'call-by-value variable: no finalization kind', 'val () = d2var_set_finknd (d2v, d2vfin_D2VFINsome (s2e)) // HX: may be overwritten later\n  in\n    p3t0\n  end // end of [refknd = 0]', 'val () = d2var_set_finknd (d2v, d2vfin_D2VFINnone ())\n  in\n    p3t0\n  end // end of [refknd = 0]'),
 (P, 'call-by-reference: the address has the sort int', 's2var_make_id_srt (sym, s2rt_addr)', 's2var_make_id_srt (sym, s2rt_int)'),
 (P, 'call-by-reference: the view has the opened type', 'd2var_set_mastype (d2vw, gopt_some (s2at))', 'd2var_set_mastype (d2vw, gopt_some (s2at_opn))'),
 (P, 'call-by-reference: the variable has no pointer type', 'd2var_set_type (d2v, gopt_some (s2e_ptr))\n    val () = d2var_set_mastype (d2v, gopt_some (s2e_ptr))', 'd2var_set_type (d2v, gopt_some (s2e_ptr))\n    val () = d2var_set_mastype (d2v, gopt_none ())'),
 (P, 'call-by-reference: the svar is not added', 'val () = trans3_env_add_svar (s2v_addr) // adding svar', 'val () = () // adding svar'),
 (P, 'a pattern that is not a variable for a reference', 'if p2at_node_is_P2Tvar (p2t0.p2at_node()) then', 'if p2at_node_is_P2Tany (p2t0.p2at_node()) then'),
 (P, 'trdn_arg: the arity error on the left', '    else let\n        val () = serr := serr + 1 in glist_nil ()\n      end // end of [list_nil]\n  ) else ( // end of [list_cons]', '    else let\n        val () = serr := serr - 1 in glist_nil ()\n      end // end of [list_nil]\n  ) else ( // end of [list_cons]'),
 (P, 'trdn_arg: the arity error on the right', '        val () = serr := serr - 1\n        val p3t = p3at_errpat (loc0, s2e)\n        val p3ts = aux', '        val () = serr := serr + 1\n        val p3t = p3at_errpat (loc0, s2e)\n        val p3ts = aux'),
 (P, 'trdn_arg: the proofs are not marked', '        val () =\n          if npf > 0 then p2at_proofize (p2t)', '        val () =\n          if npf > 5 then p2at_proofize (p2t)'),
 (P, 'trdn: the arity error on the left', '  else let\n      val () = serr := serr + 1 in glist_nil ()\n    end\n) else (', '  else let\n      val () = serr := serr - 1 in glist_nil ()\n    end\n) else ('),
 (P, 'trdn: the arity error on the right', '      val () = serr := serr - 1\n      val p3t = p3at_errpat (loc0, s2e)\n      val p3ts = p2atlst_trdn', '      val () = serr := serr + 1\n      val p3t = p3at_errpat (loc0, s2e)\n      val p3ts = p2atlst_trdn'),
 (P, 'any: the linear case is not recorded', 'if islin then p3at_set_type_left(p3t0, gopt_some(s2e0))', 'if ~islin then p3at_set_type_left(p3t0, gopt_some(s2e0))'),
 (P, 'any: the variable has a type', 'val ((*void*)) = d2var_set_type(d2v, gopt_none())', 'val ((*void*)) = d2var_set_type(d2v, gopt_some(s2e))'),
 (P, 'var: linear variables are the others', 'val () = if islin then { // linear var', 'val () = if ~islin then { // linear var'),
 (P, 'var: the linear value', 'val () = d2var_set_linval (d2v, 0)\n    val () = d2var_set_finknd (d2v, d2vfin_D2VFINnone())', 'val () = d2var_set_linval (d2v, 1)\n    val () = d2var_set_finknd (d2v, d2vfin_D2VFINnone())'),
 (P, 'int: the kind is checked against the index', '$SOL.s2exp_tyleq_solve_err (loc0, s2e_knd, s2e1_arg, nerr)', '$SOL.s2exp_tyleq_solve_err (loc0, s2e1_arg, s2e_knd, nerr)'),
 (P, 'int: the message', 'prerr ": the integer pattern is ill-typed."\n  val () = prerr_newline ()\n  val () = prerr_the_staerrlst ()\n  val s2e0 = s2hnf2exp (s2f0)\n  val () = the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))\n} // end of [val]\n//\nin\n  p3t0\nend // end of [p2at_trdn_int]', 'prerr ": the integer pattern is ill typed."\n  val () = prerr_newline ()\n  val () = prerr_the_staerrlst ()\n  val s2e0 = s2hnf2exp (s2f0)\n  val () = the_trans3errlst_add (trans3err_T3E_p2at_trdn (p2t0, s2e0))\n} // end of [val]\n//\nin\n  p3t0\nend // end of [p2at_trdn_int]'),
 (P, 'bool: the constructor is not checked', 'if s2cstref_equ_exp (the_bool_bool_t0ype, s2e_fun) then let\n    val-~GLcons (s2e_arg, _) = glist_view(s2es_arg)\n    val s2f_arg = s2exp2hnf (s2e_arg)\n    val () = trans3_env_hypadd_eqeq (loc0, s2f_ind, s2f_arg)', 'if s2cstref_equ_exp (the_char_int_t0ype, s2e_fun) then let\n    val-~GLcons (s2e_arg, _) = glist_view(s2es_arg)\n    val s2f_arg = s2exp2hnf (s2e_arg)\n    val () = trans3_env_hypadd_eqeq (loc0, s2f_ind, s2f_arg)'),
 (P, 'bool: the index of the pattern', 'val s2e_ind = s2exp_bool (b)\nval s2f_ind = s2exp2hnf_cast (s2e_ind)\nval s2e_pat = s2exp_bool_index_t0ype (s2e_ind)', 'val s2e_ind = s2exp_bool (b)\nval s2f_ind = s2exp2hnf_cast (s2e_ind)\nval s2e_pat = s2exp_bool_t0ype ()'),
 (P, 'char: the message', 'prerr ": the char pattern is ill-typed."', 'prerr ": the char pattern is not well-typed."'),
 (P, 'char: the constant', 's2cstref_equ_exp (the_char_int_t0ype, s2e_fun) then let\n    val-~GLcons\n      (s2e_arg, _) = glist_view(s2es_arg)\n    // end of [val]', 's2cstref_equ_exp (the_bool_bool_t0ype, s2e_fun) then let\n    val-~GLcons\n      (s2e_arg, _) = glist_view(s2es_arg)\n    // end of [val]'),
 (P, 'float: the type', 'val\ns2e_pat = s2exp_double_t0ype((*void*))', 'val\ns2e_pat = s2exp_int_t0ype((*void*))'),
 (P, 'string: the length', 'val n = string_length (str)', 'val n = string_length (str) + i2sz(1)'),
 (P, 'string: the message', 'prerr ": the string pattern is ill-typed."', 'prerr ": the string pattern is ill typed."'),
 (P, 'intrep: the pattern type', 'val s2e_pat = intrep_syn_type_ind (loc0, rep)', 'val s2e_pat = intrep_syn_type (loc0, rep)'),
 (P, 'i0nt: the kind is not checked', 'val () =\n          $SOL.s2exp_tyleq_solve_err (loc0, s2e_pat_knd, s2e1_arg, nerr)\n        // end of [val]', 'val () = ()\n        // end of [val]'),
 (P, 'auxcheck: the function is not checked', '$SOL.s2exp_tyleq_solve_err (loc0, s2e_pat_fun, s2e_fun, nerr)', '()'),
 (P, 'auxcheck: a missing argument is no error', 'else (nerr := nerr + 1)\n  end // end of [S2Eapp]', 'else ()\n  end // end of [S2Eapp]'),
 (P, 'f0loat: the message', 'prerr ": the pattern of floating point number is ill-typed."', 'prerr ": the pattern of a floating point number is ill-typed."'),
 (P, 'empty: the type', 'val s2e_pat = s2exp_void_t0ype ()\n  val err = $SOL.s2exp_tyleq_solve (loc0, s2e_pat, s2e)', 'val s2e_pat = s2exp_int_t0ype ()\n  val err = $SOL.s2exp_tyleq_solve (loc0, s2e_pat, s2e)'),
 (P, 'rec: omitted components are an error', 'val isomit = labp2atlst_isomit (lp2ts)', 'val isomit = false'),
 (P, 'rec: the rest is not reported', 'val () = auxrest (loc0, lp2ts, nerr)', 'val () = ()'),
 (P, 'rec: the rest is reported without the count', '        val () = nerr := nerr + 1\n      in\n        auxrest (loc0, lp2ts, nerr)', '      in\n        auxrest (loc0, lp2ts, nerr)'),
 (P, 'rec: a found label does not consume the pattern', 'val () = lp2ts := lp2ts1 in Some_vt (p2t)', 'val () = () in Some_vt (p2t)'),
 (P, 'rec: the skipped patterns are lost', 'if found then (lp2ts := glist_cons (lp2t, lp2ts1))', 'if found then (lp2ts := lp2ts1)'),
 (P, 'rec: an omission keeps the rest', 'val () = lp2ts := glist_sing (lp2t) in None_vt ()', 'val () = () in None_vt ()'),
 (P, 'rec: the labels of the components', 'val lp3t = labp3at_new (l, p3t)\n        val lp3ts = auxcheck (loc0, isomit, lp2ts, ls2es, err)\n      in\n        glist_cons (lp3t, lp3ts)\n      end // end of [Some_vt]', 'val lp3t = labp3at_new ($LAB.label_make_int (99), p3t)\n        val lp3ts = auxcheck (loc0, isomit, lp2ts, ls2es, err)\n      in\n        glist_cons (lp3t, lp3ts)\n      end // end of [Some_vt]'),
 (P, 'rec: the boxity test', 'isbox = (knd > 0)', 'isbox = (knd >= 0)'),
 (P, 'rec: the kind of a linear boxed record', 'if (isbox && islin) then PCKfree() else PCKcon()', 'if (isbox || islin) then PCKfree() else PCKcon()'),
 (P, 'rec: the arity of the proofs', '$SOL.pfarity_equal_solve\n      (loc0, npf, npf1)', '$SOL.pfarity_equal_solve\n      (loc0, npf, 0)'),
 (P, 'lst: the linearity of the list pattern', 'if lin >= 0 then test_linkind(lin) else false', 'if lin > 0 then test_linkind(lin) else false'),
 (P, 'lst: the linear list type', 'else if s2cstref_equ_exp (\n    the_list_vt0ype_int_vtype, s2e_fun\n  ) then let', 'else if s2cstref_equ_exp (\n    the_list_t0ype_int_type, s2e_fun\n  ) then let'),
 (P, 'lst: the non-linear check', 'val () = if not(islin) then auxerr_nonlin (p2t0)', 'val () = if islin then auxerr_nonlin (p2t0)'),
 (P, 'lst: the length is not constrained', 'val n = glist_length (p3ts)\n    val s2e_ind = s2exp_int (n)\n    val s2f_ind =\n      s2exp2hnf_cast (s2e_ind)\n    // end of [val]\n    val s2f2_arg = s2exp2hnf (s2e2_arg)\n    val () = trans3_env_hypadd_eqeq (loc0, s2f_ind, s2f2_arg)\n//\n    val () = if islin then auxerr_lin (p2t0)', 'val n = glist_length (p3ts)\n    val s2e_ind = s2exp_int (n + 1)\n    val s2f_ind =\n      s2exp2hnf_cast (s2e_ind)\n    // end of [val]\n    val s2f2_arg = s2exp2hnf (s2e2_arg)\n    val () = trans3_env_hypadd_eqeq (loc0, s2f_ind, s2f2_arg)\n//\n    val () = if islin then auxerr_lin (p2t0)'),
 (P, 'refas: the type of the variable', 'val () = d2var_set_mastype (d2v, gopt_some (s2e0))\nval s2e1 = s2hnf_opnexi_and_add (loc0, s2f0)', 'val () = d2var_set_mastype (d2v, gopt_none ())\nval s2e1 = s2hnf_opnexi_and_add (loc0, s2f0)'),
 (P, 'refas: the left type is not used', 'val () = d2var_set_type (d2v, gopt_some (s2e_left))\n    val () = d2var_set_linval (d2v, 0)', 'val () = d2var_set_type (d2v, gopt_some (s2e0))\n    val () = d2var_set_linval (d2v, 0)'),
 (P, 'refas: the type is not topized', 'gopt_some (s2exp_topize_1 (s2e1))', 'gopt_some (s2e1)'),
 (P, 'exist: the sorts are not compared', 'val ismat = s2rt_ltmat1 (s2t2, s2t1)', 'val ismat = true'),
 (P, 'exist: the sorts are compared the wrong way', 'val ismat = s2rt_ltmat1 (s2t2, s2t1)', 'val ismat = s2rt_ltmat1 (s2t1, s2t2)'),
 (P, 'exist: the error of a missing binding', '      val () = err := err + 1\n      val () = auxerr2 (loc0, s2v1)', '      val () = auxerr2 (loc0, s2v1)'),
 (P, 'exist: the variables are not added', 'val () = trans3_env_add_svarlst (s2vs)', 'val () = ()'),
 (P, 'exist: the hypotheses are not added', 'val () = trans3_env_hypadd_proplst_vt (loc0, s2ps2)', 'val () = list_vt_free (s2ps2)'),
 (P, 'vbox: the linear variable', 'val () = d2var_set_finknd (d2v, d2vfin_D2VFINsome_vbox (s2e))', 'val () = d2var_set_finknd (d2v, d2vfin_D2VFINsome (s2e))'),
 (P, 'vbox: the effect', 'val () = the_effenv_add_eff ($EFF.effect_ref)', 'val () = the_effenv_add_eff ($EFF.effect_wrt)'),
 (P, 'vbox: the check', 'val err = the_effenv_check_ref (loc0)', 'val err = the_effenv_check_wrt (loc0)'),
 (P, 'ann: the ascription is checked the wrong way', 'val nerr = $SOL.s2exp_tyleq_solve (loc0, s2e0, s2e_ann)', 'val nerr = $SOL.s2exp_tyleq_solve (loc0, s2e_ann, s2e0)'),
 (P, 'ann: the sub-pattern has the ascribed type', 'val p3t = p2at_trdn (p2t, s2e0)\n//\nin\n  p3at_ann (loc0, s2e0, p3t, s2e_ann)', 'val p3t = p2at_trdn (p2t, s2e_ann)\n//\nin\n  p3at_ann (loc0, s2e0, p3t, s2e_ann)'),
 (P, 'guard: the index', 'val s2e_gval = s2exp_bool_index_t0ype (s2e_ind)', 'val s2e_gval = s2exp_bool_t0ype ()'),
 (P, 'guard: the message', 'prerr ": the guard is ill-typed."', 'prerr ": the guard is ill typed."'),
 (P, 'syn: a constructor pattern is a variable of another sort', '| ~P2Tcon (_, _, _, _, _, _) =>\n    s2exp_Var_make_srt (p2t0.p2at_loc(), s2rt_t0ype)', '| ~P2Tcon (_, _, _, _, _, _) =>\n    s2exp_Var_make_srt (p2t0.p2at_loc(), s2rt_type)'),
 (P, 'syn: the sort of a vbox pattern', 's2exp_Var_make_srt (p2t0.p2at_loc(), s2rt_view)', 's2exp_Var_make_srt (p2t0.p2at_loc(), s2rt_prop)'),
 (P, 'syn: a string pattern', '| ~P2Tstring (_) => s2exp_string_type () // string0', '| ~P2Tstring (_) => s2exp_double_t0ype () // string0'),
 (P, 'syn: the omitted labels', '| ~LABP2ATomit (loc) => glist_nil () // HX: should an error be reported?', '| ~LABP2ATomit (loc) => aux_labp2atlst (lp2ts) // HX: should an error be reported?'),
 (P, 'syn: the type is not recorded', 'val () = p2at_set_type (p2t0, gopt_some (s2e0))', 'val () = ()'),
 (P, 'trup_arg: an annotation is not followed', '| ~P2Tann(p2t, s2e) =>\n    p2at_trdn_arg(p2t, s2e)', '| ~P2Tann(p2t, s2e) =>\n    p2at_trdn_arg(p2t, s2exp_t0ype_err ())'),
 # ---- pats_trans3_selab.dats
 (S, 'd2lab_trup: an index is not translated', '    val ind = d2explst_trup (ind) in d3lab_ind (loc, ind)', '    val ind = glist_nil () in d3lab_ind (loc, ind)'),
 (S, 'd2lablst_trup: the order', 'glist_map_fun<d2lab,d3lab> (d2ls, d2lab_trup)', 'glist_reverse<d3lab> (glist_map_fun<d2lab,d3lab> (d2ls, d2lab_trup))'),
 (S, 'arrbndck: the lower bound', 'val s2p1 = s2exp_igtez (s2i1)', 'val s2p1 = s2exp_igtez (s2i2)'),
 (S, 'arrbndck: the upper bound', 'val s2p2 = s2exp_intlt (s2i1, s2i2)\n  in\n    list_vt_cons', 'val s2p2 = s2exp_intlt (s2i2, s2i1)\n  in\n    list_vt_cons'),
 (S, 'arrbndck: the unsigned index', '        val s2p = s2exp_intlt (s2i1, s2i2) in list_vt_sing (s2p)', '        val s2p = s2exp_igtez (s2i1) in list_vt_sing (s2p)'),
 (S, 'arrbndck: no error for a non-integer', '        val () = auxerr (d3e1) in list_vt_nil ()', '        val () = () in list_vt_nil ()'),
 (S, 'arrbndlst_check: too many indexes', 'if sgn < 0 then let\n//\nval () = auxerr(loc0, ind, dim, sgn) in list_vt_nil()', 'if sgn < -1 then let\n//\nval () = auxerr(loc0, ind, dim, sgn) in list_vt_nil()'),
 (S, 'arrbndlst_check: too few indexes', 'end else if sgn > 0 then let', 'end else if sgn > 1 then let'),
 (S, 'arrbndlst_check: the order of the constraints', 'list_vt_append (s2ps1, s2ps2)\n    end // end of [GLcons]', 'list_vt_append (s2ps2, s2ps1)\n    end // end of [GLcons]'),
 (S, 'lincheck: the linear rest is not counted', '      if s2exp_is_lin(s2e) then linrest := linrest + 1\n    // end of [if] // end of [val]\n  in\n    lincheck (ls2es, linrest)', '      if s2exp_is_lin(s2e) then linrest := linrest + 0\n    // end of [if] // end of [val]\n  in\n    lincheck (ls2es, linrest)'),
 (S, 'labfind_lincheck: the components before the label', '          if s2exp_is_lin(s2e) then linrest := linrest + 1\n        ) (* end of [if] *) // end of [val]', '          if s2exp_is_nonlin(s2e) then linrest := linrest + 1\n        ) (* end of [if] *) // end of [val]'),
 (S, 'labfind_lincheck: the components after the label', 'then let\n        val () = lincheck(ls2es, linrest) in s2e', 'then let\n        val () = () in s2e'),
 (S, 'a boxed record is not shared', 'if tyreckind_is_box (knd) then sharing := sharing + 1', 'if tyreckind_is_box (knd) then sharing := sharing + 0'),
 (S, 'a label that is not found: the message', 'prerr "] but it does not."\n      val () = prerr_newline ()\n    in\n      the_trans3errlst_add (trans3err_T3E_s2exp_selab_labnot(loc0, s2e, lab0))', 'prerr "] but it does not exist."\n      val () = prerr_newline ()\n    in\n      the_trans3errlst_add (trans3err_T3E_s2exp_selab_labnot(loc0, s2e, lab0))'),
 (S, 'an existential type is not opened (label)', '    val s2e = s2hnf_opn1exi_and_add (loc0, s2f)\n  in\n    auxlab_sexp', '    val s2e = s2hnf2exp (s2f)\n  in\n    auxlab_sexp'),
 (S, 'an overloaded dot-symbol', '    | ~GOsome(d2s) => let\n        val () =\n        prerr_error3_loc(loc0) ', '    | ~GOnone() => let\n        val () =\n        prerr_error3_loc(loc0) '),
 (S, 'an index of a non-array', 'prerr "] is expected to be a tyarr (array-type)."', 'prerr "] is expected to be an array type."'),
 (S, 'an existential type is not opened (index)', '    val s2e = s2hnf_opn1exi_and_add (loc0, s2f)\n  in\n    auxind (loc0, s2e, ind)', '    val s2e = s2hnf2exp (s2f)\n  in\n    auxind (loc0, s2e, ind)'),
 (S, 'an index selects a linear element: not counted', 'val () = if s2exp_is_lin (s2es2ps.0) then linrest := linrest + 1', 'val () = ()'),
 (S, 'the constraints of the labels: the order', '@(s2e, list_vt_append (s2ps1, s2ps2))\n  end // end of [GLcons]', '@(s2e, list_vt_append (s2ps2, s2ps1))\n  end // end of [GLcons]'),
 (S, 'the context: the hole is not replaced', 'Some_vt @(s2exp_hrepl (s2e1_ctx, s2e2_ctx), s2h2)', 'Some_vt @(s2e2_ctx, s2h2)'),
 (S, 'the context: the record is rebuilt with the wrong kind', 's2exp_tyrec_srt (s2t, knd, npf, ls2es_ctx)', 's2exp_tyrec_srt (s2t, knd, npf+1, ls2es_ctx)'),
 (S, 'the context: the components before the label are lost', 'context := Some_vt @(glist_cons (ls2e, ls2es_ctx), s2h)', 'context := Some_vt @(ls2es_ctx, s2h)'),
 (S, 'the context: the label of the hole', 'val ls2e_ctx = labs2exp_new (l, name, s2e_ctx)', 'val ls2e_ctx = labs2exp_new (l, gopt_none (), s2e_ctx)'),
 (S, 'the checked context: the bounds are not checked', 'auxselist (s2e, d3ls, context2, true(*ischeck*))', 'auxselist (s2e, d3ls, context2, false(*ischeck*))'),
 (S, 'the linear selection: the type is not changed', 'val () = d2var_set_type (d2v, gopt_some (s2e))\n  in\n    // nothing\n  end // end of [val]\nin\n  d3exp_sel_var (loc0, s2e_sel, d2v, s2rt, d3ls)\nend // end of [then]', 'val () = ()\n  in\n    // nothing\n  end // end of [val]\nin\n  d3exp_sel_var (loc0, s2e_sel, d2v, s2rt, d3ls)\nend // end of [then]'),
 (S, 'the linear selection: the variable is not consumed', 'val () = d2var_inc_linval (d2v)', 'val () = ()'),
 (S, 'the linear selection: the component is not topized', 'val s2e_sel = s2exp_topize (1, s2e_sel)', 'val s2e_sel = s2exp_topize (0, s2e_sel)'),
 (S, 'the linear selection: the error', 'the_trans3errlst_add (trans3err_T3E_d2var_selab_context (loc0, d2v, d3ls))', '()'),
 (S, 'the linear selection: the constraints', 'val () = trans3_env_add_proplst_vt (loc0, s2ps)\nval islin = s2exp_is_lin (s2e_sel)', 'val () = list_vt_free (s2ps)\nval islin = s2exp_is_lin (s2e_sel)'),
 (S, 'a variable is not mutable', 'else if d2var_is_mutabl (d2v) then\n    d2var_trup_selab_mut (loc0, loc, d2v, d2ls)', 'else if false then\n    d2var_trup_selab_mut (loc0, loc, d2v, d2ls)'),
 (S, 'the linear check comes second', 'if d2var_is_linear (d2v) then\n    d2var_trup_selab_lin (loc0, loc, d2v, d2ls)', 'if d2var_is_linear (d2v) && ~d2var_is_mutabl (d2v) then\n    d2var_trup_selab_lin (loc0, loc, d2v, d2ls)'),
 (S, 'the linear rest error', 'prerr ": a linear component is abandoned by field selection."', 'prerr ": a linear component is abandoned by selection."'),
 (S, 'the linear rest: the test', 'val () = if (linrest > 0) then auxerr_linrest (loc0, d3e, d3ls)', 'val () = if (linrest > 1) then auxerr_linrest (loc0, d3e, d3ls)'),
 (S, 'the selection without labels is the root', 'else d3e // HX: there is no need to open the type', 'else d3exp_errexp (loc0) // HX: there is no need to open the type'),
 (S, 'the selection on a mutable variable: the root', 'd3exp_sel_var (loc0, s2e_sel, d2v, s2rt, d3ls)\nend // end of [d2var_trup_selab_mut]', 'd3exp_sel_var (loc0, s2e_sel, d2v, s2e_sel, d3ls)\nend // end of [d2var_trup_selab_mut]'),
 (S, 'the dereference is not followed', '| ~D2Ederef(d2s, d2e) =>\n    d2exp_trup_deref(loc0, d2s, d2e, d2ls)', '| ~D2Ederef(d2s, d2e) =>\n    d2exp_trup_deref(loc0, d2s, d2rt, d2ls)'),
 (S, 'the labels of a variable are translated first', 'val d3ls = d2lablst_trup (d2ls)\n//\nvar s2rt: s2exp', 'val d3ls = glist_nil ()\n//\nvar s2rt: s2exp'),
 # ---- pats_trans3_fldfrat.dats
 (F, 'free@: a linear component is no error', 'val islin = s2exp_is_lin2 (s2e)', 'val islin = s2exp_is_lin (s2e)'),
 (F, 'free@: the count of errors', 'val () = nerr := nerr + 1\n      val () = prerr_error3_loc (loc0)', 'val () = nerr := nerr + 0\n      val () = prerr_error3_loc (loc0)'),
 (F, 'free@: the message', 'prerr ": a linear component of the type ["', 'prerr ": a linear component of type ["'),
 (F, 'the view of an element is not consumed', 'val () = d2var_set_type(d2v, gopt_none((*void*)))', 'val () = ()'),
 (F, 'the type of a missing view', '| ~None_vt ((*void*)) => s2exp_errexp(s2rt_t0ype)', '| ~None_vt ((*void*)) => s2exp_errexp(s2rt_type)'),
 (F, 'the order of the elements', 'val s2es_elt = auxfind (loc0, s2ls)\n  in\n    glist_cons (s2e_elt, s2es_elt)', 'val s2es_elt = glist_nil ()\n  in\n    glist_cons (s2e_elt, s2es_elt)'),
 (F, 'the arguments are instantiated at the wrong location', 'val locarg = $LOC.location_leftmost (loc)', 'val locarg = loc0'),
 (F, 'the first instantiation', 's2exp_uni_instantiate_sexparglst (s2e_dcon, s2as, err)', 's2exp_uni_instantiate_sexparglst (s2e_dcon, glist_nil (), err)'),
 (F, 'the constraints of the first instantiation', 'val () = trans3_env_add_proplst_vt (loc0, s2ps)\n    val locarg', 'val () = list_vt_free (s2ps)\n    val locarg'),
 (F, 'fold@: the elements are compared the wrong way', '$SOL.s2explst_tyleq_solve_err (loc0, s2es_elt, s2es_arg, err)', '$SOL.s2explst_tyleq_solve_err (loc0, s2es_arg, s2es_elt, err)'),
 (F, 'fold@: the message', 'prerr ": some argument types are mismatched."', 'prerr ": some argument types are mismatched"'),
 (F, 'fold@: the type of the expression is not changed', 'd3lval_set_type_err(0(*refval*), d3e, s2e_res, err)', 'd3lval_set_type_err(0(*refval*), d3e, s2e_ptr, err)'),
 (F, 'fold@: the message of the type change', 'prerr ": the type of the dynamic expression cannot be changed."', 'prerr ": the type of the expression cannot be changed."'),
 (F, 'not a constructor: the message', 'prerr ": unfolded datatype constructor is expected."', 'prerr ": an unfolded datatype constructor is expected."'),
 (F, 'free@: the error of the write effect', 'the_trans3errlst_add(trans3err_T3E_d2exp_trup_wrt(loc0))', '()'),
 (F, 'free@: the effect is not checked', 'val err =\nthe_effenv_check_wrt(loc0)', 'val err =\nthe_effenv_check_ref(loc0)'),
 (F, 'free@: the error is not recorded', 'the_trans3errlst_add(trans3err_T3E_d3exp_freeat(loc0, d3e))\n      // end of [if]', '()\n      // end of [if]'),
 (F, 'fold@ is free@', 'val d3e = auxmain(loc0, 1(*opknd*), s2as, d2e)', 'val d3e = auxmain(loc0, 0(*opknd*), s2as, d2e)'),
 # ---- pats_trans3_lvalres.dats
 (L, 'exch: the type of the context is the new type', 'val s2e_elt =\n      s2ctxt_hrepl (ctxt, s2e_new)\n    // end of [val]\n    val s2e = s2exp_hrepl (s2e_ctx, s2e_elt)', 'val s2e_elt =\n      s2ctxt_hrepl (ctxt, s2e_old)\n    // end of [val]\n    val s2e = s2exp_hrepl (s2e_ctx, s2e_elt)'),
 (L, 'exch: the variable is not updated', 'val () = d2var_set_type (d2v, gopt_some (s2e))\n  in\n    s2e_old\n  end // end of [GOsome]', 'val () = ()\n  in\n    s2e_old\n  end // end of [GOsome]'),
 (L, 'exch: the types are compared the wrong way', 'val err = $SOL.s2exp_tyleq_solve (loc0, s2e_new, s2e_old)', 'val err = $SOL.s2exp_tyleq_solve (loc0, s2e_old, s2e_new)'),
 (L, 'exch: the message', 'prerr ": mismatch of bef/aft types of call-by-reference: "', 'prerr ": mismatch of bef/aft types of call-by-reference:"'),
 (L, 'exch: the constraints of the checked selection', 'val () = trans3_env_add_proplst_vt (loc0, s2ps)\n//\nin\n//\ncase+ gopt_view(ctxtopt)', 'val () = list_vt_free (s2ps)\n//\nin\n//\ncase+ gopt_view(ctxtopt)'),
 (L, 'exch: the message of the proof search', 'prerr ": the proof search for view located at ["', 'prerr ": the search for view located at ["'),
 (L, 'exch: the result of a failed search', '    val () = auxerr_pfobj (loc0, s2l) in s2exp_t0ype_err ()', '    val () = auxerr_pfobj (loc0, s2l) in s2exp_errexp (s2rt_type)'),
 (L, 'a mutable variable is not mutable', '    if d2var_is_mutabl (d2v) then let\n      val-~GOsome (s2l) = gopt_view (d2var_get_addr (d2v))\n      val d3ls = glist_nil () // HX: a special case of sel_var', '    if false then let\n      val-~GOsome (s2l) = gopt_view (d2var_get_addr (d2v))\n      val d3ls = glist_nil () // HX: a special case of sel_var'),
 (L, 'a linear variable is not checked for a reference', '      val () =\n        d2var_refval_check (loc0, d2v, refval)\n      // end of [val]\n      val opt =', '      val () = ()\n      val opt ='),
 (L, 'the type of a linear variable is not exchanged', 'd2var_exch_type (d2v, gopt_some (s2e_new))', 'd2var_exch_type (d2v, gopt_none ())'),
 (L, 'the type of the expression is not set', 'val () = d3exp_set_type (d3e0, s2e_new)\n    in', 'val () = ()\n    in'),
 (L, 'an old linear type is not abandoned', 'val islin = s2exp_is_lin (s2e_old)\n          val () = if islin then\n            auxerr_linold (loc0, d3e0, glist_nil((*d3ls*)), s2e_old)', 'val islin = s2exp_is_nonlin (s2e_old)\n          val () = if islin then\n            auxerr_linold (loc0, d3e0, glist_nil((*d3ls*)), s2e_old)'),
 (L, 'the message of an abandoned linear type', 'prerr ": a linear component of the following type is abandoned: "', 'prerr ": a linear component of the following type is abandoned:"'),
 (L, 'the message of a non-mutable variable', 'prerr "] is required to be mutable in order to support call-by-reference."', 'prerr "] is required to be mutable to support call-by-reference."'),
 (L, 'the refval test', '  if refval > 0 then let\n    val () = prerr_error3_loc (loc0)\n    val () = prerr ": the dynamic variable ["', '  if refval >= 0 then let\n    val () = prerr_error3_loc (loc0)\n    val () = prerr ": the dynamic variable ["'),
 (L, 'sel_var linear: the type is not hnfized', 'val s2e_old = s2exp_hnfize (s2e_old)', 'val s2e_old = s2e_old'),
 (L, 'sel_var linear: the type is not updated', 'd2var_set_type (d2v, gopt_some (s2e))\n        end // end of [GOsome]\n      | ~GOnone () => let', '()\n        end // end of [GOsome]\n      | ~GOnone () => let'),
 (L, 'sel_var linear: the context type', '          val s2e =\n            s2ctxt_hrepl (ctxt, s2e_new)\n          // end of [val]\n        in\n          d2var_set_type', '          val s2e =\n            s2ctxt_hrepl (ctxt, s2exp_t0ype_err ())\n          // end of [val]\n        in\n          d2var_set_type'),
 (L, 'viewat: the address', '    | ~Some_vt (s2l) =>\n        s2addr_set_viewat (loc0, s2l, d3ls, s2e_new)', '    | ~Some_vt (s2l) =>\n        s2addr_set_viewat (loc0, s2l, glist_nil (), s2e_new)'),
 (L, 'a non-left-value is no error', '    (d3exp_node_view_free (v); err := err + 1)', '    (d3exp_node_view_free (v); err := err + 0)'),
 (L, 'pat_left: the type of the pattern', 'val () = d3lval_set_type_err (0(*refval*), d3e0, s2e, err)', 'val () = d3lval_set_type_err (1(*refval*), d3e0, s2e, err)'),
 (L, 'pat_left: the message', 'prerr ": the dynamic expression should be a left-value but it is not."', 'prerr ": the dynamic expression should be a left-value but is not."'),
 (L, 'patlst_left: the pairs', '      val () =\n        d3lval_set_pat_type_left (d3e, p3t) in loop (d3es, p3ts)', '      val () =\n        d3lval_set_pat_type_left (d3e, p3t) in loop (d3es, glist_nil ())'),
 (L, 'arg_set_type: a non-linear argument is an error', 'else if s2exp_is_nonlin (s2e_new) then () // HX-2013-03: safely discarded', 'else if s2exp_is_lin (s2e_new) then () // HX-2013-03: safely discarded'),
 (L, 'arg_set_type: the reference test', '  if refval > 0 then auxerr (d3e0)\n  else if s2exp_is_nonlin', '  if refval > 1 then auxerr (d3e0)\n  else if s2exp_is_nonlin'),
 (L, 'arg_set_type: the message', 'prerr ": the function argument needs to be a left-value."', 'prerr ": the function argument is to be a left-value."'),
 (L, 'freeptr: the kind', '      if knd > 0\n        then (if lin <= 0 then true else false) else false', '      if knd >= 0\n        then (if lin <= 0 then true else false) else false'),
 (L, 'freeptr: the linearity', 'then (if lin <= 0 then true else false) else false', 'then (if lin < 0 then true else false) else false'),
 (L, 'fun_restore: a closure is restored', 'if funclo_get_clokind (fc) >= 0 then auxres (d3e_fun) else d3e_fun', 'if funclo_get_clokind (fc) > 0 then auxres (d3e_fun) else d3e_fun'),
 (L, 'auxres: the linear function', '  else if lin = 1 then\n    s2exp_fun_srt (\n      s2rt_vtype, fc0, ~1(*topized*), s2fe, npf, s2es_arg, s2e_res', '  else if lin = 1 then\n    s2exp_fun_srt (\n      s2rt_vtype, fc0, 0(*topized*), s2fe, npf, s2es_arg, s2e_res'),
 (L, 'auxres: the message of the repeated application', 'prerr ": a linear function cannot be applied repeatedly."', 'prerr ": a linear function cannot be applied twice."'),
 (L, 'auxres: reference for a closure of kind 0', 'if funclo_get_clokind (fc0) = 0 then 1 else 0', 'if funclo_get_clokind (fc0) = 1 then 1 else 0'),
 (L, 'auxres: the message of a non-left function', 'prerr ": the function itself needs to be a left-value."', 'prerr ": the function itself is to be a left-value."'),
 (L, 'auxres: no auto-freeing', 'else if s2exp_fun_is_freeptr (s2fun_new) then (freeknd := 1) // auto-freeing', 'else if s2exp_fun_is_freeptr (s2fun_new) then (freeknd := 0) // auto-freeing'),
 (L, 'auxres: the free kind is not passed', 'd3exp_refarg (loc0, s2fun_new, refval, freeknd, d3e0)', 'd3exp_refarg (loc0, s2fun_new, refval, 0, d3e0)'),
 (L, 'arg_restore: the invariant argument', '    val freeknd = // HX: freeknd = 0\n      d3lval_arg_set_type (refval, d3e, s2e_res)\n    val d3e = d3exp_refarg (loc, s2e_res, refval, freeknd, d3e)\n    val d3es = auxlst1 (d3es, s2es_arg, wths2es)\n  in\n    glist_cons (d3e, d3es)\n  end // end of [WTHS2EXPLSTcons_invar]', '    val freeknd = // HX: freeknd = 0\n      d3lval_arg_set_type (0, d3e, s2e_res)\n    val d3e = d3exp_refarg (loc, s2e_res, refval, freeknd, d3e)\n    val d3es = auxlst1 (d3es, s2es_arg, wths2es)\n  in\n    glist_cons (d3e, d3es)\n  end // end of [WTHS2EXPLSTcons_invar]'),
 (L, 'arg_restore: the type of a transformed argument is not opened', 'val s2e_res = s2hnf_opnexi_and_add (loc, s2f_res)', 'val s2e_res = s2hnf2exp (s2f_res)'),
 (L, 'arg_restore: a non-transformed argument', '    val d3es = auxlst1 (d3es, s2es_arg, wths2es)\n  in\n    glist_cons (d3e, d3es)\n  end // end of [WTHS2EXPLSTcons_none]', '    val d3es = auxlst1 (d3es, glist_nil (), wths2es)\n  in\n    glist_cons (d3e, d3es)\n  end // end of [WTHS2EXPLSTcons_none]'),
 (L, 'arg_restore: the end of the list', '  if glist_is_cons (d3es)\n    then auxlst2 (d3es, s2es_arg, wths2es) else glist_nil ()', '  if glist_is_cons (d3es) && glist_is_cons (s2es_arg)\n    then auxlst2 (d3es, s2es_arg, wths2es) else glist_nil ()'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
ONLY = sys.argv[3:]
T = os.environ.get('TMPDIR', '/tmp')
def build():
    r = subprocess.run(['make', '-C', d, 't3g3dump', '-j16'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    o = open(T + '/t3g3mut.out', 'w'); e = open(T + '/t3g3mut.err', 'w')
    subprocess.run([os.path.join(d, 't3g3dump')], stdout=o, stderr=e, cwd=d, timeout=600)
    o.close(); e.close()
    return filecmp.cmp(T + '/t3g3mut.out', ref_out, shallow=False) and filecmp.cmp(T + '/t3g3mut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if old == new: print('SKIP (no change): %s' % what); continue
    if ONLY and what not in ONLY: continue
    bak = T + '/t3g3mut_backup_' + fn
    shutil.copy(path, bak)
    try:
        open(path, 'w').write(src.replace(old, new))
        nm += 1
        try:
            if not build(): res = 'detected (does not compile)'; nd += 1
            elif run(): res = 'NOT DETECTED'
            else: res = 'detected'; nd += 1
        except subprocess.TimeoutExpired:
            res = 'detected (timeout)'; nd += 1
    finally:
        shutil.copy(bak, path)
        assert filecmp.cmp(path, bak, shallow=False)
    print('%-30s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
