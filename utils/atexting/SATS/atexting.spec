# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
# The arena encoding (in the global arena) of the syntax:
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats --global \
#     SATS/atexting.spec > SATS/atexting_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats --global \
#     SATS/atexting.spec > DATS/atexting_gen.hats
#
type token_node
  TOKeol ()
  TOKeof ()
  TOKint (string)
  TOKide (string)
  TOKspchr (int)
  TOKbslash (int)
  TOKspace (string)
  TOKsharp (string)
  TOKsquote ()
  TOKdquote (string)
  TOKcode_beg (string)
  TOKcode_end (string)

type token
  TOKEN (token_loc: loc_t, token_node: token_node)

type atext_node
  TEXTnil ()
  TEXTtoken (token)
  TEXTstring (string)
  TEXTerrmsg (string)
  TEXTlist (glist(atext))
  TEXTsquote (glist(atext))
  TEXTdquote (token, glist(atext))
  TEXTextcode (token, glist(atext), token)
  TEXTdefname (token, token)
  TEXTfuncall (token, token, glist(atext))

type atext
  ATEXT (atext_loc: loc_t, atext_node: atext_node)

type parerr_node
  PARERR_SQUOTE (loc_t)
  PARERR_DQUOTE (loc_t)
  PARERR_FUNARG (loc_t)
  PARERR_EXTCODE (loc_t)

type parerr
  PARERR (parerr_loc: loc_t, parerr_node: parerr_node)
