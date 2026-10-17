# the generator of the cases of the level-3 translation test, group 2 (called by g2_gen.py, see there and PORTING.md, "Level 3 translation, group 2")
#
# A scenario is a function (a block of 'val' statements) in the common subset of ATS1 and ATS2: it builds d2exp trees (directed: the expected
# types match or mismatch the shape of the expression, the pattern matrices are those of cg_pat.py), calls d2exp_trdn / p2at_trdn_con /
# d2exp_trup_applst_sym / c2laulst_trdn of the modules under test inside an environment (trans3_env, effects, linear variables), and dumps the
# d3exp result completely (dd_d3exp), the items of the environment (the constraints and hypotheses) and the state of the cells. The doubles of the
# other groups print their calls (g2env.tmpl). G2SEED and G2SCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True

SEED = int(os.environ.get('G2SEED', '1'))
SCALE = float(os.environ.get('G2SCALE', '3'))

PRES = ['s2rt_type', 's2rt_t0ype', 's2rt_prop', 's2rt_view', 's2rt_vtype']

def families(G, C, Sc3, T3C, d3order, d):
    import cg_pat, cg_cases
    F3 = T3C.families(G, C, Sc3, d3order, d)
    F = [f for f in F3 if f[0] == 'setup']
    # ------------------------------------------------------------------------------------------------------
    # the values
    def L(sc): return sc.loc()
    def S(sc, dep=1):
        # a type that the solver can handle (the random constants of the scenario have no [argsrtss]: the solver aborts on an application of them)
        R = sc.R
        c = R.randint(0, 9) if dep > 0 else R.randint(0, 6)
        if c == 0: return 's2exp_void_t0ype ()'
        if c == 1: return 's2exp_bool_t0ype ()'
        if c == 2: return 's2exp_exception_vtype ()'
        if c == 3: return 's2exp_bool_bool_t0ype (%s)' % R.choice(['true', 'false'])
        if c == 4: return 'K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 3)
        if c == 5: return 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % sc.handle('s2var')
        if c == 6: return 's2exp_bottom_t0ype_exi ()'
        if c == 7: return ty_tyrec(sc, sc.gv('tyreckind', 0), R.choice([0, 0, 1]), [S(sc, dep - 1) for _ in range(R.choice([1, 2]))])
        if c == 8: return ty_fun(sc, [S(sc, dep - 1) for _ in range(R.choice([0, 1, 2]))], S(sc, dep - 1), R.choice([0, 0, 1]), R.choice([0, 1]))
        return ty_exi(sc, S(sc, dep - 1))
    def e(sc, node, ty=None):
        x = sc.val('K_d2exp (%s, %s)' % (L(sc), node), 'd2exp')
        if ty is not None:
            x = sc.val('K_d2exp (%s, K_D2Eann_type (%s, %s))' % (L(sc), x, ty), 'd2exp')
        return x
    def leafe(sc, ty=None):
        return e(sc, 'K_D2Eint (%d)' % sc.R.randint(0, 9), ty)
    def leafv(sc, ty=None):
        # a typed leaf, or (one time in four) a linear variable of the scenario: d2exp_trup of the double consumes it
        if getattr(sc, 'vtys', None) and sc.R.random() < 0.25:
            return e(sc, 'K_D2Evar (%s)' % sc.R.choice(list(sc.vtys.keys())))
        return leafe(sc, ty)
    def tyc(sc, node, srt=None):
        return sc.val('K_s2exp (%s, %s)' % (srt or sc.R.choice(PRES), node), 's2exp')
    def ty_tyrec(sc, knd, npf, elts):
        fl = sc.lst('labs2explst', ['K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, t) for i, t in enumerate(elts)])
        return tyc(sc, 'K_S2Etyrec (%s, %d, %s)' % (knd, npf, fl), 's2rt_type')
    def ty_fun(sc, args, res, npf=0, lin=0, fc=None, eff=None):
        R = sc.R
        return tyc(sc, 'K_S2Efun (%s, %d, K_S2EFFset (%s), %d, %s, %s)' % (
            fc or 'mkfunclo (%d)' % R.randint(0, 3), lin, eff or 'mkeffset (%d)' % R.randint(0, 4), npf, sc.lst('s2explst', args), res), 's2rt_type')
    def ty_uni(sc, body, nv=None):
        R = sc.R
        vs = [sc.val('s2var_make_srt (%s)' % R.choice(PRES), 's2var') for _ in range(nv or R.choice([1, 2]))]
        return tyc(sc, 'K_S2Euni (%s, %s, %s)' % (sc.lst('s2varlst', vs), props(sc), body)), vs
    def ty_exi(sc, body):
        R = sc.R
        vs = [sc.val('s2var_make_srt (%s)' % R.choice(PRES), 's2var') for _ in range(R.choice([1, 2]))]
        return tyc(sc, 'K_S2Eexi (%s, %s, %s)' % (sc.lst('s2varlst', vs), props(sc), body))
    def ty_wth(sc, res):
        R = sc.R
        w = 'K_WTHS2EXPLSTnil ()'
        for _ in range(R.choice([0, 1, 2])):
            w = R.choice(['K_WTHS2EXPLSTcons_none (%s)' % w, 'K_WTHS2EXPLSTcons_invar (%d, %s, %s)' % (R.choice([0, 1]), S(sc, 0), w), 'K_WTHS2EXPLSTcons_trans (%d, %s, %s)' % (R.choice([0, 1]), S(sc, 0), w)])
        return tyc(sc, 'K_S2Ewthtype (%s, %s)' % (res, w))
    def ty_wth0(sc, res):
        # a wthtype without [invar]/[trans] entries (the arguments of the function need not be refargs: s2fun_opninv_and_add aborts otherwise)
        w = 'K_WTHS2EXPLSTnil ()'
        for _ in range(sc.R.choice([0, 1, 2])): w = 'K_WTHS2EXPLSTcons_none (%s)' % w
        return tyc(sc, 'K_S2Ewthtype (%s, %s)' % (res, w))
    def ty_boolidx(sc):
        R = sc.R
        c = R.randint(0, 3)
        if c == 0: return 's2exp_bool_bool_t0ype (true)'
        if c == 1: return 's2exp_bool_bool_t0ype (false)'
        if c == 2:
            v = sc.val('s2var_make_srt (s2rt_bool)', 's2var')
            return 's2exp_bool_index_t0ype (K_s2exp (s2rt_bool, K_S2Evar (%s)))' % v
        return 's2exp_bool_t0ype ()'
    def prop1(sc):
        R = sc.R
        if R.random() < 0.5: return 's2exp_bool (%s)' % R.choice(['true', 'false'])
        v = sc.val('s2var_make_srt (s2rt_bool)', 's2var')
        return 'K_s2exp (s2rt_bool, K_S2Evar (%s))' % v
    def props(sc):
        return sc.lst('s2explst', [prop1(sc) for _ in range(sc.R.choice([0, 1, 1, 2]))])
    def mixty(sc):
        R = sc.R
        c = R.randint(0, 5)
        if c == 0: return 's2exp_void_t0ype ()'
        if c == 1: return 's2exp_bool_t0ype ()'
        if c == 2: return 's2exp_exception_vtype ()'
        if c == 3: return ty_boolidx(sc)
        return S(sc)
    # ------------------------------------------------------------------------------------------------------
    # the environment of a call
    def prefix(sc, nlin=2):
        R = sc.R
        sc.pools()
        sc.do('trans3_env_push ()')
        sc.do('the_effenv_push_set (mkeffset (%d))' % R.choice([0, 1, 2, 3, 4]))
        sc.do('the_d2varenv_push_let ()')
        sc.do('the_pfmanenv_push_let ()')
        sc.vtys = {}
        for v in sc.pool['d2var'][:nlin]:
            sc.do('d2var_set_linval (%s, 0)' % v)
            ty = sc.val(S(sc, 1), 's2exp')
            sc.vtys[v] = ty
            sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, ty))
            sc.do('the_d2varenv_add_dvar (%s)' % v)
        # the arguments of an enclosing function (the wthtype of a result needs them: s2exp_wthtype_instantiate)
        fa = [sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var') for _ in range(2)]
        for v in fa:
            sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, S(sc, 0)))
            vv = sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var')
            sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (v, vv))
            sc.do('d2var_set_addr (%s, OS_s2expopt (%s))' % (v, S(sc, 0)))
        sc.do('the_lamlpenv_push_lam (%s)' % sc.lst('p3atlst', ['p3at_var (%s, %s, %s)' % (L(sc), S(sc, 0), v) for v in fa]))
    def suffix(sc):
        for v in sc.pool['d2var']: sc.do('chk_d2var (%s)' % v)
        sc.do('the_lamlpenv_pop ()')
        sc.do('the_pfmanenv_pop ()')
        sc.do('the_d2varenv_pop ()')
        sc.do('the_effenv_pop ()')
        sc.do('(g2_dd_items (trans3_env_pop ()); dd_nl ())')
        sc.do('t3chk ()')
    def run(sc, d2e, ty, fn='d2exp_trdn'):
        sc.say('-- ' + fn)
        v = sc.val('%s (%s, %s)' % (fn, d2e, ty), 'd3exp')
        sc.dd('d3exp', v)
        sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        return v
    def runh(sc, d2e, ty):
        """d2exp_trdn of the (expected) type that has been hnfized: the same function through s2exp2hnf"""
        return run(sc, d2e, ty)
    # ------------------------------------------------------------------------------------------------------
    def fam_dn_misc(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(3):
            ty = mixty(sc)
            run(sc, e(sc, 'K_D2Etop ()'), ty)
            run(sc, e(sc, 'K_D2Esing (%s)' % leafe(sc, mixty(sc))), mixty(sc))
            run(sc, e(sc, 'K_D2Eshowtype (%s)' % leafe(sc, mixty(sc))), mixty(sc))
            # a plain expression: typed leaf
            run(sc, leafe(sc, mixty(sc)), mixty(sc))
            run(sc, leafe(sc), mixty(sc))
            # with a wthtype (the state type): open/instantiate, funarg_d2vfin_check
            run(sc, leafe(sc, mixty(sc)), ty_wth(sc, mixty(sc)))
            run(sc, leafe(sc, ty_wth(sc, mixty(sc))), ty_wth(sc, mixty(sc)))
            # let / where
            ds = sc.gv('d2eclist', 1)
            run(sc, e(sc, 'K_D2Elet (%s, %s)' % (ds, leafe(sc, mixty(sc)))), mixty(sc))
            run(sc, e(sc, 'K_D2Ewhere (%s, %s)' % (leafe(sc, mixty(sc)), ds)), mixty(sc))
            # application of a non-macro, of a macro
            args = sc.lst('d2exparglst', ['K_D2EXPARGdyn (0, %s, %s)' % (L(sc), sc.lst('d2explst', [leafe(sc, mixty(sc))]))])
            run(sc, e(sc, 'K_D2Eapplst (%s, %s)' % (leafe(sc), args)), mixty(sc))
            run(sc, e(sc, 'K_D2Eapplst (%s, %s)' % (e(sc, 'K_D2Evar (%s)' % sc.handle('d2var')), args)), mixty(sc))
            # an identity macro: [macdef f (x) = ,(x)]: the result is the argument
            x = sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var')
            m = sc.val('d2mac_make (%s, %s, 0, %s, K_d2exp (%s, K_D2Emacsyn (mkmacsynkind (1), K_d2exp (%s, K_D2Evar (%s)))))' % (
                L(sc), sc.leaf('symbol'), sc.lst('m2acarglst', ['K_M2ACARGdyn (%s)' % sc.lst('d2varlst', [x])]), L(sc), L(sc), x), 'd2mac')
            marg = leafe(sc, mixty(sc))
            ma = sc.lst('d2exparglst', ['K_D2EXPARGdyn (0, %s, %s)' % (L(sc), sc.lst('d2explst', [marg]))])
            run(sc, e(sc, 'K_D2Eapplst (%s, %s)' % (e(sc, 'K_D2Emac (%s)' % m), ma)), mixty(sc))
        suffix(sc)
    F.append(('dn_misc', fam_dn_misc, 3))
    def fam_dn_lists(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(3):
            ty = mixty(sc)
            es = sc.lst('d2explst', [leafe(sc, mixty(sc)) for _ in range(R.choice([0, 1, 2, 3]))])
            sc.say('-- d2explst_trdn_elt')
            sc.dd('d3explst', 'd2explst_trdn_elt (%s, %s)' % (es, ty))
            sc.say('-- d2expopt_trdn_elt')
            sc.dd('d3expopt', 'd2expopt_trdn_elt (ON_d2expopt (), %s)' % ty)
            sc.dd('d3expopt', 'd2expopt_trdn_elt (OS_d2expopt (%s), %s)' % (leafe(sc, mixty(sc)), ty))
            sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        suffix(sc)
    F.append(('dn_lists', fam_dn_lists, 1))
    # ------------------------------------------------------------------------------------------------------
    def fam_dn_tup(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(4):
            n = R.choice([0, 1, 2, 3])
            knds = ['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()']
            # the expression: knd 0 flat / 1 boxed / 2 linear boxed, npf
            ek = R.choice([0, 1, 2]); enpf = R.choice([0, 0, 1])
            elts = [leafe(sc, mixty(sc)) for _ in range(n)]
            # the type: same arity, or one more / fewer
            m = n + R.choice([0, 0, 0, 1, -1])
            if m < 0: m = 0
            tys = [mixty(sc) for _ in range(m)]
            tk = R.choice(knds) if R.random() < 0.4 else sc.gv('tyreckind', 0)
            ty = ty_tyrec(sc, tk, enpf if R.random() < 0.7 else 1 - enpf, tys)
            run(sc, e(sc, 'K_D2Etup (%d, %d, %s)' % (ek, enpf, sc.lst('d2explst', elts))), ty)
            run(sc, e(sc, 'K_D2Elist (%d, %s)' % (enpf, sc.lst('d2explst', elts))), ty)
            run(sc, e(sc, 'K_D2Etup (%d, %d, %s)' % (ek, enpf, sc.lst('d2explst', elts))), mixty(sc))
            # records
            ls = ['K_labd2exp (l0ab_make_label (%s, mklab (%d)), %s)' % (L(sc), i, x) for i, x in enumerate(elts)]
            run(sc, e(sc, 'K_D2Erec (%d, %d, %s)' % (ek, enpf, sc.lst('labd2explst', ls))), ty)
            run(sc, e(sc, 'K_D2Erec (%d, %d, %s)' % (ek, enpf, sc.lst('labd2explst', ls))), mixty(sc))
            # sequences
            sq = [leafe(sc, mixty(sc)) for _ in range(R.choice([0, 1, 2, 3]))]
            run(sc, e(sc, 'K_D2Eseq (%s)' % sc.lst('d2explst', sq)), mixty(sc))
        suffix(sc)
    F.append(('dn_tup', fam_dn_tup, 3))
    # ------------------------------------------------------------------------------------------------------
    def fam_dn_other(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(3):
            # raise, effmask
            for efk in (0, 1, 3):
                sc.do('the_effenv_push_set (mkeffset (%d))' % efk)
                run(sc, e(sc, 'K_D2Eraise (%s)' % leafe(sc, mixty(sc))), mixty(sc))
                sc.do('the_effenv_pop ()')
            run(sc, e(sc, 'K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), leafe(sc, mixty(sc)))), mixty(sc))
            # exist: the expected type is an existential (or a wthtype of one), or not
            sa = sc.gv('s2exparg', 1)
            run(sc, e(sc, 'K_D2Eexist (%s, %s)' % (sa, leafe(sc, mixty(sc)))), ty_exi(sc, mixty(sc)))
            run(sc, e(sc, 'K_D2Eexist (%s, %s)' % (sa, leafe(sc, mixty(sc)))), ty_wth(sc, ty_exi(sc, mixty(sc))))
            run(sc, e(sc, 'K_D2Eexist (%s, %s)' % (sa, leafe(sc, mixty(sc)))), mixty(sc))
            # delay, ldelay (the type is lazy_vt or not)
            run(sc, e(sc, 'K_D2Edelay (%s)' % leafe(sc, mixty(sc))), mixty(sc))
            run(sc, e(sc, 'K_D2Eldelay (%s, ON_d2expopt ())' % leafe(sc, mixty(sc))), mixty(sc))
            lz = tyc(sc, 'K_S2Eapp (s2exp_cst (%s), %s)' % ('s2cstref_get_cst (the_lazy_vt0ype_vtype)', sc.lst('s2explst', [mixty(sc)])), 's2rt_vtype')
            run(sc, e(sc, 'K_D2Eldelay (%s, OS_d2expopt (%s))' % (leafe(sc, mixty(sc)), leafe(sc))), lz)
            # trywith: the clauses are over exceptions
            ncl = R.choice([0, 1, 2])
            cl = [sc.val('K_c2lau (%s, %s, LN_gm2atlst (), %d, %d, %s)' % (L(sc), sc.lst('p2atlst', ['p2at_any (%s)' % L(sc)]), R.choice([0, 1]), R.choice([0, 0, 1]), leafe(sc, mixty(sc))), 'c2lau') for _ in range(ncl)]
            run(sc, e(sc, 'K_D2Etrywith (i2nvresstate_nil, %s, %s)' % (leafe(sc, mixty(sc)), sc.lst('c2laulst', cl))), mixty(sc))
        suffix(sc)
    F.append(('dn_other', fam_dn_other, 2))
    # ------------------------------------------------------------------------------------------------------
    def fam_dn_lam(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(5):
            na = R.choice([0, 1, 2, 3])
            pats = ['p2at_any (%s)' % L(sc) if R.random() < 0.5 else 'p2at_var (%s, %s)' % (L(sc), sc.handle('d2var')) for _ in range(na)]
            body = leafv(sc, mixty(sc)) if R.random() < 0.7 else e(sc, 'K_D2Eraise (%s)' % leafe(sc, 's2exp_exception_vtype ()'))
            # annotations on the body: funclo, effect
            if R.random() < 0.4: body = e(sc, 'K_D2Eann_funclo (%s, mkfunclo (%d))' % (body, R.randint(0, 3)))
            if R.random() < 0.4: body = e(sc, 'K_D2Eann_seff (%s, K_S2EFFset (mkeffset (%d)))' % (body, R.randint(0, 4)))
            if R.random() < 0.2: body = e(sc, 'K_D2Eann_seff (%s, K_S2EFFset (mkeffset (%d)))' % (e(sc, 'K_D2Eann_funclo (%s, mkfunclo (%d))' % (body, R.randint(0, 3))), R.randint(0, 4)))
            lin = R.choice([0, 0, 1]); npf = R.choice([0, 0, 1])
            lam = e(sc, 'K_D2Elam_dyn (%d, %d, %s, %s)' % (lin, npf, sc.lst('p2atlst', pats), body))
            # the types: matching, wrong arity, wrong npf / linearity, wrapped in a universal / refarg, not a function
            nt = na + R.choice([0, 0, 0, 1, -1])
            if nt < 0: nt = 0
            args = [mixty(sc) for _ in range(nt)]
            res = mixty(sc)
            fty = ty_fun(sc, args, res, npf if R.random() < 0.8 else 1 - npf, lin if R.random() < 0.8 else 1 - lin)
            run(sc, lam, fty)
            uty, vs = ty_uni(sc, fty)
            run(sc, lam, uty)
            run(sc, lam, tyc(sc, 'K_S2Erefarg (%d, %s)' % (R.choice([0, 1]), fty)))
            run(sc, lam, tyc(sc, 'K_S2Erefarg (%d, %s)' % (R.choice([0, 1]), uty)))
            run(sc, lam, mixty(sc))
            # a static lambda with no variable, with variables
            ps = props(sc)
            ty2, vs2 = ty_uni(sc, mixty(sc))
            run(sc, e(sc, 'K_D2Elam_sta (LN_s2varlst (), %s, %s)' % (ps, leafe(sc, mixty(sc)))), ty2)
            run(sc, e(sc, 'K_D2Elam_sta (LN_s2varlst (), %s, %s)' % (ps, leafe(sc, mixty(sc)))), mixty(sc))
            run(sc, e(sc, 'K_D2Elam_sta (%s, %s, %s)' % (sc.lst('s2varlst', vs2[:1]), ps, leafe(sc, mixty(sc)))), ty2)
        suffix(sc)
    F.append(('dn_lam', fam_dn_lam, 3))
    # ------------------------------------------------------------------------------------------------------
    def invres(sc):
        R = sc.R
        if R.random() < 0.6: return 'i2nvresstate_nil'
        vs = list(sc.vtys.keys())
        # the invariants give the types that the linear variables have (a different type is an error of the merge: the environment aborts then)
        arg = sc.lst('i2nvarglst', ['i2nvarg_make (%s, OS_s2expopt (%s))' % (v, sc.vtys[v]) for v in R.sample(vs, R.choice([0, 1, 2]))])
        return 'K_i2nvresstate (%s, %s, %s, ON_s2explstopt ())' % (sc.lst('s2varlst', sc.pool['s2var'][:R.choice([0, 1])]), props(sc), arg)
    def fam_dn_if(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(4):
            ty = mixty(sc)
            cnd = leafe(sc, ty_boolidx(sc) if R.random() < 0.8 else mixty(sc))
            th = leafv(sc, mixty(sc))
            el = 'OS_d2expopt (%s)' % leafv(sc, mixty(sc)) if R.random() < 0.6 else 'ON_d2expopt ()'
            run(sc, e(sc, 'K_D2Eifhead (%s, %s, %s, %s)' % (invres(sc), cnd, th, el)), ty)
            # static conditional
            run(sc, e(sc, 'K_D2Esifhead (%s, %s, %s, %s)' % (invres(sc), prop1(sc), th, leafv(sc, mixty(sc)))), ty)
            run(sc, e(sc, 'K_D2Esifhead (%s, %s, %s, %s)' % (invres(sc), prop1(sc), th, leafv(sc, mixty(sc)))), ty)
            # ifcase: 0..4 clauses, tests typed boolean or [D2Etop]
            cls = []
            for _ in range(R.choice([1, 1, 2, 3, 4])):
                tst = e(sc, 'K_D2Etop ()') if R.random() < 0.3 else leafe(sc, ty_boolidx(sc) if R.random() < 0.85 else mixty(sc))
                cls.append(sc.val('K_i2fcl (%s, %s, %s)' % (L(sc), tst, leafv(sc, mixty(sc))), 'i2fcl'))
            run(sc, e(sc, 'K_D2Eifcasehd (%d, %s, %s)' % (R.choice([0, 1]), invres(sc), sc.lst('i2fclist', cls))), ty)
        suffix(sc)
    F.append(('dn_if', fam_dn_if, 3))
    # ------------------------------------------------------------------------------------------------------
    # case expressions: the matrices of cg_pat.py
    def fam_dn_case(sc, k):
        R = sc.R
        prefix(sc)
        sc.do('g2_init_universe ()')
        sc.do('cg_env_clear ()')
        U = cg_pat.Uni(sc, R.choice([1, 2, 3]))
        for rep in range(3):
            ncol = R.choice([1, 1, 2])
            tys = [cg_pat.rand_type(R, len(U.dts), 1) for _ in range(ncol)]
            ncl = R.choice([0, 1, 1, 2, 3, 4, 5])
            cls = []
            def clause(U, tys, dd, chaos, guard=0.2):
                pats = [cg_pat.gen_pat(sc, U, t, dd, chaos, top=True) for t in tys]
                r = R.random()
                gx = leafe(sc, ty_boolidx(sc))
                if r < guard / 2: gua = sc.lst('gm2atlst', ['K_gm2at (%s, %s, ON_p2atopt ())' % (L(sc), gx)])
                elif r < guard: gua = sc.lst('gm2atlst', ['K_gm2at (%s, %s, OS_p2atopt (p2at_any (%s)))' % (L(sc), gx, L(sc))] + (['K_gm2at (%s, %s, ON_p2atopt ())' % (L(sc), leafe(sc, ty_boolidx(sc)))] if R.random() < 0.5 else []))
                else: gua = 'LN_gm2atlst ()'
                return sc.val('K_c2lau (%s, %s, %s, %d, %d, %s)' % (L(sc), sc.lst('p2atlst', pats), gua, R.choice([0, 1]), R.choice([0, 0, 1]), leafv(sc, mixty(sc))), 'c2lau')
            for i in range(ncl):
                tys1 = tys
                if R.random() < 0.08: tys1 = tys + [('int',)] if R.random() < 0.5 else tys[:-1]   # an arity error
                cls.append(clause(U, tys1, R.choice([1, 2, 2]), R.choice([0, 0, 0.1])))
            if R.random() < 0.3 and ncl > 0:
                cls.append(clause(U, [('int',)] * ncol, 0, 0.0, 0.0))
            # the scrutinees: typed leaves
            scr = [leafe(sc, ty_exi(sc, mixty(sc)) if R.random() < 0.4 else mixty(sc)) for _ in range(ncol)]
            knd = R.choice([0, 1, 1, 2])
            ch = e(sc, 'K_D2Ecasehead (mkcaskind (%d), %s, %s, %s)' % (knd, invres(sc), sc.lst('d2explst', scr), sc.lst('c2laulst', cls)))
            rty = mixty(sc)
            for efk in (0, 1):
                sc.do('the_effenv_push_set (mkeffset (%d))' % efk)
                run(sc, ch, rty)
                sc.do('the_effenv_pop ()')
        # static case
        for rep in range(2):
            sl = []
            for _ in range(R.choice([1, 2, 3])):
                sp = sc.gv('sp2at', 1)
                sl.append(sc.val('K_sc2lau (%s, %s, %s)' % (L(sc), sp, leafv(sc, mixty(sc))), 'sc2lau'))
            run(sc, e(sc, 'K_D2Escasehead (%s, %s, %s)' % (invres(sc), S(sc, 1), sc.lst('sc2laulst', sl))), mixty(sc))
        suffix(sc)
    F.append(('dn_case', fam_dn_case, 4))
    # ------------------------------------------------------------------------------------------------------
    # constructor patterns (p2at_trdn_con): the constructors of datatypes, every decoration, the expected type is the datatype, a constructor type, an
    # existential, or something else
    def fam_patcon(sc, k):
        R = sc.R
        prefix(sc)
        for rep in range(3):
            ncon = R.choice([1, 2, 3])
            cons = [('Con%d' % j, R.choice([0, 1, 2, 3]), R.choice([0, 0, 1]), j) for j in range(ncon)]
            c, ds = cg_cases.mk_dat(sc, 'dt%d' % rep, cons)
            for j, d2c in enumerate(ds):
                nargs = cons[j][1]
                for rep2 in range(3):
                    na = nargs + R.choice([0, 0, 0, 1, -1])
                    if na < 0: na = 0
                    subs = []
                    def mkvar():
                        v = sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var')
                        ty = sc.val(S(sc, 1), 's2exp')
                        sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, ty))
                        sc.do('d2var_set_mastype (%s, OS_s2expopt (%s))' % (v, ty))
                        sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([-1, 0, 0])))
                        return v
                    for i in range(na):
                        r = R.random()
                        if r < 0.3:
                            # a nested constructor pattern (p2at_trdn of the double calls p2at_trdn_con): its decoration and arity at random
                            j2 = R.randrange(len(ds))
                            na2 = cons[j2][1] + R.choice([0, 0, 0, 1, -1])
                            if na2 < 0: na2 = 0
                            nsubs = ['p2at_any (%s)' % L(sc) if R.random() < 0.5 else 'p2at_var (%s, %s)' % (L(sc), mkvar()) for _ in range(na2)]
                            subs.append('p2at_con (%s, mkpckind (%d), %s, LN_s2qualst (), d2con_get_type (%s), %d, %s)' % (L(sc), R.randint(0, 3), ds[j2], ds[j2], R.choice([0, 0, 1]), sc.lst('p2atlst', nsubs)))
                        elif r < 0.4: subs.append('p2at_any (%s)' % L(sc))
                        elif r < 0.5: subs.append('p2at_int (%s, %d)' % (L(sc), R.randint(0, 3)))
                        elif r < 0.8: subs.append('p2at_var (%s, %s)' % (L(sc), mkvar()))
                        else: subs.append('p2at_refas (%s, %s, p2at_any (%s))' % (L(sc), mkvar(), L(sc)))
                    qua = 'LN_s2qualst ()'
                    if R.random() < 0.4:
                        qv = [sc.val('s2var_make_srt (%s)' % R.choice(PRES), 's2var') for _ in range(R.choice([1, 2]))]
                        qua = sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', qv), props(sc))])
                    pck = R.randint(0, 3)
                    econ = 'd2con_get_type (%s)' % d2c if R.random() < 0.85 else mixty(sc)
                    p2t = sc.val('p2at_con (%s, mkpckind (%d), %s, %s, %s, %d, %s)' % (L(sc), pck, d2c, qua, econ, R.choice([0, 0, 1]), sc.lst('p2atlst', subs)), 'p2at')
                    targs = sc.lst('s2explst', [S(sc, 0) for _ in range(R.choice([nargs, nargs, nargs + 1]))])
                    tys = ['s2exp_cst (%s)' % c,
                           tyc(sc, 'K_S2Edatcontyp (%s, %s)' % (d2c, targs), 's2rt_type'),
                           ty_exi(sc, 's2exp_cst (%s)' % c),
                           ty_wth(sc, 's2exp_cst (%s)' % c) if R.random() < 0.3 else mixty(sc),
                           tyc(sc, 'K_S2Edatcontyp (%s, %s)' % (sc.pool['d2con'][0], targs), 's2rt_type')]
                    for ty in R.sample(tys, R.choice([2, 3, 4])):
                        sc.say('-- p2at_trdn_con')
                        v = sc.val('p2at_trdn_con (%s, s2exp2hnf (%s))' % (p2t, ty), 'p3at')
                        sc.dd('p3at', v)
                        sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        suffix(sc)
    F.append(('patcon', fam_patcon, 4))
    # ------------------------------------------------------------------------------------------------------
    # overloaded symbols (appsym)
    def fam_appsym(sc, k):
        R = sc.R
        prefix(sc)
        inv = ty_exi(sc, 's2exp_void_t0ype ()')
        T = ['s2exp_void_t0ype ()', 's2exp_bool_t0ype ()', 's2exp_exception_vtype ()', 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % sc.pool['s2var'][0],
             'K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 1), 'K_s2exp (s2rt_t0ype, K_S2Einvar (%s))' % inv]
        T = [sc.val(t, 's2exp') for t in T]
        for rep in range(6):
            ngrp = R.choice([0, 1, 1, 2])
            kind = R.choice([0, 0, 1, 2, 2])
            npfs = [1, 1, 0] if kind == 2 else [0, 0, 1]
            # the groups of the call: the types of the arguments, npf
            gtys = [[R.choice(T) for _ in range(R.choice([0, 1, 2]))] for _ in range(ngrp)]
            gnpf = [min(len(g), R.choice(npfs)) for g in gtys]
            root_ty = R.choice(T)
            # the groups as the symbol resolution sees them: [d2exp_trup_applst_seloverld] inserts the root at the position npf of the first dynamic group
            seen = [list(g) for g in gtys]; seen_npf = list(gnpf)
            if kind == 2:
                if ngrp == 0: seen = [[root_ty]]; seen_npf = [-1]
                else: seen[0] = seen[0][:gnpf[0]] + [root_ty] + seen[0][gnpf[0]:]
            def mkty(gs, gn, i, vary):
                if i >= len(gs): return ty_wth0(sc, R.choice(T)) if R.random() < 0.2 else R.choice(T)
                args = list(gs[i]); npf = gn[i]
                if vary and R.random() < 0.5: args = [R.choice(T) for _ in range(R.choice([0, 1, 2]))]; npf = min(len(args), R.choice([0, 1]))
                return ty_fun(sc, args, mkty(gs, gn, i + 1, vary), npf, R.choice([0, 0, 1]))
            items = []
            for ic in range(R.choice([1, 2, 3, 4])):
                r = R.random()
                # the candidates have the shape of the call (and often its types), or a variation of it
                fty = mkty(seen, seen_npf, 0, R.random() < 0.35)
                if R.random() < 0.3:
                    fty, vs = ty_uni(sc, fty)
                if R.random() < 0.15:
                    fty = tyc(sc, 'K_S2Emetfun (ON_stampopt (), %s, %s)' % (sc.lst('s2explst', ['K_s2exp (s2rt_int, K_S2Eint (1))']), fty), 's2rt_type')
                pval = R.choice([0, 0, 1, 2])
                if r < 0.65:
                    qs = 'LN_s2qualst ()'
                    cst = sc.val('d2cst_make (%s, %s, mkfil (0), mkdcstkind (0), %s, LN_intlst (), %s, mkdcstextdef (0))' % (sc.leaf('symbol'), L(sc), qs, fty), 'd2cst')
                    items.append(('K_D2ITMcst (%s)' % cst, pval))
                    if R.random() < 0.25: items.append(('K_D2ITMcst (%s)' % cst, pval))   # a duplicate (the removal of duplicates)
                elif r < 0.9:
                    v = sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var')
                    sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, fty))
                    items.append(('K_D2ITMvar (%s)' % v, pval))
                    if R.random() < 0.3: items.append(('K_D2ITMvar (%s)' % v, pval))
                    if R.random() < 0.2 and len(items) > 1: items.append(items[0])   # a duplicate of an item of the other kind
                elif r < 0.95 and ngrp > 0:
                    items.append(('K_D2ITMmacvar (%s)' % sc.handle('d2var'), pval))   # not a function item: an error (excluded by the arity test)
                else:
                    # a nested list of overloads
                    cst = sc.val('d2cst_make (%s, %s, mkfil (0), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (0))' % (sc.leaf('symbol'), L(sc), fty), 'd2cst')
                    items.append(('K_D2ITMsymdef (%s, %s)' % (sc.leaf('symbol'), sc.lst('d2pitmlst', ['K_D2PITM (%d, K_D2ITMcst (%s))' % (pval, cst)])), pval))
            d2s = sc.val('d2sym_make (%s, %s, %s, %s)' % (L(sc), sc.leaf('d0ynq'), sc.leaf('symbol'), sc.lst('d2pitmlst', ['K_D2PITM (%d, %s)' % (pv, it) for it, pv in items])), 'd2sym')
            grps = []
            if R.random() < 0.2: grps.append('K_D2EXPARGsta (%s, %s)' % (L(sc), sc.gv('s2exparglst', 1)))
            for g, npf in zip(gtys, gnpf):
                grps.append('K_D2EXPARGdyn (%d, %s, %s)' % (npf, L(sc), sc.lst('d2explst', [leafe(sc, t) for t in g])))
            d2as = sc.lst('d2exparglst', grps)
            d2e0 = e(sc, 'K_D2Eapplst (%s, %s)' % (e(sc, 'K_D2Esym (%s)' % d2s), d2as))
            sc.say('-- applst_sym %d' % kind)
            sc.dd('d2sym', d2s); sc.dd('d2exparglst', d2as)
            if kind == 0: v = sc.val('d2exp_trup_applst_sym (%s, %s, %s)' % (d2e0, d2s, d2as), 'd3exp')
            elif kind == 1: v = sc.val('d2exp_trup_applst_tmpsym (%s, %s, %s, %s)' % (d2e0, d2s, sc.gv('t2mpmarglst', 1), d2as), 'd3exp')
            else:
                root = leafe(sc, root_ty)
                fn = e(sc, 'K_D2Eselab (%s, %s)' % (root, sc.lst('d2lablst', ['d2lab_lab (%s, %s, ON_d2symopt ())' % (L(sc), sc.leaf('label'))])))
                v = sc.val('d2exp_trup_applst_seloverld (%s, %s, %s, %s)' % (d2e0, fn, d2s, d2as), 'd3exp')
            sc.dd('d3exp', v)
            sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        suffix(sc)
    F.append(('appsym', fam_appsym, 6))
    # ------------------------------------------------------------------------------------------------------
    # the process ends: a linear function that uses a linear variable of the outside (the_d2varenv_check_llam exits). The scenario is the last one and runs
    # only when the environment variable CG_ERRTEST is 1 (g2cmp.sh); the stdout and stderr up to the exit and the exit status are compared
    def fam_exit(sc, k):
        R = sc.R
        prefix(sc)
        # a linear variable that no frame of the environment owns: the double reports it, and it stays linear in the list of the function
        x = sc.val('d2var_make (%s, %s)' % (L(sc), sc.leaf('symbol')), 'd2var')
        sc.do('d2var_set_linval (%s, 0)' % x)
        sc.do('d2var_set_type (%s, OS_s2expopt (s2exp_exception_vtype ()))' % x)
        T1 = sc.val('s2exp_bool_t0ype ()', 's2exp')
        lam = e(sc, 'K_D2Elam_dyn (1, 0, %s, %s)' % (sc.lst('p2atlst', ['p2at_any (%s)' % L(sc)]), e(sc, 'K_D2Evar (%s)' % x)))
        fty = ty_fun(sc, [T1], T1, 0, 1)
        run(sc, lam, fty)
        sc.say('not reached')
        suffix(sc)
    F.append(('exit_llam', fam_exit, 0))
    return F

def main(G, C, T3C, d3order, d):
    Sc3 = T3C.build(G, C)
    F = families(G, C, Sc3, T3C, d3order, d)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = Sc3(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = T3C.wrap_text(sc.text())
        if sc.name.startswith('sc_exit'):
            t = t.replace('fun %s (): void' % sc.name, 'fun %s_body (): void' % sc.name) + 'fun %s (): void = if cg_getenv_int () = 1 then %s_body () else ()\n' % (sc.name, sc.name)
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1200 or sc.name.startswith('sc_setup'):
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    write_chunks(d, C, bodies)
    print('g2_cases: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

def write_chunks(d, C, chunks):
    put = C.put
    for f in os.listdir(d):
        m = re.match(r'^(?:g2case_|g2case1_|g2cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'g2cases_%02d.hats' % k
        put(os.path.join(d, cases), body)
        put(os.path.join(d, 'g2case_%02d.dats' % k),
            '(* generated by g2_gen.py: the chunk %d of the cases of the level-3 translation test, group 2 (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "g2case_pre.hats"\n'
            'extern fun g2tc%d_all (): void = "ext#g2tc_%d"\n#include "%s"\nimplement g2tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        put(os.path.join(d, 'g2case1_%02d.dats' % k),
            '(* generated by g2_gen.py: the chunk %d of the cases of the level-3 translation test, group 2 (ATS1) *)\n#include "g2case_pre1.hats"\n'
            'extern fun g2tc%d_all (): void = "g2tc_%d"\n#include "%s"\nimplement g2tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun g2tc%d_all (): void = "ext#g2tc_%d"\n' % (k, k))
        ch1.append('extern fun g2tc%d_all (): void = "g2tc_%d"\n' % (k, k))
    call = 'fun g2tc_all (): void = {\n' + ''.join('  val () = g2tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    put(os.path.join(d, 'g2chunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 'g2chunks1.hats'), ''.join(ch1) + call)
