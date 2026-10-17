# arenagen specification for pats_e1xpval.{sats,dats}: the errors of the evaluator of #define/#if expressions
# python3 ../utils/arenagen/arenagen.py --global sats pats_e1xpval.spec > pats_e1xpval_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_e1xpval.spec > pats_e1xpval_gen_dats.hats
type valerr
  VE_valize (e1xp)
  VE_valize_defined (e1xp)
  VE_valize_undefined (e1xp)
  VE_maxlevel (int, e1xp)
  VE_opr_arglst (e1xp, symbol)
  VE_E1XPide_unbound (e1xp)
  VE_E1XPundef (e1xp)
  VE_E1XPlist (e1xp)
  VE_E1XPapp_fun (e1xp)
  VE_E1XPappid_fun (e1xp, symbol)
  VE_E1XPappid_opr (e1xp, symbol)
  VE_E1XPappid_arity (e1xp, symbol)
  VE_E1XPfun (e1xp)
  VE_E1XPerr (e1xp)
