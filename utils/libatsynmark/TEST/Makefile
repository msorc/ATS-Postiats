#
# Makefile of the tests of libatsynmark
#
#   make           builds test01 (the tokens of STDIN), test02 (the position-synmarks of STDIN),
#                  test03 (the functions of the API: see test03.dats)
#   make test      builds pats2xhtml and runs the md5 suite (suite.py: expected.md5, cases/)
#   make update    rewrites expected.md5 from the ATS1 programs REF_P2X, REF_API,
#                  REF_TEST01 and REF_TEST02 (see suite.py; not needed by the suite)
#
# The suite runs in a temporary directory with the locale C: it does not depend on the
# directory of the checkout nor on the locale of the caller.
#

include ../Makefile_vars

all:: test01 test02 test03

######

P2XDIR=$(PATSHOME)/utils/atsynmark/BUILD

test01 test02 test03: %: %.dats $(LIBSYNMARK) $(LIBATSOPT)
	$(PATSOPT) --output $@_dats.c --dynamic $<
	$(PATSCC) -o $@ $@_dats.c $(LIBSYNMARK) $(LIBATSOPT) $(LIBGMP)

$(P2XDIR)/pats2xhtml: $(LIBSYNMARK) $(LIBATSOPT)
	$(MAKE) -C $(P2XDIR) -f ../Makefile_build

######

test:: all $(P2XDIR)/pats2xhtml
	python3 suite.py run --p2x $(P2XDIR)/pats2xhtml --api ./test03 --test01 ./test01 --test02 ./test02

testall:: test

update:
	python3 suite.py update --p2x $(REF_P2X) --api $(REF_API) --test01 $(REF_TEST01) --test02 $(REF_TEST02)

######

clean:: ; $(RMF) *~ *_dats.c *_dats.o

cleanall:: clean
cleanall:: ; $(RMF) test01 test02 test03

###### end of [Makefile] ######
