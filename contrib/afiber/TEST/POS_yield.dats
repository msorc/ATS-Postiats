(*
** MS-2026-10: afiber
** three fibers interleave with [afiber_yield];
** the output order must be deterministic round-robin
*)
#include "share/atspre_staload.hats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

var the_log: int = 0
val the_log_ref = ref_make_viewptr{int}(view@ the_log | addr@ the_log)

fun log (digit: int): void =
  the_log_ref[] := 10 * the_log_ref[] + digit

fun work (k: int): void = let
  val () = log (k)
  val () = afiber_yield ()
  val () = log (k)
  val () = afiber_yield ()
  val () = log (k)
in end

implement main0 () = {
  val () = assertloc (afiber_is_main ())
  val () = assertloc (afiber_self () = 0L)
  val f1 = afiber_spawn (llam () => work (1))
  val f2 = afiber_spawn (llam () => work (2))
  val f3 = afiber_spawn (llam () => work (3))
  val () = assertloc (afiber_nlive () = 3L)
  val () = log (0)
  val () = afiber_yield ()
  val () = log (0)
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = afiber_join (f3)
  val () = assertloc (afiber_nlive () = 0L)
  val () = println! ("log = ", the_log_ref[])
  val () = assertloc (the_log_ref[] = 1230123123)
  val () = afiber_run_until_done ()
  val () = println! ("POS_yield: passed")
}
