#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#

######


######

PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc

######

PATSHOMEQ="$(PATSHOME)"

######

SHAREDOCU=$(PATSHOMEQ)/share/DOCUGEN

######

INCLUDE:=-I $(PATSHOMEQ)/src
INCLATS:=-IATS $(SHAREDOCU) -IATS $(PATSHOMEQ)

######
PATSCCFLAGS=-DATS_MEMALLOC_LIBC
#
######

CAT=cat

######

all:: all_html

######

DECLATEXT= \
  declatext_dats.o \

declatext_dats.o: ; \
  $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -c $(SHAREDOCU)/declatext.dats

######

HTMLGENDECL= \
  htmlgendecl_dats.o \

htmlgendecl_dats.o: ; \
  $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -c $(SHAREDOCU)/htmlgendecl.dats

htmlgendecl_atxt.dats: ; \
  $(ATSDOC) --outcode $@ -i $(SHAREDOCU)/htmlgendecl.atxt > htmlgendecl_atxt.txt

######

all_html::

all_html:: HTML/unicode.html
HTML/unicode.html:   unicode_atxt.exe ; ./$< > $@
unicode_atxt.txt: unicode.atxt ; $(CAT) $< |   $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
unicode_atxt.exe: htmlgendecl_atxt.dats   unicode_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $<     $(DECLATEXT) $(HTMLGENDECL) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_unicode:: ;   scp HTML/unicode.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libatslex
clean:: ; $(RMF) unicode_atxt.exe
cleanall:: ; $(RMF) HTML/unicode.html


######

uploadall:: ;   scp HTML/*.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libatslex

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

cleanall:: clean

###### end of [Makefile] ######
