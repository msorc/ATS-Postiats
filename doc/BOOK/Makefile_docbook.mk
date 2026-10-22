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
# the directory that holds the tool that highlights the ATS code
#
MYTEXT ?= ./MYTEXT
#
HILITE = $(PYTHON) ../hilite.py $(MYTEXT)/bin/mytexting
#
######
#
# the syntax highlighting of the ATS code: the code blocks of the book
# are marked in the DocBook source (with "############dats2xhtml_docbook"
# and the like) and the tool of the MYTEXT directory (mytexting) replaces
# them with HTML that is highlighted by libatsynmark
#
hilite: ; \
  if [ -f $(MYTEXT)/mytexting.dats ] ; then \
    $(MAKE) -C $(MYTEXT) mytexting ; \
    for i in HTML/*.html ; do \
      case "$$i" in HTML/$(BOOKNAME).html) ;; \
        *) $(HILITE) $$i ;; \
      esac ; \
    done ; \
  fi
#
hilite-book: ; \
  if [ -f $(MYTEXT)/mytexting.dats ] ; then \
    $(MAKE) -C $(MYTEXT) mytexting ; \
    $(HILITE) HTML/$(BOOKNAME).html ; \
  fi
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
	$(MAKE) hilite
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
	@echo '<?xml version="1.0"?>' > $(DOCBUILD)/single.xsl
	@echo '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' >> $(DOCBUILD)/single.xsl
	@echo '<xsl:import href="$(DOCBOOK_XSL)/html/docbook.xsl"/>' >> $(DOCBUILD)/single.xsl
	@echo '<xsl:output method="html" encoding="UTF-8" indent="no"/>' >> $(DOCBUILD)/single.xsl
	@echo '</xsl:stylesheet>' >> $(DOCBUILD)/single.xsl
	$(XSLTPROC) --nonet \
	  -o HTML/$(BOOKNAME).html $(DOCBUILD)/single.xsl $(DOCBUILD)/main.db
	$(MAKE) hilite-book
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
