(*
** MS-2026-10: afiber, M:N
** The parking mutex (Go's woken/starving state machine) under heavy
** contention: 32 fibers on 4 workers lock/increment/unlock 50000 times
** each, every 1000th time yielding inside the critical section; 2 of
** the fibers also hold the mutex for 2 ms once (sleeping inside), so
** that the waiters wait more than 1 ms: the starving mode is entered
** (FIFO hand-off) and left again. Checks the count, and that no fiber
** waited for the mutex more than 2 s.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

#define NFIBER 32
#define NITER 50000

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)
var the_maxwait: lint = 0L
val the_maxwait_ref = ref_make_viewptr{lint}(view@ the_maxwait | addr@ the_maxwait)

fun work (id: int, k: int): void =
  if k < NITER then let
    val t0 = afiber_clock_ns ()
    val () = mx_lock ()
    val w = $UN.cast{lint}((afiber_clock_ns () - t0) / $UN.cast{ullint}(1000))
    val () = if w > the_maxwait_ref[] then the_maxwait_ref[] := w
    val () = the_cnt_ref[] := the_cnt_ref[] + 1
    val () = if k mod 1000 = 999 then afiber_yield ()
    val () = if id < 2 && k = 100 * (id + 1) then sleep_ms (2)
    val () = mx_unlock ()
  in work (id, k+1) end else ()

fun spawn_all (i: int): void =
  if i < NFIBER then let
    val () = afiber_spawn_detached (llam () => work (i, 0))
  in spawn_all (i+1) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = assertloc (afiber_nworkers () >= 2)
  val t0 = afiber_clock_ns ()
  val () = spawn_all (0)
  val () = afiber_run_until_done ()
  val () = afiber_workers_stop ()
  val () = assertloc (the_cnt_ref[] = NFIBER * NITER)
  val () = assertloc (the_maxwait_ref[] < 2000000)
  val () = mx_fini ()
  val () = println! ("POS_mn_mutex32: passed (max wait ", the_maxwait_ref[] / 1000L, " ms, ",
    (afiber_clock_ns () - t0) / $UN.cast{ullint}(1000000), " ms)")
}
