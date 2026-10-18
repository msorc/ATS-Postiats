# afiber vs Go benchmarks

`bench.dats` (afiber + afiberchan) and `go/bench.go` run the same eight workloads;
`make bench` builds both and prints the tables (median of 7 runs, `run.py`).
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
(`results_before.md`). The same day afiber got a hand-written x86-64 switch, a free list
of stacks and a channel ring without division:

| benchmark | before ns/op | after ns/op | gain | go P=1 ns/op |
|---|---:|---:|---:|---:|
| spawn+run empty fiber | 14894 | 639 | 23x | 287 |
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
* **Spawn is 2.2x slower than Go** and this is the one-off cost of a fresh stack: the benchmark
  spawns in batches of 10000, so the first batch pays `mmap` + `mprotect` (guard page) + two
  page faults per fiber (~5 µs each, `strace -c`: 10008 `mmap`, 10003 `mprotect`); the other
  19 batches reuse those stacks from the free list at a few hundred ns each. Go reuses goroutine
  stacks the same way but allocates fresh ones from a span, without a syscall per stack.
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
