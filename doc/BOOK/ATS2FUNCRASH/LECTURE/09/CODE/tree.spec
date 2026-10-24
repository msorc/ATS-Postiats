# arenagen specification for the binary trees of lecture 09
# python3 ../../../../../../utils/arenagen/arenagen.py --global sats tree.spec > tree_gen.hats
# python3 ../../../../../../utils/arenagen/arenagen.py --global dats tree.spec > tree_gen_dats.hats
type tree
  TREEnil ()
  TREEcons (tree, int, tree)
