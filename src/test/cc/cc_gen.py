#!/usr/bin/env python3
# usage: python3 cc_gen.py   (rewrites cc_compat1.hats cc_compat2.hats cc_hand3_1.hats cc_hand3_2.hats cc_cases_NN.hats ccase_NN.dats ccase1_NN.dats cc_chunks*.hats)
#
# Test of the core modules of ccomp (pats_ccomp.dats, _tmplab, _tmpvar, _funlab, _funent, _d2env, _instrseq, _util, _print: the ATS2 ports of src/pats_ccomp*.dats)
# against the ATS1 build of src/ (see PORTING.md, "ccomp core modules"). Same method as hd_gen.py (it uses its machinery: the specs of staexp2, dynexp2, dynexp3,
# histaexp and hidynexp, the compat layers and the random builders of the hd test): ONE generated program of scenarios, written in the common subset of ATS1 and ATS2,
# is compiled by the ATS2 driver (ccdump.dats) and by the ATS1 driver (ccdump1.dats, linked with the ATS1 objects of the main tree); stdout and stderr must be identical.
#  * cc_compat2.hats / cc_compat1.hats: from ../../pats_ccomp.spec: a wrapper K_<CON> for every constructor and record, the typed list/option helpers (LN_/LC_/ON_/OS_), and a
#    COMPLETE dumper dd_<T> of every type; the cells tmplab, tmpvar, d2env, funlab, funent (abstract in ATS1) are built by the API and dumped through their getters.
#  * cc_cases_<k>.hats: the scenarios (cc_cases.py).
import os, re, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
T = os.path.dirname(d)          # src/test
M = os.path.dirname(T)          # src
sys.path.insert(0, d); sys.path.insert(0, os.path.join(T, 'hd')); sys.path.insert(0, T)
import hd_gen as H
G = H.G; C = H.d2_cases

# ---- the ccomp spec joins the others
n1 = len(G.order)
H.load_spec(os.path.join(M, 'pats_ccomp.spec'))
CCORDER = G.order[n1:]
CCELLS = ['tmplab', 'tmpvar', 'd2env', 'funlab', 'funent']
CC_LISTS = {}; CC_OPTS = {}
for l in open(os.path.join(M, 'pats_ccomp.spec')).read().split('\n'):
    l = l.split('#', 1)[0].rstrip()
    m = re.match(r'^typedef\s+(\w+)\s*=\s*glist\((\w+)\)\s*$', l)
    if m: CC_LISTS[m.group(1)] = m.group(2)
    m = re.match(r'^typedef\s+(\w+)\s*=\s*gopt\((\w+)\)\s*$', l)
    if m: CC_OPTS[m.group(1)] = m.group(2)
G.ONE1.update({'labprimval': 'LABPRIMVAL', 'hifundec2': 'HIFUNDEC2', 'hiimpdec2': 'HIIMPDEC2'})
G.TUP1['tmpmov'] = 2; G.ATS1TYPE['tmpmov'] = 'tmpmov'
G.LEAF.add('double'); C.LEAFT.add('double')
G.LEAF.discard('instrlst'); C.LEAFT.discard('instrlst')    # the placeholder of hd is now the real glist
G.LEAF.discard('funlab'); C.LEAFT.discard('funlab')        # (the hd cases use [mkfunlab (k)] for the placeholder: ScC.gv)
for c in CCELLS:
    G.CELLS.append(c)

CELL_DUMPERS = '''
and dd_tmplab (x: tmplab): void =
  (dd_ps "tmplab{"; dd_location (tmplab_get_loc (x)); dd_ps ","; dd_stamp (tmplab_get_stamp (x)); dd_ps "}")
and dd_tmpvar (x: tmpvar): void =
  (dd_ps "tmpvar{"; dd_location (tmpvar_get_loc (x)); dd_ps ","; dd_hisexp (tmpvar_get_type (x)); dd_ps ",ref="; dd_bool (tmpvar_isref (x));
   dd_ps ",ret="; dd_bool (tmpvar_isret (x)); dd_ps ",tailcal="; dd_int (tmpvar_get_tailcal (x)); dd_ps ",top="; dd_int (tmpvar_get_topknd (x));
   dd_ps ",origin="; fprint_tmpvaropt (dd_out, tmpvar_get_origin (x)); dd_ps ",suffix="; dd_int (tmpvar_get_suffix (x));
   dd_ps ",stamp="; dd_stamp (tmpvar_get_stamp (x)); dd_ps "}")
and dd_d2env (x: d2env): void =
  (dd_ps "d2env{"; dd_d2var (d2env_get_var (x)); dd_ps ","; dd_hisexp (d2env_get_type (x)); dd_ps "}")
and dd_funlab (x: funlab): void =
  (dd_ps "funlab{"; dd_string (funlab_get_name (x)); dd_ps ",level="; dd_int (funlab_get_level (x)); dd_ps ",funclo="; dd_funclo (funlab_get_funclo (x));
   dd_ps ",type="; dd_hisexp (funlab_get_type (x)); dd_ps ",tmpknd="; dd_int (funlab_get_tmpknd (x)); dd_ps ",d2c="; dd_d2cstopt (funlab_get_d2copt (x));
   dd_ps ",d2v="; dd_d2varopt (funlab_get_d2vopt (x)); dd_ps ",ncopy="; dd_int (funlab_get_ncopy (x)); dd_ps ",origin="; dd_funlabopt_shallow (funlab_get_origin (x));
   dd_ps ",suffix="; dd_int (funlab_get_suffix (x)); dd_ps ",tmparg="; dd_t2mpmarglst (funlab_get_tmparg (x));
   dd_ps ",funent="; dd_funentopt_shallow (funlab_get_funent (x)); dd_ps ",stamp="; dd_stamp (funlab_get_stamp (x)); dd_ps "}")
and dd_funent (x: funent): void =
  (dd_ps "funent{"; dd_location (funent_get_loc (x)); dd_ps ",lab="; fprint_funlab (dd_out, funent_get_lab (x)); dd_ps ",imparg="; dd_s2varlst (funent_get_imparg (x));
   dd_ps ",tmparg="; dd_s2explstlst (funent_get_tmparg (x)); dd_ps ",tmpsub="; dd_tmpsubopt (funent_get_tmpsub (x)); dd_ps ",tmpret="; dd_tmpvar (funent_get_tmpret (x));
   dd_ps ",flablst="; dd_funlablst (funent_get_flablst (x)); dd_ps ",flablst_fin="; dd_funlablstopt (funent_get_flablst_fin (x));
   dd_ps ",d2envlst="; dd_d2envlst (funent_get_d2envlst (x)); dd_ps ",d2envlst_fin="; dd_d2envlstopt (funent_get_d2envlst_fin (x));
   dd_ps ",vbindmap="; dd_vbindmap (funent_get_vbindmap (x)); dd_ps ",instrlst="; dd_instrlst (funent_get_instrlst (x));
   dd_ps ",tmpvarlst="; dd_tmpvarlst (funent_get_tmpvarlst (x)); dd_ps ",fnxlablst="; dd_funlablst (funent_get_fnxlablst (x)); dd_ps "}")
'''

def gen_compat(lang):
    saved = (G.order, G.lists, G.opts)
    G.order = CCORDER; G.lists = dict(CC_LISTS); G.opts = dict(CC_OPTS)
    try:
        s = G.gen_compat(lang)
    finally:
        G.order, G.lists, G.opts = saved
    # gen_compat ends with the hand dumpers of s2rtVar / s2VarBound (already defined by the earlier layers): drop them
    s = re.sub(r'\nand dd_s2rtVar \(x: s2rtVar\).*?\n\n', '\n', s, flags=re.S)
    s = re.sub(r'\nand dd_s2VarBound \(x: s2VarBound\).*?\n\n', '\n', s, flags=re.S)
    s = re.sub(r'^fun dd_s2rtVar \(x: s2rtVar\).*?\n\n', '', s, flags=re.S | re.M)
    s = re.sub(r'^fun dd_s2VarBound \(x: s2VarBound\).*?\n\n', '', s, flags=re.S | re.M)
    if lang == 1:
        # in ATS1 the [instrlst] of the constructors of primdec_node is the abstract ccomp_instrlst_type (the where-clause of the sats binds instrlst later)
        lines = s.split('\n')
        for i, l in enumerate(lines):
            m = re.match(r'^fun K_(PMDextvar|PMDvaldecs|PMDvaldecs_rec|PMDvardecs) \((.*)\): primdec_node = (\w+) \((.*)\)$', l)
            if m:
                ps = [p for p in m.group(2).split(', ')]
                args = m.group(4).split(', ')
                for j, p in enumerate(ps):
                    if p.endswith(': instrlst'): args[j] = '$UN.cast{ccomp_instrlst_type} (%s)' % args[j]
                lines[i] = 'fun K_%s (%s): primdec_node = %s (%s)' % (m.group(1), m.group(2), m.group(3), ', '.join(args))
            m = re.match(r'^  \| (PMDextvar|PMDvaldecs|PMDvaldecs_rec|PMDvardecs) \(', l)
            if m:
                lines[i] = re.sub(r'dd_instrlst \((a\d)\)', r'dd_instrlst ($UN.cast{instrlst} (\1))', l)
        s = '\n'.join(lines)
    return s.rstrip() + '\n' + CELL_DUMPERS

def hand3(lang):
    lv = 'List0_vt' if lang == 2 else 'List_vt'
    o = []
    for t in ('tmpvar', 'funlab', 'd2env'):
        o.append('''fun dd_listvt_%s (xs: %s (%s)): void = let
  fun loop (xs: %s (%s), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_%s x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end''' % (t, lv, t, lv, t, t))
    o.append('''fun dd_optvt_tmpvar (x: Option_vt (tmpvar)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_tmpvar e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"''')
    o.append('''fun dd_optvt_funlab (x: Option_vt (funlab)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_funlab e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"''')
    o.append('''fun dd_optvt_primval (x: Option_vt (primval)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_primval e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"''')
    return '(* generated by cc_gen.py: the hand dumpers that need the generated ones *)\n' + '\n'.join(o) + '\n'

import cc_cases

if __name__ == '__main__':
    C.put(os.path.join(d, 'cc_compat2.hats'), gen_compat(2))
    C.put(os.path.join(d, 'cc_compat1.hats'), gen_compat(1))
    C.put(os.path.join(d, 'cc_hand3_2.hats'), hand3(2))
    C.put(os.path.join(d, 'cc_hand3_1.hats'), hand3(1))
    cc_cases.main(G, C, H, d, M, T, CCORDER, CCELLS, CC_LISTS, CC_OPTS)
