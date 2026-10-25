#
# The test of the ccomp group C2: pats_ccomp_{dynexp,decl,claulst}.dats (ATS2 ports of src/pats_ccomp_{dynexp,decl,claulst}.dats), see ../../PORTING.md, "ccomp group C2".
#
#   make test        ATS2 only: the output of cc2 on the generated scenarios (CC2SEED=1 CC2SCALE=3) is the md5 of the output of the ATS1 driver (cc2.md5), also for the cases that end the process
#   make compare     the differential test against the ATS1 driver (ATS1 environment as for ../d2dump1.sh: ATSHOME, ATSHOMERELOC=ATS-0.2.12, atscc, a gcc wrapper accepting K&R C, and the
#                    ATS1 objects of the main tree: SRC=/path/to/ATS-Postiats/src); the ATS1 runs are limited by ulimit -v
#   make cover       gcov coverage by ATS line of the three modules        make mutate      the mutation test (cc2mutate.py)       make asan    AddressSanitizer build and run
#   make small       regenerate cc2.md5 from the ATS1 driver
# Everything else of ccomp (the data constructors, the cells, the environment, patterns, case, ...) is a test double written once for both languages (cc2_dbl.py, cc2_state.c).
#
OUT=../cc2_out

# gen: the generated files (python); build: the staging directory and the program, no run. `make test` does both and then runs and compares; when the top Makefile has built
# the program in its prebuild step (SUBS_PREBUILT, only for `make all` with JOBS>1) `test` only runs and compares.
ifdef SUBS_PREBUILT
TESTDEPS=
else
TESTDEPS=build
endif
.PHONY: gen build build1
gen:
	python3 cc2_gen.py
build: gen
	$(MAKE) --no-print-directory build1
# build1: the build without the generators (the prebuild of ../Makefile has run them)
build1:
	sh cc2_2.sh $(OUT) -O1

test: $(TESTDEPS)
	@a=`$(OUT)/cc2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 cc2.md5`" && echo "cc2: output as expected" || { echo "cc2: output differs from cc2.md5"; exit 1; }
	@test "`sh cc2exit.sh $(OUT)/cc2 | md5sum | awk '{print $$1}'`" = "`sed -n 2p cc2.md5`" && echo "cc2: the cases that end the process as expected" || { echo "cc2: exit cases differ from cc2.md5"; exit 1; }

small:
	python3 cc2_gen.py
	sh cc2_1.sh $(OUT)
	a=`$(OUT)/cc2_1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/cc2_1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > cc2.md5
	sh cc2exit.sh $(OUT)/cc2_1 | md5sum | awk '{print $$1}' >> cc2.md5

compare:
	python3 cc2_gen.py
	sh cc2_2.sh $(OUT) -O1
	sh cc2_1.sh $(OUT)
	sh cc2cmp.sh $(OUT)

cover: compare
	sh cc2gcov.sh $(OUT)

mutate: compare
	python3 cc2mutate.py $(OUT) $(OUT)/o1.txt $(OUT)/e1.txt

asan:
	python3 cc2_gen.py
	sh cc2_2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/cc2 > /dev/null && echo "cc2: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan

.PHONY: test small compare cover mutate asan clean
