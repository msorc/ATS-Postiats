#!/usr/bin/env python3
"""ccmutate.py OUTDIR REFERENCE.out [REFERENCE.err] [N...]   Mutation test of the ATS2 ports of the core modules of ccomp: for each deliberate bug below the module is mutated,
recompiled in the staging directory of cc2.sh (OUTDIR/stage2), relinked, run, and its stdout and stderr compared with the reference (the output of cc1, the ATS1 build).
With numbers: only those mutations."""
import sys, os, shutil, subprocess, tempfile
OUT = os.path.abspath(sys.argv[1]); REF = os.path.abspath(sys.argv[2])
REFERR = os.path.abspath(sys.argv[3]) if len(sys.argv) > 3 and not sys.argv[3].isdigit() else None
SEL = [int(a) for a in sys.argv[3:] if a.isdigit()] if REFERR is None else [int(a) for a in sys.argv[4:] if a.isdigit()]
W = os.path.join(OUT, 'stage2')
CC = 'pats_ccomp.dats'; TV = 'pats_ccomp_tmpvar.dats'; FL = 'pats_ccomp_funlab.dats'; FE = 'pats_ccomp_funent.dats'; DE = 'pats_ccomp_d2env.dats'
TL = 'pats_ccomp_tmplab.dats'; IS = 'pats_ccomp_instrseq.dats'; UT = 'pats_ccomp_util.dats'; PR = 'pats_ccomp_print.dats'
M = [
 # ---- pats_ccomp_tmpvar.dats
 ('tmpvar_make: the ref flag', TV, ', 0 (*value*), 0 (*noret*), 0 (*local*)', ', 1 (*value*), 0 (*noret*), 0 (*local*)'),
 ('tmpvar_make: the ret flag', TV, ', 0 (*value*), 0 (*noret*), 0 (*local*)', ', 0 (*value*), 1 (*noret*), 0 (*local*)'),
 ('tmpvar_make: the top kind', TV, ', 0 (*value*), 0 (*noret*), 0 (*local*)', ', 0 (*value*), 0 (*noret*), 1 (*local*)'),
 ('tmpvar_isref: the test', TV, 'tmpvar_isref(tmp) = tmpvar_ref(tmp) > 0', 'tmpvar_isref(tmp) = tmpvar_ref(tmp) > 1'),
 ('tmpvar_isret: the test', TV, 'tmpvar_isret(tmp) = tmpvar_ret(tmp) > 0', 'tmpvar_isret(tmp) = tmpvar_ret(tmp) > 1'),
 ('tmpvar_inc_tailcal: the increment', TV, 'val () = tmpvar_set_ret (tmp, n+1(*ret*))', 'val () = tmpvar_set_ret (tmp, n+2(*ret*))'),
 ('tmpvar_make_ret: the value', TV, 'val () = tmpvar_set_ret (tmp, 1(*ret*))', 'val () = tmpvar_set_ret (tmp, 2(*ret*))'),
 ('tmpvar_make_ref: the value', TV, 'val () = tmpvar_set_ref (tmp, 1(*ref*))', 'val () = tmpvar_set_ref (tmp, 0(*ref*))'),
 ('fprint_tmpvar: the ref mark', TV, 'val () = if isref then fprint_string (out, "ref")', 'val () = if isref then fprint_string (out, "Ref")'),
 ('fprint_tmpvar: the ret mark', TV, 'val () = if isret then fprint_string (out, "ret")', 'val () = if isret then ()'),
 ('compare_tmpvar_tmpvar: the sign', TV, '  $UN.cast{int}(sgn)\nend\n) // end of [compare_tmpvar_tmpvar]', '  ~($UN.cast{int}(sgn))\nend\n) // end of [compare_tmpvar_tmpvar]'),
 ('eq_tmpvar_tmpvar: the stamps', TV, '($STMP.eq_stamp_stamp (tmpvar_stamp(tmp1), tmpvar_stamp(tmp2)))', '($STMP.eq_stamp_stamp (tmpvar_stamp(tmp1), tmpvar_stamp(tmp1)))'),
 ('tmpvarset_vt_add: no insertion', TV, 'val _(*replaced*) = $effmask_wrt ($LS.linset_insert (xs, x))', 'val _(*replaced*) = true'),
 ('tmpvar_get_suffix: the field', TV, 'tmpvar_get_suffix(tmp) = tmpvar_suffix(tmp)', 'tmpvar_get_suffix(tmp) = tmpvar_topknd(tmp)'),
 ('tmpvar_set_tyclo: no effect', TV, 'val () = tmpvar_set_type (tmp, hse)\n} (* end of [tmpvar_set_tyclo] *)', 'val () = ()\n} (* end of [tmpvar_set_tyclo] *)'),
 ('tmpvar_set_origin: the suffix', TV, 'implement tmpvar_set_suffix (tmp, sfx) = set_tmpvar_suffix (tmp, sfx)', 'implement tmpvar_set_suffix (tmp, sfx) = set_tmpvar_suffix (tmp, sfx+1)'),
 # ---- pats_ccomp_funlab.dats
 ('funlab_make: the template kind', FL, ', ~1 (*tmpknd*)', ', 0 (*tmpknd*)'),
 ('funlab_make: the function closure kind', FL, '| ~HSEfun (fc, _, _) => fc\n  | v => (hisexp_node_view_free (v); FUNCLOfun ())', '| ~HSEfun (fc, _, _) => FUNCLOfun ()\n  | v => (hisexp_node_view_free (v); FUNCLOfun ())'),
 ('funlab_incget_ncopy: the increment', FL, 'val cnt1 = cnt + 1', 'val cnt1 = cnt + 2'),
 ('funlab_make_type: the name', FL, 'else "__patsfun_"', 'else "__patsfn_"'),
 ('funlab_make_dcst_type: the separator', FL, 'string_app3 (d2c2, "$", stamp2)', 'string_app3 (d2c2, "#", stamp2)'),
 ('funlab_make_dvar_type: the separator', FL, 'string_app3 (d2v2, "_", stamp2)', 'string_app3 (d2v2, "-", stamp2)'),
 ('fprint_funlab: the level', FL, 'val () = fprint_string (out, "(level=")', 'val () = fprint_string (out, "(lvl=")'),
 ('funlabset: the order', FL, '$STMP.compare_stamp_stamp (funlab_get_stamp (x), funlab_get_stamp (y))', '$STMP.compare_stamp_stamp (funlab_get_stamp (y), funlab_get_stamp (x))'),
 ('funlablst2set: only the first', FL, 'in loop (glist_tail (fls), res)', 'in loop (glist_nil (), res)'),
 ('fprint_funlablstopt: the text', FL, 'val () = fprint_string (out, "Some(")', 'val () = fprint_string (out, "Some[")'),
 ('funlab_set_ncopy: no effect', FL, 'funlab_set_ncopy (flab, cnt) = set_funlab_ncopy (flab, cnt)', 'funlab_set_ncopy (flab, cnt) = ()'),
 ('funlab_get_funent: a copy', FL, 'funlab_set_funent (flab, opt) = set_funlab_funent (flab, opt)', 'funlab_set_funent (flab, opt) = ()'),
 ('funlab_get_name_c: the name', FL, 'funlab_get_name_c (flab) = funlab_name (flab)', 'funlab_get_name_c (flab) = "?"'),
 # ---- pats_ccomp_funent.dats
 ('funent_get_level', FE, '(fent) = funlab_get_level (funent_lab (fent))', '(fent) = funlab_get_level (funent_lab (fent)) + 1'),
 ('funent_make: the fnx labels', FE, ', glist_nil((*void*)) // fnxlablst', ', fls0 // fnxlablst'),
 ('funent_is_tmplt: the test', FE, '  glist_is_cons (tmparg)\nend // end of [funent_is_tmplst]', '  glist_is_nil (tmparg)\nend // end of [funent_is_tmplst]'),
 ('funent_make2: the return variable', FE, 'val tmps = tmpvarset_vt_add (tmps, tmpret)', 'val tmps = tmps'),
 ('fprint_funent: the text', FE, 'val () = prstr "tmpret="', 'val () = prstr "tmpret:"'),
 ('funent_set_fnxlablst: no effect', FE, 'funent_set_fnxlablst (fent, fls) = set_funent_fnxlablst (fent, fls)', 'funent_set_fnxlablst (fent, fls) = ()'),
 ('funent_set_d2envlst_fin: wrong field', FE, 'funent_set_d2envlst_fin (fent, opt) = set_funent_d2envlst_fin (fent, opt)', 'funent_set_d2envlst_fin (fent, opt) = ()'),
 ('funent_make: the final lists', FE, ', d2es, gopt_none((*void*)) // d2envlst, d2envlst_fin', ', d2es, gopt_some (d2es) // d2envlst, d2envlst_fin'),
 # ---- pats_ccomp_d2env.dats
 ('d2var2env: the type', DE, '  d2env_make (d2v, hse)\nend // end of [d2var2env]', '  d2env_make (d2v, hisexp_tybox)\nend // end of [d2var2env]'),
 ('d2envset: the order', DE, 'compare_d2var_d2var (d2env_get_var (d2e1), d2env_get_var (d2e2))', 'compare_d2var_d2var (d2env_get_var (d2e2), d2env_get_var (d2e1))'),
 ('fprint_d2env: the brackets', DE, 'fprint_string (out, "("); fprint_hisexp (out, hse); fprint_string (out, ")")', 'fprint_string (out, "["); fprint_hisexp (out, hse); fprint_string (out, "]")'),
 ('d2envlst2set: nothing is added', DE, 'then loop (glist_tail (d2es), d2envset_vt_add (res, glist_head (d2es)))', 'then loop (glist_tail (d2es), res)'),
 ('fprint_d2envlstopt: the text', DE, 'else fprint_string (out, "None()")', 'else fprint_string (out, "None")'),
 # ---- pats_ccomp_tmplab.dats
 ('fprint_tmplab: the text', TL, 'val () = fprint_string (out, "tmplab(")', 'val () = fprint_string (out, "tmplab[")'),
 ('tmplab_make: the location', TL, 'tmplab_new (loc, stamp)', 'tmplab_new ($LOC.location_dummy, stamp)'),
 # ---- pats_ccomp_instrseq.dats
 ('instrseq_get_free: the order', IS, 'glist_make_list_vt (list_vt_reverse (xs))', 'glist_make_list_vt (xs)'),
 ('instrseq_addlst: only the first', IS, 'instrseq_addlst (res, glist_tail (xs))', '()'),
 ('instrseq_add_comment: the text', IS, 'instrseq_add (res, instr_comment (loc, comment))', 'instrseq_add (res, instr_comment (loc, "c"))'),
 ('instrseq_add_extvar: the name', IS, 'instrseq_add (res, instr_extvar (loc, xnm, pmv))', 'instrseq_add (res, instr_extvar (loc, "x", pmv))'),
 ('instrseq_addlst_vt: the order', IS, 'val () = instrseq_add (res, x) in instrseq_addlst_vt (res, xs)', 'val () = instrseq_addlst_vt (res, xs) in instrseq_add (res, x)'),
 # ---- pats_ccomp_util.dats
 ('primval_is_nshared: selptr', UT, '| ~PMVselptr _ => true // left-value', '| ~PMVselptr _ => false // left-value'),
 ('primval_is_nshared: lamfix', UT, '| ~PMVlamfix _ => true // lamfix-value', '| ~PMVlamfix _ => false // lamfix-value'),
 ('primval_is_nshared: castfn', UT, '| ~PMVcastfn (d2c, pmv) => primval_is_nshared (pmv)', '| ~PMVcastfn (d2c, pmv) => false'),
 ('primval_is_nshared: argref', UT, '| ~PMVargref _ => true // left-value', '| ~PMVargref _ => false // left-value'),
 ('primval_make_funlab: the closure kind', UT, 'primval_cfunlab (loc, hse, funclo_get_clokind (funclo), fl)', 'primval_cfunlab (loc, hse, 0, fl)'),
 ('primval_make2_funlab: the type', UT, 'primval_funlab(loc, hse0, fl)', 'primval_funlab(loc, hse, fl)'),
 ('tmpsub_append: the tail', UT, 'tmpsub_TMPSUBcons (s2v, s2f, tmpsub_append (xs1, xs2))', 'tmpsub_TMPSUBcons (s2v, s2f, xs2)'),
 ('tmpsub2stasub: no binding', UT, 'val () = stasub_add (sub, s2v, s2e) in loop (sub, tsub)', 'val () = () in loop (sub, tsub)'),
 ('get_tmpvarset: INSmove_con', UT, '| ~INSmove_con\n    (tmp, _, _, _) => tmpadd(tmp)', '| ~INSmove_con\n    (tmp, _, _, _) => ()'),
 ('get_tmpvarset: INStrywith', UT, '    tmpadd (tmp);\n    auxlst (res, _try); auxibrlst (res, _with)', '    tmpadd (tmp);\n    auxlst (res, _try)'),
 ('get_tmpvarset: PMDlocal', UT, '    val () = auxpmdlst (res, pmds_body)', '    val () = ()'),
 ('get_tmpvarset: PMDimpdec', UT, 'if gopt_is_some (opt) then auxlst (res, gopt_unsome (opt)) else ()', 'if gopt_is_some (opt) then () else ()'),
 ('get_tmpvarset: INSloop test', UT, '    and ((*void*)) = auxlst(res, _test)\n', '    and ((*void*)) = ()\n'),
 ('get_tmpvarset: INSxstore_ptrofs', UT, '| ~INSxstore_ptrofs\n    (tmp, _, _, _, _) => tmpadd(tmp)', '| ~INSxstore_ptrofs\n    (tmp, _, _, _, _) => ()'),
 ('get_tmpvarset: INSmove_list_ptail', UT, '(tmp1_tl, tmp2_tl, _) => tmpadd (tmp1_tl)', '(tmp1_tl, tmp2_tl, _) => tmpadd (tmp2_tl)'),
 ('patckont_is_none: the test', UT, 'patckont_is_PTCKNTnone (fail)', '(not (patckont_is_PTCKNTnone (fail)))'),
 ('tmpvar_is_void: the test', UT, 'hisexp_is_void (tmpvar_get_type (tmp))', '(not (hisexp_is_void (tmpvar_get_type (tmp))))'),
 ('primval_is_top: the test', UT, 'primval_node_is_PMVtop (pmv.primval_node())', 'primval_node_is_PMVempty (pmv.primval_node())'),
 # ---- pats_ccomp.dats
 ('instr_move_fltrec2: the move', CC, '    instr_move_val (loc, tmpret, pmv)\n  end // end of [HSEtyrecsin]', '    instr_pmove_val (loc, tmpret, pmv)\n  end // end of [HSEtyrecsin]'),
 ('primlab_is_lab: the test', CC, '| ~PMLlab _ => true | ~PMLind _ => false', '| ~PMLlab _ => false | ~PMLind _ => true'),
 ('primval_make_ptrofsel: the type', CC, 'val hse_ptr = hisexp_typtr', 'val hse_ptr = hisexp_tybox'),
 ('primval_lamfix: the kind', CC, 'primval_node_PMVlamfix(knd, pmv_funval)', 'primval_node_PMVlamfix(gopt_none((*void*)), pmv_funval)'),
 ('instr_loop: the labels', CC, 'tlab_init, tlab_fini, tlab_cont\n, inss_init, pmv_test, inss_test, inss_post, inss_body\n)\n//', 'tlab_fini, tlab_init, tlab_cont\n, inss_init, pmv_test, inss_test, inss_post, inss_body\n)\n//'),
 ('primdec_local: the order', CC, 'primdec_node_PMDlocal(_head, _body)', 'primdec_node_PMDlocal(_body, _head)'),
 ('primval_make_sizeof: the type', CC, 'hisexp_size_t0ype() in primval_sizeof(loc, hse, s2e)', 'hisexp_int_t0ype() in primval_sizeof(loc, hse, s2e)'),
 ('primval_refarg: the free kind', CC, 'primval_node_PMVrefarg(knd, freeknd, pmv)', 'primval_node_PMVrefarg(knd, knd, pmv)'),
 ('hiimpdec_set_instrlstopt: no effect', CC, '  set_hiimpdec_instrlst (imp, $UN.cast{hiinstrlstopt}(opt))', '  ()'),
 ('hifundec_set_funlabopt: no effect', CC, '  set_hifundec_funlab (hfd, $UN.cast{hifunlabopt}(opt))', '  ()'),
 ('hiimpdec_set_funlabopt: the field', CC, '  set_hiimpdec_funlab (imp, $UN.cast{hifunlabopt}(opt))', '  set_hiimpdec_instrlst (imp, $UN.cast{hiinstrlstopt}(opt))'),
 ('ibranch_make: the location', CC, '(loc, inss) = ibranch_new(loc, inss)', '(loc, inss) = ibranch_new($LOC.location_dummy, inss)'),
 # ---- pats_ccomp_print.dats
 ('fprint_primcstsp: the name', PR, 'val () = prstr ("$myfilename(")', 'val () = prstr ("$myfile(")'),
 ('fprint_primdec: PMDlocal', PR, 'val () = prstr "PMDlocal("', 'val () = prstr "PMDLocal("'),
 ('fprint_primval: the char fallback', PR, 'fprint_string (out, "int(")', 'fprint_string (out, "i(")'),
 ('fprint_tmpmovlst: the arrow', PR, 'val () = fprint_string (out, "<-")', 'val () = fprint_string (out, "->")'),
 ('fprint_instr: INSfcall', PR, 'val () = prstr "INSfcall("', 'val () = prstr "INSfCall("'),
 ('fprint_patckont: PTCKNTraise', PR, 'val () = prstr "PTCKNTraise("', 'val () = prstr "PTCKNTRaise("'),
 ('fprint_tmpcstmat_kind: some2', PR, '| ~TMPCSTMATsome2 _ => 2', '| ~TMPCSTMATsome2 _ => 1'),
 ('fprint_vbindmap: the arrow', PR, 'fprint_string (out, "->")', 'fprint_string (out, "=>")'),
 ('fprint_primdeclst: the newline', PR, '  fprint_newline (out)\nend // end of [fprint_primdeclst]', '  ()\nend // end of [fprint_primdeclst]'),
 ('fprint_instr: the else', PR, 'prstr "INS...(...)"', 'prstr "INS..."'),
]
def run(arg):
    i, (name, fn, old, new) = arg
    tmp = tempfile.mkdtemp(prefix='ccmut')
    path = os.path.join(W, fn)
    src = open(path).read()
    try:
        n = src.count(old)
        if n != 1: return (i, name, 'ERROR', 'occurs %d times' % n)
        open(path, 'w').write(src.replace(old, new))
        mod = fn[:-5]
        cc = ['patscc', '-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-c', '-o', os.path.join(tmp, mod + '.o'), path]
        r = subprocess.run(cc, capture_output=True, text=True, cwd=tmp)
        open(path, 'w').write(src)
        if r.returncode != 0: return (i, name, 'BUILD-FAILED', (r.stdout + r.stderr)[-300:].replace('\n', ' '))
        objs = [os.path.join(W, 'obj', f) for f in sorted(os.listdir(os.path.join(W, 'obj'))) if f.endswith('.o') and f != mod + '.o']
        exe = os.path.join(tmp, 'cc2m')
        r = subprocess.run(['gcc', '-o', exe, os.path.join(tmp, mod + '.o')] + objs + ['-lgmp'], capture_output=True, text=True)
        if r.returncode != 0: return (i, name, 'LINK-FAILED', r.stderr[-200:].replace('\n', ' '))
        try:
            p = subprocess.run([exe], capture_output=True, timeout=300)
        except subprocess.TimeoutExpired:
            return (i, name, 'DETECTED', 'timeout')
        ref = open(REF, 'rb').read()
        if p.returncode != 0: return (i, name, 'DETECTED', 'exit %d' % p.returncode)
        if p.stdout != ref:
            a, b = p.stdout.split(b'\n'), ref.split(b'\n')
            return (i, name, 'DETECTED', '%d lines differ' % (sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))))
        if REFERR and p.stderr != open(REFERR, 'rb').read(): return (i, name, 'DETECTED', 'stderr differs')
        return (i, name, 'SURVIVED', '')
    finally:
        open(path, 'w').write(src)
        shutil.rmtree(tmp, ignore_errors=True)
bad = 0; cnt = 0
for i, name, st, info in map(run, [(i, m) for i, m in enumerate(M) if not SEL or i in SEL]):
    cnt += 1
    print('%-12s %2d %s %s' % (st, i, name, info)); sys.stdout.flush()
    if st != 'DETECTED': bad += 1
print('mutations: %d, not detected: %d' % (cnt, bad))
