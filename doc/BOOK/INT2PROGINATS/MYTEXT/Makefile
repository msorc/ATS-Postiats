######
#
# A simple Makefile
#
######

PATSCC=$(PATSHOME)/bin/patscc

######

# PATSHOME is the root of the ATS2 repository (or of an installation of
# ATS2); it defaults to the root of this repository.
PATSHOME ?= $(abspath ../../../..)
export PATSHOME

######

LDPATH := -L$(PATSHOME)/ccomp/atslib/lib
LIBRARY = -latsynmark -latsopt -latslib -lgmp

######

all:: mytexting

######
#
mytexting: \
mytexting.dats ; \
mkdir -p bin; \
$(PATSCC) \
  -O2 -o bin/$@ mytexting.dats \
  -DATS_MEMALLOC_LIBC \
  -I$(PATSHOME)/src $(LDPATH) $(LIBRARY)
#
######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_dats.c

cleanall:: clean
cleanall:: ; $(RMF) bin/mytexting

###### end of [Makefile] ######
