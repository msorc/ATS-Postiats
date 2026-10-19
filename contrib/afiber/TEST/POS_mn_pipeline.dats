(*
** MS-2026-10: afiber, M:N (step G)
** a pipeline of 4 stages over channels of capacity 2 on 4 workers:
** a source sends 1..N, every stage adds 1, the sink checks every value
** (order too) and the count. Then [chan_close] while three receivers
** are parked (they must get None_vt), and [chan_trysend] on a full
** channel.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

#define NITEM 100000
#define NSTAGE 4

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)
var the_bad: int = 0
val the_bad_ref = ref_make_viewptr{int}(view@ the_bad | addr@ the_bad)
var the_none: int = 0
val the_none_ref = ref_make_viewptr{int}(view@ the_none | addr@ the_none)

fun add_bad (): void =
  (mx_lock (); the_bad_ref[] := the_bad_ref[] + 1; mx_unlock ())

fun source (out: !chan_vt(int)): void = let
  fun loop (out: !chan_vt(int), i: int): void =
    if i <= NITEM then (chan_send<int> (out, i); loop (out, i+1))
in loop (out, 1); chan_close (out) end

fun stage (inp: !chan_vt(int), out: !chan_vt(int)): void =
  case+ chan_recv<int> (inp) of
  | ~Some_vt(x) => (chan_send<int> (out, x + 1); stage (inp, out))
  | ~None_vt() => chan_close (out)

fun sink (inp: !chan_vt(int), i: int): void =
  case+ chan_recv<int> (inp) of
  | ~Some_vt(x) => let
      val () = if x != i + NSTAGE then add_bad ()
    in sink (inp, i+1) end
  | ~None_vt() => (mx_lock (); the_cnt_ref[] := i - 1; mx_unlock ())

fun waiter (ch: !chan_vt(int)): void =
  case+ chan_recv<int> (ch) of
  | ~Some_vt(_) => add_bad ()
  | ~None_vt() => (mx_lock (); the_none_ref[] := the_none_ref[] + 1; mx_unlock ())

fun spawn_stage (inp: !chan_vt(int), out: !chan_vt(int)): afiber_vt = let
  val a = chan_ref<int> (inp)
  val b = chan_ref<int> (out)
in
  afiber_spawn (llam () => (stage (a, b); chan_unref_type<int> (a); chan_unref_type<int> (b)))
end

fun spawn_waiter (ch: !chan_vt(int)): afiber_vt = let
  val r = chan_ref<int> (ch)
in
  afiber_spawn (llam () => (waiter (r); chan_unref_type<int> (r)))
end

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  //
  val c0 = chan_make<int> (2)
  val c1 = chan_make<int> (2)
  val c2 = chan_make<int> (2)
  val c3 = chan_make<int> (2)
  val c4 = chan_make<int> (2)
  val s1 = spawn_stage (c0, c1)
  val s2 = spawn_stage (c1, c2)
  val s3 = spawn_stage (c2, c3)
  val s4 = spawn_stage (c3, c4)
  val k = chan_ref<int> (c4)
  val fk = afiber_spawn (llam () => (sink (k, 1); chan_unref_type<int> (k)))
  val () = source (c0)
  val () = afiber_join (s1)
  val () = afiber_join (s2)
  val () = afiber_join (s3)
  val () = afiber_join (s4)
  val () = afiber_join (fk)
  val () = assertloc (the_cnt_ref[] = NITEM)
  val () = assertloc (the_bad_ref[] = 0)
  val () = chan_unref_type<int> (c0)
  val () = chan_unref_type<int> (c1)
  val () = chan_unref_type<int> (c2)
  val () = chan_unref_type<int> (c3)
  val () = chan_unref_type<int> (c4)
  //
  // close while receivers are parked
  val ch = chan_make<int> (2)
  val f1 = spawn_waiter (ch)
  val f2 = spawn_waiter (ch)
  val f3 = spawn_waiter (ch)
  val () = sleep_ms (30)
  val () = assertloc (the_none_ref[] = 0)
  val () = chan_close (ch)
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = afiber_join (f3)
  val () = assertloc (the_none_ref[] = 3)
  val () = assertloc (the_bad_ref[] = 0)
  val () = chan_unref_type<int> (ch)
  //
  // trysend on a full channel
  val tc = chan_make<int> (2)
  val () = (case+ chan_trysend<int> (tc, 1) of ~None_vt() => () | ~Some_vt(_) => assertloc (false))
  val () = (case+ chan_trysend<int> (tc, 2) of ~None_vt() => () | ~Some_vt(_) => assertloc (false))
  val () = (case+ chan_trysend<int> (tc, 3) of ~None_vt() => assertloc (false) | ~Some_vt(x) => assertloc (x = 3))
  val () = assertloc (chan_size<int> (tc) = 2)
  val () = (case+ chan_tryrecv<int> (tc) of ~Some_vt(x) => assertloc (x = 1) | ~None_vt() => assertloc (false))
  val () = (case+ chan_trysend<int> (tc, 3) of ~None_vt() => () | ~Some_vt(_) => assertloc (false))
  val () = chan_unref_type<int> (tc)
  //
  val () = afiber_run_until_done ()
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_pipeline: passed")
}
