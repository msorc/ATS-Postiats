#
# For building the Erlang code of session-typed channels
# (mylibats2erl1_all.hrl and mylibats2erl2_all.hrl)
# and for installing the libatscc2erl runtime into TEST1 and TEST2
#
# HX-2026-10: this Makefile was missing; it regenerates
# the two files
#

######

PATSOPT=$(PATSHOME)/bin/patsopt
PATSOPT2=$(PATSOPT) --tlcalopt-disable
ATSCC2ERL=$(PATSHOME)/bin/atscc2erl

######

CAT=cat
CPF=cp -f
RMF=rm -f
DATE=date
PRINTF=printf

######

all:: mylibats2erl1_all.hrl
all:: mylibats2erl2_all.hrl

######

output/DATS/%_dats.hrl: DATS/%.dats ; \
$(PATSOPT2) -d $< | $(ATSCC2ERL) -o $@ -i

######

MYLIBATS2ERL_DATS=\
output/DATS/list_dats.hrl \
output/DATS/co-list_dats.hrl \
output/DATS/array_dats.hrl

######

mylibats2erl%_all.hrl: \
CATS/basis%_cats.hrl $(MYLIBATS2ERL_DATS) ; \
( \
$(PRINTF) '%%%%\n%%%% Time of Generation:\n%%%% '; $(DATE); \
$(PRINTF) '%%%%\n\n'; $(CAT) $^; \
$(PRINTF) '\n%%%% ****** ****** %%%%\n\n%%%% end of [$@] %%%%\n' \
) > $@

######

install:: all
#
# HX: TEST[12]/libatscc2erl/Sessiontype_mylibats2erl_all.hrl
# are symbolic links to mylibats2erl[12]_all.hrl
#
install:: ; \
$(CPF) $(PATSHOME)/contrib/libatscc2erl/ATS2-0.3.2/output/libatscc2erl_all.hrl TEST1/libatscc2erl/.
install:: ; \
$(CPF) $(PATSHOME)/contrib/libatscc2erl/ATS2-0.3.2/output/libatscc2erl_all.hrl TEST2/libatscc2erl/.

######

clean:: ; $(RMF) *~ */*~

cleanall:: clean
cleanall:: ; $(RMF) output/DATS/*_dats.hrl

###### end of [Makefile] ######
