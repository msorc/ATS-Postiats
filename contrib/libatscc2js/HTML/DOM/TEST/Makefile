# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
######
#
# Test of the DOM library of libatscc2js: [make regress] translates
# test02.dats and DATS/document.dats into JS and runs them under Node.js
# with a stub of the DOM (test_DOM.js).
# atscc2js is built by [make -C $(PATSHOME)/contrib/CATS-atscc2js].
#
######

PATSHOME ?= $(abspath ../../../../..)
export PATSHOME
PATSOPT=$(PATSHOME)/bin/patsopt
ATSCC2JS=$(PATSHOME)/contrib/CATS-atscc2js/bin/atscc2js
NODE=node

HAVE_ATSCC2JS=$(wildcard $(ATSCC2JS))
HAVE_NODE=$(shell which $(NODE) 2>/dev/null)

######

all::

ifneq ($(HAVE_ATSCC2JS),)
ifneq ($(HAVE_NODE),)
regress:: test02_dats.js document_dats.js ; $(NODE) test_DOM.js
endif
endif
regress::

test02_dats.c: test02.dats ; $(PATSOPT) -o $@ -d test02.dats
test02_dats.js: test02_dats.c ; $(ATSCC2JS) -o $@ -i test02_dats.c
document_dats.c: ../DATS/document.dats ; $(PATSOPT) -o $@ -d ../DATS/document.dats
document_dats.js: document_dats.c ; $(ATSCC2JS) -o $@ -i document_dats.c

######

clean:: ; rm -f *~ *_dats.c
cleanall:: clean
cleanall:: ; rm -f *_dats.js

######
