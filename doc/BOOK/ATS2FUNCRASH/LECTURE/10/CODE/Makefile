######
#
# A simple Makefile
#
######

# PATSHOME is the root of the ATS2 repository (or of an installation of ATS2)
PATSHOME ?= $(abspath ../../../../../..)
export PATSHOME
PATSCC=$(PATSHOME)/bin/patscc

######

all:: lecture10

######

lecture10: lecture10.dats ../../05/CODE/listfun.hats streamfun.hats ; $(PATSCC) -o $@ lecture10.dats

######

regress:: lecture10; ./lecture10

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture10

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
