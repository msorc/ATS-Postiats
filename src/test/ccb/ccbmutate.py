#!/usr/bin/env python3
"""ccbmutate.py OUTDIR REF.out REF.err [N...]   Mutation test of the ATS2 ports of pats_ccomp_{hitype,hipat,subst,template,main}: each deliberate bug below is applied to the
module in the staging directory of ccb2.sh (OUTDIR/stage2), recompiled, relinked and run; stdout and stderr must differ from the reference (the output of ccb1, the ATS1 build)."""
import sys, os, subprocess
OUT = os.path.abspath(sys.argv[1]); REF = open(sys.argv[2], 'rb').read(); REFERR = open(sys.argv[3], 'rb').read()
SEL = [int(a) for a in sys.argv[4:] if a.isdigit()]
W = os.path.join(OUT, 'stage2')
HT = 'pats_ccomp_hitype.dats'; HP = 'pats_ccomp_hipat.dats'; SB = 'pats_ccomp_subst.dats'; TP = 'pats_ccomp_template.dats'; MN = 'pats_ccomp_main.dats'
M = [  # (name, file, old, new, nth occurrence)
 ('hitype: tagless constructors', HT, 'if d2con_is_tagless (d2c) then 0 else 1', 'if d2con_is_tagless (d2c) then 1 else 0', 0),
 ('hitype: boxed record at flag 1', HT, '    if flag > 0\n      then hitype_tybox()', '    if flag > 1\n      then hitype_tybox()', 0),
 ('hitype: boxed sum at flag 1', HT, '(if flag > 0 then true else false): bool', '(if flag > 1 then true else false): bool', 0),
 ('hitype: boxed exn at flag 1', HT, '(if flag > 0 then true else false): bool', '(if flag > 1 then true else false): bool', 1),
 ('hitype: tyvar head boxed/unboxed', HT, 'then 1(*boxed*) else ~1(*unboxed*)', 'then ~1(*boxed*) else 1(*unboxed*)', 0),
 ('hitype: equality of the fields of sums', HT, 'if tgd1 = tgd2\n      then auxlablst(lxs1, lxs2) else false', 'if tgd1 = tgd2\n      then true else false', 0),
 ('hitype: the order of the typedefs', HT, '  loop (kis, list_vt_nil ())', '  loop (glist_reverse<keyitm> (kis), list_vt_nil ())', 0),
 ('hitype: the tybox of applications', HT, 'if knd > 0\n  then emit_text (out, "atstybox_type(")', 'if knd >= 0\n  then emit_text (out, "atstybox_type(")', 0),
 ('hitype: array fields', HT, 'if isa then\n  emit_text (out, "atstyarr_field(")', 'if not isa then\n  emit_text (out, "atstyarr_field(")', 0),
 ('hitype: the prefix of sums', HT, '"postiats_tysum_"', '"postiats_tysum2_"', 0),
 ('hitype: the typedefs with variables', HT, '    if tyvar\n      then emit_text(out, "#if(0)\\n")', '    if not tyvar\n      then emit_text(out, "#if(0)\\n")', 0),
 ('hipat: the use count', HP, 'val () = if use >= 1 then instrseq_add (res, ins)', 'val () = if use >= 2 then instrseq_add (res, ins)', 0),
 ('hipat: unused variables of records', HP, 'if utimes = 0 then () // HX: [d2v] is unused', 'if utimes = 1 then () // HX: [d2v] is unused', 0),
 ('hipat: the move of a shared value', HP, 'if d2var_is_mutabl (d2v) then false', 'if d2var_is_mutabl (d2v) then true', 0),
 ('hipat: the reference arguments', HP, '  if refval = 0 then', '  if refval = 1 then', 0),
 ('hipat: the number of the arguments', HP, 'auxpatck(env, res, narg+1, hips, fail)', 'auxpatck(env, res, narg, hips, fail)', 0),
 ('hipat: himatch2 free list', HP, 'val () = ccompenv_inc_freeconenv (env)\nval () = himatch_ccomp', 'val () = himatch_ccomp', 0),
 ('subst: the reference temporaries', SB, 'if tmpvar_isref(tmp) then tmpvar_set_ref (tmp2, 1)', 'if not (tmpvar_isref(tmp)) then tmpvar_set_ref (tmp2, 1)', 0),
 ('subst: the level of the copy', SB, 'val () = the_d2varlev_inc()', 'val () = ()', 0),
 ('subst: the funlab of a variable', SB, '    | ~Some_vt(pmv_flab) => pmv_flab', '    | ~Some_vt(pmv_flab) => primval_d2vfunlab(loc0, hse0, d2v, flab)', 0),
 ('subst: tail calls', SB, '      tmpvar_inc_tailcal(tmp)', '      ()', 0),
 ('subst: the order of the instructions', SB, '  glist_reverse<instr> (loop (env, map, sub, inss, sfx, glist_nil ()))', '  loop (env, map, sub, inss, sfx, glist_nil ())', 0),
 ('subst: the first of the mutually tail recursive functions', SB, 'if i <= 1 then the_funlablst_add(flab2)', 'if i <= 0 then the_funlablst_add(flab2)', 0),
 ('subst: the tail call optimization', SB, '      if tlcalopt > 0', '      if tlcalopt > 5', 0),
 ('subst: the warning', SB, 'referencing toplevel code in a template', 'referencing toplevel code in a templat', 0),
 ('template: constants', TP, 'if eq_s2cst_s2cst (s2c, s2c_arg) then true else false', 'if eq_s2cst_s2cst (s2c, s2c_arg) then false else true', 0),
 ('template: the update of the environment', TP, '        (s2f1 := s2f)', '        ()', 0),
 ('template: the append of the substitutions', TP, 'val tsub01 = tmpsub_append(tsub0, tsub1)', 'val tsub01 = tsub1', 0),
 ('template: the first match of a list', TP, '    if tmpcstmat_is_TMPCSTMATnone (opt)', '    if not (tmpcstmat_is_TMPCSTMATnone (opt))', 0),
 ('template: the recursion depth', TP, 'val () = ccompenv_inc_tmprecdepth (env)', 'val () = ()', 0),
 ('template: the substitution of the entry', TP, 'val () = funent_set_tmpsub (fent2, gopt_some<tmpsub> (tsub))', 'val () = ()', 0),
 ('main: the arguments of main', MN, 'if arty >= 2 then emit_text (out, ", argv")', 'if arty > 2 then emit_text (out, ", argv")', 0),
 ('main: the dynload flag', MN, '(out, "ATSdynloadflag_ext(\\n")', '(out, "ATSdynloadflag_Ext(\\n")', 0),
 ('main: the positions of the external code', MN, '(out, pos_lt_DYNMID)', '(out, pos_lte_DYNMID)', 0),
 ('main: the reset of the function labels', MN, 'val () = the_funlablst_initset2()', 'val () = ()', 0),
 ('main: the templates in the function labels', MN, '      if tmpknd > 0 then true else false', '      if tmpknd >= 0 then true else false', 0),
]
CF = ['patscc', '-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-O0']
def run():
    r = subprocess.run([os.path.join(OUT, 'ccb2')], capture_output=True, timeout=600)
    return r.stdout, r.stderr
def build(mod):
    r = subprocess.run(CF + ['-c', '-o', mod[:-5] + '.o', '../' + mod], cwd=os.path.join(W, 'obj'), capture_output=True)
    if r.returncode != 0: return False
    objs = sorted(f for f in os.listdir(os.path.join(W, 'obj')) if f.endswith('.o'))
    r = subprocess.run(CF + ['-o', os.path.join(OUT, 'ccb2'), *objs, '-lgmp'], cwd=os.path.join(W, 'obj'), capture_output=True)
    return r.returncode == 0
bad = 0; n = 0
for i, (name, f, old, new, nth) in enumerate(M, 1):
    if SEL and i not in SEL: continue
    p = os.path.join(W, f); src = open(p).read()
    parts = src.split(old)
    assert len(parts) > nth + 1, (i, name)
    mut = old.join(parts[:nth + 1]) + new + old.join(parts[nth + 1:])
    open(p, 'w').write(mut)
    try:
        ok = build(f)
        if not ok: res = 'BUILD FAILED'
        else:
            try:
                o, e = run()
                res = 'detected' if (o != REF or e != REFERR) else 'SURVIVED'
            except subprocess.TimeoutExpired: res = 'detected (timeout)'
    finally:
        open(p, 'w').write(src)
    n += 1
    if res == 'SURVIVED' or res == 'BUILD FAILED': bad += 1
    print('%2d %-60s %s' % (i, name, res)); sys.stdout.flush()
build(HT); build(HP); build(SB); build(TP); build(MN)
print('mutations: %d, undetected or broken: %d' % (n, bad))
