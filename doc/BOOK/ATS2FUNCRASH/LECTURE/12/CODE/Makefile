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

all:: lecture12

######

lecture12: lecture12.dats ../../04-10/CODE/eventloop.hats ../../05/CODE/listfun.hats ../../10/CODE/streamfun.hats  ; $(PATSCC) -o $@ lecture12.dats

######

regress:: lecture12; ./lecture12

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f lecture12

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
