#!/usr/bin/env python3
# covunion.py [-v] DIR...: per module, the lines covered by the gcov files (pats_*.dats.gcov) of any of the DIRs (the whole-file driver f3dump and the
# compiler patsopt), raw and without the lines of covexcl.txt (code that no ATS source can reach).
import sys, os
here = os.path.dirname(os.path.abspath(__file__))
args = [a for a in sys.argv[1:] if a != '-v']; verbose = '-v' in sys.argv
excl = {}
for l in open(os.path.join(here, 'covexcl.txt')):
    if l.startswith('#') or not l.strip(): continue
    m, a, b, _ = l.split(None, 3); excl.setdefault(m, []).append((int(a), int(b)))
mods = sorted({f[:-len('.dats.gcov')] for d in args for f in os.listdir(d) if f.endswith('.dats.gcov')})
for m in mods:
    st = {}
    for d in args:
        p = os.path.join(d, m + '.dats.gcov')
        if not os.path.exists(p): continue
        for l in open(p, errors='replace'):
            q = l.split(':', 2)
            if len(q) < 3: continue
            c = q[0].strip(); n = q[1].strip()
            if c == '-' or not n.isdigit() or n == '0': continue
            n = int(n); hit = not (c.startswith('#####') or c.startswith('====='))
            st[n] = st.get(n, False) or hit
    ex = excl.get(m, [])
    inex = lambda n: any(a <= n <= b for a, b in ex)
    allc = len(st); hit = sum(1 for v in st.values() if v)
    st2 = {n: v for n, v in st.items() if not inex(n)}
    c2 = len(st2); h2 = sum(1 for v in st2.values() if v)
    if allc == 0: continue
    print('%-26s lines %5d covered %5d (%.1f%%)   reachable %5d covered %5d (%.1f%%)' % (m, allc, hit, 100.0*hit/allc, c2, h2, 100.0*h2/c2))
    if verbose: print('   not covered:', ' '.join(str(n) for n in sorted(st2) if not st2[n]))
