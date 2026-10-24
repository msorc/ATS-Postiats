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
all:: strings
all:: bsearch_arr
all:: terminate

######


######











strings: strings_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: strings; ./strings
cleanall:: ; $(RMF) strings

bsearch_arr: bsearch_arr_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: bsearch_arr; ./bsearch_arr
cleanall:: ; $(RMF) bsearch_arr

terminate: terminate_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: terminate; ./terminate
cleanall:: ; $(RMF) terminate

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
