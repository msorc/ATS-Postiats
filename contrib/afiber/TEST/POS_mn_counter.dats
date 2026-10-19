(*
** MS-2026-10: afiber, M:N
** 200 fibers on 4 workers increment a shared counter 1000 times each
** under an [afiber_mutex]; some yield while holding it (the others
** park on the mutex). The total must be exact.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun bump (k: int): void = let
  val () = mx_lock ()
  val c = the_cnt_ref[]
  val () = if k mod 97 = 96 then afiber_yield () // a read-modify-write across a yield
  val () = the_cnt_ref[] := c + 1
  val () = mx_unlock ()
in end

fun work (k: int): void =
  if k < 1000 then let
    val () = bump (k)
    val () = if k mod 64 = 0 then afiber_yield ()
  in work (k+1) end else ()

fun spawn_all (i: int, n: int): void =
  if i < n then let
    val () = afiber_spawn_detached (llam () => work (0))
  in spawn_all (i+1, n) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = assertloc (afiber_nworkers () >= 2)
  val () = assertloc (afiber_worker_id () = 0)
  val () = spawn_all (0, 200)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_workers_stop ()
  val () = assertloc (afiber_nworkers () = 1)
  val () = assertloc (the_cnt_ref[] = 200 * 1000)
  val () = mx_fini ()
  val () = println! ("POS_mn_counter: passed")
}
