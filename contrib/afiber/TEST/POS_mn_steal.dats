(*
** MS-2026-10: afiber, M:N
** One fiber spawns 2000 short fibers (each yields a few times and adds 1
** to a total under an [afiber_spin]) and then only joins them. The
** children are queued on the worker of the spawner: the other workers
** must take them (steal from its ring, or from the global FIFO when the
** ring overflowed). The total must be exact and the children must have
** run on at least two workers. Each child waits (yielding) until two
** distinct workers have been seen, so that the test also ends when the
** workers compete for one CPU.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_lk: ptr = the_null_ptr
val the_lk_ref = ref_make_viewptr{ptr}(view@ the_lk | addr@ the_lk)
var the_total: int = 0
val the_total_ref = ref_make_viewptr{int}(view@ the_total | addr@ the_total)
var the_seen: int = 0 // bit i: a child ran on worker i
val the_seen_ref = ref_make_viewptr{int}(view@ the_seen | addr@ the_seen)

fun nbits (x: int): int = if x = 0 then 0 else (x mod 2) + nbits (x / 2)
fun pow2 (k: int): int = if k <= 0 then 1 else 2 * pow2 (k-1)

// returns the number of distinct workers seen so far
fun note (wid: int): int = let
  val lk = $UN.castvwtp1{afiber_spin}(the_lk_ref[])
  val (pf | ()) = afiber_spin_lock (lk)
  val b = pow2 (wid)
  val () = if (the_seen_ref[] / b) mod 2 = 0 then the_seen_ref[] := the_seen_ref[] + b
  val n = nbits (the_seen_ref[])
  val () = afiber_spin_unlock (pf | lk)
  prval () = $UN.cast2void (lk)
in n end

fun bump (): void = let
  val lk = $UN.castvwtp1{afiber_spin}(the_lk_ref[])
  val (pf | ()) = afiber_spin_lock (lk)
  val () = the_total_ref[] := the_total_ref[] + 1
  val () = afiber_spin_unlock (pf | lk)
  prval () = $UN.cast2void (lk)
in end

fun child_wait (t0: ullint): void = let
  val n = note (afiber_worker_id ())
in
  if n >= 2 then ()
  else if afiber_clock_ns () - t0 > $UN.cast{ullint}(10000000000) then ()
  else (afiber_yield (); child_wait (t0))
end

fun child (): void = let
  val () = afiber_yield ()
  val () = child_wait (afiber_clock_ns ())
  val () = afiber_yield ()
  val () = afiber_yield ()
in bump () end

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f); join_all (rest))

fun spawn_n (i: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if i >= n then res else let
    val f = afiber_spawn (llam () => child ())
  in spawn_n (i+1, n, list_vt_cons (f, res)) end

fun spawner (): void = let
  val cs = spawn_n (0, 2000, list_vt_nil ())
in join_all (cs) end

implement main0 () = {
  val () = the_lk_ref[] := $UN.castvwtp0{ptr}(afiber_spin_make ())
  val () = afiber_workers_start (4)
  val () = assertloc (afiber_nworkers () >= 2)
  val f = afiber_spawn (llam () => spawner ())
  val () = afiber_join (f)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_workers_stop ()
  val () = assertloc (the_total_ref[] = 2000)
  val () = assertloc (nbits (the_seen_ref[]) >= 2)
  val () = afiber_spin_free ($UN.castvwtp0{afiber_spin}(the_lk_ref[]))
  val () = println! ("POS_mn_steal: passed")
}
