# the problems of the test of the constraint solver (see c3_gen.py): a problem is a line of operations of the interpreter (c3_ops.py)
import os, random, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import s2_cases, s2_cases2, c3_ops

NAMES = {}
for i, (n, a, b, k) in enumerate(c3_ops.OPS): NAMES[n] = (i + 1, a)
SC = c3_ops.SORTCODE

class Prob:
    """a problem: the operations of one line"""
    def __init__(self):
        self.w = []
        self.nreg = {}
    def op(self, name, *args):
        code, spec = NAMES[name]
        specs = spec.split() if spec else []
        self.w.append(str(code))
        j = 0
        for s in specs:
            n, t = s.split(':')
            a = args[j]; j += 1
            if t[0] == 'l':
                self.w.append(str(len(a)))
                self.w.extend(str(x) for x in a)
            else:
                self.w.append(str(a))
        assert j == len(args), (name, args)
    def line(self):
        return ' '.join(self.w)

PERVIDX = dict((n, i) for i, (n, a, r) in enumerate(s2_cases2.PERV))
PERVRES = dict((n, SC[r]) for n, a, r in s2_cases2.PERV)

# ---------------------------------------------------------------------------------------------------------------------------------------
# the generators
class G:
    """the state of a problem under construction: the registers (the next free index of each type), the random generator, the kind of integers"""
    BIGS = ['4294967296', '9223372036854775807', '9223372036854775808', '18446744073709551617', '123456789012345678901234567890', '2147483648', '1000000007']
    def __init__(self, R, kind='gmp'):
        self.R = R; self.p = Prob(); self.kind = kind
        self.n = {}
        self.vars = []; self.bvars = []; self.avars = []; self.csts = []; self.bcsts = []; self.dvars = []
        self.hyps = []
        self.carity = {}
    def new(self, t):
        k = self.n.get(t, 0); self.n[t] = k + 1; return k
    def op(self, *a): self.p.op(*a)
    # ---- cells
    def var(self, srt='int'):
        k = self.new('V'); self.op('MKV', k, SC[srt], 'v%d' % k)
        (self.vars if srt == 'int' else self.bvars if srt == 'bool' else self.avars).append(k)
        return k
    def cst(self, args, res):
        """an abstract static constant of sort (args) -> res"""
        s = []
        for a in args:
            r = self.new('S'); self.op('SRT', r, SC[a]); s.append(r)
        rr = self.new('S'); self.op('SRT', rr, SC[res])
        if args:
            f = self.new('S'); self.op('SRTF', f, s, rr); srt = f
        else: srt = rr
        c = self.new('C'); self.op('MKC', c, 'c%d' % c, self.R.randint(0, 19), srt)
        self.carity[c] = len(args)
        return c
    def pv(self, name):
        c = self.new('C'); self.op('PV', c, PERVIDX[name]); return c
    # ---- static expressions
    def e_var(self, v):
        e = self.new('E'); self.op('EV', e, v); return e
    def e_int(self, i):
        e = self.new('E'); self.op('EI', e, i); return e
    def e_big(self, s):
        e = self.new('E'); self.op('EIB', e, s); return e
    def e_bool(self, b):
        e = self.new('E'); self.op('EB', e, 1 if b else 0); return e
    def e_p(self, name, args):
        if not args:
            return self.e_cst(self.pv(name))
        e = self.new('E'); self.op('EP', e, PERVIDX[name], args, PERVRES[name]); return e
    def e_app(self, c, args, res):
        s = self.new('S'); self.op('SRT', s, SC[res])
        f = self.new('E'); self.op('EC', f, c)
        e = self.new('E'); self.op('EAPP', e, f, args, s); return e
    def e_cst(self, c):
        e = self.new('E'); self.op('EC', e, c); return e
    # ---- random expressions
    def const_int(self):
        R = self.R
        c = R.random()
        if c < 0.55: return R.randint(0, 6)
        if c < 0.8: return R.randint(-8, 40)
        if c < 0.9 or self.kind == 'int': return R.choice([0, 1, 2, 3, 100, -1])
        return R.randint(-2**31, 2**31)
    def int_exp(self, d):
        R = self.R
        if d <= 0 or R.random() < 0.18:
            c = R.random()
            if self.vars and c < 0.6: return self.e_var(R.choice(self.vars))
            if c < 0.85 or self.kind == 'int' or R.random() < 0.7: return self.e_int(self.const_int())
            return self.e_big(R.choice(self.BIGS))
        k = R.choices(['add', 'sub', 'neg', 'mulc', 'mulv', 'div', 'ndiv', 'idiv', 'abs', 'sgn', 'max', 'min', 'ifint', 'app', 'sizeof', 'addr', 'metdec'],
                      [10, 10, 3, 6, 3, 3, 2, 2, 2, 1, 2, 2, 2, 2, 1, 1, 1])[0]
        if k in ('add', 'sub'):
            return self.e_p(k + '_int_int', [self.int_exp(d - 1), self.int_exp(d - 1)])
        if k == 'neg': return self.e_p('neg_int', [self.int_exp(d - 1)])
        if k == 'mulc':
            a = self.e_int(R.choice([-3, -2, -1, 0, 1, 2, 3, 5, 7, 10])); b = self.int_exp(d - 1)
            return self.e_p('mul_int_int', [a, b] if R.random() < 0.5 else [b, a])
        if k == 'mulv': return self.e_p('mul_int_int', [self.int_exp(d - 1), self.int_exp(d - 1)])
        if k in ('div', 'ndiv', 'idiv'):
            a = self.int_exp(d - 1); b = self.e_int(R.choice([-3, -2, 1, 2, 3, 4, 0]) if R.random() < 0.85 else R.randint(-5, 5))
            if R.random() < 0.1: b = self.int_exp(d - 1)
            return self.e_p(k + '_int_int', [a, b])
        if k == 'abs': return self.e_p('abs_int', [self.int_exp(d - 1)])
        if k == 'sgn': return self.e_p('sgn_int', [self.int_exp(d - 1)])
        if k in ('max', 'min'): return self.e_p(k + '_int_int', [self.int_exp(d - 1), self.int_exp(d - 1)])
        if k == 'ifint': return self.e_p('ifint_bool_int_int', [self.bool_exp(d - 1), self.int_exp(d - 1), self.int_exp(d - 1)])
        if k == 'app' and R.random() < 0.15:
            ar = R.randint(1, 2); ss = []
            for _ in range(ar): ss.append(self.srt('int'))
            rr = self.srt('int'); f = self.new('S'); self.op('SRTF', f, ss, rr)
            fv = self.new('V'); self.op('MKVS', fv, f, 'fv%d' % fv)
            hd = self.e_var(fv); sr = self.srt('int')
            e = self.new('E'); self.op('EAPP', e, hd, [self.int_exp(d - 1) for _ in range(ar)], sr); return e
        if k == 'app':
            if not self.csts or R.random() < 0.3: self.csts.append(self.cst(['int'] * R.randint(1, 2), 'int'))
            c = R.choice(self.csts)
            return self.e_app(c, [self.int_exp(d - 1) for _ in range(self.arity(c))], 'int')
        if k == 'sizeof':
            e = self.new('E'); self.op('ESZ', e, self.int_exp(0)); return e
        if k == 'addr':
            return self.e_p('int_of_addr', [self.addr_exp(d - 1)])
        return self.int_exp(d - 1)
    def arity(self, c):
        return self.carity.get(c, 1)
    def addr_exp(self, d):
        R = self.R
        if d <= 0 or R.random() < 0.3:
            if self.avars and R.random() < 0.7: return self.e_var(R.choice(self.avars))
            if R.random() < 0.3: return self.e_p('null_addr', [])
            return self.e_p('addr_of_int', [self.int_exp(0)])
        k = R.choice(['add', 'sub', 'subaa', 'cast'])
        if k == 'add': return self.e_p('add_addr_int', [self.addr_exp(d - 1), self.int_exp(d - 1)])
        if k == 'sub': return self.e_p('sub_addr_int', [self.addr_exp(d - 1), self.int_exp(d - 1)])
        if k == 'cast': return self.e_p('addr_of_int', [self.int_exp(d - 1)])
        return self.e_p('addr_of_int', [self.e_p('sub_addr_addr', [self.addr_exp(d - 1), self.addr_exp(d - 1)])])
    def bool_exp(self, d):
        R = self.R
        if d <= 0 or R.random() < 0.15:
            c = R.random()
            if self.bvars and c < 0.5: return self.e_var(R.choice(self.bvars))
            if c < 0.7: return self.e_p('true_bool', []) if R.random() < 0.5 else self.e_p('false_bool', [])
            return self.e_bool(R.random() < 0.5)
        k = R.choices(['cmp', 'neg', 'add', 'mul', 'eq', 'neq', 'addrcmp', 'app', 'clscmp', 'eqeq', 'metdec', 'top'], [30, 5, 4, 4, 2, 2, 5, 2, 2, 3, 3, 1])[0]
        if k == 'cmp':
            op = R.choice(['lt', 'lte', 'gt', 'gte', 'eq', 'neq'])
            return self.e_p(op + '_int_int', [self.int_exp(d - 1), self.int_exp(d - 1)])
        if k == 'neg': return self.e_p('neg_bool', [self.bool_exp(d - 1)])
        if k in ('add', 'mul', 'eq', 'neq'): return self.e_p(k + '_bool_bool', [self.bool_exp(d - 1), self.bool_exp(d - 1)])
        if k == 'addrcmp':
            op = R.choice(['lt', 'lte', 'gt', 'gte', 'eq', 'neq'])
            return self.e_p(op + '_addr_addr', [self.addr_exp(d - 1), self.addr_exp(d - 1)])
        if k == 'app':
            if not self.bcsts or R.random() < 0.3: self.bcsts.append(self.cst(['int'], 'bool'))
            return self.e_app(R.choice(self.bcsts), [self.int_exp(d - 1)], 'bool')
        if k == 'clscmp':
            def cls():
                if R.random() < 0.35:
                    v = self.new('V'); self.op('MKV', v, SC['cls'], 'cv%d' % v); return self.e_var(v)
                a = self.new('C'); self.op('MKC', a, 'k%d' % a, R.randint(0, 19), self.srt('cls')); return self.e_cst(a)
            if R.random() < 0.4:
                # classes with a super class: [B <= A] holds, [A <= B] does not
                ca = self.new('C'); self.op('MKC', ca, 'ka%d' % ca, R.randint(0, 19), self.srt('cls'))
                cb = self.new('C'); self.op('MKC', cb, 'kb%d' % cb, R.randint(0, 19), self.srt('cls'))
                self.op('SUPCLS', cb, ca)
                if R.random() < 0.4:
                    cc = self.new('C'); self.op('MKC', cc, 'kc%d' % cc, R.randint(0, 19), self.srt('cls')); self.op('SUPCLS', cc, cb)
                    ca2, cb2 = (ca, cc) if R.random() < 0.5 else (cc, ca)
                    return self.e_p('lte_cls_cls', [self.e_cst(ca2), self.e_cst(cb2)])
                a, b = (self.e_cst(ca), self.e_cst(cb))
                return self.e_p('lte_cls_cls', [a, b] if R.random() < 0.5 else [b, a])
            a = cls(); b = a if R.random() < 0.3 else cls()
            return self.e_p('lte_cls_cls', [a, b])
        if k == 'eqeq':
            return self.new_eqeq(d)
        if k == 'metdec' and R.random() < 0.4:
            # a metric on terms that are not integers: the structural order (subterms)
            n = R.randint(1, 2)
            a = [self.types_exp(R.randint(0, 2)) for _ in range(n)]
            b = [self.types_exp(R.randint(0, 3)) if R.random() < 0.7 else self.int_exp(1) for _ in range(n if R.random() < 0.85 else R.randint(1, 3))]
            if R.random() < 0.5: a, b = b, a
            e = self.new('E'); self.op('EMET', e, a, b); return e
        if k == 'metdec':
            n = R.randint(1, 3)
            a = [self.int_exp(d - 1) for _ in range(n)]; b = [self.int_exp(d - 1) for _ in range(n if R.random() < 0.8 else R.randint(0, 3))]
            e = self.new('E'); self.op('EMET', e, a, b); return e
        e = self.new('E'); self.op('ETOP', e, R.randint(0, 3), self.int_exp(0)); return e
    def types_exp(self, d):
        """a term of the sort [types]: nil, cons, variables"""
        R = self.R
        if not hasattr(self, 'tvars'): self.tvars = []
        if d <= 0 or R.random() < 0.25:
            if self.tvars and R.random() < 0.5: return self.e_var(R.choice(self.tvars))
            if R.random() < 0.3:
                v = self.new('V'); self.op('MKV', v, SC['types'], 'tv%d' % v); self.tvars.append(v); return self.e_var(v)
            return self.e_p('types_nil', [])
        h = self.new('C'); self.op('MKC', h, 'h%d' % h, R.randint(0, 19), self.srt('t0ype'))
        return self.e_p('types_cons', [self.e_cst(h) if R.random() < 0.6 else self.int_exp(0), self.types_exp(d - 1)])
    def new_eqeq(self, d):
        R = self.R
        c = R.random()
        if c < 0.5: a, b = self.int_exp(d - 1), self.int_exp(d - 1)
        elif c < 0.7: a, b = self.bool_exp(d - 1), self.bool_exp(d - 1)
        elif c < 0.85: a, b = self.addr_exp(d - 1), self.addr_exp(d - 1)
        else: a, b = self.int_exp(0), self.bool_exp(0)
        e = self.new('E'); self.op('EEQ', e, a, b); return e
    def newn(self, R):
        n = self.new('N'); self.op('NI', n, R.choice([-2, 1, 3, 0, 5])); return n
    def srt(self, name):
        s = self.new('S'); self.op('SRT', s, SC[name]); return s


# ---------------------------------------------------------------------------------------------------------------------------------------
def setup_vars(g, nint=None, nb=None, na=None):
    R = g.R
    nint = R.randint(1, 4) if nint is None else nint
    nb = (1 if R.random() < 0.25 else 0) if nb is None else nb
    na = (1 if R.random() < 0.2 else 0) if na is None else na
    for _ in range(nint): g.var('int')
    for _ in range(nb): g.var('bool')
    for _ in range(na): g.var('addr')

def fam_make(R, kind):
    """s3exp_make / lintize / the environment / s3explst_solve_s2exp on random static expressions"""
    g = G(R, kind); setup_vars(g)
    g.op('ENV_NEW')
    allv = g.vars + g.bvars + g.avars
    for v in allv:
        if R.random() < 0.8: g.op('ENV_ADDV', v)
    for _ in range(R.randint(0, 3)):
        e = g.bool_exp(R.randint(1, 3))
        x = g.new('X'); g.op('MAKE', x, e)
        if R.random() < 0.7:
            y = g.new('X'); g.op('LINT', y, x); g.op('ENV_ADDB', y)
        if R.random() < 0.15: g.op('ENV_PUSH')
        if R.random() < 0.1: g.op('ENV_POP')
    for _ in range(R.randint(1, 2)):
        e = g.bool_exp(R.randint(1, 3))
        g.op('SOLVE', R.randint(0, 9), e)
    if R.random() < 0.5: g.op('ENV_EXT')
    if R.random() < 0.3:
        e = g.int_exp(2); x = g.new('X'); g.op('MAKE', x, e); y = g.new('X'); g.op('LINT', y, x)
        g.op('ENV_FNL', y)
    if R.random() < 0.25:
        # the application of a term that is not a constant: the head and the arguments are made in this order (their variables get the next stamps)
        hd = g.int_exp(2); sr = g.srt('int')
        ap = g.new('E'); g.op('EAPP', ap, hd, [g.int_exp(2) for _ in range(R.randint(1, 2))], sr)
        x = g.new('X'); g.op('MAKE', x, ap)
    return g.p.line()

def fam_real(R, kind):
    """the shapes of the constraints of the type checker: bounds of arrays, lengths of lists, metrics, loops"""
    g = G(R, kind)
    n = g.var('int'); i = g.var('int'); m = g.var('int')
    en, ei, em = g.e_var(n), g.e_var(i), g.e_var(m)
    zero = g.e_int(0); one = g.e_int(1)
    g.op('ENV_NEW'); g.op('ENV_ADDV', n); g.op('ENV_ADDV', i); g.op('ENV_ADDV', m)
    def hyp(e):
        x = g.new('X'); g.op('MAKE', x, e); y = g.new('X'); g.op('LINT', y, x); g.op('ENV_ADDB', y)
    k = R.choice(['bounds', 'lens', 'metric', 'loop', 'divmod', 'arith', 'sub'])
    if k == 'bounds':
        hyp(g.e_p('lte_int_int', [zero, ei])); hyp(g.e_p('lt_int_int', [ei, en]))
        c = R.choice([['lt_int_int', [ei, en]], ['lte_int_int', [g.e_p('add_int_int', [ei, one]), en]], ['gte_int_int', [en, g.e_p('add_int_int', [ei, one])]],
                      ['lte_int_int', [zero, g.e_p('sub_int_int', [en, one])]], ['lt_int_int', [g.e_p('sub_int_int', [ei, one]), en]],
                      ['lte_int_int', [g.e_p('add_int_int', [ei, one]), g.e_p('sub_int_int', [en, one])]]])
        g.op('SOLVE', R.randint(0, 9), g.e_p(c[0], c[1]))
    elif k == 'lens':
        s = g.e_p('add_int_int', [en, em])
        hyp(g.e_p('gte_int_int', [en, zero])); hyp(g.e_p('gte_int_int', [em, zero]))
        c = R.choice([['eq_int_int', [s, g.e_p('add_int_int', [em, en])]], ['gte_int_int', [s, en]], ['gte_int_int', [s, g.e_p('add_int_int', [en, one])]],
                      ['eq_int_int', [g.e_p('sub_int_int', [s, em]), en]]])
        g.op('SOLVE', R.randint(0, 9), g.e_p(c[0], c[1]))
    elif k == 'metric':
        hyp(g.e_p('gt_int_int', [en, zero]))
        nm1 = g.e_p('sub_int_int', [en, one])
        if R.random() < 0.5:
            e = g.new('E'); g.op('EMET', e, [nm1], [en]); g.op('SOLVE', R.randint(0, 9), e)
        else:
            e = g.new('E'); g.op('EMET', e, [en, nm1], [en, en]); g.op('SOLVE', R.randint(0, 9), e)
        g.op('SOLVE', R.randint(0, 9), g.e_p('gte_int_int', [nm1, zero]))
    elif k == 'loop':
        hyp(g.e_p('lte_int_int', [ei, en])); hyp(g.e_p('lt_int_int', [ei, en]))
        j = g.e_p('add_int_int', [ei, one])
        g.op('SOLVE', R.randint(0, 9), g.e_p('lte_int_int', [j, en]))
    elif k == 'divmod':
        hyp(g.e_p('gte_int_int', [en, zero]))
        d = g.e_int(R.choice([2, 3, 4, -2]))
        q = g.e_p(R.choice(['div_int_int', 'idiv_int_int', 'ndiv_int_int']), [en, d])
        g.op('SOLVE', R.randint(0, 9), g.e_p(R.choice(['lte_int_int', 'gte_int_int']), [q, en]))
    elif k == 'arith':
        a = g.e_p('mul_int_int', [g.e_int(R.randint(2, 5)), ei]); hyp(g.e_p('gte_int_int', [ei, zero]))
        g.op('SOLVE', R.randint(0, 9), g.e_p('gte_int_int', [a, ei]))
        g.op('SOLVE', R.randint(0, 9), g.e_p('gte_int_int', [g.e_p('mul_int_int', [ei, ei]), zero]))
    else:
        hyp(g.e_p('lte_int_int', [em, en]))
        g.op('SOLVE', R.randint(0, 9), g.e_p('gte_int_int', [g.e_p('sub_int_int', [en, em]), zero]))
        g.op('SOLVE', R.randint(0, 9), g.e_p('gt_int_int', [g.e_p('sub_int_int', [en, em]), zero]))
    if R.random() < 0.3: g.op('ENV_EXT')
    return g.p.line()

def s3_exp(g, d, ints):
    """a random s3exp built by the smart constructors (register of type X)"""
    R = g.R
    if d <= 0 or R.random() < 0.2:
        c = R.random()
        if c < 0.5 and ints:
            x = g.new('X'); g.op('Xvar', x, R.choice(ints)); return x
        if c < 0.6:
            x = g.new('X'); g.op('Xconst', x, R.choice([0, 1, 4, 5, 6, 7])); return x
        x = g.new('X'); g.op('Xint', x, g.const_int()); return x
    k = R.choice(['iadd', 'isub', 'imul', 'ineg', 'isucc', 'ipred', 'icff', 'isum', 'iadd', 'isub'])
    x = g.new('X')
    if k in ('iadd', 'isub', 'imul'):
        a = s3_exp(g, d - 1, ints); b = s3_exp(g, d - 1, ints); g.op('X' + k, x, a, b)
    elif k in ('ineg', 'isucc', 'ipred'):
        a = s3_exp(g, d - 1, ints); g.op('X' + k, x, a)
    elif k == 'icff':
        c = g.new('N')
        if R.random() < 0.8 or g.kind == 'int': g.op('NI', c, R.choice([-3, -1, 0, 1, 2, 5, 7]))
        else: g.op('NS', c, R.choice(g.BIGS))
        a = s3_exp(g, d - 1, ints); g.op('Xicff', x, c, a)
    else:
        xs = [s3_exp(g, d - 1, ints) for _ in range(R.randint(0, 3))]; g.op('Xisum', x, xs)
    return x

def s3_bool(g, d, ints, bools):
    R = g.R
    if d <= 0 or R.random() < 0.15:
        c = R.random(); x = g.new('X')
        if bools and c < 0.5: g.op('Xvar', x, R.choice(bools)) if R.random() < 0.5 else g.op('Xbvar', x, R.choice(bools))
        else: g.op('Xbool', x, R.randint(0, 1))
        return x
    k = R.choice(['cmp', 'cmp', 'cmp', 'bneg', 'badd', 'bmul', 'beq', 'bneq', 'bineq'])
    x = g.new('X')
    if k == 'cmp':
        a = s3_exp(g, d - 1, ints); b = s3_exp(g, d - 1, ints)
        g.op('X' + R.choice(['ilt', 'ilte', 'igt', 'igte', 'ieq', 'ineq']), x, a, b)
    elif k == 'bneg':
        a = s3_bool(g, d - 1, ints, bools); g.op('Xbneg', x, a)
    elif k == 'bineq':
        a = s3_exp(g, d - 1, ints); g.op('Xbineq', x, R.choice([-2, -1, 1, 2]), a)
    else:
        a = s3_bool(g, d - 1, ints, bools); b = s3_bool(g, d - 1, ints, bools); g.op('X' + k, x, a, b)
    return x

def fam_s3(R, kind):
    """the algebra of s3exp: smart constructors, queries, lintize, raw nodes"""
    g = G(R, kind); setup_vars(g, R.randint(1, 4), R.randint(0, 1), 0)
    ints = g.vars; bools = g.bvars
    g.op('ENV_NEW')
    xs = [s3_exp(g, R.randint(1, 3), ints) for _ in range(R.randint(2, 4))]
    bs = [s3_bool(g, R.randint(1, 3), ints, bools) for _ in range(R.randint(1, 2))]
    for x in xs[:2] + bs[:1]:
        if R.random() < 0.6: g.op('QSRT', x)
        if R.random() < 0.6: g.op('QFVS', x)
    a = R.choice(xs); b = R.choice(xs)
    g.op('QSYN', a, b); g.op('QSYN', a, a); g.op('QGTE', a, b); g.op('QGTE', b, a)
    # the terms of the sums: variables, constants, nonlinear atoms
    cs = g.cst([], 'int'); xcs = g.new('X'); g.op('Xcst', xcs, cs)
    cs2 = g.cst([], 'int'); xcs2 = g.new('X'); g.op('Xcst', xcs2, cs2)
    pool = list(xs) + list(bs) + [xcs, xcs2]
    if ints: pool.append(g.new('X')); g.op('Xvar', pool[-1], ints[0])
    pool.append(g.new('X')); g.op('Xconst', pool[-1], R.choice(range(8)))
    if len(ints) > 1:
        m = g.new('X'); g.op('Ximul', m, pool[-2] if len(pool) > 1 else xs[0], xs[0]); pool.append(m)
    for _ in range(R.randint(2, 6)):
        u = R.choice(pool); w = R.choice(pool)
        g.op('QSYN', u, w); g.op('QGTE', u, w)
    for _ in range(R.randint(1, 3)):
        u = R.choice(pool); w = R.choice(pool); r = g.new('X'); g.op(R.choice(['Xiadd', 'Xisub', 'Ximul']), r, u, w)
    if R.random() < 0.5 and ints:
        # the raw nodes: equal and different pairs
        sr = g.new('S'); g.op('SRT', sr, SC['int'])
        d1 = g.new('X'); g.op('S3Ebdom', d1, ints[0]); d2 = g.new('X'); g.op('S3Ebdom', d2, ints[0]); g.op('QSYN', d1, d2); g.op('QSYN', d1, pool[0])
        e1 = g.new('X'); g.op('S3Eerr', e1, sr); g.op('QSYN', e1, e1)
        k1 = g.new('X'); g.op('S3Ebineq', k1, 1, xs[0]); k2 = g.new('X'); g.op('S3Ebineq', k2, 2, xs[0]); k3 = g.new('X'); g.op('S3Ebineq', k3, 1, xs[0])
        g.op('QSYN', k1, k2); g.op('QSYN', k1, k3); g.op('QSYN', k2, k3)
        c1 = g.new('N'); g.op('NI', c1, 2); c2 = g.new('N'); g.op('NI', c2, 3)
        f1 = g.new('X'); g.op('S3Eicff', f1, c1, xs[0]); f2 = g.new('X'); g.op('S3Eicff', f2, c2, xs[0]); g.op('QSYN', f1, f2); g.op('QSYN', f1, f1)
        a1 = g.new('X'); g.op('S3Eapp', a1, xcs, [xs[0]]); a2 = g.new('X'); g.op('S3Eapp', a2, xcs, [xs[0], xs[1]]); a3 = g.new('X'); g.op('S3Eapp', a3, xcs, [xs[0]])
        g.op('QSYN', a1, a2); g.op('QSYN', a2, a1); g.op('QSYN', a1, a3); g.op('QSYN', a3, a3)
        i1 = g.new('X'); g.op('S3Eisum', i1, [xs[0]]); i2 = g.new('X'); g.op('S3Eisum', i2, [xs[0], xs[1]]); g.op('QSYN', i1, i2); g.op('QSYN', i2, i1)
        z = g.new('X'); g.op('S3Esizeof', z, g.e_var(ints[0])); z2 = g.new('X'); g.op('S3Esizeof', z2, g.e_var(ints[0])); g.op('QSYN', z, z2); g.op('QSYN', z, z)
    if R.random() < 0.3: g.op('PRXL', pool[:R.randint(0, 3)])
    # a structural twin: the same operations on the same registers
    t = g.new('X'); g.op('Xiadd', t, a, b); u = g.new('X'); g.op('Xiadd', u, a, b); g.op('QSYN', t, u)
    # nonlinear terms: lintize replaces them by variables of the environment
    for x in xs[:2] + bs[:2]:
        if R.random() < 0.7:
            y = g.new('X'); g.op('LINT', y, x)
    if R.random() < 0.5:
        # a product with an abstract constant, inside a sum, a negation, an inequality
        pc = g.new('X'); g.op('Ximul', pc, xcs, xs[0]); u1 = g.new('X'); g.op('Xiadd', u1, pc, xs[1]); u2 = g.new('X'); g.op('Xineg', u2, pc)
        ib = g.new('X'); g.op('Xigte', ib, u1, u2); nb = g.new('X'); g.op('Xbneg', nb, ib)
        bv = g.new('X'); g.op('Xbvar' if bools else 'Xbool', bv, *( [bools[0]] if bools else [1])); nb2 = g.new('X'); g.op('S3Ebneg', nb2, ib)
        for t in (pc, u1, u2, ib, nb, nb2):
            y = g.new('X'); g.op('LINT', y, t)
    if R.random() < 0.5:
        z = g.new('X'); g.op('Ximul', z, xs[0], xs[1]); y = g.new('X'); g.op('LINT', y, z)
        y2 = g.new('X'); g.op('LINT', y2, z); g.op('QSYN', y, y2)
    if R.random() < 0.3: g.op('ENV_EXT')
    # raw nodes (not normalized): the printer, the sorts and the free variables
    if R.random() < 0.6:
        r1 = g.new('X'); g.op('S3Ebadd', r1, bs[0], bs[-1]); g.op('QSRT', r1); g.op('QFVS', r1)
        r2 = g.new('X'); g.op('S3Ebineq', r2, R.choice([-2, -1, 0, 1, 2]), xs[0]); g.op('QFVS', r2)
        r3 = g.new('X'); g.op('S3Eimul', r3, xs[0], xs[-1]); g.op('QSRT', r3); g.op('QFVS', r3)
        if len(ints) > 1:
            # a raw product of two variables, alone and inside sums, inequalities and applications: lintize replaces it by a variable
            va = g.new('X'); g.op('Xvar', va, ints[0]); vb = g.new('X'); g.op('Xvar', vb, ints[1])
            rp = g.new('X'); g.op('S3Eimul', rp, va, vb)
            rs = g.new('X'); g.op('S3Eisum', rs, [va, rp]); ri = g.new('X'); g.op('S3Ebineq', ri, 2, rs)
            rn = g.new('X'); g.op('S3Ebneg', rn, ri); fc = g.cst(['int', 'int'], 'int'); xfc = g.new('X'); g.op('Xcst', xfc, fc)
            ra = g.new('X'); g.op('S3Eapp', ra, xfc, [rp, va])
            for t in (rp, rs, ri, rn, ra):
                y = g.new('X'); g.op('LINT', y, t)
        r4 = g.new('X'); g.op('S3Eisum', r4, xs); g.op('QFVS', r4)
        r5 = g.new('X'); g.op('S3Ebneq', r5, bs[0], bs[-1]); g.op('QFVS', r5)
        if len(g.vars) > 0:
            r6 = g.new('X'); g.op('S3Ebdom', r6, g.vars[0]); g.op('QFVS', r6); g.op('QSRT', r6)
            r7 = g.new('X'); g.op('S3Eiatm', r7, g.vars[:R.randint(0, 3)]); g.op('QFVS', r7); g.op('QSRT', r7)
            c8 = g.new('N'); g.op('NI', c8, R.choice([-2, 1, 3])); r8 = g.new('X'); g.op('S3Eicff', r8, c8, xs[0]); g.op('QFVS', r8)
        sr = g.new('S'); g.op('SRT', sr, SC['int'])
        r9 = g.new('X'); g.op('S3Eerr', r9, sr); g.op('QSRT', r9); g.op('QFVS', r9)
        ee = g.e_var(g.vars[0]); r10 = g.new('X'); g.op('S3Esizeof', r10, ee); g.op('QSRT', r10); g.op('QFVS', r10)
        c = g.cst(['int'], 'int'); xc = g.new('X'); g.op('Xcst', xc, c)
        r11 = g.new('X'); g.op('Xapp', r11, xc, [xs[0]]); g.op('QSRT', r11) ; g.op('QFVS', r11)
    return g.p.line()

# ---------------------------------------------------------------------------------------------------------------------------------------
# constraints
def lin(g, vals, d):
    """a linear static expression over the variables [vals] (var register -> value) and its value"""
    R = g.R
    vs = list(vals.keys())
    if d <= 0 or R.random() < 0.3:
        if vs and R.random() < 0.7:
            v = R.choice(vs); return g.e_var(v), vals[v]
        c = R.randint(-6, 12); return g.e_int(c), c
    k = R.choice(['add', 'sub', 'mulc', 'neg', 'add', 'sub'])
    if k == 'neg':
        e, v = lin(g, vals, d - 1); return g.e_p('neg_int', [e]), -v
    if k == 'mulc':
        c = R.choice([-3, -2, 2, 3, 4, 0, 1]); ce = g.e_int(c); e, v = lin(g, vals, d - 1)
        return (g.e_p('mul_int_int', [ce, e]) if R.random() < 0.5 else g.e_p('mul_int_int', [e, ce])), c * v
    a, va = lin(g, vals, d - 1); b, vb = lin(g, vals, d - 1)
    return (g.e_p('add_int_int', [a, b]), va + vb) if k == 'add' else (g.e_p('sub_int_int', [a, b]), va - vb)

def cmp_exp(g, vals, truth, d=2):
    """a comparison of two linear expressions whose truth value under [vals] is [truth]"""
    R = g.R
    a, va = lin(g, vals, d); b, vb = lin(g, vals, d)
    ops = [('lt', va < vb), ('lte', va <= vb), ('gt', va > vb), ('gte', va >= vb), ('eq', va == vb), ('neq', va != vb)]
    ok = [o for o, t in ops if t == truth]
    o = R.choice(ok)
    g.lastcmp = (o, a, b)
    return g.e_p(o + '_int_int', [a, b])

def hypo(g, vals, d=2):
    """an item: a hypothesis (true under the assignment); the kinds: prop, bind, eqeq"""
    R = g.R
    c = R.random()
    h = g.new('H')
    if c < 0.7:
        e = cmp_exp(g, vals, True, d); g.op('H3PROP', h, R.randint(0, 9), e); g.hyps.append(g.lastcmp)
    elif c < 0.85 and vals:
        v = R.choice(list(vals.keys())); e, val = lin(g, {}, 1)
        g.op('H3BIND', h, R.randint(0, 9), v, e)
    else:
        a, va = lin(g, vals, d)
        b = g.e_int(va)
        g.op('H3EQEQ', h, R.randint(0, 9), a, b)
    i = g.new('I'); g.op('I_HYPO', i, h); return i

def kind_reg(g):
    R = g.R
    k = g.new('T')
    c = R.random()
    if c < 0.6: g.op('KMAIN', k)
    elif c < 0.65: g.op('KISNAT', k)
    elif c < 0.7: g.op('KISDEC', k)
    elif c < 0.75: g.op('KCASE', k, R.randint(0, 2), R.randint(0, 20))
    elif c < 0.85:
        dv = g.new('D'); g.op('MKD', dv, R.randint(0, 9), 'dv%d' % dv)
        e1 = g.e_int(1); e2 = g.e_int(2)
        g.op(R.choice(['KFIN', 'KLVAR', 'KVBOX']), k, dv, e1, e2)
    elif c < 0.9: g.op('KLSTATE', k)
    elif c < 0.93:
        dv = g.new('D'); g.op('MKD', dv, R.randint(0, 9), 'dv%d' % dv); g.op('KLSTATEV', k, dv)
    elif c < 0.97: g.op('KLOOP', k, R.randint(-1, 1))
    else: g.op('KSOLV', k)
    return k

def item_list(g, vals, d, nmax=4):
    R = g.R
    its = []
    for _ in range(R.randint(0, nmax)):
        c = R.random()
        if c < 0.4: its.append(hypo(g, vals))
        elif c < 0.6 and d > 0: its.append(cnstr_item(g, vals, d - 1))
        elif c < 0.7:
            i = g.new('I'); g.op('I_CREFN', i, R.randint(0, 9)); its.append(i)
        elif c < 0.78 and d > 0:
            k = cnstr(g, vals, d - 1); i = g.new('I'); g.op('I_CREF', i, R.randint(0, 9), 1, k); its.append(i)
        elif c < 0.88 and d > 0:
            dl = []
            for _ in range(R.randint(1, 3)):
                l = g.new('IL'); g.op('LIL', l, item_list(g, vals, d - 1, 2)); dl.append(l)
            i = g.new('I'); g.op('I_DISJ', i, dl); its.append(i)
        elif c < 0.93:
            w = g.new('W'); g.op('MKVV', w, R.randint(0, 9), SC['int']); i = g.new('I'); g.op('I_SVARV', i, w); its.append(i)
        elif c < 0.97:
            e = cmp_exp(g, vals, True); i = g.new('I'); g.op('I_SOLA', i, e); its.append(i)
        else:
            if g.vars: i = g.new('I'); g.op('I_SVAR', i, R.choice(g.vars)); its.append(i)
    return its

def cnstr_item(g, vals, d):
    k = cnstr(g, vals, d); i = g.new('I'); g.op('I_CNSTR', i, k); return i

def concl(g, vals, hyp_e=None):
    R = g.R
    if g.hyps and R.random() < 0.45:
        o, a, b = R.choice(g.hyps)
        weaker = {'lt': ['lt', 'lte', 'neq'], 'lte': ['lte'], 'eq': ['eq', 'lte', 'gte'], 'gt': ['gt', 'gte', 'neq'], 'gte': ['gte'], 'neq': ['neq']}[o]
        return g.e_p(R.choice(weaker) + '_int_int', [a, b])
    return cmp_exp(g, vals, R.random() < 0.55)

def cnstr(g, vals, d):
    R = g.R
    c = R.random(); k = g.new('K')
    if d <= 0 or c < 0.35:
        e = concl(g, vals); g.op('C3PROP', k, R.randint(0, 9), e)
    elif c < 0.42:
        e = concl(g, vals); g.op('C3SOLV', k, R.randint(0, 9), e)
    elif c < 0.47:
        e = g.int_exp(1); g.op('C3ISNAT', k, R.randint(0, 9), e)
    elif c < 0.52:
        a = [g.int_exp(1) for _ in range(R.randint(1, 2))]; b = [g.int_exp(1) for _ in range(R.randint(1, 2))]
        g.op('C3ISDEC', k, R.randint(0, 9), a, b)
    elif c < 0.57:
        g.op('C3CASE', k, R.randint(0, 20), R.randint(0, 2), R.randint(0, 20))
    else:
        kd = kind_reg(g)
        its = []
        if g.vars:
            for v in vals:
                if R.random() < 0.7:
                    i = g.new('I'); g.op('I_SVAR', i, v); its.append(i)
        its += item_list(g, vals, d - 1)
        if R.random() < 0.8:
            e = concl(g, vals); kk = g.new('K'); g.op('C3PROP', kk, R.randint(0, 9), e)
            i = g.new('I'); g.op('I_CNSTR', i, kk); its.append(i)
        g.op('C3ITM', k, R.randint(0, 9), kd, its)
    return k

def fam_c3(R, kind):
    """constraints (c3nstr) and their solution by c3nstr_ats2_solve; the printer, the json, the export, the map of the constants and variables"""
    g = G(R, kind)
    vals = {}
    for _ in range(R.randint(1, 3)):
        v = g.var('int'); vals[v] = R.randint(-5, 10)
    k = cnstr(g, vals, R.randint(1, 3))
    if R.random() < 0.15: g.op('PRK', k)
    if R.random() < 0.1: g.op('JSK', k)
    if R.random() < 0.05: g.op('EXPK', k)
    if R.random() < 0.05: g.op('MAPK', k)
    g.op('RUN3', k)
    return g.p.line()

def fam_env(R, kind):
    """the environment of the solver: nonlinear terms, applications of constants, marks"""
    g = G(R, kind); setup_vars(g, R.randint(1, 3), 0, 0)
    g.op('ENV_NEW')
    for v in g.vars: g.op('ENV_ADDV', v)
    ints = g.vars
    for _ in range(R.randint(2, 6)):
        c = R.random()
        if c < 0.2:
            g.op('ENV_PUSH')
        elif c < 0.3:
            g.op('ENV_POP')
        elif c < 0.5:
            a = s3_exp(g, 2, ints); b = s3_exp(g, 1, ints); m = g.new('X'); g.op('Ximul', m, a, b)
            y = g.new('X'); g.op('LINT', y, m)
            if R.random() < 0.5: g.op('ENV_FNL', m)
        elif c < 0.65:
            cc = g.cst(['int', 'int'], 'int'); xs = [g.int_exp(1), g.int_exp(1)]
            v = g.new('V'); sr = g.srt('int'); g.op('ENV_RCS', v, sr, cc, xs)
            xs3 = [g.new('X'), g.new('X')]
            for x, e in zip(xs3, xs): g.op('MAKE', x, e)
            g.op('ENV_FCS', cc, xs3)
            # the relation that was added: c (args, v) (found as a nonlinear term, the order of its arguments)
            # (lintize replaced the head, the constant, by a variable first)
            xc = g.new('X'); g.op('Xcst', xc, cc); hv = g.new('V'); g.op('ENV_RNL', hv, xc)
            xh = g.new('X'); g.op('Xvar', xh, hv); xv = g.new('X'); g.op('Xvar', xv, v)
            for order in (xs3 + [xv], [xv] + xs3):
                ap = g.new('X'); g.op('Xapp', ap, xh, order); g.op('ENV_FNL', ap)
        elif c < 0.75:
            x = s3_exp(g, 2, ints); v = g.new('V'); g.op('ENV_RNL', v, x)
        elif c < 0.85:
            cc = g.cst(['int'], 'int'); xs = [g.int_exp(1)]
            v = g.var('int'); g.op('ENV_ACS', cc, xs, v)
        elif c < 0.92:
            v = g.var('int'); x = s3_exp(g, 1, ints); g.op('ENV_ANL', v, x)
        else:
            e = g.bool_exp(2); x = g.new('X'); g.op('MAKE', x, e); g.op('ENV_ADDB', x)
        if R.random() < 0.4: g.op('ENV_EXT')
    g.op('ENV_EXT')
    return g.p.line()

FAMS = {'make': fam_make, 'real': fam_real, 's3': fam_s3, 'c3': fam_c3, 'env': fam_env}

def decode(line):
    """a readable form of a problem line (debugging)"""
    w = line.split(); i = 0; out = []
    byc = dict((c, (n, a)) for n, (c, a) in NAMES.items())
    while i < len(w):
        n, spec = byc[int(w[i])]; i += 1
        args = []
        for s in (spec.split() if spec else []):
            nm, t = s.split(':')
            if t[0] == 'l':
                k = int(w[i]); i += 1; args.append('[' + ' '.join(w[i:i + k]) + ']'); i += k
            else:
                args.append(nm + '=' + w[i]); i += 1
        out.append(n + '(' + ', '.join(args) + ')')
    return '\n'.join(out)

if __name__ == '__main__' and len(sys.argv) > 1 and sys.argv[1] == 'dec':
    for l in sys.stdin:
        if l.strip() and not l.startswith('#'): print(decode(l.strip())); print('--')

def fam_icn(R, kind):
    """s3exp2icnstr / s3exp2myintvec / s2varindmap on s3exp built by the smart constructors and on raw nodes"""
    g = G(R, kind); setup_vars(g, R.randint(1, 4), R.randint(0, 2), 0)
    ints = g.vars; bools = g.bvars
    allv = ints + bools
    g.op('ENV_NEW')
    for _ in range(R.randint(1, 3)):
        c = R.random()
        if c < 0.5: x = s3_bool(g, R.randint(1, 3), ints, bools)
        elif c < 0.7:
            x = g.new('X'); a = s3_exp(g, R.randint(1, 2), ints); g.op('S3Ebineq', x, R.choice([-2, -1, 1, 2]), a)
        elif c < 0.8:
            x = g.new('X'); g.op('S3Ebdom', x, R.choice(allv))
        elif c < 0.9:
            a = s3_bool(g, 1, ints, bools); b = s3_bool(g, 1, ints, bools); x = g.new('X'); g.op(R.choice(['S3Ebadd', 'S3Ebmul', 'S3Ebeq', 'S3Ebneq']), x, a, b)
        else:
            x = s3_exp(g, 2, ints) if R.random() < 0.5 else s3_bool(g, 2, ints, bools)
        vs = [v for v in allv if R.random() < 0.9]
        if R.random() < 0.7: g.op('ICN', x, vs)
        else: g.op('ICV', x, vs)
    # raw sums for the vectors: the supported elements and the others
    if R.random() < 0.6 and ints:
        els = []
        for _ in range(R.randint(1, 4)):
            c = R.random(); x = g.new('X'); n = g.new('N'); g.op('NI', n, R.choice([-2, 1, 3, 0]))
            if c < 0.2: g.op('Xvar', x, R.choice(ints))
            elif c < 0.35: g.op('S3Eunit', x)
            elif c < 0.55: v = g.new('X'); g.op('Xvar', v, R.choice(ints)); g.op('S3Eicff', x, n, v)
            elif c < 0.7: u = g.new('X'); g.op('S3Eunit', u); g.op('S3Eicff', x, n, u)
            elif c < 0.8: v = g.new('X'); g.op('Xbool', v, 1); g.op('S3Eicff', x, n, v)
            elif c < 0.9: g.op('S3Enull', x)
            else: g.op('Xbool', x, 0)
            els.append(x)
        x = g.new('X'); g.op('S3Eisum', x, els); g.op('ICV', x, [v for v in ints if R.random() < 0.9])
        x = g.new('X'); g.op('S3Eicff', x, g.newn(R), els[0]); g.op('ICV', x, ints)
    # linear forms for the vectors
    for _ in range(R.randint(1, 2)):
        x = s3_exp(g, R.randint(0, 2), ints)
        vs = [v for v in ints if R.random() < 0.9]
        g.op('ICV', x, vs)
    return g.p.line()
FAMS['icn'] = fam_icn

def fam_h3(R, kind):
    """the hypotheses (h3ypo), s3explst_make and s3exp_make_s2cst_s2explst"""
    g = G(R, kind); setup_vars(g, R.randint(1, 3), R.randint(0, 1), 0)
    g.op('ENV_NEW')
    for v in g.vars + g.bvars: g.op('ENV_ADDV', v)
    for _ in range(R.randint(1, 3)):
        c = R.random(); h = g.new('H')
        if c < 0.45: g.op('H3PROP', h, R.randint(0, 9), g.bool_exp(2))
        elif c < 0.7:
            # a binding must be acyclic: the variable i is bound to an expression over the variables of larger index only
            i = R.randrange(len(g.vars)); saved = g.vars; g.vars = saved[i + 1:]
            e = g.int_exp(2); g.vars = saved
            g.op('H3BIND', h, R.randint(0, 9), g.vars[i], e)
        else:
            a, b = (g.int_exp(2), g.int_exp(2)) if R.random() < 0.7 else (g.bool_exp(1), g.bool_exp(1))
            g.op('H3EQEQ', h, R.randint(0, 9), a, b)
        x = g.new('X'); g.op('MAKEH', x, h)
        if R.random() < 0.5: y = g.new('X'); g.op('LINT', y, x); g.op('ENV_ADDB', y)
    for _ in range(R.randint(1, 2)):
        g.op('MAKEL', [g.int_exp(2) for _ in range(R.randint(0, 3))])
    for _ in range(R.randint(1, 3)):
        name = R.choice(['add_int_int', 'sub_int_int', 'mul_int_int', 'neg_int', 'lt_int_int', 'gte_int_int', 'eq_int_int', 'neg_bool', 'add_bool_bool',
                         'abs_int', 'sgn_int', 'max_int_int', 'min_int_int', 'div_int_int', 'ndiv_int_int', 'idiv_int_int', 'ifint_bool_int_int',
                         'int_of_addr', 'addr_of_int', 'add_addr_int', 'sub_addr_addr', 'lte_cls_cls', 'types_cons', 'int_kind', 'atstype_int', 'sizeof_t0ype_int',
                         'absrel_int_int', 'ndivrel_int_int_int', 'lterel_cls_cls', 'null_addr', 'true_bool', 'gt_addr_addr', 'sub_addr_int', 'mul_bool_bool', 'neq_int_int'])
        ar = {'neg_int': 1, 'neg_bool': 1, 'abs_int': 1, 'sgn_int': 1, 'int_of_addr': 1, 'addr_of_int': 1, 'sizeof_t0ype_int': 1, 'int_kind': 0, 'atstype_int': 0,
              'null_addr': 0, 'true_bool': 0, 'ifint_bool_int_int': 3, 'ndivrel_int_int_int': 3, 'lterel_cls_cls': 3}.get(name, 2)
        args = []
        for j in range(ar):
            a = name.split('_')
            if name in ('neg_bool', 'add_bool_bool', 'mul_bool_bool') or (name == 'ifint_bool_int_int' and j == 0): args.append(g.bool_exp(1))
            elif name in ('int_of_addr',) or (name in ('add_addr_int', 'sub_addr_int') and j == 0) or name in ('sub_addr_addr', 'gt_addr_addr'): args.append(g.addr_exp(1))
            elif name == 'lte_cls_cls' or name == 'lterel_cls_cls':
                kc = g.new('C'); g.op('MKC', kc, 'k%d' % kc, R.randint(0, 19), g.srt('cls')); args.append(g.e_cst(kc))
            elif name in ('types_cons', 'sizeof_t0ype_int'): args.append(g.int_exp(1))
            else: args.append(g.int_exp(1))
        c = g.pv(name); x = g.new('X'); g.op('MAKECST', x, c, args)
    if R.random() < 0.5:
        c = g.cst(['int'], 'int'); x = g.new('X'); g.op('MAKECST', x, c, [g.int_exp(1)])
    g.op('ENV_EXT')
    return g.p.line()
FAMS['h3'] = fam_h3

def fam_exp(R, kind):
    """the export of a constraint: the constants, variables and sorts that it mentions (sorts: functions, tuples, datasorts, variables, errors), data constructors"""
    g = G(R, kind)
    srts = []
    for _ in range(R.randint(1, 3)):
        c = R.random(); s = g.new('S')
        if c < 0.2: g.op('SRT', s, R.randint(0, 14))
        elif c < 0.4:
            sd = g.new('SD'); g.op('MKSD', sd, 'sd%d' % sd); g.op('SRTDAT', s, sd)
        elif c < 0.5: g.op('SRTERR', s)
        elif c < 0.6:
            i = g.new('S'); g.op('SRT', i, 0); g.op('SRTV', s, R.randint(0, 9), R.randint(0, 1), i)
        elif c < 0.7: g.op('SRTIMP', s, R.randint(0, 3), 'imp%d' % s)
        elif c < 0.85:
            a = g.new('S'); g.op('SRT', a, 0); b = g.new('S'); g.op('SRT', b, 1); g.op('SRTT', s, [a, b])
        else:
            sd = g.new('SD'); g.op('MKSD', sd, 'sd%d' % sd); a = g.new('S'); g.op('SRTDAT', a, sd)
            b = g.new('S'); g.op('SRT', b, 0); g.op('SRTF', s, [a, b], a)
        srts.append(s)
    vs = []; cs = []
    for s in srts:
        v = g.new('V'); g.op('MKVS', v, s, 'xv%d' % v); vs.append(v)
        c = g.new('C'); g.op('MKC', c, 'xc%d' % c, R.randint(0, 19), s); cs.append(c)
    es = [g.e_var(v) for v in vs] + [g.e_cst(c) for c in cs]
    # data constructors
    dcs = []
    for _ in range(R.randint(0, 2)):
        c = g.cst([], 't0ype'); dc = g.new('DC'); g.op('MKDC', dc, c, R.randint(0, 9), [R.choice(es)] if es and R.random() < 0.5 else []); dcs.append((dc, c))
    # definitions that mention the constants: acyclic ones (the solver and the printers unfold them); cyclic ones (a constant that is mentioned by its own
    # definition) only for the traversal of the map of the constants, which marks a constant before it visits the definition
    cyc = R.random() < 0.25
    for c in cs[:2]:
        if cyc and R.random() < 0.8:
            d1 = g.new('E'); g.op('EEQ', d1, g.e_cst(c), R.choice(es)); g.op('SETDEF', c, d1)
    if len(cs) > 1:
        if cyc:
            d2 = g.new('E'); g.op('EEQ', d2, g.e_cst(cs[1]), g.e_cst(cs[0])); g.op('SETDEF', cs[0], d2)
        elif R.random() < 0.5:
            d2 = g.new('E'); g.op('EEQ', d2, g.e_cst(cs[0]), R.choice(es[:len(vs)])); g.op('SETDEF', cs[1], d2)
    props = []
    for _ in range(R.randint(1, 3)):
        if dcs and R.random() < 0.6:
            dc, c = R.choice(dcs); e1 = g.new('E'); g.op('EDCT', e1, dc, [R.choice(es)] if es else [])
            if R.random() < 0.5:
                r = g.e_cst(c); e1b = g.new('E'); g.op('EDCP', e1b, dc, r, [R.choice(es)] if es else []); e1 = e1b
        else:
            e1 = R.choice(es)
        e2 = R.choice(es)
        p = g.new('E'); g.op('EEQ', p, e1, e2); props.append(p)
    # a constraint with the hypotheses and the conclusions
    its = []
    for v in vs:
        i = g.new('I'); g.op('I_SVAR', i, v); its.append(i)
    for p in props[:-1]:
        h = g.new('H'); g.op('H3PROP', h, R.randint(0, 9), p); i = g.new('I'); g.op('I_HYPO', i, h); its.append(i)
    k = g.new('T'); g.op('KMAIN', k)
    kk = g.new('K'); g.op('C3PROP', kk, R.randint(0, 9), props[-1])
    i = g.new('I'); g.op('I_CNSTR', i, kk); its.append(i)
    cc = g.new('K'); g.op('C3ITM', cc, R.randint(0, 9), k, its)
    if cyc:
        g.op('MAPK', cc)
    else:
        g.op('EXPK', cc); g.op('MAPK', cc); g.op('JSK', cc)
        if R.random() < 0.5: g.op('RUN3', cc)
    return g.p.line()
FAMS['exp'] = fam_exp
