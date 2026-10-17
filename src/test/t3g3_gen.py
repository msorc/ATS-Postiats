#!/usr/bin/env python3
# usage: python3 t3g3_gen.py   (after t3_gen.py: rewrites t3g3hand.hats t3g3hand1.hats t3g3env.hats t3g3env1.hats t3g3cases_*.hats t3g3case_*.dats t3g3case1_*.dats t3g3chunks*.hats)
#
# Test of the group 3 of the level-3 translation (pats_trans3_p2at, _selab, _fldfrat, _lvalres) against the ATS1 build of src/ (see PORTING.md,
# "Level 3 translation, group 3 (p2at/selab/fldfrat/lvalres)"). Same method as t3_gen.py: ONE generated program of scenarios, in the common subset of
# ATS1 and ATS2, is compiled by the ATS2 driver (t3g3dump.dats) and by the ATS1 driver (t3g3dump1.dats, linked with the ATS1 objects of $SRC);
# stdout and stderr must be identical. The compat layers (K_<CON>, dd_<T>) and the pervasive environment are those of the level-3 test.
import os, sys
sys.dont_write_bytecode = True
d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, d)
import t3_gen
import d2_gen, d2_cases, t3_cases
import t3g3_cases

if __name__ == '__main__':
    d2_cases.put(os.path.join(d, 't3g3hand.hats'), t3_gen.expand_hand(2, 't3g3hand.tmpl'))
    d2_cases.put(os.path.join(d, 't3g3hand1.hats'), t3_gen.expand_hand(1, 't3g3hand.tmpl'))
    d2_cases.put(os.path.join(d, 't3g3env.hats'), t3_gen.expand_hand(2, 't3g3env.tmpl'))
    d2_cases.put(os.path.join(d, 't3g3env1.hats'), t3_gen.expand_hand(1, 't3g3env.tmpl'))
    t3g3_cases.main(d2_gen, d2_cases, t3_gen.D3ORDER)
