#!/usr/bin/env python3
# usage: python3 cc1_gen.py   (rewrites cc1_cases_NN.hats, cc1_chunks.hats, cc1_chunks1.hats, cc1_chunk_NN.dats, cc1_chunk1_NN.dats)
#
# Test of the C1 group of the ccomp port (pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}.dats), see PORTING.md, "ccomp group C1".
# Same method as hd_gen.py: ONE generated program of scenarios, written in the common subset of ATS1 and ATS2 (cc1_common.hats + cc1_impl.hats + the language layers
# cc1_lang1.hats / cc1_lang2.hats), is compiled by the ATS2 driver (cc1_drv.dats, with the modules of src) and by the ATS1 driver (cc1_drv1.dats, linked with the
# ATS1 objects of src/); the stdout and the stderr of the two must be identical.
#   env scenarios:    random sequences of the operations of the compilation environment (ccompenv), a model of the stacks keeps them legal
#   environ scenarios: random graphs of functions (funent/funlab): the transitive closures, the environments, the variable bindings
#   comp scenarios:   random trees of erased expressions (case, loop, loopexn, trywith, delay, ldelay, lazyeval) compiled through the doubles of hidexp_ccomp
import os, random, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
SEED = int(os.environ.get('CC1SEED', '1'))
SCALE = int(os.environ.get('CC1SCALE', '1'))
NENV = int(os.environ.get('CC1NENV', '40')); NENVIRON = int(os.environ.get('CC1NENVIRON', '16')); NCOMP = int(os.environ.get('CC1NCOMP', '24'))

class Sc:
    """one scenario = one ATS function sc_<n> (): void"""
    def __init__(self, n, rnd):
        self.n = n; self.r = rnd; self.o = []; self.k = 0
        self.pushes = []          # names of the proofs of the pending ccompenv_push
    def ln(self, s): self.o.append('  ' + s)
    def uid(self, p='x'):
        self.k += 1; return '%s%d' % (p, self.k)
    def val(self, e, p='v'):
        v = self.uid(p); self.ln('val %s = %s' % (v, e)); return v
    def op(self, e): self.ln('val () = %s' % e)
    def text(self):
        return 'fun sc_%d (): void = let\n%s\nin\n  ()\nend // end of [sc_%d]\n' % (self.n, '\n'.join(self.o), self.n)

def pick(r, xs): return xs[r.randrange(len(xs))]

def pools(s, r, n, nfun=6, with_funents=True, maxenv=3):
    """the values of a scenario: d2vars, d2csts, d2cons, hisexps, primvals, tmplabs, d2envs, funlabs (+ funents), hifundecs, hiimpdecs, filenvs, tmpsubs, tmpcstmats, tmpvarmats, .."""
    P = {}
    nd = 6
    P['dv'] = [s.val('mkd2var (%d)' % (10*n+i), 'dv') for i in range(nd)]
    P['dc'] = [s.val('mkd2cst (%d)' % (10*n+i), 'dc') for i in range(3)]
    P['dn'] = [s.val('mkd2con (%d)' % i, 'dn') for i in range(2)]
    P['hse'] = hse = [s.val('mkhse (%d)' % i, 'hs') for i in range(3)]
    for i, v in enumerate(P['dv']):
        s.op('d2var_set_level (%s, %d)' % (v, i % 3))
        s.op('set_dv_hisexp (%s, %s)' % (v, hse[i % 3]))
    P['pv'] = [s.val('primval_int (mkloc (%d), %s, %d)' % (100+i, hse[i % 3], i), 'pv') for i in range(8)]
    P['tl'] = [s.val('tmplab_make (mkloc (%d))' % (200+i), 'tl') for i in range(6)]
    P['de'] = de = [s.val('d2env_make (%s, %s)' % (P['dv'][i], hse[i % 3]), 'de') for i in range(4)]
    fl = []
    for i in range(nfun):
        qo = 'OS_d2cstopt (%s)' % P['dc'][i % 3] if i % 3 == 0 else 'ON_d2cstopt ()'
        so = 'OS_d2varopt (%s)' % P['dv'][i % 6] if i % 3 == 1 else 'ON_d2varopt ()'
        fl.append(s.val('funlab_make ("fl%d_%d", %d, mkhfun (%d), None_vt (), %s, %s, LN_t2mpmarglst (), $STMP.funlab_stamp_make ())' % (n, i, i % 4, i, qo, so), 'fl'))
    P['fl'] = fl
    fe = []
    if with_funents:
        for i in range(nfun):
            d2es = 'LN_d2envlst ()'
            for j in range(r.randrange(0, maxenv + 1)): d2es = 'LC_d2envlst (%s, %s)' % (pick(r, de), d2es)
            fls = 'LN_funlablst ()'
            for j in range(r.randrange(0, 4)): fls = 'LC_funlablst (%s, %s)' % (pick(r, fl), fls)
            vb = s.val('mk_vbmap_nil ()', 'vb')
            s.ln('var %s_m = %s' % (vb, vb))
            for j in range(r.randrange(0, 3)): s.op('vbmap_ins (%s_m, %s, %s)' % (vb, pick(r, P['dv']), pick(r, P['pv'])))
            e = s.val('funent_make (mkloc (%d), %s, LN_s2varlst (), LN_s2explstlst (), ON_tmpsubopt (), tmpvar_make (mkloc (%d), %s), %s, %s, %s_m, LN_instrlst (), LN_tmpvarlst ())' % (300+i, fl[i], 400+i, hse[0], fls, d2es, vb), 'fe')
            s.op('funlab_set_funent (%s, OS_funentopt (%s))' % (fl[i], e))
            fe.append(e)
    P['fe'] = fe
    return P

def gen_env_scenario(n, r, scale):
    s = Sc(n, r)
    s.ln('val () = (dd_ps "=== env scenario %d\\n")' % n)
    P = pools(s, r, n)
    dv, dc, dn, hse, pv, tl, de, fl, fe = [P[k] for k in ('dv', 'dc', 'dn', 'hse', 'pv', 'tl', 'de', 'fl', 'fe')]
    hf = [s.val('hifundec_make (mkloc (%d), %s, LN_s2varlst (), hidexp_int (mkloc (%d), %s, %d))' % (500+i, dv[i], 510+i, hse[0], i), 'hf') for i in range(3)]
    sv = s.val('s2var_make_srt (s2rt_t0ype)', 'sv')
    imp = [s.val('hiimpdec_make (mkloc (%d), %d, %s, LN_s2varlst (), LC_s2explstlst (LC_s2explst (s2exp_var (%s), LC_s2explst (s2exp_int (%d), LN_s2explst ())), LN_s2explstlst ()), hidexp_int (mkloc (%d), %s, %d))' % (520+i, i, dc[i], sv, i, 530+i, hse[0], i), 'im') for i in range(3)]
    fv = [s.val('mkfilenv (%d)' % (n*4+i), 'fv') for i in range(3)]
    # file environments: 0 and 1 with both maps, 2 pervasive (no maps)
    for i in range(2):
        s.op('fenv_set_tcmap (%s, LC_hiimpdeclst (%s, LC_hiimpdeclst (%s, LN_hiimpdeclst ())))' % (fv[i], imp[i], imp[(i+1) % 3]))
        s.op('fenv_set_tvmap (%s, LC_hifundeclst (%s, LC_hifundeclst (%s, LN_hifundeclst ())))' % (fv[i], hf[i], hf[(i+1) % 3]))
    allow_tmpvar = r.randrange(3) > 0
    ts = [s.val('K_tmpsub_nil ()', 'ts')]
    ts.append(s.val('K_tmpsub_cons (s2var_make_srt (s2rt_t0ype), s2exp_int (%d), K_tmpsub_nil ())' % n, 'ts'))
    cm = [s.val('K_tmpcstmat_none ()', 'cm'), s.val('K_tmpcstmat_some (%s, %s, 5)' % (imp[0], ts[1]), 'cm'), s.val('K_tmpcstmat_some2 (%s, LN_s2explstlst (), %s)' % (dc[1], fl[2]), 'cm')]
    vm = [s.val('K_tmpvarmat_none ()', 'vm'), s.val('K_tmpvarmat_some (%s, %s, 6)' % (hf[1], ts[1]), 'vm'), s.val('K_tmpvarmat_some2 (%s, LN_s2explstlst (), %s)' % (dv[2], fl[3]), 'vm')]
    h2 = [s.val('K_hifundec2 (%s, %s)' % (hf[i], ts[i % 2]), 'h2') for i in range(2)]
    i2 = [s.val('K_hiimpdec2 (%s, %s, LN_s2explstlst ())' % (imp[i], ts[i % 2]), 'i2') for i in range(2)]
    hide = [s.val('hidecl_extcode (mkloc (%d), %d, %d, "code%d")' % (600+i, i % 2, (7 * i + 3) % 5, i), 'hi') for i in range(5)]
    s.ln('val env = ccompenv_make ()')
    s.op('p_env (env)')
    S = dict(ld=0, td=0, fd=0, dd=1, fld=1, vd=1)      # the model of the depths of the stacks
    def d2es():
        x = 'LN_d2envlst ()'
        for j in range(r.randrange(0, 4)): x = 'LC_d2envlst (%s, %s)' % (pick(r, de), x)
        return x
    def fls_vt(lo, hi):
        x = 'list_vt_nil ()'
        for j in range(r.randrange(lo, hi)): x = 'list_vt_cons (%s, %s)' % (pick(r, fl), x)
        return x
    def inc(k, d=1):
        def f(): S[k] += d
        return f
    ops = []   # (weight, guard, emitter -> str, effect on the model)
    def add(w, guard, em, eff=None): ops.append((w, guard, em, eff))
    T = lambda: True
    add(2, T, lambda: 'op_tmplevel (env, 1)'); add(1, T, lambda: 'op_tmplevel (env, ~1)')
    add(2, T, lambda: 'op_tmprecdepth (env, 1)'); add(1, T, lambda: 'op_tmprecdepth (env, ~1)')
    add(2, T, lambda: 'op_freeconenv_inc (env)', inc('fd'))
    add(3, lambda: S['fd'] > 0, lambda: pick(r, ['op_freeconenv_add (env, %s)' % pick(r, pv), 'op_freetupenv_add_if (env, %s, mkpckind (%d))' % (pick(r, pv), r.randrange(4)),
        'op_freeconenv_add_if (env, %s, mkpckind (%d), %s)' % (pick(r, pv), r.randrange(4), pick(r, dn))]))
    add(2, lambda: S['fd'] > 0, lambda: 'op_freeconenv_getdec (env)', inc('fd', -1))
    add(3, T, lambda: 'op_loopexn_inc (env, %s, %s, %s)' % (pick(r, tl), pick(r, tl), pick(r, tl)), inc('ld'))
    add(3, lambda: S['ld'] > 0, lambda: pick(r, ['op_loopfini (env)', 'op_loopcont (env)']))
    add(2, lambda: S['ld'] > 0, lambda: 'op_loopexn_dec (env)', inc('ld', -1))
    def fnxlist():
        if r.randrange(2): return fls_vt(0, 4)
        x = 'list_vt_nil ()'
        for j in range(r.randrange(1, 4)): x = 'list_vt_cons (%s, %s)' % (pick(r, [fl[1], fl[4]]), x)
        return x
    add(2, T, lambda: 'op_tailcal_inc_fnx (env, %s)' % fnxlist(), inc('td'))
    def directed2():
        a, b, c = pick(r, fl), pick(r, fl), pick(r, fl)
        return 'op_tailcal_inc_fnx (env, list_vt_cons (%s, list_vt_cons (%s, list_vt_cons (%s, list_vt_nil ()))))\n  val () = op_tailcal_find (env, %s)\n  val () = op_tailcal_find (env, %s)' % (a, b, c, c, b)
    add(2, T, directed2, inc('td'))
    add(3, T, lambda: 'op_tailcal_inc (env, %s)' % pick(r, [fl[0], fl[3], fl[1], fl[4], fl[0], fl[3], fl[1], fl[4], fl[2], fl[5]]), inc('td'))
    add(6, lambda: S['td'] > 0, lambda: pick(r, ['op_tailcal_find (env, %s)' % pick(r, fl), 'op_tailcal_find_cst (env, %s)' % pick(r, dc), 'op_tailcal_find_var (env, %s)' % pick(r, dv),
        'op_tailcal_find_tmpcst (env, %s)' % pick(r, dc), 'op_tailcal_find_tmpvar (env, %s)' % pick(r, dv),
        'op_tailcal_find_var (env, %s)' % pick(r, [dv[1], dv[4]]), 'op_tailcal_find_cst (env, %s)' % dc[0], 'op_tailcal_find_tmpcst (env, %s)' % dc[0],
        'op_tailcal_find_tmpvar (env, %s)' % pick(r, [dv[1], dv[4]])]))
    add(2, lambda: S['td'] > 0, lambda: 'op_tailcal_dec (env)', inc('td', -1))
    add(1, T, lambda: 'op_dvarset_inc (env)', inc('dd'))
    add(1, T, lambda: 'op_dvarset_incwth (env, %s)' % d2es(), inc('dd'))
    add(4, T, lambda: pick(r, ['op_dvarset_add_var (env, %s)' % pick(r, dv), 'op_dvarset_add_env (env, %s)' % pick(r, de),
        'op_dvarset_addlst_if (env, %d, %s)' % (r.randrange(3), d2es()), 'op_dvarset_add_tempenver (env, %s)' % pick(r, de)]))
    add(2, lambda: S['dd'] > 1, lambda: 'op_dvarset_getdec (env)', inc('dd', -1))
    add(2, T, lambda: 'op_flabset_inc (env)', inc('fld'))
    add(3, T, lambda: 'op_flabset_add (env, %s)' % pick(r, fl))
    add(2, lambda: S['fld'] > 1, lambda: 'op_flabset_getdec (env)', inc('fld', -1))
    def ifmap():
        vb = s.val('mk_vbmap_nil ()', 'vb')
        s.ln('var %s_m = %s' % (vb, vb))
        for j in range(r.randrange(0, 3)): s.op('vbmap_ins (%s_m, %s, %s)' % (vb, pick(r, dv), pick(r, pv)))
        return 'op_flabset_addlst_ifmap (env, %d, %s_m, %s)' % (r.randrange(0, 4), vb, fls_vt(1, 4))
    add(4, T, ifmap)
    add(2, T, lambda: 'op_vbindmapenv_inc (env)', inc('vd'))
    add(3, T, lambda: pick(r, ['op_vbindmapenv_add (env, %s, %s)' % (pick(r, dv), pick(r, pv)), 'op_vbindmapenv_find (env, %s)' % pick(r, dv)]))
    add(2, lambda: S['vd'] > 1, lambda: 'op_vbindmapenv_getdec (env)', inc('vd', -1))
    def push():
        nm = s.uid('pf'); s.ln('val (%s | ()) = op_push (env)' % nm); s.pushes.append(nm); return None
    add(4, T, push)
    def pop():
        nm = s.pushes.pop(); s.ln('val () = op_pop (%s | env)' % nm); return None
    add(3, lambda: len(s.pushes) >= 1, pop)
    def lj():
        a = s.pushes.pop(); b = s.pushes.pop(); s.ln('val () = op_localjoin (%s, %s | env)' % (b, a)); return None
    add(4, lambda: len(s.pushes) >= 2, lj)
    add(4, T, lambda: pick(r, ['op_vbindmapall_add (env, %s, %s)' % (pick(r, dv), pick(r, pv)), 'op_vbindmapall_find (env, %s)' % pick(r, dv),
        'op_vbindmapenvall_add (env, %s, %s)' % (pick(r, dv), pick(r, pv))]))
    add(2, T, lambda: 'op_add_tmpsub (env, %s)' % pick(r, ts))
    add(2, T, lambda: 'op_add_fundec (env, %s)' % pick(r, hf))
    add(2, T, lambda: 'op_add_fundec2 (env, %s)' % pick(r, h2))
    add(2, T, lambda: 'op_add_impdec (env, %s)' % pick(r, imp))
    add(2, T, lambda: 'op_add_impdec2 (env, %s)' % pick(r, i2))
    add(2, T, lambda: 'op_add_staload (env, %s)' % pick(r, fv[:2] if allow_tmpvar else fv))
    add(2, T, lambda: 'op_add_impdecloc (env, %s, %s, %d)' % (pick(r, imp), sv, r.randrange(100)))
    def directed():
        k = r.randrange(3)
        return 'op_add_impdec (env, %s)\n  val () = op_add_staload (env, %s)\n  val () = op_tmpcst_match (env, %s)' % (imp[k], pick(r, fv[:2] if allow_tmpvar else fv), dc[k])
    add(2, T, directed)
    add(2, T, lambda: 'op_add_fundecsloc (env, %s, LC_hifundeclst (%s, LC_hifundeclst (%s, LN_hifundeclst ())))' % (pick(r, ['LN_s2qualst ()', 'LC1_s2qualst ()']), pick(r, hf), pick(r, hf)))
    add(2, T, lambda: 'op_add_tmpcstmat (env, %s)' % pick(r, cm))
    add(2, T, lambda: 'op_add_tmpvarmat (env, %s)' % pick(r, vm))
    add(4, T, lambda: 'op_tmpcst_match (env, %s)' % pick(r, dc))
    add(3, lambda: allow_tmpvar, lambda: 'op_tmpvar_match (env, %s)' % pick(r, dv))
    def tempenver():
        vs = 'LN_d2varlst ()'
        for j in range(r.randrange(0, 4)): vs = 'LC_d2varlst (%s, %s)' % (pick(r, dv), vs)
        return 'op_add_tempenver (env, %s)' % vs
    add(2, T, tempenver)
    add(3, T, lambda: pick(r, ['op_get_tempenver (env)', 'op_get2_tempenver (env)']))
    def thelst():
        e = 'op_the_lst_add (%d, %s)' % (r.randrange(6), pick(r, hide))
        if r.randrange(3) == 0: e = e + '\n  val () = op_the_lst_get (%d)' % r.randrange(6)
        return e
    add(3, T, thelst)
    def extcodes():
        n = r.randrange(2, 7)
        e = ''
        for j in range(n):
            e += 'op_the_lst_add (3, %s)\n  val () = ' % s.val('hidecl_extcode (mkloc (%d), %d, %d, "xc%d")' % (650 + j, r.randrange(2), r.randrange(4), j), 'hx')
        return e + 'op_the_lst_get (3)'
    add(2, T, extcodes)
    nstep = (60 + r.randrange(40)) * scale
    for step in range(nstep):
        av = [o for o in ops if o[1]()]
        tot = sum(o[0] for o in av)
        x = r.randrange(tot)
        for o in av:
            if x < o[0]: break
            x -= o[0]
        e = o[2]()
        if e is not None: s.op(e)
        if o[3]: o[3]()
        s.op('p_env (env)')
    # drain (some scenarios free the environment with the stacks not empty)
    nodrain = r.randrange(3) == 0
    while s.pushes:
        nm = s.pushes.pop(); s.ln('val () = op_pop (%s | env)' % nm); s.op('p_env (env)')
    for k in range(6): s.op('op_the_lst_get (%d)' % k)
    while S['fd'] > 0 and not nodrain: s.op('op_freeconenv_getdec (env)'); S['fd'] -= 1
    while S['dd'] > 0 and not nodrain: s.op('op_dvarset_getdec (env)'); S['dd'] -= 1
    while S['fld'] > 0 and not nodrain: s.op('op_flabset_getdec (env)'); S['fld'] -= 1
    while S['vd'] > 0 and not nodrain: s.op('op_vbindmapenv_getdec (env)'); S['vd'] -= 1
    s.op('p_env (env)')
    s.op('ccompenv_free (env)')
    return s

def gen_environ_scenario(n, r, scale):
    s = Sc(n, r)
    s.ln('val () = (dd_ps "=== environ scenario %d\\n")' % n)
    P = pools(s, r, n, nfun=7, maxenv=4)
    dv, dc, hse, pv, de, fl, fe = [P[k] for k in ('dv', 'dc', 'hse', 'pv', 'de', 'fl', 'fe')]
    # the funlabs of the "fnx" groups
    for i in range(len(fe)):
        if r.randrange(3) == 0:
            fls = 'LN_funlablst ()'
            for j in range(r.randrange(1, 4)): fls = 'LC_funlablst (%s, %s)' % (pick(r, fl), fls)
            s.op('funent_set_fnxlablst (%s, %s)' % (fe[i], fls))
    for step in range(int((40 + r.randrange(30)) * scale)):
        k = r.randrange(12)
        i = r.randrange(len(fe))
        if k < 3: s.op('op_eval_flablst (%s)' % fe[i])
        elif k < 6: s.op('op_eval_d2envlst (%s)' % fe[i])
        elif k < 8: s.op('op_envful (%s)' % fl[i])
        elif k < 9: s.op('op_fullarg (%s)' % fl[i])
        elif k < 10:
            s.op('op_vbmap_init (%s)' % fe[i])
            for j in range(3): s.op('op_vbmap_find (%s)' % pick(r, dv))
            if r.randrange(2): s.op('op_vbmap_uninit (%s)' % fe[i]); s.op('op_vbmap_find (%s)' % pick(r, dv))
        elif k < 11:
            s.op('op_vbmap_init2 (%s)' % fe[i])
            for j in range(3): s.op('op_vbmap_find (%s)' % pick(r, dv))
            if r.randrange(2): s.op('op_vbmap_uninit (%s)' % fe[i])
        else:
            if r.randrange(2): s.op('op_funlablst_add (%s)' % pick(r, fl))
            else:
                x = 'LN_funlablst ()'
                for j in range(r.randrange(0, 4)): x = 'LC_funlablst (%s, %s)' % (pick(r, fl), x)
                s.op('op_funlablst_addlst (%s)' % x)
            if r.randrange(3) == 0: s.op('op_funlablst_get ()')
    s.op('op_vbmap_uninit (%s)' % fe[0])
    return s

def gen_tree(s, r, P, depth, inloop, ids):
    """a random erased expression (the name of a value of the scenario)"""
    hse = P['hse']; dv = P['dv']
    def loc(): return 'mkloc (%d)' % (700 + r.randrange(1000))
    def hs(): return pick(r, hse)
    def leaf():
        if inloop and r.randrange(4) == 0: return s.val('hidexp_loopexn (%s, %s, %d)' % (loc(), hs(), r.randrange(2)), 'hd')
        if r.randrange(3) == 0: return s.val('hidexp_var (%s, %s, %s)' % (loc(), hs(), pick(r, dv[:4])), 'hd')
        return s.val('hidexp_int (%s, %s, %d)' % (loc(), hs(), r.randrange(10)), 'hd')
    if depth <= 0 or r.randrange(6) == 0: return leaf()
    k = r.randrange(9)
    def sub(il=None, dp=None): return gen_tree(s, r, P, depth - 1 if dp is None else dp, inloop if il is None else il, ids)
    def clauses(il=None):
        cs = 'LN_hiclaulst ()'
        for j in range(r.randrange(1, 4)):
            body = sub(il)
            hp = s.val('hipat_any (%s, %s, %s)' % (loc(), hs(), pick(r, dv)), 'hp')
            cl = s.val('hiclau_make (%s, LC_hipatlst (%s, LN_hipatlst ()), LN_higmatlst (), %d, %d, %s)' % (loc(), hp, r.randrange(2), r.randrange(2), body), 'hc')
            cs = 'LC_hiclaulst (%s, %s)' % (cl, cs)
        return cs
    if k == 0:   # case
        hdes = 'LN_hidexplst ()'
        for j in range(r.randrange(0, 3)): hdes = 'LC_hidexplst (%s, %s)' % (sub(), hdes)
        cs = clauses()
        return s.val('hidexp_case (%s, %s, mkcaskind (%d), %s, %s)' % (loc(), hs(), r.randrange(3), hdes, cs), 'hd')
    if k == 1 or k == 2:   # loop
        init = 'OS_hidexpopt (%s)' % sub(False) if r.randrange(2) else 'ON_hidexpopt ()'
        test = sub(True); post = 'OS_hidexpopt (%s)' % sub(True) if r.randrange(2) else 'ON_hidexpopt ()'
        body = sub(True)
        return s.val('hidexp_loop (%s, %s, %s, %s, %s, %s)' % (loc(), hs(), init, test, post, body), 'hd')
    if k == 3:   # trywith
        t = sub(); cs = clauses()
        return s.val('hidexp_trywith (%s, %s, %s, %s)' % (loc(), hs(), t, cs), 'hd')
    if k == 4:   # delay (inside a delay the loops of the outside are still on the stack: the functions are compiled in place)
        return s.val('hidexp_delay (%s, %s, %s)' % (loc(), hs(), sub()), 'hd')
    if k == 5:
        a = sub(); b = sub()
        return s.val('hidexp_ldelay (%s, %s, %s, %s)' % (loc(), hs(), a, b), 'hd')
    if k == 6:
        return s.val('hidexp_lazyeval (%s, %s, %d, %s)' % (loc(), hs(), r.randrange(2), sub()), 'hd')
    return leaf()

def gen_comp_scenario(n, r, scale):
    s = Sc(n, r)
    s.ln('val () = (dd_ps "=== comp scenario %d\\n")' % n)
    P = pools(s, r, n, nfun=4, with_funents=False)
    dv, hse, pv, fl = [P[k] for k in ('dv', 'hse', 'pv', 'fl')]
    for i in range(8): s.op('dbl_dv_set (%d, %s)' % (i, dv[i % 6]))
    s.ln('val env = ccompenv_make ()')
    s.op('cc1_setlev (%d)' % r.randrange(0, 3))
    if r.randrange(2): s.op('op_tmplevel (env, 1)')
    if r.randrange(3) == 0: s.op('op_tmprecdepth (env, 1)')
    for i in range(3): s.op('op_vbindmapall_add (env, %s, %s)' % (dv[i], pv[i]))
    s.op('p_env (env)')
    ntree = int((3 + r.randrange(4)) * scale)
    for t in range(ntree):
        tree = gen_tree(s, r, P, 3 + r.randrange(3), False, None)
        if r.randrange(4) == 0:
            tmp = s.val('tmpvar_make_ret (mkloc (%d), %s)' % (800+t, pick(r, hse)), 'tm')
            s.op('op_comp_ret (env, %s, %s)' % (tmp, tree))
        else:
            s.op('op_comp (env, %s)' % tree)
        if r.randrange(2): s.op('op_funlablst_get ()')
        if r.randrange(3) == 0: s.op('op_vbindmapall_find (env, %s)' % pick(r, dv))
        if r.randrange(3) == 0: s.op('op_loopexn_inc (env, %s, %s, %s)' % (pick(r, P['tl']), pick(r, P['tl']), pick(r, P['tl'])))
        s.op('p_env (env)')
    s.op('op_toplevel_cells (mkloc (1), tmpvar_make (mkloc (2), %s), %d)' % (hse[0], 1 + r.randrange(3)))
    s.op('op_dyncstlst_add (%s)' % P['dc'][0]); s.op('op_dyncstlst_add (%s)' % P['dc'][1]); s.op('op_dyncstlst_add (%s)' % P['dc'][0]); s.op('op_dyncstlst_get ()')
    s.op('op_dynconlst_add (%s)' % P['dn'][0]); s.op('op_dynconlst_add (%s)' % P['dn'][1]); s.op('op_dynconlst_add (%s)' % P['dn'][0]); s.op('op_dynconlst_get ()')
    s.op('ccompenv_free (env)')
    return s

def main():
    r = random.Random(SEED)
    scs = []
    n = 0
    for i in range(NENV):
        n += 1; scs.append(gen_env_scenario(n, r, SCALE))
    for i in range(NENVIRON):
        n += 1; scs.append(gen_environ_scenario(n, r, SCALE))
    for i in range(NCOMP):
        n += 1; scs.append(gen_comp_scenario(n, r, SCALE))
    nchunk = 8
    chunks = [[] for _ in range(nchunk)]
    for i, s in enumerate(scs): chunks[i % nchunk].append(s)
    ch2 = []; ch1 = []
    for ci, ch in enumerate(chunks):
        body = '\n'.join(s.text() for s in ch) + '\nfun tc_body (): void = let val k = cc1_getonly () in\n' + ''.join('  (if k = 0 || k = %d then sc_%d ());\n' % (s.n, s.n) for s in ch) + '  ()\nend\n'
        put(os.path.join(d, 'cc1_cases_%02d.hats' % ci), body)
        put(os.path.join(d, 'cc1_chunk_%02d.dats' % ci),
            '(* generated by cc1_gen.py: the chunk %d of the scenarios of the C1 test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "cc1_pre.hats"\n'
            'extern fun tc_all_%d (): void = "ext#cc1tc_%d"\n#include "cc1_cases_%02d.hats"\nimplement tc_all_%d () = tc_body ()\n' % (ci, ci, ci, ci, ci))
        put(os.path.join(d, 'cc1_chunk1_%02d.dats' % ci),
            '(* generated by cc1_gen.py: the chunk %d of the scenarios of the C1 test (ATS1) *)\n#include "cc1_pre1.hats"\n'
            'extern fun tc_all_%d (): void = "cc1tc_%d"\n#include "cc1_cases_%02d.hats"\nimplement tc_all_%d () = tc_body ()\n' % (ci, ci, ci, ci, ci))
        ch2.append('extern fun tc_all_%d (): void = "ext#cc1tc_%d"\n' % (ci, ci))
        ch1.append('extern fun tc_all_%d (): void = "cc1tc_%d"\n' % (ci, ci))
    call = 'fun tc_all (): void = (%s)\n' % '; '.join('tc_all_%d ()' % k for k in range(nchunk))
    put(os.path.join(d, 'cc1_chunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 'cc1_chunks1.hats'), ''.join(ch1) + call)
    print('cc1_gen: %d scenarios, %d chunks, %d lines' % (len(scs), nchunk, sum(s.text().count('\n') for s in scs)))

def put(path, text):
    if os.path.exists(path) and open(path).read() == text: return
    open(path, 'w').write(text)

if __name__ == '__main__': main()
