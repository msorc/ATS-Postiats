#
# A simple Makefile
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt

######

PATSCCOMP2=\
"emcc -Wno-warn-absolute-paths -I${PATSHOME} -I${PATSHOME}/ccomp/runtime"

######

.PHONY: all

######
#
#
all:: \
test01_dats.js
test01_dats.js: \
  test01.dats ; \
  $(PATSCC) -atsccomp $(PATSCCOMP2) \
    --js-library ./../canvas-2d/CATS_JS/HTML5canvas2d.js -o $@ $<
#
cleanall:: ; $(RMF) test01_dats.js
#
######
#

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

######

###### end of [Makefile]
