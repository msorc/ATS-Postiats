(*
** MS-2026-10: afiber, M:N
** The closure of a fiber is freed by the thread that allocated it (the
** owner): the allocator's arena lock is then not taken by another
** thread. This test exercises the three ways a closure is released:
** (1) the thread that runs the body is the owner (it frees it there),
** (2) the fiber is reaped by another thread (the block goes to the list
** of the owner, which frees it), (3) the fiber is detached (the reaper
** is a worker, not the owner).
** The fibers are spawned and joined on several workers, and they
** migrate (they yield), so that the owner of a closure is often not the
** thread that runs it. Every fiber adds to a counter: nothing must be
** lost. The AddressSanitizer leak check (make leakcheck) must find no
** leak.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
#include "./mn_common.hats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)

fun bump (n: int): void = let
  val () = mx_lock ()
  val () = the_cnt_ref[] := the_cnt_ref[] + n
  val () = mx_unlock ()
in end

// a child: it adds 1 and it sometimes yields (so that it migrates)
fun child (k: int): void = let
  val () = if k mod 3 = 0 then afiber_yield ()
in bump (1) end

fun join_all (xs: List0_vt(afiber_vt)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (f, rest) => (afiber_join (f); join_all (rest))

// the closures of the children are allocated here
fun spawn_children (k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val f = afiber_spawn (llam () => child (k))
  in spawn_children (k+1, n, list_vt_cons (f, res)) end

// a parent: it spawns the children and it joins them (it may have
// migrated in the meantime: the closure is then released by another
// thread than the one that allocated it)
fun parent (k: int, n: int): void = let
  val fs = spawn_children (0, n, list_vt_nil ())
  val () = bump (1)
  val () = join_all (fs)
in end

fun spawn_parents (k: int, n: int, res: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if k >= n then res else let
    val f = afiber_spawn (llam () => parent (k, 8))
  in spawn_parents (k+1, n, list_vt_cons (f, res)) end

// the detached fibers: they are reaped by a worker, which is not the
// owner of their closure
fun spawn_detached (i: int, n: int): void =
  if i < n then let
    val () = afiber_spawn_detached (llam () => child (i))
  in spawn_detached (i+1, n) end else ()

implement main0 () = {
  val () = mx_init ()
  val () = afiber_workers_start (4)
  val () = assertloc (afiber_nworkers () >= 2)
  // the fibers that main spawns and joins itself
  val fs = spawn_children (0, 50, list_vt_nil ())
  val () = join_all (fs)
  // the fibers that main spawns and that another fiber joins
  val ps = spawn_parents (0, 20, list_vt_nil ())
  val () = join_all (ps)
  // the detached fibers
  val () = spawn_detached (0, 200)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_workers_stop ()
  val () = assertloc (the_cnt_ref[] = 50 + 20 * 9 + 200)
  val () = mx_fini ()
  val () = println! ("POS_mn_spawnfree: passed")
}
