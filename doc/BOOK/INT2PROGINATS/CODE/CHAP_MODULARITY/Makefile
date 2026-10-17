######
##
##
## A simple Makefile for compiling ATS programs
##
##
######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt

######

ATSCCFLAGS=-O2

######

all: checkall cleanall

######

checkall:: test_acker ; ./test_acker
checkall:: test_acker2 ; ./test_acker2
checkall:: test_acker3 ; ./test_acker3
checkall:: test_ratmod ; ./test_ratmod

######

regress:: checkall

######

distclean:: cleanall

######


######


######

ACKER_SRC=acker.dats test_acker.dats
ACKER_OBJ := $(ACKER_SRC)
ACKER_OBJ := $(patsubst %.dats, %_dats.o, $(ACKER_OBJ))

test_acker: $(ACKER_OBJ)
	$(PATSCC) $(ATSCCFLAGS) -o $@ $^ || touch $@
cleanall:: ; $(RMF) test_acker

######

ACKER2_SRC=acker2.dats test_acker2.dats
ACKER2_OBJ := $(ACKER2_SRC)
ACKER2_OBJ := $(patsubst %.dats, %_dats.o, $(ACKER2_OBJ))

test_acker2: $(ACKER2_OBJ)
	$(PATSCC) $(ATSCCFLAGS) -o $@ $^ || touch $@
cleanall:: ; $(RMF) test_acker2

######

ACKER3_SRC=acker3.dats test_acker3.dats
ACKER3_OBJ := $(ACKER3_SRC)
ACKER3_OBJ := $(patsubst %.dats, %_dats.o, $(ACKER3_OBJ))

test_acker3: $(ACKER3_OBJ)
	$(PATSCC) $(ATSCCFLAGS) -o $@ $^ || touch $@
cleanall:: ; $(RMF) test_acker3

######


######

RATMOD_SRC=\
  ratmod.sats ratmod.dats test_ratmod.dats
RATMOD_OBJ := $(RATMOD_SRC)
RATMOD_OBJ := $(patsubst %.sats, %_sats.o, $(RATMOD_OBJ))
RATMOD_OBJ := $(patsubst %.dats, %_dats.o, $(RATMOD_OBJ))

test_ratmod: $(RATMOD_OBJ)
	$(PATSCC) $(ATSCCFLAGS) -o $@ $^ || touch $@
cleanall:: ; $(RMF) test_ratmod

######



######

%_sats.o: %.sats
	$(PATSCC) $(ATSCCFLAGS) -c $< || touch $@

%_dats.o: %.dats
	$(PATSCC) -DATS_MEMALLOC_LIBC $(ATSCCFLAGS) -c $< || touch $@

######

RMF=rm -f

######

clean:
	$(RMF) *~
	$(RMF) *_?ats.o
	$(RMF) *_?ats.c

cleanall:: clean

###### end of [Makefile] ######
