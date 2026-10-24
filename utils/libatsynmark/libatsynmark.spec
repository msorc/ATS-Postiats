# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for SATS/libatsynmark.sats (the d0eclrep tree), --global, --compact
# python3 ../arenagen/arenagen.py --global sats libatsynmark.spec > SATS/libatsynmark_gen.hats
# python3 ../arenagen/arenagen.py --global --compact dats libatsynmark.spec > DATS/libatsynmark_gen_dats.hats
# (make -f Makefile_build gen)
#
# [charlst] is a glist(char) here (the prelude has no nonlinear list)
typedef d0eclreplst = glist(d0eclrep)
type d0eclrep
  D0ECLREPsing (d0ecl, charlst)
  D0ECLREPinclude (d0ecl, charlst, d0eclreplst)
  D0ECLREPguadecl (guad0eclrep)
type guad0eclrep
  GUAD0ECLREPone (d0eclreplst)
  GUAD0ECLREPtwo (d0eclreplst, d0eclreplst)
  GUAD0ECLREPcons (d0eclreplst, guad0eclrep)
