# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: fold on demand and proof-argument elision
# Testing the folding of unfolded datavtype values by the checker, and
# the calls that omit the proofs of preserved at-views (POS_elide*,
# NEG_elide_*): each POS_*.dats must compile and run (without leaks for
# leakcheck), each NEG_*.dats must be rejected with its hint or reason
#
######

include $(PATSHOME)/share/atsmake-pre.mk

######

PATSCCOMP=\
$(CC) -std=c99 -D_GNU_SOURCE -D_XOPEN_SOURCE -I${PATSHOMEQ} -I${PATSHOMEQ}/ccomp/runtime
export PATSCCOMP

######

POSTESTS := POS_traverse POS_demand POS_rotate POS_elide POS_elide_overload
NEGTESTS := NEG_consumed.dats NEG_fieldtype.dats
NEGELIDE := NEG_elide_noaddr NEG_elide_nonat NEG_elide_consumed

######

all:: $(POSTESTS)
POS_%: POS_%.dats ; $(PATSCC) -O2 -o $@ $<
cleanall:: ; $(RMF) $(POSTESTS)

######

regress:: $(POSTESTS); \
for t in $(POSTESTS); do ./$$t || { echo "$$t failed"; exit 1; }; done
regress:: ; \
for f in $(NEGTESTS); do \
  if $(PATSOPT) --typecheck -d $$f > $$f.out 2>&1; then \
    echo "$$f: accepted but should be rejected"; exit 1; \
  fi; \
  grep -q "is unfolded (pattern at .*) and fold@ xs cannot be applied" $$f.out || \
    { echo "$$f: rejected without the hint"; cat $$f.out; exit 1; }; \
  $(RMF) $$f.out; \
done; echo "NEG_*: all rejected"
#
# HX: the reasons of the two negative tests
#
NEG_consumed.dats.hint: NEG_consumed.dats ; \
  $(PATSOPT) --typecheck -d $< > $@ 2>&1 || true
NEG_fieldtype.dats.hint: NEG_fieldtype.dats ; \
  $(PATSOPT) --typecheck -d $< > $@ 2>&1 || true
regress:: NEG_consumed.dats.hint NEG_fieldtype.dats.hint; \
grep -q "the view of field 1 is consumed" NEG_consumed.dats.hint && \
grep -q "field 2 has type .* but the constructor needs" NEG_fieldtype.dats.hint && \
echo "NEG_*: the reasons are given"
#
# HX: proof-argument elision: the reasons of the negative tests
#
NEG_elide_%.hint: NEG_elide_%.dats ; \
  if $(PATSOPT) --typecheck -d $< > $@ 2>&1; then \
    echo "$<: accepted but should be rejected"; $(RMF) $@; exit 1; \
  fi
regress:: $(addsuffix .hint,$(NEGELIDE)); \
grep -q "cannot be inferred from the other arguments" NEG_elide_noaddr.hint && \
grep -q "which is not an at-view" NEG_elide_nonat.hint && \
grep -q "which is consumed (no !)" NEG_elide_consumed.hint && \
echo "NEG_elide_*: all rejected with the reasons"
cleanall:: ; $(RMF) *.hint

######
#
# HX: checking for leaks with LeakSanitizer
#
leakcheck:: ; \
for t in $(POSTESTS); do \
  $(PATSCC) -g -fsanitize=address -o $${t}_asan $$t.dats && ./$${t}_asan || exit 1; \
done
cleanall:: ; $(RMF) $(addsuffix _asan,$(POSTESTS))

######

testall:: all
testall:: regress
testall:: cleanall

######

include $(PATSHOME)/share/atsmake-post.mk

######

cleanats:: ; $(RMF) *_?ats.c
cleanats:: ; $(RMF) *.dats.out

######

cleanall:: clean

###### end of [Makefile] ######
