(This is the M:N run before step 1 of the speed-up plan, commit 4552ac427. The run after step 1 is `results.md`.)

# Benchmark results, M:N scheduling (afiber workers vs Go GOMAXPROCS)

Measured 2026-10-18 on: AMD Ryzen 9 5950X (16 cores, 32 threads, `nproc` = 32), Linux 7.1.13-2-MANJARO,
gcc 16.2.1 `-O2 -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, go 1.27.0. Median of 5 runs
(7 for the one-worker suite). N = 32 means 32 hardware threads (16 physical cores with SMT), not 32 cores.

## One-worker suite after M:N (`make bench`, run with `BEFORE=` pointing at a binary built from the
## pre-M:N library, `git archive HEAD`, and with `bench_ats_1n` built)

Columns: `afiber` is the new build (`-D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, one worker, no `afiber_workers_start`);
`1:N build` is the new library compiled without that macro; `before M:N` is the previous library, same machine, same hour.
The older recorded numbers are in `results_1n.md`.

| benchmark | ops | afiber ns/op | afiber 1:N build ns/op | afiber before M:N ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| spawn | 200000 | 655.3 | 656.2 | 664.4 | 314.0 | 267.6 | 2.09x slower |
| yield | 1000000 | 17.2 | 18.0 | 16.5 | 71.2 | 122.4 | 4.14x faster |
| pingpong | 1000000 | 35.6 | 35.5 | 30.0 | 144.3 | 142.0 | 4.05x faster |
| pipe | 5000000 | 14.8 | 15.6 | 13.7 | 35.3 | 37.3 | 2.38x faster |
| fanin | 5000000 | 15.1 | 15.7 | 13.9 | 35.4 | 51.1 | 2.34x faster |
| chain | 30000 | 11149.2 | 10958.1 | 10873.7 | 1748.8 | 1376.9 | 6.38x slower |
| sieve | 1500 | 46090.5 | 48026.9 | 40915.1 | 111780.9 | 27272.6 | 2.43x faster |

| memory (parked fibers) | tasks | afiber KB/task | afiber 1:N build KB/task | afiber before M:N KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|---:|---:|
| mem | 30000 | 4.17 | 4.17 | 4.16 | 2.71 | 3.20 |

Cost of M:N support at one worker (afiber, new vs before): yield +4% (17.2 vs 16.5 ns), ping-pong +19%
(35.6 vs 30.0), pipe +8%, fan-in +9%, sieve +13%, spawn and chain within noise (-1%, +2.5%), memory unchanged.
The overhead is the spinlock/atomic traffic of the shared run queue and the post-switch action, which now
run even when there is a single worker. It does not depend on the exception-frame mode (the 1:N build is the same
within noise). Go P=1 is still 2.4-4.1x slower on the channel workloads.

## M:N suite (`make benchmn`)

Same work in both languages, total work is fixed so N only changes how many threads share it:
mn_pingpong 16 pairs, 1.6M messages (cap 1); mn_pipeline 1 source, 8 stages, 1 sink, 2M items (cap 128);
mn_cpu 64 fibers, 512M LCG steps in all, a yield per 1000 steps; mn_spawn 200000 fibers in batches of 1000
spawn+join; mn_mutex 32 fibers, 2M lock/inc/unlock (afiber_mutex vs sync.Mutex).

ns per op, median of 5 runs (afiber: N workers; go: GOMAXPROCS=N)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=32 |
|---|---|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 28.2 | 249.4 | 403.4 | 514.4 | 1667.0 |
| mn_pingpong | go | 145.9 | 106.0 | 73.0 | 56.3 | 15.8 |
| mn_pipeline | afiber | 31.4 | 131.9 | 267.1 | 537.3 | 638.8 |
| mn_pipeline | go | 75.3 | 99.3 | 99.6 | 111.0 | 112.6 |
| mn_cpu | afiber | 1.2 | 0.6 | 0.3 | 0.4 | 1.0 |
| mn_cpu | go | 1.9 | 1.0 | 0.5 | 0.3 | 0.6 |
| mn_spawn | afiber | 200.4 | 526.1 | 769.5 | 1934.7 | 2830.4 |
| mn_spawn | go | 233.9 | 232.9 | 250.9 | 251.2 | 254.7 |
| mn_mutex | afiber | 2.9 | 76.6 | 82.4 | 483.8 | 2731.4 |
| mn_mutex | go | 4.6 | 32.5 | 75.8 | 59.3 | 55.5 |

speedup of wall time vs the same implementation at N=1 (above 1 = faster)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=32 |
|---|---|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 1.00 | 0.11 | 0.07 | 0.05 | 0.02 |
| mn_pingpong | go | 1.00 | 1.38 | 2.00 | 2.59 | 9.23 |
| mn_pipeline | afiber | 1.00 | 0.24 | 0.12 | 0.06 | 0.05 |
| mn_pipeline | go | 1.00 | 0.76 | 0.76 | 0.68 | 0.67 |
| mn_cpu | afiber | 1.00 | 1.89 | 3.59 | 2.85 | 1.19 |
| mn_cpu | go | 1.00 | 1.90 | 3.68 | 5.91 | 2.86 |
| mn_spawn | afiber | 1.00 | 0.38 | 0.26 | 0.10 | 0.07 |
| mn_spawn | go | 1.00 | 1.00 | 0.93 | 0.93 | 0.92 |
| mn_mutex | afiber | 1.00 | 0.04 | 0.03 | 0.01 | 0.00 |
| mn_mutex | go | 1.00 | 0.14 | 0.06 | 0.08 | 0.08 |

afiber time / go time at the same N (above 1 = afiber slower)

| benchmark | N=1 | N=2 | N=4 | N=8 | N=32 |
|---|---:|---:|---:|---:|---:|
| mn_pingpong | 0.19 | 2.35 | 5.52 | 9.13 | 105.43 |
| mn_pipeline | 0.42 | 1.33 | 2.68 | 4.84 | 5.67 |
| mn_cpu | 0.65 | 0.66 | 0.67 | 1.35 | 1.57 |
| mn_spawn | 0.86 | 2.26 | 3.07 | 7.70 | 11.11 |
| mn_mutex | 0.62 | 2.36 | 1.09 | 8.15 | 49.22 |
