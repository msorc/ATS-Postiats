#!/usr/bin/env python3
# usage: python3 g2_gen.py   (rewrites g2env.hats g2env1.hats g2cases_*.hats g2case_*.dats g2case1_*.dats g2chunks*.hats, and the compat layers of the level-3 and codegen2 tests)
#
# Test of pats_trans3_{dynexp_dn,appsym,caseof,patcon} against the ATS1 build of src/ (see PORTING.md, "Level 3 translation, group 2").
# Same method as t3_gen.py: ONE generated program of scenarios, written in the common subset of ATS1 and ATS2, is compiled by the ATS2 driver (g2dump.dats)
# and by the ATS1 driver (g2dump1.dats, linked with the ATS1 objects of $ATS1REF, the real ones of the four modules included); the stdout and the stderr
# of the two must be identical. The functions that the other groups of the trans3 port implement (d2exp_trup, d3exp_trdn, p2at_trdn, ..) are test
# doubles (g2env.tmpl) that print their calls; everything else (trans3_env, patcst2, dmacro2, the solver, stacst2..) is real on both sides.
import os, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import t3_gen, d2_gen, d2_cases, t3_cases, cg_pat, cg_cases
import g2_cases

if __name__ == '__main__':
    put = d2_cases.put
    # the layers of the level-3 test (the same files as t3_gen.py makes) and of the codegen2/patcst2 test
    put(os.path.join(d, 't3compat_gen.hats'), t3_gen.gen_compat(2))
    put(os.path.join(d, 't3compat1_gen.hats'), t3_gen.gen_compat(1))
    put(os.path.join(d, 't3hand.hats'), t3_gen.expand_hand(2))
    put(os.path.join(d, 't3hand1.hats'), t3_gen.expand_hand(1))
    put(os.path.join(d, 't3env.hats'), t3_gen.expand_hand(2, 't3env.tmpl'))
    put(os.path.join(d, 't3env1.hats'), t3_gen.expand_hand(1, 't3env.tmpl'))
    put(os.path.join(d, 'cgcompat_gen.hats'), cg_pat.gen_compat(2))
    put(os.path.join(d, 'cgcompat1_gen.hats'), cg_pat.gen_compat(1))
    put(os.path.join(d, 'g2env.hats'), t3_gen.expand_hand(2, 'g2env.tmpl'))
    put(os.path.join(d, 'g2env1.hats'), t3_gen.expand_hand(1, 'g2env.tmpl'))
    g2_cases.main(d2_gen, d2_cases, t3_cases, t3_gen.D3ORDER, d)
