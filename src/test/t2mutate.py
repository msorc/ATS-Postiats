#!/usr/bin/env python3
# t2mutate.py: sensitivity of the whole-file level-2 test (PORTING.md, "Level 2 translation (trans2)").
# usage: python3 t2mutate.py LIST [N]   LIST: a file of lines "KIND<TAB>path" (as t2files.sh builds); runs the first N mutants (default all).
# A copy of src is made in $W (default /tmp/t2mut); each mutant edits one .dats of the copy, rebuilds t2dump there and compares the dumps
# (stdout and stderr) of the ATS1 driver (reference, computed once) and of the mutated driver on LIST, in chunks of 30 files run in parallel.
import os, sys, subprocess, shutil, re, glob
here = os.path.dirname(os.path.abspath(__file__))
W = os.environ.get('W', '/tmp/t2mut')
JOBS = int(os.environ.get('JOBS', '28'))
LIST = os.path.abspath(sys.argv[1])
N = int(sys.argv[2]) if len(sys.argv) > 2 else 10**9
# (file, old, new, nth occurrence (1-based)): one deliberate bug each
MUT = [
 ('pats_trans2_env.dats', 't2env_cell_make<int> (1) // HX: the initial level is 1', 't2env_cell_make<int> (0) // HX: the initial level is 1', 1),
 ('pats_trans2_env.dats', 'if d2itm_is_D2ITMvar (d2i) then None_vt () else Some_vt (d2i)', 'Some_vt (d2i)', 1),
 ('pats_trans2_env.dats', 'val s2i = s2itm_S2ITMcst (glist_cons (s2c, s2cs))', 'val s2i = s2itm_S2ITMcst (glist_sing (s2c))', 1),
 ('pats_trans2_sort.dats', 'sort application is not supported.', 'sort application is not supported!', 1),
 ('pats_trans2_staexp.dats', 'then isprf else s2rt_is_prf(s2t_res)): bool', 'then isprf else false): bool', 1),
 ('pats_trans2_staexp.dats', '| ~GLnil() => (serr := serr + 1; glist_nil())', '| ~GLnil() => (serr := serr - 1; glist_nil())', 1),
 ('pats_trans2_staexp.dats', 'val sgn = n - (1(*rt*) + arity)', 'val sgn = n - arity', 1),
 ('pats_trans2_p1at.dats', 'in d2con_select_arity (d2cs, n)', 'in d2con_select_arity (d2cs, n+1)', 1),
 ('pats_trans2_dynexp.dats', '  val () = the_d2varlev_inc ()', '  val () = ()', 1),
 ('pats_trans2_dynexp.dats', 'if sc2lau_get_dstag (y) - kx <= 0', 'if sc2lau_get_dstag (y) - kx < 0', 1),
 ('pats_trans2_dynexp.dats', '    if knd = 0\n', '    if knd = 1\n', 1),
 ('pats_trans2_dynexp.dats', 'if n != np2ts then', 'if n < np2ts then', 1),
 ('pats_trans2_decl.dats', 'val d2pis_new = glist_cons(d2pi, d2pis)', 'val d2pis_new = glist_append<d2pitm> (d2pis, glist_sing<d2pitm> (d2pi))', 1),
 ('pats_trans2_decl.dats', 'in aux (i+1, d2cs)', 'in aux (i+2, d2cs)', 1),
 ('pats_trans2_decl.dats', 'if d2con_get_arity_real(d2c1) = 0', 'if d2con_get_arity_real(d2c1) > 0', 1),
 ('pats_trans2_decl.dats', ') => @(fenv, 1)', ') => @(fenv, 0)', 1),
 ('pats_trans2_decl.dats', 'if isrec then the_d2expenv_add_dvarlst (d2vs) else ()', 'if true then the_d2expenv_add_dvarlst (d2vs) else ()', 1),
 ('pats_trans2_impdec.dats', 'val () = d2cst_set_def (d2c, gopt_some d2e)', 'val () = ()', 1),
 ('pats_trans2_impdec.dats', 'if lin1 < lin2 then prerr ": linear function is given a nonlinear type."', 'if lin1 > lin2 then prerr ": linear function is given a nonlinear type."', 1),
 ('pats_trans2_decl.dats', 'val () = if knd >= 2 then the_d2expenv_add_dmacdef (d2m)', 'val () = if knd >= 1 then the_d2expenv_add_dmacdef (d2m)', 1),
 ('pats_trans2_decl.dats', 'if knd >= 0 then gopt_some(s2rt_impred(knd)) else gopt_none()', 'if knd > 0 then gopt_some(s2rt_impred(knd)) else gopt_none()', 1),
 ('pats_trans2_env.dats', 'val () = the_namespace_pop ()\n  val () = the_s2rtenv_pop_free', 'val () = the_s2rtenv_pop_free', 1),
 ('pats_trans2_staexp.dats', 'val okay = s2rt_ltmat1(s2t0, s2t)', 'val okay = s2rt_ltmat1(s2t, s2t0)', 1),
 ('pats_trans2_decl.dats', '  s1rt_tr(d0.s1tacst_res())', '  s2rt_int', 1),
]

def sh(cmd, **kw):
    return subprocess.run(cmd, shell=True, **kw)

def chunks(listfile, dst, n=30):
    lines = open(listfile).read().split('\n')
    lines = [l for l in lines if l]
    os.makedirs(dst, exist_ok=True)
    names = []
    for i in range(0, len(lines), n):
        nm = os.path.join(dst, 'c_%04d' % (i // n))
        open(nm, 'w').write('\n'.join(lines[i:i+n]) + '\n')
        names.append(nm)
    return names

def run_all(binary, names, tag, cwd):
    cmds = ['cd %s && sh ./d1chunk.sh %s %s %s.%s' % (cwd, binary, nm, nm, tag) for nm in names]
    open(os.path.join(W, 'cmds.txt'), 'w').write('\n'.join(cmds) + '\n')
    sh('cat %s/cmds.txt | xargs -P %d -I{} sh -c "{}"' % (W, JOBS))

def same(names, t1, t2):
    bad = 0
    for nm in names:
        for ext in ('o', 'e'):
            a = open('%s.%s.%s' % (nm, t1, ext), 'rb').read()
            b = open('%s.%s.%s' % (nm, t2, ext), 'rb').read()
            if a != b: bad += 1; break
    return bad

os.makedirs(W, exist_ok=True)
names = chunks(LIST, os.path.join(W, 'lists'))
if not os.path.exists(os.path.join(W, 'src')):
    sh('cp -a %s %s/src' % (os.path.join(here, '..'), W))
    # the names of the C functions contain the path of the source: everything is rebuilt in the copy
    sh('rm -rf %s/src/test/t2obj %s/src/test/t2dump %s/src/test/pats_error_sats.c' % (W, W, W))
    sh('cd %s/src/test && make -j%d t2dump > make.log 2>&1' % (W, JOBS))
T = os.path.join(W, 'src', 'test')
if not all(os.path.exists(nm + '.ref.o') for nm in names):
    run_all(os.path.join(here, 't2dump1'), names, 'ref', here)
res = []
for k, (f, old, new, nth) in enumerate(MUT[:N]):
    path = os.path.join(W, 'src', f)
    orig = os.path.join(here, '..', f)
    s = open(orig).read()
    idx = -1
    for _ in range(nth):
        idx = s.find(old, idx + 1)
        assert idx >= 0, 'mutant %d: pattern not found: %r' % (k, old)
    open(path, 'w').write(s[:idx] + new + s[idx + len(old):])
    r = sh('cd %s && make -j%d t2dump > make.log 2>&1' % (T, JOBS))
    if r.returncode != 0:
        res.append((k, f, 'BUILD FAILED')); print(k, f, 'BUILD FAILED', flush=True)
        shutil.copy(orig, path); continue
    run_all(os.path.join(T, 't2dump'), names, 'mut', T)
    bad = same(names, 'ref', 'mut')
    res.append((k, f, 'detected (%d of %d chunks differ)' % (bad, len(names)) if bad else 'NOT DETECTED'))
    print(k, f, old[:50].replace('\n', ' '), '->', res[-1][2], flush=True)
    shutil.copy(orig, path)
sh('cd %s && make -j%d t2dump > make.log 2>&1' % (T, JOBS))
nd = sum(1 for r in res if r[2].startswith('detected'))
print('mutants: %d, detected: %d' % (len(res), nd))
