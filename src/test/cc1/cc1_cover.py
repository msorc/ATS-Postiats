#!/usr/bin/env python3
# usage: python3 cc1_cover.py   The coverage of the functions of the six modules of the C1 group: every function that a module implements (the ATS1 ones, in src/) is called by the
# common part of the test (cc1_common.hats, cc1_impl.hats, cc1_exit.hats), directly or through the doubles, and the generated scenarios use every operation (op_*) that the common part defines.
import re, os, glob
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..', '..')
S1 = os.environ.get('ATS1REF') or os.environ['ATS1SRC']
mods = ['ccompenv', 'environ', 'caseof', 'looping', 'trywith', 'lazyeval']
text = ''.join(open(os.path.join(d, f)).read() for f in ('cc1_common.hats', 'cc1_impl.hats', 'cc1_exit.hats'))
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'cc1_cases_[0-9][0-9].hats'))))
sats = open(os.path.join(M, 'pats_ccomp.sats')).read()
sats = re.sub(r'\(\*.*?\*\)', '', sats, flags=re.S)
declared = set(re.findall(r'\bfun\s+([A-Za-z_0-9]+)', sats))
tot = 0; miss = []; internal = []
for m in mods:
    src = open(os.path.join(S1, 'pats_ccomp_%s.dats' % m)).read()
    src = re.sub(r'\(\*.*?\*\)', '', src, flags=re.S)
    names = re.findall(r'\nimplement\s+([A-Za-z_0-9]+)', src)
    new = open(os.path.join(M, 'pats_ccomp_%s.dats' % m)).read()
    new = re.sub(r'\(\*.*?\*\)', '', new, flags=re.S)
    names2 = re.findall(r'\nimplement\s+([A-Za-z_0-9]+)', new)
    for n in names:
        if n not in declared:
            internal.append(n); continue
        tot += 1
        if n not in names2: miss.append(('not implemented in the port', n))
        elif n in ('hidexp_ccomp_ret_case', 'hidexp_ccomp_loop', 'hidexp_ccomp_loopexn', 'hidexp_ccomp_ret_trywith', 'hidexp_ccomp_ret_delay', 'hidexp_ccomp_ret_ldelay', 'hidexp_ccomp_ret_lazyeval'):
            if not re.search(r'\b%s\b' % n, text): miss.append(('not called', n))
        elif not re.search(r'\b%s\b' % n.replace('the_', 'the_').replace('_get', '_get').replace('_add', '_add'), text.replace('the_lst_', 'the_exndeclst_ the_saspdeclst_ the_extypelst_ the_extcodelst_ the_staloadlst_ the_dynloadlst_ ')):
            miss.append(('not called', n))
print('functions of pats_ccomp.sats implemented by the six modules in ATS1: %d; not covered: %s' % (tot, miss))
print('internal functions (covered through the lines, see cc1_gcov.sh): %s' % internal)
ops = set(re.findall(r'\nfun (op_\w+)', open(os.path.join(d, 'cc1_common.hats')).read()))
used = set(re.findall(r'\b(op_\w+)', cases))
print('operations of the common part: %d, used by the scenarios: %d; unused: %s' % (len(ops), len(ops & used), sorted(ops - used)))
