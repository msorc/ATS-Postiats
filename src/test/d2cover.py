#!/usr/bin/env python3
# usage: python3 d2cover.py   (after d2_gen.py)  The coverage of the generated cases of the level-2 dynamic test: the constructors and the records of
# pats_dynexp2.spec (built by a wrapper K_x or by a smart constructor of the cases) and the functions declared in pats_dynexp2.sats that the ATS1
# sources implement (the cases call them). The functions that are only used internally are listed too.
import re, os, glob, sys
d = os.path.dirname(os.path.abspath(__file__))
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 'd2cases_[0-9][0-9].hats'))))
helpers = ''.join(open(os.path.join(d, f)).read() for f in ('d2common1.hats', 'd2common2.hats', 'd2compat_hand3.hats'))
spec = open(os.path.join(d, '..', 'pats_dynexp2.spec')).read().split('\n')
cons = []; recs = []; cur = None
for l in spec:
    l = l.split('#', 1)[0].rstrip()
    m = re.match(r'^record\s+(\w+)\s*\(', l)
    if m: recs.append(m.group(1)); continue
    m = re.match(r'^type\s+(\w+)', l)
    if m: cur = m.group(1); continue
    m = re.match(r'^\s+(\w+)\s*\(', l)
    if m and cur: cons.append((cur, m.group(1)))
CELLS = set('d2cst d2var d2mac'.split())
used = set(re.findall(r'\bK_(\w+)', cases))
# the smart constructors build the nodes: d2exp_X, p2at_X, d2ecl_X (the name of the function is the lower-case name of the constructor)
ids = set(re.findall(r'\b(\w+)\b', cases + helpers))
def built(t, c):
    if c in used: return True
    pre = {'d2exp_node': 'd2exp_', 'p2at_node': 'p2at_', 'd2ecl_node': 'd2ecl_'}.get(t)
    return bool(pre) and (pre + c[3:].lower()) in ids
miss_c = [c for t, c in cons if not built(t, c)]
recmk = {'d2sym': 'd2sym_make', 'p2at': 'p2at_make_node', 'd2exp': 'd2exp_make_node', 'd2ecl': 'd2ecl_make_node', 'd2lab': 'd2lab_lab', 'labd2exp': 'labd2exp_make',
         'i2nvarg': 'i2nvarg_make', 'i2nvresstate': 'i2nvresstate_make', 'loopi2nv': 'loopi2nv_make', 'i2fcl': 'i2fcl_make', 'gm2at': 'gm2at_make', 'c2lau': 'c2lau_make',
         'sc2lau': 'sc2lau_make', 'f2undec': 'f2undec_make', 'v2aldec': 'v2aldec_make', 'v2ardec': 'v2ardec_make', 'prv2ardec': 'prv2ardec_make', 'i2mpdec': 'i2mpdec_make',
         'd2varlstref': 'K_d2varlstref'}
miss_r = [r for r in recs if r not in CELLS and r not in used and recmk.get(r, '') not in ids and ('K_' + r) not in ids]
print('constructors: %d, built %d' % (len(cons), len(cons) - len(miss_c)), 'missing:', miss_c)
print('records (not cells): %d, built %d' % (len([r for r in recs if r not in CELLS]), len([r for r in recs if r not in CELLS]) - len(miss_r)), 'missing:', miss_r)
# the functions
decl = []
txt = open(os.path.join(d, '..', 'pats_dynexp2.sats')).read()
txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
txt = re.sub(r'//.*', '', txt)
for m in re.finditer(r'^\s*(?:fun|and)\s*(?:\{[^}]*\})?\s*(\w+)', txt, re.M): decl.append(m.group(1))
for m in re.finditer(r'^fun\{[^}]*\}\s*\n\s*(\w+)', txt, re.M): decl.append(m.group(1))
for m in re.finditer(r'^fun\s*\n\s*(\w+)', txt, re.M): decl.append(m.group(1))
decl = sorted(set(decl))
# declared in ATS1 and never implemented there, or implemented in another module (see PORTING.md), or internal
notimpl = set('d2cst_set_decarg d2cst_is_fun d2symset_vt_nil d2symset_vt_add d2symset_vt_listize_free compare_d2cst_ptr compare_d2var_ptr d2varmap_zip_ptr'.split())
cand = [f for f in decl if f not in notimpl]
# the maps are called through the t_ wrappers of d2compat_hand3.hats (template arguments)
miss = [f for f in cand if f not in ids]
print('functions: %d declared, %d to call (the others: not implemented by ATS1 or internal), called %d' % (len(decl), len(cand), len(cand) - len(miss)))
print('missing:', ' '.join(miss))
