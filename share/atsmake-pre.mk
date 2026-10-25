#
# For building
# Makefiles for projects in ATS 
#

######
#
# Author: Hongwei Xi (githwxi)
# Author: Ian Denhardt (zenhack.net)
#
######
#
CC=gcc
#
######
#
ifdef \
PATSHOME
  PATSHOMEQ="$(PATSHOME)"
else
#
  PATSHOMEQ="/usr/local/lib/ats2-postiats"
#
endif # end of [ifdef]
#
######
#
PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt
PATSLIB=$(PATSHOMEQ)/ccomp/atslib/lib
#
# PATSLIB32=$(PATSHOMEQ)/ccomp/atslib/lib32
# PATSLIB64=$(PATSHOMEQ)/ccomp/atslib/lib64
#
######
#
ifdef \
PATSCCOMP
else
export \
PATSCCOMP=$(CC) -std=c99 -D_GNU_SOURCE
endif
#
######

PATS2XHTML=$(PATSHOMEQ)/bin/pats2xhtml

######

INCLUDE += -I$(PATSHOMEQ)
INCLUDE += -I$(PATSHOMEQ)/ccomp/runtime

######

CFLAGS += -D_GNU_SOURCE

######
#
LDFLAGS += -L$(PATSLIB)
# LDFLAGS += -L$(PATSLIB32)
# LDFLAGS += -L$(PATSLIB64)
#
LDFLAGS += -latslib
#
######

EXTRAFLAGS =

######

# libc is the default allocator (the flag -DATS_MEMALLOC_LIBC is a no-op)
MALLOCFLAG :=

######

SOURCES_C=
SOURCES_SATS=
SOURCES_DATS=

######

all::
cleanats::
cleanall::

######

###### end of [atsmake-pre.mk] ######
