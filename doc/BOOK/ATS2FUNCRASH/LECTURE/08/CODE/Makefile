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

all:: lecture08

######

lecture08: lecture08.dats arrayfun.hats ; $(PATSCC) -o $@ lecture08.dats

######

regress:: lecture08; ./lecture08

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture08

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
