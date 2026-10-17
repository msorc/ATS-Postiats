#!/usr/bin/env python3
"""cc2mutate.py OUTDIR REFERENCE.out REFERENCE.err   Mutation test of the ATS2 ports of pats_ccomp_{dynexp,decl,claulst}.dats: for each deliberate bug below the module is mutated, recompiled
(in a private copy), relinked with the objects of the staging directory of cc2_2.sh (OUTDIR/stage2), run, and its stdout and stderr compared with the reference (the output of cc2_1, the ATS1
build); the cases that end the process (CC2EXIT) are compared through cc2exit.sh. A mutation is detected when something differs (or the compilation fails to link/run)."""
import sys, os, shutil, subprocess, tempfile, hashlib
from concurrent.futures import ThreadPoolExecutor
OUT = os.path.abspath(sys.argv[1]); REF = os.path.abspath(sys.argv[2]); REFERR = os.path.abspath(sys.argv[3])
W = os.path.join(OUT, 'stage2')
L = os.path.dirname(os.path.abspath(__file__))
D = 'pats_ccomp_dynexp.dats'; E = 'pats_ccomp_decl.dats'; C = 'pats_ccomp_claulst.dats'
M = [
 ('d2var_ccomp_some: environvar test', D, 'if lvl1 < lvl0 then let (* environvar *)', 'if lvl1 <= lvl0 then let (* environvar *)'),
 ('d2var_ccomp_some: toplevel variables', D, 'if lvl1 > 0 then primval_env', 'if lvl1 > 1 then primval_env'),
 ('ret_app: tail calls only with the flag', D, 'if tlcalopt > 0 then tmpvar_isret(tmpret) else false', 'if tlcalopt > 1 then tmpvar_isret(tmpret) else false'),
 ('ret_app: the counter of the tail calls', D, 'if added > 0 then tmpvar_inc_tailcal(tmpret)', 'if added > 1 then tmpvar_inc_tailcal(tmpret)'),
 ('ret_app: the ordinary call', D, 'if added = 0 then let', 'if added = 1 then let'),
 ('ret_if: the branches', D, 'val ins = instr_cond (loc0, pmv_cond, inss_then, inss_else)', 'val ins = instr_cond (loc0, pmv_cond, inss_else, inss_then)'),
 ('ret_rec: the kind of the record', D, '  if knd > 0 then\n    instr_move_boxrec', '  if knd > 1 then\n    instr_move_boxrec'),
 ('arrpsz: the pointer increment', D, 'if n >= 1 then let', 'if n >= 2 then let'),
 ('laminit: the closure of an inner function', D, 'if flvl > 0 then tmpvar_set2_tyclo(tmpret, flab)\n// end of [if] // end of [val]\n//\nval\nins =\ninstr_closure_initize(loc0, tmpret, gopt_none((*lam*))', 'if flvl > 1 then tmpvar_set2_tyclo(tmpret, flab)\n// end of [if] // end of [val]\n//\nval\nins =\ninstr_closure_initize(loc0, tmpret, gopt_none((*lam*))'),
 ('lam_flab: the template kind', D, 'if tmplev > 0 then funlab_set_tmpknd(flab, 1)', 'if tmplev > 1 then funlab_set_tmpknd(flab, 1)'),
 ('lam: knd != 0 is a value', D, '    if knd != 0\n      then auxval (env, res, tmpret, hde0)\n      else hidexp_ccomp_ret_laminit', '    if knd = 0\n      then auxval (env, res, tmpret, hde0)\n      else hidexp_ccomp_ret_laminit'),
 ('funlab_arg_body: the level of the arguments', D, 'hifunarg_ccomp (env, res, flab, lvl1, loc_fun, hips_arg)', 'hifunarg_ccomp (env, res, flab, flvl0, loc_fun, hips_arg)'),
 ('tmpcst: the template level', D, '\nelse if tmplev > 0 then let\n  in\n    primval_tmpltcst', '\nelse if tmplev > 1 then let\n  in\n    primval_tmpltcst'),
 ('var: the reference variable', D, 'if gopt_is_none(d2var_get_view(d2v))\n  then pmv (*val*)', 'if gopt_is_some(d2var_get_view(d2v))\n  then pmv (*val*)'),
 ('selvar: the view', D, '| ~GOsome(_) => primval_selptr (loc0, hse0, pmv, hse_rt, pmls)\n| ~GOnone() => primval_select2', '| ~GOsome(_) => primval_select2 (loc0, hse0, pmv, hse_rt, pmls)\n| ~GOnone() => primval_selptr'),
 ('fundecs: the first function of a group', E, 'if i <= 1 then the_funlablst_add(flab)', 'if i <= 0 then the_funlablst_add(flab)'),
 ('fundecs: the counter of a group', E, 'val i2 = (if i >= 1 then i + 1 else i): int\n    val flabs = auxinit', 'val i2 = (if i >= 2 then i + 1 else i): int\n    val flabs = auxinit'),
 ('fundecs: the tail call frame', E, 'if i = 0 then\n      ccompenv_inc_tailcalenv(env, flab)', 'if i = 1 then\n      ccompenv_inc_tailcalenv(env, flab)'),
 ('fundecs: the counter of mutual recursion', E, 'if i > 0 then\n        tmpvar_inc_tailcal', 'if i > 1 then\n        tmpvar_inc_tailcal'),
 ('fundecs: the template kind of a function', E, 'then true else glist_is_cons(decarg)', 'then false else glist_is_cons(decarg)'),
 ('valdecs: the failure of val+', E, '| VK_val_pos() => patckont_PTCKNTnone() | _ => patckont_PTCKNTcaseof_fail(loc)', '| VK_val_pos() => patckont_PTCKNTcaseof_fail(loc) | _ => patckont_PTCKNTnone()'),
 ('impdec: the template instances', E, '      if knd = 0 then\n        (if istmp then ccompenv_add_impdec(env, imp))', '      if knd = 1 then\n        (if istmp then ccompenv_add_impdec(env, imp))'),
 ('impdec: the function label of a constant', E, 'if not(istmp) then\n        $D2E.d2cst_set_funlab', 'if istmp then\n        $D2E.d2cst_set_funlab'),
 ('vardecs: a reference temporary', E, 'val tmp = tmpvar_make_ref (loc_d2v, hse_elt)', 'val tmp = tmpvar_make (loc_d2v, hse_elt)'),
 ('vardecs: the level', E, '  $D2E.d2var_set_level (d2v, lvl0)\nval opt_s2at', '  ()\nval opt_s2at'),
 ('patterns: a variable that is used', C, 'if nused > 0\n        then patcomp_PTCMPvar', 'if nused > 1\n        then patcomp_PTCMPvar'),
 ('patterns: a mutable variable has no move', C, 'if ismut then res2 else addtpmv(res2, tpmv)', 'if ismut then addtpmv(res2, tpmv) else res2'),
 ('matrix: the labels', C, 'if sgn = 0 then auxlst (xs1, xs2, tmvlst) else None_vt ()', 'if sgn != 0 then auxlst (xs1, xs2, tmvlst) else None_vt ()'),
 ('matrix: a matching test', C, '        if ismat\n          then None_vt () else let\n          val isbin', '        if not(ismat)\n          then None_vt () else let\n          val isbin'),
 ('matrix: a binarian constructor', C, 'if isbin then Some_vt (xs2) else Some_vt (xs20)', 'if isbin then Some_vt (xs20) else Some_vt (xs2)'),
 ('matrix: the order of the moves', C, 'val tmvlst1 = list_vt_reverse(tmvlst1)', 'val tmvlst1 = (tmvlst1)'),
 ('clauses: the guards', C, 'val isnot = glist_is_nil(hicl.hiclau_gua())', 'val isnot = glist_is_cons(hicl.hiclau_gua())'),
 ('jumps: the guard failure', C, '          if patckont_is_PTCKNTnone (ptjmp)\n            then () else set_patckontref_val (kntr, ptjmp)', '          if patckont_is_PTCKNTnone (ptjmp)\n            then set_patckontref_val (kntr, ptjmp) else ()'),
 ('jumps: the default continuation', C, 'if patckont_is_PTCKNTnone (patckontref_val (kntr))\n            then set_patckontref_val (kntr, fail) else ()', 'if patckont_is_PTCKNTnone (patckontref_val (kntr))\n            then () else set_patckontref_val (kntr, fail)'),
 ('clauses: the failure of a guard', C, 'patckont_PTCKNTcaseof_fail (loc)', 'patckont_PTCKNTnone ()'),
 ('instructions: the order of the checks', C, 'list_vt_reverse_append(res1, res2)', 'list_vt_reverse_append(res2, res1)'),
 ('jumps: the matching prefix', C, 'auxlst (xs1, xss2, glist_cons<patcomp> (x1, rxs))', 'auxlst (xs1, xss2, rxs)'),
]
SEL = [int(a) for a in sys.argv[4:] if a.isdigit()]
CF = ['-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-O1']
def md5(b): return hashlib.md5(b).hexdigest()
ref = open(REF, 'rb').read(); referr = open(REFERR, 'rb').read()
def run1(i):
    # the mutant replaces the module IN the staging directory (the C names contain the paths of the sats: one tree), which is restored afterwards
    name, f, old, new = M[i]
    path = os.path.join(W, f)
    src = open(path).read()
    if old not in src: return (i, 'PATTERN NOT FOUND')
    tmp = tempfile.mkdtemp(prefix='cc2mut')
    mod = f[:-5]
    try:
        open(path, 'w').write(src.replace(old, new, 1))
        r = subprocess.run(['patsopt', '--output', os.path.join(tmp, mod + '.c'), '-d', path], capture_output=True, cwd=os.path.join(W, 'obj'))
        if r.returncode != 0: return (i, 'compile error (patsopt): ' + r.stderr.decode()[:200].replace('\n', ' '))
        r = subprocess.run(['patscc'] + CF + ['-c', '-o', os.path.join(tmp, mod + '.o'), os.path.join(tmp, mod + '.c')], capture_output=True, cwd=os.path.join(W, 'obj'))
        if r.returncode != 0: return (i, 'compile error (gcc): ' + r.stderr.decode()[:200].replace('\n', ' '))
        objs = [os.path.join(W, 'obj', o) for o in sorted(os.listdir(os.path.join(W, 'obj'))) if o.endswith('.o') and o != mod + '.o']
        exe = os.path.join(tmp, 'cc2m')
        r = subprocess.run(['patscc'] + CF + ['-o', exe, os.path.join(tmp, mod + '.o')] + objs + ['-lgmp'], capture_output=True, cwd=os.path.join(W, 'obj'))
        if r.returncode != 0: return (i, 'link error: ' + r.stderr.decode()[:200].replace('\n', ' '))
        try:
            r = subprocess.run([exe], capture_output=True, timeout=300)
        except subprocess.TimeoutExpired:
            return (i, 'DETECTED (timeout)')
        if r.stdout != ref or r.stderr != referr: return (i, 'DETECTED')
        r2 = subprocess.run(['sh', os.path.join(L, 'cc2exit.sh'), exe], capture_output=True, timeout=600)
        r3 = subprocess.run(['sh', os.path.join(L, 'cc2exit.sh'), os.path.join(OUT, 'cc2')], capture_output=True, timeout=600)
        if r2.stdout != r3.stdout: return (i, 'DETECTED (exit cases)')
        return (i, 'SURVIVED')
    finally:
        open(path, 'w').write(src)
        shutil.rmtree(tmp, ignore_errors=True)
idx = SEL if SEL else list(range(len(M)))
res = []
with ThreadPoolExecutor(max_workers=1) as ex:
    for i, st in ex.map(run1, idx):
        print('%2d %-50s %s' % (i, M[i][0], st)); sys.stdout.flush()
        res.append(st)
det = sum(1 for s in res if s.startswith('DETECTED'))
print('mutations: %d detected of %d' % (det, len(res)))
