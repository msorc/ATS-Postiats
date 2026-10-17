#
# A simple Makefile
#

######

ifeq ("$(PATSHOME)","")
  PATSHOMEQ="$(ATSHOME)"
else
  PATSHOMEQ="$(PATSHOME)"
endif

######

PATSCC=$(PATSHOMEQ)/bin/patscc
PATSOPT=$(PATSHOMEQ)/bin/patsopt

######

all::

######

all:: Ackermann
Ackermann: Ackermann.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: Ackermann

######

all:: BinaryTreeLemmas
BinaryTreeLemmas: BinaryTreeLemmas.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: BinaryTreeLemmas

######


######


######

all:: CutElimILL
CutElimILL: CutElimILL.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: CutElimILL

######

all:: HilbertCalc
HilbertCalc: HilbertCalc.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: HilbertCalc

######

all:: infprime
infprime: infprime.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: infprime

######

all:: sqrt2_irrat
sqrt2_irrat: sqrt2_irrat.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: sqrt2_irrat

######


######

all:: naive-set
naive-set: naive-set.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: naive-set

######

all:: PHP
PHP: PHP.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: PHP

######

all:: SMI
SMI: SMI.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: SMI

######

all:: \
STLC-SN-foas
STLC-SN-foas: STLC-SN-foas.dats ; $(PATSCC) -tcats $< || (echo "$< failed" && exit 1)
regress:: STLC-SN-foas

######

all:: \
IsoscelesAngleq
IsoscelesAngleq: \
IsoscelesAngleq.dats; $(PATSCC) -verbose -tcats $< || (echo "$< failed" && exit 1)

######


######


######


######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

######

cleanall:: clean

###### end of [Makefile] ######
