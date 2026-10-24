# doc/EXAMPLE/LINHEAP

A test of each rule of the linear heap. ATS2 here has no garbage
collector, and the compiler rejects every nonlinear heap allocation (see
"No GC: heap allocation is linear-only" in [AGENTS.md](../../../AGENTS.md)).
This directory holds one program for each rejected construct, and two
programs that must compile, run and not leak.

```sh
make -C doc/EXAMPLE/LINHEAP regress    # build the POS programs, run them, check every NEG rejection
make -C doc/EXAMPLE/LINHEAP leakcheck  # the POS programs under AddressSanitizer
```

(`PATSHOME` must point at the tree; the Makefile uses `$PATSHOME/bin/patscc`
and `patsopt`.)

## The programs that must be rejected (NEG_*)

Each is passed to `patsopt --typecheck`; the test requires that the
compiler fails with "nonlinear heap allocation is not supported". The exact
messages and what to write instead are in the
[FAQ](../../GUIDE/faq.md).

| file | the rejected construct |
| --- | --- |
| `NEG_datatype.dats` | a `datatype` with a non-nullary constructor |
| `NEG_cloref_fun.dats` | a function declared as a `cloref` closure |
| `NEG_cloref_lam.dats` | a `lam` that is a `cloref` closure |
| `NEG_boxtup.dats` | a boxed tuple `'(1, 2)` |
| `NEG_boxrec.dats` | a boxed record `'{a=1, b=2}` |
| `NEG_tupvt.dats` | a boxed linear tuple `$tup_vt(1, 2)`: it could never be freed |
| `NEG_delay.dats` | `$delay` |
| `NEG_list_t.dats` | `$list_t` |

`NEGUAF_arena.dats` is a different kind of rejection: a use after free. A
handle into an arena is used after `arena_free` consumed the arena, and the
compiler reports that the linear variable "is no longer available".

## The programs that must work (POS_*)

* `POS_linheap.dats`: the supported heap values, all freed: an enumeration
  datatype (allocates nothing), a `datavtype` tree with its free function,
  `$list` (a `list_vt`), flat tuples and records, a `cloptr` closure freed
  with `cloptr_free`, a `$ldelay` value that is evaluated and freed, and a
  linear exception consumed by its handler.
* `POS_arena.dats`: shared (nonlinear) data in an arena (`libats/arena`):
  a syntax tree whose generated encoding (what `utils/arenagen` produces
  from a `.spec` file) shares a subtree between two parents, an evaluator
  and a printer, and one `arena_free` that releases everything.

`make leakcheck` builds both with `-fsanitize=address`, so a leak is a test
failure. The Makefile follows the usual pattern of the examples and has the
`testall` target used by `doc/Makefile_test`.
