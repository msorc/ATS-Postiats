#!/usr/bin/env python3
# usage: python3 cg_gen.py   (rewrites d2compat_gen.hats d2compat1_gen.hats cgcompat_gen.hats cgcompat1_gen.hats cgcases_*.hats cgcase_*.dats cgcase1_*.dats cgchunks*.hats)
#
# Test of pats_codegen2{,_util,_datype,_fprint,_absrec} and pats_patcst2 against the ATS1 build of src/ (see PORTING.md, "Codegen2" and
# "Pattern coverage (patcst2)"). Same method as d2_gen.py: ONE generated program of test cases, written in the common subset of ATS1 and ATS2,
# is compiled by the ATS2 driver (cgdump.dats, with ../pats_codegen2*.dats, ../pats_patcst2.dats) and by the ATS1 driver (cgdump1.dats, linked with
# the ATS1 objects of $ATS1REF); the stdout and the stderr of the two must be identical.
#
#  * d2compat_gen.hats / d2compat1_gen.hats: the wrappers K_<CON> of the level-2 trees and the typed lists (d2_gen.py).
#  * cgcompat_gen.hats / cgcompat1_gen.hats: the same for the types of pats_patcst2.spec (K_P2TCany .., LN_p2atcstlst ..).
#  * cgcases_<k>.hats: the scenarios (cg_cases.py).
import re, os, sys
sys.dont_write_bytecode = True

d = os.path.dirname(os.path.abspath(__file__))
import d2_gen
import d2_cases
import cg_cases
import cg_pat

if __name__ == '__main__':
    d2_cases.put(os.path.join(d, 'd2compat_gen.hats'), d2_gen.gen_compat(2))
    d2_cases.put(os.path.join(d, 'd2compat1_gen.hats'), d2_gen.gen_compat(1))
    d2_cases.put(os.path.join(d, 'cgcompat_gen.hats'), cg_pat.gen_compat(2))
    d2_cases.put(os.path.join(d, 'cgcompat1_gen.hats'), cg_pat.gen_compat(1))
    cg_cases.main(d2_gen, d)
