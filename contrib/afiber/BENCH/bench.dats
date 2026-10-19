(* MS-2026-10: afiber benchmarks; the Go twins are in bench.go.
   usage: bench NAME [N]   (prints "NAME N ns" and, for [mem], the rss) *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"

%{^
#include <stdio.h>
#include <string.h>
static long bench_rss_kb(void) {
  FILE *f = fopen("/proc/self/status", "r"); char l[256]; long v = -1;
  if (!f) return -1;
  while (fgets(l, sizeof l, f)) if (!strncmp(l, "VmRSS:", 6)) { v = atol(l+6); break; }
  fclose(f); return v;
}
static unsigned long bench_lcg(unsigned long x) { return x * 6364136223846793005UL + 1442695040888963407UL; }
static unsigned long bench_acc = 0;
static void bench_acc_xor(unsigned long x) { __atomic_fetch_xor(&bench_acc, x, __ATOMIC_RELAXED); }
static long bench_count = 0;
static void bench_count_atomic(void) { __atomic_fetch_add(&bench_count, 1, __ATOMIC_RELAXED); }
static void bench_count_plain(void) { bench_count++; }
static long bench_count_get(void) { return bench_count; }
%}
(* MS-2026-10 (step J): [chan_recv_ref] instead of [chan_recv] (no [Some_vt] node per item);
   the items of these benchmarks are >= 0, -1 stands for "closed and drained" *)
fun rv (ch: !chan_vt(int)): int = let
  var x: int
in
  if chan_recv_ref<int> (ch, x)
  then let prval () = opt_unsome{int}(x) in x end
  else let prval () = opt_unnone{int}(x); val () = x := 0 in ~1 end
end
extern fun lcg (x: ulint): ulint = "mac#bench_lcg"
extern fun acc_xor (x: ulint): void = "mac#bench_acc_xor"
extern fun count_atomic (): void = "mac#bench_count_atomic"
extern fun count_plain (): void = "mac#bench_count_plain"
extern fun count_get (): lint = "mac#bench_count_get"
extern fun mx_make (): ptr = "mac#atscntrb_afiber_mutex_make"
extern fun mx_lock (m: ptr): void = "mac#atscntrb_afiber_mutex_lock"
extern fun mx_unlock (m: ptr): void = "mac#atscntrb_afiber_mutex_unlock"
extern fun mx_free (m: ptr): void = "mac#atscntrb_afiber_mutex_free"
extern fun rss_kb (): lint = "mac#bench_rss_kb"

var the_sink: int = 0
val the_sink_ref = ref_make_viewptr{int}(view@ the_sink | addr@ the_sink)

fun report (name: string, n: int, t0: ullint): void =
  println! (name, " ", n, " ", afiber_clock_ns () - t0)

(* ---- spawn: N empty fibers, spawned in batches of 10000 ---- *)
(* bench_spawn: steady state. One untimed warm-up batch of 10000 first, so the stacks are
   already on the free list (mmap + mprotect paid) and the timed batches only reuse them.
   bench_spawn_cold: exactly one batch of n fibers with no warm-up, every fiber pays a fresh
   stack (mmap + mprotect + page faults). *)
fun spawn_batch (i: int, b: int): void =
  if i < b then
    (afiber_spawn_detached (llam () => the_sink_ref[] := the_sink_ref[] + 1);
     spawn_batch (i+1, b))
fun bench_spawn (n: int): void = let
  val () = spawn_batch (0, 10000)
  val () = afiber_run_until_done ()
  val t0 = afiber_clock_ns ()
  fun loop (k: int): void =
    if k > 0 then let
      val b = min (k, 10000)
      val () = spawn_batch (0, b)
      val () = afiber_run_until_done ()
    in loop (k - b) end
  val () = loop (n)
in report ("spawn", n, t0) end
fun bench_spawn_cold (n: int): void = let
  val t0 = afiber_clock_ns ()
  val () = spawn_batch (0, n)
  val () = afiber_run_until_done ()
in report ("spawn_cold", n, t0) end

(* ---- yield: 2 fibers, n yields each ---- *)
fun yielder (n: int): void =
  if n > 0 then (afiber_yield (); yielder (n-1))
fun bench_yield (n: int): void = let
  val t0 = afiber_clock_ns ()
  val a = afiber_spawn (llam () => yielder (n))
  val b = afiber_spawn (llam () => yielder (n))
  val () = afiber_join (a)
  val () = afiber_join (b)
in report ("yield", 2*n, t0) end

(* ---- pingpong: n round trips over two capacity-1 channels ---- *)
fun ping (c1: !chan_vt(int), c2: !chan_vt(int), k: int, n: int): void =
  if k < n then let
    val () = chan_send<int> (c1, k)
    val _ = rv (c2)
  in ping (c1, c2, k+1, n) end
fun pong (c1: !chan_vt(int), c2: !chan_vt(int), k: int, n: int): void =
  if k < n then let
    val x = rv (c1)
    val () = chan_send<int> (c2, x)
  in pong (c1, c2, k+1, n) end
fun bench_pingpong (n: int): void = let
  val t0 = afiber_clock_ns ()
  val c1 = chan_make<int> (1)
  val c2 = chan_make<int> (1)
  val a1 = chan_ref<int> (c1) val a2 = chan_ref<int> (c2)
  val b1 = chan_ref<int> (c1) val b2 = chan_ref<int> (c2)
  val fa = afiber_spawn (llam () => (ping (a1, a2, 0, n);
    chan_unref_type<int> (a1); chan_unref_type<int> (a2)))
  val fb = afiber_spawn (llam () => (pong (b1, b2, 0, n);
    chan_unref_type<int> (b1); chan_unref_type<int> (b2)))
  val () = afiber_join (fa)
  val () = afiber_join (fb)
  val () = (chan_unref_type<int> (c1); chan_unref_type<int> (c2))
in report ("pingpong", 2*n, t0) end

(* ---- pipe / fanin: P producers, main consumes n items, cap 128 ---- *)
fun produce (ch: !chan_vt(int), n: int): void =
  if n > 0 then (chan_send<int> (ch, n); produce (ch, n-1))
fun consume (ch: !chan_vt(int), n: int, s: int): int =
  if n > 0 then let
    val x = rv (ch)
  in consume (ch, n-1, s+x) end else s
fun spawn_prod {n:nat} (ch: !chan_vt(int), p: int, per: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if p > 0 then let
    val c = chan_ref<int> (ch)
    val f = afiber_spawn (llam () => (produce (c, per); chan_unref_type<int> (c)))
  in spawn_prod (ch, p-1, per, list_vt_cons (f, fs)) end else fs
fun join_all (fs: List_vt(afiber_vt)): void =
  case+ fs of
  | ~list_vt_cons (f, fs) => (afiber_join (f); join_all (fs))
  | ~list_vt_nil () => ()
fun bench_prod (name: string, p: int, n: int): void = let
  val t0 = afiber_clock_ns ()
  val ch = chan_make<int> (128)
  val per = n / p
  val fs = spawn_prod (ch, p, per, list_vt_nil ())
  val s = consume (ch, per * p, 0)
  val () = the_sink_ref[] := s
  val () = join_all (fs)
  val () = chan_unref_type<int> (ch)
in report (name, per * p, t0) end

(* ---- chain: a daisy chain of n fibers, one token travels through ---- *)
fun worker (l: chan_vt(int), r: chan_vt(int)): void = let
  val x = rv (r)
  val () = chan_send<int> (l, x+1)
in chan_unref_type<int> (l); chan_unref_type<int> (r) end
fun build (i: int, n: int, left: chan_vt(int)): chan_vt(int) =
  if i < n then let
    val right = chan_make<int> (1)
    val l2 = chan_ref<int> (left)
    val r2 = chan_ref<int> (right)
    val () = afiber_spawn_detached (llam () => worker (l2, r2))
    val () = chan_unref_type<int> (left)
  in build (i+1, n, right) end else left
fun bench_chain (n: int): void = let
  val t0 = afiber_clock_ns ()
  val first = chan_make<int> (1)
  val fm = chan_ref<int> (first)
  val last = build (0, n, first)
  val () = chan_send<int> (last, 0)
  val x = rv (fm)
  val () = assertloc (x = n)
  val () = (chan_unref_type<int> (last); chan_unref_type<int> (fm))
  val () = afiber_run_until_done ()
in report ("chain", n, t0) end

(* ---- sieve: the first n primes through a chain of filter fibers ---- *)
fun gen (out: chan_vt(int), k: int): void =
  case+ chan_send_opt<int> (out, k) of
  | ~None_vt() => gen (out, k+1)
  | ~Some_vt(_) => chan_unref_type<int> (out)
fun filter (inp: chan_vt(int), out: chan_vt(int), p: int): void =
  let val x = rv (inp) in
  if x >= 0 then
    if x mod p = 0 then filter (inp, out, p) else
      (case+ chan_send_opt<int> (out, x) of
       | ~None_vt() => filter (inp, out, p)
       | ~Some_vt(_) => (chan_close (inp); chan_unref_type<int> (inp); chan_unref_type<int> (out)))
  else (chan_close (out); chan_unref_type<int> (inp); chan_unref_type<int> (out))
  end
fun sieve (ch: chan_vt(int), i: int, n: int): chan_vt(int) =
  if i < n then let
    val p = rv (ch)
    val () = the_sink_ref[] := p
    val nx = chan_make<int> (1)
    val a = chan_ref<int> (ch)
    val b = chan_ref<int> (nx)
    val () = afiber_spawn_detached (llam () => filter (a, b, p))
    val () = chan_unref_type<int> (ch)
  in sieve (nx, i+1, n) end else ch
fun bench_sieve (n: int): void = let
  val t0 = afiber_clock_ns ()
  val c0 = chan_make<int> (1)
  val g = chan_ref<int> (c0)
  val () = afiber_spawn_detached (llam () => gen (g, 2))
  val last = sieve (c0, 0, n)
  val t1 = afiber_clock_ns ()
  val () = (chan_close (last); chan_unref_type<int> (last))
  val () = afiber_run_until_done ()
in report ("sieve", n, t0 + (afiber_clock_ns () - t1)) end

(* ---- mem: n fibers parked on a channel; rss when all are parked ---- *)
fun parked (ch: chan_vt(int)): void = let
  val () = (case+ chan_recv<int> (ch) of ~Some_vt(_) => () | ~None_vt() => ())
  val () = chan_unref_type<int> (ch)
in end
fun spawn_parked (ch: !chan_vt(int), i: int, n: int): void =
  if i < n then let
    val c = chan_ref<int> (ch)
    val () = afiber_spawn_detached (llam () => parked (c))
  in spawn_parked (ch, i+1, n) end
fun bench_mem (n: int): void = let
  val r0 = rss_kb ()
  val t0 = afiber_clock_ns ()
  val ch = chan_make<int> (1)
  val () = spawn_parked (ch, 0, n)
  val () = afiber_yield ()
  val r1 = rss_kb ()
  val () = (chan_close (ch); chan_unref_type<int> (ch))
  val () = afiber_run_until_done ()
in
  println! ("mem ", n, " ", afiber_clock_ns () - t0, " rss_kb_per_task ", (g0int2float_lint_double (r1 - r0) / g0int2float_int_double (n)))
end

(* ================= M:N benchmarks: usage NAME N W (W workers) ================= *)

(* ---- mn_pingpong: 16 independent pairs, n round trips each ---- *)
fun spawn_pairs {n:nat} (p: int, n: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if p > 0 then let
    val c1 = chan_make<int> (1)
    val c2 = chan_make<int> (1)
    val a1 = chan_ref<int> (c1) val a2 = chan_ref<int> (c2)
    val b1 = chan_ref<int> (c1) val b2 = chan_ref<int> (c2)
    val () = (chan_unref_type<int> (c1); chan_unref_type<int> (c2))
    val fa = afiber_spawn (llam () => (ping (a1, a2, 0, n);
      chan_unref_type<int> (a1); chan_unref_type<int> (a2)))
    val fb = afiber_spawn (llam () => (pong (b1, b2, 0, n);
      chan_unref_type<int> (b1); chan_unref_type<int> (b2)))
  in spawn_pairs (p-1, n, list_vt_cons (fa, list_vt_cons (fb, fs))) end
  else fs
fun bench_mn_pingpong (total: int): void = let
  val P = 16
  val n = total / (2 * P)
  val t0 = afiber_clock_ns ()
  val fs = spawn_pairs (P, n, list_vt_nil ())
  val () = join_all (fs)
in report ("mn_pingpong", 2 * n * P, t0) end

(* ---- mn_pipeline: 1 source -> cap 128 -> 8 stages -> cap 128 -> main ---- *)
fun stage (a: !chan_vt(int), b: !chan_vt(int), per: int): void =
  if per > 0 then let
    val x = rv (a)
    val () = chan_send<int> (b, x + 1)
  in stage (a, b, per-1) end
fun spawn_stages {n:nat} (a: !chan_vt(int), b: !chan_vt(int), k: int, per: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if k > 0 then let
    val x = chan_ref<int> (a)
    val y = chan_ref<int> (b)
    val f = afiber_spawn (llam () => (stage (x, y, per); chan_unref_type<int> (x); chan_unref_type<int> (y)))
  in spawn_stages (a, b, k-1, per, list_vt_cons (f, fs)) end else fs
fun bench_mn_pipeline (n0: int): void = let
  val K = 8
  val per = n0 / K
  val n = per * K
  val t0 = afiber_clock_ns ()
  val a = chan_make<int> (128)
  val b = chan_make<int> (128)
  val src = chan_ref<int> (a)
  val fsrc = afiber_spawn (llam () => (produce (src, n); chan_unref_type<int> (src)))
  val fs = spawn_stages (a, b, K, per, list_vt_cons (fsrc, list_vt_nil ()))
  val s = consume (b, n, 0)
  val () = the_sink_ref[] := s
  val () = join_all (fs)
  val () = (chan_unref_type<int> (a); chan_unref_type<int> (b))
in report ("mn_pipeline", n, t0) end


fun inc_list (xs: List0_vt(int)): List0_vt(int) =
  case+ xs of
  | ~list_vt_nil () => list_vt_nil ()
  | ~list_vt_cons (x, xs1) => list_vt_cons (x + 1, inc_list (xs1))
fun bstage (a: !chan_vt(int), b: !chan_vt(int), per: int): void =
  if per > 0 then let
    val k = (if per > 16 then 16 else $UN.cast{intGt(0)}(per)): intGt(0)
    val xs = chan_recv_batch<int> (a, k)
    val m = list_vt_length (xs)
    val rest = chan_send_list<int> (b, inc_list (xs))
    val () = list_vt_free (rest)
  in bstage (a, b, per-m) end
fun spawn_bstages {n:nat} (a: !chan_vt(int), b: !chan_vt(int), k: int, per: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if k > 0 then let
    val x = chan_ref<int> (a)
    val y = chan_ref<int> (b)
    val f = afiber_spawn (llam () => (bstage (x, y, per); chan_unref_type<int> (x); chan_unref_type<int> (y)))
  in spawn_bstages (a, b, k-1, per, list_vt_cons (f, fs)) end else fs
fun bench_mn_pipeline_batch (n0: int): void = let
  val K = 8
  val per = n0 / K
  val n = per * K
  val t0 = afiber_clock_ns ()
  val a = chan_make<int> (128)
  val b = chan_make<int> (128)
  val src = chan_ref<int> (a)
  val fsrc = afiber_spawn (llam () => (produce (src, n); chan_unref_type<int> (src)))
  val fs = spawn_bstages (a, b, K, per, list_vt_cons (fsrc, list_vt_nil ()))
  val s = consume (b, n, 0)
  val () = the_sink_ref[] := s
  val () = join_all (fs)
  val () = (chan_unref_type<int> (a); chan_unref_type<int> (b))
in report ("mn_pipeline_batch", n, t0) end

(* ---- mn_cpu: 64 fibers, each iters LCG steps, yielding every 1000 ---- *)
fun cpu_work (i: int, iters: int, x: ulint): ulint =
  if i < iters then let
    val () = if i mod 1000 = 999 then afiber_yield ()
  in cpu_work (i+1, iters, lcg (x)) end else x
fun spawn_cpu {n:nat} (k: int, iters: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if k > 0 then let
    val f = afiber_spawn (llam () => acc_xor (cpu_work (0, iters, g0int2uint_int_ulint (k))))
  in spawn_cpu (k-1, iters, list_vt_cons (f, fs)) end else fs
fun bench_mn_cpu (total: int): void = let
  val K = 64
  val iters = total / K
  val t0 = afiber_clock_ns ()
  val () = join_all (spawn_cpu (K, iters, list_vt_nil ()))
in report ("mn_cpu", K * iters, t0) end

(* ---- mn_spawn: batches of 1000 joinable fibers, each bumps an atomic counter ---- *)
fun spawn_cnt {n:nat} (k: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if k > 0 then spawn_cnt (k-1, list_vt_cons (afiber_spawn (llam () => count_atomic ()), fs)) else fs
fun bench_mn_spawn (n: int): void = let
  val t0 = afiber_clock_ns ()
  fun loop (k: int): void =
    if k > 0 then let
      val b = min (k, 1000)
      val () = join_all (spawn_cnt (b, list_vt_nil ()))
    in loop (k - b) end
  val () = loop (n)
  val () = assertloc (count_get () = g0int2int_int_lint (n))
in report ("mn_spawn", n, t0) end

(* ---- mn_mutex: 32 fibers increment one counter under a mutex ---- *)
fun mutex_work (m: ptr, k: int): void =
  if k > 0 then (mx_lock (m); count_plain (); mx_unlock (m); mutex_work (m, k-1))
fun spawn_mutex {n:nat} (m: ptr, k: int, per: int, fs: list_vt(afiber_vt,n)): List_vt(afiber_vt) =
  if k > 0 then spawn_mutex (m, k-1, per, list_vt_cons (afiber_spawn (llam () => mutex_work (m, per)), fs))
  else fs
fun bench_mn_mutex (total: int): void = let
  val F = 32
  val per = total / F
  val t0 = afiber_clock_ns ()
  val m = mx_make ()
  val () = join_all (spawn_mutex (m, F, per, list_vt_nil ()))
  val () = assertloc (count_get () = g0int2int_int_lint (per * F))
  val () = mx_free (m)
in report ("mn_mutex", per * F, t0) end

implement main0 {n} (argc, argv) = let
  val () = if argc < 2 then (prerrln! ("usage: bench NAME [N]"); exit (1))
  val name = (if argc >= 2 then argv[1] else "") : string
  val n = (if argc >= 3 then g0string2int (argv[2]) else 0) : int
  val w = (if argc >= 4 then g0string2int (argv[3]) else 1) : int
  val () = if w > 1 then afiber_workers_start (w)
  val () =
  if name = "spawn" then bench_spawn (n)
  else if name = "spawn_cold" then bench_spawn_cold (n)
  else if name = "yield" then bench_yield (n)
  else if name = "pingpong" then bench_pingpong (n)
  else if name = "pipe" then bench_prod ("pipe", 1, n)
  else if name = "fanin" then bench_prod ("fanin", 8, n)
  else if name = "chain" then bench_chain (n)
  else if name = "sieve" then bench_sieve (n)
  else if name = "mem" then bench_mem (n)
  else if name = "mn_pingpong" then bench_mn_pingpong (n)
  else if name = "mn_pipeline" then bench_mn_pipeline (n)
  else if name = "mn_pipeline_batch" then bench_mn_pipeline_batch (n)
  else if name = "mn_cpu" then bench_mn_cpu (n)
  else if name = "mn_spawn" then bench_mn_spawn (n)
  else if name = "mn_mutex" then bench_mn_mutex (n)
  else (prerrln! ("unknown benchmark: ", name, " argc=", argc); $extfcall(void, "exit", 1))
in
  if w > 1 then afiber_workers_stop ()
end
