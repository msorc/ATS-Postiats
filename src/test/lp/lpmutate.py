#!/usr/bin/env python3
"""lpmutate.py KIND PROBLEMS REFERENCE.out [N]   Mutation test of the ATS2 port of the linear constraint solver.

For each of the deliberate bugs below a copy of src/ is mutated, the driver is rebuilt (lpdrv2.sh), run on PROBLEMS
(KIND gmp|int) and its output is compared with REFERENCE.out (the output of the ATS1 driver, or of the unmutated ATS2 driver).
A mutation that is not detected (same output) is reported: it is either equivalent or a gap of the problems."""
import sys, os, shutil, subprocess, tempfile, concurrent.futures

HERE = os.path.dirname(os.path.abspath(__file__))
SRC2 = os.path.abspath(os.path.join(HERE, '..', '..'))

# (name, file, old, new, kinds)  -- [old] must occur exactly [count] times (default 1)
M = [
 ('inspect: gte at 0 is a contradiction', 'pats_lintprgm.dats', 'if !p >= 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION', 'if !p > 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION', 'gi'),
 ('inspect: lt at 0', 'pats_lintprgm.dats', 'if !p  <  0 then ans3 := TAUTOLOGY', 'if !p  <=  0 then ans3 := TAUTOLOGY', 'gi'),
 ('inspect: neq', 'pats_lintprgm.dats', 'if !p != 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION', 'if !p > 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION', 'gi'),
 ('cffgcd: the stop at 1', 'pats_lintprgm.dats', 'if !p != 1 then let', 'if !p != 2 then let', 'gi'),
 ('cffgcd: the gcd starts from 1', 'pats_lintprgm.dats', 'var res: myint(a) = myint_make_int<a> (0)', 'var res: myint(a) = myint_make_int<a> (1)', 'gi'),
 ('normalize: ediv by the gcd', 'pats_lintprgm.dats', 'val () = !p := ediv01_myint_myint<a> (!p, gcd)\n    val () = loop', 'val () = !p := mul01_myint_myint<a> (!p, gcd)\n    val () = loop', 'gi'),
 ('normalize: the tightening of a negative constant', 'pats_lintprgm.dats', 'val () = !p := sub01_myint_myint<a> (!p, gcd)', 'val () = !p := add01_myint_myint<a> (!p, gcd)', 'gi'),
 ('copy: the elements are negated', 'pats_lintprgm.dats', 'val () = !p2 := myint_copy<a> (!p1)', 'val () = !p2 := neg1_myint<a> (!p1)', 'gi'),
 ('negate: an increment', 'pats_lintprgm.dats', 'val () = !p := neg_myint<a> (!p)', 'val () = !p := add_myint_int<a> (!p, 1)', 'gi'),
 ('scale: an addition', 'pats_lintprgm.dats', 'val () = !p := mul10_myint_myint<a> (cff, !p)', 'val () = !p := add01_myint_myint<a> (!p, cff)', 'gi'),
 ('addby_cff: sub for add', 'pats_lintprgm.dats', 'val () = !p1 := add01_myint_myint<a> (!p1, cx2)', 'val () = !p1 := sub01_myint_myint<a> (!p1, cx2)', 'gi'),
 ('addby: sub for add', 'pats_lintprgm.dats', 'val () = !p1 := add01_myint_myint<a> (!p1, !p2)', 'val () = !p1 := sub01_myint_myint<a> (!p1, !p2)', 'gi'),
 ('compare_at: the order', 'pats_lintprgm.dats', 'val sgn = compare_myint_int (!p_i, x)', 'val sgn = ~(compare_myint_int (!p_i, x))', 'gi'),
 ('icnstr_negate: the knd of a conjunction', 'pats_lintprgm.dats', 'val () = knd := 1-knd', 'val () = knd := knd', 'gi'),
 ('icnstr_copy: a wrong knd', 'pats_lintprgm.dats', 'fold@ (ic); ICvec (knd1, iv_new)', 'fold@ (ic); ICvec ((if knd1 = 2 then 1 else knd1), iv_new)', 'gi'),
 ('inspect_gte of a list: a contradiction is kept', 'pats_lintprgm.dats', 'if ans3 > 0 then // TAUTOLOGY', 'if ans3 < 0 then // TAUTOLOGY', 'gi'),
 ('combine_at: the coefficients are swapped', 'pats_lintprgm_solve.dats', 'val iv = myintvec_copy_cff<a> (c_pos, iv_neg, n)', 'val iv = myintvec_copy_cff<a> (c_neg, iv_neg, n)', 'gi'),
 ('split_at: the negatives are positives', 'pats_lintprgm_solve.dats', '''      val () = ivs1 := negs
      prval () = fold@ (ivs)
      val () = negs := ivs''', '''      val () = ivs1 := poss
      prval () = fold@ (ivs)
      val () = poss := ivs''', 'gi'),
 ('auxcomb: stops on a tautology', 'pats_lintprgm_solve.dats', 'if (sgn >= 0) then let', 'if (sgn > 0) then let', 'gi'),
 ('absmincff: the maximum', 'pats_lintprgm_solve.dats', 'isz || lt_myint_myint<a> (!p, cff)', 'isz || gt_myint_myint<a> (!p, cff)', 'gi'),
 ('elimeq_at: the sign of the equality', 'pats_lintprgm_solve.dats', '  if sgn >= 0 then let\n    val () = c := neg_myint<a> (c)', '  if sgn > 0 then let\n    val () = c := neg_myint<a> (c)', 'gi'),
 ('indexset: the limit of the immediate sets', 'pats_lintprgm_solve.dats', 'if x <= 62 then (((w >> (x+1)) land 1UL) = 1UL) else false', 'if x <= 61 then (((w >> (x+1)) land 1UL) = 1UL) else false', 'gi'),
 ('indexset: a member of the big sets', 'pats_lintprgm_solve.dats', 'if j >= nw then false else', 'if j >= nw - 1 then false else', 'gi'),
 ('auxneq: the second branch', 'pats_lintprgm_solve.dats', 'val () = myintvec_add_int<a> (iv2_new, ~1)', 'val () = myintvec_add_int<a> (iv2_new, ~2)', 'gi'),
 ('auxneq: a contradiction is a conjunction', 'pats_lintprgm_solve.dats', '(if sgn > 0 then 0(*conj*) else 1(*disj*)): nat2', '(if sgn > 0 then 1(*conj*) else 0(*disj*)): nat2', 'gi'),
 ('disj: the branches are not restored', 'pats_lintprgm_solve.dats', 'val () = (ics1 := list_vt_reverse_append<ic> (rics1, ics1))', 'val () = (ics1 := list_vt_append<ic> (rics1, ics1))', 'gi'),
 ('elimeqlst of the inequalities: the stamp', 'pats_lintprgm_solve.dats', 'val () = myintvec_elimeqlst<a> (stamp, iv_new, i1veqs, n)', 'val () = myintvec_elimeqlst<a> (0, iv_new, i1veqs, n)', 'gi'),
 ('elimeqlst_rev: the stamps', 'pats_lintprgm_solve.dats', 'stamp0 <= stamp then', 'stamp0 < stamp then', 'gi'),
 ('myiveqlst_mark: the previous cell is not linked', 'pats_lintprgm_solve.dats', '| @MYIVEQLSTmark (_, next) =>\n      (myiveqlst_set_prev<a> (next, resp); fold@ (res))', '| @MYIVEQLSTmark (_, next) =>\n      (fold@ (res))', 'gi'),
 ('solve: the first index of the hint', 'pats_lintprgm_solve.dats', '    then loop(iset, k-1, list_vt_cons(k, res1), res2)\n    else loop(iset, k-1, res1, list_vt_cons(k, res2))', '    then loop(iset, k-1, res1, list_vt_cons(k, res2))\n    else loop(iset, k-1, list_vt_cons(k, res1), res2)', 'gi'),
 ('print: the separator', 'pats_lintprgm_print.dats', 'fprint_string (out, ", ")', 'fprint_string (out, ",")', 'gi'),
 ('print: the knd of the disjunction', 'pats_lintprgm_print.dats', 'prstr "disj"', 'prstr "conj"', 'gi'),
 ('gmp: sub is an add', 'pats_lintprgm_myint_gmp.dats', 'val p = mi2p0(x) in lpz_sub (p, mi2p1(y)); p2mi(p)', 'val p = mi2p0(x) in lpz_add (p, mi2p1(y)); p2mi(p)', 'g'),
 ('gmp: mul10 reads x twice', 'pats_lintprgm_myint_gmp.dats', 'val q = mi2p0(y) in lpz_mul_to (q, mi2p1(x), q); p2mi(q)', 'val q = mi2p0(y) in lpz_mul_to (q, mi2p1(x), mi2p1(x)); p2mi(q)', 'g'),
 ('gmp: the modulus is a remainder', 'pats_lintprgm_myint_gmp.cats', 'mpz_mod (PATSOPT_LPZ(r)', 'mpz_tdiv_r (PATSOPT_LPZ(r)', 'g'),
 ('gmp: add_int of a negative integer', 'pats_lintprgm_myint_gmp.cats', 'if (i >= 0) mpz_add_ui', 'if (i >= -1) mpz_add_ui', 'g'),
 ('int: gcd of the negative integers', 'pats_lintprgm_myint.cats', 'if (m0 >= 0) m = m0; else m = -m0 ;', 'if (m0 >= 0) m = m0; else m = m0 ;', 'i'),
 ('int: the division', 'pats_lintprgm_myint_int.dats', 'val res = mi2i0(x) / mi2i1(y)\n} // end of [div01_myint_myint<intknd>]', 'val res = mi2i0(x) % mi2i1(y)\n} // end of [div01_myint_myint<intknd>]', 'i'),
 ('int: mod11 is the C remainder of the other sign', 'pats_lintprgm_myint_int.dats', 'mod11_myint_myint<intknd> (x, y) = i2mi(mi2i1(x) % mi2i1(y))', 'mod11_myint_myint<intknd> (x, y) = i2mi(mi2i1(y) % mi2i1(x))', 'i'),
]

def want(k, kinds): return (k == 'gmp' and 'g' in kinds) or (k == 'int' and 'i' in kinds)

def mutate_copy(dst, m):
    for f in os.listdir(SRC2):
        p = os.path.join(SRC2, f)
        if os.path.isfile(p) and (f.startswith('pats_lintprgm') or f.startswith('pats_utils') or f.startswith('pats_intinf') or f.startswith('pats_basics') or f.startswith('pats_location') or f in ('pats_filename.sats', 'pats_symbol.sats', 'pats_label.sats', 'pats_params.hats', 'pats_error.sats') or f.endswith('.cats')):
            shutil.copy(p, dst)
    name, fn, old, new = m[0], m[1], m[2], m[3]
    exp = m[5] if len(m) > 5 else 1
    path = os.path.join(dst, fn)
    s = open(path).read()
    n = s.count(old)
    if n != (exp if exp else 1):
        return 'the text to mutate occurs %d times' % n
    s = s.replace(old, new)
    open(path, 'w').write(s)
    return None

def run(args):
    i, m, kind, probs, ref = args
    tmp = tempfile.mkdtemp(prefix='lpmut')
    try:
        err = mutate_copy(tmp, m)
        if err: return (i, m[0], 'ERROR', err)
        exe = os.path.join(tmp, 'drv')
        env = dict(os.environ, T2=tmp)
        r = subprocess.run([os.path.join(HERE, 'lpdrv2.sh'), kind, exe], env=env, capture_output=True, text=True)
        if r.returncode != 0: return (i, m[0], 'BUILD-FAILED', r.stdout[-300:] + r.stderr[-300:])
        try:
            out = subprocess.run([exe, probs], capture_output=True, timeout=600).stdout
        except subprocess.TimeoutExpired:
            return (i, m[0], 'DETECTED', 'timeout')
        refb = open(ref, 'rb').read()
        if out == refb: return (i, m[0], 'SURVIVED', '')
        a, b = out.split(b'\n'), refb.split(b'\n')
        d = sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))
        return (i, m[0], 'DETECTED', '%d lines differ' % d)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

def main():
    kind, probs, ref = sys.argv[1], os.path.abspath(sys.argv[2]), os.path.abspath(sys.argv[3])
    only = set(int(x) for x in os.environ['ONLY'].split(',')) if os.environ.get('ONLY') else None
    jobs = [(i, m, kind, probs, ref) for i, m in enumerate(M) if want(kind, m[4]) and (only is None or i in only)]
    nsurv = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=int(os.environ.get('JOBS', '8'))) as ex:
        for i, name, st, info in ex.map(run, jobs):
            print('%-9s %2d %s %s' % (st, i, name, info)); sys.stdout.flush()
            if st != 'DETECTED': nsurv += 1
    print('mutations: %d, not detected: %d' % (len(jobs), nsurv))
main()
