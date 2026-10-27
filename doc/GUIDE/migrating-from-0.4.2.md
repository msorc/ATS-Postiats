# Migrating from ATS2 0.4.2

ATS2 0.4.2 has a garbage collector (Boehm GC) and shares data freely. This
line (0.4.3) has none: heap memory is owned, and the compiler rejects every
nonlinear heap allocation. This page gives the before and after of the
usual constructs. Every "after" program is in
[examples/](examples) and is built, run and leak-checked
(`make -C doc/GUIDE/examples testall`).

The rule behind all of them: a value that lives on the heap is linear.
Whoever holds it either frees it or passes it on; a function that only
looks at it takes it with `!` (borrowed). Values that live in a variable or
inside another value (integers, flat tuples, string literals) are not
affected. The exact messages of the compiler are in the [FAQ](faq.md).

| in 0.4.2 | now |
| --- | --- |
| `list`, `list0` | `list_vt` (`List_vt`) |
| `option`, `option0` | `option_vt` (`Option_vt`) |
| `datatype` with arguments | `datavtype` |
| `cloref`, `cloref1` closures | `cloptr`/`cloptr1` (`llam`), or flat `lam@` |
| `$delay`, `stream`, `lazy` | `$ldelay`, `stream_vt` |
| `arrayref`, `matrixref` | `arrayptr`, `matrixptr` |
| `libats/ML` | the linear containers of `libats` |
| `'(a, b)`, `'{a=1}`, `$tup`, `$rec` | `@(a, b)`, `@{a=1}` |
| `ref` | still there, but only from memory that is never freed (`ref_make_viewptr`); prefer a variable and `&` |
| Boehm GC (`-DATS_MEMALLOC_GCBDW`, `myatscc --gc`) | gone; libc `malloc` is the allocator |

Enumeration-like datatypes (only nullary constructors) are still allowed:
they allocate nothing.

## Build flags

`patscc -DATS_MEMALLOC_LIBC -o prog prog.dats` becomes
`patscc -o prog prog.dats`; the old flag is still accepted. The flags
`-include alloca.h` and `-D_GNU_SOURCE` are not needed. `-lgc` and
`-DATS_MEMALLOC_GCBDW` are gone.

## list and list0 become list_vt

Before:

```ats
val xs = list0_cons (1, list0_cons (2, list0_nil ()))
val ys = list0_map<int><int> (xs, lam x => 2 * x)
val () = println! (ys)       // no free anywhere
```

After ([examples/list_vt.dats](examples/list_vt.dats)):

```ats
fun sum (xs: !List_vt(int)): int =
  case+ xs of
  | list_vt_nil () => 0
  | list_vt_cons (x, xs1) => x + sum (xs1)

implement main0 () = {
  val xs = $list_vt{int}(1, 2, 3, 4)
  val () = println! ("xs = ", xs)
  val () = println! ("sum = ", sum (xs))
//
  implement list_vt_map$fopr<int><int> (x) = 2 * x
  val ys = list_vt_map<int><int> (xs)    // xs is borrowed, ys is new
  val () = println! ("ys = ", ys)
//
  val () = list_vt_free (xs)
  val () = list_vt_free (ys)
}
```

```
xs = 1, 2, 3, 4
sum = 10
ys = 2, 4, 6, 8
```

`$list(...)` and `$lst(...)` now make a `list_vt`; `$list_t(...)` is
rejected. A function that returns a new list (`list_vt_map`) leaves its
argument to its owner; one that consumes (`list_vt_mapfree`, `list_vt_free`)
says so in its type. Read the signature in `prelude/SATS/list_vt.sats`.

## option becomes option_vt

Before: `val r = Some (x)` and a `case` on it.

After ([examples/option_vt.dats](examples/option_vt.dats)). A pattern with
`~` consumes the cell:

```ats
fun find_even (xs: !List_vt(int)): Option_vt(int) =
  case+ xs of
  | list_vt_nil () => None_vt ()
  | list_vt_cons (x, xs1) =>
      if x mod 2 = 0 then Some_vt (x) else find_even (xs1)

val r = find_even (xs)
val () = (
  case+ r of
  | ~Some_vt (x) => println! ("first even = ", x)
  | ~None_vt () => println! ("no even number")
) : void
```

```
first even = 6
```

## datatype becomes datavtype

Before:

```ats
datatype tree = Leaf | Node of (tree, int, tree)
```

After ([examples/datavtype.dats](examples/datavtype.dats)):

```ats
datavtype tree =
  | Leaf of () | Node of (tree, int, tree)

fun size (t: !tree): int =           // reads, does not consume
  case+ t of
  | Leaf () => 0
  | Node (l, _, r) => size (l) + 1 + size (r)

fun tree_free (t: tree): void =      // consumes: ~ in the patterns
  case+ t of
  | ~Leaf () => ()
  | ~Node (l, _, r) => (tree_free (l); tree_free (r))
```

A function that rebuilds a tree takes it by value and returns the new one
(`insert` in the example). A tree that is used twice has to be copied
explicitly, since a datavtype value is never shared.

## fold@ is implied

In 0.4.2 a variable unfolded by an `@Con` pattern had to be folded back
with `fold@` before it was used again as a whole or before the clause
ended. In 0.4.3 the type checker folds it where the folded type is
required: when the variable is returned, passed as an argument or assigned,
and at the end of the scope of the pattern.

```ats
fun bump_head {n:nat} (xs: list_vt (int, n)): list_vt (int, n) =
  case+ xs of
  | @list_vt_cons (x, _) => (x := x + 1; xs)   // no fold@ (xs) before xs
  | list_vt_nil () => xs
```

The code you already have still compiles: an explicit `fold@` is accepted,
and it is still needed between field writes, and when `fold@` is given
explicit static arguments. When the fold cannot be done, the error says
why (for example "the view of field 1 is consumed", or a field of a type
that the constructor does not accept). See
[doc/EXAMPLE/AUTOFOLD](../EXAMPLE/AUTOFOLD) for the programs that are
accepted and the ones that are rejected with their hints.

## cloref becomes cloptr or lam@

Before:

```ats
fun make_adder (y: int): int -<cloref1> int = lam x => x + y
val add5 = make_adder (5)
val () = println! (add5 (add5 1))
```

After ([examples/cloptr.dats](examples/cloptr.dats)). A `cloptr1` closure is
a heap object that you free after the last call; a function that only calls
it takes it as `!(...)`:

```ats
fun make_adder (y: int): (int) -<cloptr1> int =
  lam (x) => x + y

fun twice (f: !((int) -<cloptr1> int), x: int): int = let
  val y = f (x)
in
  f (y)
end

val add5 = make_adder (5)
val () = println! ("twice add5 1 = ", twice (add5, 1))
val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(add5))
```

When the closure is only passed down (never returned or stored), use a flat
closure, which lives in a variable and needs no free:

```ats
fun apply_flat (f: &(int) -<clo1> int, x: int): int = f (x)

val y = 10
var f = lam@ (x: int): int => x + y
val () = println! ("flat = ", apply_flat (f, 1))
```

A function that must be curried and returned (`fun f (x:int) (y:int)`)
returns a `cloptr1`; often a plain two-argument function is what you want.
Higher-order library functions come as templates with a `$fopr` or
`$fwork` function that you implement (as `list_vt_map` above), or in
`_fun` (a plain function) and `_cloptr` (a linear closure) variants.

## $delay becomes $ldelay

Before: `val xs = $delay (stream_cons (1, ...))` with `stream`.

After ([examples/stream_vt.dats](examples/stream_vt.dats)). The stream is
linear, and what is not read is freed with the stream:

```ats
fun from (n: int): stream_vt(int) =
  $ldelay (stream_vt_cons (n, from (n+1)))

val x = stream_vt_nth_exn (from (1), 4)   // consumes the stream
```

```
the fifth natural number = 5
```

`$ldelay (e, f)` takes a second expression, `f`, that frees what `e` would
have consumed if the thunk is dropped unevaluated (see `sieve` in
[doc/EXAMPLE/INTRO/sieve_llazy.dats](../EXAMPLE/INTRO/sieve_llazy.dats)).

## arrayref becomes arrayptr

Before: `val A = arrayref_make_elt<int> (5, 0)`.

After ([examples/arrayptr.dats](examples/arrayptr.dats)):

```ats
val A = arrayptr_make_elt<int> (i2sz(5), 0)
val () = A[1] := 10
val () = A[3] := 30
val () = println! ("A[1]+A[3] = ", A[1] + A[3])
val () = arrayptr_free (A)
```

`arrayptr_free` is for arrays of elements that need no cleanup; for
linear elements free each element first (`arrayptr_freelin`). An array on
the stack is also fine: `var A = @[int][5](0)`.

## libats/ML becomes the linear containers

`libats/ML` (`list0`, `array0`, `hashtbl`, `HashTable`, ...) is gone. Use the
containers of `libats` (`linmap_avltree`, `linset_avltree`,
`hashtbl_chain`, `dynarray`, `lindeque_dllist`, `stkarray`, ...) or, for
compiler-like data with shared nodes, `libats/arena`. After
([examples/containers.dats](examples/containers.dats)):

```ats
staload "libats/SATS/linmap_avltree.sats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/linmap_avltree.dats"

implement compare_key_key<string> (x, y) = compare (x, y)

implement main0 () = {
  var m: map(string, int) = linmap_make_nil{string,int}()
  val-~None_vt() = linmap_insert_opt (m, "one", 1)
  val-~None_vt() = linmap_insert_opt (m, "two", 2)
  val-~Some_vt(v) = linmap_search_opt (m, "two")
  val () = println! ("two -> ", v)
  val () = linmap_free (m)
}
```

The map is updated in place (`&m`) and freed once; the functions that
may find an old value return an `Option_vt` that you must open.

## Boxed tuples and records become flat

Before: `val t = '(1, 2)` and `val r = '{a=1, b=2}` (also `$tup`, `$rec`,
`$tup_vt`, `$rec_vt`).

After ([examples/flat.dats](examples/flat.dats)):

```ats
typedef point = @{x=int, y=int}

fun norm1 (p: point): int = abs (p.x) + abs (p.y)
fun swap (p: point): @(int, int) = @(p.y, p.x)

val p = @{x= ~3, y=4} : point
val @(a, b) = swap (p)
```

Flat tuples and records are values: they are copied, passed and returned
as they are, and need no free. When you need one shared, mutable, heap
allocated record, declare a `datavtype` with one constructor, or a
`vtypedef` over a pointer with its view.

## Checking your port

* `patsopt --typecheck -d prog.dats` reports every remaining rejection
  (the [FAQ](faq.md) explains each one).
* Compile with `-g -fsanitize=address` and run: LeakSanitizer reports any
  heap block that was not freed (the type checker proves this for
  linear values, but C code and `$UNSAFE` casts are outside its reach).
* The sources of the books were ported by the same rules:
  [doc/BOOK/ATS2TUTORIAL/CODE](../BOOK/ATS2TUTORIAL/CODE) has a
  `chap_*.dats` file for each construct above.
