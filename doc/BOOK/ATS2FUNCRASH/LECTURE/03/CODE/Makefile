######
#
# A simple Makefile
#
######

# PATSHOME is the root of the ATS2 repository (or of an installation of ATS2)
PATSHOME ?= $(abspath ../../../../../..)
export PATSHOME
PATSCC=$(PATSHOME)/bin/patscc
MYATSCC=$(PATSHOME)/bin/myatscc

######

all::

######

all:: \
lecture03
lecture03: ; \
$(MYATSCC) lecture03.dats

######

regress:: lecture03; ./lecture03_dats

######

clean:: ; rm -f *~

######

cleanall:: clean
cleanall:: ; rm -f *_dats

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
