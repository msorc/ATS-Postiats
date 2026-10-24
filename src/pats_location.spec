# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_location.{sats,dats}
# python3 ../utils/arenagen/arenagen.py --global sats pats_location.spec > pats_location_gen.hats
# python3 ../utils/arenagen/arenagen.py --global dats pats_location.spec > pats_location_gen_dats.hats
type locpragma
  LOCPRAGMA0 ()
  LOCPRAGMA1 (string)
  LOCPRAGMA2 (string, string)
type location
  LOCATION (filename: filename, beg_ntot: lint, beg_nrow: int, beg_ncol: int, end_ntot: lint, end_nrow: int, end_ncol: int, locpragma: locpragma)
