#!/usr/bin/env python3
# usage: python3 c3mutate.py c3|j2 [WHAT...]
#
# Mutation test of the constraint-solver test (c3dump, data file c3data_gmp.txt) and of the level-2 jsonize test (j2dump): each mutation is a deliberate bug that is
# put in a ported module (the file is restored afterwards), the driver is rebuilt and its output is compared with the md5 sums of the ATS1 build (c3dump.md5,
# j2dump.md5): every mutation must change an output (be "detected"). A mutation that does not compile counts as detected.
import sys, os, subprocess, shutil, filecmp, hashlib
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
C3 = [
 # ---- pats_constraint3.dats
 ('pats_constraint3.dats', 's3exp_var: a boolean variable is an integer one', 'if isb then s3exp_S3Ebvar (s2v) else s3exp_S3Evar (s2v)', 'if isb then s3exp_S3Evar (s2v) else s3exp_S3Ebvar (s2v)'),
 ('pats_constraint3.dats', 'the sort of a product of booleans is int', '| ~S3Ebmul _ => s2rt_bool', '| ~S3Ebmul _ => s2rt_int'),
 ('pats_constraint3.dats', 'the free variables of a sum are not collected', '| ~S3Eisum (s3es) => looplst (res, s3es)', '| ~S3Eisum (s3es) => res'),
 ('pats_constraint3.dats', 'syneq ignores the kind of an inequality', 'if knd1 = knd2 then s3exp_syneq (x1, x2) else false', 'if true then s3exp_syneq (x1, x2) else false'),
 ('pats_constraint3.dats', 'syneq of two coefficients compares nothing', 'if c1 = c2 then s3exp_syneq (x1, x2) else false', 'if true then s3exp_syneq (x1, x2) else false'),
 ('pats_constraint3.dats', 'syneq of two applications forgets the arguments', 'if s3exp_syneq (x1, x2) then s3explst_syneq (xs1, xs2) else false', 'if s3exp_syneq (x1, x2) then true else false'),
 ('pats_constraint3.dats', 'the order of the structural comparison of terms', 's2hnf_syneq (s2f1, s2f2) orelse synlt_s2hnf_s2hnf (s2f1, s2f2)', 's2hnf_syneq (s2f1, s2f2) andalso synlt_s2hnf_s2hnf (s2f1, s2f2)'),
 ('pats_constraint3.dats', 'a metric that is strictly smaller on a component', '    if lt > 0 then s2p_lt (*true*)', '    if lt >= 0 then s2p_lt (*true*)'),
 ('pats_constraint3.dats', 'the lexicographic metric adds instead of multiplying', 's2exp_badd (s2p_lt, s2exp_bmul (s2p_lte, s2p_rest))', 's2exp_badd (s2p_lt, s2exp_badd (s2p_lte, s2p_rest))'),
 ('pats_constraint3.dats', 'a metric of equal terms is not reduced', '      if lte >= 0\n        then auxlst (s2es1, s2es2) else s2p_lte (*false*)', '      if lte < 0\n        then auxlst (s2es1, s2es2) else s2p_lte (*false*)'),
 ('pats_constraint3.dats', 'addresses are compared as booleans', 'else if s2rt_is_addr (s2t1) then s3exp_ieq (s3e1, s3e2)', 'else if s2rt_is_addr (s2t1) then s3exp_beq (s3e1, s3e2)'),
 ('pats_constraint3.dats', 'the binding of a variable does not go into the environment', 'val () = trans3_env_hypadd_bind (loc0, s2v1, s2f2)', 'val () = ()'),
 ('pats_constraint3.dats', 'the constants true and false are swapped', 'else if s2cstref_equ_cst (the_true_bool, s2c) then s3exp_true', 'else if s2cstref_equ_cst (the_true_bool, s2c) then s3exp_false'),
 ('pats_constraint3.dats', 'the arguments of an application are made in the other order', '  val s3e = s3exp_make (env, glist_head<s2exp> (s2es))\n  val s3es = s3explst_make (env, glist_tail<s2exp> (s2es))\nin\n  glist_cons<s3exp> (s3e, s3es)',
  '  val s3es = s3explst_make (env, glist_tail<s2exp> (s2es))\n  val s3e = s3exp_make (env, glist_head<s2exp> (s2es))\nin\n  glist_cons<s3exp> (s3e, s3es)'),
 ('pats_constraint3.dats', 'the head of a non-constant application is made after the arguments', '      val s3e1 = s3exp_make (env, s2e1)\n      val s3es2 = s3explst_make (env, s2es2)', '      val s3es2 = s3explst_make (env, s2es2)\n      val s3e1 = s3exp_make (env, s2e1)'),
 ('pats_constraint3.dats', 'a sizeof is an error', 'val s2ze = s2zexp_make_s2exp (s2e) in s3exp_S3Esizeof (s2ze)', 'val s2ze = s2zexp_make_s2exp (s2e) in s3exp_err (s2rt_int)'),
 ('pats_constraint3.dats', 'the domain of a boolean variable is not extracted', '      s3bes := list_vt_cons (s3exp_S3Ebdom (s2v), s3bes)', '      ()'),
 ('pats_constraint3.dats', 'the relation of a constant application is not extracted', '      | @Some_vt (s3be) => let\n          val () = s3bes := list_vt_cons (s3be, s3bes) in fold@ (rel)', '      | @Some_vt (s3be) => let\n          val () = () in fold@ (rel)'),
 ('pats_constraint3.dats', 'the result of a constant application is added first', 's2exp_app_srt (s2rt_bool, s2e_cst, s2es1)', 's2exp_app_srt (s2rt_bool, s2e_cst, glist_cons<s2exp> (s2e_var, arg1))'),
 ('pats_constraint3.dats', 'the relation of a constant application is not linearized', 'val s3be = s3exp_lintize (env, s3be) // nonlin terms -> vars', 'val s3be = s3be'),
 ('pats_constraint3.dats', 'find_cstapp does not compare the arguments', 'then s3explst_syneq (s3es0, s3es) else false', 'then true else false'),
 ('pats_constraint3.dats', 'find_nonlin is never successful', 'val test = s3exp_syneq (s3e0, s3e)', 'val test = false'),
 ('pats_constraint3.dats', 'a pop does not go through the other marks', '    | ~S2VBCFLSTmark (env) => env // HX: pop is done', '    | ~S2VBCFLSTmark (env) => S2VBCFLSTmark (env)'),
 ('pats_constraint3.dats', 'a nonlinear replacement has the wrong sort', 'val s2t = s3exp_get_srt (s3e)\n    val s2v = s2var_make_srt (s2t)', 'val s2t = s2rt_int\n    val s2v = s2var_make_srt (s2t)'),
 # ---- pats_constraint3_simplify.dats
 ('pats_constraint3_simplify.dats', 'the negation of a sum', '| ~S3Ebadd (s3e1, s3e2) => s3exp_S3Ebmul (s3exp_S3Ebneg s3e1, s3exp_S3Ebneg s3e2)', '| ~S3Ebadd (s3e1, s3e2) => s3exp_S3Ebadd (s3exp_S3Ebneg s3e1, s3exp_S3Ebneg s3e2)'),
 ('pats_constraint3_simplify.dats', 'the negation of an inequality does not change the kind', '| ~S3Ebineq (knd, s3e) => s3exp_S3Ebineq (~knd, s3e)', '| ~S3Ebineq (knd, s3e) => s3exp_S3Ebineq (knd, s3e)'),
 ('pats_constraint3_simplify.dats', 'badd of a true left operand', '    if b1 > 0 then s3exp_true else s3e2\n  ) else let', '    if b1 > 0 then s3e2 else s3exp_true\n  ) else let'),
 ('pats_constraint3_simplify.dats', 'bmul with a false right operand', '      if b2 > 0 then s3e1 else s3exp_false\n    ) else s3exp_S3Ebmul', '      if b2 > 0 then s3exp_false else s3e1\n    ) else s3exp_S3Ebmul'),
 ('pats_constraint3_simplify.dats', 'beq with a false left operand', '    if b1 > 0 then s3e2 else s3exp_bneg (s3e2)', '    if b1 > 0 then s3e2 else s3e2'),
 ('pats_constraint3_simplify.dats', 'the sign of a nonnegative constant', 'if knd = 2 then s3exp_bool (i >= 0)', 'if knd = 2 then s3exp_bool (i > 0)'),
 ('pats_constraint3_simplify.dats', 'icff of zero', 'else if c = 0 then s3exp_0', 'else if c = 0 then x'),
 ('pats_constraint3_simplify.dats', 'icff of a sum', 'val cxs = s3explst_icff (c, xs) in s3exp_S3Eisum (l2l cxs)', 'val cxs = s3explst_icff (c, xs) in s3exp_S3Eicff (c, x)'),
 ('pats_constraint3_simplify.dats', 'a sum of one term is a sum', '      then s3exp_S3Eisum (xs) else glist_head<s3exp> (xs)', '      then glist_head<s3exp> (xs) else s3exp_S3Eisum (xs)'),
 ('pats_constraint3_simplify.dats', 'the order of two variables in a sum', 'compare_s2var_s2var (s2v1, s2v2) <= 0 // HX: not [>=]!', 'compare_s2var_s2var (s2v1, s2v2) >= 0 // HX: not [>=]!'),
 ('pats_constraint3_simplify.dats', 'nonlinear terms do not go first', '  | ~S3Eiatm _ => false\n  | ~S3Evar s2v2 =>\n      compare_s2var_s2var', '  | ~S3Eiatm _ => true\n  | ~S3Evar s2v2 =>\n      compare_s2var_s2var'),
 ('pats_constraint3_simplify.dats', 'the sum of two coefficients', 's3exp_icff (c1+c2, y1)', 's3exp_icff (c1+1, y1)'),
 ('pats_constraint3_simplify.dats', 'the merge of two sums keeps equal terms apart', '        if gte21 then let\n          val x12 = s3exp_icff_add (x1, x2)', '        if false then let\n          val x12 = s3exp_icff_add (x1, x2)'),
 ('pats_constraint3_simplify.dats', 'the product of two variables', 's3exp_S3Eiatm (s2varmset_pair (un_S3Evar (x1), un_S3Evar (x2)))', 's3exp_S3Eiatm (s2varmset_sing (un_S3Evar (x1)))'),
 ('pats_constraint3_simplify.dats', 'the product of two atoms', 's3exp_S3Eiatm (s2varmset_union (un_S3Eiatm (x1), un_S3Eiatm (x2)))', 's3exp_S3Eiatm (un_S3Eiatm (x1))'),
 ('pats_constraint3_simplify.dats', 'the sum of a sum and a term is reversed', '      val xs = s3exp_isum_list (xs1, glist_sing<s3exp> (x2))\n    in', '      val xs = s3exp_isum_list (glist_sing<s3exp> (x2), xs1)\n    in'),
 ('pats_constraint3_simplify.dats', 'the difference of two sums does not negate', '      val xs2 = un_S3Eisum (x2)\n      val xs2 = l2l (s3explst_icff (intinf_neg_1, xs2))\n      val xs = s3exp_isum_list (xs1, xs2)\n    in\n      s3exp_isum (l2l xs)\n    end // end of [S3Eisum, S3Eisum]\n    else let\n      val xs2 = glist_sing<s3exp> (s3exp_ineg (x2))', '      val xs2 = un_S3Eisum (x2)\n      val xs2 = l2l (s3explst_icff (intinf_1, xs2))\n      val xs = s3exp_isum_list (xs1, xs2)\n    in\n      s3exp_isum (l2l xs)\n    end // end of [S3Eisum, S3Eisum]\n    else let\n      val xs2 = glist_sing<s3exp> (s3exp_ineg (x2))'),
 ('pats_constraint3_simplify.dats', 'lintize does not count a negation', '    if flag > flag0 then s3exp_S3Ebneg (s3e) else s3e0', '    if false then s3exp_S3Ebneg (s3e) else s3e0'),
 ('pats_constraint3_simplify.dats', 'lintize of a product forgets to count', '    val () = flag := flag + 1\n    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)\n  in\n    s3exp_var (s2v)\n  end // end of [S3Eimul]', '    val () = ()\n    val s2v = s2vbcfenv_replace_nonlin (env, s3e0)\n  in\n    s3exp_var (s2v)\n  end // end of [S3Eimul]'),
 # ---- pats_constraint3_icnstr.dats
 ('pats_constraint3_icnstr.dats', 'an equality of booleans is a conjunction', '    ICveclst (1(*disj*), list_vt_pair (ic12, ic12_neg))', '    ICveclst (0(*conj*), list_vt_pair (ic12, ic12_neg))'),
 ('pats_constraint3_icnstr.dats', 'a boolean variable is x = 0', '    val () = myintvec_add_int (iv, ~1)', '    val () = myintvec_add_int (iv, 1)'),
 ('pats_constraint3_icnstr.dats', 'a boolean domain is a constraint', '| ~S3Ebdom (s2v) => ICveclst (0(*conj*), list_vt_nil)', '| ~S3Ebdom (s2v) => ICveclst (1(*disj*), list_vt_nil)'),
 ('pats_constraint3_icnstr.dats', 'the coefficient of a variable is subtracted', 'val () = !pi := add01_myint_myint (!pi, cff)', 'val () = !pi := sub01_myint_myint (!pi, cff)'),
 ('pats_constraint3_icnstr.dats', 'a disequality of booleans', '    val ic_1_neg2 = ICveclst (0(*conj*), list_vt_pair (ic1, ic2_neg))', '    val ic_1_neg2 = ICveclst (0(*conj*), list_vt_pair (ic1, ic2))'),
 ('pats_constraint3_icnstr.dats', 'the sum of booleans is a conjunction', '    ICveclst (1(*disj*), list_vt_pair (ic1, ic2))\n  end // end of [S3Ebadd]', '    ICveclst (0(*conj*), list_vt_pair (ic1, ic2))\n  end // end of [S3Ebadd]'),
 ('pats_constraint3_icnstr.dats', 'an unknown variable is not an error', 'val () = myint_free (cff) in err := err + 1', 'val () = myint_free (cff) in ()'),
 ('pats_constraint3_icnstr.dats', 'the first variable is not found', 'if i > 0 then let\n  val (pf | p) = myintvec_takeout {a} (iv)', 'if i > 1 then let\n  val (pf | p) = myintvec_takeout {a} (iv)'),
 ('pats_constraint3_icnstr.dats', 'the first variable has the index 0', '    prval () = opt_unsome {res} (x) in x+1', '    prval () = opt_unsome {res} (x) in x+0'),
 # ---- pats_constraint3_solve.dats
 ('pats_constraint3_solve.dats', 'the conclusion is not negated', 'val ic_conc_neg = icnstr_negate<a> (ic_conc)', 'val ic_conc_neg = ic_conc'),
 ('pats_constraint3_solve.dats', 'the assumptions are taken in the other order', '      val res = loop (loc0, vim, n, s3ps1, list_vt_cons (ic, res))', '      val res = list_vt_cons (ic, loop (loc0, vim, n, s3ps1, res))'),
 ('pats_constraint3_solve.dats', 'an untranslatable constraint is true', '      s3exp_false // HX: make it the worst scenario', '      s3exp_true // HX: make it the worst scenario'),
 ('pats_constraint3_solve.dats', 'the case exhaustiveness of case is an error', '    | CK_case () => 1 (*warning*)', '    | CK_case () => 0 (*warning*)'),
 ('pats_constraint3_solve.dats', 'a constraint under a hypothesis does not stop', '  if ans1 >= 0 then 0(*unsolved*) else ans2', '  if ans1 >= 0 then ans2 else 0(*unsolved*)'),
 ('pats_constraint3_solve.dats', 'the branches of a disjunction are in the other order', '    val s3is1 = glist_append<s3itm> (s3is, s3is0)', '    val s3is1 = glist_append<s3itm> (s3is0, s3is)'),
 ('pats_constraint3_solve.dats', 'one unsolved constraint is some', '    if unsolved <= 1u\n      then prerr ": there is one unsolved constraint"', '    if unsolved <= 0u\n      then prerr ": there is one unsolved constraint"'),
 ('pats_constraint3_solve.dats', 'a solved constraint counts', '  if status >= 0 then (unsolved := unsolved + 1u)', '  if status >= 0 then (unsolved := unsolved + 2u)'),
 ('pats_constraint3_solve.dats', 'a reference to no constraint is not solved', '      | ~GOnone () => ~1(*solved*)', '      | ~GOnone () => 0(*solved*)'),
 ('pats_constraint3_solve.dats', 'a hypothesis is not linearized', '            val s3p = s3exp_lintize(env, s3p) in s2vbcfenv_add_sbexp (env, s3p)', '            val s3p = s3p in s2vbcfenv_add_sbexp (env, s3p)'),
 ('pats_constraint3_solve.dats', 'the loop kind of the message', '    if knd = 0 then prerr ": unsolved constraint for loop(break)"', '    if knd = 1 then prerr ": unsolved constraint for loop(break)"'),
 # ---- pats_constraint3_init.dats
 ('pats_constraint3_init.dats', 'the sign of the divisor', '    | ~S2Eint (i) => (if i < 0 then ~1 else (if i > 0 then 1 else 0))', '    | ~S2Eint (i) => (if i < 0 then 1 else (if i > 0 then 1 else 0))'),
 ('pats_constraint3_init.dats', 'a division by a positive constant', '  if sgn >= 0 then s3e else s3exp_ineg (s3e)', '  if sgn > 0 then s3e else s3exp_ineg (s3e)'),
 ('pats_constraint3_init.dats', 'the constants of classes', '    (\n      s3exp_bool (s2cst_lte_cls_cls (s2c1, s2c2))\n    )', '    (\n      s3exp_bool (s2cst_lte_cls_cls (s2c2, s2c1))\n    )'),
 ('pats_constraint3_init.dats', 'min is max', 'val () = ins (map, the_min_int_int, f_min_int_int)', 'val () = ins (map, the_min_int_int, f_max_int_int)'),
 ('pats_constraint3_init.dats', 'the subtraction of addresses is an addition', 'val () = ins (map, the_sub_addr_addr, f_sub_int_int)', 'val () = ins (map, the_sub_addr_addr, f_add_int_int)'),
 # ---- pats_constraint3_mapgen.dats, pats_constraint3_jsonize.dats
 ('pats_constraint3_mapgen.dats', 'the constants are visited twice', '  s2cstset_vt_ismem (s2cs, s2c)', '  false'),
 ('pats_constraint3_jsonize.dats', 'the label of a kind', 'jsonval_conarg0 ("C3TKlstate")', 'jsonval_conarg0 ("C3TKlstate_")'),
 ('pats_constraint3_jsonize.dats', 'the order of the arguments of a hypothesis', '      ("H3YPObind", jsonize_s2var(s2v1), jsonize1_s2exp(s2e2))', '      ("H3YPObind", jsonize1_s2exp(s2e2), jsonize_s2var(s2v1))'),
 ('pats_constraint3_jsonize.dats', 'the sorts of the variables are not collected', '  aux_s2rt(s2var_get_srt(s2v), res)', '  res'),
 ('pats_constraint3_jsonize.dats', 'the export separator', '"{\\n\\"s2cstmap\\":\\n"', '"{\\n\\"s2cstmap\\":"'),
]
J2 = [
 ('pats_jsonize_synent2.dats', 'the label of a variable sort', 'jsonval_conarg1 ("S2RTtup", s2ts)', 'jsonval_conarg1 ("S2RTtuple", s2ts)'),
 ('pats_jsonize_synent2.dats', 'the stamp of a constant', 'jsonval_labval1 ("s2cst_stamp", stamp)', 'jsonval_labval1 ("s2cst_stampp", stamp)'),
 ('pats_jsonize_synent2.dats', 'the order of the arguments of an application', 'jsonval_conarg2("S2Eapp", s2e1(*fun*), s2es2(*arglst*))', 'jsonval_conarg2("S2Eapp", s2es2(*arglst*), s2e1(*fun*))'),
 ('pats_jsonize_synent2.dats', 'the hnfize flag of a list', '    jsonize_s2exp (flag, glist_head<s2exp> (s2es))', '    jsonize_s2exp (0, glist_head<s2exp> (s2es))'),
 ('pats_jsonize_synent2.dats', 'a record label without a name', '    | ~GOnone () => jsonval_none ()\n    | ~GOsome (x) => jsonval_some (jsonval_string(x))\n  ) : jsonval', '    | ~GOnone () => jsonval_none ()\n    | ~GOsome (x) => jsonval_none ()\n  ) : jsonval'),
 ('pats_jsonize_synent2.dats', 'the invariant of a pattern constructor', 'val jsv5 = jsonval_int (npf)', 'val jsv5 = jsonval_int (0)'),
 ('pats_jsonize_synent2.dats', 'the kind of a sort variable is lost', '    jsonize_s2rt(s2rtVar_get_s2rt(s2tV))', '    jsonval_conarg0 ("S2RTerr")'),
 ('pats_jsonize_synent2.dats', 'the supertypes of a constant', 'jsonize0_s2explst(s2cst_get_supcls(s2c))', 'jsonize0_s2explst(glist_nil{s2exp} ())'),
 ('pats_jsonize_synent2.dats', 'the expression label of a clause', '"c2lau_neg", neg', '"c2lau_neq", neg'),
 ('pats_jsonize_synent2.dats', 'the list of declarations of a local', 'jsonval_conarg2("D2Clocal", head, body)', 'jsonval_conarg2("D2Clocal", body, head)'),
 ('pats_jsonize_synent2.dats', 'the output separator', ',\\n\\"d2conmap\\":\\n', ',\\n\\"d2conmap\\":'),
 ('pats_jsonize_synent2.dats', 'the label of the variable map', ',\\n\\"s2varmap\\":\\n', ',\\n\\"s2varmaps\\":\\n'),
 ('pats_jsonize_synent2.dats', 'a hnfize that is not done', 'if flag = 0 then s2e0 else s2exp_hnfize (s2e0)', 'if flag = 0 then s2e0 else s2e0'),
 ('pats_jsonize_synent2.dats', 'the label of a character', 'jsonval_conarg1 ("P2Tchar", jsonval_int (char2int0(c)))', 'jsonval_conarg1 ("P2Tchar", jsonval_int (char2int0(c)+1))'),
]
which = sys.argv[1]
MUT = {'c3': C3, 'j2': J2}[which]
ONLY = sys.argv[2:] if len(sys.argv) > 2 else None
T = os.environ.get('TMPDIR', '/tmp')
if which == 'c3':
    TARGET = 'c3dump'
    def run():
        o = subprocess.run([os.path.join(d, 'c3dump'), os.path.join(d, 'c3data_gmp.txt')], capture_output=True, cwd=d)
        return (hashlib.md5(o.stdout).hexdigest(), hashlib.md5(o.stderr).hexdigest())
    ref = tuple(open(os.path.join(d, 'c3dump.md5')).read().split()[:2])
else:
    TARGET = 'j2dump'
    def run():
        o = subprocess.run([os.path.join(d, 'j2dump')], capture_output=True, cwd=d)
        return (hashlib.md5(o.stdout).hexdigest(), hashlib.md5(o.stderr).hexdigest())
    ref = tuple(open(os.path.join(d, 'j2dump.md5')).read().split()[:2])
def build():
    r = subprocess.run(['make', '-C', d, TARGET, '-j16'], capture_output=True, text=True)
    return r.returncode == 0
assert build() and run() == ref, 'the unmutated build must give the reference output'
nd = 0; nm = 0
for fn, what, old, new in MUT:
    if new is None: continue
    path = os.path.join(M, fn)
    src = open(path).read()
    if src.count(old) != 1:
        print('SKIP (pattern found %d times): %s: %s' % (src.count(old), fn, what)); continue
    if old == new: print('SKIP (no change): %s' % what); continue
    if ONLY and what not in ONLY: continue
    bak = T + '/c3mut_backup_' + fn
    shutil.copy(path, bak)
    try:
        open(path, 'w').write(src.replace(old, new))
        nm += 1
        if not build(): res = 'detected (does not compile)'; nd += 1
        elif run() == ref: res = 'NOT DETECTED'
        else: res = 'detected'; nd += 1
    finally:
        shutil.copy(bak, path)
        assert filecmp.cmp(path, bak, shallow=False)
    print('%-34s %-8s %s' % (fn, res, what)); sys.stdout.flush()
build()
print('mutations: %d, detected: %d' % (nm, nd))
