#
# HX-2026-10: no GC
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats \
#     SATS/patsolve_z3_solving.spec > SATS/patsolve_z3_solving_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats \
#     SATS/patsolve_z3_solving.spec > DATS/SOLVING/patsolve_z3_solving_gen.hats
#
type s2cinterp
  S2CINTnone ()
  S2CINTsome (ptr)
  S2CINTbuiltin_0 (fopr0)
  S2CINTbuiltin_1 (fopr1)
  S2CINTbuiltin_2 (fopr2)
  S2CINTbuiltin_list ()
