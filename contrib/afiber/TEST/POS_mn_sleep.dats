(*
** MS-2026-10: afiber, M:N
** many fibers sleep on 4 workers: the global wake order follows the
** durations (they differ by 30 ms), every fiber sleeps at least as
** long as asked, and the whole run is not much longer than the longest.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_last: int = 0
val the_last_ref = ref_make_viewptr{int}(view@ the_last | addr@ the_last)
var the_woken: int = 0
val the_woken_ref = ref_make_viewptr{int}(view@ the_woken | addr@ the_woken)

// phase A: one sleep of (k mod 8 + 1) * 30 ms
fun nap_a (k: int): void = let
  val d = (k mod 8 + 1) * 30
  val t0 = now_ms ()
  val () = sleep_ms (d)
  val t1 = now_ms ()
  val () = assertloc (t1 - t0 >= $UN.cast{lint}(d))
  val () = mx_lock ()
  val () = assertloc (d >= the_last_ref[]) // woken in order of the durations
  val () = the_last_ref[] := d
  val () = the_woken_ref[] := the_woken_ref[] + 1
  val () = mx_unlock ()
in end

// phase B: three short sleeps in a row, each at least as long as asked
fun nap_b (k: int): void = let
  fun loop (j: int): void =
    if j < 3 then let
      val d = 2 + (k + j) mod 5
      val t0 = now_ms ()
      val () = sleep_ms (d)
      val t1 = now_ms ()
      val () = assertloc (t1 - t0 >= $UN.cast{lint}(d))
    in loop (j+1) end
  val () = loop (0)
  val () = mx_lock ()
  val () = the_woken_ref[] := the_woken_ref[] + 1
  val () = mx_unlock ()
in end

fun spawn_a (k: int, n: int): void =
  if k < n then (afiber_spawn_detached (llam () => nap_a (k)); spawn_a (k+1, n)) else ()
fun spawn_b (k: int, n: int): void =
  if k < n then (afiber_spawn_detached (llam () => nap_b (k)); spawn_b (k+1, n)) else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val t0 = now_ms ()
  val () = spawn_a (0, 64)
  val () = afiber_run_until_done ()
  val dt = now_ms () - t0
  val () = assertloc (the_woken_ref[] = 64)
  val () = assertloc (dt >= 240L)
  val () = assertloc (dt < 3000L)
  //
  val () = the_woken_ref[] := 0
  val () = spawn_b (0, 64)
  val () = afiber_run_until_done ()
  val () = assertloc (the_woken_ref[] = 64)
  //
  // main sleeps while the workers are idle
  val t1 = now_ms ()
  val () = sleep_ms (20)
  val () = assertloc (now_ms () - t1 >= 20L)
  val () = assertloc (afiber_worker_id () = 0)
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_sleep: passed")
}
