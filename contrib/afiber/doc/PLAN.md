# afiber: green threads for ATS2, plan and status

This is the planning document of `contrib/afiber` (written 2026-10-17/18,
status as of 2026-10-19), kept with the package and updated to the state of
the implementation. The
first part is the options analysis and the design as decided; the last
part ("Status") records what was implemented, where it departs from the
plan, and what is still open.

## Context

The goal was green threads (user-level threads scheduled by the program,
not the OS) for ATS2. The repository is the no-GC, self-hosted ATS2: heap
allocation is linear-only, closures that escape are `cloptr` or
`-<lincloptr1>`, the compiler emits plain C with real C calls (tail calls
are same-function `goto`s only), and the `atscc2*` script backends re-parse
that C. The decisions taken: a **library** (no change to `src/`),
**stackful** fibers with their own C stacks, **one OS thread, cooperative**
scheduling, a first phase of spawn/yield/join + linear channels + timer
sleep (no poll-based I/O), and **ucontext** for the stack switch (asm
later). The library is named `afiber` (the `a`-prefix convention of
`athread`), and it lives in `contrib/afiber` under the MIT license.

Why this shape fits the no-GC repository: every existing prelude/libats
function can block inside a fiber (no function colouring, no heap frames),
the entry closure `() -<lincloptr1> void` is the existing
`athread_create_cloptr` idiom, a fiber handle and a channel are ordinary
linear resources, and the freshly re-bootstrapped compiler with md5-pinned
output is left untouched.

## Options considered

| Option | Compiler change | Backends | Blocking anywhere | Verdict |
|---|---|---|---|---|
| **A. Stackful fiber library** | none | C only | yes | **chosen** |
| B. Builtin async/await state machines | large (hidexp transform, effect through typerase, linear frame ownership, no `try` across `await`) | needs `CATS-parsemit` work | only in async fns | later, if ever |
| C. CPS library of `llam` continuations | none | all | only at API boundaries | possible companion for the script backends |
| D. A + one type-level yield effect (`src/pats_effect`, `pats_trans1_effect`, trans3 only) | tiny | C only | yes | phase 2 candidate: proves "no yield under lock" |
| E. M:N over `athread` workers | none (runtime file) | C only | yes | phase 3 candidate: needs atomics, a per-thread exception-frame head, a thread-safe arena |

Notes:

- A is the only option whose cost is entirely in library code and whose
  semantics match every existing library function. Its risks are the stack
  switch (ucontext for portability first, asm later), stack sizing, and the
  discipline of saving the exception-frame head per fiber.
- B is the "language feature" answer. ATS2 has no effect information below
  trans3, no mid-function suspension machinery, and linear locals in a heap
  frame are a research-sized design (every exit path must consume or free
  the frame's linear fields). It also colours the whole library.
- C is the cross-backend story: a tiny "linear continuations + trampoline"
  module; callback style, not green threads.
- D adds what a library cannot: knowing statically that a function does not
  yield. One effect bit, checked in trans3 like `!wrt`, no codegen.
- E is where linear types shine (data moves between OS threads with no
  races) but needs atomics/TLS/arena work first. Design A keeps E open: the
  scheduler state is one C object behind an API, the switch is isolated in
  three C functions, and no API exposes `ucontext`.

Full CPS conversion with trampolining in the compiler was rejected: every
call would allocate a (linear) continuation, no trampoline exists in the
emitter, and the parsemit backends would break.

### Scheduling and communication

- 1:N (one OS thread, cooperative): no data races by construction, the
  global arena and `ref_make_viewptr` globals stay valid, no atomics,
  deterministic. The only hazard is logical atomicity across a yield.
- M:N: later phase on top of a stackful 1:N design.
- Preemption (SIGALRM) interacts with `alloca`, `malloc` and exceptions:
  cooperative only.
- Channels: linear bounded channels as in the INT2PROGINATS `channel_vt`
  example, with scheduler wait queues in place of condvars. Sending a
  linear value is a move; the type checker proves it is not used
  afterwards. Session-typed endpoints (the `libatscc2js` WorkerSession
  scheme) and structured concurrency (a linear nursery that must join every
  fiber before it is freed) are expressible on top.
- I/O integration (fiber-aware read/write/accept/sleep) needs `poll`/`epoll`
  bindings and `O_NONBLOCK`; deferred.

## Facts the implementation relies on (verified in the code base)

- `ccomp/runtime/pats_ccomp_runtime_trywith.c`: the exception frame chain
  head is the process-global static returned by `my_atsexnframe_getref()`;
  frames are `alloca`'d (they live on the fiber's own stack). The fiber
  switch saves/restores the head value per fiber; nothing else in the
  runtime is per-thread. `pats_ccomp_exception.h` is included in the
  generated C before the `%{# %}` blocks of staloaded `.sats`, so a `.cats`
  can call the getter (guarded by `#ifndef _ATS_CCOMP_EXCEPTION_NONE_`).
- `libats/DATS/athread.dats`: the pattern for running a linear closure
  once: `fun app (f: () -<lincloptr1> void) = (f (); cloptr_free($UN.castvwtp0{cloptr0}(f)))`,
  passed as a plain C function pointer plus `void*` env. The C side never
  needs the closure layout.
- `libats/libc/SATS/sys/mman.sats` has only flags and `shm_*`: no
  `mmap`/`munmap`/`mprotect` binding, so stacks are allocated in C.
- `libats/CATS/arena.cats`: a `static` inside an `ATSinline()` function is
  per translation unit. A scheduler must not be per-TU (one file spawns,
  another yields): a weak global.
- No-GC checks (`src/pats_trans3_util.dats`, `src/pats_trans2_decl.dats`):
  records must be `datavtype`/`absvtype`, flat tuples only, `llam` may
  capture linear values, `lam =<cloptr1>` cannot.
- Error texts for the NEG tests: `needs to be consumed but it is preserved`
  and `is no longer available`.
- Template implementations are not visible transitively: a user file that
  staloads only `afiberchan.dats` cannot instantiate templates of a module
  that `afiberchan.dats` staloads (a `staload _ = ".dats"` inside a `.sats`
  does not help either). A library module must therefore avoid depending
  on other template modules, or its users must staload them.

## Design

### C side: `CATS/afiber.cats`

Scheduler in C (the switch, the frame-head swap and the trampoline must be
C anyway; intrusive singly-linked queues through the fiber record cost no
allocation). The record holds the `ucontext_t`, the mmap'd stack (guard
page at the low end), the saved exception-frame head, the state, the
`detached` flag, the entry function and its env (the ATS `app` wrapper and
the closure), the joiner, the queue link, the sleep deadline, the ASan fake
stack and the id. The scheduler object (`main` record, `current`, `prev`,
run queue, deadline-ordered sleep list, one `reap` slot, `nlive`,
`nextid`) is a weak global, `atscntrb_afiber__sched`, so every compilation
unit shares it.

- `switch_to(next)`: set `current`, save/restore `*my_atsexnframe_getref()`,
  ASan `__sanitizer_start_switch_fiber`, `swapcontext`, then on landing
  `__sanitizer_finish_switch_fiber` and reaping of a dead detached fiber.
- `schedule()`: move expired sleepers (CLOCK_MONOTONIC) to the run queue;
  pop next; if none and sleepers exist, `nanosleep` until the earliest
  deadline; if none at all, abort with "deadlock: every fiber is blocked".
- Trampoline (`makecontext`, `uc_link = NULL`): run the entry, mark DEAD,
  wake the joiner or set `reap` if detached, wake main if it waits for all,
  `schedule()`.
- `create`: `ATS_MALLOC` the record, mmap the stack, `getcontext` +
  `makecontext`, frame head NULL (an uncaught exception reaches
  `atsruntime_handle_uncaughtexn` and ends the process, as with athread),
  push to the run queue. Spawning never switches.
- `yield`, `join` (fatal on self-join; frees the stack and record once the
  fiber is dead), `detach`, `sleep_ns`, `run_until_done` (main only), wait
  queues `make/free/is_empty/park/wake_one/wake_all`.
- Stacks: `mmap` + `mprotect` guard page; `ATSCNTRB_AFIBER_STACKSZ`
  (default 256 KiB), `ATSCNTRB_AFIBER_STACK_MALLOC` fallback. Overflow is a
  SIGSEGV on the guard page.
- Needs `-D_GNU_SOURCE` (or `_XOPEN_SOURCE=700`) for `makecontext` and
  `MAP_ANONYMOUS`.

### ATS API: `SATS/afiber.sats`, `DATS/afiber.dats`

`absvtype afiber_vtype = ptr` (linear handle: join or detach),
`afiber_id = lint` (main is 0); `afiber_create_funenv{env:vtype}` and the
detached variant (`mac#`); templates `afiber_spawn`, `afiber_spawn_sz`,
`afiber_spawn_detached`, `afiber_spawn_detached_sz` built on the `app`
wrapper; `afiber_yield`, `afiber_join`, `afiber_detach`, `afiber_get_id`,
`afiber_is_done`, `afiber_self`, `afiber_is_main`, `afiber_nlive`,
`afiber_run_until_done`, `afiber_sleep_ns/usec/msec`, `afiber_clock_ns`,
`afiber_stacksz_default`; `afiber_waitq` (linear) with `make`, `free`
(fatal if a fiber is parked), `is_empty`, `park`, `wake_one`, `wake_all`.

### Channels: `SATS/afiberchan.sats`, `DATS/afiberchan.dats`, `CATS/afiberchan.cats`

`absvtype chan_vtype (a:vt@ype+) = ptr`; `chan_make<a>(cap)`, `chan_ref`,
`chan_unref` (the last owner gets the unreceived items as a `List_vt(a)`),
`chan_unref_type` (nonlinear `a`), `chan_rfcnt`, `chan_capacity`,
`chan_size`, `chan_is_closed`, `chan_close` (idempotent, wakes everyone),
`chan_send_opt` (`Some_vt(x)` back if closed), `chan_send` (fatal if
closed), `chan_recv` (`None_vt` once closed and drained), `chan_trysend`,
`chan_tryrecv`. Since step G (MS-2026-10) `chan_vtype` is the pointer to one
C object (`atscntrb_afiberchan_t`, 64-byte aligned, one allocation): the
first cache line holds the spinlock, the closed flag, the ring `head` and
`n`, the two embedded wait queues and the reference count; the second line
has the read-mostly `cap` and `tsz`; the `cap` slots of `sizeof(a)` bytes
follow. A send on one core and a receive on another so move the first line
and one slot, not the six separate allocations of the first version. The
ATS code makes two C calls per operation on the common path (`send_begin`
locks and returns the slot, `send_end` wakes a receiver and unlocks; `recv_*`
likewise; the proof `afiber_locked_v` is threaded through a dataview indexed
by the returned slot); the values move in and out with
`$UN.ptr0_set<a>`/`$UN.ptr0_get<a>` on the slot pointers. `chan_recv_ref`
returns the item through a reference and allocates nothing; `chan_recv`
boxes it in an `Option_vt`. Loops re-check the state after every wakeup, so
wake-ups may be spurious.

### Tests: `TEST/`

Self-contained Makefile (`all`, `regress`, `leakcheck` with
AddressSanitizer, `cleanall`, `testall`), run by `doc/Makefile_test` as
`../contrib/afiber/TEST`. POS tests: `POS_yield` (deterministic
round-robin), `POS_join`, `POS_many` (10 000 detached 16 KiB fibers),
`POS_recursion` (depth 100 000 on an 8 MiB stack), `POS_sleep` (wake order
and elapsed time), `POS_exn` (exceptions raised and caught by fibers whose
`try` blocks interleave across yields), `POS_pingpong`, `POS_prodcons`
(close, drain, `None_vt`), `POS_linear` (`strptr` and a datavtype through a
channel, one item recovered from `chan_unref`), `POS_trysend`. NEG tests
(must be rejected by the type checker): `NEG_consume_unjoined`,
`NEG_uaf_join_twice`, `NEG_uaf_chan_unref`.

## Phase 3: M:N (option E), design (2026-10-18)

Fibers run on `n` OS threads ("workers"); worker 0 is the program's main
thread, workers 1..n-1 are pthreads started by `afiber_workers_start(n)`.
Without that call (or with `n <= 1`) the scheduler behaves as the 1:N one:
same FIFO order, same deterministic output, same tests. Still a library;
no change to `src/`.

### Facts that shape it

- The `try` macro (`ATStrywith_try`, `pats_ccomp_exception.h`) caches
  `framep = my_atsexnframe_getref()` for the whole `try` block. A fiber
  that yields inside a `try` can resume on another worker, so the head
  can be neither a process global (two workers run fibers at once) nor a
  `__thread` variable (the cached pointer would name the old thread's
  head). It must be a field of the fiber record. The generated `main`
  unit includes `pats_ccomp_runtime_trywith.c` unless
  `_ATS_CCOMP_RUNTIME_TRYWITH_NONE_` is defined; with that macro,
  `afiber.cats` supplies (as weak, identical definitions in every unit)
  `my_atsexnframe_getref` returning `&(current fiber)->exnframe` and a copy
  of `atsruntime_raise`. Then the switch no longer swaps the head. Without
  the macro, the switch swaps the global head as before and
  `afiber_workers_start(n > 1)` is fatal ("compile with
  -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_"). Before the scheduler exists the
  getter initialises it (main thread, main fiber); a thread that is not a
  worker gets a `__thread` fallback head (it cannot use fiber operations).
- The compiler may keep the address of a `__thread` variable across a
  call, and a fiber may come back on another thread. Scheduler code reads
  its worker only through a `noinline` getter with an
  `asm volatile("" ::: "memory")` and re-reads it after every switch. User
  code must not keep `errno` (or other TLS) across a blocking afiber call.
- A fiber that parks is not saved until the switch has happened: it must
  not become visible to another worker before that. Every hand-off is a
  **post-switch action** stored in the worker and run by the context that
  lands (`__resumed`): release a spinlock (park), make the previous fiber
  runnable (yield), finish a dead fiber (mark DEAD, wake the joiner or
  free a detached fiber, decrement `nlive`). The 1:N `reap` slot was the
  first such action.
- An idle worker cannot wait on the stack of the fiber it just left
  (another worker may resume it). Each worker has an **idle context**: the
  native pthread stack for workers 1..n-1, and for worker 0 a small mmap'd
  stack created by `afiber_workers_start`. A worker with nothing to run
  switches to it; the idle loop picks work or waits. In single-worker mode
  there is no idle context: the scheduler sleeps on the current stack as
  before.
- The main fiber is pinned to worker 0 (main-thread-only libraries,
  `exit` from the main thread). It sits in the shared FIFO like any fiber
  (so 1-worker order is unchanged); another worker that pops it moves it
  to worker 0's `main slot` and wakes worker 0; worker 0 looks at its main
  slot before the queue.

### Shape

- Scheduler (weak global): the main fiber record; the worker array
  (`nworkers`, worker 0 embedded); the run queue and the sleep list under
  one spinlock (the "sched lock"); idling through a pthread mutex + condvar
  with an atomic `nidle` count (a pusher pushes, then reads `nidle`; a
  worker going idle increments `nidle`, then re-checks the queue; both with
  seq_cst atomics, so no lost wake-up); `nlive` and `nextid` atomics; a
  stop flag.
- Worker: index, `current`, `prev` (ASan), the idle context, the post
  actions, its pthread, its own stack free list (no lock; a stack can be
  born on one worker and cached on another).
- Fiber record: add a spinlock for the join/detach/death hand-off.
- Idle: with no sleepers and every other worker idle and nothing queued:
  "deadlock: every fiber is blocked". With sleepers: a timed wait until
  the earliest deadline (CLOCK_MONOTONIC condvar).
- Spinlocks: test-and-test-and-set with `__atomic` builtins, `pause`, and
  `sched_yield()` after a number of spins.
- `nworkers == 1` keeps the fast path: no condvar, no idle context.

### API changes

- `afiber_workers_start(n: int)`: main only, once, before or after
  spawning; `n` counts the main thread. `afiber_workers_stop()`: main only,
  after `afiber_run_until_done`; joins the threads and frees the idle
  stacks (for leak checkers). `afiber_nworkers()`, `afiber_worker_id()`
  (0 on the main thread), `afiber_ncpu()`.
- `afiber_spin` (linear handle) with an unindexed proof view
  `afiber_locked_v`: `make`, `free`, `lock: (afiber_locked_v | void)`,
  `unlock (afiber_locked_v | ...)`.
- Wait queues are protected by a spinlock the caller holds:
  `afiber_waitq_park (pf: !afiber_locked_v | q, lk)` releases `lk` after
  the switch and returns with `lk` held again (condvar style);
  `wake_one`, `wake_all`, `is_empty` take `!afiber_locked_v`.
- `afiber_mutex` (parking, fiber-level): `make`, `free`, `lock`, `unlock`,
  built on a spin + a waitq.
- Channels: a spinlock in the channel object; every operation runs under
  it (including `rfcnt` changes).
- Programs that use workers are compiled with `-pthread
  -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_` (and `-D_GNU_SOURCE`).

### Step A: per-worker run queues (2026-10-19)

The one global FIFO under `s->lock` (taken by every `wake` and every `pick`) is replaced, for N >= 2 workers, by
Go's scheduler design (`runqput`/`runqget`/`runqsteal`/`wakep`/`resetspinning`); the one-worker paths are untouched.

- Each worker owns a local queue: `runnext` (one fiber, the last one woken: a woken fiber runs on the waker's worker, so a
  channel ping-pong stays on one core) and a ring of 256 slots (`head` moved by CAS, `tail` written by the owner only).
  `wake` puts the fiber in `runnext` (the fiber it evicts goes to the ring tail); a yielder goes to the ring tail, after its
  switch (post action `POST_YIELD` -> `wake_yield`), so it never runs straight back. A full ring moves half of itself to the
  global FIFO.
- `pick(w)`: main slot (worker 0), `runq_get`, global FIFO (and the expired sleepers; it takes 1/N of the FIFO into the
  ring so the lock is not taken per fiber), then one stealing round (half of a victim's ring). A `runnext` is stolen only in
  the last round of a spinning worker, after 3 us, and if the victim still has nothing else in its ring.
- Wake-ups: a producer pushes, fences, reads `nidle`; it wakes a worker only if none is already `spinning`
  (`nspinning`, claimed by CAS 0 -> 1; the woken worker is flagged). A flagged (or newly dry) worker spins up to 4 rounds of
  `pick`; the last spinner that finds work wakes the next idle worker. A worker that gives up announces itself (`nidle++`),
  looks again (relaxed scan of the global FIFO, the main slot, the sleep deadline `sleep_dl`, every ring and `runnext`) and
  only then waits: one of the two sides sees the other, so no wake-up is lost.
- Main never enters a ring (it is pinned to worker 0 through `mainslot`, under `s->lock`); sleepers stay on `sleepq` under
  `s->lock`, with the earliest deadline mirrored in `sleep_dl` for lock-free checks.
- Tests: `POS_mn_steal` (2000 children of one spawner run on at least two workers), `POS_mn_yieldfair` (8 fibers yielding
  10000 times each all get to run).

### Not in this phase

Fiber-aware I/O; main on any worker (main runs on the main thread's own
stack, so it is pinned to worker 0).

## Status (2026-10-19)

All of the design above is implemented, on `devel` (the work branches
`afiber`, phase 1, and `afiber-mn`, phases 2-3 and the speed-up steps, are
merged; `afiber-mn` is deleted). Nothing here changes `src/`.

### Done

- 1:N: stackful fibers, x86-64 asm switch (ucontext fallback), channels, wait
  queues, sleep, exceptions per fiber; stack slab (`ATSCNTRB_AFIBER_STACK_SLAB`,
  one `mmap` per 32 stacks, one `mprotect` per stack, `ATSCNTRB_AFIBER_NOGUARD`
  for none), per-worker stack free list, the fiber record in its own stack;
  `ATSCNTRB_AFIBER_SINGLE` compiles the M:N paths out.
- M:N (phase 3 and its step A): workers over pthreads, post-switch actions,
  idle contexts, main pinned to worker 0, per-worker `runnext` + 256-slot ring
  with work stealing, one spinner at a time, announce-then-look idling,
  cache-line layout of the scheduler and the workers, worker 0 spinning up to
  `ATSCNTRB_AFIBER_MAIN_SPIN_NS` while main is parked.
- Locks: `afiber_spin` (spinlock with `pause` backoff before `sched_yield`,
  `ATSCNTRB_AFIBER_SPIN_MAXR`/`SPIN_PAUSES`), `afiber_mutex` (Go's
  `sync.Mutex` state machine: locked/woken/starving bits + waiter count, the
  wait queue as the semaphore, FIFO hand-off after 1 ms of starvation).
- Channel: one 64-byte-aligned C object (lock, flags, ring header, both wait
  queues on the first line, slots in the same allocation), common paths in two
  C calls, `chan_recv_ref`/`chan_tryrecv_ref` (no allocation per item),
  `chan_recv_batch`/`chan_send_list`.
- Tests: `TEST/` (27 POS/NEG tests, `regress`, ASan `leakcheck`, 7 variant
  builds, `stress`/`stress16`), run by `doc/Makefile_test`. ThreadSanitizer
  builds of the M:N tests report nothing (`POS_mn_exn` excepted, TSan cannot
  follow a `try` that migrates).
- Benchmarks against Go (`BENCH/`, `make bench`, `make benchmn`); the history
  of the four speed-up steps is `BENCH/results_step0.md` .. `results_step3.md`,
  the current tables `BENCH/results.md`, the reading `BENCH/README.md`.
- Packaging: `doc/DISTRIB/ATEXT/contrib_afiber.atxt`.

Where afiber is faster than Go (idle Ryzen 9 5950X, 2026-10-19, medians): one
worker yield 18 ns vs 69, ping-pong 30.5 vs 146, pipe 8.0 vs 35, fan-in 8.3
vs 35, steady-state spawn 95 vs 242, sieve 36 vs 111 us per prime; M:N
ping-pong 19/9.5/4.9/4.1/4.4 ns at N = 2/4/8/16/32 vs Go 102/70/53/39/16,
`mn_mutex` 11-26 ns vs 28-72, `mn_cpu` scaling 20.8x at N=32 vs 2.9x.

### Where afiber is still slower than Go

The figures are the step-4 run (`BENCH/results.md`); N is the number of
workers (afiber) or `GOMAXPROCS` (Go).

1. **Fresh stacks: `chain` 4.0x, `spawn_cold` 8.9x slower.** A fiber whose
   stack has never been used costs 7.0 us (`chain`: 30,000 fibers alive at
   once, every stack fresh) or 6.8 us (`spawn_cold`: the first 10,000 fibers
   of a process) against Go's 1.75 us and 0.76 us. What is left after the slab
   is one `mprotect` for the guard page and the kernel zeroing the first
   touched 4 KB page (1.07 page faults per fiber); Go's stacks are 2 KB from a
   pooled allocator and need neither. The no-guard build is 3.2 us. A reused
   stack costs nothing of this: steady-state spawn is 95 ns, 2.6x faster than
   Go. Levers: a smaller default stack (`ATSCNTRB_AFIBER_STACKSZ`, the user's
   choice), pre-faulting a slab's top pages in one pass, `NOGUARD` for programs
   whose fibers are known to fit. The floor is the page fault; Go's figure is
   near it.
2. **Memory per parked fiber: 4.03 KB vs 2.71.** One touched page plus the
   128-byte record; Go starts at 2 KB and grows its stacks. Stackful fibers
   cannot grow a stack, so only a smaller default stack with a smaller first
   page footprint could close it. Not planned.
3. **`mn_pipeline` from N=4: 1.1x to 1.9x slower, and no scaling.** One
   source, 8 stages, one sink, 2M items through 9 channels of capacity 128:
   afiber 17/78/110/149/160/211 ns per item at N = 1/2/4/8/16/32, Go
   74/100/98/106/108/109. Below Go at N=2, above from N=4, and 0.08x of its own
   N=1 speed at N=32. Cause (measured): every item takes a channel lock twice
   (send, receive), the ten fibers share the nine locks, and the lock lines
   bounce between cores: 0.28 instructions per cycle at N=4 (perf stat 1.08e9
   cycles for 3.06e8 instructions), 49% of the cycles in `chan_send_opt` and
   44% in `chan_recv`, the scheduler under 8%. Evidence that the lock
   acquisitions are the whole story: the hand-run `mn_pipeline_batch` (the
   stages take up to 16 items per lock acquisition) runs at 26/24/48/70/76/103,
   under Go at every N. Fix: **G3**, a lock-free bounded MPMC ring (Vyukov
   style, one sequence word per slot) with the spinlock kept only for the wait
   queues; the producer and the consumer then touch different lines and park
   only on empty/full. Direct hand-off to a parked receiver (Go's `chansend`
   copies the value onto the receiver's stack) would need the receiver's slot
   pointer in the fiber record; it is a smaller gain and is not planned before
   G3.
4. **`mn_spawn` from N=2: 1.5x to 2.6x slower.** Main spawns 1000 fibers and
   joins them, 200 times: afiber 134/362/434/491/544/751 ns per spawn+join at
   N = 1/2/4/8/16/32, Go 231/244/228/221/240/293. Measured causes: (a) idle
   workers sleep and are woken through futex between the batches, 5,366 futex
   calls per 100,000 spawns at N=4 (none at N=1), each a sleep/wake pair of
   several us; (b) glibc's malloc arena lock (`__lll_lock_wait_private` in the
   profile): each fiber's closure is allocated by main on the main thread and
   freed by the fiber on the thread that ran it. Not the cause: the stacks
   (1,007 `mprotect` per 100,000 spawns at N=4, as at N=1: the per-worker
   caches work) and main's wake-up latency (worker 0 spinning while main is
   parked did not move the numbers; its ring is almost never empty when main
   parks). Go pays (a) and (b) too, which is why its own row is 2x its N=1
   value. Fix: **H2**, a per-worker free list for small closure blocks (the
   `app` wrapper frees the closure on the fiber's thread; return the block to
   the spawning worker's list, or allocate closures from a per-worker slab),
   and a longer bounded idle spin before the condvar so that a worker that will
   be needed within a few us does not sleep.
5. **`mn_pingpong` at N=32: 4.4 ns vs Go's 16.1 is still faster**, but afiber
   scales 5.0x from N=1 while Go scales 9.0x: 16 pairs on 32 hardware threads
   share 16 physical cores and afiber's pairs stay on one worker each (the
   `runnext` hand-off), so the second thread of a core is idle. Not a loss;
   noted so the speedup column is read right.

Not performance, but visible in the tables: the Go column drifts a few percent
between sessions (Go P=1 `spawn_cold` 734 to 775 ns), so the "vs Go" ratios
are not comparable digit for digit across the `results_step*.md` files.

### Other open items

- `chan_recv` returns `Option_vt(a)` and so allocates and frees a node per
  item (28% of the one-worker ping-pong cycles before `chan_recv_ref`);
  programs on the hot path should use `chan_recv_ref`. A later API revision
  could make the no-allocation form the primary one.
- The one-worker `spawn` of 94.6 ns in the step-4 run (87.9 in step 3, the
  SINGLE build unchanged at 77.5) needs a re-check before it is called a
  regression.
- The mutex is not FIFO under contention in the normal mode; after 1 ms of
  waiting it switches to FIFO hand-off. Under oversubscription (several
  workers pinned to one CPU on a loaded machine) a hand-off to a parked waiter
  whose worker thread is not scheduled is a lock convoy: `POS_mn_mutex32` under
  `taskset -c 0` takes 0.2 s alone and over 20 s with the machine loaded. Go's
  starvation mode has the same property; not a configuration the M:N
  scheduler is for.
- The spinlock spins about 30 us before its first `sched_yield`, so a waiter
  pinned to the same CPU as the lock holder pays more than before step 3
  (`-DATSCNTRB_AFIBER_SPIN_OLD` restores 100 pauses then yield).
- No fiber-aware I/O: a blocking `read`/`accept` blocks the whole OS
  thread. Needs `poll`/`epoll` bindings, `O_NONBLOCK`, and a readiness
  poller in the idle loop (the sleep list is the natural place to add it).
  This is the largest functional gap.
- The main fiber is pinned to worker 0 (it runs on the main thread's stack).
  Running main on any worker is an API change (`afiber_main(n, fn)` running
  `fn` on a fiber stack) or a platform question (another thread executing on
  the main thread's stack VMA); not planned.
- No rendezvous (capacity 0) channels, no `select` over several channels, no
  session-typed endpoints, no structured-concurrency scope.
- Stack overflow is a silent SIGSEGV on the guard page (silent corruption
  with `NOGUARD`); a `sigaltstack` handler with a message is a possible
  improvement. Fibers cannot be cancelled; an uncaught exception in a fiber
  ends the process.
- No type-level yield information: nothing stops a yield inside a critical
  section. Option D above (one effect bit in `src/`) would provide it.
- aarch64 asm is a follow-up; other targets use ucontext (deprecated by
  POSIX, absent in musl). Only Linux/glibc/x86-64 has been tested. Intel CET
  shadow stacks (`glibc.cpu.x86_shstk`, opt-in) fault on a `ret`-based
  switch: use the ucontext build there.
- All units of a program must be built with the same `ATSCNTRB_AFIBER_*`
  settings, because the weak scheduler global embeds the fiber record and
  the channel accessors are inline. Without GNU C (`__attribute__((weak))`)
  the scheduler falls back to one instance per compilation unit, which is
  wrong for programs that spawn in one unit and yield in another.
- The global arena and plain `ref`s are not thread-safe; `errno`/TLS must
  not be kept across a blocking call. Cached stacks are not returned to the
  OS before exit (`afiber_workers_stop` drains the caches of a multi-worker
  program).
- `POS_mn_many` keeps under 5000 live fibers at a time: 100,000 live stacks
  exceed `vm.max_map_count` (two mappings per stack, the slab does not change
  that).

### Departures from the plan

- Location and license: planned as `libats/afiber*` (GPL header of
  libats); moved to `contrib/afiber` under the MIT license, Copyright (C)
  2026 Mikhail Sorochan. C names use the `atscntrb_afiber` prefix, the
  package name is `ATSCNTRB.afiber`, include paths are `contrib/afiber/...`.
- The channel buffer was planned on `libats/deqarray`. Because template
  implementations are not visible transitively, a user staloading only the
  channel module could not compile; the channel is one C object in
  `CATS/afiberchan.cats` instead, and the package depends on nothing but the
  prelude.
- The switch was planned on ucontext; x86-64 got an asm switch (no signal
  mask, no system call), ucontext stays as the fallback.
- `-D_ATS_CCOMP_EXCEPTION_NONE_` does not build with the stock runtime at
  all (`pats_ccomp_runtime.c` references the exception type), so the guard
  in `afiber.cats` is checked with a plain C syntax-only compile, not with
  a test program.
- The tests moved with the package (`contrib/afiber/TEST`) instead of
  `doc/EXAMPLE/AFIBER`.
- Fiber `state` is a relaxed atomic (TSan found the mixed accesses); a
  constructor initialises the scheduler so worker 0 is the main thread;
  `afiber_workers_stop` is fatal while fibers are alive and returns the
  scheduler to one worker.
