#
# The rules that make the HTML and the PDF of a book from its DocBook
# source.  A book includes this file (with "include ../Makefile_docbook.mk")
# and sets the variables below:
#
#   BOOKNAME    the name of the book: the HTML file and the PDF file
#               are named after it
#   BOOKCHAPS   the directories that hold the chapters; each of them
#               holds a main.db that is generated from a main.atxt
#
# The DocBook source of the book is prepared first: the text of the code
# blocks is escaped, because the .atxt sources are HTML-flavoured and a
# code block may contain a '<' or a '&' that the XML syntax does not
# allow.
#
# The tools that are needed are xsltproc (with the DocBook XSL
# stylesheets) and, for the PDF, a web browser in headless mode.
#

######

PYTHON ?= python3
XSLTPROC ?= xsltproc
CHROME ?= google-chrome
#
# the DocBook XSL stylesheets (they are in a directory whose name has
# the version of the stylesheets in it)
#
DOCBOOK_XSL ?= $(shell ls -d /usr/share/xml/docbook/xsl-stylesheets* 2>/dev/null | head -n 1)
#
# the directory where the DocBook source is prepared
#
DOCBUILD ?= ./DOCBUILD
#
######
#
# the DocBook source of the book: the chapters are copied into DOCBUILD
# and the text of the code blocks is escaped there (the files that are
# tracked in git are already well-formed)
#
docbuild: main.db
	rm -rf $(DOCBUILD)
	mkdir -p $(DOCBUILD)
	for i in $(BOOKCHAPS); do \
	  if [ -f $$i/main.db ] ; then \
	    mkdir -p $(DOCBUILD)/$$i; \
	    cp $$i/main.db $(DOCBUILD)/$$i/main.db; \
	  fi; \
	done
	cp bookinfo.db main.db preface.db $(DOCBUILD)/
	$(PYTHON) ../escapedoc.py $(DOCBUILD)/preface.db `find $(DOCBUILD) -name main.db`
#
######
#
# the HTML of the book: it is made of one file per chapter (and one for
# the table of contents, which is index.html)
#
html: docbuild
	@command -v $(XSLTPROC) > /dev/null || { \
	  echo "ERROR: $(XSLTPROC) is missing: it is needed to make the HTML." && exit 1 ; }
	mkdir -p HTML
	$(XSLTPROC) --nonet \
	  --stringparam chunker.output.encoding UTF-8 \
	  --stringparam html.stylesheet assets/$(BOOKNAME).css \
	  -o HTML/ $(DOCBOOK_XSL)/html/chunk.xsl $(DOCBUILD)/main.db
#
######
#
# the PDF of the book: it is printed from a single HTML file
#
pdf: docbuild
	@command -v $(XSLTPROC) > /dev/null || { \
	  echo "ERROR: $(XSLTPROC) is missing: it is needed to make the PDF." && exit 1 ; }
	@command -v $(CHROME) > /dev/null || { \
	  echo "ERROR: $(CHROME) is missing: it is needed to print the PDF." && exit 1 ; }
	mkdir -p HTML PDF
	$(XSLTPROC) --nonet \
	  --stringparam html.output.encoding UTF-8 \
	  -o HTML/$(BOOKNAME).html $(DOCBOOK_XSL)/html/docbook.xsl $(DOCBUILD)/main.db
	$(CHROME) --headless --disable-gpu --no-sandbox \
	  --user-data-dir=$(DOCBUILD)/chrome-profile \
	  --no-pdf-header-footer \
	  --print-to-pdf=PDF/$(BOOKNAME).pdf \
	  file://$(abspath HTML/$(BOOKNAME).html)
#
######
#
# the generated files
#
clean:: ; $(RMF) HTML/*.html
clean:: ; $(RMF) PDF/*.pdf
#
cleanall:: ; rm -rf $(DOCBUILD)
#
######
