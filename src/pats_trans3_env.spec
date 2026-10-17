# arenagen specification for pats_trans3_env.sats: the constraints of the level-3 translation (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_trans3_env.spec > pats_trans3_env_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans3_env.spec > pats_trans3_env_gen_dats.hats
#
# Same conventions as pats_dynexp2.spec (PORTING.md, "Type-checking environment (trans3_env)").
# The ATS1 [ref (c3nstropt)] of [c3nstroptref] is the [mut] field [c3nstroptref_val] (as [d2varlstref]).
# [lamlp] (the loop/lambda marker of the environment) and [lstbefitm] (a saved linear variable) are public.
typedef s3itmlst = glist(s3itm)
vtypedef s3itmlst_vt = List0_vt(s3itm)
typedef s3itmlstlst = glist(s3itmlst)
typedef c3nstropt = gopt(c3nstr)
typedef lstbefitmlst = glist(lstbefitm)
typedef lamlplst = glist(lamlp)
type c3nstrkind
  C3TKmain ()
  C3TKcase_exhaustiveness (caskind, p2atcstlst)
  C3TKtermet_isnat ()
  C3TKtermet_isdec ()
  C3TKsome_fin (d2var, s2exp, s2exp)
  C3TKsome_lvar (d2var, s2exp, s2exp)
  C3TKsome_vbox (d2var, s2exp, s2exp)
  C3TKlstate ()
  C3TKlstate_var (d2var)
  C3TKloop (int)
  C3TKsolverify ()
type s3itm
  S3ITMsvar (s2var)
  S3ITMhypo (h3ypo)
  S3ITMsVar (s2Var)
  S3ITMcnstr (c3nstr)
  S3ITMcnstr_ref (c3nstroptref)
  S3ITMdisj (s3itmlstlst)
  S3ITMsolassert (s2exp)
type c3nstr_node
  C3NSTRprop (s2exp)
  C3NSTRitmlst (s3itmlst)
  C3NSTRsolverify (s2exp)
type h3ypo_node
  H3YPOprop (s2exp)
  H3YPObind (s2var, s2exp)
  H3YPOeqeq (s2exp, s2exp)
record c3nstr (c3nstr_loc: location, c3nstr_kind: c3nstrkind, c3nstr_node: c3nstr_node)
record c3nstroptref (c3nstroptref_loc: location, mut c3nstroptref_val: c3nstropt)
record h3ypo (h3ypo_loc: location, h3ypo_node: h3ypo_node)
record lstbefitm (lstbefitm_var: d2var, lstbefitm_linval: int, lstbefitm_type: s2expopt)
type lamlp
  LAMLPlam (p3atlst)
  LAMLPloop0 ()
  LAMLPloop1 (loopi2nv, lstbefitmlst, d2expopt)
