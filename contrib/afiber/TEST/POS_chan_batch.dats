(*
** MS-2026-10: afiberchan, steps J and G2: the non-allocating receives
** and the batches. FIFO order across batches and single operations
** mixed; a producer that sends a long list into a small channel (it
** parks in the middle) against a batch consumer; [chan_close] while a
** batch receiver and a [chan_recv_ref] receiver are parked; a list sent
** to a closed channel comes back.
*)
#include "share/atspre_staload.hats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"

#define N 1000

var the_bad: int = 0
val the_bad_ref = ref_make_viewptr{int}(view@ the_bad | addr@ the_bad)
var the_got: int = 0
val the_got_ref = ref_make_viewptr{int}(view@ the_got | addr@ the_got)

fun mklist (i: int, j: int): List0_vt(int) =
  if i > j then list_vt_nil() else list_vt_cons(i, mklist (i+1, j))

// the list must be i, i+1, ...: returns the next expected number
fun check (xs: List0_vt(int), i: int): int =
  case+ xs of
  | ~list_vt_nil() => i
  | ~list_vt_cons(x, xs1) =>
    (if x != i then the_bad_ref[] := the_bad_ref[] + 1; check (xs1, i+1))

// -1: none
fun rr (ch: !chan_vt(int)): int = let
  var x: int
in
  if chan_recv_ref<int> (ch, x)
  then let prval () = opt_unsome{int}(x) in x end
  else let prval () = opt_unnone{int}(x); val () = x := 0 in ~1 end
end

fun tr (ch: !chan_vt(int)): int = let
  var x: int
in
  if chan_tryrecv_ref<int> (ch, x)
  then let prval () = opt_unsome{int}(x) in x end
  else let prval () = opt_unnone{int}(x); val () = x := 0 in ~1 end
end

fun producer (ch: !chan_vt(int)): void = let
  val rest = chan_send_list<int> (ch, mklist (1, N))
  val () = assertloc (list_vt_length (rest) = 0)
  val () = list_vt_free (rest)
in chan_close (ch) end

fun consumer (ch: !chan_vt(int), next: int, k: intGt(0)): void = let
  val xs = chan_recv_batch<int> (ch, k)
  val n = list_vt_length (xs)
in
  if n = 0 then let
    val () = list_vt_free (xs)
  in the_got_ref[] := next - 1 end
  else let
    val () = assertloc (n <= k)
    val next1 = check (xs, next)
  in consumer (ch, next1, if k >= 7 then 1 else k+1) end
end

implement main0 () = {
  //
  // mixed single and batch operations, in order
  //
  val ch = chan_make<int> (8)
  val rest = chan_send_list<int> (ch, mklist (1, 5))
  val () = list_vt_free (rest)
  val () = chan_send<int> (ch, 6)
  val () = assertloc (chan_size<int> (ch) = 6)
  val xs = chan_recv_batch<int> (ch, 3)
  val () = assertloc (check (xs, 1) = 4)
  val () = assertloc (rr (ch) = 4)
  val () = assertloc (tr (ch) = 5)
  val xs = chan_recv_batch<int> (ch, 10)
  val () = assertloc (check (xs, 6) = 7)
  val () = assertloc (tr (ch) = ~1)
  val () = assertloc (chan_size<int> (ch) = 0)
  val () = assertloc (the_bad_ref[] = 0)
  //
  // a producer that parks in the middle of a list, a batch consumer
  //
  val ch2 = chan_make<int> (7)
  val p = chan_ref<int> (ch2)
  val q = chan_ref<int> (ch2)
  val fp = afiber_spawn (llam () => (producer (p); chan_unref_type<int> (p)))
  val fq = afiber_spawn (llam () => (consumer (q, 1, 1); chan_unref_type<int> (q)))
  val () = afiber_join (fp)
  val () = afiber_join (fq)
  val () = assertloc (the_got_ref[] = N)
  val () = assertloc (the_bad_ref[] = 0)
  val () = chan_unref_type<int> (ch2)
  //
  // close while a batch receiver and a [chan_recv_ref] receiver are parked
  //
  val ch3 = chan_make<int> (2)
  val r1 = chan_ref<int> (ch3)
  val r2 = chan_ref<int> (ch3)
  val f1 = afiber_spawn (llam () => let
      val xs = chan_recv_batch<int> (r1, 4)
      val () = assertloc (list_vt_length (xs) = 0)
      val () = list_vt_free (xs)
    in chan_unref_type<int> (r1) end)
  val f2 = afiber_spawn (llam () => let
      val () = assertloc (rr (r2) = ~1)
    in chan_unref_type<int> (r2) end)
  val () = afiber_yield ()
  val () = afiber_yield ()
  val () = chan_close (ch3)
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  //
  // a list sent to a closed channel comes back whole
  //
  val rest = chan_send_list<int> (ch3, mklist (1, 3))
  val () = assertloc (check (rest, 1) = 4)
  val () = assertloc (the_bad_ref[] = 0)
  val xs = chan_unref<int> (ch3)
  val () = list_vt_free (xs)
  //
  val xs = chan_unref<int> (ch)
  val () = list_vt_free (xs)
  val () = afiber_run_until_done ()
  val () = println! ("POS_chan_batch: passed")
}
