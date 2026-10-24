# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_histaexp.{sats,dats}: the types of the typerase output (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_histaexp.spec > pats_histaexp_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_histaexp.spec > pats_histaexp_gen_dats.hats
#
# Same conventions as pats_staexp2.spec. The ATS1 one-constructor datatypes [hitnam] (HITNAM of (int, int, string)) and
# [labhisexp] (HSLABELED of (label, Option (string), hisexp)) are records [hitnam_new (knd, fin, name)] and
# [labhisexp_new (lab, opt, elt)] (like labs2exp); [hisexp] is the record '{hisexp_name, hisexp_node} of ATS1.
typedef hisexplst = glist(hisexp)
typedef hisexpopt = gopt(hisexp)
typedef hisexplstlst = glist(hisexplst)
typedef labhisexplst = glist(labhisexp)
record hitnam (hitnam_ptr: int, hitnam_fin: int, hitnam_name: string)
record hisexp (hisexp_name: hitnam, hisexp_node: hisexp_node)
record labhisexp (labhisexp_lab: label, labhisexp_opt: stringopt, labhisexp_elt: hisexp)
type hisexp_node
  HSEcst (s2cst)
  HSEtybox ()
  HSEtyabs (symbol)
  HSEapp (hisexp, hisexplst)
  HSEextype (string, hisexplstlst)
  HSEfun (funclo, hisexplst, hisexp)
  HSErefarg (int, hisexp)
  HSEtyarr (hisexp, s2explst)
  HSEtyrec (tyreckind, labhisexplst)
  HSEtyrecsin (labhisexp)
  HSEtysum (d2con, labhisexplst)
  HSEtyvar (s2var)
  HSEtyclo (funlab)
  HSEvararg (s2exp)
  HSEs2exp (s2exp)
  HSEs2zexp (s2zexp)
