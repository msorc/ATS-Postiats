# FAQ: what the compiler says, and what to write instead

The messages below are copied from `patsopt` (0.4.3). Source locations
look like `file.dats:7:32-43: error(3): ...` (`file:line:col-col`, or
`file:line:col-line:col` when the range spans lines), followed by the
source line(s) of the range with the range underlined; the older form
`file.dats: 180(line=7, offs=32) -- 191(line=7, offs=43): error(3): ...`
without the source line is selected by `--legacy-errors` or by the
environment variable `PATSOPT_LEGACY_ERRORS=1`. The messages are quoted
with their location and source lines (the closing line `patsopt(TRANS3):
there are [1] errors in total.` and the messages that only follow from the
first one are left out). Types and constraints are printed in the syntax of
the source language; `?1` stands for a type that the compiler has not
determined yet. The code of the rejected
programs is in [doc/EXAMPLE/LINHEAP](../EXAMPLE/LINHEAP) (`NEG_*.dats`),
and the replacements are shown in the [migration guide](migrating-from-0.4.2.md).

Why does the compiler reject these? There is no garbage collector, so every
heap object needs an owner that frees it. A `datatype`, a `cloref` closure
or a boxed tuple is shared freely and has no owner; the compiler cannot
prove that it is ever freed and refuses to allocate it.

## The rules of the linear heap

### a datatype with a non-nullary constructor

```
NEG_datatype.dats:6:10-46: error(2): nonlinear heap allocation is not supported (no GC): the datatype [intlst] has a non-nullary constructor; use [datavtype] instead.
    6 | datatype intlst = nil | cons of (int, intlst)
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

For `datatype intlst = nil | cons of (int, intlst)`. Write `datavtype`
(constructors are then consumed by patterns with `~`, or matched by
reference through a `!` argument). A datatype whose constructors are all
nullary (`datatype color = Red | Green | Blue`) is fine.
See [datavtype.dats](examples/datavtype.dats).

### a cloref closure

```
NEG_cloref_lam.dats:9:11-45: error(3): nonlinear heap allocation is not supported (no GC): a cloref closure is constructed; use a linear closure (cloptr) or a function instead.
    9 |   val f = lam (x: int): int =<cloref1> x + y
      |           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

For `lam (x: int): int =<cloref1> x + y`, or a function declared
`:<cloref1>`. If the code does not capture variables, make it a function
(`fun`). If it captures, use `=<cloptr1>` and free it with `cloptr_free`
after the last call, or a flat closure `lam@` that lives in a variable.
See [cloptr.dats](examples/cloptr.dats).

### a boxed tuple

```
NEG_boxtup.dats:7:32-39: error(3): nonlinear heap allocation is not supported (no GC): a boxed tuple is constructed (and could never be freed); use a flat tuple @(...) or a datavtype instead.
    7 | implement main0 () = { val t = '(1, 2) val () = println! (t.0) }
      |                                ^~~~~~~
```

For `'(1, 2)`, `$tup(1, 2)` and also the linear `$tup_vt(1, 2)`: a box
could never be freed. Write `@(1, 2)`; if the data must live on the heap,
declare a `datavtype` with one constructor.

### a boxed record

```
NEG_boxrec.dats:7:32-43: error(3): nonlinear heap allocation is not supported (no GC): a boxed record is constructed (and could never be freed); use a flat record @{...} or a datavtype instead.
    7 | implement main0 () = { val r = '{a=1, b=2} val () = println! (r.a) }
      |                                ^~~~~~~~~~~
```

For `'{a=1, b=2}`, `$rec(...)`. Write `@{a=1, b=2}`.
See [flat.dats](examples/flat.dats).

### $delay

```
NEG_delay.dats:7:32-41: error(3): nonlinear heap allocation is not supported (no GC): $delay constructs a nonlinear lazy value; use $ldelay instead.
    7 | implement main0 () = { val x = $delay(1) }
      |                                ^~~~~~~~~
NEG_delay.dats:7:22-43: error(3): the linear variable x of type lazy_vt(int(1)) is not consumed at the end of its scope
  hint: consume it (free it, return it or pass it on), or declare the parameter as !T
    7 | implement main0 () = { val x = $delay(1) }
      |                      ^~~~~~~~~~~~~~~~~~~~~
```

Write `$ldelay` and the type `stream_vt`/`lazy_vt`. The result is linear:
you will usually see a second error saying that the variable "needs to be
consumed" until you read or free the stream (`stream_vt_free`).
See [stream_vt.dats](examples/stream_vt.dats).

### $list_t

```
NEG_list_t.dats:7:33-51: error(3): nonlinear heap allocation is not supported (no GC): a nonlinear list is constructed; use $list(...) or $list_vt(...) instead.
    7 | implement main0 () = { val xs = $list_t{int}(1, 2) }
      |                                 ^~~~~~~~~~~~~~~~~~
```

For `$list_t{int}(1, 2)`. Write `$list_vt{int}(1, 2)` (`$list(...)` makes
a `list_vt` too). See [list_vt.dats](examples/list_vt.dats).

## Linear types: the errors you will meet most

### a linear value is not consumed (a leak)

```
sum.dats:8:22-11:2: error(3): the linear variable xs of type list_vt(int, 4) is not consumed at the end of its scope
  hint: consume it (free it, return it or pass it on), or declare the parameter as !T
    8 | implement main0 () = {
      |                      ^
    9 |   val xs = $list_vt{int}(1, 2, 3, 4)
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   10 |   val () = println! ("sum = ", sum (xs))
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ...
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
NEGUAF_arena.dats:15:27-29: error(3): the linear variable ar is no longer available (it has been consumed)
   15 |   val () = astring_fprint(ar, stdout_ref, s)
      |                           ^~
```

The value was consumed (freed, passed to a consuming function, or matched
with `~`) and is used again. A common case is the use of an arena after
`arena_free`: nothing derived from it may be used afterwards
([NEGUAF_arena.dats](../EXAMPLE/LINHEAP/NEGUAF_arena.dats)). To use a value
twice, borrow it (`!`) or make a copy (`list_vt_copy`).

### a borrowed value is consumed

```
example.dats:2:43-45: error(3): the linear variable xs must still be available here, but it was consumed
    2 | fun f (xs: !List_vt(int)): List_vt(int) = xs
      |                                           ^~
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

### an `if` or `case` whose branches are linear, inside a `val`

```
NEG_if_linear.dats:11:27-30: error(3): the dynamic expression cannot be assigned the type ?1
   11 |   val res = if x = 0 then res else list_vt_cons(1, res)
      |                           ^~~
NEG_if_linear.dats:11:27-30: error(3): sort mismatch: expected t@ype, actual vtype (of list_vt(int, n))
```

for

```
val res = if x = 0 then res else list_vt_cons(1, res)
```

The `=` is not the problem (a plain `bool` condition fails the same way, and
so does the compiler of 0.4.2): when an `if` or a `case` has no expected
type, its type is a variable (`?1`) of sort `t@ype`, which a linear type (a
`list_vt`, ...: sort `vtype`) cannot instantiate, as the message says.
Give the expected type, either by writing the `if` as the body of a function with a declared result type, or
with an ascription:

```
val res = (if x = 0 then res else list_vt_cons(1, res)): List0_vt(int)
```

(`val res: List0_vt(int) = if ...` is not enough.) See
[POS_if_linear.dats](../EXAMPLE/ERRORS/POS_if_linear.dats) and
[NEG_if_linear.dats](../EXAMPLE/ERRORS/NEG_if_linear.dats).

### a non-tail call to a function of the same `fnx`-group

```
error(ccomp): a non-tail call to a function of the same [fnx]-group (use [fun] instead of [fnx]).
```

The functions of a `fnx ... and ...` group are compiled into one C function
so that their tail-calls become jumps. A call to a function of the group
that is not a tail-call (`1 + g(n-1)`, `list_vt_cons(x, g(xs))`, ...) has no
C function to call. Older compilers (0.4.2 included) did not say so and
produced C code with an implicit declaration of the function. Use
`fun ... and ...` for a group that is not tail-recursive
([NEG_fnx_nontail.dats](../EXAMPLE/ERRORS/NEG_fnx_nontail.dats)).

## Names that are gone

### unrecognized identifier: list0, option0, arrayref, ref

```
example.dats:2:10-24: error(2): unrecognized dynamic identifier [list0_nil].
    2 | val xs = list0_nil{int}()
      |          ^~~~~~~~~~~~~~
example.dats:2:9-31: error(2): the dynamic identifier [arrayref_make_elt] is unrecognized.
    2 | val a = arrayref_make_elt<int>(10, 0)
      |         ^~~~~~~~~~~~~~~~~~~~~~
example.dats:2:9-17: error(2): the dynamic identifier [ref] is unrecognized.
    2 | val r = ref<int>(0)
      |         ^~~~~~~~
```

`list`, `list0`, `option`, `option0`, `stream`, `lazy`, `arrayref` and
`matrixref` do not exist in this prelude. Use `list_vt`, `option_vt`,
`stream_vt`, `lazy_vt`, `arrayptr` and `matrixptr`.
`ref` can only be made with `ref_make_viewptr` from memory that is never
freed (for example a toplevel `var`); most code wants a `var` and `&x`
instead. See the table in the [migration guide](migrating-from-0.4.2.md).

### the file libats/ML/... is not available

```
example.dats:1:1-36: error(1): the file [libats/ML/SATS/basis.sats] is not available for staloading.
    1 | staload "libats/ML/SATS/basis.sats"
      | ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
