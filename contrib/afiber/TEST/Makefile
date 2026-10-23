#
# MS-2026-10: afiber tests
# POS_*.dats must compile and run; NEG_consume_*.dats must be rejected
# with "needs to be consumed", NEG_uaf_*.dats with "is no longer available".
# To add a test: append it to POSTESTS (one worker) or MNTESTS (M:N).
# MNFLAGS are the flags of M:N programs (workers need the exception-frame
# head in the fiber record); they are added to every test, so the one-worker
# tests also run in that mode. [regress_variants] runs the one-worker tests
# once more with MNFLAGS empty (the global head is swapped at each switch).
# [stress] runs each M:N test many times, also on one CPU and with 16 workers.
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
MNFLAGS ?= -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_
STRESSN ?= 200

POSTESTS := POS_yield POS_join POS_many POS_recursion POS_sleep POS_exn POS_pingpong POS_prodcons POS_linear POS_trysend POS_waves POS_slab POS_chan_batch
MNTESTS := POS_mn_counter POS_mn_chan POS_mn_join POS_mn_exn POS_mn_sleep POS_mn_many POS_mn_main POS_mn_mutex2 POS_mn_steal POS_mn_yieldfair POS_mn_mutex32 POS_mn_pipeline POS_mn_mainwait POS_mn_batch POS_mn_spawnfree
# the M:N tests need the workers to be possible
ALLTESTS := $(POSTESTS) $(if $(MNFLAGS),$(MNTESTS))

NEGCONSUME := $(wildcard NEG_consume_*.dats)
NEGUAF := $(wildcard NEG_uaf_*.dats)

######

all:: $(ALLTESTS)
$(POSTESTS) $(MNTESTS): %: %.dats; \
  $(PATSCC) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 $(MNFLAGS) $(CFLAGS_EXTRA) -o $@ $<
POS_mn_%: mn_common.hats
cleanall:: ; $(RMF) $(POSTESTS) $(MNTESTS)

######

regress:: $(ALLTESTS) ; \
for t in $(ALLTESTS); do \
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
$(MAKE) cleanall regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_NOGUARD && \
$(MAKE) cleanall regress CFLAGS_EXTRA=-DATSCNTRB_AFIBER_STACK_SLAB=1 && \
$(MAKE) cleanall regress MNFLAGS= && \
$(MAKE) cleanall regress MNFLAGS="-pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ -DATSCNTRB_AFIBER_UCONTEXT" && \
$(MAKE) cleanall

######
#
# HX: leak check with ASan. afiber.cats has the
# __sanitizer_start/finish_switch_fiber hooks; without them one would need
# ASAN_OPTIONS=detect_stack_use_after_return=0
#
leakcheck:: ; \
for t in $(ALLTESTS); do \
  $(PATSCC) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -g -fsanitize=address $(MNFLAGS) $(CFLAGS_EXTRA) \
    -o $${t}_asan $$t.dats && ./$${t}_asan || exit 1; \
done
cleanall:: ; $(RMF) $(addsuffix _asan,$(POSTESTS) $(MNTESTS))

######
#
# HX: run every M:N test STRESSN times; then pinned to one CPU
# (the workers compete for it); then with 16 workers instead of 4.
#
stress:: $(MNTESTS) ; \
for t in $(MNTESTS); do \
  i=0; while [ $$i -lt $(STRESSN) ]; do \
    ./$$t > /dev/null || { echo "$$t failed (run $$i)"; exit 1; }; i=$$((i+1)); \
  done; \
  i=0; while [ $$i -lt $(STRESSN) ]; do \
    taskset -c 0 ./$$t > /dev/null || { echo "$$t failed on one CPU (run $$i)"; exit 1; }; i=$$((i+1)); \
  done; \
  echo "$$t: stress passed"; \
done
stress16:: ; \
for t in $(MNTESTS); do \
  sed 's/afiber_workers_start (4)/afiber_workers_start (16)/' $$t.dats > $${t}_w16.dats; \
  $(PATSCC) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 $(MNFLAGS) -o $${t}_w16 $${t}_w16.dats || exit 1; \
  i=0; while [ $$i -lt $(STRESSN) ]; do \
    ./$${t}_w16 > /dev/null || { echo "$$t (16 workers) failed (run $$i)"; exit 1; }; i=$$((i+1)); \
  done; \
  echo "$$t: 16 workers stress passed"; \
done
cleanall:: ; $(RMF) $(addsuffix _w16,$(MNTESTS)) $(addsuffix _w16.dats,$(MNTESTS))

######

testall:: all regress cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c *_w16*
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *.out

cleanall:: clean

###### end of [Makefile] ######
