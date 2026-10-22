# doc/BOOK

The books of ATS2.

- `INT2PROGINATS/` — *Introduction to Programming in ATS2*.
- `ATS2TUTORIAL/` — *A Tutorial on Programming in ATS2*.
- `ATS-for-APUE3/` — *ATS for Programming in the UNIX Environment*.
- `ATS2FUNCRASH/` — *Programming in ATS2: the Fun and Crash of It*.

## Making the books

```sh
make book             # at the root of the repository: it makes all of them
make -C doc/BOOK/INT2PROGINATS html   # the HTML of one book
make -C doc/BOOK/INT2PROGINATS pdf    # the PDF of one book
```

The books are written in the `.atxt` format: `atsdoc` turns the
chapters into DocBook files (`CHAP_*/main.db`, `LECTURE/*/main.db`) that
`main.db` (which is tracked in git) includes.  The HTML and the PDF are
then made from the DocBook source with the DocBook XSL stylesheets:

- `xsltproc` (with the DocBook XSL stylesheets) makes the HTML,
- the tool of the `MYTEXT` directory of the book (`mytexting`) replaces
  the marked code blocks with the HTML that is highlighted by
  `libatsynmark`,
- a web browser in headless mode (`google-chrome`) prints the PDF.

The rules that do this are shared by the books (`Makefile_docbook.mk`);
the text of the code blocks is escaped first (`escapedoc.py`), because
the `.atxt` sources are HTML-flavoured and a code block may contain a
`<` or a `&` that the XML syntax does not allow.

The old pipeline, which used jade (or openjade) and the DocBook DSSSL
stylesheets, is still there in each book (`make html-jade`,
`make pdf-jade`), but it does not work with the DocBook source of the
books as it is now.
