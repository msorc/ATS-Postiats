#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"

var the_log: int = 0
val the_log_ref = ref_make_viewptr{int}(view@ the_log | addr@ the_log)

fun nap (k: int, ms: int): void = let
  val () = afiber_sleep_msec ($UN.cast{ullint}(ms))
in the_log_ref[] := 10 * the_log_ref[] + k end

implement main0 () = {
  val t0 = afiber_clock_ns ()
  val f1 = afiber_spawn (llam () => nap (1, 30))
  val f2 = afiber_spawn (llam () => nap (2, 10))
  val f3 = afiber_spawn (llam () => nap (3, 20))
  val () = afiber_detach (f1)
  val () = afiber_detach (f2)
  val () = afiber_detach (f3)
  val () = afiber_sleep_ns ($UN.cast{ullint}(0))
  val () = afiber_run_until_done ()
  val t1 = afiber_clock_ns ()
  val () = println! ("log = ", the_log_ref[])
  val () = assertloc (the_log_ref[] = 231)
  val dt = $UN.cast{lint}(t1) - $UN.cast{lint}(t0)
  val () = assertloc (dt >= 30000000L)
  val () = println! ("POS_sleep: passed")
}
