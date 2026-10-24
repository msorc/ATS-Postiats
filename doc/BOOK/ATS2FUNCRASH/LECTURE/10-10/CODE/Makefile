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

all:: QueenPuzzle

######

QueenPuzzle: QueenPuzzle.dats ../../05/CODE/listfun.hats ../../06/CODE/listfun2.hats ../../06/CODE/queens.hats ../../10/CODE/streamfun.hats  ; $(PATSCC) -o $@ QueenPuzzle.dats

######

regress:: QueenPuzzle; ./QueenPuzzle

######

clean:: ; rm -f *~ *_dats.c

######

cleanall:: clean
cleanall:: ; rm -f QueenPuzzle

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
