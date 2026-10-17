######
#
# A Simple Makefile
#
# make            builds BUILD/libatsynmark.a (link it with libatsopt.a and -lgmp, see Makefile_build)
# make install    copies it to $(PATSHOME)/ccomp/atslib/lib
# make test       builds the programs of TEST/ and runs the md5 suite (needs python3)
# make check      typechecks the files
#
# ATS1 is not needed: see Makefile_build
#
######

CPF=cp -f
RMF=rm -f
MAKE=make

PATSHOME ?= $(abspath $(CURDIR)/../..)

######

build:: ; \
$(MAKE) -C BUILD -f ../Makefile_build

######

all:: build

######

install:: build ; \
mkdir -p $(PATSHOME)/ccomp/atslib/lib && $(CPF) BUILD/libatsynmark.a $(PATSHOME)/ccomp/atslib/lib/

######

check:: ; \
$(MAKE) -C BUILD -f ../Makefile_build check

######

test:: build ; $(MAKE) -C TEST test
testall:: test

######
#
clean:: ; $(RMF) ./BUILD/*.o
clean:: ; $(RMF) ./BUILD/*.c
clean:: ; $(RMF) ./BUILD/*.?ats
clean:: ; $(MAKE) -C TEST clean
#
######
#
cleanall:: clean
#
cleanall:: ; $(RMF) ./BUILD/libatsynmark.a
cleanall:: ; $(MAKE) -C TEST cleanall
#
######

###### end of [Makefile] ######
