#
# The ATS3 (ATS-Xanadu) prelude test corpus ported to ATS2.
#
# Each test is a small program that exercises one part of the
# ATS2 library; the expected output is in the corresponding
# [*.test-cmp] file.  The reference output of the original
# ATS3 programs is in [../goldens/prelude].
#

######

include $(PATSHOME)/share/atsmake-pre.mk

######

TESTS = \
test00_prelude \
test01_a0rf000 \
test02_a1rf000 \
test03_a1sz000 \
test04_strn000 \
test05_gdbg000 \
test06_list000 \
test07_gseq000 \
test08_optn000 \
test09_llist00 \
test10_xcptn00 \
test11_gasq000

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
