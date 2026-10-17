#
# A simple Makefile
#

######

PATSCC=patscc
PATSOPT=patsopt
PATSFIND=patsfind
PATSHOMEQ="$(PATSHOME)"

######
#
export \
PATSHOMELOCS=\
./node_modules:./../../node_modules
#
######

all::

######

CFLAGS:=
CFLAGS+=-I"./../.."
CFLAGS+=-DATS_MEMALLOC_LIBC

######


######


######

all:: \
test03
test03: \
test03.dats ; \
$(PATSCC) -cleanaft $(CFLAGS) -o $@ $< -lgmp
regress:: test03; ./$<
cleanall:: ; $(RMF) test03

######

all:: \
test04
test04: \
test04.dats ; \
$(PATSCC) -cleanaft $(CFLAGS) -o $@ $< -lgmp
regress:: test04; ./$<
cleanall:: ; $(RMF) test04

######


######


######

RMF=rm -f

######

testall:: all
testall:: regress
testall:: cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o

cleanall:: clean

###### end of [Makefile] ######
