# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_dmacro2.sats: the macro values (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_dmacro2.spec > pats_dmacro2_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_dmacro2.spec > pats_dmacro2_gen_dats.hats
typedef m2valist = glist(m2val)
type m2val
  M2Vint (int)
  M2Vbool (bool)
  M2Vchar (char)
  M2Vfloat (string)
  M2Vstring (string)
  M2Vunit ()
  M2Vscode (s2exp)
  M2Vdcode (d2exp)
  M2Vlist (m2valist)
  M2Verr ()
