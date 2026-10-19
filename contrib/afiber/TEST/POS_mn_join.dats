(*
** MS-2026-10: afiber, M:N
** fibers joined by other fibers and by main, detached fibers, nested
** spawns, [afiber_is_done] polling; every fiber adds into one total.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_sum: int = 0
val the_sum_ref = ref_make_viewptr{int}(view@ the_sum | addr@ the_sum)

fun add (n: int): void = let
  val () = mx_lock ()
  val () = the_sum_ref[] := the_sum_ref[] + n
  val () = mx_unlock ()
in end

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f); join_all (rest))

// a grandchild: adds 1, sometimes yields or sleeps first
fun grandchild (k: int): void = let
  val () = if k mod 3 = 0 then afiber_yield () else if k mod 3 = 1 then afiber_sleep_usec ($UN.cast{ullint}(50))
in add (1) end

// a child: adds 10, spawns one joinable and one detached grandchild
fun child (k: int): void = let
  val g = afiber_spawn (llam () => grandchild (k))
  val () = afiber_spawn_detached (llam () => grandchild (k+1))
  val () = add (10)
  val () = afiber_join (g)
in end

fun spawn_children (k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val f = afiber_spawn (llam () => child (k))
  in spawn_children (k+1, n, list_vt_cons (f, res)) end

// a parent joins its children (the join is done by a fiber, not by main)
fun parent (p: int): void = let
  val cs = spawn_children (0, 8, list_vt_nil ())
  val () = add (100)
  val () = join_all (cs)
in end

fun spawn_parents (k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val f = afiber_spawn (llam () => parent (k))
  in spawn_parents (k+1, n, list_vt_cons (f, res)) end

fun wait_done (fb: !afiber_vt, n: int): void =
  if afiber_is_done (fb) then ()
  else if n <= 0 then assertloc (false)
  else (afiber_sleep_usec ($UN.cast{ullint}(100)); wait_done (fb, n-1))

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val NP = 25
  val ps = spawn_parents (0, NP, list_vt_nil ())
  // main joins fibers that are running on the other workers
  val f = afiber_spawn (llam () => add (7))
  val () = wait_done (f, 100000)
  val () = afiber_join (f)
  val () = assertloc (afiber_is_main ())
  val () = join_all (ps)
  // a parent: 100, 8 children of (10 + 1 + 1)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = assertloc (the_sum_ref[] = 7 + NP * (100 + 8 * 12))
  val () = afiber_workers_stop ()
  val () = mx_fini ()
  val () = println! ("POS_mn_join: passed")
}
