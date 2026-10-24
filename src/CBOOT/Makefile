# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# Makefile of the bootstrap bundle of patsopt: links patsopt from the C code in this directory with a C compiler and (for
# the default integer kind) gmp. Nothing else is needed: no ATS compiler, no python. See README.
#
#   make                       builds ./patsopt (with gmp)
#   make libatsopt.a           builds the library version of the compiler (the API of utils/libatsopt)
#   make KIND=intknd           builds ./patsopt without gmp (the integers of the constraint solver are machine integers)
#   make -j8 CC=gcc CFLAGS=-O1
#
CC=gcc
CFLAGS=-O2
LDFLAGS=
KIND=gmpknd

include modules.mk

ifeq ($(KIND),gmpknd)
KIND_C=$(addprefix gmpknd/,$(GMPKND_C))
LIBS=-lgmp
else
KIND_C=$(addprefix intknd/,$(INTKND_C))
LIBS=
endif

# the executable and the library share the modules; the driver (main, ATS1-style run-time) is only in patsopt,
# pats_main compiled without main and libatsopt_ext are only in libatsopt.a
LIBONLY=pats_main_none_dats.c libatsopt_ext_dats.c libatsopt_ext.c
EXEONLY=pats_main_dats.c pats_runtime_ats1.c
OBJDIR=obj_$(KIND)
OBJS=$(addprefix $(OBJDIR)/,$(patsubst %.c,%.o,$(filter-out $(LIBONLY),$(COMMON_C) $(KIND_C))))
LIBOBJS=$(addprefix $(OBJDIR)/,$(patsubst %.c,%.o,$(filter-out $(EXEONLY),$(COMMON_C) $(KIND_C))))

ALLCFLAGS=-std=c99 -D_GNU_SOURCE \
  -Iinc -Iinc/ccomp/runtime -I. $(CFLAGS)

patsopt: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

libatsopt.a: $(LIBOBJS)
	$(RM) $@; ar rcs $@ $(LIBOBJS)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(ALLCFLAGS) -c -o $@ $<
# the driver uses the run-time of pats_runtime_ats1.c, not the ATS2 one
$(OBJDIR)/pats_main_dats.o: ALLCFLAGS+=-D_ATS_CCOMP_RUNTIME_NONE_

clean:
	$(RM) -r obj_gmpknd obj_intknd patsopt libatsopt.a

.PHONY: clean
