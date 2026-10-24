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

all:: lecture11

######

lecture11: lecture11.dats ../../05/CODE/listfun.hats ../../10/CODE/streamfun.hats streamfun2.hats ; $(PATSCC) -o $@ lecture11.dats

######

regress:: lecture11; ./lecture11

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture11

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
