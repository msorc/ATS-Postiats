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
all:: wday
all:: charlst
all:: bstree
all:: intexp
all:: intexp2
all:: intopt

######


######











wday: wday_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: wday; ./wday
cleanall:: ; $(RMF) wday

charlst: charlst_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: charlst; ./charlst
cleanall:: ; $(RMF) charlst

bstree: bstree_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: bstree; ./bstree
cleanall:: ; $(RMF) bstree

intexp: intexp_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: intexp; ./intexp
cleanall:: ; $(RMF) intexp

intexp2: intexp2_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: intexp2; ./intexp2
cleanall:: ; $(RMF) intexp2

intopt: intopt_dats.c ; \
  $(CCOPT) $(INCLUDES) $(CCFLAGS) -o $@ $< || echo $@ ": ERROR!!!"
regress:: intopt; ./intopt
cleanall:: ; $(RMF) intopt

######

%_dats.c: %.dats ; \
  $(PATSOPT) $(ATSCCFLAGS) -o $@ --dynamic $< || echo $@ ": ERROR!!!"

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
