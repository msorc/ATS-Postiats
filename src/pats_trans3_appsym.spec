# arenagen specification for the private types of pats_trans3_appsym.dats (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_appsym.spec > pats_trans3_appsym_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_appsym.spec > pats_trans3_appsym_gen_dats.hats
# ATS1: datatype d3pitm = D3PITM of (int, d3exp) (a one-constructor datatype: a record here),
#       datatype d3exparg = D3EXPARGsta of (loc_t, s2exparglst) | D3EXPARGdyn of (int(*npf*), loc_t, d3explst)
typedef d3pitmlst = glist(d3pitm)
typedef d3exparglst = glist(d3exparg)
vtypedef d3pitmlst_vt = List0_vt(d3pitm)
vtypedef d3exparglst_vt = List0_vt(d3exparg)
record d3pitm (d3pitm_pval: int, d3pitm_dexp: d3exp)
type d3exparg
  D3EXPARGsta (location, s2exparglst)
  D3EXPARGdyn (int, location, d3explst)
