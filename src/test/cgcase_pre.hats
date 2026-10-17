(* the prelude of the chunks of the cases of the codegen2/patcst2 test (ATS2): the prelude of the level-2 dynamic test and the modules under test (see cg_gen.py) *)
#include "d2case_pre.hats"
staload "../pats_stacst2.sats"
staload "../pats_trans2_env.sats"
staload "../pats_codegen2.sats"
staload "../pats_patcst2.sats"
%{^
#include "cgenv.cats"
%}
#include "cgcompat_hand.hats"
#include "cgcompat_gen.hats"
#include "cgcommon.hats"
