#
# The test of group 1 of the trans3 port (PORTING.md, "Level 3 translation, group 1 (dynexp_up/util/syncst)").
# Run it in src/test:   make -f t3g1.mk t3g1test   (`make t3g1` does it). The doubles of the other groups are in t3g1stub.hats.
#
include Makefile
.DEFAULT_GOAL := t3g1test
T3G1HATS=$(wildcard $(M)/*.hats) $(M)/pats_trans3.sats
T3G1GEN=t3g1_gen.py t3g1hand.tmpl t3g1env.tmpl t3_gen.py t3_cases.py d2_gen.py d2_cases.py s2_cases.py s2_cases2.py t3hand.tmpl $(M)/pats_dynexp3.spec $(M)/pats_trans3_env.spec

t3g1gen.stamp: $(T3G1GEN)
	python3 t3g1_gen.py
	@touch $@
# the stamp is kept in git but the files it stands for are not: a fresh checkout has the stamp and none of them
t3g1envx.hats t3g1envx1.hats t3g1hand.hats t3g1hand1.hats t3g1cases.hats:
	rm -f t3g1gen.stamp; $(MAKE) -f t3g1.mk t3g1gen.stamp
t3g1obj/pats_error_sats.o: pats_error_sats.c
	@mkdir -p t3g1obj
	$(PATSCCA) -c -o $@ $<
t3g1obj/t3g1dump.o: t3g1dump.dats t3g1gen.stamp t3g1stub.hats $(T3HATS) t3g1envx.hats t3g1hand.hats t3g1cases.hats $(T3G1HATS)
	@mkdir -p t3g1obj
	$(PATSCCA) -I$(abspath .) -c -o $@ $<
t3g1dump: t3g1gen.stamp $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3G1MODS))) t3g1obj/pats_error_sats.o t3g1obj/t3g1dump.o
	$(PATSCCA) -o t3g1dump $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3G1MODS))) t3g1obj/pats_error_sats.o t3g1obj/t3g1dump.o -lgmp
t3g1dump1: t3g1gen.stamp
	sh t3g1dump1.sh
t3g1compare: t3g1dump t3g1dump1
	./t3g1dump1 > t3g1.out1 2> t3g1.err1; echo "ATS1 exit: $$?"; ./t3g1dump > t3g1.out2 2> t3g1.err2; echo "ATS2 exit: $$?"; \
	cmp t3g1.out1 t3g1.out2 && cmp t3g1.err1 t3g1.err2 && echo "t3g1compare: identical ($$(wc -l < t3g1.out1) lines of stdout, $$(wc -l < t3g1.err1) of stderr)"
t3g1test: t3g1dump
	./t3g1dump > t3g1.out2 2> t3g1.err2; echo "ATS2 exit: $$?"; \
	a=`md5sum < t3g1.out2 | awk '{print $$1}'`; b=`md5sum < t3g1.err2 | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 t3g1dump.md5 | cut -d' ' -f1,2`" && echo "t3g1dump: output as expected"
.PHONY: t3g1test t3g1compare t3g1dump t3g1dump1

# AddressSanitizer (leak detection on): the whole run
t3g1obj_asan/%_dats.o: $(M)/%.dats $(T3G1HATS)
	@mkdir -p t3g1obj_asan
	cd t3g1obj_asan && $(PATSCCA) -g -fsanitize=address -c -o $(notdir $@) $(abspath $<)
t3g1obj_asan/pats_error_sats.o: pats_error_sats.c
	@mkdir -p t3g1obj_asan
	$(PATSCCA) -g -fsanitize=address -c -o $@ $<
t3g1obj_asan/t3g1dump.o: t3g1dump.dats t3g1gen.stamp t3g1stub.hats $(T3HATS) t3g1envx.hats t3g1hand.hats t3g1cases.hats $(T3G1HATS)
	@mkdir -p t3g1obj_asan
	$(PATSCCA) -g -fsanitize=address -I$(abspath .) -c -o $@ $<
t3g1dump_asan: t3g1gen.stamp $(addprefix t3g1obj_asan/,$(addsuffix _dats.o,$(T3G1MODS))) t3g1obj_asan/pats_error_sats.o t3g1obj_asan/t3g1dump.o
	$(PATSCCA) -g -fsanitize=address -o t3g1dump_asan $(addprefix t3g1obj_asan/,$(addsuffix _dats.o,$(T3G1MODS))) t3g1obj_asan/pats_error_sats.o t3g1obj_asan/t3g1dump.o -lgmp
.PHONY: t3g1dump_asan
