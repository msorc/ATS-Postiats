#!/usr/bin/env python3
# usage: python3 t3_gen.py   (rewrites t3compat_gen.hats t3compat1_gen.hats t3cases_*.hats t3case_*.dats t3case1_*.dats t3chunks*.hats)
#
# Test of the level-3 trees (pats_dynexp3{,_print}) and of the type-checking environment (pats_trans3_env{,_dvar,_effect,_lamlp,_lstate,_pfman,
# _print,_scst,_svar,_termet}) against the ATS1 build of src/ (see PORTING.md, "Level 3 trees (dynexp3)" and "Type-checking environment (trans3_env)").
# Same method as d2_gen.py: ONE generated program of scenarios, written in the common subset of ATS1 and ATS2, is compiled by the ATS2 driver
# (t3dump.dats) and by the ATS1 driver (t3dump1.dats, linked with the ATS1 objects of $ATS1REF); stdout and stderr must be identical.
# The compat layers (K_<CON> wrappers and complete dumpers dd_<T>) are those of d2_gen.py, extended with the specs of dynexp3 and trans3_env.
import os, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import d2_gen, d2_cases

def load_spec(path):
    G = d2_gen
    cur = None
    for l in open(path).read().split('\n'):
        l = l.split('#', 1)[0].rstrip()
        if not l: continue
        m = re.match(r'^typedef\s+(\w+)\s*=\s*glist\((\w+)\)\s*$', l)
        if m: G.lists[m.group(1)] = m.group(2); continue
        m = re.match(r'^typedef\s+(\w+)\s*=\s*gopt\((\w+)\)\s*$', l)
        if m: G.opts[m.group(1)] = m.group(2); continue
        if l.startswith('typedef') or l.startswith('vtypedef'): continue
        m = re.match(r'^record\s+(\w+)\s*\((.*)\)\s*$', l)
        if m:
            fs = []
            for p in G.splitf(m.group(2)):
                mm = re.match(r'^(mut\s+)?(\w+)\s*:\s*(.+)$', p)
                fs.append((mm.group(2), mm.group(3).strip()))
                if mm.group(1): G.mut.setdefault(m.group(1), []).append(mm.group(2))
            G.recs[m.group(1)] = fs; G.order.append(m.group(1)); cur = None
            continue
        m = re.match(r'^type\s+(\w+)\s*$', l)
        if m:
            cur = m.group(1); G.types[cur] = []; G.order.append(cur); continue
        m = re.match(r'^\s+(\w+)\s*\((.*)\)\s*$', l)
        if m and cur:
            G.types[cur].append((m.group(1), [p.strip() for p in G.splitf(m.group(2))])); continue
        raise Exception('spec line: ' + l)

D3ORDER = []
n0 = len(d2_gen.order)
for sp in ['pats_dynexp3.spec', 'pats_trans3_env.spec']:
    load_spec(os.path.join(d, '..', sp))
D3ORDER = d2_gen.order[n0:]
d2_gen.ONE1['labp3at'] = 'LABP3AT'
d2_gen.ONE1['labd3exp'] = 'DL0ABELED'
d2_gen.LEAF.add('p2atcstlst')
d2_cases.LEAFT.add('p2atcstlst')

def gen_compat(lang):
    s = d2_gen.gen_compat(lang)
    if lang == 1:
        a = "fun K_c3nstroptref (a0: location, a1: c3nstropt): c3nstroptref = '{ c3nstroptref_loc= a0, c3nstroptref_val= a1 }"
        assert a in s
        s = s.replace(a, "fun K_c3nstroptref (a0: location, a1: c3nstropt): c3nstroptref = '{ c3nstroptref_loc= a0, c3nstroptref_ref= ref (a1) }")
        assert 'x.c3nstroptref_val' in s
        s = s.replace('x.c3nstroptref_val', '!(x.c3nstroptref_ref)')
        m = re.search(r"fun K_c3lau \(([^)]*)\): c3lau = '\{[^\n]*\}", s)
        assert m
        s = s.replace(m.group(0), "fun K_c3lau (%s): c3lau = c3lau_make (a0, a1, a2, a3, a4, a5)" % m.group(1))
        b = 'fun LN_c3laulst (): c3laulst = list_nil ()'
        assert b in s
        s = s.replace(b, 'fun LN_c3laulst (): c3laulst = $UN.cast{c3laulst} (list_nil {ptr} ())')
        a = 'fun LC_c3laulst (x: c3lau, xs: c3laulst): c3laulst = list_cons (x, xs)'
        assert a in s
        s = s.replace(a, 'fun LC_c3laulst (x: c3lau, xs: c3laulst): c3laulst = $UN.cast{c3laulst} (list_cons ($UN.cast{ptr} (x), $UN.cast{List (ptr)} (xs)))')
    return s

import t3_cases

def expand_hand(lang, name='t3hand.tmpl'):
    out = []
    for l in open(os.path.join(d, name)).read().split('\n'):
        m = re.match(r'^([12])\|(.*)$', l)
        if m:
            if int(m.group(1)) != lang: continue
            l = m.group(2)
        out.append(l.replace('<<(', '@(' if lang == 2 else '('))
    return '\n'.join(out) + '\n'

if __name__ == '__main__':
    d2_cases.put(os.path.join(d, 't3compat_gen.hats'), gen_compat(2))
    d2_cases.put(os.path.join(d, 't3compat1_gen.hats'), gen_compat(1))
    d2_cases.put(os.path.join(d, 't3hand.hats'), expand_hand(2))
    d2_cases.put(os.path.join(d, 't3hand1.hats'), expand_hand(1))
    d2_cases.put(os.path.join(d, 't3env.hats'), expand_hand(2, 't3env.tmpl'))
    d2_cases.put(os.path.join(d, 't3env1.hats'), expand_hand(1, 't3env.tmpl'))
    t3_cases.main(d2_gen, d2_cases, D3ORDER)
