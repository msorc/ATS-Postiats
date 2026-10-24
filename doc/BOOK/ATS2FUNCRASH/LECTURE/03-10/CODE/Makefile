######
#
# The code of this chapter is for the JS backend (libatscc2js, see the
# chapter on JS); here it is only type-checked.
#
######

PATSOPT=$(PATSHOME)/bin/patsopt

######

all:: ; $(PATSOPT) --typecheck -d Sierpinski.dats

######

regress:: all

######

clean:: ; rm -f *~

######

cleanall:: clean

######

testall:: all
testall:: regress
testall:: cleanall

###### end of [Makefile] ######
