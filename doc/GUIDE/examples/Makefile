# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The "after" code of doc/GUIDE/migrating-from-0.4.2.md.
#   make regress    build and run each example
#   make leakcheck  the same with AddressSanitizer (LeakSanitizer)
#
PATSHOME ?= $(abspath ../../..)
export PATSHOME
PATSCC=$(PATSHOME)/bin/patscc
RMF=rm -f
PROGS=list_vt option_vt datavtype cloptr stream_vt arrayptr containers flat

all:: $(PROGS)
$(PROGS): %: %.dats; $(PATSCC) -O2 -o $@ $<

regress:: all
	for p in $(PROGS); do ./$$p > /dev/null || { echo "$$p failed"; exit 1; }; done; echo "GUIDE examples: ok"

leakcheck::
	for p in $(PROGS); do \
	  $(PATSCC) -g -fsanitize=address -o $${p}_asan $$p.dats && ./$${p}_asan > /dev/null \
	  || { echo "$$p: leak or error"; exit 1; }; done; echo "GUIDE examples: no leaks"

testall:: regress leakcheck cleanall

clean:: ; $(RMF) *~ *_dats.c *_dats.o
cleanall:: clean ; $(RMF) $(PROGS) $(addsuffix _asan,$(PROGS))
