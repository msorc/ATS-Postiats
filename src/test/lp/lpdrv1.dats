(*
** The ATS1 driver of the linear constraint solver (the reference), built from
** the sources of $ATS1REF with atscc (see ../Makefile, target lp1_gmp/lp1_int).
** LPKND is defined on the command line of atsopt/atscc: -DATS LPKNDGMP or LPKNDINT
*)
staload UN = "prelude/SATS/unsafe.sats"
staload LOC = "pats_location.sats"
staload INTINF = "pats_intinf.sats"
staload "pats_intinf.sats"
staload _ = "pats_lintprgm.dats"
staload _ = "pats_lintprgm_print.dats"
//
// HX: pats_lintprgm_solve.dats includes the implementation of [intknd] (in a local),
// it must come first: the sats of the solver is loaded again by the files that follow
// and the overload [] of [myintvec_get_at] would be ambiguous in it
//
#include "pats_lintprgm_solve.dats"
#ifdef LPKNDGMP
#include "pats_lintprgm_myint_gmp.dats"
typedef knd = gmpknd
#else
typedef knd = intknd
#endif
//
macdef i2g1 = int1_of_int
macdef i2sz1 = size1_of_int1
//
#include "lpdrv_decls1.hats"
#include "lpdrv_common.hats"
//
dynload "pats_utils.dats"
dynload "pats_intinf.dats"
dynload "pats_lintprgm.dats"
dynload "pats_lintprgm_print.dats"
//
implement
main (argc, argv) = () where {
  val () = assertloc (argc >= 2)
  val () = lpdrv_open (argv.[1])
  val () = run_all ()
} // end of [main]
