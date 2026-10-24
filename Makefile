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
#   make tools      # atsdoc, pats2xhtml and the libraries they need (not part of `make all`)
#   make test       # the regression suites of the repository (builds `all` and `tools` first)
#   make install    # PREFIX=/usr/local DESTDIR=: lib/ats2-postiats-<version>/ and the wrappers bin/{patsopt,patscc,myatscc,...}
#   make uninstall  # removes what `make install` made
#   make dist       # the release tarballs and their .sha256
#   make doc        # regenerate the generated sources of the libraries
#   make book       # make the books (the HTML and the PDF)
#   make pack       # the release tarballs
#   make clean      # remove the build products
#   make distclean  # remove all the build products (the tree is as after a clone)
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

.PHONY: all bootstrap tools check test doc book pack dist install uninstall clean cleanall distclean

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
# atsdoc, pats2xhtml, libatsdoc.a and libatsynmark.a (they are built on
# libatsopt.a, so `all` comes first)
#
tools:: all
	$(MAKE) -f $(DEVL) bin_atsdoc bin_pats2xhtml

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
test:: all tools
	PATH=$(PATSHOME)/bin:$$PATH $(MAKE) -C src test
	PATH=$(PATSHOME)/bin:$$PATH $(MAKE) -C utils/atsdoc test
	PATH=$(PATSHOME)/bin:$$PATH $(MAKE) -C utils/libatsynmark test
	PATH=$(PATSHOME)/bin:$$PATH $(MAKE) -C doc -f Makefile_test testall

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
# the release tarballs in doc/DISTRIB: ATS2-Postiats-<version>.tgz (./configure
# builds with libgmp when <gmp.h> is there, else without it) and
# ATS2-Postiats-include-<version>.tgz
#
pack::
	@if [ ! -x bin/atsdoc ] ; then \
	  echo "ERROR: bin/atsdoc is missing: build it with 'make -f $(DEVL) bin_atsdoc'." && exit 1 ; \
	fi
	@if [ ! -f src/CBOOT/modules.mk ] ; then \
	  echo "ERROR: src/CBOOT is incomplete: regenerate it with 'make -C src CBOOT'." && exit 1 ; \
	fi
	$(MAKE) -C doc/DISTRIB atspackaging
	$(MAKE) -C doc/DISTRIB atspacktarzvcf
	$(MAKE) -C doc/DISTRIB -f Makefile_inclats tarzvcf

######
#
# make install [PREFIX=/usr/local] [DESTDIR=]
#
# $(PREFIX)/lib/ats2-postiats-<version>/ is PATSHOME: the files that patsopt,
# patscc and the programs they compile need at run time (bin/, prelude/,
# libats/, share/, contrib/, ccomp/runtime/, ccomp/atslib/lib/*.a); the
# scripts $(PREFIX)/bin/{patsopt,patscc,myatscc,...} set PATSHOME to it (when
# the caller has not) and exec the real programs. atsdoc, pats2xhtml,
# libatsopt.a, libatsdoc.a and libatsynmark.a are installed when they were
# built (make tools). DESTDIR is for packagers: it is not in the scripts.
#
VERSION := $(shell cat $(PATSHOME)/VERSION 2>/dev/null)
PACKAGE_TARNAME := ats2-postiats
PREFIX ?= /usr/local
DESTDIR ?=
#
INST_HOME := $(PREFIX)/lib/$(PACKAGE_TARNAME)-$(VERSION)
INST_HOME_D := $(DESTDIR)$(INST_HOME)
INST_BIN_D := $(DESTDIR)$(PREFIX)/bin
# the programs of bin/ that are installed when they exist (with a script in $(PREFIX)/bin)
INST_PROGS := patsopt patscc myatscc atsdoc pats2xhtml
# the trees that are copied (symbolic links are kept; the build products are not)
INST_TREES := share ccomp/runtime prelude libats contrib
#
define WRAPPER
#!/bin/sh
# @PROG@ of ATS2/Postiats $(VERSION): sets PATSHOME and runs the real program
: "$${PATSHOME:=@HOME@}"
export PATSHOME
if [ ! -d "$$PATSHOME" ] ; then
  echo "ATS-Postiats should have been available at '$$PATSHOME'" >&2
  exit 1
fi
exec "$$PATSHOME/bin/@PROG@" "$$@"
endef
export WRAPPER
#
install::
	@test -n "$(VERSION)" || { echo "ERROR: no VERSION file" ; exit 1 ; }
	@for p in patsopt patscc myatscc ; do \
	  test -x $(PATSHOME)/bin/$$p || { echo "ERROR: bin/$$p is not built: run 'make' first." ; exit 1 ; } ; \
	done
	@test -f $(PATSHOME)/ccomp/atslib/lib/libatslib.a || { echo "ERROR: ccomp/atslib/lib/libatslib.a is not built: run 'make' first." ; exit 1 ; }
	mkdir -p $(INST_HOME_D)/bin $(INST_HOME_D)/ccomp/atslib/lib $(INST_BIN_D)
	cd $(PATSHOME) && tar -cf - --exclude='*.o' --exclude=.keeper $(INST_TREES) \
	  | tar -xf - -C $(INST_HOME_D)
	cd $(PATSHOME) && for f in AUTHORS COPYING VERSION ; do \
	  test -f $$f && cp -f $$f $(INST_HOME_D)/ ; done ; true
	cd $(PATSHOME) && if [ -d libatsdoc -a -x bin/atsdoc ] ; then \
	  mkdir -p $(INST_HOME_D)/utils/atsdoc && \
	  tar -cf - --exclude='*.o' --exclude=BUILD libatsdoc | tar -xf - -C $(INST_HOME_D) && \
	  tar -cf - utils/atsdoc/HATS | tar -xf - -C $(INST_HOME_D) ; fi
	cd $(PATSHOME) && for p in $(INST_PROGS) ; do \
	  if [ -x bin/$$p ] ; then \
	    install -m 755 bin/$$p $(INST_HOME_D)/bin/$$p && \
	    printf '%s\n' "$$WRAPPER" | sed -e 's|@PROG@|'$$p'|g' -e 's|@HOME@|$(INST_HOME)|g' > $(INST_BIN_D)/$$p && \
	    chmod 755 $(INST_BIN_D)/$$p ; \
	  fi ; done
	cd $(PATSHOME) && for l in libatslib libatsopt libatsdoc libatsynmark ; do \
	  if [ -f ccomp/atslib/lib/$$l.a ] ; then \
	    install -m 644 ccomp/atslib/lib/$$l.a $(INST_HOME_D)/ccomp/atslib/lib/$$l.a ; \
	  fi ; done
	@echo "installed: $(INST_HOME_D) and $(INST_BIN_D)/{patsopt,patscc,myatscc,...}"

# the scripts are removed by name and PATSHOME as a whole; the empty $(PREFIX)/bin and
# $(PREFIX)/lib that install may have created are removed too (rmdir never removes a non-empty directory)
uninstall::
	for p in $(INST_PROGS) ; do rm -f $(INST_BIN_D)/$$p ; done
	rm -rf $(INST_HOME_D)
	-rmdir $(INST_BIN_D) $(DESTDIR)$(PREFIX)/lib 2>/dev/null ; true

######
#
# make dist: the release tarballs ATS2-Postiats-*.tgz, each with a .sha256
#
dist:: pack
	cd doc/DISTRIB && for f in ATS2-Postiats-$(VERSION).tgz ATS2-Postiats-include-$(VERSION).tgz ; do \
	  { sha256sum $$f || shasum -a 256 $$f ; } > $$f.sha256 && ls -l $$f $$f.sha256 && cat $$f.sha256 || exit 1 ; \
	done

######

clean::
	$(MAKE) -f $(DEVL) src_cleanall
	$(MAKE) -f $(DEVL) atslib_cleanall
	$(MAKE) -C src/CBOOT clean

cleanall:: clean

# all the build products, including the programs of bin/ and the libraries
distclean:: cleanall
	rm -f $(addprefix bin/,$(INST_PROGS)) ccomp/atslib/lib/*.a ccomp/atslib/output/*
	-$(MAKE) -C utils/atsdoc cleanall
	-$(MAKE) -C utils/atsynmark cleanall
	-$(MAKE) -C utils/libatsynmark cleanall

######

###### end of [Makefile] ######
