#
#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt
PATSOLVE=$(PATSHOME)/bin/patsolve_z3

######

all::

######

all:: \
bsearch_arr
bsearch_arr: \
bsearch_arr.dats ; \
$(PATSOPT) --typecheck --dynamic bsearch_arr.dats

######

LNS=ln -s
RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

######
#
# The example of this directory is only typechecked by the regression suite.
#
######

regress::

cleanall:: clean

###### end of [Makefile] ######
