#include "share/atspre_staload.hats"
staload "../pats_error.sats"
staload _ = "../pats_error.dats"
dynload "../pats_error.dats"
implement main0 () = {
  val () = try abort<void> () with ~FatalErrorExn () => println! ("caught")
  val () = try abort_interr<void> () with ~FatalErrorExn_interr () => println! ("caught2")
  val () = try (if true then $raise PATSOPT_FILENONE_EXN ("foo.dats") else ()) with ~PATSOPT_FILENONE_EXN (s) => println! ("caught ", s)
}
