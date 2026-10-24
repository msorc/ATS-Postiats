# Quickstart

This page takes you from an installed ATS2 to a first program that owns
heap memory. Install first: see [INSTALL](../../INSTALL). Then
`patscc --version` prints the version (0.4.3 here) and `which patscc` tells
you which installation you are running.

## Hello, world

`hello.dats`:

```ats
#include "share/atspre_staload.hats"
implement main0 () = println! ("Hello, world!")
```

```sh
patscc -o hello hello.dats
./hello
```

```
Hello, world!
```

`#include "share/atspre_staload.hats"` loads the prelude, the standard
library that every program uses. `main0` is the `main` function that takes
no argument and returns nothing. `patscc` runs `patsopt` (ATS to C) and
then your C compiler; it needs no flag. Useful variations:

```sh
patscc -O2 -o hello hello.dats      # flags for the C compiler go through
CC=clang patscc -o hello hello.dats # the C compiler is ${CC:-cc}
patscc -tcats hello.dats            # typecheck only (also: patsopt --typecheck -d hello.dats)
patscc -ccats hello.dats            # only make hello_dats.c
```

## A program that owns memory

ATS2 has no garbage collector. Heap data are linear values: the compiler
checks that each one is used exactly once, so it must be freed (or passed
on) by its owner, and cannot be used after that. A list of integers:

`sum.dats`:

```ats
#include "share/atspre_staload.hats"

fun sum (xs: !List_vt(int)): int =
  case+ xs of
  | list_vt_nil () => 0
  | list_vt_cons (x, xs1) => x + sum (xs1)

implement main0 () = {
  val xs = $list_vt{int}(1, 2, 3, 4)
  val () = println! ("sum = ", sum (xs))
  val () = list_vt_free (xs)
}
```

```sh
patscc -o sum sum.dats && ./sum
```

```
sum = 10
```

The `!` in `!List_vt(int)` means that `sum` borrows the list: it looks at
it and gives it back. `main0` owns `xs` and has to free it. Delete the line
with `list_vt_free` and the compiler refuses the program:

```
error(3): the linear dynamic variable [xs$3303(-1)] needs to be consumed but it is preserved with the type [...] instead.
```

That is the whole idea; the leak is a compile-time error. To check a
program at run time as well, compile it with the address sanitizer:
`patscc -g -fsanitize=address -o sum sum.dats && ./sum`.

## What you cannot write

The compiler rejects the constructs that would allocate heap data which no
one can free: a `datatype` with a non-nullary constructor, a `cloref`
closure, a boxed tuple or record, `$delay` and `$list_t`. Each message tells
what to use instead; the [FAQ](faq.md) lists them with the replacements, and
the [migration guide](migrating-from-0.4.2.md) shows the before and after of
the usual code.

## A Makefile

The examples of the repository build with `share/atsmake-pre.mk`, but a
plain Makefile is enough:

```make
PATSCC = patscc
%: %.dats ; $(PATSCC) -O2 -o $@ $<
```

## Next

* The books in [doc/BOOK](../BOOK): *Introduction to Programming in ATS*
  (from the language basics to dependent types and linear views) and the
  *ATS2 tutorial* (the libraries).
* The examples in [doc/EXAMPLE](../EXAMPLE), starting with
  [INTRO](../EXAMPLE/INTRO) and [LINHEAP](../EXAMPLE/LINHEAP).
* `man patscc`, `man patsopt`.
* The library sources: `prelude/SATS/*.sats` and `libats/SATS/*.sats` are
  their own documentation (the interfaces are commented).
