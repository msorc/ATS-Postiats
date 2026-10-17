#!/usr/bin/env python3
# usage: python3 cgmutate.py REF.out REF.err [description ...]   (the stdout and stderr of cgdump1, the ATS1 reference; see cgcmp.sh)
#
# Mutation test of the codegen2/patcst2 test: each mutation is a deliberate bug that is put in a ported module (the file is restored afterwards),
# cgdump is rebuilt and its output is compared with the ATS1 reference: every mutation must change the output (be "detected").
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 ('pats_codegen2.dats', 'the declarations of the kind 2 are processed',
  'if knd <= 2', 'if knd <= 1'),
 ('pats_codegen2.dats', 'an absrec is dispatched as a fprint',
  'absrec_test_e1xp(x)\n  then codegen2_absrec(out, d2c0, xs)', 'absrec_test_e1xp(x)\n  then codegen2_fprint(out, d2c0, xs)'),
 ('pats_codegen2.dats', 'the body of a local is not looked at',
  '| ~D2Clocal(_, d2cs_body) => auxlst (d2cs_body)', '| ~D2Clocal(_, d2cs_body) => ()'),
 ('pats_codegen2_util.dats', 'the string keyword is compared with a different test',
  '| ~E1XPstring(name2) => (name = name2)', '| ~E1XPstring(name2) => (name <> name2)'),
 ('pats_codegen2_util.dats', 'the first constant of an item is not the one',
  '| ~GLcons(s2c, _) => Some_vt(s2c) | ~GLnil() => None_vt()', '| ~GLcons(s2c, _) => None_vt() | ~GLnil() => None_vt()'),
 ('pats_codegen2_util.dats', 'a tydef is a datatype',
  'if s2cst_is_tydef(s2c)', 'if s2cst_is_datype(s2c)'),
 ('pats_codegen2_util.dats', 'the template arguments of an application are written with parentheses',
  'aux_s2qualst(out, "<", ">", s2qs)', 'aux_s2qualst(out, "(", ")", s2qs)'),
 ('pats_codegen2_util.dats', 'a linear sort is t0p',
  'if s2rt_is_lin(s2t) then fprint_string(out, "vt0p")', 'if s2rt_is_lin(s2t) then fprint_string(out, "t0p")'),
 ('pats_codegen2_util.dats', 'the arrow of a function sort',
  'fprint_string(out, ") ->")', 'fprint_string(out, ") -> ")'),
 ('pats_codegen2_util.dats', 'a tuple is a record',
  'if istup then "$tup" else "$rec"', 'if istup then "$rec" else "$tup"'),
 ('pats_codegen2_util.dats', 'a flat record is a boxed one',
  'tyreckind_is_flted(knd)\n    val () =\n    if isflted', 'tyreckind_is_boxed(knd)\n    val () =\n    if isflted'),
 ('pats_codegen2_util.dats', 'the labels of a record are printed when they are numbers',
  'if $LAB.label_is_sym(l) then', 'if $LAB.label_is_int(l) then'),
 ('pats_codegen2_util.dats', 'a nonlinear boxed record is linear',
  'if s2exp_is_nonlin(s2e0)\n        then (fprint_string(out, tuprec); fprint_string(out, "_t"))', 'if s2exp_is_nonlin(s2e0)\n        then (fprint_string(out, tuprec); fprint_string(out, "_vt"))'),
 ('pats_codegen2_datype.dats', 'the clause of datcon',
  'fprint_string (out, " _ => \\""); fprint_string (out, name);', 'fprint_string (out, " => \\""); fprint_string (out, name);'),
 ('pats_codegen2_datype.dats', 'the tag of datcontag',
  'fprint_string (out, " _ => "); fprint_int (out, tag);', 'fprint_string (out, " _ => "); fprint_int (out, tag+1);'),
 ('pats_codegen2_datype.dats', 'the default name of datcontag',
  'fprint_string (out, "datcontag_");', 'fprint_string (out, "datcon_");'),
 ('pats_codegen2_datype.dats', 'the error message of datcon without a spec',
  ', ": error(codegen2): no spec on datatype is given\\n"\n) (* end of [val] *)\n//\nval () = (fprint_string (out, "*)"); fprint_newline (out))', ', ": error(codegen2): no spec on datatype given\\n"\n) (* end of [val] *)\n//\nval () = (fprint_string (out, "*)"); fprint_newline (out))'),
 ('pats_codegen2_fprint.dats', 'the default name of the fprint-function',
  'string0_append3("fprint_", name, "_")', 'string0_append3("fprint", name, "_")'),
 ('pats_codegen2_fprint.dats', 'the body of the separator loop of the declarations',
  'if n < narg then (auxsep1_n(n); loop(n+1))', 'if n <= narg then (auxsep1_n(n); loop(n+1))'),
 ('pats_codegen2_fprint.dats', 'the arguments of a constructor are numbered from 0',
  'if n <= narg then (auxarg3_n(n); loop(n+1))', 'if n < narg then (auxarg3_n(n); loop(n+1))'),
 ('pats_codegen2_fprint.dats', 'the pattern of an argument',
  'if (i != n) then fprint_string(out, "_")', 'if (i != n) then fprint_string(out, "__")'),
 ('pats_codegen2_fprint.dats', 'the separators between the arguments of a constructor',
  'if n > n0\n    then auxsep2_n(n)', 'if n > n0 + 1\n    then auxsep2_n(n)'),
 ('pats_codegen2_fprint.dats', 'the sep function',
  '"$sep(out) = fprint(out, \\",\\")"', '"$sep(out) = fprint(out, \\";\\")"'),
 ('pats_codegen2_absrec.dats', 'the exch field',
  '| ABSRECFLDexch() =>\n  {\n    val () = absrec_emit_decl(out, s2c0, tnm, l0, "exec", s2e)', '| ABSRECFLDexch() =>\n  {\n    val () = absrec_emit_decl(out, s2c0, tnm, l0, "exch", s2e)'),
 ('pats_codegen2_absrec.dats', 'a getref is a get',
  'else if is_getref(name) then @(ABSRECFLDgetref, s2e2)', 'else if is_getref(name) then @(ABSRECFLDget, s2e2)'),
 ('pats_codegen2_absrec.dats', 'the linearity of the sort of the typedef',
  'if ~islin\n  then fprint_string(out, "type") else fprint_string(out, "vtype")', 'if islin\n  then fprint_string(out, "type") else fprint_string(out, "vtype")'),
 ('pats_codegen2_absrec.dats', 'the separator of the universal arguments',
  'then fprint_string(out, ";")', 'then fprint_string(out, ",")'),
 ('pats_codegen2_absrec.dats', 'the default name of the record',
  'string0_append(s2cst_get_name(s2c0), "_")', 'string0_append(s2cst_get_name(s2c0), "__")'),
 ('pats_patcst2.dats', 'the complement of a boolean',
  'list_vt_sing (p2atcst_P2TCbool (~b))', 'list_vt_sing (p2atcst_P2TCbool (b))'),
 ('pats_patcst2.dats', 'a constructor of an extensible sum',
  'if tag >= 0 then let', 'if tag > 0 then let'),
 ('pats_patcst2.dats', 'a wildcard intersects nothing on the right',
  'else if p2atcst_is_P2TCany (p2tc2) then true', 'else if p2atcst_is_P2TCany (p2tc2) then false'),
 ('pats_patcst2.dats', 'the difference of an integer and a set',
  'if intinfset_is_member (xs, i1) then list_vt_sing (p2tc1) else list_vt_nil\n    // end of [P2TCint, P2TCintc]', 'if intinfset_is_member (xs, i1) then list_vt_nil else list_vt_sing (p2tc1)\n    // end of [P2TCint, P2TCintc]'),
 ('pats_patcst2.dats', 'the other columns of a complement are empty',
  'list_vt_cons (x, auxanys_lst (p2tcs1, list_vt_nil))', 'list_vt_cons (x, list_vt_nil)'),
 ('pats_patcst2.dats', 'a guarded clause',
  'if glist_is_cons (c2l.c2lau_gua()) then let', 'if glist_is_nil (c2l.c2lau_gua()) then let'),
 ('pats_patcst2.dats', 'the label sort is not stable',
  'if $LAB.compare_label_label (labp2atcst_lab (x), labp2atcst_lab (y)) < 0', 'if $LAB.compare_label_label (labp2atcst_lab (x), labp2atcst_lab (y)) <= 0'),
 ('pats_patcst2.dats', 'the suffix of an integer is not cut',
  'val ln = n - sfx', 'val ln = n'),
 ('pats_patcst2.dats', 'a box record is printed as a flat one',
  "val () = if knd > 0 then fprint_char (out, '\\'')", "val () = if knd > 1 then fprint_char (out, '\\'')"),
 ('pats_patcst2.dats', 'the arguments of the list cons are swapped',
  'p2atcst_P2TCcon(d2c_cons, glist_cons(x, glist_sing(ys)))', 'p2atcst_P2TCcon(d2c_cons, glist_cons(ys, glist_sing(x)))'),
 ('pats_patcst2.dats', 'the results of a constructor complement are appended in the wrong order',
  'p2atcstlst_vt_append (res1, res2)', 'p2atcstlst_vt_append (res2, res1)'),
 ('pats_patcst2.dats', 'the records are compared on the wrong side',
  'if sgn < 0 then\n        labp2atcstlst_inter_test (lxs1, lxs20)', 'if sgn > 0 then\n        labp2atcstlst_inter_test (lxs1, lxs20)'),
 ('pats_patcst2.dats', 'the separator of the fields of a record',
  'fprint_string (out, "= ");', 'fprint_string (out, "=");'),
 ('pats_patcst2.dats', 'the pattern of the as-pattern is dropped',
  '| ~P2Trefas (_(*d2v*), p2t) => p2at2cst (p2t)', '| ~P2Trefas (_(*d2v*), p2t) => mk_any ()'),
 ('pats_patcst2.dats', 'the difference of two records',
  'labp2atcstlstlst_prefix (lx1, lxss)', 'labp2atcstlstlst_prefix (lx2, lxss)'),
 ('pats_patcst2.dats', 'the sets of characters are printed with other brackets',
  'val () = prstr "[^"\n    val () = fprint_charset', 'val () = prstr "[~"\n    val () = fprint_charset'),
 ('pats_intinf_gmp.hats', 'the intinfset is in ascending order',
  '    if sgn > 0\n      then glist_cons (x1, intinfset_add (xs1, x))', '    if sgn < 0\n      then glist_cons (x1, intinfset_add (xs1, x))'),
 ('pats_utils.dats', 'the charset is in ascending order',
  '    if x1 > x\n      then glist_cons (x1, charset_add (xs1, x))', '    if x1 < x\n      then glist_cons (x1, charset_add (xs1, x))'),
]
ref_out, ref_err = sys.argv[1], sys.argv[2]
ONLY = sys.argv[3:] if len(sys.argv) > 3 else None
T = os.environ.get('TMPDIR', '/tmp')
def build():
    r = subprocess.run(['make', '-C', d, 'cgdump', '-j16'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    o = open(T + '/cgmut.out', 'w'); e = open(T + '/cgmut.err', 'w')
    subprocess.run([os.path.join(d, 'cgdump')], stdout=o, stderr=e, cwd=d)
    o.close(); e.close()
    return filecmp.cmp(T + '/cgmut.out', ref_out, shallow=False) and filecmp.cmp(T + '/cgmut.err', ref_err, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    path = os.path.join(M, fn)
    src = open(path).read()
    if old == new: continue
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if ONLY and what not in ONLY: continue
    bak = T + '/cgmut_backup_' + fn
    shutil.copy(path, bak)
    try:
        open(path, 'w').write(src.replace(old, new))
        # the .hats are included by the modules: the objects must be rebuilt
        if fn.endswith('.hats'):
            for dd in ('cgobj',):
                for f in os.listdir(os.path.join(d, dd)):
                    if f.endswith('_dats.o') and fn.startswith('pats_intinf'): os.utime(os.path.join(M, 'pats_intinf.dats'), None)
        nm += 1
        if not build(): res = 'detected (does not compile)'; nd += 1
        elif run(): res = 'NOT DETECTED'
        else: res = 'detected'; nd += 1
    finally:
        shutil.copy(bak, path)
        assert filecmp.cmp(path, bak, shallow=False)
        if fn.endswith('.hats'): os.utime(os.path.join(M, 'pats_intinf.dats'), None)
    print('%-28s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
