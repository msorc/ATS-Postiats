# Benchmark results after step 1 of the speed-up plan (one worker and M:N)

Measured 2026-10-18 (late evening) into 2026-10-19 00:00 local, on: AMD Ryzen 9 5950X (16 cores, 32 threads, `nproc` = 32),
Linux 7.1.13-2-MANJARO, gcc 16.2.1 `-O2 -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, go 1.27.0. Median of 7 runs for the
one-worker suite, 5 for the M:N suite. The machine was otherwise idle at the start of the run. All numbers are from this one
machine. N = 32 means 32 hardware threads (16 physical cores with SMT), not 32 cores.

The run before step 1 (M:N library at 4552ac427) is in `results_step0.md`; "before step 1" below is that library, built
as a `BEFORE=` binary on the same machine. Step 1 of the plan in `doc/PLAN.md` is these commits on `afiber-mn`:

- 96a839698 scheduler and worker fields on separate cache lines (64-byte aligned groups, static asserts)
- e5669fc12 mutex fast path (one atomic exchange) and a 4x30 `pause` spin before parking; no longer FIFO under contention
- fbd59b06a `ATSCNTRB_AFIBER_SINGLE`: compile-time one-worker mode, compiles the M:N paths out
- bb131d93d BENCH: `spawn` after a warm-up batch, new `spawn_cold` row, N=16 column, `bench_ats_single` column
- a4f2cf9be BENCH `run.py` prints "-" where a `BEFORE=` binary lacks a benchmark
- 7723c22ae the mutex slow path announces (`nwait++`) before it looks: fixes a lost wake-up found in review
- f555d9e7e `POS_mn_mutex2` regression test (two fibers on two workers contending for one mutex)

## One-worker suite (`make bench`, with `bench_ats_single` built and `BEFORE=` the 4552ac427 binary)

Columns: `afiber` is the new library, default build (one worker, no `afiber_workers_start`); `afiber SINGLE build` is
compiled with `-DATSCNTRB_AFIBER_SINGLE`; `afiber before step 1` is the library at 4552ac427 (it has no `spawn_cold`, hence "-").

| benchmark | ops | afiber ns/op | afiber SINGLE build ns/op | afiber before step 1 ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| spawn | 200000 | 135.9 | 126.0 | 643.3 | 240.7 | 220.6 | 1.77x faster |
| spawn_cold | 10000 | 10392.1 | 10407.7 | - | 775.5 | 339.1 | 13.40x slower |
| yield | 1000000 | 17.5 | 14.7 | 17.1 | 68.2 | 116.8 | 3.90x faster |
| pingpong | 1000000 | 34.9 | 29.8 | 35.0 | 145.0 | 142.1 | 4.16x faster |
| pipe | 5000000 | 15.4 | 13.5 | 14.7 | 34.9 | 35.8 | 2.26x faster |
| fanin | 5000000 | 15.8 | 13.6 | 15.1 | 34.6 | 49.8 | 2.18x faster |
| chain | 30000 | 10885.7 | 10849.4 | 10969.5 | 1698.3 | 1401.3 | 6.41x slower |
| sieve | 1500 | 46633.4 | 43158.0 | 45657.3 | 111839.0 | 25070.6 | 2.40x faster |

| memory (parked fibers) | tasks | afiber KB/task | afiber SINGLE build KB/task | afiber before step 1 KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|---:|---:|
| mem | 30000 | 4.17 | 4.17 | 4.17 | 2.71 | 3.20 |

One worker, default build, against "before step 1": unchanged within noise (yield 17.5 vs 17.1 ns, ping-pong 34.9 vs 35.0,
pipe 15.4 vs 14.7, fan-in 15.8 vs 15.1, chain 10886 vs 10970, sieve 46.6 vs 45.7 us per prime, memory 4.17 KB unchanged):
the new layout costs nothing at one worker. The SINGLE build restores the pre-M:N cost: yield 14.7, ping-pong 29.8,
pipe 13.5, fan-in 13.6, sieve 43.2 us per prime; the pre-M:N figures in `README.md` (measured the same day on this machine)
are 16.0 / 29.9 / 13.6 / 13.8 / 41.7.

`spawn` went from 643 to 136 ns because the benchmark now runs one untimed warm-up batch, not because the library
got faster: the old row's mean was dominated by the first batch of 10,000 fibers, each paying a fresh `mmap` + `mprotect`.
The steady state (stacks from the free list) is 136 ns, 1.8x faster than Go P=1 (241 ns). `spawn_cold`, that first batch
(10,000 fibers on fresh stacks), costs 10.4 us per fiber, 13x slower than Go's 776 ns. The old "spawn is 2x slower than
Go" statements described the cold batch averaged into the steady state. Chain (30,000 live fibers, all stacks fresh) is
unchanged at 10.9 us, 6.4x slower than Go.

## M:N suite (`make benchmn`)

Same work in both languages, total work is fixed so N only changes how many threads share it:
mn_pingpong 16 pairs, 1.6M messages (cap 1); mn_pipeline 1 source, 8 stages, 1 sink, 2M items (cap 128);
mn_cpu 64 fibers, 512M LCG steps in all, a yield per 1000 steps; mn_spawn 200000 fibers in batches of 1000
spawn+join; mn_mutex 32 fibers, 2M lock/inc/unlock (afiber_mutex vs sync.Mutex).

ns per op, median of 5 runs (afiber: N workers; go: GOMAXPROCS=N)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 28.7 | 164.0 | 325.8 | 413.0 | 641.0 | 1018.4 |
| mn_pingpong | go | 144.2 | 102.0 | 68.8 | 48.6 | 39.3 | 15.6 |
| mn_pipeline | afiber | 31.8 | 140.1 | 250.6 | 408.3 | 352.8 | 510.9 |
| mn_pipeline | go | 74.0 | 97.5 | 95.6 | 109.4 | 113.1 | 109.2 |
| mn_cpu | afiber | 1.2 | 0.6 | 0.3 | 0.3 | 0.7 | 0.9 |
| mn_cpu | go | 1.9 | 1.0 | 0.5 | 0.3 | 0.6 | 0.6 |
| mn_spawn | afiber | 200.8 | 509.6 | 817.1 | 1553.9 | 1659.2 | 2079.4 |
| mn_spawn | go | 230.5 | 223.4 | 211.0 | 228.2 | 250.2 | 266.7 |
| mn_mutex | afiber | 2.0 | 10.3 | 22.4 | 180.1 | 453.9 | 545.3 |
| mn_mutex | go | 4.6 | 30.0 | 78.7 | 63.7 | 58.1 | 59.9 |

speedup of wall time vs the same implementation at N=1 (above 1 = faster)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 1.00 | 0.17 | 0.09 | 0.07 | 0.04 | 0.03 |
| mn_pingpong | go | 1.00 | 1.41 | 2.09 | 2.97 | 3.67 | 9.24 |
| mn_pipeline | afiber | 1.00 | 0.23 | 0.13 | 0.08 | 0.09 | 0.06 |
| mn_pipeline | go | 1.00 | 0.76 | 0.77 | 0.68 | 0.65 | 0.68 |
| mn_cpu | afiber | 1.00 | 1.90 | 3.63 | 3.71 | 1.75 | 1.35 |
| mn_cpu | go | 1.00 | 1.90 | 3.65 | 6.00 | 3.32 | 2.88 |
| mn_spawn | afiber | 1.00 | 0.39 | 0.25 | 0.13 | 0.12 | 0.10 |
| mn_spawn | go | 1.00 | 1.03 | 1.09 | 1.01 | 0.92 | 0.86 |
| mn_mutex | afiber | 1.00 | 0.19 | 0.09 | 0.01 | 0.00 | 0.00 |
| mn_mutex | go | 1.00 | 0.15 | 0.06 | 0.07 | 0.08 | 0.08 |

afiber time / go time at the same N (above 1 = afiber slower)

| benchmark | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | 0.20 | 1.61 | 4.73 | 8.50 | 16.30 | 65.28 |
| mn_pipeline | 0.43 | 1.44 | 2.62 | 3.73 | 3.12 | 4.68 |
| mn_cpu | 0.65 | 0.65 | 0.65 | 1.05 | 1.23 | 1.38 |
| mn_spawn | 0.87 | 2.28 | 3.87 | 6.81 | 6.63 | 7.80 |
| mn_mutex | 0.43 | 0.34 | 0.28 | 2.83 | 7.81 | 9.11 |

Against the M:N run before step 1 (`results_step0.md`, which has no N=16 column):

* The mutex is the one workload step 1 fixed. `mn_mutex` N=1 2.9 -> 2.0 ns, N=2 76.6 -> 10.3, N=4 82.4 -> 22.4
  (Go 78.7: afiber 3.5x faster), N=8 483.8 -> 180.1, N=32 2731 -> 545; N=16 is new (453.9). From N=8 it is still slower
  than Go (about 60 ns): when the spin fails the fiber parks and wakes through the global run queue under the one
  scheduler lock, and from N=8 the threads span the two L3 complexes of this CPU.
* The cache-line layout gave the lock-bound workloads between 6% and 39%, no more, as predicted: `mn_pingpong` N=2
  249 -> 164, N=4 403 -> 326, N=8 514 -> 413, N=32 1667 -> 1018; `mn_pipeline` N=4 267 -> 251, N=8 537 -> 408,
  N=32 639 -> 511; `mn_spawn` N=8 1935 -> 1554, N=32 2830 -> 2079; `mn_cpu` speedup at N=8 2.85x -> 3.71x, at N=32
  1.19x -> 1.35x.
* The global run-queue lock itself is untouched, so these still lose to Go at N>=2: ping-pong by 1.6x at N=2 and 65x
  at N=32, pipeline 1.4x to 4.7x, spawn 2.3x to 7.8x. Removing that lock is step A of the plan (per-worker queues,
  `runnext`, stealing), not done yet. `mn_cpu` still stops scaling past N=4 (3.71x at N=8, 1.75x at N=16) while Go
  reaches 6.0x at N=8.
* At N=1 afiber is faster than Go on every row (0.20 to 0.87 of Go's time).
