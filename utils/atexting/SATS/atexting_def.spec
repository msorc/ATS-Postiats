# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
# The arena encoding (in the global arena) of text definitions
# and command-line arguments:
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats --global \
#     SATS/atexting_def.spec > SATS/atexting_def_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats --global \
#     SATS/atexting_def.spec > DATS/atexting_def_gen.hats
#
type atextdef
  TEXTDEFnil ()
  TEXTDEFval (atext)
  TEXTDEFfun (atextfun)
  TEXTDEFfstr (atextfstr)

type commarg
  CAhelp (string)
  CAgitem (string)
  CAnsharp (string, gopt(string))
  CAinpfil (string, gopt(string))
  CAoutfil (string, gopt(string))
