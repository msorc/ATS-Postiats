# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for the private types of pats_trans3_env_effect.dats (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_env_effect.spec > pats_trans3_env_effect_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_env_effect.spec > pats_trans3_env_effect_gen_dats.hats
# An item of the stack of effects: the stack is a [glist] of items, a mark is an item (knd=0/1: soft/hard), the
# ATS1 [effenvitmlst] was a linear list of [EFILSTcons (itm, _) | EFILSTmark (knd, _) | EFILSTnil].
type effenvitm
  EFFENVITMeff (effset)
  EFFENVITMeffmask (s2eff)
  EFFENVITMmark (int)
