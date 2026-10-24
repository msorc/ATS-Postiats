# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The ATS3 (ATS-Xanadu) xatslib test corpus ported to ATS2.
#
# Each test is a small program that exercises one part of the
# library; the expected output is in the corresponding
# [*.test-cmp] file.
#
# The tests of the ATS3 [xatslib/githwxi] that need the CSV
# parser, the file reader or the object (hash map) library of
# that library are not ported; see [../MAPPING.txt].
#

######

include $(PATSHOME)/share/atsmake-pre.mk

######

TESTS = \
test00_githwxi \
test01_range00 \
test02_q2lst00 \
test03_gint000 \
test99_mydiary

######

all:: $(TESTS)

######

$(TESTS): % : %.dats ; \
  $(PATSCC2) -cleanaft -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o $@ $<

######

regress:: $(TESTS)
regress:: ; for t in $(TESTS); do \
  ./$$t 2>&1 | diff -q $$t.test-cmp - >/dev/null || \
  (echo "$$t failed" && exit 1); \
  done

######

cleanall:: ; $(RMF) $(TESTS)

######

include $(PATSHOME)/share/atsmake-post.mk

######

###### end of [Makefile] ######
