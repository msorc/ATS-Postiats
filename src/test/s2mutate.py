#!/usr/bin/env python3
# usage: python3 s2mutate.py REF.out REF.err   (the stdout and stderr of s2dump1, the ATS1 reference; see s2cmp.sh)
#
# Mutation test of the level-2 test: each mutation is a deliberate bug that is put in a ported module (the file is restored afterwards),
# s2dump is rebuilt and its output is compared with the ATS1 reference: every mutation must change the output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 ('pats_staexp2_sort.dats', 'the arguments of the sorts of a function are not swapped (contravariance)',
  'if s2rtlst_ltmat(knd, s2ts2, s2ts1)', 'if s2rtlst_ltmat(knd, s2ts1, s2ts2)'),
 ('pats_staexp2_svar.dats', 'the order of the elements of a multiset',
  'if sgn > 0 then mknode (1, x0, p)', 'if sgn < 0 then mknode (1, x0, p)'),
 ('pats_avlmap.dats', 'the union forgets the right subtree',
  'val m = aux (lft (t2), m, cmp)\n      val m = avlmap_insert (m, key (t2), vl (t2), cmp)\n    in\n      aux (rgt (t2), m, cmp)',
  'val m = aux (lft (t2), m, cmp)\n      val m = avlmap_insert (m, key (t2), vl (t2), cmp)\n    in\n      m'),
 ('pats_staexp2_scst.dats', 'the superclasses are looked up in the parents',
  'if s2c1 = s2c2 then\n    true else auxlst (s2cst_get_supcls (s2c1), s2c2)', 'if s2c1 = s2c2 then\n    true else auxlst (s2cst_get_supcls (s2c2), s2c2)'),
 ('pats_staexp2.dats', 'the sum of two effects: the wrong operand',
  'case+ 0 of\n  | _ when s2eff_isnil (s2fe1) => s2fe2\n  | _ when s2eff_isnil (s2fe2) => s2fe1', 'case+ 0 of\n  | _ when s2eff_isnil (s2fe1) => s2fe2\n  | _ when s2eff_isnil (s2fe2) => s2fe2'),
 ('pats_staexp2_szexp.dats', 'the merge of two flat closures gives a proof size',
  '| ~S2ZEclo() => s2zexp_S2ZEclo() // are immovable', '| ~S2ZEclo() => s2zexp_S2ZEprf() // are immovable'),
 ('pats_staexp2_print.dats', 'a space in a printer',
  'prstr "S2Eexi("', 'prstr "S2Eexi ("'),
 ('pats_staexp2_util1.dats', 'the linearization of the sort names',
  'else if name = $SYM.symbol_TYPE then $SYM.symbol_VIEWTYPE', 'else if name = $SYM.symbol_TYPE then $SYM.symbol_VIEWT0YPE'),
 ('pats_staexp2_dcon.dats', 'the real arity counts the proofs',
  'if s2rt_is_prf (s2exp_srt (s2e)) then aux2 (i, s2es1) else aux2 (i+1, s2es1)', 'if s2rt_is_prf (s2exp_srt (s2e)) then aux2 (i+1, s2es1) else aux2 (i, s2es1)'),
 ('pats_staexp2_ctxt.dats', 'the context replacement returns the replaced part (the bug found by the first run)',
  'if flag > flag0 then s2exp_at (s2e, s2a) else s2e0', 'if flag > flag0 then s2exp_at (s2e, s2a) else s2e'),
 ('pats_namespace.dats', 'the local join appends in the wrong order',
  'glist_append<filenv> (ns, ns2)', 'glist_append<filenv> (ns2, ns)'),
 ('pats_staexp2_error.dats', 'the number of recorded errors',
  '#define MAXLEN 100', '#define MAXLEN 101'),
 ('pats_staexp2_util1.dats', 'the substitution does not copy the substitution under a binder',
  'val s2vs = stasub_extend_svarlst (sub1, s2vs)\n  val s2ps = s2explst_subst_flag (sub1, s2ps, flag)', 'val s2vs = stasub_extend_svarlst (sub1, s2vs)\n  val s2ps = s2explst_subst_flag (sub, s2ps, flag)'),
 ('pats_staexp2_skexp.dats', 'the contravariance of the arguments of a function kind',
  's2kexplst_ismat_exn (_arg2, _arg1) // contra-variant', 's2kexplst_ismat_exn (_arg1, _arg2) // contra-variant'),
 ('pats_staexp2_svvar.dats', 'the upper bounds are inserted as lower bounds',
  's2Var_set_ubs\n  (s2V, glist_cons(ub, s2Var_get_ubs(s2V)))', 's2Var_set_lbs\n  (s2V, glist_cons(ub, s2Var_get_lbs(s2V)))'),
 ('pats_staexp2_util2.dats', 'hnfize of an application: always rebuild',
  'if flag > flag0\n      then s2exp_app_srt(s2e0.s2exp_srt(), s2e_fun, s2es_arg)', 'if flag >= flag0\n      then s2exp_app_srt(s2e0.s2exp_srt(), s2e_fun, s2es_arg)'),
 ('pats_staexp2_util2.dats', 'syneq of integers inverted',
  '| ~S2Eint i2 => if i1 != i2 then false else true', '| ~S2Eint i2 => if i1 = i2 then false else true'),
 ('pats_staexp2_util2.dats', 'syneq with environments: the bound variables are paired the wrong way',
  'val ans = (if s2v2 = s2v20 then true else false): bool', 'val ans = (if s2v2 = s2v20 then false else true): bool'),
 ('pats_staexp2_util2.dats', 'the oddity of the effects (S2EFFadd) is "repaired"',
  'then s2eff_syneq(s2fe21, s2fe22) else false', 'then s2eff_syneq(s2fe12, s2fe22) else false'),
 ('pats_staexp2_util2.dats', 'prenex: existential instead of universal',
  'if knd = 0 then\n    s2exp_prenexize_work', 'if knd = 1 then\n    s2exp_prenexize_work'),
 ('pats_staexp2_util2.dats', 'topize: the linearity test inverted',
  'if s2exp_is_lin(s2e0) then false else true', 'if s2exp_is_lin(s2e0) then true else false'),
 ('pats_staexp2_util2.dats', 'the environment of a binder forgets the bound variables',
  'auxenv_loop (s2vs, list_vt_cons (s2v, env))', 'auxenv_loop (s2vs, env)'),
 ('pats_staexp2_util2.dats', 'the invar of an unchanged variable',
  'if flag <= flag0 then s2e0 else s2e', 'if flag < flag0 then s2e0 else s2e'),
 ('pats_staexp2_util2.dats', 'syneq with environments of the tops: the kind test inverted',
  'if knd1 = knd2 then\n      s2exp_syneq_env(env1, env2, s2e1, s2e2) else false', 'if knd1 != knd2 then\n      s2exp_syneq_env(env1, env2, s2e1, s2e2) else false'),
 ('pats_staexp2_util3.dats', 'the occurrence check counts the wrong way',
  'if iseq then (ans := ans + 1) else s2Vs := glist_cons(s2V, s2Vs)', 'if iseq then s2Vs := glist_cons(s2V, s2Vs) else (ans := ans + 1)'),
 ('pats_staexp2_util3.dats', 'isbot with a proposition',
  'if isnil\n      then (', 'if ~isnil\n      then ('),
 ('pats_staexp2_util3.dats', 'free variables: an unsolved variable is not given the error link',
  's2Var_set_link(s2V, gopt_some(s2exp_errexp(s2t)))', '()'),
 ('pats_stacst2.dats', 'the boolean constants swapped',
  'if b\n      then the_true_bool\n      else the_false_bool', 'if b\n      then the_false_bool\n      else the_true_bool'),
 ('pats_stacst2.dats', 'the effect exn is the effect ref',
  'else if s2cstref_equ_cst(the_effexn, s2c) then s2eff_effset(effset_exn)', 'else if s2cstref_equ_cst(the_effexn, s2c) then s2eff_effset(effset_ref)'),
 ('pats_stacst2.dats', 'the sum of boolean propositions is a product',
  's2exp_badd(s2p0, aux(s2p, s2ps))', 's2exp_bmul(s2p0, aux(s2p, s2ps))'),
 ('pats_stacst2.dats', 'a constant application is found only at the head',
  '| ~S2Eapp(s2e, _) => s2cstref_equ_exp(r, s2e)', '| ~S2Eapp(s2e, _) => false'),
 ('pats_staexp2_solve.dats', 'the top kinds of the equality',
  '(knd1 >= knd2)', '(knd1 > knd2)'),
 ('pats_staexp2_solve.dats', 'the top kinds of the subtyping',
  'knd1 < knd2\n      ) then (err := err + 1)', 'knd1 <= knd2\n      ) then (err := err + 1)'),
 ('pats_staexp2_solve.dats', 'the arguments of functions are covariant',
  's2explst_tyleq_solve_err(loc0, s2es2_arg, s2es1_arg, err) // contravariant!', 's2explst_tyleq_solve_err(loc0, s2es1_arg, s2es2_arg, err) // contravariant!'),
 ('pats_staexp2_solve.dats', 'the order of the variables of the hypothesis',
  'if sgn > 0 then\n      trans3_env_hypadd_bind(loc0, s2v1, s2f2)', 'if sgn < 0 then\n      trans3_env_hypadd_bind(loc0, s2v1, s2f2)'),
 ('pats_staexp2_solve.dats', 'equal labels',
  'compare(l1, l2) = 0', 'compare(l1, l2) >= 0'),
 ('pats_staexp2_solve.dats', 'abstract constructors: the check inverted',
  'if absconeq\n  then aux_solve', 'if ~absconeq\n  then aux_solve'),
 ('pats_staexp2_solve.dats', 'the effect sets: the subset reversed',
  'then effset_subset (un_S2EFFset (s2fe1), un_S2EFFset (s2fe2))', 'then effset_subset (un_S2EFFset (s2fe2), un_S2EFFset (s2fe1))'),
 ('pats_staexp2_solve.dats', 'different constants are equal',
  'if (s2c1 != s2c2) then (err := err + 1)', 'if (s2c1 = s2c2) then (err := err + 1)'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
def build():
    r = subprocess.run(['make', '-C', d, 's2dump', '-j8'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    o = open(os.environ.get('TMPDIR','/tmp') + '/s2mut.out', 'w'); e = open(os.environ.get('TMPDIR','/tmp') + '/s2mut.err', 'w')
    subprocess.run([os.path.join(d, 's2dump')], stdout=o, stderr=e, cwd=d)
    o.close(); e.close()
    return filecmp.cmp(os.environ.get('TMPDIR','/tmp') + '/s2mut.out', ref_out, shallow=False) and filecmp.cmp(os.environ.get('TMPDIR','/tmp') + '/s2mut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    if os.environ.get('MUTONLY') and os.environ['MUTONLY'] not in what: continue
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    bak = os.environ.get('TMPDIR','/tmp') + '/s2mut_backup_' + fn
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
    print('%-28s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
