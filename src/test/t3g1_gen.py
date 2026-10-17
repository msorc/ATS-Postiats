#!/usr/bin/env python3
# usage: python3 t3g1_gen.py   (run in src/test; it writes t3g1cases.hats and the compat layers)
#
# Test of group 1 of the trans3 port (pats_trans3_syncst, _util, _dynexp_up; PORTING.md, "Level 3 translation, group 1") against the ATS1 build
# of src/. Same method as t3_gen.py: ONE generated program of scenarios in the common subset of ATS1 and ATS2, compiled by the ATS2 driver
# (t3g1dump.dats, linked with the ATS2 ports) and by the ATS1 driver (t3g1dump1.dats, linked with the ATS1 objects of src/); stdout and stderr
# must be identical. The modules of the OTHER groups are real in ATS1 and test doubles in ATS2 (t3g1stub.hats): the scenarios only call them
# on inputs for which the doubles are exact (empty lists, the "rest" case of [d2exp_trdn], see t3g1stub.hats).
# T3G1SEED and T3G1SCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(sys.argv[0]))
sys.path.insert(0, d)
import d2_gen, d2_cases, t3_gen, t3_cases

G = d2_gen; C = d2_cases
SEED = int(os.environ.get('T3G1SEED', '1'))
SCALE = float(os.environ.get('T3G1SCALE', '3'))

Sc3 = t3_cases.build(G, C)
F0 = t3_cases.families(G, C, Sc3, t3_gen.D3ORDER, d)
SETUP = [f for (n, f, k) in F0 if n == 'setup'][0]

# ---------------------------------------------------------------------------------------------------------------------
# small generators of static expressions (the "identity domain": the solver of the types is real in both builds)
class Gen:
    def __init__(self, sc):
        self.sc = sc; self.R = sc.R
    def loc(self): return 'mkloc (%d)' % self.R.randint(0, 40)
    def k(self): return self.R.randint(0, 9)
    # a type that has no free existential variable
    def basic(self):
        R = self.R
        return R.choice([
            's2exp_int_t0ype ()', 's2exp_int_int_t0ype (%d)' % R.choice([0, 1, 2, 3, 7]), 's2exp_bool_t0ype ()',
            's2exp_bool_bool_t0ype (%s)' % R.choice(['true', 'false']), 's2exp_char_t0ype ()', 's2exp_string_type ()', 's2exp_void_t0ype ()',
            's2exp_double_t0ype ()', 's2exp_uint_t0ype ()', 's2exp_lint_t0ype ()', 'mk_strint (%d)' % R.choice([1, 3]),
            's2exp_char_int_t0ype (%d)' % R.choice([65, 97]),
        ])
    def var(self):
        return 's2exp_Var_make_srt (%s, s2rt_t0ype)' % self.loc()
    def ty(self, d=1):
        R = self.R
        r = R.random()
        if r < 0.75 or d <= 0: return self.basic()
        if r < 0.85: return self.var()
        if r < 0.95: return self.funty(d - 1)
        return 'K_s2exp (s2rt_t0ype, K_S2Etyrec (K_TYRECKINDflt0 (), 0, %s))' % self.sc.lst('labs2explst', [
            'K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, self.ty(d - 1)) for i in range(R.choice([1, 2]))])
    def funty(self, d=1, fc=None, npf=None, args=None, res=None):
        R = self.R
        fc = fc if fc is not None else 0
        args = args if args is not None else [self.basic() for _ in range(R.choice([0, 1, 2, 3]))]
        npf = npf if npf is not None else R.choice([-1, -1, 0, 1])
        res = res if res is not None else self.basic()
        return 'K_s2exp (s2rt_type, K_S2Efun (mkfunclo (%d), %d, K_S2EFFset (mkeffset (%d)), %d, %s, %s))' % (
            fc, R.choice([0, 0, 1]), R.choice([0, 1, 2, 3, 4]), npf, self.sc.lst('s2explst', args), res)
    def uni(self, body, nv=1):
        sc = self.sc
        vs = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(nv)]
        return vs, 'K_s2exp (s2rt_type, K_S2Euni (%s, %s, %s))' % (sc.lst('s2varlst', vs), sc.lst('s2explst', []), body)
    def svar_exp(self, v): return 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % v

# ---------------------------------------------------------------------------------------------------------------------
INTREPS = ['0', '1', '7', '42', '99', '1000', '123456789012345678901234567890', '00', '07', '017', '0777', '0x0', '0x1F', '0xa', '0XAb', '0xFFFFFFFFFFFFFFFFFFFF', '0x10', '0X7f']
SFX = ['', 'u', 'U', 'l', 'L', 'ul', 'UL', 'Ul', 'uL', 'lu', 'LU', 'lU', 'll', 'LL', 'lL', 'ull', 'ULL', 'Ull', 'llu', 'LLU', 'llU',
       'uu', 'lul', 'lll', 'ulll', 'llll', 'uull', 'lLu', 'UlL']
FLTREPS = ['0.0', '1.5', '3.14159', '1e10', '1.0e-5', '2.5E+3', '.5', '5.', '0x1p3', '0x1.8p1', '1', '12345678901234567890.0']
FSFX = ['', 'f', 'F', 'l', 'L', 'd', 'D', 'ff', 'fl', 'LL', 'lf', 'fF']

def fam_ints(sc, k):
    R = sc.R
    sc.say('-- intrep_syn_type, intrep_syn_type_ind, d2exp_trup_intrep (reps and suffixes)')
    reps = []
    for _ in range(14):
        reps.append(R.choice(INTREPS) + R.choice(SFX))
    for rep in reps:
        loc = 'mkloc (%d)' % R.randint(0, 30)
        sc.dd('s2exp', 'intrep_syn_type (%s, "%s")' % (loc, rep))
        sc.dd('s2exp', 'intrep_syn_type_ind (%s, "%s")' % (loc, rep))
        e = sc.val('K_d2exp (%s, K_D2Eintrep ("%s"))' % (loc, rep), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_intrep (%s, "%s")' % (e, rep))
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
    sc.say('-- i0nt tokens')
    for rep in [R.choice(INTREPS) + R.choice(SFX) for _ in range(10)]:
        tok = sc.val('mktok_int2 (%d, "%s")' % (R.randint(0, 9), rep), 'i0nt')
        sc.dd('s2exp', 'i0nt_syn_type (%s)' % tok)
        sc.dd('s2exp', 'i0nt_syn_type_ind (%s)' % tok)
        e = sc.val('K_d2exp (mkloc (%d), K_D2Ei0nt (%s))' % (R.randint(0, 30), tok), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_i0nt (%s, %s)' % (e, tok))
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
    sc.do('t3chk ()')

def fam_floats(sc, k):
    R = sc.R
    sc.say('-- float_syn_type, f0loat_syn_type')
    for rep in [R.choice(FLTREPS) + R.choice(FSFX) for _ in range(14)]:
        loc = 'mkloc (%d)' % R.randint(0, 30)
        sc.dd('s2exp', 'float_syn_type (%s, "%s")' % (loc, rep))
        e = sc.val('K_d2exp (%s, K_D2Efloat ("%s"))' % (loc, rep), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_float (%s, "%s")' % (e, rep))
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        tok = sc.val('mktok_float2 (%d, "%s")' % (R.randint(0, 9), rep), 'f0loat')
        sc.dd('s2exp', 'f0loat_syn_type (%s)' % tok)
        e = sc.val('K_d2exp (%s, K_D2Ef0loat (%s))' % (loc, tok), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_f0loat (%s, %s)' % (e, tok))
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        # literals
        l = sc.val('K_d2exp (%s, K_D2Eliteral (%s))' % (loc, e), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_literal (%s, %s)' % (l, e))
        ef = sc.val('K_d2exp (%s, K_D2Efloat ("%s"))' % (loc, rep), 'd2exp')
        lf = sc.val('K_d2exp (%s, K_D2Eliteral (%s))' % (loc, ef), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_literal (%s, %s)' % (lf, ef))
    sc.do('t3chk ()')

def fam_atoms(sc, k):
    R = sc.R
    sc.say('-- bool, char, string, int, cstsp, tyrep, literal, empty, top2, extval, errexp')
    for i in range(10):
        loc = 'mkloc (%d)' % R.randint(0, 30)
        n = R.choice([0, 1, 2, -1, 100, 65536])
        for nm, node in [('int', 'K_D2Eint (%d)' % n), ('bool', 'K_D2Ebool (%s)' % R.choice(['true', 'false'])),
                         ('char', 'K_D2Echar (mkchr (%d))' % R.randint(0, 3)), ('string', 'K_D2Estring ("%s")' % R.choice(['', 'a', 'hello', 'x y']))]:
            e = sc.val('K_d2exp (%s, %s)' % (loc, node), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup_%s (%s, %s)' % (nm, e, {'int': str(n), 'bool': node[len('K_D2Ebool ('):-1], 'char': 'mkchr (%d)' % 0, 'string': '"zz"'}[nm]))
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        c0 = sc.val('mkc0har (%d)' % R.randint(0, 9), 'c0har')
        s0 = sc.val('mks0tring (%d)' % R.randint(0, 9), 's0tring')
        for node in ['K_D2Ec0har (%s)' % c0, 'K_D2Es0tring (%s)' % s0, 'K_D2Ecstsp (mkcstsp (%d))' % R.randint(0, 2), 'K_D2Eempty ()',
                     'K_D2Etop2 (%s)' % Gen(sc).ty(1), 'K_D2Eextval (%s, "nm%d")' % (Gen(sc).ty(1), i), 'K_D2Eerrexp ()',
                     'K_D2Etyrep (%s)' % Gen(sc).ty(1)]:
            e = sc.val('K_d2exp (%s, %s)' % (loc, node), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        e = sc.val('K_d2exp (%s, K_D2Ecstsp (mkcstsp (%d)))' % (loc, i), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_cstsp (%s, mkcstsp (%d))' % (e, i))
        sc.dd('s2exp', 'cstsp_syn_type (%s, mkcstsp (%d))' % (e, i))
        e = sc.val('K_d2exp (%s, K_D2Etyrep (%s))' % (loc, Gen(sc).ty(1)), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup_tyrep (%s, %s)' % (e, Gen(sc).ty(1)))
        # literals of the other kinds
        for node in ['K_D2Estring ("lit")', 'K_D2Es0tring (%s)' % s0, 'K_D2Eint (3)', 'K_D2Evar (%s)' % sc.new('d2var'), 'K_D2Eerrexp ()']:
            lit = sc.val('K_d2exp (%s, %s)' % (loc, node), 'd2exp')
            e = sc.val('K_d2exp (%s, K_D2Eliteral (%s))' % (loc, lit), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup_literal (%s, %s)' % (e, lit))
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
    sc.do('t3chk ()')

# ---------------------------------------------------------------------------------------------------------------------
# the static functions of util: [d2exp_syn_type] and friends on random expressions (no function with arguments: the double of
# [p2atlst_syn_type] only knows the empty list)
class ExpGen:
    def __init__(self, sc, pool_v, pool_c):
        self.sc = sc; self.R = sc.R; self.g = Gen(sc); self.pv = pool_v; self.pc = pool_c
    def loc(self): return 'mkloc (%d)' % self.R.randint(0, 40)
    def E(self, node): return 'K_d2exp (%s, %s)' % (self.loc(), node)
    def leaf(self):
        R = self.R; sc = self.sc
        c = R.randint(0, 17)
        if c == 0: return self.E('K_D2Eint (%d)' % R.choice([0, 1, 5]))
        if c == 1: return self.E('K_D2Ebool (%s)' % R.choice(['true', 'false']))
        if c == 2: return self.E('K_D2Echar (mkchr (%d))' % R.randint(0, 3))
        if c == 3: return self.E('K_D2Efloat ("%s")' % R.choice(FLTREPS))
        if c == 4: return self.E('K_D2Estring ("s%d")' % R.randint(0, 3))
        if c == 5: return self.E('K_D2Ei0nt (mktok_int2 (%d, "%s"))' % (R.randint(0, 9), R.choice(INTREPS) + R.choice(['', 'u', 'L'])))
        if c == 6: return self.E('K_D2Ec0har (mkc0har (%d))' % R.randint(0, 9))
        if c == 7: return self.E('K_D2Ef0loat (mktok_float2 (%d, "%s"))' % (R.randint(0, 9), R.choice(FLTREPS) + R.choice(['', 'f', 'L'])))
        if c == 8: return self.E('K_D2Es0tring (mks0tring (%d))' % R.randint(0, 9))
        if c == 9: return self.E('K_D2Ecstsp (mkcstsp (%d))' % R.randint(0, 2))
        if c == 10: return self.E('K_D2Eempty ()')
        if c == 11: return self.E('K_D2Eextval (%s, "ev")' % self.g.ty(1))
        if c == 12: return self.E('K_D2Eerrexp ()')
        if c == 13: return self.E('K_D2Evar (%s)' % R.choice(self.pv))
        if c == 14: return self.E('K_D2Ecst (%s)' % R.choice(self.pc))
        if c == 15: return self.E('K_D2Etyrep (%s)' % self.g.ty(1))
        if c == 16: return self.E('K_D2Etop2 (%s)' % self.g.ty(1))
        return self.E('K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), self.E('K_D2Eint (1)'))) if False else self.E('K_D2Eint (2)')
    def lst(self, n, d):
        return self.sc.lst('d2explst', [self.exp(d) for _ in range(n)])
    def exp(self, d):
        R = self.R; sc = self.sc; g = self.g
        if d <= 0 or R.random() < 0.25: return self.leaf()
        c = R.randint(0, 14)
        if c == 0: return self.E('K_D2Eassgn (%s, %s)' % (self.exp(d - 1), self.exp(d - 1)))
        if c == 1: return self.E('K_D2Elst (%d, %s, %s)' % (R.choice([-1, 0, 1]), R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()]), self.lst(R.choice([0, 1, 2]), d - 1)))
        if c == 2: return self.E('K_D2Etup (%d, %d, %s)' % (R.choice([0, 1, 2]), R.choice([-1, 0, 1]), self.lst(R.choice([0, 1, 2]), d - 1)))
        if c == 3:
            ls = sc.lst('labd2explst', ['K_labd2exp (mkl0ab (%d), %s)' % (i, self.exp(d - 1)) for i in range(R.choice([0, 1, 2]))])
            return self.E('K_D2Erec (%d, %d, %s)' % (R.choice([0, 1, 2]), R.choice([-1, 0, 1]), ls))
        if c == 4: return self.E('K_D2Eseq (%s)' % self.lst(R.choice([0, 1, 2, 3]), d - 1))
        if c == 5: return self.E('K_D2Earrpsz (%s, %s)' % (R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()]), self.lst(R.choice([0, 1, 2]), d - 1)))
        if c == 6: return self.E('K_D2Elam_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), self.exp(d - 1)))
        if c == 7: return self.E('K_D2Elaminit_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), self.exp(d - 1)))
        if c == 8:
            vs = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(R.choice([0, 1, 2]))]
            return self.E('K_D2Elam_sta (%s, %s, %s)' % (sc.lst('s2varlst', vs), sc.lst('s2explst', []), self.exp(d - 1)))
        if c == 9: return self.E('K_D2Elam_met (K_d2varlstref (%s), %s, %s)' % (sc.lst('d2varlst', R.sample(self.pv, 1)), sc.lst('s2explst', [g.basic()]), self.exp(d - 1)))
        if c == 10: return self.E('K_D2Efix (%d, %s, %s)' % (R.choice([0, 1]), R.choice(self.pv), self.exp(d - 1)))
        if c == 11: return self.E('K_D2Eann_type (%s, %s)' % (self.exp(d - 1), g.ty(1)))
        if c == 12: return self.E('K_D2Eann_seff (%s, K_S2EFFset (mkeffset (%d)))' % (self.exp(d - 1), R.randint(0, 4)))
        if c == 13: return self.E('K_D2Eann_funclo (%s, mkfunclo (%d))' % (self.exp(d - 1), R.randint(0, 3)))
        return self.E('K_D2Edelay (%s)' % self.exp(d - 1))

    # ---- the expressions that [d2exp_trup] handles with the real code of group 1 only: the position of a child decides what is allowed
    #      ("dn": a position of [d2exp_trdn], the test double only knows the "rest" case; "up": a position of [d2exp_trup])
    def ls(self, n, d, mode):
        f = self.dn if mode == 'dn' else self.up
        return self.sc.lst('d2explst', [f(d) for _ in range(n)])
    def dn(self, d):
        R = self.R; sc = self.sc; g = self.g
        if d <= 0 or R.random() < 0.35: return self.leaf()
        c = R.randint(0, 6)
        if c == 0: return self.E('K_D2Elst (%d, %s, %s)' % (R.choice([-1, 0, 1]), R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()]), self.ls(R.choice([0, 1, 2]), d - 1, 'dn')))
        if c == 1: return self.E('K_D2Earrpsz (%s, %s)' % (R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()]), self.ls(R.choice([0, 1, 2]), d - 1, 'dn')))
        if c == 2: return self.E('K_D2Eann_type (%s, %s)' % (self.dn(d - 1), g.ty(1)))
        if c == 3: return self.E('K_D2Eann_seff (%s, K_S2EFFset (mkeffset (%d)))' % (self.up(d - 1), R.randint(0, 4)))
        if c == 4:
            vs = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(R.choice([1, 2]))]
            return self.E('K_D2Elam_sta (%s, %s, %s)' % (sc.lst('s2varlst', vs), sc.lst('s2explst', []), self.up(d - 1)))
        if c == 5: return self.E('K_D2Elam_met (K_d2varlstref (%s), %s, %s)' % (sc.lst('d2varlst', R.sample(self.pv, 1)), sc.lst('s2explst', [g.basic()]), self.up(d - 1)))
        return self.E('K_D2Efix (%d, %s, %s)' % (R.choice([0, 1]), R.choice(self.pv), self.up(d - 1)))
    def up(self, d):
        R = self.R; sc = self.sc; g = self.g
        if d <= 0 or R.random() < 0.25: return self.leaf()
        c = R.randint(0, 16)
        if c <= 5: return self.dn(d)
        if c == 6: return self.E('K_D2Etup (%d, %d, %s)' % (R.choice([0, 1, 2]), R.choice([-1, 0, 1]), self.ls(R.choice([0, 1, 2]), d - 1, 'up')))
        if c == 7:
            l = sc.lst('labd2explst', ['K_labd2exp (mkl0ab (%d), %s)' % (i, self.up(d - 1)) for i in range(R.choice([0, 1, 2]))])
            return self.E('K_D2Erec (%d, %d, %s)' % (R.choice([0, 1, 2]), R.choice([-1, 0, 1]), l))
        if c == 8:
            n = R.choice([0, 1, 2, 3])
            xs = [self.dn(d - 1) for _ in range(max(0, n - 1))] + ([self.up(d - 1)] if n > 0 else [])
            return self.E('K_D2Eseq (%s)' % sc.lst('d2explst', xs))
        if c == 9: return self.E('K_D2Elam_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), self.up(d - 1)))
        if c == 10: return self.E('K_D2Elaminit_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), self.up(d - 1)))
        if c == 11: return self.E('K_D2Edelay (%s)' % self.up(d - 1))
        if c == 12: return self.E('K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), self.up(d - 1)))
        if c == 13: return self.E('K_D2Elet (LN_d2eclist (), %s)' % self.up(d - 1))
        if c == 14: return self.E('K_D2Ewhere (%s, LN_d2eclist ())' % self.up(d - 1))
        if c == 15: return self.E('K_D2Esing (%s)' % self.up(d - 1))
        return self.E('K_D2Elist (%d, %s)' % (R.choice([-1, 0, 1]), self.ls(R.choice([0, 1, 2]), d - 1, 'up')))

def mkpools(sc, nv=3, nc=3, typed=True):
    """d2vars with types and d2csts with types"""
    R = sc.R; g = Gen(sc)
    vs = []
    for i in range(nv):
        v = sc.new('d2var')
        if typed: sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, g.ty(1) if i % 3 != 2 else g.funty(0)))
        vs.append(v)
    cs = []
    for i in range(nc):
        ty = g.ty(1) if i % 2 == 0 else g.funty(0)
        c = sc.val('d2cst_make (mksym (%d), mkloc (%d), mkfil (0), mkdcstkind (%d), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (%d))' % (
            R.randint(0, 6), R.randint(0, 20), R.randint(0, 5), ty, R.randint(0, 4)), 'd2cst')
        cs.append(c)
    return vs, cs

def fam_syn(sc, k):
    R = sc.R
    vs, cs = mkpools(sc)
    eg = ExpGen(sc, vs, cs)
    sc.say('-- d2exp_syn_type, d2exp_funclo_of_d2exp, d2exp_s2eff_of_d2exp')
    for _ in range(14):
        e = sc.val(eg.exp(3), 'd2exp')
        sc.dd('s2exp', 'd2exp_syn_type (%s)' % e)
        sc.do('t_funclo_of (%s, mkfunclo (%d))' % (e, R.randint(0, 3)))
        sc.do('t_s2eff_of (%s)' % e)
    es = [sc.val(eg.exp(2), 'd2exp') for _ in range(3)]
    sc.dd('s2explst', 'd2explst_syn_type (%s)' % sc.lst('d2explst', es))
    sc.dd('s2explst', 'd2explst_syn_type (LN_d2explst ())')
    ls = sc.lst('labd2explst', ['K_labd2exp (mkl0ab (%d), %s)' % (i, es[i % 3]) for i in range(4)])
    sc.dd('labs2explst', 'labd2explst_syn_type (%s)' % ls)
    sc.do('t3chk ()')

# ---------------------------------------------------------------------------------------------------------------------
# util on d3exp
def fam_d3(sc, k):
    R = sc.R; g = Gen(sc)
    sc.say('-- d3exp_linheap_check')
    sc.pools()
    def loc(): return 'mkloc (%d)' % R.randint(0, 40)
    def fnty():
        fc = R.randint(0, 3)
        base = g.funty(0, fc=fc)
        r = R.random()
        if r < 0.55: return base
        if r < 0.7: return 'K_s2exp (s2rt_type, K_S2Euni (%s, %s, %s))' % (sc.lst('s2varlst', [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')]), sc.lst('s2explst', []), base)
        if r < 0.8: return 'K_s2exp (s2rt_type, K_S2Eexi (%s, %s, %s))' % (sc.lst('s2varlst', []), sc.lst('s2explst', []), base)
        if r < 0.9: return 'K_s2exp (s2rt_type, K_S2Emetfun (ON_stampopt (), %s, %s))' % (sc.lst('s2explst', [g.basic()]), base)
        return g.basic()
    def recty(isrec):
        kk = R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt1 (mkstamp (0))', 'K_TYRECKINDflt_ext ("ext")'])
        srt = R.choice(['s2rt_type', 's2rt_t0ype', 's2rt_prop', 's2rt_view', 's2rt_vt0ype', 's2rt_vtype'])
        ls = sc.lst('labs2explst', ['K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, g.basic()) for i in range(R.choice([0, 1, 2]))])
        t = 'K_s2exp (%s, K_S2Etyrec (%s, %d, %s))' % (srt, kk, R.choice([-1, 0, 1]), ls)
        if R.random() < 0.15: t = g.basic()
        return t
    for _ in range(16):
        c = R.randint(0, 5)
        if c == 0:
            e = sc.val('d3exp_lam_dyn (%s, %s, %d, %d, LN_p3atlst (), %s)' % (loc(), fnty(), R.choice([-1, 0, 1]), R.choice([-1, 0]), sc.gv('d3exp', 1)), 'd3exp')
        elif c == 1:
            e = sc.val('d3exp_tup (%s, %s, %d, %d, %s)' % (loc(), recty(False), R.choice([0, 1, 2]), R.choice([-1, 0]), sc.gv('d3explst', 1)), 'd3exp')
        elif c == 2:
            e = sc.val('d3exp_rec (%s, %s, %d, %d, %s)' % (loc(), recty(True), R.choice([0, 1, 2]), R.choice([-1, 0]), sc.gv('labd3explst', 1)), 'd3exp')
        elif c == 3:
            e = sc.val('d3exp_delay (%s, %s, %s)' % (loc(), g.basic(), sc.gv('d3exp', 1)), 'd3exp')
        elif c == 4:
            e = sc.val('d3exp_lst (%s, %s, %d, %s, %s)' % (loc(), g.basic(), R.choice([-1, 0, 1, 2, 3]), g.basic(), sc.gv('d3explst', 1)), 'd3exp')
        else:
            e = sc.val('d3exp_int (%s, %s, %d)' % (loc(), g.basic(), R.randint(0, 3)), 'd3exp')
        sc.dd('d3exp', 'd3exp_linheap_check (%s)' % e)
    sc.say('-- d3lablst_is_overld, fshowtype_d3exp')
    for _ in range(8):
        ls = []
        for i in range(R.choice([0, 1, 2, 3])):
            ov = 'ON_d2symopt ()' if R.random() < 0.6 else 'OS_d2symopt (%s)' % sc.gv('d2sym', 1)
            ls.append(sc.val('d3lab_lab (%s, mklab (%d), %s)' % (loc(), i, ov), 'd3lab'))
        sc.dd('bool', 'd3lablst_is_overld (%s)' % sc.lst('d3lablst', ls))
    for _ in range(6):
        e = sc.val('d3exp_int (%s, %s, %d)' % (loc(), R.choice([g.basic(), fnty()]), R.randint(0, 3)), 'd3exp')
        sc.do('fshowtype_d3exp_up (%s)' % e)
        sc.do('fshowtype_d3exp_dn (%s)' % e)
    sc.say('-- d23exp_free')
    sc.do('t_d23free (%s, %s)' % (sc.gv('d2exp', 1), sc.gv('d3exp', 1)))
    sc.do('t3chk ()')

def fam_trdn(sc, k):
    R = sc.R; g = Gen(sc)
    sc.say('-- d3exp_trdn, d3explst_trdn_arg, d3explst_get_ind')
    def loc(): return 'mkloc (%d)' % R.randint(0, 40)
    sc.do('t_trans3_env_push ()')
    for _ in range(24):
        ty1 = g.ty(1) if R.random() < 0.7 else g.var()
        ty2 = g.ty(1) if R.random() < 0.7 else g.var()
        if R.random() < 0.15: ty2 = 'K_s2exp (s2rt_t0ype, K_S2Erefarg (%d, %s))' % (R.choice([0, 1]), g.basic())
        e = sc.val('d3exp_int (%s, %s, %d)' % (loc(), ty1, R.randint(0, 3)), 'd3exp')
        sc.dd('d3exp', 'd3exp_trdn (%s, %s)' % (e, ty2))
        sc.dd('d3exp', e)
        if R.random() < 0.3: sc.do('t3chk ()')
    for _ in range(6):
        es = [sc.val('d3exp_int (%s, %s, %d)' % (loc(), g.ty(1), R.randint(0, 3)), 'd3exp') for _ in range(R.choice([0, 1, 2, 3]))]
        ts = [g.ty(1) for _ in range(R.choice([0, 1, 2, 3]))]
        sc.dd('d3explst', 'd3explst_trdn_arg (%s, %s)' % (sc.lst('d3explst', es), sc.lst('s2explst', ts)))
    for _ in range(6):
        es = [sc.val('d3exp_int (%s, %s, %d)' % (loc(), R.choice([g.ty(1), 'K_s2exp (s2rt_type, K_S2Eexi (%s, %s, %s))' % (
            sc.lst('s2varlst', [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')]), sc.lst('s2explst', [g.basic()]), g.basic())]), R.randint(0, 3)), 'd3exp')
              for _ in range(R.choice([0, 1, 2]))]
        sc.dd('s2explst', 'd3explst_get_ind (%s)' % sc.lst('d3explst', es))
    sc.do('(dd_listvt_s3itm (t_trans3_env_pop ()); dd_nl ())')
    sc.do('t3chk ()')

# ---------------------------------------------------------------------------------------------------------------------
# dynexp_up: [d2exp_trup] on expressions that do not need the other groups
def fam_up_atoms(sc, k):
    """trup of the atoms, the sequences, the aggregates, the binders with no argument, the effects, ..."""
    R = sc.R; g = Gen(sc)
    vs, cs = mkpools(sc, 4, 3, True)
    eg = ExpGen(sc, vs, cs)
    sc.say('-- d2exp_trup')
    sc.do('t_trans3_env_push ()')
    for i in range(30):
        e = sc.val(eg.up(R.choice([1, 2, 3])), 'd2exp')
        loc = eg.loc()
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc)
        if i % 5 == 4: sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

def fam_up_vars(sc, k):
    """variables (linear ones too), templates, constants with static arguments"""
    R = sc.R; g = Gen(sc)
    sc.say('-- d2exp_trup_var, d2exp_trup_cst, d2exp_trup_tmpcst, d2exp_trup_tmpvar')
    loc = lambda: 'mkloc (%d)' % R.randint(0, 40)
    sc.do('t_trans3_env_push ()')
    # variables: nonlinear, linear (in and out of a scope), without type, with template arguments
    vs = []
    for i in range(6):
        v = sc.new('d2var')
        vs.append(v)
        if i != 3: sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, g.ty(1)))
        if i in (1, 4): sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([0, 1])))
        if i == 5:
            # {a:t@ype} a
            a = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
            sc.do('d2var_set_decarg (%s, %s)' % (v, sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [a]), sc.lst('s2explst', []))])))
            sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, g.svar_exp(a)))
    for rep in range(2):
        for v in vs:
            e = sc.val('K_d2exp (%s, K_D2Evar (%s))' % (loc(), v), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
            sc.dd('d3exp', 'd2exp_trup_var (%s, %s)' % (loc(), v))
            sc.dd('s2expopt', 'd2var_get_type (%s)' % v)
            sc.dd('int', 'd2var_get_linval (%s)' % v)
        sc.do('t3chk ()')
        # inside a scope in which the linear variables are local
        sc.do('t_the_d2varenv_push_let ()')
        for v in vs[:3]: sc.do('the_d2varenv_add_dvar (%s)' % v)
        for v in vs + vs[1:2] + vs[4:5]:
            e = sc.val('K_d2exp (%s, K_D2Evar (%s))' % (loc(), v), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
            sc.dd('s2expopt', 'd2var_get_type (%s)' % v)
            sc.dd('int', 'd2var_get_linval (%s)' % v)
        sc.do('the_d2varenv_check (mkloc (3))')
        sc.do('t_the_d2varenv_pop ()')
        sc.do('t3chk ()')
        # var typed after being consumed
        for v in vs: sc.dd('s2exp', 'd2var_get_type_some (%s, %s)' % (loc(), v))
        sc.do('t3chk ()')
    # constants
    cs = []
    for i in range(5):
        a = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
        qs = 'LN_s2qualst ()' if i < 2 else sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [a]), sc.lst('s2explst', []))] + (
            ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')]), sc.lst('s2explst', []))] if i == 4 else []))
        ty = g.ty(1) if i < 2 else g.svar_exp(a)
        c = sc.val('d2cst_make (mksym (%d), mkloc (%d), mkfil (0), mkdcstkind (0), %s, LN_intlst (), %s, mkdcstextdef (0))' % (i, i, qs, ty), 'd2cst')
        cs.append(c)
    for c in cs:
        e = sc.val('K_d2exp (%s, K_D2Ecst (%s))' % (loc(), c), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.dd('d3exp', 'd2exp_trup_cst (%s, %s)' % (loc(), c))
        # explicit template arguments
        for t2m in ['LN_t2mpmarglst ()', sc.lst('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (loc(), sc.lst('s2explst', [g.basic()]))]),
                    sc.lst('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (loc(), sc.lst('s2explst', [g.basic()])), 'K_t2mpmarg (%s, %s)' % (loc(), sc.lst('s2explst', [g.basic()]))])]:
            sc.dd('d3exp', 'd2exp_trup_tmpcst (%s, %s, %s)' % (loc(), c, t2m))
            t = sc.val('K_d2exp (%s, K_D2Etmpid (%s, %s))' % (loc(), e, t2m), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup (%s)' % t)
    for v in vs:
        e = sc.val('K_d2exp (%s, K_D2Evar (%s))' % (loc(), v), 'd2exp')
        for t2m in ['LN_t2mpmarglst ()', sc.lst('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (loc(), sc.lst('s2explst', [g.basic()]))])]:
            sc.dd('d3exp', 'd2exp_trup_tmpvar (%s, %s, %s)' % (loc(), v, t2m))
            t = sc.val('K_d2exp (%s, K_D2Etmpid (%s, %s))' % (loc(), e, t2m), 'd2exp')
            sc.dd('d3exp', 'd2exp_trup (%s)' % t)
    # a template of something that is not a constant or a variable
    t = sc.val('K_d2exp (%s, K_D2Etmpid (%s, LN_t2mpmarglst ()))' % (loc(), 'K_d2exp (mkloc (1), K_D2Eint (1))'), 'd2exp')
    sc.dd('d3exp', 'd2exp_trup (%s)' % t)
    sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

def fam_up_apps(sc, k):
    """applications: dynamic (no argument needs the doubles beyond the "rest" case of [d2exp_trdn]), static, constructors"""
    R = sc.R; g = Gen(sc)
    loc = lambda: 'mkloc (%d)' % R.randint(0, 40)
    sc.say('-- d2exp_trup_applst, d23exp_trup_applst, d2exp_trup_con')
    sc.do('t_trans3_env_push ()')
    fns = []   # (cst, number of arguments, npf, kind)
    def mkc(i, ty):
        return sc.val('d2cst_make (mksym (%d), mkloc (%d), mkfil (0), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (0))' % (i, i, ty), 'd2cst')
    for i in range(4):
        n = R.choice([0, 1, 2, 3])
        args = [g.basic() for _ in range(n)]
        npf = R.choice([-1, -1, -1, 0, 1]) if i != 0 else -1
        res = g.basic() if R.random() < 0.8 else g.funty(0, fc=0, npf=-1, args=[g.basic()], res=g.basic())   # curried
        fns.append((mkc(i, g.funty(0, fc=0, npf=npf, args=args, res=res)), n, npf, 0))
    # a function that returns an existential type: () -> [a:t@ype] a
    a1 = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
    exi = 'K_s2exp (s2rt_t0ype, K_S2Eexi (%s, %s, %s))' % (sc.lst('s2varlst', [a1]), sc.lst('s2explst', []), g.svar_exp(a1))
    fns.append((mkc(7, g.funty(0, fc=0, npf=-1, args=[], res=exi)), 0, -1, 1))
    fns.append((mkc(8, g.funty(0, fc=0, npf=-1, args=[g.basic()], res=exi)), 1, -1, 1))
    # a metric function
    fns.append((mkc(9, 'K_s2exp (s2rt_type, K_S2Emetfun (ON_stampopt (), %s, %s))' % (sc.lst('s2explst', [g.basic()]), g.funty(0, fc=0, npf=-1, args=[g.basic()], res=g.basic()))), 1, -1, 0))
    # a polymorphic function: {a:t@ype} (a) -> a
    a = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
    pty = 'K_s2exp (s2rt_type, K_S2Euni (%s, %s, %s))' % (sc.lst('s2varlst', [a]), sc.lst('s2explst', []), g.funty(0, fc=0, npf=-1, args=[g.svar_exp(a)], res=g.svar_exp(a)))
    fns.append((mkc(5, pty), 1, -1, 2))
    vs = [sc.new('d2var') for _ in range(3)]
    for v in vs: sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, g.basic()))
    zero = [f for f in fns if f[1] == 0]
    # a template variable {a:t@ype} a (its translation instantiates the quantifier: a new existential variable)
    tv = sc.new('d2var')
    ta = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
    sc.do('d2var_set_decarg (%s, %s)' % (tv, sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [ta]), sc.lst('s2explst', []))])))
    sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (tv, g.svar_exp(ta)))
    def argexp(d=1):
        c = R.randint(0, 8)
        if c >= 7: return 'K_d2exp (%s, K_D2Evar (%s))' % (loc(), tv)
        if c == 0: return 'K_d2exp (%s, K_D2Eint (%d))' % (loc(), R.randint(0, 3))
        if c == 1: return 'K_d2exp (%s, K_D2Evar (%s))' % (loc(), R.choice(vs))
        if c == 2: return 'K_d2exp (%s, K_D2Ebool (%s))' % (loc(), R.choice(['true', 'false']))
        if c == 3: return 'K_d2exp (%s, K_D2Echar (mkchr (%d)))' % (loc(), R.randint(0, 3))
        if c == 4 or not zero or d <= 0: return 'K_d2exp (%s, K_D2Estring ("s"))' % loc()
        z = R.choice(zero)     # a nested application: the argument is an expression (not a value) of a possibly existential type
        return 'K_d2exp (%s, K_D2Eapplst (K_d2exp (%s, K_D2Ecst (%s)), %s))' % (loc(), loc(), z[0], sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, LN_d2explst ())' % loc()]))
    for i in range(46):
        c, n, npf, kind = R.choice(fns)
        groups = []
        if kind == 2 and R.random() < 0.7:
            groups.append('K_D2EXPARGsta (%s, %s)' % (loc(), sc.lst('s2exparglst', [
                'K_s2exparg (%s, %s)' % (loc(), R.choice(['K_S2EXPARGseq (%s)' % sc.lst('s2explst', [g.basic()]), 'K_S2EXPARGone ()', 'K_S2EXPARGall ()']))])))
        for gi in range(R.choice([1, 1, 1, 2])):
            if R.random() < 0.1 and gi == 0 and not groups:
                groups.append('K_D2EXPARGsta (%s, %s)' % (loc(), sc.lst('s2exparglst', [
                    'K_s2exparg (%s, K_S2EXPARGseq (%s))' % (loc(), sc.lst('s2explst', [g.basic()]))])))
            else:
                na = n if R.random() < 0.8 else R.choice([0, 1, 2, 3, 4])
                groups.append('K_D2EXPARGdyn (%d, %s, %s)' % (R.choice([npf, npf, npf, -1, 0, 1]), loc(), sc.lst('d2explst', [argexp() for _ in range(na)])))
        fe = sc.val('K_d2exp (%s, K_D2Ecst (%s))' % (loc(), c), 'd2exp')
        e = sc.val('K_d2exp (%s, K_D2Eapplst (%s, %s))' % (loc(), fe, sc.lst('d2exparglst', groups)), 'd2exp')
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
        if i % 6 == 5: sc.do('t3chk ()')
    # the application of the result of an application, which is a function under an existential quantifier: () -> [a:t@ype] (a) -> a
    for i in range(6):
        a2 = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
        exifn = 'K_s2exp (s2rt_type, K_S2Eexi (%s, %s, %s))' % (sc.lst('s2varlst', [a2]), sc.lst('s2explst', []), g.funty(0, fc=0, npf=-1, args=[g.svar_exp(a2)], res=g.svar_exp(a2)))
        gc = mkc(20 + i, g.funty(0, fc=0, npf=-1, args=[], res=exifn))
        inner = 'K_d2exp (%s, K_D2Eapplst (K_d2exp (%s, K_D2Ecst (%s)), %s))' % (loc(), loc(), gc, sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, LN_d2explst ())' % loc()]))
        e = sc.val('K_d2exp (%s, K_D2Eapplst (%s, %s))' % (loc(), inner, sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, %s)' % (loc(), sc.lst('d2explst', [argexp()] if i % 3 else []))])), 'd2exp')
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
    sc.do('t3chk ()')
    # an application of a variable of function type, of a non-function
    v = sc.new('d2var')
    sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, g.funty(0, fc=0, npf=-1, args=[g.basic()], res=g.basic())))
    for fe in ['K_D2Evar (%s)' % v, 'K_D2Evar (%s)' % vs[0], 'K_D2Eint (1)']:
        f = sc.val('K_d2exp (%s, %s)' % (loc(), fe), 'd2exp')
        gr = sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, %s)' % (loc(), sc.lst('d2explst', [argexp()]))])
        e = sc.val('K_d2exp (%s, K_D2Eapplst (%s, %s))' % (loc(), f, gr), 'd2exp')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.dd('d3exp', 'd2exp_trup_applst (%s, %s, %s)' % (e, f, gr))
    sc.do('t3chk ()')
    # constructors of data types
    for ci in range(4):
        dsrt = 's2rt_type'
        sc2 = sc.val('s2cst_make (mksym (%d), mkloc (%d), mkfil (0), %s, ON_s2expoptopt (), false, false, ON_s2expopt (), ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())' % (ci, ci, dsrt), 's2cst')
        av = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
        qs = sc.lst('s2qualst', [] if ci % 2 == 0 else ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [av]), sc.lst('s2explst', []))])
        nargs = R.choice([0, 1, 2])
        targs = [g.basic() for _ in range(nargs)]
        if ci % 2 == 1 and nargs > 0: targs[0] = g.svar_exp(av)
        dc = sc.val('d2con_make (mkloc (%d), mkfil (0), mksym (%d), %s, %d, %s, -1, %s, ON_s2explstopt ())' % (ci, ci, sc2, R.choice([0, 1]), qs, sc.lst('s2explst', targs)), 'd2con')
        for t in range(6):
            sas = sc.lst('s2exparglst', [] if R.random() < 0.6 else ['K_s2exparg (%s, K_S2EXPARGseq (%s))' % (loc(), sc.lst('s2explst', [g.basic()]))])
            na = nargs if R.random() < 0.75 else R.choice([0, 1, 2, 3])
            e = sc.val('K_d2exp (%s, K_D2Econ (%s, %s, %s, %d, %s, %s))' % (loc(), dc, loc(), sas, R.choice([-1, -1, -1, 0, 1]), loc(), sc.lst('d2explst', [argexp() for _ in range(na)])), 'd2exp')
            sc.do('t_trans3_env_push ()')
            sc.dd('d3exp', 'd2exp_trup (%s)' % e)
            sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
    sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

def fam_up_misc(sc, k):
    """let, effmask, vararg, vcopyenv, tempenver, solassert, solverify, mac, macsyn, delay, ldelay, lam_*, fix, raise, showtype, arrinit, array, sym"""
    R = sc.R; g = Gen(sc)
    loc = lambda: 'mkloc (%d)' % R.randint(0, 40)
    vs, cs = mkpools(sc, 4, 2, True)
    eg = ExpGen(sc, vs, cs)
    sc.say('-- d2exp_trup: the binders, the effects, the macros, ..')
    sc.do('t_trans3_env_push ()')
    def tr(node):
        e = sc.val('K_d2exp (%s, %s)' % (loc(), node), 'd2exp')
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
    for i in range(3):
        tr('K_D2Elet (LN_d2eclist (), %s)' % eg.up(2))
        tr('K_D2Ewhere (%s, LN_d2eclist ())' % eg.up(2))
        tr('K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), eg.up(2)))
        tr('K_D2Evararg (%s)' % eg.ls(R.choice([0, 1, 2]), 1, 'up'))
        tr('K_D2Evcopyenv (%d, %s)' % (R.choice([0, 1]), 'K_d2exp (%s, K_D2Evar (%s))' % (loc(), R.choice(vs))))
        tr('K_D2Evcopyenv (%d, %s)' % (R.choice([0, 1]), eg.up(1)))
        tr('K_D2Etempenver (%s)' % sc.lst('d2varlst', R.sample(vs, R.choice([0, 1, 2]))))
        tr('K_D2Esolverify (%s)' % R.choice([g.basic(), 's2exp_bool_bool_t0ype (true)', 's2exp_bool_bool_t0ype (false)']))
        tr('K_D2Esolassert (%s)' % ('K_d2exp (%s, K_D2Eextval (%s, "p"))' % (loc(), R.choice(['s2exp_bool_bool_t0ype (true)', g.basic()]))))
        tr('K_D2Esing (%s)' % eg.up(1))
        tr('K_D2Elist (%d, %s)' % (R.choice([-1, 0, 1]), eg.ls(R.choice([0, 1, 2]), 1, 'up')))
        tr('K_D2Eshowtype (%s)' % eg.up(1))
        tr('K_D2Eraise (%s)' % 'K_d2exp (%s, K_D2Eextval (s2exp_exception_vtype (), "exn"))' % loc())
        tr('K_D2Edelay (%s)' % eg.up(1))
        tr('K_D2Eldelay (%s, %s)' % (eg.up(1), R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % 'K_d2exp (%s, K_D2Eempty ())' % loc()])))
        tr('K_D2Eann_type (%s, %s)' % ('K_d2exp (%s, K_D2Eextval (%s, "t"))' % (loc(), 's2exp_int_t0ype ()'), 's2exp_int_t0ype ()'))
        tr('K_D2Eann_type (%s, %s)' % ('K_d2exp (%s, K_D2Eextval (%s, "t"))' % (loc(), 's2exp_int_t0ype ()'), 's2exp_bool_t0ype ()'))
        sy = 'K_D2Emacsyn (mkmacsynkind (%d), %s)' % (R.randint(0, 2), eg.leaf())
        tr(sy)
        tr('K_D2Esym (%s)' % sc.gv('d2sym', 1))
        tr('K_D2Earrinit (%s, %s, %s)' % (g.basic(), R.choice(['ON_d2expopt ()', 'OS_d2expopt (K_d2exp (%s, K_D2Eint (3)))' % loc()]), 'LN_d2explst ()'))
        tr('K_D2Earrpsz (%s, %s)' % (R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()]), 'LN_d2explst ()'))
        tr('K_D2Elst (%d, %s, LN_d2explst ())' % (R.choice([-1, 0, 1]), R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % g.basic()])))
        tr('K_D2Eseq (%s)' % sc.lst('d2explst', ['K_d2exp (%s, K_D2Eempty ())' % loc(), eg.up(1)]))
        tr('K_D2Eseq (%s)' % sc.lst('d2explst', ['K_d2exp (%s, K_D2Eempty ())' % loc(), 'K_d2exp (%s, K_D2Eempty ())' % loc(), eg.up(2)]))
        tr('K_D2Etup (%d, %d, %s)' % (R.choice([0, 1]), R.choice([-1, 0]), eg.ls(2, 1, 'up')))
        tr('K_D2Erec (%d, %d, %s)' % (R.choice([0, 1]), R.choice([-1, 0]), sc.lst('labd2explst', ['K_labd2exp (mkl0ab (%d), %s)' % (i, eg.up(1)) for i in range(2)])))
        tr('K_D2Elam_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), eg.up(2)))
        tr('K_D2Elaminit_dyn (%d, %d, LN_p2atlst (), %s)' % (R.choice([0, 1]), R.choice([-1, 0]), eg.up(2)))
        sv = [sc.val('s2var_make_srt (s2rt_t0ype)', 's2var') for _ in range(R.choice([0, 1, 2]))]
        tr('K_D2Elam_sta (%s, %s, %s)' % (sc.lst('s2varlst', sv), sc.lst('s2explst', [R.choice(['s2exp_bool_bool_t0ype (true)', g.basic()])] if R.random() < 0.5 else []), eg.up(2)))
        tr('K_D2Elam_met (K_d2varlstref (%s), %s, %s)' % (sc.lst('d2varlst', [R.choice(vs)]), sc.lst('s2explst', [R.choice([g.basic(), 'K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 4)])]), eg.up(2)))
        tr('K_D2Efix (%d, %s, %s)' % (R.choice([0, 1]), R.choice(vs), eg.up(2)))
        tr('K_D2Eifhead (%s, %s, %s, ON_d2expopt ())' % ('i2nvresstate_nil', eg.up(1), eg.up(1))) if False else None
        sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

def fam_up_eff(sc, k):
    """effects: lambdas with an effect annotation whose bodies call functions with effects, raise, effmask; closures with an annotated funclo"""
    R = sc.R; g = Gen(sc)
    loc = lambda: 'mkloc (%d)' % R.randint(0, 40)
    sc.say('-- d2exp_trup: effects')
    sc.do('t_trans3_env_push ()')
    cs = []
    for i in range(5):
        ty = 'K_s2exp (s2rt_type, K_S2Efun (mkfunclo (0), 0, K_S2EFFset (mkeffset (%d)), -1, %s, %s))' % (i, sc.lst('s2explst', []), g.basic())
        cs.append(sc.val('d2cst_make (mksym (%d), mkloc (%d), mkfil (0), mkdcstkind (0), LN_s2qualst (), LN_intlst (), %s, mkdcstextdef (0))' % (i, i, ty), 'd2cst'))
    def E(node): return 'K_d2exp (%s, %s)' % (loc(), node)
    def call(c): return E('K_D2Eapplst (%s, %s)' % (E('K_D2Ecst (%s)' % c), sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, LN_d2explst ())' % loc()])))
    def body():
        r = R.randint(0, 5)
        if r == 0: return call(R.choice(cs))
        if r == 1: return E('K_D2Eraise (%s)' % E('K_D2Eextval (s2exp_exception_vtype (), "e")'))
        if r == 2: return E('K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), call(R.choice(cs))))
        if r == 3: return E('K_D2Eseq (%s)' % sc.lst('d2explst', [E('K_D2Eempty ()'), call(R.choice(cs))]))
        if r == 4: return E('K_D2Eeffmask (K_S2EFFset (mkeffset (%d)), %s)' % (R.randint(0, 4), E('K_D2Eraise (%s)' % E('K_D2Eextval (s2exp_exception_vtype (), "e")'))))
        return E('K_D2Etup (0, -1, %s)' % sc.lst('d2explst', [call(R.choice(cs)), call(R.choice(cs))]))
    for i in range(30):
        b = body()
        r = R.randint(0, 3)
        if r == 0: e = b
        else:
            ann = 'K_D2Eann_seff (%s, K_S2EFFset (mkeffset (%d)))' % (b, R.randint(0, 4))
            kind = R.choice(['K_D2Elam_dyn', 'K_D2Elaminit_dyn'])
            if r == 3: ann = 'K_D2Eann_funclo (%s, mkfunclo (%d))' % (E(ann), R.randint(0, 3))
            e = E('%s (%d, -1, LN_p2atlst (), %s)' % (kind, R.choice([0, 1]), E(ann) if r != 3 else E(ann)))
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % (e if r != 0 else b))
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
        if i % 5 == 4: sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

def fam_up_more(sc, k):
    """extfcall/extmcall, fixpoints and metrics, solverify, redexes, arrays with a size, macros, vcopyenv"""
    R = sc.R; g = Gen(sc)
    loc = lambda: 'mkloc (%d)' % R.randint(0, 40)
    sc.say('-- d2exp_trup: extfcall, extmcall, fix, lam_met, solverify, arrinit, macros')
    sc.do('t_trans3_env_push ()')
    def E(node): return 'K_d2exp (%s, %s)' % (loc(), node)
    def tr(e):
        sc.do('t_trans3_env_push ()')
        sc.dd('d3exp', 'd2exp_trup (%s)' % e)
        sc.do('t_trans3_env_pop_and_add_main (%s)' % loc())
    # extfcall / extmcall with linear and nonlinear arguments
    sc.pools()
    lin_srt = ['s2rt_vt0ype', 's2rt_view', 's2rt_vtype', 's2rt_t0ype', 's2rt_prop', 's2rt_type']
    vs = []
    for i in range(6):
        v = sc.new('d2var')
        sc.do('d2var_set_type (%s, OS_s2expopt (K_s2exp (%s, K_S2Ecst (%s))))' % (v, lin_srt[i], sc.handle('s2cst')))
        vs.append(v)
    for i in range(10):
        args = sc.lst('d2explst', [E('K_D2Evar (%s)' % R.choice(vs)) for _ in range(R.choice([0, 1, 2, 3]))])
        tr(E('K_D2Eextfcall (%s, "fn%d", %s)' % (g.basic(), i, args)))
        tr(E('K_D2Eextmcall (%s, %s, "mtd%d", %s)' % (g.basic(), E('K_D2Evar (%s)' % R.choice(vs)), i, args)))
    sc.do('t3chk ()')
    # fixpoints: the body uses the variable, which is typed by the syntactic type of the definition
    for i in range(6):
        f = sc.new('d2var')
        ft = R.choice(['K_D2Elam_dyn (0, -1, LN_p2atlst (), %s)', 'K_D2Elaminit_dyn (0, -1, LN_p2atlst (), %s)', 'K_D2Eann_type (%s, ' + g.funty(0) + ')'])
        inner = E('K_D2Evar (%s)' % f)
        body = E(ft % inner)
        tr(E('K_D2Efix (%d, %s, %s)' % (R.choice([0, 1]), f, body)))
        sc.dd('s2expopt', 'd2var_get_type (%s)' % f)
        sc.dd('s2expopt', 'd2var_get_mastype (%s)' % f)
    sc.do('t3chk ()')
    # metrics: a recursive call of a function with a termination metric
    for i in range(4):
        f = sc.new('d2var')
        mets = [g.basic() if False else 'K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 5)]
        fty = g.funty(0, fc=0, npf=-1, args=[s2e for s2e in ['s2exp_int_int_t0ype (%d)' % R.randint(0, 3)]], res=g.basic())
        mty = 'K_s2exp (s2rt_type, K_S2Emetfun (OS_stampopt (d2var_get_stamp (%s)), %s, %s))' % (f, sc.lst('s2explst', ['K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 5)]), fty)
        sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (f, mty))
        call = E('K_D2Eapplst (%s, %s)' % (E('K_D2Evar (%s)' % f), sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, %s)' % (loc(), sc.lst('d2explst', [E('K_D2Eint (%d)' % R.randint(0, 3))]))])))
        tr(E('K_D2Elam_met (K_d2varlstref (%s), %s, %s)' % (sc.lst('d2varlst', [f]), sc.lst('s2explst', mets), call)))
    sc.do('t3chk ()')
    # solverify of a redex, the type of a sequence that ends with a redex
    for i in range(3):
        a = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
        redex = 'K_s2exp (s2rt_t0ype, K_S2Eapp (K_s2exp (s2rt_t0ype, K_S2Elam (%s, %s)), %s))' % (sc.lst('s2varlst', [a]), g.svar_exp(a), sc.lst('s2explst', [g.basic()]))
        tr(E('K_D2Esolverify (%s)' % redex))
        tr(E('K_D2Eseq (%s)' % sc.lst('d2explst', [E('K_D2Eempty ()'), E('K_D2Eextval (%s, "r")' % redex)])))
        tr(E('K_D2Esolassert (%s)' % E('K_D2Eextval (%s, "q")' % redex)))
    sc.do('t3chk ()')
    # arrays with a size: an index, not an index, no size, no element
    for i in range(6):
        for asz in ['ON_d2expopt ()', 'OS_d2expopt (%s)' % E('K_D2Eint (%d)' % R.randint(0, 4)), 'OS_d2expopt (%s)' % E('K_D2Eextval (s2exp_int_t0ype (), "n")'),
                    'OS_d2expopt (%s)' % E('K_D2Eextval (s2exp_bool_t0ype (), "n")')]:
            els = sc.lst('d2explst', [E('K_D2Eint (%d)' % j) for j in range(R.choice([0, 0, 1, 2]))])
            tr(E('K_D2Earrinit (%s, %s, %s)' % (g.basic(), asz, els)))
    sc.do('t3chk ()')
    # vcopyenv of variables with and without type
    for v in vs[:2] + [sc.new('d2var')]:
        for knd in (0, 1): tr(E('K_D2Evcopyenv (%d, %s)' % (knd, E('K_D2Evar (%s)' % v))))
    sc.do('t3chk ()')
    # macros (short form; the evaluator is the real one in both builds)
    x = sc.new('d2var')
    m0 = sc.val('d2mac_make (mkloc (1), mksym (1), 0, LN_m2acarglst (), %s)' % E('K_D2Eint (7)'), 'd2mac')
    m1 = sc.val('d2mac_make (mkloc (2), mksym (2), 0, %s, %s)' % (sc.lst('m2acarglst', ['K_M2ACARGdyn (%s)' % sc.lst('d2varlst', [x])]), E('K_D2Evar (%s)' % x)), 'd2mac')
    m2 = sc.val('d2mac_make (mkloc (3), mksym (3), 0, %s, %s)' % (sc.lst('m2acarglst', ['K_M2ACARGdyn (%s)' % sc.lst('d2varlst', [x])]),
                E('K_D2Eseq (%s)' % sc.lst('d2explst', [E('K_D2Evar (%s)' % x), E('K_D2Evar (%s)' % x)]))), 'd2mac')
    tr(E('K_D2Emac (%s)' % m0))
    for m in (m1, m2):
        for a in ('K_D2Eint (3)', 'K_D2Ebool (true)', 'K_D2Estring ("s")'):
            tr(E('K_D2Eapplst (%s, %s)' % (E('K_D2Emac (%s)' % m), sc.lst('d2exparglst', ['K_D2EXPARGdyn (-1, %s, %s)' % (loc(), sc.lst('d2explst', [E(a)]))]))))
    for kd in range(3):
        tr(E('K_D2Emacsyn (mkmacsynkind (%d), %s)' % (kd, E('K_D2Eint (%d)' % kd))))
    sc.do('t3chk ()')
    sc.do('t_trans3_env_pop_and_add_main (mkloc (0))')
    sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
    sc.do('t3chk ()')

# ---------------------------------------------------------------------------------------------------------------------
def main():
    G_ = G
    C.put(os.path.join(d, 't3compat_gen.hats'), t3_gen.gen_compat(2))
    C.put(os.path.join(d, 't3compat1_gen.hats'), t3_gen.gen_compat(1))
    C.put(os.path.join(d, 't3hand.hats'), t3_gen.expand_hand(2))
    C.put(os.path.join(d, 't3hand1.hats'), t3_gen.expand_hand(1))
    C.put(os.path.join(d, 't3g1envx.hats'), t3_gen.expand_hand(2, 't3g1env.tmpl'))
    C.put(os.path.join(d, 't3g1envx1.hats'), t3_gen.expand_hand(1, 't3g1env.tmpl'))
    C.put(os.path.join(d, 't3g1hand.hats'), t3_gen.expand_hand(2, 't3g1hand.tmpl'))
    C.put(os.path.join(d, 't3g1hand1.hats'), t3_gen.expand_hand(1, 't3g1hand.tmpl'))
    fams = [('setup', SETUP, 0), ('ints', fam_ints, 3), ('floats', fam_floats, 2), ('atoms', fam_atoms, 2), ('syn', fam_syn, 4), ('d3', fam_d3, 3),
            ('trdn', fam_trdn, 3), ('upatoms', fam_up_atoms, 4), ('upvars', fam_up_vars, 2), ('upapps', fam_up_apps, 3), ('upmisc', fam_up_misc, 2), ('upeff', fam_up_eff, 3), ('upmore', fam_up_more, 3)]
    R = random.Random(SEED)
    scs = []
    for name, fam, n in fams:
        for i in range(max(1, int(round(n * SCALE / 3.0))) if n > 0 else 1):
            sc = Sc3(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    body = ''.join(t3_cases.wrap_text(sc.text()) for sc in scs)
    body += 'fun t3g1_all (): void = {\n' + ''.join('  val () = %s ()\n' % sc.name for sc in scs) + '}\n'
    C.put(os.path.join(d, 't3g1cases.hats'), '(* generated by t3g1_gen.py *)\n' + body)
    print('t3g1_gen: %d scenarios, %d lines' % (len(scs), body.count('\n')))

if __name__ == '__main__':
    main()
