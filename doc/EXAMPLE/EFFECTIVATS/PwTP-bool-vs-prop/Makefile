#
# A simple Makefile
#
######
#
ATSDOC=$(PATSHOME)/bin/atsdoc
#
PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt
PATSOLVE=$(PATSHOME)/bin/patsolve_z3
#
PATSLIB=$(PATSHOME)/ccomp/atslib/lib
#
ATSCC2JS=$(PATSHOME)/bin/atscc2js
LIBATCC2JS=$(PATSHOMERELOC)/contrib/libatscc/libatscc2js
#
######

all:: main.html

######

INPATH :=
INPATH += -I$(PATSHOME)/src
INPATH += -IATS $(PATSHOME)

LDPATH :=
LDPATH += -L$(PATSLIB)

LIBRARY :=
LIBRARY := -latsynmark -latsdoc -latslib -latsopt -lgmp

######
#
main.exe: \
main_atxt.dats ; \
$(PATSCC) \
  -DATS_MEMALLOC_LIBC \
  $(INPATH) -o $@ $< $(LDPATH) $(LIBRARY)
#
main_atxt.dats: main.atxt; \
$(ATSDOC) --outcode $@ -i main.atxt > main_atxt.txt
#
######

main.html: main.exe ; ./main.exe > $@

######
#
upload_main: \
  main.html ; scp $^ \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/PwTP-bool-vs-prop/.
#
######
#
bool-vs-prop: \
bool-vs-prop.dats ; \
$(PATSOPT) -tc --constraint-export -d $< | $(PATSOLVE) -i
#
######

CAT=cat
RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) main.exe
clean:: ; $(RMF) main_atxt.txt
clean:: ; $(RMF) main_atxt.dats

######
#
######
#
# The document of this directory is only built by the regression suite.
#
######

regress::

cleanall:: clean
#
cleanall:: ; $(RMF) main.html
cleanall:: ; $(RMF) *_?ats.html
#
###### end of [Makefile] ######
