#!/usr/bin/env python3
# usage: python3 hd_gen.py   (rewrites hd_compat2.hats hd_compat1.hats hd_hand_a2.hats hd_hand_a1.hats hd_cases_NN.hats hdcase_NN.dats hdcase1_NN.dats hd_chunks*.hats)
#
# Test of the erased trees (pats_hidynexp{,_print,_util}) and of the type erasure (pats_typerase_{error,staexp,dynexp,decl}) against the ATS1 build of src/
# (see PORTING.md, "Erased trees (hidynexp)" and "Type erasure (typerase)"). Same method as t3_gen.py: ONE generated program of scenarios, written in the
# common subset of ATS1 and ATS2, is compiled by the ATS2 driver (hddump.dats) and by the ATS1 driver (hddump1.dats, linked with the ATS1 objects of $ATS1REF);
# the stdout and the stderr of the two must be identical.
#  * hd_compat2.hats / hd_compat1.hats: from the specs of staexp2, dynexp2, dynexp3, histaexp and hidynexp: a wrapper K_<CON> for every constructor and
#    record, typed list/option helpers (LN_/LC_/ON_/OS_), and a COMPLETE dumper dd_<T> of every type (every constructor, every field).
#  * hd_cases_<k>.hats: the scenarios (hd_cases.py): random trees of the erased syntax and of the level-3 syntax, calls of every function of the modules.
import os, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
T = os.path.dirname(d)          # src/test
M = os.path.dirname(T)          # src
sys.path.insert(0, T); sys.path.insert(0, d)
import d2_gen, d2_cases
G = d2_gen

# ---- the leaf types that this test changes: [hisexp] is the REAL type (generated from pats_histaexp.spec), [instrlst] is a placeholder like [funlab]
G.LEAF.discard('hisexp'); d2_cases.LEAFT.discard('hisexp')
G.LEAF.add('instrlst'); d2_cases.LEAFT.add('instrlst')
G.ONE1.update({'labp3at': 'LABP3AT', 'labd3exp': 'DL0ABELED', 'labhipat': 'LABHIPAT', 'labhidexp': 'LABHIDEXP', 'hitnam': 'HITNAM', 'labhisexp': 'HSLABELED'})

def load_spec(path):
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

G.opts.pop('funlabopt')   # the placeholder funlab of pats_dynexp2.sats is not the funlab of pats_histaexp.sats
n0 = len(G.order)
for sp in ['pats_dynexp3.spec', 'pats_histaexp.spec', 'pats_hidynexp.spec']:
    load_spec(os.path.join(M, sp))
HDORDER = G.order[n0:]
HIORDER = [n for n in HDORDER if n.startswith('hi') or n.startswith('hd') or n.startswith('labhi') or n.startswith('HID') or n in ('hidecl_node', 'hidexp_node', 'hipat_node', 'hilab_node')]

def gen_compat(lang):
    s = G.gen_compat(lang)
    if lang == 1:
        # the index [n] of [c3lau (n)] of ATS1 (as t3_gen.py)
        m = re.search(r"fun K_c3lau \(([^)]*)\): c3lau = '\{[^\n]*\}", s)
        assert m
        s = s.replace(m.group(0), "fun K_c3lau (%s): c3lau = c3lau_make (a0, a1, a2, a3, a4, a5)" % m.group(1))
        b = 'fun LN_c3laulst (): c3laulst = list_nil ()'
        assert b in s
        s = s.replace(b, 'fun LN_c3laulst (): c3laulst = $UN.cast{c3laulst} (list_nil {ptr} ())')
        a = 'fun LC_c3laulst (x: c3lau, xs: c3laulst): c3laulst = list_cons (x, xs)'
        assert a in s
        s = s.replace(a, 'fun LC_c3laulst (x: c3lau, xs: c3laulst): c3laulst = $UN.cast{c3laulst} (list_cons ($UN.cast{ptr} (x), $UN.cast{List (ptr)} (xs)))')
        # the ATS1 records that are not '{..} literals / the fields that ATS1 hides behind placeholders
        for r in ('hifundec', 'hiimpdec'):
            m = re.search(r"fun K_%s \(([^)]*)\): %s = '\{[^\n]*\}" % (r, r), s)
            assert m, r
            if r == 'hifundec':
                new = ("fun K_hifundec (%s): hifundec = let\n  val x = hifundec_make (a0, a1, a2, a3)\n  val () = $UN.ptrset<hideclopt> (hifundec_getref_hideclopt (x), a4)\n"
                       "  val () = $UN.ptrset<hifunlabopt> (hifundec_getref_funlabopt (x), a5)\nin x end") % m.group(1)
            else:
                new = ("fun K_hiimpdec (%s): hiimpdec = let\n  val x = hiimpdec_make (a0, a1, a2, a3, a4, a5)\n  val () = $UN.ptrset<hifunlabopt> (hiimpdec_getref_funlabopt (x), a6)\n"
                       "  val () = $UN.ptrset<hiinstrlstopt> (hiimpdec_getref_instrlstopt (x), a7)\nin x end") % m.group(1)
            s = s.replace(m.group(0), new)
        for a, b in [('dd_hideclopt (x.hifundec_hidecl)', 'dd_hideclopt_shallow (hifundec_get_hideclopt (x))'),
                     ('dd_hifunlabopt (x.hifundec_funlab)', 'dd_hifunlabopt ($UN.ptrget<hifunlabopt> (hifundec_getref_funlabopt (x)))'),
                     ('dd_hifunlabopt (x.hiimpdec_funlab)', 'dd_hifunlabopt ($UN.ptrget<hifunlabopt> (hiimpdec_getref_funlabopt (x)))'),
                     ('dd_hiinstrlstopt (x.hiimpdec_instrlst)', 'dd_hiinstrlstopt ($UN.ptrget<hiinstrlstopt> (hiimpdec_getref_instrlstopt (x)))')]:
            assert a in s, a
            s = s.replace(a, b)
    else:
        a = 'dd_hideclopt (hifundec_hidecl (x))'
        assert a in s
        s = s.replace(a, 'dd_hideclopt_shallow (hifundec_hidecl (x))')
    return s

def hand_a(lang):
    """the layer of d2compat_hand2 / d2compat1_hand2 without the placeholder dumper of [hisexp] (it is the real type here), plus the placeholder [instrlst]"""
    f = os.path.join(T, 'd2compat_hand2.hats' if lang == 2 else 'd2compat1_hand2.hats')
    txt = open(f).read()
    out = []
    for l in txt.split('\n'):
        if l.startswith('fun dd_hisexp '): continue
        out.append(l)
    if lang == 1:
        out.insert(1, 'typedef instrlst = hidynexp_instrlst_type\ntypedef hifunlabopt = Option (funlab)\ntypedef hiinstrlstopt = Option (instrlst)')
    # a [hifundec] holds the declaration that holds it (hifundec_hidecl is set by the typerase of D3Cfundecs): the dump of the field is shallow
    if lang == 2:
        out.append('fun dd_hideclopt_shallow (x: hideclopt): void = (\n  case+ gopt_view (x) of ~GOsome (y) => (dd_ps "Some("; fprint_hidecl (dd_out, y); dd_ps ")") | ~GOnone () => dd_ps "None"\n)')
    else:
        out.append('fun dd_hideclopt_shallow (x: hideclopt): void = (\n  case+ x of Some (y) => (dd_ps "Some("; fprint_hidecl (dd_out, y); dd_ps ")") | None () => dd_ps "None"\n)')
    out.append('fun mkinstrlst (k: int): instrlst = $UN.cast{instrlst} (%s (k + 1))' % ('$UN.cast{lint}' if lang == 2 else 'lint_of_int'))
    out.append('fun dd_instrlst (x: instrlst): void = (dd_ps "instrlst#"; dd_int ($UN.cast{int} (%s)))' % ('$UN.cast{lint} (x)' if lang == 2 else '$UN.cast2lint (x)'))
    return '\n'.join(out) + '\n'

def common2():
    """d2common2.hats with the dumps of the fields of the cells that hold placeholders ([hisexp], [funlab] of pats_dynexp2.sats) cast to the real types"""
    t = open(os.path.join(T, 'd2common2.hats')).read()
    for a, b in [('dd_hisexpopt (d2cst_get_hisexp x)', 'dd_hisexpopt ($UN.cast{hisexpopt} (d2cst_get_hisexp x))'),
                 ('dd_funlabopt (d2cst_get_funlab x)', 'dd_hifunlabopt ($UN.cast{hifunlabopt} (d2cst_get_funlab x))'),
                 ('dd_hisexpopt (d2var_get_hisexp x)', 'dd_hisexpopt ($UN.cast{hisexpopt} (d2var_get_hisexp x))')]:
        assert a in t, a
        t = t.replace(a, b)
    return t

import hd_cases

if __name__ == '__main__':
    d2_cases.put(os.path.join(d, 'hd_compat2.hats'), gen_compat(2))
    d2_cases.put(os.path.join(d, 'hd_compat1.hats'), gen_compat(1))
    d2_cases.put(os.path.join(d, 'hd_common2.hats'), common2())
    d2_cases.put(os.path.join(d, 'hd_hand_a2.hats'), hand_a(2))
    d2_cases.put(os.path.join(d, 'hd_hand_a1.hats'), hand_a(1))
    hd_cases.main(G, d2_cases, HDORDER, d, M, T)
