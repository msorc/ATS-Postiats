#!/usr/bin/env python3
# usage: python3 ccb_gen.py   (rewrites ccb_compat2.hats ccb_compat1.hats ccb_cases_NN.hats ccbcase_NN.dats ccbcase1_NN.dats ccb_chunks*.hats)
#
# Test of ccomp group B (pats_ccomp_{hitype,hipat,subst,template,main}.dats) against the ATS1 build of src/ (see PORTING.md, "ccomp group B").
# Same method as hd_gen.py (test/hd): ONE generated program of scenarios, written in the common subset of ATS1 and ATS2, is compiled by the ATS2 driver
# (ccbdump.dats: the ports of src/ and the test doubles of test/ccb/dbl) and by the ATS1 driver (ccbdump1.dats: the objects of src/ of the main tree);
# stdout and stderr of the two must be identical.
#  * ccb_compat2.hats / ccb_compat1.hats: from the specs of staexp2 .. hidynexp and pats_ccomp.spec: the wrappers K_<CON> and a COMPLETE dumper dd_<T> of every type
#    (tmplab, tmpvar, d2env, funlab, funent are abstract in ATS1: hand-written makers and dumpers in ccb_hand*.hats / ccb_common.hats).
#  * ccb_cases_<k>.hats: the scenarios (ccb_cases.py).
import os, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
T = os.path.dirname(d)          # src/test
M = os.path.dirname(T)          # src
sys.path.insert(0, T); sys.path.insert(0, os.path.join(T, 'hd')); sys.path.insert(0, d)
import hd_gen
G = hd_gen.G
import d2_cases

# ---- the types of pats_ccomp.spec
CCB_LEAF = ['tmplab', 'tmpvar', 'd2env', 'funlab', 'funent']
n0 = len(G.order)
hd_gen.load_spec(os.path.join(M, 'pats_ccomp.spec'))
CCORDER = [n for n in G.order[n0:] if n not in CCB_LEAF]
# the abstract types of ATS1: handles, dumped by hand (shallow: they are cyclic through funlab/funent)
G.LEAF.discard('instrlst')            # the REAL instrlst (glist (instr)) of pats_ccomp.sats
d2_cases.LEAFT.discard('instrlst')
for t in CCB_LEAF:
    G.LEAF.add(t); d2_cases.LEAFT.add(t)
    if t in G.recs: G.CELLS.append(t)
G.opts.pop('hifunlabopt', None); G.opts.pop('hiinstrlstopt', None)   # hand-written (ccb_hand_a*.hats): they hold the placeholders as words
G.ONE1.update({'labprimval': 'LABPRIMVAL', 'hifundec2': 'HIFUNDEC2', 'hiimpdec2': 'HIIMPDEC2'})
G.TUP1.update({'tmpmov': 2})
G.ATS1TYPE.update({'tmpmov': '@(tmprimval, tmpvar)'})
for r in ('tmplab', 'tmpvar', 'd2env', 'funlab', 'funent'):
    G.recs.pop(r, None)
    if r in G.order: G.order.remove(r)
# ---- the placeholders of hidynexp (funlab, instrlst) are the real types here: the lists/options that mention them are re-typed by the hand layer
CHAIN = {2: '''
and dd_vbindmap (m: vbindmap): void = let
  fun loop (xs: List0_vt (@(d2var, primval)), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var (x.0); dd_ps "->"; dd_primval (x.1); loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (d2varmap_listize<primval> (m), 0); dd_ps "]"
end // end of [dd_vbindmap]
and dd_hiinstrlstopt (x: hiinstrlstopt): void = (
  case+ gopt_view (x) of ~GOsome (y) => (dd_ps "some("; dd_instrlst ($UN.cast{instrlst} (y)); dd_ps ")") | ~GOnone () => dd_ps "-"
)
and dd_funent (x: funent): void = DD_FUNENT
''', 1: '''
and dd_vbindmap (m: vbindmap): void = let
  fun loop (xs: List_vt (@(d2var, primval)), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var (x.0); dd_ps "->"; dd_primval (x.1); loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (d2varmap_listize {primval} (m), 0); dd_ps "]"
end // end of [dd_vbindmap]
and dd_hiinstrlstopt (x: hiinstrlstopt): void = (
  case+ x of Some (y) => (dd_ps "some("; dd_instrlst ($UN.cast{instrlst} (y)); dd_ps ")") | None () => dd_ps "-"
)
and dd_funent (x: funent): void = DD_FUNENT
'''}
DD_FUNENT = '''(
  dd_ps "funent{loc="; dd_location (funent_get_loc x);
  dd_ps ",lab="; dd_funlab (funent_get_lab x);
  dd_ps ",imparg="; dd_s2varlst (funent_get_imparg x);
  dd_ps ",tmparg="; dd_s2explstlst (funent_get_tmparg x);
  dd_ps ",tmpsub="; dd_tmpsubopt (funent_get_tmpsub x);
  dd_ps ",tmpret="; dd_tmpvar (funent_get_tmpret x);
  dd_ps ",flablst="; dd_funlablst (funent_get_flablst x);
  dd_ps ",flablst_fin="; dd_funlablstopt (funent_get_flablst_fin x);
  dd_ps ",d2envlst="; dd_d2envlst (funent_get_d2envlst x);
  dd_ps ",d2envlst_fin="; dd_d2envlstopt (funent_get_d2envlst_fin x);
  dd_ps ",vbindmap="; dd_vbindmap (funent_get_vbindmap x);
  dd_ps ",instrlst="; dd_instrlst (funent_get_instrlst x);
  dd_ps ",tmpvarlst="; dd_tmpvarlst (funent_get_tmpvarlst x);
  dd_ps ",fnxlablst="; dd_funlablst (funent_get_fnxlablst x);
  dd_ps "}"
)'''
CHAIN = {k: v.replace('DD_FUNENT', DD_FUNENT) for k, v in CHAIN.items()}

def gen_compat(lang):
    s = hd_gen.gen_compat(lang)
    s = s.rstrip('\n') + '\n' + CHAIN[lang]
    if lang == 1:
        # ATS1: the instrlst of the primdec nodes is the abstype ccomp_instrlst_type (a placeholder), the others are List (instr)
        for a, b in [('PMDextvar (a0, a1)\n', 'PMDextvar (a0, $UN.cast{ccomp_instrlst_type} (a1))\n'),
                     ('= PMDextvar (a0, a1)', '= PMDextvar (a0, $UN.cast{ccomp_instrlst_type} (a1))'),
                     ('= PMDvaldecs (a0, a1, a2)', '= PMDvaldecs (a0, a1, $UN.cast{ccomp_instrlst_type} (a2))'),
                     ('= PMDvaldecs_rec (a0, a1, a2)', '= PMDvaldecs_rec (a0, a1, $UN.cast{ccomp_instrlst_type} (a2))'),
                     ('= PMDvardecs (a0, a1)', '= PMDvardecs (a0, $UN.cast{ccomp_instrlst_type} (a1))'),
                     ('dd_string (a0); dd_ps ","; dd_instrlst (a1); dd_ps ")")', 'dd_string (a0); dd_ps ","; dd_instrlst ($UN.cast{instrlst} (a1)); dd_ps ")")'),
                     ('dd_hivaldeclst (a1); dd_ps ","; dd_instrlst (a2); dd_ps ")")', 'dd_hivaldeclst (a1); dd_ps ","; dd_instrlst ($UN.cast{instrlst} (a2)); dd_ps ")")'),
                     ('dd_hivardeclst (a0); dd_ps ","; dd_instrlst (a1); dd_ps ")")', 'dd_hivardeclst (a0); dd_ps ","; dd_instrlst ($UN.cast{instrlst} (a1)); dd_ps ")")')]:
            if a.endswith('\n'): continue
            assert a in s, a
            s = s.replace(a, b)
    for a, b in {2: [('fun K_HSEtyclo (a0: funlab): hisexp_node = hisexp_node_HSEtyclo (a0)', 'fun K_HSEtyclo (a0: funlab): hisexp_node = hisexp_node_HSEtyclo ($UN.cast{hisexp_funlab_type} (a0))'),
                     ('| ~HSEtyclo (a0) => (dd_ps "HSEtyclo("; dd_funlab (a0); dd_ps ")")', '| ~HSEtyclo (a0) => (dd_ps "HSEtyclo("; dd_funlab ($UN.cast{funlab} (a0)); dd_ps ")")')],
                 1: [('fun K_HSEtyclo (a0: funlab): hisexp_node = HSEtyclo (a0)', 'fun K_HSEtyclo (a0: funlab): hisexp_node = HSEtyclo ($UN.cast{hisexp_funlab_type} (a0))'),
                     ('| HSEtyclo (a0) => (dd_ps "HSEtyclo("; dd_funlab (a0); dd_ps ")")', '| HSEtyclo (a0) => (dd_ps "HSEtyclo("; dd_funlab ($UN.cast{funlab} (a0)); dd_ps ")")')]}[lang]:
        assert a in s, a
        s = s.replace(a, b)
    return s

def filt(path, drop):
    out = []
    for l in open(path).read().split('\n'):
        if any(l.startswith(p) for p in drop): continue
        out.append(l)
    return '\n'.join(out) + '\n'

def hand0(lang):
    return filt(os.path.join(T, 'd2compat_hand.hats' if lang == 2 else 'd2compat1_hand.hats'), ['fun mkfunlab ', 'fun mkhisexp '])

HAND_OPT = {2: '''
fun ON_hifunlabopt (): hifunlabopt = gopt_none ()
fun OS_hifunlabopt (x: funlab): hifunlabopt = gopt_some<hisexp_funlab_type> ($UN.cast{hisexp_funlab_type} (x))
fun dd_hifunlabopt (x: hifunlabopt): void = (
  case+ gopt_view (x) of ~GOsome (y) => (dd_ps "some("; dd_funlab ($UN.cast{funlab} (y)); dd_ps ")") | ~GOnone () => dd_ps "-"
)
fun ON_hiinstrlstopt (): hiinstrlstopt = gopt_none ()
fun OS_hiinstrlstopt (x: instrlst): hiinstrlstopt = gopt_some<hidynexp_instrlst_type> ($UN.cast{hidynexp_instrlst_type} (x))
''', 1: '''
fun ON_hifunlabopt (): hifunlabopt = None ()
fun OS_hifunlabopt (x: funlab): hifunlabopt = Some (x)
fun dd_hifunlabopt (x: hifunlabopt): void = (
  case+ x of Some (y) => (dd_ps "some("; dd_funlab (y); dd_ps ")") | None () => dd_ps "-"
)
fun ON_hiinstrlstopt (): hiinstrlstopt = None ()
fun OS_hiinstrlstopt (x: instrlst): hiinstrlstopt = Some (x)
'''}

def hand_a(lang):
    s = hd_gen.hand_a(lang)
    out = []
    for l in s.split('\n'):
        if l.startswith('fun dd_funlab ') or l.startswith('fun mkinstrlst ') or l.startswith('fun dd_instrlst '): continue
        if l.startswith('typedef instrlst = hidynexp_instrlst_type'): continue
        out.append(l)
    out.append(HAND_OPT[lang])
    return '\n'.join(out)

import ccb_cases

CCDYN = ['pats_ccomp', 'pats_ccomp_tmplab', 'pats_ccomp_tmpvar', 'pats_ccomp_funlab', 'pats_ccomp_funent', 'pats_ccomp_d2env', 'pats_ccomp_instrseq', 'pats_ccomp_util',
         'pats_ccomp_hitype', 'pats_ccomp_hipat', 'pats_ccomp_subst', 'pats_ccomp_template', 'pats_ccomp_main']

STUBS = ['fprint_instrlst', 'fprint_tmpsubopt']

def stubs():
    """ccb_stubs{1,2}.hats: [implement f (..) = abort] for the functions of the sats that the modules call and that no test reaches yet (generated from the sats)"""
    import ccb_sats
    tab = ccb_sats.parse(os.path.join(M, 'pats_ccomp.sats'))
    o1 = ['(* generated by ccb_gen.py: stubs of ccomp functions that the cases do not reach (ATS1) *)']
    o2 = ['(* generated by ccb_gen.py: stubs of ccomp functions that the cases do not reach (ATS2) *)']
    for n in STUBS:
        ps, ret = tab[n]
        assert '|' not in ret, n
        names = ', '.join('a%d' % i for i in range(len(ps)))
        o1.append('implement %s (%s) = $ERR.abort ()' % (n, names))
        o2.append('implement %s (%s) = $ERR.abort<%s> ()' % (n, names, ret))
    d2_cases.put(os.path.join(d, 'ccb_stubs1.hats'), '\n'.join(o1) + '\n')
    d2_cases.put(os.path.join(d, 'ccb_stubs2.hats'), '\n'.join(o2) + '\n')

def cdecls():
    """ccb_stub.h (the prototypes) and ccb_cdecl{1,2}.hats (the externs of the C functions of ccb_stub.c) from the table ccb_ctab.json"""
    import json
    tab = json.load(open(os.path.join(d, 'ccb_ctab.json')))
    cty = {'ptr': 'void*', 'int': 'int', 'void': 'void', 'FILEref': 'void*', 'string': 'void*', '&int >> int': 'void*'}
    h = ['/* generated by ccb_gen.py from ccb_ctab.json: the prototypes of the C functions of ccb_stub.c that the ATS side calls (a C function that is called without a prototype returns int) */']
    o1 = ['(* generated by ccb_gen.py: the C functions of ccb_stub.c (ATS1) *)', '%{^', '#include "ccb_stub.h"', '%}']
    o2 = ['(* generated by ccb_gen.py: the C functions of ccb_stub.c (ATS2) *)', '%{^', '#include "ccb_stub.h"', '%}']
    for name, args, ret in tab:
        h.append('extern %s %s (%s) ;' % (cty[ret], name, ', '.join(cty[a] for a in args) or 'void'))
        ps = ', '.join('a%d: %s' % (i, a) for i, a in enumerate(args))
        o1.append('extern fun %s (%s): %s = "%s"' % (name, ps, ret, name))
        o2.append('extern fun %s (%s): %s = "mac#%s"' % (name, ps, ret, name))
    d2_cases.put(os.path.join(d, 'ccb_stub.h'), '\n'.join(h) + '\n')
    d2_cases.put(os.path.join(d, 'ccb_cdecl1.hats'), '\n'.join(o1) + '\n')
    d2_cases.put(os.path.join(d, 'ccb_cdecl2.hats'), '\n'.join(o2) + '\n')

def drivers():
    """ccbdump.dats (ATS2) and ccbdump1.dats (ATS1): the dynload lists of the hd drivers plus the ccomp modules"""
    h2 = open(os.path.join(T, 'hd', 'hddump.dats')).read().split('\n')
    h1 = open(os.path.join(T, 'hd', 'hddump1.dats')).read().split('\n')
    dyn2 = [l for l in h2 if l.startswith('dynload ')]
    dyn1 = [l for l in h1 if l.startswith('dynload ')]
    dyn2 = [l for l in dyn2 if 'histaexp_funlab' not in l]
    o2 = ['(* ATS2 driver of the ccomp group B test (generated by ccb_gen.py; see PORTING.md, "ccomp group B"): the ports of src/ + the doubles of test/ccb/dbl *)',
          '#include "ccb_pre2.hats"', '']
    o2 += dyn2 + ['dynload "../pats_histaexp_funlab.dats"'] + ['dynload "../%s.dats"' % m for m in CCDYN]
    o2 += open(os.path.join(d, 'ccb_drv2.tail')).read().split('\n')
    o1 = ['(* ATS1 driver of the ccomp group B test (generated by ccb_gen.py): the ATS1 objects of src/ *)', '#include "ccb_pre1.hats"', '']
    o1 += dyn1 + ['dynload "pats_histaexp_funlab.dats"'] + ['dynload "%s.dats"' % m for m in CCDYN]
    o1 += open(os.path.join(d, 'ccb_drv1.tail')).read().split('\n')
    d2_cases.put(os.path.join(d, 'ccbdump.dats'), '\n'.join(o2) + '\n')
    d2_cases.put(os.path.join(d, 'ccbdump1.dats'), '\n'.join(o1) + '\n')

if __name__ == '__main__':
    d2_cases.put(os.path.join(d, 'ccb_compat2.hats'), gen_compat(2))
    d2_cases.put(os.path.join(d, 'ccb_compat1.hats'), gen_compat(1))
    d2_cases.put(os.path.join(d, 'ccb_common2.hats'), hd_gen.common2())
    d2_cases.put(os.path.join(d, 'ccb_hand0_2.hats'), hand0(2))
    d2_cases.put(os.path.join(d, 'ccb_hand0_1.hats'), hand0(1))
    d2_cases.put(os.path.join(d, 'ccb_hand_a2.hats'), hand_a(2))
    d2_cases.put(os.path.join(d, 'ccb_hand_a1.hats'), hand_a(1))
    ccb_cases.main(G, d2_cases, CCORDER, d, M, T)
    cdecls()
    stubs()
    drivers()
