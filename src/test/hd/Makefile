#
# The test of pats_hidynexp{,_print,_util}.dats and pats_typerase_{error,staexp,dynexp,decl}.dats (ATS2 ports of src/pats_hidynexp*.dats, src/pats_typerase*.dats),
# see ../../PORTING.md, "Erased trees (hidynexp)" and "Type erasure (typerase)".
#
#   make test        ATS2 only: the output of hd2 on the generated cases (HDSEED=1, HDSCALE=3) is the md5 of the output of the ATS1 driver (hd.md5), also for the cases that end the process
#   make compare     the differential test against the ATS1 driver (needs the ATS1 environment of ../d2dump1.sh: ATSHOME, ATSHOMERELOC, atscc, a gcc wrapper for K&R C,
#                    and the ATS1 objects of the main tree: SRC=/path/to/ATS-Postiats/src)
#   make cover       gcov coverage (by ATS line) of the seven modules, and the functions / constructors that the cases call (hdcover.py)
#   make mutate      the mutation test (hdmutate.py: the output of the ATS1 driver is the reference)      make asan    AddressSanitizer build and run
#   make small       regenerate hd.md5 from the ATS1 driver
# The modules are the real ones of src; the doubles of trans2_env / trans3_env are s2env2.hats / s2env1.hats and the cells of the file environments (hd_stub.c).
#
OUT=../hd_out

hd_compat2.hats hd_compat1.hats hd_cases_00.hats: hd_gen.py hd_cases.py hd_ty.py ../d2_gen.py ../d2_cases.py ../../pats_hidynexp.spec ../../pats_histaexp.spec ../../pats_dynexp3.spec
	python3 hd_gen.py

# gen: the generated files (python); build: the staging directory and the program, no run. `make test` does both and then runs and compares; when the top Makefile has built
# the program in its prebuild step (SUBS_PREBUILT, only for `make all` with JOBS>1) `test` only runs and compares.
ifdef SUBS_PREBUILT
TESTDEPS=
else
TESTDEPS=build
endif
.PHONY: gen build build1
gen:
	python3 hd_gen.py
build: gen
	$(MAKE) --no-print-directory build1
# build1: the build without the generators (the prebuild of ../Makefile has run them)
build1:
	sh hd2.sh $(OUT) -O1

test: $(TESTDEPS)
	@a=`$(OUT)/hd2 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/hd2 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 hd.md5`" && echo "hd: output as expected" || { echo "hd: output differs from hd.md5"; exit 1; }
	@test "`sh hdexit.sh $(OUT)/hd2 | md5sum | awk '{print $$1}'`" = "`sed -n 2p hd.md5`" && echo "hd: the cases that end the process as expected" || { echo "hd: exit cases differ from hd.md5"; exit 1; }

# regenerate hd.md5 from the ATS1 driver
small:
	python3 hd_gen.py
	sh hd1.sh $(OUT)
	a=`$(OUT)/hd1 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(OUT)/hd1 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; echo "$$a $$b" > hd.md5
	sh hdexit.sh $(OUT)/hd1 | md5sum | awk '{print $$1}' >> hd.md5

compare:
	python3 hd_gen.py
	sh hd2.sh $(OUT) -O1
	sh hd1.sh $(OUT)
	sh hdcmp.sh $(OUT)

cover: compare
	python3 hdcover.py
	HDEXITS=`grep -c '^fun hdx_' hd_exit.hats` sh hdgcov.sh $(OUT)

mutate: compare
	python3 hdmutate.py $(OUT) $(OUT)/o1.txt $(OUT)/e1.txt

asan:
	python3 hd_gen.py
	sh hd2.sh $(OUT)_asan -g -fsanitize=address
	$(OUT)_asan/hd2 > /dev/null && echo "hd: asan, no error and no leak"

clean:
	$(RM) -r $(OUT) $(OUT)_asan hd_compat1.hats hd_compat2.hats hd_common2.hats hd_hand_a1.hats hd_hand_a2.hats hd_cases_[0-9][0-9].hats hdcase_[0-9][0-9].dats hdcase1_[0-9][0-9].dats hd_chunks.hats hd_chunks1.hats hd_exit.hats

.PHONY: test small compare cover mutate asan clean
