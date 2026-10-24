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

all:: HanoiTowers

######

HanoiTowers: HanoiTowers.dats  ; $(PATSCC) -o $@ HanoiTowers.dats

######

regress:: HanoiTowers; ./HanoiTowers

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f HanoiTowers

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
