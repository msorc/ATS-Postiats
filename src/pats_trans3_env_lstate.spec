# arenagen specification for the private types of pats_trans3_env_lstate.dats (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_env_lstate.spec > pats_trans3_env_lstate_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_env_lstate.spec > pats_trans3_env_lstate_gen_dats.hats
# [lstaftitm]: the ATS1 flat record @{lstaftitm_var, lstaftitm_knd (0/1/2: skip/merge/sub+merge), lstaftitm_type, lstaftitm_saits};
# [lstaftc3nstr_rec]: the ATS1 dataviewtype LSTAFTC3NSTR (lstaftitmlst, List_vt (c3nstroptref)) (the [lstaftc3nstr] of the sats
# is a linear handle of such a record). The items are mutated in place, as in ATS1: [mut] fields.
typedef lstaftitmlst = glist(lstaftitm)
typedef c3nstroptreflst = glist(c3nstroptref)
typedef saityplst = glist(s2expopt)
record lstaftitm (lstaftitm_var: d2var, mut lstaftitm_knd: int, mut lstaftitm_type: s2expopt, mut lstaftitm_saits: saityplst)
record lstaftc3nstr_rec (mut lstaftc3nstr_rec_lsais: lstaftitmlst, mut lstaftc3nstr_rec_ctrs: c3nstroptreflst)
