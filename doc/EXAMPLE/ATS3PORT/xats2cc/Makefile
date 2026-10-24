# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The ATS3 (ATS-Xanadu) C-backend test corpus ported to ATS2.
#
# Each test exercises one feature of the language (closures,
# pattern matching, external functions, ...) and the expected
# output is in the corresponding [*.test-cmp] file.
#

######

include $(PATSHOME)/share/atsmake-pre.mk

######

TESTS = \
test00_xats2cc \
test01_xats2cc \
test02_xats2cc \
test03_xats2cc \
test04_xats2cc \
test05_xats2cc \
test06_xats2cc \
test07_xats2cc \
test08_xats2cc \
test09_xats2cc \
test10_xats2cc \
test11_xats2cc

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

cleanall:: ; $(RMF) $(TESTS) $(TESTS)_dats.c

######

include $(PATSHOME)/share/atsmake-post.mk

######

###### end of [Makefile] ######
