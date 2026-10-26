#
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: GPL-3.0-or-later
#
# patslint: a linter for ATS2 source files (see README)
#
# make            builds BUILD/patslint (and libatsynmark.a, libatsopt.a if they are
#                 missing) and copies it and patslint-diff to $(PATSHOME)/bin
# make test       runs the cases of TEST (needs python3)
# make check      typechecks the files
#

RMF=rm -f
CPF=cp -f
MAKE=make

PATSHOME ?= $(abspath $(CURDIR)/../..)
export PATSHOME

######

build:: ; $(MAKE) -C BUILD -f ../Makefile_build
build:: ; $(CPF) BUILD/patslint $(PATSHOME)/bin/patslint
build:: ; $(CPF) patslint-diff $(PATSHOME)/bin/patslint-diff

all:: build

######

check:: ; $(MAKE) -C BUILD -f ../Makefile_build check

test:: ; $(MAKE) -C BUILD -f ../Makefile_build
test:: ; LC_ALL=C python3 TEST/suite.py run --patslint BUILD/patslint --diff ./patslint-diff

testall:: test

# rewrites the expected outputs of TEST from the current patslint (review the diff)
update:: ; $(MAKE) -C BUILD -f ../Makefile_build
update:: ; LC_ALL=C python3 TEST/suite.py update --patslint BUILD/patslint --diff ./patslint-diff

######

clean:: ; $(MAKE) -C BUILD -f ../Makefile_build clean

cleanall:: ; $(MAKE) -C BUILD -f ../Makefile_build cleanall
cleanall:: ; $(RMF) $(PATSHOME)/bin/patslint $(PATSHOME)/bin/patslint-diff

###### end of [Makefile] ######
