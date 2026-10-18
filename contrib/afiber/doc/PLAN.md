# afiber: green threads for ATS2, plan and status

This is the planning document of `contrib/afiber` (written 2026-10-17/18),
kept with the package and updated to the state of the implementation. The
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
`chan_tryrecv`. The record is a `datavtype` with the capacity, the
reference count, the closed flag, the buffer and two wait queues. The
buffer is a C ring buffer of `cap` slots of `sizeof(a)` bytes; values move
in and out with `$UN.ptr0_set<a>`/`$UN.ptr0_get<a>`. Loops re-check the
state after every wakeup, so wake-ups may be spurious.

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

## Status (2026-10-18)

### Implemented

Everything in the design above is implemented and verified:

- `make -C contrib/afiber/TEST all regress`: 11 POS tests pass, 3 NEG tests
  are rejected with the expected messages.
- `make -C contrib/afiber/TEST leakcheck`: all 11 pass under
  AddressSanitizer with no leak or error reports (before the asm switch the
  only output was ASan's one-line warning about makecontext; on x86-64 it no
  longer occurs).
- `make -C contrib/afiber/TEST regress_variants` runs the suite with
  `-DATSCNTRB_AFIBER_UCONTEXT`, `-DATSCNTRB_AFIBER_STACK_MALLOC` and
  `-DATSCNTRB_AFIBER_STACK_CACHE=8`, so the fallbacks stay exercised.
- x86-64 asm switch: a static naked `atscntrb_afiber__swap` saves
  rbx/rbp/r12-r15/rsp plus MXCSR and the x87 control word (no signal mask,
  no system call); `__create` builds the initial frame by hand and the
  trampoline is entered by `ret`. `-DATSCNTRB_AFIBER_UCONTEXT`, or a
  non-x86-64 target, keeps the ucontext path (untested elsewhere).
- Stack free list: default-size stacks are recycled instead of
  `munmap`ped; unbounded by default, `ATSCNTRB_AFIBER_STACK_CACHE=n` bounds
  it; other sizes (`afiber_spawn_sz`) are not cached. Cached stacks keep
  their dirty pages, so RSS stays at the high-water mark; under ASan the
  shadow of a stack is unpoisoned when it is cached.
- `BENCH/`: afiber vs Go benchmarks (`make -C contrib/afiber/BENCH bench`,
  the tables and their reading are in `BENCH/README.md`). Against Go with
  `GOMAXPROCS=1` on 2026-10-18: yield 16 ns vs 68, channel ping-pong 30 ns
  vs 144, buffered pipe 14 ns vs 35, sieve 2.7x faster; spawn 640 ns vs 290
  and a one-shot chain of 30000 fibers 6x slower, both the cost of a fresh
  `mmap`+`mprotect`+2 page faults per stack that the free list cannot
  cover; 4.2 KB vs 2.7 KB resident per parked fiber. Before the asm switch
  and the free list: yield 500 ns, ping-pong 530 ns, spawn 14.9 µs.
- `make -C doc -f Makefile_test testall` passes with the test directory
  included; `make -C src check` is unaffected (no compiler change).
- A two-unit program (spawn in one `.dats`, yield in another) confirmed
  that the weak-symbol scheduler is shared.
- `#include "contrib/afiber/mylibies.hats"` is enough for a user program.
- Packaging: `doc/DISTRIB/ATEXT/contrib_afiber.atxt` copies README,
  `mylibies.hats`, `doc`, CATS, SATS, DATS and TEST into the distribution.

### Departures from the plan

- Location and license: planned as `libats/afiber*` (GPL header of
  libats); moved to `contrib/afiber` under the MIT license, Copyright (C)
  2026 Mikhail Sorochan. C names use the `atscntrb_afiber` prefix, the
  package name is `ATSCNTRB.afiber`, include paths are `contrib/afiber/...`.
- The channel buffer was planned on `libats/deqarray`. Because template
  implementations are not visible transitively, a user staloading only the
  channel module could not compile; the buffer is a small C ring buffer in
  `CATS/afiberchan.cats` instead, and the package depends on nothing but
  the prelude.
- `-D_ATS_CCOMP_EXCEPTION_NONE_` does not build with the stock runtime at
  all (`pats_ccomp_runtime.c` references the exception type), so the guard
  in `afiber.cats` is checked with a plain C syntax-only compile, not with
  a test program.
- The tests moved with the package (`contrib/afiber/TEST`) instead of
  `doc/EXAMPLE/AFIBER`.

### Gaps and open items

- No fiber-aware I/O: a blocking `read`/`accept` blocks the whole OS
  thread. Needs `poll`/`epoll` bindings, `O_NONBLOCK`, and a readiness
  poller in `schedule()` (the sleep list is the natural place to add it).
- aarch64 asm is a follow-up; other targets use ucontext (deprecated by
  POSIX, absent in musl). Only Linux/glibc/x86-64 has been tested.
- Intel CET shadow stacks (`glibc.cpu.x86_shstk`, opt-in) fault on a
  `ret`-based switch: use the ucontext build there.
- All units of a program must be built with the same
  `ATSCNTRB_AFIBER_UCONTEXT` / `STACK_CACHE` / `STACK_MALLOC` settings,
  because the weak scheduler global embeds the fiber record.
- Cached stacks are not returned to the OS before exit.
- No type-level yield information: nothing stops a yield inside a critical
  section. Option D above (one effect bit in `src/`) would provide it.
- No `afiber_mutex` (a parking one is ten lines on `afiber_waitq`), no
  rendezvous (capacity 0) channels, no `select` over several channels, no
  session-typed endpoints, no structured-concurrency scope.
- Stack overflow is a silent SIGSEGV on the guard page; a `sigaltstack`
  handler with a message is a possible improvement. Fibers cannot be
  cancelled; an uncaught exception in a fiber ends the process.
- One OS thread only. M:N scheduling (option E) needs atomics (no
  `stdatomic` binding yet), a per-thread exception-frame head, and a
  thread-safe global arena.
- Without GNU C (`__attribute__((weak))`) the scheduler falls back to one
  instance per compilation unit, which is wrong for programs that spawn in
  one unit and yield in another.
