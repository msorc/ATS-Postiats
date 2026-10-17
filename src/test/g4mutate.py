#!/usr/bin/env python3
# usage: python3 g4mutate.py REF.out REF.err [N ...]
# Mutation test of the group 4 test: each mutation is a deliberate bug (a textual replacement) in one of the 7 modules of src/. The module is
# rebuilt (make g4dump), g4dump is run, and its stdout/stderr must differ from REF (the output of the ATS1 driver g4dump1, `make g4dump1`).
# The module is restored after each run (also on an error); a backup is in /tmp/g4mut_backup.
import os, subprocess, sys, shutil
d = os.path.dirname(os.path.abspath(__file__))
S2 = os.path.join(d, '..')
M = [
 ('decl', 'val () =\n  the_effenv_push_set_if (isprf, $EFF.effset_all)', 'val () =\n  the_effenv_push_set_if (~isprf, $EFF.effset_all)'),
 ('decl', '  val ((*void*)) = trans3_env_add_svarlst(imparg)\n', '  val ((*void*)) = ()\n'),
 ('decl', 'if\nisrec\nthen let', 'if\n~isrec\nthen let'),
 ('decl', 'if sgn < 0 then (os2ts0 := os2ts)', 'if sgn > 0 then (os2ts0 := os2ts)'),
 ('decl', '    val ((*void*)) = the_s2cstbindlst_pop_and_unbind ((*void*))\n    val ((*void*)) = the_s2cstbindlst_addlst (s2cs_body)', '    val ((*void*)) = the_s2cstbindlst_addlst (s2cs_body)\n    val ((*void*)) = the_s2cstbindlst_pop_and_unbind ((*void*))'),
 ('decl', 'val () = d2var_set_mastype (d2v2, d2var_get_mastype (d2v))', 'val () = d2var_set_mastype (d2v2, d2var_get_type (d2v))'),
 ('decl', "| ~GOnone() => let\n              val\n              s2eopt = gopt_some(s2e_def)", "| ~GOnone() => let\n              val\n              s2eopt = gopt_some(s2e)"),
 ('decl', '      val () = d2var_set_mastype (d2v_fun, opt)\n    } (* end of [val] *)', '    } (* end of [val] *)'),
 ('decl', 'val () = d3lval_set_pat_type_left (d3e_def, p3t_val)', 'val () = ()'),
 ('decl', 'val d3e_def = d2exp_trup(impdec.i2mpdec_def ())', 'val d3e_def = d2exp_trup(impdec.i2mpdec_def ()); val () = trans3_env_push ()'),
 ('looping', 'val ctrknd = c3nstrkind_C3TKloop(0(*breaking*))', 'val ctrknd = c3nstrkind_C3TKloop(1(*breaking*))'),
 ('looping', "  | ~GOsome (d2e) => gopt_some (d2exp_trdn (d2e, s2f_void))", "  | ~GOsome (d2e) => gopt_none ()"),
 ('looping', 'val () = trans3_env_hypadd_propopt_neg (loc_test, os2p_test)', 'val () = trans3_env_hypadd_propopt (loc_test, os2p_test)'),
 ('looping', 'if ~(iseq) then d2var_reset_type (d2v)\n      end // end of [Some, Some]', 'if (iseq) then d2var_reset_type (d2v)\n      end // end of [Some, Some]'),
 ('looping', 'val () = lstbefitmlst_restore_type (lsbis1)', 'val () = ()'),
 ('looping', 'val () = i2nvresstate_update (locinv, i2nv.loopi2nv_res ())', 'val () = ()'),
 ('assgn', '  val () = d2var_inc_linval(d2v)\nin\n  if glist_is_cons (d3ls)', '  val () = ()\nin\n  if glist_is_cons (d3ls)'),
 ('assgn', '    val () = d2var_inc_linval (d2vw)\n//\n    val\n    s2e_elt = s2ctxt_hrepl(ctxt, s2e_sel2)', '    val () = ()\n//\n    val\n    s2e_elt = s2ctxt_hrepl(ctxt, s2e_sel2)'),
 ('assgn', 'if sharing > 0\n    then auxerr_sharing (loc0, s2e_elt, d3ls)', 'if sharing >= 0\n    then auxerr_sharing (loc0, s2e_elt, d3ls)'),
 ('assgn', '    val _(*err*) = the_effenv_check_ref (loc0)\n  in\n    d3exp_assgn_ref', '  in\n    d3exp_assgn_ref'),
 ('assgn', 'glist_cons(arr, glist_append(ind, glist_sing(d2e_r)))', 'glist_cons(arr, glist_append(glist_sing(d2e_r), ind))'),
 ('assgn', 'the_trans3errlst_add(trans3err_T3E_s2addr_assgn_deref_proof(loc0, s2e, d3ls))', 'the_trans3errlst_add(trans3err_T3E_s2addr_assgn_deref_linsel(loc0, s2e, d3ls))'),
 ('deref', 'val s2e_sel = s2exp_topize (1, s2e_sel)', 'val s2e_sel = s2exp_topize (0, s2e_sel)'),
 ('deref', '    val _(*err*) = the_effenv_check_ref (loc0)\n//\n  in\n    d3exp_sel_ref', '//\n  in\n    d3exp_sel_ref'),
 ('deref', 'd2exparg_D2EXPARGdyn (~1(*npf*), loc_arg, d2es_arg)', 'd2exparg_D2EXPARGdyn (0(*npf*), loc_arg, d2es_arg)'),
 ('deref', 'val () = d2var_inc_linval (d2vw)', 'val () = ()'),
 ('ptrof', 'if glist_is_cons (d3ls) then let\n    val () = assertloc (gopt_is_some (d2var_get_addr (d2v)))', 'if glist_is_nil (d3ls) then let\n    val () = assertloc (gopt_is_some (d2var_get_addr (d2v)))'),
 ('ptrof', 'val () =\n            s2rt := s2exp_void_t0ype () in s2exp_ptr_addr_type (s2l)', 'val () =\n            s2rt := s2exp_t0ype_err () in s2exp_ptr_addr_type (s2l)'),
 ('ptrof', 'val s2ls = auxlabs (d3ls)', 'val s2ls = glist_nil ()'),
 ('viewat', '    val () = d2var_inc_linval (d2vw)\n//\n    val s2e_out', '//\n    val s2e_out'),
 ('viewat', 'if l1 = l2 then eq_dlablst_slablst (d3ls, s2ls) else false', 'if ~(l1 = l2) then eq_dlablst_slablst (d3ls, s2ls) else false'),
 ('viewat', '    val () = s2addr_set_viewat (loc0, s2l, d3ls, s2e_r)\n    val loc = d2e_l.d2exp_loc ()', '    val () = ()\n    val loc = d2e_l.d2exp_loc ()'),
 ('viewat', '  val () = auxck_addreq (loc0, s2l, d3ls, s2l_new)', '  val () = auxck_addreq (loc0, s2l_new, d3ls, s2l)'),
 ('viewat', 'val s2e_old =\n      s2addr_exch_type (loc0, s2l, d3ls, s2e1)', 'val s2e_old =\n      s2addr_exch_type (loc0, s2l, d3ls, s2e2)'),
 ('xchng', 'val err = $SOL.s2hnf_tyleq_solve (loc1, s2f0_sel, s2f_sel)\n    val () = if err > 0 then let', 'val err = $SOL.s2hnf_tyleq_solve (loc1, s2f_sel, s2f0_sel)\n    val () = if err > 0 then let'),
 ('xchng', '    d3exp_sel_ptr( loc1, s2e_sel, d3e, s2rt, d3ls )', '    d3exp_sel_ptr( loc0, s2e_sel, d3e, s2rt, d3ls )'),
 ('xchng', '    then auxerr1(loc0, loc1, s2f0_sel, s2f_sel)\n    // end of [if]\n//\n  in\n    d3exp_sel_var', '    then auxerr1(loc1, loc0, s2f0_sel, s2f_sel)\n    // end of [if]\n//\n  in\n    d3exp_sel_var'),
 ('xchng', '    val d3e_r =\n    s2addr_xchng_deref(loc0, s2l, d3ls, d2e_r, s2rt)\n    val ((*if-error*)) = auxerr_wrt_if(loc0)', '    val d3e_r =\n    s2addr_xchng_deref(loc0, s2l, d3ls, d2e_r, s2rt)\n    val ((*if-error*)) = ()'),
 ('xchng', 'val _(*err*) = the_effenv_check_ref (d2e_r.d2exp_loc ())', 'val _(*err*) = the_effenv_check_ref (loc0)'),
 ('xchng', '    val () = d2var_inc_linval (d2vw)\n    val s2e_elt = s2ctxt_hrepl (ctxt, s2e0_sel)', '    val s2e_elt = s2ctxt_hrepl (ctxt, s2e0_sel)'),
]
def run(cmd, env=None):
    return subprocess.run(cmd, shell=True, cwd=d, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
def main():
    ref_out, ref_err = sys.argv[1], sys.argv[2]
    only = [int(x) for x in sys.argv[3:]]
    ro = open(ref_out, 'rb').read(); re_ = open(ref_err, 'rb').read()
    shutil.copytree(S2, '/tmp/g4mut_backup', ignore=shutil.ignore_patterns('test', '*.o', '*.c'), dirs_exist_ok=True) if False else None
    det = 0; tot = 0
    for i, (m, old, new) in enumerate(M):
        if only and i not in only: continue
        p = os.path.join(S2, 'pats_trans3_%s.dats' % m)
        orig = open(p).read()
        open('/tmp/g4mut_backup_%s.dats' % m, 'w').write(orig)
        if orig.count(old) != 1:
            print('%2d %-8s SKIP (the text occurs %d times)' % (i, m, orig.count(old))); continue
        tot += 1
        try:
            open(p, 'w').write(orig.replace(old, new))
            r = run('make g4dump_exe 2>&1 | tail -3')
            built = os.path.exists(os.path.join(d, 'g4dump'))
            o = run('./g4dump')
            same = (o.stdout == ro and o.stderr == re_)
            status = 'DETECTED' if not same else 'NOT DETECTED'
            if not same: det += 1
            print('%2d %-8s %s (rc=%d) %s' % (i, m, status, o.returncode, new.split('\n')[0][:60]))
        finally:
            open(p, 'w').write(orig)
    print('mutations: %d, detected %d' % (tot, det))
    run('make g4dump_exe 2>&1 | tail -1')
if __name__ == '__main__': main()
