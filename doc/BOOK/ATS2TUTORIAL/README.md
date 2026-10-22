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

The chapters that document an API of the GC era of ATS2 (`arrayref`,
`matrixref`, `stream`) carry a note that says so: the API they describe
was removed when the support for the garbage collector was dropped.

## Making the book

```sh
make            # the HTML and the PDF
make html       # the HTML only: HTML/index.html is the table of contents
make pdf        # the PDF only: PDF/ATS2TUTORIAL-BOOK.pdf
```

See `../README.md` for the tools that are needed.
