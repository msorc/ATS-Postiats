#!/usr/bin/env python3
# usage: python3 cgcover.py [-v]   (after `make cgdump_cov`; `make cgcover` does it)
# The coverage of the codegen2/patcst2 test: (1) the functions declared in pats_codegen2.sats and pats_patcst2.sats that the cases call, (2) the
# constructors of pats_patcst2.spec that the cases build (K_x), (3) the lines of the ATS sources executed by cgdump_cov (gcov of the C
# files compiled with --gline: the line numbers are those of the .dats files).
import re, os, glob, sys, subprocess, shutil, tempfile
d = os.path.dirname(os.path.abspath(__file__))
verbose = '-v' in sys.argv
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'cgcases_[0-9][0-9].hats'))))
helpers = open(os.path.join(d, 'cgcommon.hats')).read()
ids = set(re.findall(r'\b(\w+)\b', cases + helpers))
def decls(sats):
    txt = open(os.path.join(d, '..', sats)).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//.*', '', txt)
    out = set()
    for m in re.finditer(r'^\s*(?:fun|and)\s*(?:\{[^}]*\})?\s*(\w+)', txt, re.M): out.add(m.group(1))
    for m in re.finditer(r'^fun\s*\n\s*(\w+)', txt, re.M): out.add(m.group(1))
    return sorted(out)
internal = set('i0nt2intinf p2atcst_lst p2atcstlst_of_vt labp2atcstlst_of_vt p2atcstlstlst_of_vt'.split())
for sats in ('pats_codegen2.sats', 'pats_patcst2.sats'):
    ds = decls(sats)
    miss = [f for f in ds if f not in ids and f not in internal]
    print('%s: %d functions, %d called by the cases%s' % (sats, len(ds), len(ds) - len(miss) - len([f for f in ds if f in internal and f not in ids]), (', not called: ' + ' '.join(miss)) if miss else ''))
spec = open(os.path.join(d, '..', 'pats_patcst2.spec')).read()
cons = re.findall(r'^\s+(P2TC\w+)\s*\(', spec, re.M)
miss = [c for c in cons if ('K_' + c) not in ids]
print('constructors of pats_patcst2.spec: %d, built %d%s' % (len(cons), len(cons) - len(miss), (', missing: ' + ' '.join(miss)) if miss else ''))
# the lines
mods = ['pats_codegen2', 'pats_codegen2_util', 'pats_codegen2_datype', 'pats_codegen2_fprint', 'pats_codegen2_absrec', 'pats_patcst2']
tmp = tempfile.mkdtemp(prefix='cgcov')
for f in glob.glob(os.path.join(d, 'cgobj_cov', '*.gcda')) + glob.glob(os.path.join(d, 'cgobj_cov', '*.gcno')):
    pass
for f in glob.glob(os.path.join(d, 'cgobj_cov', '*.gcda')): os.remove(f)
r = subprocess.run([os.path.join(d, 'cgdump_cov')], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=d)
tot_e = tot_x = 0
for m in mods:
    gcno = os.path.join(d, 'cgobj_cov', m + '_dats.gcno')
    subprocess.run(['gcov', '-o', os.path.join(d, 'cgobj_cov'), gcno], cwd=tmp, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    src = os.path.join(d, '..', m + '.dats')
    gf = None
    for cand in glob.glob(os.path.join(tmp, '*.gcov')):
        first = open(cand, errors='replace').readline()
        if first.strip().endswith(m + '.dats') and 'Source:' in first and os.path.basename(cand).startswith(m + '.dats'):
            gf = cand
    if not gf:
        print(m, 'no gcov file'); continue
    nexe = nrun = 0; unc = []
    for l in open(gf, errors='replace'):
        mm = re.match(r'^\s*([^:]+):\s*(\d+):(.*)$', l)
        if not mm: continue
        c, n, t = mm.group(1).strip(), int(mm.group(2)), mm.group(3)
        if n == 0 or c == '-': continue
        nexe += 1
        if c.startswith('#') or c.startswith('='):
            unc.append((n, t))
        else: nrun += 1
    tot_e += nexe; tot_x += nrun
    print('%-24s %4d of %4d executable lines executed' % (m + '.dats', nrun, nexe))
    if verbose or True:
        for n, t in unc: print('    not executed: %d: %s' % (n, t.strip()[:100]))
    for cand in glob.glob(os.path.join(tmp, '*.gcov')): os.remove(cand)
print('total: %d of %d (%.1f%%)' % (tot_x, tot_e, 100.0 * tot_x / max(1, tot_e)))
shutil.rmtree(tmp)
