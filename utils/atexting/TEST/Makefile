######
#
# A simple Makefile
#
######

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

######
#
INPATH := -I$(PATSHOME)/src
#
LDPATH := -L$(PATSHOME)/ccomp/atslib/lib
#
# libatsynmark.a: make -f Makefile_devl bin_pats2xhtml (or make -C utils/libatsynmark install)
#
LIBRARY = -latsynmark -latsopt -latslib -lgmp
#
######
#
all:: \
mytexting
mytexting: \
mytexting.dats ; \
$(PATSCC) -verbose \
  -O2 -o $@ mytexting.dats \
  -DATS_MEMALLOC_LIBC \
  $(INPATH) $(LDPATH) $(LIBRARY)
#
######
#
regress:: \
mytexting
regress:: \
data.atxt ; \
./mytexting -o data_atxt.out -i $<
#
######

testall:: all
testall:: regress
testall:: cleanall

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_dats.c

######

cleanall:: clean
cleanall:: ; $(RMF) mytexting
cleanall:: ; $(RMF) data_atxt.out

###### end of [Makefile] ######
