##
##
## A simple Makefile for compiling ATS programs
##
##

######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

ATSCNTRB=$(PATSHOME)/contrib/atscntrb

######

CFLAGS :=
CFLAGS += -O2
CFLAGS += -D_GNU_SOURCE -DATS_MEMALLOC_LIBC

######
#
#
#
#
######
#
all:: \
gnumber
gnumber: \
gnumber.dats ; \
$(PATSCC) -I$(ATSCNTRB) $(CFLAGS) -o $@ $< -lgmp
regress:: \
gnumber ; ./gnumber
#
cleanall:: ; $(RMF) gnumber
#
######
#
#
#
#
######
#
#
#
#
######


######

RMF=rm -f

######

testall:: all
testall:: regress
testall:: cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
