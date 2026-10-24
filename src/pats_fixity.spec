# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_fixity.sats (fxty only: fxopr and fxitm
# are polymorphic and are written by hand in pats_fixity.sats/pats_fixity_fxty.dats)
# python3 ../utils/arenagen/arenagen.py --global sats pats_fixity.spec > pats_fixity_gen.hats
# python3 ../utils/arenagen/arenagen.py --global dats pats_fixity.spec > pats_fixity_gen_dats.hats
type fxty
  FXTYnon ()
  FXTYinf (prec, assoc)
  FXTYpre (prec)
  FXTYpos (prec)
