(*
** MS-2026-10: afiber, M:N (steps J and G2)
** the batch API on 4 workers: two producers send lists of numbered
** items (item = producer * 1000000 + i) into a channel of capacity 16,
** three consumers use [chan_recv_batch] (batch sizes 1..9) and one
** uses [chan_recv_ref]. Every consumer must see the items of each
** producer in increasing order (FIFO), and together they get every item
** exactly once (count and sum).
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

#define NITEM 20000

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)
var the_sum: llint = 0ll
val the_sum_ref = ref_make_viewptr{llint}(view@ the_sum | addr@ the_sum)
var the_bad: int = 0
val the_bad_ref = ref_make_viewptr{int}(view@ the_bad | addr@ the_bad)

fun mklist (p: int, i: int, j: int): List0_vt(int) =
  if i > j then list_vt_nil() else list_vt_cons(p * 1000000 + i, mklist (p, i+1, j))

fun producer (ch: !chan_vt(int), p: int): void = let
  // lists of 100 items
  fun loop (ch: !chan_vt(int), i: int): void =
    if i <= NITEM then let
      val rest = chan_send_list<int> (ch, mklist (p, i, i + 99))
      val () = if list_vt_length (rest) > 0 then (mx_lock (); the_bad_ref[] := the_bad_ref[] + 1; mx_unlock ())
      val () = list_vt_free (rest)
    in loop (ch, i + 100) end
in loop (ch, 1) end

// last.(p): the last item seen of producer p (p = 1, 2)
typedef last_t = @(int, int)

fun see (x: int, last: &last_t, cnt: &int, sum: &llint): void = let
  val p = x / 1000000
  val i = x mod 1000000
  val () = cnt := cnt + 1
  val () = sum := sum + $UN.cast{llint}(x)
in
  if p = 1 then (if i <= last.0 then the_bad_ref[] := the_bad_ref[] + 1 else last.0 := i)
  else (if i <= last.1 then the_bad_ref[] := the_bad_ref[] + 1 else last.1 := i)
end

fun see_list (xs: List0_vt(int), last: &last_t, cnt: &int, sum: &llint): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (x, xs1) => (see (x, last, cnt, sum); see_list (xs1, last, cnt, sum))

fun finish (cnt: int, sum: llint): void =
  (mx_lock (); the_cnt_ref[] := the_cnt_ref[] + cnt; the_sum_ref[] := the_sum_ref[] + sum; mx_unlock ())

fun bconsumer (ch: !chan_vt(int), k0: intGt(0)): void = let
  var last: last_t = @(0, 0)
  var cnt: int = 0
  var sum: llint = 0ll
  fun loop (ch: !chan_vt(int), k: intGt(0), last: &last_t, cnt: &int, sum: &llint): void = let
    val xs = chan_recv_batch<int> (ch, k)
    val n = list_vt_length (xs)
  in
    if n = 0 then list_vt_free (xs)
    else (see_list (xs, last, cnt, sum); loop (ch, (if k >= 9 then 1 else k+1), last, cnt, sum))
  end
  val () = loop (ch, k0, last, cnt, sum)
in finish (cnt, sum) end

fun rconsumer (ch: !chan_vt(int)): void = let
  var last: last_t = @(0, 0)
  var cnt: int = 0
  var sum: llint = 0ll
  fun loop (ch: !chan_vt(int), last: &last_t, cnt: &int, sum: &llint): void = let
    var x: int
  in
    if chan_recv_ref<int> (ch, x)
    then let
      prval () = opt_unsome{int}(x)
    in see (x, last, cnt, sum); loop (ch, last, cnt, sum) end
    else let
      prval () = opt_unnone{int}(x)
      val () = x := 0
    in end
  end
  val () = loop (ch, last, cnt, sum)
in finish (cnt, sum) end

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  //
  val ch = chan_make<int> (16)
  val p1 = chan_ref<int> (ch)
  val p2 = chan_ref<int> (ch)
  val c1 = chan_ref<int> (ch)
  val c2 = chan_ref<int> (ch)
  val c3 = chan_ref<int> (ch)
  val c4 = chan_ref<int> (ch)
  val f1 = afiber_spawn (llam () => (producer (p1, 1); chan_unref_type<int> (p1)))
  val f2 = afiber_spawn (llam () => (producer (p2, 2); chan_unref_type<int> (p2)))
  val g1 = afiber_spawn (llam () => (bconsumer (c1, 1); chan_unref_type<int> (c1)))
  val g2 = afiber_spawn (llam () => (bconsumer (c2, 4); chan_unref_type<int> (c2)))
  val g3 = afiber_spawn (llam () => (bconsumer (c3, 9); chan_unref_type<int> (c3)))
  val g4 = afiber_spawn (llam () => (rconsumer (c4); chan_unref_type<int> (c4)))
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = chan_close (ch)
  val () = afiber_join (g1)
  val () = afiber_join (g2)
  val () = afiber_join (g3)
  val () = afiber_join (g4)
  val () = assertloc (the_bad_ref[] = 0)
  val () = assertloc (the_cnt_ref[] = 2 * NITEM)
  // sum of 1..NITEM = NITEM * (NITEM + 1) / 2 for each producer
  val s = $UN.cast{llint}(NITEM) * $UN.cast{llint}(NITEM + 1) / 2ll
  val () = assertloc (the_sum_ref[] = 2ll * s + 3ll * 1000000ll * $UN.cast{llint}(NITEM))
  val xs = chan_unref<int> (ch)
  val () = assertloc (list_vt_length (xs) = 0)
  val () = list_vt_free (xs)
  //
  val () = afiber_run_until_done ()
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_batch: passed")
}
