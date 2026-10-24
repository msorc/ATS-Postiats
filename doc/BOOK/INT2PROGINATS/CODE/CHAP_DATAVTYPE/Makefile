#
# A simple Makefile
#

######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######

CFLAGS=-O2
ATSCFLAGS=

######

all:: rbtree
all:: bstree_vt
all:: list_vt
all:: mergeSort
all:: insertionSort
all:: quickSort

######

rbtree: rbtree.dats; \
  $(PATSCC) $(CFLAGS) -o $@ $<
regress:: rbtree; ./rbtree
cleanall:: ; $(RMF) rbtree

######

bstree_vt: bstree_vt.dats; \
  $(PATSCC) $(CFLAGS) -o $@ $<
regress:: bstree_vt; ./bstree_vt
cleanall:: ; $(RMF) bstree_vt

######

list_vt: list_vt.dats; \
  $(PATSCC) $(CFLAGS) -o $@ $<
regress:: list_vt; ./list_vt
cleanall:: ; $(RMF) list_vt

######

mergeSort: mergeSort.dats; \
  $(PATSCC) $(CFLAGS) -o $@ $<
regress:: mergeSort; ./mergeSort
cleanall:: ; $(RMF) mergeSort

######

insertionSort: insertionSort.dats; \
  $(PATSCC) $(CFLAGS) -o $@ $<
regress:: insertionSort; ./insertionSort
cleanall:: ; $(RMF) insertionSort

######

quickSort: quickSort.dats insertionSort.dats; \
  $(PATSCC) $(CFLAGS) -o $@ quickSort.dats
regress:: quickSort; ./quickSort
cleanall:: ; $(RMF) quickSort

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
