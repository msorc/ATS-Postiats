#
# The test of pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}.dats (ATS2 ports of src/pats_ccomp_*.dats, group C1 of the ccomp port),
# see ../../PORTING.md, "ccomp group C1 (ccompenv/environ/caseof/looping/trywith/lazyeval)".
#
#   make test        ATS2 only: the output of cc1_2 on the generated scenarios (CC1SEED=1) is the md5 of the output of the ATS1 driver (cc1.md5), also for the cases that end the process
#   make compare     the differential test against the ATS1 driver (needs the ATS1 environment of ../d2dump1.sh: ATSHOME, ATSHOMERELOC, atscc, a gcc wrapper for K&R C,
#                    and the ATS1 objects of a built main tree: SRC=/path/to/ATS-Postiats/src)
#   make cover       gcov coverage (by ATS line) of the six modules, and the functions / operations that the scenarios call (cc1_cover.py)
#   make mutate      the mutation test (cc1_mutate.py: the output of the ATS1 driver is the reference)      make asan    AddressSanitizer build and run
#   make small       regenerate cc1.md5 from the ATS1 driver
# The test needs the modules of phase 1 of the port (pats_ccomp_{tmplab,tmpvar,d2env,funlab,funent,instrseq,util,print}.dats and pats_ccomp.dats) in src/ (or in $(CC1_P1)); the
# other functions that the six modules call (hidexp_ccomp, hiclaulst_ccomp, the matching of templates, ..) are doubles (cc1_common.hats, cc1_impl*.hats), the same code for ATS1 and ATS2.
#
OUT=../cc1_out
HAVE_P1=$(wildcard ../../pats_ccomp_funlab.dats ../../pats_ccomp_print.dats ../../pats_ccomp_funent.dats ../../pats_ccomp_instrseq.dats ../../pats_ccomp.dats)

test:
ifeq ($(words $(HAVE_P1)),5)
	python3 cc1_gen.py
	sh cc1_2.sh $(OUT) -O1
	@a=`$(OUT)/cc1_2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc1_2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 cc1.md5`" && echo "cc1: output as expected" || { echo "cc1: output differs from cc1.md5"; exit 1; }
	@test "`sh cc1_exit.sh $(OUT)/cc1_2 | md5sum | awk '{print $$1}'`" = "`sed -n 2p cc1.md5`" && echo "cc1: the cases that end the process as expected" || { echo "cc1: exit cases differ from cc1.md5"; exit 1; }
else
	@echo "cc1: skipped (the modules of phase 1 of the ccomp port are not in src/)"
endif

# regenerate cc1.md5 from the ATS1 driver
small:
	python3 cc1_gen.py
	sh cc1_1.sh $(OUT)
	a=`$(OUT)/cc1_1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc1_1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > cc1.md5
	sh cc1_exit.sh $(OUT)/cc1_1 | md5sum | awk '{print $$1}' >> cc1.md5

compare:
	python3 cc1_gen.py
	sh cc1_2.sh $(OUT) -O1
	sh cc1_1.sh $(OUT)
	sh cc1_cmp.sh $(OUT)

cover: compare
	python3 cc1_cover.py
	sh cc1_gcov.sh $(OUT)

mutate: compare
	python3 -u cc1_mutate.py $(OUT)

asan:
	python3 cc1_gen.py
	sh cc1_2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/cc1_2 > /dev/null && echo "cc1: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan cc1_cases_[0-9][0-9].hats cc1_chunk_[0-9][0-9].dats cc1_chunk1_[0-9][0-9].dats cc1_chunks.hats cc1_chunks1.hats cc1_dyn.hats

.PHONY: test small compare cover mutate asan clean
