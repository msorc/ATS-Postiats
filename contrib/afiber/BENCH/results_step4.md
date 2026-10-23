# Benchmark results after step 4 of the speed-up plan (one worker and M:N)

Measured 2026-10-19 about 16:00 local, on: AMD Ryzen 9 5950X (16 cores, 32 threads, `nproc` = 32),
Linux 7.1.13-2-MANJARO, gcc 16.2.1 `-O2 -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_`, go 1.27.0. Median of 7 runs for the
one-worker suite, 5 for the M:N suite. The machine was idle. All numbers are from this one machine, the same one as
`results_step3.md`. N = 32 means 32 hardware threads (16 physical cores with SMT), not 32 cores.

The run after step 3 is in `results_step3.md` (then `results_step2.md`, `results_step1.md`, `results_step0.md`); "step 3" below is
the library AND the benchmark code at 0015eb145 (the step-3 write-up), built as the `BEFORE=` binary of the one-worker suite
(column "afiber step 3"). That binary has the old benchmark code, which receives with `chan_recv` (a `Some_vt` node per item), so
in the one-worker table the channel gains are the library change and the benchmark's new receive call together (see below).
Step 4 of the plan in `doc/PLAN.md` (steps H, J and G2) is these commits on `afiber-mn`:

- bf3b67e60 BENCH ignores `__pycache__`.
- 8412aae04 step H: worker 0 keeps spinning and stealing (`atscntrb_afiber__main_spin`, bound `ATSCNTRB_AFIBER_MAIN_SPIN_NS`,
  default 200 us, 0 disables) while the main fiber is parked (BLOCKED or WAITALL), some other worker is busy and fibers are alive,
  instead of announcing idle and sleeping on its condvar; the `mainslot` load in `pick_mt` is now an acquire. New test
  `POS_mn_mainwait`. Result: it does not change `mn_spawn` (400-800 ns at N>=2 with the spin on and off; worker 0 entered the spin
  only 139 times in 400,000 spawns, because its own ring is almost never empty when main parks). The wake-up-latency diagnosis of
  the step-3 write-up was wrong for this benchmark; the measured causes are in "What remains". The spin is kept because it is
  bounded, tested and cheap, and it removes a futex round trip whenever main does park while worker 0 is dry (a program whose main
  waits on a long fiber), which this benchmark does not exercise.
- ee51d5981 steps J and G2 (channel): the common paths of `chan_send_opt`, `chan_recv`, `chan_trysend`, `chan_tryrecv` are one C
  call to lock and take the slot (`send_begin`/`recv_begin`, or the try forms) and one to wake a parked partner and unlock
  (`send_end`/`recv_end`), with `send_recheck`/`recv_recheck` after a park (the lock is still held); the `afiber_locked_v` proof is
  threaded through the new dataviews. The fused calls alone changed little: the measured one-worker cost was that every `chan_recv`
  returns `Option_vt(a)` and so mallocs and frees a `Some_vt` node per received item (28% of the ping-pong cycles in the profile),
  which Go's receive never does. New API: `chan_recv_ref(ch, &x): bool` and `chan_tryrecv_ref` (no allocation; the fair
  counterpart of Go's `v, ok := <-ch`), `chan_recv_batch(ch, n): List0_vt(a)` and `chan_send_list(ch, xs)` (one lock acquisition per
  batch). Direct hand-off to a parked receiver is NOT implemented (it needs a slot pointer in the fiber record or a lock-free
  ring); the idea "wake only if the buffer was empty before the push" was rejected, because with several parked receivers it would
  leave one asleep on a non-empty buffer. New tests `POS_chan_batch`, `POS_mn_batch`.
- 2a3f58693 BENCH: `bench.dats` receives with `chan_recv_ref` in every benchmark (so the comparison with Go is like for like:
  neither side allocates per received item); a hand-run `mn_pipeline_batch` (the 8 stages use `chan_recv_batch`/`chan_send_list`
  with batches of up to 16; source and sink still per item) that is not in `run.py`.
- 94538fde0 README and PLAN text for J and G2.

Verification of the merged tree: `make -C contrib/afiber/TEST cleanall regress leakcheck` (27 tests, ASan clean),
`regress_variants` (7 builds), `stress stress16` (14 M:N tests x 200 runs free, 200 pinned to one CPU, 200 at 16 workers; 32
minutes), `make -C doc -f Makefile_test testall` exit 0. ThreadSanitizer runs of the touched M:N tests report nothing.

## One-worker suite (`make bench`, with `bench_ats_single` built and `BEFORE=` the step-3 binary)

Columns: `afiber` is the new library, default build (one worker, no `afiber_workers_start`); `afiber SINGLE build` is
compiled with `-DATSCNTRB_AFIBER_SINGLE`; `afiber step 3` is the library and benchmark at 0015eb145. Units: ns per op; `spawn_cold` and
`chain` are ns per fiber (6776 ns = 6.8 us); `sieve` is ns per prime (36308 ns = 36.3 us).

| benchmark | ops | afiber ns/op | afiber SINGLE build ns/op | afiber step 3 ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| spawn | 200000 | 94.6 | 77.5 | 87.9 | 241.9 | 217.3 | 2.56x faster |
| spawn_cold | 10000 | 6776.3 | 6651.8 | 6707.6 | 761.1 | 319.1 | 8.90x slower |
| yield | 1000000 | 18.0 | 14.8 | 18.0 | 68.6 | 117.8 | 3.82x faster |
| pingpong | 1000000 | 30.5 | 23.8 | 36.8 | 145.6 | 141.9 | 4.78x faster |
| pipe | 5000000 | 8.0 | 6.5 | 15.0 | 34.7 | 36.0 | 4.34x faster |
| fanin | 5000000 | 8.3 | 6.7 | 15.7 | 34.8 | 50.0 | 4.19x faster |
| chain | 30000 | 6999.7 | 6905.9 | 6917.7 | 1754.6 | 1388.1 | 3.99x slower |
| sieve | 1500 | 36308.0 | 32302.5 | 39882.1 | 111398.2 | 25754.0 | 3.07x faster |

| memory (parked fibers) | tasks | afiber KB/task | afiber SINGLE build KB/task | afiber step 3 KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|---:|---:|
| mem | 30000 | 4.03 | 4.03 | 4.03 | 2.71 | 3.21 |

One worker, against step 3 (the "afiber step 3" column; remember that its benchmark code receives with the allocating `chan_recv`):

* **The channel benchmarks are 1.1x to 1.9x faster, because receive no longer allocates.** ping-pong 36.8 -> 30.5 ns (SINGLE
  23.8; Go 145.6, so 4.8x faster), pipe 15.0 -> 8.0 (SINGLE 6.5; Go 34.7: 4.3x), fan-in 15.7 -> 8.3 (Go 34.8: 4.2x), sieve 39.9 ->
  36.3 us per prime (SINGLE 32.3; Go 111.4: 3.1x). The gain is the no-allocation receive: the library's `chan_recv_ref` plus the
  benchmark now calling it. `chan_recv` returning `Option_vt` is still there and still mallocs and frees a `Some_vt` node per item;
  the library change alone, measured with the old benchmark code, was roughly unchanged (ping-pong about 37, pipe about 16).
  Users who care about the per-item cost should receive with `chan_recv_ref`.
* yield 18.0 -> 18.0: unchanged (the library's yield did not change).
* spawn 87.9 -> 94.6 ns (SINGLE 77.5, unchanged): probably noise of this run, to re-check; it is not a known regression (no code
  on the spawn path changed in step 4).
* spawn_cold (6.8 us per fiber), chain (7.0 us per fiber) and memory (4.03 KB per parked fiber) are unchanged (step 3: 6.7 / 6.9 /
  4.03).

## M:N suite (`make benchmn`)

Same work in both languages, total work is fixed so N only changes how many threads share it:
mn_pingpong 16 pairs, 1.6M messages (cap 1); mn_pipeline 1 source, 8 stages, 1 sink, 2M items (cap 128);
mn_cpu 64 fibers, 512M LCG steps in all, a yield per 1000 steps; mn_spawn 200000 fibers in batches of 1000
spawn+join; mn_mutex 32 fibers, 2M lock/inc/unlock (afiber_mutex vs sync.Mutex). All benchmarks receive with `chan_recv_ref`.

ns per op, median of 5 runs (afiber: N workers; go: GOMAXPROCS=N)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 22.2 | 18.8 | 9.5 | 4.9 | 4.1 | 4.4 |
| mn_pingpong | go | 145.0 | 101.5 | 69.7 | 52.9 | 38.8 | 16.1 |
| mn_pipeline | afiber | 17.2 | 78.3 | 110.3 | 149.3 | 159.7 | 211.2 |
| mn_pipeline | go | 74.4 | 99.9 | 97.5 | 106.1 | 108.4 | 109.3 |
| mn_cpu | afiber | 1.2 | 0.6 | 0.3 | 0.2 | 0.1 | 0.1 |
| mn_cpu | go | 1.9 | 1.0 | 0.5 | 0.3 | 0.6 | 0.6 |
| mn_spawn | afiber | 133.8 | 361.9 | 433.9 | 490.6 | 544.2 | 751.0 |
| mn_spawn | go | 231.3 | 244.4 | 227.6 | 221.0 | 239.6 | 293.3 |
| mn_mutex | afiber | 1.6 | 11.0 | 19.7 | 25.7 | 24.7 | 23.9 |
| mn_mutex | go | 4.6 | 28.3 | 71.5 | 62.1 | 58.5 | 60.4 |

speedup of wall time vs the same implementation at N=1 (above 1 = faster)

| benchmark | impl | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | afiber | 1.00 | 1.18 | 2.34 | 4.56 | 5.39 | 5.02 |
| mn_pingpong | go | 1.00 | 1.43 | 2.08 | 2.74 | 3.74 | 9.00 |
| mn_pipeline | afiber | 1.00 | 0.22 | 0.16 | 0.12 | 0.11 | 0.08 |
| mn_pipeline | go | 1.00 | 0.74 | 0.76 | 0.70 | 0.69 | 0.68 |
| mn_cpu | afiber | 1.00 | 1.98 | 3.94 | 7.84 | 14.24 | 20.78 |
| mn_cpu | go | 1.00 | 1.90 | 3.68 | 6.18 | 3.25 | 2.87 |
| mn_spawn | afiber | 1.00 | 0.37 | 0.31 | 0.27 | 0.25 | 0.18 |
| mn_spawn | go | 1.00 | 0.95 | 1.02 | 1.05 | 0.97 | 0.79 |
| mn_mutex | afiber | 1.00 | 0.15 | 0.08 | 0.06 | 0.07 | 0.07 |
| mn_mutex | go | 1.00 | 0.16 | 0.06 | 0.07 | 0.08 | 0.08 |

afiber time / go time at the same N (above 1 = afiber slower)

| benchmark | N=1 | N=2 | N=4 | N=8 | N=16 | N=32 |
|---|---:|---:|---:|---:|---:|---:|
| mn_pingpong | 0.15 | 0.19 | 0.14 | 0.09 | 0.11 | 0.27 |
| mn_pipeline | 0.23 | 0.78 | 1.13 | 1.41 | 1.47 | 1.93 |
| mn_cpu | 0.65 | 0.62 | 0.61 | 0.51 | 0.15 | 0.09 |
| mn_spawn | 0.58 | 1.48 | 1.91 | 2.22 | 2.27 | 2.56 |
| mn_mutex | 0.35 | 0.39 | 0.28 | 0.41 | 0.42 | 0.40 |

Hand-run `mn_pipeline_batch` (`./bench_ats mn_pipeline_batch 2000000 N`, 2M items, one run each; not part of
`run.py`): the 8 stages take up to 16 items per lock acquisition (`chan_recv_batch`/`chan_send_list`), the source and the sink go per
item. Total time in ns, then ns per item (total / 2e6):

| N | 1 | 2 | 4 | 8 | 16 | 32 |
|---|---:|---:|---:|---:|---:|---:|
| total ns | 51677075 | 47424871 | 95174248 | 140451237 | 152715757 | 206378541 |
| ns per item | 25.8 | 23.7 | 47.6 | 70.2 | 76.4 | 103.2 |
| `mn_pipeline` (per item, above) | 17.2 | 78.3 | 110.3 | 149.3 | 159.7 | 211.2 |
| Go `mn_pipeline` | 74.4 | 99.9 | 97.5 | 106.1 | 108.4 | 109.3 |

Against step 3 (`results_step3.md`) and against Go:

* **`mn_pipeline` is better, still not Go's.** N=1/2/4/8/16/32: 30.9 / 94.0 / 135.7 / 186.5 / 192.5 / 252.2 -> 17.2 / 78.3 / 110.3 / 149.3 /
  159.7 / 211.2 ns (Go 74.4 / 99.9 / 97.5 / 106.1 / 108.4 / 109.3). afiber is below Go at N=2 (0.78 of its time); from N=4 it is 1.1x to
  1.9x slower (was 1.3x to 2.3x). It still does not scale: 0.08 of its N=1 speed at N=32 (Go 0.68), the cause is the two channel-lock cache
  lines, see below. The gain is again the no-allocation receive (the step-3 numbers allocate a node per item).
* **The batch variant** (25.8 / 23.7 / 47.6 / 70.2 / 76.4 / 103.2 ns per item) is under Go at every N, by 2.9x at N=1 and 1.05x at N=32,
  but it is a different program (fewer lock acquisitions per item by construction), not the like-for-like row.
* `mn_pingpong` N=1/2/4/8/16/32 28.4 / 22.1 / 11.2 / 5.8 / 4.7 / 5.7 -> 22.2 / 18.8 / 9.5 / 4.9 / 4.1 / 4.4 ns (Go 145.0 / 101.5 / 69.7 / 52.9 /
  38.8 / 16.1): 13% to 23% better (the no-allocation receive), 0.09 to 0.27 of Go's time.
* `mn_mutex` N=2..32 14.0 / 21.6 / 29.8 / 25.1 / 24.3 -> 11.0 / 19.7 / 25.7 / 24.7 / 23.9 ns (Go 28.3 / 71.5 / 62.1 / 58.5 / 60.4): unchanged within the
  spread of a contended mutex (the channel is not involved), 0.28 to 0.42 of Go's time.
* `mn_cpu` is unchanged (speedup 20.78x at N=32 here, 19.19x in step 3; Go 2.87x).
* **`mn_spawn` is unchanged**: N=1..32 134.6 / 356.4 / 482.7 / 513.7 / 541.9 / 725.7 -> 133.8 / 361.9 / 433.9 / 490.6 / 544.2 / 751.0 ns (Go 231.3 / 244.4 /
  227.6 / 221.0 / 239.6 / 293.3), 1.5x to 2.6x slower than Go at N>=2. Step H did not help; the causes are measured below.
* At N=1 afiber is faster than Go on every row (0.15 to 0.65 of Go's time).

## What remains

* **`mn_pipeline` at N>=4: the two channel locks.** All 10 fibers share two channels, so each item takes the same two lock cache lines,
  which bounce between the cores the fibers run on. perf stat at N=4: 1.08e9 cycles for 3.06e8 instructions (IPC about 0.28; before the
  fused calls and the no-allocation receive 1.89e9 / 4.95e8, IPC 0.26): the pipeline is bound by cache-line transfers, not by
  instructions, and not by the scheduler. Batching helps (the batch row above) but cannot be the library's answer for per-item code.
* **`mn_spawn` at N>=2 (362-751 ns against 134 at N=1): futex wake-ups and glibc's malloc arena lock, not main's pinning and not
  stacks.** `strace -c` and `perf`: 5,366 futex calls per 100,000 spawns at N=4 (idle workers sleeping and being woken between the
  1000-fiber batches; at N=1 there are none), and `__lll_lock_wait_private` (the malloc arena lock) in the profile: each fiber's
  closure is allocated by main on the main thread and freed by the fiber on the thread that ran it. Stacks are not the cause: 1,007
  `mprotect` per 100,000 spawns at N=4, the same as at N=1 (the stack cache works across workers). Go pays the same two costs, which
  is why Go's own `mn_spawn` at N>=2 is about 2x its N=1 value too (231 -> 244..293 here).
* `chan_recv` still allocates a `Some_vt` node per item (28% of the ping-pong cycles before the change); `chan_recv_ref` does not.
* The `spawn` 94.6 ns of this run should be re-checked (SINGLE 77.5 and the other one-worker rows did not move).
* A convoy under oversubscription, not a bug: `POS_mn_mutex32` pinned to one CPU (`taskset -c 0`, 4 workers on one CPU) takes 0.2 s
  alone but over 20 s when the machine is loaded: in starvation mode the lock is handed to a parked waiter whose worker thread may
  not be scheduled for a time slice (Go's starvation mode has the same property). Not a configuration the M:N scheduler is for.

Next steps, in order of expected payoff (not measured yet):

* **G3, a lock-free ring in the channel** (MPMC, e.g. a Vyukov bounded queue), the lock kept only for parking, so that the producer and
  the consumer touch different cache lines. A larger change; also the way to a real direct hand-off. Target: `mn_pipeline` at N>=4
  near Go's cost and some scaling.
* **H2, `mn_spawn` at N>=2**: a per-worker free list for small closure blocks (so the fiber's closure is freed on the allocating
  thread's side, or at least off the shared arena lock) and/or longer idle spinning of the workers between the batches, to cut the
  futex round trips.
