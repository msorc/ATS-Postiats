#
# ATS2TUTORIAL
#

######
#
# Author: Hongwei Xi
# Authoremail: gmhwxiATgmailDOTcom
#
######
#
# Author: Kiawamu Okabe
# Authoremail: kiwamuATgmailDOTcom
# For initiating regression test
#
######

include $(PATSHOME)/share/atsmake-pre.mk

######

all:: \
ATS2TUTORIAL-CODE.html

######
#
ATS2TUTORIAL-CODE.html: ATS2TUTORIAL-CODE.php ; php -f $< > $@
#
######

######
#
# Basic Topics
#
######
#
all:: \
chap_dynload
chap_dynload: \
CHAP_DYNLOAD/foo.dats \
CHAP_DYNLOAD/foo2.dats ; \
$(PATSCC2) -o $@ $^
#
regress:: chap_dynload; ./$<
cleanall:: ; $(RMF) chap_dynload
#
######
#
all:: \
chap_brktoverld
chap_brktoverld: \
chap_brktoverld.dats ; $(PATSCC2) -tcats $<
#
######
#
all:: \
chap_dotoverld
chap_dotoverld: \
chap_dotoverld.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_dotoverld; ./$<
cleanall:: ; $(RMF) chap_dotoverld
#
######
#
all:: \
chap_recursion
chap_recursion: \
chap_recursion.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_recursion; ./$<
cleanall:: ; $(RMF) chap_recursion
#
######
#
all:: \
chap_datatypes
chap_datatypes: \
chap_datatypes.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_datatypes; ./$<
cleanall:: ; $(RMF) chap_datatypes
#
######
#
all:: \
chap_list
chap_list: \
chap_list.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_list; ./$<
cleanall:: ; $(RMF) chap_list
#
######
#
######
#
all:: \
chap_exception
chap_exception: \
chap_exception.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_exception; ./$<
cleanall:: ; $(RMF) chap_exception
#
######
#
######
#
all:: \
chap_reference
chap_reference: \
chap_reference.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_reference; ./$<
cleanall:: ; $(RMF) chap_reference
#
######
#
all:: \
chap_tuprec_1
chap_tuprec_1: \
chap_tuprec_1.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_tuprec_1; ./$<
cleanall:: ; $(RMF) chap_tuprec_1
#
######
#
all:: \
chap_arrayptr
chap_arrayptr: \
chap_arrayptr.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_arrayptr; ./$<
cleanall:: ; $(RMF) chap_arrayptr
#
all:: \
chap_arrszptr
chap_arrszptr: \
chap_arrszptr.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_arrszptr; ./$<
cleanall:: ; $(RMF) chap_arrszptr
#
all:: \
chap_matrixptr
chap_matrixptr: \
chap_matrixptr.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_matrixptr; ./$<
cleanall:: ; $(RMF) chap_matrixptr
#
all:: \
chap_mtrxszptr
chap_mtrxszptr: \
chap_mtrxszptr.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_mtrxszptr; ./$<
cleanall:: ; $(RMF) chap_mtrxszptr
#
######
#
all:: \
chap_funsetmap_set
chap_funsetmap_set: \
chap_funsetmap_set.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_funsetmap_set; ./$<
cleanall:: ; $(RMF) chap_funsetmap_set
#
all:: \
chap_funsetmap_map
chap_funsetmap_map: \
chap_funsetmap_map.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_funsetmap_map; ./$<
cleanall:: ; $(RMF) chap_funsetmap_map
#
######
#
all:: \
chap_hashtable
chap_hashtable: \
chap_hashtable.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_hashtable; ./$<
cleanall:: ; $(RMF) chap_hashtable
#
all:: \
chap_hashtable2
chap_hashtable2: \
chap_hashtable2.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_hashtable2; ./$<
cleanall:: ; $(RMF) chap_hashtable2
#
######
#
all:: \
chap_stream
chap_stream: \
chap_stream.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_stream; ./$<
cleanall:: ; $(RMF) chap_stream
#
######
#
all:: \
chap_hordfun
chap_hordfun: \
chap_hordfun.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_hordfun; ./$<
cleanall:: ; $(RMF) chap_hordfun
#
######
#
######
#
# Advanced Topics
#
######
#
all:: \
chap_extvar
chap_extvar: \
chap_extvar.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_extvar; ./$<
cleanall:: ; $(RMF) chap_extvar
#
######
#
all:: \
chap_cloptr
chap_cloptr: \
chap_cloptr.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_cloptr; ./$<
cleanall:: ; $(RMF) chap_cloptr
#
######
#
all:: \
chap_stkclo
chap_stkclo: \
chap_stkclo.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_stkclo; ./$<
cleanall:: ; $(RMF) chap_stkclo
#
######
#
all:: \
chap_stream_vt
chap_stream_vt: \
chap_stream_vt.dats ; \
$(PATSCC2) -o $@ $<
#
regress:: chap_stream_vt; ./$<
cleanall:: ; $(RMF) chap_stream_vt
#
######

include $(PATSHOME)/share/atsmake-post.mk

######

testall:: all
testall:: regress
testall:: cleanall

######

cleanats:: ; $(RMF) *_?ats.c

######

###### end of [Makefile] ######
