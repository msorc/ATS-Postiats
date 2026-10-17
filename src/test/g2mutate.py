#!/usr/bin/env python3
# g2mutate.py: the mutation test of the level-3 translation test, group 2 (see PORTING.md, "Level 3 translation, group 2").
# usage: python3 g2mutate.py STAGE REFDIR [N ...]
#   STAGE: the staged build of `make g2dump` (G2STAGE), REFDIR: the files ref.out ref.err ref.rc (the stdout/stderr/exit status of the ATS1-built g2dump1) and
#   ref_exit.out ref_exit.err ref_exit.rc (the same with CG_ERRTEST=1: the scenario that ends the process). Each deliberate bug is applied to a
#   COPY of one module in STAGE (the link to src is replaced for the time of the test), the module is recompiled, g2dump relinked and run; the run must differ.
import os, subprocess, sys, shutil
ST = os.path.abspath(sys.argv[1])
RD = sys.argv[2]
import re
def filt(b):
    # the text of the final assertion differs by construction (assertloc in ATS2): drop the lines of an abort
    return b''.join(l for l in b.splitlines(True) if l.strip() and not (l.startswith(b'exit(ATS)') or re.match(rb'^/\S*\.dats: \d+\(line=', l)))
def ref(n): return (open(os.path.join(RD, n + '.out'), 'rb').read(), open(os.path.join(RD, n + '.err'), 'rb').read(), int(open(os.path.join(RD, n + '.rc')).read().strip()))
REF = ref('ref'); REFX = ref('ref_exit')
only = set(int(a) for a in sys.argv[3:])
M = {'dn': 'pats_trans3_dynexp_dn', 'ap': 'pats_trans3_appsym', 'co': 'pats_trans3_caseof', 'pc': 'pats_trans3_patcon'}
MUT = [
 ('dn', 'if glist_is_nil(s2vs)\n      then d2exp_trdn_lam_sta_nil', 'if glist_is_cons(s2vs)\n      then d2exp_trdn_lam_sta_nil'),
 ('dn', 'val () =\n          serr := serr+1 in glist_nil()\n        // end of [val]\n      end // end of [list_nil]\n    | ~GLcons\n        (ls2e, ls2es)', 'val () =\n          serr := serr-1 in glist_nil()\n        // end of [val]\n      end // end of [list_nil]\n    | ~GLcons\n        (ls2e, ls2es)'),
 ('dn', 'val () = if serr < 0 then (prerr_string ": more arguments are expected."', 'val () = if serr > 0 then (prerr_string ": more arguments are expected."'),
 ('dn', 'val () = the_effenv_push_lam (s2fe)', 'val () = the_effenv_push_lam (s2fe1)'),
 ('dn', 'val () = if lin > 0 then the_d2varenv_check_llam (loc0)', 'val () = if lin > 1 then the_d2varenv_check_llam (loc0)'),
 ('dn', 'val loc_else = d2e_then.d2exp_loc() // HX: [d2e_then] (as in ATS1)', 'val loc_else = d2e_else.d2exp_loc()'),
 ('dn', 'gopt_some(s2exp_bmul(s2p_conj, s2exp_bneg(s2p_test)))', 'gopt_some(s2exp_bmul(s2p_conj, s2p_test))'),
 ('dn', '| ~GOsome(s2p_test) => gopt_some(s2exp_bmul(s2p_conj, s2p_test))', '| ~GOsome(s2p_test) => gopt_some(s2exp_bmul(s2p_test, s2p_conj))'),
 ('dn', 'trans3_env_hypadd_propopt_neg\n    (\n      d2e_cond.d2exp_loc()\n    , os2p_cond', 'trans3_env_hypadd_propopt\n    (\n      d2e_cond.d2exp_loc()\n    , os2p_cond'),
 ('dn', 'if\n(knd = 0)\nthen {', 'if\n(knd = 1)\nthen {'),
 ('dn', 'val d3e = d2exp_trdn (d2e, s2e_void)', 'val d3e = d2exp_trdn (d2e, s2e0)'),
 ('dn', 'if (err > 0) then\n  the_trans3errlst_add(trans3err_T3E_d2exp_trup_exn(loc0))', 'if (err > 1) then\n  the_trans3errlst_add(trans3err_T3E_d2exp_trup_exn(loc0))'),
 ('dn', 'loc0, CK_case_neg, r2es', 'loc0, CK_case, r2es'),
 ('dn', '  if iswth then funarg_d2vfin_check(loc0)', '  if false then funarg_d2vfin_check(loc0)'),
 ('dn', '$SOL.pfarity_equal_solve (loc0, npf, npf1)', '$SOL.pfarity_equal_solve (loc0, npf, npf)'),
 ('dn', '$SOL.boxity_equal_solve_err (loc0, knd, knd1, err)\n    val () = $SOL.pfarity_equal_solve_err (loc0, npf, npf1, err)\n    val () =\n    if err != 0 then {\n      val () =\n        prerr_the_staerrlst ()\n      val () =\n        the_trans3errlst_add(trans3err_T3E_d2exp_trdn_tup', '$SOL.boxity_equal_solve_err (loc0, 0, knd1, err)\n    val () = $SOL.pfarity_equal_solve_err (loc0, npf, npf1, err)\n    val () =\n    if err != 0 then {\n      val () =\n        prerr_the_staerrlst ()\n      val () =\n        the_trans3errlst_add(trans3err_T3E_d2exp_trdn_tup'),
 ('dn', '~GLnil() => list_vt_reverse(res)\n  | ~GLcons(d2e, d2es1) => let', '~GLnil() => res\n  | ~GLcons(d2e, d2es1) => let'),
 ('dn', 'val () = $SOL.s2eff_subeq_solve_err (loc0, s2fe, s2fe1, err2)', 'val () = $SOL.s2eff_subeq_solve_err (loc0, s2fe1, s2fe, err2)'),
 ('dn', '    val () = trans3_env_push ()\n    val () = trans3_env_add_svarlst (s2vs)\n    val () = trans3_env_hypadd_proplst (loc0, s2ps)\n    val d3e0 = d2exp_trdn (d2e0, s2e)\n    val () = trans3_env_pop_and_add_main (loc0)\n  in\n    d3exp_lam_sta (loc0, s2e0, s2vs, s2ps, d3e0)\n  end // end of [S2Euni]\n//\n| ~S2Erefarg', '    val () = trans3_env_push ()\n    val () = trans3_env_add_svarlst (s2vs)\n    val d3e0 = d2exp_trdn (d2e0, s2e)\n    val () = trans3_env_pop_and_add_main (loc0)\n  in\n    d3exp_lam_sta (loc0, s2e0, s2vs, s2ps, d3e0)\n  end // end of [S2Euni]\n//\n| ~S2Erefarg'),
 ('ap', 'if test then let\n          val d3pi', 'if ~test then let\n          val d3pi'),
 ('ap', 'if d3pitm_get_pval(x) = mpval', 'if d3pitm_get_pval(x) != mpval'),
 ('ap', 'if mpval < pval then pval else mpval', 'if mpval > pval then pval else mpval'),
 ('ap', 'if ~auxeq_d3pitm(d3pi0, x)', 'if auxeq_d3pitm(d3pi0, x)'),
 ('ap', '| ~D2ITMcst(d2c2) => (d2c1 = d2c2)', '| ~D2ITMcst(d2c2) => true'),
 ('ap', 'glist_length (d2es) = glist_length (s2es_arg) in', 'glist_length (d2es) <= glist_length (s2es_arg) in'),
 ('ap', 'if (npf = npf1) then let', 'if (npf <= npf1) then let'),
 ('ap', 'd23exp_trup_applst(d2e0, d3e_fun, d2as_rest)', 'd23exp_trup_applst(d2e0, d3e_fun, d2as)'),
 ('ap', 'if npf > 0\n  then let', 'if npf > 1\n  then let'),
 ('ap', '@(glist_sing(xy.0), l2l(d3as), d2as)', '@(glist_nil(), l2l(d3as), d2as)'),
 ('ap', 'if ismat then list_vt_cons (x, xs) else xs', 'if ~ismat then list_vt_cons (x, xs) else xs'),
 ('ap', 'if iswth\n          then d3explst_arg_restore', 'if ~iswth\n          then d3explst_arg_restore'),
 ('ap', 'if (err > 0) then (\n        the_trans3errlst_add (trans3err_T3E_d3exp_trup_applst_eff', 'if (err > 1) then (\n        the_trans3errlst_add (trans3err_T3E_d3exp_trup_applst_eff'),
 ('ap', 'val s2es_fun_arg = \n        s2fun_opninv_and_add (locarg, s2es_fun_arg, s2e_fun_res)', 'val s2es_fun_arg = s2es_fun_arg'),
 ('ap', '| ~D2ITMsymdef\n        (_(*sym*), d2pis_new) => let\n        val d2piss = list_vt_cons (d2pis, d2piss)', '| ~D2ITMsymdef\n        (_(*sym*), d2pis_new) => let\n        val d2piss = list_vt_cons (glist_nil(), d2piss)'),
 ('ap', 'auxmap_s2kexp(d3es, list_vt_cons(s2ke, res))', 'auxmap_s2kexp(d3es, res)'),
 ('co', 'if seq > 0 then let', 'if seq > 1 then let'),
 ('co', 'if neg > 0 then s2exp_bottom_t0ype_exi () else s2e_res', 'if neg > 1 then s2exp_bottom_t0ype_exi () else s2e_res'),
 ('co', '  | CK_case_pos () => c2lau_pat_comp (c2l)\n  | CK_case_neg () => list_vt_nil ()\n) : p2atcstlstlst_vt // end of [val]\n//\nval lsbis', '  | CK_case_pos () => list_vt_nil ()\n  | CK_case_neg () => list_vt_nil ()\n) : p2atcstlstlst_vt // end of [val]\n//\nval lsbis'),
 ('co', '(p2atcstlst_of_vt (xs), p2tcs_c2l)\n    val () = list_vt_free (xs)', '(p2tcs_c2l, p2atcstlst_of_vt (xs))\n    val () = list_vt_free (xs)'),
 ('co', 'if test\n        then list_vt_cons (list_vt_copy<p2atcst> (xs), res) else res', 'if ~test\n        then list_vt_cons (list_vt_copy<p2atcst> (xs), res) else res'),
 ('co', 'if glist_is_nil (gua)', 'if glist_is_cons (gua)'),
 ('co', 'val () = if ~isexhaust then let\n  val _(*err*) = the_effenv_caskind_check_exn (loc0, casknd)\nin', 'val () = if isexhaust then let\n  val _(*err*) = the_effenv_caskind_check_exn (loc0, casknd)\nin'),
 ('co', 'if not(isfst) then lstbefitmlst_restore_type (lsbis)', 'if isfst then lstbefitmlst_restore_type (lsbis)'),
 ('co', '| CK_case_neg () => ()\n//\nend // end of [c2laulst2_auxred]', '| CK_case_neg () => c2laulst2_auxerr (loc0, c2l, cp2tcss_inter)\n//\nend // end of [c2laulst2_auxred]'),
 ('co', 'val _(*void*) = d3explst_open_and_add (d3es)', 'val _(*void*) = ()'),
 ('co', 'list_vt_reverse_append (diff, res)', 'list_vt_reverse_append (res, diff)'),
 ('co', 'val () = lstbefitmlst_restore_type (lsbis)\n    val ctr', 'val ctr'),
 ('dn', 'val () = lstbefitmlst_restore_type(lsbis)\n//\nval d2e_else', 'val d2e_else'),
 ('dn', '    val () = lstbefitmlst_restore_type(lsbis)\n    val ifcls_rest', '    val ifcls_rest'),
 ('dn', 'val () = lstbefitmlst_restore_type(lsbis)\n//\nval loc_else = d2e_then', 'val loc_else = d2e_then'),
 ('dn', 'val () = the_d2varenv_push_lam (lin1)', 'val () = the_d2varenv_push_lam (lin)'),
 ('dn', 'val () = the_pfmanenv_push_lam (lin1)', 'val () = the_pfmanenv_push_lam (lin)'),
 ('dn', 'val ((*void*)) = i2nvresstate_update (loc0, invres)\n//\nin\n  d3exp_if', 'in\n  d3exp_if'),
 ('pc', 'if flag > 0 then 1 else d2con_get_vwtp (d2c)', 'if flag > 0 then 0 else d2con_get_vwtp (d2c)'),
 ('pc', 'if flag_vwtp > 0 then pck := PCKlincon', 'if flag_vwtp > 1 then pck := PCKlincon'),
 ('pc', 'if eq_s2cst_s2cst (s2c, s2c1) then flag := 0', 'if eq_s2cst_s2cst (s2c, s2c1) then flag := 1'),
 ('pc', 'val () = if err > 0 then {', 'val () = if err > 1 then {'),
 ('pc', 'd2var_set_finknd (d2v, d2vfin_D2VFINsome (s2e))', 'd2var_set_finknd (d2v, d2vfin_D2VFINnone ())'),
 ('pc', 's2var_make_srt (s2rt_addr)', 's2var_make_srt (s2rt_int)'),
 ('pc', 'val () = trans3_env_add_svar (s2v) // adding svar', 'val () = ()'),
 ('pc', '  val () = $SOL.s2exp_hypequal_solve (loc0, s2e_res, s2e)\n', '  val () = ()\n'),
 ('pc', 'else if flag > 0 then let\n    var serr: int = 0', 'else if flag > 1 then let\n    var serr: int = 0'),
 ('pc', 'if (flag < 0) then let', 'if (flag < ~1) then let'),
]
CC = 'patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I%s' % ST
MODS = open(os.path.join(ST, 'test', 'g2mods.txt')).read().split()
def sh(cmd, cwd):
    return subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
res = []
for i, (k, old, new) in enumerate(MUT):
    if only and i not in only: continue
    f = os.path.join(ST, M[k] + '.dats')
    real = os.path.realpath(f)
    src = open(real).read()
    if src.count(old) != 1:
        print('%2d: SKIP (the text occurs %d times) %s' % (i, src.count(old), old[:50].replace('\n', ' '))); continue
    if os.path.islink(f): os.unlink(f)
    open(f, 'w').write(src.replace(old, new))
    try:
        r = sh('%s -c -o mut_%s_dats.o %s' % (CC, M[k], f), os.path.join(ST, 'test', 'obj'))
        if r.returncode != 0:
            print('%2d: COMPILE ERROR %s' % (i, r.stderr.decode()[:300])); continue
        objs = ' '.join(('obj/mut_%s_dats.o' if m == M[k] else 'obj/%s_dats.o') % m for m in MODS)
        r = sh('%s -o g2dump_mut %s obj/pats_error_sats.o obj/g2dump.o obj/g2case_[0-9][0-9].o -lgmp' % (CC, objs), os.path.join(ST, 'test'))
        if r.returncode != 0:
            print('%2d: LINK ERROR %s' % (i, r.stderr.decode()[:300])); continue
        r = sh('./g2dump_mut', os.path.join(ST, 'test'))
        same = (r.stdout == REF[0] and r.stderr == REF[1] and r.returncode == REF[2])
        if same:   # the process that ends
            r = sh('CG_ERRTEST=1 ./g2dump_mut', os.path.join(ST, 'test'))
            same = (r.stdout == REFX[0] and filt(r.stderr) == filt(REFX[1]) and r.returncode == REFX[2])
        print('%2d: %s  [%s] %s' % (i, 'SURVIVED' if same else 'detected', k, old[:60].replace('\n', ' ')))
        sys.stdout.flush()
        res.append(not same)
    finally:
        os.unlink(f)
        os.symlink(real, f)
print('detected %d of %d' % (sum(res), len(res)))
