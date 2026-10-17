(*
** The ATS2 driver of the linear constraint solver (see ../Makefile, targets lp2_gmp/lp2_int).
** LPKNDGMP is defined on the command line of patsopt/patscc (-DATS LPKNDGMP) for gmp.
*)
#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
staload UN = "prelude/SATS/unsafe.sats"
staload LOC = "../../pats_location.sats"
staload INTINF = "../../pats_intinf.sats"
staload "../../pats_intinf.sats"
staload "../../pats_lintprgm.sats"
staload _ = "../../pats_lintprgm.dats"
staload _ = "../../pats_lintprgm_print.dats"
#ifdef LPKNDGMP
#include "../../pats_lintprgm_myint_gmp.dats"
typedef knd = gmpknd
#else
#include "../../pats_lintprgm_myint_int.dats"
typedef knd = intknd
#endif
#include "../../pats_lintprgm_solve.dats"
//
macdef i2g1 = g1ofg0
macdef i2sz1 = i2sz
//
#include "lpdrv_decls.hats"
#include "lpdrv_common.hats"
//
dynload "../../pats_utils.dats"
dynload "../../pats_intinf.dats"
dynload "../../pats_lintprgm.dats"
//
implement
main0 (argc, argv) = {
  val () = assertloc (argc >= 2)
  val () = lpdrv_open (argv[1])
  val () = run_all ()
} // end of [main0]
