# Crash into [ATS](http://www.ats-lang.org/)

HX-2017-06-02:

I have long been wanting to write a set of notes on functional
programming in ATS. Hopefully, I will be able to carry out the task
this time :)

My current plan is to present a crash course on functional programming
that targets someone who has already acquired certain basic
understanding of programming in general (e.g., someone who has
already done a bit of programming that is roughly equivalent to taking
one semester of an introductory programming course based on C, Java or
Python). This crash course is primarily based on the ML-like
functional core of ATS extended with templates (for handling
parametric polymorphism), and the presented style of functional
programming makes extensive use of combinators (which are mostly
simple list-processing and stream-processing functions).

## Making the book

```sh
make            # the HTML and the PDF
make html       # the HTML only: HTML/index.html is the table of contents
make pdf        # the PDF only: PDF/ATS2FUNCRASH-BOOK.pdf
```

See `../README.md` for the tools that are needed.

## The dialect

The book describes the linear-only, no-GC dialect of ATS2 (no `list`,
`list0`, `option`, `stream`, `lazy`, `arrayref`, `matrixref`, no
`libats/ML`, no `cloref`, no boxed tuples and records, no `$delay`).
The functional lists, arrays and streams of the lectures are `list_vt`,
`arrayptr`/`matrixptr` and `stream_vt`; a function argument of a
combinator is a stack-allocated closure (`&(...) -<clo1> ...`, created by
`lam@`) and a closure that escapes (a continuation, a callback) is a linear
`-<lincloptr1>`/`-<cloptr1>` one that is freed explicitly.

The code of a lecture is in `LECTURE/NN/CODE`; its `Makefile` builds and runs
it with `patscc` (no flag is needed). `check_snippets.py` checks that
the code fragments of a lecture come from the files of its `CODE`:

```sh
python3 check_snippets.py LECTURE/04/main.atxt LECTURE/04/CODE/*.dats LECTURE/04/CODE/*.hats
```
(run in this directory with `PATSHOME` set). The fragments that it still reports
are illustrations that are not compiled (shell commands, `#include`
directives).
