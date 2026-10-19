(*
** MS-2026-10: afiber, M:N, step H
** main waits for fibers that run on the other workers: worker 0 keeps
** looking for work (a bounded spin) instead of sleeping. 2000 fibers in
** batches of 100, joined one by one; then main sleeps 50 ms with the
** workers idle (worker 0 must really sleep: the wall time is checked,
** and the CPU time is visible with [time]); then main waits 20 ms on a
** channel for a fiber that sleeps before it sends (the bounded spin ends,
** the condition variable wakes main).
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

var the_sum: int = 0
val the_sum_ref = ref_make_viewptr{int}(view@ the_sum | addr@ the_sum)

fun work (k: int): void = let
  fun loop (j: int): void = if j > 0 then (afiber_yield (); loop (j-1))
  val () = loop (k mod 4)
  val () = mx_lock ()
  val () = the_sum_ref[] := the_sum_ref[] + 1
  val () = mx_unlock ()
in end

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f); join_all (rest))

fun spawn_batch (k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val f = afiber_spawn (llam () => work (k))
  in spawn_batch (k+1, n, list_vt_cons (f, res)) end

fun batches (b: int): void =
  if b > 0 then (join_all (spawn_batch (0, 100, list_vt_nil ())); batches (b-1))

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  //
  val () = batches (20)
  val () = assertloc (the_sum_ref[] = 2000)
  //
  val t0 = now_ms ()
  val () = afiber_sleep_msec ($UN.cast{ullint}(50))
  val dt = now_ms () - t0
  val () = assertloc (dt >= 50L)
  val () = assertloc (dt < 500L)
  //
  val ch = chan_make<int> (1)
  val c = chan_ref<int> (ch)
  val f = afiber_spawn (llam () => let
    val () = afiber_sleep_msec ($UN.cast{ullint}(20))
    val () = chan_send<int> (c, 42)
  in chan_unref_type<int> (c) end)
  val t1 = now_ms ()
  val () =
    (case+ chan_recv<int> (ch) of
     | ~Some_vt(x) => assertloc (x = 42)
     | ~None_vt() => assertloc (false))
  val dt = now_ms () - t1
  val () = assertloc (dt >= 20L)
  val () = assertloc (dt < 500L)
  val () = afiber_join (f)
  val () = chan_unref_type<int> (ch)
  //
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_mainwait: passed")
}
