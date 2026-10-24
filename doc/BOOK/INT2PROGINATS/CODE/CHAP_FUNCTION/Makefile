#
# A simple Makefile
#

######

CC=gcc
CCOPT=$(CC) -std=c99 -D_XOPEN_SOURCE

######

PATSCCT=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

INCLUDES=-I$(PATSHOME) -I$(PATSHOME)/ccomp/runtime

######

CCFLAGS=-O2

######

ATSCCFLAGS=

######

all:: coinchange
all:: queens
all:: acker
all:: bsearch
all:: twice
all:: misc

######




coinchange: coinchange_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: coinchange; ./coinchange
cleanall:: ; $(RMF) coinchange

queens: queens_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: queens; ./queens
cleanall:: ; $(RMF) queens


acker: acker_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: acker; ./acker
cleanall:: ; $(RMF) acker

bsearch: bsearch_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: bsearch; ./bsearch
cleanall:: ; $(RMF) bsearch

twice: twice_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: twice; ./twice
cleanall:: ; $(RMF) twice

misc: misc_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: misc; ./misc
cleanall:: ; $(RMF) misc

######

%_dats.c: %.dats ; \
  $(PATSOPT) $(ATSCCFLAGS) -o $@ --dynamic $<

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

######

###### end of [Makefile] ######
