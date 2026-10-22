#
# The entry point of the build of ATS2 (ATS/Postiats).
#
# The steps of the build are in Makefile_devl (the release script uses
# them); this Makefile gives them the names that are easier to remember:
#
#   make            # the same as `make all`
#   make check      # typecheck every module of the compiler
#   make test       # the regression suites of the repository
#   make doc        # regenerate the generated sources of the libraries
#   make pack       # the release tarballs
#   make clean      # remove the build products
#
# The stage-0 compiler (the first patsopt; ATS1 is not needed) is given
# with PATSOPT (and STAGE0HOME for an installed ATS2):
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

.PHONY: all check test doc pack clean cleanall

######

all::
	$(MAKE) -f $(DEVL) $(PATSOPT_ARGS) all

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
# the release tarballs: ATS2-Postiats-<version>.tgz (the two variants:
# with and without libgmp) and ATS2-Postiats-include-<version>.tgz
#
pack::
	@if [ ! -x bin/atsdoc ] ; then \
	  echo "ERROR: bin/atsdoc is missing: build it with 'make -f $(DEVL) bin_atsdoc'." && exit 1 ; \
	fi
	@if [ ! -d src/CBOOT ] ; then \
	  echo "ERROR: src/CBOOT is missing: generate it with 'make -C src CBOOT'." && exit 1 ; \
	fi
	$(MAKE) -C doc/DISTRIB atspackaging
	$(MAKE) -C doc/DISTRIB atspacktarzvcf_gmp
	$(MAKE) -C doc/DISTRIB atspacktarzvcf_int
	$(MAKE) -C doc/DISTRIB -f Makefile_inclats tarzvcf

######

clean::
	$(MAKE) -f $(DEVL) src_cleanall
	$(MAKE) -f $(DEVL) atslib_cleanall

cleanall:: clean

######

###### end of [Makefile] ######
