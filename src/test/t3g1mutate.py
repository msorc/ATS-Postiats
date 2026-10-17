#!/usr/bin/env python3
# usage: python3 t3g1mutate.py REF.out REF.err [WHAT...]   (run in the build directory DIR/test made by linkfarm.sh; REF = stdout and stderr of t3g1dump1, the ATS1 reference)
#
# Mutation test of the test of group 1 of the trans3 port (PORTING.md, "Level 3 translation, group 1"): each mutation is a deliberate bug in one of the three ported
# modules. The mutated file replaces the symbolic link of the link farm (src/ itself is never changed), t3g1dump is rebuilt and its outputs are compared
# with the ATS1 reference: every mutation must change an output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.getcwd(); M = os.path.join(d, '..')
T = os.environ.get('TMPDIR', '/tmp')
MUT = [
 # ---- pats_trans3_util.dats
 ('pats_trans3_util.dats', 'showtype up text', 'then fprint_string (out, "**SHOWTYPE[UP]**")', 'then fprint_string (out, "**SHOWTYPE[UP ]**")'),
 ('pats_trans3_util.dats', 'funclo of an annotation is dropped', 'let val () = fc0 := fc in d2e end', 'let val () = () in d2e end'),
 ('pats_trans3_util.dats', 'a static lambda has the effect all', '  | ~D2Elam_sta _ =>\n      (s2fe0 := s2eff_nil; d2e0)', '  | ~D2Elam_sta _ =>\n      (s2fe0 := s2eff_all; d2e0)'),
 ('pats_trans3_util.dats', 'the default effect is nil', 'val () = s2fe0 := s2eff_all in d2e0', 'val () = s2fe0 := s2eff_nil in d2e0'),
 ('pats_trans3_util.dats', 'a linear function (lin=0) is linear', 'val islin = (if lin > 0 then true else false): bool', 'val islin = (if lin >= 0 then true else false): bool'),
 ('pats_trans3_util.dats', 'the sort of a nonlinear list literal', 'if lin = 0 then s2rt_t0ype else s2rt_vt0ype', 'if lin = 0 then s2rt_vt0ype else s2rt_t0ype'),
 ('pats_trans3_util.dats', 'the default funclo of laminit', 'val fc0 = FUNCLOclo (0) // HX: default', 'val fc0 = FUNCLOclo (1) // HX: default'),
 ('pats_trans3_util.dats', 'the metric function of the syntactic type has a stamp', 's2exp_metfun (gopt_none ((*stamp*)), met, s2e)', 's2e'),
 ('pats_trans3_util.dats', 'the syntactic type of a sequence is the first', '      val d2e = d2explst_last (d2es) in d2exp_syn_type (d2e)', '      val d2e = glist_head (d2es) in d2exp_syn_type (d2e)'),
 ('pats_trans3_util.dats', 'the type of d2exp_trdn is set always', 's2exp_node_is_S2EVar (s2e1.s2exp_node ())\nthen', 'true\nthen'),
 ('pats_trans3_util.dats', 'the error of d3exp_trdn is not recorded', 'the_trans3errlst_add(trans3err_T3E_d3exp_trdn(d3e1, s2e2))', '()'),
 ('pats_trans3_util.dats', 'a refarg is not looked through', '| ~S2Erefarg\n    (_, s2e2) => d3exp_trdn (d3e1, s2e2)', '| ~S2Erefarg\n    (_, s2e2) => aux (d3e1, s2f2)'),
 ('pats_trans3_util.dats', 'the arguments are cut at the shorter list', '    | ~GLnil () => glist_nil ()\n    ) // end of [list_cons]', '    | ~GLnil () => glist_cons (d3e, d3es)\n    ) // end of [list_cons]'),
 ('pats_trans3_util.dats', 'is_cloref counts the flat closures', 'funclo_get_clokind (fc) < 0', 'funclo_get_clokind (fc) <= 0'),
 ('pats_trans3_util.dats', 'a boxed tuple of proofs is rejected', 'if tyreckind_is_boxed (knd) then ~(s2exp_is_prf (s2e)) else false', 'if tyreckind_is_boxed (knd) then true else false'),
 ('pats_trans3_util.dats', 'the list of lin=0 is nonlinear', 'if (lin >= 0 && ~test_linkind(lin)) then', 'if (lin > 0 && ~test_linkind(lin)) then'),
 ('pats_trans3_util.dats', 'a delay is accepted', '    | ~D3Edelay _ =>\n        auxerr', '    | ~D3Edelay _ =>\n        (*auxerr'),
 ('pats_trans3_util.dats', 'the open of the indices is skipped', 'val () = d3exp_open_and_add (x) in d3exp_get_type (x)', 'val () = () in d3exp_get_type (x)'),
 ('pats_trans3_util.dats', 'a quantified function type is looked through only for exi', '| ~S2Euni (_, _, s2e) => s2exp_is_cloref (s2e)', '| ~S2Euni (_, _, s2e) => false'),
 ('pats_trans3_util.dats', 'the overloaded dot of the first label only', '    | ~GOsome _ => true | ~GOnone () => d3lablst_is_overld (d3ls)', '    | ~GOsome _ => true | ~GOnone () => false'),
 # ---- pats_trans3_syncst.dats
 ('pats_trans3_syncst.dats', 'the suffix LU', 'else if strcasecmp (sfx, "LU") = 0 then IK_ULINT', 'else if strcasecmp (sfx, "LU") = 0 then IK_LINT'),
 ('pats_trans3_syncst.dats', 'the suffix LLU', 'else if strcasecmp (sfx, "LLU") = 0 then IK_ULLINT', 'else if strcasecmp (sfx, "LLU") = 0 then IK_LLINT'),
 ('pats_trans3_syncst.dats', 'the suffix U', 'if strcasecmp (sfx, "U") = 0 then IK_UINT', 'if strcasecmp (sfx, "U") = 0 then IK_LINT'),
 ('pats_trans3_syncst.dats', 'the float suffix F', 'if strcasecmp (sfx, "F") = 0 then FK_FLOAT', 'if strcasecmp (sfx, "F") = 0 then FK_DOUBLE'),
 ('pats_trans3_syncst.dats', 'the float suffix L', 'else if strcasecmp (sfx, "L") = 0 then FK_LDOUBLE', 'else if strcasecmp (sfx, "L") = 0 then FK_FLOAT'),
 ('pats_trans3_syncst.dats', 'the error of an integer suffix is not recorded', 'the_trans3errlst_add (trans3err_T3E_intsp (loc0, rep))\n      in\n        s2exp_t0ype_err ()\n      end // end of [_]\n   end // end of [else]', '()\n      in\n        s2exp_t0ype_err ()\n      end // end of [_]\n   end // end of [else]'),
 ('pats_trans3_syncst.dats', 'the character code', 'val i = char2int0 (c)', 'val i = 0'),
 ('pats_trans3_syncst.dats', 'the length of a string', 'val n = string0_length (str)\n  val s2f = s2exp_string_int_type (n)', 'val n = string0_length (str) + i2sz(1)\n  val s2f = s2exp_string_int_type (n)'),
 ('pats_trans3_syncst.dats', 'the octal base', 'intinf_make_base_string_ofs (8, rep1, 1(*0*))', 'intinf_make_base_string_ofs (10, rep1, 1)'),
 ('pats_trans3_syncst.dats', 'the hexadecimal offset', 'intinf_make_base_string_ofs (16, rep1, 2(*0x*))', 'intinf_make_base_string_ofs (16, rep1, 0)'),
 ('pats_trans3_syncst.dats', 'the value of an integer with a suffix', 'val rep1 = my_make_substring (rep, i2sz(0), ln)', 'val rep1 = my_make_substring (rep, i2sz(0), ln + i2sz(1))'),
 ('pats_trans3_syncst.dats', 'the base of the integer of a pattern', 'val base =\n    $UT.intrep_get_base (rep)', 'val base =\n    10'),
 ('pats_trans3_syncst.dats', 'the type of $myfile', '| $SYN.CSTSPmyloc () => s2exp_string_type ()', '| $SYN.CSTSPmyloc () => s2exp_int_t0ype ()'),
 ('pats_trans3_syncst.dats', 'the name of tyrep', '"atstype_tyrep"', '"atstype_tyrep1"'),
 ('pats_trans3_syncst.dats', 'a float literal has the string sort', '    val s2e0 = s2exp_literal_float (rep)\n  in\n    d3exp_literal (loc0, s2e0, d3e_lit)\n  end // end of [D2Efloat]', '    val s2e0 = s2exp_literal_string (rep)\n  in\n    d3exp_literal (loc0, s2e0, d3e_lit)\n  end // end of [D2Efloat]'),
 ('pats_trans3_syncst.dats', 'the other literals are errors', '(d2exp_node_view_free (v); d3exp_errexp (loc0))', '(d2exp_node_view_free (v); d3exp_empty (loc0, s2exp_void_t0ype ()))'),
 ('pats_trans3_syncst.dats', 'the suffix position', 'val ln = n - $UN.cast{size_t}(sfx)\nin\n  $UN.cast{string}', 'val ln = n - $UN.cast{size_t}(sfx) + i2sz(1)\nin\n  $UN.cast{string}'),
 ('pats_trans3_syncst.dats', 'the literal message', 'print_string ("d2exp_trup_literal: d2e0 = ")', 'print_string ("d2exp_trup_literal: d2e = ")'),
 # ---- pats_trans3_dynexp_up.dats
 ('pats_trans3_dynexp_up.dats', 'an array of proofs: the size is not the length', 'val asz = glist_length (d2es)\n    val d3es = d2explst_trdn_elt(d2es, s2e)', 'val asz = glist_length (d2es) + 1\n    val d3es = d2explst_trdn_elt(d2es, s2e)'),
 ('pats_trans3_dynexp_up.dats', 'the arity error of the arguments is reversed', 'val () = err := err - 1 in glist_nil()', 'val () = err := err + 1 in glist_nil()'),
 ('pats_trans3_dynexp_up.dats', 'the arity error of a constructor is not recorded', 'the_trans3errlst_add (trans3err_T3E_d2exp_trup_con_npf (d2e0, npf)) // nothing', '() // nothing'),
 ('pats_trans3_dynexp_up.dats', 'a linear variable is consumed without the type', 'd2var_set_type (d2v, gopt_none ((*void*))) // HX: [d2v] is consumed', '() // HX: [d2v] is consumed'),
 ('pats_trans3_dynexp_up.dats', 'a linear variable is not counted', 'val () = d2var_inc_linval (d2v)\nin', 'val () = ()\nin'),
 ('pats_trans3_dynexp_up.dats', 'a nonlinear variable is linear', 'if (\nlin >= 0\n) then let', 'if (\nlin >= ~1\n) then let'),
 ('pats_trans3_dynexp_up.dats', 'the template of a variable is instantiated with the wrong location', '    val locsarg =\n      $LOC.location_rightmost (loc0)\n    val (s2e_tmp, s2ess) =\n      s2exp_tmp_instantiate_rest (s2e0, locsarg, s2qs, err)', '    val locsarg = loc0\n    val (s2e_tmp, s2ess) =\n      s2exp_tmp_instantiate_rest (s2e0, locsarg, s2qs, err)'),
 ('pats_trans3_dynexp_up.dats', 'the template of a constant is not instantiated', '    val (s2e_tmp, s2ess) =\n      s2exp_tmp_instantiate_rest (s2e, locsarg, s2qs, err)\n  in\n    d3exp_tmpcst (loc0, s2e_tmp, d2c, s2ess)', '    val (s2e_tmp, s2ess) =\n      s2exp_tmp_instantiate_rest (s2e, locsarg, s2qs, err)\n  in\n    d3exp_tmpcst (loc0, s2e, d2c, s2ess)'),
 ('pats_trans3_dynexp_up.dats', 'the type of an explicit template of a variable', 's2exp_tmp_instantiate_tmpmarglst (s2e_d2v, locarg, s2qs, t2mas, err)', 's2exp_tmp_instantiate_tmpmarglst (s2e_d2v, loc0, s2qs, t2mas, err)'),
 ('pats_trans3_dynexp_up.dats', 'the type of a symbol error', 'the_trans3errlst_add (trans3err_T3E_d2exp_trup_sym (d2e0))', '()'),
 ('pats_trans3_dynexp_up.dats', 'the extfcall check', 'val islin = s2exp_is_lin (s2e)\n    val () = if islin then auxerr (loc0, d3e)\n  in\n    auxcheck (loc0, d3es)\n  end // end of [list_cons]\n| ~GLnil ((*void*)) => ()\n//\nend // end of [auxcheck]\n\nin (* in of [local] *)\n\nimplement\nd2exp_trup_extfcall', 'val islin = false\n    val () = if islin then auxerr (loc0, d3e)\n  in\n    auxcheck (loc0, d3es)\n  end // end of [list_cons]\n| ~GLnil ((*void*)) => ()\n//\nend // end of [auxcheck]\n\nin (* in of [local] *)\n\nimplement\nd2exp_trup_extfcall'),
 ('pats_trans3_dynexp_up.dats', 'the static application location of the error', 'val locsarg = $LOC.location_rightmost (loc_fun)', 'val locsarg = loc_fun'),
 ('pats_trans3_dynexp_up.dats', 'the combination of the locations of an application', 'val loc_app = $LOC.location_combine (loc_fun, locarg)\n    val s2es_fun_arg =', 'val loc_app = loc_fun\n    val s2es_fun_arg ='),
 ('pats_trans3_dynexp_up.dats', 'the static location of the last argument', '$LOC.location_combine (loc, s2a.s2exparg_loc ())', 'loc'),
 ('pats_trans3_dynexp_up.dats', 'the proof arity error of an application is not recorded', 'the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_npf (loc_fun, npf))', '()'),
 ('pats_trans3_dynexp_up.dats', 'the effect error of an application is not recorded', 'the_trans3errlst_add (trans3err_T3E_d23exp_trup_app23_eff (loc_app, s2fe_fun))', '()'),
 ('pats_trans3_dynexp_up.dats', 'the effect of an application is not checked', 'the_effenv_check_s2eff (loc_app, s2fe_fun)', '0'),
 ('pats_trans3_dynexp_up.dats', 'the arguments of an application are opened after the call', 'val ((*void*)) = d23explst_open_and_add (d23es_arg)\nin', 'val ((*void*)) = ()\nin'),
 ('pats_trans3_dynexp_up.dats', 'the function of an application is not opened', 'val () = d3exp_open_and_add (d3e_fun)\nin\n  d23exp_trup_applst', 'val () = ()\nin\n  d23exp_trup_applst'),
 ('pats_trans3_dynexp_up.dats', 'the arguments of a constructor are not opened', '  val () = d23explst_open_and_add (d23es_arg)\n//\n  var err: int = 0\n  val locsarg', '  val () = ()\n//\n  var err: int = 0\n  val locsarg'),
 ('pats_trans3_dynexp_up.dats', 'a value argument is translated (not left alone)', 'if isval\n        then D23Ed2exp d2e', 'if false\n        then D23Ed2exp d2e'),
 ('pats_trans3_dynexp_up.dats', 'the wthtype of the result is ignored', 'if iswth then\n        d3explst_arg_restore (d3es_arg, s2es_fun_arg, wths2es)\n      else d3es_arg', 'd3es_arg'),
 ('pats_trans3_dynexp_up.dats', 'a list literal of lin=-1 is linear', 'if lin >= 0 then test_linkind (lin) else false', 'if lin >= 0 then test_linkind (lin) else true'),
 ('pats_trans3_dynexp_up.dats', 'the type of a tuple', 'val s2tup = s2exp_tyrec(knd, npf, ls2es)', 'val s2tup = s2exp_tyrec(knd, ~1, ls2es)'),
 ('pats_trans3_dynexp_up.dats', 'the type of a record', 'val s2e_rec = s2exp_tyrec(recknd, npf, ls2es)', 'val s2e_rec = s2exp_tyrec(recknd, ~1, ls2es)'),
 ('pats_trans3_dynexp_up.dats', 'the elements of a sequence are checked against the last type', 'val d3e = d2exp_trdn (d2e, s2e_void)\n    val (d3es, s2e_res)', 'val d3e = d2exp_trup (d2e)\n    val (d3es, s2e_res)'),
 ('pats_trans3_dynexp_up.dats', 'the type of a sequence is not normalized', 'val s2e_res = s2exp_hnfize (d3e.d3exp_type ())', 'val s2e_res = d3e.d3exp_type ()'),
 ('pats_trans3_dynexp_up.dats', 'the scope of a let does not check the variables', 'val () = the_d2varenv_check (loc0)\n//\n  val () = the_effenv_pop ()', 'val () = ()\n//\n  val () = the_effenv_pop ()'),
 ('pats_trans3_dynexp_up.dats', 'the bindings of a let are not undone', 'val () = the_s2cstbindlst_pop_and_unbind ()\n  val () = the_d2varenv_pop ()', 'val () = ()\n  val () = the_d2varenv_pop ()'),
 ('pats_trans3_dynexp_up.dats', 'effmask does not push the mask', 'val () = the_effenv_push_effmask (s2fe)\n    val d3e = d2exp_trup (d2e)\n    val () = the_effenv_pop ()', 'val () = the_effenv_push ()\n    val d3e = d2exp_trup (d2e)\n    val () = the_effenv_pop ()'),
 ('pats_trans3_dynexp_up.dats', 'vcopyenv of a proof', 'if test_prfkind(knd)\n              then s2exp_vcopyenv_v(s2e) else s2exp_vcopyenv_vt(s2e)', 'if test_prfkind(knd)\n              then s2exp_vcopyenv_vt(s2e) else s2exp_vcopyenv_v(s2e)'),
 ('pats_trans3_dynexp_up.dats', 'vcopyenv of an untyped variable', '| ~GOnone () => s2exp_void_t0ype ()\n      ) : s2exp // end of [val]\n    in\n      d3exp_vcopyenv', '| ~GOnone () => s2exp_int_t0ype ()\n      ) : s2exp // end of [val]\n    in\n      d3exp_vcopyenv'),
 ('pats_trans3_dynexp_up.dats', 'the linearity error of a function argument pattern is not recorded', 'the_trans3errlst_add(trans3err_T3E_d2exp_trup_arg_body_linpat(p2t))', '()'),
 ('pats_trans3_dynexp_up.dats', 'the check of the linear variables of a lambda', 'val () = the_d2varenv_check(loc0)\nval () =\n  if lin > 0 then the_d2varenv_check_llam(loc0)', 'val () = the_d2varenv_check(loc0)\nval () =\n  if lin > 1 then the_d2varenv_check_llam(loc0)'),
 ('pats_trans3_dynexp_up.dats', 'the function of a lambda is linear when lin=0', 'val islin = (lin > 0)\nval isprf', 'val islin = (lin >= 0)\nval isprf'),
 ('pats_trans3_dynexp_up.dats', 'the lambda body is not pushed in the proof manager', 'val\n() = the_pfmanenv_push_lam(lin) // lin:0/1:stopping/continue', 'val\n() = the_pfmanenv_push_lam(1-lin) // lin:0/1:stopping/continue'),
 ('pats_trans3_dynexp_up.dats', 'the check of a flat closure is inverted', '        | FUNCLOclo0 () => () // [CLO]', '        | FUNCLOcloptr () => () // [CLO]'),
 ('pats_trans3_dynexp_up.dats', 'a static lambda does not add the guards', 'val () = trans3_env_hypadd_proplst (loc0, s2ps)', 'val () = ()'),
 ('pats_trans3_dynexp_up.dats', 'a static lambda does not add the variables', 'val () = trans3_env_add_svarlst (s2vs)', 'val () = ()'),
 ('pats_trans3_dynexp_up.dats', 'the metric is not checked', 'val () = s2explst_check_termet (loc0, s2es_met)', 'val () = ()'),
 ('pats_trans3_dynexp_up.dats', 'the metric variables are not pushed', 'val () = termetenv_push_dvarlst (d2vs_ref.d2varlstref_val (), s2es_met)', 'val () = termetenv_push_dvarlst (glist_nil (), s2es_met)'),
 ('pats_trans3_dynexp_up.dats', 'a fixpoint is typed by the syntactic type', 'val s2e2opt_def = gopt_some (s2e2_def)', 'val s2e2opt_def = gopt_some (s2e_def)'),
 ('pats_trans3_dynexp_up.dats', 'the master type of a fixpoint is not set', 'val () = d2var_set_mastype (d2v, s2e2opt_def)', 'val () = ()'),
 ('pats_trans3_dynexp_up.dats', 'a closure is made a function in the fixpoint type', 's2exp_fun_srt (s2e0.s2exp_srt (), FUNCLOfun, lin, s2fe, npf, s2es_arg, s2e_res)', 's2exp_fun_srt (s2e0.s2exp_srt (), fc, lin, s2fe, npf, s2es_arg, s2e_res)'),
 ('pats_trans3_dynexp_up.dats', 'a macro syntax: decode and xstage swapped', '| $SYN.MSKdecode () => $MAC.dmacro_eval_decode (d2e)', '| $SYN.MSKdecode () => $MAC.dmacro_eval_xstage (d2e)'),
 ('pats_trans3_dynexp_up.dats', 'the macro message', '": the macro syntax `(...) is used incorrectly."', '": the macro syntax `(...) is used wrongly."'),
 ('pats_trans3_dynexp_up.dats', 'solassert does not add the proposition', 'val ((*added*)) = trans3_env_solver_assert (loc0, s2e_prop)', 'val ((*added*)) = ()'),
 ('pats_trans3_dynexp_up.dats', 'solverify is not hnfized', 'val s2f_prop = s2exp_hnfize(s2e_prop)', 'val s2f_prop = s2e_prop'),
 ('pats_trans3_dynexp_up.dats', 'a raise does not check the effect', 'val err =\n      the_effenv_check_exn (loc0)', 'val err =\n      0'),
 ('pats_trans3_dynexp_up.dats', 'an array with no element has no top type', 'else s2exp_top (0(*knd*), s2e_elt)', 'else s2e_elt'),
 ('pats_trans3_dynexp_up.dats', 'the size of an array of the form int is not an index', 's2exp_int_index_t0ype(s2i_asz)', 's2exp_int_t0ype()'),
 ('pats_trans3_dynexp_up.dats', 'the error type of the size of an array', '| ~None_vt((*void*)) => s2exp_errexp(s2rt_int)', '| ~None_vt((*void*)) => s2exp_int(0)'),
 ('pats_trans3_dynexp_up.dats', 'the array subscript argument', 'd2exparg_D2EXPARGdyn(~1(*npf*), loc_arg, d2es_arg)', 'd2exparg_D2EXPARGdyn(0(*npf*), loc_arg, d2es_arg)'),
 ('pats_trans3_dynexp_up.dats', 'a showtype is not printed', 'val () = fshowtype_d3exp_up (d3e)', 'val () = ()'),
 ('pats_trans3_dynexp_up.dats', 'a list expression is a record', 'd2exp_tup_flt (loc0, npf,d2es) in d2exp_trup (d2e0)', 'd2exp_tup_flt (loc0, ~1,d2es) in d2exp_trup (d2e0)'),
 ('pats_trans3_dynexp_up.dats', 'the typing of an extval', '| ~D2Eextval(s2e, name) => d3exp_extval (loc0, s2e, name)', '| ~D2Eextval(s2e, name) => d3exp_extval (loc0, s2exp_int_t0ype (), name)'),
 ('pats_trans3_dynexp_up.dats', 'the type of a typed variable name', 'the_trans3errlst_add (trans3err_T3E_d2var_typeless (loc0, d2v))', '()'),
 ('pats_trans3_dynexp_up.dats', 'the message of a consumed non-linear variable', '": the (non-linear) dynamic variable ["', '": the (nonlinear) dynamic variable ["'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
ONLY = sys.argv[3:] if len(sys.argv) > 3 else None
env = dict(os.environ)
def build():
    r = subprocess.run(['make', '-f', 't3g1.mk', '-j8', 't3g1dump'], cwd=d, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
    return r.returncode == 0
def run():
    o = open(T + '/t3g1mut.out', 'w'); e = open(T + '/t3g1mut.err', 'w')
    subprocess.run([os.path.join(d, 't3g1dump')], stdout=o, stderr=e, cwd=d, timeout=120)
    o.close(); e.close()
    return filecmp.cmp(T + '/t3g1mut.out', ref_out, shallow=False) and filecmp.cmp(T + '/t3g1mut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    link = os.path.join(M, fn)
    real = os.path.realpath(link)
    src = open(real).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if old == new: print('SKIP (no change): %s' % what); continue
    if ONLY and what not in ONLY: continue
    os.remove(link)
    try:
        open(link, 'w').write(src.replace(old, new))
        nm += 1
        try:
            if not build(): res = 'detected (does not compile)'; nd += 1
            elif run(): res = 'NOT DETECTED'
            else: res = 'detected'; nd += 1
        except subprocess.TimeoutExpired:
            res = 'detected (timeout)'; nd += 1
    finally:
        os.remove(link); os.symlink(real, link)
        os.utime(real)   # the object of the module is rebuilt by the next make
    print('%-28s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
