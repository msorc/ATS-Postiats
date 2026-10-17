######
#
# A simple Makefile
#
######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

ATSCNTRB=$(PATSHOME)/contrib/atscntrb

######

ATSRELOC1=$(PATSHOME)/bin/atsreloc_curl

######

all::

######
#
#
#
######
#
#
#
######
#
#
#
#
######
#
#
#
######
#
#
#
######
#
#
#
######
#
#
#
######
#
#
#
######
#
#
#
######
#
#
#
######
#
all:: \
Remove_lines_from_a_file
Remove_lines_from_a_file: \
Remove_lines_from_a_file.dats ; \
$(PATSCC) -DATS_MEMALLOC_LIBC -o $@ $< -latslib
#
regress:: \
Remove_lines_from_a_file; ./$< 1 7
cleanall:: ; $(RMF) Remove_lines_from_a_file
#
######
#
all:: \
Stream_Merge
Stream_Merge: \
Stream_Merge.dats ; \
$(PATSCC) -DATS_MEMALLOC_LIBC -o $@ $< -latslib
#
regress:: \
Stream_Merge; ./$< DATA/Stream_Merge_0.txt DATA/Stream_Merge_1.txt
#
cleanall:: ; $(RMF) Stream_Merge
#
######

myatsreloc:: myatsreloc.dats; $(PATSOPT) --atsreloc -d $< | $(ATSRELOC1)

######

RMF=rm -f
RMRF=rm -rf

######

testall:: \
myatsreloc

######

testall:: all
testall:: regress
testall:: cleanall

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

cleanall:: clean
cleanall:: ; $(RMRF) ./PATSRELOCROOT/*

###### end of [Makefile] ######
