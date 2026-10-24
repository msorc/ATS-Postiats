# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# Testing how patsopt reports the errors of a program:
#
# - NEG_fnx_nontail.dats: a call to a partner of a [fnx]-group that is not a
#   tail-call cannot be compiled (the group is one C function): patsopt says so
#   (it used to produce C code with an implicit declaration);
# - NEG_unbound.dats: an error of the typechecker;
# - for both: the exit status is 1 and patsopt does not print
#   "uncaught exception" (the exception FatalErrorExn does not escape);
# - NEG_if_linear.dats: an [if] with linear branches and no expected type
#   (the same in 0.4.2); POS_if_linear.dats: the two ways to write it;
# - POS_fnx_tail.dats: a [fnx]-group of tail-calls compiles and runs.
#
######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt
RMF=rm -f

######

all:: POS_fnx_tail
POS_fnx_tail: POS_fnx_tail.dats; $(PATSCC) -DATS_MEMALLOC_LIBC -O2 -o $@ $<
cleanall:: ; $(RMF) POS_fnx_tail
all:: POS_if_linear
POS_if_linear: POS_if_linear.dats; $(PATSCC) -DATS_MEMALLOC_LIBC -O2 -o $@ $<
cleanall:: ; $(RMF) POS_if_linear

######

regress:: POS_fnx_tail ; ./$< | tail -1 | grep -q "9 18 27 36 45 54 63 72 81" || (echo "$< failed" && exit 1)
regress:: POS_if_linear ; ./$< || (echo "$< failed" && exit 1)
regress:: ; \
for t in NEG_fnx_nontail:"non-tail call to a function of the same \[fnx\]-group" \
         NEG_unbound:"is unrecognized" \
         NEG_if_linear:"cannot be assigned the type"; do \
  f=$${t%%:*}.dats; msg=$${t#*:}; \
  $(PATSOPT) -d $$f > $$f.c 2> $$f.out; st=$$?; \
  if [ $$st -ne 1 ]; then echo "$$f: exit status $$st (1 expected)"; exit 1; fi; \
  grep -q "$$msg" $$f.out || { echo "$$f: unexpected message"; cat $$f.out; exit 1; }; \
  if grep -q "uncaught exception" $$f.out; then \
    echo "$$f: the exception escapes"; cat $$f.out; exit 1; \
  fi; \
done; echo "NEG_*: all rejected cleanly"

######

testall:: all
testall:: regress
testall:: cleanall

######

clean:: ; $(RMF) *~ *_?ats.c *.dats.c *.dats.out

cleanall:: clean

###### end of [Makefile] ######
