# arenagen specification for SATS/libatsdoc_atext.sats (the atext tree), --global, --compact
# python3 ../utils/arenagen/arenagen.py --global sats libatsdoc_atext.spec > SATS/libatsdoc_atext_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats libatsdoc_atext.spec > DATS/libatsdoc_atext_gen_dats.hats
# (make gen)
#
# [atextlst] is a glist(atext) (the prelude has no nonlinear list)
typedef atextlst = glist(atext)
type atext
  ATEXTnil ()
  ATEXTstrcst (string)
  ATEXTstrsub (string)
  ATEXTapptxt2 (atext, atext)
  ATEXTappstr2 (string, string)
  ATEXTapptxt3 (atext, atext, atext)
  ATEXTappstr3 (string, string, string)
  ATEXTconcatxt (atextlst)
  ATEXTconcatxtsep (atextlst, atext)
