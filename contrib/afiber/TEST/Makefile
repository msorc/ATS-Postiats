#
# MS-2026-10: afiber tests
# POS_*.dats must compile and run; NEG_consume_*.dats must be rejected
# with "needs to be consumed", NEG_uaf_*.dats with "is no longer available".
# To add a test: append it to POSTESTS (channel tests will go there).
# CFLAGS_EXTRA is appended to the patscc flags of [all] and [leakcheck]:
#   make regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_UCONTEXT
# [regress_variants] runs the suite with the fallback builds (ucontext
# switch, malloc'd stacks, a bounded stack cache).
#
######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt
RMF=rm -f
CFLAGS_EXTRA ?=

POSTESTS := POS_yield POS_join POS_many POS_recursion POS_sleep POS_exn POS_pingpong POS_prodcons POS_linear POS_trysend POS_waves

NEGCONSUME := $(wildcard NEG_consume_*.dats)
NEGUAF := $(wildcard NEG_uaf_*.dats)

######

all:: $(POSTESTS)
$(POSTESTS): %: %.dats; \
  $(PATSCC) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 $(CFLAGS_EXTRA) -o $@ $<
cleanall:: ; $(RMF) $(POSTESTS)

######

regress:: $(POSTESTS) ; \
for t in $(POSTESTS); do \
  ./$$t || { echo "$$t failed"; exit 1; }; \
done
regress:: ; \
for f in $(NEGCONSUME); do \
  if $(PATSOPT) --typecheck -d $$f > $$f.out 2>&1; then \
    echo "$$f: accepted but should be rejected"; exit 1; \
  fi; \
  grep -q "needs to be consumed" $$f.out || \
    { echo "$$f: rejected for another reason"; cat $$f.out; exit 1; }; \
  $(RMF) $$f.out; \
done; echo "NEG_consume_*: all rejected"
regress:: ; \
for f in $(NEGUAF); do \
  if $(PATSOPT) --typecheck -d $$f > $$f.out 2>&1; then \
    echo "$$f: accepted but should be rejected"; exit 1; \
  fi; \
  grep -q "is no longer available" $$f.out || \
    { echo "$$f: rejected for another reason"; cat $$f.out; exit 1; }; \
  $(RMF) $$f.out; \
done; echo "NEG_uaf_*: all rejected"

######

regress_variants:: ; \
$(MAKE) cleanall regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_UCONTEXT && \
$(MAKE) cleanall regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_STACK_MALLOC && \
$(MAKE) cleanall regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_STACK_CACHE=8 && \
$(MAKE) cleanall

######
#
# HX: leak check with ASan. afiber.cats has the
# __sanitizer_start/finish_switch_fiber hooks; without them one would need
# ASAN_OPTIONS=detect_stack_use_after_return=0
#
leakcheck:: ; \
for t in $(POSTESTS); do \
  $(PATSCC) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -g -fsanitize=address $(CFLAGS_EXTRA) \
    -o $${t}_asan $$t.dats && ./$${t}_asan || exit 1; \
done
cleanall:: ; $(RMF) $(addsuffix _asan,$(POSTESTS))

######

testall:: all regress cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *.out

cleanall:: clean

###### end of [Makefile] ######
