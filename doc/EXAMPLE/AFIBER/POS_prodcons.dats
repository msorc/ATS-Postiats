(* HX-2026-10: afiberchan 3 producers, 2 consumers *)
#include "share/atspre_staload.hats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"
staload "libats/SATS/afiberchan.sats"
staload _ = "libats/DATS/afiberchan.dats"

var the_sum: int = 0
val the_sum_ref = ref_make_viewptr{int}(view@ the_sum | addr@ the_sum)

fun produce (ch: !chan_vt(int)): void = let
  fun loop (ch: !chan_vt(int), i: int): void =
    if i <= 100 then (chan_send<int> (ch, i); loop (ch, i+1))
in loop (ch, 1) end

fun consume (ch: !chan_vt(int)): void =
  case+ chan_recv<int> (ch) of
  | ~Some_vt(x) => (the_sum_ref[] := the_sum_ref[] + x; consume (ch))
  | ~None_vt() => ()

implement main0 () = {
  val ch = chan_make<int> (4)
  val p1 = chan_ref<int> (ch)
  val p2 = chan_ref<int> (ch)
  val p3 = chan_ref<int> (ch)
  val q1 = chan_ref<int> (ch)
  val q2 = chan_ref<int> (ch)
  val () = assertloc (chan_rfcnt (ch) = 6)
  val () = assertloc (chan_capacity (ch) = 4)
  val fp1 = afiber_spawn (llam () => (produce (p1); chan_unref_type<int> (p1)))
  val fp2 = afiber_spawn (llam () => (produce (p2); chan_unref_type<int> (p2)))
  val fp3 = afiber_spawn (llam () => (produce (p3); chan_unref_type<int> (p3)))
  val fq1 = afiber_spawn (llam () => (consume (q1); chan_unref_type<int> (q1)))
  val fq2 = afiber_spawn (llam () => (consume (q2); chan_unref_type<int> (q2)))
  val () = afiber_join (fp1)
  val () = afiber_join (fp2)
  val () = afiber_join (fp3)
  val () = chan_close (ch)
  val () = assertloc (chan_is_closed (ch))
  val () = afiber_join (fq1)
  val () = afiber_join (fq2)
  val () = assertloc (the_sum_ref[] = 3 * 5050)
  val () = assertloc (chan_rfcnt (ch) = 1)
  val () = assertloc (chan_size<int> (ch) = 0)
  val xs = chan_unref<int> (ch)
  val () = assertloc (list_vt_length (xs) = 0)
  val () = list_vt_free (xs)
  val () = afiber_run_until_done ()
  val () = println! ("POS_prodcons: passed")
}
