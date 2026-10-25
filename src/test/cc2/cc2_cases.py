# the generator of the scenarios of the ccomp group C2 test (called by cc2_gen.py, see there and PORTING.md "ccomp group C2")
#
# A scenario is a function (a block of 'val' statements): it creates cells (d2var, d2cst, d2con, ..), the environment of the compilation (a double, cc2_dbl.py),
# builds random erased trees (the smart constructors of pats_hidynexp.sats through the compat layers of the hd test) and calls the functions of the three
# modules, dumping every result completely (cd_primval, cd_instrlst, cd_primdec, cd_ibranchlst, ..). The doubles print the calls that they receive.
# CC2SEED and CC2SCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
import cc2_gen as CG
import cc2_dbl
import hd_cases

G = CG.G
C = CG.d2_cases
d = CG.d
M = CG.M
T = CG.T
put = CG.put

SEED = int(os.environ.get('CC2SEED', '1'))
SCALE = float(os.environ.get('CC2SCALE', '3'))

def build():
    ScH = hd_cases.build(G, C)

    class ScC(ScH):
        # ---- the erased expressions (all the constructors that [hidexp_ccomp] handles; no node that ends the process)
        def E(self, d=2, ret=False):
            """[ret]: the expression is compiled by [hidexp_ccomp_ret] (hidexp_ccomp_ret has no case for [HDEcstsp], [HDEtyrep], [HDEtempenver], [HDEerrexp], [HDErefarg]); a value
            position ([hidexp_ccomp]) has no case for [HDEarrinit] (ATS1: the process ends in both)"""
            R = self.R; L = self.loc(); H = self.hse(1)
            if d <= 0 or R.random() < 0.40:
                ch = [
                  'hidexp_var (%s, %s, %s)' % (L, H, self.var()), 'hidexp_var (%s, %s, %s)' % (L, H, self.var()), 'hidexp_var (%s, %s, %s)' % (L, H, self.var()),
                  'hidexp_cst (%s, %s, %s)' % (L, H, self.cst()),
                  'hidexp_int (%s, %s, %d)' % (L, H, R.randrange(3)), 'hidexp_intrep (%s, %s, "9")' % (L, H),
                  'hidexp_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false'])), 'hidexp_char (%s, %s, mkchr (%d))' % (L, H, R.randrange(2)),
                  'hidexp_float (%s, %s, "1.5")' % (L, H), 'hidexp_string (%s, %s, "s%d")' % (L, H, R.randrange(2)),
                  'hidexp_i0nt (%s, %s, mki0nt (%d))' % (L, H, R.randrange(3)), 'hidexp_f0loat (%s, %s, mkf0loat (%d))' % (L, H, R.randrange(2)),
                  'hidexp_top (%s, %s)' % (L, H), 'hidexp_empty (%s, %s)' % (L, H), 'hidexp_foldat (%s, %s)' % (L, H),
                  'hidexp_extval (%s, %s, "ev")' % (L, H),
                  'hidexp_tmpcst (%s, %s, %s, %s)' % (L, H, self.cst2(), self.gv('t2mpmarglst', 1)), 'hidexp_tmpvar (%s, %s, %s, %s)' % (L, H, self.var(), self.gv('t2mpmarglst', 1)),
                  'hidexp_tmpcst (%s, %s, %s, %s)' % (L, H, self.sizeof_cst(), self.sizeof_marg()),
                  'hidexp_ptrofvar (%s, %s, %s)' % (L, H, self.var()), 'hidexp_vcopyenv (%s, %s, %s)' % (L, H, self.var()),
                  'hidexp_loopexn (%s, %s, %d)' % (L, H, R.randrange(2)),
                  'hidexp_sif (%s, %s, %s, hidexp_int (%s, %s, 1), hidexp_int (%s, %s, 2))' % (L, H, self.gv('s2exp', 1), self.loc(), self.hse(1), self.loc(), self.hse(1))]
                if not ret:
                    ch += ['hidexp_cstsp (%s, %s, mkcstsp (%d))' % (L, H, R.randrange(2)), 'hidexp_tyrep (%s, %s, %s)' % (L, H, self.hse(1)),
                           'hidexp_tempenver (%s, %s, %s)' % (L, H, self.gv('d2varlst', 1)), 'hidexp_cstsp (%s, %s, mkcstsp (%d))' % (L, H, R.randrange(2))]
                return R.choice(ch)
            d -= 1
            k = R.randrange(42)
            if k == 25 and ret: k = 9
            if k == 27 and not ret: k = 26
            if k == 16 and ret: k = 0
            if k == 12 and ret: k = 9   # hidexp_app2 may return its argument
            if k == 2 and ret: k = 1    # hidexp_rec2 may return its only field
            if k == 0:
                n = R.randrange(4)
                xs = [self.E(d) for _ in range(max(n - 1, 0))] + ([self.E(d, ret)] if n > 0 else [])
                return 'hidexp_seq (%s, %s, %s)' % (L, H, self.lstx('hidexplst', xs))
            if k == 1: return 'hidexp_rec (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.le(d), self.hse(1))
            if k == 2: return 'hidexp_rec2 (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.le(d, R.choice([1, 1, 2, 0])), self.hse(1))
            if k == 3: return 'hidexp_let (%s, %s, %s, %s)' % (L, H, self.Dl(d), self.E(d, ret))
            if k == 4: return 'hidexp_let_simplify (%s, %s, %s, %s)' % (L, H, self.Dl(d), self.E(d, ret))
            if k in (5, 6): return 'hidexp_lam (%s, %s, %d, %s, %s)' % (L, self.funhse(), R.choice([0, 0, 1]), self.lstx('hipatlst', [self.P(1) for _ in range(R.randrange(3))]), self.E(d, True))
            if k == 7: return 'hidexp_selvar (%s, %s, %s, %s, %s)' % (L, H, self.var(), self.hse(1), self.ils(d))
            if k == 8: return 'hidexp_selptr (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k in (9, 10, 11): return 'hidexp_app (%s, %s, %s, %s, %s)' % (L, H, self.hse(1), self.E(d), self.es(d))
            if k == 12: return 'hidexp_app2 (%s, %s, %s, %s, %s)' % (L, H, self.hse(1), self.E(d), self.es(d))
            if k in (13, 14): return 'hidexp_if (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.E(d, True), self.E(d, True))
            if k == 15: return 'hidexp_ignore (%s, %s, %s)' % (L, H, self.E(d))
            if k == 16: return 'hidexp_seq_simplify (%s, %s, %s)' % (L, H, self.es(d))
            if k == 17: return 'hidexp_freeat (%s, %s, %s)' % (L, H, self.E(d))
            if k == 18: return 'hidexp_extfcall (%s, %s, "f", %s)' % (L, H, self.es(d))
            if k == 19: return 'hidexp_extmcall (%s, %s, %s, "m", %s)' % (L, H, self.E(d), self.es(d))
            if k in (20, 21): return 'hidexp_con (%s, %s, %s, %s, %s)' % (L, H, self.con(), self.hse(1), self.le(d))
            if k == 22: return 'hidexp_selab (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k == 23: return 'hidexp_ptrofsel (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k == 24: return 'hidexp_castfn (%s, %s, %s, %s)' % (L, H, self.cst(), self.E(d))
            if k == 25: return 'hidexp_refarg (%s, %s, %d, %d, %s)' % (L, H, R.randrange(2), R.randrange(2), self.E(d))
            if k == 26: return 'hidexp_arrpsz (%s, %s, %s, %s, %d)' % (L, H, self.hse(1), self.es(d), R.randrange(4))
            if k == 27: return 'hidexp_arrinit (%s, %s, %s, %s, %s, %d)' % (L, H, self.hse(1), self.E(d), self.es(d), R.randrange(4))
            if k == 28: return 'hidexp_delay (%s, %s, %s)' % (L, H, self.E(d))
            if k == 29: return 'hidexp_ldelay (%s, %s, %s, %s)' % (L, H, self.E(d), self.E(d))
            if k == 30: return 'hidexp_lazyeval (%s, %s, %d, %s)' % (L, H, R.randrange(2), self.E(d))
            if k == 31: return 'hidexp_assgn_var (%s, %s, %s, %s, %s, %s)' % (L, H, self.var(), self.hse(1), self.ils(d), self.E(d))
            if k == 32: return 'hidexp_assgn_ptr (%s, %s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d), self.E(d))
            if k == 33: return 'hidexp_xchng_var (%s, %s, %s, %s, %s, %s)' % (L, H, self.var(), self.hse(1), self.ils(d), self.E(d))
            if k == 34: return 'hidexp_xchng_ptr (%s, %s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d), self.E(d))
            if k == 35: return 'hidexp_raise (%s, %s, %s)' % (L, H, self.E(d))
            if k == 36: return 'hidexp_vararg (%s, %s, %s)' % (L, H, self.es(d))
            if k == 37: return 'hidexp_lst (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.hse(1), self.es(d))
            if k == 38: return 'hidexp_loop (%s, %s, %s, %s, %s, %s)' % (L, H, self.gv('hidexpopt', 0), self.E(d), self.gv('hidexpopt', 0), self.E(d))
            if k == 40: return 'hidexp_case (%s, %s, mkcaskind (%d), %s, %s)' % (L, H, R.randrange(3), self.es(d, 1), self.lstx('hiclaulst', [self.hcl(1, 1) for _ in range(R.randrange(1, 3))]))
            if k == 41: return 'hidexp_trywith (%s, %s, %s, %s)' % (L, H, self.E(d), self.lstx('hiclaulst', [self.hcl(1, 1) for _ in range(R.randrange(1, 3))]))
            return 'hidexp_fix (%s, %s, %d, %s, %s)' % (L, H, R.choice([0, 0, 1]), self.var(), self.lamdef(d))
        def cst2(self):
            return self.R.choice(self.pool['d2cst'][:-1])   # not the designated [sizeof] constant
        def sizeof_cst(self):
            return self.pool['d2cst'][-1]
        def P(self, d=2):
            # as hd_cases.ScH.P, without [hipat_f0loat] (himatchlst_patcomp does not handle it: INTERROR and assertloc)
            R = self.R; L = self.loc(); H = self.hse(1)
            if d <= 0 or R.random() < 0.45:
                return R.choice([
                  'hipat_any (%s, %s, %s)' % (L, H, self.var()), 'hipat_var (%s, %s, %s)' % (L, H, self.var()),
                  'hipat_int (%s, %s, %d)' % (L, H, R.randrange(2)), 'hipat_intrep (%s, %s, "7")' % (L, H),
                  'hipat_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false'])), 'hipat_char (%s, %s, mkchr (%d))' % (L, H, R.randrange(2)),
                  'hipat_string (%s, %s, "s%d")' % (L, H, R.randrange(2)), 'hipat_float (%s, %s, "f%d")' % (L, H, R.randrange(2)),
                  'hipat_i0nt (%s, %s, mki0nt (%d))' % (L, H, R.randrange(3)),
                  'hipat_empty (%s, %s)' % (L, H), 'hipat_con_any (%s, %s, %s, %s)' % (L, H, self.pck(), self.con()),
                  'hipat_any (%s, %s, %s)' % (L, H, self.var()), 'hipat_var (%s, %s, %s)' % (L, H, self.var())])
            d -= 1
            k = R.randrange(6)
            if k == 0: return 'hipat_con (%s, %s, %s, %s, %s, %s)' % (L, H, self.pck(), self.con(), self.hse(1), self.lps(d))
            if k == 1: return 'hipat_rec (%s, %s, %d, %s, %s, %s)' % (L, H, R.randrange(2), self.pck(), self.lps(d), self.hse(1))
            if k == 2: return 'hipat_rec2 (%s, %s, %d, %s, %s, %s)' % (L, H, R.randrange(2), self.pck(), self.lps(d, R.choice([1, 1, 2, 0])), self.hse(1))
            if k == 3: return 'hipat_ann (%s, %s, %s, %s)' % (L, H, self.P(d), self.hse(1))
            if k == 4: return 'hipat_refas (%s, %s, %s, %s)' % (L, H, self.var(), self.P(d))
            return 'hipat_lst (%s, %d, %s, %s, %s)' % (L, R.randrange(2), H, self.hse(1), self.lstx('hipatlst', [self.P(d) for _ in range(R.randrange(3))]))
        def funhse(self):
            return 'hisexp_fun (%s, %s, %s)' % (self.leaf('funclo'), self.hses(1), self.hse(1))
        def lamdef(self, d):
            R = self.R
            return 'hidexp_lam (%s, %s, %d, %s, %s)' % (self.loc(), self.funhse(), R.choice([0, 0, 1]), self.lstx('hipatlst', [self.P(1) for _ in range(R.randrange(3))]), self.E(max(d, 0), True))
        def sizeof_marg(self):
            return 'LC_t2mpmarglst (t2mpmarg_make (%s, LC_s2explst (%s, LN_s2explst ())), LN_t2mpmarglst ())' % (self.loc(), 's2exp_cst (%s)' % self.handle('s2cst'))
        # ---- clauses: [ncol] patterns, guards
        def hgua(self, d):
            R = self.R
            if R.random() < 0.5: o = 'ON_hipatopt ()'
            else: o = 'OS_hipatopt (%s)' % self.P(1)
            return 'higmat_make (%s, %s, %s)' % (self.loc(), self.E(d), o)
        def hcl(self, ncol, d, pat=None):
            R = self.R
            ps = [self.P(2) for _ in range(ncol)]
            n = R.choice([0, 0, 0, 1, 1, 2])
            gs = self.lstx('higmatlst', [self.hgua(max(d - 1, 0)) for _ in range(n)])
            return 'hiclau_make (%s, %s, %s, %d, %d, %s)' % (self.loc(), self.lstx('hipatlst', ps), gs, R.randrange(2), R.randrange(2), self.E(max(d - 1, 0), True))
        # ---- primitive values
        def pmv(self, d=1):
            R = self.R; L = self.loc(); H = self.hse(1)
            k = R.randrange(9)
            if k == 0: return 'primval_int (%s, %s, %d)' % (L, H, R.randrange(3))
            if k == 1: return 'primval_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false']))
            if k == 2: return 'primval_make_tmp (%s, tmpvar_make (%s, %s))' % (L, L, H)
            if k == 3: return 'primval_arg (%s, %s, %d)' % (L, H, R.randrange(3))
            if k == 4: return 'primval_string (%s, %s, "p%d")' % (L, H, R.randrange(3))
            if k == 5: return 'primval_empty (%s, %s)' % (L, H)
            if k == 6: return 'primval_top (%s, %s)' % (L, H)
            if k == 7: return 'primval_cst (%s, %s, %s)' % (L, H, self.cst())
            return 'primval_char (%s, %s, mkchr (%d))' % (L, H, R.randrange(2))
        # ---- the environment of a scenario
        def setup(self, tlcal=None, lev=None, tmplev=None, vars_extra=3):
            R = self.R
            self.do('cc2_reset ()')
            self.pools()
            for _ in range(vars_extra): self.new('d2var')
            V = self.pool['d2var']; K = self.pool['d2cst']
            self.hsev = {}
            for v in V:
                self.do('d2var_set2_hisexp (%s, OS_hisexpopt (%s))' % (v, self.hse(1)))
            self.fvars = list(V)
            for c in K:
                self.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (c, self.hse(1)))
            # two of the constants have a function type that is a closure (the funclo comes from the type)
            self.views = self.mkviews()
            self.do('cc2_sizeof_set (%s)' % ('$UN.cast{ptr} (%s)' % K[-1]))
            tl = R.choice([0, 1, 2]) if tlcal is None else tlcal
            self.do('$GLOB.the_CCOMPATS_tlcalopt_set (%d)' % tl)
            env = self.val('ccompenv_make ()')
            self.env = env
            lv = R.choice([0, 1, 2]) if lev is None else lev
            for _ in range(lv): self.do('cc2_lev_inc ()')
            self.lv = lv
            return env
        def bind_vars(self, p=0.7, view=0.25, utimes=0.5):
            R = self.R
            V = self.pool['d2var']
            for i, v in enumerate(V):
                if R.random() < view:
                    self.do('d2var_set_view (%s, OS_d2varopt (%s))' % (v, V[(i + 1) % len(V)]))
                if R.random() < utimes: self.do('d2var_inc_utimes (%s)' % v)
                self.do('d2var_set_level (%s, %d)' % (v, R.randrange(self.lv + 2)))
                if R.random() < p:
                    k = R.randrange(5)
                    if k == 0: x = self.pmv()
                    elif k == 1:
                        fl = self.val('funlab_make_type (%s)' % self.hse(1), 'funlab')
                        x = 'primval_make_funlab (%s, %s)' % (self.loc(), fl)
                    elif k == 2:
                        fl = self.val('funlab_make_dvar_type (%s, %s, None_vt ())' % (v, self.hse(1)), 'funlab')
                        x = 'primval_d2vfunlab (%s, %s, %s, %s)' % (self.loc(), self.hse(1), v, fl)
                    elif k == 3:
                        fl = self.val('funlab_make_dvar_type (%s, %s, Some_vt (mkfunclo (1)))' % (v, self.hse(1)), 'funlab')
                        x = 'primval_make_funlab (%s, %s)' % (self.loc(), fl)
                    else: x = 'primval_make_tmp (%s, tmpvar_make (%s, %s))' % (self.loc(), self.loc(), self.hse(1))
                    self.do('ccompenv_add_vbindmapenvall (%s, %s, %s)' % (self.env, v, x))
        def tail_frames(self, n=None):
            R = self.R
            K = self.pool['d2cst']; V = self.pool['d2var']
            n = R.choice([0, 1, 2, 3]) if n is None else n
            for _ in range(n):
                k = R.randrange(4)
                if k == 0: fl = self.val('funlab_make_dcst_type (%s, %s, None_vt ())' % (R.choice(K), self.hse(1)), 'funlab')
                elif k == 1: fl = self.val('funlab_make_dvar_type (%s, %s, None_vt ())' % (R.choice(V), self.hse(1)), 'funlab')
                elif k == 2: fl = self.val('funlab_make_tmpcst_type (%s, %s, %s, None_vt ())' % (R.choice(K), self.gv('t2mpmarglst', 1), self.hse(1)), 'funlab')
                else: fl = self.val('funlab_make_type (%s)' % self.hse(1), 'funlab')
                self.do('ccompenv_inc_tailcalenv (%s, %s)' % (self.env, fl))
                if R.random() < 0.3:
                    self.do('ccompenv_inc_tailcalenv_fnx (%s, list_vt_cons (%s, list_vt_cons (%s, list_vt_nil ())))' % (self.env, fl, self.val('funlab_make_dvar_type (%s, %s, None_vt ())' % (R.choice(V), self.hse(1)), 'funlab')))
        def cd(self, typ, expr):
            self.lines.append('  val () = (cd_%s (%s); dd_nl ())' % (typ, expr))
        def finish(self):
            self.do('ccompenv_free (%s)' % self.env)
    return ScH, ScC

def families(G, ScC):
    F = []
    # ------------------------------------------------------------------------------------------------------------ the pervasive static constants (the table of the double of trans2_env, as in the hd test)
    def fam_setup(sc, k):
        cs = hd_cases.setup_perv(sc)
        lc = cs['list_vt0ype_int_vtype']
        nilc = sc.val('d2con_make (mkloc (1), mkfil (0), mksym (1), %s, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())' % lc, 'd2con')
        consc = sc.val('d2con_make (mkloc (2), mkfil (0), mksym (2), %s, 0, LN_s2qualst (), 2, LN_s2explst (), ON_s2explstopt ())' % lc, 'd2con')
        sc.do('s2cst_set_islst (%s, OS_d2conpairopt (K_d2conpair (%s, %s)))' % (lc, nilc, consc))
        sc.dd('hisexp', 'hisexp_int_t0ype ()'); sc.dd('hisexp', 'hisexp_bool_t0ype ()'); sc.dd('hisexp', 'hisexp_size_t0ype ()'); sc.dd('hisexp', 'hisexp_void_t0ype ()')
    F.append(('setup', fam_setup, 0))
    # ------------------------------------------------------------------------------------------------------------ expressions: pmv / ret / pmvv
    def run_exp(sc, k, E, kind):
        if E is None: E = sc.val(sc.E(3, kind == 2), 'hidexp')
        env = sc.env
        L = sc.loc(); H = sc.hse(1)
        sc.call('fprint_hidexp', [E], 'fprint')
        res = sc.val('instrseq_make_nil ()')
        if kind == 0:
            p = sc.val('hidexp_ccomp (%s, %s, %s)' % (env, res, E)); sc.cd('primval', p)
        elif kind == 1:
            p = sc.val('hidexp_ccompv (%s, %s, %s)' % (env, res, E)); sc.cd('primval', p)
        else:
            tmp = sc.val('%s (%s, %s)' % (sc.R.choice(['tmpvar_make_ret', 'tmpvar_make', 'tmpvar_make_ret']), L, H), 'tmpvar')
            sc.do('hidexp_ccomp_ret (%s, %s, %s, %s)' % (env, res, tmp, E)); sc.cd('tmpvar', tmp)
        ins = sc.val('instrseq_get_free (%s)' % res); sc.cd('instrlst', ins)
    def fam_exp(sc, k):
        R = sc.R
        sc.setup()
        sc.bind_vars()
        sc.tail_frames()
        if R.random() < 0.3: sc.do('ccompenv_inc_tmplevel (%s)' % sc.env)
        for _ in range(R.randrange(3, 7)):
            run_exp(sc, k, None, R.choice([0, 0, 1, 2, 2]))
        sc.finish()
    F.append(('exp', fam_exp, 24))
    # ------------------------------------------------------------------------------------------------------------ tail calls: every kind of function value in a frame of the tail-call environment
    def fam_tail(sc, k):
        R = sc.R
        sc.setup(tlcal=R.choice([1, 2]), lev=R.choice([0, 1]))
        env = sc.env
        K = sc.pool['d2cst'][:-1]; V = sc.pool['d2var']
        mode = k % 7
        hse = sc.hse(1); loc = sc.loc()
        v = V[0]
        null = '$UN.cast{ptr} (0)'
        if mode == 0:
            c = K[0]
            fl = sc.val('funlab_make_dcst_type (%s, %s, None_vt ())' % (c, hse))
            fn = 'hidexp_cst (%s, %s, %s)' % (loc, sc.hse(1), c)
        elif mode in (1, 2, 3):
            fcopt = 'None_vt ()' if mode != 2 else 'Some_vt (mkfunclo (1))'
            fl = sc.val('funlab_make_dvar_type (%s, %s, %s)' % (v, hse, fcopt))
            pm = 'primval_d2vfunlab (%s, %s, %s, %s)' % (loc, sc.hse(1), v, fl) if mode == 3 else 'primval_make_funlab (%s, %s)' % (loc, fl)
            sc.do('ccompenv_add_vbindmapenvall (%s, %s, %s)' % (env, v, pm))
            sc.do('d2var_set_level (%s, %d)' % (v, R.choice([0, 1, 2])))
            fn = 'hidexp_var (%s, %s, %s)' % (loc, sc.hse(1), v)
        elif mode == 4:
            sc.do('ccompenv_inc_tmplevel (%s)' % env)
            fl = sc.val('funlab_make_tmpcst_type (%s, %s, %s, None_vt ())' % (K[0], sc.gv('t2mpmarglst', 1), hse))
            fn = 'hidexp_tmpcst (%s, %s, %s, %s)' % (loc, sc.hse(1), K[0], sc.gv('t2mpmarglst', 1))
        else:
            sc.do('ccompenv_inc_tmplevel (%s)' % env)
            fl = sc.val('funlab_make_type (%s)' % hse)
            sc.do('cc2_fl_reg ($UN.cast{ptr} (%s), %s, $UN.cast{ptr} (%s), 1)' % (fl, null, v))
            fn = 'hidexp_tmpvar (%s, %s, %s, %s)' % (loc, sc.hse(1), v, sc.gv('t2mpmarglst', 1))
        sc.do('ccompenv_inc_tailcalenv (%s, %s)' % (env, fl))
        for _ in range(R.randrange(1, 3)):
            res = sc.val('instrseq_make_nil ()')
            tmp = sc.val('tmpvar_make_ret (%s, %s)' % (sc.loc(), sc.hse(1)), 'tmpvar')
            E = sc.val('hidexp_app (%s, %s, %s, %s, %s)' % (sc.loc(), sc.hse(1), sc.hse(1), fn, sc.es(1, R.randrange(3))), 'hidexp')
            sc.do('hidexp_ccomp_ret (%s, %s, %s, %s)' % (env, res, tmp, E)); sc.cd('tmpvar', tmp)
            ins = sc.val('instrseq_get_free (%s)' % res); sc.cd('instrlst', ins)
        sc.finish()
    F.append(('tail', fam_tail, 12))
    # ------------------------------------------------------------------------------------------------------------ the lists of expressions and of labels
    def fam_lists(sc, k):
        R = sc.R
        sc.setup(); sc.bind_vars(); sc.tail_frames(1)
        env = sc.env
        for _ in range(4):
            res = sc.val('instrseq_make_nil ()')
            xs = sc.val(sc.es(2, R.randrange(0, 4)), 'hidexplst')
            p = sc.val('hidexplst_ccomp (%s, %s, %s)' % (env, res, xs)); sc.cd('primvalist', p)
            p = sc.val('hidexplst_ccompv (%s, %s, %s)' % (env, res, xs)); sc.cd('primvalist', p)
            ins = sc.val('instrseq_get_free (%s)' % res); sc.cd('instrlst', ins)
        sc.finish()
    F.append(('lists', fam_lists, 3))
    # ------------------------------------------------------------------------------------------------------------ lambdas and fixpoints
    def fam_lam(sc, k):
        R = sc.R
        sc.setup(lev=R.choice([0, 1, 2]))
        sc.bind_vars(); sc.tail_frames()
        env = sc.env
        if R.random() < 0.4: sc.do('ccompenv_inc_tmplevel (%s)' % env)
        for _ in range(R.randrange(2, 5)):
            kind = R.choice([0, 0, 2, 2])
            if R.random() < 0.5: E = sc.lamdef(R.choice([1, 2, 3]))
            else: E = 'hidexp_fix (%s, %s, %d, %s, %s)' % (sc.loc(), sc.funhse(), R.choice([0, 0, 1]), sc.var(), sc.lamdef(R.choice([1, 2, 3])))
            run_exp(sc, k, sc.val(E, 'hidexp'), kind)
        # the entry of a function, directly
        for _ in range(R.randrange(1, 3)):
            fl = sc.val('funlab_make_type (%s)' % sc.hse(1), 'funlab')
            ins = sc.val('LC_instrlst (instr_funlab (%s, %s), LN_instrlst ())' % (sc.loc(), fl), 'instrlst')
            hips = sc.lstx('hipatlst', [sc.P(1) for _ in range(R.randrange(3))])
            fent = sc.val('hidexp_ccomp_funlab_arg_body (%s, %s, %s, %s, %s, %s, %s, %s)' % (env, fl, sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1), ins, sc.loc(), hips, sc.E(2, True)))
            sc.cd('funent', fent)
        sc.finish()
    F.append(('lam', fam_lam, 16))
    # ------------------------------------------------------------------------------------------------------------ declarations
    def dec_values(sc):
        """the cells that the declarations need: the function variables have an erased type, the variables of [var] a view of the form [s2exp_at]"""
        R = sc.R
        V = sc.pool['d2var']
        views = []
        for _ in range(2):
            v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), R.randrange(1, 6)), 'd2var')
            vw = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), R.randrange(1, 6)))
            sc.do('d2var_set_mastype (%s, OS_s2expopt (K_s2exp (s2rt_type, K_S2Eat (s2exp_cst (%s), s2exp_cst (%s)))))' % (vw, sc.handle('s2cst'), sc.handle('s2cst')))
            sc.do('d2var_set2_hisexp (%s, OS_hisexpopt (%s))' % (v, sc.hse(1)))
            views.append((v, vw)); sc.fvars.append(v)
        return views
    def Dc2(sc, views, d):
        R = sc.R; L = sc.loc()
        V = sc.pool['d2var']; K = sc.pool['d2cst']
        k = R.randrange(24)
        def fd():
            return 'hifundec_make (%s, %s, %s, %s)' % (sc.loc(), R.choice(sc.fvars), sc.gv('s2varlst', 1), sc.lamdef(max(d - 1, 0)))
        def imp():
            c = R.choice(K)
            kk = R.randrange(7)
            if kk == 0: df = sc.lamdef(max(d - 1, 0))
            elif kk == 1: df = 'hidexp_fix (%s, %s, %d, %s, %s)' % (sc.loc(), sc.funhse(), R.choice([0, 1]), R.choice(V), sc.lamdef(max(d - 1, 0)))
            elif kk == 2: df = 'hidexp_cst (%s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(K))
            elif kk == 3: df = 'hidexp_var (%s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(V))
            elif kk == 4: df = 'hidexp_tmpcst (%s, %s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(K[:-1]), sc.gv('t2mpmarglst', 1))
            else: df = sc.lamdef(max(d - 1, 0))
            return 'hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (sc.loc(), R.randrange(2), c, sc.gv('s2varlst', 1), sc.gv('s2explstlst', R.choice([0, 1])), df)
        if k == 0: return 'hidecl_none (%s)' % L if R.random() < 0.5 else 'hidecl_make_node (%s, K_HIDreassume (%s))' % (L, sc.handle('s2cst'))
        if k == 1: return 'hidecl_list (%s, %s)' % (L, sc.Dl2(views, d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
        if k in (2, 3): return 'hidecl_valdecs (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), sc.lstx('hivaldeclst', ['hivaldec_make (%s, %s, %s)' % (sc.loc(), sc.P(1), sc.E(max(d - 1, 0))) for _ in range(R.randrange(3))]))
        if k in (4, 5): return 'hidecl_valdecs_rec (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), sc.lstx('hivaldeclst', ['hivaldec_make (%s, %s, %s)' % (sc.loc(), sc.P(1), sc.E(max(d - 1, 0), True)) for _ in range(R.randrange(3))]))
        if k in (6, 7, 8): return 'hidecl_fundecs (%s, mkfunkind (%d), %s, %s)' % (L, R.choice([0, 1, 1, 2, 2, 3]), sc.gv('s2qualst', R.choice([0, 1])), sc.lstx('hifundeclst', [fd() for _ in range(R.randrange(1, 4))]))
        if k in (9, 10): return 'hidecl_vardecs (%s, %s)' % (L, sc.lstx('hivardeclst', ['hivardec_make (%s, %d, %s, %s, %s, %s)' % (sc.loc(), R.randrange(2), v, vw, sc.hse(1), 'ON_hidexpopt ()' if R.random() < 0.5 else 'OS_hidexpopt (%s)' % sc.E(1, True)) for (v, vw) in [R.choice(views) for _ in range(R.randrange(3))]]))
        if k == 11: return 'hidecl_extcode (%s, %d, %d, "code")' % (L, R.randrange(3), R.randrange(3))
        if k == 12: return 'hidecl_include (%s, %d, %s)' % (L, R.randrange(2), sc.Dl2(views, d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
        if k == 13: return 'hidecl_local (%s, %s, %s)' % (L, sc.Dl2(views, d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()', sc.Dl2(views, d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
        if k in (14, 15): return 'hidecl_impdec (%s, %d, %s)' % (L, R.randrange(2), imp())
        if k == 16: return 'hidecl_extvar (%s, "xv", %s)' % (L, sc.E(max(d - 1, 0)))
        if k == 17: return 'hidecl_extype (%s, "xt", %s)' % (L, sc.hse(1))
        if k == 18: return 'hidecl_staload (%s, %s, mkfil (0), %d, %s, %d)' % (L, sc.gv('symbolopt', 1), R.randrange(2), sc.leaf('filenv'), R.randrange(2))
        if k == 19: return 'hidecl_dynload (%s, mkfil (0))' % L
        if k == 20: return 'hidecl_exndecs (%s, %s)' % (L, sc.gv('d2conlst', 1))
        if k == 21: return 'hidecl_datdecs (%s, %d, %s)' % (L, R.choice([0, 1, 2, 3, 4, 8, 16]), sc.gv('s2cstlst', 1))
        if k == 22: return 'hidecl_saspdec (%s, %s)' % (L, sc.gv('s2aspdec', 1))
        return 'hidecl_staloadloc (%s, mkfil (0), mksym (1), %s)' % (L, sc.Dl2(views, d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
    def Dl2(sc, views, d, n):
        return sc.lstx('hideclist', [Dc2(sc, views, d) for _ in range(n)])
    ScC.Dl2 = Dl2
    ScC.Dc = lambda self, d=1: Dc2(self, self.views, d)
    ScC.mkviews = lambda self: dec_values(self)
    def fam_dec(sc, k):
        R = sc.R
        sc.setup(); sc.bind_vars(); sc.tail_frames(R.choice([0, 0, 1]))
        env = sc.env
        views = dec_values(sc)
        if R.random() < 0.25: sc.do('ccompenv_inc_tmplevel (%s)' % env)
        for _ in range(R.randrange(3, 7)):
            hid = sc.val(Dc2(sc, views, 2), 'hidecl')
            sc.do('(fprint_hidecl (dd_out, %s); dd_nl ())' % hid)
            pmd = sc.val('hidecl_ccomp (%s, %s)' % (env, hid))
            sc.cd('primdec', pmd)
        hids = sc.val(Dl2(sc, views, 1, R.randrange(2, 4)), 'hideclist')
        pmds = sc.val('hideclist_ccomp (%s, %s)' % (env, hids)); sc.cd('primdeclst', pmds)
        sc.finish()
        if R.random() < 0.5:
            hids = sc.val(Dl2(sc, views, 1, R.randrange(1, 3)), 'hideclist')
            pmds = sc.val('hideclist_ccomp0 (%s)' % hids); sc.cd('primdeclst', pmds)
    F.append(('dec', fam_dec, 24))
    def fam_fun(sc, k):
        """function groups and implementations directly: [hifundeclst_ccomp] with the kinds of functions and the level of templates, [hiimpdec_ccomp(_if)]"""
        R = sc.R
        sc.setup(lev=R.choice([0, 1]))
        sc.bind_vars(); sc.tail_frames(R.choice([0, 1]))
        env = sc.env
        V = sc.pool['d2var']; K = sc.pool['d2cst']
        for _ in range(R.randrange(2, 5)):
            hfds = sc.lstx('hifundeclst', ['hifundec_make (%s, %s, %s, %s)' % (sc.loc(), R.choice(sc.fvars), sc.gv('s2varlst', 1), sc.lamdef(R.choice([1, 2]))) for _ in range(R.randrange(1, 4))])
            hfds = sc.val(hfds, 'hifundeclst')
            if R.random() < 0.3: sc.do('ccompenv_inc_tmplevel (%s)' % env)
            sc.do('hifundeclst_ccomp (%s, %d, mkfunkind (%d), %s, %s)' % (env, R.randrange(3), R.choice([0, 1, 1, 2, 2]), sc.gv('s2qualst', R.choice([0, 1])), hfds))
        for _ in range(R.randrange(2, 5)):
            c = R.choice(K)
            kk = R.randrange(6)
            if kk == 0: df = sc.lamdef(2)
            elif kk == 1: df = 'hidexp_cst (%s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(K))
            elif kk == 2: df = 'hidexp_var (%s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(V))
            elif kk == 3: df = 'hidexp_tmpcst (%s, %s, %s, %s)' % (sc.loc(), sc.hse(1), R.choice(K[:-1]), sc.gv('t2mpmarglst', 1))
            elif kk == 4: df = 'hidexp_fix (%s, %s, %d, %s, %s)' % (sc.loc(), sc.funhse(), R.choice([0, 1]), R.choice(V), sc.lamdef(1))
            else: df = sc.E(2) if False else sc.lamdef(1)
            imp = sc.val('hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (sc.loc(), R.randrange(2), c, sc.gv('s2varlst', 1), sc.gv('s2explstlst', R.choice([0, 1])), df), 'hiimpdec')
            if R.random() < 0.5: sc.do('hiimpdec_ccomp (%s, %d, %s, %d)' % (env, R.randrange(3), imp, R.randrange(2)))
            else:
                sc.do('hiimpdec_ccomp_if (%s, %d, %s, %d)' % (env, R.randrange(3), imp, R.randrange(2)))
                sc.do('hiimpdec_ccomp_if (%s, %d, %s, %d)' % (env, R.randrange(3), imp, R.randrange(2)))
            sc.do('(dd_ps "funlabopt: "; cd_funlabopt (hiimpdec_get_funlabopt (%s)); dd_nl ())' % imp)
            sc.do('(dd_ps "d2cst funlab: "; dd_bool (cc2_has_funlab (%s)); dd_nl ())' % c)
        sc.finish()
    F.append(('fun', fam_fun, 12))
    # ------------------------------------------------------------------------------------------------------------ clause matrices
    def fam_claulst(sc, k):
        R = sc.R
        sc.setup(lev=R.choice([0, 1]))
        V = sc.pool['d2var']; D = sc.pool['d2con']
        # the constructors D[0], D[1] belong to the same datatype (a binarian one)
        c = sc.val('s2cst_make (mksym (1), mkloc (1), mkfil (0), s2rt_type, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())', 's2cst')
        sc.do('s2cst_set_dconlst (%s, OS_d2conlstopt (LC_d2conlst (%s, LC_d2conlst (%s, LN_d2conlst ()))))' % (c, D[0], D[1]))
        for v in V:
            if R.random() < 0.6: sc.do('d2var_inc_utimes (%s)' % v)
            if R.random() < 0.3: sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (v, R.choice(V)))
        env = sc.env
        for _ in range(R.randrange(2, 5)):
            ncol = R.choice([1, 1, 2, 3])
            ncl = R.choice([1, 2, 3, 4, 5, 6])
            hicls = sc.val(sc.lstx('hiclaulst', [sc.hcl(ncol, 2) for _ in range(ncl)]), 'hiclaulst')
            pmvs = sc.val(sc.lstx('primvalist', [sc.pmv() for _ in range(ncol)]), 'primvalist')
            tmpret = sc.val('tmpvar_make (%s, %s)' % (sc.loc(), sc.hse(1)), 'tmpvar')
            fk = R.randrange(5)
            if fk == 0: fail = 'K_PTCKNTnone ()'
            elif fk == 1: fail = 'K_PTCKNTcaseof_fail (%s)' % sc.loc()
            elif fk == 2: fail = 'K_PTCKNTfunarg_fail (%s, %s)' % (sc.loc(), sc.val('funlab_make_type (%s)' % sc.hse(1), 'funlab'))
            elif fk == 3: fail = 'K_PTCKNTtmplab (tmplab_make (%s))' % sc.loc()
            else: fail = 'K_PTCKNTraise (%s, %s)' % (tmpret, sc.pmv())
            fl = sc.val(fail, 'patckont')
            sc.do('(dd_ps "fail: "; cd_patckont (%s); dd_nl ())' % fl)
            ibs = sc.val('hiclaulst_ccomp (%s, %d, %s, %s, %s, %s)' % (env, R.randrange(3), pmvs, hicls, tmpret, fl))
            sc.cd('ibranchlst', ibs)
        sc.finish()
    F.append(('claulst', fam_claulst, 48))
    return F

def exit_cases(ScC, R):
    """the functions ccx_k (): each builds the small values of its case and runs the operation that ends the process"""
    out = []
    def mk(k, body):
        sc = ScC(G, R, 'ccx_%d' % k)
        sc.setup(tlcal=1, lev=0)
        body(sc)
        out.append(sc.text())
    V = lambda sc: sc.pool['d2var']
    K = lambda sc: sc.pool['d2cst']
    # 1: an unsupported node ([hidexp_errexp])
    def x1(sc):
        res = sc.val('instrseq_make_nil ()')
        sc.val('hidexp_ccomp (%s, %s, hidexp_errexp (%s, %s))' % (sc.env, res, sc.loc(), sc.hse(1)))
        sc.val('instrseq_get_free (%s)' % res); sc.finish()
    mk(1, x1)
    # 2: a function that is not a lambda
    def x2(sc):
        sc.do('hifundeclst_ccomp (%s, 0, mkfunkind (2), LN_s2qualst (), %s)' % (sc.env, sc.lstx('hifundeclst', ['hifundec_make (%s, %s, LN_s2varlst (), hidexp_int (%s, %s, 1))' % (sc.loc(), V(sc)[0], sc.loc(), sc.hse(1))])))
        sc.finish()
    mk(2, x2)
    # 3: an implement whose definition is not a function but a constant, for a function constant
    def x3(sc):
        c = sc.val('d2cst_make (mksym (3), mkloc (3), mkfil (0), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (0))' % sc.gv('s2exp', 1), 'd2cst')
        sc.do('hiimpdec_ccomp (%s, 0, hiimpdec_make (%s, 0, %s, LN_s2varlst (), LN_s2explstlst (), hidexp_int (%s, %s, 1)), 0)' % (sc.env, sc.loc(), c, sc.loc(), sc.hse(1)))
        sc.finish()
    mk(3, x3)
    # 4: an unsupported pattern
    def x4(sc):
        sc.val('hiclaulst_ccomp (%s, 0, %s, %s, tmpvar_make (%s, %s), K_PTCKNTnone ())' % (sc.env, sc.lstx('primvalist', [sc.pmv()]), sc.lstx('hiclaulst', ['hiclau_make (%s, %s, LN_higmatlst (), 0, 0, hidexp_int (%s, %s, 1))' % (sc.loc(), sc.lstx('hipatlst', ['hipat_make_node (%s, %s, K_HIPerr ())' % (sc.loc(), sc.hse(1))]), sc.loc(), sc.hse(1))]), sc.loc(), sc.hse(1)))
        sc.finish()
    mk(4, x4)
    # 5: the constant [$myfun]
    def x5(sc):
        res = sc.val('instrseq_make_nil ()')
        sc.val('hidexp_ccomp (%s, %s, hidexp_cstsp (%s, %s, mkcstsp (2)))' % (sc.env, res, sc.loc(), sc.hse(1)))
        sc.val('instrseq_get_free (%s)' % res); sc.finish()
    mk(5, x5)
    # 6: a function variable without an erased type
    def x6(sc):
        sc.do('d2var_set2_hisexp (%s, ON_hisexpopt ())' % V(sc)[0])
        sc.do('hifundeclst_ccomp (%s, 0, mkfunkind (2), LN_s2qualst (), %s)' % (sc.env, sc.lstx('hifundeclst', ['hifundec_make (%s, %s, LN_s2varlst (), %s)' % (sc.loc(), V(sc)[0], sc.lamdef(1))])))
        sc.finish()
    mk(6, x6)
    # 7: a variable of [var] whose view has no type
    def x7(sc):
        sc.val('hidecl_ccomp (%s, hidecl_vardecs (%s, %s))' % (sc.env, sc.loc(), sc.lstx('hivardeclst', ['hivardec_make (%s, 0, %s, %s, %s, ON_hidexpopt ())' % (sc.loc(), V(sc)[0], V(sc)[1], sc.hse(1))])))
        sc.finish()
    mk(7, x7)
    # 8: [hidexp_ccomp_ret] of a node that it does not handle
    def x8(sc):
        res = sc.val('instrseq_make_nil ()')
        sc.do('hidexp_ccomp_ret (%s, %s, tmpvar_make (%s, %s), hidexp_cstsp (%s, %s, mkcstsp (0)))' % (sc.env, res, sc.loc(), sc.hse(1), sc.loc(), sc.hse(1)))
        sc.val('instrseq_get_free (%s)' % res); sc.finish()
    mk(8, x8)
    return out

def write_chunks(chunks):
    for f in os.listdir(d):
        m = re.match(r'^(?:cc2case_|cc2case1_|cc2_cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'cc2_cases_%02d.hats' % k
        put(os.path.join(d, cases), body)
        put(os.path.join(d, 'cc2case_%02d.dats' % k),
            '(* generated by cc2_gen.py: the chunk %d of the scenarios of the ccomp group C2 test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "cc2case_pre.hats"\n'
            'extern fun tc%d_all (): void = "ext#cc2tc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        put(os.path.join(d, 'cc2case1_%02d.dats' % k),
            '(* generated by cc2_gen.py: the chunk %d of the scenarios of the ccomp group C2 test (ATS1) *)\n#include "cc2case_pre1.hats"\n'
            'extern fun tc%d_all (): void = "cc2tc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun tc%d_all (): void = "ext#cc2tc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "cc2tc_%d"\n' % (k, k))
    call = 'fun tc_all (): void = {\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    put(os.path.join(d, 'cc2_chunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 'cc2_chunks1.hats'), ''.join(ch1) + call)

# ---------------------------------------------------------------------------------------------------------------------------------- the common text
def fixph(t):
    # the dumpers of the placeholders (instrlst, funlab of the histaexp/hidynexp sats) print the word: not reproducible, print a fixed text
    out = []
    for l in t.split('\n'):
        m = re.match(r'^fun (dd_instrlst|dd_hdinstrlst|dd_funlab) \(x: (\w+)\): void = ', l)
        if m: l = 'fun %s (x: %s): void = dd_ps "placeholder#"' % (m.group(1), m.group(2))
        out.append(l)
    return '\n'.join(out)

def main(CGm):
    # ---- the compat layers of the front end (hd_gen's), under other names
    put(os.path.join(d, 'cc2_hd_compat2.hats'), CG.hd_gen.gen_compat(2))
    ren1 = lambda t: re.sub(r'\bdd_instrlst\b', 'dd_hdinstrlst', re.sub(r'\binstrlst\b', 'hdinstrlst', t))   # ATS1: the typedef of the placeholder would hide the [instrlst] of pats_ccomp.sats
    put(os.path.join(d, 'cc2_hd_compat1.hats'), ren1(CG.hd_gen.gen_compat(1)))
    put(os.path.join(d, 'cc2_hd_hand_b1.hats'), ren1(open(os.path.join(T, 'hd', 'hd_hand_b1.hats')).read()))
    put(os.path.join(d, 'cc2_hd_common2.hats'), CG.hd_gen.common2())
    put(os.path.join(d, 'cc2_hd_hand_a2.hats'), fixph(CG.hd_gen.hand_a(2)))
    put(os.path.join(d, 'cc2_hd_hand_a1.hats'), ren1(fixph(CG.hd_gen.hand_a(1))))
    # ---- the compat layers of ccomp, the cells, the doubles
    put(os.path.join(d, 'cc2_compat2.hats'), CG.gen_cc_compat(2))
    put(os.path.join(d, 'cc2_compat1.hats'), CG.gen_cc_compat(1))
    put(os.path.join(d, 'cc2_cells2.hats'), CG.gen_cells(2))
    put(os.path.join(d, 'cc2_cells1.hats'), CG.gen_cells(1))
    put(os.path.join(d, 'cc2_cdecl.hats'), '(* generated by cc2_gen.py: the C functions of cc2_state.c *)' + cc2_dbl.CDECL)
    put(os.path.join(d, 'cc2_shim2.hats'), cc2_dbl.SHIM2)
    put(os.path.join(d, 'cc2_shim1.hats'), cc2_dbl.SHIM1)
    sc_ = cc2_dbl.smart_constructors()
    put(os.path.join(d, 'cc2_dbl_data.hats'), '(* generated by cc2_gen.py: the smart constructors of the trees of pats_ccomp.sats (the doubles of pats_ccomp.dats) *)\n' + sc_)
    hdr = '(* generated by cc2_gen.py: the test doubles of the ccomp group C2 test (%s), see cc2_dbl.py *)\n#define ATS_DYNLOADFLAG 0\n'
    put(os.path.join(d, 'cc2_dbl2.dats'), hdr % 'ATS2' + '#include "cc2case_pre.hats"\n#include "cc2_cells2.hats"\n#include "cc2_shim2.hats"\n#include "cc2_common.hats"\n#include "../pats_ccomp_gen_dats.hats"\n#include "cc2_dbl_data.hats"\n' + cc2_dbl.NEUTRAL + cc2_dbl.DIALECT2)
    put(os.path.join(d, 'cc2_dbl1.dats'), hdr % 'ATS1' + '#include "cc2case_pre1.hats"\n#include "cc2_cells1.hats"\n#include "cc2_shim1.hats"\n#include "cc2_common.hats"\n#include "cc2_dbl_data.hats"\n' + cc2_dbl.NEUTRAL + cc2_dbl.DIALECT1)
    # ---- the scenarios
    hd_cases.G_HD = [n for n in CG.hd_gen.HDORDER if n in ('hipat_node', 'hidecl_node', 'hidexp_node', 'hilab_node', 'labhipat', 'hipat', 'labhidexp', 'hidecl', 'hidexp', 'hilab', 'higmat', 'hiclau', 'hifundec', 'hivaldec', 'hivardec', 'hiimpdec')]
    ScH, ScC = build()
    F = families(G, ScC)
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
    write_chunks(bodies)
    xs = exit_cases(ScC, random.Random(SEED + 1000))
    put(os.path.join(d, 'cc2_exit.hats'), ''.join(xs) + 'fun cc2_exit (k: int): void = (\n' + ''.join('  if k = %d then ccx_%d () else\n' % (i + 1, i + 1) for i in range(len(xs))) + '  ()\n)\n')
    print('cc2_cases: %d exit cases, %d scenarios, %d chunks, %d lines' % (len(xs), len(scs), len(bodies), sum(b.count('\n') for b in bodies)))
