# the generator of the cases of the erased-tree / typerase test (called by hd_gen.py, see there and PORTING.md "Erased trees (hidynexp)", "Type erasure (typerase)")
#
# A scenario is a function (a block of 'val' statements): it creates cells (s2var, s2cst, d2var, d2cst, d2con), builds random values of the types of the specs
# (the wrappers K_x and the typed lists/options of the compat layers, and the smart constructors of the sats) and calls the functions of the modules,
# dumping every result completely. The machinery (the class Sc, the random leaf values) is that of d2_cases.py. HDSEED and HDSCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
import hd_ty

SEED = int(os.environ.get('HDSEED', '1'))
SCALE = float(os.environ.get('HDSCALE', '3'))

def build(G, C):
    C.TERM.update({
      'hipat_node': ['HIPany', 'HIPvar', 'HIPint', 'HIPintrep', 'HIPbool', 'HIPchar', 'HIPstring', 'HIPfloat', 'HIPi0nt', 'HIPf0loat', 'HIPempty', 'HIPerr'],
      'hidexp_node': ['HDEcst', 'HDEvar', 'HDEint', 'HDEintrep', 'HDEbool', 'HDEchar', 'HDEfloat', 'HDEstring', 'HDEi0nt', 'HDEf0loat', 'HDEcstsp', 'HDEtop',
                      'HDEempty', 'HDEextval', 'HDEfoldat', 'HDEptrofvar', 'HDEtempenver', 'HDEloopexn', 'HDEerrexp', 'HDEtyrep'],
      'hidecl_node': ['HIDnone', 'HIDextcode', 'HIDexndecs', 'HIDdatdecs', 'HIDdcstdecs', 'HIDreassume', 'HIDstaload', 'HIDdynload'],
      'hilab_node': ['HILlab'],
      'hisexp_node': ['HSEtybox', 'HSEcst', 'HSEtyvar'],
    })

    class ScH(C.Sc):
        def leaf(self, t):
            R = self.R
            if t == 'instrlst': return 'mkinstrlst (%d)' % R.randint(0, 5)
            return C.Sc.leaf(self, t)
        def loc(self): return self.leaf('location')
        def pools(self):
            for _ in range(4): self.new('s2var')
            for _ in range(3): self.new('s2cst')
            for _ in range(3): self.new('d2var')
            for _ in range(3): self.new('d2cst')
            for _ in range(3): self.new('d2con')
        def gv(self, t, d):
            if t == 'hisexp': return self.hse(d)
            return C.Sc.gv(self, t, d)
        # the types of the erased syntax (real hisexp built by the smart constructors of pats_histaexp.sats)
        def hses(self, d):
            n = self.R.randrange(4)
            e = 'LN_hisexplst ()'
            for _ in range(n): e = 'LC_hisexplst (%s, %s)' % (self.hse(d), e)
            return e
        def hsess(self, d):
            n = self.R.randrange(3)
            e = 'LN_hisexplstlst ()'
            for _ in range(n): e = 'LC_hisexplstlst (%s, %s)' % (self.hses(max(d - 1, 0)), e)
            return e
        def lh(self, d):
            return 'K_labhisexp (%s, %s, %s)' % (self.leaf('label'), self.R.choice(['ON_stringopt ()', 'OS_stringopt ("nm")']), self.hse(d))
        def lhs(self, d):
            e = 'LN_labhisexplst ()'
            for _ in range(self.R.randrange(4)): e = 'LC_labhisexplst (%s, %s)' % (self.lh(d), e)
            return e
        def hse(self, d=2):
            r = self.R; t = r.random()
            if d <= 0 or t < 0.35:
                return r.choice(['hisexp_tybox', 'hisexp_typtr', 'hisexp_funptr', 'hisexp_cloptr', 'hisexp_clotyp', 'hisexp_arrptr', 'hisexp_datconptr',
                    'hisexp_datcontyp', 'hisexp_exnconptr', 'hisexp_undefined', 'hisexp_int_t0ype ()', 'hisexp_bool_t0ype ()', 'hisexp_size_t0ype ()',
                    'hisexp_void_t0ype ()', 'hisexp_void_t0ype ()', 'hisexp_cst (%s)' % self.handle('s2cst'), 'hisexp_tyabs (%s)' % self.leaf('symbol'),
                    'hisexp_tyvar (%s)' % self.handle('s2var'), 'hisexp_tyvar (%s)' % self.handle('s2var'), 'hisexp_tyclo (%s)' % self.leaf('funlab'),
                    'hisexp_make_srt (%s)' % self.sort(), 'hisexp_make_srtsym (%s, %s)' % (self.sort(), self.leaf('symbol'))])
            d -= 1
            k = r.randrange(9)
            if k == 0: return 'hisexp_app (%s, %s)' % (self.hse(d), self.hses(d))
            if k == 1: return 'hisexp_fun (%s, %s, %s)' % (self.leaf('funclo'), self.hses(d), self.hse(d))
            if k == 2: return 'hisexp_extype ("ext%d", %s)' % (r.randrange(3), self.hsess(d))
            if k == 3: return 'hisexp_refarg (%d, %s)' % (r.randrange(2), self.hse(d))
            if k == 4: return 'hisexp_tyarr (%s, %s)' % (self.hse(d), self.gv('s2explst', 0))
            if k == 5: return 'hisexp_tyrec (%s, %s)' % (self.tyreckind(), self.lhs(d))
            if k == 6: return 'hisexp_tyrecsin (%s)' % self.lh(d)
            if k == 7: return 'hisexp_tyrec2 (%s, %s)' % (self.tyreckind(), self.lhs(d))
            return 'hisexp_tysum (%s, %s)' % (self.handle('d2con'), self.lhs(d))
        def tyreckind(self):
            return self.R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt_ext ("nm")'])
        # ---- small-domain erased trees (the same values come back often, so that the equality tests of [hipat_subtest] succeed)
        def var(self): return self.R.choice(self.pool['d2var'])
        def con(self): return self.R.choice(self.pool['d2con'][:2])
        def cst(self): return self.R.choice(self.pool['d2cst'])
        def lab(self): return 'mklab (%d)' % self.R.randrange(3)
        def pck(self): return 'mkpckind (%d)' % self.R.choice([0, 2])
        def lps(self, d, n=None):
            n = self.R.randrange(4) if n is None else n
            return self.lstx('labhipatlst', ['K_labhipat (%s, %s)' % (self.lab(), self.P(d)) for _ in range(n)])
        def lstx(self, alias, elems):
            e = 'LN_%s ()' % alias
            for x in reversed(elems): e = 'LC_%s (%s, %s)' % (alias, x, e)
            return e
        def P(self, d=2):
            R = self.R; L = self.loc(); H = self.hse(1)
            if d <= 0 or R.random() < 0.45:
                return R.choice([
                  'hipat_any (%s, %s, %s)' % (L, H, self.var()), 'hipat_var (%s, %s, %s)' % (L, H, self.var()),
                  'hipat_int (%s, %s, %d)' % (L, H, R.randrange(2)), 'hipat_intrep (%s, %s, "7")' % (L, H),
                  'hipat_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false'])), 'hipat_char (%s, %s, mkchr (%d))' % (L, H, R.randrange(2)),
                  'hipat_string (%s, %s, "s%d")' % (L, H, R.randrange(2)), 'hipat_float (%s, %s, "f%d")' % (L, H, R.randrange(2)),
                  'hipat_i0nt (%s, %s, mki0nt (%d))' % (L, H, R.randrange(3)), 'hipat_f0loat (%s, %s, mkf0loat (%d))' % (L, H, R.randrange(2)),
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
        def le(self, d, n=None):
            n = self.R.randrange(4) if n is None else n
            return self.lstx('labhidexplst', ['K_labhidexp (%s, %s)' % (self.lab(), self.E(d)) for _ in range(n)])
        def es(self, d, n=None):
            n = self.R.randrange(4) if n is None else n
            return self.lstx('hidexplst', [self.E(d) for _ in range(n)])
        def ils(self, d):
            return self.lstx('hilablst', [(('hilab_lab (%s, %s)' % (self.loc(), self.lab())) if self.R.random() < 0.5 else ('hilab_ind (%s, %s)' % (self.loc(), self.es(d, 2)))) for _ in range(self.R.randrange(3))])
        def E(self, d=2):
            R = self.R; L = self.loc(); H = self.hse(1)
            if d <= 0 or R.random() < 0.45:
                return R.choice([
                  'hidexp_var (%s, %s, %s)' % (L, H, self.var()), 'hidexp_var (%s, %s, %s)' % (L, H, self.var()), 'hidexp_cst (%s, %s, %s)' % (L, H, self.cst()),
                  'hidexp_int (%s, %s, %d)' % (L, H, R.randrange(3)), 'hidexp_intrep (%s, %s, "9")' % (L, H),
                  'hidexp_bool (%s, %s, %s)' % (L, H, R.choice(['true', 'false'])), 'hidexp_char (%s, %s, mkchr (%d))' % (L, H, R.randrange(2)),
                  'hidexp_float (%s, %s, "1.5")' % (L, H), 'hidexp_string (%s, %s, "s%d")' % (L, H, R.randrange(2)),
                  'hidexp_i0nt (%s, %s, mki0nt (%d))' % (L, H, R.randrange(3)), 'hidexp_f0loat (%s, %s, mkf0loat (%d))' % (L, H, R.randrange(2)),
                  'hidexp_cstsp (%s, %s, mkcstsp (%d))' % (L, H, R.randrange(3)), 'hidexp_tyrep (%s, %s, %s)' % (L, H, self.hse(1)),
                  'hidexp_top (%s, %s)' % (L, H), 'hidexp_empty (%s, %s)' % (L, H), 'hidexp_empty (%s, %s)' % (L, H), 'hidexp_foldat (%s, %s)' % (L, H),
                  'hidexp_extval (%s, %s, "ev")' % (L, H), 'hidexp_errexp (%s, %s)' % (L, H),
                  'hidexp_tmpcst (%s, %s, %s, %s)' % (L, H, self.cst(), self.gv('t2mpmarglst', 1)), 'hidexp_tmpvar (%s, %s, %s, %s)' % (L, H, self.var(), self.gv('t2mpmarglst', 1)),
                  'hidexp_ptrofvar (%s, %s, %s)' % (L, H, self.var()), 'hidexp_vcopyenv (%s, %s, %s)' % (L, H, self.var()),
                  'hidexp_tempenver (%s, %s, %s)' % (L, H, self.gv('d2varlst', 1)), 'hidexp_loopexn (%s, %s, %d)' % (L, H, R.randrange(2))])
            d -= 1
            k = R.randrange(22)
            if k == 0: return 'hidexp_seq (%s, %s, %s)' % (L, H, self.es(d))
            if k == 1: return 'hidexp_rec (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.le(d), self.hse(1))
            if k == 2: return 'hidexp_rec2 (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.le(d, R.choice([1, 1, 2, 0])), self.hse(1))
            if k == 3: return 'hidexp_let (%s, %s, %s, %s)' % (L, H, self.Dl(d), self.E(d))
            if k == 4: return 'hidexp_let_simplify (%s, %s, %s, %s)' % (L, H, self.Dl(d), self.E(d))
            if k == 5: return 'hidexp_lam (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.lstx('hipatlst', [self.P(1) for _ in range(R.randrange(3))]), self.E(d))
            if k == 6: return 'hidexp_selvar (%s, %s, %s, %s, %s)' % (L, H, self.var(), self.hse(1), self.ils(d))
            if k == 7: return 'hidexp_selptr (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k == 8: return 'hidexp_app (%s, %s, %s, %s, %s)' % (L, H, self.hse(1), self.E(d), self.es(d))
            if k == 9: return 'hidexp_if (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.E(d), self.E(d))
            if k == 10: return 'hidexp_ignore (%s, %s, %s)' % (L, H, self.E(d))
            if k == 11: return 'hidexp_seq_simplify (%s, %s, %s)' % (L, H, self.es(d))
            if k == 12: return 'hidexp_freeat (%s, %s, %s)' % (L, H, self.E(d))
            if k == 13: return 'hidexp_extfcall (%s, %s, "f", %s)' % (L, H, self.es(d))
            if k == 14: return 'hidexp_con (%s, %s, %s, %s, %s)' % (L, H, self.con(), self.hse(1), self.le(d))
            if k == 15: return 'hidexp_selab (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k == 16: return 'hidexp_ptrofsel (%s, %s, %s, %s, %s)' % (L, H, self.E(d), self.hse(1), self.ils(d))
            if k == 17: return 'hidexp_castfn (%s, %s, %s, %s)' % (L, H, self.cst(), self.E(d))
            if k == 18: return 'hidexp_refarg (%s, %s, %d, %d, %s)' % (L, H, R.randrange(2), R.randrange(2), self.E(d))
            if k == 19: return 'hidexp_arrpsz (%s, %s, %s, %s, %d)' % (L, H, self.hse(1), self.es(d), R.randrange(4))
            if k == 20: return 'hidexp_delay (%s, %s, %s)' % (L, H, self.E(d))
            return 'hidexp_fix (%s, %s, %d, %s, %s)' % (L, H, R.randrange(2), self.var(), self.E(d))
        def Dl(self, d, n=None):
            n = self.R.choice([0, 1, 1, 2, 3]) if n is None else n
            return self.lstx('hideclist', [self.Dc(d) for _ in range(n)])
        def Dc(self, d=1):
            R = self.R; L = self.loc()
            k = R.randrange(14)
            if k == 0: return 'hidecl_none (%s)' % L
            if k == 1: return 'hidecl_list (%s, %s)' % (L, self.Dl(d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
            if k == 2: return 'hidecl_valdecs (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), self.lstx('hivaldeclst', [self.VD(d) for _ in range(R.randrange(3))]))
            if k == 3: return 'hidecl_valdecs_rec (%s, mkvalkind (%d), %s)' % (L, R.randrange(4), self.lstx('hivaldeclst', [self.VD(d) for _ in range(R.randrange(3))]))
            if k == 4: return 'hidecl_fundecs (%s, mkfunkind (%d), %s, %s)' % (L, R.randrange(7), self.gv('s2qualst', 1), self.lstx('hifundeclst', [self.FD(d) for _ in range(R.randrange(3))]))
            if k == 5: return 'hidecl_vardecs (%s, %s)' % (L, self.lstx('hivardeclst', [self.VR(d) for _ in range(R.randrange(3))]))
            if k == 6: return 'hidecl_extcode (%s, %d, %d, "code")' % (L, R.randrange(3), R.randrange(3))
            if k == 7: return 'hidecl_include (%s, %d, %s)' % (L, R.randrange(2), self.Dl(d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
            if k == 8: return 'hidecl_local (%s, %s, %s)' % (L, self.Dl(d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()', self.Dl(d - 1, R.randrange(3)) if d > 0 else 'LN_hideclist ()')
            if k == 9: return 'hidecl_impdec (%s, %d, %s)' % (L, R.randrange(2), self.IM(d))
            if k == 10: return 'hidecl_extvar (%s, "xv", %s)' % (L, self.E(max(d - 1, 0)))
            if k == 11: return 'hidecl_extype (%s, "xt", %s)' % (L, self.hse(1))
            if k == 12: return 'hidecl_staload (%s, %s, mkfil (0), %d, %s, %d)' % (L, self.gv('symbolopt', 1), R.randrange(2), self.leaf('filenv'), R.randrange(2))
            return 'hidecl_dynload (%s, mkfil (0))' % L
        def VD(self, d): return 'hivaldec_make (%s, %s, %s)' % (self.loc(), self.P(max(d - 1, 0)), self.E(max(d - 1, 0)))
        def FD(self, d): return 'hifundec_make (%s, %s, %s, %s)' % (self.loc(), self.var(), self.gv('s2varlst', 1), self.E(max(d - 1, 0)))
        def VR(self, d): return 'hivardec_make (%s, %d, %s, %s, %s, %s)' % (self.loc(), self.R.randrange(2), self.var(), self.var(), self.hse(1), self.gv('hidexpopt', max(d - 1, 0)))
        def IM(self, d): return 'hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (self.loc(), self.R.randrange(2), self.cst(), self.gv('s2varlst', 1), self.gv('s2explstlst', 1), self.E(max(d - 1, 0)))
    import hd_ty
    ScH.zexps = hd_ty.zexps
    return ScH

# ---------------------------------------------------------------------------------------------------------------------
# the smart constructors of pats_hidynexp.sats, parsed from the sats
HIRET = ('hipat', 'hidexp', 'hilab', 'higmat', 'hiclau', 'hifundec', 'hivaldec', 'hivardec', 'hiimpdec', 'hidecl')
def parse_makers(M):
    txt = open(os.path.join(M, 'pats_hidynexp.sats')).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//[^\n]*', '', txt)
    res = []
    for m in re.finditer(r'\bfun\s+(\w+)\s*\(([^()]*)\)\s*:\s*(\w+)', txt):
        name, params, ret = m.group(1), m.group(2), m.group(3)
        if not re.match(r'^(hipat_|hidexp_|hilab_|higmat_|hiclau_|hifundec_|hivaldec_|hivardec_|hiimpdec_|hidecl_)', name): continue
        if 'make_node' in name: continue
        if ret not in HIRET: continue
        ps = []
        for p in params.split(','):
            p = p.strip()
            if not p: continue
            ty = p.split(':')[1].strip()
            ty = {'loc_t': 'location', 'cstsp': 'cstsp'}.get(ty, ty)
            ps.append(ty)
        if not ps: continue
        res.append((name, ps, ret))
    return res

def parse_funs(M, fn):
    """the functions declared in a sats: name -> (params, ret)"""
    txt = open(os.path.join(M, fn)).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//[^\n]*', '', txt)
    res = {}
    for m in re.finditer(r'\bfun\s+(\w+)\s*\(([^()]*)\)\s*:\s*(\w+)', txt):
        res[m.group(1)] = ([p.strip().split(':')[1].strip() for p in m.group(2).split(',') if p.strip()], m.group(3))
    return res

def setup_perv(sc):
    """the pervasive static constants (the table of the test double of trans2_env), stacst2_initialize, the list constructors that [hipat_lst] looks up"""
    import s2_cases
    S2 = sys.modules['s2_cases2']
    cs = {}
    for i, (name, args, res) in enumerate(S2.PERV):
        c = S2.perv_cst(sc, name, args, res, i)
        cs[name] = c
        sc.do('t_penv_add (mksymname ("%s"), K_S2ITMcst (LC_s2cstlst (%s, LN_s2cstlst ())))' % (name, c))
    sc.do('stacst2_initialize ()')
    return cs

def families(G, C, ScH, M):
    F = []
    # ----------------------------------------------------------------------------------------------------------
    def fam_setup(sc, k):
        cs = setup_perv(sc)
        lc = cs['list_vt0ype_int_vtype']
        nilc = sc.val('d2con_make (mkloc (1), mkfil (0), mksym (1), %s, 0, LN_s2qualst (), 0, LN_s2explst (), ON_s2explstopt ())' % lc, 'd2con')
        consc = sc.val('d2con_make (mkloc (2), mkfil (0), mksym (2), %s, 0, LN_s2qualst (), 2, LN_s2explst (), ON_s2explstopt ())' % lc, 'd2con')
        sc.do('s2cst_set_islst (%s, OS_d2conpairopt (K_d2conpair (%s, %s)))' % (lc, nilc, consc))
        for n in ('atstype_int', 'atstype_bool', 'atstype_size', 'atsvoid_t0ype', 'list_vt0ype_int_vtype'):
            sc.dd('s2cst', cs[n])
        sc.dd('d2conpairopt', 's2cst_get_islst (%s)' % lc)
        sc.dd('hisexp', 'hisexp_int_t0ype ()'); sc.dd('hisexp', 'hisexp_bool_t0ype ()'); sc.dd('hisexp', 'hisexp_size_t0ype ()'); sc.dd('hisexp', 'hisexp_void_t0ype ()')
    F.append(('setup', fam_setup, 0))
    # ----------------------------------------------------------------------------------------------------------
    makers = parse_makers(M)
    def fam_make(sc, k):
        R = sc.R
        sc.pools()
        res = []
        for name, ps, ret in makers:
            for rep in range(2):
                args = [sc.gv(t, 2) for t in ps]
                x = sc.val('%s (%s)' % (name, ', '.join(args)), ret)
                res.append((name, ret, x))
                sc.dd(ret, x)
                if ret in ('hipat', 'hidexp', 'hidecl'):
                    sc.call('fprint_' + ret, [x], 'fprint'); sc.call('print_' + ret, [x], 'print'); sc.call('prerr_' + ret, [x], 'prerr')
                elif ret in ('hilab', 'hifundec', 'hivaldec', 'hivardec', 'hiimpdec'):
                    sc.call('fprint_' + ret, [x], 'fprint')
        # the node makers
        x = sc.val('hipat_make_node (%s, %s, K_HIPany (%s))' % (sc.loc(), sc.hse(1), sc.var()), 'hipat'); sc.dd('hipat', x)
        x = sc.val('hidexp_make_node (%s, %s, K_HDEvar (%s))' % (sc.loc(), sc.hse(1), sc.var()), 'hidexp'); sc.dd('hidexp', x)
        x = sc.val('hidecl_make_node (%s, K_HIDnone ())' % sc.loc(), 'hidecl'); sc.dd('hidecl', x)
        # the raw constructors and the records
        for n in G_HD:
            if n in G.recs:
                for _ in range(2):
                    x = sc.val(sc.record(n, 2), n); sc.dd(n, x)
            else:
                for c, ts in G.types[n]:
                    for _ in range(2):
                        x = sc.val(sc.datatype_con(n, c, 2), n); sc.dd(n, x)
        for t in ('hipatlst', 'labhipatlst', 'hideclist', 'hidexplst', 'labhidexplst', 'hilablst', 'higmatlst', 'hiclaulst', 'hifundeclst', 'hivaldeclst', 'hivardeclst', 'hiimpdeclst'):
            sc.dd(t, sc.gv(t, 2))
        for t in ('hipatopt', 'hideclopt', 'hideclistopt', 'hidexpopt', 'hifunlabopt', 'hiinstrlstopt'):
            sc.dd(t, sc.gv(t, 2)); sc.dd(t, 'ON_%s ()' % t)
        # the printers of the lists and options
        for _ in range(3):
            sc.call('fprint_hipatlst', [sc.gv('hipatlst', 2)], 'fprint'); sc.call('fprint_labhipatlst', [sc.gv('labhipatlst', 2)], 'fprint')
            sc.call('fprint_hidexplst', [sc.gv('hidexplst', 2)], 'fprint'); sc.call('fprint_hidexpopt', [sc.gv('hidexpopt', 2)], 'fprint')
            sc.call('fprint_labhidexplst', [sc.gv('labhidexplst', 2)], 'fprint'); sc.call('fprint_hilablst', [sc.gv('hilablst', 2)], 'fprint')
            sc.call('fprint_hideclist', [sc.gv('hideclist', 2)], 'fprint')
        for t, f in (('hipatlst', 'fprint_hipatlst'), ('labhipatlst', 'fprint_labhipatlst'), ('hidexplst', 'fprint_hidexplst'), ('labhidexplst', 'fprint_labhidexplst'),
                     ('hilablst', 'fprint_hilablst'), ('hideclist', 'fprint_hideclist')):
            sc.call(f, ['LN_%s ()' % t], 'fprint')
        sc.call('fprint_hidexpopt', ['ON_hidexpopt ()'], 'fprint')
    F.append(('make', fam_make, 3))

    # ----------------------------------------------------------------------------------------------------------
    def fam_pat(sc, k):
        """the tests on patterns: is_wild, subtest (all the ordered pairs of small-domain patterns), the lists, unused labels, hipat_lst/rec2, set_asvar"""
        R = sc.R
        sc.pools()
        L = sc.loc; H = lambda: sc.hse(1)
        V = sc.pool['d2var']; D = sc.pool['d2con']
        det = []
        for i in range(2):
            det += ['hipat_int (%s, %s, %d)' % (L(), H(), i), 'hipat_bool (%s, %s, %s)' % (L(), H(), ['false', 'true'][i]), 'hipat_char (%s, %s, mkchr (%d))' % (L(), H(), i),
                    'hipat_string (%s, %s, "s%d")' % (L(), H(), i), 'hipat_float (%s, %s, "f%d")' % (L(), H(), i)]
        det += ['hipat_any (%s, %s, %s)' % (L(), H(), V[0]), 'hipat_var (%s, %s, %s)' % (L(), H(), V[1]), 'hipat_empty (%s, %s)' % (L(), H()),
                'hipat_refas (%s, %s, %s, hipat_any (%s, %s, %s))' % (L(), H(), V[0], L(), H(), V[1]), 'hipat_refas (%s, %s, %s, hipat_int (%s, %s, 0))' % (L(), H(), V[0], L(), H()),
                'hipat_ann (%s, %s, hipat_var (%s, %s, %s), %s)' % (L(), H(), L(), H(), V[2], H()), 'hipat_ann (%s, %s, hipat_int (%s, %s, 1), %s)' % (L(), H(), L(), H(), H()),
                'hipat_con_any (%s, %s, mkpckind (0), %s)' % (L(), H(), D[0]), 'hipat_con_any (%s, %s, mkpckind (0), %s)' % (L(), H(), D[1]),
                'hipat_con (%s, %s, mkpckind (0), %s, %s, %s)' % (L(), H(), D[0], H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_int (%s, %s, 0))' % (L(), H())])),
                'hipat_con (%s, %s, mkpckind (0), %s, %s, %s)' % (L(), H(), D[0], H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_any (%s, %s, %s))' % (L(), H(), V[0])])),
                'hipat_con (%s, %s, mkpckind (0), %s, %s, %s)' % (L(), H(), D[1], H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_any (%s, %s, %s))' % (L(), H(), V[0])])),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_int (%s, %s, 1))' % (L(), H())]), H()),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (1), hipat_int (%s, %s, 1))' % (L(), H())]), H()),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_any (%s, %s, %s))' % (L(), H(), V[2])]), H())]
        ps = [sc.val(x, 'hipat') for x in det] + [sc.val(sc.P(2), 'hipat') for _ in range(6)]
        for p in ps:
            sc.call('hipat_is_wild', [p], 'bool')
            sc.call('hipat_get_type', [p], 'hisexp')
        for i in range(len(ps)):
            if i % 2 != k % 2: continue
            for j in range(len(ps)):
                sc.call('hipat_subtest', [ps[i], ps[j]], 'bool')
        # structural copies: the same text twice (the generator is replayed), so that the equality tests succeed more often
        for _ in range(12):
            st = R.getstate()
            a = sc.val(sc.P(2), 'hipat')
            R.setstate(st)
            b = sc.val(sc.P(2), 'hipat')
            sc.call('hipat_subtest', [a, b], 'bool'); sc.call('hipat_subtest', [b, a], 'bool')
        for _ in range(10):
            xs = sc.lstx('hipatlst', [R.choice(ps) for _ in range(R.randrange(4))])
            ys = sc.lstx('hipatlst', [R.choice(ps) for _ in range(R.randrange(4))])
            sc.call('hipatlst_is_wild', [xs], 'bool'); sc.call('hipatlst_subtest', [xs, ys], 'bool'); sc.call('hipatlst_subtest', [xs, xs], 'bool')
            sc.call('fprint_hipatlst', [xs], 'fprint')
        for _ in range(14):
            lx = sc.lps(1, R.randrange(4)); ly = sc.lps(1, R.randrange(4))
            sc.call('labhipatlst_is_wild', [lx], 'bool'); sc.call('labhipatlst_is_unused', [lx], 'bool'); sc.call('labhipatlst_subtest', [lx, ly], 'bool')
            sc.call('labhipatlst_subtest', [lx, lx], 'bool'); sc.call('labhipatlst_get_type', [lx], 'labhisexplst')
        # labels that are all wildcards (unused) and a mix
        w = sc.lstx('labhipatlst', ['K_labhipat (mklab (%d), hipat_any (%s, %s, %s))' % (i, sc.loc(), sc.hse(1), sc.var()) for i in range(3)])
        sc.call('labhipatlst_is_unused', [w], 'bool'); sc.call('labhipatlst_is_wild', [w], 'bool')
        w2 = sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_any (%s, %s, %s))' % (sc.loc(), sc.hse(1), sc.var()), 'K_labhipat (mklab (1), hipat_var (%s, %s, %s))' % (sc.loc(), sc.hse(1), sc.var())])
        sc.call('labhipatlst_is_unused', [w2], 'bool'); sc.call('labhipatlst_is_wild', [w2], 'bool')
        sc.call('labhipatlst_is_unused', [sc.lstx('labhipatlst', [])], 'bool')
        # hipat_lst / hipat_rec2
        for lin in (0, 1):
            for n in range(4):
                x = sc.val('hipat_lst (%s, %d, %s, %s, %s)' % (sc.loc(), lin, sc.hse(1), sc.hse(1), sc.lstx('hipatlst', [R.choice(ps) for _ in range(n)])), 'hipat')
                sc.dd('hipat', x); sc.call('fprint_hipat', [x], 'fprint')
        for knd in (0, 1):
            for n in range(4):
                x = sc.val('hipat_rec2 (%s, %s, %d, %s, %s, %s)' % (sc.loc(), sc.hse(1), knd, sc.pck(), sc.lps(1, n), sc.hse(1)), 'hipat')
                sc.dd('hipat', x)
                y = sc.val('hipat_rec (%s, %s, %d, %s, %s, %s)' % (sc.loc(), sc.hse(1), knd, sc.pck(), sc.lps(1, n), sc.hse(1)), 'hipat')
                sc.dd('hipat', y)
        # the asvar
        for p in ps[:8]:
            sc.do('hipat_set_asvar (%s, OS_d2varopt (%s))' % (p, sc.var()))
            sc.dd('hipat', p)
            sc.do('hipat_set_asvar (%s, ON_d2varopt ())' % p)
            sc.dd('hipat', p)
    F.append(('pat', fam_pat, 2))
    # ----------------------------------------------------------------------------------------------------------
    def exp_setup(sc):
        """the tests on expressions and declarations: is_empty, is_value, is_lvalue, the simplifiers, app2, the types"""
        R = sc.R
        sc.pools()
        V = sc.pool['d2var']
        mv = sc.val('d2var_make (%s, mksym (2))' % sc.loc(), 'd2var')
        sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (mv, V[0]))
        mv2 = sc.val('d2var_make (%s, mksym (3))' % sc.loc(), 'd2var')
        sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (mv2, V[1]))
        sc.call('d2var_is_mutabl', [mv], 'bool'); sc.call('d2var_is_mutabl', [V[0]], 'bool')
        sc.pool['d2var'] = V + [mv, mv2]
        L = sc.loc; H = lambda: sc.hse(1)
        es = [sc.val(sc.E(3), 'hidexp') for _ in range(10)]
        # the shapes that decide the predicates
        sh = []
        sh.append('hidexp_empty (%s, %s)' % (L(), H())); sh.append('hidexp_foldat (%s, %s)' % (L(), H()))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[0], sh[1]])))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[0], 'hidexp_int (%s, %s, 1)' % (L(), H())])))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [])))
        sh.append('hidexp_var (%s, %s, %s)' % (L(), H(), mv)); sh.append('hidexp_var (%s, %s, %s)' % (L(), H(), V[2]))
        sh.append('hidexp_selvar (%s, %s, %s, %s, %s)' % (L(), H(), mv, H(), sc.ils(1))); sh.append('hidexp_selvar (%s, %s, %s, %s, %s)' % (L(), H(), V[2], H(), sc.ils(1)))
        sh.append('hidexp_selptr (%s, %s, %s, %s, %s)' % (L(), H(), sh[0], H(), sc.ils(1)))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[6], sh[5]])))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[5], sh[6]])))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[5]])))
        sh.append('hidexp_seq (%s, %s, %s)' % (L(), H(), sc.lstx('hidexplst', [sh[5], sh[0], sh[8]])))
        sh.append('hidexp_lam (%s, %s, 1, %s, %s)' % (L(), H(), sc.lstx('hipatlst', []), sh[0]))
        sh.append('hidexp_rec (%s, %s, 0, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), %s)' % sh[5], 'K_labhidexp (mklab (1), %s)' % sh[6]]), H()))
        sh.append('hidexp_rec (%s, %s, 0, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), %s)' % sh[0], 'K_labhidexp (mklab (1), %s)' % sh[1]]), H()))
        sh.append('hidexp_rec (%s, %s, 1, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', []), H()))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_none (%s)' % L()]), sh[5]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_extcode (%s, 0, 0, "c")' % L()]), sh[5]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_valdecs (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', ['hivaldec_make (%s, hipat_any (%s, %s, %s), %s)' % (L(), L(), H(), V[0], sh[5])]))]), sh[6]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_valdecs (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', ['hivaldec_make (%s, hipat_any (%s, %s, %s), %s)' % (L(), L(), H(), V[0], 'hidexp_extfcall (%s, %s, "f", %s)' % (L(), H(), sc.lstx('hidexplst', [])))]))]), sh[6]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_fundecs (%s, mkfunkind (2), %s, %s)' % (L(), sc.lstx('s2qualst', []), sc.lstx('hifundeclst', []))]), sh[6]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_list (%s, %s)' % (L(), sc.lstx('hideclist', ['hidecl_none (%s)' % L()]))]), sh[6]))
        sh.append('hidexp_let (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', ['hidecl_vardecs (%s, %s)' % (L(), sc.lstx('hivardeclst', []))]), sh[6]))
        return R, V, L, H, es, sh, mv, mv2
    def fam_exp(sc, k):
        R, V, L, H, es, sh, mv, mv2 = exp_setup(sc)
        for x in sh[:14]: es.append(sc.val(x, 'hidexp'))
        for e in es:
            sc.call('hidexp_is_empty', [e], 'bool'); sc.call('hidexp_is_value', [e], 'bool'); sc.call('hidexp_is_lvalue', [e], 'bool'); sc.call('hidexp_get_type', [e], 'hisexp')
            sc.dd('hidexp', e)
            sc.call('fprint_hidexp', [e], 'fprint'); sc.call('print_hidexp', [e], 'print'); sc.call('prerr_hidexp', [e], 'prerr')

    F.append(('exp', fam_exp, 2))
    def fam_exp2(sc, k):
        R, V, L, H, es, sh, mv, mv2 = exp_setup(sc)
        sh.append('hidexp_let (%s, %s, %s, hidexp_int (%s, %s, 1))' % (L(), H(), sc.lstx('hideclist', ['hidecl_none (%s)' % L()]), L(), H()))
        sh.append('hidexp_let (%s, %s, %s, hidexp_ignore (%s, %s, %s))' % (L(), H(), sc.lstx('hideclist', []), L(), H(), sh[5]))
        for x in sh[14:]: es.append(sc.val(x, 'hidexp'))
        for e in es[-12:]:
            sc.call('hidexp_is_empty', [e], 'bool'); sc.call('hidexp_is_value', [e], 'bool'); sc.call('hidexp_is_lvalue', [e], 'bool')
        for _ in range(12):
            xs = sc.lstx('hidexplst', [R.choice(es) for _ in range(R.randrange(5))])
            sc.call('hidexplst_isall_empty', [xs], 'bool'); sc.call('hidexplst_isexi_empty', [xs], 'bool'); sc.call('hidexplst_get_type', [xs], 'hisexplst')
            sc.call('fprint_hidexplst', [xs], 'fprint')
            x = sc.val('hidexp_seq_simplify (%s, %s, %s)' % (L(), H(), xs), 'hidexp'); sc.dd('hidexp', x)
        emp = [e for e in es[-30:]]
        for _ in range(8):
            xs = sc.lstx('hidexplst', [sh[R.choice([0, 1, 2, 4])] for _ in range(R.randrange(4))] + [R.choice(es)] + [sh[R.choice([0, 1, 2])] for _ in range(R.randrange(3))])
            x = sc.val('hidexp_seq_simplify (%s, %s, %s)' % (L(), H(), xs), 'hidexp'); sc.dd('hidexp', x)
        for xs in ('LN_hidexplst ()', sc.lstx('hidexplst', [sh[0], sh[1]]), sc.lstx('hidexplst', [sh[0]])):
            x = sc.val('hidexp_seq_simplify (%s, %s, %s)' % (L(), H(), xs), 'hidexp'); sc.dd('hidexp', x)

    F.append(('exp2', fam_exp2, 2))
    def fam_exp3(sc, k):
        R, V, L, H, es, sh, mv, mv2 = exp_setup(sc)
        # the let simplifier: the last declaration binds a variable / a wildcard / an empty pattern, the body is that variable / empty
        v0, v1 = V[0], V[1]
        pats = ['hipat_var (%s, %s, %s)' % (L(), H(), v0), 'hipat_var (%s, %s, %s)' % (L(), H(), v1), 'hipat_any (%s, %s, %s)' % (L(), H(), v0), 'hipat_empty (%s, %s)' % (L(), H()),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_var (%s, %s, %s))' % (L(), H(), v0)]), H()),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_empty (%s, %s))' % (L(), H())]), H()),
                'hipat_rec (%s, %s, 1, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_var (%s, %s, %s))' % (L(), H(), v0)]), H()),
                'hipat_rec (%s, %s, 0, mkpckind (0), %s, %s)' % (L(), H(), sc.lstx('labhipatlst', ['K_labhipat (mklab (0), hipat_var (%s, %s, %s))' % (L(), H(), v0), 'K_labhipat (mklab (1), hipat_var (%s, %s, %s))' % (L(), H(), v1)]), H()),
                'hipat_int (%s, %s, 3)' % (L(), H())]
        bodies = ['hidexp_var (%s, %s, %s)' % (L(), H(), v0), 'hidexp_var (%s, %s, %s)' % (L(), H(), v1), 'hidexp_empty (%s, %s)' % (L(), H()), 'hidexp_foldat (%s, %s)' % (L(), H()),
                  'hidexp_rec (%s, %s, 0, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), hidexp_var (%s, %s, %s))' % (L(), H(), v0)]), H()),
                  'hidexp_rec (%s, %s, 0, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), hidexp_empty (%s, %s))' % (L(), H())]), H()),
                  'hidexp_rec (%s, %s, 1, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), hidexp_var (%s, %s, %s))' % (L(), H(), v0)]), H()),
                  'hidexp_rec (%s, %s, 0, %s, %s)' % (L(), H(), sc.lstx('labhidexplst', ['K_labhidexp (mklab (0), hidexp_var (%s, %s, %s))' % (L(), H(), v0), 'K_labhidexp (mklab (1), hidexp_empty (%s, %s))' % (L(), H())]), H()),
                  'hidexp_int (%s, %s, 3)' % (L(), H())]
        for pt in pats:
            for bd in bodies:
                for pre in (0, 1, 2):
                    decs = ['hidecl_none (%s)' % L(), 'hidecl_extcode (%s, 0, 0, "x")' % L()][:pre]
                    last = 'hidecl_valdecs (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', ['hivaldec_make (%s, %s, %s)' % (L(), pt, 'hidexp_int (%s, %s, 5)' % (L(), H()))]))
                    x = sc.val('hidexp_let_simplify (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', decs + [last]), bd), 'hidexp')
                    sc.dd('hidexp', x)
        for bd in bodies[:3]:
            x = sc.val('hidexp_let_simplify (%s, %s, %s, %s)' % (L(), H(), 'LN_hideclist ()', bd), 'hidexp'); sc.dd('hidexp', x)
            two = 'hidecl_valdecs (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', ['hivaldec_make (%s, %s, %s)' % (L(), pats[0], bodies[2]), 'hivaldec_make (%s, %s, %s)' % (L(), pats[1], bodies[2])]))
            x = sc.val('hidexp_let_simplify (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', [two]), bd), 'hidexp'); sc.dd('hidexp', x)
            for kind in ('hidecl_valdecs_rec', 'hidecl_valdecs'):
                last = '%s (%s, mkvalkind (0), %s)' % (kind, L(), sc.lstx('hivaldeclst', []))
                x = sc.val('hidexp_let_simplify (%s, %s, %s, %s)' % (L(), H(), sc.lstx('hideclist', [last]), bd), 'hidexp'); sc.dd('hidexp', x)

    F.append(('exp3', fam_exp3, 1))
    def fam_exp4(sc, k):
        R, V, L, H, es, sh, mv, mv2 = exp_setup(sc)
        # the declarations
        ds = [sc.val(sc.Dc(2), 'hidecl') for _ in range(24)]
        for x in ['hidecl_none (%s)' % L(), 'hidecl_list (%s, %s)' % (L(), sc.lstx('hideclist', [])), 'hidecl_list (%s, %s)' % (L(), sc.lstx('hideclist', ['hidecl_none (%s)' % L()])),
                  'hidecl_fundecs (%s, mkfunkind (2), %s, %s)' % (L(), sc.lstx('s2qualst', []), sc.lstx('hifundeclst', [])),
                  'hidecl_valdecs (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', [])), 'hidecl_valdecs_rec (%s, mkvalkind (0), %s)' % (L(), sc.lstx('hivaldeclst', [])),
                  'hidecl_vardecs (%s, %s)' % (L(), sc.lstx('hivardeclst', [])), 'hidecl_include (%s, 0, %s)' % (L(), sc.lstx('hideclist', [])),
                  'hidecl_extcode (%s, 0, 0, "c")' % L(), 'hidecl_local (%s, %s, %s)' % (L(), sc.lstx('hideclist', []), sc.lstx('hideclist', []))]:
            ds.append(sc.val(x, 'hidecl'))
        for dc in ds:
            sc.call('hidecl_is_empty', [dc], 'bool'); sc.dd('hidecl', dc)
            sc.call('fprint_hidecl', [dc], 'fprint'); sc.call('print_hidecl', [dc], 'print'); sc.call('prerr_hidecl', [dc], 'prerr')
        sc.call('fprint_hideclist', [sc.lstx('hideclist', ds[:5])], 'fprint')
        # hidexp_app2: a castfn constant (the first argument, or an empty value) and others
        cf = sc.val('d2cst_make (mksym (4), mkloc (1), mkfil (0), mkdcstkind (5), LN_s2qualst (), %s, s2exp_int (0), mkdcstextdef (0))' % sc.lst('intlst', ['1']), 'd2cst')
        nf = sc.val('d2cst_make (mksym (5), mkloc (1), mkfil (0), mkdcstkind (0), LN_s2qualst (), %s, s2exp_int (0), mkdcstextdef (0))' % sc.lst('intlst', ['1']), 'd2cst')
        for c in (cf, nf):
            for args in (sc.lstx('hidexplst', []), sc.lstx('hidexplst', [R.choice(es)]), sc.lstx('hidexplst', [R.choice(es), R.choice(es)])):
                x = sc.val('hidexp_app2 (%s, %s, %s, hidexp_cst (%s, %s, %s), %s)' % (L(), H(), H(), L(), H(), c, args), 'hidexp'); sc.dd('hidexp', x)
        x = sc.val('hidexp_app2 (%s, %s, %s, %s, %s)' % (L(), H(), H(), R.choice(es), sc.lstx('hidexplst', [R.choice(es)])), 'hidexp'); sc.dd('hidexp', x)
        # the lists of types
        for l in (sc.lps(1, 2), sc.lps(1, 0)): sc.call('labhipatlst_get_type', [l], 'labhisexplst')
        sc.call('labhidexplst_get_type', [sc.le(1, 3)], 'labhisexplst'); sc.call('labhidexplst_get_type', [sc.le(1, 0)], 'labhisexplst')
        sc.call('hidexplst_get_type', ['LN_hidexplst ()'], 'hisexplst')
    F.append(('exp4', fam_exp4, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_dec(sc, k):
        """the mutable parts: the cells of hifundec / hiimpdec, hifundeclst_set_hideclopt, the maps of the instances of templates, the file environments"""
        R = sc.R
        sc.pools()
        L = sc.loc; H = lambda: sc.hse(1)
        V = sc.pool['d2var']; Cs = sc.pool['d2cst']
        fds = [sc.val('hifundec_make (%s, %s, %s, %s)' % (L(), V[i % 3], sc.gv('s2varlst', 1), sc.E(2)), 'hifundec') for i in range(4)]
        for f in fds:
            sc.dd('hifundec', f); sc.call('fprint_hifundec', [f], 'fprint')
            sc.dd('hideclopt', 'hifundec_get_hideclopt (%s)' % f)
            sc.dd('hideclopt', 't_pget_hideclopt (hifundec_getref_hideclopt (%s))' % f)
            sc.dd('hifunlabopt', 't_pget_hifunlabopt (hifundec_getref_funlabopt (%s))' % f)
            sc.do('t_pset_hifunlabopt (hifundec_getref_funlabopt (%s), OS_hifunlabopt (mkfunlab (%d)))' % (f, R.randrange(5)))
            sc.dd('hifunlabopt', 't_pget_hifunlabopt (hifundec_getref_funlabopt (%s))' % f)
            sc.do('t_pset_hideclopt (hifundec_getref_hideclopt (%s), OS_hideclopt (%s))' % (f, sc.Dc(1)))
            sc.dd('hideclopt', 'hifundec_get_hideclopt (%s)' % f)
            sc.dd('hifundec', f)
        d0 = sc.val('hidecl_fundecs (%s, mkfunkind (2), %s, %s)' % (L(), sc.gv('s2qualst', 1), sc.lstx('hifundeclst', fds)), 'hidecl')
        sc.do('hifundeclst_set_hideclopt (%s, OS_hideclopt (%s))' % (sc.lstx('hifundeclst', fds[:3]), d0))
        for f in fds:
            sc.call('hifundec_get_hideclopt', [f], 'hideclopt')
            sc.dd('hideclopt', 't_pget_hideclopt (hifundec_getref_hideclopt (%s))' % f)
        sc.do('hifundeclst_set_hideclopt (%s, ON_hideclopt ())' % sc.lstx('hifundeclst', fds[:2]))
        for f in fds: sc.call('hifundec_get_hideclopt', [f], 'hideclopt')
        sc.do('hifundeclst_set_hideclopt (%s, ON_hideclopt ())' % sc.lstx('hifundeclst', []))
        ims = [sc.val('hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (L(), R.randrange(2), Cs[i % 3], sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1) if i % 2 == 0 else 'LN_s2explstlst ()', sc.E(2)), 'hiimpdec') for i in range(5)]
        for m in ims:
            sc.dd('hiimpdec', m); sc.call('fprint_hiimpdec', [m], 'fprint')
            sc.dd('hifunlabopt', 't_pget_hifunlabopt (hiimpdec_getref_funlabopt (%s))' % m)
            sc.dd('hiinstrlstopt', 't_pget_hiinstrlstopt (hiimpdec_getref_instrlstopt (%s))' % m)
            sc.do('t_pset_hifunlabopt (hiimpdec_getref_funlabopt (%s), OS_hifunlabopt (mkfunlab (%d)))' % (m, R.randrange(5)))
            sc.do('t_pset_hiinstrlstopt (hiimpdec_getref_instrlstopt (%s), OS_hiinstrlstopt (mkinstrlst (%d)))' % (m, R.randrange(5)))
            sc.dd('hiimpdec', m)
        # the maps of the instances of templates
        sc.do('{ var m = t_tcmap_nil () %s %s }' % (' '.join('val () = t_tcmap_ins (m, %s)' % m for m in ims + ims[:2]),
              ' '.join('val () = (dd_hiimpdeclst (t_tcmap_find (m, %s)); dd_nl ())' % c for c in Cs)))
        sc.do('{ var m = t_tvmap_nil () %s %s %s }' % (' '.join('val () = t_tvmap_ins (m, %s)' % f for f in fds[:2]),
              'val () = t_tvmap_inss (m, %s)' % sc.lstx('hifundeclst', fds[1:]),
              ' '.join('val () = dd_optvt_hifundec (t_tvmap_find (m, %s)) val () = dd_nl ()' % v for v in V)))
        sc.do('{ var m = t_tvmap_nil () val () = t_tvmap_inss (m, %s) val () = dd_optvt_hifundec (t_tvmap_find (m, %s)) val () = dd_nl () }' % (sc.lstx('hifundeclst', []), V[0]))
        # the file environments: the maps are stored in the cells of the filenv, and read back
        for i in range(1, 4):
            fe = sc.leaf('filenv') if i == 0 else 'mkfilenv (%d)' % i
            sc.do('(dd_tcmapopt (filenv_get_tmpcstimpmapopt (%s)); dd_nl ())' % fe)
            sc.do('(dd_tvmapopt (filenv_get_tmpvardecmapopt (%s)); dd_nl ())' % fe)
            sc.do('{ var m = t_tcmap_nil () %s val () = t_pset_tcmapopt (t_fenv_ref_tc (%s), t_tcmapopt_some (m)) }' % (' '.join('val () = t_tcmap_ins (m, %s)' % m for m in ims[:i + 1]), fe))
            sc.do('{ var m = t_tvmap_nil () %s val () = t_pset_tvmapopt (t_fenv_ref_tv (%s), t_tvmapopt_some (m)) }' % (' '.join('val () = t_tvmap_ins (m, %s)' % f for f in fds[:i + 1]), fe))
            sc.do('(dd_tcmapopt (filenv_get_tmpcstimpmapopt (%s)); dd_nl ())' % fe)
            sc.do('(dd_tvmapopt (filenv_get_tmpvardecmapopt (%s)); dd_nl ())' % fe)
            sc.do('{ val o = filenv_get_tmpcstimpmapopt (%s) val () = (case+ t_tcmapopt_get (o) of ~Some_vt (m) => (%s) | ~None_vt () => dd_ps "none") val () = dd_nl () }' % (
                fe, '; '.join('dd_hiimpdeclst (t_tcmap_find (m, %s)); dd_ps "|"' % c for c in Cs)))
            sc.do('{ val o = filenv_get_tmpvardecmapopt (%s) val () = (case+ t_tvmapopt_get (o) of ~Some_vt (m) => (%s) | ~None_vt () => dd_ps "none") val () = dd_nl () }' % (
                fe, '; '.join('dd_optvt_hifundec (t_tvmap_find (m, %s)); dd_ps "|"' % v for v in V)))
    F.append(('dec', fam_dec, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_d2(sc, k):
        """the hisexp of the constants and the variables (d2cst_get2_hisexp, ..), the function types"""
        R = sc.R
        sc.pools()
        Cs = sc.pool['d2cst']; V = sc.pool['d2var']
        for c in Cs:
            sc.dd('hisexpopt', 'd2cst_get2_hisexp (%s)' % c)
            sc.call('d2cst_get2_funclo', [c], 'optvt_funclo')
        for v in V:
            sc.dd('hisexpopt', 'd2var_get2_hisexp (%s)' % v)
            sc.call('d2var_get2_funclo', [v], 'optvt_funclo')
        fts = []
        for fc in ('FUNCLOfun ()', 'FUNCLOclo (1)', 'FUNCLOclo (0)', 'FUNCLOclo (~1)'):
            fts.append('hisexp_fun (%s, %s, %s)' % (fc, sc.hses(1), sc.hse(1)))
        fts += ['hisexp_tybox', 'hisexp_cst (%s)' % sc.handle('s2cst'), 'hisexp_tyrec (%s, %s)' % (sc.tyreckind(), sc.lhs(1))]
        for i, ft in enumerate(fts):
            c = Cs[i % 3]; v = V[i % 3]
            sc.do('d2cst_set2_hisexp (%s, OS_hisexpopt (%s))' % (c, ft))
            sc.do('d2var_set2_hisexp (%s, OS_hisexpopt (%s))' % (v, ft))
            sc.dd('hisexpopt', 'd2cst_get2_hisexp (%s)' % c); sc.dd('hisexpopt', 'd2var_get2_hisexp (%s)' % v)
            sc.call('d2cst_get2_funclo', [c], 'optvt_funclo'); sc.call('d2var_get2_funclo', [v], 'optvt_funclo')
            sc.call('d2cst_is_fun', [c], 'bool')
            if i < 4:
                sc.dd('hisexplst', 'd2cst_get2_type_arg (%s)' % c); sc.dd('hisexp', 'd2cst_get2_type_res (%s)' % c)
            sc.do('chk_d2cst (%s)' % c); sc.do('chk_d2var (%s)' % v)
        sc.do('d2cst_set2_hisexp (%s, ON_hisexpopt ())' % Cs[0]); sc.dd('hisexpopt', 'd2cst_get2_hisexp (%s)' % Cs[0])
        sc.do('d2var_set2_hisexp (%s, ON_hisexpopt ())' % V[0]); sc.dd('hisexpopt', 'd2var_get2_hisexp (%s)' % V[0])
        sc.call('d2cst_get2_funclo', [Cs[0]], 'optvt_funclo'); sc.call('d2var_get2_funclo', [V[0]], 'optvt_funclo')
    F.append(('d2', fam_d2, 1))
    hd_ty.families_ty(G, C, ScH, F)
    return F

G_HD = []

def main(G, C, hdorder, d, M, T):
    global G_HD
    G_HD = [n for n in hdorder if n in ('hipat_node', 'hidecl_node', 'hidexp_node', 'hilab_node', 'labhipat', 'hipat', 'labhidexp', 'hidecl', 'hidexp', 'hilab', 'higmat', 'hiclau', 'hifundec', 'hivaldec', 'hivardec', 'hiimpdec')]
    ScH = build(G, C)
    F = families(G, C, ScH, M)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = ScH(G, R, 'sc_%s_%d' % (name, i))
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
    xs = hd_ty.exit_cases(ScH, G, random.Random(SEED + 1000))
    C.put(os.path.join(d, 'hd_exit.hats'), ''.join(xs) + 'fun hd_exit (k: int): void = (\n' + ''.join('  if k = %d then hdx_%d () else\n' % (i + 1, i + 1) for i in range(len(xs))) + '  ()\n)\n')
    print('hd_cases: %d exit cases, %d scenarios, %d chunks, %d lines' % (len(xs), len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

def write_chunks(d, C, chunks):
    for f in os.listdir(d):   # remove the files of an older generation (more chunks)
        m = re.match(r'^(?:hdcase_|hdcase1_|hd_cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'hd_cases_%02d.hats' % k
        C.put(os.path.join(d, cases), body)
        C.put(os.path.join(d, 'hdcase_%02d.dats' % k),
            '(* generated by hd_gen.py: the chunk %d of the cases of the erased-tree / typerase test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "hdcase_pre.hats"\n'
            'extern fun tc%d_all (): void = "ext#hdtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        C.put(os.path.join(d, 'hdcase1_%02d.dats' % k),
            '(* generated by hd_gen.py: the chunk %d of the cases of the erased-tree / typerase test (ATS1) *)\n#include "hdcase_pre1.hats"\n'
            'extern fun tc%d_all (): void = "hdtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun tc%d_all (): void = "ext#hdtc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "hdtc_%d"\n' % (k, k))
    call = 'fun tc_all (): void = {\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    C.put(os.path.join(d, 'hd_chunks.hats'), ''.join(ch2) + call)
    C.put(os.path.join(d, 'hd_chunks1.hats'), ''.join(ch1) + call)
