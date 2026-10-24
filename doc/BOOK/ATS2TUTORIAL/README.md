# doc/BOOK/ATS2TUTORIAL

The source of the ATS2 tutorial book.

- `CHAP_*/main.atxt` — the chapters (the documents are written in the
  `.atxt` format and are processed by `atsdoc`, see `utils/atsdoc`).
- `CODE/` — the code of the chapters; it is part of the regression suite
  (`doc/Makefile_test`).
- `MYTEXT/` — the macros that the chapters use.
- `main.db` — the table of contents of the book (the chapters that it
  refers to are the ones that are shipped).
- `HTML/`, `PDF/` — the generated books (they are not tracked by git).

The book describes the linear-only, no-GC dialect of ATS2 (no `list`,
`option`, `stream`, `arrayref`, `matrixref`, no `libats/ML`, no `cloref`, no
boxed tuples and records). Several chapters keep their names and their
`id`s from the GC era (`arrayref`, `matrixref`, `stream`, `funsetmap`, ...)
but teach the linear replacement (`arrayptr`, `matrixptr`, `stream_vt`,
`linset_avltree`/`linmap_avltree`); the chapter on lazy streams is a short
note on the removal of the non-linear ones.

The code fragments of a chapter must come from `CODE/`, which is built and
run by `doc/Makefile_test`. `check_snippets.py` checks it:

```sh
python3 check_snippets.py CHAP_ARRAYREF/main.atxt   # run in this directory
```

It reports every `#dats2xhtml`/`#sats2xhtml` fragment that is not (modulo
white space and comments) in a file of `CODE/` or, for an interface, in the
`prelude` or `libats/SATS` interfaces. The fragments that it still reports
(directives, shell commands, `foo.sats` of the chapter on `staload`, the
`#codegen2` variants, ...) are illustrations that are not compiled.

## Making the book

```sh
make            # the HTML and the PDF
make html       # the HTML only: HTML/index.html is the table of contents
make pdf        # the PDF only: PDF/ATS2TUTORIAL-BOOK.pdf
```

See `../README.md` for the tools that are needed.
