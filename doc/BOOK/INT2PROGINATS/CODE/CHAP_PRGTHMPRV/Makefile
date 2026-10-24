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
all:: listconcat
all:: matrix_get

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


listconcat: listconcat.dats; $(PATSCC) $(ATSCCFLAGS) -o $@ $<
regress:: listconcat; ./$<
cleanall:: ; $(RMF) listconcat

######

matrix_get: matrix_get.dats; $(PATSCC) $(ATSCCFLAGS) -o $@ $<
regress:: matrix_get; ./$<
cleanall:: ; $(RMF) matrix_get

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
