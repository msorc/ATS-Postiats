######
#
# Makefile of atsdoc (the text processor that turns a .atxt file into an ATS2 program)
#
# make            builds BUILD/atsdoc and copies it to $(PATSHOME)/bin/atsdoc
#                 (it builds libatsopt.a if it is missing), and builds libatsdoc.a
#                 (../../libatsdoc) and copies it to $(PATSHOME)/ccomp/atslib/lib
# make build      only atsdoc
# make libs       only libatsdoc.a (after atsdoc)
# make test       runs the md5 suite of TEST/ (needs python3 and bin/patscc)
# make check      typechecks the files
# make genall     regenerates the files of the .atxt templates of the repository with this
#                 toolchain only and compares them with the expected ones (TEST/genall.sh,
#                 TEST/genall.md5; GENARGS="prelude" or a path prefix to run a part, JOBS=n)
# make genprelude the same for the prelude SRCGEN directories (tracked files; no ATS1)
#
# ATS1 is not needed: see Makefile_build and ../../libatsdoc/Makefile
#
######

RMF=rm -f
CPF=cp -f
MAKE=make

PATSHOME ?= $(abspath $(CURDIR)/../..)

.DEFAULT_GOAL := all

######

build:: ; \
$(MAKE) -C BUILD -f ../Makefile_build

build:: ; \
$(CPF) BUILD/atsdoc $(PATSHOME)/bin/atsdoc

######

all:: build libs

libs:: build ; $(MAKE) -C $(PATSHOME)/libatsdoc install

######

check:: ; \
$(MAKE) -C BUILD -f ../Makefile_build check

######

test:: ; $(MAKE) -C TEST test
testall:: test

######
#
# the programs of the DOCUGEN documents need libatsynmark.a and libatsopt.a in
# ccomp/atslib/lib (`make -f Makefile_devl all bin_pats2xhtml` builds them)
#
GENARGS=all
JOBS=8
#
genall:: all ; $(MAKE) -C ../libatsynmark install
genall:: ; PATSHOME=$(PATSHOME) sh TEST/genall.sh -j $(JOBS) $(GENARGS)
genprelude:: all ; PATSHOME=$(PATSHOME) sh TEST/genall.sh prelude
#
######

######
#
clean:: ; $(RMF) ./BUILD/*.o
clean:: ; $(RMF) ./BUILD/*.c
clean:: ; $(MAKE) -C TEST clean
#
######
#
cleanall:: clean
#
cleanall:: ; $(RMF) ./BUILD/atsdoc
cleanall:: ; $(RMF) $(PATSHOME)/bin/atsdoc
cleanall:: ; $(MAKE) -C TEST cleanall
cleanall:: ; $(MAKE) -C $(PATSHOME)/libatsdoc cleanall
#
######

###### end of [Makefile] ######
