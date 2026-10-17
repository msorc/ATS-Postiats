#!/usr/bin/env python3
# usage: python3 cccover.py   (after cc_gen.py)  The coverage of the generated cases of the ccomp core test: the constructors and the records of pats_ccomp.spec that the cases build
# (K_x, or a smart constructor of the sats), and the functions of pats_ccomp.sats that the ATS1 sources of the core modules implement (or declare with a C name) and that the cases call.
import re, os, glob, sys
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..', '..')
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'cc_cases_[0-9][0-9].hats'))))
cases += open(os.path.join(d, 'cc_hand2.hats')).read() + open(os.path.join(d, 'cc_gen.py')).read() + open(os.path.join(d, 'cc_compat2.hats')).read().split('and dd_tmplab')[1]
cons = []; recs = []
cur = None
for l in open(os.path.join(M, 'pats_ccomp.spec')).read().split('\n'):
    l = l.split('#', 1)[0].rstrip()
    m = re.match(r'^record\s+(\w+)\s*\(', l)
    if m: recs.append(m.group(1)); continue
    m = re.match(r'^type\s+(\w+)', l)
    if m: cur = m.group(1); continue
    m = re.match(r'^\s+(\w+)\s*\(', l)
    if m and cur: cons.append((cur, m.group(1)))
used = set(re.findall(r'\bK_(\w+)', cases))
CELLS = ('tmplab', 'tmpvar', 'd2env', 'funlab', 'funent')
smart = {'primval_node': 'primval_', 'instr_node': 'instr_', 'primdec_node': 'primdec_', 'primlab_node': 'primlab_'}
sm = set(re.findall(r'\b((?:primval|instr|primdec|primlab|ibranch)_\w+) \(', cases))
def covered(t, c):
    if c in used: return True
    p = smart.get(t)
    return bool(p and (p + c[3:].lower()) in sm)
miss_c = [c for t, c in cons if not covered(t, c)]
miss_r = [r for r in recs if r not in used and r not in CELLS]
print('constructors: %d, built %d' % (len(cons), len(cons) - len(miss_c)), 'missing:', miss_c)
print('records: %d (5 cells through the API), built by K_ %d' % (len(recs), len(recs) - len(miss_r) - len(CELLS)), 'missing:', miss_r)
txt = open(os.path.join(M, 'pats_ccomp.sats')).read()
txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S); txt = re.sub(r'//[^\n]*', '', txt)
fns = re.findall(r'\bfun\s*(?:\{[^}]*\})?\s+(\w+)|\bfun(\{[^}]*\})\s*(\w+)', txt)
fns = [a or c for a, b, c in fns]
mods = ['ccomp', 'ccomp_print', 'ccomp_tmplab', 'ccomp_tmpvar', 'ccomp_d2env', 'ccomp_funlab', 'ccomp_funent', 'ccomp_util', 'ccomp_instrseq']
main_ = os.environ.get('ATS1REF') or os.environ['ATS1SRC']
allsrc = ''.join(open(os.path.join(main_, 'pats_' + m + '.dats')).read() for m in mods)
todo = []; called = []; skipped = []
for fn in dict.fromkeys(fns):
    if not re.search(r'implement\s*(?:\{[^}]*\})?\s*%s\b' % fn, allsrc) and not re.search(r'\n%s\s*\n?\s*\(' % fn, allsrc) and not re.search(r'\n%s\s*\n' % fn, allsrc) and not fn.startswith('tmpvar_set_'):
        skipped.append(fn); continue
    if re.search(r'\b%s\b' % fn, cases): called.append(fn)
    else: todo.append(fn)
print('pats_ccomp.sats: %d functions of the core modules, %d called, not called: %s' % (len(called) + len(todo), len(called), todo))
