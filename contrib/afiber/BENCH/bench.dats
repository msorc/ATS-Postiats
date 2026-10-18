(* MS-2026-10: afiber benchmarks; the Go twins are in bench.go.
   usage: bench NAME [N]   (prints "NAME N ns" and, for [mem], the rss) *)
#include "share/atspre_staload.hats"
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
%}
extern fun rss_kb (): lint = "mac#bench_rss_kb"

var the_sink: int = 0
val the_sink_ref = ref_make_viewptr{int}(view@ the_sink | addr@ the_sink)

fun report (name: string, n: int, t0: ullint): void =
  println! (name, " ", n, " ", afiber_clock_ns () - t0)

(* ---- spawn: N empty fibers, spawned in batches of 10000 ---- *)
fun spawn_batch (i: int, b: int): void =
  if i < b then
    (afiber_spawn_detached (llam () => the_sink_ref[] := the_sink_ref[] + 1);
     spawn_batch (i+1, b))
fun bench_spawn (n: int): void = let
  val t0 = afiber_clock_ns ()
  fun loop (k: int): void =
    if k > 0 then let
      val b = min (k, 10000)
      val () = spawn_batch (0, b)
      val () = afiber_run_until_done ()
    in loop (k - b) end
  val () = loop (n)
in report ("spawn", n, t0) end

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
    val-~Some_vt(_) = chan_recv<int> (c2)
  in ping (c1, c2, k+1, n) end
fun pong (c1: !chan_vt(int), c2: !chan_vt(int), k: int, n: int): void =
  if k < n then let
    val-~Some_vt(x) = chan_recv<int> (c1)
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
    val-~Some_vt(x) = chan_recv<int> (ch)
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
  val-~Some_vt(x) = chan_recv<int> (r)
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
  val-~Some_vt(x) = chan_recv<int> (fm)
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
  case+ chan_recv<int> (inp) of
  | ~Some_vt(x) =>
    if x mod p = 0 then filter (inp, out, p) else
      (case+ chan_send_opt<int> (out, x) of
       | ~None_vt() => filter (inp, out, p)
       | ~Some_vt(_) => (chan_close (inp); chan_unref_type<int> (inp); chan_unref_type<int> (out)))
  | ~None_vt() => (chan_close (out); chan_unref_type<int> (inp); chan_unref_type<int> (out))
fun sieve (ch: chan_vt(int), i: int, n: int): chan_vt(int) =
  if i < n then let
    val-~Some_vt(p) = chan_recv<int> (ch)
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

implement main0 {n} (argc, argv) = let
  val () = if argc < 2 then (prerrln! ("usage: bench NAME [N]"); exit (1))
  val name = (if argc >= 2 then argv[1] else "") : string
  val n = (if argc >= 3 then g0string2int (argv[2]) else 0) : int
in
  if name = "spawn" then bench_spawn (n)
  else if name = "yield" then bench_yield (n)
  else if name = "pingpong" then bench_pingpong (n)
  else if name = "pipe" then bench_prod ("pipe", 1, n)
  else if name = "fanin" then bench_prod ("fanin", 8, n)
  else if name = "chain" then bench_chain (n)
  else if name = "sieve" then bench_sieve (n)
  else if name = "mem" then bench_mem (n)
  else (prerrln! ("unknown benchmark: ", name, " argc=", argc); exit (1))
end
