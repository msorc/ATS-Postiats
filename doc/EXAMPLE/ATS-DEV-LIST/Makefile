#
# A simple Makefile
#

######

PATSCC=patscc
PATSHOMEQ="$(PATSHOME)"

######

all::

######

all:: offsetof
offsetof: offsetof.dats ; \
  $(PATSCC) -cleanaft -DATS_MEMALLOC_LIBC -o $@ $<
cleanall:: ; $(RMF) offsetof

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o

######
#
# The example of this directory is only compiled by the regression suite.
#
######

regress::

cleanall:: clean

###### end of [Makefile] ######
