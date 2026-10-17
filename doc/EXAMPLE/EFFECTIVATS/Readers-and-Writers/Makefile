##
##
## A simple Makefile
##
##

######

include \
$(PATSHOME)/share/atsmake-pre.mk

######

CFLAGS += -O2

######

SOURCES_SATS := \
  DB_read_write.sats \

SOURCES_DATS := \
  DB_read_write.dats \

######

MYTARGET=MYTARGET
MYCCRULE=MYCCRULE

######

include $(PATSHOME)/share/atsmake-post.mk

######

all:: test
test:: ; $(PATSCC) -tcats DB_read_write.sats
test:: ; $(PATSCC) -tcats DB_read_write.dats

######

PATSHOMEQ="$(PATSHOME)"
PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc

######

INPATH :=
INPATH += -I$(PATSHOME)/src
INPATH += -IATS $(PATSHOME)

LDPATH :=
LDPATH += -L$(PATSHOME)/ccomp/atslib/lib

LIBRARY :=
LIBRARY := -latsynmark -latsdoc -latslib -latsopt -lgmp

######
#
main.exe: \
main_atxt.dats ; \
$(PATSCC) \
  -DATS_MEMALLOC_LIBC \
  $(INPATH) -o $@ $< $(LDPATH) $(LIBRARY)
#
main_atxt.dats: main.atxt; \
$(ATSDOC) --outcode $@ -i main.atxt > main_atxt.txt
#
######

main.html: main.exe ; ./main.exe > $@

######

upload_main: \
  main.html ; \
  scp main.html \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/Readers-and-Writers/

######
#
# clean: cleanats
#
cleanats:: ; $(RMF) main.exe
cleanats:: ; $(RMF) main_atxt.txt
cleanats:: ; $(RMF) main_atxt.dats
cleanats:: ; $(RMF) main_atxt_dats.c
#
######

cleanall:: ; $(RMF) main.html

######

###### end of [Makefile] ######
