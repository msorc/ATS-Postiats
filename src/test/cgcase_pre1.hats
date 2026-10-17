(* the prelude of the chunks of the cases of the codegen2/patcst2 test (ATS1): see cgcase_pre.hats *)
#include "d2case_pre1.hats"
staload "pats_stacst2.sats"
staload "pats_trans2_env.sats"
staload "pats_codegen2.sats"
staload "pats_patcst2.sats"
%{^
#include "cgenv.cats"
%}
#include "cgcompat1_hand.hats"
#include "cgcompat1_gen.hats"
#include "cgcommon.hats"
