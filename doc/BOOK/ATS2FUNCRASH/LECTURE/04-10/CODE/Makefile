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

all:: animate

######

animate: animate.dats eventloop.hats ; $(PATSCC) -o $@ animate.dats

######

regress:: animate; ./animate

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f animate

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
