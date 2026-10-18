(*
** MS-2026-10: afiber, M:N
** exceptions raised and caught by fibers that yield and sleep inside
** their [try] blocks, so they migrate between workers while a handler
** frame is live. Each catch must get its own exception.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

exception E1 of (int)
exception E2 of (int)

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun count (): void = let
  val () = mx_lock ()
  val () = the_cnt_ref[] := the_cnt_ref[] + 1
  val () = mx_unlock ()
in end

fun pause (k: int): void =
  case+ k mod 4 of
  | 0 => afiber_yield ()
  | 1 => afiber_sleep_usec ($UN.cast{ullint}(100))
  | 2 => (afiber_yield (); afiber_yield ())
  | _ => ()

fun raise1 (v: int): void = $raise E1(v)
fun raise2 (v: int): void = $raise E2(v)

fun raiser (v: int, k: int): void = let
  val () = pause (k)
in raise1 (v) end

fun deep (d: int, v: int, k: int): void =
  if d = 0 then raiser (v, k)
  else let
    val () = pause (k + d)
    val () = deep (d-1, v, k)
  in () end

fun one (id: int, i: int): void = let
  val v = id * 1000 + i
  // inner handler catches E1, yields, then raises E2 for the outer one
  val () =
    try (
      try deep (3, v, i) with ~E1(x) => let
        val () = assertloc (x = v)
        val () = pause (i+1)
      in raise2 (x+1) end
    ) with ~E2(y) => let
      val () = assertloc (y = v + 1)
    in count () end
  // a handler that does not match: the exception passes through
  val () =
    try (
      try deep (2, v, i+2) with ~E2(_) => assertloc (false)
    ) with ~E1(x) => let
      val () = assertloc (x = v)
    in count () end
in end

fun fib (id: int, i: int): void =
  if i < 40 then (one (id, i); fib (id, i+1)) else ()

fun spawn_all (k: int, n: int): void =
  if k < n then let
    val () = afiber_spawn_detached (llam () => fib (k, 0))
  in spawn_all (k+1, n) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = spawn_all (0, 32)
  // main has its own handler frames while the workers run fibers
  val () = try (afiber_yield (); raise1 (5)) with ~E1(x) => assertloc (x = 5)
  val () = afiber_run_until_done ()
  val () = try (afiber_sleep_usec ($UN.cast{ullint}(300)); raise2 (6)) with ~E2(x) => assertloc (x = 6)
  val () = afiber_workers_stop ()
  val () = assertloc (the_cnt_ref[] = 32 * 40 * 2)
  val () = mx_fini ()
  val () = println! ("POS_mn_exn: passed")
}
