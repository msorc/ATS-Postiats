# arenagen specification for the private type of pats_trans3_env_dvar.dats (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_env_dvar.spec > pats_trans3_env_dvar_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_env_dvar.spec > pats_trans3_env_dvar_gen_dats.hats
# A frame of the stack of local dynamic variables: a [glist] of frames in a cell (ATS1: the linear
# [ld2vsetlst] = LD2VSset (d2varset_vt, _) | LD2VSlam (lin, d2varlst_vt, _) | LD2VSnil).
# [ld2vsfrm_knd]=0: a set (the linear [d2varset_vt] kept as a [ptr] in [ld2vsfrm_set]); =1: a marker for a lambda
# ([ld2vsfrm_lin] is its linearity, [ld2vsfrm_d2vs] the variables it collected).
record ld2vsfrm (ld2vsfrm_knd: int, ld2vsfrm_lin: int, ld2vsfrm_set: ptr, mut ld2vsfrm_d2vs: d2varlst)
