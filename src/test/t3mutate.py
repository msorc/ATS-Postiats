#!/usr/bin/env python3
# usage: python3 t3mutate.py REF.out REF.err [WHAT...]   (the stdout and stderr of t3dump1, the ATS1 reference)
#
# Mutation test of the level-3 test: each mutation is a deliberate bug that is put in a ported module (the file is restored afterwards), t3dump is rebuilt
# and its outputs are compared with the ATS1 reference: every mutation must change an output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 # ---- pats_dynexp3.dats
 ('pats_dynexp3.dats', 'p3at_is_lincon tests the unfold kind', '| ~P3Tcon (pck, _, _, _) => pck = PCKlincon', '| ~P3Tcon (pck, _, _, _) => pck = PCKunfold'),
 ('pats_dynexp3.dats', 'p3at_is_unfold tests the lincon kind', '| ~P3Tcon (pck, _, _, _) => pck = PCKunfold', '| ~P3Tcon (pck, _, _, _) => pck = PCKlincon'),
 ('pats_dynexp3.dats', 'a variable pattern is not full', '| ~P3Tvar _ => true', '| ~P3Tvar _ => false'),
 ('pats_dynexp3.dats', 'the labels of d3explst_get_labtype skip one', 'glist_cons(ls2e, auxlst(d3es, i+1))', 'glist_cons(ls2e, auxlst(d3es, i+2))'),
 ('pats_dynexp3.dats', 'd3exp_con does not topize the types of the tops', 'then s2exp_topize_0 (s2e) else s2e', 'then s2e else s2exp_topize_0 (s2e)'),
 ('pats_dynexp3.dats', 'd3exp_app_unista keeps the argument for a metfun', '| ~S2Emetfun _ => d3exp_app_sta (loc, s2f, d3e)', '| ~S2Emetfun _ => d3e'),
 ('pats_dynexp3.dats', 'the type of d3exp_lam_met is lost', 'd3exp_node_D3Elam_met(s2es_met, d3e_body)', 'd3exp_node_D3Elam_met(glist_nil (), d3e_body)'),
 # ---- pats_dynexp3_print.dats
 ('pats_dynexp3_print.dats', 'a space in the printer of D3Eapp_dyn', 'val () = prstr "D3Eapp_dyn("', 'val () = prstr "D3Eapp_dyn ("'),
 ('pats_dynexp3_print.dats', 'the printer of a boolean pattern', 'val name = if b then "true" else "false"', 'val name = if b then "True" else "false"'),
 # ---- pats_trans3_env.dats
 ('pats_trans3_env.dats', 'unimet returns the whole type for a metric without stamp', '| ~GOnone () => @(s2e1, s2ps_fst)', '| ~GOnone () => @(s2e, s2ps_fst)'),
 ('pats_trans3_env.dats', 'the negation of an optional proposition', 'trans3_env_hypadd_prop (loc, s2exp_bneg (s2p))', 'trans3_env_hypadd_prop (loc, s2p)'),
 ('pats_trans3_env.dats', 'the arity error of the sign', 'auxerr1 (locarg, ~1) // HX: fewer arguments expected', 'auxerr1 (locarg, 1) // HX: fewer arguments expected'),
 ('pats_trans3_env.dats', 'exi instantiation is uni', '  s2exp_exiuni_instantiate_all (0, s2e0, locarg, err)', '  s2exp_exiuni_instantiate_all (1, s2e0, locarg, err)'),
 ('pats_trans3_env.dats', 'the items of a scope are popped newest first', '  glist_reverse (xs)\nend // end of [the_s3itmlst_env_pop]', '  xs\nend // end of [the_s3itmlst_env_pop]'),
 ('pats_trans3_env.dats', 'pop_and_add_main adds another kind', 'trans3_env_pop_and_add (loc, c3nstrkind_C3TKmain())', 'trans3_env_pop_and_add (loc, c3nstrkind_C3TKsolverify())'),
 ('pats_trans3_env.dats', 'the constraint of an integer pattern', '$SOL.s2exp_hypequal_solve (loc0, s2e_arg, s2exp_intinf (i))', '$SOL.s2exp_hypequal_solve (loc0, s2e_arg, s2exp_int (0))'),
 ('pats_trans3_env.dats', 'a character constraint set is a single character', 's2exp_intneq (s2e_arg, s2exp_int_char x)', "s2exp_intneq (s2e_arg, s2exp_int_char 'a')"),
 ('pats_trans3_env.dats', 'the sort of the labels of a record is not stable', 'if sgn < 0 then glist_cons (x, glist_cons (y, ys))', 'if sgn <= 0 then glist_cons (x, glist_cons (y, ys))'),
 ('pats_trans3_env.dats', 'the labels of a record are matched the wrong way', 'if sgn < 0 then\n          hypadd_labpatcst_aux (loc0, lp2tcs1, ls2es)', 'if sgn > 0 then\n          hypadd_labpatcst_aux (loc0, lp2tcs1, ls2es)'),
 ('pats_trans3_env.dats', 'a disjunction of patterns is empty', 'the_s3itmlst_env_add (s3itm_S3ITMdisj (s3iss))', 'the_s3itmlst_env_add (s3itm_S3ITMdisj (glist_nil ()))'),
 ('pats_trans3_env.dats', 'un_s2exp_wthtype always says yes', '  @(iswth, s2e_res, wths2es)', '  @(true, s2e_res, wths2es)'),
 ('pats_trans3_env.dats', 'the type of an opened expression is not set', '  d3exp_set_type (d3e, s2e)\nend // end of [d3exp_open_and_add]', '  d3exp_set_type (d3e, d3e.d3exp_type ())\nend // end of [d3exp_open_and_add]'),
 ('pats_trans3_env.dats', 'the occurrence in the second side of an equality is missed', '    then true else aux1_s2exp(s2v0, s2e2)\n  // end of [if] // end of [S2Eeqeq]', '    then true else false\n  // end of [if] // end of [S2Eeqeq]'),
 ('pats_trans3_env.dats', 'the binding of an occurrence check is not followed', '| ~Some_vt(s2e) => aux1_s2exp(s2v0, s2e)', '| ~Some_vt(s2e) => false'),
 ('pats_trans3_env.dats', 'the template instantiation is not reversed', '  case+ glist_view (s2qs) of\n  | ~GLnil() =>\n      list_vt_reverse (t2mas)', '  case+ glist_view (s2qs) of\n  | ~GLnil() =>\n      (t2mas)'),
 ('pats_trans3_env.dats', 'the sup relation of the strings', 'val s2c1 = s2cstref_get_cst (the_string_int_type)', 'val s2c1 = s2cstref_get_cst (the_string_type)'),
 # ---- pats_trans3_env_effect.dats
 ('pats_trans3_env_effect.dats', 'a hard mark is soft', 'val efis = glist_cons (effenvitm_EFFENVITMmark (1(*hard*)), efis_get ())', 'val efis = glist_cons (effenvitm_EFFENVITMmark (0(*soft*)), efis_get ())'),
 ('pats_trans3_env_effect.dats', 'the effects of an item are subtracted instead of intersected', '          effset_inter (efs0, efs)\n        // end of [val]', '          effset_diff (efs0, efs)\n        // end of [val]'),
 ('pats_trans3_env_effect.dats', 'a union of the effects of a mask is a difference', '| ~S2EFFset (efs) => effset_union (efs0, efs)', '| ~S2EFFset (efs) => effset_diff (efs0, efs)'),
 ('pats_trans3_env_effect.dats', 'a soft mark stops the check', 'if knd > 0 then 1(*fail*) else check_set_auxcheck', 'if knd >= 0 then 1(*fail*) else check_set_auxcheck'),
 ('pats_trans3_env_effect.dats', 'the check of an expression accepts every item', 'val ans = (if issup then 0 else 1): int', 'val ans = (if issup then 1 else 0): int'),
 ('pats_trans3_env_effect.dats', 'case+ does not check the exceptions', '| CK_case () => the_effenv_check_exn (loc0)', '| CK_case () => 0'),
 # ---- pats_trans3_env_dvar.dats
 ('pats_trans3_env_dvar.dats', 'a lambda that is not linear collects', 'if lin > 0 then let\n        val () = set_ld2vsfrm_d2vs', 'if lin >= 0 then let\n        val () = set_ld2vsfrm_d2vs'),
 ('pats_trans3_env_dvar.dats', 'the variables of a llam are taken from a set frame', '    if frm.ld2vsfrm_knd () = 1 then let\n      val d2vs = frm.ld2vsfrm_d2vs ()', '    if frm.ld2vsfrm_knd () = 0 then let\n      val d2vs = frm.ld2vsfrm_d2vs ()'),
 ('pats_trans3_env_dvar.dats', 'a non-linear lambda is crossed by the save', 'if frm.ld2vsfrm_lin () > 0 then save_auxsetlst (xs1, res) else ()', 'if frm.ld2vsfrm_lin () >= 0 then save_auxsetlst (xs1, res) else ()'),
 ('pats_trans3_env_dvar.dats', 'a mutable variable is linear', 'val () = d2var_set_linval (d2v, ~1(*nonlin*))', 'val () = d2var_set_linval (d2v, 0)'),
 ('pats_trans3_env_dvar.dats', 'the type of a consumed variable is kept', '    if linval >= 0 then d2var_set_type(d2v, gopt_none ())', '    if linval > 0 then d2var_set_type(d2v, gopt_none ())'),
 ('pats_trans3_env_dvar.dats', 'a finalization of a view is not recorded', 'd2var_set_finknd (d2v_view, d2vfin_D2VFINsome (s2e_at))', 'd2var_set_finknd (d2v_view, d2vfin_D2VFINnone ())'),
 ('pats_trans3_env_dvar.dats', 'the llam check keeps the type', '        d2var_set_type (d2v, gopt_none ())\n      // end of [if]', '        ()\n      // end of [if]'),
 ('pats_trans3_env_dvar.dats', 'a pop stops at a lambda marker', '    end else pop_loop (ld2vss)\n  end else let\n    val () = ld2vs_put (d2varset_vt_nil ()) in glist_nil ()', '    end else ld2vss\n  end else let\n    val () = ld2vs_put (d2varset_vt_nil ()) in glist_nil ()'),
 # ---- pats_trans3_env_lstate.dats
 ('pats_trans3_env_lstate.dats', 'a type that differs by a reference is merged only once', 'if iseq then saityplst_check_auxlst (s2e0, xs) else 1(*merge*)', 'if iseq then saityplst_check_auxlst (s2e0, xs) else 0(*merge*)'),
 ('pats_trans3_env_lstate.dats', 'a type that is found in the context has the kind 2', 'val opt = d2var_get_mastype (d2v) in (k := 1; opt)', 'val opt = d2var_get_mastype (d2v) in (k := 2; opt)'),
 ('pats_trans3_env_lstate.dats', 'the substitution is done for every merge', 'if knd >= 2\n            then s2exp_subst (sub, s2e0) else s2e0', 'if knd >= 1\n            then s2exp_subst (sub, s2e0) else s2e0'),
 ('pats_trans3_env_lstate.dats', 'the linear value is not restored', '        d2var_set_linval (d2v, x.lstbefitm_linval ())', '        d2var_set_linval (d2v, 0)'),
 ('pats_trans3_env_lstate.dats', 'the update of a loop does not count', '      d2var_inc_linval (d2v)\n    // end of [val]', '      ()\n    // end of [val]'),
 ('pats_trans3_env_lstate.dats', 'the constraint of the merge is not stored', 'val () = set_c3nstroptref_val (ctr, gopt_some (c3t0))', 'val () = ()'),
 # ---- pats_trans3_env_pfman.dats
 ('pats_trans3_env_pfman.dats', 'a pop of the proof manager stops at the variables', '    if x.d2vmrk_knd () = 0 then pop_loop (glist_tail (xs)) else glist_tail (xs)', '    if x.d2vmrk_knd () = 0 then glist_tail (xs) else glist_tail (xs)'),
 ('pats_trans3_env_pfman.dats', 'a lambda does not stop the search', '#define PUSH_LAM ~1 // stopping', '#define PUSH_LAM 1 // stopping'),
 ('pats_trans3_env_pfman.dats', 'a marked list of the search ends at a flexible mark', '    if knd > 0 then pfobj_search_loop (xs1, s2l0, res) else None_vt ()', '    if knd >= 0 then pfobj_search_loop (xs1, s2l0, res) else None_vt ()'),
 ('pats_trans3_env_pfman.dats', 'the search of an at-view compares with the content', 'val iseq = s2exp_syneq(s2l, s2e2)', 'val iseq = s2exp_syneq(s2l, s2e1)'),
 ('pats_trans3_env_pfman.dats', 'the context of a found view is not a hole', 'val s2e_ctx = s2exp_at(s2e1, s2e2)', 'val s2e_ctx = s2exp_at(s2e2, s2e2)'),
 # ---- termet, lamlp, scst, svar, print
 ('pats_trans3_env_termet.dats', 'the sort of a metric is not tested', 'val isint = s2rt_is_int (s2e.s2exp_srt ())', 'val isint = not (s2rt_is_int (s2e.s2exp_srt ()))'),
 ('pats_trans3_env_termet.dats', 'a metric that is not bound is fine', '    val s2p = s2exp_bool (false)\n  in\n    trans3_env_add_prop (loc0, s2p)', '    val s2p = s2exp_bool (true)\n  in\n    trans3_env_add_prop (loc0, s2p)'),
 ('pats_trans3_env_termet.dats', 'the sorts of the metrics are not recorded', '    val () = s2ts0 := metfun_srtlst (s2es)', '    val () = s2ts0 := glist_nil ()'),
 ('pats_trans3_env_lamlp.dats', 'the arguments of a function are searched across a loop', '| ~LAMLPloop0 _ => get_funarg_loop (xs)', '| ~LAMLPloop0 _ => None_vt ()'),
 ('pats_trans3_env_scst.dats', 'a bound constant is not marked as abstract', 'val () = s2cst_set_isasp(s2c, gopt_some(s2e))', 'val () = s2cst_set_isasp(s2c, gopt_none())'),
 ('pats_trans3_env_scst.dats', 'the unbinding keeps the definition', 's2cst_set_def(s2c, gopt_none())', 's2cst_set_def(s2c, gopt_some(s2exp_int(0)))'),
 ('pats_trans3_env_scst.dats', 'the constants of a list are added in the reverse order', 'glist_append (l2l(s2cs), xs)', 'glist_append (xs, l2l(s2cs))'),
 ('pats_trans3_env_svar.dats', 'the bindings of a scope are not removed', '      val () = s2varbindmap_remove (map, s2v) in auxrmv (map, s2vs)', '      val () = () in auxrmv (map, s2vs)'),
 ('pats_trans3_env_print.dats', 'the name of a hypothesis', 'prstr "H2YPOeqeq("', 'prstr "H3YPOeqeq("'),
 ('pats_trans3_env_print.dats', 'the separator of the lists of the lists of items', 'fprintlst<s3itmlst> (out, xss, "; ", fprint_s3itmlst)', 'fprintlst<s3itmlst> (out, xss, ", ", fprint_s3itmlst)'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
ONLY = sys.argv[3:] if len(sys.argv) > 3 else None
T = os.environ.get('TMPDIR', '/tmp')
def build():
    r = subprocess.run(['make', '-C', d, 't3dump', '-j16'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    o = open(T + '/t3mut.out', 'w'); e = open(T + '/t3mut.err', 'w')
    subprocess.run([os.path.join(d, 't3dump')], stdout=o, stderr=e, cwd=d)
    o.close(); e.close()
    return filecmp.cmp(T + '/t3mut.out', ref_out, shallow=False) and filecmp.cmp(T + '/t3mut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if old == new: print('SKIP (no change): %s' % what); continue
    if ONLY and what not in ONLY: continue
    bak = T + '/t3mut_backup_' + fn
    shutil.copy(path, bak)
    try:
        open(path, 'w').write(src.replace(old, new))
        nm += 1
        if not build(): res = 'detected (does not compile)'; nd += 1
        elif run(): res = 'NOT DETECTED'
        else: res = 'detected'; nd += 1
    finally:
        shutil.copy(bak, path)
        assert filecmp.cmp(path, bak, shallow=False)
    print('%-30s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
