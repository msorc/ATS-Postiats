#!/usr/bin/env python3
# usage: python3 d2mutate.py REF.out REF.err   (the stdout and stderr of d2dump1, the ATS1 reference; see d2cmp.sh)
#
# Mutation test of the level-2 dynamic test: each mutation is a deliberate bug that is put in a ported module (the file is restored afterwards),
# d2dump is rebuilt and its output is compared with the ATS1 reference: every mutation must change the output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 ('pats_dynexp2.dats', 'p2at_refas forgets to insert the variable',
  'val dvs = $UT.lstord_insert<d2var>\n    (p2t.p2at_dvs(), d2v, cmp_d2vsym)', 'val dvs = $UT.lstord_insert<d2var>\n    (p2t.p2at_dvs(), d2v, cmp_d2vsym) val dvs = p2t.p2at_dvs()'),
 ('pats_dynexp2.dats', 'the fake npf of d2exp_app_sta_dyn',
  'if npf >= ~1 then', 'if npf >= 0 then'),
 ('pats_dynexp2.dats', 'the last clause of an ifcase is not looked at',
  '| ~GLnil() => i2fcl_is_else(x)', '| ~GLnil() => false'),
 ('pats_dynexp2.dats', 'a singleton sequence becomes empty',
  '    | ~GLnil() => d2e\n', '    | ~GLnil() => d2exp_empty(loc)\n'),
 ('pats_dynexp2.dats', 'the type of a mutable argument: the arguments of the at-type are swapped',
  'gopt_some(s2exp_at (s2e, s2l))', 'gopt_some(s2exp_at (s2l, s2e))'),
 ('pats_dynexp2.dats', 'the knd and the npf of a record pattern are swapped',
  'p2at_node_P2Trec(knd, npf, lp2ts)', 'p2at_node_P2Trec(npf, knd, lp2ts)'),
 ('pats_dynexp2.dats', 'the static variables of the constructor patterns are not collected',
  '| ~GLcons (x, xs) => f (p2at_svs_add_svarlst (res, x.s2qua_svs()), xs)', '| ~GLcons (x, xs) => f (res, xs)'),
 ('pats_dynexp2.dats', 'the else-kind of an ifcase',
  'val knd = (if opt then 1 else 0): int', 'val knd = (if opt then 0 else 1): int'),
 ('pats_dynexp2.dats', 'a pattern of the form existential does not collect its variables',
  'p2at_svs_add_svarlst (p2t.p2at_svs(), s2vs)', 'p2t.p2at_svs()'),
 ('pats_dynexp2_dvar.dats', 'the symbols of two variables are compared in the wrong order',
  '$SYM.compare_symbol_symbol (d2var_get_sym (x1), d2var_get_sym (x2))', '$SYM.compare_symbol_symbol (d2var_get_sym (x2), d2var_get_sym (x1))'),
 ('pats_dynexp2_dvar.dats', 'the level of a new variable',
  ', ~1 // level: toplevel is 0', ', 0 // level: toplevel is 0'),
 ('pats_dynexp2_dvar.dats', 'a stack of a map keeps the key when it is empty',
  'if glist_is_cons (xs1)\n        then avlmap_insert', 'if glist_is_nil (xs1)\n        then avlmap_insert'),
 ('pats_dynexp2_dvar.dats', 'the view variable of a pointer is linear 1',
  'val () = d2var_set_linval (d2vw, 0)', 'val () = d2var_set_linval (d2vw, 1)'),
 ('pats_dynexp2_dvar.dats', 'the map does not say that the key was there',
  'in\n  found\nend // end of [d2varmap_insert]', 'in\n  false\nend // end of [d2varmap_insert]'),
 ('pats_dynexp2_dvar.dats', 'the name of a view variable',
  'string0_append (nam, "$view")', 'string0_append (nam, "$vw")'),
 ('pats_dynexp2_dcst.dats', 'a static dcst is one that has no external definition 1',
  '| ~$SYN.DCSTEXTDEFnone(k) => (k = 0)', '| ~$SYN.DCSTEXTDEFnone(k) => (k = 1)'),
 ('pats_dynexp2_dcst.dats', 'a template constant has no template arguments',
  'glist_is_cons(d2cst_get_decarg(d2c))', 'glist_is_nil(d2cst_get_decarg(d2c))'),
 ('pats_dynexp2_dcst.dats', 'the order of the dcsts',
  '$effmask_all (compare (d2cst_get_stamp (x1), d2cst_get_stamp (x2)))', '$effmask_all (compare (d2cst_get_stamp (x2), d2cst_get_stamp (x1)))'),
 ('pats_dynexp2_dcst.dats', 'the map of the dcsts does not replace an existing key',
  'val () = map := $UN.cast{d2cstmap(a)}\n    (avlmap_insert (m, $UN.cast{ptr} (d2c), $UN.cast{ptr} (x), compare_d2cst_ptr))', 'val () = map := $UN.cast{d2cstmap(a)}\n    (if found then m else avlmap_insert (m, $UN.cast{ptr} (d2c), $UN.cast{ptr} (x), compare_d2cst_ptr))'),
 ('pats_dynexp2_util.dats', 'the constructors are selected by arity only when there are 3',
  'nd2cs >= 2', 'nd2cs >= 3'),
 ('pats_dynexp2_util.dats', 'a string is not a value, variable, lambda or constant',
  '| ~D2Estring _ => true', '| ~D2Estring _ => false'),
 ('pats_dynexp2_util.dats', 'the arity of a pattern',
  'if n = p1at_arity (p1t) then loop1 (d1e, ns) else false', 'if n <= p1at_arity (p1t) then loop1 (d1e, ns) else false'),
 ('pats_dynexp2_util.dats', 'the location of the root of a selection',
  'd2e.d2exp_loc() + d2l1.d2lab_loc()', 'd2e.d2exp_loc() + d2l2.d2lab_loc()'),
 ('pats_dynexp2_util.dats', 'a linear variable is mutable in a left-value',
  'then d2lval_D2LVALvar_lin(d2v, d2ls)', 'then d2lval_D2LVALvar_mut(d2v, d2ls)'),
 ('pats_dynexp2_util.dats', 'the overloaded symbol of a selection is the first one',
  '| ~GLnil () => d2l.d2lab_overld()', '| ~GLnil () => gopt_none()'),
 ('pats_dynexp2_print.dats', 'a space in a printer',
  'prstr "D2Elet(\\n"', 'prstr "D2Elet (\\n"'),
 ('pats_dynexp2_print.dats', 'the printer of a declaration',
  'fprint_string (out, "D2PITM(")', 'fprint_string (out, "D2PITM (")'),
 ('pats_dynexp2_print.dats', 'the kind of an extension in the printer',
  'prstr "D2Etup(knd="', 'prstr "D2Etup(kind="'),
 ('pats_dynexp2_dvar.dats', 'a variable is printed with its linear value instead of its level',
  'val () = fprint_int (out, d2var_get_level d2v)', 'val () = fprint_int (out, d2var_get_linval d2v)'),
 ('pats_dynexp2_dmac.dats', 'the printer of a macro argument',
  'prstr "M2ACARGsta("; fprint_s2varlst', 'prstr "M2ACARGsta ("; fprint_s2varlst'),
 ('pats_dynexp2_mapgen.dats', 'the data constructors are not collected',
  'val ((*void*)) = d2cs := d2conset_vt_add(d2cs, d2c)', 'val ((*void*)) = d2cs := d2cs'),
 ('pats_dynexp2_appenv.hats', 'the definition of an external variable is not traversed',
  '| ~D2Cextvar(name, d2e) => d2exp_app(d2e, env)', '| ~D2Cextvar(name, d2e) => ()'),
 ('pats_dynexp2_appenv.hats', 'the arguments of an array subscription are not traversed',
  'd2exp_app (d2e, env); d2explst_app (d2es_ind, env)', 'd2exp_app (d2e, env)'),
 ('pats_staexp2_appenv.hats', 'the arguments of a type application are not traversed',
  's2exp_app (s2e1, env); s2explst_app (s2es2, env)\n  ) (* end of [S2Eapp] *)', 's2exp_app (s2e1, env)\n  ) (* end of [S2Eapp] *)'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
ONLY = sys.argv[3:] if len(sys.argv) > 3 else None
def build():
    r = subprocess.run(['make', '-C', d, 'd2dump', '-j16'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    T = os.environ.get('TMPDIR', '/tmp')
    o = open(T + '/d2mut.out', 'w'); e = open(T + '/d2mut.err', 'w')
    subprocess.run([os.path.join(d, 'd2dump')], stdout=o, stderr=e, cwd=d)
    o.close(); e.close()
    return filecmp.cmp(T + '/d2mut.out', ref_out, shallow=False) and filecmp.cmp(T + '/d2mut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if ONLY and what not in ONLY: continue
    bak = os.environ.get('TMPDIR', '/tmp') + '/d2mut_backup_' + fn
    shutil.copy(path, bak)
    try:
        open(path, 'w').write(src.replace(old, new))
        nm += 1
        if not build(): res = 'detected (does not compile)'; nd += 1
        elif run(): res = 'NOT DETECTED'
        else: res = 'detected'; nd += 1
    finally:
        shutil.copy(bak, path)
        assert filecmp.cmp(path, bak, shallow=False)
    print('%-28s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
