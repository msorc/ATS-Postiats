#
# A simple Makefile
# for building libatsopt
#

######

CC=emcc
CCOMP=$(CC)

######
#
ATSCC=$(ATSHOME)/bin/atscc
ATSOPT=$(ATSHOME)/bin/atsopt
#
PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt
#
######

ATSRUNTIME=$(ATSHOME)/ccomp/runtime

######

CFLAGS += -Wno-implicit-function-declaration

######

all:: libatsopt

######
#
# For building libatsopt without libgmp dependency
#
libatsopt:: ; \
$(MAKE) -C $(PATSHOME)/src cleanall
libatsopt:: ; \
$(MAKE) -C $(PATSHOME)/src C3NSTRINTKND=intknd libatsopt
#
libatsopt:: ; $(RMF) libatsopt.o
libatsopt:: ; $(MAKE) -C $(PATSHOME)/src CBOOTmin
#
libatsopt:: ; $(MAKE) -C $(PATSHOME)/src/CBOOT/JS cleanall
libatsopt:: ; $(MAKE) -C $(PATSHOME)/src/CBOOT/JS libatsopt
#
######
#
######
#
# The C API of libatsopt (libatsopt_ext) is part of src/libatsopt.a: there
# is nothing to build here (see ../Makefile_build).
#
######

RMF=rm -f
MAKE=make

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o

######

cleanall:: clean
cleanall:: ; $(RMF) libatsopt.o
cleanall:: ; $(RMF) libatsopt_ext.o
cleanall:: ; $(RMF) libatsopt_ext.js

###### end of [Makefile] ######
