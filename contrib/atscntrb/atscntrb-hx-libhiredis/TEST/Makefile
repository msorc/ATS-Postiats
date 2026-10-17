#
# A simple Makefile
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=${PATSHOMEQ}/bin/patscc

######

all::

######
#
all:: \
test00
test00: \
test00.dats ; \
$(PATSCC) -cleanaft -I./../.. -o $@ $< -lhiredis
#
cleanall:: ; $(RMF) test00
#
######
#
all:: \
test01
test01: \
test01.dats ; \
$(PATSCC) -cleanaft -I./../.. -DATS_MEMALLOC_LIBC -o $@ $< -lhiredis
#
cleanall:: ; $(RMF) test01
#
######
#
#
#
######
#
all:: \
test03
#
#
#
#
######
#
#
#
######

RMF=rm -f

######

testall:: all
testall:: cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o

cleanall:: clean

###### end of [Makefile] ######
