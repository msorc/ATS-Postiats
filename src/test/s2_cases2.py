# the cases of slice 2 of the level-2 test (pats_staexp2_util2/util3/solve, pats_stacst2): imported by s2_cases.py (see there and PORTING.md,
# "Level 2, slice 2"). The families here use the machinery of s2_cases.Sc: restrict (acyclic bindings/links/definitions), twin (a structural
# copy, optionally with one node replaced), force (a root constructor).
import re
import s2_cases as C

SORTN = {'bool': 's2rt_bool', 'int': 's2rt_int', 'addr': 's2rt_addr', 'types': 's2rt_types', 'vt0ype': 's2rt_vt0ype', 'cls': 's2rt_cls', 'tkind': 's2rt_tkind',
         't0ype': 's2rt_t0ype', 'type': 's2rt_type', 'float': 's2rt_float', 'string': 's2rt_string', 'prop': 's2rt_prop', 'view': 's2rt_view', 'vtype': 's2rt_vtype',
         'eff': 's2rt_eff'}
def _p(name, args, res): return (name, args, res)
PERV = [_p('true_bool', [], 'bool'), _p('false_bool', [], 'bool'), _p('neg_bool', ['bool'], 'bool'), _p('add_bool_bool', ['bool'] * 2, 'bool'),
  _p('mul_bool_bool', ['bool'] * 2, 'bool'), _p('eq_bool_bool', ['bool'] * 2, 'bool'), _p('neq_bool_bool', ['bool'] * 2, 'bool'), _p('neg_int', ['int'], 'int')]
for n in 'add sub mul div ndiv idiv'.split(): PERV.append(_p(n + '_int_int', ['int'] * 2, 'int'))
for n in 'lt lte gt gte eq neq'.split(): PERV.append(_p(n + '_int_int', ['int'] * 2, 'bool'))
PERV += [_p('abs_int', ['int'], 'int'), _p('absrel_int_int', ['int'] * 2, 'bool'), _p('sgn_int', ['int'], 'int'), _p('sgnrel_int_int', ['int'] * 2, 'bool'),
  _p('max_int_int', ['int'] * 2, 'int'), _p('min_int_int', ['int'] * 2, 'int'), _p('maxrel_int_int_int', ['int'] * 3, 'bool'), _p('minrel_int_int_int', ['int'] * 3, 'bool'),
  _p('ndivrel_int_int_int', ['int'] * 3, 'bool'), _p('idivrel_int_int_int', ['int'] * 3, 'bool'),
  _p('ifint_bool_int_int', ['bool', 'int', 'int'], 'int'), _p('ifintrel_bool_int_int_int', ['bool', 'int', 'int', 'int'], 'bool'),
  _p('int_of_addr', ['addr'], 'int'), _p('addr_of_int', ['int'], 'addr'), _p('null_addr', [], 'addr')]
for n in 'lt lte gt gte eq neq'.split(): PERV.append(_p(n + '_addr_addr', ['addr'] * 2, 'bool'))
PERV += [_p('add_addr_int', ['addr', 'int'], 'addr'), _p('sub_addr_int', ['addr', 'int'], 'addr'), _p('sub_addr_addr', ['addr'] * 2, 'int'),
  _p('types_nil', [], 'types'), _p('types_cons', ['vt0ype', 'types'], 'types'), _p('lte_cls_cls', ['cls'] * 2, 'bool'), _p('gte_cls_cls', ['cls'] * 2, 'bool'),
  _p('lterel_cls_cls', ['cls', 'cls', 'bool'], 'bool'), _p('gterel_cls_cls', ['cls', 'cls', 'bool'], 'bool'), _p('atstkind_type', [], 'tkind'), _p('atstkind_t0ype', [], 'tkind'),
  _p('bool_t0ype', [], 't0ype'), _p('bool_bool_t0ype', ['bool'], 't0ype')]
for n in 'int uint lint ulint llint ullint size ssize'.split(): PERV.append(_p(n + '_kind', [], 'tkind'))
PERV += [_p('g0int_t0ype', ['tkind'], 't0ype'), _p('g1int_int_t0ype', ['tkind', 'int'], 't0ype'), _p('g0uint_t0ype', ['tkind'], 't0ype'), _p('g1uint_int_t0ype', ['tkind', 'int'], 't0ype')]
for n in ('char', 'schar', 'uchar'): PERV += [_p(n + '_t0ype', [], 't0ype'), _p(n + '_int_t0ype', ['int'], 't0ype')]
for n in 'float double ldouble'.split(): PERV.append(_p(n + '_kind', [], 'tkind'))
PERV += [_p('g0float_t0ype', ['tkind'], 't0ype'), _p('string_type', [], 'type'), _p('string_int_type', ['int'], 'type'), _p('literal_float', ['float'], 'type'),
  _p('literal_string', ['string'], 'type'), _p('ptr_type', [], 'type'), _p('ptr_addr_type', ['addr'], 'type'), _p('atsvoid_t0ype', [], 't0ype'), _p('unit_p', [], 'prop'),
  _p('unit_v', [], 'view'), _p('exception_vtype', [], 'vtype'), _p('arrpsz_vt0ype_int_vt0ype', ['vt0ype', 'int'], 'vt0ype'), _p('list_t0ype_int_type', ['t0ype', 'int'], 'type'),
  _p('list_vt0ype_int_vtype', ['vt0ype', 'int'], 'vtype'), _p('vbox_view_prop', ['view'], 'prop'), _p('ref_vt0ype_type', ['vt0ype'], 'type'),
  _p('lazy_t0ype_type', ['t0ype'], 'type'), _p('lazy_vt0ype_vtype', ['vt0ype'], 'vtype'), _p('sizeof_t0ype_int', ['t0ype'], 'int'),
  _p('at_vt0ype_addr_view', ['vt0ype', 'addr'], 'view'), _p('invar_prop_prop', ['prop'], 'prop'), _p('invar_view_view', ['view'], 'view'),
  _p('invar_t0ype_t0ype', ['t0ype'], 't0ype'), _p('invar_vt0ype_vt0ype', ['vt0ype'], 'vt0ype'), _p('vcopyenv_view_view', ['view'], 'view'),
  _p('vcopyenv_vt0ype_vt0ype', ['vt0ype'], 'vt0ype')]
for n in ('bottom_t0ype_uni', 'bottom_t0ype_exi', 'bottom_vt0ype_uni', 'bottom_vt0ype_exi'): PERV.append(_p(n, [], 't0ype' if 'vt0' not in n else 'vt0ype'))
for n in 'int bool uint size ssize'.split(): PERV.append(_p('atstype_' + n, [], 't0ype'))
for n in 'nil all ntm exn ref wrt'.split(): PERV.append(_p('eff' + n, [], 'eff'))

VALN = {'unit_p': 'unit_prop', 'unit_v': 'unit_view'}
def valn(n): return VALN.get(n, n)

def sortexp(args, res):
    if not args: return SORTN[res]
    return 'K_S2RTfun (%s, %s)' % ('LC_s2rtlst (' + ', LC_s2rtlst ('.join(SORTN[a] for a in args[:1]) + ''.join(
        ', LC_s2rtlst (%s' % SORTN[a] for a in args[1:]) + ', LN_s2rtlst ()' + ')' * len(args), SORTN[res])

def perv_cst(sc, name, args, res, k):
    srt = sortexp(args, res)
    if args:
        argsrtss = 'LC_syms2rtlstlst (%s, LN_syms2rtlstlst ())' % sc.lst('syms2rtlst', ['K_syms2rt (mksym (%d), %s)' % (i, SORTN[a]) for i, a in enumerate(args)])
    else:
        argsrtss = 'LN_syms2rtlstlst ()'
    return sc.val('s2cst_make (mksymname ("%s"), mkloc (%d), mkfil (0), %s, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), %s, ON_s2expopt ())'
                  % (name, k % 20, srt, argsrtss), 's2cst')

def fam_setup(sc, k):
    """the pervasive static constants of pats_stacst2.dats (the table of the test double of trans2_env, the first use of the [the_xxx] fixes the constant), their definitions"""
    sc.do('t_penv_clear ()')
    cs = {}
    for i, (name, args, res) in enumerate(PERV):
        c = perv_cst(sc, name, args, res, i)
        cs[name] = c
        sc.do('t_penv_add (mksymname ("%s"), K_S2ITMcst (LC_s2cstlst (%s, LN_s2cstlst ())))' % (name, c))
    v = sc.new('s2var')
    sc.do('t_penv_add (mksymname ("zz_var"), K_S2ITMvar (%s))' % v)
    sc.say('-- stacst2_initialize')
    sc.do('stacst2_initialize ()')
    for name in ('sizeof_t0ype_int', 'at_vt0ype_addr_view', 'invar_prop_prop', 'invar_view_view', 'invar_t0ype_t0ype', 'invar_vt0ype_vt0ype'):
        sc.do('chk_s2cst (%s)' % cs[name])
    finish_cells(sc)

def finish_cells(sc):
    C.finish(sc)

# ------------------------------------------------------------------------------------------------------------------------------------------------
def twin(sc, gen, mutate=None, restrict2=None):
    """gen() twice from the same state of the random generator: a structural copy (mutate: the number of the node of the second tree that is replaced)"""
    st = sc.R.getstate(); n0 = sc.nodecnt
    sc.mutate_at = None
    a = gen()
    sc.R.setstate(st); sc.nodecnt = n0
    sc.mutate_at = (n0 + mutate) if mutate else None
    saved = dict(sc.restrict)
    if restrict2: sc.restrict.update(restrict2)
    b = gen()
    sc.restrict = saved
    sc.mutate_at = None
    return a, b

def force(sc, cname, d):
    sc.forced = cname
    return sc.s2exp(d)

S2E_CONS = ['S2Eint', 'S2Eintinf', 'S2Efloat', 'S2Estring', 'S2Ecst', 'S2Eextype', 'S2Eextkind', 'S2Evar', 'S2EVar', 'S2Ehole', 'S2Edatcontyp', 'S2Edatconptr', 'S2Eat', 'S2Esizeof',
            'S2Eeff', 'S2Eeqeq', 'S2Eproj', 'S2Eapp', 'S2Elam', 'S2Efun', 'S2Emetfun', 'S2Emetdec', 'S2Etop', 'S2Ewithout', 'S2Etyarr', 'S2Etyrec', 'S2Einvar', 'S2Eexi', 'S2Euni',
            'S2Erefarg', 'S2Evararg', 'S2Ewthtype', 'S2Eerrexp']

def acyclic_world(sc, nv=4, nV=3, nc=3):
    """variables (bound in the test double of trans3_env), existential variables (with links) and constants (with definitions) such that the
    random trees (restricted to the earlier ones) give no cycle of bindings/links/definitions"""
    R = sc.R
    sc.restrict = {}
    sc.nolink = False
    vs = [sc.new('s2var') for _ in range(nv)]
    Vs = [sc.new('s2Var') for _ in range(nV)]
    cs = [sc.new('s2cst') for _ in range(nc)] + [sc.new_s2cst(fun=True) for _ in range(2)]
    sc.do('t_bind_clear ()')
    for i, v in enumerate(vs):
        if R.random() < 0.7:
            sc.restrict = {'s2var': vs[:i], 's2Var': Vs[:1] if False else [], 's2cst': cs}
            if i == 0: sc.restrict['s2var'] = []
            e = sc.gv('s2exp', 2)
            sc.do('t_bind_add (%s, %s)' % (v, e))
    sc.restrict = {}
    for i, V in enumerate(Vs):
        if R.random() < 0.7:
            sc.restrict = {'s2var': vs, 's2Var': Vs[:i] if i else [], 's2cst': cs}
            if i == 0: sc.restrict['s2Var'] = []
            sc.do('s2Var_set_link (%s, OS_s2expopt (%s))' % (V, sc.gv('s2exp', 2)))
    sc.restrict = {}
    # the definitions: of the first constants only (the later ones may use them)
    for i, c in enumerate(cs[:3]):
        if R.random() < 0.6:
            sc.restrict = {'s2var': vs, 's2Var': Vs, 's2cst': cs[:i] if i else []}
            if i == 0: sc.restrict['s2cst'] = []
            sc.do('s2cst_set_def (%s, OS_s2expopt (%s))' % (c, sc.gv('s2exp', 2)))
    sc.restrict = {'s2var': vs, 's2Var': Vs, 's2cst': cs}
    return vs, Vs, cs

# ------------------------------------------------------------------------------------------------------------------------------------------------
def fam_hnf(sc, k):
    """pats_staexp2_util2.dats: the head normal forms (every constructor, links, bindings, definitions, beta-redexes, topization, invariants)"""
    R = sc.R
    L = lambda a, n: sc.gv(a, n)
    vs, Vs, cs = acyclic_world(sc)
    sc.varbias = 0.3
    sc.say('-- hnfize of every constructor')
    for cname in S2E_CONS:
        e = sc.val(force(sc, cname, 3), 's2exp')
        sc.dd('s2exp', e)
        h = sc.val('s2exp_hnfize (%s)' % e, 's2exp')
        sc.dd('s2exp', h)
        sc.call('s2exp_refeq', [e, h], 'bool')
        sc.dd('s2exp', 's2hnf2exp (s2exp2hnf (%s))' % e)
        sc.dd('s2exp', 's2exp_linkrem (%s)' % e)
        sc.dd('s2exp', 's2exp_mhnfize (%s)' % e)
        sc.dd('s2exp', 's2exp_topize_0 (%s)' % e)
        sc.dd('s2exp', 's2exp_topize_1 (%s)' % e)
        sc.dd('s2exp', 's2exp_topize (%d, %s)' % (R.choice([0, 1]), e))
        sc.call('s2exp_is_lin2', [e], 'bool')
    sc.say('-- beta redexes, heads')
    for _ in range(4):
        body = sc.val(L('s2exp', 2), 's2exp')
        ps = [sc.handle('s2var'), sc.handle('s2var')]
        lam = sc.val('s2exp_lam_srt (%s, %s, %s)' % (sc.sort(1), sc.lst('s2varlst', ps[:R.choice([1, 2])]), body), 's2exp')
        args = sc.lst('s2explst', [L('s2exp', 1) for _ in range(R.choice([0, 1, 2, 3]))])
        app = sc.val('s2exp_app_srt (%s, %s, %s)' % (sc.sort(1), lam, args), 's2exp')
        sc.dd('s2exp', app); sc.dd('s2exp', 's2exp_hnfize (%s)' % app); sc.dd('s2exp', 's2exp_mhnfize (%s)' % app)
        # the head is a variable bound to a lambda, or an existential variable with a link
        fv = sc.new('s2var')
        sc.do('t_bind_add (%s, %s)' % (fv, lam))
        app2 = sc.val('s2exp_app_srt (%s, s2exp_var (%s), %s)' % (sc.sort(1), fv, args), 's2exp')
        sc.dd('s2exp', 's2exp_hnfize (%s)' % app2)
        V = sc.handle('s2Var')
        app3 = sc.val('s2exp_app_srt (%s, s2exp_Var (%s), %s)' % (sc.sort(1), V, args), 's2exp')
        sc.dd('s2exp', 's2exp_hnfize (%s)' % app3)
    sc.say('-- lists')
    for _ in range(3):
        es = sc.val(L('s2explst', 3)); ess = sc.val(L('s2explstlst', 2)); eo = sc.val(L('s2expopt', 3))
        sc.dd('s2explst', 's2explst_hnfize (%s)' % es)
        sc.dd('s2expopt', 's2expopt_hnfize (%s)' % eo)
        sc.dd('s2explst', 's2explst_mhnfize (%s)' % es)
        sc.dd('s2explstlst', 's2explstlst_mhnfize (%s)' % ess)
        sc.dd('s2expopt', 's2expopt_hnfize (ON_s2expopt ())')
        sc.dd('s2explst', 's2explst_hnfize (LN_s2explst ())')
    sc.say('-- s2eff_hnfize')
    effs = ['s2eff_nil', 's2eff_all', 's2eff_effset (mkeffset (3))', 's2eff_var (%s)' % sc.handle('s2var'), 's2eff_exp (%s)' % L('s2exp', 2),
            'K_S2EFFadd (s2eff_nil, s2eff_all)']
    for n in ('effnil', 'effall', 'effntm', 'effexn', 'effref', 'effwrt'):
        effs.append('s2eff_exp (s2exp_cst (s2cstref_get_cst (the_%s)))' % n)
    effs.append('s2eff_exp (s2exp_Var (%s))' % sc.handle('s2Var'))
    effs.append('s2eff_exp (s2exp_var (%s))' % sc.handle('s2var'))
    effs.append('s2eff_exp (K_s2exp (s2rt_eff, K_S2Eeff (s2eff_all)))')
    effs.append('s2eff_exp (K_s2exp (s2rt_eff, K_S2Eint (1)))')
    for e in effs: sc.dd('s2eff', 's2eff_hnfize (%s)' % e)
    C.finish(sc)

def fam_topize(sc, k):
    """s2exp_topize on the kinds of expressions that it distinguishes (proofs, boxed, flat records, arrays, linear)"""
    R = sc.R
    vs, Vs, cs = acyclic_world(sc)
    pr = lambda s: 'K_s2exp (%s, K_S2Eint (%d))' % (s, R.randint(0, 5))
    ex = []
    for s in ('s2rt_prop', 's2rt_view', 's2rt_type', 's2rt_t0ype', 's2rt_vtype', 's2rt_vt0ype', 's2rt_int', 's2rt_bool'):
        ex.append(pr(s))
    T = lambda s, node: 'K_s2exp (%s, %s)' % (s, node)
    flds = lambda *xs: sc.lst('labs2explst', ['K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, x) for i, x in enumerate(xs)])
    for kind in ('K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt1 (mkstamp (0))', 'K_TYRECKINDflt_ext ("t")'):
        ex.append(T('s2rt_t0ype', 'K_S2Etyrec (%s, %d, %s)' % (kind, R.choice([0, 1]), flds(pr('s2rt_t0ype'), pr('s2rt_vt0ype'), pr('s2rt_prop')))))
        ex.append(T('s2rt_vt0ype', 'K_S2Etyrec (%s, 0, %s)' % (kind, flds(pr('s2rt_vt0ype')))))
    ex.append(T('s2rt_t0ype', 'K_S2Etyarr (%s, %s)' % (pr('s2rt_t0ype'), sc.lst('s2explst', [pr('s2rt_int')]))))
    ex.append(T('s2rt_vt0ype', 'K_S2Etyarr (%s, %s)' % (pr('s2rt_vt0ype'), sc.lst('s2explst', [pr('s2rt_int'), pr('s2rt_int')]))))
    ex.append(T('s2rt_t0ype', 'K_S2Etop (0, %s)' % pr('s2rt_t0ype')))
    ex.append(T('s2rt_t0ype', 'K_S2Etop (1, %s)' % pr('s2rt_vt0ype')))
    ex.append(T('s2rt_vt0ype', 'K_S2Etop (1, K_s2exp (s2rt_vt0ype, K_S2Etop (0, %s)))' % pr('s2rt_vt0ype')))
    ex.append(T('s2rt_view', 'K_S2Etop (0, %s)' % pr('s2rt_view')))
    ex.append(T('s2rt_type', 'K_S2Einvar (%s)' % pr('s2rt_type')))
    Vf = sc.val('s2Var_make_srt (mkloc (2), s2rt_type)', 's2Var'); Vl = sc.val('s2Var_make_srt (mkloc (3), s2rt_type)', 's2Var')
    sc.do('s2Var_set_link (%s, OS_s2expopt (K_s2exp (s2rt_type, K_S2Eint (9))))' % Vl)
    ex.append(T('s2rt_type', 'K_S2Einvar (K_s2exp (s2rt_type, K_S2EVar (%s)))' % Vf))
    ex.append(T('s2rt_type', 'K_S2Einvar (K_s2exp (s2rt_type, K_S2EVar (%s)))' % Vl))
    ex.append(T('s2rt_type', 'K_S2Einvar (K_s2exp (s2rt_type, K_S2Evar (%s)))' % vs[0]))
    ex.append(T('s2rt_type', 'K_S2Einvar (K_s2exp (s2rt_type, K_S2Etop (0, %s)))' % pr('s2rt_t0ype')))
    for e in ex:
        if 'K_S2Einvar' in e and e.count('K_S2EVar') == 1:
            x = sc.val(e, 's2exp'); sc.call('s2exp_refeq', [x, 's2exp_hnfize (%s)' % x], 'bool')
    for e in ex:
        x = sc.val(e, 's2exp')
        sc.dd('s2exp', x)
        for f in ('s2exp_topize_0 (%s)', 's2exp_topize_1 (%s)', 's2exp_topize (0, %s)', 's2exp_topize (1, %s)', 's2exp_hnfize (%s)', 's2exp_mhnfize (%s)'):
            sc.dd('s2exp', f % x)
        sc.call('s2exp_is_lin2', [x], 'bool')
    C.finish(sc)

# ------------------------------------------------------------------------------------------------------------------------------------------------
def syneq_calls(sc, a, b, vs1=None, vs2=None):
    sc.call('s2exp_syneq', [a, b], 'bool')
    sc.call('s2hnf_syneq', ['s2exp2hnf_cast (%s)' % a, 's2exp2hnf_cast (%s)' % b], 'bool')
    sc.call('s2exp_syneq2', [a, b], 'bool')
    sc.call('s2hnf_syneq2', ['s2exp2hnf_cast (%s)' % a, 's2exp2hnf_cast (%s)' % b], 'bool')
    sc.call('s2explst_syneq', [sc.lst('s2explst', [a, b]), sc.lst('s2explst', [b, a])], 'bool')
    sc.call('s2explst_syneq', [sc.lst('s2explst', [a, b]), sc.lst('s2explst', [a, a])], 'bool')
    sc.call('s2explst_syneq2', [sc.lst('s2explst', [a, b]), sc.lst('s2explst', [b, a])], 'bool')
    sc.call('s2explst_syneq2', [sc.lst('s2explst', [a]), sc.lst('s2explst', [a, b])], 'bool')
    sc.call('t_exp_syneq_env', [vs1 or 'LN_s2varlst ()', vs2 or 'LN_s2varlst ()', a, b], 'bool')
    sc.call('t_hnf_syneq_env', [vs1 or 'LN_s2varlst ()', vs2 or 'LN_s2varlst ()', a, b], 'bool')
    sc.call('t_lst_syneq_env', [vs1 or 'LN_s2varlst ()', vs2 or 'LN_s2varlst ()', sc.lst('s2explst', [a, b]), sc.lst('s2explst', [a, b])], 'bool')
    sc.call('t_lstlst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explstlst', [sc.lst('s2explst', [a]), sc.lst('s2explst', [b])]), sc.lst('s2explstlst', [sc.lst('s2explst', [a]), sc.lst('s2explst', [b])])], 'bool')

def fam_syneq(sc, k):
    """s2exp_syneq (up to the head normal form) and the version with bound variables: every constructor, equal copies and copies with a node replaced"""
    R = sc.R
    vs, Vs, cs = acyclic_world(sc)
    sc.say('-- syneq')
    for ci, cname in enumerate(S2E_CONS):
        if ci % 3 != k % 3: continue
        for mut in (None, 1, 2):
            a, b = twin(sc, lambda: force(sc, cname, 3), mut)
            ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
            syneq_calls(sc, ea, eb)
    sc.say('-- random pairs')
    pool = []
    for _ in range(4):
        pool.append(sc.val(sc.gv('s2exp', 2), 's2exp'))
    for i in range(len(pool)):
        for j in range(len(pool)):
            sc.call('s2exp_syneq', [pool[i], pool[j]], 'bool'); sc.call('s2exp_syneq2', [pool[i], pool[j]], 'bool')
    sc.say('-- bound variables')
    for _ in range(2):
        v1 = sc.new('s2var'); v2 = sc.new('s2var'); w1 = sc.new('s2var'); w2 = sc.new('s2var')
        # the same body with the variables renamed: alpha-equivalent
        def body():
            return sc.s2exp(2)
        sc.restrict = {'s2var': [v1, v2]}
        a, b = twin(sc, body, None, {'s2var': [w1, w2]})
        a2, c = twin(sc, body, 2, {'s2var': [w1, w2]})
        sc.restrict = {}
        ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp'); ec = sc.val(c, 's2exp')
        L1 = sc.lst('s2varlst', [v1, v2]); L2 = sc.lst('s2varlst', [w1, w2]); L3 = sc.lst('s2varlst', [w2, w1])
        for binder in ('lam', 'exi', 'uni'):
            def mk(vl, body):
                if binder == 'lam': return 's2exp_lam_srt (s2rt_t0ype, %s, %s)' % (vl, body)
                return 's2exp_%s (%s, LN_s2explst (), %s)' % (binder, vl, body)
            x = sc.val(mk(L1, ea), 's2exp'); y = sc.val(mk(L2, eb), 's2exp'); z = sc.val(mk(L3, eb), 's2exp'); u = sc.val(mk(L2, ec), 's2exp')
            sc.call('s2exp_syneq2', [x, y], 'bool'); sc.call('s2exp_syneq2', [x, z], 'bool'); sc.call('s2exp_syneq2', [x, u], 'bool'); sc.call('s2exp_syneq2', [x, x], 'bool')
            sc.call('s2hnf_syneq2', ['s2exp2hnf_cast (%s)' % x, 's2exp2hnf_cast (%s)' % y], 'bool')
            sc.call('s2exp_syneq', [x, y], 'bool')
        sc.call('t_exp_syneq_env', [L1, L2, ea, eb], 'bool'); sc.call('t_exp_syneq_env', [L1, L3, ea, eb], 'bool'); sc.call('t_exp_syneq_env', [L1, L1, ea, ea], 'bool')
        sc.call('t_exp_syneq_env', ['LN_s2varlst ()', L2, ea, eb], 'bool')
        for x, y in ((v1, w1), (v1, w2), (v2, w2), (v1, v1), (v2, v1), (w1, w1)):
            for e1, e2 in ((L1, L2), (L1, L3), (L1, L1), ('LN_s2varlst ()', 'LN_s2varlst ()'), (L1, 'LN_s2varlst ()'), ('LN_s2varlst ()', L2),
                           (sc.lst('s2varlst', [v1]), sc.lst('s2varlst', [w2, w1])), (sc.lst('s2varlst', [v2, v1, w1]), sc.lst('s2varlst', [w2, w1, v2]))):
                sc.call('t_var_syneq_env', [e1, e2, x, y], 'bool')
    # the printers of the lists of the dumps use the generated dumpers only
    C.finish(sc)

# ------------------------------------------------------------------------------------------------------------------------------------------------
def fam_prenex(sc, k):
    """s2exp_absuni and s2exp_opnexi, s2exp_freevars, s2Var_occurcheck_s2exp, s2exp_isbot, s2exp_fun_isbot (util2, util3)"""
    R = sc.R
    vs, Vs, cs = acyclic_world(sc)
    sc.varbias = 0.4
    def binder(knd, body, nv=None):
        n = nv if nv is not None else R.choice([0, 1, 2])
        bv = [sc.new('s2var') for _ in range(n)]
        ps = [sc.val('K_s2exp (s2rt_bool, K_S2Evar (%s))' % x) for x in bv[:1]] if bv and R.random() < 0.5 else []
        return sc.val('s2exp_%s (%s, %s, %s)' % (knd, sc.lst('s2varlst', bv), sc.lst('s2explst', ps), body), 's2exp')
    sc.say('-- prenex forms')
    for _ in range(8):
        inner = sc.val(sc.gv('s2exp', 2), 's2exp')
        shapes = []
        shapes.append(binder('uni', binder('uni', inner)))
        shapes.append(binder('exi', binder('exi', inner)))
        shapes.append(binder('uni', binder('exi', binder('uni', inner))))
        shapes.append(sc.val('s2exp_at (%s, %s)' % (binder('exi', inner), binder('exi', sc.gv('s2exp', 1))), 's2exp'))
        shapes.append(sc.val('s2exp_at (%s, %s)' % (binder('uni', inner), binder('uni', sc.gv('s2exp', 1))), 's2exp'))
        shapes.append(binder('exi', sc.val('s2exp_at (%s, %s)' % (binder('exi', inner), sc.gv('s2exp', 1)), 's2exp')))
        shapes.append(binder('uni', sc.val('s2exp_at (%s, %s)' % (binder('exi', inner), sc.gv('s2exp', 1)), 's2exp')))
        shapes.append(sc.val('s2exp_tyrec (0, 0, %s)' % sc.lst('labs2explst', ['K_labs2exp (mklab (0), ON_stringopt (), %s)' % binder('exi', inner)]), 's2exp'))
        shapes.append(inner)
        for e in shapes:
            sc.dd('s2exp', e)
            sc.do('{ val @(e, vs, ps) = s2exp_absuni (%s) val () = (dd_s2exp e; dd_ps " "; dd_listvt_s2var vs; dd_ps " "; dd_listvt_s2exp ps; dd_nl ()) }' % e)
            sc.do('{ val @(e, vs, ps) = s2exp_opnexi (%s) val () = (dd_s2exp e; dd_ps " "; dd_listvt_s2var vs; dd_ps " "; dd_listvt_s2exp ps; dd_nl ()) }' % e)
    sc.say('-- free variables and the occurrence check')
    for _ in range(10):
        sc.nolink = False
        e = sc.val(sc.gv('s2exp', 3), 's2exp')
        sc.do('(dd_listvt_s2var (s2varset_vt_listize_free (s2exp_freevars (%s))); dd_nl ())' % e)
        for V in Vs[:2] + [sc.new('s2Var')]:
            sc.do('{ val @(n, cs, vs, Vs) = s2Var_occurcheck_s2exp (%s, %s) val () = (dd_int n; dd_ps " "; dd_s2cstlst cs; dd_ps " "; dd_s2varlst vs; dd_ps " "; dd_s2Varlst Vs; dd_nl ()) }' % (V, e))
    # the sets of existential variables of the constants and the variables
    V = sc.new('s2Var'); V2 = sc.new('s2Var')
    sc.do('s2cst_set_sVarset (%s, s2Varset_add (s2Varset_nil (), %s))' % (cs[0], V))
    sc.do('s2var_set_sVarset (%s, s2Varset_add (s2Varset_nil (), %s))' % (vs[0], V2))
    sc.do('s2Var_add_sVarlst (%s, %s)' % (V, V2))
    for e in ('s2exp_cst (%s)' % cs[0], 's2exp_var (%s)' % vs[0], 's2exp_app_srt (s2rt_t0ype, s2exp_cst (%s), %s)' % (cs[0], sc.lst('s2explst', ['s2exp_var (%s)' % vs[0]])),
              's2exp_Var (%s)' % V, 's2exp_Var (%s)' % V2):
        for X in (V, V2):
            sc.do('{ val @(n, cs, vs, Vs) = s2Var_occurcheck_s2exp (%s, %s) val () = (dd_int n; dd_ps " "; dd_s2cstlst cs; dd_ps " "; dd_s2varlst vs; dd_ps " "; dd_s2Varlst Vs; dd_nl ()) }' % (X, e))
    sc.say('-- isbot')
    for _ in range(3):
        v = sc.new('s2var'); w = sc.new('s2var')
        body = 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % v
        other = 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % w
        T = lambda node: 'K_s2exp (s2rt_t0ype, %s)' % node
        cands = [T('K_S2Euni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [v]), body)),
                 T('K_S2Euni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [w, v]), body)),
                 T('K_S2Euni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [w]), body)),
                 T('K_S2Euni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [v]), other)),
                 T('K_S2Euni (%s, %s, %s)' % (sc.lst('s2varlst', [v]), sc.lst('s2explst', [other]), body)),
                 T('K_S2Euni (%s, LN_s2explst (), K_s2exp (s2rt_t0ype, K_S2Eint (1)))' % sc.lst('s2varlst', [v])),
                 T('K_S2Eexi (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [v]), body)), body, 'K_s2exp (s2rt_int, K_S2Eint (1))']
        for c in list(cands):
            cands.append(T('K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (sc.lst('s2explst', [other]), c)))
            cands.append(T('K_S2Euni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [w]), c)))
            cands.append(T('K_S2Emetfun (ON_stampopt (), LN_s2explst (), %s)' % c))
        for c in cands:
            e = sc.val(c, 's2exp')
            sc.call('s2exp_isbot', [e], 'bool'); sc.call('s2exp_fun_isbot', [e], 'bool')
    C.finish(sc)

# ------------------------------------------------------------------------------------------------------------------------------------------------
STAERRDUMP = '{ var n: int val xs = the_staerrlst_get (n) val () = (dd_int n; dd_nl (); dd_listvt_staerr xs; dd_nl ()) }'

def solve_world(sc):
    """constants with a function sort, an arity of 4 in argsrtss with variances, a relation of superclasses, abstract constants; trees without variables"""
    R = sc.R
    cs = []
    for i in range(4):
        n = R.choice([1, 2, 3])
        srts = ['K_S2RTfun (%s, s2rt_t0ype)' % sc.lst('s2rtlst', ['s2rt_t0ype'] * n)]
        argsrts = sc.lst('syms2rtlst', ['K_syms2rt (mksym (%d), %s)' % (j, R.choice(['s2rt_t0ype', 's2rt_t0ype_pos', 's2rt_t0ype_neg', 's2rt_type_pos', 's2rt_type_neg', 's2rt_vt0ype_neg', 's2rt_prop_pos'])) for j in range(4)])
        isabs = R.choice(['ON_s2expoptopt ()', 'OS_s2expoptopt (ON_s2expopt ())'])
        c = sc.val('s2cst_make (%s, %s, mkfil (0), %s, %s, %s, false, ON_s2expopt (), ON_d2conpairopt (), LC_syms2rtlstlst (%s, LN_syms2rtlstlst ()), ON_s2expopt ())' % (
            sc.leaf('symbol'), sc.leaf('location'), srts[0], isabs, R.choice(['true', 'false']), argsrts), 's2cst')
        cs.append(c)
    sc.do('s2cst_add_sup (%s, %s)' % (cs[1], cs[0])); sc.do('s2cst_add_sup (%s, %s)' % (cs[2], cs[1])); sc.do('s2cst_add_supcls (%s, s2exp_cst (%s))' % (cs[3], cs[0]))
    ds = [sc.new('d2con') for _ in range(2)]
    vs = [sc.new('s2var') for _ in range(3)]
    sc.restrict = {'s2cst': cs, 's2var': vs, 'd2con': ds}
    sc.nolink = True
    sc.varbias = 0.2
    sc.do('t_bind_clear ()')
    return cs, vs

LOCS = ['mkloc (1)', 'mkloc (4)', 'mkloc (9)']

def solve_dump(sc):
    # (the_staerrlst_get and prerr_the_staerrlst both empty the list)
    if sc.R.random() < 0.5: sc.do(STAERRDUMP)
    else: sc.do('prerr_the_staerrlst ()')
    sc.do('the_staerrlst_clear ()')

def solve_pair(sc, a, b, both=True):
    loc = sc.R.choice(LOCS)
    sc.call('s2exp_equal_solve', [loc, a, b], 'int'); solve_dump(sc)
    sc.call('s2hnf_equal_solve', [loc, 's2exp2hnf_cast (%s)' % a, 's2exp2hnf_cast (%s)' % b], 'int'); solve_dump(sc)
    sc.call('s2exp_tyleq_solve', [loc, a, b], 'int'); solve_dump(sc)
    sc.call('s2hnf_tyleq_solve', [loc, 's2exp2hnf_cast (%s)' % a, 's2exp2hnf_cast (%s)' % b], 'int'); solve_dump(sc)
    if both:
        sc.call('s2exp_tyleq_solve', [loc, b, a], 'int'); solve_dump(sc)
    sc.do('{ var err: int = 0 val () = s2exp_equal_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc, a, b)); solve_dump(sc)
    sc.do('{ var err: int = 0 val () = s2exp_tyleq_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc, a, b)); solve_dump(sc)
    sc.do('{ var err: int = 0 val () = s2hnf_equal_solve_err (%s, s2exp2hnf_cast (%s), s2exp2hnf_cast (%s), err) val () = (dd_int err; dd_nl ()) }' % (loc, a, b)); solve_dump(sc)
    sc.do('{ var err: int = 0 val () = s2hnf_tyleq_solve_err (%s, s2exp2hnf_cast (%s), s2exp2hnf_cast (%s), err) val () = (dd_int err; dd_nl ()) }' % (loc, a, b)); solve_dump(sc)

def fam_solve(sc, k):
    """pats_staexp2_solve.dats: the equality and the subtyping (twins: success paths; a node replaced: failures at depth; random pairs), the primitive checks, the effects,
    the quantifiers (instantiation by the test double), existential variables"""
    R = sc.R
    L = lambda a, n: sc.gv(a, n)
    sc.say('-- primitive checks')
    sc.do('the_staerrlst_clear ()')
    loc = lambda: R.choice(LOCS)
    for a, b in ((0, 0), (0, 1)):
        sc.do('{ var err: int = 0 val () = label_equal_solve_err (%s, mklab (%d), mklab (%d), err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
        sc.do('{ var err: int = 0 val () = stamp_equal_solve_err (%s, mkstamp (%d), mkstamp (%d), err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
    sc.do('{ val s1 = mkstamp (0) val s2 = mkstamp (0) var err: int = 0 val () = stamp_equal_solve_err (%s, s1, s1, err) val () = stamp_equal_solve_err (%s, s1, s2, err) val () = (dd_int err; dd_nl ()) }' % (loc(), loc()))
    for i in range(4):
        for j in range(4):
            if (i + j) % 2 == 0 or i == j:
                sc.call('funclo_equal_solve', [loc(), 'mkfunclo (%d)' % i, 'mkfunclo (%d)' % j], 'int')
                sc.do('{ var err: int = 0 val () = funclo_equal_solve_err (%s, mkfunclo (%d), mkfunclo (%d), err) val () = (dd_int err; dd_nl ()) }' % (loc(), i, j))
    for a in (0, 1, 2):
        for b in (0, 1, 2):
            sc.do('{ var err: int = 0 val () = clokind_equal_solve_err (%s, %d, %d, err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
            sc.call('linearity_equal_solve', [loc(), str(a), str(b)], 'int')
            sc.do('{ var err: int = 0 val () = linearity_equal_solve_err (%s, %d, %d, err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
            sc.call('pfarity_equal_solve', [loc(), str(a), str(b)], 'int')
            sc.do('{ var err: int = 0 val () = pfarity_equal_solve_err (%s, %d, %d, err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
            sc.do('{ var err: int = 0 val () = refval_equal_solve_err (%s, %d, %d, err) val () = (dd_int err; dd_nl ()) }' % (loc(), a, b))
    kinds = ['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt_ext ("nm")', 'K_TYRECKINDflt1 (mkstamp (0))']
    for kn in kinds:
        for b in (0, 1):
            sc.do('{ var err: int = 0 val () = boxity_equal_solve_err (%s, %d, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc(), b, kn))
        for kn2 in kinds:
            sc.do('{ var err: int = 0 val () = tyreckind_equal_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc(), kn, kn2))
    solve_dump(sc)
    sc.say('-- effects')
    effs = ['s2eff_nil', 's2eff_all', 's2eff_effset (mkeffset (3))', 's2eff_effset (mkeffset (2))', 's2eff_effset (mkeffset (0))', 's2eff_exp (%s)' % L('s2exp', 1),
            's2eff_exp (s2exp_cst (s2cstref_get_cst (the_effnil)))', 's2eff_exp (s2exp_cst (s2cstref_get_cst (the_effwrt)))', 's2eff_exp (s2exp_cst (s2cstref_get_cst (the_effwrt)))',
            'K_S2EFFadd (s2eff_nil, s2eff_all)', 's2eff_var (%s)' % sc.new('s2var'), 's2eff_exp (s2exp_Var (%s))' % sc.new('s2Var'),
            's2eff_exp (s2exp_Var (s2Var_make_srt (mkloc (2), s2rt_eff)))']
    for i, x in enumerate(effs):
        for j, y in enumerate(effs):
            if (i + 2 * j) % 3 == 0 or i == j or j >= len(effs) - 3:
                sc.call('s2eff_subeq_solve', [loc(), x, y], 'int')
                sc.do('{ var err: int = 0 val () = s2eff_subeq_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc(), x, y))
                solve_dump(sc)
    sc.say('-- the pairs')
    cs, vs = solve_world(sc)
    for _ in range(2):
        a, b = twin(sc, lambda: sc.s2exp(3))
        ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
        solve_pair(sc, ea, eb)
        for mut in (1, 2, 3, 4):
            a, b = twin(sc, lambda: sc.s2exp(3), mut)
            ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
            solve_pair(sc, ea, eb)
    for _ in range(2):
        ea = sc.val(sc.gv('s2exp', 3), 's2exp'); eb = sc.val(sc.gv('s2exp', 3), 's2exp')
        solve_pair(sc, ea, eb)
    sc.say('-- the lists')
    for _ in range(2):
        for ty, gen in (('s2explst', lambda: sc.gv('s2explst', 2)), ('labs2explst', lambda: sc.gv('labs2explst', 2)), ('wths2explst', lambda: sc.gv('wths2explst', 2))):
            for mut in (None, 2):
                x, y = twin(sc, gen, mut)
                ex = sc.val(x); ey = sc.val(y)
                for kind in ('equal', 'tyleq'):
                    sc.do('{ var err: int = 0 val () = %s_%s_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (ty, kind, loc(), ex, ey)); solve_dump(sc)
                    sc.do('{ var err: int = 0 val () = %s_%s_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (ty, kind, loc(), ey, ex)); solve_dump(sc)
            ex = sc.val(gen()); ey = sc.val(gen())
            for kind in ('equal', 'tyleq'):
                sc.do('{ var err: int = 0 val () = %s_%s_solve_err (%s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (ty, kind, loc(), ex, ey)); solve_dump(sc)
        ars = sc.lst('syms2rtlst', ['K_syms2rt (mksym (%d), %s)' % (j, R.choice(['s2rt_t0ype', 's2rt_t0ype_pos', 's2rt_t0ype_neg'])) for j in range(4)])
        x = sc.val(sc.gv('s2explst', 2)); y = sc.val(sc.gv('s2explst', 2))
        sc.do('{ var err: int = 0 val () = s2explst_tyleq_solve_argsrtlst_err (%s, %s, %s, %s, err) val () = (dd_int err; dd_nl ()) }' % (loc(), ars, x, y)); solve_dump(sc)
    sc.say('-- every constructor on the left')
    for ci, cname in enumerate(S2E_CONS):
        if cname in ('S2EVar', 'S2Ehole') or ci % 4 != k % 4: continue
        a, b = twin(sc, lambda: force(sc, cname, 2))
        ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
        solve_pair(sc, ea, eb, both=False)
        a, b = twin(sc, lambda: force(sc, cname, 2), 2)
        ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
        solve_pair(sc, ea, eb, both=False)
    sc.say('-- applications of constants, variances')
    T = lambda s, node: 'K_s2exp (%s, %s)' % (s, node)
    for _ in range(2):
        c1 = R.choice(cs); c2 = R.choice(cs)
        n1 = R.choice([1, 2, 3]); n2 = n1 if R.random() < 0.7 else R.choice([1, 2, 3])
        args1 = [sc.s2exp(1) for _ in range(n1)]
        args2 = [R.choice(args1) if R.random() < 0.5 and i < len(args1) else sc.s2exp(1) for i in range(n2)]
        e1 = sc.val(T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', args1))), 's2exp')
        e2 = sc.val(T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c2, sc.lst('s2explst', args2))), 's2exp')
        solve_pair(sc, e1, e2)
        e3 = sc.val('s2exp_cst (%s)' % c2); solve_pair(sc, e1, e3); solve_pair(sc, e3, e1, both=False)
        e4 = sc.val(T('s2rt_t0ype', 'K_S2Eapp (%s, %s)' % (sc.gv('s2exp', 1), sc.lst('s2explst', args2))), 's2exp')
        solve_pair(sc, e1, e4); solve_pair(sc, e4, e1, both=False)
    sc.say('-- quantifiers')
    for _ in range(1):
        a1 = sc.new('s2var'); a2 = sc.new('s2var')
        body = lambda x: 's2exp_fun_srt (s2rt_type, mkfunclo (0), 0, s2eff_nil, 0, %s, s2exp_var (%s))' % (sc.lst('s2explst', ['s2exp_var (%s)' % x]), x)
        u = sc.val('s2exp_uni (%s, LN_s2explst (), %s)' % (sc.lst('s2varlst', [a1]), body(a1)), 's2exp')
        x = sc.val('s2exp_exi (%s, %s, %s)' % (sc.lst('s2varlst', [a2]), sc.lst('s2explst', ['s2exp_var (%s)' % a2]), body(a2)), 's2exp')
        t1 = sc.val(sc.s2exp(2), 's2exp')
        funt = sc.val('s2exp_fun_srt (s2rt_type, mkfunclo (0), 0, s2eff_nil, 0, %s, %s)' % (sc.lst('s2explst', [t1]), t1), 's2exp')
        for p, q in ((u, funt), (funt, u), (x, funt), (funt, x), (u, x), (x, u), (u, u), (x, x)):
            solve_pair(sc, p, q, both=False)
    sc.say('-- existential variables')
    for _ in range(2):
        sc.nolink = True
        t = sc.val(sc.gv('s2exp', 2), 's2exp')
        srt = R.choice(['s2rt_t0ype', 's2rt_type', 's2rt_prop', 's2rt_int', 's2rt_vt0ype'])
        V = sc.val('s2Var_make_srt (%s, %s)' % (sc.leaf('location'), srt), 's2Var')
        W = sc.val('s2Var_make_srt (%s, %s)' % (sc.leaf('location'), srt), 's2Var')
        if R.random() < 0.5:
            sc.do('s2Var_lb_insert (mkloc (3), %s, %s)' % (V, sc.s2exp(1)))
            sc.do('s2Var_ub_insert (mkloc (5), %s, %s)' % (V, sc.s2exp(1)))
        for f in ('s2exp_equal_solve', 's2exp_tyleq_solve'):
            sc.call(f, [loc(), 's2exp_Var (%s)' % V, t], 'int'); solve_dump(sc)
            sc.dd('s2exp', 's2exp_Var (%s)' % V); sc.do('chk_s2Var (%s)' % V)
            sc.call(f, [loc(), t, 's2exp_Var (%s)' % W], 'int'); solve_dump(sc)
            sc.do('chk_s2Var (%s)' % W)
            sc.call(f, [loc(), 's2exp_Var (%s)' % V, 's2exp_Var (%s)' % V], 'int'); solve_dump(sc)
            sc.call(f, [loc(), 's2exp_Var (%s)' % V, 's2exp_Var (%s)' % W], 'int'); solve_dump(sc)
        # invar around a variable, a variable with a link
        sc.call('s2exp_tyleq_solve', [loc(), 'K_s2exp (%s, K_S2Einvar (s2exp_Var (%s)))' % (srt, V), t], 'int'); solve_dump(sc)
        sc.call('s2exp_tyleq_solve', [loc(), t, 'K_s2exp (%s, K_S2Einvar (s2exp_Var (%s)))' % (srt, W)], 'int'); solve_dump(sc)
        sc.call('s2exp_equal_solve', [loc(), t, 'K_s2exp (%s, K_S2Einvar (%s))' % (srt, t)], 'int'); solve_dump(sc)
        # an occurrence of the variable in the term: an equation instead of a solution
        sc.call('s2exp_equal_solve', [loc(), 's2exp_Var (%s)' % V, 's2exp_app_srt (%s, s2exp_cst (%s), %s)' % (srt, R.choice(cs), sc.lst('s2explst', ['s2exp_Var (%s)' % V]))], 'int'); solve_dump(sc)
        sc.call('s2exp_equal_solve', [loc(), 's2exp_app_srt (%s, s2exp_cst (%s), %s)' % (srt, R.choice(cs), sc.lst('s2explst', ['s2exp_Var (%s)' % W])), 's2exp_Var (%s)' % W], 'int'); solve_dump(sc)
    sc.restrict = {}; sc.nolink = False
    C.finish(sc)

def fam_hypeq(sc, k):
    """s2exp_hypequal_solve and friends: abstract constructors, variables (ordered), functions"""
    R = sc.R
    sc.say('-- hypequal')
    cs, vs = solve_world(sc)
    for _ in range(14):
        a, b = twin(sc, lambda: sc.s2exp(3), R.choice([None, None, 1, 2, 3]))
        ea = sc.val(a, 's2exp'); eb = sc.val(b, 's2exp')
        loc = R.choice(LOCS)
        sc.do('s2exp_hypequal_solve (%s, %s, %s)' % (loc, ea, eb))
        sc.do('s2hnf_hypequal_solve (%s, s2exp2hnf_cast (%s), s2exp2hnf_cast (%s))' % (loc, ea, eb))
        sc.do('s2explst_hypequal_solve (%s, %s, %s)' % (loc, sc.lst('s2explst', [ea, eb]), sc.lst('s2explst', [ea, eb])))
        sc.do('s2explst_hypequal_solve (%s, %s, %s)' % (loc, sc.lst('s2explst', [ea]), sc.lst('s2explst', [ea, eb])))
        sc.do('s2explst_hypequal_solve (%s, %s, %s)' % (loc, sc.lst('s2explst', [ea, eb]), sc.lst('s2explst', [eb])))
        sc.do('s2explst_hypequal_solve (%s, LN_s2explst (), LN_s2explst ())' % loc)
        sc.do('s2explst_hypequal_solve (%s, LN_s2explst (), %s)' % (loc, sc.lst('s2explst', [ea])))
    sc.say('-- variables, abstract applications, functions')
    T = lambda s, node: 'K_s2exp (%s, %s)' % (s, node)
    for _ in range(8):
        v, w = R.sample(vs, 2)
        t = sc.val(sc.gv('s2exp', 2), 's2exp')
        loc = R.choice(LOCS)
        pairs = [('s2exp_var (%s)' % v, 's2exp_var (%s)' % w), ('s2exp_var (%s)' % w, 's2exp_var (%s)' % v), ('s2exp_var (%s)' % v, 's2exp_var (%s)' % v),
                 ('s2exp_var (%s)' % v, t), (t, 's2exp_var (%s)' % w), ('s2exp_var (%s)' % v, T('s2rt_t0ype', 'K_S2Eapp (s2exp_var (%s), %s)' % (v, sc.lst('s2explst', [t])))),
                 (T('s2rt_t0ype', 'K_S2Eapp (s2exp_var (%s), %s)' % (w, sc.lst('s2explst', [t]))), 's2exp_var (%s)' % w)]
        c1, c2 = R.choice(cs), R.choice(cs)
        a1 = sc.s2exp(1); a2 = sc.s2exp(1)
        pairs += [(T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', [a1]))), T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', [a1])))),
                  (T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', [a1]))), T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c2, sc.lst('s2explst', [a2])))),
                  (T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', [a1, a2]))), T('s2rt_t0ype', 'K_S2Eapp (s2exp_cst (%s), %s)' % (c1, sc.lst('s2explst', [a1])))),
                  ('s2exp_cst (%s)' % c1, 's2exp_cst (%s)' % c1), ('s2exp_cst (%s)' % c1, 's2exp_cst (%s)' % c2),
                  (T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, %s, s2exp_var (%s))' % (sc.lst('s2explst', ['s2exp_var (%s)' % v]), v)),
                   T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, %s, s2exp_var (%s))' % (sc.lst('s2explst', ['s2exp_var (%s)' % w]), w))),
                  (T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (sc.lst('s2explst', [a1, a2]), a1)), T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (sc.lst('s2explst', [a2]), a1))),
                  (T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, LN_s2explst (), %s)' % a1), 's2exp_cst (%s)' % c1),
                  ('s2exp_cst (%s)' % c1, T('s2rt_type', 'K_S2Efun (FUNCLOfun (), 0, s2eff_nil, 0, LN_s2explst (), %s)' % a1))]
        for x, y in pairs:
            sc.do('s2exp_hypequal_solve (%s, %s, %s)' % (loc, x, y))
    sc.restrict = {}; sc.nolink = False
    C.finish(sc)

# ------------------------------------------------------------------------------------------------------------------------------------------------
def fam_stacst(sc, k):
    """pats_stacst2.dats: every function (the constants are the ones of the setup)"""
    R = sc.R
    L = lambda a, n: sc.gv(a, n)
    sc.restrict = {}
    sc.nolink = False
    sc.say('-- the references')
    names = [n for n, a, r in PERV]
    for n in names:
        sc.do('(dd_s2cst (s2cstref_get_cst (the_%s)); dd_nl ())' % valn(n))
    cst = sc.new('s2cst'); c2 = sc.val('s2cstref_get_cst (the_%s)' % valn(R.choice(names)), 's2cst')
    for n in [valn(x) for x in R.sample(names, 12)]:
        sc.call('s2cstref_equ_cst', ['the_%s' % n, cst], 'bool'); sc.call('s2cstref_equ_cst', ['the_%s' % n, 's2cstref_get_cst (the_%s)' % n], 'bool')
        sc.call('s2cstref_equ_exp', ['the_%s' % n, 's2exp_cst (s2cstref_get_cst (the_%s))' % n], 'bool')
        sc.call('s2cstref_equ_exp', ['the_%s' % n, 's2exp_app_srt (s2rt_t0ype, s2exp_cst (s2cstref_get_cst (the_%s)), %s)' % (n, L('s2explst', 1))], 'bool')
        sc.call('s2cstref_equ_exp', ['the_%s' % n, L('s2exp', 2)], 'bool')
    # names that are not constants of the pervasive environment
    sc.do('{ val r = s2cstref_make ("no_such_constant") val () = (dd_bool (s2cstref_equ_cst (r, %s)); dd_bool (s2cstref_equ_exp (r, s2exp_cst (%s))); dd_nl ()) }' % (cst, cst))
    sc.do('{ val r = s2cstref_make ("zz_var") val () = (dd_bool (s2cstref_equ_cst (r, %s)); dd_bool (s2cstref_equ_cst (r, %s)); dd_nl ()) }' % (cst, cst))
    sc.do('{ val r = s2cstref_make ("true_bool") val () = (dd_bool (s2cstref_equ_cst (r, %s)); dd_s2cst (s2cstref_get_cst (r)); dd_bool (s2cstref_equ_cst (r, s2cstref_get_cst (the_true_bool))); dd_nl ()) }' % cst)
    sc.say('-- booleans')
    for b in ('true', 'false'):
        sc.dd('s2exp', 's2exp_bool (%s)' % b); sc.dd('s2exp', 's2exp_bool_bool_t0ype (%s)' % b)
    sc.dd('s2exp', 's2exp_bool_t0ype ()')
    inds = [sc.val(L('s2exp', 1), 's2exp') for _ in range(3)]
    for i in inds:
        sc.dd('s2exp', 's2exp_bool_index_t0ype (%s)' % i)
        sc.do('dd_optvt_s2exp (un_s2exp_bool_index_t0ype (s2exp2hnf_cast (s2exp_bool_index_t0ype (%s))))' % i)
        sc.do('dd_optvt_s2exp (un_s2exp_bool_index_t0ype (s2exp2hnf_cast (%s)))' % i)
    sc.do('dd_optvt_s2exp (un_s2exp_bool_index_t0ype (s2exp2hnf_cast (s2exp_bool_bool_t0ype (true))))')
    a, b = inds[0], inds[1]
    for f in ('s2exp_agtz (%s)' % a, 's2exp_bneg (%s)' % a, 's2exp_badd (%s, %s)' % (a, b), 's2exp_bmul (%s, %s)' % (a, b), 's2exp_ineg (%s)' % a, 's2exp_intlt (%s, %s)' % (a, b),
              's2exp_intgt (%s, %s)' % (a, b), 's2exp_intlte (%s, %s)' % (a, b), 's2exp_intgte (%s, %s)' % (a, b), 's2exp_intneq (%s, %s)' % (a, b), 's2exp_igtez (%s)' % a):
        sc.dd('s2exp', f)
    for n in range(4):
        sc.dd('s2exp', 's2explst_badd (%s)' % sc.lst('s2explst', inds[:n] + ['s2exp_bool (true)'] * max(0, n - 3)))
        sc.dd('s2exp', 's2explst_bmul (%s)' % sc.lst('s2explst', inds[:n]))
    sc.dd('s2exp', 's2explst_badd (LN_s2explst ())'); sc.dd('s2exp', 's2explst_bmul (LN_s2explst ())')
    sc.say('-- integers')
    for e in ('s2exp_int (3)', 's2exp_int (~1)', 's2exp_intinf (mkintinf (5))', 's2exp_intinf (mkintinf (0))', 'K_s2exp (s2rt_int, K_S2Estring ("s"))', 'K_s2exp (s2rt_int, K_S2Efloat ("1.5"))',
              'K_s2exp (s2rt_int, K_S2Evar (%s))' % sc.new('s2var'), L('s2exp', 2)):
        sc.do('dd_optvt_int (un_s2exp_intconst (%s))' % e)
    for f in ('s2exp_int_t0ype ()', 's2exp_uint_t0ype ()', 's2exp_lint_t0ype ()', 's2exp_ulint_t0ype ()', 's2exp_llint_t0ype ()', 's2exp_ullint_t0ype ()',
              's2exp_int_int_t0ype (3)', 's2exp_int_intinf_t0ype (mkintinf (7))', 's2exp_uint_int_t0ype (4)', 's2exp_uint_intinf_t0ype (mkintinf (8))',
              's2exp_lint_intinf_t0ype (mkintinf (9))', 's2exp_ulint_intinf_t0ype (mkintinf (10))', 's2exp_llint_intinf_t0ype (mkintinf (11))', 's2exp_ullint_intinf_t0ype (mkintinf (12))',
              's2exp_int_index_t0ype (%s)' % a, 's2exp_uint_index_t0ype (%s)' % b,
              's2exp_g0int_kind_t0ype (s2exp_cst (s2cstref_get_cst (the_lint_kind)))', 's2exp_g1int_kind_index_t0ype (s2exp_cst (s2cstref_get_cst (the_int_kind)), %s)' % a,
              's2exp_g0uint_kind_t0ype (s2exp_cst (s2cstref_get_cst (the_ulint_kind)))', 's2exp_g1uint_kind_index_t0ype (s2exp_cst (s2cstref_get_cst (the_uint_kind)), %s)' % b):
        sc.dd('s2exp', f)
    gs = ['s2exp_int_int_t0ype (3)', 's2exp_uint_int_t0ype (4)', 's2exp_int_index_t0ype (%s)' % a, 's2exp_g1uint_kind_index_t0ype (s2exp_cst (s2cstref_get_cst (the_size_kind)), %s)' % b,
          's2exp_int_t0ype ()', 's2exp_char_int_t0ype (5)', L('s2exp', 2)]
    for g in gs:
        for f in ('un_s2exp_g1int_index_t0ype', 'un_s2exp_g1uint_index_t0ype', 'un_s2exp_g1size_index_t0ype'):
            sc.do('dd_optvt_s2exp (%s (s2exp2hnf_cast (%s)))' % (f, g))
    sc.say('-- chars, floats, strings, pointers')
    for f in ('s2exp_char_t0ype ()', 's2exp_char_int_t0ype (65)', 's2exp_char_index_t0ype (%s)' % a, 's2exp_schar_t0ype ()', 's2exp_schar_int_t0ype (3)', 's2exp_uchar_t0ype ()',
              's2exp_uchar_int_t0ype (4)', 's2exp_float_t0ype ()', 's2exp_double_t0ype ()', 's2exp_ldouble_t0ype ()', 's2exp_string_type ()', 's2exp_string_int_type (mksize (5))',
              's2exp_string_index_type (%s)' % a, 's2exp_literal_float ("2.5")', 's2exp_literal_string ("lit")', 's2exp_ptr_type ()', 's2exp_ptr_addr_type (%s)' % a,
              's2exp_void_t0ype ()', 's2exp_unit_prop ()', 's2exp_unit_view ()', 's2exp_exception_vtype ()', 's2exp_arrpsz_vt0ype_int_vt0ype (%s, 4)' % a,
              's2exp_list_vt0ype_int_vtype (%s, 2)' % b, 's2exp_vbox_view_prop (%s)' % a, 's2exp_ref_vt0ype_type (%s)' % b, 's2exp_lazy_vt0ype_vtype (%s)' % a,
              's2exp_bottom_t0ype_uni ()', 's2exp_bottom_t0ype_exi ()', 's2exp_bottom_vt0ype_uni ()', 's2exp_bottom_vt0ype_exi ()', 's2exp_types_nil ()', 's2exp_types_cons (%s, %s)' % (a, b),
              's2exp_types_list (%s)' % sc.lst('s2explst', [a, b]), 's2exp_types_list (LN_s2explst ())', 's2exp_vcopyenv_v (%s)' % a, 's2exp_vcopyenv_vt (%s)' % b):
        sc.dd('s2exp', f)
    unq = [('un_s2exp_char_index_t0ype', ['s2exp_char_int_t0ype (65)', 's2exp_char_index_t0ype (%s)' % a, 's2exp_char_t0ype ()', L('s2exp', 2)]),
           ('un_s2exp_ptr_addr_type', ['s2exp_ptr_addr_type (%s)' % a, 's2exp_ptr_type ()', L('s2exp', 2)]),
           ('un_s2exp_vbox_view_prop', ['s2exp_vbox_view_prop (%s)' % a, 's2exp_unit_view ()', L('s2exp', 2)]),
           ('un_s2exp_ref_vt0ype_type', ['s2exp_ref_vt0ype_type (%s)' % a, 's2exp_ptr_type ()', L('s2exp', 2)]),
           ('un_s2exp_lazy_t0ype_type', ['s2exp_cstapp (s2cstref_get_cst (the_lazy_t0ype_type), %s)' % sc.lst('s2explst', [a]), 's2exp_ptr_type ()', L('s2exp', 2)]),
           ('un_s2exp_lazy_vt0ype_vtype', ['s2exp_lazy_vt0ype_vtype (%s)' % a, 's2exp_cstapp (s2cstref_get_cst (the_lazy_t0ype_type), %s)' % sc.lst('s2explst', [a]), L('s2exp', 2)])]
    for f, es in unq:
        for e in es: sc.do('dd_optvt_s2exp (%s (s2exp2hnf_cast (%s)))' % (f, e))
    # the matches of the hnf of the definitions of constants
    sc.say('-- s2eff_hnfize, the instantiation of the invariants and sizeof')
    for n in ('sizeof_t0ype_int', 'at_vt0ype_addr_view', 'invar_prop_prop', 'invar_view_view', 'invar_t0ype_t0ype', 'invar_vt0ype_vt0ype'):
        e = sc.val('s2exp_cstapp (s2cstref_get_cst (the_%s), %s)' % (n, sc.lst('s2explst', [a] if n != 'at_vt0ype_addr_view' else [a, b])), 's2exp')
        sc.dd('s2exp', e); sc.dd('s2exp', 's2exp_hnfize (%s)' % e)
    C.finish(sc)

def fam_stacst2(sc, k):
    """the abstract and the non-function cases of the constructors of pats_stacst2.dats are the ones above; here the other direction: stacst2 functions on random trees
    (the un_ functions of every kind of expression)"""
    R = sc.R
    sc.restrict = {}
    for _ in range(12):
        e = sc.val(sc.gv('s2exp', 3), 's2exp')
        for f in ('un_s2exp_bool_index_t0ype', 'un_s2exp_g1int_index_t0ype', 'un_s2exp_g1uint_index_t0ype', 'un_s2exp_g1size_index_t0ype', 'un_s2exp_char_index_t0ype',
                  'un_s2exp_ptr_addr_type', 'un_s2exp_vbox_view_prop', 'un_s2exp_ref_vt0ype_type', 'un_s2exp_lazy_t0ype_type', 'un_s2exp_lazy_vt0ype_vtype'):
            sc.do('dd_optvt_s2exp (%s (s2exp2hnf_cast (%s)))' % (f, e))
        sc.do('dd_optvt_int (un_s2exp_intconst (%s))' % e)
    C.finish(sc)


def fam_target2(sc, k):
    """the paths of util2/util3/solve that the random trees reach rarely: names of extypes, labels of projections, kinds and fields of records,
    lists of different lengths, with-types in the traversals, a variable whose zexp is a variable, occurrences of a fresh variable"""
    R = sc.R
    vs, Vs, cs = acyclic_world(sc)
    sc.restrict = {}
    T = lambda node, s='s2rt_t0ype': 'K_s2exp (%s, %s)' % (s, node)
    I = lambda n: T('K_S2Eint (%d)' % n, 's2rt_int')
    fld = lambda i, e, lab=None: 'K_labs2exp (%s, ON_stringopt (), %s)' % (lab or 'mklab (%d)' % i, e)
    exs = []
    # extype / extkind: names and lists
    for K in ('S2Eextype', 'S2Eextkind'):
        for nm in ('"a"', '"b"'):
            for ess in ([[I(1)]], [[I(1), I(2)]], [], [[I(1)], [I(2)]], [[I(1)], [I(3)]]):
                exs.append(T('K_%s (%s, %s)' % (K, nm, sc.lst('s2explstlst', [sc.lst('s2explst', l) for l in ess]))))
    # projections
    for ls in ([('lab', 0)], [('ind', 1)], [('lab', 1)], [('lab', 0), ('ind', 2)], [('ind', 2), ('lab', 0)], []):
        l = sc.lst('s2lablst', ['K_S2LABlab (mklab (%d))' % n if kd == 'lab' else 'K_S2LABind (%s)' % sc.lst('s2explst', [I(n)]) for kd, n in ls])
        exs.append(T('K_S2Eproj (%s, %s, %s)' % (I(1), I(2), l)))
    # records: kinds, npf, fields
    kinds = ['K_TYRECKINDbox ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDbox_lin ()']
    for kd in kinds:
        for npf in (0, 1):
            for fs in ([fld(0, I(1))], [fld(0, I(1)), fld(1, I(2))], [fld(1, I(1))], [fld(0, I(2))], []):
                exs.append(T('K_S2Etyrec (%s, %d, %s)' % (kd, npf, sc.lst('labs2explst', fs))))
    # arrays, functions, tops, invars, refargs, varargs, withouts, eqeqs, sizeofs, datacons
    d1 = sc.new('d2con'); d2 = sc.new('d2con')
    for e in [T('K_S2Etyarr (%s, %s)' % (I(1), sc.lst('s2explst', l))) for l in ([I(1)], [I(2)], [I(1), I(2)], [])]:
        exs.append(e)
    for fc in ('FUNCLOfun ()', 'FUNCLOclo (0)', 'FUNCLOclo (1)'):
        for lin in (0, 1):
            for npf in (0, 1):
                exs.append(T('K_S2Efun (%s, %d, s2eff_nil, %d, %s, %s)' % (fc, lin, npf, sc.lst('s2explst', [I(1)]), I(2))))
    for ef in ('s2eff_nil', 's2eff_all', 's2eff_exp (%s)' % I(1), 'K_S2EFFadd (s2eff_nil, s2eff_all)', 'K_S2EFFadd (s2eff_nil, s2eff_nil)'):
        exs.append(T('K_S2Efun (FUNCLOfun (), 0, %s, 0, LN_s2explst (), %s)' % (ef, I(2))))
    for e in (I(1), I(2)):
        for k2 in (0, 1):
            exs += [T('K_S2Etop (%d, %s)' % (k2, e)), T('K_S2Erefarg (%d, %s)' % (k2, e))]
        exs += [T('K_S2Einvar (%s)' % e), T('K_S2Evararg (%s)' % e), T('K_S2Ewithout (%s)' % e), T('K_S2Esizeof (%s)' % e), T('K_S2Eeqeq (%s, %s)' % (e, I(1))), T('K_S2Eat (%s, %s)' % (e, I(1)))]
    for dc in (d1, d2):
        exs += [T('K_S2Edatcontyp (%s, %s)' % (dc, sc.lst('s2explst', [I(1)]))), T('K_S2Edatconptr (%s, %s, %s)' % (dc, I(1), sc.lst('s2explst', [I(1)])))]
    exs += [T('K_S2Eintinf (mkintinf (3))'), T('K_S2Eint (3)'), T('K_S2Eintinf (mkintinf (4))'), T('K_S2Eint (4)'), T('K_S2Eint (5)', 's2rt_int'), T('K_S2Eintinf (mkintinf (5))')]
    for i in range(len(exs)):
        for j in range(len(exs)):
            if (i * 7 + j * 3 + k) % 47 == 0 or (i == j and (i + k) % 3 == 0) or (abs(i - j) == 1 and (i + k) % 4 == 0):
                a = sc.val(exs[i], 's2exp'); b = sc.val(exs[j], 's2exp')
                sc.call('s2exp_syneq', [a, b], 'bool'); sc.call('s2exp_syneq2', [a, b], 'bool')
    # the environments with the same shapes (a binder around, so that the bodies are compared with the environment)
    v = sc.new('s2var'); w = sc.new('s2var')
    for i in range(len(exs)):
        for j in range(len(exs)):
            if (i * 7 + j * 3 + k) % 127 == 0 or (i == j and (i + k) % 7 == 0):
                a = sc.val(exs[i], 's2exp'); b = sc.val(exs[j], 's2exp')
                sc.call('t_exp_syneq_env', [sc.lst('s2varlst', [v]), sc.lst('s2varlst', [w]), a, b], 'bool')
                sc.call('t_lst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explst', [a, a]), sc.lst('s2explst', [b, b])], 'bool')
                sc.call('t_lst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explst', [a, a]), sc.lst('s2explst', [a])], 'bool')
                sc.call('t_lst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explst', [a]), sc.lst('s2explst', [a, b])], 'bool')
                sc.call('t_lstlst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explstlst', [sc.lst('s2explst', [a])]), sc.lst('s2explstlst', [sc.lst('s2explst', [a]), sc.lst('s2explst', [b])])], 'bool')
                sc.call('t_lstlst_syneq_env', ['LN_s2varlst ()', 'LN_s2varlst ()', sc.lst('s2explstlst', [sc.lst('s2explst', [a]), sc.lst('s2explst', [b])]), sc.lst('s2explstlst', [sc.lst('s2explst', [a])])], 'bool')
                sc.call('s2explst_syneq', [sc.lst('s2explst', [a, b]), sc.lst('s2explst', [a])], 'bool'); sc.call('s2explst_syneq', [sc.lst('s2explst', [a]), sc.lst('s2explst', [a, b])], 'bool')
    # with-types in the traversals of util3, and mhnfize of a variable whose szexp is a variable
    wv = sc.new('s2var')
    ws = ['K_WTHS2EXPLSTnil ()', 'K_WTHS2EXPLSTcons_invar (1, %s, K_WTHS2EXPLSTcons_trans (0, %s, K_WTHS2EXPLSTcons_none (K_WTHS2EXPLSTnil ())))' % (T('K_S2Evar (%s)' % wv), T('K_S2Evar (%s)' % v)),
          'K_WTHS2EXPLSTcons_none (K_WTHS2EXPLSTcons_invar (0, %s, K_WTHS2EXPLSTnil ()))' % I(1)]
    V = sc.new('s2Var')
    for wl in ws:
        e = sc.val(T('K_S2Ewthtype (%s, %s)' % (T('K_S2EVar (%s)' % V), wl)), 's2exp')
        sc.do('(dd_listvt_s2var (s2varset_vt_listize_free (s2exp_freevars (%s))); dd_nl ())' % e)
        sc.do('{ val @(n, cs, vs, Vs) = s2Var_occurcheck_s2exp (%s, %s) val () = (dd_int n; dd_ps " "; dd_s2cstlst cs; dd_ps " "; dd_s2varlst vs; dd_ps " "; dd_s2Varlst Vs; dd_nl ()) }' % (sc.new('s2Var'), e))
        sc.do('{ val @(n, cs, vs, Vs) = s2Var_occurcheck_s2exp (%s, %s) val () = (dd_int n; dd_ps " "; dd_s2cstlst cs; dd_ps " "; dd_s2varlst vs; dd_ps " "; dd_s2Varlst Vs; dd_nl ()) }' % (V, e))
    V1 = sc.new('s2Var')
    sc.do('s2Var_set_szexp (%s, K_S2ZEvar (%s))' % (V1, v))
    sc.dd('s2exp', 's2exp_mhnfize (s2exp_Var (%s))' % V1)
    sc.dd('s2exp', 's2exp_mhnfize (s2exp_Var (%s))' % sc.new('s2Var'))
    sc.do('s2Var_set_link (%s, OS_s2expopt (%s))' % (V1, I(4)))
    sc.dd('s2exp', 's2exp_mhnfize (s2exp_Var (%s))' % V1)
    # an occurrence of a fresh variable in a term (an equation instead of a solution)
    cs2, vs2 = solve_world(sc)
    for f in ('s2exp_equal_solve',):   # (tyleq has no occurs check: a cyclic solution of the zexp, S2-14, and the next merge loops)
        for srt in ('s2rt_t0ype', 's2rt_prop'):
            Vo = sc.val('s2Var_make_srt (mkloc (2), %s)' % srt, 's2Var'); Wo = sc.val('s2Var_make_srt (mkloc (3), %s)' % srt, 's2Var')
            sc.call(f, [R.choice(LOCS), 's2exp_Var (%s)' % Vo, 's2exp_app_srt (%s, s2exp_cst (%s), %s)' % (srt, cs2[0], sc.lst('s2explst', ['s2exp_Var (%s)' % Vo]))], 'int'); solve_dump(sc)
            sc.call(f, [R.choice(LOCS), 's2exp_app_srt (%s, s2exp_cst (%s), %s)' % (srt, cs2[1], sc.lst('s2explst', ['s2exp_Var (%s)' % Wo])), 's2exp_Var (%s)' % Wo], 'int'); solve_dump(sc)
            sc.call(f, [R.choice(LOCS), 'K_s2exp (%s, K_S2Einvar (s2exp_Var (%s)))' % (srt, Vo), 's2exp_Var (%s)' % Vo], 'int'); solve_dump(sc)
            sc.call(f, [R.choice(LOCS), 's2exp_Var (%s)' % Wo, 'K_s2exp (%s, K_S2Einvar (%s))' % (srt, I(3))], 'int'); solve_dump(sc)
    # an invar that is a variable on the right (tyleq), a top on the right with the kind 0 and a linear/non-linear left
    for kn in (0, 1):
        for lft in (T('K_S2Eint (1)'), 'K_s2exp (s2rt_vt0ype, K_S2Eint (1))', 'K_s2exp (s2rt_t0ype, K_S2Etop (0, K_s2exp (s2rt_t0ype, K_S2Eint (1))))'):
            for rt in (T('K_S2Etop (%d, %s)' % (kn, T('K_S2Eint (1)'))), T('K_S2Etop (%d, %s)' % (kn, T('K_S2Eint (2)')))):
                solve_pair(sc, sc.val(lft, 's2exp'), sc.val(rt, 's2exp'))
    sc.restrict = {}; sc.nolink = False
    C.finish(sc)

FAMILIES = [('hnf', fam_hnf, 4, {}), ('topize', fam_topize, 1, {}), ('syneq', fam_syneq, 6, {}), ('prenex', fam_prenex, 2, {}), ('solve', fam_solve, 6, {}), ('hypeq', fam_hypeq, 3, {}),
            ("target2", fam_target2, 0.5, {}), ('stacst', fam_stacst, 1, {}), ('stacst2', fam_stacst2, 1, {})]
SETUP = ('setup', fam_setup, 1, {})
