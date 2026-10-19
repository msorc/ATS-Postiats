(*
** MS-2026-10: afiber, M:N
** 8 fibers (spawned before the workers start, so they are in the global
** FIFO) yield 10000 times each on 4 workers and count under an
** [afiber_mutex]. A yield must let the others run: when the first fiber
** finishes, all 8 must have run once (a yield that put the yielder in
** [runnext] and ran it straight back would let one fiber finish alone
** on its worker). Between two yields a fiber works for about 1.5 us, so
** the other workers (threads) have time to come up. With fewer than 4
** CPUs (the workers compete for them) the check is only that more than
** one fiber has run.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

#define NF 8
#define NY 10000

var the_started: int = 0
val the_started_ref = ref_make_viewptr{int}(view@ the_started | addr@ the_started)
var the_finished: int = 0
val the_finished_ref = ref_make_viewptr{int}(view@ the_finished | addr@ the_finished)
var the_early: int = 0 // fibers that finished while some other fiber had not run yet
val the_early_ref = ref_make_viewptr{int}(view@ the_early | addr@ the_early)
var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun work (ns: ullint): void = let
  val t0 = afiber_clock_ns ()
  fun loop (t0: ullint, ns: ullint): void =
    if afiber_clock_ns () - t0 < ns then loop (t0, ns) else ()
in loop (t0, ns) end

fun loop (k: int): void =
  if k < NY then let
    val () = afiber_yield ()
    val () = work ($UN.cast{ullint}(1500))
    val () = mx_lock ()
    val () = the_cnt_ref[] := the_cnt_ref[] + 1
    val () = mx_unlock ()
  in loop (k+1) end else ()

fun fiber (): void = let
  val () = mx_lock ()
  val () = the_started_ref[] := the_started_ref[] + 1
  val () = mx_unlock ()
  val () = loop (0)
  val () = mx_lock ()
  val ns = the_started_ref[]
  val () = the_finished_ref[] := the_finished_ref[] + 1
  val need = if afiber_ncpu () >= 4 then NF else 2
  val () = if ns < need then the_early_ref[] := the_early_ref[] + 1
  val () = mx_unlock ()
in end

fun spawn_all (i: int): void =
  if i < NF then let
    val () = afiber_spawn_detached (llam () => fiber ())
  in spawn_all (i+1) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = spawn_all (0)
  val () = afiber_workers_start (4)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_workers_stop ()
  val () = assertloc (the_finished_ref[] = NF)
  val () = assertloc (the_cnt_ref[] = NF * NY)
  val () = assertloc (the_early_ref[] = 0)
  val () = mx_fini ()
  val () = println! ("POS_mn_yieldfair: passed")
}
