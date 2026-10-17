#!/usr/bin/env python3
# Regenerates the arity-indexed part of atsdoc_compat.hats (the part between
# "begin of [generated]" and "end of [generated]"): python3 atsdoc_compat_gen.py
import os, re
N = 16
def tup(n): return 'xs: @(' + ','.join(['string'] * n) + ')'
def xs(n): return ', '.join('xs.%d' % i for i in range(n))
g = []
for n in range(1, N + 1):
    g.append('fun\nsprintf_%d (fmt: string, %s): Strptr1 =\n  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, %s)\n' % (n, tup(n), xs(n)))
def over(nm, f): return '//\nsymintr %s\n' % nm + ''.join('overload %s with %s_%d of 10\n' % (nm, f, n) for n in range(1, N + 1))
g.append(over('sprintf', 'sprintf'))
for n in range(1, N + 1):
    g.append('fun\nfprintf_%d (out: FILEref, fmt: string, %s): void =\n  atsdoc_fprint_strptr(out, sprintf_%d(fmt, xs))\n' % (n, tup(n), n))
g.append(over('fprintf', 'fprintf'))
for nm, out in (('printf', 'stdout_ref'), ('prerrf', 'stderr_ref')):
    for n in range(1, N + 1):
        g.append('fun\n%s_%d (fmt: string, %s): void =\n  fprintf_%d(%s, fmt, xs)\n' % (nm, n, tup(n), n, out))
    g.append(over(nm, nm))
body = '//\n// begin of [generated] (n = 1, ..., %d)\n//\n' % N + ''.join(g) + '//\n// end of [generated]\n//\n'
p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'atsdoc_compat.hats')
t = open(p).read()
a = t.index('//\n// begin of [generated]')
b = t.index('// end of [generated]\n//\n') + len('// end of [generated]\n//\n')
open(p, 'w').write(t[:a] + body + t[b:])
