#
#
# A Simple Makefile
#
#
# The book is written in the .atxt format: atsdoc turns the chapters
# into DocBook files (CHAP_*/main.db) that main.db (which is tracked in
# git) includes with general entities.
#
# The HTML and the PDF are made with the DocBook XSL stylesheets
# (xsltproc).  The DocBook source is prepared first: the text of the
# code blocks is escaped, because the .atxt sources are HTML-flavoured
# and a code block may contain a '<' or a '&' that the XML syntax does
# not allow.
#
# The tools that are needed are xsltproc (with the DocBook XSL
# stylesheets) and, for the PDF, a web browser in headless mode.
#

######

PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc
#LIBATSDOC=$(PATSHOMEQ)/ccomp/atslib/lib

######

# PATSHOME is the root of the ATS2 repository (or of an installation of
# ATS2); it defaults to the root of this repository.
PATSHOME ?= $(abspath ../../..)
export PATSHOME
PATSHOMEQ="$(PATSHOME)"

######

all::
all:: html
all:: pdf

######

cleanall::

######

MAKE=make
JADE=/usr/bin/openjade

######
#
# the name of the book and the directories that hold the chapters
#
BOOKNAME=INT2PROGINATS-BOOK
BOOKCHAPS=CHAP_*
#
# the rules that make the HTML and the PDF are shared by the books
#
include ../Makefile_docbook.mk
#
######
#
# the old pipeline: it needs jade (or openjade) and the DocBook DSSSL
# stylesheets, and it does not work with the DocBook source of the book
# as it is now (the names of the entities and the values of the ids
# contain '_', which the SGML syntax does not allow)
#
DSL=default
DSL=./mydocbook.dsl
#
pdf-jade: main.db ; \
jw -b pdf --dsl default --parser $(JADE) --output PDF/ main.db
#
html-jade: main.db ; \
jw -b html --parser $(JADE) --dsl $(DSL) --output HTML/ main.db
#
htmltoc: ; \
$(MAKE) -C HTML -f Makefile htmltoc
#
synhilit: \
mytexting; $(MAKE) -C HTML synhilit
#
mytexting: ; $(MAKE) -C MYTEXT mytexting
#
######

main.db:: allchap
main.db:: preface.db

######
#
preface.exe: \
preface_atxt.dats; \
$(PATSCC) -DATS_MEMALLOC_LIBC -o $@ preface_atxt.dats -latsdoc -latslib
#
preface_atxt.dats: \
preface.atxt; $(ATSDOC) --outcode $@ -i preface.atxt > preface_atxt.txt
#
preface.db:: preface.exe ; ./$< > $@
#
preface.db:: ; $(RMF) preface.exe preface_atxt_dats.c preface_atxt.dats preface_atxt.txt
#
######
#
# PART I
#
allchap:: CHAP_START
allchap:: CHAP_PROGELEM
allchap:: CHAP_FUNCTION
allchap:: CHAP_DATATYPE
allchap:: CHAP_POLYMORPH
#
######
#
# PART II
#
allchap:: CHAP_EFFECTFUL
allchap:: CHAP_MODULARITY
allchap:: CHAP_CINTERACT
#
######
#
# PART III
#
allchap:: CHAP_DEPTYPES
allchap:: CHAP_DEPDTREF
allchap:: CHAP_THMPRVING
allchap:: CHAP_PRGTHMPRV
#
######
#
# PART IV
#
allchap:: CHAP_VVTINTRO
allchap:: CHAP_DATAVIEW
allchap:: CHAP_DATAVTYPE
allchap:: CHAP_ABSVTYPE
#
######
#
# PART V
#
allchap:: CHAP_FNTMPINT
#
######
#
CHAP_START:: ; \
  $(MAKE) -C CHAP_START -f ../Makefile_chap main.db
#
clean:: ; $(MAKE) -C CHAP_START -f ../Makefile_chap clean
#
######

CHAP_PROGELEM:: ; \
  $(MAKE) -C CHAP_PROGELEM -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_PROGELEM -f ../Makefile_chap clean

CHAP_FUNCTION:: ; \
  $(MAKE) -C CHAP_FUNCTION -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_FUNCTION -f ../Makefile_chap clean

CHAP_DATATYPE:: ; \
  $(MAKE) -C CHAP_DATATYPE -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_DATATYPE -f ../Makefile_chap clean

CHAP_POLYMORPH:: ; \
  $(MAKE) -C CHAP_POLYMORPH -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_POLYMORPH -f ../Makefile_chap clean

######

CHAP_EFFECTFUL:: ; \
  $(MAKE) -C CHAP_EFFECTFUL -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_EFFECTFUL -f ../Makefile_chap clean

######

CHAP_MODULARITY:: ; \
  $(MAKE) -C CHAP_MODULARITY -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_MODULARITY -f ../Makefile_chap clean

######

CHAP_CINTERACT:: ; \
  $(MAKE) -C CHAP_CINTERACT -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_CINTERACT -f ../Makefile_chap clean

######

CHAP_DEPTYPES:: ; \
  $(MAKE) -C CHAP_DEPTYPES -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_DEPTYPES -f ../Makefile_chap clean

######

CHAP_DEPDTREF:: ; \
  $(MAKE) -C CHAP_DEPDTREF -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_DEPDTREF -f ../Makefile_chap clean

######

CHAP_THMPRVING:: ; \
  $(MAKE) -C CHAP_THMPRVING -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_THMPRVING -f ../Makefile_chap clean

######

CHAP_PRGTHMPRV:: ; \
  $(MAKE) -C CHAP_PRGTHMPRV -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_PRGTHMPRV -f ../Makefile_chap clean

######

CHAP_VVTINTRO:: ; \
  $(MAKE) -C CHAP_VVTINTRO -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_VVTINTRO -f ../Makefile_chap clean

######

CHAP_DATAVIEW:: ; \
  $(MAKE) -C CHAP_DATAVIEW -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_DATAVIEW -f ../Makefile_chap clean

######

CHAP_DATAVTYPE:: ; \
  $(MAKE) -C CHAP_DATAVTYPE -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_DATAVTYPE -f ../Makefile_chap clean

######

CHAP_ABSVTYPE:: ; \
  $(MAKE) -C CHAP_ABSVTYPE -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_ABSVTYPE -f ../Makefile_chap clean

######

CHAP_FNTMPINT:: ; \
  $(MAKE) -C CHAP_FNTMPINT -f ../Makefile_chap main.db
clean:: ; $(MAKE) -C CHAP_FNTMPINT -f ../Makefile_chap clean

######
#
RMF=rm -f
CPRF=cp -rf
SCPR=scp -r
#
CHMOD=chmod
RSYNC=rsync
#
######
#
SUBDIRS_CODE := $(wildcard CODE/CHAP_*/)
#
regress:: ; \
  set -e; \
  for i in $(SUBDIRS_CODE); do $(MAKE) -C $$i $@; done
#
######
#
upload:: \
upload_pdf
upload_pdf:: ; \
  rsync -av --delete PDF ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INT2PROGINATS/
#
######
#
upload:: \
upload_html
upload_html:: ; \
  rsync -av --delete HTML ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INT2PROGINATS/
#
######

uploadloc:: ; \
  $(SCPR) PDF hwxi@csa2.bu.edu:public_html/ATS/DOCUMENT/INT2PROGINATS/
  $(SCPR) HTML hwxi@csa2.bu.edu:public_html/ATS/DOCUMENT/INT2PROGINATS/

######
#
upload_code:: ; \
  $(MAKE) -C CODE cleanall
upload_code:: ; \
  $(RSYNC) -av --delete CODE ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INT2PROGINATS/
#
######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats
clean:: ; $(RMF) *_atxt_dats.c
clean:: ; $(RMF) HTML/*.html
clean:: ; $(RMF) PDF/*.pdf
clean:: ; $(MAKE) -C HTML clean
clean:: ; $(MAKE) -C MYTEXT clean

cleanall:: clean
cleanall:: ; $(RMF) preface.db
cleanall:: ; rm -rf $(DOCBUILD)
cleanall:: ; $(MAKE) -C HTML cleanall
cleanall:: ; $(MAKE) -C MYTEXT cleanall

###### end of [Makefile] ######
