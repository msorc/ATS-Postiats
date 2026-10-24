# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_typerase.sats: the list of the errors of the level-4 translation (typerase) (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_typerase.spec > pats_typerase_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_typerase.spec > pats_typerase_gen_dats.hats
# (the ATS1 constructor T4E_d3exp_tyer_isnotval is commented out in src/pats_typerase.sats: it is only a warning)
type trans4err
  T4E_p3at_tyer_isprf (p3at)
  T4E_d3exp_tyer_isprf (d3exp)
