# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_ccomp_hitype.dats: the C types (ATS1: the datatypes [hitype] and [labhitype] local to
# pats_ccomp_hitype.dats), --compact
# python3 ../utils/arenagen/arenagen.py --global sats pats_ccomp_hitype.spec > pats_ccomp_hitype_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_ccomp_hitype.spec > pats_ccomp_hitype_gen_dats.hats
#
# The spec type is [hit] (not [hitype]): [hitype] is the abstype of pats_ccomp.sats, which the .dats [assume]s equal to [hit].
# The ATS1 one-constructor datatype [HTLABELED (label, Option (string), hitype)] is the record [labhit] (like labhisexp).
typedef hitlst = glist(hit)
typedef labhitlst = glist(labhit)
type hit
  HITnmd (string)
  HITapp (hit, hitlst)
  HITtyarr (hit, s2explst)
  HITtyrec (labhitlst)
  HITtysum (int, labhitlst)
  HITtyexn (labhitlst)
  HITtyvar (s2var)
  HITtyclo (funlab)
  HITvararg (hit)
  HITrefarg (int, hit)
  HITundef (stamp, hisexp)
  HITerror ()
record labhit (labhit_lab: label, labhit_opt: stringopt, labhit_elt: hit)
