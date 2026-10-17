#
# A simple Makefile
#

######

CCOPT=gcc -std=c99
PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

ATSCCFLAGS=-O2

######

all:: ifact
all:: ifact23

######


######


######

ifact: ifact.dats ; $(PATSCC) $(ATSCCFLAGS) -o $@ $<
regress:: ifact; ./$<
cleanall:: ; $(RMF) ifact

ifact23: ifact23.dats; $(PATSCC) $(ATSCCFLAGS) -o $@ $<
regress:: ifact23; ./$<
cleanall:: ; $(RMF) ifact23

######


######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
