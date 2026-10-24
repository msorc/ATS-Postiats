##
##
## A simple Makefile for compiling ATS programs
##
##

######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

CFLAGS :=
CFLAGS += -O2

######
#
all:: gnumber
all:: myprint
all:: list_map
all:: loopcons
all:: intfloat
#
gnumber: gnumber.dats ; \
$(PATSCC) $(CFLAGS) -o $@ $<
regress:: gnumber ; ./gnumber
cleanall:: ; $(RMF) gnumber
#
myprint: myprint.dats ; \
$(PATSCC) $(CFLAGS) -o $@ $<
regress:: myprint ; ./myprint
cleanall:: ; $(RMF) myprint
#
list_map: list_map.dats ; \
$(PATSCC) $(CFLAGS) -o $@ $<
regress:: list_map ; ./list_map
cleanall:: ; $(RMF) list_map
#
loopcons: loopcons.dats ; \
$(PATSCC) $(CFLAGS) -o $@ $<
regress:: loopcons ; ./loopcons
cleanall:: ; $(RMF) loopcons
#
intfloat: intfloat.dats ; \
$(PATSCC) $(CFLAGS) -o $@ $<
regress:: intfloat ; ./intfloat
cleanall:: ; $(RMF) intfloat
#
######

RMF=rm -f

######

testall:: all
testall:: regress
testall:: cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
