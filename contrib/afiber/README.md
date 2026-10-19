# afiber

Stackful cooperative green threads for ATS2, with no GC (MIT license).

A fiber owns a C stack (mmap'd, with a guard page) and is switched by a
small assembly routine on x86-64 (`ucontext` elsewhere, or with
`-DATSCNTRB_AFIBER_UCONTEXT`); by default all fibers run on one OS thread,
and `afiber_workers_start(n)` spreads them over n OS threads (M:N, below).
Fibers are scheduled cooperatively
(round-robin at `afiber_yield`, parked by `afiber_join`, `afiber_sleep_*`,
the wait queues and the channels). Exceptions work inside a fiber: each
fiber has its own handler chain. Every function of the
prelude and of libats can block inside a fiber.

## Files

- `SATS/afiber.sats`, `DATS/afiber.dats`, `CATS/afiber.cats`: fibers.
  `afiber_spawn (llam () => ...)` returns a linear `afiber_vt` that must be
  joined (`afiber_join`) or detached (`afiber_detach`); `afiber_yield`,
  `afiber_sleep_ns/usec/msec`, `afiber_run_until_done` (main only: park
  until no fiber is left), wait queues (`afiber_waitq_*`, protected by an
  `afiber_spin` the caller holds) as the parking primitive, `afiber_mutex`,
  and the M:N calls `afiber_workers_start/stop`, `afiber_nworkers`,
  `afiber_worker_id`, `afiber_ncpu`.
- `SATS/afiberchan.sats`, `DATS/afiberchan.dats`, `CATS/afiberchan.cats`:
  reference-counted bounded channels. `chan_make<T>(cap)`, `chan_ref`,
  `chan_send`/`chan_recv` (park while full/empty), `chan_trysend`/
  `chan_tryrecv`, `chan_close`, `chan_unref` (the last owner gets the
  unreceived items back as a `List_vt(T)`). Linear values move through.
- `TEST/`: `make -C TEST testall` (and `leakcheck` with AddressSanitizer).
- `doc/PLAN.md`: the options analysis, the design, and the status (what is
  implemented, departures from the plan, open items).

## Use

```
#include "share/atspre_staload.hats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"
staload "contrib/afiber/SATS/afiberchan.sats"
staload _ = "contrib/afiber/DATS/afiberchan.dats"
```
or `#include "contrib/afiber/mylibies.hats"`. Compile with
`patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC ...` (`_GNU_SOURCE` or
`_XOPEN_SOURCE=700` for `makecontext` in the ucontext build). The default
stack is 256 KiB (`-DATSCNTRB_AFIBER_STACKSZ=...`, or `afiber_spawn_sz` per
fiber); a stack overflow hits the guard page. Default-size stacks are
recycled through a free list, unbounded unless
`-DATSCNTRB_AFIBER_STACK_CACHE=n` is given; cached stacks are not returned
to the OS. Fresh stacks are carved from slabs of `ATSCNTRB_AFIBER_STACK_SLAB`
stacks (default 32, one `mmap` each; 1 is one `mmap` per stack): a fresh stack
costs one `mprotect` (its guard page) and every 32nd one an `mmap`; the mapping
count stays two per stack. `-DATSCNTRB_AFIBER_NOGUARD` drops the guard page, so a
fresh stack costs no syscall, but a stack overflow is then silent memory
corruption: use it only when the fibers are known to fit. The record of a fiber
lives in the top of its own stack (no `malloc` per spawn). The slab is not used
with `-DATSCNTRB_AFIBER_STACK_MALLOC`. The part of a slab not carved yet stays
mapped (untouched, `MAP_NORESERVE`) until `afiber_workers_stop`, or the exit
of a one-worker program. All units of a program must use the same `ATSCNTRB_AFIBER_*`
settings. `-DATSCNTRB_AFIBER_RUNNEXT_WAIT_NS=n` (default 3000) is the time an idle worker waits before it steals a `runnext` slot
(M:N only). `-DATSCNTRB_AFIBER_SINGLE` is for programs that never start workers:
it compiles the M:N paths out and restores the pre-M:N one-worker cost
(`afiber_workers_start(n > 1)` is then fatal). `make -C TEST regress_variants`
runs the tests with the ucontext, malloc'd-stack, bounded-cache, no-guard, SLAB=1 and SINGLE builds. `BENCH/` has afiber vs Go
benchmarks (`make -C BENCH bench`). If main returns while fibers are
suspended they are discarded; an uncaught exception in a fiber ends the
process; a deadlock (every fiber parked) aborts with a message.

## M:N

```
val () = afiber_workers_start (afiber_ncpu ()) // n counts the main thread
... spawn, channels, mutexes ...
val () = afiber_run_until_done ()
val () = afiber_workers_stop ()                // optional: join the threads
```
Compile every unit with `-pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_
-D_GNU_SOURCE`: the macro keeps the generated program from including the
runtime's exception-frame head (a process global), and afiber supplies
one per fiber, so a fiber can move between threads inside a `try`.
Without it `afiber_workers_start (n > 1)` aborts with a message. Each
worker has its own run queue (a `runnext` slot and a ring, as in Go's
scheduler) and idle workers steal half of a busy one's ring; a global
FIFO takes the overflow and the sleepers. The main fiber stays on the
main thread. A fiber
may resume on another OS thread after any call that can block: do not
keep `errno` or other thread-local state across one. Shared data needs a
channel, an `afiber_mutex` (not FIFO under contention: it spins briefly before parking) or an `afiber_spin`; the global arena of
`libats/arena` is not thread-safe. Tests: `make -C TEST stress`,
`make -C TEST stress16`. Without `afiber_workers_start` nothing changes:
one thread, FIFO order, deterministic.
