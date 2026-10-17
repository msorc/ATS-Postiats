# the generator of the cases of the macro test (called by m2_gen.py, see there and PORTING.md "Macros (dmacro2)")
#
# A scenario builds level-2 dynamic expressions (the smart constructors of pats_dynexp2.sats and the wrappers K_x of the compat layers of
# d2_gen.py), macros (d2mac), evaluation contexts (evalctx) and environments (alphenv), runs the evaluator of pats_dmacro2{,_eval0,_eval1}
# (eval0_d2exp, eval1_d2exp, eval0_app_mac_long/short, dmacro_eval_decode/xstage/app_short, liftval2dexp, the printers, ...) and dumps
# every result completely. The text is the common subset of ATS1 and ATS2. M2SEED / M2SCALE (the environment) set the seed and the size.
import os, random, re, sys
sys.dont_write_bytecode = True
import d2_cases as C

SEED = int(os.environ.get('M2SEED', '1'))
SCALE = float(os.environ.get('M2SCALE', '1'))

# the p2at nodes that eval1_p2at supports (the others abort the program: see the exit scenarios)
SUP_P2T = ['P2Tany', 'P2Tvar', 'P2Tcon', 'P2Tint', 'P2Tintrep', 'P2Tbool', 'P2Tchar', 'P2Tfloat', 'P2Tstring', 'P2Ti0nt', 'P2Tf0loat',
           'P2Tempty', 'P2Tlst', 'P2Trec', 'P2Tann']
BINOPS = ['+', '-', '*', '<', '<=', '>', '>=', '=', '<>', '!=']
MACFUNS = ['car', 'cdr', 'isnil', 'iscons', 'islist']

class MSc(C.Sc):
    # ------------------------------------------------------------------ the generic generator (restricted)
    def datatype(self, t, d):
        G = self.G; R = self.R
        cons = G.types[t]
        names = [c for c, ts in cons]
        if t == 's2exp_node' and not self.fulls2: names = [c for c in names if c in C.SAFE_S2E]
        if t == 'p2at_node': names = [c for c in names if c in SUP_P2T]
        if d <= 0 and t in C.TERM:
            names = [c for c in C.TERM[t] if c in names] or names
        if t == 'tyreckind': names = C.TERM['tyreckind']
        c = R.choice(names)
        ts = dict(cons)[c]
        return 'K_%s (%s)' % (c, ', '.join(self.carg(t, c, i, at, d) for i, at in enumerate(ts)))
    def new_d2mac(self):
        # a macro whose argument list is empty (an application of it to arguments is an arity error, never a MatchError)
        R = self.R
        return self.val('d2mac_make (%s, %s, %d, LN_m2acarglst (), %s)' % (
            self.leaf('location'), self.leaf('symbol'), R.choice([0, 1]), self.gv('d2exp', 1)), 'd2mac')
    # ------------------------------------------------------------------ small constructors (strings of ATS)
    def L(self): return 'mkloc (%d)' % self.R.randint(0, 20)
    def dv(self, name=None):
        return self.val('d2var_make (%s, %s)' % (self.L(), 'mksym (%d)' % self.R.randint(0, 6)), 'd2var')
    def sv(self):
        return self.val('s2var_make_id_srt (mksym (%d), s2rt_t0ype)' % self.R.randint(0, 6), 's2var')
    def dlist(self, es): return self.lst('d2explst', es)
    def dyn(self, es, npf=None):
        return 'K_D2EXPARGdyn (%d, %s, %s)' % (self.R.choice([0, 0, 1]) if npf is None else npf, self.L(), self.dlist(es))
    def sta(self, s2es, shape='seq'):
        if shape == 'seq': a = 'K_s2exparg (%s, K_S2EXPARGseq (%s))' % (self.L(), self.lst('s2explst', s2es))
        elif shape == 'one': a = 'K_s2exparg (%s, K_S2EXPARGone ())' % self.L()
        else: a = 'K_s2exparg (%s, K_S2EXPARGall ())' % self.L()
        return a
    def stag(self, shapes):
        """a static argument group: a list of s2exparg given as pairs (shape, s2es)"""
        return 'K_D2EXPARGsta (%s, %s)' % (self.L(), self.lst('s2exparglst', [self.sta(s, sh) for sh, s in shapes]))
    def app(self, f, groups): return 'd2exp_applst (%s, %s, %s)' % (self.L(), f, self.lst('d2exparglst', groups))
    def sym(self, name, q=False): return 'd2exp_sym (%s, %s (%s, "%s"))' % (self.L(), 'mkdsymq' if q else 'mkdsym', self.L(), name)
    def op(self, name, es, q=False): return self.app(self.sym(name, q), [self.dyn(es)])
    def var(self, v): return 'd2exp_var (%s, %s)' % (self.L(), v)
    def num(self, i): return 'd2exp_int (%s, %d)' % (self.L(), i)
    def mac(self, m): return 'd2exp_mac (%s, %s)' % (self.L(), m)
    def macapp(self, m, groups): return self.app(self.mac(m), groups)
    def macsyn(self, k, e): return 'd2exp_macsyn (%s, mkmacsynkind (%d), %s)' % (self.L(), k, e)
    def quote(self, e): return self.macsyn(0, e)        # encode
    def unquote(self, e): return self.macsyn(1, e)      # decode  ,( )
    def xstage(self, e): return self.macsyn(2, e)       # xstage  %( )
    def macfun(self, name, es): return 'd2exp_macfun (%s, $SYM.symbol_make_string ("%s"), %s)' % (self.L(), name, self.dlist(es))
    def ifh(self, c, t, e=None):
        return 'd2exp_ifhead (%s, i2nvresstate_nil, %s, %s, %s)' % (self.L(), c, t, 'ON_d2expopt ()' if e is None else 'OS_d2expopt (%s)' % e)
    def mkmac(self, kind, groups, body, name=None):
        """groups: a list of ('d', [d2var]) / ('s', [s2var])"""
        gs = []
        for k, vs in groups:
            if k == 'd': gs.append('K_M2ACARGdyn (%s)' % self.lst('d2varlst', vs))
            else: gs.append('K_M2ACARGsta (%s)' % self.lst('s2varlst', vs))
        return self.val('d2mac_make (%s, %s, %d, %s, %s)' % (self.L(), name or 'mksym (%d)' % self.R.randint(0, 6), kind, self.lst('m2acarglst', gs), body))
    # ------------------------------------------------------------------ the runs
    def ctxs(self, binds):
        s = ''
        for k, v, x in binds:
            s += ' val () = ctx := evalctx_%sadd (ctx, %s, %s)' % (k, v, x)
        return s
    def pre(self, binds=(), env=''):
        return 'var ctx = evalctx_nil ()%s var env = alphenv_nil ()%s' % (self.ctxs(binds), env)
    POST = ' val () = alphenv_free env val () = evalctx_free ctx'
    def mark(self, what):
        self.mk = getattr(self, 'mk', 0) + 1
        self.say('@%s %d' % (what, self.mk))
    def ev0(self, e, binds=(), loc=None, show=False):
        self.mark('ev0')
        self.do('{ %s val r = eval0_d2exp (%s, ctx, env, %s) val () = (dd_m2val r; dd_nl ())%s%s }' % (
            self.pre(binds), loc or self.L(), e, ' val () = (print_m2val r; print_newline ()) val () = (prerr_m2val r; prerr_newline ())' if show else '', self.POST))
        self.do('t3chk ()')
    def ev1(self, e, binds=(), loc=None, env=''):
        self.mark('ev1')
        self.do('{ %s val r = eval1_d2exp (%s, ctx, env, %s) val () = (dd_d2exp r; dd_nl ())%s }' % (
            self.pre(binds, env), loc or self.L(), e, self.POST))
        self.do('t3chk ()')
    def mlong(self, m, groups, binds=()):
        self.mark('mlong')
        self.do('{ %s val r = eval0_app_mac_long (%s, %s, ctx, env, %s) val () = (dd_m2val r; dd_nl ())%s }' % (
            self.pre(binds), self.L(), m, self.lst('d2exparglst', groups), self.POST))
        self.do('t3chk ()')
    def mshort(self, m, groups, binds=()):
        self.mark('mshort')
        self.do('{ %s val r = eval0_app_mac_short (%s, %s, ctx, env, %s) val () = (dd_d2exp r; dd_nl ())%s }' % (
            self.pre(binds), self.L(), m, self.lst('d2exparglst', groups), self.POST))
        self.do('t3chk ()')
    # ------------------------------------------------------------------ values
    def m2v(self, d=1):
        R = self.R
        c = R.random()
        if c < 0.25: return 'K_M2Vint (%d)' % R.choice([0, 1, 2, 3, 5, -1, 7, 10, 100])
        if c < 0.32: return 'K_M2Vbool (%s)' % R.choice(['true', 'false'])
        if c < 0.38: return 'K_M2Vchar (mkchr (%d))' % R.randint(0, 3)
        if c < 0.44: return 'K_M2Vfloat ("%s")' % R.choice(['3.14', '2.0'])
        if c < 0.52: return 'K_M2Vstring ("s%d")' % R.randint(0, 3)
        if c < 0.57: return 'K_M2Vunit ()'
        if c < 0.64: return 'K_M2Vscode (%s)' % self.gv('s2exp', 1)
        if c < 0.74: return 'K_M2Vdcode (%s)' % self.gv('d2exp', 1)
        if c < 0.78: return 'K_M2Verr ()'
        if d <= 0: return 'K_M2Vint (1)'
        n = R.choice([0, 1, 2, 3])
        return 'K_M2Vlist (%s)' % self.mlist([self.m2v(d - 1) for _ in range(n)])
    def mlist(self, xs):
        e = 'LN_m2valist ()'
        for x in reversed(xs): e = 'LC_m2valist (%s, %s)' % (x, e)
        return e
    def intlit(self):
        R = self.R
        c = R.random()
        if c < 0.5: return self.num(R.choice([0, 1, 2, 3, 5, -1, 7, 10]))
        if c < 0.75: return 'd2exp_i0nt (%s, mki0nt (%d))' % (self.L(), R.randint(0, 5))
        return self.num(R.randint(0, 9))
    def lit(self):
        R = self.R
        return R.choice([
            lambda: self.num(R.randint(-3, 9)),
            lambda: 'd2exp_char (%s, mkchr (%d))' % (self.L(), R.randint(0, 3)),
            lambda: 'd2exp_float (%s, "%s")' % (self.L(), R.choice(['3.14', '2.0'])),
            lambda: 'd2exp_string (%s, "s%d")' % (self.L(), R.randint(0, 3)),
            lambda: 'd2exp_i0nt (%s, mki0nt (%d))' % (self.L(), R.randint(0, 5)),
            lambda: 'd2exp_c0har (%s, mkc0har (%d))' % (self.L(), R.randint(0, 5)),
            lambda: 'd2exp_f0loat (%s, mkf0loat (%d))' % (self.L(), R.randint(0, 5)),
            lambda: 'd2exp_s0tring (%s, mks0tring (%d))' % (self.L(), R.randint(0, 5)),
            lambda: 'd2exp_empty (%s)' % self.L(),
            lambda: 'd2exp_bool (%s, %s)' % (self.L(), R.choice(['true', 'false'])),
        ])()

# ====================================================================================================================
# the expression grammar of the long form (eval0): typed random terms
def g0(sc, d, want, scope):
    """an expression of the code level (evaluated by eval0) that yields a value of the kind [want] (int/bool/code/list/any);
    [scope]: dict kind -> [d2var] of variables bound to such values by the caller"""
    R = sc.R
    bad = R.random() < 0.06     # an ill-typed operand
    if want == 'any': want = R.choice(['int', 'int', 'bool', 'code', 'str'])
    vs = scope.get(want, [])
    if d <= 0 or R.random() < 0.2:
        if vs and R.random() < 0.6 and not bad: return sc.var(R.choice(vs))
        if want == 'int': return sc.intlit() if not bad else sc.lit()
        if want == 'bool': return sc.op(R.choice(['<', '=', '>=']), [sc.intlit(), sc.intlit()])
        if want == 'code': return sc.quote(sc.leafcode(scope))
        if want == 'str': return 'd2exp_string (%s, "s%d")' % (sc.L(), R.randint(0, 3))
        if want == 'list': return sc.var(R.choice(scope['list'])) if scope.get('list') else sc.lit()
    c = R.random()
    if want == 'int':
        if c < 0.4: return sc.op(R.choice(['+', '-', '*']), [g0(sc, d - 1, 'int', scope), g0(sc, d - 1, 'int', scope)])
        if c < 0.6: return sc.ifh(g0(sc, d - 1, 'bool', scope), g0(sc, d - 1, 'int', scope), g0(sc, d - 1, 'int', scope) if R.random() < 0.8 else None)
        if c < 0.7: return 'd2exp_sing (%s, %s)' % (sc.L(), g0(sc, d - 1, 'int', scope))
        if c < 0.8 and scope.get('list'): return sc.macfun('car', [sc.var(R.choice(scope['list']))])
        return sc.op(R.choice(['+', '*']), [sc.intlit(), g0(sc, d - 1, 'any', scope)])
    if want == 'bool':
        if c < 0.5: return sc.op(R.choice(BINOPS[3:]), [g0(sc, d - 1, 'int', scope), g0(sc, d - 1, 'int', scope)])
        if c < 0.7 and scope.get('list'): return sc.macfun(R.choice(['isnil', 'iscons', 'islist']), [sc.var(R.choice(scope['list']))])
        if c < 0.85: return sc.ifh(g0(sc, d - 1, 'bool', scope), g0(sc, d - 1, 'bool', scope), g0(sc, d - 1, 'bool', scope))
        return sc.macfun(R.choice(['islist', 'isnil']), [g0(sc, d - 1, 'any', scope)])
    if want == 'code':
        if c < 0.5: return sc.quote(sc.leafcode(scope))
        if c < 0.7: return sc.quote(sc.op('+', [sc.leafcode(scope), sc.unquote(g0(sc, d - 1, 'code', scope))]))
        if c < 0.85: return sc.ifh(g0(sc, d - 1, 'bool', scope), g0(sc, d - 1, 'code', scope), g0(sc, d - 1, 'code', scope))
        return sc.quote(sc.xstage(g0(sc, d - 1, 'int', scope)))
    if want == 'str':
        return 'd2exp_string (%s, "s%d")' % (sc.L(), R.randint(0, 3))
    return sc.lit()

def leafcode(sc, scope):
    R = sc.R
    c = R.random()
    if c < 0.4: return sc.num(R.randint(0, 9))
    if c < 0.7 and scope.get('dcode'): return sc.unquote(sc.var(R.choice(scope['dcode'])))
    if c < 0.85: return sc.var(sc.pool['d2var'][0]) if sc.pool.get('d2var') else sc.num(1)
    return 'd2exp_string (%s, "c")' % sc.L()
MSc.leafcode = leafcode

# ====================================================================================================================
def newscope(sc, ni=2, nb=1, nl=1, nc=1):
    scope = {'int': [], 'bool': [], 'list': [], 'dcode': [], 'code': []}
    binds = []
    for _ in range(ni):
        v = sc.dv(); scope['int'].append(v); binds.append(('d', v, 'K_M2Vint (%d)' % sc.R.choice([0, 1, 2, 3, 5, 10])))
    for _ in range(nb):
        v = sc.dv(); scope['bool'].append(v); binds.append(('d', v, 'K_M2Vbool (%s)' % sc.R.choice(['true', 'false'])))
    for _ in range(nl):
        v = sc.dv(); scope['list'].append(v)
        binds.append(('d', v, 'K_M2Vlist (%s)' % sc.mlist(['K_M2Vint (%d)' % sc.R.randint(0, 5) for _ in range(sc.R.choice([0, 1, 2, 3]))])))
    for _ in range(nc):
        v = sc.dv(); scope['dcode'].append(v); scope['code'].append(v)
        binds.append(('d', v, 'K_M2Vdcode (%s)' % sc.gv('d2exp', 1)))
    return scope, binds

# ---------------------------------------------------------------- the families
def fam_lit(sc, k):
    """eval0 of the literals, variables (bound and unbound), singletons, the unsupported forms; liftval2dexp; the printers"""
    R = sc.R
    v1 = sc.dv(); v2 = sc.dv()
    binds = [('d', v1, sc.m2v(2))]
    es = [sc.lit() for _ in range(6)]
    es += [sc.var(v1), sc.var(v2), 'd2exp_sing (%s, %s)' % (sc.L(), sc.lit()), 'd2exp_sing (%s, %s)' % (sc.L(), sc.var(v1))]
    es += [sc.gv('d2exp', 2) for _ in range(5)]
    for e in es:
        sc.ev0(e, binds, show=R.random() < 0.3)
    # the integer tokens of every shape (the conversion of the representation)
    for rep in ('0', '12', '2147483647', '2147483648', '9999999999', '0x1f', '010', '4294967297'):
        sc.ev0('d2exp_i0nt (%s, mki0nt_rep (%s, "%s"))' % (sc.L(), sc.L(), rep))
    # the ill-formed applications
    sc.ev0(sc.app(sc.num(1), [sc.dyn([sc.num(2)])]))
    sc.ev0(sc.app(sc.var(v1), [sc.dyn([sc.num(2)])]), binds)
    sc.ev0(sc.op('+', [sc.num(1), sc.num(2)], q=True))        # a qualified symbol
    sc.ev0(sc.op('foo', [sc.num(1), sc.num(2)]))              # an unknown symbol
    sc.ev0(sc.op('+', [sc.num(1), sc.num(2)]), loc='mkloc (%d)' % R.randint(0, 20))

def fam_ops(sc, k):
    """the 10 binary operators on every pair of operand kinds, and the numbers of arguments"""
    R = sc.R
    v = sc.dv()
    binds = [('d', v, 'K_M2Vint (4)')]
    kinds = [lambda: sc.num(R.randint(-2, 9)), lambda: sc.intlit(), lambda: sc.var(v), lambda: 'd2exp_char (%s, mkchr (1))' % sc.L(),
             lambda: 'd2exp_string (%s, "x")' % sc.L(), lambda: sc.quote(sc.num(1)), lambda: sc.var(sc.dv())]
    for op in BINOPS:
        pairs = [(i, j) for i in range(len(kinds)) for j in range(len(kinds))]
        if k % 3 != 0: pairs = R.sample(pairs, 10)
        for i, j in pairs:
            sc.ev0(sc.op(op, [kinds[i](), kinds[j]()]), binds)
    op = R.choice(BINOPS)
    # the shapes of the argument lists
    sc.ev0(sc.app(sc.sym(op), []))
    sc.ev0(sc.app(sc.sym(op), [sc.dyn([])]))
    sc.ev0(sc.app(sc.sym(op), [sc.dyn([sc.num(1)])]))
    sc.ev0(sc.app(sc.sym(op), [sc.dyn([sc.num(1), sc.num(2), sc.num(3)])]))
    sc.ev0(sc.app(sc.sym(op), [sc.dyn([sc.num(1), sc.num(2)]), sc.dyn([sc.num(3), sc.num(4)])]))
    sc.ev0(sc.app(sc.sym(op), [sc.stag([('seq', [])]), sc.dyn([sc.num(1), sc.num(2)])]))
    sc.ev0(sc.app(sc.sym(op), [sc.stag([('seq', [])])]))

def fam_ifs(sc, k):
    """ifhead, the macfuns on lists and on non-lists, the singleton parentheses"""
    R = sc.R
    scope, binds = newscope(sc, 2, 1, 2, 1)
    for _ in range(8):
        sc.ev0(g0(sc, 3, 'any', scope), binds)
    # the conditions of every kind
    for c in (sc.var(scope['bool'][0]), sc.num(1), sc.quote(sc.num(1)), sc.var(scope['list'][0]), sc.op('<', [sc.num(1), sc.num(2)]), sc.op('<', [sc.num(3), sc.num(2)])):
        sc.ev0(sc.ifh(c, sc.num(1), sc.num(2)), binds)
        sc.ev0(sc.ifh(c, sc.num(1)), binds)
    for f in MACFUNS + ['foo']:
        for a in (sc.var(scope['list'][0]), sc.var(scope['list'][1]), sc.num(1), sc.quote(sc.num(2))):
            sc.ev0(sc.macfun(f, [a]), binds)
        sc.ev0(sc.macfun(f, []), binds)
        sc.ev0(sc.macfun(f, [sc.var(scope['list'][0]), sc.num(3)]), binds)
    # the error values (an unbound variable, a value bound to M2Verr, a comparison of non-integers)
    ev = sc.dv()
    eb = binds + [('d', ev, 'K_M2Verr ()')]
    for f in MACFUNS:
        sc.ev0(sc.macfun(f, [sc.var(ev)]), eb)
        sc.ev0(sc.macfun(f, [sc.var(sc.dv())]), eb)
        sc.ev0(sc.macfun(f, [sc.op('<', [sc.quote(sc.num(1)), sc.num(2)])]), eb)
    sc.ev0(sc.macfun('cdr', [sc.macfun('cdr', [sc.var(scope['list'][0])])]), binds)
    sc.ev0(sc.macfun('islist', [sc.macfun('cdr', [sc.var(scope['list'][1])])]), binds)
    # nested lists
    nl = sc.dv()
    b2 = binds + [('d', nl, 'K_M2Vlist (%s)' % sc.mlist(['K_M2Vlist (%s)' % sc.mlist(['K_M2Vint (1)']), 'K_M2Vlist (LN_m2valist ())', 'K_M2Vint (2)']))]
    for f in ('car', 'cdr', 'isnil', 'iscons', 'islist'):
        sc.ev0(sc.macfun(f, [sc.var(nl)]), b2)
        sc.ev0(sc.macfun(f, [sc.macfun('cdr', [sc.var(nl)])]), b2)
        sc.ev0(sc.macfun(f, [sc.macfun('car', [sc.var(nl)])]), b2)
        sc.ev0(sc.macfun(f, [sc.macfun('cdr', [sc.macfun('cdr', [sc.macfun('cdr', [sc.var(nl)])])])]), b2)

def fam_syn(sc, k):
    """the three macro syntaxes in eval0: encode (eval1 inside), decode, xstage; and the results lifted"""
    R = sc.R
    scope, binds = newscope(sc, 2, 1, 1, 2)
    for _ in range(5):
        body = g0(sc, 2, 'code', scope)
        sc.ev0(body, binds)
        sc.ev0(sc.unquote(body), binds)
        sc.ev0(sc.xstage(body), binds)
    for _ in range(4):
        i = g0(sc, 2, 'int', scope)
        sc.ev0(sc.xstage(i), binds)
        sc.ev0(sc.unquote(i), binds)
        sc.ev0(sc.quote(sc.op('+', [sc.unquote(sc.quote(sc.num(1))), sc.xstage(i)])), binds)
        sc.ev0(sc.xstage(sc.quote(i)), binds)
    for e in (sc.lit(), sc.var(scope['dcode'][0]), sc.quote(sc.gv('d2exp', 2)), sc.gv('d2exp', 2)):
        sc.ev0(sc.quote(e), binds)
        sc.ev0(sc.unquote(sc.quote(e)), binds)
        sc.ev0(sc.xstage(sc.quote(e)), binds)
    # the entry points
    for e in (g0(sc, 2, 'code', scope), sc.quote(sc.gv('d2exp', 2)), g0(sc, 2, 'int', scope), sc.lit(), sc.xstage(g0(sc, 2, 'int', scope))):
        sc.dd('d2exp', 'dmacro_eval_decode (%s)' % e)
        sc.dd('d2exp', 'dmacro_eval_xstage (%s)' % e)

def fam_lift(sc, k):
    """liftval2dexp on every kind of value; the printers of the values"""
    R = sc.R
    vals = ['K_M2Vint (3)', 'K_M2Vint (-4)', 'K_M2Vbool (true)', 'K_M2Vbool (false)', 'K_M2Vchar (mkchr (0))', 'K_M2Vfloat ("2.5")', 'K_M2Vstring ("ab")',
            'K_M2Vunit ()', 'K_M2Vscode (%s)' % sc.gv('s2exp', 1), 'K_M2Vdcode (%s)' % sc.gv('d2exp', 1), 'K_M2Verr ()',
            'K_M2Vlist (%s)' % sc.mlist(['K_M2Vint (1)', 'K_M2Vstring ("x")', 'K_M2Vlist (LN_m2valist ())'])]
    vals += [sc.m2v(3) for _ in range(6)]
    for v in vals:
        x = sc.val(v, 'm2val')
        sc.dd('m2val', x)
        sc.do('(print_m2val (%s); print_newline ())' % x)
        sc.do('(prerr_m2val (%s); prerr_newline ())' % x)
        sc.do('(fprint_m2val (dd_out, %s); dd_nl ())' % x)
        sc.dd('d2exp', 'liftval2dexp (%s, %s)' % (sc.L(), x))
    for l in (sc.mlist([]), sc.mlist(vals[:3]), sc.mlist(vals[-3:])):
        sc.do('(fprint_m2valist (dd_out, %s); dd_nl ())' % l)
        sc.dd('m2valist', l)
    sc.dd('m2val', 'm2val_true'); sc.dd('m2val', 'm2val_false')

def fam_ctx(sc, k):
    """evalctx: add, find, print, free; stasub_make_evalctx and the substitution of the static variables"""
    R = sc.R
    ds = [sc.dv() for _ in range(4)]; ss = [sc.sv() for _ in range(3)]
    ctxbinds = []
    order = list(range(7)); R.shuffle(order)
    for i in order:
        if i < 4: ctxbinds.append(('d', ds[i], sc.m2v(2)))
        else: ctxbinds.append(('s', ss[i - 4], R.choice(['K_M2Vscode (%s)' % sc.gv('s2exp', 1), 'K_M2Vscode (s2exp_int (%d))' % R.randint(0, 9), 'K_M2Vint (3)', 'K_M2Verr ()'])))
    ctxbinds.append(('d', ds[0], sc.m2v(1)))   # a shadowing binding
    d_unbound = sc.dv()
    sc.do('{ %s val () = print_evalctx ctx val () = prerr_evalctx ctx val () = (fprint_evalctx (dd_out, ctx); dd_nl ())%s }' % (sc.pre(ctxbinds), SC_POST))
    sc.do('{ %s %s%s }' % (sc.pre(ctxbinds), ' '.join('val () = (dd_optvt_m2val (evalctx_dfind (ctx, %s)); dd_nl ())' % d for d in ds + [d_unbound]), SC_POST))
    sc.do('{ %s val () = (fprint_evalctx (dd_out, ctx); dd_nl ())%s }' % (sc.pre(()), SC_POST))
    # the static substitution through the evaluator of the code level (D2Eextval, D2Eann_type, ...) and directly
    for _ in range(4):
        e = sc.gv('s2exp', 2)
        sv = ss[R.randrange(3)]
        e2 = 's2exp_var (%s)' % sv
        for ee in (e, e2, 'S2Eapp_dummy'):
            if ee == 'S2Eapp_dummy': continue
            sc.do('{ %s val sub = stasub_make_evalctx ctx val r = s2exp_subst (sub, %s) val () = (dd_s2exp r; dd_nl ()) val () = stasub_free sub%s }' % (sc.pre(ctxbinds), ee, SC_POST))
        sc.ev1('d2exp_extval (%s, s2exp_var (%s), "e")' % (sc.L(), sv), ctxbinds)
        sc.ev1('d2exp_ann_type (%s, %s, %s)' % (sc.L(), sc.var(ds[0]), e2), ctxbinds)
        sc.ev1('d2exp_lst (%s, 0, OS_s2expopt (%s), %s)' % (sc.L(), e2, sc.dlist([sc.num(1)])), ctxbinds)
    sc.do('{ %s val sub = stasub_make_evalctx ctx val () = stasub_free sub%s }' % (sc.pre(()), SC_POST))
SC_POST = MSc.POST

def fam_alph(sc, k):
    """alphenv: random sequences of add/push/pop/find"""
    R = sc.R
    ds = [sc.dv() for _ in range(5)]; ss = [sc.sv() for _ in range(4)]
    ds2 = [sc.dv() for _ in range(5)]; ss2 = [sc.sv() for _ in range(4)]
    body = ''
    for _ in range(R.choice([30, 40, 50])):
        c = R.random()
        i = R.randrange(5); j = R.randrange(4)
        if c < 0.18: body += ' val () = alphenv_dadd (env, %s, %s)' % (ds[i], R.choice(ds2))
        elif c < 0.30: body += ' val () = alphenv_sadd (env, %s, %s)' % (ss[j], R.choice(ss2))
        elif c < 0.42: body += ' val () = alphenv_push env'
        elif c < 0.55: body += ' val () = alphenv_pop env'
        elif c < 0.78: body += ' val () = (dd_optvt_d2var (alphenv_dfind (env, %s)); dd_nl ())' % ds[i]
        else: body += ' val () = (dd_optvt_s2var (alphenv_sfind (env, %s)); dd_nl ())' % ss[j]
    # a final scan
    body += ' ' + ' '.join('val () = (dd_optvt_d2var (alphenv_dfind (env, %s)); dd_nl ())' % d for d in ds)
    body += ' ' + ' '.join('val () = (dd_optvt_s2var (alphenv_sfind (env, %s)); dd_nl ())' % s for s in ss)
    sc.do('{ var env = alphenv_nil ()%s val () = alphenv_free env }' % body)
    # an empty one, and pops on it
    sc.do('{ var env = alphenv_nil () val () = alphenv_pop env val () = (dd_optvt_d2var (alphenv_dfind (env, %s)); dd_nl ()) val () = alphenv_push env val () = alphenv_free env }' % ds[0])
    # shadowing: the first (innermost) binding wins
    sc.do('{ var env = alphenv_nil () val () = alphenv_dadd (env, %s, %s) val () = alphenv_push env val () = alphenv_dadd (env, %s, %s) '
          'val () = (dd_optvt_d2var (alphenv_dfind (env, %s)); dd_nl ()) val () = alphenv_pop env val () = (dd_optvt_d2var (alphenv_dfind (env, %s)); dd_nl ()) val () = alphenv_free env }' % (
          ds[0], ds2[0], ds[0], ds2[1], ds[0], ds[0]))

# ---------------------------------------------------------------- the macros
def fam_mlong(sc, k):
    """macros in long form: identity, sums, recursion (factorial, the sum of a list), static arguments, arity errors, nested calls"""
    R = sc.R
    x, y, n, xs = sc.dv(), sc.dv(), sc.dv(), sc.dv()
    s = sc.sv()
    m_id = sc.mkmac(1, [('d', [x])], sc.var(x))
    m_add = sc.mkmac(1, [('d', [x, y])], sc.op('+', [sc.var(x), sc.var(y)]))
    m_sub = sc.mkmac(1, [('d', [x]), ('d', [y])], sc.op('-', [sc.var(x), sc.var(y)]))
    m_unit = sc.mkmac(1, [], sc.num(R.randint(0, 9)))
    m_fact = sc.mkmac(1, [('d', [n])], sc.num(0))
    fact_def = sc.ifh(sc.op('<=', [sc.var(n), sc.num(1)]), sc.num(1), sc.op('*', [sc.var(n), sc.macapp(m_fact, [sc.dyn([sc.op('-', [sc.var(n), sc.num(1)])])])]))
    sc.do('d2mac_set_def (%s, %s)' % (m_fact, fact_def))
    m_sum = sc.mkmac(1, [('d', [xs])], sc.num(0))
    sum_def = sc.ifh(sc.macfun('isnil', [sc.var(xs)]), sc.num(0),
                     sc.op('+', [sc.macfun('car', [sc.var(xs)]), sc.macapp(m_sum, [sc.dyn([sc.macfun('cdr', [sc.var(xs)])])])]))
    sc.do('d2mac_set_def (%s, %s)' % (m_sum, sum_def))
    m_lst = sc.mkmac(1, [('d', [xs])], sc.var(xs))
    m_cdr = sc.mkmac(1, [('d', [xs])], sc.macfun('cdr', [sc.var(xs)]))
    # a macro with a static group
    m_sta = sc.mkmac(1, [('s', [s]), ('d', [x])], sc.quote('d2exp_ann_type (%s, %s, s2exp_var (%s))' % (sc.L(), sc.var(x), s)))
    m_sta2 = sc.mkmac(1, [('d', [x]), ('s', [])], sc.var(x))
    m_two = sc.mkmac(1, [('d', [x, y]), ('d', [n])], sc.op('+', [sc.op('*', [sc.var(x), sc.var(y)]), sc.var(n)]))
    for e in (sc.mac(m_unit), sc.macapp(m_unit, []), sc.macapp(m_unit, [sc.dyn([])])):
        sc.ev0(e)
    for a in (sc.num(3), sc.var(x), sc.quote(sc.num(1)), sc.op('+', [sc.num(1), sc.num(2)])):
        sc.ev0(sc.macapp(m_id, [sc.dyn([a])]), [('d', x, 'K_M2Vint (9)')])
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.num(3), sc.num(4)])]))
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.num(3), sc.quote(sc.num(4))])]))
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.num(3)]), sc.dyn([sc.num(4)])]))      # a group count mismatch: the arity error and a kind-right group
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.num(3), sc.num(4), sc.num(5)])]))      # too many arguments in a group
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.num(3), sc.num(4)]), sc.dyn([sc.num(5)])]))   # too many groups
    sc.ev0(sc.macapp(m_sub, [sc.dyn([sc.num(10)]), sc.dyn([sc.num(4)])]))
    sc.ev0(sc.macapp(m_sub, [sc.dyn([sc.num(10)]), sc.dyn([sc.num(4), sc.num(1)])]))
    sc.ev0(sc.macapp(m_sub, [sc.dyn([sc.num(10)]), sc.dyn([])]))
    sc.ev0(sc.macapp(m_sub, [sc.dyn([]), sc.dyn([sc.num(4)])]))
    sc.ev0(sc.macapp(m_sub, [sc.dyn([sc.num(1)]), sc.stag([('seq', [])])]))   # a static group where a dynamic one is expected
    for i in (0, 1, 2, 5, R.randint(3, 7)):
        sc.ev0(sc.macapp(m_fact, [sc.dyn([sc.num(i)])]))
    for xsl in ([], [sc.num(4)], [sc.num(1), sc.num(2), sc.num(3)]):
        sc.ev0(sc.macapp(m_lst, [sc.dyn(xsl)]))
        sc.ev0(sc.macapp(m_sum, [sc.dyn(xsl)]))
        sc.ev0(sc.macapp(m_cdr, [sc.dyn(xsl)]))
        sc.ev0(sc.macapp(m_sum, [sc.dyn([sc.macapp(m_lst, [sc.dyn(xsl)])])]))
    sc.ev0(sc.macapp(m_sum, [sc.dyn([sc.num(1), sc.num(2)]), sc.dyn([sc.num(3)])]))
    sc.ev0(sc.macapp(m_two, [sc.dyn([sc.num(2), sc.num(3)]), sc.dyn([sc.num(1)])]))
    sc.ev0(sc.macapp(m_two, [sc.dyn([sc.num(2)]), sc.dyn([sc.num(1)])]))
    # the static groups
    sc.ev0(sc.macapp(m_sta, [sc.stag([('seq', ['s2exp_int (1)'])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.stag([('seq', ['s2exp_int (1)', 's2exp_int (2)'])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.stag([('seq', [])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.stag([('seq', ['s2exp_int (1)']), ('seq', ['s2exp_int (2)']), ('one', []), ('all', [])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.stag([('one', []), ('seq', ['s2exp_int (3)']), ('all', [])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.stag([('one', [])]), sc.dyn([sc.num(5)])]))
    sc.ev0(sc.macapp(m_sta, [sc.dyn([sc.num(5)]), sc.dyn([sc.num(5)])]))     # dynamic where static is expected
    sc.ev0(sc.macapp(m_sta, [sc.stag([('seq', ['s2exp_int (1)'])]), sc.stag([('seq', ['s2exp_int (1)'])])]))
    sc.ev0(sc.macapp(m_sta2, [sc.dyn([sc.num(5)]), sc.stag([('seq', [])])]))
    sc.ev0(sc.macapp(m_sta2, [sc.dyn([sc.num(5)]), sc.stag([('seq', ['s2exp_int (1)'])])]))
    # a group of three variables / of none: the argument counts of a group (the errors of evalctx_extend_darg)
    a, b, c = sc.dv(), sc.dv(), sc.dv()
    m_three = sc.mkmac(1, [('d', [a, b, c])], sc.op('+', [sc.var(a), sc.op('+', [sc.var(b), sc.var(c)])]))
    m_none = sc.mkmac(1, [('d', [])], sc.num(R.randint(0, 9)))
    m_none2 = sc.mkmac(1, [('d', []), ('d', [a])], sc.var(a))
    for n in range(0, 5):
        sc.ev0(sc.macapp(m_three, [sc.dyn([sc.num(i + 1) for i in range(n)])]))
        sc.ev0(sc.macapp(m_none, [sc.dyn([sc.num(i + 1) for i in range(n)])]))
    sc.ev0(sc.macapp(m_none2, [sc.dyn([sc.num(1)]), sc.dyn([sc.num(2)])]))
    sc.ev0(sc.macapp(m_none2, [sc.dyn([]), sc.dyn([sc.num(2)])]))
    sc.ev0(sc.macapp(m_none2, [sc.stag([('seq', [])]), sc.dyn([sc.num(2)])]))
    # the same static groups
    s1, s2 = sc.sv(), sc.sv()
    m_s2 = sc.mkmac(1, [('s', [s1, s2]), ('s', [])], sc.quote('d2exp_ann_type (%s, %s, s2exp_var (%s))' % (sc.L(), sc.num(1), s2)))
    for n in range(0, 4):
        sc.ev0(sc.macapp(m_s2, [sc.stag([('seq', ['s2exp_int (%d)' % i for i in range(n)])]), sc.stag([('seq', ['s2exp_int (7)'] * (n % 2))])]))
    # direct calls of the entry point
    for m, gs in ((m_id, [sc.dyn([sc.num(1)])]), (m_add, [sc.dyn([sc.num(1), sc.num(2)])]), (m_add, [sc.dyn([sc.num(1), sc.num(2)]), sc.dyn([sc.num(1)])]),
                  (m_unit, []), (m_fact, [sc.dyn([sc.num(4)])])):
        sc.mlong(m, gs)
    # evaluated inside the context of the caller (the macro body sees only its own arguments)
    sc.ev0(sc.macapp(m_id, [sc.dyn([sc.var(y)])]), [('d', y, 'K_M2Vint (5)')])
    sc.ev0(sc.macapp(m_unit, []), [('d', x, 'K_M2Vint (5)')])
    sc.ev0(sc.macapp(m_add, [sc.dyn([sc.var(x), sc.var(y)])]), [('d', x, 'K_M2Vint (5)'), ('d', y, 'K_M2Vint (6)')])

def fam_mshort(sc, k):
    """macros in short form: the arguments are quoted (eval1), ,( ) calls the evaluator; the over-application merges the groups"""
    R = sc.R
    x, y, z = sc.dv(), sc.dv(), sc.dv()
    s = sc.sv()
    m_id = sc.mkmac(0, [('d', [x])], sc.unquote(sc.var(x)))
    m_dbl = sc.mkmac(0, [('d', [x])], sc.op('+', [sc.unquote(sc.var(x)), sc.unquote(sc.var(x))]))
    m_two = sc.mkmac(0, [('d', [x, y])], sc.op('*', [sc.unquote(sc.var(x)), sc.var(y)]))
    m_fn = sc.mkmac(0, [('d', [x])], sc.app(sc.var(y), [sc.dyn([sc.unquote(sc.var(x))])]))   # yields an application: over-applying merges
    m_unit = sc.mkmac(0, [], sc.op('+', [sc.num(1), sc.num(2)]))
    m_mix = sc.mkmac(0, [('d', [x, y])], sc.op('+', [sc.unquote(sc.op('+', [sc.num(1), sc.num(2)])), sc.xstage(sc.op('*', [sc.num(3), sc.num(4)]))]))
    m_sta = sc.mkmac(0, [('s', [s]), ('d', [x])], 'd2exp_ann_type (%s, %s, s2exp_var (%s))' % (sc.L(), sc.unquote(sc.var(x)), s))
    xs = sc.dv()
    m_lst = sc.mkmac(0, [('d', [xs])], sc.unquote(sc.macfun('car', [sc.var(xs)])))
    m_bad = sc.mkmac(0, [('d', [x])], sc.unquote(sc.num(3)))        # the expansion is not code
    m_bad2 = sc.mkmac(0, [('d', [x])], sc.unquote(sc.var(z)))       # unbound variable
    m_xs = sc.mkmac(0, [('d', [x])], sc.xstage(sc.op('+', [sc.num(1), sc.num(2)])))
    m_nest = sc.mkmac(0, [('d', [x])], sc.macapp(m_dbl, [sc.dyn([sc.unquote(sc.var(x))])]))   # a short macro applied inside the body (eval1_d2exp_applst)
    for m in (m_id, m_dbl, m_two, m_fn, m_unit, m_mix, m_sta, m_lst, m_bad, m_bad2, m_xs, m_nest):
        pass
    args = lambda: R.choice([sc.num(3), sc.var(z), sc.op('+', [sc.num(1), sc.num(2)]), sc.unquote(sc.quote(sc.num(7))), sc.quote(sc.num(1)), sc.gv('d2exp', 1)])
    for m in (m_id, m_dbl, m_fn, m_bad, m_bad2, m_xs, m_nest, m_lst):
        for _ in range(2):
            a = args()
            sc.mshort(m, [sc.dyn([a])], [('d', y, 'K_M2Vdcode (%s)' % sc.num(5))])
            sc.do('{ %s val r = dmacro_eval_app_short (%s, %s, %s) val () = (dd_d2exp r; dd_nl ())%s }' % (sc.pre(()), sc.L(), m, sc.lst('d2exparglst', [sc.dyn([a])]), SC_POST))
            sc.do('t3chk ()')
            sc.ev0(sc.macapp(m, [sc.dyn([a])]), [('d', y, 'K_M2Vdcode (%s)' % sc.num(5))])
            sc.ev1(sc.macapp(m, [sc.dyn([a])]), [('d', y, 'K_M2Vdcode (%s)' % sc.num(5))])
            sc.ev1(sc.app(sc.mac(m), [sc.dyn([a]), sc.dyn([sc.num(8)])]), [('d', y, 'K_M2Vdcode (%s)' % sc.num(5))])    # over-applied
    sc.mshort(m_two, [sc.dyn([sc.num(3), sc.num(4)])])
    sc.mshort(m_two, [sc.dyn([sc.num(3), sc.num(4)]), sc.dyn([sc.num(5)])])
    sc.mshort(m_two, [sc.dyn([sc.num(3)]), sc.dyn([sc.num(4)]), sc.stag([('seq', ['s2exp_int (1)'])])])        # a dynamic group then others: kind error
    sc.mshort(m_two, [sc.dyn([sc.num(3), sc.num(4), sc.num(5)])])
    sc.mshort(m_dbl, [sc.dyn([sc.num(3)]), sc.dyn([sc.num(4)]), sc.dyn([sc.num(5)])])
    sc.mshort(m_dbl, [sc.dyn([sc.num(3), sc.num(4)])])
    sc.mshort(m_dbl, [sc.dyn([])])
    sc.mshort(m_unit, [])
    sc.mshort(m_unit, [sc.dyn([sc.num(3)]), sc.stag([('seq', [])])])
    sc.mshort(m_mix, [sc.dyn([sc.num(3), sc.num(4)])])
    sc.mshort(m_mix, [sc.dyn([sc.num(3), sc.quote(sc.num(4))])])
    sc.mshort(m_sta, [sc.stag([('seq', ['s2exp_int (1)'])]), sc.dyn([sc.num(5)])])
    sc.mshort(m_sta, [sc.stag([('seq', ['s2exp_int (1)', 's2exp_int (2)'])]), sc.dyn([sc.num(5)])])
    sc.mshort(m_sta, [sc.stag([('seq', ['s2exp_int (1)'])]), sc.dyn([sc.num(5)]), sc.dyn([sc.num(6)])])
    sc.mshort(m_sta, [sc.stag([('one', [])]), sc.dyn([sc.num(5)])])
    sc.mshort(m_sta, [sc.dyn([sc.num(5)]), sc.dyn([sc.num(5)])])
    sc.mshort(m_lst, [sc.dyn([sc.num(1), sc.num(2)])])
    sc.mshort(m_lst, [sc.dyn([sc.quote(sc.num(1)), sc.num(2)])])
    sc.mshort(m_lst, [sc.dyn([])])
    # a long-form macro called inside quotes: reported
    m_long = sc.mkmac(1, [('d', [x])], sc.var(x))
    sc.ev1(sc.macapp(m_long, [sc.dyn([sc.num(1)])]))
    sc.ev1(sc.mac(m_long))
    sc.ev1(sc.mac(m_id))
    sc.ev1(sc.macapp(m_id, [sc.dyn([sc.num(1)]), sc.dyn([sc.num(2)])]))

def fam_eval1(sc, k):
    """eval1 on random trees of every constructor of d2exp, under random contexts and environments; the decode/xstage forms inside"""
    R = sc.R
    for _ in range(3): sc.new('d2var'); sc.new('d2cst'); sc.new('d2con'); sc.new('s2var')
    ss = [sc.sv() for _ in range(2)]
    ds = [sc.dv() for _ in range(2)]
    for _ in range(3): sc.new('d2mac')
    binds = [('s', ss[0], 'K_M2Vscode (%s)' % sc.gv('s2exp', 1)), ('s', ss[1], 'K_M2Vint (1)'), ('d', ds[0], 'K_M2Vdcode (%s)' % sc.num(5)), ('d', ds[1], sc.m2v(1))]
    G = sc.G
    cs = [c for c, ts in G.types['d2exp_node']]
    for c in cs:
        fn, args = C.smart_call(sc, 'd2exp', c, 2)
        e = sc.val('%s (%s)' % (fn, ', '.join(args)), 'd2exp')
        sc.ev1(e, binds if R.random() < 0.7 else ())
    for _ in range(6):
        sc.ev1(sc.gv('d2exp', 3), binds)
    # the macro syntaxes inside random trees
    for _ in range(6):
        inner = R.choice([sc.var(ds[0]), sc.var(ds[1]), g0(sc, 1, 'code', {'int': [], 'bool': [], 'list': [], 'dcode': [ds[0]], 'code': [ds[0]]}), sc.gv('d2exp', 1)])
        wrap = R.choice([lambda x: sc.unquote(x), lambda x: sc.xstage(x), lambda x: sc.quote(x)])
        e = sc.val('d2exp_tup (%s, 0, 0, %s)' % (sc.L(), sc.dlist([wrap(inner), sc.gv('d2exp', 1)])), 'd2exp')
        sc.ev1(e, binds)
        sc.ev1(wrap(inner), binds)
    # a hand-made list through the template
    sc.do('{ %s val r = t_listmap (%s, ctx, env, %s) val () = (dd_d2explst r; dd_nl ())%s }' % (sc.pre(binds), sc.L(), sc.dlist([sc.gv('d2exp', 2) for _ in range(3)]), SC_POST))
    sc.do('{ %s val r = t_listmap (%s, ctx, env, %s) val () = (dd_d2explst r; dd_nl ())%s }' % (sc.pre(binds), sc.L(), sc.dlist([]), SC_POST))

def fam_eval1b(sc, k):
    """eval1: binders (let, where, val declarations, lambdas, clauses with guards), the declarations that are not handled"""
    R = sc.R
    for _ in range(3): sc.new('d2var'); sc.new('d2con'); sc.new('s2var'); sc.new('d2cst')
    binds = [('d', sc.dv(), 'K_M2Vint (1)')]
    pat = lambda: sc.gv('p2at', 2)
    for _ in range(4):
        d2cs = sc.gv('d2eclist', 2)
        sc.ev1('d2exp_let (%s, %s, %s)' % (sc.L(), d2cs, sc.gv('d2exp', 2)), binds)
        sc.ev1('d2exp_where (%s, %s, %s)' % (sc.L(), sc.gv('d2exp', 2), d2cs), binds)
    for _ in range(4):
        v2ds = sc.lst('v2aldeclst', ['K_v2aldec (%s, %s, %s, %s)' % (sc.L(), pat(), sc.gv('d2exp', 2), sc.gv('s2expopt', 1)) for _ in range(R.choice([0, 1, 2, 3]))])
        for knd in ('D2Cvaldecs', 'D2Cvaldecs_rec'):
            d = sc.val('K_%s (mkvalkind (%d), %s)' % (knd, R.randint(0, 3), v2ds))
            dc = sc.val('K_d2ecl (%s, %s)' % (sc.L(), d))
            sc.ev1('d2exp_let (%s, %s, %s)' % (sc.L(), sc.lst('d2eclist', [dc, sc.gv('d2ecl', 1), dc]), sc.gv('d2exp', 1)), binds)
    for _ in range(4):
        sc.ev1('d2exp_lam_dyn (%s, %d, %d, %s, %s)' % (sc.L(), R.choice([0, 1]), R.choice([0, 1]), sc.gv('p2atlst', 2), sc.gv('d2exp', 2)), binds)
        sc.ev1('d2exp_casehead (%s, mkcaskind (%d), %s, %s, %s)' % (sc.L(), R.randint(0, 2), sc.gv('i2nvresstate', 2), sc.gv('d2explst', 2), sc.gv('c2laulst', 2)), binds)
        sc.ev1('d2exp_ifhead (%s, %s, %s, %s, %s)' % (sc.L(), sc.gv('i2nvresstate', 2), sc.gv('d2exp', 2), sc.gv('d2exp', 2), sc.gv('d2expopt', 2)), binds)
        sc.ev1('d2exp_sifhead (%s, %s, %s, %s, %s)' % (sc.L(), sc.gv('i2nvresstate', 2), sc.gv('s2exp', 2), sc.gv('d2exp', 2), sc.gv('d2exp', 2)), binds)
        sc.ev1('d2exp_rec (%s, %d, 0, %s)' % (sc.L(), R.choice([0, 1]), sc.gv('labd2explst', 2)), binds)
        sc.ev1('d2exp_selab (%s, %s, %s)' % (sc.L(), sc.gv('d2exp', 1), sc.gv('d2lablst', 2)), binds)
        sc.ev1('d2exp_con (%s, %s, %s, %s, 0, %s, %s)' % (sc.L(), sc.handle('d2con'), sc.L(), sc.gv('s2exparglst', 2), sc.L(), sc.gv('d2explst', 2)), binds)
        sc.ev1('d2exp_tmpid (%s, %s, %s)' % (sc.L(), sc.gv('d2exp', 1), sc.gv('t2mpmarglst', 2)), binds)
    # the arms that need a precise shape: S2EXPARGseq, labelled patterns, D2LABind, a head that is an application
    ss = [sc.sv() for _ in range(2)]
    sbinds = [('s', ss[0], 'K_M2Vscode (s2exp_int (4))')]
    sexpa = lambda: 'K_s2exparg (%s, K_S2EXPARGseq (%s))' % (sc.L(), sc.lst('s2explst', ['s2exp_var (%s)' % ss[0], 's2exp_int (2)']))
    sc.ev1('d2exp_exist (%s, %s, %s)' % (sc.L(), sexpa(), sc.num(1)), sbinds)
    sc.ev1('d2exp_exist (%s, K_s2exparg (%s, K_S2EXPARGone ()), %s)' % (sc.L(), sc.L(), sc.num(1)), sbinds)
    sc.ev1('d2exp_exist (%s, K_s2exparg (%s, K_S2EXPARGall ()), %s)' % (sc.L(), sc.L(), sc.num(1)), sbinds)
    sc.ev1('d2exp_con (%s, %s, %s, %s, 0, %s, %s)' % (sc.L(), sc.handle('d2con'), sc.L(), sc.lst('s2exparglst', [sexpa(), sexpa()]), sc.L(), sc.dlist([sc.num(1)])), sbinds)
    lp = sc.lst('labp2atlst', ['K_LABP2ATnorm (%s, p2at_var (%s, %s))' % (sc.leaf('l0ab'), sc.L(), sc.dv()), 'K_LABP2ATomit (%s)' % sc.L(),
                               'K_LABP2ATnorm (%s, p2at_int (%s, 3))' % (sc.leaf('l0ab'), sc.L())])
    sc.ev1('d2exp_lam_dyn (%s, 0, 0, %s, %s)' % (sc.L(), sc.lst('p2atlst', ['p2at_rec (%s, 0, 0, %s)' % (sc.L(), lp), 'p2at_ann (%s, p2at_any (%s), s2exp_var (%s))' % (sc.L(), sc.L(), ss[0])]), sc.num(1)), sbinds)
    sc.ev1('d2exp_selab (%s, %s, %s)' % (sc.L(), sc.var(sc.dv()), sc.lst('d2lablst', ['d2lab_ind (%s, %s)' % (sc.L(), sc.dlist([sc.num(1), sc.num(2)])), 'd2lab_lab (%s, %s, ON_d2symopt ())' % (sc.L(), sc.leaf('label'))])))
    inner = sc.app(sc.mac(sc.mkmac(0, [('d', [sc.dv()])], sc.app(sc.var(sc.dv()), [sc.dyn([sc.num(1)])]), 'mksym (2)')), [sc.dyn([sc.num(9)])])
    sc.ev1(sc.app(inner, [sc.dyn([sc.num(2)])]))
    sc.ev1(sc.app(sc.app(sc.var(sc.dv()), [sc.dyn([sc.num(1)])]), [sc.dyn([sc.num(2)]), sc.stag([('seq', [])])]))
    sc.ev1(sc.app(sc.app(sc.var(sc.dv()), []), [sc.dyn([sc.num(2)])]))
    # every kind of d2ecl
    for c, ts in sc.G.types['d2ecl_node']:
        d = sc.val(C.Sc.datatype_con(sc, 'd2ecl_node', c, 1))
        dc = sc.val('K_d2ecl (%s, %s)' % (sc.L(), d), 'd2ecl')
        sc.ev1('d2exp_let (%s, %s, %s)' % (sc.L(), sc.lst('d2eclist', [dc]), sc.num(1)), binds)

def fam_order(sc, k):
    """eval1 on nodes whose children are all `,(...)` of a non-code value: every child reports an error at its own location, so the order of the
    reports is the order of the evaluation of the children"""
    R = sc.R
    cnt = [0]
    def uq():
        cnt[0] += 1
        return 'd2exp_macsyn (%s, mkmacsynkind (1), d2exp_int (mkloc (%d), %d))' % (sc.L(), 30 + cnt[0], cnt[0])
    def uqs(n): return [uq() for _ in range(n)]
    L = sc.L
    for _ in range(2):
        sc.ev1('d2exp_tup (%s, 0, 0, %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_list (%s, 0, %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_seq (%s, %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_lst (%s, 0, ON_s2expopt (), %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_rec (%s, 0, 0, %s)' % (L(), sc.lst('labd2explst', ['K_labd2exp (mkl0ab (%d), %s)' % (i, uq()) for i in range(3)])))
        sc.ev1('d2exp_ifhead (%s, i2nvresstate_nil, %s, %s, OS_d2expopt (%s))' % (L(), uq(), uq(), uq()))
        sc.ev1('d2exp_sifhead (%s, i2nvresstate_nil, s2exp_int (1), %s, %s)' % (L(), uq(), uq()))
        sc.ev1('d2exp_assgn (%s, %s, %s)' % (L(), uq(), uq()))
        sc.ev1('d2exp_xchng (%s, %s, %s)' % (L(), uq(), uq()))
        sc.ev1('d2exp_arrsub (%s, mkdsym (%s, "x"), %s, %s, %s)' % (L(), L(), uq(), L(), sc.dlist(uqs(2))))
        sc.ev1('d2exp_arrinit (%s, s2exp_int (1), OS_d2expopt (%s), %s)' % (L(), uq(), sc.dlist(uqs(2))))
        sc.ev1('d2exp_arrpsz (%s, ON_s2expopt (), %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_selab (%s, %s, %s)' % (L(), uq(), sc.lst('d2lablst', ['d2lab_ind (%s, %s)' % (L(), sc.dlist(uqs(2))), 'd2lab_ind (%s, %s)' % (L(), sc.dlist(uqs(2)))])))
        sc.ev1('d2exp_extfcall (%s, s2exp_int (1), "f", %s)' % (L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_extmcall (%s, s2exp_int (1), %s, "m", %s)' % (L(), uq(), sc.dlist(uqs(2))))
        sc.ev1('d2exp_con (%s, %s, %s, %s, 0, %s, %s)' % (L(), sc.handle('d2con'), L(), sc.lst('s2exparglst', []), L(), sc.dlist(uqs(3))))
        sc.ev1('d2exp_ann_type (%s, %s, s2exp_int (1))' % (L(), uq()))
        sc.ev1('d2exp_delay (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_ldelay (%s, %s, OS_d2expopt (%s))' % (L(), uq(), uq()))
        sc.ev1('d2exp_raise (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_vararg (%s, %s)' % (L(), sc.dlist(uqs(2))))
        sc.ev1('d2exp_lam_dyn (%s, 0, 0, %s, %s)' % (L(), sc.lst('p2atlst', []), uq()))
        sc.ev1('d2exp_let (%s, %s, %s)' % (L(), sc.lst('d2eclist', ['K_d2ecl (%s, K_D2Cvaldecs (mkvalkind (0), %s))' % (L(), sc.lst('v2aldeclst', ['K_v2aldec (%s, p2at_any (%s), %s, ON_s2expopt ())' % (L(), L(), uq()) for _ in range(3)]))]), uq()))
        sc.ev1('d2exp_where (%s, %s, %s)' % (L(), uq(), sc.lst('d2eclist', ['K_d2ecl (%s, K_D2Cvaldecs_rec (mkvalkind (0), %s))' % (L(), sc.lst('v2aldeclst', ['K_v2aldec (%s, p2at_any (%s), %s, ON_s2expopt ())' % (L(), L(), uq()) for _ in range(3)]))])))
        sc.ev1('d2exp_casehead (%s, mkcaskind (0), i2nvresstate_nil, %s, %s)' % (L(), sc.dlist(uqs(2)), sc.lst('c2laulst', ['K_c2lau (%s, %s, %s, 0, 0, %s)' % (L(), sc.lst('p2atlst', ['p2at_any (%s)' % L()]),
              sc.lst('gm2atlst', ['K_gm2at (%s, %s, ON_p2atopt ())' % (L(), uq()), 'K_gm2at (%s, %s, ON_p2atopt ())' % (L(), uq())]), uq()) for _ in range(2)])))
        sc.ev1('d2exp_applst (%s, %s, %s)' % (L(), uq(), sc.lst('d2exparglst', [sc.dyn(uqs(2)), sc.dyn(uqs(2))])))
        sc.ev1('d2exp_tmpid (%s, %s, %s)' % (L(), uq(), sc.lst('t2mpmarglst', [])))
        sc.ev1('d2exp_sing (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_ptrof (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_viewat (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_deref (%s, mkdsym (%s, "x"), %s)' % (L(), L(), uq()))
        sc.ev1('d2exp_showtype (%s, %s)' % (L(), uq()))
        sc.ev1('d2exp_vcopyenv (%s, 0, %s)' % (L(), uq()))
        sc.ev1('d2exp_exist (%s, K_s2exparg (%s, K_S2EXPARGone ()), %s)' % (L(), L(), uq()))
        sc.ev1('d2exp_ann_seff (%s, %s, K_S2EFFset (mkeffset (0)))' % (L(), uq()))
        sc.ev1('d2exp_ann_funclo (%s, %s, mkfunclo (0))' % (L(), uq()))

def fam_sub(sc, k):
    """the static substitution of the context at every position of a static expression that eval1 handles"""
    R = sc.R
    sv = sc.sv(); sw = sc.sv()
    binds = [('s', sv, 'K_M2Vscode (s2exp_int (%d))' % R.randint(1, 9)), ('s', sw, R.choice(['K_M2Verr ()', 'K_M2Vint (3)', 'K_M2Vscode (s2exp_int (0))']))]
    L = sc.L
    for x in (sv, sw):
        e = 's2exp_var (%s)' % x
        o = 'OS_s2expopt (%s)' % e
        sc.ev1('d2exp_extval (%s, %s, "e")' % (L(), e), binds)
        sc.ev1('d2exp_extfcall (%s, %s, "f", %s)' % (L(), e, sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_extmcall (%s, %s, %s, "m", %s)' % (L(), e, sc.num(1), sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_sifhead (%s, %s, %s, %s, %s)' % (L(), 'i2nvresstate_make (%s, %s, %s)' % (sc.lst('s2varlst', [x]), sc.lst('s2explst', [e]), sc.lst('i2nvarglst', ['i2nvarg_make (%s, %s)' % (sc.dv(), o)])), e, sc.num(1), sc.num(2)), binds)
        sc.ev1('d2exp_ifhead (%s, %s, %s, %s, ON_d2expopt ())' % (L(), 'i2nvresstate_make (%s, %s, %s)' % (sc.lst('s2varlst', [x]), sc.lst('s2explst', [e]), sc.lst('i2nvarglst', ['i2nvarg_make (%s, %s)' % (sc.dv(), o), 'i2nvarg_make (%s, ON_s2expopt ())' % sc.dv()])), sc.num(1), sc.num(2)), binds)
        sc.ev1('d2exp_lst (%s, 0, %s, %s)' % (L(), o, sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_arrinit (%s, %s, ON_d2expopt (), %s)' % (L(), e, sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_arrpsz (%s, %s, %s)' % (L(), o, sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_ann_type (%s, %s, %s)' % (L(), sc.num(1), e), binds)
        sc.ev1('d2exp_tmpid (%s, %s, %s)' % (L(), sc.num(1), sc.lst('t2mpmarglst', ['t2mpmarg_make (%s, %s)' % (L(), sc.lst('s2explst', [e, 's2exp_int (1)']))])), binds)
        sc.ev1('d2exp_con (%s, %s, %s, %s, 0, %s, %s)' % (L(), sc.handle('d2con'), L(), sc.lst('s2exparglst', ['K_s2exparg (%s, K_S2EXPARGseq (%s))' % (L(), sc.lst('s2explst', [e]))]), L(), sc.dlist([sc.num(1)])), binds)
        sc.ev1('d2exp_lam_dyn (%s, 0, 0, %s, %s)' % (L(), sc.lst('p2atlst', ['p2at_ann (%s, p2at_any (%s), %s)' % (L(), L(), e)]), sc.num(1)), binds)
        sc.ev1('d2exp_let (%s, %s, %s)' % (L(), sc.lst('d2eclist', ['K_d2ecl (%s, K_D2Cvaldecs (mkvalkind (0), %s))' % (L(), sc.lst('v2aldeclst', ['K_v2aldec (%s, p2at_any (%s), %s, %s)' % (L(), L(), sc.num(1), o)]))]), sc.num(2)), binds)
        sc.ev1('d2exp_let (%s, %s, %s)' % (L(), sc.lst('d2eclist', ['K_d2ecl (%s, K_D2Cvaldecs_rec (mkvalkind (0), %s))' % (L(), sc.lst('v2aldeclst', ['K_v2aldec (%s, p2at_any (%s), %s, %s)' % (L(), L(), sc.num(1), o)]))]), sc.num(2)), binds)
        sc.ev1('d2exp_casehead (%s, mkcaskind (0), i2nvresstate_nil, %s, %s)' % (L(), sc.dlist([sc.num(1)]), sc.lst('c2laulst', ['K_c2lau (%s, %s, %s, 0, 0, %s)' % (L(), sc.lst('p2atlst', ['p2at_ann (%s, p2at_any (%s), %s)' % (L(), L(), e)]), sc.lst('gm2atlst', ['K_gm2at (%s, %s, OS_p2atopt (p2at_ann (%s, p2at_any (%s), %s)))' % (L(), sc.num(1), L(), L(), e)]), sc.num(2))])), binds)
        sc.ev1('d2exp_exist (%s, K_s2exparg (%s, K_S2EXPARGseq (%s)), %s)' % (L(), L(), sc.lst('s2explst', [e]), sc.num(1)), binds)
    # the static substitution of the direct call
    for x in (sv, sw):
        sc.do('{ %s val sub = stasub_make_evalctx ctx val r = s2exp_subst (sub, s2exp_var (%s)) val () = (dd_s2exp r; dd_nl ()) val () = stasub_free sub%s }' % (sc.pre(binds), x, SC_POST))
    # the REAL hnfize / syneq of pats_staexp2_util2 (no stubs any more): beta redexes after the substitution, applications of lambdas, nested
    for x in (sv, sw):
        v1 = sc.sv(); v2 = sc.sv()
        red = 's2exp_app_srt (s2rt_t0ype, s2exp_lam (%s, s2exp_var (%s)), %s)' % (sc.lst('s2varlst', [v1]), v1, sc.lst('s2explst', ['s2exp_var (%s)' % x]))
        red2 = 's2exp_app_srt (s2rt_t0ype, s2exp_lam (%s, s2exp_app_srt (s2rt_t0ype, s2exp_lam (%s, s2exp_var (%s)), %s)), %s)' % (
            sc.lst('s2varlst', [v1]), sc.lst('s2varlst', [v2]), v2, sc.lst('s2explst', ['s2exp_var (%s)' % v1]), sc.lst('s2explst', ['s2exp_var (%s)' % x]))
        for ee in (red, red2, 's2exp_var (%s)' % x):
            sc.do('{ %s val sub = stasub_make_evalctx ctx val r = s2exp_subst (sub, %s) val () = (dd_s2exp r; dd_nl ())'
                  ' val h = s2exp_hnfize (r) val () = (dd_s2exp h; dd_nl ()) val () = (dd_s2exp (s2hnf2exp (s2exp2hnf (r))); dd_nl ())'
                  ' val () = (print_bool (s2exp_syneq (r, h)); print_newline ()) val () = (print_bool (s2exp_syneq (h, s2exp_int (%d))); print_newline ())'
                  ' val () = (print_bool (s2explst_syneq (%s, %s)); print_newline ()) val () = stasub_free sub%s }' % (
                  sc.pre(binds), ee, R.randint(1, 9), sc.lst('s2explst', [ee]), sc.lst('s2explst', [ee, 's2exp_int (1)']), SC_POST))

# the scenarios that end the process: run one at a time by m2exit.sh (the environment variable M2EXIT=n), never in the main program.
# 1-5: the patterns that eval1_p2at does not support (exitloc); 6, 7: a macro applied insufficiently (the MatchError of the ATS1 [val-list_cons])
def exit_scenarios(G, R):
    scs = []
    def mk(n):
        sc = MSc(G, R, 'sx_%d' % n)
        scs.append(sc)
        return sc
    for n, pat in ((1, 'p2at_refas (%s, %s, p2at_any (%s))'), (2, 'p2at_exist (%s, %s, p2at_any (%s))'), (3, 'p2at_vbox (%s, %s)'),
                   (4, 'p2at_list (%s, 0, %s)'), (5, 'p2at_errpat (%s)')):
        sc = mk(n)
        v = sc.dv(); s_ = sc.sv()
        if n == 1: p = pat % (sc.L(), v, sc.L())
        elif n == 2: p = pat % (sc.L(), sc.lst('s2varlst', [s_]), sc.L())
        elif n == 3: p = pat % (sc.L(), v)
        elif n == 4: p = pat % (sc.L(), sc.lst('p2atlst', ['p2at_any (%s)' % sc.L()]))
        else: p = pat % sc.L()
        sc.ev1('d2exp_lam_dyn (%s, 0, 0, %s, %s)' % (sc.L(), sc.lst('p2atlst', ['p2at_var (%s, %s)' % (sc.L(), v), p]), sc.num(1)))
        sc.ev1(sc.num(2))
    for n, kind in ((6, 1), (7, 0)):
        sc = mk(n)
        x, y = sc.dv(), sc.dv()
        m = sc.mkmac(kind, [('d', [x]), ('d', [y])], sc.op('+', [sc.var(x), sc.var(y)]))
        sc.ev0(sc.macapp(m, [sc.dyn([sc.num(1)]), sc.dyn([sc.num(2)])]))
        if kind == 1: sc.ev0(sc.macapp(m, [sc.dyn([sc.num(1)])]))
        else: sc.ev1(sc.macapp(m, [sc.dyn([sc.num(1)])]))
        sc.ev0(sc.num(3))
    return scs

FAMILIES = [
    ('lit', fam_lit, 6), ('ops', fam_ops, 4), ('ifs', fam_ifs, 5), ('syn', fam_syn, 6), ('lift', fam_lift, 4), ('ctx', fam_ctx, 6),
    ('order', fam_order, 2), ('sub', fam_sub, 3), ('alph', fam_alph, 6), ('mlong', fam_mlong, 5), ('mshort', fam_mshort, 5), ('eval1', fam_eval1, 8), ('eval1b', fam_eval1b, 8),
]

def main(G, write_chunks):
    R = random.Random(SEED)
    scs = []
    for name, fam, n in FAMILIES:
        for i in range(max(1, int(round(n * SCALE)))):
            sc = MSc(G, R, 'sm_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = sc.text()
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1500:
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    xs = exit_scenarios(G, R)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    # the last chunk: the scenarios that end the process, run one at a time by the driver (M2EXIT=n)
    k = len(bodies)
    body = ''.join(sc.text() for sc in xs)
    body += 'fun tc%d_body (): void = {\n  val n = m2_exit_arg ()\n' % k + ''.join('  val () = if n = %d then %s ()\n' % (i + 1, sc.name) for i, sc in enumerate(xs)) + '}\n'
    bodies.append(body)
    write_chunks(G, bodies)
    print('m2_cases: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))
