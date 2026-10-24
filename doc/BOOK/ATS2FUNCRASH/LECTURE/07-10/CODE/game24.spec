# arenagen specification for the expressions of the game of 24
# python3 ../../../../../../utils/arenagen/arenagen.py --global sats game24.spec > game24_gen.hats
# python3 ../../../../../../utils/arenagen/arenagen.py --global dats game24.spec > game24_gen_dats.hats
type expr
  EXPRnum (double)
  EXPRbop (char, expr, expr)
