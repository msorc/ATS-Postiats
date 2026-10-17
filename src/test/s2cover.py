#!/usr/bin/env python3
# usage: python3 s2cover.py   (after s2_gen.py)  The coverage of the generated cases: the constructors and the records of the specs and the
# functions declared in pats_staexp2.sats, pats_staexp2_util.sats, pats_staexp2_error.sats, pats_namespace.sats, pats_stacst2.sats, pats_staexp2_solve.sats that the ATS1 sources implement
# and that the cases call (the functions that are only used internally are listed too).
import re, os, glob, sys
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
cases = ''.join(open(f).read() for f in sorted(glob.glob(os.path.join(d, 's2cases_[0-9][0-9].hats'))))
out = open(os.path.join(d, 's2dump_stdout.txt')).read() if os.path.exists(os.path.join(d, 's2dump_stdout.txt')) else ''
# constructors
specs = []
for sp in ('pats_staexp2.spec', 'pats_staexp2_error.spec'):
    specs += open(os.path.join(d, '..', sp)).read().split('\n')
cons = []; recs = []
cur = None
for l in specs:
    l = l.split('#', 1)[0].rstrip()
    m = re.match(r'^record\s+(\w+)\s*\(', l)
    if m: recs.append(m.group(1)); continue
    m = re.match(r'^type\s+(\w+)', l)
    if m: cur = m.group(1); continue
    m = re.match(r'^\s+(\w+)\s*\(', l)
    if m and cur: cons.append((cur, m.group(1)))
# the cells are not built with K_
CELLS = set('s2rtdat s2rtVar s2cst s2var s2Var s2VarBound s2hole s2ctxt d2con'.split())
used = set(re.findall(r'\bK_(\w+)', cases))
# also the constructors that appear in the dumper output (the records of the output)
miss_c = [c for t, c in cons if c not in used]
miss_r = [r for r in recs if r not in CELLS and r not in used]
print('constructors: %d, used %d' % (len(cons), len(cons) - len(miss_c)), 'missing:', miss_c)
print('records (not cells): %d, used %d' % (len([r for r in recs if r not in CELLS]), len([r for r in recs if r not in CELLS]) - len(miss_r)), 'missing:', miss_r)
# functions
unimpl = set(open(os.path.join(d, 's2unimpl.txt')).read().split()) if os.path.exists(os.path.join(d, 's2unimpl.txt')) else set()
decl = []
for f in ('pats_staexp2.sats', 'pats_staexp2_util.sats', 'pats_staexp2_error.sats', 'pats_namespace.sats', 'pats_stacst2.sats', 'pats_staexp2_solve.sats'):
    txt = open(os.path.join(d, '..', f)).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//.*', '', txt)
    for m in re.finditer(r'^\s*(?:fun|and)\s*(?:\{[^}]*\})?\s*(\w+)', txt, re.M): decl.append(m.group(1))
    for m in re.finditer(r'^(\w+)\s*$', txt, re.M): pass
    # "fun{a:type}\nname" forms
    for m in re.finditer(r'^fun\{[^}]*\}\s*\n\s*(\w+)', txt, re.M): decl.append(m.group(1))
    for m in re.finditer(r'^fun\s*\n\s*(\w+)', txt, re.M): decl.append(m.group(1))
decl = sorted(set(decl))
helpers = ''.join(open(os.path.join(d, f)).read() for f in ('s2common1.hats', 's2common2.hats', 's2glue2_post.hats', 's2glue2_pre.hats', 's2glue2_mid.hats'))
ids = set(re.findall(r'\b(\w+)\b', cases + helpers))
INTERNAL_TO_STUB = set('s2exp_hnfize_flag_svar'.split())  # (implemented by the test double of trans3_env)
notimpl = set('s2cstref_get_exp s2cstref_unget_exp s2explst_opnexi s2explstlst_hnfize stacst2_initialize_ d2con_make_list_nil d2con_make_list_cons filenv_get_name fprint_s2vararg prerr_s2rtdat print_s2rtdat s2cst_get_arylst s2cst_get_iscpy s2cst_set_iscpy s2cst_set_isabs s2eff_contain_s2eff s2explst_tszeq s2rt_is_string s2var_is_boxed'.split())
cand = [f for f in decl if f not in INTERNAL_TO_STUB and f not in notimpl and not f.endswith('_type') and f not in ('SHARED', 'NSHARED')]
miss = [f for f in cand if f not in ids]
print('functions: %d declared, %d to call (the others: util2/util3 or unimplemented in ATS1), called %d' % (len(decl), len(cand), len(cand) - len(miss)))
print('missing:', ' '.join(miss))
