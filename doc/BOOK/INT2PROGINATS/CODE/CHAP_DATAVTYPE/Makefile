#
# A simple Makefile
#

######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

CFLAGS=-O2
ATSCFLAGS=

######


######

all:: rbtree
rbtree: rbtree.dats; \
  $(PATSCC) -DATS_MEMALLOC_LIBC $(CFLAGS) -o $@ $<
regress:: rbtree; ./rbtree

######


######


######


######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean
cleanall:: ; $(RMF) rbtree

###### end of [Makefile] ######
