# afiber

Stackful cooperative green threads for ATS2, with no GC (MIT license).

A fiber owns a C stack (mmap'd, with a guard page) and is switched with
`ucontext`; all fibers run on one OS thread and are scheduled cooperatively
(round-robin at `afiber_yield`, parked by `afiber_join`, `afiber_sleep_*`,
the wait queues and the channels). Exceptions work inside a fiber: the
handler chain is saved and restored at every switch. Every function of the
prelude and of libats can block inside a fiber.

## Files

- `SATS/afiber.sats`, `DATS/afiber.dats`, `CATS/afiber.cats`: fibers.
  `afiber_spawn (llam () => ...)` returns a linear `afiber_vt` that must be
  joined (`afiber_join`) or detached (`afiber_detach`); `afiber_yield`,
  `afiber_sleep_ns/usec/msec`, `afiber_run_until_done` (main only: park
  until no fiber is left), wait queues (`afiber_waitq_*`) as the parking
  primitive.
- `SATS/afiberchan.sats`, `DATS/afiberchan.dats`, `CATS/afiberchan.cats`:
  reference-counted bounded channels. `chan_make<T>(cap)`, `chan_ref`,
  `chan_send`/`chan_recv` (park while full/empty), `chan_trysend`/
  `chan_tryrecv`, `chan_close`, `chan_unref` (the last owner gets the
  unreceived items back as a `List_vt(T)`). Linear values move through.
- `TEST/`: `make -C TEST testall` (and `leakcheck` with AddressSanitizer).

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
`_XOPEN_SOURCE=700` for `makecontext`). The default stack is 256 KiB
(`-DATSCNTRB_AFIBER_STACKSZ=...`, or `afiber_spawn_sz` per fiber); a stack
overflow hits the guard page. If main returns while fibers are suspended
they are discarded; an uncaught exception in a fiber ends the process; a
deadlock (every fiber parked) aborts with a message.
