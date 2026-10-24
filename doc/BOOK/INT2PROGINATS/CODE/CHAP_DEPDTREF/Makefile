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

all:: 
all:: listfuns
all:: mergesort
all:: rbtree

######


######











listfuns: listfuns_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: listfuns; ./listfuns
cleanall:: ; $(RMF) listfuns

mergesort: mergesort_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: mergesort; ./mergesort
cleanall:: ; $(RMF) mergesort

rbtree: rbtree_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: rbtree; ./rbtree
cleanall:: ; $(RMF) rbtree

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
