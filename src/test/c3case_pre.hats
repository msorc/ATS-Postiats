(* the prelude of the driver of the constraint-solver test (ATS2): the prelude of the level-3 test and the modules of the solver (see c3_gen.py) *)
#include "t3case_pre.hats"
staload JSON = "../pats_jsonize.sats"
staload "../pats_jsonize.sats"
staload "../pats_jsonize_synent2.sats"
staload "../pats_lintprgm.sats"
//
// the templates of the conversion of s3exp into the constraints of the solver (the kind of the integers: C3NSTRINTKND of pats_params.hats);
// the [s3exp] of pats_constraint3.sats must be the last one defined (staloading a .dats opens the .sats that it staloads)
//
staload _(*anon*) = "../pats_lintprgm.dats"
staload _(*anon*) = "../pats_lintprgm_print.dats"
#include "../pats_lintprgm_myint.dats"
staload "../pats_constraint3.sats"
staload "../pats_errmsg.sats"
staload _(*anon*) = "../pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_constraint3_icnstr"
staload _(*anon*) = "../pats_constraint3_icnstr.dats"
#include "../pats_params.hats"
#if C3NSTRINTKND="intknd" #then
typedef knd = intknd
#else
typedef knd = gmpknd
#endif
//
#include "c3decls.hats"
#include "c3glue_gen.hats"
#include "c3common0.hats"
