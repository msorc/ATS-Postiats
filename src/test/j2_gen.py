#!/usr/bin/env python3
# usage: python3 j2_gen.py   (rewrites j2hand.hats j2hand1.hats j2cases_*.hats j2case_*.dats j2case1_*.dats j2chunks*.hats and the support files of the level-3 test)
#
# Test of the level-2 jsonize (pats_jsonize_synent2) against the ATS1 build of src/ (see PORTING.md, "Level-2 jsonize"). Same method as t3_gen.py: ONE
# generated program of scenarios, in the common subset of ATS1 and ATS2, is compiled by the ATS2 driver (j2dump.dats) and by the ATS1 driver (j2dump1.dats,
# linked with the ATS1 objects of $SRC); stdout and stderr must be identical. The compat layers (K_<CON>, dd_<T>) are those of the level-3 test.
import os, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import t3_gen
import d2_gen, d2_cases, t3_cases
import c3_gen
import j2_cases

if __name__ == '__main__':
    c3_gen.t3_support()
    d2_cases.put(os.path.join(d, 'j2hand.hats'), t3_gen.expand_hand(2, 'j2hand.tmpl'))
    d2_cases.put(os.path.join(d, 'j2hand1.hats'), t3_gen.expand_hand(1, 'j2hand.tmpl'))
    j2_cases.main(d2_gen, d2_cases, t3_gen.D3ORDER)
