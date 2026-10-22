# doc/BOOK/INT2PROGINATS

The source of the *Introduction to Programming in ATS2* book.

- `CHAP_*/main.atxt` — the chapters (the documents are written in the
  `.atxt` format and are processed by `atsdoc`, see `utils/atsdoc`).
- `CODE/` — the code of the chapters; it is part of the regression suite
  (`doc/Makefile_test`).
- `main.db` — the table of contents of the book.
- `HTML/`, `PDF/` — the generated books (they are not tracked by git).

## Making the book

```sh
make            # the HTML and the PDF (this is what `make book` does
                # at the root of the repository)
make html       # the HTML only: HTML/index.html is the table of contents
make pdf        # the PDF only: PDF/INT2PROGINATS-BOOK.pdf
```

The chapters are turned into DocBook files (`CHAP_*/main.db`) by `atsdoc`;
`main.db` (which is tracked in git) includes them.  The HTML and the PDF
are then made from the DocBook source with the DocBook XSL stylesheets:

- `xsltproc` (with the DocBook XSL stylesheets) makes the HTML,
- a web browser in headless mode (`google-chrome`) prints the PDF.

The text of the code blocks is escaped first (`../escapedoc.py`): the `.atxt`
sources are HTML-flavoured, so a code block may contain a `<` or a `&`
that the XML syntax does not allow.

`PATSHOME` (the root of the ATS2 repository, or of an installation of
ATS2) defaults to the root of this repository.

The old pipeline, which used jade (or openjade) and the DocBook DSSSL
stylesheets, is still there (`make html-jade`, `make pdf-jade`), but it
does not work with the DocBook source of the book as it is now.
