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

all:: lecture09

######

lecture09: lecture09.dats ../../04/CODE/intfun.hats tree.sats tree_gen.hats tree_gen_dats.hats ; $(PATSCC) -o $@ lecture09.dats

######

regress:: lecture09; ./lecture09

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture09

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
