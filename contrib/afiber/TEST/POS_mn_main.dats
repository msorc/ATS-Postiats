(*
** MS-2026-10: afiber, M:N
** the main fiber stays on worker 0 across yield, join, sleep, channel
** operations, mutex and run_until_done; other fibers do run on the
** workers 1..3 (some are made to take a while).
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

var the_on0: int = 0
val the_on0_ref = ref_make_viewptr{int}(view@ the_on0 | addr@ the_on0)
var the_other: int = 0
val the_other_ref = ref_make_viewptr{int}(view@ the_other | addr@ the_other)

fun record (): void = let
  val w = afiber_worker_id ()
  val () = assertloc (w >= 0 andalso w < afiber_nworkers ())
  val () = mx_lock ()
  val () = if w = 0 then the_on0_ref[] := the_on0_ref[] + 1 else the_other_ref[] := the_other_ref[] + 1
  val () = mx_unlock ()
in end

fun busy (ms: int): void = let
  val t0 = now_ms ()
  fun loop (): void = if now_ms () - t0 < $UN.cast{lint}(ms) then loop ()
in loop () end

fun body (ch: !chan_vt(int), k: int): void = let
  val () = record ()
  val () = busy (1)
  val () = afiber_yield ()
  val () = record ()
  val () = chan_send<int> (ch, k)
  val () = if k mod 3 = 0 then afiber_sleep_usec ($UN.cast{ullint}(100))
  val () = record ()
in end

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => let
      val () = afiber_join (f)
      val () = assertloc (afiber_worker_id () = 0)
    in join_all (rest) end

fun spawn_all (ch: !chan_vt(int), k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () => (body (c, k); chan_unref_type<int> (c)))
  in spawn_all (ch, k+1, n, list_vt_cons (f, res)) end

fun recv_n (ch: !chan_vt(int), n: int, sum: int): int =
  if n = 0 then sum else let
    val-~Some_vt(x) = chan_recv<int> (ch)
    val () = assertloc (afiber_worker_id () = 0)
  in recv_n (ch, n-1, sum + x) end

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = assertloc (afiber_is_main ())
  val ch = chan_make<int> (4)
  val fs = spawn_all (ch, 0, 48, list_vt_nil ())
  //
  val () = assertloc (afiber_worker_id () = 0)
  val s = recv_n (ch, 48, 0) // 0 + 1 + .. + 47
  val () = assertloc (s = 48 * 47 / 2)
  val () = assertloc (afiber_worker_id () = 0)
  val () = join_all (fs)
  //
  // the others have run on other workers by now
  val () = assertloc (the_other_ref[] > 0)
  val () = assertloc (the_on0_ref[] + the_other_ref[] = 3 * 48)
  //
  fun loop (i: int): void =
    if i < 100 then let
      val () = afiber_yield ()
      val () = assertloc (afiber_worker_id () = 0)
      val () = afiber_sleep_usec ($UN.cast{ullint}(20))
      val () = assertloc (afiber_worker_id () = 0)
      val () = mx_lock ()
      val () = afiber_yield () // yield with the mutex held
      val () = mx_unlock ()
      val () = assertloc (afiber_worker_id () = 0)
    in loop (i+1) end
  // while some fibers still run
  val fs2 = spawn_all (ch, 100, 148, list_vt_nil ())
  val () = loop (0)
  val s2 = recv_n (ch, 48, 0)
  val () = assertloc (s2 = 48 * (100 + 147) / 2)
  val () = join_all (fs2)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_worker_id () = 0)
  val () = chan_unref_type<int> (ch)
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_main: passed")
}
