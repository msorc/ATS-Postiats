#!/usr/bin/env python3
# usage: python3 m2cover.py [--gcov]   (after m2_gen.py; --gcov: after `make m2dump_cov`, runs m2dump_cov and gcov)
# The coverage of the generated cases of the macro test: the constructors of the macro values (pats_dmacro2.spec), the functions declared in
# pats_dmacro2.sats (the cases call them), the constructors of d2exp/p2at/d2ecl that eval1 handles, and with --gcov the lines (gcov, by ATS line:
# patscc --gline) of the 5 modules pats_dmacro2{,_eval0,_eval1,_print}.dats and pats_trans3_error.dats (all the instances of a template merged).
import re, os, glob, sys, subprocess
d = os.path.dirname(os.path.abspath(__file__))
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'm2cases_[0-9][0-9].hats'))))
spec = open(os.path.join(d, '..', 'pats_dmacro2.spec')).read().split('\n')
cons = [m.group(1) for l in spec for m in [re.match(r'^\s+(\w+)\s*\(', l)] if m]
used = set(re.findall(r'\bK_(\w+)', cases))
print('m2val constructors: %d, built %d' % (len(cons), len([c for c in cons if c in used])), 'missing:', [c for c in cons if c not in used])
# the functions of the sats
txt = open(os.path.join(d, '..', 'pats_dmacro2.sats')).read()
txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
txt = re.sub(r'//.*', '', txt)
decl = sorted(set(re.findall(r'^\s*fun\s*(?:\{[^}]*\})?\s*(\w+)', txt, re.M)) | set(re.findall(r'^fun\{[^}]*\}\s*\n\s*(\w+)', txt, re.M)))
ids = set(re.findall(r'\b(\w+)\b', cases + open(os.path.join(d, 'm2compat_hand.hats')).read()))
miss = [f for f in decl if f not in ids]
print('functions of pats_dmacro2.sats: %d declared, called %d' % (len(decl), len(decl) - len(miss)), 'missing:', miss)
# the d2exp / p2at / d2ecl constructors that eval1 handles: (arms of eval1_d2exp / eval1_p2at / eval1_d2ecl); built by the smart constructors of the cases
e1 = open(os.path.join(d, '..', 'pats_dmacro2_eval1.dats')).read()
arms = sorted(set(re.findall(r'^\| ~(D2E\w+|P2T\w+|D2C\w+)', e1, re.M)))
dspec = open(os.path.join(d, '..', 'pats_dynexp2.spec')).read()
allc = set(re.findall(r'^\s+((?:D2E|P2T|D2C)\w+)\s*\(', dspec, re.M))
ids2 = set(re.findall(r'\b(\w+)\b', cases))
def built(c):
    pre = {'D2E': 'd2exp_', 'P2T': 'p2at_', 'D2C': 'd2ecl_'}[c[:3]]
    return ('K_' + c) in ids2 or (pre + c[3:].lower()) in ids2
print('eval1 arms: %d, constructors built by the cases: %d' % (len(arms), len([c for c in arms if built(c)])), 'missing:', [c for c in arms if not built(c)])
print('all d2exp/p2at/d2ecl constructors as inputs of eval1: %d, built %d' % (len(allc), len([c for c in allc if built(c)])), 'not built:', sorted(c for c in allc if not built(c)))
if '--gcov' in sys.argv:
    od = os.path.join(d, 'm2obj_cov')
    for f in glob.glob(os.path.join(od, '*.gcda')): os.remove(f)
    subprocess.run([os.path.join(d, 'm2dump_cov')], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=od)
    for n in range(1, 8):   # the scenarios that end the process (m2exit.sh); the counters of the runs accumulate
        subprocess.run([os.path.join(d, 'm2dump_cov')], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=od, env=dict(os.environ, M2EXIT=str(n)))
    mods = ['pats_dmacro2', 'pats_dmacro2_eval0', 'pats_dmacro2_eval1', 'pats_dmacro2_print', 'pats_trans3_error']
    tot = 0; hit = 0
    for m in mods:
        subprocess.run(['gcov', '-o', '.', m + '_dats.c'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=od)
        # the gcov file of the ATS source (the line pragmas) is named after the source path
        fs = [f for f in glob.glob(os.path.join(od, '*.gcov')) if os.path.basename(f).startswith(m + '.dats')]
        if not fs: print('no gcov file for', m); continue
        n = 0; h = 0; unc = []
        for l in open(fs[0], errors='replace'):
            mm = re.match(r'^\s*([0-9#=\-]+\*?):\s*(\d+):(.*)$', l)
            if not mm: continue
            cnt, ln, src = mm.group(1), int(mm.group(2)), mm.group(3)
            if ln == 0 or cnt == '-': continue
            n += 1
            if cnt.startswith('#') or cnt.startswith('='): unc.append((ln, src.strip()))
            else: h += 1
        tot += n; hit += h
        print('%-26s %4d of %4d executable lines covered' % (m + '.dats', h, n))
        if '-v' in sys.argv:
            for ln, s in unc: print('    uncovered %d: %s' % (ln, s))
    print('TOTAL %d of %d executable lines (%.1f%%)' % (hit, tot, 100.0 * hit / max(tot, 1)))
