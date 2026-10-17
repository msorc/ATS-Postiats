#!/usr/bin/env python3
"""hsmutate.py OUTDIR REFERENCE.out   Mutation test of the ATS2 port of pats_histaexp: for each deliberate bug below the module is mutated,
recompiled in the staging directory of hsdrv2.sh (OUTDIR/stage2), relinked, run, and its stdout compared with REFERENCE.out (the output of hs1)."""
import sys, os, shutil, subprocess, tempfile, concurrent.futures
OUT = os.path.abspath(sys.argv[1]); REF = os.path.abspath(sys.argv[2])
W = os.path.join(OUT, 'stage2')
M = [
 ('get_boxknd: boxed is unboxed', 'pats_histaexp.dats', 'if tyreckind_is_boxed(knd) then 1 else 0', 'if tyreckind_is_boxed(knd) then 0 else 1'),
 ('get_boxknd: the sum', 'pats_histaexp.dats', '| ~HSEtysum(d2c, _) => 0 // HX: it is not [1]!', '| ~HSEtysum(d2c, _) => 1'),
 ('get_extknd: flat ext', 'pats_histaexp.dats', 'if tyreckind_is_fltext(knd) then 1 else 0', 'if tyreckind_is_fltext(knd) then 0 else 1'),
 ('is_boxed: knd > 0', 'pats_histaexp.dats', 'hit.hitnam_ptr() > 0', 'hit.hitnam_fin() > 0'),
 ('is_void: the singleton record', 'pats_histaexp.dats', '''(lhse) => let
    val hse = lhse.labhisexp_elt() in hisexp_is_void(hse)''', '''(lhse) => let
    val hse = lhse.labhisexp_elt() in false'''),
 ('is_noret: type variables', 'pats_histaexp.dats', '| ~HSEtyvar (s2v) => true', '| ~HSEtyvar (s2v) => false'),
 ('is_noret: constants', 'pats_histaexp.dats', '''| ~HSEcst(s2c) =>
    $S2C.s2cstref_equ_cst($S2C.the_atsvoid_t0ype, s2c)
  // end of [HSEcst]''', '''| ~HSEcst(s2c) => false'''),
 ('fun_is_void: the result', 'pats_histaexp.dats', ''') => hisexp_is_void(hse_res)''', ''') => hisexp_is_void(hse_fun)'''),
 ('hisexp_fun: closures are pointers', 'pats_histaexp.dats', '''| FUNCLOclo0() =>
    hisexp_make_node(HITNAM_CLOTYP, node)''', '''| FUNCLOclo0() =>
    hisexp_make_node(HITNAM_CLOPTR, node)'''),
 ('hisexp_fun: cloref', 'pats_histaexp.dats', '''| FUNCLOcloref() =>
    hisexp_make_node(HITNAM_CLOPTR, node)''', '''| FUNCLOcloref() =>
    hisexp_make_node(HITNAM_CLOTYP, node)'''),
 ('tyrec2: the singleton', 'pats_histaexp.dats', 'glist_is_nil (glist_tail<labhisexp> (lhses))', 'glist_is_cons (glist_tail<labhisexp> (lhses))'),
 ('tyvar: boxed sorts', 'pats_histaexp.dats', 'if isbox then HITNAM_BOXED else HITNAM_TYVAR', 'if isbox then HITNAM_TYVAR else HITNAM_BOXED'),
 ('make_srt: unboxed name', 'pats_histaexp.dats', 'hisexp_tybox\nelse let', 'hisexp_typtr\nelse let'),
 ('refarg: the name', 'pats_histaexp.dats', '"postiats_refarg"', '"postiats_refarg0"'),
 ('extype: the name is not final', 'pats_histaexp.dats', 'hitnam_new(0(*non*), 1(*fin*), name)', 'hitnam_new(0(*non*), 0(*fin*), name)'),
 ('subst: extype keeps the name', 'pats_histaexp.dats', 'then hisexp_extype (name, hsess) else hse0', 'then hisexp_extype ("x", hsess) else hse0'),
 ('subst: a variable is substituted without the flag', 'pats_histaexp.dats', 'val () = flag := flag + 1 in hisexp_s2exp (s2e)', 'val () = () in hisexp_s2exp (s2e)'),
 ('subst: arrays', 'pats_histaexp.dats', 'then hisexp_tyarr (hse_elt, s2es) else hse0', 'then hse0 else hse0'),
 ('subst: tysum keeps the constructor', 'pats_histaexp.dats', 'if flag > f0 then hisexp_tysum (d2c, lhses) else hse0', 'if flag > f0 then hisexp_tyrec (tyreckind_TYRECKINDbox (), lhses) else hse0'),
 ('subst: the list of the lists', 'pats_histaexp.dats', 'if flag > f0 then glist_cons (hses, hsess) else hsess0', 'if flag > f0 then glist_cons (hses, hsess0) else hsess0'),
 ('subst: the labelled', 'pats_histaexp.dats', 'if flag > f0 then labhisexp_new (lab, opt, hse) else lhse0', 'if flag > f0 then labhisexp_new (lab, lab_dummy_opt, hse) else lhse0'),
 ('print: the separator of HSEfun', 'pats_histaexp_print.dats', '''    val () = fprint_hisexplst(out, _arg)
    val () = prstr "; "
    val () = fprint_hisexp(out, _res)''', '''    val () = fprint_hisexplst(out, _arg)
    val () = prstr ", "
    val () = fprint_hisexp(out, _res)'''),
 ('print: the label of a record', 'pats_histaexp_print.dats', 'val () = fprint_string (out, "=")', 'val () = fprint_string (out, ":")'),
 ('constants: the name of tyclo', 'pats_histaexp.dats', '"postiats_tyclo"', '"postiats_tyclo1"'),
 ('constants: funptr is not a pointer', 'pats_histaexp.dats', 'hitnam_new(1(*ptr*), 1(*fin*), "atstype_funptr")', 'hitnam_new(0(*ptr*), 1(*fin*), "atstype_funptr")'),
]
def run(arg):
    # sequential: the module is compiled IN PLACE (the mangled names of the functions of a sats depend on its path)
    i, (name, fn, old, new) = arg
    tmp = tempfile.mkdtemp(prefix='hsmut')
    path = os.path.join(W, fn)
    src = open(path).read()
    try:
        n = src.count(old)
        if n != 1: return (i, name, 'ERROR', 'occurs %d times' % n)
        if 'lab_dummy_opt' in new: new = new.replace('lab_dummy_opt', 'gopt_none ()')
        open(path, 'w').write(src.replace(old, new))
        mod = fn[:-5]
        cc = ['patscc', '-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-c', '-o', os.path.join(tmp, mod + '.o'), path]
        r = subprocess.run(cc, capture_output=True, text=True, cwd=tmp)
        open(path, 'w').write(src)
        if r.returncode != 0: return (i, name, 'BUILD-FAILED', (r.stdout + r.stderr)[-200:].replace('\n', ' '))
        objs = [os.path.join(W, 'obj', f) for f in sorted(os.listdir(os.path.join(W, 'obj'))) if f.endswith('.o') and f != mod + '.o']
        exe = os.path.join(tmp, 'hs2m')
        r = subprocess.run(['gcc', '-o', exe, os.path.join(tmp, mod + '.o')] + objs + ['-lgmp'], capture_output=True, text=True)
        if r.returncode != 0: return (i, name, 'LINK-FAILED', r.stderr[-200:].replace('\n', ' '))
        p = subprocess.run([exe], capture_output=True, timeout=300)
        ref = open(REF, 'rb').read()
        if p.returncode != 0: return (i, name, 'DETECTED', 'exit %d' % p.returncode)
        if p.stdout == ref: return (i, name, 'SURVIVED', '')
        a, b = p.stdout.split(b'\n'), ref.split(b'\n')
        return (i, name, 'DETECTED', '%d lines differ' % (sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))))
    finally:
        open(path, 'w').write(src)
        shutil.rmtree(tmp, ignore_errors=True)
bad = 0
if True:
    for i, name, st, info in map(run, list(enumerate(M))):
        print('%-12s %2d %s %s' % (st, i, name, info)); sys.stdout.flush()
        if st != 'DETECTED': bad += 1
print('mutations: %d, not detected: %d' % (len(M), bad))
