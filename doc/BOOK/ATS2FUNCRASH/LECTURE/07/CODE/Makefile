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

all:: lecture07

######

lecture07: lecture07.dats ../../05/CODE/listfun.hats ../../06/CODE/listfun2.hats listfun3.hats ; $(PATSCC) -o $@ lecture07.dats

######

regress:: lecture07; ./lecture07

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture07

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
