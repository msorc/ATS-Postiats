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
LDPATH += -L$(PATSHOME)/utils/libatsopt
LDPATH += -L$(PATSHOME)/utils/libatsynmark

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

all_html:: HTML/cstream.html
HTML/cstream.html:   cstream_atxt.exe ; ./$< > $@
cstream_atxt.txt: cstream.atxt ; $(CAT) $< |   $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
cstream_atxt.exe: htmlgendecl_atxt.dats   cstream_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $<     $(DECLATEXT) $(HTMLGENDECL) $(LDPATH) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_cstream:: ;   scp HTML/cstream.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libats-hwxi/cstream/SATS/DOCUGEN/HTML/
clean:: ; $(RMF) cstream_atxt.exe
cleanall:: ; $(RMF) HTML/cstream.html

all_html:: HTML/cstream_tokener.html
HTML/cstream_tokener.html:   cstream_tokener_atxt.exe ; ./$< > $@
cstream_tokener_atxt.txt: cstream_tokener.atxt ; $(CAT) $< |   $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
cstream_tokener_atxt.exe: htmlgendecl_atxt.dats   cstream_tokener_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ;   $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $<     $(DECLATEXT) $(HTMLGENDECL) $(LDPATH) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_cstream_tokener:: ;   scp HTML/cstream_tokener.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libats-hwxi/cstream/SATS/DOCUGEN/HTML/
clean:: ; $(RMF) cstream_tokener_atxt.exe
cleanall:: ; $(RMF) HTML/cstream_tokener.html


######

uploadall:: ;   scp HTML/*.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libats-hwxi/cstream/SATS/DOCUGEN/HTML/

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

cleanall:: clean

###### end of [Makefile] ######
