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

all:: EstimatePi

######

EstimatePi: EstimatePi.dats ../../05/CODE/listfun.hats  ; $(PATSCC) -o $@ EstimatePi.dats

######

regress:: EstimatePi; ./EstimatePi

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f EstimatePi

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
