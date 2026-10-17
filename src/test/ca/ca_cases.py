# the generator of the cases of the emit test (called by ca_gen.py, see there and PORTING.md "ccomp group A (emit)")
#
# A scenario is a function (a block of 'val' statements): it creates cells (s2var, s2cst, d2var, d2cst, d2con, tmpvar, funlab, funent, ..), builds trees of the
# specs (the wrappers K_x and the typed lists/options of the compat layers) and calls the emitters on them, printing the C text. The machinery (the class Sc, the
# random leaf values) is that of d2_cases.py / hd_cases.py. CASEED and CASCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True

SEED = int(os.environ.get('CASEED', '1'))
SCALE = float(os.environ.get('CASCALE', '3'))

def build(G, C, hd_cases):
    ScH = hd_cases.build(G, C)
    class ScC(ScH):
        # ---------------------------------------------------------------- the world of a scenario
        def world(self, full=False):
            """the pools: types, variables, constants, constructors, tmpvars, labels, funlabs (full: all the kinds of constants)"""
            R = self.R
            self.full = full
            self.pools()                                 # s2var x4, s2cst x3, d2var x3, d2cst x3, d2con x3 (random: only used as arguments of the types)
            self.hs = {}
            hs = self.hs
            def H(name, expr): hs[name] = self.val(expr, 'hisexp'); return hs[name]
            H('void', 'hisexp_void_t0ype ()'); H('int', 'hisexp_int_t0ype ()'); H('bool', 'hisexp_bool_t0ype ()'); H('size', 'hisexp_size_t0ype ()')
            H('typtr', 'hisexp_typtr'); H('tybox', 'hisexp_tybox'); H('cloptr', 'hisexp_cloptr'); H('funptr', 'hisexp_funptr'); H('clotyp', 'hisexp_clotyp')
            H('abs', 'hisexp_tyabs (mksym (2))'); H('cst', 'hisexp_cst (%s)' % self.pool['s2cst'][0]); H('arrptr', 'hisexp_arrptr')
            H('datconptr', 'hisexp_datconptr'); H('exnconptr', 'hisexp_exnconptr')
            self.vars = [self.val('d2var_make (mkloc (%d), mksym (%d))' % (i, i), 'd2var') for i in range(4)]
            self.svs = self.pool['s2var']
            self.mk_cons()
            self.mk_csts()
            self.mk_tmps()
            self.mk_funlabs()
            return self
        # ---- locations, small things
        def L(self, k=None): return 'mkloc (%d)' % (self.R.randrange(20) if k is None else k)
        def hse_any(self): return self.R.choice(list(self.hs.values()))
        def hse_nv(self): return self.R.choice([v for k, v in self.hs.items() if k != 'void'])
        def emit_line(self, call):
            self.do('(%s; emit_newline (dd_out))' % call)
        def drop(self, expr): self.lines.append('  val _ = %s' % expr)
        def hdr(self, text): self.do('H_e (dd_out, "%s")' % text)
        def lstx(self, alias, elems):
            e = 'LN_%s ()' % alias
            for x in reversed(elems): e = 'LC_%s (%s, %s)' % (alias, x, e)
            return e
        def hsl(self, hses): return self.lstx('hisexplst', hses)
        # ---- the hisexp types
        def FT(self, args, res, fc=0):
            return self.val('hisexp_fun (mkfunclo (%d), %s, %s)' % (fc, self.hsl(args), res), 'hisexp')
        def HSG(self, d=2):
            """a random type without the placeholders that cannot be printed"""
            r = self.R; t = r.random()
            hs = self.hs
            if d <= 0 or t < 0.4: return self.hse_any()
            d -= 1
            k = r.randrange(7)
            if k == 0: return self.val('hisexp_app (%s, %s)' % (self.HSG(d), self.hsl([self.HSG(d) for _ in range(r.randrange(3))])), 'hisexp')
            if k == 1: return self.val('hisexp_fun (mkfunclo (%d), %s, %s)' % (r.randrange(4), self.hsl([self.HSG(d) for _ in range(r.randrange(3))]), self.HSG(d)), 'hisexp')
            if k == 2: return self.val('hisexp_refarg (%d, %s)' % (r.randrange(2), self.HSG(d)), 'hisexp')
            if k == 3: return self.val('hisexp_tyarr (%s, %s)' % (self.HSG(d), self.lstx('s2explst', ['s2exp_int (%d)' % r.randrange(1, 5)])), 'hisexp')
            if k == 4: return self.val('hisexp_tyrec (%s, %s)' % (self.tyreckind(), self.LHS([(self.HSG(d)) for _ in range(r.randrange(3))])), 'hisexp')
            if k == 5: return self.val('hisexp_tyrecsin (%s)' % self.LH(0, self.HSG(d)), 'hisexp')
            return self.val('hisexp_extype ("ext%d", %s)' % (r.randrange(3), self.lstx('hisexplstlst', [self.hsl([self.HSG(d)])])), 'hisexp')
        def LH(self, j, hse):
            return 'K_labhisexp (%s, ON_stringopt (), %s)' % (self.labx(j), hse)
        def LHS(self, hses):
            return self.lstx('labhisexplst', [self.LH(j, h) for j, h in enumerate(hses)])
        def labx(self, j):
            return 'mklab (%d)' % (2 * j)             # even: [label_make_int], all different
        # ---- the d2con / s2cst / d2cst
        def mk_cons(self):
            self.dc = {}
            S = self.sc_ = {}
            def scst(name, srt, k):
                S[name] = self.val('s2cst_make (mksym (%d), mkloc (%d), H_fil (%d), %s, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())' % (k, k, k, srt), 's2cst')
            def dcon(name, sc, k, arity, tag, vw=0):
                args = self.lstx('s2explst', ['s2exp_int (%d)' % i for i in range(arity)])
                c = self.val('d2con_make (mkloc (%d), H_fil (%d), mksym (%d), %s, %d, LN_s2qualst (), 0, %s, ON_s2explstopt ())' % (k, k, k, S[sc], vw, args), 'd2con')
                self.do('d2con_set_tag (%s, %d)' % (c, tag))
                self.dc[name] = c
            scst('p', 's2rt_t0ype', 1); scst('l', 's2rt_vt0ype', 2); scst('s', 's2rt_type', 3); scst('ls', 's2rt_t0ype', 4)
            dcon('con0', 'p', 1, 0, 0); dcon('con1', 'p', 2, 1, 1); dcon('con2', 'p', 3, 2, 2)
            dcon('lin1', 'l', 4, 1, 2, 1); dcon('lin0', 'l', 5, 0, 3, 1)
            dcon('sing', 's', 6, 2, 0)
            self.do('s2cst_set_dconlst (%s, OS_d2conlstopt (%s))' % (S['s'], self.lstx('d2conlst', [self.dc['sing']])))
            dcon('nil', 'ls', 7, 0, 0); dcon('cons', 'ls', 8, 2, 1)
            self.do('s2cst_set_islst (%s, OS_d2conpairopt (K_d2conpair (%s, %s)))' % (S['ls'], self.dc['nil'], self.dc['cons']))
            self.do('s2cst_set_dconlst (%s, OS_d2conlstopt (%s))' % (S['ls'], self.lstx('d2conlst', [self.dc['nil'], self.dc['cons']])))
            dcon('exn0', 'p', 9, 0, -1); dcon('exn1', 'p', 10, 1, -1); dcon('exn2', 'p', 11, 3, -1)
            dcon('none', 'p', 12, 1, -2)
            self.do('$GLOB.the_PACKNAME_set_name ("pk")')
            dcon('pcon1', 'p', 13, 1, 5); dcon('pexn1', 'p', 14, 1, -1)
            scst('pp', 's2rt_t0ype', 15)
            self.do('$GLOB.the_PACKNAME_set_none ()')
            self.dcons = list(self.dc.values())
        def mk_csts(self):
            self.dcs = []
            R = self.R
            k = 0
            self.do('$GLOB.the_PACKNAME_set_none ()')
            combos = [(knd, ext) for knd in range(6) for ext in range(5)] if self.full else [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (1, 0), (1, 3), (3, 2), (5, 1), (2, 4)]
            self.fcs = []
            if True:
                for knd, ext in combos:
                    k += 1
                    if ext == 4 and knd % 2 == 1: self.do('$GLOB.the_PACKNAME_set_name ("pk")')
                    ty = self.fun_s2exp(R.randrange(3), False)
                    c = self.val('d2cst_make (mksym (%d), mkloc (%d), H_fil (%d), mkdcstkind (%d), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (%d))' % (k, k, k, knd, ty, ext), 'd2cst')
                    nargs = R.randrange(0, 3)
                    if knd in (0, 2, 3, 5):
                        hse = self.FT([self.hse_nv() for _ in range(nargs)], self.hse_any(), 0)
                    else:
                        hse = self.hse_nv()
                    self.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (c, hse))
                    self.do('$GLOB.the_PACKNAME_set_none ()')
                    self.dcs.append(c)
                    if knd == 0: self.fcs.append(c)
            # the constants whose type is a function returning the bottom (the call does not return)
            v = self.val('s2var_make_srt (s2rt_t0ype)', 's2var')
            bot = self.val('s2exp_uni (%s, LN_s2explst (), s2exp_var (%s))' % (self.lstx('s2varlst', [v]), v), 's2exp')
            ty = self.val('s2exp_fun_srt (s2rt_t0ype, FUNCLOfun (), 0, s2eff_nil, 0, %s, %s)' % (self.lstx('s2explst', ['s2exp_int (0)']), bot), 's2exp')
            self.bot = self.val('d2cst_make (mksym (3), mkloc (3), H_fil (3), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (2))' % ty, 'd2cst')
            self.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (self.bot, self.FT([self.hse_nv()], self.hse_any(), 0)))
            ty2 = self.val('s2exp_uni (%s, LN_s2explst (), %s)' % (self.lstx('s2varlst', [v]), ty), 's2exp')     # S2Euni around the function
            self.bot2 = self.val('d2cst_make (mksym (4), mkloc (4), H_fil (4), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (2))' % ty2, 'd2cst')
            self.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (self.bot2, self.FT([], self.hse_any(), 0)))
            # (self.fcs: the constants of kind DCKfun, d2cst_is_fundec)
        def fun_s2exp(self, n, bot):
            return self.val('s2exp_fun_srt (s2rt_t0ype, FUNCLOfun (), 0, s2eff_nil, 0, %s, s2exp_int (1))' % self.lstx('s2explst', ['s2exp_int (%d)' % i for i in range(n)]), 's2exp')
        # ---- tmpvars, tmplabs
        def mk_tmps(self):
            R = self.R
            self.tmps = []; self.tmpv = []
            hs = self.hs
            def T(kind, topknd, origin, sfx, hse, tl=0):
                t = self.val('H_tmpvar (%s, %s, %d, %d, %s, %d)' % (self.L(), hse, kind, topknd, origin, sfx), 'tmpvar')
                if tl: t = self.val('H_tmpvar_tl (%s, %d)' % (t, tl), 'tmpvar')
                self.tmps.append(t); return t
            t0 = T(0, 0, 'ON_tmpvaropt ()', 0, hs['int'])
            T(1, 0, 'ON_tmpvaropt ()', 0, hs['int']); T(2, 0, 'ON_tmpvaropt ()', 0, hs['void']); T(0, 1, 'ON_tmpvaropt ()', 0, hs['typtr'])
            T(0, 0, 'OS_tmpvaropt (%s)' % t0, 3, hs['int']); T(1, 1, 'OS_tmpvaropt (%s)' % t0, 5, hs['tybox']); T(2, 1, 'ON_tmpvaropt ()', 0, hs['void'])
            T(2, 0, 'ON_tmpvaropt ()', 0, hs['int'], 2); T(0, 0, 'ON_tmpvaropt ()', 0, hs['void']); T(3, 0, 'ON_tmpvaropt ()', 0, hs['int']); T(3, 1, 'OS_tmpvaropt (%s)' % t0, 2, hs['int'])
            self.tmplabs = [self.val('H_tmplab (%s)' % self.L(), 'tmplab') for _ in range(4)]
        def tv(self): return self.R.choice(self.tmps)
        def tvn(self): return self.R.choice([t for i, t in enumerate(self.tmps) if i not in (2, 6, 8)])    # not of the void type
        def tl(self): return self.R.choice(self.tmplabs)
        # ---- funlabs (with and without funents, with and without environments)
        def mk_funlabs(self):
            R = self.R
            hs = self.hs
            self.fls = []; self.flenv = []; self.flnoenv = []
            d2c = self.fcs[0]
            def FL(name, level, args, res, qopt, tmpknd, origin, sfx, fc=0, t2mas='LN_t2mpmarglst ()'):
                ft = self.FT(args, res, fc)
                f = self.val('H_funlab (H_str (%d), %d, %s, %s, %d, %s, %d, %s)' % (name, level, ft, qopt, tmpknd, origin, sfx, t2mas), 'funlab')
                self.fls.append(f); return f
            f0 = FL(4, 0, [hs['int'], hs['typtr']], hs['int'], 'ON_d2cstopt ()', -1, 'ON_funlabopt ()', 0)
            f1 = FL(5, 1, [], hs['void'], 'OS_d2cstopt (%s)' % self.fcs[1], 0, 'ON_funlabopt ()', 0)         # qualified, extern (DCSTEXTDEFnone(1)? see mk_csts)
            f2 = FL(6, 1, [hs['bool']], hs['bool'], 'OS_d2cstopt (%s)' % self.fcs[0], 2, 'ON_funlabopt ()', 0)  # template instance
            f3 = FL(4, 1, [hs['int']], hs['int'], 'ON_d2cstopt ()', 1, 'OS_funlabopt (%s)' % f0, 3)             # a copy of f0
            f4 = FL(7, 2, [hs['int'], hs['int']], hs['int'], 'ON_d2cstopt ()', -1, 'OS_funlabopt (%s)' % f3, 0)  # a copy of a copy
            f5 = FL(8, 1, [hs['int']], hs['int'], 'ON_d2cstopt ()', -1, 'ON_funlabopt ()', 0, 1)                # cloptr
            f6 = FL(9, 1, [hs['int'], hs['bool']], hs['void'], 'ON_d2cstopt ()', -1, 'ON_funlabopt ()', 2, 2)   # clo (knd 0)
            f7 = FL(10, 1, [], hs['int'], 'ON_d2cstopt ()', -1, 'ON_funlabopt ()', 0, 3)                        # cloref
            f8 = FL(5, 1, [], hs['void'], 'OS_d2cstopt (%s)' % self.fcs[1], 0, 'OS_funlabopt (%s)' % f1, 0)       # a copy of a qualified function
            self.fbase = [f0, f1, f2, f3, f4, f5, f6, f7, f8]
            # function entries (the _fin fields are set by H_funent: the closure of [funent_eval_*] is not computed)
            v = self.vars
            def FE(f, d2es, tmparg='LN_s2explstlst ()', flst=None, fnx=None, vb=None, inss=None, ret=None):
                loc = self.L()
                tmps = [self.tv() for _ in range(R.randrange(0, 4))]
                ent = self.val('H_funent (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)' % (
                    loc, f, self.lstx('s2varlst', [self.svs[0]]) if tmparg != 'LN_s2explstlst ()' else 'LN_s2varlst ()', tmparg,
                    self.R.choice(['ON_tmpsubopt ()', 'ON_tmpsubopt ()', 'OS_tmpsubopt (K_TMPSUBcons (%s, s2exp_int (1), K_TMPSUBnil ()))' % self.svs[1]]),
                    ret or self.R.choice(self.tmps), self.lstx('funlablst', flst or []), d2es, vb or 'H_vbmap0 ()',
                    inss or self.body(R.randrange(0, 3)), self.lstx('tmpvarlst', tmps),
                    self.lstx('funlablst', flst or [f]), d2es, self.lstx('funlablst', fnx or [])), 'funent')
                return ent
            self.FE = FE
            self.denv = lambda i, hse: 'K_d2env (%s, %s)' % (v[i], hse)
            # envless: f0 (no env), f4; envful: f2 (one env), f5, f6, f7
            e0 = FE(f0, 'LN_d2envlst ()'); self.flnoenv += [f0]
            e4 = FE(f4, 'LN_d2envlst ()'); self.flnoenv += [f4]
            e2 = FE(f2, self.lstx('d2envlst', [self.denv(0, hs['int'])]), tmparg=self.lstx('s2explstlst', [self.lstx('s2explst', ['s2exp_int (1)'])]))
            e5 = FE(f5, self.lstx('d2envlst', [self.denv(1, hs['typtr']), self.denv(2, hs['int'])])); self.flenv += [f2, f5]
            e6 = FE(f6, self.lstx('d2envlst', [self.denv(3, hs['bool'])])); self.flenv += [f6]
            e7 = FE(f7, 'LN_d2envlst ()')
            e8 = FE(f8, 'LN_d2envlst ()')
            self.fents = [e0, e4, e2, e5, e6, e7, e8]
            # f1, f3: no funent
        def body(self, n):
            return self.lstx('instrlst', [self.INS(1, simple=True) for _ in range(n)])
        # ---------------------------------------------------------------- primvals
        def PM(self, node, hse=None, loc=None):
            return 'K_primval (%s, %s, %s)' % (loc or self.L(), hse or self.hse_any(), node)
        def PL(self, lab_or_ind, loc=None):
            return 'K_primlab (%s, %s)' % (loc or self.L(), lab_or_ind)
        def PV(self, d=2):
            R = self.R
            if d <= 0 or R.random() < 0.5: return self.PVleaf()
            d -= 1
            k = R.randrange(9)
            if k == 0: return self.PM('K_PMVcastfn (%s, %s)' % (R.choice(self.dcs), self.PV(d)))
            if k == 1: return self.PM('K_PMVselcon (%s, %s, %s)' % (self.PV(d), self.HSG(1), self.labx(R.randrange(3))))
            if k == 2: return self.PM('K_PMVptrof (%s)' % self.PV(d))
            if k == 3: return self.PM('K_PMVvararg (%s)' % self.lstx('primvalist', [self.PV(d) for _ in range(R.randrange(3))]))
            if k == 4: return self.PM('K_PMVrefarg (%d, %d, %s)' % (R.randrange(2), R.randrange(2), self.PV(d)))
            if k == 5: return self.PM('K_PMVlamfix (%s, %s)' % (R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % R.choice(self.vars)]), self.PV(d)))
            if k == 6: return self.SELPV(d)
            return self.PM('K_PMVptrof (%s)' % self.PV(d))
        def PVleaf(self):
            R = self.R
            k = R.randrange(34)
            T = lambda n: self.PM(n)
            if k == 0: return T('K_PMVtmp (%s)' % self.tv())
            if k == 1: return T('K_PMVtmpref (%s)' % self.tv())
            if k == 2: return T('K_PMVarg (%d)' % R.randrange(3))
            if k == 3: return T('K_PMVargref (%d)' % R.randrange(3))
            if k == 4: return T('K_PMVargenv (%d)' % R.randrange(3))
            if k == 5: return T('K_PMVargtmpref (%d)' % R.randrange(3))
            if k == 6: return T('K_PMVcst (%s)' % R.choice(self.dcs))
            if k == 7: return T('K_PMVenv (%s)' % R.choice(self.vars))
            if k == 8: return T('K_PMVint (%d)' % R.choice([0, 1, 7, 100, 123456]))
            if k == 9: return T('K_PMVintrep ("%s")' % R.choice(['0', '1', '1234567890123456789012345678901234567890']))
            if k == 10: return T('K_PMVbool (%s)' % R.choice(['true', 'false']))
            if k == 11: return T('K_PMVchar (H_chr (%d))' % R.choice([0, 7, 10, 39, 65, 92, 127, 200, 255]))
            if k == 12: return T('K_PMVfloat (H_dbl (%d))' % R.randrange(15))
            if k == 13: return T('K_PMVstring (H_str (%d))' % R.randrange(20))
            if k == 14: return T('K_PMVi0nt (mki0nt (%d))' % R.randrange(3))
            if k == 15: return T('K_PMVf0loat (mkf0loat (%d))' % R.randrange(2))
            if k == 16: return T('K_PMVcstsp (K_PMCSTSPmyfil (H_fil (%d)))' % R.randrange(7))
            if k == 17: return T('K_PMVcstsp (K_PMCSTSPmyloc (%s))' % self.L())
            if k == 18: return T('K_PMVcstsp (K_PMCSTSPmyfun (%s))' % R.choice(self.fls))
            if k == 19: return T('K_PMVtyrep (%s)' % self.HSG(1))
            if k == 20: return T('K_PMVsizeof (%s)' % self.HSG(1))
            if k == 21: return T('K_PMVtop ()')
            if k == 22: return T('K_PMVempty ()')
            if k == 23: return T('K_PMVextval ("extv%d")' % R.randrange(3))
            if k == 24: return T('K_PMVfunlab (%s)' % R.choice(self.fls))
            if k == 25: return T('K_PMVcfunlab (%d, %s)' % (R.randrange(3), R.choice(self.fls)))
            if k == 26: return T('K_PMVd2vfunlab (%s, %s)' % (R.choice(self.vars), R.choice(self.fls)))
            if k == 27: return T('K_PMVtmpltcst (%s, %s)' % (R.choice(self.dcs), self.t2mas()))
            if k == 28: return T('K_PMVtmpltvar (%s, %s)' % (R.choice(self.vars), self.t2mas()))
            if k == 29: return T('K_PMVtmpltcstmat (%s, %s, %s)' % (R.choice(self.dcs), self.t2mas(), self.tcmat()))
            if k == 30: return T('K_PMVtmpltvarmat (%s, %s, %s)' % (R.choice(self.vars), self.t2mas(), self.tvmat()))
            if k == 31: return T('K_PMVerror ()')
            if k == 32: return T('K_PMVtmp (%s)' % self.tv())
            return T('K_PMVint (%d)' % R.randrange(5))
        def t2mas(self):
            R = self.R
            n = R.randrange(3)
            return self.lstx('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (self.L(), self.lstx('s2explst', ['s2exp_int (%d)' % i for i in range(R.randrange(3))])) for _ in range(n)])
        def tcmat(self):
            R = self.R; k = R.randrange(3)
            if k == 0: return 'K_TMPCSTMATnone ()'
            if k == 1: return 'K_TMPCSTMATsome2 (%s, %s, %s)' % (R.choice(self.dcs), self.lstx('s2explstlst', [self.lstx('s2explst', ['s2exp_int (1)'])]), R.choice(self.fls))
            return 'K_TMPCSTMATsome2 (%s, LN_s2explstlst (), %s)' % (R.choice(self.dcs), R.choice(self.fls))
        def tvmat(self):
            R = self.R; k = R.randrange(3)
            if k == 0: return 'K_TMPVARMATnone ()'
            return 'K_TMPVARMATsome2 (%s, %s, %s)' % (R.choice(self.vars), self.lstx('s2explstlst', [self.lstx('s2explst', ['s2exp_int (2)'])]), R.choice(self.fls))
        # ---- selections: a type with a path through it
        def TYPATH(self, d=2, forced=None):
            """returns (hse expr, pmls [expr], ok): a nested type and a path through it (labels of the fields, indexes of the arrays)"""
            R = self.R
            def gen(d):
                k = forced if (forced is not None and d == 2) else R.randrange(5)
                if d <= 0: k = 4
                if k == 4:
                    return (self.hse_nv(), [])
                if k == 0:     # array
                    sub, path = gen(d - 1)
                    ind = self.lstx('primvalist', [self.PM('K_PMVint (%d)' % R.randrange(4), self.hs['int'])])
                    return (self.val('hisexp_tyarr (%s, %s)' % (sub, self.lstx('s2explst', ['s2exp_int (%d)' % R.randrange(1, 6)])), 'hisexp'), [self.PL('K_PMLind (%s)' % ind)] + path)
                n = R.randrange(1, 4)
                subs = [gen(d - 1) for _ in range(n)]
                j = R.randrange(n)
                if k == 1:   # record (boxed, flat, external flat)
                    knd = R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt1 (mkstamp (0))', 'K_TYRECKINDflt_ext ("ext")'])
                    t = self.val('hisexp_tyrec (%s, %s)' % (knd, self.LHS([s[0] for s in subs])), 'hisexp')
                    return (t, [self.PL('K_PMLlab (%s)' % self.labx(j))] + subs[j][1])
                if k == 2:   # singleton record
                    t = self.val('hisexp_tyrecsin (%s)' % self.LH(0, subs[0][0]), 'hisexp')
                    return (t, [self.PL('K_PMLlab (%s)' % self.labx(0))] + subs[0][1])
                t = self.val('hisexp_tysum (%s, %s)' % (R.choice(self.dcons), self.LHS([s[0] for s in subs])), 'hisexp')
                return (t, [self.PL('K_PMLlab (%s)' % self.labx(j))] + subs[j][1])
            t, path = gen(d)
            if not path:
                return self.TYPATH(d, forced)
            return t, path
        def SELPV(self, d, which=None):
            R = self.R
            which = which if which is not None else R.randrange(5)
            t, path = self.TYPATH(2)
            pv = self.PV(max(d - 1, 0))
            if which == 0:    # PMVselect: one label, any container (auxsel is not used)
                return self.PM('K_PMVselect (%s, %s, %s)' % (pv, t, path[0]))
            if which == 1: return self.PM('K_PMVselect2 (%s, %s, %s)' % (pv, t, self.lstx('primlablst', path)))
            if which == 2: return self.PM('K_PMVselptr (%s, %s, %s)' % (pv, t, self.lstx('primlablst', path)))
            if which == 3: return self.PM('K_PMVptrofsel (%s, %s, %s)' % (pv, t, self.lstx('primlablst', path)))
            return self.PM('K_PMVselcon (%s, %s, %s)' % (pv, t, self.labx(R.randrange(3))))
        # ---------------------------------------------------------------- instructions
        def LPV(self, hse_rec=None, n=None):
            n = self.R.randrange(0, 4) if n is None else n
            return self.lstx('labprimvalist', ['K_labprimval (%s, %s)' % (self.labx(j), self.PV(1 if self.R.random() < 0.7 else 0)) for j in range(n)])
        def INS(self, d=2, simple=False, which=None):
            R = self.R
            I = lambda n, loc=None: 'K_instr (%s, %s)' % (loc or self.L(), n)
            k = which if which is not None else R.randrange(44 if not simple else 12)
            tv = self.tv; tvn = self.tvn
            if k == 0: return I('K_INSfunlab (%s)' % R.choice(self.fls))
            if k == 1: return I('K_INStmplab (%s)' % self.tl())
            if k == 2: return I('K_INScomment ("%s")' % R.choice(['a comment', 'multi\\nline', '']))
            if k == 3: return I('K_INSmove_val (%s, %s)' % (tv(), self.PV(d)))
            if k == 4: return I('K_INSpmove_val (%s, %s)' % (tv(), self.PV(d)))
            if k == 5: return I('K_INSextfcall (%s, "%s", %s)' % (tv(), R.choice(['printf', 'f_x']), self.lstx('primvalist', [self.PV(d - 1 if d > 0 else 0) for _ in range(R.randrange(3))])))
            if k == 6: return I('K_INSextmcall (%s, %s, "%s", %s)' % (tv(), self.PV(d), R.choice(['mth', 'get']), self.lstx('primvalist', [self.PV(0) for _ in range(R.randrange(3))])))
            if k == 7: return I('K_INSfreecon (%s)' % self.PV(d))
            if k == 8: return I('K_INSloopexn (%d, %s)' % (R.randrange(2), self.tl()))
            if k == 9: return I('K_INSraise (%s, %s)' % (tv(), self.PV(d)))
            if k == 10: return I('K_INSmove_list_nil (%s)' % tv())
            if k == 11: return I('K_INSpmove_list_nil (%s)' % tv())
            if k == 12: return I('K_INSpmove_list_cons (%s, %s)' % (tv(), self.HSG(1)))
            if k == 13: return I('K_INSmove_list_phead (%s, %s, %s)' % (tv(), tv(), self.HSG(1)))
            if k == 14: return I('K_INSmove_list_ptail (%s, %s, %s)' % (tv(), tv(), self.HSG(1)))
            if k == 15: return I('K_INSmove_arrpsz_ptr (%s, %s)' % (tv(), tv()))
            if k == 16: return I('K_INSstore_arrpsz_asz (%s, %d)' % (tv(), R.randrange(5)))
            if k == 17: return I('K_INSstore_arrpsz_ptr (%s, %s, %d)' % (tv(), self.HSG(1), R.randrange(5)))
            if k == 18: return I('K_INSupdate_ptrinc (%s, %s)' % (tv(), self.HSG(1)))
            if k == 19: return I('K_INSupdate_ptrdec (%s, %s)' % (tv(), self.HSG(1)))
            if k == 20: return I('K_INStmpdec (%s)' % tv())
            if k == 21: return I('K_INSextvar ("xv%d", %s)' % (R.randrange(3), self.PV(d)))
            if k == 22: return I('K_INSdcstdef (%s, %s)' % (R.choice(self.dcs), self.PV(d)))
            if k == 23: return I('K_INStempenver (%s)' % self.lstx('d2varlst', [v for v in self.vars[:R.randrange(3)]]))
            if k == 24: return I('K_INSmove_delay (%s, %d, %s, %s)' % (tv(), R.randrange(2), self.HSG(1) if R.random() < 0.6 else self.hs['void'], self.PV(d)))
            if k == 25: return I('K_INSmove_lazyeval (%s, %d, %s, %s)' % (tv(), R.randrange(2), self.HSG(1), self.PV(d)))
            if k == 26: return I('K_INSclosure_initize (%s, %s, %s)' % (tv(), R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % R.choice(self.vars)]), R.choice(self.flenv + [self.fbase[5], self.fbase[6]])))
            if k == 27: return I('K_INSletpop ()')
            if k == 28: return I('K_INSletpush (%s)' % self.lstx('primdeclst', [self.PD(d - 1 if d > 0 else 0) for _ in range(R.randrange(3))]))
            if k == 29: return I('K_INScond (%s, %s, %s)' % (self.PV(1), self.INSL(d - 1 if d > 0 else 0), self.INSL(d - 1 if d > 0 else 0)))
            if k == 30: return I('K_INSloop (%s, %s, %s, %s, %s, %s, %s, %s)' % (self.tl(), self.tl(), self.tl(), self.INSL(d - 1 if d > 0 else 0), self.PV(1),
                                  self.INSL(d - 1 if d > 0 else 0), self.INSL(d - 1 if d > 0 else 0) if R.random() < 0.6 else 'LN_instrlst ()', self.INSL(d - 1 if d > 0 else 0)))
            if k == 31: return I('K_INScaseof (%s)' % self.IBRS(d - 1 if d > 0 else 0))
            if k == 32: return I('K_INStrywith (%s, %s, %s)' % (tv(), self.INSL(d - 1 if d > 0 else 0), self.IBRS(d - 1 if d > 0 else 0)))
            if k == 33: return I('K_INSmove_con (%s, %s, %s, %s)' % (tv(), R.choice(self.dcons), self.HSG(1), self.LPV()))
            if k == 34: return I('K_INSmove_boxrec (%s, %s, %s)' % (tv(), self.LPV(), self.REC(0)))
            if k == 35: return I('K_INSmove_fltrec (%s, %s, %s)' % (tv(), self.LPV(), self.REC(1)))
            if k == 36: return I('K_INSpatck (%s, %s, %s)' % (self.PV(1), self.PCK(), self.PCKNT()))
            if k == 37:
                t, path = self.TYPATH(2)
                return I('K_INSstore_ptrofs (%s, %s, %s, %s)' % (self.PV(1), t, self.lstx('primlablst', path), self.PV(1)))
            if k == 38:
                t, path = self.TYPATH(2)
                return I('K_INSxstore_ptrofs (%s, %s, %s, %s, %s)' % (tv(), self.PV(1), t, self.lstx('primlablst', path), self.PV(1)))
            if k == 39: return self.FCALL(d)
            if k == 40: return self.FCALL2()
            if k == 41: return I('K_INSmove_con (%s, %s, %s, %s)' % (tv(), R.choice(self.dcons), self.HSG(1), self.LPV(n=2)))
            if k == 42: return I('K_INSmove_boxrec (%s, %s, %s)' % (tv(), self.LPV(n=2), self.REC(0)))
            return I('K_INSfreecon (%s)' % self.PV(1))
        def REC(self, flat):
            """a record type (flat: not boxed, with or without the external kind)"""
            R = self.R
            knd = R.choice(['K_TYRECKINDflt0 ()', 'K_TYRECKINDflt_ext ("ext")', 'K_TYRECKINDflt1 (mkstamp (0))']) if flat else R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()'])
            return self.val('hisexp_tyrec (%s, %s)' % (knd, self.LHS([self.hse_nv() for _ in range(R.randrange(1, 4))])), 'hisexp')
        def INSL(self, d, n=None):
            n = self.R.choice([0, 1, 2, 3]) if n is None else n
            return self.lstx('instrlst', [self.INS(d, simple=(d <= 0)) for _ in range(n)])
        def IBRS(self, d):
            n = self.R.choice([0, 1, 2, 3])
            return self.lstx('ibranchlst', ['K_ibranch (%s, %s)' % (self.L(), self.INSL(d)) for _ in range(n)])
        def PCK(self):
            R = self.R; k = R.randrange(8)
            if k == 0: return 'K_PATCKcon (%s)' % R.choice(self.dcons)
            if k == 1: return 'K_PATCKint (%d)' % R.choice([0, 3, 100])
            if k == 2: return 'K_PATCKbool (%s)' % R.choice(['true', 'false'])
            if k == 3: return 'K_PATCKchar (H_chr (%d))' % R.choice([0, 65, 39, 200])
            if k == 4: return 'K_PATCKfloat (H_dbl (%d))' % R.randrange(7)
            if k == 5: return 'K_PATCKstring (H_str (%d))' % R.randrange(12)
            if k == 6: return 'K_PATCKi0nt (mki0nt (%d))' % R.randrange(3)
            return 'K_PATCKf0loat (mkf0loat (%d))' % R.randrange(2)
        def PCKNT(self):
            R = self.R; k = R.randrange(7)
            if k == 0: return 'K_PTCKNTnone ()'
            if k == 1: return 'K_PTCKNTtmplab (%s)' % self.tl()
            if k == 2: return 'K_PTCKNTtmplabint (%s, %d)' % (self.tl(), R.randrange(4))
            if k == 3:
                movs = [self.MOV() for _ in range(R.randrange(0, 3))]
                return 'K_PTCKNTtmplabmov (%s, %s)' % (self.tl(), self.lstx('tmpmovlst', movs))
            if k == 4: return 'K_PTCKNTcaseof_fail (%s)' % self.L()
            if k == 5: return 'K_PTCKNTfunarg_fail (%s, %s)' % (self.L(), R.choice(self.fls))
            return 'K_PTCKNTraise (%s, %s)' % (self.tv(), self.PV(1))
        def MOV(self):
            R = self.R
            src = 'K_TPMVnone (%s)' % self.PV(1) if R.random() < 0.5 else 'K_TPMVsome (%s, %s)' % (self.tv(), self.PV(1))
            return 'K_tmpmov (%s, %s)' % (src, self.tv())
        def FCALL(self, d=1):
            R = self.R
            I = lambda n: 'K_instr (%s, %s)' % (self.L(), n)
            nargs = R.randrange(0, 3)
            args = self.lstx('primvalist', [self.PV(0) for _ in range(nargs)])
            fk = R.randrange(10)
            hse_fun = self.FT([self.hse_nv() for _ in range(nargs)], self.hse_any(), R.choice([0, 0, 1, 2, 3]))
            if fk == 0: f = self.PM('K_PMVcst (%s)' % R.choice(self.fcs))
            elif fk == 1: f = self.PM('K_PMVcst (%s)' % R.choice(self.dcs))
            elif fk == 2: f = self.PM('K_PMVcst (%s)' % self.bot)
            elif fk == 3: f = self.PM('K_PMVcst (%s)' % self.bot2)
            elif fk == 4: f = self.PM('K_PMVfunlab (%s)' % R.choice(self.flnoenv))
            elif fk == 5: f = self.PM('K_PMVcfunlab (%d, %s)' % (R.randrange(2), R.choice(self.flenv + self.flnoenv + [self.fbase[1]])))
            elif fk == 6: f = self.PM('K_PMVtmpltcst (%s, %s)' % (R.choice(self.dcs), self.t2mas()))
            elif fk == 7: f = self.PM('K_PMVtmpltvarmat (%s, %s, %s)' % (R.choice(self.vars), self.t2mas(), self.tvmat()))
            elif fk == 8: f = self.PM('K_PMVrefarg (%d, %d, %s)' % (R.randrange(2), R.randrange(1, 3), self.PV(0)), hse=hse_fun)
            else: f = self.PM('K_PMVtmp (%s)' % self.tv(), hse=hse_fun)     # (aux_funval2 reads the type of the function value: [hse_fun])
            return I('K_INSfcall (%s, %s, %s, %s)' % (self.tv(), f, hse_fun, args))
        def FCALL2(self):
            R = self.R
            n = R.randrange(0, 4)
            args = self.lstx('primvalist', [self.PV(0) for _ in range(n)])
            return 'K_instr (%s, K_INSfcall2 (%s, %s, %d, %s, %s))' % (self.L(), self.tv(), R.choice(self.fls), R.choice([0, 1, 2, 3, 4]), self.FT([self.hse_nv()], self.hse_any()), args)
        # ---------------------------------------------------------------- declarations
        def PD(self, d=1, which=None):
            R = self.R
            P = lambda n: 'K_primdec (%s, %s)' % (self.L(), n)
            k = which if which is not None else R.randrange(15 if d > 0 else 10)
            if k == 0: return P('K_PMDnone ()')
            if k == 1: return P('K_PMDsaspdec (K_s2aspdec (%s, %s, s2exp_int (0)))' % (self.L(), self.pool['s2cst'][0]))
            if k == 2: return P('K_PMDextvar ("ev", %s)' % self.INSL(0, R.randrange(3)))
            if k == 3: return P('K_PMDdatdecs (LN_s2cstlst ())')
            if k == 4: return P('K_PMDexndecs (%s)' % self.lstx('d2conlst', [self.dc['exn0']]))
            if k == 5: return P('K_PMDfundecs (mkfunkind (2), LN_s2qualst (), LN_hifundeclst ())')
            if k == 6: return P('K_PMDvaldecs (mkvalkind (0), LN_hivaldeclst (), %s)' % self.INSL(0, R.randrange(3)))
            if k == 7: return P('K_PMDvaldecs_rec (mkvalkind (1), LN_hivaldeclst (), %s)' % self.INSL(0, R.randrange(3)))
            if k == 8: return P('K_PMDvardecs (LN_hivardeclst (), %s)' % self.INSL(0, R.randrange(3)))
            if k == 9: return P('K_PMDstaload (K_hidecl (%s, K_HIDstaload (%s, H_fil (%d), %d, %s, 0)))' % (self.L(), R.choice(['ON_symbolopt ()', 'OS_symbolopt (mksym (2))']), R.randrange(5), R.randrange(2), self.val('H_filenv (H_fil (0), LN_d2eclist ())', 'filenv')))
            if k == 10: return P('K_PMDimpdec (%s)' % self.IMP())
            if k == 11: return P('K_PMDinclude (%d, %s)' % (R.randrange(2), self.lstx('primdeclst', [self.PD(d - 1) for _ in range(R.randrange(3))])))
            if k == 12: return P('K_PMDlist (%s)' % self.lstx('primdeclst', [self.PD(d - 1) for _ in range(R.randrange(3))]))
            if k == 13: return P('K_PMDstaloadloc (H_fil (%d), mksym (1), %s)' % (R.randrange(5), self.lstx('primdeclst', [self.PD(d - 1) for _ in range(R.randrange(3))])))
            if k == 14: return P('K_PMDlocal (%s, %s)' % (self.lstx('primdeclst', [self.PD(d - 1) for _ in range(R.randrange(3))]), self.lstx('primdeclst', [self.PD(d - 1) for _ in range(R.randrange(3))])))
            return P('K_PMDdynload (hidecl_dynload (%s, H_fil (%d)))' % (self.L(), R.randrange(5)))
        def IMP(self):
            R = self.R
            imp = self.val('hiimpdec_make (%s, %d, %s, LN_s2varlst (), LN_s2explstlst (), hidexp_empty (%s, %s))' % (self.L(), R.randrange(2), R.choice(self.dcs), self.L(), self.hs['void']), 'hiimpdec')
            if R.random() < 0.7:
                self.do('hiimpdec_set_instrlstopt (%s, OS_instrlstopt (%s))' % (imp, self.INSL(0, R.randrange(3))))
            return imp
    return ScC

# --------------------------------------------------------------------------------------------------------------------------------------
def fam_setup(sc, k):
    import hd_cases
    sc.pools()
    hd_cases.setup_perv(sc)

def fam_text(sc, k):
    sc.world()
    out = 'dd_out'
    sc.hdr('text')
    for t in ('emit_LPAREN', 'emit_RPAREN', 'emit_newline'):
        sc.do('%s (%s)' % (t, out))
    sc.do('emit_text (dd_out, "plain text")')
    for i in range(0, 20):
        sc.emit_line('emit_string (dd_out, H_str (%d))' % i)
        sc.emit_line('emit_ident (dd_out, H_str (%d))' % i)
    sc.emit_line('emit_ATSPMVstring (dd_out, H_str (0))')
    sc.emit_line('emit_ATSPMVstring (dd_out, H_str (2))')
    for i in range(0, 256):
        sc.emit_line('emit_char (dd_out, H_chr (%d))' % i)
    for i in range(0, 256, 5):
        sc.emit_line('emit_ATSPMVchar (dd_out, H_chr (%d))' % i)
    for i in range(0, 15):
        sc.emit_line('emit_float (dd_out, H_dbl (%d))' % i)
        sc.emit_line('emit_ATSPMVfloat (dd_out, H_dbl (%d))' % i)
    for i in (0, 1, 7, 100, 123456, 2147483647, -5):
        sc.emit_line('emit_int (dd_out, %d)' % i)
        sc.emit_line('emit_ATSPMVint (dd_out, %d)' % i)
    sc.emit_line('emit_ATSPMVintrep (dd_out, "12345678901234567890")')
    for i in (0, 1, 5, 20, 99, 123456789):
        sc.emit_line('emit_intinf (dd_out, mkintinf (%d))' % i)
    sc.emit_line('emit_intinf (dd_out, $INT.intinf_make_string ("123456789012345678901234567890"))')
    for b in ('true', 'false'):
        sc.emit_line('emit_bool (dd_out, %s)' % b)
        sc.emit_line('emit_ATSPMVbool (dd_out, %s)' % b)
    for i in range(3):
        sc.emit_line('emit_ATSPMVi0nt (dd_out, mki0nt (%d))' % i)
        sc.emit_line('emit_ATSPMVf0loat (dd_out, mkf0loat (%d))' % i)
    for i in range(7):
        sc.emit_line('emit_symbol (dd_out, mksym (%d))' % i)
        sc.emit_line('emit_label (dd_out, mklab (%d))' % i)
        sc.emit_line('emit_atslabel (dd_out, mklab (%d))' % i)
        sc.emit_line('emit_labelext (dd_out, %d, mklab (%d))' % (i % 2, i))
        sc.emit_line('emit_stamp (dd_out, mkstamp (%d))' % i)
    sc.emit_line('emit_label (dd_out, $LAB.label_make_string (H_str (4)))')
    sc.emit_line('emit_labelext (dd_out, 0, $LAB.label_make_string (H_str (7)))')
    for i in range(0, 8):
        sc.emit_line('emit_filename (dd_out, H_fil (%d))' % i)
        sc.emit_line('emit_location (dd_out, mkloc (%d))' % i)
    sc.do('emit_time_stamp (dd_out)')
    for i in range(3):
        sc.emit_line('emit_primcstsp (dd_out, K_PMCSTSPmyfil (H_fil (%d)))' % i)
        sc.emit_line('emit_primcstsp (dd_out, K_PMCSTSPmyloc (mkloc (%d)))' % i)
        sc.emit_line('emit_primcstsp (dd_out, K_PMCSTSPmyfun (%s))' % sc.fls[i])

def fam_names(sc, k):
    sc.world(full=True)
    sc.hdr('names')
    for n, c in sc.sc_.items():
        sc.emit_line('emit_s2cst (dd_out, %s)' % c)
    for c in sc.dcons:
        sc.emit_line('emit_d2con (dd_out, %s)' % c)
        sc.do('emit_d2con_extdec (dd_out, %s)' % c)
    sc.do('emit_d2conlst_extdec (dd_out, %s)' % sc.lstx('d2conlst', sc.dcons))
    sc.do('emit_d2conlst_initize (dd_out, %s)' % sc.lstx('d2conlst', sc.dcons))
    for c in sc.dcs:
        sc.emit_line('emit_d2cst (dd_out, %s)' % c)
        sc.emit_line('emit2_d2cst (dd_out, %s)' % c)
        sc.do('emit_d2cst_extdec (dd_out, %s)' % c)
    sc.do('emit_d2cstlst_extdec (dd_out, %s)' % sc.lstx('d2cstlst', sc.dcs))
    for v in sc.vars:
        sc.emit_line('emit_d2var_env (dd_out, %s)' % v)
    sc.emit_line('emit_symbol (dd_out, d2var_get_sym (%s))' % sc.vars[0])

def fam_tmp(sc, k):
    sc.world()
    sc.hdr('tmps')
    R = sc.R
    for i, t in enumerate(sc.tmplabs):
        sc.emit_line('emit_tmplab (dd_out, %s)' % t)
        sc.emit_line('emit_tmplabint (dd_out, %s, %d)' % (t, i))
    for n in (0, 1, 2, 3, 5):
        sc.do('emit_set_nfnx (%d)' % n)
        for i in range(3):
            sc.emit_line('emit_funarg (dd_out, %d)' % i)
            sc.emit_line('emit_funapy (dd_out, %d)' % i)
    sc.do('emit_set_nfnx (0)')
    for pf in ('none', 'sp_'):
        if pf == 'none': sc.do('$GLOB.the_STATIC_PREFIX_set_none ()')
        else: sc.do('$GLOB.the_STATIC_PREFIX_set_name ("sp_")')
        for t in sc.tmps:
            sc.emit_line('emit_tmpvar (dd_out, %s)' % t)
            sc.do('emit_tmpdec (dd_out, %s)' % t)
        sc.do('emit_tmpdeclst (dd_out, %s)' % sc.lstx('tmpvarlst', sc.tmps))
    sc.do('$GLOB.the_STATIC_PREFIX_set_none ()')
    for f in sc.fls:
        sc.emit_line('emit_funlab (dd_out, %s)' % f)
        sc.emit_line('emit2_funlab (dd_out, %s)' % f)
    # arrays
    hs = sc.hs
    ats = []
    for dims in (['s2exp_int (3)'], ['s2exp_int (2)', 's2exp_int (5)'], ['s2exp_intinf (mkintinf (7))'], ['s2exp_intinf ($INT.intinf_make_string ("123456789012345678901234567890"))'],
                 ['s2exp_var (%s)' % sc.svs[0]], ['s2exp_int (2)', 's2exp_var (%s)' % sc.svs[1], 's2exp_int (3)'], []):
        for elt in ('int', 'void', 'typtr'):
            a = sc.val('hisexp_tyarr (%s, %s)' % (hs[elt], sc.lstx('s2explst', dims)), 'hisexp')
            for tk in (0, 1):
                t = sc.val('H_tmpvar (%s, %s, 0, %d, ON_tmpvaropt (), 0)' % (sc.L(), a, tk), 'tmpvar')
                sc.do('emit_tmpdec (dd_out, %s)' % t)
    sc.do('$GLOB.the_STATIC_PREFIX_set_name ("pf_")')
    sc.do('emit_tmpdec (dd_out, %s)' % sc.tmps[3])
    sc.do('$GLOB.the_STATIC_PREFIX_set_none ()')

def fam_pmv(sc, k):
    sc.world()
    sc.hdr('primval')
    R = sc.R
    for _ in range(40):
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PV(2))
    pvs = [sc.PV(1) for _ in range(4)]
    sc.emit_line('emit_primvalist (dd_out, %s)' % sc.lstx('primvalist', pvs))
    sc.emit_line('emit_primvalist (dd_out, LN_primvalist ())')
    for _ in range(6):
        sc.emit_line('emit_primval_deref (dd_out, %s, %s)' % (sc.PV(1), sc.HSG(1)))
    sc.emit_line('emit_primval_deref (dd_out, %s, %s)' % (sc.PM('K_PMVptrof (%s)' % sc.PV(0)), sc.HSG(1)))
    for ek in (-1, 0, 1):
        sc.emit_line('emit_primlab (dd_out, %d, %s)' % (ek, sc.PL('K_PMLlab (%s)' % sc.labx(1))))
        sc.emit_line('emit_primlab (dd_out, %d, %s)' % (ek, sc.PL('K_PMLind (%s)' % sc.lstx('primvalist', [sc.PV(0), sc.PV(0)]))))
    # ptrof / refarg / vararg shapes
    for t in sc.tmps[:4]:
        pv = sc.PM('K_PMVtmpref (%s)' % t, sc.hs['int'])
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVptrof (%s)' % pv, sc.hs['typtr']))
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVrefarg (0, 0, %s)' % pv))
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVrefarg (1, 1, %s)' % pv))
    arr = sc.val('hisexp_tyarr (%s, %s)' % (sc.hs['int'], sc.lstx('s2explst', ['s2exp_int (2)'])), 'hisexp')
    for hse in (arr, sc.hs['void'], sc.hs['int']):
        pv = sc.PM('K_PMVtmpref (%s)' % sc.tmps[0], hse)
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVptrof (%s)' % pv, sc.hs['typtr']))
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVrefarg (1, 0, %s)' % pv))
    sel = sc.PM('K_PMVselptr (%s, %s, LN_primlablst ())' % (sc.PV(0), sc.hs['tybox']))
    sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVptrof (%s)' % sel))
    sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVrefarg (1, 0, %s)' % sel))
    sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVvararg (LN_primvalist ())'))
    # environments: the funent that is being emitted binds the variables
    ent = sc.FE(sc.fbase[4], 'LN_d2envlst ()', vb='H_vbmap2 (%s, %s, %s, %s)' % (sc.vars[0], sc.PV(0), sc.vars[1], sc.PM('K_PMVint (5)', sc.hs['int'])))
    sc.do('funent_varbindmap_initize (%s)' % ent)
    for v in sc.vars:
        sc.emit_line('emit_d2var_env (dd_out, %s)' % v)
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVenv (%s)' % v))
    sc.do('funent_varbindmap_uninitize (%s)' % ent)
    for v in sc.vars[:2]:
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVenv (%s)' % v))
    d2es = sc.lstx('d2envlst', [sc.denv(0, sc.hs['int']), sc.denv(1, sc.hs['typtr'])])
    sc.drop('emit_d2envlst (dd_out, %s, 0)' % d2es); sc.do('emit_newline (dd_out)')
    sc.drop('emit_d2envlst (dd_out, %s, 2)' % d2es); sc.do('emit_newline (dd_out)')
    sc.drop('emit_d2envlst (dd_out, LN_d2envlst (), 0)'); sc.do('emit_newline (dd_out)')
    sc.emit_line('emit_d2env (dd_out, %s)' % sc.denv(2, sc.hs['int']))
    sc.drop('emit_funenvlst (dd_out, %s)' % d2es); sc.do('emit_newline (dd_out)')
    sc.drop('emit_funenvlst (dd_out, LN_d2envlst ())'); sc.do('emit_newline (dd_out)')
    hl = sc.hsl([sc.hs['int'], sc.hs['bool'], sc.hs['typtr']])
    sc.do('emit_funarglst (dd_out, 0, %s)' % hl); sc.do('emit_newline (dd_out)')
    sc.do('emit_funarglst (dd_out, 2, %s)' % hl); sc.do('emit_newline (dd_out)')
    sc.do('emit_funarglst (dd_out, 1, LN_hisexplst ())'); sc.do('emit_newline (dd_out)')
    sc.do('emit_tyrep (dd_out, %s)' % sc.HSG(1)); sc.do('emit_sizeof (dd_out, %s)' % sc.HSG(1)); sc.do('emit_newline (dd_out)')

def fam_sel(sc, k):
    sc.world()
    sc.hdr('select')
    R = sc.R
    for forced in (0, 1, 2, 3):
        for which in range(5):
            for _ in range(2):
                t, path = sc.TYPATH(2, forced)
                pv = sc.PV(1)
                nodes = [
                  'K_PMVselect (%s, %s, %s)' % (pv, t, path[0]),
                  'K_PMVselect2 (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path)),
                  'K_PMVselptr (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path)),
                  'K_PMVptrofsel (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path)),
                  'K_PMVselcon (%s, %s, %s)' % (pv, t, sc.labx(R.randrange(3)))]
                sc.emit_line('emit_primval (dd_out, %s)' % sc.PM(nodes[which]))
    for _ in range(12):
        t, path = sc.TYPATH(3)
        pv = sc.PM('K_PMVtmpref (%s)' % sc.tvn(), sc.hs['int'])
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVselptr (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path))))
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVselect2 (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path))))
        sc.emit_line('emit_primval (dd_out, %s)' % sc.PM('K_PMVptrofsel (%s, %s, %s)' % (pv, t, sc.lstx('primlablst', path))))
        sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSstore_ptrofs (%s, %s, %s, %s)))' % (sc.L(), pv, t, sc.lstx('primlablst', path), sc.PV(0)))
        sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSxstore_ptrofs (%s, %s, %s, %s, %s)))' % (sc.L(), sc.tv(), pv, t, sc.lstx('primlablst', path), sc.PV(0)))

def fam_ins(sc, k):
    sc.world()
    sc.hdr('instr')
    R = sc.R
    for which in list(range(0, 44)) * 2:
        sc.emit_line('emit_instr (dd_out, %s)' % sc.INS(2, which=which))
    for _ in range(10):
        sc.emit_line('emit_instrlst (dd_out, %s)' % sc.INSL(2))
        sc.emit_line('emit_instrlst_ln (dd_out, %s)' % sc.INSL(1))
    sc.emit_line('emit_instrlst (dd_out, LN_instrlst ())')
    sc.emit_line('emit_instrlst_ln (dd_out, LN_instrlst ())')
    for _ in range(4):
        sc.emit_line('emit_ibranchlst (dd_out, %s)' % sc.IBRS(1))
    sc.emit_line('emit_ibranchlst (dd_out, LN_ibranchlst ())')
    # the fixed shapes of the constructors (a nullary one, the singular one, the lists, the exceptions)
    for c in sc.dcons:
        for hse in (sc.HSG(1), sc.REC(0)):
            sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSmove_con (%s, %s, %s, %s)))' % (sc.L(), sc.tv(), c, hse, sc.LPV()))
            sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSpatck (%s, K_PATCKcon (%s), %s)))' % (sc.L(), sc.PV(0), c, sc.PCKNT()))
    for _ in range(3):
        sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSmove_con (%s, %s, %s, %s)))' % (sc.L(), sc.tv(), sc.dc['con1'], sc.HSG(1), 'LC_labprimvalist (K_labprimval (%s, %s), LN_labprimvalist ())' % (sc.labx(0), sc.PM('K_PMVtop ()'))))
    sc.do('$GLOB.the_DEBUGATS_dbgline_set (1)')
    for _ in range(8):
        sc.emit_line('emit_instr (dd_out, %s)' % sc.INS(1))
    sc.do('$GLOB.the_DEBUGATS_dbgline_set (0)')
    sc.do('$GLOB.the_DEBUGATS_dbgflag_set (1)')
    for which in range(0, 44):
        sc.emit_line('emit_instr (dd_out, %s)' % sc.INS(1, which=which))
    sc.do('$GLOB.the_DEBUGATS_dbgflag_set (0)')

def fam_call(sc, k):
    sc.world()
    sc.hdr('calls')
    R = sc.R
    for _ in range(60):
        sc.emit_line('emit_instr (dd_out, %s)' % sc.FCALL())
    for _ in range(30):
        sc.emit_line('emit_instr (dd_out, %s)' % sc.FCALL2())
    for _ in range(4):
        sc.emit_line('emit_instr_fcall (dd_out, %s)' % sc.FCALL())
        sc.emit_line('emit_instr_fcall2 (dd_out, %s)' % sc.FCALL2())

def fam_pck(sc, k):
    sc.world()
    sc.hdr('patck')
    for c in sc.dcons:
        for fail in range(7):
            sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSpatck (%s, K_PATCKcon (%s), %s)))' % (sc.L(), sc.PV(0), c, sc.PCKNT()))
    for _ in range(40):
        sc.emit_line('emit_instr (dd_out, K_instr (%s, K_INSpatck (%s, %s, %s)))' % (sc.L(), sc.PV(1), sc.PCK(), sc.PCKNT()))
    sc.emit_line('emit_instr_patck (dd_out, K_instr (%s, K_INSpatck (%s, %s, K_PTCKNTnone ())))' % (sc.L(), sc.PV(1), sc.PCK()))

def fam_decl(sc, k):
    sc.world()
    sc.hdr('decl')
    R = sc.R
    L = sc.L
    H = lambda node: 'K_hidecl (%s, %s)' % (L(), node)
    sc.do('emit_exndec (dd_out, %s)' % H('K_HIDexndecs (%s)' % sc.lstx('d2conlst', [sc.dc['exn0'], sc.dc['exn1'], sc.dc['pexn1']])))
    sc.do('emit_exndec (dd_out, %s)' % H('K_HIDexndecs (LN_d2conlst ())'))
    sc.do('emit_saspdec (dd_out, %s)' % H('K_HIDsaspdec (K_s2aspdec (%s, %s, s2exp_int (0)))' % (L(), sc.sc_['p'])))
    sc.do('emit_saspdec (dd_out, %s)' % H('K_HIDsaspdec (K_s2aspdec (%s, %s, s2exp_int (0)))' % (L(), sc.sc_['pp'])))
    for hse in (sc.hs['int'], sc.hs['void'], sc.val('hisexp_tysum (%s, %s)' % (sc.dc['con1'], sc.LHS([sc.hs['int'], sc.hs['bool']])), 'hisexp'),
                sc.val('hisexp_tyrec (K_TYRECKINDflt0 (), %s)' % sc.LHS([sc.hs['int']]), 'hisexp')):
        sc.do('emit_extype (dd_out, %s)' % H('K_HIDextype ("xty", %s)' % hse))
    for code in ('"int x ;\\n"', '""', 'H_str (2)', 'H_str (18)'):
        sc.do('emit_extcode (dd_out, %s)' % H('K_HIDextcode (0, %d, %s)' % (R.randrange(3), code)))
    for i in range(0, 8):
        sc.do('emit_dynload (dd_out, %s)' % H('K_HIDdynload (H_fil (%d))' % i))
    # the declarations of the staloaded files
    ec = lambda knd, pos, code: 'K_d2ecl (%s, K_D2Cextcode (%d, %d, %s))' % (L(), knd, pos, code)
    def stal(fil, d2cs, flag=0, loaded=0):
        fenv = sc.val('H_filenv (H_fil (%d), %s)' % (fil, d2cs), 'filenv')
        return 'K_d2ecl (%s, K_D2Cstaload (ON_symbolopt (), H_fil (%d), %d, %s, %d))' % (L(), fil, flag, fenv, loaded)
    inner_s = sc.lstx('d2eclist', [ec(0, 0, '"/*sta0*/"'), ec(0, 1, '"/*sta1*/"'), ec(1, 0, '"/*sta0k1*/"'), 'K_d2ecl (%s, K_D2Cnone ())' % L()])
    inner_d = sc.lstx('d2eclist', [ec(0, 0, '"/*dyn0*/"'), ec(0, 1, '"/*dyn1*/"')])
    inner_x = sc.lstx('d2eclist', [ec(0, 0, '"/*x0*/"'), 'K_d2ecl (%s, K_D2Clocal (%s, %s))' % (L(), inner_d, inner_s), stal(0, inner_d), stal(1, inner_s)])
    sats_i = 1; sats_j = 5      # H_fil (1) = foo-bar.sats, H_fil (5) = /tmp/été/y_z.sats; 0, 2, 3, 4: not .sats
    ds = []
    for _ in range(6):
        ds.append(sc.lstx('d2eclist', [
            ec(0, 0, 'H_str (%d)' % R.randrange(20)),
            stal(sats_i, inner_s), stal(0, inner_d), stal(sats_j, sc.lstx('d2eclist', [ec(0, 0, '"/*s2*/"')])),
            'K_d2ecl (%s, K_D2Clocal (%s, %s))' % (L(), inner_d, inner_s),
            'K_d2ecl (%s, K_D2Cinclude (%d, %s))' % (L(), R.randrange(2), R.choice([inner_d, inner_s])),
            'K_d2ecl (%s, K_D2Cinclude (0, %s))' % (L(), inner_x), 'K_d2ecl (%s, K_D2Cinclude (1, %s))' % (L(), inner_x),
            'K_d2ecl (%s, K_D2Cstaload (ON_symbolopt (), H_fil (0), 1, %s, 1))' % (L(), sc.val('H_filenv (H_fil (0), %s)' % inner_d, 'filenv')),
            ec(0, 1, '"/*skipped*/"')]))
    for fil in (1, 5, 0, 2, 3):
        for d2cs in ds[:3]:
            fenv = sc.val('H_filenv (H_fil (%d), %s)' % (fil, d2cs), 'filenv')
            sc.do('emit_staload (dd_out, %s)' % H('K_HIDstaload (ON_symbolopt (), H_fil (%d), %d, %s, %d)' % (fil, R.randrange(2), fenv, R.randrange(2))))
    sc.do('emit_staload (dd_out, %s)' % H('K_HIDstaload (ON_symbolopt (), H_fil (1), 0, %s, 0)' % sc.val('H_filenv (H_fil (1), LN_d2eclist ())', 'filenv')))
    for _ in range(12):
        sc.do('emit_primdeclst (dd_out, %s)' % sc.lstx('primdeclst', [sc.PD(2) for _ in range(R.randrange(1, 4))]))
    for w in range(15):
        sc.do('emit_primdeclst (dd_out, %s)' % sc.lstx('primdeclst', [sc.PD(1, which=w)]))
    sc.do('emit_primdeclst (dd_out, LN_primdeclst ())')

def fam_funent(sc, k):
    sc.world()
    sc.hdr('funent')
    R = sc.R
    hs = sc.hs
    ents = list(sc.fents)
    # entries with bodies, template entries, mutually recursive entries (tail calls)
    f10 = sc.FT([hs['int']], hs['int']); 
    def mkfl(name, level, args, res, fc=0, sfx=0, tmpknd=-1, qopt='ON_d2cstopt ()', origin='ON_funlabopt ()'):
        return sc.val('H_funlab (H_str (%d), %d, %s, %s, %d, %s, %d, LN_t2mpmarglst ())' % (name, level, sc.FT(args, res, fc), qopt, tmpknd, origin, sfx), 'funlab')
    for rep in range(4):
        fa = mkfl(11 + rep, 1, [hs['int'], hs['bool']], R.choice([hs['int'], hs['void']]), 0, R.randrange(2))
        fb = mkfl(12 + rep, 1, [hs['int']], hs['int'])
        fc_ = mkfl(13 + rep, 1, [hs['bool'], hs['typtr'], hs['int']], hs['bool'])
        fd_ = mkfl(14 + rep, 1, [hs['int']], hs['void'])      # a function without a function entry
        tmpret = sc.val('H_tmpvar_tl (H_tmpvar (%s, %s, 2, 0, ON_tmpvaropt (), 0), %d)' % (sc.L(), hs['int'], R.choice([0, 1, 2, 3])), 'tmpvar')
        tmpret2 = sc.val('H_tmpvar (%s, %s, 2, 0, ON_tmpvaropt (), 0)' % (sc.L(), hs['void']), 'tmpvar')
        for kind in range(4):
            tmps = [sc.tv() for _ in range(R.randrange(0, 4))]
            fnx = [] if kind < 2 else ([fa, fb, fc_] if kind == 2 else [fa, fb, fd_, fc_])
            d2es = sc.lstx('d2envlst', [sc.denv(i, sc.hse_nv()) for i in range(R.randrange(0, 3))]) if kind % 2 else 'LN_d2envlst ()'
            tmparg = sc.lstx('s2explstlst', [sc.lstx('s2explst', ['s2exp_int (1)', 's2exp_int (2)'])]) if kind == 1 else 'LN_s2explstlst ()'
            ent = sc.val('H_funent (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)' % (
                sc.L(), fa, sc.lstx('s2varlst', [sc.svs[0], sc.svs[1]]) if kind == 1 else 'LN_s2varlst ()', tmparg,
                R.choice(['ON_tmpsubopt ()', 'OS_tmpsubopt (K_TMPSUBcons (%s, s2exp_int (1), K_TMPSUBcons (%s, s2exp_var (%s), K_TMPSUBnil ())))' % (sc.svs[0], sc.svs[1], sc.svs[2])]),
                tmpret if kind != 2 else tmpret2, sc.lstx('funlablst', [fb]), d2es,
                R.choice(['H_vbmap0 ()', 'H_vbmap1 (%s, %s)' % (R.choice(sc.vars), sc.PV(0))]), sc.INSL(2, R.randrange(1, 4)), sc.lstx('tmpvarlst', tmps),
                sc.lstx('funlablst', [fa, fb]), d2es, sc.lstx('funlablst', fnx)), 'funent')
            ents.append(ent)
            if kind >= 2:
                for fl, rt in ((fb, tmpret), (fc_, tmpret2)):
                    e2 = sc.val('H_funent (%s, %s, LN_s2varlst (), LN_s2explstlst (), ON_tmpsubopt (), %s, LN_funlablst (), %s, H_vbmap0 (), %s, %s, LN_funlablst (), %s, LN_funlablst ())' % (
                        sc.L(), fl, rt, d2es, sc.INSL(1, R.randrange(1, 3)), sc.lstx('tmpvarlst', [sc.tv(), sc.tv()]), d2es), 'funent')
    # a function entry whose sibling (fnxlablst) binds a variable that the body of the sibling reads: funent_varbindmap_initize2
    fa = mkfl(30, 1, [hs['int']], hs['int']); fb = mkfl(31, 1, [hs['int']], hs['int'])
    rt = sc.val('H_tmpvar (%s, %s, 2, 0, ON_tmpvaropt (), 0)' % (sc.L(), hs['int']), 'tmpvar')
    body = sc.lstx('instrlst', ['K_instr (%s, K_INSmove_val (%s, %s))' % (sc.L(), rt, sc.PM('K_PMVenv (%s)' % sc.vars[0], hs['int']))])
    sc.val('H_funent (%s, %s, LN_s2varlst (), LN_s2explstlst (), ON_tmpsubopt (), %s, LN_funlablst (), LN_d2envlst (), H_vbmap1 (%s, %s), %s, LN_tmpvarlst (), LN_funlablst (), LN_d2envlst (), LN_funlablst ())' % (
        sc.L(), fb, rt, sc.vars[0], sc.PM('K_PMVint (77)', hs['int']), body), 'funent')
    ents.append(sc.val('H_funent (%s, %s, LN_s2varlst (), LN_s2explstlst (), ON_tmpsubopt (), %s, LN_funlablst (), LN_d2envlst (), H_vbmap0 (), %s, LN_tmpvarlst (), LN_funlablst (), LN_d2envlst (), %s)' % (
        sc.L(), fa, rt, sc.body(1), sc.lstx('funlablst', [fa, fb])), 'funent'))
    for ent in ents:
        sc.do('emit_funent_ptype (dd_out, %s)' % ent)
        sc.do('emit_funent_closure (dd_out, %s)' % ent)
        sc.do('emit_funent_implmnt (dd_out, %s)' % ent)
    for fl in (sc.fbase[1], sc.fbase[3]):
        pass
    sc.do('$GLOB.the_STATIC_PREFIX_set_name ("sp_")')
    for ent in ents[:3]:
        sc.do('emit_funent_implmnt (dd_out, %s)' % ent)
    sc.do('$GLOB.the_STATIC_PREFIX_set_none ()')
    sc.do('emit_funent_ptype (dd_out, %s)' % ents[0])

def exit_cases(ScC, G, R):
    """the functions cax_k (): each builds the (small) values of its case and runs the operation that ends the process"""
    out = []
    def mk(k, body):
        sc = ScC(G, R, 'cax_%d' % k)
        sc.world()
        body(sc)
        out.append(sc.text())
    I = lambda sc, n: 'K_instr (%s, %s)' % (sc.L(), n)
    h = lambda sc: sc.hs['int']
    mk(1, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSmove_ref (%s, %s)' % (sc.tv(), sc.PV(0)))))
    mk(2, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSmove_arg_val (0, %s)' % sc.PV(0))))
    mk(3, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSmove_ptrofsel (%s, %s, %s, LN_primlablst ())' % (sc.tv(), sc.PV(0), sc.hs['tybox']))))
    mk(4, lambda sc: sc.do('emit_primval (dd_out, %s)' % sc.PM('K_PMVselect2 (%s, %s, %s)' % (sc.PV(0), sc.hs['int'], sc.lstx('primlablst', [sc.PL('K_PMLlab (%s)' % sc.labx(0))])))))
    mk(5, lambda sc: sc.do('emit_primval (dd_out, %s)' % sc.PM('K_PMVselptr (%s, %s, %s)' % (sc.PV(0), sc.hs['int'], sc.lstx('primlablst', [sc.PL('K_PMLind (LN_primvalist ())')])))))
    mk(6, lambda sc: sc.do('emit_primval (dd_out, %s)' % sc.PM('K_PMVptrofsel (%s, %s, %s)' % (sc.PV(0), sc.val('hisexp_tyrec (K_TYRECKINDflt0 (), %s)' % sc.LHS([sc.hs['int']]), 'hisexp'), sc.lstx('primlablst', [sc.PL('K_PMLlab (%s)' % sc.labx(5))])))))
    mk(7, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSfcall (%s, %s, %s, LN_primvalist ())' % (sc.tv(), sc.PM('K_PMVtmp (%s)' % sc.tv(), sc.hs['int']), sc.hs['int']))))
    mk(8, lambda sc: (sc.do('d2cst_set2_hisexp (%s, ON_hisexpopt ())' % sc.dcs[-1]), sc.do('emit_d2cst_extdec (dd_out, %s)' % sc.dcs[-1])))
    mk(9, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSclosure_initize (%s, ON_d2varopt (), %s)' % (sc.tv(), sc.fbase[1]))))
    mk(10, lambda sc: sc.do('emit_primval (dd_out, %s)' % sc.PM('K_PMVselect2 (%s, %s, %s)' % (sc.PV(0), sc.val('hisexp_tyrec (K_TYRECKINDflt0 (), %s)' % sc.LHS([sc.hs['int']]), 'hisexp'), sc.lstx('primlablst', [sc.PL('K_PMLlab (%s)' % sc.labx(0)), sc.PL('K_PMLlab (%s)' % sc.labx(0))])))))
    mk(11, lambda sc: sc.do('emit_instr (dd_out, %s)' % I(sc, 'K_INSfcall (%s, %s, %s, LN_primvalist ())' % (sc.tv(), sc.PM('K_PMVcst (%s)' % sc.dcs[-1], sc.hs['int']), sc.hs['bool']))))
    return out

def write_exit(d, C, xs):
    C.put(os.path.join(d, 'ca_exit.hats'), ''.join(xs) + 'fun ca_exit (k: int): void = (\n  tcs_all ();\n' + ''.join('  if k = %d then cax_%d () else\n' % (i + 1, i + 1) for i in range(len(xs))) + '  ()\n)\n')

def main(G, C, M, T, d, CC):
    import hd_cases
    import s2_cases     # (loads s2_cases2: the table of the pervasive constants)
    ScC = build(G, C, hd_cases)
    fams = [('setup', fam_setup, 0), ('text', fam_text, 1), ('names', fam_names, 1), ('tmp', fam_tmp, 1), ('pmv', fam_pmv, 1), ('sel', fam_sel, 1), ('ins', fam_ins, 1), ('call', fam_call, 1), ('pck', fam_pck, 1), ('decl', fam_decl, 1), ('funent', fam_funent, 1)]
    R = random.Random(SEED)
    scs = []
    for name, fam, n in fams:
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
    xs = exit_cases(ScC, G, random.Random(SEED + 1000))
    write_exit(d, C, xs)
    print('ca_cases: %d exit cases, %d scenarios, %d chunks, %d lines' % (len(xs), len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

def write_chunks(d, C, chunks):
    for f in os.listdir(d):   # remove the files of an older generation (more chunks)
        m = re.match(r'^(?:cacase_|cacase1_|ca_cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'ca_cases_%02d.hats' % k
        C.put(os.path.join(d, cases), body)
        sets2 = 'extern fun tcs_all (): void = "ext#catcs"\nimplement tcs_all () = sc_setup_0 ()\n' if k == 0 else ''
        sets1 = 'extern fun tcs_all (): void = "catcs"\nimplement tcs_all () = sc_setup_0 ()\n' if k == 0 else ''
        C.put(os.path.join(d, 'cacase_%02d.dats' % k),
            '(* generated by ca_gen.py: the chunk %d of the cases of the emit test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "ca_pre.hats"\n'
            'extern fun tc%d_all (): void = "ext#catc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n%s' % (k, k, k, cases, k, k, sets2))
        C.put(os.path.join(d, 'cacase1_%02d.dats' % k),
            '(* generated by ca_gen.py: the chunk %d of the cases of the emit test (ATS1) *)\n#include "ca_pre1.hats"\n'
            'extern fun tc%d_all (): void = "catc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n%s' % (k, k, k, cases, k, k, sets1))
        ch2.append('extern fun tc%d_all (): void = "ext#catc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "catc_%d"\n' % (k, k))
    call = 'fun tc_all (): void = {\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    C.put(os.path.join(d, 'ca_chunks.hats'), 'extern fun tcs_all (): void = "ext#catcs"\n' + ''.join(ch2) + call)
    C.put(os.path.join(d, 'ca_chunks1.hats'), 'extern fun tcs_all (): void = "catcs"\n' + ''.join(ch1) + call)
