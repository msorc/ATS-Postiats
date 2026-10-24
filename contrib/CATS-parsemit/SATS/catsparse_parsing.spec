# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats --global \
#     SATS/catsparse_parsing.spec > SATS/catsparse_parsing_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats --global \
#     SATS/catsparse_parsing.spec > DATS/catsparse_parsing_gen.hats
#
type parerr
  PARERR (parerr_loc: loc_t, parerr_node: parerr_node)
