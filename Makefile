# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The entry point of the build of ATS2 (ATS/Postiats).
#
# The steps of the build are in Makefile_devl (the release script uses
# them); this Makefile gives them the names that are easier to remember:
#
#   make bootstrap  # a clone with no ATS2 compiler: build patsopt from the C bundle src/CBOOT (a C compiler, make and python3; libgmp or KIND=intknd), then everything
#   make            # the same as `make all` (it bootstraps when there is no bin/patsopt and no PATSOPT)
#   make check      # typecheck every module of the compiler
#   make test       # the regression suites of the repository
#   make doc        # regenerate the generated sources of the libraries
#   make book       # make the books (the HTML and the PDF)
#   make pack       # the release tarballs
#   make clean      # remove the build products
#
# The stage-0 compiler (the first patsopt; ATS1 is not needed) is, in this
# order: PATSOPT; bin/patsopt of an earlier build; else the tracked bootstrap
# bundle src/CBOOT is compiled (`make bootstrap`, done by `make all` itself).
# A patsopt of the PATH is used only when PATSOPT says so. For an installed
# ATS2 give PATSOPT (and STAGE0HOME):
#
#   make PATSOPT=/usr/bin/patsopt STAGE0HOME=/usr/lib/ats2-postiats-0.4.2 all
#
# PATSHOME is the root of this repository; it defaults to it and it is
# exported so that the sub-makes (the tools, the libraries and the tests)
# find it without the environment having to be set up beforehand:
#
#   PATSHOME=/path/to/this/repository make all
#
# The old name of this Makefile (Makefile_devl) still works.
#

######

MAKE=make
DEVL=Makefile_devl

# PATSHOME defaults to the root of this repository
PATSHOME ?= $(abspath $(CURDIR))
export PATSHOME

# the arguments of the stage-0 compiler are passed on only when they are given
ifdef PATSOPT
PATSOPT_ARG=PATSOPT=$(PATSOPT)
else
PATSOPT_ARG=
endif
ifdef STAGE0HOME
STAGE0HOME_ARG=STAGE0HOME=$(STAGE0HOME)
else
STAGE0HOME_ARG=
endif

PATSOPT_ARGS=$(PATSOPT_ARG) $(STAGE0HOME_ARG)

######

# the number of parallel jobs of the compilation of the bundle
JOBS ?= $(shell nproc 2>/dev/null || echo 4)
# KIND=intknd (no libgmp) is passed on to the bundle and to the compiler; without it both probe <gmp.h>
ifdef KIND
BOOT_ARGS=KIND=$(KIND)
ifeq ($(KIND),intknd)
C3_ARG=C3NSTRINTKND=intknd
endif
endif

.PHONY: all bootstrap check test doc book pack clean cleanall

######

# without PATSOPT and bin/patsopt the bootstrap bundle is the stage-0 compiler
ifndef PATSOPT
ifeq ($(wildcard $(PATSHOME)/bin/patsopt),)
all:: bootstrap
else
all::
	$(MAKE) -f $(DEVL) $(C3_ARG) all
endif
else
all::
	$(MAKE) -f $(DEVL) $(PATSOPT_ARGS) $(C3_ARG) all
endif

######
#
# bootstrap: patsopt from the C bundle src/CBOOT (a C compiler and libgmp only; CC=, CFLAGS=, KIND=intknd as in
# src/CBOOT/README), then the normal build `all` with that patsopt as stage 0, which installs bin/patsopt
#
bootstrap::
	$(MAKE) -C src/CBOOT -j$(JOBS) $(BOOT_ARGS) patsopt
	$(MAKE) -f $(DEVL) PATSOPT=$(abspath $(CURDIR))/src/CBOOT/patsopt $(C3_ARG) all
	@echo "bootstrap: done: bin/patsopt and bin/patscc are built from src/CBOOT; use PATSHOME=$(abspath $(CURDIR)) PATH=$(abspath $(CURDIR))/bin:\$$PATH"

######
#
# the type checking of every module of the compiler (it needs the stage-0
# compiler only)
#
check::
	$(MAKE) -C src $(PATSOPT_ARGS) check

######
#
# the regression suites: the compiler, the tools and the examples
#
test::
	$(MAKE) -C src test
	$(MAKE) -C utils/atsdoc test
	$(MAKE) -C utils/libatsynmark test
	$(MAKE) -C doc -f Makefile_test testall

######
#
# the regeneration of the generated sources of the libraries (the prelude
# sources are kept in git; the script that regenerates them is
# codegen/Makefile_atslib)
#
doc::
	$(MAKE) -f codegen/Makefile_atslib

######
#
# the books: the HTML and the PDF of the books are made with the tools
# that are described in doc/BOOK/README.md
#
BOOKS=INT2PROGINATS ATS2TUTORIAL ATS-for-APUE3 ATS2FUNCRASH
#
book::
	@for i in $(BOOKS); do \
	  echo "=== making the book: $$i" ; \
	  $(MAKE) -C doc/BOOK/$$i all || exit 1 ; \
	done

######
#
# the release tarballs: ATS2-Postiats-<version>.tgz (the two variants:
# with and without libgmp) and ATS2-Postiats-include-<version>.tgz
#
pack::
	@if [ ! -x bin/atsdoc ] ; then \
	  echo "ERROR: bin/atsdoc is missing: build it with 'make -f $(DEVL) bin_atsdoc'." && exit 1 ; \
	fi
	@if [ ! -f src/CBOOT/modules.mk ] ; then \
	  echo "ERROR: src/CBOOT is incomplete: regenerate it with 'make -C src CBOOT'." && exit 1 ; \
	fi
	$(MAKE) -C doc/DISTRIB atspackaging
	$(MAKE) -C doc/DISTRIB atspacktarzvcf_gmp
	$(MAKE) -C doc/DISTRIB atspacktarzvcf_int
	$(MAKE) -C doc/DISTRIB -f Makefile_inclats tarzvcf

######

clean::
	$(MAKE) -f $(DEVL) src_cleanall
	$(MAKE) -f $(DEVL) atslib_cleanall
	$(MAKE) -C src/CBOOT clean

cleanall:: clean

######

###### end of [Makefile] ######
