######
#
# A simple Makefile
#
# [make] generates Factorial_dats.js; [make regress] runs it under Node.js
# with a stub of the DOM (the page Factorial.html needs a browser).
# atscc2js is built by [make -C $(PATSHOME)/contrib/CATS-atscc2js].
#
######

# PATSHOME is the root of the ATS2 repository (or of an installation of ATS2)
PATSHOME ?= $(abspath ../../../../../..)
export PATSHOME
PATSOPT=$(PATSHOME)/bin/patsopt
ATSCC2JS=$(PATSHOME)/contrib/CATS-atscc2js/bin/atscc2js
NODE=node

######

HAVE_ATSCC2JS=$(wildcard $(ATSCC2JS))
HAVE_NODE=$(shell which $(NODE) 2>/dev/null)

######

ifneq ($(HAVE_ATSCC2JS),)
all:: Factorial_dats.js
else
all:: ; @echo "atscc2js is not built: skipped"
endif

Factorial_dats.c: Factorial.dats ; $(PATSOPT) -o $@ -d Factorial.dats
Factorial_dats.js: Factorial_dats.c ; $(ATSCC2JS) -o $@ -i Factorial_dats.c

######

ifneq ($(HAVE_ATSCC2JS),)
ifneq ($(HAVE_NODE),)
regress:: Factorial_dats.js ; $(NODE) test_Factorial.js
endif
endif
regress::

######

clean:: ; rm -f *~ Factorial_dats.c

######

cleanall:: clean
cleanall:: ; rm -f Factorial_dats.js

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
