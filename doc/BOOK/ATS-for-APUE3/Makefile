#
#
# A Simple Makefile
#
#
# The book is written in the .atxt format: atsdoc turns the chapter into
# a DocBook file (CHAP_FILE_IO/main.db) that main.db (which is tracked
# in git) includes with a general entity.  The HTML and the PDF are made
# with the DocBook XSL stylesheets (see ../Makefile_docbook.mk).
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

JADE=/usr/bin/openjade

######
#
# the name of the book and the directories that hold the chapters
#
BOOKNAME=ATS-for-APUE3-BOOK
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
pdf-jade: main.db ; jw -b pdf --dsl default --parser $(JADE) --output PDF/ main.db

html-jade: main.db ; jw -b html --dsl default --parser $(JADE) --output HTML/ main.db
#
######

main.db:: allchap
main.db:: preface.db

######

preface.exe: preface_atxt.dats
	$(PATSCC) -DATS_MEMALLOC_LIBC -o $@ preface_atxt.dats -latsdoc -latslib
preface_atxt.dats: preface.atxt
	$(ATSDOC) --outcode $@ -i preface.atxt > preface_atxt.txt
preface.db:: preface.exe ; ./$< > $@
preface.db:: ; $(RMF) preface.exe preface_atxt_dats.c preface_atxt.dats preface_atxt.txt

######

allchap:: CHAP_FILE_IO
CHAP_FILE_IO:: ; \
  make -C CHAP_FILE_IO -f ../Makefile_chap main.db
clean:: ; make -C CHAP_FILE_IO -f ../Makefile_chap clean

######

CPRF=cp -rf
SCPR=scp -r
CHMOD=chmod

######

upload:: upload_html

upload_pdf:: ; \
  scp -r PDF ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/ATS-for-APUE3/
upload_html:: ; \
  scp -r HTML ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/ATS-for-APUE3/

######

uploadloc:: ; $(SCPR) HTML hwxi@csa2.bu.edu:public_html/ATS/DOCUMENT/ATS-for-APUE3/

######
#
upload_code:: ; \
  make -C CODE cleanall
upload_code:: ; \
  scp -r CODE ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/ATS-for-APUE3
#
######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats
clean:: ; $(RMF) *_atxt_dats.c

cleanall:: clean
cleanall:: ; $(RMF) preface.db
cleanall:: ; $(RMF) HTML/*.html
cleanall:: ; $(RMF) PDF/main.pdf
cleanall:: ; $(RMF) TEMP/chap_*.dats

###### end of [Makefile] ######
