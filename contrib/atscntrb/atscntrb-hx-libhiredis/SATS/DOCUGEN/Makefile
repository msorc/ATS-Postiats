#
#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#
#

######

PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc
PATSCCFLAGS=-DATS_MEMALLOC_LIBC

######

PATSHOMEQ="$(PATSHOME)"

######

SHAREDOCU=$(PATSHOMEQ)/share/DOCUGEN

######

LDPATH :=
LDPATH += -L$(PATSHOME)/ccomp/atslib/lib

######

INCLUDE:=-I $(PATSHOMEQ)/src
INCLATS:=-IATS $(SHAREDOCU) -IATS $(PATSHOMEQ)

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
all_html:: HTML/hiredis.html
HTML/hiredis.html:   hiredis_atxt.exe ; ./$< > $@
hiredis_atxt.txt: hiredis.atxt ; $(CAT) $< |   $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
hiredis_atxt.exe: htmlgendecl_atxt.dats   hiredis_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $<     $(DECLATEXT) $(HTMLGENDECL) $(LDPATH) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_hiredis:: ;   scp HTML/hiredis.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/hiredis/SATS/DOCUGEN/HTML/
clean:: ; $(RMF) hiredis_atxt.exe
cleanall:: ; $(RMF) HTML/hiredis.html


######

uploadall:: ;   scp HTML/*.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/hiredis/SATS/DOCUGEN/HTML/

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

cleanall:: clean

###### end of [Makefile] ######
