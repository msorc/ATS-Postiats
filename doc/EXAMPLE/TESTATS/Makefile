#
# A simple Makefile
#

######

include $(PATSHOME)/share/atsmake-pre.mk

######

MYTARGET=MYTARGET
MYCCRULE=MYCCRULE

######

include $(PATSHOME)/share/atsmake-post.mk

######

all:: \
arrinit
arrinit: \
arrinit.dats ; \
  $(PATSCC2) -cleanaft -DATS_MEMALLOC_LIBC -o $@ $<
regress:: arrinit ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) arrinit

######


######


######

all:: \
conjdisj
conjdisj: conjdisj.dats ; \
  $(PATSCC2) -cleanaft -DATS_MEMALLOC_LIBC -o $@ $<
regress:: conjdisj ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) conjdisj

######


######

all:: \
extvar
extvar: extvar.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: extvar extvar.test-cmp
	./$< 2>&1 | diff -q extvar.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) extvar

######

all:: \
extfcall
extfcall: extfcall.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: extfcall ; USER=user ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) extfcall

######
#
all:: \
fieldarr
fieldarr: fieldarr.dats ; \
  $(PATSCC2) -DATS_MEMALLOC_LIBC -cleanaft -o $@ $<
regress:: fieldarr ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) fieldarr
#
######

cleanall:: ; $(RMF) findexn_dats.c

######


######


######

all:: \
getenv
getenv: \
getenv.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: getenv getenv.test-cmp
	msg=hi ./$< 2>&1 | diff -q getenv.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) getenv

######

all:: \
ifcase
ifcase: \
ifcase.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: ifcase ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) ifcase

######

all:: \
ifhead
ifhead: \
ifhead.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: ifhead ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) ifhead
all:: \
casehead
casehead: \
casehead.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: casehead ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) casehead

######

all:: \
intbase
intbase: \
intbase.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: intbase intbase.test-cmp
	./$< 2>&1 | diff -q intbase.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) intbase

######


######
#
cleanall:: ; $(RMF) lazytest_dats.c
#
#
######
#
all:: \
llazytest
regress:: llazytest llazytest.test-cmp
	./$< 2>&1 | diff -q llazytest.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) llazytest
cleanall:: ; $(RMF) llazytest_dats.c
#
llazytest: \
llazytest_dats.c ; \
$(PATSCC2) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o $@ $<
llazytest_dats.c: llazytest.dats ; $(PATSCC2) -ccats $<
#
######


######

all:: \
loctmplt
loctmplt: \
loctmplt.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: loctmplt ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) loctmplt

######

all:: \
loctmplt2
regress:: loctmplt2 ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) loctmplt2
#
loctmplt2: \
loctmplt2.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######

all:: \
locimplmnt
regress:: locimplmnt ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) locimplmnt
#
locimplmnt: \
locimplmnt.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######

all:: \
mutailrec
regress:: mutailrec ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) mutailrec
#
mutailrec: \
mutailrec.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######
#
all:: \
partmplt
regress:: partmplt partmplt.test-cmp
	./$< 2>&1 | diff -q partmplt.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) partmplt
#
partmplt: \
partmplt.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######
#
#
#
######
#
all:: \
patlinrec
regress:: patlinrec ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) patlinrec
#
patlinrec: \
patlinrec.dats ; \
$(PATSCC2) -cleanaft -DATS_MEMALLOC_LIBC -o $@ $<
#
######
#
#
#
######

all:: \
pfsearch
regress:: pfsearch ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) pfsearch
#
pfsearch: \
pfsearch.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######

all:: \
reassume
regress:: reassume ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) reassume
#
reassume: \
reassume.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######
#
all:: \
stkalloc
regress:: stkalloc stkalloc.test-cmp
	./$< 2>&1 | diff -q stkalloc.test-cmp - >/dev/null || \
	(echo "$< failed" && exit 1)
cleanall:: ; $(RMF) stkalloc
#
stkalloc: \
stkalloc.dats ; $(PATSCC2) -cleanaft -o $@ $<
#
######
#
all:: \
sumodd
regress:: sumodd ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) sumodd
#
sumodd: \
sumodd.dats; $(PATSCC2) -cleanaft -o $@ $<
#
######
#
#
#
######
#
all:: \
tempenver
tempenver: \
tempenver.dats ; \
$(PATSCC2) -cleanaft -o $@ $<
#
regress:: tempenver ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) tempenver
#
# cleanall:: ; $(RMF) tempenver_dats.c
#
######

all:: \
trywith
trywith: trywith.dats ; \
  $(PATSCC2) -D_GNU_SOURCE -cleanaft -DATS_MEMALLOC_LIBC -o $@ $<
#
#HX: run-time exception
regress:: trywith ; ./$< && (echo "$< failed" && exit 1) || echo "ok"
#
cleanall:: ; $(RMF) trywith

######

all:: \
union
union: union.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: union ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) union

######

all:: \
weekday
weekday: weekday.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: weekday ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) weekday

######

all:: \
withtype
withtype: withtype.dats ; $(PATSCC2) -cleanaft -o $@ $<
regress:: withtype ; ./$< || (echo "$< failed" && exit 1)
cleanall:: ; $(RMF) withtype

######

CPF=cp -f

######
#
#
######
#
#
#
cleanall:: ; $(RMF) codegen2_out.dats
#
######
#
all:: \
s2rt_float
s2rt_float: \
s2rt_float.dats; $(PATSCC) -tcats -d $< || (echo "$< failed" && exit 1)
regress:: s2rt_float
#
######
#
all:: \
variadic
variadic: variadic.dats; $(PATSCC2) -o $@ $<
#
regress:: variadic ; ./$< || (echo "$< failed" && exit 1)
#
cleanall:: ; $(RMF) variadic
cleanall:: ; $(RMF) variadic_dats.c
#
######

all:: \
wherecls
wherecls: wherecls_dats.c ; \
$(PATSCC2) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o $@ $<
wherecls_dats.c: wherecls.dats ; $(PATSCC2) -ccats $<
#
regress:: wherecls ; ./$< || (echo "$< failed" && exit 1)
#
cleanall:: ; $(RMF) wherecls
cleanall:: ; $(RMF) wherecls_dats.c

######

all:: \
undefined
undefined: undefined_dats.c ; \
$(PATSCC2) -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o $@ $<
undefined_dats.c: undefined.dats ; $(PATSCC2) -ccats $<
#
regress:: undefined ; ./$< && (echo "$< failed" && exit 1) || echo "ok"
#
cleanall:: ; $(RMF) undefined
cleanall:: ; $(RMF) undefined_dats.c

######

testall:: all
testall:: regress
testall:: cleanall

######

cleanall:: ; $(RMF) *_?ats.c

######

###### end of [Makefile] ######
