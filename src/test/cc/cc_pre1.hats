(* the prelude of the chunks of the cases of the ccomp test (ATS1): see cc_pre.hats *)
#include "hdcase_pre1.hats"
typedef hfunlab = funlab
typedef hinstrlst = instrlst
staload "pats_ccomp.sats"
typedef instrlst = List (instr)   (* a typedef of the file (hd_hand_a1.hats: the placeholder) wins over the staloaded one in ATS1 *)
#include "cc_hand1.hats"
#include "cc_compat1.hats"
#include "cc_hand3_1.hats"
