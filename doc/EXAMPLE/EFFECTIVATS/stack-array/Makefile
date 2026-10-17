#
# A simple Makefile
#

######

include \
$(PATSHOME)/share/atsmake-pre.mk

######

MYTARGET=MYTARGET
MYCCRULE=MYCCRULE

######

include \
$(PATSHOME)/share/atsmake-post.mk

######

all:: \
postfix_eval
postfix_eval: \
  postfix_eval.dats; $(PATSCC2) -DATS_MEMALLOC_LIBC -o $@ $<
regress:: postfix_eval ; ./$<
cleanall:: ; $(RMF) postfix_eval

######

PATSHOMEQ="$(PATSHOME)"
PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc

######

INPATH :=
INPATH += -I$(PATSHOME)/src
INPATH += -IATS $(PATSHOME)

LDPATH :=
LDPATH += -L$(PATSHOME)/ccomp/atslib/lib

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

upload_main: \
  main.html ; \
  scp main.html \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/stack-array/

######
#
# clean: cleanats
#
cleanats:: ; $(RMF) main.exe
cleanats:: ; $(RMF) *_?ats.c
cleanats:: ; $(RMF) main_atxt.txt
cleanats:: ; $(RMF) main_atxt.dats
#
######
#
# cleanall:: ; $(RMF) main.html
#
###### end of [Makefile] ######
