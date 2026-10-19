# Benchmark results after step 3 of the speed-up plan (one worker and M:N)

Measured 2026-10-19 about 12:20 local, on: AMD Ryzen 9 5950X (16 cores, 32 threads, `nproc` = 32),
Linux 7.1.13-2-MANJARO, gcc 16.2.1 `-O2 -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, go 1.27.0. Median of 7 runs for the
one-worker suite, 5 for the M:N suite. The machine was idle. All numbers are from this one machine, the same one as
`results_step2.md`. N = 32 means 32 hardware threads (16 physical cores with SMT), not 32 cores.

The run after step 2 is in `results_step2.md` (then `results_step1.md`, `results_step0.md`); "step 2" below is the library at
b8c12e43e, built as the `BEFORE=` binary of the one-worker suite (column "afiber step 2"; the step-2 M:N numbers are those of
`results_step2.md`). Step 3 of the plan in `doc/PLAN.md` (steps G and I) is these commits on `afiber-mn`:

- df816db98 step I, the mutex: `afiber_mutex` is Go's `sync.Mutex` state machine adapted to fibers. One atomic word: bit 0
  locked, bit 1 woken (a waiter is awake and competing, so unlock wakes nobody else), bit 2 starving (after 1 ms of waiting the
  lock is handed to the head of the wait queue, FIFO), the waiter count in bits 3 and up. The wait queue is the semaphore; its
  internal spinlock guards only the queue. Fast path: one CAS. Slow path: 4x30 `pause` while held and not starving, then park.
  The lost-wake-up argument is now a single CAS (announce and look in one word). Before, every unlock woke one waiter, the woken
  fibers lost to spinning bargers and re-parked by the dozen (a fiber switch each), and the internal spinlock was contended by
  all threads. After: at N=8 and N=32, 500,000 operations took about 495,000 slow-path entries but only about 2,900 parks (0.6%).
  New test `POS_mn_mutex32` (32 fibers x 50,000, a yield every 1000th inside the lock and two 2 ms holders, so starvation mode is
  entered and left; the longest wait seen 2-9 ms).
- af6d5bded step G, the channel: one 64-byte-aligned C object (`atscntrb_afiberchan_t` in `CATS/afiberchan.cats`): the first line
  holds the lock, the closed flag, the ring head and count, both wait queues and the refcount; the second line the read-mostly
  capacity and slot size; the slots are in the same allocation. Before, the lock, the ring header, the data and the two wait queues
  were separate mallocs, and a send on one core with a receive on another transferred 4-5 cache lines each. The ATS side
  (`DATS/afiberchan.dats`) is `assume chan_vtype(a) = ptr` with small C accessors; the API in `SATS/afiberchan.sats` is unchanged.
  Also the shared spinlock (`atscntrb_afiber__spin_lock`, used by channels, the mutex queue and the scheduler lock) now spins with
  `pause` and doubling backoff (up to `ATSCNTRB_AFIBER_SPIN_MAXR` = 256 per round) for `ATSCNTRB_AFIBER_SPIN_PAUSES` = 2000 pauses
  before its first `sched_yield`, instead of 100 pauses and then yield; `-DATSCNTRB_AFIBER_SPIN_OLD` restores the old policy.
  Measured on `mn_pipeline` at N=4 (the step-G measurement, 1M items): compact channel alone 286 -> 297 ns (no gain); compact
  channel + new spin policy 142 ns; cycles per instruction 5.4 -> 3.3; `sched_yield` calls 2,398 -> 56 per 1M items; futex calls
  4,079 -> about 2,500. Spin variants tried (cap per round / pauses before yield): 1 (no backoff) 380 ns; 8 210; 64/2000 150;
  256/2000 142 (kept); 256/20,000 140; 1024/100,000 134 but 30x slower when all workers are pinned to one CPU (`taskset -c 0`),
  so rejected. The kept policy is somewhat slower than the old one when pinned to one CPU, which is not a configuration the M:N
  scheduler is for. New test `POS_mn_pipeline` (4-stage chain over capacity-2 channels, 100,000 items, a close with parked
  receivers and a trysend on a full channel).
- 65d4b6688 cleanup: the channel's park wrappers pass the lock field explicitly.

Verification of the merged tree: `make -C contrib/afiber/TEST cleanall regress leakcheck` (24 tests, ASan clean),
`regress_variants` (7 builds), `stress stress16` (12 M:N tests x 200 runs, also pinned to one CPU, also at 16 workers),
`make -C doc -f Makefile_test testall` exit 0. ThreadSanitizer builds of the M:N tests touched by steps G and I report nothing.

## One-worker suite (`make bench`, with `bench_ats_single` built and `BEFORE=` the step-2 binary)

Columns: `afiber` is the new library, default build (one worker, no `afiber_workers_start`); `afiber SINGLE build` is
compiled with `-DATSCNTRB_AFIBER_SINGLE`; `afiber step 2` is the library at b8c12e43e. Units: ns per op; `spawn_cold` and
`chain` are ns per fiber (6694 ns = 6.7 us); `sieve` is ns per prime (40052 ns = 40.1 us).

| benchmark | ops | afiber ns/op | afiber SINGLE build ns/op | afiber step 2 ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| spawn | 200000 | 87.5 | 77.6 | 87.8 | 245.6 | 236.7 | 2.80x faster |
| spawn_cold | 10000 | 6693.8 | 6709.2 | 6735.0 | 774.8 | 299.6 | 8.64x slower |
| yield | 1000000 | 17.9 | 14.7 | 17.3 | 69.0 | 119.1 | 3.85x faster |
| pingpong | 1000000 | 37.0 | 31.9 | 35.6 | 145.5 | 142.4 | 3.93x faster |
| pipe | 5000000 | 15.1 | 12.8 | 16.1 | 35.1 | 36.2 | 2.33x faster |
| fanin | 5000000 | 15.4 | 12.8 | 16.4 | 35.1 | 50.3 | 2.27x faster |
| chain | 30000 | 6984.3 | 6987.6 | 7038.8 | 1685.0 | 1382.6 | 4.15x slower |
| sieve | 1500 | 40052.2 | 35371.0 | 46455.4 | 111509.7 | 26009.2 | 2.78x faster |

| memory (parked fibers) | tasks | afiber KB/task | afiber SINGLE build KB/task | afiber step 2 KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|---:|---:|
| mem | 30000 | 4.03 | 4.03 | 4.03 | 2.71 | 3.20 |

One worker, against step 2 (the "afiber step 2" column, rerun in this session):

* The channel benchmarks got a little faster: pipe 16.1 -> 15.1 ns, fan-in 16.4 -> 15.4, sieve 46.5 -> 40.1 us per prime (the
  SINGLE build 35.4). The compact channel object means fewer cache lines per channel operation even on one core.
* Ping-pong is a little slower: 35.6 -> 37.0 ns (+1.4); the SINGLE build 30.0 -> 31.9 (+1.9). Both builds moved the same way, and the
  SINGLE build has no M:N code, so this is probably real, not noise: most likely the accessor calls in the new ATS channel code on
  a path that does two channel operations per round trip. A thing to look at (step J below), not a blocker.
* yield 17.3 -> 17.9: the library's yield did not change, so this is noise (the SINGLE build: 14.9 -> 14.7).
* spawn (87.5), spawn_cold (6.7 us per fiber), chain (7.0 us per fiber) and memory (4.03 KB per parked fiber) are unchanged
  against step 2 (87.8 / 6.7 / 7.0 / 4.03). Go's rows moved by a few percent between the two sessions (Go P=1 spawn 241 -> 246 ns,
  spawn_cold 734 -> 775), so the "vs go" column of this run is not comparable digit for digit with `results_step2.md`.

## M:N suite (`make benchmn`)

Same work in both languages, total work is fixed so N only changes how many threads share it:
mn_pingpong 16 pairs, 1.6M messages (cap 1); mn_pipeline 1 source, 8 stages, 1 sink, 2M items (cap 128);
mn_cpu 64 fibers, 512M LCG steps in all, a yield per 1000 steps; mn_spawn 200000 fibers in batches of 1000
spawn+join; mn_mutex 32 fibers, 2M lock/inc/unlock (afiber_mutex vs sync.Mutex).

ns per op, median of 5 runs (afiber: N workers; go: GOMAXPROCS=N)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 28.4 | 22.1 | 11.2 | 5.8 | 4.7 | 5.7 |
| mn_pingpong | go | 144.7 | 102.5 | 69.5 | 47.9 | 40.7 | 15.7 |
| mn_pipeline | afiber | 30.9 | 94.0 | 135.7 | 186.5 | 192.5 | 252.2 |
| mn_pipeline | go | 74.4 | 98.9 | 101.2 | 108.2 | 111.6 | 109.2 |
| mn_cpu | afiber | 1.2 | 0.6 | 0.3 | 0.2 | 0.1 | 0.1 |
| mn_cpu | go | 1.9 | 1.0 | 0.5 | 0.3 | 0.6 | 0.6 |
| mn_spawn | afiber | 134.6 | 356.4 | 482.7 | 513.7 | 541.9 | 725.7 |
| mn_spawn | go | 225.5 | 247.1 | 203.1 | 291.8 | 255.9 | 254.2 |
| mn_mutex | afiber | 1.6 | 14.0 | 21.6 | 29.8 | 25.1 | 24.3 |
| mn_mutex | go | 4.6 | 27.6 | 72.7 | 59.5 | 58.0 | 59.0 |

speedup of wall time vs the same implementation at N=1 (above 1 = faster)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 1.00 | 1.29 | 2.53 | 4.90 | 6.06 | 4.96 |
| mn_pingpong | go | 1.00 | 1.41 | 2.08 | 3.02 | 3.55 | 9.23 |
| mn_pipeline | afiber | 1.00 | 0.33 | 0.23 | 0.17 | 0.16 | 0.12 |
| mn_pipeline | go | 1.00 | 0.75 | 0.74 | 0.69 | 0.67 | 0.68 |
| mn_cpu | afiber | 1.00 | 1.99 | 3.92 | 7.82 | 13.34 | 19.19 |
| mn_cpu | go | 1.00 | 1.90 | 3.70 | 6.38 | 3.27 | 2.88 |
| mn_spawn | afiber | 1.00 | 0.38 | 0.28 | 0.26 | 0.25 | 0.19 |
| mn_spawn | go | 1.00 | 0.91 | 1.11 | 0.77 | 0.88 | 0.89 |
| mn_mutex | afiber | 1.00 | 0.12 | 0.07 | 0.05 | 0.06 | 0.07 |
| mn_mutex | go | 1.00 | 0.17 | 0.06 | 0.08 | 0.08 | 0.08 |

afiber time / go time at the same N (above 1 = afiber slower)

| benchmark | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | 0.20 | 0.22 | 0.16 | 0.12 | 0.12 | 0.37 |
| mn_pipeline | 0.42 | 0.95 | 1.34 | 1.72 | 1.72 | 2.31 |
| mn_cpu | 0.65 | 0.62 | 0.61 | 0.53 | 0.16 | 0.10 |
| mn_spawn | 0.60 | 1.44 | 2.38 | 1.76 | 2.12 | 2.85 |
| mn_mutex | 0.35 | 0.51 | 0.30 | 0.50 | 0.43 | 0.41 |

Against step 2 (`results_step2.md`) and against Go:

* **The mutex now beats Go at every N (step I).** `mn_mutex` N=2/4/8/16/32: 11.0 / 36.5 / 207 / 446 / 530 -> 14.0 / 21.6 / 29.8 /
  25.1 / 24.3 ns (Go 27.6 / 72.7 / 59.5 / 58.0 / 59.0). afiber/Go is 0.51 / 0.30 / 0.50 / 0.43 / 0.41 (0.35 at N=1): 2-3x faster
  than Go everywhere, where step 2 was 3.3x to 8.9x slower from N=8. N=2 is 3 ns slower than step 2: a CAS fast path instead of an
  exchange, and the spread of a contended mutex. The cause of the old cost is gone: at N=8 and N=32 only 0.6% of the slow-path
  entries park.
* **The pipeline is much better, still not Go's (step G).** `mn_pipeline` N=2/4/8/16/32: 132 / 302 / 416 / 393 / 448 -> 94.0 / 135.7 /
  186.5 / 192.5 / 252.2 ns (Go 98.9 / 101.2 / 108.2 / 111.6 / 109.2). At N=2 afiber is at Go's cost (0.95); from N=4 it is still
  1.3x to 2.3x slower (was 3.0x to 4.1x). It does not scale (0.33 to 0.12 of its N=1 speed; Go 0.75 to 0.68): 10 fibers share two
  channels, so every item takes the same two channel locks, see the profile below. At N=1 afiber is still 2.4x faster (0.42).
* **Unchanged within noise**: `mn_pingpong` N=2..32 22.1 / 11.2 / 5.8 / 4.7 / 5.7 ns (step 2: 21.8 / 10.9 / 5.7 / 5.1 / 5.3; faster than Go
  at every N, 0.12 to 0.37 of its time); `mn_cpu` speedup 19.19x at N=32 (19.84x in step 2; Go 2.88x); `mn_spawn` N=2..32
  356 / 483 / 514 / 542 / 726 ns (step 2: 346 / 444 / 508 / 516 / 726; Go 203-292), 1.4x to 2.9x slower than Go: the pinned main
  fiber, step H below.
* At N=1 afiber is faster than Go on every row (0.20 to 0.65 of Go's time), as before.

## What remains (profile of `mn_pipeline` at N>=4)

* After step G the cycles per instruction at N=4 fell from 5.4 to 3.3, `sched_yield` calls from 2,398 to 56 per 1M items. The
  remaining cost is the two channel locks that all 10 fibers of the benchmark share: perf shows 49% of the cycles in
  `chan_send_opt` and 44% in `chan_recv`. The scheduler is not the cost.
* `mn_spawn` at N>=2 (356-726 ns against 135 at N=1): the pinned main fiber (a join parks main, worker 0 idles, the child's death wakes
  it with a futex).
* `mn_mutex` is no longer on this list.

Next steps, in order of expected payoff (not measured yet):

* **H, main on any worker**, or stop pinning the benchmark's joins to main (`mn_spawn` near its N=1 value).
* **G2, the pipeline at N>=4**: direct hand-off in the channel (Go copies the value straight to the parked receiver's stack, so the
  receiver does not retake the lock) and/or fewer lock acquisitions per item (batching).
* **J, the one-worker ping-pong regression** of +1.4 ns (SINGLE +1.9) from the new ATS channel code (the accessor calls).
