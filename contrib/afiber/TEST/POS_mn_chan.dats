(*
** MS-2026-10: afiber, M:N
** producers and consumers on 4 workers over channels: ints (sum
** check, close, drain) and linear strptr values. Also tryrecv polling.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
#include "./mn_common.hats"

#define NPROD 4
#define NCONS 3
#define NITEM 2000

var the_sum: int = 0
val the_sum_ref = ref_make_viewptr{int}(view@ the_sum | addr@ the_sum)
var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun add_result (sum: int, cnt: int): void = let
  val () = mx_lock ()
  val () = the_sum_ref[] := the_sum_ref[] + sum
  val () = the_cnt_ref[] := the_cnt_ref[] + cnt
  val () = mx_unlock ()
in end

(* ****** ****** *)

fun produce (ch: !chan_vt(int)): void = let
  fun loop (ch: !chan_vt(int), i: int): void =
    if i <= NITEM then (chan_send<int> (ch, i); loop (ch, i+1))
in loop (ch, 1) end

fun consume (ch: !chan_vt(int), sum: int, cnt: int): void =
  case+ chan_recv<int> (ch) of
  | ~Some_vt(x) => consume (ch, sum + x, cnt + 1)
  | ~None_vt() => add_result (sum, cnt)

// polls with tryrecv, yielding while the channel is empty
fun consume_poll (ch: !chan_vt(int), sum: int, cnt: int): void =
  case+ chan_tryrecv<int> (ch) of
  | ~Some_vt(x) => consume_poll (ch, sum + x, cnt + 1)
  | ~None_vt() =>
      if chan_is_closed (ch) then (
        // closed: drain what is left
        case+ chan_tryrecv<int> (ch) of
        | ~Some_vt(x) => consume_poll (ch, sum + x, cnt + 1)
        | ~None_vt() => add_result (sum, cnt)
      ) else (afiber_yield (); consume_poll (ch, sum, cnt))

(* ****** ****** *)

fun slist_free (xs: List_vt(strptr)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (s, rest) => (strptr_free (s); slist_free (rest))

fun sproduce (ch: !chan_vt(strptr)): void = let
  fun loop (ch: !chan_vt(strptr), i: int): void =
    if i < 300 then let
      val s =
        (case+ i mod 3 of
         | 0 => string0_copy ("a")
         | 1 => string0_copy ("bb")
         | _ => string0_copy ("ccc")) : strptr
      val () = chan_send<strptr> (ch, s)
    in loop (ch, i+1) end
in loop (ch, 0) end

fun sconsume (ch: !chan_vt(strptr), sum: int, cnt: int): void =
  case+ chan_recv<strptr> (ch) of
  | ~Some_vt(s) => let
      val n = g0u2i (string_length ($UN.castvwtp1{string}(s)))
      val () = strptr_free (s)
    in sconsume (ch, sum + n, cnt + 1) end
  | ~None_vt() => add_result (sum, cnt)

(* ****** ****** *)

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f); join_all (rest))

fun spawn_prod (ch: !chan_vt(int), k: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k = 0 then res else let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () => (produce (c); chan_unref_type<int> (c)))
  in spawn_prod (ch, k-1, list_vt_cons (f, res)) end

fun spawn_cons (ch: !chan_vt(int), k: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k = 0 then res else let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () =>
      (if k mod 2 = 0 then consume (c, 0, 0) else consume_poll (c, 0, 0); chan_unref_type<int> (c)))
  in spawn_cons (ch, k-1, list_vt_cons (f, res)) end

fun sspawn_prod (ch: !chan_vt(strptr), k: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k = 0 then res else let
    val c = chan_ref<strptr> (ch)
    val f = afiber_spawn (llam () => let
      val () = sproduce (c)
      val xs = chan_unref<strptr> (c)
    in slist_free (xs) end)
  in sspawn_prod (ch, k-1, list_vt_cons (f, res)) end

fun sspawn_cons (ch: !chan_vt(strptr), k: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k = 0 then res else let
    val c = chan_ref<strptr> (ch)
    val f = afiber_spawn (llam () => let
      val () = sconsume (c, 0, 0)
      val xs = chan_unref<strptr> (c)
    in slist_free (xs) end)
  in sspawn_cons (ch, k-1, list_vt_cons (f, res)) end

(* ****** ****** *)

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  //
  val ch = chan_make<int> (8)
  val ps = spawn_prod (ch, NPROD, list_vt_nil ())
  val cs = spawn_cons (ch, NCONS, list_vt_nil ())
  val () = join_all (ps)
  val () = chan_close (ch)
  val () = join_all (cs)
  val () = assertloc (the_sum_ref[] = NPROD * (NITEM * (NITEM + 1) / 2))
  val () = assertloc (the_cnt_ref[] = NPROD * NITEM)
  val () = assertloc (chan_size<int> (ch) = 0)
  val () = assertloc (chan_rfcnt (ch) = 1)
  val () = chan_unref_type<int> (ch)
  //
  val () = the_sum_ref[] := 0
  val () = the_cnt_ref[] := 0
  val sch = chan_make<strptr> (5)
  val ps = sspawn_prod (sch, NPROD, list_vt_nil ())
  val cs = sspawn_cons (sch, NCONS, list_vt_nil ())
  val () = join_all (ps)
  val () = chan_close (sch)
  val () = join_all (cs)
  // 300 strings per producer, of lengths 1, 2, 3 in turn
  val () = assertloc (the_cnt_ref[] = NPROD * 300)
  val () = assertloc (the_sum_ref[] = NPROD * 600)
  val xs = chan_unref<strptr> (sch)
  val () = assertloc (list_vt_length (xs) = 0)
  val () = slist_free (xs)
  //
  val () = afiber_run_until_done ()
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_chan: passed")
}
