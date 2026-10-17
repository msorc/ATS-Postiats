#!/usr/bin/env python3
# usage: python3 hdcover.py   (after hd_gen.py)  The coverage of the generated cases of the erased-tree / typerase test: the constructors and the records of the specs
# (pats_hidynexp.spec, pats_histaexp.spec, pats_dynexp3.spec) that the cases build (K_x or a smart constructor), and the functions declared in pats_hidynexp.sats and
# pats_typerase.sats that the cases call.
import re, os, glob, sys
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..', '..')
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'hd_cases_[0-9][0-9].hats'))))
cases += open(os.path.join(d, 'hd_common.hats')).read() + open(os.path.join(d, 'hd_hand_b2.hats')).read()
cons = []; recs = []
for sp in ('pats_hidynexp.spec', 'pats_typerase.spec'):
    cur = None
    for l in open(os.path.join(M, sp)).read().split('\n'):
        l = l.split('#', 1)[0].rstrip()
        m = re.match(r'^record\s+(\w+)\s*\(', l)
        if m: recs.append(m.group(1)); continue
        m = re.match(r'^type\s+(\w+)', l)
        if m: cur = m.group(1); continue
        m = re.match(r'^\s+(\w+)\s*\(', l)
        if m and cur: cons.append((cur, m.group(1)))
used = set(re.findall(r'\bK_(\w+)', cases))
# a constructor is also built by the typerase on the other side: dumped results contain it; only K_ and the smart constructors count here
smart = {'hipat_node': 'hipat_', 'hidexp_node': 'hidexp_', 'hidecl_node': 'hidecl_', 'hilab_node': 'hilab_'}
def covered(t, c):
    if c in used: return True
    if c.startswith('T4E_'): return True   # built by the typerase
    return False
miss_c = [c for t, c in cons if not covered(t, c)]
miss_r = [r for r in recs if r not in used]
print('constructors: %d, built by K_ %d' % (len(cons), len(cons) - len(miss_c)), 'missing:', miss_c)
print('records: %d, built by K_ %d' % (len(recs), len(recs) - len(miss_r)), 'missing:', miss_r)
for f, src in (('pats_hidynexp.sats', ['pats_hidynexp']), ('pats_typerase.sats', ['pats_typerase'])):
    txt = open(os.path.join(M, f)).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S); txt = re.sub(r'//[^\n]*', '', txt)
    fns = re.findall(r'\bfun\s+(\w+)', txt)
    allsrc = ''
    main_ = os.environ.get('ATS1REF') or os.environ['ATS1SRC']
    for s in src:
        for g in glob.glob(os.path.join(main_, s + '*.dats')): allsrc += open(g).read()
    todo = []; called = []; skipped = []
    for fn in dict.fromkeys(fns):
        if not re.search(r'implement\s+%s\b' % fn, allsrc) and not re.search(r'\n%s\s*\n?\s*\(' % fn, allsrc) and not re.search(r'\n%s\s*\n' % fn, allsrc):
            skipped.append(fn); continue
        if re.search(r'\b%s\b' % fn, cases): called.append(fn)
        else: todo.append(fn)
    print('%s: %d functions implemented in ATS1, %d called, not called: %s' % (f, len(called) + len(todo), len(called), todo))
    print('  not implemented in ATS1 (skipped):', skipped)
