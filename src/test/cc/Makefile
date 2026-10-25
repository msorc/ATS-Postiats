#
# The test of the core modules of ccomp: pats_ccomp.dats, pats_ccomp_{tmplab,tmpvar,funlab,funent,d2env,instrseq,util,print}.dats (ATS2 ports of src/pats_ccomp*.dats),
# see ../../PORTING.md, "ccomp core modules". It reuses the test of the erased trees (../hd).
#
#   make test        ATS2 only: the output of cc2 on the generated cases (CCSEED=1 CCSCALE=3) is the md5 of the output of the ATS1 driver (cc.md5), also for the cases that end the process
#   make compare     the differential test against the ATS1 driver (needs the ATS1 environment: ATSHOME, ATSHOMERELOC=ATS-0.2.12, atscc, a gcc wrapper for K&R C,
#                    and the ATS1 objects of the main tree: SRC=/path/to/ATS-Postiats/src)
#   make cover       gcov coverage (by ATS line) of the nine modules, and the functions / constructors that the cases call (cccover.py)
#   make mutate      the mutation test (ccmutate.py: the output of the ATS1 driver is the reference)      make asan    AddressSanitizer build and run
#   make small       regenerate cc.md5 from the ATS1 driver
#
OUT=../cc_out

hdgen:
	$(MAKE) -C ../hd hd_compat2.hats hd_compat1.hats hd_cases_00.hats

cc_compat2.hats cc_compat1.hats cc_cases_00.hats: cc_gen.py cc_cases.py ../hd/hd_gen.py ../hd/hd_cases.py ../../pats_ccomp.spec
	cd ../hd && python3 hd_gen.py
	python3 cc_gen.py

# gen: the generated files (python); build: the staging directory and the program, no run. `make test` does both and then runs and compares; when the top Makefile has built
# the program in its prebuild step (SUBS_PREBUILT, only for `make all` with JOBS>1) `test` only runs and compares.
ifdef SUBS_PREBUILT
TESTDEPS=
else
TESTDEPS=build
endif
.PHONY: gen build
gen:
	cd ../hd && python3 hd_gen.py
	python3 cc_gen.py
build: gen
	sh cc2.sh $(OUT) -O1

test: $(TESTDEPS)
	@a=`$(OUT)/cc2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 cc.md5`" && echo "cc: output as expected" || { echo "cc: output differs from cc.md5"; exit 1; }
	@test "`sh ccexit.sh $(OUT)/cc2 | md5sum | awk '{print $$1}'`" = "`sed -n 2p cc.md5`" && echo "cc: the cases that end the process as expected" || { echo "cc: exit cases differ from cc.md5"; exit 1; }

# regenerate cc.md5 from the ATS1 driver
small:
	cd ../hd && python3 hd_gen.py
	python3 cc_gen.py
	sh cc1.sh $(OUT)
	a=`$(OUT)/cc1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > cc.md5
	sh ccexit.sh $(OUT)/cc1 | md5sum | awk '{print $$1}' >> cc.md5

compare:
	cd ../hd && python3 hd_gen.py
	python3 cc_gen.py
	sh cc2.sh $(OUT) -O1
	sh cc1.sh $(OUT)
	sh cccmp.sh $(OUT)

cover: compare
	python3 cccover.py
	CCEXITS=`grep -c '^fun ccx_' cc_exit.hats` sh ccgcov.sh $(OUT)

mutate: compare
	python3 ccmutate.py $(OUT) $(OUT)/o1.txt $(OUT)/e1.txt

asan:
	cd ../hd && python3 hd_gen.py
	python3 cc_gen.py
	sh cc2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/cc2 > /dev/null && echo "cc: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan cc_compat1.hats cc_compat2.hats cc_hand3_1.hats cc_hand3_2.hats cc_cases_[0-9][0-9].hats ccase_[0-9][0-9].dats ccase1_[0-9][0-9].dats cc_chunks.hats cc_chunks1.hats cc_exit.hats

.PHONY: test small compare cover mutate asan clean hdgen
