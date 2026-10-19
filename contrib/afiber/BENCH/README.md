# afiber vs Go benchmarks

(The tables below are the one-worker numbers measured before M:N. The current numbers, after step 4 of the
speed-up plan, are in `results.md`; the run after step 3 is `results_step3.md`, after step 2 `results_step2.md`, after step 1 `results_step1.md`; the M:N run before step 1 (the library at 4552ac427, up to 19% slower on channel
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
`bench.dats` receives with `chan_recv_ref` in every benchmark (no allocation per item, as in Go). A hand-run row not in `run.py`: `./bench_ats mn_pipeline_batch 2000000 N` (the 8 stages use `chan_recv_batch`/`chan_send_list` with batches of up to 16; source and sink per item). `make bench` also builds with the M:N flags; with `make bench_ats_1n` (the library without
`_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`), `make bench_ats_single` (`-DATSCNTRB_AFIBER_SINGLE`) and `BEFORE=<binary>`
(`BEFORE_LABEL=` names its column) `python3 run.py` adds columns for the 1:N build, the SINGLE build and a binary of the
previous library; a benchmark the `BEFORE=` binary lacks prints "-". Numbers: `results.md` (after step 4), `results_step3.md`, `results_step2.md`, `results_step1.md` (after step 1), `results_step0.md` (before it); the older one-worker
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
  stealing, and wakes a P only when one is idle and nobody is spinning, so the common case takes no shared lock. Step A (below) gave afiber the same design and removed this cause; the pipeline's remaining cost after step 2 was the channel's own lock (51% of cycles in `chan_send_opt`, 37% in `chan_recv` at N=4), not the scheduler (under 8%), which step 3 reduced.
* **What was done (steps 1 to 4) and what is next.** Step 1 (commits listed in `results_step1.md`), measured there:
  - mutex fast path (one atomic exchange) and a 4x30 `pause` spin before parking, as `sync.Mutex` does: `mn_mutex`
    N=4 82 -> 22 ns (Go 79), N=32 2731 -> 545; the mutex is no longer FIFO under contention. Still 3-9x slower than Go
    from N=8, where a failed spin parks through the global queue (step 3 fixed this, below);
  - scheduler and worker fields on separate cache lines: 6-39% on the lock-bound workloads (ping-pong N=2 249 -> 164,
    N=32 1667 -> 1018; `mn_cpu` at N=8 2.85x -> 3.71x), as predicted, no more: the lock is still there;
  - `ATSCNTRB_AFIBER_SINGLE` (compile the M:N paths out for programs that never start workers): yield 14.7, ping-pong
    29.8, pipe 13.5 ns, the pre-M:N cost; the default build is unchanged against before step 1;
  - benchmark hygiene: warm-up for `spawn`, the `spawn_cold` row, an N=16 column, the SINGLE column.

  Step 1 measured the cause above; step 2 (commits and tables in `results.md`) removed it. **Step A**, per-worker run queues
  (`runnext` slot, 256-slot ring, stealing, Go's wakep/spinning rules; `ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS`, default 3000, was tried
  at 3000/500/0 ns at N=4 and 16 with no difference beyond noise): the global lock is off the common path. `mn_pingpong`
  N=2/4/8/16/32 164/326/413/641/1018 -> 21.8/10.9/5.7/5.1/5.3 ns, faster than Go at every N (0.12 to 0.33 of Go's time), 5.7x
  scaling at N=16; `mn_cpu` speedup at N=8/16/32 3.71x/1.75x/1.35x -> 7.73x/13.96x/19.84x (Go 6.27x/3.26x/2.87x); `mn_spawn`
  N=2..32 510/817/1554/1659/2079 -> 346/444/508/516/726 ns (Go 234-288). **Step D**, a stack slab (one `mmap` per 32 stacks,
  one `mprotect` per carved stack, `ATSCNTRB_AFIBER_NOGUARD` for none), the fiber record in its own stack, the free-list link
  moved off the lowest page: one-worker `spawn` 136 -> 88 ns, `spawn_cold` 10.5 -> 6.8 us (Go 734 ns: 9.2x slower, was 13.4x),
  `chain` 10.9 -> 7.1 us (Go 1.70: 4.2x slower, was 6.4x), memory 4.17 -> 4.03 KB per parked fiber; yield, ping-pong, pipe,
  fan-in and sieve unchanged within noise.

  Step 2 left `mn_pipeline` (140/251/408/353/511 -> 132/302/416/393/448 ns, Go ~100) and `mn_mutex` (207-530 ns at N>=8, Go ~60)
  unchanged, and `mn_spawn` at N>=2 held up by the pinned main fiber. **Step 3** (tables in `results.md`, measured against
  the step-2 library at b8c12e43e):
  - **Step I**, the mutex is Go's `sync.Mutex` state machine (one word: locked, woken, starving bits and the waiter count; a
    waiter that waited 1 ms switches to FIFO hand-off; fast path one CAS, slow path 4x30 `pause`, then park): at N=8 and N=32
    only 0.6% of the slow-path entries park. `mn_mutex` N=2/4/8/16/32 11.0/36.5/207/446/530 -> 14.0/21.6/29.8/25.1/24.3 ns
    (Go 27.6/72.7/59.5/58.0/59.0): 2-3x faster than Go at every N (0.30 to 0.51 of its time).
  - **Step G**, the channel is one 64-byte-aligned C object (lock, ring header and wait queues on the first line, slots in the
    same allocation), and the shared spinlock backs off (`pause` with doubling rounds up to `ATSCNTRB_AFIBER_SPIN_MAXR` = 256, for
    `ATSCNTRB_AFIBER_SPIN_PAUSES` = 2000 pauses before the first `sched_yield`; `-DATSCNTRB_AFIBER_SPIN_OLD` restores 100 pauses
    then yield). `mn_pipeline` N=2/4/8/16/32 132/302/416/393/448 -> 94/136/187/193/252 ns (Go 99/101/108/112/109): at Go's cost at
    N=2 (0.95), 1.3x to 2.3x slower from N=4 (was 3.0x to 4.1x). At N=4 the layout alone did not help (286 -> 297 ns); with
    the new spin policy 142 ns, cycles per instruction 5.4 -> 3.3, `sched_yield` 2,398 -> 56 per 1M items. It still does not
    scale: 10 fibers share two channels, the two channel locks are 49% (`chan_send_opt`) and 44% (`chan_recv`) of the cycles.
  - One worker: pipe 16.1 -> 15.1 ns, fan-in 16.4 -> 15.4, sieve 46.5 -> 40.1 us per prime; ping-pong 35.6 -> 37.0 ns (SINGLE
    30.0 -> 31.9) is a small regression, probably the accessor calls of the new ATS channel code; the rest is unchanged.
    `mn_pingpong`, `mn_cpu` and `mn_spawn` are unchanged within noise. (Step 3 blamed `mn_spawn` at N>=2 on the pinned main
    fiber and wake-up latency; that diagnosis was wrong, step 4 measured the causes: futex wake-ups and the malloc arena lock.)

  **Step 4** (tables in `results.md`, measured against the step-3 binary at 0015eb145):
  - **Step H**: worker 0 keeps spinning and stealing while the main fiber is parked and other workers are busy
    (`ATSCNTRB_AFIBER_MAIN_SPIN_NS`, default 200 us, 0 disables). It does not change `mn_spawn` (worker 0 entered the spin 139 times
    in 400,000 spawns). The measured causes of `mn_spawn` at N>=2: 5,366 futex calls per 100,000 spawns at N=4 (idle workers
    woken between the 1000-fiber batches) and glibc's malloc arena lock (a closure is allocated by main and freed by the thread
    that ran the fiber); stacks are not the cause (1,007 `mprotect` per 100,000 spawns at N=4, as at N=1). Go pays the same two
    costs (its own `mn_spawn` at N>=2 is about 2x its N=1 value).
  - **Steps J and G2**, the channel: the common paths of send, receive and the try forms are two C calls (lock and take the slot,
    wake the partner and unlock). The real one-worker cost was the `Some_vt` node that `chan_recv` mallocs and frees per item
    (28% of the ping-pong cycles), so there is a non-allocating `chan_recv_ref`/`chan_tryrecv_ref`, and `chan_recv_batch`/`chan_send_list`
    (one lock acquisition per batch). One worker (the benchmark now receives with `chan_recv_ref`): ping-pong 36.8 -> 30.5 ns (SINGLE
    23.8; Go 146), pipe 15.0 -> 8.0 (Go 35), fan-in 15.7 -> 8.3, sieve 39.9 -> 36.3 us per prime (Go 111); yield 18.0, spawn 94.6 (step 3
    87.9: probably noise, to re-check), spawn_cold, chain, memory unchanged. `mn_pipeline` N=1/2/4/8/16/32 31/94/136/187/193/252 -> 17.2/78.3/
    110.3/149.3/159.7/211.2 ns (Go 74/100/98/106/108/109): below Go at N=2, 1.1x to 1.9x slower from N=4 (was 1.3x to 2.3x), still not
    scaling. The hand-run `mn_pipeline_batch`: 25.8/23.7/47.6/70.2/76.4/103.2 ns per item, under Go at every N, but a different program.
    `mn_pingpong` 22.1/11.2/5.8/4.7/5.7 -> 18.8/9.5/4.9/4.1/4.4 (N=2..32); `mn_mutex`, `mn_cpu` unchanged. `chan_recv` with `Option_vt` is still
    there and still allocates. Direct hand-off to a parked receiver is not implemented.

  Next, in order of expected payoff: **G3**, a lock-free (MPMC, e.g. Vyukov) ring in the channel with the lock kept only for parking:
  the remaining `mn_pipeline` cost is the two channel locks' cache lines bouncing between cores (IPC about 0.28 at N=4); **H2**,
  `mn_spawn` at N>=2: a per-worker free list for small closure blocks and/or longer idle spinning between batches.
  M:N now pays off for fine-grained communication between independent streams (ping-pong), compute fibers and mutex-heavy
  code; a single producer/consumer chain through a channel (the pipeline) wins at N=1 and loses to Go at N>=4.
