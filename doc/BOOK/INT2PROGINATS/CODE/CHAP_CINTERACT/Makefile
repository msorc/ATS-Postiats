##
##
## A simple Makefile for compiling ATS programs
##
##

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt

######

ATSCCFLAGS=-O2

######

all::

######

distclean:: cleanall

######


######

all:: fact
fact: fact_dats.c fact2.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: fact; ./fact
cleanall:: ; $(RMF) fact

######

all:: factext
factext: factext_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: factext; ./factext
cleanall:: ; $(RMF) factext

######

all:: extfcall
extfcall: extfcall_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: extfcall; ./extfcall
cleanall:: ; $(RMF) extfcall

######

all:: strcmp
strcmp: strcmp_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: strcmp; ./strcmp
cleanall:: ; $(RMF) strcmp

######


######


all:: ArrayCopyFromList
ArrayCopyFromList: ArrayCopyFromList_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: ArrayCopyFromList; ./ArrayCopyFromList
cleanall:: ; $(RMF) ArrayCopyFromList

######

all:: StaticAllocList
StaticAllocList: StaticAllocList_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: StaticAllocList; ./StaticAllocList
cleanall:: ; $(RMF) StaticAllocList

######

all:: abc
abc: abc_dats.c ; $(PATSCC) $(ATSCCFLAGS) -o $@ $^
regress:: abc; ./abc
cleanall:: ; $(RMF) abc

######

######

%_dats.c: %.dats; $(PATSCC) $(ATSCCFLAGS) -ccats $< || touch $@

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
