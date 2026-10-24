# doc/EXAMPLE/INTRO

The introductory examples of ATS2. Each file is a complete program (most
have a `main0`); they are the first examples of the books. All of them are
written for the linear-heap dialect: the lists are `list_vt`, the lazy
streams `stream_vt`, the closures `cloptr`, and what is allocated is freed.

## Running them

```sh
patscc -o fact1 fact1.dats && ./fact1      # one example, no flags
make -C doc/EXAMPLE/INTRO all              # build all of them
make -C doc/EXAMPLE/INTRO regress          # run each of them
```

(`PATSHOME` must be set, or use an installed `patscc`.) The directory is
part of the regression suite (`doc/Makefile_test`) and is shipped in the
release tarball. A few files start with a `##myatsccdef=` comment that
sends the code to the web service of ats-lang.org for remote typechecking;
ignore it and use `patscc`.

## What each file shows

Functions and recursion:

* `hello.dats`: hello world in a dozen languages.
* `f91.dats`: McCarthy's 91-function, tested on a range of arguments.
* `fact1.dats`: the factorial, naive.
* `fact2.dats`: two verified factorials (not tail-recursive and
  tail-recursive), with types that state the result.
* `fact3.dats`: the factorial through an `arrayptr` of `0..n-1` and
  `arrayptr_foreach_env`; the array is freed.
* `fact_uninterp.dats`: the factorial specified in the type system with an
  uninterpreted function `fact` and axioms (`praxi`).
* `gfact.dats`: a generic factorial over the number templates (`gnumber`).
* `fib1.dats`: Fibonacci, exponential time.
* `fib2.dats`: Fibonacci with a loop over a pair (linear time).
* `fibmem.dats`: Fibonacci with memoization.
* `tally.dats`: tail recursion and `for` loops.
* `acker1.dats`, `acker2.dats`: Ackermann's function, direct and with nested
  functions.
* `acker3.dats`, `acker4.dats`: Ackermann's function with closures: the
  closures are `cloptr` and are freed after each application.

Lists and data types:

* `bintree.dats`: binary trees as a `datavtype` (a linear tree with `free`).
* `listfuns.dats`: common list functions (`fromto`, `zip`, ...) on
  `list_vt` and the code generated for the `case` expressions.
* `listpermute.dats`: all the permutations of a list.
* `intrange.dats`: a list of an integer range built by
  tail-recursion-modulo-allocation (a `list_vt` filled through a pointer).
* `fprintlst2.dats`: printing a list of lists with separators.
* `fprtuple.dats`: printing tuples through templates (`fprint_tup$beg<>`).
* `ordset.dats`: an ML-style module of ordered sets, as a flat record of
  functions.
* `areverse.dats`: reversing an array in place; the dependent types check
  every index.

Strings, files and input:

* `atoi.dats`, `atof.dats`: strings to an integer and to a double.
* `strprefix.dats`: the longest common prefix of two strings.
* `fcopy.dats`, `fcopy2.dats`: copying a file (`FILEref`); `*.test-inp`,
  `*.test-out` and `*.test-cmp` are the input, the expected output and the
  comparison of the regression test.
* `intecho.dats`: reading integers from the standard input.
* `linenmbr.dats`: numbering the lines of the input (the lines are kept in
  a linear list).

Lazy evaluation:

* `fib_lazy.dats`, `sieve_lazy.dats`: lazy streams with `$ldelay` and
  `stream_vt` (the "lazy" version of the first examples).
* `fib_llazy.dats`, `sieve_llazy.dats`: the same with explicit linear
  stream cells; the sieve of Eratosthenes.

Other:

* `staref.dats`: a statically allocated variable and the view that
  guards it (the replacement of a global `ref`).
* `myatslib.dats`: a program that includes the library sources it needs
  instead of linking `libatslib.a` (`ATS_DYNLOADFLAG 0`), for maximal
  portability.
