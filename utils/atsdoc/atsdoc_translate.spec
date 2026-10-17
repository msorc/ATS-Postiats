# arenagen specification for SATS/atsdoc_translate.sats (funarg, tranitm, docerr), --global
# python3 ../arenagen/arenagen.py --global sats atsdoc_translate.spec > SATS/atsdoc_translate_gen.hats
# python3 ../arenagen/arenagen.py --global dats atsdoc_translate.spec > DATS/atsdoc_translate_gen_dats.hats
# (make gen)
#
# [funarglst] is a glist(funarg) (the prelude has no nonlinear list)
typedef funarglst = glist(funarg)
type funarg
  FAint (string)
  FAident (string)
  FAstrsub (string)
  FAfunres (string)
  FAnil ()
type tranitm_node
  EXTCODE (string)
  FUNCALL (string, int, funarglst, string)
type tranitm
  TRANITM (tranitm_loc: location, tranitm_node: tranitm_node)
type docerr
  DOCERR (docerr_loc: location, docerr_node: int)
