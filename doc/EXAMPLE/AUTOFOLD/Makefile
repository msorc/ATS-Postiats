# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: fold on demand
# Testing the folding of unfolded datavtype values by the checker:
# each POS_*.dats must compile and run (without leaks for leakcheck),
# each NEG_*.dats must be rejected with the hint of fold on demand
#
######

include $(PATSHOME)/share/atsmake-pre.mk

######

PATSCCOMP=\
$(CC) -std=c99 -D_GNU_SOURCE -D_XOPEN_SOURCE -I${PATSHOMEQ} -I${PATSHOMEQ}/ccomp/runtime
export PATSCCOMP

######

POSTESTS := POS_traverse POS_demand POS_rotate
NEGTESTS := $(wildcard NEG_*.dats)

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
