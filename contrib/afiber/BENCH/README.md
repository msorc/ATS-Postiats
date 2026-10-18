# afiber vs Go benchmarks

(The tables below are the one-worker numbers measured before M:N. The current numbers, after step 1 of the
speed-up plan, are in `results.md`; the M:N run before step 1 (the library at 4552ac427, up to 19% slower on channel
ping-pong at one worker) is in `results_step0.md`.)

`bench.dats` (afiber + afiberchan) and `go/bench.go` run the same eight workloads;
`make bench` builds both and prints the tables (median of 7 runs, `run.py`).
`spawn` is measured after one untimed warm-up batch (stacks already on the free list); `spawn_cold` is the first
batch alone (10000 fibers on fresh stacks).
Channels have the same capacity on both sides (1 for ping-pong/chain/sieve, 128 for pipe/fanin);
afiber has no unbuffered channel, so Go uses capacity 1 too.

Measured 2026-10-18: 32-core x86-64 Linux, gcc 16.2 `-O2`, go 1.27. afiber is one OS
thread, so **Go with GOMAXPROCS=1 is the like-for-like column**; the 32-thread column shows what
the Go scheduler does when it may use every core.

| benchmark | ops | afiber ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|
| spawn+run empty fiber | 200000 | 639.0 | 286.6 | 258.8 | 2.23x slower |
| yield (context switch) | 1000000 | 16.0 | 67.9 | 119.1 | 4.23x faster |
| channel ping-pong (cap 1) | 1000000 | 29.9 | 143.9 | 143.7 | 4.82x faster |
| channel pipe, 1 producer (cap 128) | 5000000 | 13.6 | 35.3 | 36.6 | 2.60x faster |
| channel fan-in, 8 producers (cap 128) | 5000000 | 13.8 | 35.1 | 50.9 | 2.54x faster |
| chain of fibers (spawn + 1 hop each) | 30000 | 10820.6 | 1774.1 | 1400.2 | 6.10x slower |
| prime sieve (ns per prime, 1500 primes) | 1500 | 41708.0 | 110701.9 | 26413.2 | 2.65x faster |

| parked fibers (30000) | afiber | go P=1 | go P=32 |
|---|---:|---:|---:|
| RSS per task | 4.16 KB | 2.71 KB | 3.20 KB |

## Before and after the speedup

The first measurement of the day used `swapcontext` and a fresh `mmap` per fiber
(`results_before.md`). The `spawn` row is the mean of cold and steady state (see "Reading the numbers"). The same day afiber got a hand-written x86-64 switch, a free list
of stacks and a channel ring without division:

| benchmark | before ns/op | after ns/op | gain | go P=1 ns/op |
|---|---:|---:|---:|---:|
| spawn+run empty fiber (mean of 200000, first batch cold) | 14894 | 639 | 23x | 287 |
| yield | 502 | 16 | 31x | 68 |
| channel ping-pong | 534 | 30 | 18x | 144 |
| channel pipe | 22.5 | 13.6 | 1.7x | 35 |
| channel fan-in | 36.3 | 13.8 | 2.6x | 35 |
| chain | 15501 | 10821 | 1.4x | 1774 |
| sieve (per prime) | 485677 | 41708 | 12x | 110702 |
| RSS per parked fiber | 5.10 KB | 4.16 KB | | 2.71 KB |

## Reading the numbers

* **A switch is 16 ns**: `atscntrb_afiber__swap` saves six callee-saved registers, the
  stack pointer and the fp control words, nothing else, and `strace -c` shows no syscall
  at all during a yield. Go's switch goes through its scheduler (~70 ns). Before, `swapcontext`
  made one `rt_sigprocmask` syscall per switch, ~250 ns of a ~500 ns switch.
* **Channels** are a ring-buffer move with no lock or atomic, because there is one thread;
  Go pays for a mutex per operation even at P=1. Ping-pong needs two switches per round trip,
  so it is the switch cost twice plus two channel operations.
* **Spawn: the mean hid two numbers.** The table above (and `results_before.md`) averages 200000 spawns in batches
  of 10000, and the first batch pays a fresh stack per fiber: `mmap` + `mprotect` (guard page) + two page faults
  (~5 us each, `strace -c`: 10008 `mmap`, 10003 `mprotect`), about 11 us per fiber; the other 19 batches take stacks from
  the free list at ~95-136 ns. So the 639 ns mean, "2.2x slower than Go", was 86% first batch. Since step 1 the benchmark
  warms up first: `spawn` is the steady state, 136 ns (Go P=1 241 ns, afiber 1.8x faster), and `spawn_cold` is the first
  batch alone, 10.4 us per fiber (Go 776 ns, 13x slower); see `results.md`. Go reuses goroutine stacks the same way but
  allocates fresh ones from a span, without a syscall per stack.
* **Chain is 6x slower** for the same reason, with no reuse: 30000 fibers are live at once, so
  every one has a fresh stack (`strace -c`: 30008 `mmap`, 30003 `mprotect`; `perf stat`: 62643
  page faults), and the kernel's VMA work grows with the number of mappings. A one-shot burst
  of fibers larger than anything seen before is the case the cache does not cover; a slab
  allocator for stacks (one `mmap` for many stacks) would, at the price of guard pages.
* **Memory**: a parked afiber costs 4.2 KB resident (one touched stack page plus the ~130-byte
  control block), vs 2.7-3.2 KB for a goroutine; 4 KB is the page granularity of an mmap'd
  stack. Virtual size is 256 KB per fiber (`MAP_NORESERVE`), and each fiber uses two kernel
  mappings (stack + guard), so the number of live fibers is bounded by `vm.max_map_count` / 2
  (65530 by default on many systems; 1048576 here).
* Go P=32 does not win on these workloads except the sieve, where its filters run in parallel
  (and still only 1.6x faster than single-threaded afiber); with ~35 ns of work per item the
  cross-thread wakeups cost more than the parallelism gains (fan-in and yield are slower at
  P=32 than at P=1).
* Go's `mem` wall time includes a fixed 50 ms sleep and is not compared.

## M:N benchmarks (afiber workers vs Go GOMAXPROCS)

`make benchmn` builds `bench_ats` with `-pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_` and runs five workloads
for N = 1, 2, 4, 8, 16 (the physical core count here) and ncpu, afiber with `afiber_workers_start(N)` and Go with `GOMAXPROCS=N` (median of 5, `REPS=`
to change). One benchmark by hand: `./bench_ats mn_pingpong 1600000 4`, `GOMAXPROCS=4 ./bench_go mn_pingpong 1600000`
(`NAME TOTAL [WORKERS]`). The workloads are `mn_pingpong` (16 pairs), `mn_pipeline` (source, 8 stages, sink),
`mn_cpu` (64 fibers of pure compute, yield per 1000 steps), `mn_spawn` (spawn+join batches of 1000) and `mn_mutex`
(32 fibers on one counter). The total work is fixed, so the "speedup" table is wall time at N=1 over wall time at N.
`make bench` also builds with the M:N flags; with `make bench_ats_1n` (the library without
`_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`), `make bench_ats_single` (`-DATSCNTRB_AFIBER_SINGLE`) and `BEFORE=<binary>`
(`BEFORE_LABEL=` names its column) `python3 run.py` adds columns for the 1:N build, the SINGLE build and a binary of the
previous library; a benchmark the `BEFORE=` binary lacks prints "-". Numbers: `results.md` (after step 1), `results_step0.md` (before it); the older one-worker
numbers: `results_1n.md`.

### Reading the M:N numbers (2026-10-18, 16-core/32-thread Ryzen 9 5950X; the figures in the bullets are from `results_step0.md`, before step 1)

* **Parallel compute scales**: `mn_cpu` is 1.9x at N=2 and 3.6x at N=4, equal to Go (1.9x, 3.7x), and afiber is
  faster than Go in absolute terms up to N=4 (a plain LCG loop; Go's `Gosched` is dearer). Past that Go keeps
  scaling (5.9x at N=8) while afiber drops (2.9x at N=8, 1.2x at N=32): every yield (1 per ~1 us of work) takes the one
  run-queue lock, and the more workers, the more they queue on it.
* **Everything that touches the scheduler gets slower with more workers, in afiber, by a lot**: ping-pong costs
  28 ns/message at N=1 but 249 at N=2, 403 at N=4 and 1667 at N=32 (Go: 146 at N=1, falling to 16 at N=32);
  the pipeline 31 -> 267 ns/item at N=4 (Go 75 -> 100, also not scaling); spawn+join 200 -> 770 ns at N=4
  (Go flat at ~250); mutex 2.9 -> 82 ns at N=4 and 2.7 us at N=32 (Go 4.6 -> 76 and 56).
  At N=1 afiber is 1.2-5x faster than Go in all but `mn_cpu` (also faster there); at N>=2 it loses on every channel,
  spawn and mutex benchmark by 1.1x to 105x.
* **Measured cause** (`perf stat`, `perf record`/`annotate`, `strace -c` on `mn_pingpong 400000 4`, 2026-10-18; the
  explanation first written here, cross-thread wake-ups of an idle worker, was reasoning from the design and is wrong):
  at N=4 the instructions only double (131 M -> 264 M) but the cycles grow 55x (37 M -> 2049 M), 7.8 cycles per
  instruction: a `pause` loop on a cache line owned by another core. 38% of the time is in `pick_slow`, 37% in `wake_mt`,
  and ~65% of each of those two on the load of `s->lock` in `atscntrb_afiber__spin_lock`: the one spinlock of the
  global run queue, taken twice per message per side (every send takes it in `wake_mt`, every park in `pick_slow`), with
  the line bouncing between cores (and between the two L3 complexes at N>=8). Idle-worker wake-ups are not the cost:
  only 1,429 `futex` calls for 400,000 messages (16 pairs keep every worker busy); the 5,392 `sched_yield` are spins
  that passed 100 rounds. `mn_cpu` stops scaling for the same reason (a yield at N>1 takes the lock twice), and the
  mutex had two layers of it: its own spinlock plus the global queue on every park and wake. Go has a run queue per P,
  a `runnext` slot that runs the just-woken goroutine on the same P (a ping-pong pair stays on one thread), work
  stealing, and wakes a P only when one is idle and nobody is spinning, so the common case takes no shared lock.
* **What was done (step 1) and what is next.** Step 1 (commits listed in `results.md`), measured there:
  - mutex fast path (one atomic exchange) and a 4x30 `pause` spin before parking, as `sync.Mutex` does: `mn_mutex`
    N=4 82 -> 22 ns (Go 79), N=32 2731 -> 545; the mutex is no longer FIFO under contention. Still 3-9x slower than Go
    from N=8, where a failed spin parks through the global queue;
  - scheduler and worker fields on separate cache lines: 6-39% on the lock-bound workloads (ping-pong N=2 249 -> 164,
    N=32 1667 -> 1018; `mn_cpu` at N=8 2.85x -> 3.71x), as predicted, no more: the lock is still there;
  - `ATSCNTRB_AFIBER_SINGLE` (compile the M:N paths out for programs that never start workers): yield 14.7, ping-pong
    29.8, pipe 13.5 ns, the pre-M:N cost; the default build is unchanged against before step 1;
  - benchmark hygiene: warm-up for `spawn`, the `spawn_cold` row, an N=16 column, the SINGLE column.

  Next, in order of payoff. **Step A**, per-worker run queues with a `runnext` slot and work stealing: removes the
  global lock from the common path (a woken fiber goes to the waker's `runnext`, yield pushes to the local ring,
  `pick` steals only when dry). Expected, not measured: ping-pong at N>=2 near its N=1 cost (~30-60 ns), `mn_cpu`
  scaling to the core count, `mn_spawn` flat near 200 ns. **Step D**, a stack slab (one `mmap` for k stacks, each guard
  `mprotect`ed on first use): one syscall per stack instead of two, chain ~11 -> ~6 us per fiber, `spawn_cold` about
  halved, no change to the steady state; an opt-in no-guard mode (silent overflow) would take chain to ~1 us. Until step A,
  M:N pays off for coarse-grained compute fibers (about 10 us or more between scheduler calls) and loses for
  fine-grained communication: use `afiber_workers_start` only for the first.
