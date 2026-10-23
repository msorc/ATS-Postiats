(*
** MS-2026-10: afiber, M:N (step G3')
** three producers and three consumers on 4 workers over a channel of
** capacity 4: the channel is almost always empty or full, so the
** producers and the consumers park often (the hand-off is used). Every
** item must be received exactly once (the count and the sum are
** checked), and the items of each producer must be seen in order
** (FIFO), which is what the ring guarantees.
**)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

#define NPROD 3
#define NCONS 3
#define NITEM 20000
#define CAP 4

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)
var the_sum: llint = 0ll
val the_sum_ref = ref_make_viewptr{llint}(view@ the_sum | addr@ the_sum)
var the_bad: int = 0
val the_bad_ref = ref_make_viewptr{int}(view@ the_bad | addr@ the_bad)

(* ****** ****** *)

// the item of the producer p is p * 1000000 + i (i = 1..NITEM)
fun produce (ch: !chan_vt(int), p: int): void = let
  fun loop (ch: !chan_vt(int), i: int): void =
    if i <= NITEM then let
      val () = chan_send<int> (ch, p * 1000000 + i)
    in loop (ch, i + 1) end
in loop (ch, 1) end

(* ****** ****** *)

// the last item seen of each producer
typedef last_t = @(int, int, int)

fun see (x: int, last: &last_t, cnt: &int, sum: &llint): void = let
  val p = x / 1000000
  val i = x mod 1000000
  val () = cnt := cnt + 1
  val () = sum := sum + $UN.cast{llint}(x)
in
  if p = 1 then (if i <= last.0 then the_bad_ref[] := the_bad_ref[] + 1 else last.0 := i)
  else if p = 2 then (if i <= last.1 then the_bad_ref[] := the_bad_ref[] + 1 else last.1 := i)
  else (if i <= last.2 then the_bad_ref[] := the_bad_ref[] + 1 else last.2 := i)
end

fun consume (ch: !chan_vt(int)): void = let
  var last: last_t = @(0, 0, 0)
  var cnt: int = 0
  var sum: llint = 0ll
  fun loop (ch: !chan_vt(int), last: &last_t, cnt: &int, sum: &llint): void = let
    var x: int
  in
    if
    chan_recv_ref<int> (ch, x)
    then let
      prval () = opt_unsome{int}(x)
    in
      see (x, last, cnt, sum) ; loop (ch, last, cnt, sum)
    end // end of [then]
    else let
      prval () = opt_unnone{int}(x)
      val () = x := 0
    in
      mx_lock () ; the_cnt_ref[] := the_cnt_ref[] + cnt ;
      the_sum_ref[] := the_sum_ref[] + sum ; mx_unlock ()
    end // end of [else]
  end // end of [loop]
  val () = loop (ch, last, cnt, sum)
in end // end of [consume]

(* ****** ****** *)

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f) ; join_all (rest))

fun spawn_prod (ch: !chan_vt(int), p: int, fs: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () => (produce (c, p) ; chan_unref_type<int> (c)))
  in list_vt_cons (f, fs) end

fun spawn_cons (ch: !chan_vt(int), fs: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () => (consume (c) ; chan_unref_type<int> (c)))
  in list_vt_cons (f, fs) end

(* ****** ****** *)

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  //
  val ch = chan_make<int> (CAP)
  val ps = spawn_prod (ch, 1, list_vt_nil ())
  val ps = spawn_prod (ch, 2, ps)
  val ps = spawn_prod (ch, 3, ps)
  val cs = spawn_cons (ch, list_vt_nil ())
  val cs = spawn_cons (ch, cs)
  val cs = spawn_cons (ch, cs)
  val () = join_all (ps)
  val () = chan_close (ch)
  val () = join_all (cs)
  // every item was received exactly once
  val () = assertloc (the_cnt_ref[] = NPROD * NITEM)
  // the sum of the items of the producers 1, 2 and 3
  val per = $UN.cast{llint}(NITEM * (NITEM + 1) / 2)
  val () = assertloc (the_sum_ref[] =
    6ll * $UN.cast{llint}(NITEM) * 1000000ll + 3ll * per)
  // the items of each producer were seen in order
  val () = assertloc (the_bad_ref[] = 0)
  val () = assertloc (chan_size<int> (ch) = 0)
  val () = chan_unref_type<int> (ch)
  //
  val () = afiber_run_until_done ()
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_chan_ring: passed")
}
