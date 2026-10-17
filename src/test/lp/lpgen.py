#!/usr/bin/env python3
"""Generator of the problems of the linear constraint solver (test/lp).

  python3 lpgen.py SEED COUNT MODE [FAMILY [SIZE]] > problems.txt

MODE: gmp (coefficients up to ~2^170, bigger than 64 bits) or int (coefficients that fit in an int; both
builds wrap around on overflow, -fwrapv). FAMILY: mix (default: all of the following, and records I of integers),
sat, unsat, rnd, nest (conjunctions/disjunctions), chain (many variables), wide (58-80 variables), arith, or bench (records B: only
solved, SIZE = number of variables).

A record is  P id label N h idx.. c items..  (see lpdrv.c); the label is
  sat    a solution is planted: the solver must not answer -1 (contradiction)
  unsat  rationally (or by the gcd rules) infeasible: the solver must answer -1
  ?      random: no claim
"""
import random, sys

def fmt_item(it, out):
    if it[0] == 'V':
        out.append('V %d %s' % (it[1], ' '.join(str(c) for c in it[2])))
    elif it[0] == 'L':
        out.append('L %d %d' % (it[1], len(it[2])))
        for x in it[2]: fmt_item(x, out)
    else:
        out.append('E')

def fmt_prob(kind, pid, label, N, hints, items):
    out = ['%s p%d %s %d %d %s %d' % (kind, pid, label, N, len(hints), ' '.join(str(h) for h in hints), len(items))]
    for it in items: fmt_item(it, out)
    return '\n'.join(out)

class G:
    def __init__(self, rnd, mode):
        self.r = rnd; self.mode = mode
    def coef(self):
        r = self.r
        return r.choice([0, 0, 1, -1, 2, -2, 3, -3, 5, -5, 7, -7, r.randint(-30, 30), r.randint(-30, 30), r.randint(-1000, 1000)])
    def scale_factor(self):
        r = self.r
        if self.mode == 'int':
            return r.choice([1, 1, 1, 2, 3, 5, 6, 10, 12])
        return r.choice([1, 1, 1, 2, 3, 10, 12, 10**9, 10**18, 10**19, 2**64, 2**64 + 1, 10**30, 10**40, 3**50, r.randint(1, 10**50)])
    def vec(self, N, density=None):
        r = self.r
        if density is None: density = 0.6 if N <= 6 else max(0.2, 3.0 / N)
        v = [r.randint(-20, 20)] + [self.coef() if r.random() < density else 0 for _ in range(N - 1)]
        return v
    def nzvec(self, N):
        v = self.vec(N)
        if all(c == 0 for c in v[1:]): v[r_idx(self.r, N)] = self.r.choice([1, -1, 2])
        return v
    def point(self, N):
        return [self.r.randint(-6, 6) for _ in range(N - 1)]
    def val(self, v, x):
        return v[0] + sum(a * b for a, b in zip(v[1:], x))
    def sat_item(self, N, x, knd=None):
        """a constraint satisfied by the point x"""
        r = self.r
        a = self.vec(N)
        if knd is None: knd = r.choice([2, 2, 2, -2, 1, 1, -1])
        v = self.val(a, x)
        if knd == 2: a[0] += r.choice([0, 0, 1, 2, 7, 30]) - v           # the value at x is >= 0
        elif knd == -2: a[0] += -1 - r.choice([0, 0, 1, 2, 7, 30]) - v    # the value at x is < 0
        elif knd == 1: a[0] -= v                                          # the value at x is 0
        else:
            d = r.choice([-5, -2, -1, 1, 2, 5, 9]); a[0] += d - v         # the value at x is d != 0
        return ('V', knd, a)
    def scale(self, it, m=None):
        if m is None: m = self.scale_factor()
        return ('V', it[1], [c * m for c in it[2]])
    def core(self, N):
        """a list of items (all V) that is infeasible"""
        r = self.r
        t = r.choice(['pair', 'chain', 'eq', 'gcdeq', 'gcdineq', 'eqineq', 'neq'])
        if N < 2 and t not in ('pair', 'gcdeq'): t = 'pair'
        self.last_core = t   # the gcd cores are infeasible over the integers only: no company
        if t == 'pair':
            a = self.nzvec(N)
            i1 = ('V', 2, a)
            b = [-c for c in a]; b[0] = -a[0] - 1 - r.choice([0, 0, 3])
            return [self.scale(i1), self.scale(('V', 2, b))]
        if t == 'chain':
            k = r.randint(3, 6)
            vs = [self.vec(N) for _ in range(k - 1)]
            last = [-sum(v[i] for v in vs) for i in range(N)]
            last[0] -= 1 + r.choice([0, 0, 4])
            return [self.scale(('V', 2, v)) for v in vs + [last]]
        if t == 'eq':
            x = self.point(N)
            es = [self.sat_item(N, x, 1) for _ in range(r.randint(1, 3))]
            mu = [r.randint(-3, 3) for _ in es]
            comb = [sum(m * e[2][i] for m, e in zip(mu, es)) for i in range(N)]
            comb[0] += r.choice([-3, -1, 1, 2, 5])
            return [self.scale(e) for e in es] + [('V', 1, comb)]
        if t == 'gcdeq':
            g = r.choice([2, 3, 4, 6, 10])
            a = [g * self.coef() for _ in range(N - 1)]
            if all(c == 0 for c in a): a[r_idx(r, N) - 1] = g
            c = r.randint(-20, 20)
            if c % g == 0: c += 1
            return [('V', 1, [c] + a)]
        if t == 'gcdineq':
            g = r.choice([2, 3, 4, 6, 10])
            a = [g * self.coef() for _ in range(N - 1)]
            if all(c == 0 for c in a): a[r_idx(r, N) - 1] = g
            M = g * r.randint(-5, 5)
            lo, hi = M + 1, M + g - 1
            return [('V', 2, [-lo] + a), ('V', 2, [hi] + [-c for c in a])]
        if t == 'eqineq':
            a = self.nzvec(N)
            e = self.scale(('V', 1, a))
            b = [-c for c in a]; b[0] = -a[0] - 1
            return [e, ('V', 2, b)]
        a = self.nzvec(N)
        k = r.choice([1, 2, 3, -1, -2, -3])
        return [('V', -1, [k * c for c in a]), self.scale(('V', 1, a))]
    def rnd_item(self, N):
        return ('V', self.r.choice([2, 2, 2, -2, 1, 1, -1]), self.vec(N))

def r_idx(r, N):
    return r.randint(1, N - 1)

def hints(r, N):
    t = r.random()
    if t < 0.3: return []
    k = r.randint(1, max(1, min(N - 1, 12)))
    hs = [r.randint(1, N - 1) for _ in range(k)] if N > 1 else []
    if N > 63 and r.random() < 0.7: hs += [r.randint(60, N - 1) for _ in range(r.randint(1, 4))]
    if r.random() < 0.1: hs.append(N + r.randint(0, 3))   # out of range: ignored by the driver
    return hs

def prob_sat(g, N):
    r = g.r
    x = g.point(N)
    items = []
    for _ in range(r.randint(1, 9 if N <= 6 else 5)):
        t = r.random()
        if t < 0.12:
            # a disjunction one of whose branches is satisfied by x (the others are random or infeasible)
            br = [('L', 0, [g.sat_item(N, x) for _ in range(r.randint(1, 3))])]
            for _ in range(r.randint(1, 2)):
                br.append(('L', 0, g.core(N)) if r.random() < 0.5 else ('L', 0, [g.rnd_item(N) for _ in range(2)]))
            r.shuffle(br)
            items.append(('L', 1, br))
        elif t < 0.2:
            items.append(('L', 0, [g.sat_item(N, x) for _ in range(r.randint(1, 3))]))
        else:
            it = g.sat_item(N, x)
            items.append(g.scale(it) if (g.mode == 'gmp' and r.random() < 0.4) else it)
    if r.random() < 0.15: items.append(('E',))
    return 'sat', items

def prob_unsat(g, N):
    r = g.r
    x = g.point(N)
    t = r.random()
    ncore = r.randint(1, 3) if t < 0.2 else 1
    cores = []; gcd = False
    for _ in range(ncore):
        cores.append(g.core(N)); gcd = gcd or g.last_core.startswith('gcd')
    # a gcd core is infeasible over the integers only (the solver does not see it after the elimination of
    # an equality): no other constraint then
    noise = [] if gcd else [g.sat_item(N, x) for _ in range(r.randint(0, 4))]
    if t < 0.2:
        # every branch of the disjunction is infeasible
        br = [('L', 0, c + ([] if gcd else [g.sat_item(N, x) for _ in range(r.randint(0, 2))])) for c in cores]
        items = noise + [('L', 1, br)]
    elif t < 0.3:
        items = noise + [('L', 0, cores[0])]
    else:
        items = noise + cores[0]
    r.shuffle(items)
    if r.random() < 0.15: items.append(('E',))
    return 'unsat', items

def prob_rnd(g, N):
    r = g.r
    items = []
    for _ in range(r.randint(1, 8 if N <= 6 else 5)):
        t = r.random()
        if t < 0.1:
            items.append(('L', r.randint(0, 1), [g.rnd_item(N) for _ in range(r.randint(0, 3))]))
        elif t < 0.12:
            items.append(('E',))
        else:
            it = g.rnd_item(N)
            items.append(g.scale(it) if (g.mode == 'gmp' and r.random() < 0.3) else it)
    return '?', items

def prob_nest(g, N):
    r = g.r
    x = g.point(N)
    def build(d, sat):
        # returns an item that is satisfied by x when [sat]
        if d == 0 or r.random() < 0.3:
            return g.sat_item(N, x) if sat or r.random() < 0.5 else g.rnd_item(N)
        k = r.randint(0, 3)
        if r.random() < 0.5:
            return ('L', 0, [build(d - 1, sat) for _ in range(k)])
        its = [build(d - 1, sat and i == 0) for i in range(k)] if k else []
        if sat and its: its = [build(d - 1, True)] + its[1:]
        r.shuffle(its)
        return ('L', 1, its)
    items = [build(3, True) for _ in range(r.randint(1, 3))]
    return ('?' if True else 'sat'), items

def prob_chain(g, N):
    """difference constraints and equalities over many variables; sometimes a negative cycle"""
    r = g.r
    x = g.point(N)
    items = []
    n = N - 1
    for i in range(1, n):
        v = [0] * N; v[i + 1] = 1; v[i] = -1      # x_{i+1} - x_i + c >= 0
        v[0] = x[i] - x[i - 1] and (x[i - 1] - x[i]) + r.choice([0, 0, 1, 3])
        v[0] = x[i - 1] - x[i] + r.choice([0, 0, 1, 3])
        items.append(('V', 2, v))
    for _ in range(r.randint(0, 4)):
        i, j = r.randint(1, n), r.randint(1, n)
        if i == j: continue
        v = [0] * N; v[i] = 1; v[j] = -1; v[0] = x[j - 1] - x[i - 1]   # x_i - x_j + c = 0
        items.append(('V', 1, v))
    label = 'sat'
    if r.random() < 0.5 and n >= 3:
        # a cycle x_a - x_b >= d1, x_b - x_c >= d2, x_c - x_a >= d3 with d1+d2+d3 > 0 is infeasible
        idx = r.sample(range(1, n + 1), r.randint(2, min(n, 5)))
        ds = [r.randint(-3, 3) for _ in idx]
        ds[0] += 1 - sum(ds)     # the sum is 1
        for k, i in enumerate(idx):
            j = idx[(k + 1) % len(idx)]
            v = [0] * N; v[i] = 1; v[j] = -1; v[0] = -ds[k]
            items.append(('V', 2, v))
        label = 'unsat'
    r.shuffle(items)
    return label, items

def prob_bench(g, N):
    r = g.r
    x = g.point(N)
    m = int(N * r.uniform(1.2, 2.2)) + 2
    items = []
    for _ in range(m):
        it = g.sat_item(N, x, r.choice([2, 2, 2, 2, 1, -2]))
        items.append(it)
    return 'sat', items

NUMS_INT = [0, 1, -1, 2, -2, 3, 7, -7, 10, 12, -12, 97, 100, 255, 256, 65535, 65536, 1000000, 2147483647, -2147483647, 46341, 30000, -30000]
def arith(g):
    r = g.r
    if g.mode == 'int':
        a = r.choice(NUMS_INT + [r.randint(-10**9, 10**9)]); b = r.choice(NUMS_INT + [r.randint(-10**4, 10**4)])
        if r.random() < 0.3: b = r.choice([1, -1, 2, 3, -3, 6, a if a else 1, -a if a else 1])
        return 'I %d %d' % (a, b)
    pool = [0, 1, -1, 2, 10**18, 10**19, 2**63, 2**63 - 1, 2**64, 2**64 + 1, -2**63, -2**64, 10**30, 10**40, 3**60, 2**100, 7, -7, 97, 12, 36]
    def big():
        t = r.random()
        if t < 0.5: return r.choice(pool) * r.choice([1, 1, -1])
        if t < 0.8: return r.randint(-10**r.randint(1, 60), 10**r.randint(1, 60))
        return r.choice(pool) + r.randint(-5, 5)
    a, b = big(), big()
    if r.random() < 0.3: b = a * r.choice([1, 2, -3, 7, 12]) // r.choice([1, 1, 2, 3]) or 1
    if r.random() < 0.15: b = r.choice([1, -1, 2, -2])
    return 'I %d %d' % (a, b)

def main():
    seed = int(sys.argv[1]); count = int(sys.argv[2]); mode = sys.argv[3]
    fam = sys.argv[4] if len(sys.argv) > 4 else 'mix'
    size = int(sys.argv[5]) if len(sys.argv) > 5 else 8
    r = random.Random(seed)
    g = G(r, mode)
    out = []
    for pid in range(count):
        f = fam
        if fam == 'mix':
            f = r.choice(['sat', 'sat', 'unsat', 'unsat', 'unsat', 'rnd', 'rnd', 'nest', 'chain', 'wide', 'arith', 'arith'])
        if f == 'arith':
            out.append(arith(g)); continue
        if f == 'chain':
            N = r.randint(4, 26)
        elif f == 'wide':
            N = r.randint(58, 80)
        elif f == 'bench':
            N = size + 1
        elif f == 'nest':
            N = r.randint(2, 6)
        else:
            N = r.choice([2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 8]) if r.random() < 0.9 else r.randint(9, 14)
            if f in ('rnd',) and N > 8: N = 8
        N += 1 if f not in ('bench', 'wide') else 0
        label, items = {'sat': prob_sat, 'unsat': prob_unsat, 'rnd': prob_rnd, 'nest': prob_nest, 'chain': prob_chain, 'wide': prob_chain, 'bench': prob_bench}[f](g, N)
        out.append(fmt_prob('B' if f == 'bench' else 'P', pid, label, N, hints(r, N), items))
    print('\n'.join(out))

main()
