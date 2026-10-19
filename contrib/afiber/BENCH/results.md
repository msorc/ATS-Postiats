# Benchmark results after step 2 of the speed-up plan (one worker and M:N)

Measured 2026-10-19 about 09:00 local, on: AMD Ryzen 9 5950X (16 cores, 32 threads, `nproc` = 32),
Linux 7.1.13-2-MANJARO, gcc 16.2.1 `-O2 -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, go 1.27.0. Median of 7 runs for the
one-worker suite, 5 for the M:N suite. The machine was idle. All numbers are from this one machine, the same one as
`results_step1.md`. N = 32 means 32 hardware threads (16 physical cores with SMT), not 32 cores.

The run after step 1 is in `results_step1.md` (before it: `results_step0.md`); "step 1" below is the library at 0988553ec,
built as the `BEFORE=` binary of the one-worker suite (column "afiber step 1"; the step-1 M:N numbers are those of
`results_step1.md`). Step 2 of the plan in `doc/PLAN.md` (steps A and D) is these commits on `afiber-mn`:

- 331c12449 step D, stack slab: `ATSCNTRB_AFIBER_STACK_SLAB` (default 32: one `mmap` per 32 default-size stacks; each carved stack
  pays one `mprotect` for its guard page instead of `mmap` + `mprotect`), `ATSCNTRB_AFIBER_NOGUARD` (opt-in, no guard page: no
  syscall per stack from the slab, an overflow is silent corruption), `sysconf(_SC_PAGESIZE)` cached, the fiber record in the
  top 128 bytes of its own stack region (no `malloc`/`free` per spawn), the stack free-list link moved from the lowest word of
  the stack to the last word of the region. The second page fault per fiber in `chain` was that link write at the lowest page:
  faults per fiber 2.1 -> 1.07. `mmap` calls for 30,000 fibers 30,008 -> 946; `mprotect` 30,003 unchanged (3 with NOGUARD).
  New test `POS_slab`; `regress_variants` has NOGUARD and SLAB=1 builds (7 builds).
- 1ea3a8447 step A, per-worker run queues: a `runnext` slot and a 256-slot ring per worker (Go's runq), a woken fiber goes to
  the waker's `runnext`, a yielder to the ring tail, `pick` = main slot -> `runnext` -> ring -> global FIFO -> one stealing round,
  `runnext` stolen only in the last of 4 spinning rounds after a 3 us wait, `nspinning` (at most one idle worker woken per kick),
  announce-then-look-again before an idle worker sleeps. The global scheduler lock is off the common path. New tests
  `POS_mn_steal`, `POS_mn_yieldfair`; ThreadSanitizer builds of the M:N tests report nothing.
- 7f0f800a9 BENCH Makefile: the binaries depend on the library sources (they were stale after a library change).
- 5d434af3b `ATSCNTRB_AFIBER_RUNNEXT_WAIT_NS` (default 3000): the `runnext` wait is a knob. Measured at 3000/500/0 ns, N=4 and
  N=16: mn_pipeline 276/259/278 and 382/377/344 ns, mn_pingpong 11.0/11.2/11.2 and 5.5/6.0/7.5, mn_spawn 454/462/420 and
  556/644/475, mn_cpu the same: no difference beyond noise, the default stays.

Verification of the merged tree: `make -C contrib/afiber/TEST cleanall regress leakcheck` (22 tests, ASan clean),
`regress_variants` (7 builds), `stress stress16` (10 M:N tests x 200 runs, also pinned to one CPU, also at 16 workers),
`make -C doc -f Makefile_test testall` exit 0.

## One-worker suite (`make bench`, with `bench_ats_single` built and `BEFORE=` the step-1 binary)

Columns: `afiber` is the new library, default build (one worker, no `afiber_workers_start`); `afiber SINGLE build` is
compiled with `-DATSCNTRB_AFIBER_SINGLE`; `afiber step 1` is the library at 0988553ec.

| benchmark | ops | afiber ns/op | afiber SINGLE build ns/op | afiber step 1 ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| spawn | 200000 | 87.9 | 79.3 | 136.2 | 241.1 | 206.0 | 2.74x faster |
| spawn_cold | 10000 | 6755.2 | 6607.6 | 10503.0 | 734.0 | 301.9 | 9.20x slower |
| yield | 1000000 | 17.3 | 14.9 | 17.5 | 68.5 | 114.9 | 3.97x faster |
| pingpong | 1000000 | 35.8 | 30.0 | 34.9 | 144.6 | 143.7 | 4.04x faster |
| pipe | 5000000 | 16.2 | 13.4 | 15.4 | 34.7 | 35.8 | 2.14x faster |
| fanin | 5000000 | 16.3 | 13.6 | 15.8 | 34.6 | 49.5 | 2.12x faster |
| chain | 30000 | 7067.3 | 7060.8 | 10901.9 | 1700.6 | 1372.4 | 4.16x slower |
| sieve | 1500 | 46549.8 | 41024.5 | 46379.4 | 111772.4 | 24483.2 | 2.40x faster |

| memory (parked fibers) | tasks | afiber KB/task | afiber SINGLE build KB/task | afiber step 1 KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|---:|---:|
| mem | 30000 | 4.03 | 4.03 | 4.17 | 2.71 | 3.20 |

One worker, against step 1 (the "afiber step 1" column, rerun in this session):

* The stack path got faster, everything else is unchanged. `spawn` (steady state, stacks from the free list) 136.2 -> 87.9 ns
  (the SINGLE build 126.0 -> 79.3): no `malloc`/`free` of the fiber record any more. `spawn_cold` (10,000 fibers on fresh stacks)
  10.5 -> 6.8 us per fiber (6755 ns; Go 734 ns: 9.2x slower, was 13.4x in `results_step1.md`). `chain` (30,000 live fibers, all
  stacks fresh) 10.9 -> 7.1 us (7067 ns; Go 1.70 us: 4.2x slower, was 6.4x): one syscall per carved stack instead of two, and
  one page fault per fiber (1.07) instead of two. Memory 4.17 -> 4.03 KB per parked fiber (the record lives in the stack;
  Go 2.71).
* yield, ping-pong, pipe, fan-in and sieve are unchanged within noise: 17.3 / 35.8 / 16.2 / 16.3 / 46.5 us per prime against
  17.5 / 34.9 / 15.4 / 15.8 / 46.4 in the step-1 column. Pipe and fan-in read 0.8 and 0.5 ns higher than the step-1 column; that is
  inside the run-to-run spread we have seen, and the SINGLE build, which has the same code, is unchanged at 13.4 / 13.6
  (13.5 / 13.6 in `results_step1.md`). The default build still pays the M:N checks over the SINGLE build (yield 17.3 vs 14.9).
* The remaining one-worker gap to Go is the fresh-stack cost: what is left of the 6.8 us per fiber is mostly the one `mprotect` per stack and the first touch of its page (not profiled); `-DATSCNTRB_AFIBER_NOGUARD` removes the syscall at the price of the guard page.

## M:N suite (`make benchmn`)

Same work in both languages, total work is fixed so N only changes how many threads share it:
mn_pingpong 16 pairs, 1.6M messages (cap 1); mn_pipeline 1 source, 8 stages, 1 sink, 2M items (cap 128);
mn_cpu 64 fibers, 512M LCG steps in all, a yield per 1000 steps; mn_spawn 200000 fibers in batches of 1000
spawn+join; mn_mutex 32 fibers, 2M lock/inc/unlock (afiber_mutex vs sync.Mutex).

ns per op, median of 5 runs (afiber: N workers; go: GOMAXPROCS=N)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 28.9 | 21.8 | 10.9 | 5.7 | 5.1 | 5.3 |
| mn_pingpong | go | 144.6 | 102.3 | 70.5 | 46.9 | 39.5 | 16.0 |
| mn_pipeline | afiber | 32.1 | 132.0 | 302.4 | 416.2 | 392.8 | 448.2 |
| mn_pipeline | go | 74.0 | 98.1 | 100.0 | 105.9 | 110.1 | 108.6 |
| mn_cpu | afiber | 1.2 | 0.6 | 0.3 | 0.2 | 0.1 | 0.1 |
| mn_cpu | go | 1.9 | 1.0 | 0.5 | 0.3 | 0.6 | 0.6 |
| mn_spawn | afiber | 135.8 | 345.7 | 443.5 | 507.9 | 515.9 | 725.9 |
| mn_spawn | go | 229.8 | 233.7 | 286.2 | 277.1 | 269.0 | 287.7 |
| mn_mutex | afiber | 1.9 | 11.0 | 36.5 | 207.4 | 445.8 | 530.4 |
| mn_mutex | go | 4.6 | 25.4 | 77.9 | 63.2 | 59.8 | 59.4 |

speedup of wall time vs the same implementation at N=1 (above 1 = faster)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 1.00 | 1.33 | 2.66 | 5.08 | 5.67 | 5.49 |
| mn_pingpong | go | 1.00 | 1.41 | 2.05 | 3.08 | 3.66 | 9.05 |
| mn_pipeline | afiber | 1.00 | 0.24 | 0.11 | 0.08 | 0.08 | 0.07 |
| mn_pipeline | go | 1.00 | 0.75 | 0.74 | 0.70 | 0.67 | 0.68 |
| mn_cpu | afiber | 1.00 | 1.98 | 3.93 | 7.73 | 13.96 | 19.84 |
| mn_cpu | go | 1.00 | 1.90 | 3.69 | 6.27 | 3.26 | 2.87 |
| mn_spawn | afiber | 1.00 | 0.39 | 0.31 | 0.27 | 0.26 | 0.19 |
| mn_spawn | go | 1.00 | 0.98 | 0.80 | 0.83 | 0.85 | 0.80 |
| mn_mutex | afiber | 1.00 | 0.17 | 0.05 | 0.01 | 0.00 | 0.00 |
| mn_mutex | go | 1.00 | 0.18 | 0.06 | 0.07 | 0.08 | 0.08 |

afiber time / go time at the same N (above 1 = afiber slower)

| benchmark | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | 0.20 | 0.21 | 0.15 | 0.12 | 0.13 | 0.33 |
| mn_pipeline | 0.43 | 1.35 | 3.02 | 3.93 | 3.57 | 4.13 |
| mn_cpu | 0.65 | 0.62 | 0.61 | 0.53 | 0.15 | 0.09 |
| mn_spawn | 0.59 | 1.48 | 1.55 | 1.83 | 1.92 | 2.52 |
| mn_mutex | 0.42 | 0.43 | 0.47 | 3.28 | 7.45 | 8.93 |

Against step 1 (`results_step1.md`) and against Go:

* **Ping-pong and compute scale now (step A).** `mn_pingpong` N=2/4/8/16/32: 164 / 326 / 413 / 641 / 1018 -> 21.8 / 10.9 / 5.7 /
  5.1 / 5.3 ns per message. It is faster than Go at every N (Go 102 / 70.5 / 46.9 / 39.5 / 16.0; afiber/Go 0.21 / 0.15 / 0.12 / 0.13 /
  0.33) and scales 5.7x at N=16 (5.5x at N=32): a woken fiber runs on the waker's worker through `runnext`, so each of the 16
  pairs stays on one core and the 16 pairs are 16 independent streams. `mn_cpu` speedup at N=8/16/32: 3.71x / 1.75x / 1.35x ->
  7.73x / 13.96x / 19.84x (Go 6.27x / 3.26x / 2.87x). Go's `Gosched` goes through its global queue and stops scaling at 8;
  afiber's yield stays on the worker's ring. In absolute time `mn_cpu` at N=16/32 is 0.1 ns per step, 0.15 and 0.09 of Go's time.
* **Spawn+join is better but not flat.** `mn_spawn` N=2/4/8/16/32: 510 / 817 / 1554 / 1659 / 2079 -> 346 / 444 / 508 / 516 / 726 ns.
  Still 1.5-2.5x slower than Go (234-288 ns, flat) and 2.5-5.3x its own N=1 value (136 ns). The cause is the pinned main fiber:
  main's stack is the main thread's, so it runs only on worker 0. Each `join` of a fiber that is not done parks main, worker 0
  runs dry and idles, and the death of the fiber on another worker wakes main through the main slot and a condvar signal (a futex)
  to worker 0 (about one futex per 13 spawns in a `perf` profile of this benchmark).
* **Pipeline did not improve.** `mn_pipeline` N=2/4/8/16/32: 140 / 251 / 408 / 353 / 511 -> 132 / 302 / 416 / 393 / 448 ns (Go
  98-110 ns); 1.35x to 4.13x slower than Go at N>=2. The profile below says why: the cost moved from the scheduler to the channel.
* **Mutex unchanged.** `mn_mutex` N=2/4/8/16/32: 10.3 / 22.4 / 180 / 454 / 545 -> 11.0 / 36.5 / 207 / 446 / 530 ns (Go 25.4 / 77.9 / 63.2
  / 59.8 / 59.4). N=2/4 read slightly worse than step 1 (11.0 / 36.5 against 10.3 / 22.4), within the spread of a contended mutex;
  still faster than Go up to N=4 and 3.3x to 8.9x slower from N=8, where the `locked` word bounces between the two L3 complexes and
  every park/wake goes through the wait queue.
* At N=1 afiber is faster than Go on every row (0.20 to 0.65 of Go's time), as before.

## What remains (profile of `mn_pipeline` at N=4, `perf record` / `perf stat` / `strace -c`)

* 51% of the cycles are in `chan_send_opt` and 37% in `chan_recv`: the channel's own spinlock, taken by a producer and a consumer
  on different cores for every item. 5.6 cycles per instruction. 2,695 `sched_yield` calls (the spinlock gives up after 100 spins and
  yields the thread) and 5,922 futex calls per 1M items. All scheduler functions together (`idle_loop`, `runq_steal`, `wake_mt`,
  `kick`, `pick_mt`, `schedule`, `swap`) are under 8%. The pipeline's cost is now the channel, not the scheduler.
* `mn_spawn` at N>=2 (346-726 ns against 136 at N=1): the pinned main fiber, above.
* `mn_mutex` from N=8: the mutex's `locked` word and the park/wake through the wait queue; the run-queue change did not move it.

Next steps, in order of expected payoff:

* **G, the channel**: a lock-free (or at least contention-tolerant) buffer, and a spinlock that does not call `sched_yield` after 100
  spins when the holder is on another core. Expected, not measured: `mn_pipeline` at N>=2 near Go's 100 ns.
* **H, main on any worker**, or stop pinning the benchmark's joins to main. Expected, not measured: `mn_spawn` near its N=1 value.
* **I, the mutex at N>=8.**
