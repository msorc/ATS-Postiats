#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

var the_r1: lint = 0L
val the_r1_ref = ref_make_viewptr{lint}(view@ the_r1 | addr@ the_r1)
var the_r2: lint = 0L
val the_r2_ref = ref_make_viewptr{lint}(view@ the_r2 | addr@ the_r2)
var the_r3: int = 0
val the_r3_ref = ref_make_viewptr{int}(view@ the_r3 | addr@ the_r3)

fun sum (n: int): lint =
  if n = 0 then 0L else let
    val r = sum (n-1)
  in r + g0int2int_int_lint (n) end

fun loop (n: int, acc: int): int =
  if n = 0 then acc else loop (n-1, acc+1)

implement main0 () = {
  val f1 = afiber_spawn_sz (llam () => the_r1_ref[] := sum (100000), i2sz(8*1024*1024))
  val f2 = afiber_spawn (llam () => the_r2_ref[] := sum (2000))
  val f3 = afiber_spawn (llam () => the_r3_ref[] := loop (1000000, 0))
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = afiber_join (f3)
  val () = assertloc (the_r1_ref[] = 5000050000L)
  val () = assertloc (the_r2_ref[] = 2001000L)
  val () = assertloc (the_r3_ref[] = 1000000)
  val () = println! ("POS_recursion: passed")
}
