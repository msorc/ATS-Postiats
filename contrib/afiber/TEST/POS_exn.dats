#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

exception E1 of (int)
exception E2 of (int)
exception E3 of (int)

var the_log: int = 0
val the_log_ref = ref_make_viewptr{int}(view@ the_log | addr@ the_log)
fun log (d: int): void = the_log_ref[] := 10 * the_log_ref[] + d

var the_seen: int = 0
val the_seen_ref = ref_make_viewptr{int}(view@ the_seen | addr@ the_seen)

fun raise1n (n: int): void = $raise E1(n)
fun raise1 (): void = raise1n (1)
fun raise2 (): void = $raise E2(2)
fun raise3 (): void = $raise E3(42)

fun ba (): void = let
  val () = afiber_yield ()
  val () = log (3) // A resumed
in raise1 () end

fun bb (): void = let
  val () = afiber_yield ()
  val () = log (4) // B resumed
in raise2 () end

fun fa (): void = let
  val () = log (1) // A try-enter
  val () = try ba () with ~E1(n) => (log (5); the_seen_ref[] := the_seen_ref[] + n)
in end

fun fb (): void = let
  val () = log (2) // B try-enter
  val () = try bb () with ~E2(n) => (log (6); the_seen_ref[] := the_seen_ref[] + 10 * n)
in end

fun deep (d: int): void =
  if d = 0 then raise3 ()
  else let
    val () = afiber_yield ()
    val () = deep (d-1)
  in () end

fun nested (): void = let
  val () = try deep (10) with ~E3(n) => the_seen_ref[] := the_seen_ref[] + 100 * (n - 41)
in end

implement main0 () = {
  val f1 = afiber_spawn (llam () => fa ())
  val f2 = afiber_spawn (llam () => fb ())
  val f3 = afiber_spawn (llam () => nested ())
  val () = afiber_join (f1)
  val () = afiber_join (f2)
  val () = afiber_join (f3)
  val () = assertloc (the_log_ref[] = 123546)
  val () = assertloc (the_seen_ref[] = 1 + 20 + 100)
  val () = try raise1n (3) with ~E1(n) => the_seen_ref[] := n
  val () = assertloc (the_seen_ref[] = 3)
  val () = println! ("POS_exn: passed")
}
