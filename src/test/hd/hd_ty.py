# the families of the cases of the type erasure (pats_typerase_*): called by hd_cases.py (see there and PORTING.md "Type erasure (typerase)")
#
# [tycells] makes the cells (constants of every kind of abstractness, variables, existential variables, data constructors) and the type exemplars: one
# s2exp for every case of the erasure of [pats_typerase_staexp.dats]; [P3], [D3], [DC] build the level-3 trees with the smart constructors of pats_dynexp3.sats
# on top of them (the trees that typerase supports, with the lists long enough for the proof arguments [npf] that they carry).
import re

ISABS_NONE = 'ON_s2expoptopt ()'
ISABS_NODEF = 'OS_s2expoptopt (ON_s2expopt ())'
def ISABS_DEF(e): return 'OS_s2expoptopt (OS_s2expopt (%s))' % e
SORT_F1 = 'K_S2RTfun (LC_s2rtlst (s2rt_t0ype, LN_s2rtlst ()), s2rt_t0ype)'
SORT_F2 = 'K_S2RTfun (LC_s2rtlst (s2rt_t0ype, LC_s2rtlst (s2rt_int, LN_s2rtlst ())), s2rt_type)'
SORT_F3 = 'K_S2RTfun (LC_s2rtlst (s2rt_tkind, LC_s2rtlst (s2rt_t0ype, LC_s2rtlst (s2rt_prop, LN_s2rtlst ()))), s2rt_vtype)'

def mkcst(sc, k, srt, isabs):
    return sc.val('s2cst_make (mksym (%d), mkloc (%d), mkfil (0), %s, %s, false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())' % (k, k, srt, isabs), 's2cst')

def tycells(sc):
    """creates the cells and the type exemplars; fills sc.tys (the types as handles), sc.tyn (name -> handle), sc.typrf (the types of proofs)"""
    R = sc.R
    for _ in range(4): sc.new('s2var')
    for _ in range(3): sc.new('s2cst')
    for _ in range(3): sc.new('d2var')
    c = {}
    c['A'] = mkcst(sc, 0, 's2rt_t0ype', ISABS_NONE)
    c['B'] = mkcst(sc, 1, 's2rt_type', ISABS_NONE)
    c['C'] = mkcst(sc, 2, 's2rt_vtype', ISABS_NONE)
    c['P'] = mkcst(sc, 3, 's2rt_prop', ISABS_NONE)
    c['V'] = mkcst(sc, 4, 's2rt_view', ISABS_NONE)
    c['K'] = mkcst(sc, 5, 's2rt_tkind', ISABS_NONE)
    c['F1'] = mkcst(sc, 6, SORT_F1, ISABS_NONE)
    c['F2'] = mkcst(sc, 7, SORT_F2, ISABS_NONE)
    c['F3'] = mkcst(sc, 8, SORT_F3, ISABS_NONE)
    c['I'] = mkcst(sc, 9, 's2rt_int', ISABS_NONE)
    c['aN'] = mkcst(sc, 10, 's2rt_t0ype', ISABS_NODEF)
    sA = sc.val('s2exp_cst (%s)' % c['A'], 's2exp')
    c['aD'] = mkcst(sc, 11, 's2rt_t0ype', ISABS_DEF(sA))
    sc.sA = sA
    sc.cst = c
    sv = sc.pool['s2var']
    ty = {}
    def T(name, expr):
        ty[name] = sc.val(expr, 's2exp')
        return ty[name]
    T('A', 's2exp_cst (%s)' % c['A']); T('B', 's2exp_cst (%s)' % c['B']); T('C', 's2exp_cst (%s)' % c['C'])
    T('P', 's2exp_cst (%s)' % c['P']); T('V', 's2exp_cst (%s)' % c['V']); T('K', 's2exp_cst (%s)' % c['K'])
    T('aN', 's2exp_cst (%s)' % c['aN']); T('aD', 's2exp_cst (%s)' % c['aD'])
    c['aDD'] = mkcst(sc, 12, 's2rt_t0ype', ISABS_DEF(ty['aD']))
    T('aDD', 's2exp_cst (%s)' % c['aDD'])
    fn = T('fn', 's2exp_fun_srt (s2rt_t0ype, FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (sc.lst('s2explst', [ty['A'], ty['B']]), ty['C']))
    c['aF'] = None
    # an abstract constant defined by a function type
    c['aD2'] = mkcst(sc, 13, 's2rt_t0ype', ISABS_DEF(fn))
    T('aD2', 's2exp_cst (%s)' % c['aD2'])
    # abstract constants of a function sort: a definition that is a lambda / not a lambda / none
    body = sc.val('s2exp_tyrec_srt (s2rt_t0ype, K_TYRECKINDflt0 (), 0, %s)' % sc.lst('labs2explst', ['K_labs2exp (mklab (0), ON_stringopt (), s2exp_var (%s))' % sv[0], 'K_labs2exp (mklab (1), ON_stringopt (), %s)' % ty['B']]), 's2exp')
    lam = sc.val('s2exp_lam_srt (%s, %s, %s)' % (SORT_F1, sc.lst('s2varlst', [sv[0]]), body), 's2exp')
    c['aF'] = mkcst(sc, 14, SORT_F1, ISABS_DEF(lam))
    c['aFN'] = mkcst(sc, 15, SORT_F2, ISABS_NODEF)
    c['aFD'] = mkcst(sc, 16, SORT_F1, ISABS_DEF('s2exp_cst (%s)' % c['F1']))
    c['aFL'] = mkcst(sc, 17, SORT_F2, ISABS_DEF(sc.val('s2exp_lam_srt (%s, %s, %s)' % (SORT_F2, sc.lst('s2varlst', [sv[0], sv[1]]), sc.val('s2exp_tytup (0, 0, %s)' % sc.lst('s2explst', ['s2exp_var (%s)' % sv[0], ty['A']]), 's2exp')), 's2exp')))
    # constants of a function sort that is itself abstract with the definition of an other constant
    c['aFF'] = mkcst(sc, 18, SORT_F1, ISABS_DEF('s2exp_cst (%s)' % c['aF']))
    sc.cst = c
    dcs = []
    dcs.append(sc.val('d2con_make (mkloc (1), mkfil (0), mksym (1), %s, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())' % c['A'], 'd2con'))
    dcs.append(sc.val('d2con_make (mkloc (2), mkfil (0), mksym (2), %s, 0, LN_s2qualst (), 1, LN_s2explst (), ON_s2explstopt ())' % c['B'], 'd2con'))
    sc.dc = dcs
    # the existential variables with their sizes (the s2zexp of the variable)
    sV = [sc.val('s2Var_make_srt (mkloc (%d), s2rt_t0ype)' % i, 's2Var') for i in range(24)]
    sc.sV = sV
    a = ty['A']; b = ty['B']; p = ty['P']; vw = ty['V']
    S = lambda *xs: sc.lst('s2explst', list(xs))
    lab = lambda i, t, nm='ON_stringopt ()': 'K_labs2exp (mklab (%d), %s, %s)' % (i, nm, t)
    LB = lambda *xs: sc.lst('labs2explst', list(xs))
    # ---- the exemplars (every case of s2hnf_tyer and of the functions it calls)
    T('var0', 's2exp_var (%s)' % sv[0]); T('var1', 's2exp_var (%s)' % sv[1])
    T('int3', 's2exp_int (3)'); T('str', 's2exp_string ("ss")')
    T('Var0', 's2exp_Var (%s)' % sV[0])
    for i, ze in enumerate(sc.zexps(1)):
        sc.do('s2Var_set_szexp (%s, %s)' % (sV[i + 1], ze))
        T('Var%d' % (i + 1), 's2exp_Var (%s)' % sV[i + 1])
    T('dtyp0', 's2exp_datcontyp (%s, %s)' % (dcs[0], S(a, b)))
    T('dtyp1', 's2exp_datcontyp (%s, %s)' % (dcs[1], S(p, a, b, p)))
    T('dtyp2', 's2exp_datcontyp (%s, %s)' % (dcs[1], S(a)))
    T('dtyp3', 's2exp_datcontyp (%s, %s)' % (dcs[1], S(p, a, vw, b)))
    T('dtyp4', 's2exp_datcontyp (%s, %s)' % (dcs[0], S(a, p, b)))
    T('dptr', 's2exp_datconptr (%s, %s, %s)' % (dcs[0], ty['int3'], S(a)))
    T('app_plain', 's2exp_cstapp (%s, %s)' % (c['F1'], S(a)))
    T('app_plain2', 's2exp_cstapp (%s, %s)' % (c['F2'], S(a, ty['int3'])))
    T('app_plain3', 's2exp_cstapp (%s, %s)' % (c['F3'], S(ty['K'], b, p)))
    T('app_lam', 's2exp_cstapp (%s, %s)' % (c['aF'], S(a)))
    T('app_lam2', 's2exp_cstapp (%s, %s)' % (c['aFL'], S(b, ty['int3'])))
    T('app_lam3', 's2exp_cstapp (%s, %s)' % (c['aFF'], S(b)))
    T('app_nolam', 's2exp_cstapp (%s, %s)' % (c['aFD'], S(a)))
    T('app_nodef', 's2exp_cstapp (%s, %s)' % (c['aFN'], S(a, ty['int3'])))
    T('app_nodef2', 's2exp_cstapp (%s, %s)' % (c['aFN'], S(p, ty['K'], b)))
    T('app_var', 's2exp_app_srt (s2rt_t0ype, s2exp_var (%s), %s)' % (sv[2], S(a, ty['int3'], b)))
    T('app_varcst', 's2exp_app_srt (s2rt_t0ype, s2exp_cst (%s), %s)' % (c['aF'], S(a)))
    T('lam', 's2exp_lam_srt (%s, %s, %s)' % (SORT_F1, sc.lst('s2varlst', [sv[1]]), ty['fn']))
    T('metfun', 'K_s2exp (s2rt_t0ype, K_S2Emetfun (ON_stampopt (), %s, %s))' % (S(ty['int3']), ty['fn']))
    T('top', 's2exp_top (0, %s)' % a); T('top1', 's2exp_top (1, %s)' % ty['aD']); T('without', 's2exp_without (%s)' % b)
    T('tyarr', 's2exp_tyarr (%s, %s)' % (a, S(ty['int3']))); T('tyarr2', 's2exp_tyarr (%s, %s)' % (ty['aD2'], S(ty['int3'], ty['int3'])))
    for knd in ('K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt1 (mkstamp (0))', 'K_TYRECKINDflt_ext ("nm")'):
        kn = re.sub(r'[^A-Za-z0-9]', '', knd.replace('K_', ''))
        T('rec_%s_0' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (knd, LB(lab(0, a), lab(1, b))))
        T('rec_%s_1' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (knd, LB(lab(0, a))))
        T('rec_%s_p' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (knd, LB(lab(0, p), lab(1, a), lab(2, vw), lab(3, b))))
        T('rec_%s_pp' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (knd, LB(lab(0, p), lab(1, a))))
        T('rec_%s_npf' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 1, %s)' % (knd, LB(lab(0, p), lab(1, a), lab(2, b))))
        T('rec_%s_npf2' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 2, %s)' % (knd, LB(lab(0, p), lab(1, vw), lab(2, a))))
        T('rec_%s_n' % kn, 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (knd, LB(lab(0, a, 'OS_stringopt ("f0")'), lab(1, ty['fn']))))
    T('rec_nil', 's2exp_tyrec_srt (s2rt_t0ype, K_TYRECKINDflt0 (), 0, %s)' % LB())
    T('tup2', 's2exp_tytup (0, 0, %s)' % S(a, b)); T('tup1', 's2exp_tytup (1, 0, %s)' % S(a)); T('tupp', 's2exp_tytup (0, 1, %s)' % S(p, a, b))
    for fc in ('FUNCLOfun ()', 'FUNCLOclo (1)', 'FUNCLOclo (0)', 'FUNCLOclo (~1)'):
        kn = re.sub(r'[^A-Za-z0-9]', '', fc)
        T('fun_%s' % kn, 's2exp_fun_srt (s2rt_t0ype, %s, 0, s2eff_nil, 0, %s, %s)' % (fc, S(a, b), ty['aD']))
        T('funp_%s' % kn, 's2exp_fun_srt (s2rt_t0ype, %s, 1, s2eff_nil, 1, %s, %s)' % (fc, S(p, a, vw, b), vw))
        T('funpp_%s' % kn, 's2exp_fun_srt (s2rt_t0ype, %s, 0, s2eff_nil, 2, %s, %s)' % (fc, S(p, vw, ty['aD2']), ty['fn']))
        T('fun0_%s' % kn, 's2exp_fun_srt (s2rt_t0ype, %s, 0, s2eff_nil, 0, %s, %s)' % (fc, S(), a))
    T('invar', 's2exp_invar (%s)' % a); T('exi', 's2exp_exi (%s, %s, %s)' % (sc.lst('s2varlst', [sv[0]]), S(), ty['rec_TYRECKINDflt0_1']))
    T('uni', 's2exp_uni (%s, %s, %s)' % (sc.lst('s2varlst', [sv[1]]), S(p), ty['fn']))
    T('refarg0', 's2exp_refarg (0, %s)' % ty['aD2']); T('refarg1', 's2exp_refarg (1, %s)' % ty['fn'])
    T('vararg', 's2exp_vararg (%s)' % a)
    T('wth', 's2exp_wthtype (%s, K_WTHS2EXPLSTnil ())' % ty['fn'])
    T('eff', 's2exp_eff (s2eff_nil)')
    T('errexp', 's2exp_errexp (s2rt_t0ype)')
    # nested
    T('nest1', 's2exp_tyrec_srt (s2rt_t0ype, K_TYRECKINDbox (), 0, %s)' % LB(lab(0, ty['fun_FUNCLOfun']), lab(1, ty['rec_TYRECKINDflt0_0']), lab(2, ty['aDD'])))
    T('nest2', 's2exp_fun_srt (s2rt_t0ype, FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (S(ty['nest1'], ty['rec_TYRECKINDbox_0'], ty['Var3']), ty['tup2']))
    T('nest3', 's2exp_tytup (1, 0, %s)' % S(ty['nest2']))
    T('nest4', 's2exp_top (0, %s)' % ty['nest1'])
    T('nest5', 's2exp_exi (%s, %s, %s)' % (sc.lst('s2varlst', [sv[2]]), S(), ty['nest3']))
    T('nest6', 's2exp_tyarr (%s, %s)' % (ty['nest2'], S(ty['int3'])))
    sc.ty = ty
    # the constants of the d3 trees: the booleans (the symbols true_bool / false_bool), a castfn
    # the constants: types that the erasure can handle
    for i in range(3):
        sc.val('d2cst_make (mksym (%d), mkloc (%d), mkfil (0), mkdcstkind (%d), LN_s2qualst (), %s, %s, mkdcstextdef (%d))' % (i + 1, i + 6, [0, 1, 0][i], sc.lst('intlst', ['1', '2'][:i % 3]), [ty['fn'], ty['rec_TYRECKINDbox_0'], ty['aD2']][i], i), 'd2cst')
    Cs = sc.pool['d2cst']
    sc.dtrue = sc.val('d2cst_make ($SYM.symbol_TRUE_BOOL, mkloc (3), mkfil (0), mkdcstkind (1), LN_s2qualst (), %s, %s, mkdcstextdef (0))' % (sc.lst('intlst', []), ty['B']), 'd2cst')
    sc.dfalse = sc.val('d2cst_make ($SYM.symbol_FALSE_BOOL, mkloc (4), mkfil (0), mkdcstkind (1), LN_s2qualst (), %s, %s, mkdcstextdef (0))' % (sc.lst('intlst', []), ty['B']), 'd2cst')
    sc.dcast = sc.val('d2cst_make (mksym (5), mkloc (5), mkfil (0), mkdcstkind (5), LN_s2qualst (), %s, %s, mkdcstextdef (0))' % (sc.lst('intlst', ['1']), ty['fn']), 'd2cst')
    # the variables of the d3 trees have a type (mastype) and the constants a type
    for i, v in enumerate(sc.pool['d2var']):
        sc.do('d2var_set_mastype (%s, OS_s2expopt (%s))' % (v, sc.R.choice([ty['fn'], ty['A'], ty['rec_TYRECKINDbox_0'], ty['aD2']])) if i < 2 else 'd2var_set_mastype (%s, ON_s2expopt ())' % v)
    # the size types of the arrays
    ku = 's2exp_cst (t_pcst ("size_kind"))'
    sc.szty = {'sz3': sc.val('s2exp_cstapp (t_pcst ("g1uint_int_t0ype"), %s)' % sc.lst('s2explst', [ku, 's2exp_int (3)']), 's2exp'),
               'szvar': sc.val('s2exp_cstapp (t_pcst ("g1uint_int_t0ype"), %s)' % sc.lst('s2explst', [ku, 's2exp_var (%s)' % sv[0]]), 's2exp'),
               'szi': sc.val('s2exp_cstapp (t_pcst ("g1int_int_t0ype"), %s)' % sc.lst('s2explst', ['s2exp_cst (t_pcst ("int_kind"))', 's2exp_int (7)']), 's2exp')}
    sc.szty['sz3'] = sc.szty['sz3']
    sc.tys = [v for v in ty.values()]
    sc.typrf = [ty['P'], ty['V']]
    # the file environments 1..3 that the staload declarations of the trees refer to: their declarations (without staload)
    sc.nostaload = True
    for i in range(1, 4):
        inner = sc.val(DL(sc, 1, 2), 'd3eclist')
        sc.do('t_fenv_set_d3cs (mkfilenv (%d), %s)' % (i, inner))
    sc.nostaload = False
    return ty

# ---------------------------------------------------------------------------------------------------------------------
# the sizes of the types (s2zexp): every constructor, with the proofs that are dropped
def zexps(sc, d=1):
    c = sc.cst
    sv = sc.pool['s2var']
    Z = lambda xs: sc.lst('s2zexplst', xs)
    LZ = lambda *xs: sc.lst('labs2zexplst', list(xs))
    lz = lambda i, z: 'K_labs2zexp (mklab (%d), %s)' % (i, z)
    zs = ['K_S2ZEptr ()', 'K_S2ZEprf ()', 'K_S2ZEcst (%s)' % c['A'], 'K_S2ZEcst (%s)' % c['aD'], 'K_S2ZEcst (%s)' % c['aN'], 'K_S2ZEvar (%s)' % sv[0],
          'K_S2ZEapp (K_S2ZEcst (%s), %s)' % (c['F1'], Z(['K_S2ZEcst (%s)' % c['A']])),
          'K_S2ZEapp (K_S2ZEvar (%s), %s)' % (sv[1], Z(['K_S2ZEprf ()', 'K_S2ZEptr ()', 'K_S2ZEcst (%s)' % c['B']])),
          'K_S2ZEtyrec (K_TYRECKINDbox (), %s)' % LZ(lz(0, 'K_S2ZEptr ()')),
          'K_S2ZEtyrec (K_TYRECKINDflt_ext ("nm"), %s)' % LZ(lz(0, 'K_S2ZEptr ()'), lz(1, 'K_S2ZEprf ()'), lz(2, 'K_S2ZEcst (%s)' % c['A'])),
          'K_S2ZEtyrec (K_TYRECKINDflt0 (), %s)' % LZ(lz(0, 'K_S2ZEptr ()')),
          'K_S2ZEtyrec (K_TYRECKINDflt0 (), %s)' % LZ(lz(0, 'K_S2ZEprf ()'), lz(1, 'K_S2ZEcst (%s)' % c['A'])),
          'K_S2ZEtyrec (K_TYRECKINDflt1 (mkstamp (0)), %s)' % LZ(lz(0, 'K_S2ZEptr ()'), lz(1, 'K_S2ZEptr ()')),
          'K_S2ZEtyrec (K_TYRECKINDflt0 (), %s)' % LZ(),
          'K_S2ZEextype ("xt", LN_s2zexplstlst ())', 'K_S2ZEextkind ("xk", LN_s2zexplstlst ())',
          'K_S2ZEtyarr (K_S2ZEptr (), %s)' % sc.lst('s2explst', ['s2exp_int (2)']), 'K_S2ZEclo ()', 'K_S2ZEbot ()']
    zs.append('K_S2ZEVar (%s)' % sc.sV[0])
    return zs

# ---------------------------------------------------------------------------------------------------------------------
# level-3 trees
def Ty(sc, prf=0.12):
    """a type exemplar (a proof type with the probability prf)"""
    if sc.R.random() < prf: return sc.R.choice(sc.typrf)
    return sc.R.choice(sc.tys)

def tmas(sc):
    return sc.lst('t2mpmarglst', ['t2mpmarg_make (%s, %s)' % (sc.loc(), sc.lst('s2explst', [Ty(sc, 0) for _ in range(sc.R.randrange(3))])) for _ in range(sc.R.randrange(3))])

def d3list(sc, d, n, prf=0.2):
    """a list of n d3exp (some of them proofs: their types are proofs)"""
    es = []
    for _ in range(n):
        es.append(D3(sc, d, prf))
    return sc.lst('d3explst', es)

def D3(sc, d=2, prf=0.0, force=None):
    R = sc.R; L = sc.loc()
    V = sc.pool['d2var']; Cs = sc.pool['d2cst']
    isp = R.random() < prf
    T = (lambda: R.choice(sc.typrf)) if isp else (lambda: Ty(sc, 0.0))
    if (force is None and (d <= 0 or R.random() < 0.4)) or (force is not None and force >= 100):
        k = R.randrange(26) if force is None else force - 100
        return [
          'd3exp_var (%s, %s, %s)' % (L, T(), R.choice(V)), 'd3exp_cst (%s, %s, %s)' % (L, T(), R.choice(Cs)), 'd3exp_int (%s, %s, %d)' % (L, T(), R.randrange(4)),
          'd3exp_intrep (%s, %s, "5")' % (L, T()), 'd3exp_bool (%s, %s, %s)' % (L, T(), R.choice(['true', 'false'])),
          'd3exp_char (%s, %s, mkchr (%d))' % (L, T(), R.randrange(2)), 'd3exp_string (%s, %s, "ds")' % (L, T()), 'd3exp_float (%s, %s, "2.5")' % (L, T()),
          'd3exp_i0nt (%s, %s, mki0nt (%d))' % (L, T(), R.randrange(3)), 'd3exp_f0loat (%s, %s, mkf0loat (%d))' % (L, T(), R.randrange(2)),
          'd3exp_cstsp (%s, %s, mkcstsp (%d))' % (L, T(), R.randrange(3)), 'd3exp_tyrep (%s, %s, %s)' % (L, T(), Ty(sc, 0)),
          'd3exp_top (%s, %s)' % (L, T()), 'd3exp_empty (%s, %s)' % (L, T()), 'd3exp_extval (%s, %s, "ev")' % (L, T()),
          'd3exp_ptrofvar (%s, %s, %s)' % (L, T(), R.choice(V)), 'd3exp_vcopyenv (%s, %s, %d, %s)' % (L, T(), R.randrange(2), R.choice(V)),
          'd3exp_tempenver (%s, %s, %s)' % (L, T(), sc.lst('d2varlst', [R.choice(V) for _ in range(R.randrange(3))])),
          'd3exp_loopexn (%s, %d)' % (L, R.randrange(2)), 'd3exp_solverify (%s, %s)' % (L, T()), 'd3exp_errexp (%s)' % L,
          'd3exp_cst (%s, %s, %s)' % (L, T(), sc.dtrue), 'd3exp_cst (%s, %s, %s)' % (L, T(), sc.dfalse), 'd3exp_cst (%s, %s, %s)' % (L, T(), sc.dcast),
          'd3exp_var (%s, %s, %s)' % (L, T(), R.choice(V)), 'd3exp_empty (%s, %s)' % (L, T())][k]
    d -= 1
    E = lambda p=0.0: D3(sc, d, p)
    k = R.randrange(48) if force is None else force
    if k == 0: return 'd3exp_extfcall (%s, %s, "fx", %s)' % (L, T(), d3list(sc, d, R.randrange(4)))
    if k == 1: return 'd3exp_extmcall (%s, %s, %s, "mt", %s)' % (L, T(), E(), d3list(sc, d, R.randrange(3)))
    if k == 2:
        npf = R.choice([0, 0, 1, 2])
        return 'd3exp_con (%s, %s, %s, %d, %s)' % (L, T(), R.choice(sc.dc), npf, d3list(sc, d, npf + R.randrange(3)))
    if k == 3: return 'd3exp_tmpcst (%s, %s, %s, %s)' % (L, T(), R.choice(Cs), tmas(sc))
    if k == 4: return 'd3exp_tmpvar (%s, %s, %s, %s)' % (L, T(), R.choice(V), tmas(sc))
    if k == 5: return 'd3exp_foldat (%s, %s)' % (L, E())
    if k == 6: return 'd3exp_freeat (%s, %s)' % (L, E())
    if k == 7: return 'd3exp_let (%s, %s, %s)' % (L, DL(sc, d, R.choice([0, 1, 1, 2])), E())
    if k == 8: return 'd3exp_app_sta (%s, %s, %s)' % (L, T(), E())
    if k == 9 or k == 10:
        npf = R.choice([0, 0, 1, 2])
        return 'd3exp_app_dyn (%s, %s, %s, %d, %s)' % (L, T(), E(), npf, d3list(sc, d, npf + R.randrange(3)))
    if k == 11: return 'd3exp_lst (%s, %s, %d, %s, %s)' % (L, T(), R.randrange(2), Ty(sc, 0), d3list(sc, d, R.randrange(4), 0.0))
    if k == 12:
        npf = R.choice([0, 0, 1, 2])
        return 'd3exp_tup (%s, %s, %d, %d, %s)' % (L, T(), R.randrange(2), npf, d3list(sc, d, npf + R.randrange(4)))
    if k == 13:
        npf = R.choice([0, 0, 1, 2])
        return 'd3exp_rec (%s, %s, %d, %d, %s)' % (L, T(), R.randrange(2), npf, sc.lst('labd3explst', ['K_labd3exp (mkl0ab (%d), %s)' % (R.randrange(3), D3(sc, d, 0.2)) for _ in range(npf + R.randrange(3))]))
    if k == 14: return 'd3exp_seq (%s, %s, %s)' % (L, T(), d3list(sc, d, R.randrange(4), 0.0))
    if k == 15: return 'd3exp_if (%s, %s, %s, %s, %s)' % (L, T(), E(), E(), E())
    if k == 16: return 'd3exp_sif (%s, %s, %s, %s, %s)' % (L, T(), Ty(sc, 0), E(), E())
    if k == 17: return 'd3exp_ifcase (%s, %s, %d, %s)' % (L, T(), R.randrange(2), sc.lst('i3fclist', ['i3fcl_make (%s, %s, %s)' % (L, E(), E()) for _ in range(R.randrange(4))]))
    if k == 18: return D3case(sc, d)
    if k == 19: return 'd3exp_sel_var (%s, %s, %s, %s, %s)' % (L, T(), R.choice(V), Ty(sc, 0), D3labs(sc, d))
    if k == 20: return 'd3exp_sel_ptr (%s, %s, %s, %s, %s)' % (L, T(), E(), Ty(sc, 0), D3labs(sc, d))
    if k == 21: return 'd3exp_sel_ref (%s, %s, %s, %s, %s)' % (L, T(), E(), Ty(sc, 0), D3labs(sc, d))
    if k == 22: return 'd3exp_assgn_var (%s, %s, %s, %s, %s)' % (L, R.choice(V), Ty(sc, 0), D3labs(sc, d), E(0.35))
    if k == 23: return 'd3exp_assgn_ptr (%s, %s, %s, %s, %s)' % (L, E(), Ty(sc, 0), D3labs(sc, d), E(0.35))
    if k == 24: return 'd3exp_assgn_ref (%s, %s, %s, %s, %s)' % (L, E(), Ty(sc, 0), D3labs(sc, d), E())
    if k == 25: return 'd3exp_xchng_var (%s, %s, %s, %s, %s)' % (L, R.choice(V), Ty(sc, 0), D3labs(sc, d), E())
    if k == 26: return 'd3exp_xchng_ptr (%s, %s, %s, %s, %s)' % (L, E(), Ty(sc, 0), D3labs(sc, d), E())
    if k == 27: return 'd3exp_xchng_ref (%s, %s, %s, %s, %s)' % (L, E(), Ty(sc, 0), D3labs(sc, d), E())
    if k == 28: return 'd3exp_refarg (%s, %s, %d, %d, %s)' % (L, T(), R.randrange(2), R.randrange(2), E())
    if k == 29: return 'd3exp_arrpsz (%s, %s, %s, %s, %d)' % (L, T(), Ty(sc, 0), d3list(sc, d, R.randrange(4), 0.0), R.randrange(5))
    if k == 30: return D3arrinit(sc, d)
    if k == 31: return 'd3exp_selab (%s, %s, %s, %s)' % (L, T(), E(), D3labs(sc, d))
    if k == 32: return 'd3exp_ptrofsel (%s, %s, %s, %s, %s)' % (L, T(), E(), Ty(sc, 0), D3labs(sc, d))
    if k == 33: return 'd3exp_viewat_assgn (%s, %s, %s, %s)' % (L, E(), D3labs(sc, d), E())
    if k == 34: return 'd3exp_raise (%s, %s, %s)' % (L, T(), E())
    if k == 35: return 'd3exp_effmask (%s, s2eff_nil, %s)' % (L, E())
    if k == 36: return 'd3exp_vararg (%s, %s, %s)' % (L, T(), d3list(sc, d, R.randrange(4)))
    if k == 37 or k == 38:
        npf = R.choice([0, 0, 1, 2])
        return '%s (%s, %s, %d, %d, %s, %s)' % (R.choice(['d3exp_lam_dyn', 'd3exp_laminit_dyn']), L, T(), R.randrange(2), npf, p3list(sc, d, npf + R.randrange(3)), E())
    if k == 39: return 'd3exp_lam_sta (%s, %s, %s, %s, %s)' % (L, T(), sc.lst('s2varlst', [R.choice(sc.pool['s2var']) for _ in range(R.randrange(3))]), sc.lst('s2explst', [Ty(sc, 0) for _ in range(R.randrange(2))]), R.choice([E(), 'd3exp_int (%s, %s, 1)' % (L, T()), 'd3exp_cst (%s, %s, %s)' % (L, T(), R.choice(Cs)), 'd3exp_var (%s, %s, %s)' % (L, T(), R.choice(V))]))
    if k == 40: return 'd3exp_lam_met (%s, %s, %s)' % (L, sc.lst('s2explst', [Ty(sc, 0)]), E())
    if k == 41: return 'd3exp_fix (%s, %s, %d, %s, %s)' % (L, T(), R.randrange(2), R.choice(V), E())
    if k == 42: return 'd3exp_delay (%s, %s, %s)' % (L, T(), E())
    if k == 45: return 'd3exp_ldelay (%s, %s, %s, %s)' % (L, T(), E(), E())
    if k == 46: return 'd3exp_lazyeval (%s, %s, %d, %s)' % (L, T(), R.randrange(2), E())
    if k == 43: return 'd3exp_loop (%s, %s, %s, %s, %s)' % (L, sc.gv('d3expopt', 0) if False else R.choice(['ON_d3expopt ()', 'OS_d3expopt (%s)' % E()]), E(), R.choice(['ON_d3expopt ()', 'OS_d3expopt (%s)' % E()]), E())
    if k == 44: return 'd3exp_trywith (%s, %s, %s)' % (L, E(), sc.lst('c3laulst', ['c3lau_make (%s, %s, %s, %d, %d, %s)' % (L, p3list(sc, d, R.randrange(3)), GM(sc, d), R.randrange(2), R.randrange(2), E()) for _ in range(R.randrange(3))]))
    return 'd3exp_ann_type (%s, %s, %s)' % (L, E(), Ty(sc, 0))   # k = 47 (and any other)

def GM(sc, d):
    R = sc.R; L = sc.loc()
    return sc.lst('gm3atlst', ['gm3at_make (%s, %s, %s)' % (L, D3(sc, max(d - 1, 0)), R.choice(['ON_p3atopt ()', 'OS_p3atopt (%s)' % P3(sc, max(d - 1, 0))])) for _ in range(R.randrange(3))])

def D3labs(sc, d):
    R = sc.R; L = sc.loc()
    return sc.lst('d3lablst', [(('d3lab_lab (%s, mklab (%d), ON_d2symopt ())' % (L, R.randrange(3))) if R.random() < 0.5 else ('d3lab_ind (%s, %s)' % (L, d3list(sc, max(d - 1, 0), R.randrange(1, 3), 0.0)))) for _ in range(R.randrange(3))])

def D3case(sc, d):
    R = sc.R; L = sc.loc()
    n = R.randrange(1, 3)
    vals = [D3(sc, max(d - 1, 0), 0.2) for _ in range(n)]
    cls = []
    for _ in range(R.randrange(0, 3)):
        # the pats of a clause have the length of the values
        cls.append('c3lau_make (%s, %s, %s, %d, %d, %s)' % (L, sc.lst('p3atlst', [P3(sc, max(d - 1, 0)) for _ in range(n)]), GM(sc, d), R.randrange(2), R.randrange(2), D3(sc, max(d - 1, 0))))
    return 'd3exp_case (%s, %s, mkcaskind (%d), %s, %s)' % (L, Ty(sc, 0.0), R.randrange(3), sc.lst('d3explst', vals), sc.lst('c3laulst', cls))

def D3arrinit(sc, d):
    R = sc.R; L = sc.loc()
    ty = sc.szty
    asz = 'd3exp_int (%s, %s, %d)' % (L, R.choice([ty['sz3'], ty['szvar'], ty['sz3']]), R.randrange(4))
    return 'd3exp_arrinit (%s, %s, %s, %s, %s)' % (L, Ty(sc, 0), Ty(sc, 0), asz, d3list(sc, max(d - 1, 0), R.randrange(4), 0.0))

def p3list(sc, d, n):
    """n patterns (some are proofs)"""
    return sc.lst('p3atlst', [P3(sc, d, 0.2) for _ in range(n)])

def P3(sc, d=2, prf=0.0, force=None):
    R = sc.R; L = sc.loc()
    V = sc.pool['d2var']
    isp = R.random() < prf
    T = (lambda: R.choice(sc.typrf)) if isp else (lambda: Ty(sc, 0.0))
    if (force is None and (d <= 0 or R.random() < 0.5)) or (force is not None and force >= 100):
        k = R.randrange(14) if force is None else force - 100
        return [
          'p3at_any (%s, %s, %s)' % (L, T(), R.choice(V)), 'p3at_var (%s, %s, %s)' % (L, T(), R.choice(V)), 'p3at_int (%s, %s, %d)' % (L, T(), R.randrange(3)),
          'p3at_intrep (%s, %s, "6")' % (L, T()), 'p3at_bool (%s, %s, %s)' % (L, T(), R.choice(['true', 'false'])), 'p3at_char (%s, %s, mkchr (%d))' % (L, T(), R.randrange(2)),
          'p3at_string (%s, %s, "ps")' % (L, T()), 'p3at_i0nt (%s, %s, mki0nt (%d))' % (L, T(), R.randrange(3)), 'p3at_f0loat (%s, %s, mkf0loat (%d))' % (L, T(), R.randrange(2)),
          'p3at_empty (%s, %s)' % (L, T()), 'p3at_any (%s, %s, %s)' % (L, T(), R.choice(V)), 'p3at_var (%s, %s, %s)' % (L, T(), R.choice(V)),
          'p3at_con (%s, %s, mkpckind (%d), %s, 0, %s)' % (L, T(), R.randrange(4), R.choice(sc.dc), sc.lst('p3atlst', [])),
          'p3at_var (%s, %s, %s)' % (L, T(), R.choice(V))][k]
    d -= 1
    k = R.randrange(8) if force is None else force
    if k == 0 or k == 1:
        npf = R.choice([0, 0, 1, 2])
        return 'p3at_con (%s, %s, mkpckind (%d), %s, %d, %s)' % (L, T(), R.randrange(4), R.choice(sc.dc), npf, p3list(sc, d, npf + R.randrange(4)))
    if k == 2:
        npf = R.choice([0, 0, 1, 2])
        return 'p3at_rec (%s, %s, %d, %d, mkpckind (%d), %s)' % (L, T(), R.randrange(2), npf, R.randrange(4), sc.lst('labp3atlst', ['K_labp3at (mklab (%d), %s)' % (R.randrange(3), P3(sc, d, 0.2)) for _ in range(npf + R.randrange(3))]))
    if k == 3: return 'p3at_lst (%s, %s, %d, %s, %s)' % (L, T(), R.randrange(2), Ty(sc, 0), p3list(sc, d, R.randrange(3)))
    if k == 4: return 'p3at_refas (%s, %s, %s, %s)' % (L, T(), R.choice(V), P3(sc, d))
    if k == 5: return 'p3at_exist (%s, %s, %s, %s)' % (L, T(), sc.lst('s2varlst', [R.choice(sc.pool['s2var']) for _ in range(R.randrange(3))]), P3(sc, d))
    if k == 6: return 'p3at_ann (%s, %s, %s, %s)' % (L, T(), P3(sc, d), Ty(sc, 0))
    return 'p3at_con (%s, %s, mkpckind (%d), %s, 0, %s)' % (L, T(), R.randrange(4), R.choice(sc.dc), p3list(sc, d, R.randrange(3)))

def DL(sc, d, n):
    return sc.lst('d3eclist', [DC(sc, d) for _ in range(n)])

def DC(sc, d=1, force=None):
    R = sc.R; L = sc.loc()
    V = sc.pool['d2var']; Cs = sc.pool['d2cst']
    dd = max(d - 1, 0)
    k = R.randrange(22) if force is None else force
    if k >= 20 and getattr(sc, 'nostaload', False): k = R.randrange(20)
    if k == 0: return 'd3ecl_none (%s)' % L
    if k == 1: return 'd3ecl_list (%s, %s)' % (L, DL(sc, dd, R.randrange(3)) if d > 0 else 'LN_d3eclist ()')
    if k == 2: return 'd3ecl_saspdec (%s, %s)' % (L, sc.gv('s2aspdec', 1))
    if k == 3: return 'd3ecl_reassume (%s, %s)' % (L, R.choice(sc.pool['s2cst']))
    if k == 4: return 'd3ecl_extype (%s, "xt", %s)' % (L, Ty(sc, 0))
    if k == 5: return 'd3ecl_extvar (%s, "xv", %s)' % (L, D3(sc, dd))
    if k == 6: return 'd3ecl_extcode (%s, %d, %d, "cc")' % (L, R.randrange(3), R.randrange(3))
    if k == 7: return 'd3ecl_datdecs (%s, %d, %s)' % (L, R.randrange(2), sc.lst('s2cstlst', [R.choice(sc.pool['s2cst']) for _ in range(R.randrange(3))]))
    if k == 8: return 'd3ecl_exndecs (%s, %s)' % (L, sc.lst('d2conlst', list(sc.dc)))
    if k == 9: return 'd3ecl_dcstdecs (%s, %d, mkdcstkind (%d), %s)' % (L, R.randrange(2), R.randrange(6), sc.lst('d2cstlst', [R.choice(Cs) for _ in range(R.randrange(3))]))
    if k == 10: return 'd3ecl_impdec (%s, %d, i3mpdec_make (%s, %s, %s, %s, %s))' % (L, R.choice([-1, 0, 1, 1]), L, R.choice(Cs), sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1) if R.random() < 0.6 else 'LN_s2explstlst ()', D3(sc, dd))
    if k == 11 or k == 12:
        return 'd3ecl_fundecs (%s, mkfunkind (%d), %s, %s)' % (L, R.randrange(7), sc.lst('s2qualst', ['K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', [R.choice(sc.pool['s2var']) for _ in range(R.randrange(3))]) for _ in range(R.randrange(3))]),
            sc.lst('f3undeclst', ['f3undec_make (%s, %s, %s)' % (L, R.choice(V), D3(sc, dd, 0.2)) for _ in range(R.randrange(3))]))
    if k == 13: return 'd3ecl_valdecs (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), sc.lst('v3aldeclst', ['v3aldec_make (%s, %s, %s)' % (L, P3(sc, dd), D3(sc, dd, 0.2)) for _ in range(R.randrange(3))]))
    if k == 14: return 'd3ecl_valdecs_rec (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), sc.lst('v3aldeclst', ['v3aldec_make (%s, %s, %s)' % (L, P3(sc, dd), D3(sc, dd, 0.2)) for _ in range(R.randrange(3))]))
    if k == 15: return 'd3ecl_vardecs (%s, %s)' % (L, sc.lst('v3ardeclst', ['v3ardec_make (%s, %d, %s, %s, %s, %s, %s)' % (L, R.randrange(2), R.choice(V), R.choice(V), Ty(sc, 0), R.choice(['ON_d3expopt ()', 'OS_d3expopt (%s)' % D3(sc, dd)]), 'ON_d2varopt ()') for _ in range(R.randrange(3))]))
    if k == 16: return 'd3ecl_prvardecs (%s, %s)' % (L, sc.lst('prv3ardeclst', ['prv3ardec_make (%s, %s, %s, %s)' % (L, R.choice(V), Ty(sc, 0), D3(sc, dd)) for _ in range(R.randrange(3))]))
    if k == 17: return 'd3ecl_include (%s, %d, %s)' % (L, R.randrange(2), DL(sc, dd, R.randrange(3)) if d > 0 else 'LN_d3eclist ()')
    if k == 18: return 'd3ecl_dynload (%s, mkfil (0))' % L
    if k == 19: return 'd3ecl_local (%s, %s, %s)' % (L, DL(sc, dd, R.randrange(3)) if d > 0 else 'LN_d3eclist ()', DL(sc, dd, R.randrange(3)) if d > 0 else 'LN_d3eclist ()')
    if k == 20: return 'd3ecl_staload (%s, %s, mkfil (0), %d, mkfilenv (%d), %d)' % (L, R.choice(['ON_symbolopt ()', 'OS_symbolopt (mksym (1))']), R.randrange(2), R.randrange(1, 4), R.randrange(2))
    return 'd3ecl_staloadloc (%s, mkfil (0), mksym (2), mkfilenv (%d))' % (L, R.randrange(1, 4))


# ---------------------------------------------------------------------------------------------------------------------
def families_ty(G, C, ScH, F):
    # ----------------------------------------------------------------------------------------------------------
    def fam_tys(sc, k):
        """s2exp_tyer (flag 0/1) of every exemplar; s2zexp_tyer of every size; t2mpmarg"""
        R = sc.R
        tycells(sc)
        L = sc.loc
        for name, t in sc.ty.items():
            sc.do('(dd_ps "%s "; dd_hisexp (s2exp_tyer_deep (%s, %s)); dd_nl ())' % (name, L(), t))
            sc.do('(dd_ps "%s "; dd_hisexp (s2exp_tyer_shallow (%s, %s)); dd_nl ())' % (name, L(), t))
            sc.do('(dd_ps "%s "; dd_hisexp (s2exp_tyer (%s, %d, %s)); dd_nl ())' % (name, L(), R.choice([0, 1, 2]), t))
    F.append(('tys', fam_tys, 1))
    def fam_tyz(sc, k):
        R = sc.R
        tycells(sc)
        L = sc.loc
        zs = sc.zexps(1)
        for z in zs:
            sc.do('(dd_hisexp (s2zexp_tyer (%s, %s)); dd_nl ())' % (L(), z))
        # the sizes that are made of the others
        c = sc.cst
        for _ in range(10):
            z1 = R.choice(zs); z2 = R.choice(zs); z3 = R.choice(zs)
            sc.do('(dd_hisexp (s2zexp_tyer (%s, K_S2ZEapp (%s, %s))); dd_nl ())' % (L(), z1, sc.lst('s2zexplst', [z2, z3])))
            sc.do('(dd_hisexp (s2zexp_tyer (%s, K_S2ZEtyrec (%s, %s))); dd_nl ())' % (L(), R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt_ext ("e")', 'K_TYRECKINDflt1 (mkstamp (0))']),
                sc.lst('labs2zexplst', ['K_labs2zexp (mklab (%d), %s)' % (i, R.choice(zs)) for i in range(R.randrange(4))])))
        # the szexp of the existential variables, through S2EVar
        for i in range(len(sc.sV)):
            sc.do('(dd_hisexp (s2exp_tyer_deep (%s, s2exp_Var (%s))); dd_nl ())' % (L(), sc.sV[i]))
        # the targets of t2mpmarg
        for _ in range(6):
            ma = sc.val('t2mpmarg_make (%s, %s)' % (L(), sc.lst('s2explst', [Ty(sc, 0.2) for _ in range(R.randrange(4))])), 't2mpmarg')
            sc.do('(dd_hisexplst (t2mpmarg_tyer (%s)); dd_nl ())' % ma)
            sc.do('(dd_t2mpmarg (t2mpmarg_mhnfize (%s)); dd_nl ())' % ma)
        mas = sc.lst('t2mpmarglst', ['t2mpmarg_make (%s, %s)' % (L(), sc.lst('s2explst', [Ty(sc, 0.2) for _ in range(R.randrange(3))])) for _ in range(R.randrange(1, 4))])
        sc.do('(dd_hisexplstlst (t2mpmarglst_tyer (%s)); dd_nl ())' % mas)
        sc.do('(dd_t2mpmarglst (t2mpmarglst_mhnfize (%s)); dd_nl ())' % mas)
        sc.do('(dd_hisexplstlst (t2mpmarglst_tyer (LN_t2mpmarglst ())); dd_nl ())')
        sc.do('(dd_t2mpmarglst (t2mpmarglst_mhnfize (LN_t2mpmarglst ())); dd_nl ())')
    F.append(('tyz', fam_tyz, 1))
    # ----------------------------------------------------------------------------------------------------------
    def fam_tyv(sc, k):
        """d2var_tyer, d2cst_tyer: the hisexp of the variable / constant is set from its type (once), the utimes"""
        R = sc.R
        tycells(sc)
        V = sc.pool['d2var']; Cs = sc.pool['d2cst'] + [sc.dtrue, sc.dfalse, sc.dcast]
        for i in range(3):
            sc.do('d2var_set_mastype (%s, OS_s2expopt (%s))' % (V[i], sc.tys[(i * 7) % len(sc.tys)]))
        for v in V:
            sc.do('chk_d2var (%s)' % v)
            sc.dd('d2var', 'd2var_tyer (%s)' % v)
            sc.do('chk_d2var (%s)' % v)
            sc.dd('d2var', 'd2var_tyer (%s)' % v)
        for c in Cs:
            sc.do('chk_d2cst (%s)' % c)
            sc.dd('d2cst', 'd2cst_tyer (%s)' % c)
            sc.do('chk_d2cst (%s)' % c)
            sc.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (c, 'hisexp_tybox'))
            sc.dd('d2cst', 'd2cst_tyer (%s)' % c)
            sc.do('chk_d2cst (%s)' % c)
        for c in sc.pool['d2cst']:
            sc.dd('hisexplst', 'hisexp_fun_args (d2cst_get2_hisexp (%s))' % c) if False else None
        # decarg2imparg
        for _ in range(4):
            qs = sc.lst('s2qualst', ['K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', [R.choice(sc.pool['s2var']) for _ in range(R.randrange(3))]) for _ in range(R.randrange(4))])
            sc.dd('s2varlst', 'decarg2imparg (%s)' % qs)
        sc.dd('s2varlst', 'decarg2imparg (LN_s2qualst ())')
    F.append(('tyv', fam_tyv, 1))
    # ----------------------------------------------------------------------------------------------------------
    def fam_typ(sc, k):
        """p3at_tyer, p3atlst_tyer(2), the error of a partial proof pattern"""
        R = sc.R
        tycells(sc)
        L = sc.loc
        ps = [sc.val(P3(sc, 2), 'p3at') for _ in range(10)] + [sc.val(P3(sc, 2, 0.1, force=kk), 'p3at') for kk in list(range(8)) + [100 + j for j in range(14)] if kk % 2 == k % 2]
        for p in ps:
            sc.do('{ val r = p3at_tyer (%s) val () = (dd_hipat (r); dd_nl ()) val () = fprint_hipat (dd_out, r) val () = dd_nl () }' % p)
        for _ in range(8):
            xs = sc.lst('p3atlst', [R.choice(ps) for _ in range(R.randrange(4))])
            sc.do('(dd_hipatlst (p3atlst_tyer (%s)); dd_nl ())' % xs)
        # p3atlst_tyer2: the values have the length of the patterns
        for _ in range(8):
            n = R.randrange(4)
            pl = sc.lst('p3atlst', [R.choice(ps) for _ in range(n)])
            dl = d3list(sc, 0, n, 0.3)
            sc.do('(dd_hipatlst (p3atlst_tyer2 (%s, %s)); dd_nl ())' % (dl, pl))
        sc.do('(dd_hipatlst (p3atlst_tyer2 (LN_d3explst (), LN_p3atlst ())); dd_nl ())')
        # the proof patterns: full (any, var, con with proof args only ..) and partial ones: the error list, then the exception of the finalization
        P = sc.typrf
        pf = ['p3at_any (%s, %s, %s)' % (L(), P[0], sc.pool['d2var'][0]), 'p3at_var (%s, %s, %s)' % (L(), P[1], sc.pool['d2var'][1]),
              'p3at_int (%s, %s, 3)' % (L(), P[0]), 'p3at_empty (%s, %s)' % (L(), P[1]), 'p3at_con (%s, %s, mkpckind (0), %s, 0, LN_p3atlst ())' % (L(), P[0], sc.dc[0]),
              'p3at_ann (%s, %s, p3at_any (%s, %s, %s), %s)' % (L(), P[0], L(), P[0], sc.pool['d2var'][0], P[1])]
        for x in pf:
            sc.do('{ val p = %s val () = (dd_bool (p3at_is_prf (p)); dd_ps " "; dd_bool (p3at_is_full (p)); dd_nl ()) val () = (dd_hipatlst (p3atlst_tyer (%s)); dd_nl ()) val () = t_fin4 () }' % (x, sc.lst('p3atlst', ['p', 'p3at_var (%s, %s, %s)' % (L(), sc.ty['A'], sc.pool['d2var'][2])])))
        sc.do('t_fin4 ()')
        sc.do('t_add4_p (%s)' % ps[0]); sc.do('t_add4_e (%s)' % sc.val(D3(sc, 1), 'd3exp')); sc.do('t_add4_p (%s)' % ps[1])
        sc.do('t_fin4 ()'); sc.do('t_fin4 ()')
        for _ in range(3):
            sc.do('(dd_hilab (d3lab_tyer (%s)); dd_nl ())' % ('d3lab_lab (%s, mklab (%d), ON_d2symopt ())' % (L(), R.randrange(3)) if R.random() < 0.5 else 'd3lab_ind (%s, %s)' % (L(), d3list(sc, 1, R.randrange(1, 3), 0.0))))
    F.append(('typ', fam_typ, 2))
    # ----------------------------------------------------------------------------------------------------------
    def after(sc, r, kind='hidexp'):
        sc.do('{ val r = %s val () = (dd_%s (r); dd_nl ()) val () = (fprint_%s (dd_out, r); dd_nl ()) val () = (print_%s (r); print_newline ()) val () = (prerr_%s (r); prerr_newline ()) %s }' % (
            r, kind, kind, kind, kind,
            ('val () = (dd_bool (hidexp_is_empty (r)); dd_ps " "; dd_bool (hidexp_is_value (r)); dd_ps " "; dd_bool (hidexp_is_lvalue (r)); dd_nl ())' if kind == 'hidexp' else '')))
    def fam_tye(sc, k):
        """d3exp_tyer on the trees of every constructor (the types come from the exemplars: the erasure of the types is exercised at every node)"""
        R = sc.R
        tycells(sc)
        forced = [kk for kk in range(48) if kk % 3 == k % 3] + ([100 + j for j in range(26)] if k % 3 == 0 else [])
        for kk in forced:
            e = sc.val(D3(sc, 2, 0.15, force=kk), 'd3exp')
            after(sc, 'd3exp_tyer (%s)' % e)
        for i in range(14):
            e = sc.val(D3(sc, 3, 0.15), 'd3exp')
            after(sc, 'd3exp_tyer (%s)' % e)
        for i in range(6):
            xs = d3list(sc, 2, R.randrange(5), 0.3)
            sc.do('(dd_hidexplst (d3explst_tyer (%s)); dd_nl ())' % xs)
        sc.do('(dd_hidexplst (d3explst_tyer (LN_d3explst ())); dd_nl ())')
        sc.do('(dd_hidexpopt (d3expopt_tyer (ON_d3expopt ())); dd_nl ())')
        sc.do('(dd_hidexpopt (d3expopt_tyer (OS_d3expopt (%s))); dd_nl ())' % D3(sc, 1))
        for i in range(5):
            ls = D3labs(sc, 1)
            sc.do('(dd_hilablst (d3lablst_tyer (%s)); dd_nl ())' % ls)
        sc.do('(dd_hilablst (d3lablst_tyer (LN_d3lablst ())); dd_nl ())')
        for v in sc.pool['d2var']: sc.do('chk_d2var (%s)' % v)
        for c in sc.pool['d2cst']: sc.do('chk_d2cst (%s)' % c)
    F.append(('tye', fam_tye, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_tyd(sc, k):
        """d3ecl_tyer / d3eclist_tyer(_errck): every declaration, the files that are staloaded"""
        R = sc.R
        tycells(sc)
        for i in range(8):
            dc = sc.val(DC(sc, 2), 'd3ecl')
            sc.do('{ val r = d3ecl_tyer (%s) val () = (dd_hidecl (r); dd_nl ()) val () = (fprint_hidecl (dd_out, r); dd_nl ()) }' % dc)
        for kk in range(22):
            if kk % 2 != k % 2: continue
            dc = sc.val(DC(sc, 2, force=kk), 'd3ecl')
            sc.do('{ val r = d3ecl_tyer (%s) val () = (dd_hidecl (r); dd_nl ()) val () = (fprint_hidecl (dd_out, r); dd_nl ()) val () = (print_hidecl (r); print_newline ()) val () = (prerr_hidecl (r); prerr_newline ()) val () = (dd_bool (hidecl_is_empty (r)); dd_nl ()) }' % dc)
        for i in range(6):
            dl = DL(sc, 2, R.randrange(5))
            sc.do('(dd_hideclist (d3eclist_tyer (%s)); dd_nl ())' % dl)
            sc.do('(dd_hideclist (t_errck (%s)); dd_nl ())' % DL(sc, 2, R.randrange(4)))
        sc.do('(dd_hideclist (d3eclist_tyer (LN_d3eclist ())); dd_nl ())')
        # a function declaration that is a proof (the error), then the finalization
        sc.do('(dd_hideclist (t_errck (%s)); dd_nl ())' % sc.lst('d3eclist', ['d3ecl_fundecs (%s, mkfunkind (2), LN_s2qualst (), %s)' % (sc.loc(), sc.lst('f3undeclst', ['f3undec_make (%s, %s, d3exp_var (%s, %s, %s))' % (sc.loc(), sc.pool['d2var'][0], sc.loc(), sc.typrf[0], sc.pool['d2var'][1])]))]))
        sc.do('(dd_hideclist (t_errck (%s)); dd_nl ())' % sc.lst('d3eclist', ['d3ecl_valdecs (%s, mkvalkind (0), %s)' % (sc.loc(), sc.lst('v3aldeclst', ['v3aldec_make (%s, p3at_any (%s, %s, %s), d3exp_empty (%s, %s))' % (sc.loc(), sc.loc(), sc.typrf[0], sc.pool['d2var'][0], sc.loc(), sc.typrf[1])]))]))
        # the files: [staload] with loaded = 0 erases the declarations of the file and stores the maps in the cells of the file environment
        sc.nostaload = True
        for i in range(1, 4):
            fe = 'mkfilenv (%d)' % i
            inner = sc.val(DL(sc, 2, 3) if i != 2 else sc.lst('d3eclist', ['d3ecl_impdec (%s, 1, i3mpdec_make (%s, %s, %s, %s, %s))' % (sc.loc(), sc.loc(), sc.pool['d2cst'][j % 3], sc.gv('s2varlst', 1), sc.lst('s2explstlst', [sc.lst('s2explst', [sc.ty['A']])]), D3(sc, 1)) for j in range(3)] +
                           ['d3ecl_fundecs (%s, mkfunkind (2), %s, %s)' % (sc.loc(), sc.lst('s2qualst', ['K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', [sc.pool['s2var'][0]])]), sc.lst('f3undeclst', ['f3undec_make (%s, %s, %s)' % (sc.loc(), v, D3(sc, 1)) for v in sc.pool['d2var'][:2]])),
                            'd3ecl_local (%s, %s, %s)' % (sc.loc(), sc.lst('d3eclist', ['d3ecl_impdec (%s, 0, i3mpdec_make (%s, %s, %s, %s, %s))' % (sc.loc(), sc.loc(), sc.pool['d2cst'][0], sc.gv('s2varlst', 1), sc.lst('s2explstlst', [sc.lst('s2explst', [sc.ty['B']])]), D3(sc, 1))]),
                              sc.lst('d3eclist', ['d3ecl_include (%s, 0, %s)' % (sc.loc(), sc.lst('d3eclist', ['d3ecl_impdec (%s, 1, i3mpdec_make (%s, %s, LN_s2varlst (), %s, %s))' % (sc.loc(), sc.loc(), sc.pool['d2cst'][1], sc.lst('s2explstlst', [sc.lst('s2explst', [sc.ty['aD']])]), D3(sc, 1))]))]))]), 'd3eclist')
            sc.do('t_fenv_set_d3cs (%s, %s)' % (fe, inner))
            for loaded in (0, 1, 0):
                dc = 'd3ecl_staload (%s, ON_symbolopt (), mkfil (0), 1, %s, %d)' % (sc.loc(), fe, loaded)
                sc.do('{ val r = d3ecl_tyer (%s) val () = (dd_hidecl (r); dd_nl ()) }' % dc)
                sc.do('(dd_tcmapopt (filenv_get_tmpcstimpmapopt (%s)); dd_nl ())' % fe)
                sc.do('(dd_tvmapopt (filenv_get_tmpvardecmapopt (%s)); dd_nl ())' % fe)
            sc.do('{ val o = filenv_get_tmpcstimpmapopt (%s) val () = (case+ t_tcmapopt_get (o) of ~Some_vt (m) => (%s) | ~None_vt () => dd_ps "none") val () = dd_nl () }' % (
                fe, '; '.join('dd_hiimpdeclst (t_tcmap_find (m, %s)); dd_ps "|"' % c for c in sc.pool['d2cst'])))
            sc.do('{ val o = filenv_get_tmpvardecmapopt (%s) val () = (case+ t_tvmapopt_get (o) of ~Some_vt (m) => (%s) | ~None_vt () => dd_ps "none") val () = dd_nl () }' % (
                fe, '; '.join('dd_optvt_hifundec (t_tvmap_find (m, %s)); dd_ps "|"' % v for v in sc.pool['d2var'])))
            sc.do('{ val r = d3ecl_tyer (d3ecl_staloadloc (%s, mkfil (0), mksym (2), %s)) val () = (dd_hidecl (r); dd_nl ()) }' % (sc.loc(), fe))
        sc.nostaload = False
        for v in sc.pool['d2var']: sc.do('chk_d2var (%s)' % v)
        for c in sc.pool['d2cst']: sc.do('chk_d2cst (%s)' % c)
    F.append(('tyd', fam_tyd, 2))


# ---------------------------------------------------------------------------------------------------------------------
# the cases that end the process (HDEXIT=k): the unsupported trees (exitloc), the MatchErrors of ATS1 (assertloc here), the internal errors
def exit_cases(ScH, G, R):
    """the functions hdx_k (): each builds the (small) values of its case and runs the operation that ends the process"""
    out = []
    def mk(k, body):
        sc = ScH(G, R, 'hdx_%d' % k)
        for _ in range(2): sc.new('s2var')
        for _ in range(2): sc.new('d2var')
        sc.new('s2cst'); sc.new('s2cst')
        c = sc.val('s2cst_make (mksym (1), mkloc (1), mkfil (0), s2rt_t0ype, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())', 's2cst')
        sc.A = sc.val('s2exp_cst (%s)' % c, 's2exp')
        sc.P = sc.val('s2exp_cst (%s)' % sc.val('s2cst_make (mksym (2), mkloc (2), mkfil (0), s2rt_prop, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())', 's2cst'), 's2exp')
        sc.dcn = sc.val('d2con_make (mkloc (1), mkfil (0), mksym (1), %s, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())' % c, 'd2con')
        sc.dc1 = sc.val('d2con_make (mkloc (2), mkfil (0), mksym (2), %s, 0, LN_s2qualst (), 1, LN_s2explst (), ON_s2explstopt ())' % c, 'd2con')
        sc.dcs = sc.val('d2cst_make (mksym (3), mkloc (3), mkfil (0), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (0))' % sc.A, 'd2cst')
        body(sc)
        out.append(sc.text())
    L = lambda sc: sc.loc()
    mk(1, lambda sc: sc.do('(dd_hipat (p3at_tyer (p3at_float (%s, %s, "1.5"))); dd_nl ())' % (L(sc), sc.A)))
    mk(2, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_literal (%s, %s, d3exp_int (%s, %s, 1)))); dd_nl ())' % (L(sc), sc.A, L(sc), sc.A)))
    mk(3, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_item (%s, %s, K_D2ITMvar (%s), LN_t2mpmarglst ()))); dd_nl ())' % (L(sc), sc.A, sc.pool['d2var'][0])))
    mk(4, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_scase (%s, %s, %s, LN_sc3laulst ()))); dd_nl ())' % (L(sc), sc.A, sc.A)))
    mk(5, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_viewat (%s, %s, d3exp_int (%s, %s, 1), LN_d3lablst ()))); dd_nl ())' % (L(sc), sc.A, L(sc), sc.A)))
    mk(6, lambda sc: sc.do('(dd_hipat (p3at_tyer (p3at_vbox (%s, %s, %s))); dd_nl ())' % (L(sc), sc.A, sc.pool['d2var'][0])))
    mk(7, lambda sc: sc.do('(dd_hipat (p3at_tyer (p3at_errpat (%s, %s))); dd_nl ())' % (L(sc), sc.A)))
    mk(8, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_arrinit (%s, %s, %s, d3exp_int (%s, %s, 1), LN_d3explst ()))); dd_nl ())' % (L(sc), sc.A, sc.A, L(sc), sc.A)))
    mk(9, lambda sc: sc.do('(dd_hidecl (d3ecl_tyer (d3ecl_staload (%s, ON_symbolopt (), mkfil (0), 1, mkfilenv (5), 0))); dd_nl ())' % L(sc)))
    mk(10, lambda sc: sc.do('(dd_hisexplst (d2cst_get2_type_arg (%s)); dd_nl ())' % sc.dcs) if False else (sc.do('d2cst_set2_hisexp (%s, OS_hisexpopt (hisexp_tybox))' % sc.dcs), sc.do('(dd_hisexplst (d2cst_get2_type_arg (%s)); dd_nl ())' % sc.dcs)))
    mk(11, lambda sc: (sc.do('d2cst_set2_hisexp (%s, OS_hisexpopt (hisexp_tybox))' % sc.dcs), sc.do('(dd_hisexp (d2cst_get2_type_res (%s)); dd_nl ())' % sc.dcs)))
    mk(12, lambda sc: sc.do('(dd_bool (d2cst_is_fun (%s)); dd_nl ())' % sc.dcs))
    mk(13, lambda sc: sc.do('(dd_hipatlst (p3atlst_tyer2 (LN_d3explst (), %s)); dd_nl ())' % sc.lst('p3atlst', ['p3at_any (%s, %s, %s)' % (L(sc), sc.A, sc.pool['d2var'][0])])))
    mk(14, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_lam_dyn (%s, %s, 0, 2, %s, d3exp_int (%s, %s, 1)))); dd_nl ())' % (L(sc), sc.A, sc.lst('p3atlst', ['p3at_any (%s, %s, %s)' % (L(sc), sc.A, sc.pool['d2var'][0])]), L(sc), sc.A)))
    mk(15, lambda sc: sc.do('(dd_hisexp (s2exp_tyer_deep (%s, s2exp_fun_srt (s2rt_t0ype, FUNCLOfun (), 0, s2eff_nil, 3, %s, %s))); dd_nl ())' % (L(sc), sc.lst('s2explst', [sc.A]), sc.A)))
    mk(16, lambda sc: sc.do('(dd_hisexp (s2exp_tyer_deep (%s, s2exp_tyrec_srt (s2rt_t0ype, K_TYRECKINDflt0 (), 2, %s))); dd_nl ())' % (L(sc), sc.lst('labs2explst', ['K_labs2exp (mklab (0), ON_stringopt (), %s)' % sc.A]))))
    mk(17, lambda sc: sc.do('(dd_hidexp (d3exp_tyer (d3exp_con (%s, %s, %s, 1, LN_d3explst ()))); dd_nl ())' % (L(sc), sc.A, sc.dc1)))
    mk(18, lambda sc: sc.do('(dd_hipat (p3at_tyer (p3at_con (%s, %s, mkpckind (0), %s, 1, LN_p3atlst ()))); dd_nl ())' % (L(sc), sc.A, sc.dc1)))
    mk(19, lambda sc: sc.do('(dd_hipat (p3at_tyer (p3at_rec (%s, %s, 0, 2, mkpckind (0), LN_labp3atlst ()))); dd_nl ())' % (L(sc), sc.A)))
    return out
