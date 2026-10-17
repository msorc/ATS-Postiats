#
#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#
#

######

CCOPT=gcc -std=c99

######

ifeq ("$(PATSHOME)","")
  PATSHOMEQ="$(ATSHOME)"
else
  PATSHOMEQ="$(PATSHOME)"
endif

######

PATSOPT=$(PATSHOMEQ)/bin/patsopt
PATSLIB=$(PATSHOMEQ)/ccomp/atslib/lib

######

all::

######

LNS=ln -s
RMF=rm -f

######
#
all:: coinflip
coinflip: coinflip.exe
coinflip.exe: coinflip_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
coinflip_dats.c: coinflip.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output coinflip_dats.c --dynamic coinflip.dats
clean:: ; $(RMF) coinflip_dats.o
clean:: ; $(RMF) coinflip_dats.c
cleanall:: ; $(RMF) coinflip coinflip.exe

all:: ferryman
ferryman: ferryman.exe
ferryman.exe: ferryman_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
ferryman_dats.c: ferryman.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output ferryman_dats.c --dynamic ferryman.dats
clean:: ; $(RMF) ferryman_dats.o
clean:: ; $(RMF) ferryman_dats.c
cleanall:: ; $(RMF) ferryman ferryman.exe

all:: fibver_loop
fibver_loop: fibver_loop.exe
fibver_loop.exe: fibver_loop_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
fibver_loop_dats.c: fibver_loop.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output fibver_loop_dats.c --dynamic fibver_loop.dats
clean:: ; $(RMF) fibver_loop_dats.o
clean:: ; $(RMF) fibver_loop_dats.c
cleanall:: ; $(RMF) fibver_loop fibver_loop.exe

all:: fibver_trec
fibver_trec: fibver_trec.exe
fibver_trec.exe: fibver_trec_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
fibver_trec_dats.c: fibver_trec.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output fibver_trec_dats.c --dynamic fibver_trec.dats
clean:: ; $(RMF) fibver_trec_dats.o
clean:: ; $(RMF) fibver_trec_dats.c
cleanall:: ; $(RMF) fibver_trec fibver_trec.exe

all:: matrixops
matrixops: matrixops.exe
matrixops.exe: matrixops_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
matrixops_dats.c: matrixops.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output matrixops_dats.c --dynamic matrixops.dats
clean:: ; $(RMF) matrixops_dats.o
clean:: ; $(RMF) matrixops_dats.c
cleanall:: ; $(RMF) matrixops matrixops.exe

#
#
all:: fourslot
fourslot: fourslot.exe
fourslot.exe: fourslot_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
fourslot_dats.c: fourslot.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output fourslot_dats.c --dynamic fourslot.dats
clean:: ; $(RMF) fourslot_dats.o
clean:: ; $(RMF) fourslot_dats.c
cleanall:: ; $(RMF) fourslot fourslot.exe

all:: foreach_getline
foreach_getline: foreach_getline.exe
foreach_getline.exe: foreach_getline_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
foreach_getline_dats.c: foreach_getline.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output foreach_getline_dats.c --dynamic foreach_getline.dats
clean:: ; $(RMF) foreach_getline_dats.o
clean:: ; $(RMF) foreach_getline_dats.c
cleanall:: ; $(RMF) foreach_getline foreach_getline.exe

all:: intsqrt_cps
intsqrt_cps: intsqrt_cps.exe
intsqrt_cps.exe: intsqrt_cps_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
intsqrt_cps_dats.c: intsqrt_cps.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output intsqrt_cps_dats.c --dynamic intsqrt_cps.dats
clean:: ; $(RMF) intsqrt_cps_dats.o
clean:: ; $(RMF) intsqrt_cps_dats.c
cleanall:: ; $(RMF) intsqrt_cps intsqrt_cps.exe

all:: intsqrt_prf
intsqrt_prf: intsqrt_prf.exe
intsqrt_prf.exe: intsqrt_prf_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
intsqrt_prf_dats.c: intsqrt_prf.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output intsqrt_prf_dats.c --dynamic intsqrt_prf.dats
clean:: ; $(RMF) intsqrt_prf_dats.o
clean:: ; $(RMF) intsqrt_prf_dats.c
cleanall:: ; $(RMF) intsqrt_prf intsqrt_prf.exe

all:: randerlin
randerlin: randerlin.exe
randerlin.exe: randerlin_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
randerlin_dats.c: randerlin.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output randerlin_dats.c --dynamic randerlin.dats
clean:: ; $(RMF) randerlin_dats.o
clean:: ; $(RMF) randerlin_dats.c
cleanall:: ; $(RMF) randerlin randerlin.exe

all:: readdirall
readdirall: readdirall.exe
readdirall.exe: readdirall_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
readdirall_dats.c: readdirall.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output readdirall_dats.c --dynamic readdirall.dats
clean:: ; $(RMF) readdirall_dats.o
clean:: ; $(RMF) readdirall_dats.c
cleanall:: ; $(RMF) readdirall readdirall.exe

all:: sllist_mapfree
sllist_mapfree: sllist_mapfree.exe
sllist_mapfree.exe: sllist_mapfree_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
sllist_mapfree_dats.c: sllist_mapfree.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output sllist_mapfree_dats.c --dynamic sllist_mapfree.dats
clean:: ; $(RMF) sllist_mapfree_dats.o
clean:: ; $(RMF) sllist_mapfree_dats.c
cleanall:: ; $(RMF) sllist_mapfree sllist_mapfree.exe

all:: treap_man
treap_man: treap_man.exe
treap_man.exe: treap_man_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
treap_man_dats.c: treap_man.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output treap_man_dats.c --dynamic treap_man.dats
clean:: ; $(RMF) treap_man_dats.o
clean:: ; $(RMF) treap_man_dats.c
cleanall:: ; $(RMF) treap_man treap_man.exe

all:: wclines
wclines: wclines.exe
wclines.exe: wclines_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
wclines_dats.c: wclines.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output wclines_dats.c --dynamic wclines.dats
clean:: ; $(RMF) wclines_dats.o
clean:: ; $(RMF) wclines_dats.c
cleanall:: ; $(RMF) wclines wclines.exe

#
######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats
clean:: ; $(RMF) Makefile.exe

cleanall:: clean

###### end of [Makefile] ######
