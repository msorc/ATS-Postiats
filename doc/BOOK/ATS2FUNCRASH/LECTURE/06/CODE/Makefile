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

all:: lecture06

######

lecture06: lecture06.dats ../../04/CODE/intfun.hats ../../05/CODE/listfun.hats listfun2.hats queens.hats queens_dfs.hats ; $(PATSCC) -o $@ lecture06.dats

######

regress:: lecture06; ./lecture06

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture06

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
