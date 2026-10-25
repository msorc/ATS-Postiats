#
# The test of pats_ccomp_emit.dats, pats_ccomp_emit2.dats, pats_ccomp_emit3.dats (ATS2 ports of src/pats_ccomp_emit*.dats, the C emitter of ccomp),
# see ../../PORTING.md, "ccomp group A (emit)".
#
#   make test        ATS2 only: the output of ca2 on the generated cases (CASEED=1, CASCALE=3) is the md5 of the output of the ATS1 driver (ca.md5), also for the cases that end the process
#   make compare     the differential test against the ATS1 driver (needs the ATS1 environment of ../d2dump1.sh: ATSHOME, ATSHOMERELOC, atscc, a gcc wrapper for K&R C,
#                    and the ATS1 objects of the main tree: SRC=/path/to/ATS-Postiats/src)
#   make cover       gcov coverage (by ATS line) of the three modules
#   make mutate      the mutation test (camutate.py: the output of the ATS1 driver is the reference)      make asan    AddressSanitizer build and run
#   make small       regenerate ca.md5 from the ATS1 driver
# The modules are the real ones of src; the functions of the other ccomp modules are the doubles of ca_dbl.dats (ATS1 side: the real modules of src/, ca_dbl1.hats for the type emitters).
#
OUT=../ca_out
MASK=sed 's/^\*\* The starting compilation time is: .*$$/STARTTIME/'

ca_compat2.hats ca_compat1.hats ca_cases_00.hats: ca_gen.py ca_cases.py ../hd/hd_gen.py ../hd/hd_cases.py ../../pats_ccomp.spec ../../pats_histaexp.spec ../../pats_hidynexp.spec
	python3 ca_gen.py

# gen: the generated files (python); build: the staging directory and the program, no run. `make test` does both and then runs and compares; when the top Makefile has built
# the program in its prebuild step (SUBS_PREBUILT, only for `make all` with JOBS>1) `test` only runs and compares.
ifdef SUBS_PREBUILT
TESTDEPS=
else
TESTDEPS=build
endif
.PHONY: gen build build1
gen:
	python3 ca_gen.py
build: gen
	$(MAKE) --no-print-directory build1
# build1: the build without the generators (the prebuild of ../Makefile has run them)
build1:
	sh ca2.sh $(OUT) -O1

test: $(TESTDEPS)
	@a=`$(OUT)/ca2 2>/dev/null | $(MASK) | md5sum | awk '{print $$1}'`; b=`$(OUT)/ca2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 ca.md5`" && echo "ca: output as expected" || { echo "ca: output differs from ca.md5"; exit 1; }
	@test "`sh caexit.sh $(OUT)/ca2 | md5sum | awk '{print $$1}'`" = "`sed -n 2p ca.md5`" && echo "ca: the cases that end the process as expected" || { echo "ca: exit cases differ from ca.md5"; exit 1; }

# regenerate ca.md5 from the ATS1 driver
small:
	python3 ca_gen.py
	sh ca1.sh $(OUT)
	a=`$(OUT)/ca1 2>/dev/null | $(MASK) | md5sum | awk '{print $$1}'`; b=`$(OUT)/ca1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > ca.md5
	sh caexit.sh $(OUT)/ca1 | md5sum | awk '{print $$1}' >> ca.md5

compare:
	python3 ca_gen.py
	sh ca2.sh $(OUT) -O1
	sh ca1.sh $(OUT)
	sh cacmp.sh $(OUT)

cover: compare
	CAEXITS=`grep -c '^fun cax_' ca_exit.hats` sh cagcov.sh $(OUT)

mutate: compare
	python3 camutate.py $(OUT) $(OUT)/o1.txt $(OUT)/e1.txt

asan:
	python3 ca_gen.py
	sh ca2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/ca2 > /dev/null && echo "ca: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan ca_compat1.hats ca_compat2.hats ca_common2.hats ca_hand_a1.hats ca_hand_a2.hats ca_k1.hats ca_k2.hats ca_cases_[0-9][0-9].hats cacase_[0-9][0-9].dats cacase1_[0-9][0-9].dats ca_chunks.hats ca_chunks1.hats ca_exit.hats

.PHONY: test small compare cover mutate asan clean
