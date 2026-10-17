#!/usr/bin/env python3
# usage: python3 c3_gen.py [WHAT]   writes the generated files of the test of the constraint solver (see PORTING.md, "Constraint solving (constraint3)"):
#   the compat layers of the level-3 test (t3_gen.py), the registers/operations/setup of the interpreter (c3_ops.py), the language specific part (c3hand.tmpl)
#   and, for WHAT = data, the problem files c3data_*.txt (c3_probs.py)
import os, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import t3_gen, d2_cases
import c3_ops

def put(name, s):
    d2_cases.put(os.path.join(d, name), s)

def t3_support():
    """the compat layers and the test doubles of the level-3 test (the same files as t3_gen.py writes)"""
    put('t3compat_gen.hats', t3_gen.gen_compat(2))
    put('t3compat1_gen.hats', t3_gen.gen_compat(1))
    put('t3hand.hats', t3_gen.expand_hand(2))
    put('t3hand1.hats', t3_gen.expand_hand(1))
    put('t3env.hats', t3_gen.expand_hand(2, 't3env.tmpl'))
    put('t3env1.hats', t3_gen.expand_hand(1, 't3env.tmpl'))

def main_code():
    t3_support()
    put('c3reg_gen.hats', c3_ops.reg_gen())
    ex, names = c3_ops.exec_gen()
    put('c3exec_gen.hats', ex)
    put('c3setup_gen.hats', c3_ops.setup_gen())
    put('c3glue_gen.hats', c3_ops.glue_gen(2))
    put('c3glue1_gen.hats', c3_ops.glue_gen(1))
    put('c3hand.hats', t3_gen.expand_hand(2, 'c3hand.tmpl'))
    put('c3hand1.hats', t3_gen.expand_hand(1, 'c3hand.tmpl'))
    s = open(os.path.join(d, 'c3decls.hats')).read().replace('"mac#', '"')
    put('c3decls1.hats', s)
    return names

SEED = int(os.environ.get('C3SEED', '1'))
SCALE = float(os.environ.get('C3SCALE', '1'))
# the number of problems of each family, per kind of integers of the solver
COUNTS = {'gmp': [('make', 4000), ('real', 2500), ('s3', 3500), ('c3', 6000), ('env', 3000), ('icn', 3500), ('h3', 2500), ('exp', 800)],
          'int': [('make', 2000), ('real', 1200), ('s3', 1500), ('c3', 3000), ('env', 1500), ('icn', 1500), ('h3', 1300), ('exp', 400)]}

def data():
    import random, c3_probs
    for kind in ('gmp', 'int'):
        R = random.Random(SEED * 1000 + (1 if kind == 'gmp' else 2))
        out = []
        for fam, n in COUNTS[kind]:
            for i in range(max(1, int(round(n * SCALE)))):
                out.append(c3_probs.FAMS[fam](R, kind))
        put('c3data_%s.txt' % kind, '\n'.join(out) + '\n')

if __name__ == '__main__':
    names = main_code()
    open(os.path.join(d, 'c3ops.txt'), 'w').write(''.join('%s %d\n' % (n, k) for n, k in sorted(names.items(), key=lambda x: x[1])))
    if len(sys.argv) > 1 and sys.argv[1] == 'data': data()
