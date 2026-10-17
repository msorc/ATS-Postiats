# arenagen specification for pats_taggen.{sats,dats}: the tagged entity (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_taggen.spec > pats_taggen_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_taggen.spec > pats_taggen_gen_dats.hats
record tagent (tagent_sym: symbol, tagent_loc: location)
