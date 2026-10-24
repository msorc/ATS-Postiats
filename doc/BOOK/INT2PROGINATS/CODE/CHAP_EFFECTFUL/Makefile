#
# A simple Makefile
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt

######

INCLUDES=-I$(PATSHOME) -I$(PATSHOME)/ccomp/runtime

######

CCFLAGS=-O2
ATSCCFLAGS=

######

all:: hello
all:: echoline
all:: brauntest
all:: insort
all:: permord
all:: transpose
all:: counter

######


######


######


######


######


######


######

hello: hello_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: hello ; ./hello
cleanall:: ; $(RMF) hello hello.txt

######

echoline: \
echoline_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $< -latslib
regress:: echoline ; $(CAT) echoline.dats | ./echoline > /dev/null
cleanall:: ; $(RMF) echoline

brauntest: brauntest_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: brauntest ; ./brauntest
cleanall:: ; $(RMF) brauntest

######

insort: insort_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: insort ; ./insort
cleanall:: ; $(RMF) insort

######

permord: permord_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: permord ; ./permord
cleanall:: ; $(RMF) permord

######

transpose: transpose_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: transpose ; ./transpose
cleanall:: ; $(RMF) transpose

######

counter: counter_dats.c ; \
  $(PATSCC) $(ATSCCFLAGS) $(INCLUDES) $(CCFLAGS) -o $@ $<
regress:: counter ; ./counter
cleanall:: ; $(RMF) counter

######

######

%_dats.c: %.dats ; $(PATSOPT) -o $@ --dynamic $<

#####

CAT=cat
RMF=rm -f
RMRF=rm -rf

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

######

###### end of [Makefile] ######
