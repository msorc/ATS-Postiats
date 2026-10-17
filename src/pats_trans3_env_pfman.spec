# arenagen specification for the private type of pats_trans3_env_pfman.dats (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_env_pfman.spec > pats_trans3_env_pfman_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_env_pfman.spec > pats_trans3_env_pfman_gen_dats.hats
# An item of the marked list of the proof manager: a stack of [d2vmrk] in a [glist]
# (ATS1: the linear list D2VMRKLSTcons (d2var, _) | D2VMRKLSTmark (knd, _) | D2VMRKLSTnil): [d2vmrk_knd]=0: a variable
# ([d2vmrk_d2v], [d2vmrk_mrk] is 0), =1: a mark ([d2vmrk_mrk] is knd: 0/1: stop/cont, [d2vmrk_d2v] is none).
record d2vmrk (d2vmrk_knd: int, d2vmrk_d2v: d2varopt, d2vmrk_mrk: int)
