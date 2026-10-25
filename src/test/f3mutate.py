#!/usr/bin/env python3
# f3mutate.py: sensitivity of the whole-file test of the type checker (PORTING.md, "Level 3 integration").
# usage: python3 f3mutate.py LIST [N [FIRST]]   LIST: a file of lines "KIND<TAB>path" (all.txt of f3files.sh: the corpus, and/or t3list.txt of the hand-written
# cases); runs the mutants FIRST .. FIRST+N-1 (default all). A copy of src is made in $W (default /tmp/f3mut, rebuilt from scratch: the C names contain
# the path of the source); each mutant edits one .dats of the copy, rebuilds f3dump there and compares the md5 of the dumps (stdout, normalized stderr) of the
# ATS1 driver (reference, computed once) and of the mutated driver on LIST, in chunks of 30 lines run in parallel (f3runmd5.sh).
# SAMPLE=k keeps one line in k of LIST.
import os, sys, subprocess, shutil, re
here = os.path.dirname(os.path.abspath(__file__))
W = os.environ.get('W', '/tmp/f3mut')
JOBS = int(os.environ.get('JOBS', '28'))
LIST = os.path.abspath(sys.argv[1])
N = int(sys.argv[2]) if len(sys.argv) > 2 else 10**9
FIRST = int(sys.argv[3]) if len(sys.argv) > 3 else 0
SAMPLE = int(os.environ.get('SAMPLE', '1'))
# (file, old, new, nth occurrence (1-based)): one deliberate bug each
MUT = [
 ('pats_trans3_dynexp_up.dats', 'if d2var_is_mutabl (d2v) then', 'if not (d2var_is_mutabl (d2v)) then', 1),
 ('pats_trans3_dynexp_up.dats', 'if isnonlin then s2rt_t0ype else s2rt_vt0ype', 'if isnonlin then s2rt_vt0ype else s2rt_t0ype', 1),
 ('pats_trans3_dynexp_up.dats', 'if lin > 0 then the_d2varenv_check_llam(loc0)', 'if lin > 1 then the_d2varenv_check_llam(loc0)', 1),
 ('pats_trans3_dynexp_dn.dats', 'val () = if lin > 0 then the_d2varenv_check_llam (loc0)', 'val () = if lin > 1 then the_d2varenv_check_llam (loc0)', 1),
 ('pats_trans3_dynexp_dn.dats', 'serr := serr+1 in glist_nil()', 'serr := serr-1 in glist_nil()', 1),
 ('pats_trans3_p2at.dats', 'if refknd = 0 then let // call-by-value', 'if refknd = 1 then let // call-by-value', 1),
 ('pats_trans3_p2at.dats', 'if npf > 0 then p2at_proofize (p2t)', 'if npf > 1 then p2at_proofize (p2t)', 1),
 ('pats_trans3_patcon.dats', 'if flag > 0 then 1 else d2con_get_vwtp (d2c)', 'if flag >= 0 then 1 else d2con_get_vwtp (d2c)', 1),
 ('pats_trans3_patcon.dats', 'if pck = PCKcon then (if flag_vwtp > 0 then pck := PCKlincon)', 'if pck = PCKcon then (if flag_vwtp >= 0 then pck := PCKlincon)', 1),
 ('pats_trans3_caseof.dats', 'if neg > 0 then s2exp_bottom_t0ype_exi () else s2e_res', 'if neg > 1 then s2exp_bottom_t0ype_exi () else s2e_res', 1),
 ('pats_trans3_selab.dats', 'if linrest = 0 then', 'if linrest = 1 then', 1),
 ('pats_trans3_selab.dats', 'val () = if (linrest > 0) then auxerr_linrest (loc0, d3e, d3ls)', 'val () = if (linrest > 1) then auxerr_linrest (loc0, d3e, d3ls)', 1),
 ('pats_trans3_looping.dats', 'if knd = 0 then', 'if knd = 1 then', 1),
 ('pats_trans3_decl.dats', 'if sgn < 0 then (os2ts0 := os2ts)', 'if sgn > 0 then (os2ts0 := os2ts)', 1),
 ('pats_trans3_util.dats', 'if lin = 0 then s2rt_t0ype else s2rt_vt0ype', 'if lin = 1 then s2rt_t0ype else s2rt_vt0ype', 1),
 ('pats_trans3_syncst.dats', 'if sfx > 0u then let', 'if sfx > 1u then let', 1),
 ('pats_trans3_lvalres.dats', 'if lin = 0 then s2fun', 'if lin = 1 then s2fun', 1),
 ('pats_trans3_appsym.dats', '(if mpval < pval then pval else mpval)', '(if pval < mpval then pval else mpval)', 1),
 ('pats_trans3_assgn.dats', '    if sharing > 0\n', '    if sharing > 1\n', 1),
 ('pats_trans3_ptrof.dats', 'if ismut then let', 'if not ismut then let', 1),
 ('pats_trans3_viewat.dats', 'if glist_is_cons (s2ls) then false else true', 'if glist_is_cons (s2ls) then true else false', 1),
 ('pats_trans3_fldfrat.dats', 'if opknd = 0 then let', 'if opknd = 1 then let', 1),
 ('pats_trans3_deref.dats', '    if islin then\n      auxerr_reflinsel', '    if not islin then\n      auxerr_reflinsel', 1),
 ('pats_trans3_xchng.dats', 'val () = if err > 0 then let', 'val () = if err > 1 then let', 1),
 ('pats_trans3_env_termet.dats', 'if ismem then Some_vt (y) else get_termet_loop (xs, ys, d2v)', 'if not ismem then Some_vt (y) else get_termet_loop (xs, ys, d2v)', 1),
 ('pats_trans3_env_lstate.dats', 'if ans(*merge*) > 0 then list_vt_cons (d2v, d2vs) else d2vs', 'if ans(*merge*) > 1 then list_vt_cons (d2v, d2vs) else d2vs', 1),
 ('pats_trans3_env_dvar.dats', 'if ans then true else is_llamlocal_loop (ld2vss1, d2v0)', 'if ans then false else is_llamlocal_loop (ld2vss1, d2v0)', 1),
 ('pats_trans3_env_dvar.dats', 'if linval >= 0 then d2var_set_type(d2v, gopt_none ())', 'if linval > 0 then d2var_set_type(d2v, gopt_none ())', 1),
 ('pats_trans3_env.dats', 'c3nstr_node_C3NSTRprop(s2exp_intgte(s2e, s2exp_int(0)))', 'c3nstr_node_C3NSTRprop(s2exp_intgte(s2e, s2exp_int(1)))', 1),
 ('pats_trans3_env.dats', 'c3nstr_node_C3NSTRprop(s2exp_bool(false))', 'c3nstr_node_C3NSTRprop(s2exp_bool(true))', 1),
 ('pats_trans3_env.dats', 'S3ITMsvar', 'S3ITMsvar', 0),
]
MUT = [m for m in MUT if m[3] > 0]

def sh(cmd, **kw):
    return subprocess.run(cmd, shell=True, **kw)

def chunks(listfile, dst, n=30):
    lines = [l for l in open(listfile).read().split('\n') if l]
    lines = lines[::SAMPLE]
    os.makedirs(dst, exist_ok=True)
    names = []
    for i in range(0, len(lines), n):
        nm = os.path.join(dst, 'c_%04d' % (i // n))
        open(nm, 'w').write('\n'.join(lines[i:i+n]) + '\n')
        names.append(nm)
    return names

def run_all(binary, names, outdir, cwd):
    os.makedirs(outdir, exist_ok=True)
    cmds = ['cd %s && TMPDIR=%s sh ./f3runmd5.sh %s %s %s' % (cwd, W, binary, nm, outdir) for nm in names]
    open(os.path.join(W, 'cmds.txt'), 'w').write('\n'.join(cmds) + '\n')
    sh('cat %s/cmds.txt | xargs -P %d -I{} sh -c "{}"' % (W, JOBS))

def same(names, d1, d2):
    bad = 0
    for nm in names:
        b = os.path.basename(nm) + '.md5'
        try:
            if open(os.path.join(d1, b)).read() != open(os.path.join(d2, b)).read(): bad += 1
        except Exception: bad += 1
    return bad

os.makedirs(W, exist_ok=True)
names = chunks(LIST, os.path.join(W, 'lists'))
if not os.path.exists(os.path.join(W, 'src')):
    sh('cp -a %s %s/src' % (os.path.join(here, '..'), W))
    sh('cd %s/src/test && rm -rf modobj f3obj f3obj_asan f3obj_o2 f3dump f3dump_asan t3obj* t2obj* d1obj* t3g* g4obj g2obj obj pats_error_sats.c *.o' % W)
    sh('cd %s/src/test && make -j%d f3dump > make.log 2>&1' % (W, JOBS))
T = os.path.join(W, 'src', 'test')
ref = os.path.join(W, 'ref')
if not all(os.path.exists(os.path.join(ref, os.path.basename(nm) + '.md5')) for nm in names):
    run_all(os.path.join(here, 'f3dump1'), names, ref, here)
base = os.path.join(W, 'base')
shutil.rmtree(base, ignore_errors=True)
run_all(os.path.join(T, 'f3dump'), names, base, here)
nb = same(names, ref, base)
print('baseline (the unmutated copy against ATS1): %d of %d chunks differ' % (nb, len(names)), flush=True)
assert nb == 0
res = []
for k, (f, old, new, nth) in list(enumerate(MUT))[FIRST:FIRST+N]:
    path = os.path.join(W, 'src', f)
    orig = os.path.join(here, '..', f)
    s = open(orig).read()
    idx = -1
    for _ in range(nth):
        idx = s.find(old, idx + 1)
        assert idx >= 0, 'mutant %d: pattern not found: %r' % (k, old)
    open(path, 'w').write(s[:idx] + new + s[idx + len(old):])
    r = sh('cd %s && make -j%d f3dump > make.log 2>&1' % (T, JOBS))
    if r.returncode != 0:
        res.append((k, f, 'BUILD FAILED')); print(k, f, 'BUILD FAILED', flush=True)
        shutil.copy(orig, path); continue
    mut = os.path.join(W, 'mut')
    shutil.rmtree(mut, ignore_errors=True)
    run_all(os.path.join(T, 'f3dump'), names, mut, here)  # the same working directory as the reference (it is part of the search path of includes)
    bad = same(names, ref, mut)
    res.append((k, f, 'detected (%d of %d chunks differ)' % (bad, len(names)) if bad else 'NOT DETECTED'))
    print(k, f, old[:50].replace('\n', ' '), '->', res[-1][2], flush=True)
    shutil.copy(orig, path)
sh('cd %s && make -j%d f3dump > make.log 2>&1' % (T, JOBS))
nd = sum(1 for r in res if r[2].startswith('detected'))
print('mutants: %d, detected: %d' % (len(res), nd))
