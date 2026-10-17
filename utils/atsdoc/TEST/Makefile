#
# Makefile of the tests of atsdoc and libatsdoc
#
#   make           builds drv (the driver of the API of libatsdoc: see drv.dats)
#   make test      builds atsdoc, libatsdoc.a and drv, and runs the md5 suite (suite.py:
#                  expected.md5, cases/; needs python3)
#   make update    rewrites expected.md5 from the ATS1 programs REF_ATSDOC and REF_DRV
#                  (drv1.dats and rthelp.c linked with the ATS1 libatsdoc.a; not needed by the suite)
#
# The suite runs in temporary directories with the locale C and without ATS1.
#

# The outputs are compared by md5 sums: fix the collation and the messages of
# the C library (perror: "No such file or directory"...), whatever the locale of the
# caller is.
export LC_ALL := C
# The name of the function that [dynload "libatsdoc/dynloadall.dats"] calls contains the
# path of that file (as patsopt sees it): drv.dats and libatsdoc.a must be built with the
# canonical root of this repository, whatever PATSHOME the caller has (e.g. one with ".."
# segments).
export PATSHOME := $(abspath ../../..)

include $(PATSHOME)/libatsdoc/Makefile_vars

all:: drv

######

ATSDOC=$(PATSHOME)/utils/atsdoc/BUILD/atsdoc

# the sub-makes decide what is out of date
$(LIBATSDOC): FORCE
	$(MAKE) -C $(PATSHOME)/libatsdoc PATSHOME=$(PATSHOME)

$(ATSDOC): FORCE
	$(MAKE) -C $(PATSHOME)/utils/atsdoc PATSHOME=$(PATSHOME)

FORCE:

drv: drv.dats rthelp.c $(LIBATSDOC)
	$(PATSOPT) --output drv_dats.c --dynamic drv.dats
	$(PATSCC) -o $@ drv_dats.c rthelp.c $(LIBATSDOC)

######

test:: $(ATSDOC) drv
	python3 suite.py run --atsdoc $(ATSDOC) --drv ./drv

testall:: test

update:
	python3 suite.py update --atsdoc $(REF_ATSDOC) --drv $(REF_DRV)

######

clean:: ; $(RMF) *~ *_dats.c *_dats.o

cleanall:: clean
cleanall:: ; $(RMF) drv

###### end of [Makefile] ######
