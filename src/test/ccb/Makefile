#
# The test of pats_ccomp_{hitype,hipat,subst,template,main}.dats (ATS2 ports of src/pats_ccomp_*.dats), see ../../PORTING.md,
# "ccomp group B (hitype/hipat/subst/template/main)".
#
#   make test        ATS2 only: stdout and stderr of ccb2 on the generated cases (CCBSEED=1, CCBSCALE=20) are the md5 sums of the output of the ATS1 driver (ccb.md5)
#   make compare     the differential test against the ATS1 driver, which links the ATS1-built objects of the main tree (SRC=/path/to/ATS-Postiats/src; environment
#                    as for ../hd/hd1.sh: ATSHOME, ATSHOMERELOC, atscc, a gcc wrapper for K&R C; JOBS=6 is safe for the ATS1 chunks)
#   make cover       gcov coverage (by ATS line) of the five modules
#   make mutate      the mutation test (ccbmutate.py: the output of the ATS1 driver is the reference)      make asan   AddressSanitizer build and run
#   make small       regenerate ccb.md5 from the ATS1 driver
# The phase 1 modules of pats_ccomp.sats are the doubles of dbl/ (copies of the real ones of wt-cc0); the environments, emit and the global lists are the mocks of
# ccb_mock.hats / ccb_stub.c (the leaks of ccb_stub.c are the mock's: suppressed in asan).
#
OUT=../ccb_out
export CCBSCALE ?= 20
export CCBSEED ?= 1

ccb_cases_00.hats: ccb_gen.py ccb_cases.py ccb_sats.py ccb_ctab.json ../../pats_ccomp.spec ../../pats_ccomp_hitype.spec
	python3 ccb_gen.py

test: ccb_cases_00.hats
	sh ccb2.sh $(OUT) -O1
	@a=`$(OUT)/ccb2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/ccb2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 ccb.md5`" && echo "ccb: output as expected" || { echo "ccb: output differs from ccb.md5"; exit 1; }

# regenerate ccb.md5 from the ATS1 driver
small: ccb_cases_00.hats
	sh ccb1.sh $(OUT)
	a=`$(OUT)/ccb1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/ccb1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > ccb.md5

compare: ccb_cases_00.hats
	sh ccb2.sh $(OUT) -O1
	sh ccb1.sh $(OUT)
	sh ccbcmp.sh $(OUT)

cover: ccb_cases_00.hats
	sh ccb2.sh $(OUT) -O1
	sh ccbgcov.sh $(OUT)

mutate: ccb_cases_00.hats
	sh ccb2.sh $(OUT) -O1
	sh ccb1.sh $(OUT)
	sh ccbcmp.sh $(OUT)
	python3 ccbmutate.py $(OUT) $(OUT)/o1.txt $(OUT)/e1.txt

asan: ccb_cases_00.hats
	sh ccb2.sh $(OUT)_asan -g -fsanitize=address
	printf 'leak:ccb_stub\nleak:stk_push\nleak:ccb_gl_\n' > $(OUT)_asan/lsan.supp
	LSAN_OPTIONS=suppressions=$(abspath $(OUT)_asan)/lsan.supp $(OUT)_asan/ccb2 > /dev/null 2>&1 && echo "ccb: asan, no error and no leak (but the mock's)"

clean:
	$(RM) -r $(OUT) $(OUT)_asan ccb_compat1.hats ccb_compat2.hats ccb_common2.hats ccb_hand0_[12].hats ccb_hand_a[12].hats ccb_cdecl[12].hats ccb_stubs[12].hats \
	  ccb_cases_[0-9][0-9].hats ccbcase_[0-9][0-9].dats ccbcase1_[0-9][0-9].dats ccb_chunks.hats ccb_chunks1.hats ccbdump.dats ccbdump1.dats __pycache__

.PHONY: test small compare cover mutate asan clean
