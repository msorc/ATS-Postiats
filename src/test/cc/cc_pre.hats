(* the prelude of the chunks of the cases of the ccomp test (ATS2): the prelude of the hd test, then pats_ccomp.sats (see cc_gen.py) *)
#include "hdcase_pre.hats"
typedef hfunlab = funlab
typedef hinstrlst = instrlst   (* the placeholder of pats_histaexp.sats: the real [funlab] of pats_ccomp.sats follows *)
staload "../pats_ccomp.sats"
staload _ = "../pats_ccomp_tmpvar.dats"
#include "cc_hand2.hats"
#include "cc_compat2.hats"
#include "cc_hand3_2.hats"
