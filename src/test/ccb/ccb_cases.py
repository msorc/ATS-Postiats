# the generator of the cases of the test of ccomp group B (called by ccb_gen.py, see there and PORTING.md "ccomp group B")
#
# A scenario is a function (a block of 'val' statements) that creates cells (s2var, s2cst, d2var, d2cst, d2con, funlab), builds values of the types of the specs
# (the wrappers K_x and the typed lists/options of the compat layers, the smart constructors of the sats) and calls the functions of the modules under test,
# dumping every result completely. The machinery is that of d2_cases.py / hd_cases.py (class Sc, ScH). CCBSEED and CCBSCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
import hd_cases, hd_ty

SEED = int(os.environ.get('CCBSEED', '1'))
SCALE = float(os.environ.get('CCBSCALE', '3'))

def build(G, C):
    ScH = hd_cases.build(G, C)

    class ScC(ScH):
        def leaf(self, t):
            if t == 'funlab': return self.handle('funlab', 0.0)
            if t == 'tmpvar': return self.handle('tmpvar', 0.0)
            return ScH.leaf(self, t)
        def hse(self, d=2):
            return ScH.hse(self, d).replace('hisexp_tyclo (', 'ccb_tyclo (')
        def refas(self):
            V = self.pool['d2var']; R = self.R; L = self.loc(); H = self.hse(1)
            inner = R.choice(['hipat_var', 'hipat_any'])
            return 'hipat_refas (%s, %s, %s, %s (%s, %s, %s))' % (L, H, R.choice(V), inner, self.loc(), self.hse(1), R.choice(V))
        def Pt(self):
            for _ in range(30):
                e = self.P(0)
                if 'hipat_float' not in e and 'hipat_refas' not in e: return e
            return 'hipat_empty (%s, %s)' % (self.loc(), self.hse(1))
        def Pnf(self, d=2):
            R = self.R
            t = R.random()
            if t < 0.12: return self.refas()
            if t < 0.22:
                return 'hipat_rec (%s, %s, %d, %s, %s, %s)' % (self.loc(), self.hse(1), R.randrange(2), self.pck(), self.lstx('labhipatlst', ['K_labhipat (%s, %s)' % (self.lab(), self.refas()), 'K_labhipat (%s, %s)' % (self.lab(), self.Pt())]), self.hse(1))
            if t < 0.32:
                return 'hipat_con (%s, %s, %s, %s, %s, %s)' % (self.loc(), self.hse(1), self.pck(), self.con(), self.hse(1), self.lstx('labhipatlst', ['K_labhipat (%s, %s)' % (self.lab(), self.refas())]))
            for _ in range(30):
                e = self.P(d)
                if 'hipat_float' not in e and 'hipat_refas' not in e: return e
            return 'hipat_empty (%s, %s)' % (self.loc(), self.hse(1))
        def new_funlab(self):
            R = self.R
            return self.val('ccb_mkfunlab (%d, %d, %s)' % (R.randrange(10), R.randrange(3), R.choice(['hisexp_funptr', 'hisexp_cloptr', 'hisexp_clotyp'])), 'funlab')
        def new_tmpvar(self):
            R = self.R
            return self.val('tmpvar_make (%s, %s)' % (self.loc(), self.hse(1)), 'tmpvar')
        # ---- the cells of the type tests
        def tcells(self):
            """s2var, s2cst (data types and others), d2con (con / tagless / exn), funlab"""
            R = self.R
            for _ in range(4): self.new('s2var')
            for _ in range(3): self.new('s2cst')
            dts = []
            for i in range(3):
                dts.append(self.val('s2cst_make (mksym (%d), mkloc (%d), mkfil (0), s2rt_t0ype, ON_s2expoptopt (), %s, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())'
                                    % (i + 1, i, ['true', 'true', 'false'][i]), 's2cst'))
            self.dts = dts
            self.tvs = [self.val('s2var_make_srt (%s)' % s, 's2var') for s in ('s2rt_type', 's2rt_vtype', 's2rt_t0ype', 's2rt_vt0ype')]
            self.fcs = [self.val('s2cst_make (mksym (%d), mkloc (%d), mkfil (0), %s, ON_s2expoptopt (), %s, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())'
                                 % (i + 5, i, hd_ty.SORT_F1, ['true', 'false'][i]), 's2cst') for i in range(2)]
            nilc = self.val('d2con_make (mkloc (1), mkfil (0), mksym (1), %s, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())' % dts[0], 'd2con')
            consc = self.val('d2con_make (mkloc (2), mkfil (0), mksym (2), %s, 0, LN_s2qualst (), 2, LN_s2explst (), ON_s2explstopt ())' % dts[0], 'd2con')
            # dts[0] is list-like: its constructors are tagless
            self.do('s2cst_set_islst (%s, OS_d2conpairopt (K_d2conpair (%s, %s)))' % (dts[0], nilc, consc))
            tg = self.val('d2con_make (mkloc (3), mkfil (0), mksym (3), %s, 0, LN_s2qualst (), 1, LN_s2explst (), ON_s2explstopt ())' % dts[1], 'd2con')
            ex = self.val('d2con_make (mkloc (4), mkfil (0), mksym (4), %s, 0, LN_s2qualst (), 1, LN_s2explst (), ON_s2explstopt ())' % dts[2], 'd2con')
            self.do('d2con_set_tag (%s, 0)' % nilc); self.do('d2con_set_tag (%s, 1)' % consc)
            self.do('d2con_set_tag (%s, 2)' % tg); self.do('d2con_set_tag (%s, ~1)' % ex)
            self.pool['d2con'] = [nilc, consc, tg, ex]
            for i in range(4): self.new('funlab')
        def hsx(self, d=3):
            """a hisexp: the constructors of the smart constructors, the raw ones (with names that no smart constructor makes), the s2exp/s2zexp ones"""
            R = self.R; t = R.random()
            if d <= 0 or t < 0.3:
                return R.choice(['hisexp_tybox', 'hisexp_typtr', 'hisexp_funptr', 'hisexp_cloptr', 'hisexp_clotyp', 'hisexp_arrptr', 'hisexp_datconptr',
                    'hisexp_datcontyp', 'hisexp_exnconptr', 'hisexp_undefined', 'hisexp_int_t0ype ()', 'hisexp_bool_t0ype ()', 'hisexp_size_t0ype ()',
                    'hisexp_void_t0ype ()', 'hisexp_cst (%s)' % self.handle('s2cst'), 'hisexp_cst (%s)' % R.choice(self.dts), 'hisexp_cst (%s)' % R.choice(self.dts),
                    'hisexp_tyabs (%s)' % self.leaf('symbol'),
                    'hisexp_tyvar (%s)' % self.handle('s2var'), 'hisexp_tyvar (%s)' % R.choice(self.tvs), 'hisexp_tyvar (%s)' % R.choice(self.tvs), 'hisexp_app (hisexp_tyvar (%s), LC_hisexplst (hisexp_int_t0ype (), LN_hisexplst ()))' % R.choice(self.tvs), 'hisexp_s2zexp (s2zexp_make_s2exp (K_s2exp (s2rt_t0ype, K_S2Eextkind ("zk%d", LN_s2explstlst ()))))' % R.randrange(2), 'ccb_tyclo (%s)' % self.handle('funlab'),
                    'hisexp_vararg (%s)' % self.s2e_safe(1), 'hisexp_s2exp (%s)' % self.s2e_safe(2), 'hisexp_s2exp (%s)' % self.s2e_safe(2),
                    'hisexp_s2zexp (s2zexp_make_s2exp (K_s2exp (s2rt_t0ype, K_S2Eextype ("zt%d", %s))))' % (R.randrange(2), self.s2ess(0)),
                    'hisexp_make_srt (%s)' % self.sort(), 'hisexp_make_srtsym (%s, %s)' % (self.sort(), self.leaf('symbol'))])
            d -= 1
            k = R.randrange(12)
            if k == 0: return 'hisexp_app (%s, %s)' % (self.hsx(d), self.hses2(d))
            if k == 1: return 'hisexp_fun (%s, %s, %s)' % (self.leaf('funclo'), self.hses2(d), self.hsx(d))
            if k == 2: return 'hisexp_extype ("ext%d", %s)' % (R.randrange(3), self.hsess2(d))
            if k == 3: return 'hisexp_refarg (%d, %s)' % (R.randrange(2), self.hsx(d))
            if k == 4: return 'hisexp_tyarr (%s, %s)' % (self.hsx(d), self.gv('s2explst', 0))
            if k == 5: return 'hisexp_tyrec (%s, %s)' % (self.tyreckind(), self.lhs2(d))
            if k == 6: return 'hisexp_tyrecsin (%s)' % self.lh2(d)
            if k == 7: return 'hisexp_tyrec2 (%s, %s)' % (self.tyreckind(), self.lhs2(d))
            if k == 8: return 'hisexp_tysum (%s, %s)' % (self.handle('d2con'), self.lhs2(d))
            if k == 9: return 'hisexp_tysum (%s, %s)' % (R.choice(self.pool['d2con']), self.lhs2(d))
            if k == 10:
                nm = 'K_hitnam (%d, %d, "nm%d")' % (R.randrange(2), R.randrange(2), R.randrange(3))
                return 'K_hisexp (%s, %s)' % (nm, self.node2(d))
            return 'hisexp_tyrec (%s, %s)' % (self.tyreckind(), self.lhs2(d))
        def node2(self, d):
            R = self.R; k = R.randrange(7)
            if k == 0: return 'K_HSEtybox ()'
            if k == 1: return 'K_HSEcst (%s)' % self.handle('s2cst')
            if k == 2: return 'K_HSEtyrecsin (%s)' % self.lh2(d)
            if k == 3: return 'K_HSEtyvar (%s)' % self.handle('s2var')
            if k == 4: return 'K_HSEtyarr (%s, %s)' % (self.hsx(d), self.gv('s2explst', 0))
            if k == 5: return 'K_HSEtyabs (%s)' % self.leaf('symbol')
            return 'K_HSEs2exp (%s)' % self.s2e_safe(1)
        def hses2(self, d):
            e = 'LN_hisexplst ()'
            for _ in range(self.R.randrange(4)): e = 'LC_hisexplst (%s, %s)' % (self.hsx(d), e)
            return e
        def hsess2(self, d):
            e = 'LN_hisexplstlst ()'
            for _ in range(self.R.randrange(3)): e = 'LC_hisexplstlst (%s, %s)' % (self.hses2(max(d - 1, 0)), e)
            return e
        def lh2(self, d):
            return 'K_labhisexp (%s, %s, %s)' % (self.leaf('label'), self.R.choice(['ON_stringopt ()', 'ON_stringopt ()', 'OS_stringopt ("nm%d")' % self.R.randrange(3)]), self.hsx(d))
        def lhs2(self, d):
            e = 'LN_labhisexplst ()'
            for _ in range(self.R.randrange(4)): e = 'LC_labhisexplst (%s, %s)' % (self.lh2(d), e)
            return e
        def s2e_safe(self, d):
            """the s2exp that typerase / typize handle: no abort"""
            R = self.R; t = R.random()
            if d <= 0 or t < 0.3:
                return R.choice(['s2exp_cst (%s)' % self.handle('s2cst'), 's2exp_cst (%s)' % R.choice(self.dts),
                                 's2exp_var (%s)' % self.handle('s2var'), 'K_s2exp (s2rt_t0ype, K_S2Eextkind ("ek%d", LN_s2explstlst ()))' % R.randrange(2)])
            d -= 1
            k = R.randrange(6)
            if k == 0: return 'K_s2exp (s2rt_t0ype, K_S2Eextype ("et%d", %s))' % (R.randrange(3), self.s2ess(d))
            if k == 1: return 's2exp_cstapp (%s, %s)' % (R.choice(self.fcs), self.s2es_safe(d))
            if k == 2: return 'K_s2exp (s2rt_view, K_S2Eat (%s, %s))' % (self.s2e_safe(d), self.s2e_safe(d))
            if k == 3: return 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (self.tyreckind(), self.ls2es_safe(d))
            if k == 4: return 'K_s2exp (s2rt_t0ype, K_S2Eextype ("et%d", %s))' % (R.randrange(3), self.s2ess(d))
            return 's2exp_cst (%s)' % R.choice(self.dts)
        def s2ess(self, d):
            e = 'LN_s2explstlst ()'
            for _ in range(self.R.randrange(3)): e = 'LC_s2explstlst (%s, %s)' % (self.s2es_safe(max(d - 1, 0)), e)
            return e
        def s2es_safe(self, d):
            e = 'LN_s2explst ()'
            for _ in range(self.R.randrange(3)): e = 'LC_s2explst (%s, %s)' % (self.s2e_safe(d), e)
            return e
        def ls2es_safe(self, d):
            e = 'LN_labs2explst ()'
            for _ in range(self.R.randrange(3)): e = 'LC_labs2explst (K_labs2exp (%s, ON_stringopt (), %s), %s)' % (self.leaf('label'), self.s2e_safe(d), e)
            return e
        def tyreckind(self):
            return self.R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt_ext ("nm")'])
    return ScC

def families(G, C, ScC, M):
    F = []
    hdF = hd_cases.families(G, C, ScC, M)
    for name, fam, n in hdF:
        if name == 'setup': F.append((name, fam, 0))
    # ----------------------------------------------------------------------------------------------------------
    def fam_hit(sc, k):
        """pats_ccomp_hitype.dats: the C types of random hisexp (every constructor), the type table"""
        R = sc.R
        sc.tcells()
        hs = [sc.val(sc.hsx(3), 'hisexp') for _ in range(14)]
        for i, h in enumerate(hs):
            sc.say('hit %d' % i)
            sc.dd('hisexp', h)
            sc.do('(emit_hisexp (dd_out, %s); dd_nl ())' % h)
            sc.do('(emit_hisexp_sel (dd_out, %s); dd_nl ())' % h)
            sc.do('(emit_hisexplst_sep (dd_out, %s, ", "); dd_nl ())' % sc.lstx('hisexplst', [h, R.choice(hs)]))
            for fl in (0, 1):
                x = sc.val('hisexp_typize (%d, %s)' % (fl, h))
                sc.do('(fprint_hitype (dd_out, %s); dd_nl ())' % x)
                sc.do('(emit_hitype (dd_out, %s); dd_nl ())' % x)
            sc.do('(print_hitype (hisexp_typize (1, %s)); print_newline ())' % h)
            sc.do('(prerr_hitype (hisexp_typize (0, %s)); prerr_newline ())' % h)
            sc.do('(fprint_hitypelst (dd_out, %s); dd_nl ())' % 'ccb_hitl2 (hisexp_typize (0, %s), hisexp_typize (1, %s))' % (h, R.choice(hs)))
        sc.say('typedefs')
        sc.do('emit_the_typedeflst (dd_out)')
    F.append(('hit', fam_hit, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_pat(sc, k):
        """pats_ccomp_hipat.dats: hipatck_ccomp / himatch_ccomp / himatch2_ccomp / hifunarg_ccomp on random patterns, against the mock environment"""
        R = sc.R
        sc.pools()
        sc.new('funlab')
        V = sc.pool['d2var']
        for i, v in enumerate(V): sc.do('d2var_set_utimes (%s, %d)' % (v, [0, 1, 2][i % 3]))
        mv = sc.val('d2var_make (%s, mksym (2))' % sc.loc(), 'd2var')
        sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (mv, V[0]))
        sc.do('d2var_set_utimes (%s, 1)' % mv)
        sc.pool['d2var'] = V + [mv]
        env = sc.val('ccompenv_make ()')
        def pmvx(hse):
            L = sc.loc()
            t = sc.R.random()
            tv = sc.val('tmpvar_make (%s, %s)' % (L, hse))
            if t < 0.2: return sc.val('primval_tmpref (%s, %s, %s)' % (L, hse, tv))
            if t < 0.3: return sc.val('primval_selcon (%s, %s, primval_tmp (%s, %s, %s), %s, %s)' % (L, hse, L, hse, tv, hse, sc.leaf('label')))
            return sc.val('primval_tmp (%s, %s, %s)' % (L, hse, tv))
        for i in range(8):
            hip = sc.val(sc.Pnf(3), 'hipat')
            hs = sc.val('hipat_get_type (%s)' % hip)
            pmv = pmvx(hs)
            fail = R.choice(['K_PTCKNTnone ()', 'K_PTCKNTcaseof_fail (%s)' % sc.loc()])
            res = sc.val('instrseq_make_nil ()')
            sc.say('pat %d' % i)
            sc.dd('hipat', hip)
            sc.do('hipatck_ccomp (%s, %s, %s, %s, %s)' % (env, res, fail, hip, pmv))
            sc.do('(dd_instrlst (instrseq_get_free (%s)); dd_nl ())' % res)
            res = sc.val('instrseq_make_nil ()')
            if i % 2 == 0:
                sc.do('ccompenv_inc_freeconenv (%s)' % env)
                sc.do('himatch_ccomp (%s, %s, %d, %s, %s)' % (env, res, R.randrange(3), hip, pmv))
                sc.do('instrseq_add_freeconlst (%s, %s, ccompenv_getdec_freeconenv (%s))' % (res, sc.loc(), env))
            else: sc.do('himatch2_ccomp (%s, %s, %d, %s, %s)' % (env, res, R.randrange(3), hip, pmv))
            sc.do('(dd_instrlst (instrseq_get_free (%s)); dd_nl ())' % res)
            sc.dd('hipat', hip)
            for v in V[:4]:
                sc.do('(dd_optvt_primval (ccompenv_find_vbindmapall (%s, %s)); dd_nl ())' % (env, v))
        for i in range(3):
            hips = sc.lstx('hipatlst', [sc.val(sc.Pnf(2), 'hipat') for _ in range(R.randrange(1, 4))])
            res = sc.val('instrseq_make_nil ()')
            sc.say('funarg %d' % i)
            sc.do('ccompenv_inc_freeconenv (%s)' % env)
            sc.do('hifunarg_ccomp (%s, %s, %s, %d, %s, %s)' % (env, res, sc.handle('funlab'), R.randrange(3), sc.loc(), hips))
            sc.do('instrseq_add_freeconlst (%s, %s, ccompenv_getdec_freeconenv (%s))' % (res, sc.loc(), env))
            sc.do('(dd_instrlst (instrseq_get_free (%s)); dd_nl ())' % res)
        for v in sc.pool['d2var']: sc.do('chk_d2var (%s)' % v)
        sc.do('ccompenv_free (%s)' % env)
    F.append(('pat', fam_pat, 3))
    # ----------------------------------------------------------------------------------------------------------
    def s2g(sc, r, r2, d, mode, V, B, B2, mut, inexi):
        """a static expression over the variables V (mode pat) / the constants that stand for them (mode arg); the structure is a function of the state of r"""
        t = r.random()
        if d <= 0 or t < 0.35:
            k = r.randrange(7)
            if k < 3:
                i = r.randrange(len(V))
                if mode == 'pat': return 's2exp_var (%s)' % V[i]
                j = i % len(sc.dts)
                if mut and r2.random() < 0.2: j = (j + 1) % len(sc.dts)
                return 's2exp_cst (%s)' % sc.dts[j]
            if k == 3 and inexi:
                i = r.randrange(len(B))
                return 's2exp_var (%s)' % (B[i] if mode == 'pat' else B2[i])
            if k <= 4:
                j = r.randrange(len(sc.dts))
                if mode == 'arg' and mut and r2.random() < 0.2: j = (j + 1) % len(sc.dts)
                return 's2exp_cst (%s)' % sc.dts[j]
            return 's2exp_int (%d)' % r.randrange(3)
        d -= 1
        k = r.randrange(5)
        if k <= 1:
            f = sc.fcs[r.randrange(len(sc.fcs))]
            n = r.randrange(1, 3)
            args = [s2g(sc, r, r2, d, mode, V, B, B2, mut, inexi) for _ in range(n)]
            return 's2exp_cstapp (%s, %s)' % (f, sc.lstx('s2explst', args))
        if k == 2:
            n = r.randrange(0, 3)
            ls = ['K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, s2g(sc, r, r2, d, mode, V, B, B2, mut, inexi)) for i in range(n)]
            return 's2exp_tyrec_srt (s2rt_t0ype, %s, 0, %s)' % (r.choice(['K_TYRECKINDflt0 ()', 'K_TYRECKINDbox ()']), sc.lstx('labs2explst', ls))
        if k == 3:
            n = r.randrange(1, 3)
            bs = (B if mode == 'pat' else B2)[:n]
            body = s2g(sc, r, r2, d, mode, V, B, B2, mut, True)
            return 's2exp_exi (%s, %s, %s)' % (sc.lstx('s2varlst', bs), 'LN_s2explst ()', body)
        return s2g(sc, r, r2, d, mode, V, B, B2, mut, inexi)
    def fam_tmpl(sc, k):
        """pats_ccomp_template.dats: the matching of the instances of templates (hiimpdec, hifundec), against the mock environment"""
        R = sc.R
        sc.pools(); sc.tcells()
        L = sc.loc
        V = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(3)]
        B = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(2)]
        B2 = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(2)]
        Cs = sc.pool['d2cst']; Dv = sc.pool['d2var']
        def level(seed, mode, mut):
            r = random.Random(seed); r2 = random.Random(seed + 1)
            return [s2g(sc, r, r2, 2, mode, V, B, B2, mut, False) for _ in range(r.randrange(1, 3))]
        imps = []
        for i in range(5):
            seeds = [R.randrange(10**6) for _ in range(R.randrange(1, 3))]
            tmparg = sc.val(sc.lstx('s2explstlst', [sc.lstx('s2explst', level(s, 'pat', False)) for s in seeds]))
            d2c = Cs[R.randrange(2)]
            imp = sc.val('hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (L(), R.randrange(2), d2c, sc.lstx('s2varlst', V[:R.choice([2, 3, 3])]), tmparg, sc.E(1)), 'hiimpdec')
            imps.append((imp, seeds, d2c, tmparg))
        def t2mas(seeds, mut):
            return sc.lstx('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (L(), sc.lstx('s2explst', level(s, 'arg', mut))) for s in seeds])
        for imp, seeds, d2c, tmparg in imps:
            for mut in (False, False, True):
                ta = sc.val(t2mas(seeds, mut))
                for dc in (d2c, Cs[2]):
                    sc.say('impdec match')
                    sc.dd('tmpcstmat', 'hiimpdec_tmpcst_match (%s, %s, %s, %d)' % (imp, dc, ta, R.randrange(2)))
                ts = sc.val('K_TMPSUBnil ()')
                sc.dd('tmpcstmat', 'hiimpdec2_tmpcst_match (K_hiimpdec2 (%s, K_TMPSUBcons (%s, s2exp_int (1), %s), %s), %s, %s, 0)' % (imp, V[0], ts, tmparg, d2c, ta))
                sc.dd('tmpcstmat', 'hiimpdeclst_tmpcst_match (%s, %s, %s, 1)' % (sc.lstx('hiimpdeclst', [x[0] for x in imps[::-1]]), d2c, ta))
                fl = sc.val('ccb_mkfunlab_t2 (0, hisexp_funptr, %s, %s)' % (ta, d2c))
                sc.dd('tmpcstmat', 'tmpcstmat_tmpcst_match (K_TMPCSTMATsome2 (%s, %s, %s), %s, %s)' % (d2c, tmparg, fl, R.choice([d2c, Cs[2]]), ta))
                sc.do('(dd_bool (funlab_tmparg_match (%s, %s)); dd_nl ())' % (fl, ta))
        # the matching of the variables
        for i in range(4):
            seeds = [R.randrange(10**6)]
            tmparg = sc.val(sc.lstx('s2explstlst', [sc.lstx('s2explst', level(seeds[0], 'pat', False))]))
            hfd = sc.val('hifundec_make (%s, %s, %s, %s)' % (L(), Dv[R.randrange(2)], sc.lstx('s2varlst', V), sc.E(1)), 'hifundec')
            ta = sc.val('LC_t2mpmarglst (K_t2mpmarg (%s, %s), LN_t2mpmarglst ())' % (L(), sc.lstx('s2explst', (level(seeds[0], 'arg', False) + level(seeds[0] + 7, 'arg', False))[:3])))
            for dv in (Dv[0], Dv[1], Dv[2]):
                sc.say('hifundec match')
                sc.dd('tmpvarmat', 'hifundec_tmpvar_match (%s, %s, %s)' % (hfd, dv, ta))
                sc.dd('tmpvarmat', 'hifundec2_tmpvar_match (K_hifundec2 (%s, K_TMPSUBcons (%s, s2exp_int (2), K_TMPSUBnil ())), %s, %s)' % (hfd, V[1], dv, ta))
            sc.dd('tmpvarmat', 'hifundec2tmpvarmat (%s, %s)' % (hfd, ta))
            sc.dd('tmpvarmat', 'hifundecopt2tmpvarmat (Some_vt (%s), %s)' % (hfd, ta))
            sc.dd('tmpvarmat', 'hifundecopt2tmpvarmat (None_vt (), %s)' % ta)
            fl = sc.val('ccb_mkfunlab_v (0, hisexp_funptr, %s, %s)' % (ta, Dv[0]))
            sc.dd('tmpvarmat', 'tmpvarmat_tmpvar_match (K_TMPVARMATsome2 (%s, %s, %s), %s, %s)' % (Dv[0], tmparg, fl, R.choice(Dv), ta))
        # the environment: ccompenv_tmpcst_match through the mock (the entries newest first), ccomp_tmpcstmat on a miss / a TMPCSTMATsome2
        env = sc.val('ccompenv_make ()')
        for imp, seeds, d2c, tmparg in imps[:3]:
            sc.do('ccompenv_add_impdec (%s, %s)' % (env, imp))
        for imp, seeds, d2c, tmparg in imps[:2]:
            ta = sc.val(t2mas(seeds, False))
            for dc in (d2c, Cs[2]):
                sc.dd('tmpcstmat', 'ccompenv_tmpcst_match (%s, %s, %s)' % (env, dc, ta))
                p = sc.val('ccomp_tmpcstmat (%s, %s, hisexp_funptr, %s, %s, ccompenv_tmpcst_match (%s, %s, %s))' % (env, L(), dc, ta, env, dc, ta))
                sc.dd('primval', p)
        for imp, seeds, d2c, tmparg in imps[:2]:
            fl = sc.val('ccb_mkfunlab_t2 (0, hisexp_funptr, LN_t2mpmarglst (), %s)' % d2c)
            for mat in ('K_TMPCSTMATsome2 (%s, %s, %s)' % (d2c, tmparg, fl), 'K_TMPCSTMATnone ()', 'K_TMPCSTMATsome (%s, K_TMPSUBnil (), 0)' % imp):
                ta = sc.val(t2mas(seeds, False))
                sc.dd('primval', 'ccomp_tmpcstmat (%s, %s, hisexp_funptr, %s, %s, %s)' % (env, L(), d2c, ta, mat))
        hfd = sc.val('hifundec_make (%s, %s, %s, %s)' % (L(), Dv[0], sc.lstx('s2varlst', V), sc.E(0)), 'hifundec')
        sc.do('ccb_hfds_mkfun (%s)' % sc.lstx('hifundeclst', [hfd]))
        ta = sc.val('LC_t2mpmarglst (K_t2mpmarg (%s, %s), LN_t2mpmarglst ())' % (L(), sc.lstx('s2explst', level(1, 'arg', False))))
        fl = sc.val('ccb_mkfunlab_v (0, hisexp_funptr, LN_t2mpmarglst (), %s)' % Dv[0])
        for mat in ('K_TMPVARMATsome (%s, K_TMPSUBnil (), 0)' % hfd, 'K_TMPVARMATsome2 (%s, LN_s2explstlst (), %s)' % (Dv[0], fl), 'K_TMPVARMATnone ()'):
            sc.dd('primval', 'ccomp_tmpvarmat (%s, %s, hisexp_funptr, %s, %s, %s)' % (env, L(), Dv[0], ta, mat))
        sc.do('ccompenv_free (%s)' % env)
    F.append(('tmpl', fam_tmpl, 3))
    # ----------------------------------------------------------------------------------------------------------
    class Sub:
        """the generator of the instructions of the bodies of the functions that funent_subst substitutes"""
        def __init__(s, sc, R, V, H, T, F, FE, Dc, Dv, DCN, TL, Cs, IMP=None, HFD=None):
            s.IMP = IMP; s.HFD = HFD; s.sc = sc; s.R = R; s.V = V; s.H = H; s.T = T; s.F = F; s.FE = FE; s.Dc = Dc; s.Dv = Dv; s.DCN = DCN; s.TL = TL; s.Cs = Cs
        def L(s): return s.sc.loc()
        def h(s): return s.R.choice(s.H)
        def t(s): return s.R.choice(s.T)
        def lst(s, alias, xs): return s.sc.lstx(alias, xs)
        def lab(s): return 'mklab (%d)' % s.R.randrange(3)
        def pls(s, d):
            return s.lst('primlablst', [('primlab_lab (%s, %s)' % (s.L(), s.lab())) if s.R.random() < 0.6 else ('primlab_ind (%s, %s)' % (s.L(), s.lst('primvalist', [s.pm(d - 1) for _ in range(s.R.randrange(1, 3))]))) for _ in range(s.R.randrange(0, 3))])
        def pml(s, d):
            return ('primlab_lab (%s, %s)' % (s.L(), s.lab())) if s.R.random() < 0.6 else ('primlab_ind (%s, %s)' % (s.L(), s.lst('primvalist', [s.pm(d - 1)])))
        def pms(s, d, n=None):
            n = s.R.randrange(0, 3) if n is None else n
            return s.lst('primvalist', [s.pm(d) for _ in range(n)])
        def lpms(s, d):
            return s.lst('labprimvalist', ['K_labprimval (%s, %s)' % (s.lab(), s.pm(d)) for _ in range(s.R.randrange(0, 3))])
        def pm(s, d=2):
            R = s.R; L = s.L(); H = s.h()
            if d <= 0 or R.random() < 0.4:
                k = R.randrange(17)
                if k == 0: return 'primval_tmp (%s, %s, %s)' % (L, H, s.t())
                if k == 1: return 'primval_tmpref (%s, %s, %s)' % (L, H, s.t())
                if k == 2: return 'primval_arg (%s, %s, %d)' % (L, H, R.randrange(3))
                if k == 3: return 'primval_argref (%s, %s, %d)' % (L, H, R.randrange(3))
                if k == 4: return 'primval_argenv (%s, %s, %d)' % (L, H, R.randrange(3))
                if k == 5: return 'primval_cst (%s, %s, %s)' % (L, H, R.choice(s.Cs))
                if k == 6: return 'primval_int (%s, %s, %d)' % (L, H, R.randrange(5))
                if k == 7: return 'primval_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false']))
                if k == 8: return 'primval_string (%s, %s, "s%d")' % (L, H, R.randrange(3))
                if k == 9: return 'primval_top (%s, %s)' % (L, H)
                if k == 10: return 'primval_empty (%s, %s)' % (L, H)
                if k == 11: return 'primval_extval (%s, %s, "ev%d")' % (L, H, R.randrange(2))
                if k == 12: return 'primval_tyrep (%s, %s, %s)' % (L, H, s.h())
                if k == 13: return 'primval_sizeof (%s, %s, %s)' % (L, H, s.h())
                if k == 14: return 'primval_funlab (%s, %s, %s)' % (L, H, R.choice(s.F))
                if k == 15: return 'primval_cfunlab (%s, %s, %d, %s)' % (L, H, R.choice([1, 0, -1]), R.choice(s.F))
                return 'primval_d2vfunlab (%s, %s, %s, %s)' % (L, H, R.choice(s.Dv), R.choice(s.F))
            d -= 1
            k = R.randrange(13)
            if k == 0: return 'primval_castfn (%s, %s, %s, %s)' % (L, H, R.choice(s.Cs), s.pm(d))
            if k == 1: return 'primval_selcon (%s, %s, %s, %s, %s)' % (L, H, s.pm(d), s.h(), s.lab())
            if k == 2: return 'primval_select (%s, %s, %s, %s, %s)' % (L, H, s.pm(d), s.h(), s.pml(d))
            if k == 3: return 'primval_select2 (%s, %s, %s, %s, %s)' % (L, H, s.pm(d), s.h(), s.pls(d))
            if k == 4: return 'primval_selptr (%s, %s, %s, %s, %s)' % (L, H, s.pm(d), s.h(), s.pls(d))
            if k == 5: return 'primval_ptrof (%s, %s, %s)' % (L, H, s.pm(d))
            if k == 6: return 'primval_ptrofsel (%s, %s, %s, %s, %s)' % (L, H, s.pm(d), s.h(), s.pls(d))
            if k == 7: return 'primval_refarg (%s, %s, %d, %d, %s)' % (L, H, R.randrange(2), R.randrange(2), s.pm(d))
            if k == 8: return 'primval_lamfix (%s, primval_funlab (%s, %s, %s))' % (R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % R.choice(s.Dv)]), L, H, R.choice(s.FE))
            if k == 9: return 'primval_tmpltcst (%s, %s, %s, %s)' % (L, H, R.choice(s.Cs), s.sc.t2mas_ref())
            if k == 10: return 'primval_vararg (%s, %s, %s)' % (L, H, s.pms(d))
            if k == 11: return 'primval_tmpltvar (%s, %s, %s, %s)' % (L, H, R.choice(s.Dv), s.sc.t2mas_ref())
            return 'primval_tmp (%s, %s, %s)' % (L, H, s.t())
        def ins(s, d=2):
            R = s.R; L = s.L(); H = s.h(); T = s.t()
            if d <= 0 or R.random() < 0.35:
                k = R.randrange(9)
                if k == 0: return 'instr_funlab (%s, %s)' % (L, R.choice(s.F))
                if k == 1: return 'instr_tmplab (%s, %s)' % (L, R.choice(s.TL))
                if k == 2: return 'instr_comment (%s, "c%d")' % (L, R.randrange(2))
                if k == 3: return 'instr_move_val (%s, %s, %s)' % (L, T, s.pm(1))
                if k == 4: return 'instr_pmove_val (%s, %s, %s)' % (L, T, s.pm(1))
                if k == 5: return 'instr_move_arg_val (%s, %d, %s)' % (L, R.randrange(3), s.pm(1))
                if k == 6: return 'instr_move_list_nil (%s, %s)' % (L, T)
                if k == 7: return 'instr_tmpdec (%s, %s)' % (L, T)
                return 'instr_loopexn (%s, %d, %s)' % (L, R.randrange(2), R.choice(s.TL))
            d -= 1
            k = R.randrange(34)
            if k == 0: return 'instr_fcall (%s, %s, %s, %s, %s)' % (L, T, s.pm(d), H, s.pms(d))
            if k == 1: return 'instr_fcall2 (%s, %s, %s, %d, %s, %s)' % (L, T, R.choice(s.F), R.randrange(2), H, s.pms(d))
            if k == 2: return 'instr_extfcall (%s, %s, "f%d", %s)' % (L, T, R.randrange(2), s.pms(d))
            if k == 3: return 'instr_extmcall (%s, %s, %s, "m", %s)' % (L, T, s.pm(d), s.pms(d))
            if k == 4: return 'instr_cond (%s, %s, %s, %s)' % (L, s.pm(d), s.inss(d), s.inss(d))
            if k == 5: return 'instr_freecon (%s, %s)' % (L, s.pm(d))
            if k == 6: return 'instr_loop (%s, %s, %s, %s, %s, %s, %s, %s, %s)' % (L, R.choice(s.TL), R.choice(s.TL), R.choice(s.TL), s.inss(d), s.pm(d), s.inss(d), s.inss(d), s.inss(d))
            if k == 7: return 'instr_caseof (%s, %s)' % (L, s.lst('ibranchlst', ['ibranch_make (%s, %s)' % (s.L(), s.inss(d)) for _ in range(R.randrange(0, 3))]))
            if k == 8: return 'instr_letpush (%s, %s)' % (L, s.lst('primdeclst', [s.pd(d) for _ in range(R.randrange(0, 3))]))
            if k == 9: return 'instr_move_con (%s, %s, %s, %s, %s)' % (L, T, R.choice(s.DCN), H, s.lpms(d))
            if k == 10: return 'instr_move_ref (%s, %s, %s)' % (L, T, s.pm(d))
            if k == 11: return 'instr_move_boxrec (%s, %s, %s, %s)' % (L, T, s.lpms(d), H)
            if k == 12: return 'instr_move_fltrec (%s, %s, %s, %s)' % (L, T, s.lpms(d), H)
            if k == 13: return 'instr_patck (%s, %s, %s, %s)' % (L, s.pm(d), R.choice(['K_PATCKint (%d)' % R.randrange(3), 'K_PATCKbool (true)', 'K_PATCKstring ("p")']), s.kont(d))
            if k == 14: return 'instr_move_ptrofsel (%s, %s, %s, %s, %s)' % (L, T, s.pm(d), H, s.pls(d))
            if k == 15: return 'instr_store_ptrofs (%s, %s, %s, %s, %s)' % (L, s.pm(d), H, s.pls(d), s.pm(d))
            if k == 16: return 'instr_xstore_ptrofs (%s, %s, %s, %s, %s, %s)' % (L, T, s.pm(d), H, s.pls(d), s.pm(d))
            if k == 17: return 'instr_raise (%s, %s, %s)' % (L, T, s.pm(d))
            if k == 18: return 'instr_move_delay (%s, %s, %d, %s, %s)' % (L, T, R.randrange(2), H, s.pm(d))
            if k == 19: return 'instr_move_lazyeval (%s, %s, %d, %s, %s)' % (L, T, R.randrange(2), H, s.pm(d))
            if k == 20: return 'instr_trywith (%s, %s, %s, %s)' % (L, T, s.inss(d), s.lst('ibranchlst', ['ibranch_make (%s, %s)' % (s.L(), s.inss(d)) for _ in range(R.randrange(0, 2))]))
            if k == 21: return 'instr_pmove_list_nil (%s, %s)' % (L, T)
            if k == 22: return 'instr_pmove_list_cons (%s, %s, %s)' % (L, T, H)
            if k == 23: return 'instr_move_list_phead (%s, %s, %s, %s)' % (L, T, s.t(), H)
            if k == 24: return 'instr_move_list_ptail (%s, %s, %s, %s)' % (L, T, s.t(), H)
            if k == 25: return 'instr_move_arrpsz_ptr (%s, %s, %s)' % (L, T, s.t())
            if k == 26: return 'instr_store_arrpsz_asz (%s, %s, %d)' % (L, T, R.randrange(4))
            if k == 27: return 'instr_store_arrpsz_ptr (%s, %s, %s, %d)' % (L, T, H, R.randrange(4))
            if k == 28: return R.choice(['instr_update_ptrinc', 'instr_update_ptrdec']) + ' (%s, %s, %s)' % (L, T, H)
            if k == 29: return 'instr_closure_initize (%s, %s, %s, %s)' % (L, T, R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % R.choice(s.Dv)]), R.choice(s.FE))
            if k == 30: return 'instr_extvar (%s, "xv", %s)' % (L, s.pm(d))
            if k == 31: return 'instr_dcstdef (%s, %s, %s)' % (L, R.choice(s.Cs), s.pm(d))
            if k == 32: return 'instr_tempenver (%s, %s)' % (L, s.lst('d2varlst', R.sample(s.Dv, R.randrange(0, 3))))
            return 'instr_move_val (%s, %s, %s)' % (L, T, s.pm(d))
        def inss(s, d): return s.lst('instrlst', [s.ins(d) for _ in range(s.R.randrange(0, 3))])
        def kont(s, d):
            R = s.R; k = R.randrange(4)
            if k == 0: return 'K_PTCKNTnone ()'
            if k == 1: return 'K_PTCKNTtmplabint (%s, %d)' % (R.choice(s.TL), R.randrange(2))
            if k == 2: return 'K_PTCKNTtmplabmov (%s, %s)' % (R.choice(s.TL), s.lst('tmpmovlst', ['K_tmpmov (%s, %s)' % (R.choice(['K_TPMVnone (%s)' % s.pm(d), 'K_TPMVsome (%s, %s)' % (s.t(), s.pm(d))]), s.t()) for _ in range(R.randrange(0, 3))]))
            return 'K_PTCKNTraise (%s, %s)' % (s.t(), s.pm(d))
        def pd(s, d):
            R = s.R; L = s.L(); k = R.randrange(14)
            if k == 7: return 'ccb_pd_valdecs_rec (%s, mkvalkind (%d), LN_hivaldeclst (), %s)' % (L, R.randrange(4), s.inss(d))
            if k == 8: return 'primdec_impdec (%s, %s)' % (L, R.choice(s.IMP))
            if k == 9: return 'ccb_pd_fundecs (%s, mkfunkind (%d), %s, %s)' % (L, R.randrange(7), R.choice(['LN_s2qualst ()', 'LN_s2qualst ()', 'LC_s2qualst (K_s2qua (LN_s2varlst (), LN_s2explst ()), LN_s2qualst ())']), s.lst('hifundeclst', R.sample(s.HFD, R.randrange(1, 3))))
            if k == 10: return 'primdec_staload (%s, hidecl_staload (%s, ON_symbolopt (), mkfil (0), 0, %s, 0))' % (L, L, s.sc.leaf('filenv'))
            if k == 11: return 'primdec_staloadloc (%s, mkfil (0), mksym (1), %s)' % (L, s.lst('primdeclst', [s.pd(d - 1)]) if d > 0 else 'LN_primdeclst ()')
            if k == 12: return 'primdec_dynload (%s, hidecl_dynload (%s, mkfil (0)))' % (L, L)
            k = k % 7
            if k == 0: return 'primdec_none (%s)' % L
            if k == 1: return 'ccb_pd_extvar (%s, "pv", %s)' % (L, s.inss(d))
            if k == 2: return 'ccb_pd_valdecs (%s, mkvalkind (%d), LN_hivaldeclst (), %s)' % (L, R.randrange(4), s.inss(d))
            if k == 3: return 'ccb_pd_vardecs (%s, LN_hivardeclst (), %s)' % (L, s.inss(d))
            if k == 4: return 'primdec_local (%s, %s, %s)' % (L, s.lst('primdeclst', [s.pd(d - 1) for _ in range(R.randrange(0, 2))]) if d > 0 else 'LN_primdeclst ()', s.lst('primdeclst', [s.pd(d - 1) for _ in range(R.randrange(0, 2))]) if d > 0 else 'LN_primdeclst ()')
            if k == 5: return 'primdec_include (%s, %d, %s)' % (L, R.randrange(2), s.lst('primdeclst', [s.pd(d - 1) for _ in range(R.randrange(0, 2))]) if d > 0 else 'LN_primdeclst ()')
            return 'primdec_list (%s, %s)' % (L, s.lst('primdeclst', [s.pd(d - 1) for _ in range(R.randrange(0, 2))]) if d > 0 else 'LN_primdeclst ()')
    def fam_sub(sc, k):
        """pats_ccomp_subst.dats: funent_subst (and funlab_subst, d2envlst_subst, t2mpmarglst_subst) on function entries with random bodies, against the mock environment"""
        R = sc.R
        sc.pools(); sc.tcells()
        L = sc.loc
        V = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(3)]
        sc.pool['s2var'] = V + sc.pool['s2var']
        H = [sc.val(x, 'hisexp') for x in ['hisexp_tyvar (%s)' % V[0], 'hisexp_app (hisexp_cst (%s), %s)' % (sc.dts[0], sc.lstx('hisexplst', ['hisexp_tyvar (%s)' % V[1]])),
              'hisexp_int_t0ype ()', 'hisexp_tyrec (K_TYRECKINDflt0 (), %s)' % sc.lstx('labhisexplst', ['K_labhisexp (mklab (0), ON_stringopt (), hisexp_tyvar (%s))' % V[2]]),
              'hisexp_fun (FUNCLOfun (), %s, hisexp_tyvar (%s))' % (sc.lstx('hisexplst', ['hisexp_tyvar (%s)' % V[0]]), V[1]), 'hisexp_tybox']]
        T = [sc.val('tmpvar_make (%s, %s)' % (L(), H[i % len(H)]), 'tmpvar') for i in range(6)]
        sc.do('ccb_tmpvar_set_ref (%s, 1)' % T[1]); sc.do('ccb_tmpvar_set_ret (%s, 2)' % T[2]); sc.do('ccb_tmpvar_set_topknd (%s, 1)' % T[3])
        TL = [sc.val('tmplab_make (%s)' % L()) for _ in range(2)]
        F = [sc.val('ccb_mkfunlab (%d, %d, %s)' % (i, i % 2, H[4]), 'funlab') for i in range(3)]
        FE = []
        Dc = sc.pool['d2con']; Dv = sc.pool['d2var']; Cs = sc.pool['d2cst']
        for i in range(2):
            fl = sc.val('ccb_mkfunlab (%d, 1, %s)' % (10 + i, H[4]), 'funlab')
            sc.do('ccb_mkfun_body (%s, %s, LN_s2varlst (), LN_s2explstlst ())' % (L(), fl))
            FE.append(fl)
        for v in Dv: sc.do('d2var_set2_hisexp (%s, OS_hisexpopt (%s))' % (v, R.choice(H)))
        sc.t2mas_ref = lambda: 'LC_t2mpmarglst (K_t2mpmarg (%s, LC_s2explst (s2exp_var (%s), LN_s2explst ())), LN_t2mpmarglst ())' % (L(), R.choice(V))
        FV = [sc.val('ccb_mkfunlab_v (0, %s, LN_t2mpmarglst (), %s)' % (H[4], Dv[i]), 'funlab') for i in range(2)]
        F = F + FV
        IMP = [sc.val('hiimpdec_make (%s, 0, %s, %s, %s, %s)' % (L(), Cs[0], sc.lstx('s2varlst', V[:1]), sc.lstx('s2explstlst', [sc.lstx('s2explst', ['s2exp_var (%s)' % V[0]])]), sc.E(0)), 'hiimpdec') for _ in range(2)]
        HFD = [sc.val('hifundec_make (%s, %s, %s, %s)' % (L(), Dv[i], sc.lstx('s2varlst', V[:1]), sc.E(0)), 'hifundec') for i in range(2)]
        sc.do('ccb_hfds_mkfun (%s)' % sc.lstx('hifundeclst', HFD))
        sc.do('$GLOB.the_CCOMPATS_tlcalopt_set (%d)' % R.randrange(2))
        g = Sub(sc, R, V, H, T, F, FE, Dc, Dv, Dc, TL, Cs, IMP, HFD)
        # the substitutions: tyvars to constants / int / other types
        def sub_expr(i):
            es = ['s2exp_cst (%s)' % sc.dts[0], 's2exp_cst (%s)' % sc.dts[1], 's2exp_cst (%s)' % sc.dts[2]]
            return 'ccb_sub3 (%s, %s, %s, %s, %s, %s)' % (V[0], R.choice(es), V[1], R.choice(es), V[2], R.choice(es))
        env = sc.val('ccompenv_make ()')
        for imp in IMP: sc.do('ccompenv_add_impdec (%s, %s)' % (env, imp))
        sc.do('ccompenv_add_fundec (%s, %s)' % (env, HFD[0]))
        sc.do('ccompenv_add_vbindmapenvall (%s, %s, primval_funlab (%s, %s, %s))' % (env, Dv[0], L(), H[4], FE[0]))
        sc.do('ccompenv_add_vbindmapenvall (%s, %s, primval_cfunlab (%s, %s, 1, %s))' % (env, Dv[1], L(), H[4], FE[1]))
        sc.do('ccompenv_add_tmpsub (%s, K_TMPSUBcons (%s, s2exp_cst (%s), K_TMPSUBnil ()))' % (env, V[0], sc.dts[0]))
        for i in range(4):
            body = sc.val(g.inss(3), 'instrlst')
            tmpret = T[R.randrange(2, 5)]
            tl = [T[j] for j in range(6) if j != 5 or R.random() < 0.5]
            if tmpret not in tl: tl.append(tmpret)
            fl = sc.val('ccb_mkfunlab (%d, %d, %s)' % (20 + i, R.randrange(2), H[4]), 'funlab')
            imparg = sc.lstx('s2varlst', V[:R.randrange(0, 3)])
            tmparg = sc.lstx('s2explstlst', [sc.lstx('s2explst', ['s2exp_var (%s)' % V[0]])] if R.random() < 0.5 else [])
            vb = sc.val('ccb_nil_vbindmap ()')
            sc.do('ccb_ins_vbindmap (%s, %s, primval_int (%s, %s, 1))' % (vb, R.choice(Dv), L(), H[2])) if False else None
            fe = sc.val('funent_make (%s, %s, %s, %s, ON_tmpsubopt (), %s, %s, %s, ccb_nil_vbindmap (), %s, %s)' % (
                L(), fl, imparg, tmparg, tmpret, sc.lstx('funlablst', R.sample(F, R.randrange(0, 3))),
                sc.lstx('d2envlst', ['d2env_make (%s, %s)' % (R.choice(Dv), R.choice(H)) for _ in range(R.randrange(0, 3))]), body, sc.lstx('tmpvarlst', tl)))
            sc.do('funlab_set_funent (%s, OS_funentopt (%s))' % (fl, fe))
            sc.say('subst %d' % i)
            sc.dd('funent', fe)
            fl2 = sc.val('ccb_funlab_subst (%s, %s)' % (sub_expr(i), fl))
            sc.dd('funlab', fl2)
            fe2 = sc.val('ccb_funent_subst (%s, %s, %s, %s, %d)' % (env, sub_expr(i), fl2, fe, R.randrange(1, 4)))
            sc.dd('funent', fe2)
            sc.dd('funlab', fl2)
            sc.dd('funlab', fl)
        sc.say('lists')
        for i in range(2):
            sc.do('(dd_d2envlstvt (ccb_d2envlst_subst (%s, %s)); dd_nl ())' % (sub_expr(i), sc.lstx('d2envlst', ['d2env_make (%s, %s)' % (R.choice(Dv), R.choice(H)) for _ in range(3)])))
            sc.dd('t2mpmarglst', 'ccb_t2mas_subst (%s, %s)' % (sub_expr(i), sc.lstx('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (L(), sc.lstx('s2explst', ['s2exp_var (%s)' % V[0], 's2exp_var (%s)' % V[1]]))])))
        sc.do('ccompenv_free (%s)' % env)
    F.append(('sub', fam_sub, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_main(sc, k):
        """pats_ccomp_main.dats: ccomp_main on random global lists (the emitters and the compilation of the declarations are doubles), the flags of pats_global"""
        R = sc.R
        sc.pools(); sc.tcells()
        L = sc.loc
        Dv = sc.pool['d2var']; Dcon = sc.pool['d2con']
        for rnd in range(3):
            sc.say('main %d' % rnd)
            sc.do('$GLOB.the_DYNLOADFLAG_set (%d)' % R.choice([0, 1, 2, -1]))
            sc.do('$GLOB.the_MAINATSFLAG_set (%d)' % R.choice([0, 0, 1]))
            if R.random() < 0.5: sc.do('$GLOB.the_DYNLOADNAME_set_name ("dynload_alias%d")' % rnd)
            else: sc.do('$GLOB.the_DYNLOADNAME_set_none ()')
            for _ in range(R.randrange(0, 3)): sc.do('the_exndeclst_add (%s)' % sc.Dc(1))
            for _ in range(R.randrange(0, 3)): sc.do('the_saspdeclst_add (%s)' % sc.Dc(1))
            for _ in range(R.randrange(0, 3)): sc.do('the_extypelst_add (hidecl_extype (%s, "xt%d", %s))' % (L(), R.randrange(3), sc.hse(1)))
            ps = [R.choice([0, 1, 1, 5, 10, 10, 20, 99, 120]) for _ in range(R.randrange(0, 6))]
            for p in ps: sc.do('the_extcodelst_add (hidecl_extcode (%s, %d, %d, "code%d"))' % (L(), R.randrange(3), p, R.randrange(3)))
            for _ in range(R.randrange(0, 3)): sc.do('the_staloadlst_add (hidecl_staload (%s, %s, mkfil (0), %d, %s, %d))' % (L(), sc.gv('symbolopt', 1), R.randrange(2), sc.leaf('filenv'), R.randrange(2)))
            for _ in range(R.randrange(0, 3)): sc.do('the_dynloadlst_add (hidecl_dynload (%s, mkfil (%d)))' % (L(), R.randrange(2)))
            for d in Dcon[:R.randrange(0, 4)]: sc.do('the_dynconlst_add (%s)' % d); sc.do('the_dynconlst_add (%s)' % d)
            mainc = None
            cs = []
            for i in range(R.randrange(1, 3)):
                cs.append(sc.val('d2cst_make (mksym (%d), %s, mkfil (0), mkdcstkind (0), LN_s2qualst (), %s, s2exp_int (0), %s)' % (
                    i, L(), sc.lstx('intlst', [str(R.randrange(4)) for _ in range(R.randrange(0, 3))]), R.choice(['mkdcstextdef (0)', 'ccb_mainextdef (%d)' % i])), 'd2cst'))
            for c in cs: sc.do('the_dyncstlst_add (%s)' % c); sc.do('the_dyncstlst_add (%s)' % c)
            for i in range(R.randrange(0, 4)):
                hse = R.choice(['hisexp_funptr', 'hisexp_fun (mkfunclo (%d), LN_hisexplst (), hisexp_void_t0ype ())' % R.randrange(4)])
                fl = sc.val('ccb_mkfunlab_t2 (0, %s, LN_t2mpmarglst (), %s)' % (hse, R.choice(cs)), 'funlab')
                sc.do('ccb_mkfun_body (%s, %s, LN_s2varlst (), LN_s2explstlst ())' % (L(), fl))
                sc.do('funlab_set_tmpknd (%s, %d)' % (fl, R.randrange(-1, 2)))
                sc.do('the_funlablst_add (%s)' % fl)
            hids = sc.val(sc.Dl(1, R.randrange(0, 4)), 'hideclist')
            sc.do('ccomp_main (dd_out, %d, mkfil (0), %s)' % (R.randrange(2), hids))
            sc.do('dd_flush ()')
            sc.do('(dd_d2conlst (the_dynconlst_get ()); dd_nl ())')
    F.append(('main', fam_main, 3))


    return F

def main(G, C, ccorder, d, M, T):
    ScC = build(G, C)
    F = families(G, C, ScC, M)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = ScC(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = sc.text()
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1500 or sc.name.startswith('sc_setup'):
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    write_chunks(d, C, bodies)
    print('ccb_cases: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

def write_chunks(d, C, chunks):
    for f in os.listdir(d):   # remove the files of an older generation (more chunks)
        m = re.match(r'^(?:ccbcase_|ccbcase1_|ccb_cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'ccb_cases_%02d.hats' % k
        C.put(os.path.join(d, cases), body)
        C.put(os.path.join(d, 'ccbcase_%02d.dats' % k),
            '(* generated by ccb_gen.py: the chunk %d of the cases of the ccomp group B test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "ccb_pre2.hats"\n'
            'extern fun tc%d_all (): void = "ext#ccbtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        C.put(os.path.join(d, 'ccbcase1_%02d.dats' % k),
            '(* generated by ccb_gen.py: the chunk %d of the cases of the ccomp group B test (ATS1) *)\n#include "ccb_pre1.hats"\n'
            'extern fun tc%d_all (): void = "ccbtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun tc%d_all (): void = "ext#ccbtc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "ccbtc_%d"\n' % (k, k))
    call = 'fun tc_all (): void = {\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    C.put(os.path.join(d, 'ccb_chunks.hats'), ''.join(ch2) + call)
    C.put(os.path.join(d, 'ccb_chunks1.hats'), ''.join(ch1) + call)
