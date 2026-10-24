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

all:: lecture05

######

lecture05: lecture05.dats listfun.hats ; $(PATSCC) -o $@ lecture05.dats

######

regress:: lecture05; ./lecture05

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture05

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
