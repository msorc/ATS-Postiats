#!/usr/bin/env python3
# usage: python3 m2mutate.py REF.out REF.err REF.exit   (the stdout and stderr of m2dump1, the ATS1 reference; REF.exit: the stdout and the "full: " lines
# of the stderr of M2EXIT=1..7 m2dump1, as written by `sh m2exit.sh ref REF.exit`; see m2cmp.sh)
#
# Mutation test of the macro test: each mutation is a deliberate bug that is put in a ported module (the file is restored afterwards), m2dump is rebuilt
# and its outputs are compared with the ATS1 reference: every mutation must change an output (be "detected"). A mutation that is behind the
# [d2var_rename] of ATS1 (the identity: the environment [alphenv] is unobservable through eval1) is not listed.
import sys, os, subprocess, shutil, filecmp
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 # ---- pats_dmacro2.dats
 ('pats_dmacro2.dats', 'alphenv_pop does not remove the mark',
  '| ~ALPHENVmark (env) => (env)', '| ~ALPHENVmark (env) => (ALPHENVmark (env))'),
 ('pats_dmacro2.dats', 'alphenv_pop stops at a static binding',
  '  | ~ALPHENVsadd\n      (_, _, env) => loop (env)\n  | ~ALPHENVdadd\n      (_, _, env) => loop (env)\n  | ~ALPHENVmark (env) => (env)',
  '  | ~ALPHENVsadd\n      (_, _, env) => (env)\n  | ~ALPHENVdadd\n      (_, _, env) => loop (env)\n  | ~ALPHENVmark (env) => (env)'),
 ('pats_dmacro2.dats', 'alphenv_dfind returns the outermost binding (the shadowing is lost)',
  '    val ans = (\n      if key = _key then\n        Some_vt (_val) else loop (env1, key)\n      // end of [if]\n    ) : Option_vt (d2var)',
  '    val ans = (\n      if key = _key then\n        loop (env1, key) else loop (env1, key)\n      // end of [if]\n    ) : Option_vt (d2var)'),
 ('pats_dmacro2.dats', 'alphenv_sfind ignores the static bindings',
  '      if key = _key then\n        Some_vt (_val) else loop (env1, key)\n      // end of [if]\n    ) : Option_vt (s2var)',
  '      if key != key then\n        Some_vt (_val) else loop (env1, key)\n      // end of [if]\n    ) : Option_vt (s2var)'),
 ('pats_dmacro2.dats', 'evalctx_dfind returns the outermost binding',
  '    if d2v = _key then let', '    if d2v != _key then let'),
 ('pats_dmacro2.dats', 'a space in the printer of the contexts',
  'fprint_string (out, " -<s> ")', 'fprint_string (out, " -<s>  ")'),
 ('pats_dmacro2.dats', 'the substitution of the static variables is not built',
  '      val () = stasub_add (sub, s2v, s2e)\n', '      val () = stasub_add (sub, s2v, s2exp_int (0))\n'),
 ('pats_dmacro2.dats', 'a static value that is not code gives a wrong sort',
  'in s2exp_errexp(s2rt_t0ype)', 'in s2exp_errexp(s2rt_prop)'),
 ('pats_dmacro2.dats', 'a character is lifted as a string',
  '| ~M2Vchar (c) => d2exp_char (loc0, c)', '| ~M2Vchar (c) => d2exp_string (loc0, "c")'),
 ('pats_dmacro2.dats', 'the text of the error of dmacro_eval_decode',
  ', but the following value is obtained instead: ', ', but the following value is obtained: '),
 ('pats_dmacro2.dats', 'dmacro_eval_xstage does not lift',
  '  liftval2dexp (loc0, m2v)\nend // end of [dmacro_eval_xstage]', '  d2exp_empty (loc0)\nend // end of [dmacro_eval_xstage]'),
 ('pats_dmacro2.dats', 'the value true is false',
  'val m2val_true_ = m2val_M2Vbool (true)', 'val m2val_true_ = m2val_M2Vbool (false)'),
 # ---- pats_dmacro2_eval0.dats
 ('pats_dmacro2_eval0.dats', 'addition subtracts',
  'm2val_M2Vint (m2val_int_get (m2v1) + m2val_int_get (m2v2))', 'm2val_M2Vint (m2val_int_get (m2v1) - m2val_int_get (m2v2))'),
 ('pats_dmacro2_eval0.dats', 'multiplication adds',
  'm2val_M2Vint (m2val_int_get (m2v1) * m2val_int_get (m2v2))', 'm2val_M2Vint (m2val_int_get (m2v1) + m2val_int_get (m2v2))'),
 ('pats_dmacro2_eval0.dats', 'the sign of the comparison is reversed',
  'if i1 < i2 then ~1 else (if i1 > i2 then 1 else 0)', 'if i1 < i2 then 1 else (if i1 > i2 then ~1 else 0)'),
 ('pats_dmacro2_eval0.dats', '<= is <',
  'if sgn <= 0 then m2val_true else m2val_false', 'if sgn < 0 then m2val_true else m2val_false'),
 ('pats_dmacro2_eval0.dats', '!= is =',
  'if sgn != 0 then m2val_true else m2val_false', 'if sgn = 0 then m2val_true else m2val_false'),
 ('pats_dmacro2_eval0.dats', '>= is >',
  'if sgn >= 0 then m2val_true else m2val_false', 'if sgn > 0 then m2val_true else m2val_false'),
 ('pats_dmacro2_eval0.dats', 'the error of a comparison is not reported',
  '    prerr ": values are compared that do not support comparison.";', '    prerr ": values are compared that do not support comparison!";'),
 ('pats_dmacro2_eval0.dats', 'the second operand is evaluated twice the first',
  '    | ~GLcons(d2e2, _) => let\n        val m2v2 = eval0_d2exp(loc, ctx, env, d2e2)', '    | ~GLcons(d2e2, _) => let\n        val m2v2 = eval0_d2exp(loc, ctx, env, d2e1)'),
 ('pats_dmacro2_eval0.dats', 'the error of an evaluation of a non-code',
  ': evaluation is performed on a value not representing code.', ': evaluation is performed on a value not representing code'),
 ('pats_dmacro2_eval0.dats', 'car of a list of lists',
  '      | ~GLcons(m2v, _) => m2v | ~GLnil() => m2val_M2Verr()', '      | ~GLcons(m2v, _) => m2val_M2Verr() | ~GLnil() => m2val_M2Verr()'),
 ('pats_dmacro2_eval0.dats', 'cdr keeps the first element',
  '      | ~GLcons\n          (_, m2vs) => m2val_M2Vlist(m2vs)', '      | ~GLcons\n          (m2v, m2vs) => m2val_M2Vlist(glist_cons<m2val>(m2v, m2vs))'),
 ('pats_dmacro2_eval0.dats', 'isnil is iscons',
  'if glist_is_cons (m2vs) then m2val_M2Vbool(false) else m2val_M2Vbool(true)', 'if glist_is_cons (m2vs) then m2val_M2Vbool(true) else m2val_M2Vbool(false)'),
 ('pats_dmacro2_eval0.dats', 'islist answers true on an error value',
  'if m2val_is_M2Vlist (m2v)\n      then m2val_M2Vbool(true) else m2val_M2Vbool(false)', 'if m2val_is_M2Vlist (m2v) orelse m2val_is_M2Verr (m2v)\n      then m2val_M2Vbool(true) else m2val_M2Vbool(false)'),
 ('pats_dmacro2_eval0.dats', 'the branches of ifhead are swapped',
  'if b then eval0dexp (_then) else eval0dexpopt (_else)', 'if b then eval0dexpopt (_else) else eval0dexp (_then)'),
 ('pats_dmacro2_eval0.dats', 'a qualified symbol is evaluated',
  'if d2sym_is_nonqua d2s then', 'if true then'),
 ('pats_dmacro2_eval0.dats', 'the message of an unbound variable',
  'prerr "] is unbound."', 'prerr "] is not bound."'),
 ('pats_dmacro2_eval0.dats', 'an integer token is off by one',
  'm2val_M2Vint($UN.cast{int}($UT.llint_make_string(rep)))', 'm2val_M2Vint($UN.cast{int}($UT.llint_make_string(rep)) + 1)'),
 ('pats_dmacro2_eval0.dats', 'the dynamic arguments are all evaluated in the short form',
  'if knd >= 1 then\n  eval0_d2exp(loc, ctx, env, d2e)', 'if knd >= 0 then\n  eval0_d2exp(loc, ctx, env, d2e)'),
 ('pats_dmacro2_eval0.dats', 'the static groups are joined in the reverse order',
  'glist_append<s2exp> (s2es, s2es2)', 'glist_append<s2exp> (s2es2, s2es)'),
 ('pats_dmacro2_eval0.dats', 'the text of the arity error of the long form',
  'if n0 > narg then prerr "] is overlly applied."', 'if n0 > narg then prerr "] is overly applied."'),
 ('pats_dmacro2_eval0.dats', 'the short form drops one more argument group',
  'then d2exparglst_drop (d2as, narg) else glist_nil()', 'then d2exparglst_drop (d2as, narg+1) else glist_nil()'),
 ('pats_dmacro2_eval0.dats', 'the extra groups of the short form come first',
  'glist_append<d2exparg> (d2as1, d2as2))', 'glist_append<d2exparg> (d2as2, d2as1))'),
 ('pats_dmacro2_eval0.dats', 'the argument of a singleton group is not a list',
  '      evalctx_dadd(res, d2v, m2val_M2Vlist (m2vs))\n    end // end of [_]\n    )', '      evalctx_dadd(res, d2v, m2val_M2Verr ())\n    end // end of [_]\n    )'),
 ('pats_dmacro2_eval0.dats', 'the static argument is not bound as code',
  'evalctx_sadd(res, s2v, m2val_M2Vscode(s2e))', 'evalctx_sadd(res, s2v, m2val_M2Verr())'),
 ('pats_dmacro2_eval0.dats', 'the text of the error for a dynamic argument',
  ') is expected to be dynamic."', ') is expected to be static."'),
 ('pats_dmacro2_eval0.dats', 'xstage decodes without lifting',
  'm2val_M2Vdcode(liftval2dexp (loc, m2v_res))', 'm2val_M2Vdcode(d2exp_empty (loc))'),
 ('pats_dmacro2_eval0.dats', 'encode does not quote',
  '  | $SYN.MSKencode() => let\n      val d2e =\n        eval1_d2exp(loc, ctx, env, d2e)', '  | $SYN.MSKencode() => let\n      val d2e = d2e'),
 ('pats_dmacro2_eval0.dats', 'a macro function with a wrong name is a car',
  'if name = symbol_CAR then eval0_car (m2vs)', 'if name = symbol_CAR orelse name = symbol_ISLIST then eval0_car (m2vs)'),
 # ---- pats_dmacro2_eval1.dats
 ('pats_dmacro2_eval1.dats', 'a short macro is expanded only when its kind is 1',
  'if knd = 0 then ( // [d2m] is of short form', 'if knd = 1 then ( // [d2m] is of short form'),
 ('pats_dmacro2_eval1.dats', 'the arguments are evaluated before the function',
  'val d2e = eval1_d2exp (loc0, ctx, env, d2e)\nval d2as = eval1_d2exparglst (loc0, ctx, env, d2as)', 'val d2as = eval1_d2exparglst (loc0, ctx, env, d2as)\nval d2e = eval1_d2exp (loc0, ctx, env, d2e)'),
 ('pats_dmacro2_eval1.dats', 'the groups of an application are merged in the reverse order',
  'glist_append<d2exparg> (d2as1, d2as))\n  ) // end of [D2Eapplst]', 'glist_append<d2exparg> (d2as, d2as1))\n  ) // end of [D2Eapplst]'),
 ('pats_dmacro2_eval1.dats', 'the text of the error of decode in a quote',
  ') is expected to return code (AST) but it does not.', ') is expected to return code (AST) but does not.'),
 ('pats_dmacro2_eval1.dats', 'the error of the incorrect use of macro syntax',
  ': macro syntax is used incorrectly: ', ': macro syntax is used incorrectly. '),
 ('pats_dmacro2_eval1.dats', 'the static argument group `one` becomes `all`',
  '| ~S2EXPARGone() => s2exparg_one(loc0)', '| ~S2EXPARGone() => s2exparg_all(loc0)'),
 ('pats_dmacro2_eval1.dats', 'the location of a dynamic group is kept',
  'd2exparg_D2EXPARGdyn (npf, loc0, d2es)\n  end', 'd2exparg_D2EXPARGdyn (npf, locarg, d2es)\n  end'),
 ('pats_dmacro2_eval1.dats', 'the test and the branches of ifhead are evaluated in another order',
  '    val _test = eval1dexp (_test)\n    val _then = eval1dexp (_then)\n    val _else = eval1dexpopt (_else)\n  in\n    d2exp_ifhead', '    val _then = eval1dexp (_then)\n    val _test = eval1dexp (_test)\n    val _else = eval1dexpopt (_else)\n  in\n    d2exp_ifhead'),
 ('pats_dmacro2_eval1.dats', 'the index of a selection is not evaluated',
  'd2lab_ind (loc0, eval1_d2explst (loc0, ctx, env, ind))', 'd2lab_ind (loc0, ind)'),
 ('pats_dmacro2_eval1.dats', 'a labelled pattern loses its label',
  'labp2at_LABP2ATnorm (l, p2t)\n  end // end of [LABP2ATnor]', 'labp2at_LABP2ATomit (loc0)\n  end // end of [LABP2ATnor]'),
 ('pats_dmacro2_eval1.dats', 'the guards of a clause are dropped',
  'val gm2ts = eval1_gm2atlst (loc0, ctx, env, c2l.c2lau_gua ())', 'val gm2ts = c2l.c2lau_gua ()'),
 ('pats_dmacro2_eval1.dats', 'the type of a value declaration is not substituted',
  'val ann =\n      eval1_s2expopt (loc0, ctx, env, d2c.v2aldec_ann ())\n    val d2c = v2aldec_make (loc0, p2t, d2e, ann)\n    val d2cs = auxlst2 (loc0, ctx, env, d2cs, d2es)', 'val ann =\n      d2c.v2aldec_ann ()\n    val d2c = v2aldec_make (loc0, p2t, d2e, ann)\n    val d2cs = auxlst2 (loc0, ctx, env, d2cs, d2es)'),
 ('pats_dmacro2_eval1.dats', 'a recursive declaration evaluates the patterns after the definitions',
  '      val d2e = eval1_d2exp (loc0, ctx, env, d2c.v2aldec_def ())\n      // HX: [val-list_cons (p2t, p2ts) = p2ts] (MatchError)', '      val d2e = d2c.v2aldec_def ()\n      // HX: [val-list_cons (p2t, p2ts) = p2ts] (MatchError)'),
 ('pats_dmacro2_eval1.dats', 'the static substitution of the code is skipped',
  'val\ns2e = s2exp_subst(sub, s2e)', 'val\ns2e = s2e'),
 ('pats_dmacro2_eval1.dats', 'an ill-formed declaration is dropped silently',
  '| v (*not-handled*) => (d2ecl_node_view_free (v); d2ecl_errdec (loc0))', '| v (*not-handled*) => (d2ecl_node_view_free (v); d2ecl_none (loc0))'),
 ('pats_dmacro2_eval1.dats', 'the quoted constant is rebuilt with the location of the caller',
  '| ~D2Ecst _ => reloc ()', '| ~D2Ecst _ => d2exp_empty (loc0)'),
 # ---- pats_dmacro2_print.dats, pats_trans3_error.dats
 ('pats_dmacro2_print.dats', 'the printer of a boolean value',
  'val () = prstr "M2Vbool("', 'val () = prstr "M2Vbool ("'),
 ('pats_dmacro2_print.dats', 'the separator of a list of values',
  'val () = $UT.fprintlst<m2val> (out, xs, ", ", fprint_m2val)\n    val () = prstr ")"', 'val () = $UT.fprintlst<m2val> (out, xs, ",", fprint_m2val)\n    val () = prstr ")"'),
 ('pats_trans3_error.dats', 'the count of the errors',
  'val nxs = glist_length (xs)', 'val nxs = glist_length (xs) + glist_length (xs)'),
]
ref_out, ref_err, ref_exit = sys.argv[1], sys.argv[2], sys.argv[3]
ONLY = sys.argv[4:] if len(sys.argv) > 4 else None
T = os.environ.get('TMPDIR', '/tmp')
def build():
    r = subprocess.run(['make', '-C', d, 'm2dump', '-j16'], capture_output=True, text=True)
    return r.returncode == 0
def run():
    o = open(T + '/m2mut.out', 'w'); e = open(T + '/m2mut.err', 'w')
    subprocess.run([os.path.join(d, 'm2dump')], stdout=o, stderr=e, cwd=d)
    o.close(); e.close()
    same = filecmp.cmp(T + '/m2mut.out', ref_out, shallow=False) and filecmp.cmp(T + '/m2mut.err', ref_err, shallow=False)
    if not same: return False
    r = subprocess.run(['sh', os.path.join(d, 'm2exit.sh'), 'exit-only', T + '/m2mut.exit'], capture_output=True, text=True, cwd=d, env=dict(os.environ, TMPDIR=T))
    return filecmp.cmp(T + '/m2mut.exit', ref_exit, shallow=False)
nd = 0; nm = 0
for fn, what, old, new in MUT:
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if ONLY and what not in ONLY: continue
    bak = T + '/m2mut_backup_' + fn
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
    print('%-26s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
