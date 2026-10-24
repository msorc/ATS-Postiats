# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
######
#
# Makefile of libatsdoc (the run-time library of the programs that atsdoc generates)
#
# make            builds BUILD/libatsdoc.a (the atext library and its symbols)
# make install    copies it to $(PATSHOME)/ccomp/atslib/lib
# make gen        regenerates the arena encoding of the atext tree (libatsdoc_atext.spec)
# make check      typechecks the files
#
# The generated programs (atsdoc --outcode X_atxt.dats ...) are compiled by
#
#   patscc -DATS_MEMALLOC_LIBC -o X_atxt X_atxt.dats -latsdoc
#
# with -L$(PATSHOME)/ccomp/atslib/lib (after `make install`) or
# -L$(PATSHOME)/libatsdoc/BUILD. libatsdoc.a needs nothing else (it can be linked
# with libatsopt.a and libatsynmark.a as well: -latsynmark -latsdoc -latsopt). The
# programs call [dynload "libatsdoc/dynloadall.dats"] (or [libatsdoc_dynloadall()]).
#
# The name of the function that [dynload "libatsdoc/dynloadall.dats"] calls
# contains the path of this directory: the programs have to be compiled with the
# PATSHOME that libatsdoc.a was built with.
#
# ATS1 is not needed.
#
######

HERE:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(HERE)Makefile_vars

######

all:: libatsdoc

SATS=$(HERE)SATS
DATS=$(HERE)DATS
BUILD=$(HERE)BUILD

######

GENHATS=$(SATS)/libatsdoc_atext_gen.hats $(DATS)/libatsdoc_atext_gen_dats.hats

$(SATS)/libatsdoc_atext_gen.hats: $(HERE)libatsdoc_atext.spec $(PATSHOME)/utils/arenagen/arenagen.py
	python3 $(PATSHOME)/utils/arenagen/arenagen.py --global sats $< > $@
$(DATS)/libatsdoc_atext_gen_dats.hats: $(HERE)libatsdoc_atext.spec $(PATSHOME)/utils/arenagen/arenagen.py
	python3 $(PATSHOME)/utils/arenagen/arenagen.py --global --compact dats $< > $@

gen:: ; $(RMF) $(GENHATS)
gen:: $(GENHATS)

######

libatsdoc:: $(LIBATSDOC)

OBJECTS=$(BUILD)/libatsdoc_atext_dats.o $(BUILD)/libatsdoc_symbol_dats.o $(BUILD)/dynloadall_dats.o

$(LIBATSDOC): $(OBJECTS)
	$(RMF) $@; $(AR) rcs $@ $^

######

$(BUILD)/libatsdoc_atext_dats.c: $(DATS)/libatsdoc_atext.dats $(SATS)/libatsdoc_atext.sats $(GENHATS) \
  $(HERE)CATS/libatsdoc_sbuf.cats $(HERE)CATS/libatsdoc_symbol.cats $(SATS)/libatsdoc_symbol.sats
	$(PATSOPT) --output $@ --dynamic $<

$(BUILD)/libatsdoc_symbol_dats.c: $(DATS)/libatsdoc_symbol.dats $(SATS)/libatsdoc_symbol.sats $(HERE)CATS/libatsdoc_symbol.cats
	$(PATSOPT) --output $@ --dynamic $<

$(BUILD)/dynloadall_dats.c: $(HERE)dynloadall.dats
	$(PATSOPT) --output $@ --dynamic $<

$(BUILD)/%_dats.o: $(BUILD)/%_dats.c
	$(PATSCC) -c -o $@ $<

.PRECIOUS: $(BUILD)/%_dats.c

######

install:: libatsdoc ; \
mkdir -p $(PATSHOME)/ccomp/atslib/lib && cp -f $(LIBATSDOC) $(PATSHOME)/ccomp/atslib/lib/

######

check:: $(GENHATS)
	@for f in $(SATS)/libatsdoc_symbol.sats $(SATS)/libatsdoc_atext.sats; do echo "typecheck $$f"; $(PATSOPT) --typecheck -s $$f >/dev/null || exit 1; done
	@for f in $(DATS)/libatsdoc_symbol.dats $(DATS)/libatsdoc_atext.dats $(HERE)dynloadall.dats; do \
	  echo "typecheck $$f"; $(PATSOPT) --typecheck -d $$f >/dev/null || exit 1; done

######

clean:: ; $(RMF) $(BUILD)/*.o $(BUILD)/*.c $(HERE)*~

cleanall:: clean
cleanall:: ; $(RMF) $(LIBATSDOC) $(PATSHOME)/ccomp/atslib/lib/libatsdoc.a

distclean:: cleanall

###### end of [Makefile of libatsdoc] ######
