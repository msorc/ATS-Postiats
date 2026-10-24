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

all:: game24

######

game24: game24.dats ../../05/CODE/listfun.hats ../../06/CODE/listfun2.hats ../../07/CODE/listfun3.hats game24.sats game24_gen.hats game24_gen_dats.hats ; $(PATSCC) -o $@ game24.dats

######

regress:: game24; ./game24

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f game24

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
