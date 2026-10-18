#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun work (i: int): void = let
  val () = the_cnt_ref[] := the_cnt_ref[] + 1
  val () = if i mod 2 = 0 then afiber_yield ()
in end

fun spawn_all (i: int, n: int): void =
  if i < n then let
    val () = afiber_spawn_detached_sz (llam () => work (i), i2sz(16384))
  in spawn_all (i+1, n) end else ()

implement main0 () = {
  val () = spawn_all (0, 10000)
  val () = assertloc (afiber_nlive () = 10000L)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = assertloc (the_cnt_ref[] = 10000)
  val () = println! ("POS_many: passed")
}
