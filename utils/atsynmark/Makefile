######
#
# A Simple Makefile
#
# make            builds BUILD/pats2xhtml (and libatsynmark.a, libatsopt.a if they are missing)
#                 and copies it to $(PATSHOME)/bin/pats2xhtml
# make test       runs the md5 suite of libatsynmark/TEST (needs python3)
# make check      typechecks the files
#
# ATS1 is not needed: see Makefile_build
#
######

RMF=rm -f
CPF=cp -f
MAKE=make

PATSHOME ?= $(abspath $(CURDIR)/../..)
export PATSHOME

######

build:: ; \
$(MAKE) \
-C BUILD \
-f ../Makefile_build

build:: ; \
$(CPF) BUILD/pats2xhtml $(PATSHOME)/bin/pats2xhtml

######

all:: build

######

check:: ; \
$(MAKE) -C BUILD -f ../Makefile_build check

######

test:: ; $(MAKE) -C ../libatsynmark/TEST test
testall:: test

######
#
clean:: ; $(RMF) ./BUILD/*.o
clean:: ; $(RMF) ./BUILD/*.c
#
######
#
cleanall:: clean
#
cleanall:: ; $(RMF) ./BUILD/pats2xhtml
cleanall:: ; $(RMF) $(PATSHOME)/bin/pats2xhtml
#
######

###### end of [Makefile] ######
