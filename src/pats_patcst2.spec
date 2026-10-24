# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_patcst2.{sats,dats}: the pattern constraints (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_patcst2.spec > pats_patcst2_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_patcst2.spec > pats_patcst2_gen_dats.hats
#
# ATS1: datatype p2atcst with the constructors P2TC* and the one-constructor datatype labp2atcst = LABP2ATCST of (label, p2atcst)
# (a record here, like labs1exp). The nonlinear lists are glists; the linear lists [p2atcstlst_vt] are List0_vt (see the sats).
typedef p2atcstlst = glist(p2atcst)
typedef labp2atcstlst = glist(labp2atcst)
vtypedef p2atcstlst_vt = List0_vt(p2atcst)
vtypedef labp2atcstlst_vt = List0_vt(labp2atcst)
type p2atcst
  P2TCany ()
  P2TCcon (d2con, p2atcstlst)
  P2TCempty ()
  P2TCint (intinf)
  P2TCintc (intinfset)
  P2TCbool (bool)
  P2TCchar (char)
  P2TCcharc (charset)
  P2TCfloat (string)
  P2TCstring (string)
  P2TCrec (int, labp2atcstlst)
record labp2atcst (labp2atcst_lab: label, labp2atcst_elt: p2atcst)
