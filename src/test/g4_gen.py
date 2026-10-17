#!/usr/bin/env python3
# usage: python3 g4_gen.py   (rewrites g4env.hats g4env1.hats g4case_pre.hats g4case_pre1.hats g4cases_*.hats g4case_*.dats g4case1_*.dats g4chunks*.hats)
#
# Test of group 4 of the trans3 port (pats_trans3_{decl,looping,assgn,deref,ptrof,viewat,xchng}.dats) against the ATS1 build of src/
# (see PORTING.md, "Level 3 translation, group 4"). Same method as t3_gen.py: ONE generated program of scenarios, written in the common subset
# of ATS1 and ATS2, is compiled by the ATS2 driver (g4dump.dats) and by the ATS1 driver (g4dump1.dats, linked with the ATS1 objects of the
# main tree); stdout and stderr must be identical. The functions of the other groups that the 7 modules call are test doubles (t3g4/g4env.tmpl,
# written once for ATS1 and ATS2): they print their arguments, so the order of the calls and the arguments are compared too.
# The compat layers (K_<CON> wrappers, dumpers dd_<T>) are those of t3_gen.py. G4SEED, G4SCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import t3_gen, d2_gen, d2_cases, t3_cases

SEED = int(os.environ.get('G4SEED', '1'))
SCALE = float(os.environ.get('G4SCALE', '3'))
G = d2_gen; C = d2_cases

def families(Sc3, F0):
    F = []
    setup = [f for (n, f, k) in F0 if n == 'setup'][0]
    F.append(('setup', setup, 0))
    PRES = C.PRESORTS

    # ---- the building blocks of a scenario
    def sty(sc, d):
        """a safe static expression (no application of a random constant: the solver aborts on those, S2B-5)"""
        R = sc.R
        base = ['s2exp_int_t0ype ()', 's2exp_bool_t0ype ()', 's2exp_void_t0ype ()', 's2exp_char_t0ype ()', 's2exp_int_int_t0ype (3)',
                's2exp_ptr_type ()', 's2exp_string_type ()', 's2exp_double_t0ype ()']
        r = R.random()
        if d <= 0 or r < 0.45: return R.choice(base)
        if r < 0.65:
            fs = [sc.val('K_labs2exp (mklab (%d), ON_stringopt (), %s)' % (i, sty(sc, d - 1)), 'labs2exp') for i in range(R.choice([1, 2, 3]))]
            return 'K_s2exp (s2rt_t0ype, K_S2Etyrec (%s, 0, %s))' % (R.choice(['K_TYRECKINDflt0 ()', 'K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()']), sc.lst('labs2explst', fs))
        if r < 0.75: return 'K_s2exp (s2rt_view, K_S2Eat (%s, %s))' % (sty(sc, d - 1), addrv(sc))
        if r < 0.82: return 'K_s2exp (s2rt_t0ype, K_S2Etop (%d, %s))' % (R.choice([0, 1]), sty(sc, d - 1))
        if r < 0.88: return 'K_s2exp (s2rt_view, K_S2Ewithout (%s))' % sty(sc, d - 1)
        return R.choice(base)
    def addrv(sc):
        return 'K_s2exp (s2rt_addr, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_addr)', 's2var')
    def tys(sc, extra=True):
        """a static expression used as the type of a variable / the new type of an assignment"""
        R = sc.R
        r = R.random()
        if r < 0.5: return sty(sc, 0)
        if r < 0.62: return 'K_s2exp (s2rt_vt0ype, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_vt0ype)', 's2var')   # linear
        if r < 0.72: return 'K_s2exp (s2rt_prop, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_prop)', 's2var')       # proof
        if r < 0.8: return 'K_s2exp (s2rt_view, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_view)', 's2var')      # linear proof
        if r < 0.92: return sty(sc, 1)
        return sty(sc, 2)
    def knobs(sc):
        R = sc.R
        sc.do('g4_setk (0, %d)' % R.choice([0, 0, 1]))
        sc.do('g4_setk (1, %d)' % R.choice([0, 0, 1]))
        sc.do('g4_setk (2, %d)' % R.choice([0, 1, 1]))
        sc.do('g4_setk (3, %d)' % R.choice([0, 1]))
        sc.do('g4_setk (4, %d)' % R.choice([0, 1, 1]))
        sc.do('g4_setk (5, %d)' % R.choice([0, 1]))
        sc.do('g4_sets2e (0, %s)' % (tys(sc) if R.random() < 0.5 else 'K_s2exp (s2rt_vt0ype, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_vt0ype)', 's2var')))
        sc.do('g4_sets2e (1, K_s2exp (s2rt_bool, K_S2Evar (%s)))' % sc.val('s2var_make_srt (s2rt_bool)', 's2var'))
        sc.do('g4_sets2e (2, %s)' % tys(sc))
        sc.do('g4_sets2e (3, %s)' % tys(sc))
        sc.do('g4_sets2e (4, %s)' % tys(sc))
        sc.do('g4_sets2e (5, %s)' % tys(sc))
    class Env: pass
    def setup_env(sc, nx=None):
        """the scopes, the mutable variables (with their at-views in the proof manager), pointers, references, linear variables"""
        R = sc.R
        sc.pools()
        e = Env()
        loc = sc.loc
        sc.do('trans3_env_push ()')
        sc.do('the_d2varenv_push_let ()')
        sc.do('the_pfmanenv_push_let ()')
        if R.random() < 0.6: sc.do('the_effenv_push_set (mkeffset (%d))' % R.randint(0, 4)); e.eff = 1
        else: e.eff = 0
        e.xs = []; e.addrs = []; e.xws = []
        for i in range(nx if nx else R.choice([1, 2, 3])):
            x = sc.val('d2var_make (%s, mksym (%d))' % (loc(), i), 'd2var')
            sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (x, tys(sc)))
            xw = sc.val('d2var_mutablize_none (%s, %s, %s)' % (loc(), x, tys(sc)), 'd2var')
            sc.do('the_d2varenv_add_dvar (%s)' % x)
            sc.do('the_pfmanenv_add_dvar (%s)' % x)
            e.xs.append(x); e.xws.append(xw)
            e.addrs.append(sc.val('g4_addr (%s)' % x, 's2exp'))
        e.ps = []; e.rs = []; e.zs = []; e.ys = []
        for i in range(R.choice([1, 2])):
            p = sc.val('d2var_make (%s, mksym (%d))' % (loc(), 10 + i), 'd2var')
            sc.do('d2var_set_type (%s, OS_s2expopt (s2exp_ptr_addr_type (%s)))' % (p, R.choice(e.addrs + [addrv(sc)])))
            e.ps.append(p)
        r = sc.val('d2var_make (%s, mksym (20))' % loc(), 'd2var')
        sc.do('d2var_set_type (%s, OS_s2expopt (s2exp_ref_vt0ype_type (%s)))' % (r, tys(sc)))
        e.rs.append(r)
        z = sc.val('d2var_make (%s, mksym (30))' % loc(), 'd2var')
        sc.do('d2var_set_type (%s, OS_s2expopt (s2exp_lazy_vt0ype_vtype (%s)))' % (z, tys(sc)))
        e.zs.append(z)
        for i in range(R.choice([1, 2])):
            y = sc.val('d2var_make (%s, mksym (40 + %d))' % (loc(), i), 'd2var')
            if R.random() < 0.7: sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (y, tys(sc)))
            else: sc.do('d2var_set_type (%s, ON_s2expopt ())' % y)
            sc.do('d2var_set_linval (%s, %d)' % (y, R.choice([0, 0, 1])))
            e.ys.append(y)
        e.sym = sc.val('d2sym_make (%s, mkd0ynq (0), mksym (1), LN_d2pitmlst ())' % loc(), 'd2sym')
        knobs(sc)
        return e
    def finish_env(sc, e):
        sc.say('-- end')
        C.finish(sc)
        for c in sc.pool.get('s2cst', []):
            sc.dd('s2expopt', 's2cst_get_def (%s)' % c); sc.dd('s2expoptopt', 's2cst_get_isabs (%s)' % c); sc.dd('s2expopt', 's2cst_get_isasp (%s)' % c)
        sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        sc.do('(fprint_the_pfmanenv (dd_out); dd_nl ())')
        sc.do('the_pfmanenv_pop ()')
        sc.do('the_d2varenv_pop ()')
        if e.eff: sc.do('the_effenv_pop ()')
        sc.do('(dd_listvt_s3itm (trans3_env_pop ()); dd_nl ())')
        sc.do('t3chk ()')
    def E(sc, node): return sc.val('K_d2exp (%s, %s)' % (sc.loc(), node), 'd2exp')
    def var(sc, v): return E(sc, 'K_D2Evar (%s)' % v)
    def labs(sc, e, n=None):
        R = sc.R
        out = []
        for i in range(n if n is not None else R.choice([1, 1, 2, 3])):
            if R.random() < 0.7: nd = 'K_D2LABlab (mklab (%d))' % R.randint(0, 3)
            else: nd = 'K_D2LABind (%s)' % sc.lst('d2explst', [rv(sc, e) for _ in range(R.choice([1, 2]))])
            out.append(sc.val('K_d2lab (%s, %s, ON_d2symopt ())' % (sc.loc(), nd), 'd2lab'))
        return sc.lst('d2lablst', out)
    def d3labs(sc, e, n=None):
        R = sc.R
        out = []
        for i in range(n if n is not None else R.choice([0, 1, 1, 2, 3])):
            if R.random() < 0.7: out.append(sc.val('d3lab_lab (%s, mklab (%d), ON_d2symopt ())' % (sc.loc(), R.randint(0, 3)), 'd3lab'))
            else: out.append(sc.val('d3lab_ind (%s, %s)' % (sc.loc(), sc.lst('d3explst', [sc.val('d3exp_int (%s, s2exp_int_int_t0ype (%d), %d)' % (sc.loc(), i, i), 'd3exp')])), 'd3lab'))
        return sc.lst('d3lablst', out)
    def rv(sc, e):
        R = sc.R
        r = R.random()
        if r < 0.3: return E(sc, 'K_D2Etop2 (%s)' % tys(sc))
        if r < 0.5 and e.ys: return var(sc, R.choice(e.ys))
        if r < 0.65: return E(sc, 'K_D2Eint (%d)' % R.randint(0, 9))
        if r < 0.75: return E(sc, 'K_D2Eempty ()')
        if r < 0.9: return var(sc, R.choice(e.xs))
        return E(sc, 'K_D2Etop2 (%s)' % tys(sc))
    def lv(sc, e, kinds=None):
        """a left-value expression (of every kind that [d2exp_lvalize] knows, and some that it does not)"""
        R = sc.R
        k = R.choice(kinds) if kinds else R.choice(['xvar', 'xvar', 'yvar', 'xsel', 'pderef', 'rderef', 'zderef', 'psel', 'arrsub', 'viewat', 'none', 'nonptr', 'xvar', 'pderef', 'ysel', 'ysel', 'xsel0', 'ovsel', 'nonlvsel'])
        if k == 'xvar': return var(sc, R.choice(e.xs))
        if k == 'yvar': return var(sc, R.choice(e.ys))
        if k == 'xsel': return E(sc, 'K_D2Eselab (%s, %s)' % (var(sc, R.choice(e.xs)), labs(sc, e)))
        if k == 'ysel': return E(sc, 'K_D2Eselab (%s, %s)' % (var(sc, R.choice(e.ys)), labs(sc, e)))
        if k == 'xsel0': return E(sc, 'K_D2Eselab (%s, %s)' % (var(sc, R.choice(e.xs + e.ys)), 'LN_d2lablst ()'))
        if k == 'ovsel':
            l = sc.val('K_d2lab (%s, K_D2LABlab (mklab (%d)), OS_d2symopt (%s))' % (sc.loc(), R.randint(0, 3), e.sym), 'd2lab')
            return E(sc, 'K_D2Eselab (%s, %s)' % (E(sc, 'K_D2Etop2 (%s)' % tys(sc)), sc.lst('d2lablst', [l])))
        if k == 'nonlvsel':
            return E(sc, 'K_D2Eselab (%s, %s)' % (E(sc, 'K_D2Eselab (%s, %s)' % (E(sc, 'K_D2Etop2 (%s)' % tys(sc)), labs(sc, e))), labs(sc, e)))
        if k == 'pderef': return E(sc, 'K_D2Ederef (%s, %s)' % (e.sym, var(sc, R.choice(e.ps))))
        if k == 'rderef': return E(sc, 'K_D2Ederef (%s, %s)' % (e.sym, var(sc, R.choice(e.rs))))
        if k == 'zderef': return E(sc, 'K_D2Ederef (%s, %s)' % (e.sym, var(sc, R.choice(e.zs))))
        if k == 'nonptr': return E(sc, 'K_D2Ederef (%s, %s)' % (e.sym, var(sc, R.choice(e.xs + e.ys))))
        if k == 'psel':
            base = R.choice([(e.ps, 'p'), (e.rs, 'r')])[0]
            return E(sc, 'K_D2Eselab (%s, %s)' % (E(sc, 'K_D2Ederef (%s, %s)' % (e.sym, var(sc, R.choice(base)))), labs(sc, e)))
        if k == 'arrsub':
            return E(sc, 'K_D2Earrsub (%s, %s, %s, %s)' % (e.sym, var(sc, R.choice(e.xs)), sc.loc(), sc.lst('d2explst', [rv(sc, e) for _ in range(R.choice([1, 2]))])))
        if k == 'viewat': return E(sc, 'K_D2Eviewat (%s)' % lv(sc, e, ['xvar', 'pderef', 'xsel', 'yvar', 'psel']))
        return E(sc, 'K_D2Etop2 (%s)' % tys(sc))
    def dumpr(sc, e, what):
        sc.dd('d3exp', what)
        sc.do('t3chk ()')
        if sc.R.random() < 0.7:
            for w in e.xws: sc.do('chk_d2var (%s)' % w)

    # ---- the left-value operations: assignment, exchange, address-of, view-at, dereference
    def fam_lval(sc, k):
        R = sc.R
        e = setup_env(sc)
        for rep in range(R.randint(8, 14)):
            knobs(sc) if R.random() < 0.5 else None
            c = R.randint(0, 13)
            if c <= 3: dumpr(sc, e, 'd2exp_trup_assgn (%s)' % E(sc, 'K_D2Eassgn (%s, %s)' % (lv(sc, e), rv(sc, e))))
            elif c <= 6: dumpr(sc, e, 'd2exp_trup_xchng (%s)' % E(sc, 'K_D2Exchng (%s, %s)' % (lv(sc, e), rv(sc, e))))
            elif c == 7: dumpr(sc, e, 'd2exp_trup_ptrof (%s)' % E(sc, 'K_D2Eptrof (%s)' % lv(sc, e, ['xvar', 'xvar', 'xsel', 'ysel', 'yvar', 'xsel0', 'pderef', 'psel', 'nonptr', 'nonlvsel', 'none', 'rderef'])))
            elif c == 8: dumpr(sc, e, 'd2exp_trup_viewat (%s)' % E(sc, 'K_D2Eviewat (%s)' % lv(sc, e, ['xvar', 'pderef', 'xsel', 'yvar', 'psel', 'none', 'rderef', 'nonptr', 'zderef'])))
            elif c == 9: dumpr(sc, e, 'd2exp_trup_viewat_assgn (%s)' % E(sc, 'K_D2Eassgn (%s, %s)' % (E(sc, 'K_D2Eviewat (%s)' % lv(sc, e, ['xvar', 'pderef', 'xsel', 'yvar', 'none', 'rderef', 'nonptr'])), rv(sc, e))))
            elif c == 10: dumpr(sc, e, 'd2exp_trup_deref (%s, %s, %s, %s)' % (sc.loc(), e.sym, var(sc, R.choice(e.ps + e.rs + e.zs + e.xs + e.ys)), labs(sc, e, R.choice([0, 1, 2]))))
            elif c == 11: dumpr(sc, e, 'd2exp_trup_assgn_deref (%s, %s, %s, %s)' % (sc.loc(), var(sc, R.choice(e.ps + e.rs + e.zs + e.ys)), labs(sc, e, R.choice([0, 1, 2])), rv(sc, e)))
            elif c == 12: dumpr(sc, e, 'd2exp_trup_xchng_deref (%s, %s, %s, %s)' % (sc.loc(), var(sc, R.choice(e.ps + e.rs + e.zs)), labs(sc, e, R.choice([0, 1, 2])), rv(sc, e)))
            else: dumpr(sc, e, 'd2exp_trup_assgn (%s)' % E(sc, 'K_D2Eassgn (%s, %s)' % (lv(sc, e, ['arrsub', 'none', 'nonptr', 'zderef']), rv(sc, e))))
            if R.random() < 0.3:
                v = R.choice(e.xs + e.ys)
                sc.do('chk_d2var (%s)' % v)
        finish_env(sc, e)
    F.append(('lval', fam_lval, 30))

    # ---- the functions on addresses
    def fam_addr(sc, k):
        R = sc.R
        e = setup_env(sc)
        def A():
            return R.choice(e.addrs) if R.random() < 0.85 else addrv(sc)
        for rep in range(R.randint(10, 16)):
            knobs(sc) if R.random() < 0.5 else None
            c = R.randint(0, 11)
            l3 = d3labs(sc, e)
            if c == 0: sc.do('g4_s2addr_deref (%s, %s, %s)' % (sc.loc(), A(), l3))
            elif c == 1: sc.do('g4_s2addr_assgn_deref (%s, %s, %s, %s)' % (sc.loc(), A(), l3, sc.val('d3exp_top (%s, %s)' % (sc.loc(), tys(sc)), 'd3exp')))
            elif c == 2: sc.do('g4_s2addr_xchng_check (%s, %s, %s, %s, s2exp2hnf (%s))' % (sc.loc(), sc.loc(), A(), l3, tys(sc)))
            elif c == 3: sc.do('g4_s2addr_xchng_deref (%s, %s, %s, %s)' % (sc.loc(), A(), l3, rv(sc, e)))
            elif c == 4: sc.dd('s2exp', 's2addr_viewat_deref (%s, %s, %s)' % (sc.loc(), A(), l3))
            elif c == 5: sc.do('s2addr_set_viewat (%s, %s, %s, %s)' % (sc.loc(), A(), l3, R.choice(['K_s2exp (s2rt_view, K_S2Eat (%s, %s))' % (tys(sc), A()), tys(sc)])))
            elif c == 6:
                sc.do('s2addr_set_viewat_check (%s, %s, %s, %s, %s, %s, %s)' % (
                    sc.loc(), A(), l3, 'K_s2exp (s2rt_view, K_S2Eat (%s, %s))' % (tys(sc), A()),
                    R.choice(['K_s2exp (s2rt_view, K_S2Ewithout (%s))' % tys(sc), tys(sc)]), tys(sc),
                    R.choice([A(), 'K_s2exp (s2rt_addr, K_S2Eproj (%s, %s, %s))' % (A(), tys(sc), sc.lst('s2lablst', [sc.val(R.choice(['K_S2LABlab (mklab (%d))' % R.randint(0, 3), 'K_S2LABind (%s)' % sc.lst('s2explst', [sc.val('K_s2exp (s2rt_int, K_S2Eint (1))', 's2exp')])]), 's2lab') for _ in range(R.choice([1, 1, 2]))]))])))
            elif c == 7: sc.dd('d3exp', 'd2exp_trdn_xchng (%s, %s, s2exp2hnf (%s))' % (sc.loc(), lv(sc, e), tys(sc)))
            elif c == 8: sc.dd('d3exp', 'd2exp_trdn_xchng_deref (%s, %s, %s, %s, s2exp2hnf (%s))' % (sc.loc(), sc.loc(), var(sc, R.choice(e.ps + e.rs + e.zs)), labs(sc, e, R.choice([0, 1, 2])), tys(sc)))
            elif c == 9: sc.do('g4_s2addr_ptrof_like (%s, %s)' % (sc.loc(), A())) if False else sc.dd('d3exp', 'd2exp_trup_ptrof (%s)' % E(sc, 'K_D2Eptrof (%s)' % lv(sc, e, ['xvar', 'xsel', 'pderef', 'psel'])))
            elif c == 10: sc.dd('d3exp', 'd2exp_trup_xchng (%s)' % E(sc, 'K_D2Exchng (%s, %s)' % (lv(sc, e, ['xvar', 'xsel', 'pderef', 'psel', 'rderef']), lv(sc, e, ['xvar', 'xsel', 'pderef', 'psel', 'rderef']))))
            else: sc.dd('d3exp', 'd2exp_trup_assgn (%s)' % E(sc, 'K_D2Eassgn (%s, %s)' % (lv(sc, e, ['xvar', 'xsel', 'pderef', 'psel', 'rderef']), rv(sc, e))))
            sc.do('t3chk ()')
            if R.random() < 0.7:
                for w in e.xws: sc.do('chk_d2var (%s)' % w)
        finish_env(sc, e)
    F.append(('addr', fam_addr, 30))

    # ---- loops: the invariants, break/continue, the dry-run, the loop environment
    def bodyops(sc, e, n):
        R = sc.R
        out = []
        for i in range(n):
            c = R.randint(0, 6)
            if c <= 1: out.append(E(sc, 'K_D2Eassgn (%s, %s)' % (lv(sc, e, ['xvar', 'xvar', 'pderef', 'xsel']), rv(sc, e))))
            elif c == 2: out.append(E(sc, 'K_D2Eloopexn (0)'))
            elif c == 3: out.append(E(sc, 'K_D2Eloopexn (1)'))
            elif c == 4: out.append(E(sc, 'K_D2Exchng (%s, %s)' % (lv(sc, e, ['xvar', 'pderef']), lv(sc, e, ['xvar', 'pderef']))))
            else: out.append(rv(sc, e))
        return out
    def invariant(sc, e):
        R = sc.R
        vs = [sc.val('s2var_make_srt (s2rt_int)', 's2var') for _ in range(R.choice([0, 1, 2]))]
        def args():
            out = []
            for v in R.sample(e.xs + e.ys, R.randint(0, len(e.xs + e.ys))):
                out.append(sc.val('K_i2nvarg (%s, %s)' % (v, R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc)])), 'i2nvarg'))
            return sc.lst('i2nvarglst', out)
        def met():
            return R.choice(['ON_s2explstopt ()', 'OS_s2explstopt (%s)' % sc.lst('s2explst', [sc.val('K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 5), 's2exp')])])
        def gua():
            return sc.lst('s2explst', [sc.val('K_s2exp (s2rt_bool, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_bool)', 's2var'), 's2exp') for _ in range(R.choice([0, 1, 2]))])
        res = sc.val('K_i2nvresstate (%s, %s, %s, %s)' % (sc.lst('s2varlst', [sc.val('s2var_make_srt (s2rt_int)', 's2var') for _ in range(R.choice([0, 1]))]), gua(), args(), met()), 'i2nvresstate')
        return sc.val('K_loopi2nv (%s, %s, %s, %s, %s, %s)' % (sc.loc(), sc.lst('s2varlst', vs), gua(), args(), met(), res), 'loopi2nv')
    def fam_loop(sc, k):
        R = sc.R
        e = setup_env(sc)
        for y in e.ys: sc.do('the_d2varenv_add_dvar (%s)' % y)
        for rep in range(R.randint(3, 6)):
            knobs(sc) if R.random() < 0.5 else None
            c = R.randint(0, 5)
            if c <= 3:
                inv = invariant(sc, e)
                test = E(sc, 'K_D2Etop2 (%s)' % R.choice(['s2exp_bool_t0ype ()', 's2exp_bool_bool_t0ype (true)', 's2exp_bool_index_t0ype (K_s2exp (s2rt_bool, K_S2Evar (%s)))' % sc.val('s2var_make_srt (s2rt_bool)', 's2var'), tys(sc)]))
                body = E(sc, 'K_D2Eseq (%s)' % sc.lst('d2explst', bodyops(sc, e, R.randint(1, 4))))
                init = R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % rv(sc, e)])
                post = R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % E(sc, 'K_D2Eassgn (%s, %s)' % (lv(sc, e, ['xvar', 'pderef']), rv(sc, e)))])
                dumpr(sc, e, 'd2exp_trup_loop (%s, %s, %s, %s, %s, %s)' % (sc.loc(), inv, init, test, post, body))
                for v in e.xs + e.ys:
                    if R.random() < 0.3: sc.do('chk_d2var (%s)' % v)
            else:
                # break / continue under every kind of loop marker
                m = R.randint(0, 4)
                if m == 0: sc.do('the_lamlpenv_push_lam (%s)' % sc.lst('p3atlst', []))
                elif m == 1: sc.do('the_lamlpenv_push_loop0 ()')
                elif m in (2, 3): sc.do('the_lamlpenv_push_loop1 (%s, the_d2varenv_save_lstbefitmlst (), %s)' % (invariant(sc, e), R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % rv(sc, e)])))
                for kk in (0, 1): dumpr(sc, e, 'd2exp_trup_loopexn (%s, %d)' % (sc.loc(), kk))
                if m <= 3: sc.do('the_lamlpenv_pop ()')
        finish_env(sc, e)
    F.append(('loop', fam_loop, 20))

    # ---- declarations
    def decl_ops(sc, e, n, depth=0):
        R = sc.R
        locs = sc.loc
        out = []
        def D(node): return sc.val('K_d2ecl (%s, %s)' % (sc.loc(), node), 'd2ecl')
        def cst(isabs=None, isasp=None):
            if isabs is None: isabs = R.choice(['ON_s2expoptopt ()', 'OS_s2expoptopt (ON_s2expopt ())', 'OS_s2expoptopt (OS_s2expopt (%s))' % tys(sc)])
            if isasp is None: isasp = R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc)])
            return sc.val('s2cst_make (mksymname ("c%d"), %s, mkfil (0), s2rt_t0ype, %s, false, false, %s, ON_d2conpairopt (), LN_syms2rtlstlst (), ON_s2expopt ())' % (R.randint(0, 99), sc.loc(), isabs, isasp), 's2cst')
        def pat(d2v=None):
            r = R.random()
            if r < 0.15: return sc.val('K_p2at (%s, t_svs_nil (), t_dvs_nil (), ON_s2expopt (), K_P2Tint (%d))' % (sc.loc(), R.randint(0, 3)), 'p2at')
            if r < 0.25: return sc.val('K_p2at (%s, t_svs_nil (), t_dvs_nil (), ON_s2expopt (), K_P2Tbool (%s))' % (sc.loc(), R.choice(['true', 'false'])), 'p2at')
            if d2v is None or r < 0.4: return sc.val('K_p2at (%s, t_svs_nil (), t_dvs_nil (), ON_s2expopt (), K_P2Tany ())' % sc.loc(), 'p2at')
            return sc.val('K_p2at (%s, t_svs_nil (), t_dvs_nil (), ON_s2expopt (), K_P2Tvar (%s))' % (sc.loc(), d2v), 'p2at')
        def vdecs():
            ds = []
            for i in range(R.choice([1, 1, 2])):
                v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 50 + R.randint(0, 9)), 'd2var')
                ds.append(sc.val('K_v2aldec (%s, %s, %s, %s)' % (sc.loc(), pat(v), rv(sc, e), R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc)])), 'v2aldec'))
            return sc.lst('v2aldeclst', ds)
        for i in range(n):
            c = R.randint(0, 25)
            if c == 0: out.append(D('K_D2Cnone ()'))
            elif c == 1 and depth < 2: out.append(D('K_D2Clist (%s)' % sc.lst('d2eclist', decl_ops(sc, e, R.randint(0, 3), depth + 1))))
            elif c == 2: out.append(D('K_D2Csymintr (LN_i0delst ())'))
            elif c == 3: out.append(D('K_D2Coverload (mki0de (1), %d, ON_d2itmopt ())' % R.randint(0, 2)))
            elif c == 4: out.append(D('K_D2Cpragma (LN_e1xplst ())'))
            elif c == 5: out.append(D('K_D2Cstacsts (%s)' % sc.lst('s2cstlst', [cst()])))
            elif c == 6:
                v1 = sc.val('s2var_make_srt (s2rt_t0ype)', 's2var')
                lam = 'K_s2exp (K_S2RTfun (LC_s2rtlst (s2rt_t0ype, LN_s2rtlst ()), s2rt_t0ype), K_S2Elam (%s, K_s2exp (s2rt_t0ype, K_S2Evar (%s))))' % (sc.lst('s2varlst', [v1]), v1)
                dfn = R.choice([tys(sc), 'K_s2exp (s2rt_t0ype, K_S2Eapp (%s, %s))' % (lam, sc.lst('s2explst', [tys(sc)]))])
                out.append(D('K_D2Csaspdec (%s)' % sc.val('K_s2aspdec (%s, %s, %s)' % (sc.loc(), cst(), dfn), 's2aspdec')))
            elif c == 7: out.append(D('K_D2Creassume (%s)' % cst()))
            elif c == 8: out.append(D('K_D2Cextype ("t", %s)' % tys(sc)))
            elif c == 9: out.append(D('K_D2Cextvar ("v", %s)' % rv(sc, e)))
            elif c == 10: out.append(D('K_D2Cextcode (%d, %d, "code")' % (R.randint(0, 2), R.randint(0, 2))))
            elif c == 23: out.append(D('K_D2Cexndecs (LN_d2conlst ())'))
            elif c == 24: out.append(D('K_D2Cdcstdecs (%d, mkdcstkind (%d), %s)' % (R.randint(0, 2), R.randint(0, 5), sc.lst('d2cstlst', [sc.new('d2cst')]))))
            elif c == 11: out.append(D('K_D2Cdatdecs (%d, %s)' % (R.randint(0, 2), sc.lst('s2cstlst', [cst()]))))
            elif c == 12: out.append(D('K_D2Cvaldecs (mkvalkind (%d), %s)' % (R.randint(0, 9), vdecs())))
            elif c == 13: out.append(D('K_D2Cvaldecs_rec (mkvalkind (%d), %s)' % (R.randint(0, 9), vdecs())))
            elif c == 14:
                ds = []
                for i in range(R.choice([1, 2])):
                    v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 60 + R.randint(0, 9)), 'd2var')
                    sv = sc.val('s2var_make_srt (s2rt_addr)', 's2var')
                    ds.append(sc.val('K_v2ardec (%s, %d, %s, %s, %s, %s, %s, %s)' % (
                        sc.loc(), R.randint(0, 1), sv, v, R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % sc.val('d2var_make (%s, mksym (3))' % sc.loc(), 'd2var')]),
                        R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc)]), R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % rv(sc, e)]),
                        R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % sc.val('d2var_make (%s, mksym (4))' % sc.loc(), 'd2var')])), 'v2ardec'))
                out.append(D('K_D2Cvardecs (%s)' % sc.lst('v2ardeclst', ds)))
            elif c == 15:
                ds = []
                for i in range(R.choice([1, 2])):
                    v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 70 + R.randint(0, 9)), 'd2var')
                    ds.append(sc.val('K_prv2ardec (%s, %s, %s, %s)' % (sc.loc(), v, R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc)]), R.choice(['ON_d2expopt ()', 'OS_d2expopt (%s)' % rv(sc, e)])), 'prv2ardec'))
                out.append(D('K_D2Cprvardecs (%s)' % sc.lst('prv2ardeclst', ds)))
            elif c == 16:
                ds = []
                for i in range(R.choice([1, 2, 3])):
                    v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 80 + R.randint(0, 9)), 'd2var')
                    mets = sc.lst('s2explst', [sc.val('K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 5), 's2exp') for _ in range(R.choice([1, 1, 2]))])
                    body = rv(sc, e)
                    df = R.choice([body, sc.val('d2exp_lam_met_new (%s, %s, %s)' % (sc.loc(), mets, body), 'd2exp'),
                                   sc.val('d2exp_lam_met_new (%s, %s, d2exp_lam_met_new (%s, %s, %s))' % (sc.loc(), mets, sc.loc(), sc.lst('s2explst', []), body), 'd2exp')])
                    ann = R.choice(['ON_s2expopt ()', 'OS_s2expopt (%s)' % tys(sc),
                                    'OS_s2expopt (K_s2exp (s2rt_type, K_S2Emetfun (OS_stampopt (d2var_get_stamp (%s)), %s, %s)))' % (v, sc.lst('s2explst', [sc.val(R.choice(['K_s2exp (s2rt_int, K_S2Eint (1))', 'K_s2exp (s2rt_bool, K_S2Eint (1))']), 's2exp') for _ in range(R.choice([1, 2]))]), tys(sc))])
                    ds.append(sc.val('K_f2undec (%s, %s, %s, %s)' % (sc.loc(), v, df, ann), 'f2undec'))
                out.append(D('K_D2Cfundecs (mkfunkind (%d), %s, %s)' % (R.randint(0, 9), sc.lst('s2qualst', []), sc.lst('f2undeclst', ds))))
            elif c == 25:
                ds = []
                lens = [R.choice([1, 2]), R.choice([1, 2, 3]), R.choice([1, 2, 3])]
                for i in range(R.choice([2, 3, 3])):
                    v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 90 + i), 'd2var')
                    mets = sc.lst('s2explst', [sc.val(R.choice(['K_s2exp (s2rt_int, K_S2Eint (1))', 'K_s2exp (s2rt_int, K_S2Eint (2))', 'K_s2exp (s2rt_bool, K_S2Eint (1))']), 's2exp') for _ in range(lens[i])])
                    ann = R.choice(['OS_s2expopt (K_s2exp (s2rt_type, K_S2Emetfun (OS_stampopt (d2var_get_stamp (%s)), %s, %s)))' % (v, mets, tys(sc))] * 9 + ['ON_s2expopt ()'])
                    body = rv(sc, e)
                    df = R.choice([sc.val('d2exp_lam_met_new (%s, %s, %s)' % (sc.loc(), mets, body), 'd2exp'),
                                   sc.val('K_d2exp (%s, K_D2Elam_dyn (0, 1, LN_p2atlst (), %s))' % (sc.loc(), sc.val('d2exp_lam_met_new (%s, %s, %s)' % (sc.loc(), mets, body), 'd2exp')), 'd2exp'),
                                   sc.val('K_d2exp (%s, K_D2Elam_sta (%s, LN_s2explst (), %s))' % (sc.loc(), sc.lst('s2varlst', []), sc.val('d2exp_lam_met_new (%s, %s, %s)' % (sc.loc(), mets, body), 'd2exp')), 'd2exp')])
                    ds.append(sc.val('K_f2undec (%s, %s, %s, %s)' % (sc.loc(), v, df, ann), 'f2undec'))
                out.append(D('K_D2Cfundecs (mkfunkind (%d), %s, %s)' % (R.choice([1, 2, 2]), sc.lst('s2qualst', []), sc.lst('f2undeclst', ds))))
            elif c == 17:
                d2c = sc.new('d2cst')
                out.append(D('K_D2Cimpdec (%d, %s)' % (R.randint(0, 2), sc.val('K_i2mpdec (%s, %s, %s, %s, LN_s2explstlst (), LN_s2explstlst (), %s)' % (
                    sc.loc(), sc.loc(), d2c, sc.lst('s2varlst', [sc.val('s2var_make_srt (s2rt_int)', 's2var')]), rv(sc, e)), 'i2mpdec'))))
            elif c == 18: out.append(D('K_D2Cinclude (%d, %s)' % (R.randint(0, 1), sc.lst('d2eclist', decl_ops(sc, e, R.randint(0, 2), depth + 1)))) if depth < 2 else D('K_D2Cnone ()'))
            elif c == 19 and depth < 2:
                body = decl_ops(sc, e, R.randint(0, 2), depth + 1)
                head = decl_ops(sc, e, R.randint(0, 2), depth + 1)
                if R.random() < 0.7:
                    body.append(D('K_D2Csaspdec (%s)' % sc.val('K_s2aspdec (%s, %s, %s)' % (sc.loc(), cst('ON_s2expoptopt ()', 'ON_s2expopt ()'), tys(sc)), 's2aspdec')))
                if R.random() < 0.5:
                    head.append(D('K_D2Csaspdec (%s)' % sc.val('K_s2aspdec (%s, %s, %s)' % (sc.loc(), cst('ON_s2expoptopt ()', 'ON_s2expopt ()'), tys(sc)), 's2aspdec')))
                out.append(D('K_D2Clocal (%s, %s)' % (sc.lst('d2eclist', head), sc.lst('d2eclist', body))))
            elif c == 20 and depth < 2:
                sc.do('g4_setp (6, $UN.cast{ptr} (%s))' % sc.lst('d2eclist', decl_ops(sc, e, R.randint(0, 2), 2)))
                sc.do('g4_fenv_clear ()')
                st = D('K_D2Cstaload (ON_symbolopt (), mkfil (0), %d, mkfilenv (1), %d)' % (R.randint(0, 1), R.randint(0, 1)))
                out.append(st)
                if R.random() < 0.5: out.append(st)   # the second time the declarations are known
            elif c == 21 and depth < 2:
                sc.do('g4_setp (6, $UN.cast{ptr} (%s))' % sc.lst('d2eclist', decl_ops(sc, e, R.randint(0, 2), 2)))
                out.append(D('K_D2Cstaloadloc (mkfil (0), mksym (2), mkfilenv (2))'))
            else: out.append(D('K_D2Cdynload (mkfil (0))'))
        return out
    def metric_group(sc, e):
        """a recursive group whose metrics grow in length and then disagree in the sorts: [int], [int, bool], [int, int]"""
        ds = []
        for i, sorts in enumerate([['int'], ['int', 'bool'], ['int', 'int']]):
            v = sc.val('d2var_make (%s, mksym (%d))' % (sc.loc(), 100 + i), 'd2var')
            mets = sc.lst('s2explst', [sc.val('K_s2exp (s2rt_%s, K_S2Eint (1))' % s, 's2exp') for s in sorts])
            ann = 'OS_s2expopt (K_s2exp (s2rt_type, K_S2Emetfun (OS_stampopt (d2var_get_stamp (%s)), %s, %s)))' % (v, mets, 's2exp_void_t0ype ()')
            df = sc.val('d2exp_lam_met_new (%s, %s, %s)' % (sc.loc(), mets, rv(sc, e)), 'd2exp')
            ds.append(sc.val('K_f2undec (%s, %s, %s, %s)' % (sc.loc(), v, df, ann), 'f2undec'))
        return sc.val('K_d2ecl (%s, K_D2Cfundecs (mkfunkind (2), %s, %s))' % (sc.loc(), sc.lst('s2qualst', []), sc.lst('f2undeclst', ds)), 'd2ecl')
    def fam_decl(sc, k):
        R = sc.R
        e = setup_env(sc)
        if k % 3 == 0:
            sc.dd('d3ecl', 'd2ecl_tr (%s)' % metric_group(sc, e)); sc.do('t3chk ()')
        for rep in range(R.randint(3, 6)):
            knobs(sc) if R.random() < 0.4 else None
            ds = decl_ops(sc, e, R.randint(1, 4))
            if R.random() < 0.5 and ds:
                (sc.dd('d3ecl', 'd2ecl_tr (%s)' % R.choice(ds)), sc.do('t3chk ()'))
            elif R.random() < 0.5:
                sc.dd('d3eclist', 'd2eclist_tr (%s)' % sc.lst('d2eclist', ds)); sc.do('t3chk ()')
            else:
                sc.do('g4_errck (%s)' % sc.lst('d2eclist', ds))
            for v in R.sample(e.xs + e.ys, min(2, len(e.xs + e.ys))): sc.do('chk_d2var (%s)' % v)
        finish_env(sc, e)
    F.append(('decl', fam_decl, 25))

    # ---- the selection of a linear component through a context (the forced knobs): the new type of the view
    def fam_ctx(sc, k):
        R = sc.R
        e = setup_env(sc)
        for rep in range(R.randint(6, 10)):
            sc.do('g4_setk (2, 1)'); sc.do('g4_setk (4, 1)'); sc.do('g4_setk (3, %d)' % R.choice([0, 1])); sc.do('g4_setk (0, %d)' % R.choice([0, 1])); sc.do('g4_setk (1, %d)' % R.choice([0, 1]))
            sc.do('g4_sets2e (0, %s)' % R.choice(['K_s2exp (s2rt_vt0ype, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_vt0ype)', 's2var'), sty(sc, 1), 'K_s2exp (s2rt_view, K_S2Evar (%s))' % sc.val('s2var_make_srt (s2rt_view)', 's2var')]))
            a = R.choice(e.addrs); l3 = d3labs(sc, e)
            c = R.randint(0, 4)
            if c == 0: sc.do('g4_s2addr_deref (%s, %s, %s)' % (sc.loc(), a, l3))
            elif c == 1: sc.do('g4_s2addr_assgn_deref (%s, %s, %s, %s)' % (sc.loc(), a, l3, sc.val('d3exp_top (%s, %s)' % (sc.loc(), tys(sc)), 'd3exp')))
            elif c == 2: sc.do('g4_s2addr_xchng_check (%s, %s, %s, %s, s2exp2hnf (%s))' % (sc.loc(), sc.loc(), a, l3, tys(sc)))
            elif c == 3: sc.dd('s2exp', 's2addr_viewat_deref (%s, %s, %s)' % (sc.loc(), a, l3))
            else: sc.do('g4_s2addr_xchng_deref (%s, %s, %s, %s)' % (sc.loc(), a, l3, rv(sc, e)))
            sc.do('t3chk ()')
            for w in e.xws: sc.do('chk_d2var (%s)' % w)
        finish_env(sc, e)
    F.append(('ctx', fam_ctx, 10))
    return F

# ---------------------------------------------------------------------------------------------------------------------
def write_chunks(chunks):
    put = C.put
    for f in os.listdir(d):
        m = re.match(r'^(?:g4case_|g4case1_|g4cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'g4cases_%02d.hats' % k
        put(os.path.join(d, cases), body)
        put(os.path.join(d, 'g4case_%02d.dats' % k),
            '(* generated by g4_gen.py: the chunk %d of the cases of the group 4 test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "g4case_pre.hats"\n'
            'extern fun g4tc%d_all (): void = "ext#g4tc_%d"\n#include "%s"\nimplement g4tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        put(os.path.join(d, 'g4case1_%02d.dats' % k),
            '(* generated by g4_gen.py: the chunk %d of the cases of the group 4 test (ATS1) *)\n#include "g4case_pre1.hats"\n'
            'extern fun g4tc%d_all (): void = "g4tc_%d"\n#include "%s"\nimplement g4tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun g4tc%d_all (): void = "ext#g4tc_%d"\n' % (k, k))
        ch1.append('extern fun g4tc%d_all (): void = "g4tc_%d"\n' % (k, k))
    call = 'fun g4tc_all (): void = {\n' + ''.join('  val () = g4tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    put(os.path.join(d, 'g4chunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 'g4chunks1.hats'), ''.join(ch1) + call)

def main():
    put = C.put
    # the preambles: those of the t3 test
    for lang, nm in ((2, 't3case_pre.hats'), (1, 't3case_pre1.hats')):
        txt = open(os.path.join(d, nm)).read()
        put(os.path.join(d, 'g4case_pre.hats' if lang == 2 else 'g4case_pre1.hats'), '(* generated by g4_gen.py from %s *)\n' % nm + txt + '#include "%s"\n' % ('g4hand.hats' if lang == 2 else 'g4hand1.hats'))
    put(os.path.join(d, 'g4hand.hats'), t3_gen.expand_hand(2, 't3g4/g4pre.tmpl'))
    put(os.path.join(d, 'g4hand1.hats'), t3_gen.expand_hand(1, 't3g4/g4pre.tmpl'))
    put(os.path.join(d, 'g4env.hats'), t3_gen.expand_hand(2, 't3g4/g4env.tmpl'))
    put(os.path.join(d, 'g4env1.hats'), t3_gen.expand_hand(1, 't3g4/g4env.tmpl'))
    Sc3 = t3_cases.build(G, C)
    F0 = t3_cases.families(G, C, Sc3, t3_gen.D3ORDER, d)
    F = families(Sc3, F0)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = Sc3(G, R, 'g4_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = t3_cases.wrap_text(sc.text())
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1200 or sc.name.startswith('g4_setup'):
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    write_chunks(bodies)
    print('g4_gen: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

if __name__ == '__main__':
    main()
