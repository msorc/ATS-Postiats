(* the prelude of the driver of the constraint-solver test (ATS1): the prelude of the level-3 test and the modules of the solver (see c3_gen.py) *)
#include "t3case_pre1.hats"
staload JSON = "pats_jsonize.sats"
staload "pats_jsonize.sats"
staload "pats_jsonize_synent2.sats"
staload "pats_lintprgm.sats"
//
// the templates of the conversion of s3exp into the constraints of the solver (the kind of the integers: C3NSTRINTKND of pats_params.hats)
//
local
#include "pats_lintprgm_myint.dats"
in (*nothing*) end
staload _(*anon*) = "pats_lintprgm.dats"
staload _(*anon*) = "pats_lintprgm_print.dats"
staload "pats_constraint3.sats"
staload _(*anon*) = "pats_constraint3_icnstr.dats"
#include "pats_params.hats"
#if C3NSTRINTKND="intknd" #then
typedef knd = intknd
#else
typedef knd = gmpknd
#endif
//
#include "c3decls1.hats"
#include "c3glue1_gen.hats"
#include "c3common0.hats"
