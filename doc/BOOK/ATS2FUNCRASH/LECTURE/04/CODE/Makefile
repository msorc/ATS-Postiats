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

all:: lecture04
all:: multable

######

lecture04: lecture04.dats intfun.hats ; $(PATSCC) -o $@ lecture04.dats
multable: multable.dats intfun.hats ; $(PATSCC) -o $@ multable.dats

######

regress:: lecture04; ./lecture04
regress:: multable; ./multable > multable.html

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture04 multable multable.html

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
