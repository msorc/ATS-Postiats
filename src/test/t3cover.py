#!/usr/bin/env python3
# usage: python3 t3cover.py   (after t3_gen.py)  The coverage of the generated cases of the level-3 test: the constructors and the records of the specs
# (pats_dynexp3.spec, pats_trans3_env.spec) that the cases build (K_x), and the functions declared in pats_dynexp3.sats and pats_trans3_env.sats that the
# ATS1 sources implement and that the cases call (or the wrappers t_xxx of the functions that have proofs in ATS1).
import re, os, glob, sys
d = os.path.dirname(os.path.abspath(__file__))
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 't3cases_[0-9][0-9].hats'))))
cases += open(os.path.join(d, 't3common.hats')).read() + open(os.path.join(d, 't3hand.tmpl')).read()
cons = []; recs = []
for sp in ('pats_dynexp3.spec', 'pats_trans3_env.spec', 'pats_trans3.spec'):
    cur = None
    for l in open(os.path.join(d, '..', sp)).read().split('\n'):
        l = l.split('#', 1)[0].rstrip()
        m = re.match(r'^record\s+(\w+)\s*\(', l)
        if m: recs.append(m.group(1)); continue
        m = re.match(r'^type\s+(\w+)', l)
        if m: cur = m.group(1); continue
        m = re.match(r'^\s+(\w+)\s*\(', l)
        if m and cur: cons.append((cur, m.group(1)))
used = set(re.findall(r'\bK_(\w+)', cases))
miss_c = [c for t, c in cons if c not in used and not c.startswith('T3E_')]
miss_r = [r for r in recs if r not in used]
n3 = len([1 for t, c in cons if not c.startswith('T3E_')])
print('constructors: %d, used %d' % (n3, n3 - len(miss_c)), 'missing:', miss_c)
print('records: %d, built %d' % (len(recs), len(recs) - len(miss_r)), 'missing:', miss_r)
# the functions of the sats
src1 = ''
for f in ('pats_dynexp3.sats', 'pats_trans3_env.sats'):
    txt = open(os.path.join(d, '..', f)).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S); txt = re.sub(r'//[^\n]*', '', txt)
    fns = re.findall(r'\bfun\s+(\w+)', txt) + re.findall(r'\band\s+(\w+)\s*\(', txt)
    # implemented by the ATS1 sources?
    ats1 = open(os.path.join(d, '..', '..', 'src', f.replace('.sats', '.dats'))).read() if os.path.exists(os.path.join(d, '..', '..', 'src', f.replace('.sats', '.dats'))) else ''
    allsrc = ''
    for g in glob.glob(os.path.join(d, '..', '..', 'src', f.replace('.sats', '') + '*.dats')): allsrc += open(g).read()
    if not allsrc:
        main_ = os.environ.get('ATS1REF') or os.environ['ATS1SRC']
        for g in glob.glob(os.path.join(main_, f.replace('.sats', '') + '*.dats')): allsrc += open(g).read()
    todo = []; called = []; skipped = []
    for fn in dict.fromkeys(fns):
        if not re.search(r'implement\s+%s\b' % fn, allsrc) and not re.search(r'\n%s\s*\n?\s*\(' % fn, allsrc):
            skipped.append(fn); continue
        if re.search(r'\b(t_)?%s\b' % fn, cases): called.append(fn)
        else: todo.append(fn)
    print('%s: %d functions implemented in ATS1, %d called, not called: %s' % (f, len(called) + len(todo), len(called), todo))
    print('  not implemented in ATS1 (skipped):', skipped)
