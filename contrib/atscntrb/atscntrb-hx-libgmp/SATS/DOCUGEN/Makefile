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
LDPATH += -L$(PATSHOME)/utils/libatsynmark

######

INCLUDE:=-I $(PATSHOMEQ)/src
INCLATS:=-IATS $(SHAREDOCU) -IATS $(PATSHOMEQ)

######

CAT=cat

######

all:: all_html

######

DECLATEXT=   declatext_dats.o 
declatext_dats.o: ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -c $(SHAREDOCU)/declatext.dats

######

HTMLGENDECL=   htmlgendecl_dats.o 
htmlgendecl_dats.o: ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -c $(SHAREDOCU)/htmlgendecl.dats

htmlgendecl_atxt.dats: ;   $(ATSDOC) --outcode $@ -i $(SHAREDOCU)/htmlgendecl.atxt > htmlgendecl_atxt.txt

######

all_html::

######

all_html:: HTML/gmp.html
HTML/gmp.html:   gmp_atxt.exe ; ./$< > $@
gmp_atxt.txt: gmp.atxt ; $(CAT) $< |   $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
gmp_atxt.exe: htmlgendecl_atxt.dats   gmp_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $<     $(DECLATEXT) $(HTMLGENDECL) $(LDPATH) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_gmp:: ;   scp HTML/gmp.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libgmp/SATS/DOCUGEN/HTML
clean:: ; $(RMF) gmp_atxt.exe
cleanall:: ; $(RMF) HTML/gmp.html


######
#
uploadall:: ; scp HTML/*.html   ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libgmp/SATS/DOCUGEN/HTML
#
######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

cleanall:: clean

###### end of [Makefile] ######
