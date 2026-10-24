# FAQ: what the compiler says, and what to write instead

The messages below are copied from `patsopt` (0.4.3). Source locations
look like `file.dats: 180(line=7, offs=32) -- 191(line=7, offs=43): error(3): ...`;
only the part after `error(N):` is quoted. The code of the rejected
programs is in [doc/EXAMPLE/LINHEAP](../EXAMPLE/LINHEAP) (`NEG_*.dats`),
and the replacements are shown in the [migration guide](migrating-from-0.4.2.md).

Why does the compiler reject these? There is no garbage collector, so every
heap object needs an owner that frees it. A `datatype`, a `cloref` closure
or a boxed tuple is shared freely and has no owner; the compiler cannot
prove that it is ever freed and refuses to allocate it.

## The rules of the linear heap

### a datatype with a non-nullary constructor

```
error(2): nonlinear heap allocation is not supported (no GC): the datatype [intlst] has a non-nullary constructor; use [datavtype] instead.
```

For `datatype intlst = nil | cons of (int, intlst)`. Write `datavtype`
(constructors are then consumed by patterns with `~`, or matched by
reference through a `!` argument). A datatype whose constructors are all
nullary (`datatype color = Red | Green | Blue`) is fine.
See [datavtype.dats](examples/datavtype.dats).

### a cloref closure

```
error(3): nonlinear heap allocation is not supported (no GC): a cloref closure is constructed; use a linear closure (cloptr) or a function instead.
```

For `lam (x: int): int =<cloref1> x + y`, or a function declared
`:<cloref1>`. If the code does not capture variables, make it a function
(`fun`). If it captures, use `=<cloptr1>` and free it with `cloptr_free`
after the last call, or a flat closure `lam@` that lives in a variable.
See [cloptr.dats](examples/cloptr.dats).

### a boxed tuple

```
error(3): nonlinear heap allocation is not supported (no GC): a boxed tuple is constructed (and could never be freed); use a flat tuple @(...) or a datavtype instead.
```

For `'(1, 2)`, `$tup(1, 2)` and also the linear `$tup_vt(1, 2)`: a box
could never be freed. Write `@(1, 2)`; if the data must live on the heap,
declare a `datavtype` with one constructor.

### a boxed record

```
error(3): nonlinear heap allocation is not supported (no GC): a boxed record is constructed (and could never be freed); use a flat record @{...} or a datavtype instead.
```

For `'{a=1, b=2}`, `$rec(...)`. Write `@{a=1, b=2}`.
See [flat.dats](examples/flat.dats).

### $delay

```
error(3): nonlinear heap allocation is not supported (no GC): $delay constructs a nonlinear lazy value; use $ldelay instead.
```

Write `$ldelay` and the type `stream_vt`/`lazy_vt`. The result is linear:
you will usually see a second error saying that the variable "needs to be
consumed" until you read or free the stream (`stream_vt_free`).
See [stream_vt.dats](examples/stream_vt.dats).

### $list_t

```
error(3): nonlinear heap allocation is not supported (no GC): a nonlinear list is constructed; use $list(...) or $list_vt(...) instead.
```

For `$list_t{int}(1, 2)`. Write `$list_vt{int}(1, 2)` (`$list(...)` makes
a `list_vt` too). See [list_vt.dats](examples/list_vt.dats).

## Linear types: the errors you will meet most

### a linear value is not consumed (a leak)

```
error(3): the linear dynamic variable [xs$3303(-1)] needs to be consumed but it is preserved with the type [...] instead.
```

You made or received a linear value (a `list_vt`, a `datavtype`, an
`arrayptr`, a `cloptr`, a stream, ...) and did not free it or pass it on.
Free it (`list_vt_free`, `arrayptr_free`, your own `tree_free`), return it,
or hand it to a function that consumes it. The same message appears for a
function parameter that is declared linear but is not used: if the function
only reads its argument, declare it borrowed with `!`:
`fun f (xs: !List_vt(int)): int`.

### a linear value is used twice, or after it is freed

```
error(3): the linear dynamic variable [ar$3500(-1)] is no longer available.
```

The value was consumed (freed, passed to a consuming function, or matched
with `~`) and is used again. A common case is the use of an arena after
`arena_free`: nothing derived from it may be used afterwards
([NEGUAF_arena.dats](../EXAMPLE/LINHEAP/NEGUAF_arena.dats)). To use a value
twice, borrow it (`!`) or make a copy (`list_vt_copy`).

### a borrowed value is consumed

```
error(3): the linear dynamic variable [xs$3304(-1)] needs to be preserved but it is consumed instead.
```

A parameter `xs: !List_vt(int)` is borrowed: the caller keeps it. Returning
it, freeing it or passing it to a consuming function is an error. Change the
parameter to a consuming one (`xs: List_vt(int)`) or return a copy.

### reading a linear value in a case

A `case+` on a linear value consumes it. To look at it without consuming,
the scrutinee must be a borrowed (`!`) parameter, and the pattern then
binds the fields by reference (as in `size` of
[datavtype.dats](examples/datavtype.dats)); to take it apart, match with `~`
and free or rebuild every part.

## Names that are gone

### unrecognized identifier: list0, option0, arrayref, ref

```
error(2): unrecognized dynamic identifier [list0_nil].
error(2): the dynamic identifier [arrayref_make_elt] is unrecognized.
error(2): the dynamic identifier [ref] is unrecognized.
```

`list`, `list0`, `option`, `option0`, `stream`, `lazy`, `arrayref` and
`matrixref` do not exist in this prelude. Use `list_vt`, `option_vt`,
`stream_vt`, `lazy_vt`, `arrayptr` and `matrixptr`.
`ref` can only be made with `ref_make_viewptr` from memory that is never
freed (for example a toplevel `var`); most code wants a `var` and `&x`
instead. See the table in the [migration guide](migrating-from-0.4.2.md).

### the file libats/ML/... is not available

```
error(1): the file [libats/ML/SATS/basis.sats] is not available for staloading.
```

`libats/ML` is removed. Use the linear containers of `libats`
(`linmap_avltree`, `linset_avltree`, `hashtbl_chain`, `dynarray`, ...) or
`libats/arena`. See [containers.dats](examples/containers.dats).

## Other

### the C compiler complains about -DATS_MEMALLOC_GCBDW or -lgc

The Boehm GC is gone; remove the flags. `-DATS_MEMALLOC_LIBC` is the
default and still accepted.

### "The environment variable PATSHOME is undefined!"

You ran `bin/patsopt` from the build tree without setting `PATSHOME`. Use
an installed `patsopt` (the script of `PREFIX/bin` sets it) or
`export PATSHOME=/path/to/ATS-Postiats`.

### the compiler of 0.4.2 cannot read this tree, and the other way round

The prelude of this line has no `list.sats`, which every ATS2 up to 0.4.2
loads by itself. Do not mix the two installations; `which patsopt` tells
which one you run (see [INSTALL](../../INSTALL), Troubleshooting).

### does a program that compiles have no leak?

For linear values, yes: a leak is a type error. Memory obtained through
C code, `$UNSAFE` casts and `castvwtp` is outside what the checker proves.
Run the tests under `-fsanitize=address` as well.
