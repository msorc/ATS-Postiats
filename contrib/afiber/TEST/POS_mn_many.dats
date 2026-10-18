(*
** MS-2026-10: afiber, M:N
** 100000 detached fibers on 4 workers (spawned in batches, so that
** the number of live stacks stays below the kernel's mapping limit),
** then [afiber_run_until_done] and [afiber_workers_stop].
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun work (i: int): void = let
  val () = if i mod 4 = 0 then afiber_yield ()
  val () = mx_lock ()
  val () = the_cnt_ref[] := the_cnt_ref[] + 1
  val () = mx_unlock ()
in end

fun spawn_all (i: int, n: int): void =
  if i < n then let
    val () = afiber_spawn_detached_sz (llam () => work (i), i2sz(16384))
    // keep fewer than 5000 fibers alive
    val () = if afiber_nlive () > 5000L then afiber_sleep_usec ($UN.cast{ullint}(200))
  in spawn_all (i+1, n) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = spawn_all (0, 100000)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_workers_stop ()
  val () = assertloc (the_cnt_ref[] = 100000)
  val () = mx_fini ()
  val () = println! ("POS_mn_many: passed")
}
