#
# The test of pats_histaexp{,_print,_funlab}.dats (ATS2 port of src/pats_histaexp*.dats), see ../../PORTING.md, "Typerase trees (histaexp)".
#
#   make test        ATS2 only: the output of hs2 on the 400 cases of the seed 1 is the md5 of the output of the ATS1 driver (hs_small.md5)
#   make compare     the differential test against the ATS1 driver (needs the ATS1 environment of ../pardump1.sh): SEED, COUNT
#   make cover       gcov coverage (by ATS line) of the three modules          make mutate    the mutation test (hsmutate.py)
#   make asan        AddressSanitizer build and run
# The modules are the real ones of src (pats_stacst2, pats_staexp2_util2/util3/solve); hs_env2.hats / hs_env1.hats are the doubles of trans2_env/trans3_env.
#
OUT=../hs_out
SEED=2
COUNT=3000

hs_cases.hats hs_compat1.hats hs_compat2.hats: hs_gen.py ../../pats_histaexp.spec
	python3 hs_gen.py $(SEED) $(COUNT)

# gen: the generated files (python); build: the staging directory and the program, no run. `make test` does both and then runs and compares; when the top Makefile has built
# the program in its prebuild step (SUBS_PREBUILT, only for `make all` with JOBS>1) `test` only runs and compares.
ifdef SUBS_PREBUILT
TESTDEPS=
else
TESTDEPS=build
endif
.PHONY: gen build build1
gen:
	python3 hs_gen.py 1 400
build: gen
	$(MAKE) --no-print-directory build1
# build1: the build without the generators (the prebuild of ../Makefile has run them)
build1:
	sh hsdrv2.sh $(OUT) -O1

test: $(TESTDEPS)
	@a=`$(OUT)/hs2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/hs2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 hs_small.md5`" && echo "hs: output as expected" || { echo "hs: output differs from hs_small.md5"; exit 1; }

# regenerate hs_small.md5 from the ATS1 driver
small:
	python3 hs_gen.py 1 400
	sh hsdrv1.sh $(OUT)
	a=`$(OUT)/hs1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/hs1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > hs_small.md5

compare:
	python3 hs_gen.py $(SEED) $(COUNT)
	sh hsdrv2.sh $(OUT) -O1
	sh hsdrv1.sh $(OUT)
	$(OUT)/hs1 > $(OUT)/o1.txt 2> $(OUT)/e1.txt; $(OUT)/hs2 > $(OUT)/o2.txt 2> $(OUT)/e2.txt; \
	cmp $(OUT)/o1.txt $(OUT)/o2.txt && cmp $(OUT)/e1.txt $(OUT)/e2.txt && echo "hs: identical, `wc -l < $(OUT)/o1.txt` lines"

cover: compare
	sh hscover.sh $(OUT)

mutate: compare
	python3 hsmutate.py $(OUT) $(OUT)/o1.txt

asan:
	python3 hs_gen.py 1 400
	sh hsdrv2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/hs2 > /dev/null && echo "hs: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan hs_cases.hats hs_compat1.hats hs_compat2.hats

.PHONY: test small compare cover mutate asan clean
