#
# HX-2026-10: no GC
# Testing the rules for linear heap allocation:
# each NEG_*.dats must be rejected by patsopt, and
# POS_linheap.dats must compile, run and not leak
#
######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

NEGTESTS := $(wildcard NEG_*.dats)

######

all:: \
POS_linheap
POS_linheap: POS_linheap.dats; \
  $(PATSCC) -O2 -o $@ $<
cleanall:: ; $(RMF) POS_linheap

all:: \
POS_arena
POS_arena: POS_arena.dats; \
  $(PATSCC) -O2 -o $@ $<
cleanall:: ; $(RMF) POS_arena

######

regress:: POS_linheap; ./$< || (echo "$< failed" && exit 1)
regress:: POS_arena; ./$< || (echo "$< failed" && exit 1)
regress:: ; \
if $(PATSOPT) --typecheck -d NEGUAF_arena.dats > NEGUAF.out 2>&1; then \
  echo "NEGUAF_arena.dats: accepted but should be rejected"; exit 1; \
fi; \
grep -q "is no longer available" NEGUAF.out || \
  { echo "NEGUAF_arena.dats: rejected for another reason"; cat NEGUAF.out; exit 1; }; \
$(RMF) NEGUAF.out; echo "NEGUAF_arena: rejected"
regress:: ; \
for f in $(NEGTESTS); do \
  if $(PATSOPT) --typecheck -d $$f > $$f.out 2>&1; then \
    echo "$$f: accepted but should be rejected"; exit 1; \
  fi; \
  grep -q "nonlinear heap allocation is not supported" $$f.out || \
    { echo "$$f: rejected for another reason"; cat $$f.out; exit 1; }; \
  $(RMF) $$f.out; \
done; echo "NEG_*: all rejected"

######
#
# HX: checking for leaks with LeakSanitizer
#
leakcheck:: POS_linheap.dats; \
  $(PATSCC) -g -fsanitize=address \
    -o POS_linheap_asan $< && ./POS_linheap_asan
leakcheck:: POS_arena.dats; \
  $(PATSCC) -g -fsanitize=address \
    -o POS_arena_asan $< && ./POS_arena_asan
cleanall:: ; $(RMF) POS_linheap_asan POS_arena_asan
#
######

testall:: all
testall:: regress
testall:: cleanall

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *.dats.out NEGUAF.out

######

cleanall:: clean

###### end of [Makefile] ######
