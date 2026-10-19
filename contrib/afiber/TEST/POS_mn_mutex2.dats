(*
** MS-2026-10: afiber, M:N
** Regression test for a lost wake-up in the parking mutex: two fibers
** on two workers lock/increment/unlock 200000 times each, so that they
** contend as often as possible. A waiter that looked at [locked] before
** announcing itself in [nwait] could park on a mutex just freed by an
** unlocker that had read nwait == 0; with so few fibers nobody woke it
** and the program died with "deadlock: every fiber is blocked".
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun work (k: int): void =
  if k < 200000 then let
    val () = mx_lock ()
    val () = the_cnt_ref[] := the_cnt_ref[] + 1
    val () = mx_unlock ()
  in work (k+1) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (2)
  val () = assertloc (afiber_nworkers () >= 2)
  val f1 = afiber_spawn (llam () => work (0))
  val f2 = afiber_spawn (llam () => work (0))
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = afiber_workers_stop ()
  val () = assertloc (the_cnt_ref[] = 2 * 200000)
  val () = mx_fini ()
  val () = println! ("POS_mn_mutex2: passed")
}
