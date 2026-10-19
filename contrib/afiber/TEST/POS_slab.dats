(*
** Stack slab (ATSCNTRB_AFIBER_STACK_SLAB, 32 by default): waves of 3*32+5
** fibers, so that slabs are carved, released to the cache, reused and a
** slab boundary is crossed; a few fibers stay alive across the waves; a
** non-default stack size is mixed in. Under -DATSCNTRB_AFIBER_STACK_CACHE=8
** most stacks are munmap'd one by one out of their slabs.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

#define WAVE (3*32+5)

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun loop (k: int): void =
  if k > 0 then (afiber_yield (); loop (k-1)) else ()

// yields [k] times, counts itself
fun work (k: int): void = let
  val () = loop (k)
  val () = the_cnt_ref[] := the_cnt_ref[] + 1
in end

fun spawn_wave (i: int, n: int, k: int): void =
  if i < n then let
    val () = afiber_spawn_detached (llam () => work (i mod 3 + k))
  in spawn_wave (i+1, n, k) end else ()

fun join_sz (n: int): void =
  if n > 0 then let
    val f = afiber_spawn_sz (llam () => work (1), i2sz(65536))
    val () = afiber_join (f)
  in join_sz (n-1) end else ()

fun waves (w: int, nw: int): void =
  if w < nw then let
    val () = spawn_wave (0, WAVE, 1)
    // 5 fibers that outlive the next wave's start
    val () = spawn_wave (0, 5, 20)
    val () = assertloc (afiber_nlive () >= 5L)
    val () = join_sz (3)
    val () = loop (4)
  in waves (w+1, nw) end else ()

implement main0 () = {
  val () = waves (0, 4)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = assertloc (the_cnt_ref[] = 4 * (WAVE + 5 + 3))
  // once more: the cached stacks are reused
  val () = spawn_wave (0, WAVE, 2)
  val () = afiber_run_until_done ()
  val () = assertloc (the_cnt_ref[] = 4 * (WAVE + 5 + 3) + WAVE)
  val () = println! ("POS_slab: passed")
}
