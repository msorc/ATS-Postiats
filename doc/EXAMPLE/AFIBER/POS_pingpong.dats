(* HX-2026-10: afiberchan ping-pong over two capacity-1 channels *)
#include "share/atspre_staload.hats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"
staload "libats/SATS/afiberchan.sats"
staload _ = "libats/DATS/afiberchan.dats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

#define N 1000

fun ping (c1: !chan_vt(int), c2: !chan_vt(int)): void = let
  fun loop (c1: !chan_vt(int), c2: !chan_vt(int), k: int): void =
    if k < N then let
      val () = chan_send<int> (c1, k)
      val-~Some_vt(r) = chan_recv<int> (c2)
      val () = assertloc (r = k+1)
      val () = the_cnt_ref[] := the_cnt_ref[] + 1
    in loop (c1, c2, k+1) end
in loop (c1, c2, 0) end

fun pong (c1: !chan_vt(int), c2: !chan_vt(int)): void = let
  fun loop (c1: !chan_vt(int), c2: !chan_vt(int), k: int): void =
    if k < N then let
      val-~Some_vt(x) = chan_recv<int> (c1)
      val () = assertloc (x = k)
      val () = chan_send<int> (c2, x+1)
    in loop (c1, c2, k+1) end
in loop (c1, c2, 0) end

implement main0 () = {
  val c1 = chan_make<int> (1)
  val c2 = chan_make<int> (1)
  val () = assertloc (chan_rfcnt (c1) = 1)
  val a1 = chan_ref<int> (c1)
  val a2 = chan_ref<int> (c2)
  val b1 = chan_ref<int> (c1)
  val b2 = chan_ref<int> (c2)
  val () = assertloc (chan_rfcnt (c1) = 3)
  val () = assertloc (chan_rfcnt (c2) = 3)
  val fa = afiber_spawn (llam () => {
    val () = ping (a1, a2)
    val () = chan_unref_type<int> (a1)
    val () = chan_unref_type<int> (a2)
  })
  val fb = afiber_spawn (llam () => {
    val () = pong (b1, b2)
    val () = chan_unref_type<int> (b1)
    val () = chan_unref_type<int> (b2)
  })
  val () = afiber_join (fa)
  val () = afiber_join (fb)
  val () = assertloc (the_cnt_ref[] = N)
  val () = assertloc (chan_rfcnt (c1) = 1)
  val () = assertloc (chan_rfcnt (c2) = 1)
  val () = assertloc (chan_size<int> (c1) = 0)
  val () = chan_unref_type<int> (c1)
  val () = chan_unref_type<int> (c2)
  val () = afiber_run_until_done ()
  val () = println! ("POS_pingpong: passed")
}
