#
# Link-and-run drivers for the ported modules. Each driver dynloads
# the modules it needs (ATS_DYNLOADFLAG is not defined, as in patsopt).
#
# The md5 suites run all the cases of a list in ONE process (the stamps and the
# staload caches accumulate), so the md5 depends on the ORDER of the list, which
# comes from shell globs (t1cases/*.sats ...): fix the collation, whatever the
# locale of the caller is.
export LC_ALL := C
# HX-2026-10: the recorded sums are those of the numeric error locations
export PATSOPT_LEGACY_ERRORS := 1
# The cases print the location of the prelude files relative to PATSHOME: use the
# canonical root of this repository, whatever PATSHOME the caller has (e.g. one
# with ".." segments), so that the md5 sums do not depend on it.
export PATSHOME := $(abspath ../..)
PATSCC=patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I..
M=..

# Parallel build. JOBS (default: the number of processors; JOBS=1 gives the old, fully serial run) is the number of parallel compilations of
# the "prebuild" step of `all`: it builds, at the same time, every program that the suites run (the C files of ~900 modules), and the rest of `all`
# (the runs, the comparisons, the md5 sums) stays serial, in the same order, on the programs that are up to date by then. The step has two phases:
#  1. (serial) everything that is generated, once: the stamps and files of the python generators (they write files that several suites share),
#     the arena encodings ($(M)/pats_*_gen*.hats, made by `make -C $(M)`), pats_error_sats.c;
#  2. (make -jJOBS, PREBUILD=1) the programs. patscc writes the C file of `X.dats` as X_dats.c into the CURRENT directory, so two compilations
#     of a module may run at the same time only if they run in different directories: the objects are made in an object directory
#     (`cd xobj && patscc -c`; the modules with the default options are compiled once, in modobj, and linked by all the suites; the suites
#     with other options have their own directories), and the programs that patscc builds from sources are built in a private directory ../cc_tmp_PROGRAM (CCIN: at
#     the same depth as this directory, so that the "../pats_X.dats" of the sources mean the same file and give the same symbol names).
# (c3obj_int/c3dump.o is the same program as c3obj/c3dump.o with another define, compiled in a private directory for the same reason.)
# Without PREBUILD the whole Makefile is serial (.NOTPARALLEL), so that a `make -j N` of the caller cannot run the suites at the same time:
# they share the generated files, and each run needs the programs of its own step.
JOBS ?= $(shell nproc 2>/dev/null || echo 4)
export JOBS
ifndef PREBUILD
.NOTPARALLEL:
endif

# patscc of the sources $(3) (a list of files relative to this directory) into the program $(1), run in the private directory $(M)/cc_tmp_$(1).
# $(2): options before the sources, $(4): libraries after them.
CCIN=mkdir -p $(M)/cc_tmp_$(1) && cd $(M)/cc_tmp_$(1) && patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$(M) -I../test -IATS ../test $(2) -o ../test/$(1) $(foreach f,$(3),$(if $(filter ../%,$(f)),$(f),../test/$(f))) $(4)

all: prebuild
.PHONY: prebuild pregen preexes
prebuild:
ifneq ($(JOBS),1)
	@$(MAKE) --no-print-directory pregen
	@$(MAKE) --no-print-directory -j$(JOBS) -Otarget PREBUILD=1 preexes
endif
TESTS=test_basics test_utils test_intinf test_intinf_int test_counter test_stamp \
      test_error test_symbol test_filename test_location test_errmsg \
      test_label test_fixity test_symmap test_symenv test_syntax test_lexing test_avlmap

# prebuild is named again here: the prerequisites of the rule that has the recipe come first, so without it the programs below were built
# one by one (.NOTPARALLEL) before the parallel prebuild started
all: prebuild $(TESTS) pardump e1xdump treedump d1dump
	@for t in $(TESTS); do echo "run $$t"; ./$$t > /dev/null 2>&1 || exit 1; done
	@./pardump parcorpus.hand 2>&1 | diff - pardump.expected && echo "pardump: output as expected"
	@./test_syntax | diff - test_syntax.expected && echo "test_syntax: output as expected"
	@./e1xdump e1xcorpus.hand 2>&1 | diff - e1xdump.expected > /dev/null && echo "e1xdump: output as expected"
	@test "`./treedump 2>&1 | md5sum | awk '{print $$1}'`" = "`head -1 treedump.md5`" && echo "treedump: output as expected"
	@$(MAKE) --no-print-directory t1test
	@$(MAKE) --no-print-directory s2test

test_basics: test_basics.dats $(M)/pats_basics.dats
	$(call CCIN,$@,,$^)
test_utils: test_utils.dats $(M)/pats_utils.dats
	$(call CCIN,$@,,$^)
test_intinf: test_intinf.dats $(M)/pats_utils.dats $(M)/pats_intinf.dats
	$(call CCIN,$@,,$^,-lgmp)
# the gmp-free variant of pats_intinf
test_intinf_int: test_intinf.dats $(M)/pats_utils.dats $(M)/pats_intinf.dats
	$(call CCIN,$@,-DATS C3NSTRINTKND=intknd,$^)
test_counter: test_counter.dats $(M)/pats_counter.dats
	$(call CCIN,$@,,$^)
test_stamp: test_stamp.dats $(M)/pats_counter.dats $(M)/pats_stamp.dats
	$(call CCIN,$@,,$^)
# a .sats file with exception declarations is compiled by itself
pats_error_sats.c: $(M)/pats_error.sats
	patsopt --output $@ --static $<
test_error: test_error.dats $(M)/pats_error.dats pats_error_sats.c
	$(call CCIN,$@,,$^)
test_symbol: test_symbol.dats $(M)/pats_symbol.dats
	$(call CCIN,$@,,$^)
test_filename: test_filename.dats $(M)/pats_utils.dats $(M)/pats_symbol.dats $(M)/pats_filename.dats
	$(call CCIN,$@,,$^)
test_location: test_location.dats $(M)/pats_utils.dats $(M)/pats_symbol.dats $(M)/pats_filename.dats $(M)/pats_location.dats
	$(call CCIN,$@,,$^)
test_errmsg: test_errmsg.dats $(M)/pats_utils.dats $(M)/pats_symbol.dats $(M)/pats_filename.dats $(M)/pats_location.dats
	$(call CCIN,$@,,$^)

test_label: test_label.dats $(M)/pats_symbol.dats $(M)/pats_label.dats
	$(call CCIN,$@,,$^)
test_fixity: test_fixity.dats $(M)/pats_utils.dats $(M)/pats_symbol.dats $(M)/pats_filename.dats $(M)/pats_location.dats $(M)/pats_fixity_prec.dats $(M)/pats_fixity_fxty.dats $(M)/pats_error.dats pats_error_sats.c
	$(call CCIN,$@,,$^)
test_symmap: test_symmap.dats $(M)/pats_symbol.dats $(M)/pats_symmap.dats
	$(call CCIN,$@,,$^)
test_avlmap: test_avlmap.dats $(M)/pats_avlmap.dats
	$(call CCIN,$@,,$^)
test_symenv: test_symenv.dats $(M)/pats_symbol.dats $(M)/pats_symmap.dats $(M)/pats_symenv.dats
	$(call CCIN,$@,,$^)

# reader, lexbuf, lexing, tokbuf
LEXSRC=$(M)/pats_utils.dats $(M)/pats_symbol.dats $(M)/pats_filename.dats $(M)/pats_location.dats $(M)/pats_basics.dats $(M)/pats_reader.dats $(M)/pats_lexbuf.dats $(M)/pats_lexing_token.dats $(M)/pats_lexing.dats $(M)/pats_lexing_error.dats $(M)/pats_lexing_print.dats $(M)/pats_tokbuf.dats
# the level-0 syntax: the output is compared with test_syntax.expected
test_syntax: test_syntax.dats $(M)/pats_label.dats $(M)/pats_syntax.dats $(M)/pats_syntax_print.dats $(LEXSRC)
	$(call CCIN,$@,,$^)

test_lexing: test_lexing.dats $(LEXSRC)
	$(call CCIN,$@,,$^)
# the token dumper used for the comparison with the ATS1 lexer (see lexcompare)
lexdump: lexdump.dats $(LEXSRC)
	$(PATSCC) -o $@ $^

# the parser: prints what the parsers of pats_parsing_* (sort, staexp, e0xp, p0at, dynexp, decl,
# toplevel) return for the fragments "KIND<TAB>text" of a file (the kinds FILEsta/FILEdyn parse a
# whole file, the kinds TOPsta/TOPdyn a text), with the complete dumper of deepdump.hats.
# pardump.expected is the output of the ATS1-built parser (pardump1) on parcorpus.hand.
PARSRC=$(M)/pats_error.dats pats_error_sats.c $(M)/pats_label.dats $(M)/pats_syntax.dats $(M)/pats_syntax_print.dats $(LEXSRC) \
  $(M)/pats_parsing.dats $(M)/pats_parsing_util.dats $(M)/pats_parsing_error.dats $(M)/pats_parsing_kwds.dats \
  $(M)/pats_parsing_base.dats $(M)/pats_parsing_e0xp.dats $(M)/pats_parsing_sort.dats $(M)/pats_parsing_staexp.dats \
  $(M)/pats_parsing_p0at.dats $(M)/pats_parsing_dynexp.dats $(M)/pats_parsing_decl.dats $(M)/pats_parsing_toplevel.dats
pardump: pardump.dats pardump.cats deepdump.hats $(PARSRC)
	$(call CCIN,$@,,pardump.dats $(PARSRC))

# Validation against the ATS1 parser of src/ (same environment as for lexcompare):
#   make parcompare CORPUS=corpus.txt
# corpus: SEED=1 FUZZ=20000 GFUZZ=40000 DFUZZ=120000 DGFUZZ=200000 FMUT=3000 python3 parcorpus.py 40 FILES > corpus.txt
pardump1: pardump1.dats pardump.cats deepdump1.hats
	sh pardump1.sh
parcompare: pardump pardump1
	./pardump1 $(CORPUS) > /tmp/pardump1.out 2>&1; ./pardump $(CORPUS) > /tmp/pardump.out 2>&1; \
	cmp /tmp/pardump1.out /tmp/pardump.out && echo "parcompare: identical"

# Whole files (parfiles.sh) and the toplevel entry points of pats_parsing.dats (kinds PGN*, PFR*, PGNL*):
parfiles: pardump pardump1
	sh parfiles.sh

# regenerate the dumpers and the drivers (deepdump_gen.py reads ../pats_syntax.spec)
gen:
	python3 deepdump_gen.py
	python3 pardump_gen.py
	python3 tree1_gen.py

# Validation against the ATS1 lexer of src/ (needs the ATS1 environment of CLAUDE.md:
# ATSHOME, ATSHOMERELOC, the gcc wrapper, and the .o files built in src/).
#   make lexcompare LIST=files.txt     # one path per line
lexdump1: lexdump1.dats
	sh lexdump1.sh
lexcompare: lexdump lexdump1
	sh lexcompare.sh $(LIST)

clean:
	$(RM) s2dump s2dump1 s2dump_asan s2gen.stamp s2case1_[0-9][0-9]_dats.o s2case1_[0-9][0-9]_dats.c s2dump1_dats.c
	$(RM) -r s2obj s2obj_asan
	$(RM) $(TESTS) lexdump lexdump1 pardump pardump1 pardump_asan pardump_o2 e1xdump e1xdump1 e1xdump_asan treedump treedump1 treedump_asan d1dump d1dump1 d1dump_asan d1dump_o2 *_?ats.c *.o
	$(RM) -r $(MODOBJ)
	$(RM) -r d1obj d1obj_o2 d1obj_asan t1.1.o t1.1.e t1.2.o t1.2.e t1list.txt
	$(RM) -r $(M)/cc_tmp_*

# ---------------------------------------------------------------------------------------------
# Level 1: pats_effect, pats_staexp1(_print), pats_dynexp1(_print), pats_e1xpval(_error), pats_trans1_env (the e1xpenv)
#
# e1xdump: plays the directives (#define/#undef/#if.../#print) of "KIND<TAB>text" lines (KIND TOPsta, TOPdyn,
#   FILEsta, FILEdyn) with the evaluator of pats_e1xpval.dats; e1xdump.expected is the output of the ATS1-built
#   e1xdump1 on e1xcorpus.hand.
# treedump: builds a tree for every constructor of the level-1 syntax and calls the smart constructors
#   (treecases.hats, generated by tree1_gen.py), and prints them; treedump.md5 is the md5sum (and line count) of the output
#   of the ATS1-built treedump1.
L1TREESRC=$(M)/pats_effect.dats $(M)/pats_staexp1.dats $(M)/pats_staexp1_print.dats $(M)/pats_dynexp1.dats $(M)/pats_dynexp1_print.dats
L1SRC=$(M)/pats_effect.dats $(M)/pats_fixity_prec.dats $(M)/pats_fixity_fxty.dats $(M)/pats_symmap.dats $(M)/pats_symenv.dats $(M)/pats_trans1_env.dats $(M)/pats_staexp1.dats $(M)/pats_staexp1_print.dats \
  $(M)/pats_dynexp1.dats $(M)/pats_dynexp1_print.dats $(M)/pats_e1xpval.dats $(M)/pats_e1xpval_error.dats

e1xdump: e1xdump.dats e1xdump.cats pardump.cats $(PARSRC) $(L1SRC)
	$(call CCIN,$@,,e1xdump.dats $(PARSRC) $(L1SRC))

# the tree cases are large and generated: not kept in git
treecases.hats treecases1.hats: tree1_gen.py
	python3 tree1_gen.py

treedump: treedump.dats treecases.hats deepdump.hats deepdump_l1.hats pardump.cats $(PARSRC) $(L1TREESRC)
	$(call CCIN,$@,,treedump.dats $(PARSRC) $(L1TREESRC))

# AddressSanitizer builds (no error, no leak expected, except the linear environments of an evaluation that aborts)
e1xdump_asan: e1xdump.dats e1xdump.cats pardump.cats $(PARSRC) $(L1SRC)
	$(PATSCC) -fsanitize=address -g -o $@ e1xdump.dats $(PARSRC) $(L1SRC)
treedump_asan: treedump.dats treecases.hats deepdump.hats deepdump_l1.hats pardump.cats $(PARSRC) $(L1TREESRC)
	$(PATSCC) -fsanitize=address -g -o $@ treedump.dats $(PARSRC) $(L1TREESRC)

# Validation against the ATS1 build of src/ (same environment as for pardump1):
e1xdump1: e1xdump1.dats e1xdump.cats pardump.cats
	sh e1xdump1.sh
treedump1: treedump1.dats treecases1.hats deepdump1.hats deepdump1_l1.hats
	sh treedump1.sh
#   make e1xcompare CORPUS=corpus.txt     # python3 e1xcorpus.py SEED N > corpus.txt (3000 programs: 6090 lines)
e1xcompare: e1xdump e1xdump1
	./e1xdump1 $(CORPUS) > /tmp/e1xdump1.out 2>&1; ./e1xdump $(CORPUS) > /tmp/e1xdump.out 2>&1; \
	cmp /tmp/e1xdump1.out /tmp/e1xdump.out && echo "e1xcompare: identical"
treecompare: treedump treedump1
	./treedump1 > /tmp/treedump1.out 2>&1; ./treedump > /tmp/treedump.out 2>&1; \
	cmp /tmp/treedump1.out /tmp/treedump.out && echo "treecompare: identical"
#   all the files of the repository (every directive of every file)
e1xfiles: e1xdump e1xdump1
	sh e1xfiles.sh

# ---------------------------------------------------------------------------------------------
# Level 1 translation: pats_trans1*, pats_fixity, pats_global, pats_filename_reloc (see PORTING.md, "Level 1 translation")
#
# d1dump LIST [START [time]]: for the lines "KIND<TAB>path" of LIST (KIND: FILEsta/FILEdyn, RAWsta/RAWdyn, RELsta/RELdyn) the driver
#   does what pats_main.dats does for `patsopt -s/-d path` (the_fixity_load, parse_from_givename_toplevel, d0eclist_tr_errck,
#   trans1_finalize), and dumps the whole d1eclist (d1dump.dats). d1dump1 is the same driver linked with the ATS1 objects of $ATS1REF.
# The objects of the modules are compiled one by one (make -j): the -O0 ones into $(MODOBJ), shared by all the suites (see below),
# d1obj_o2 (d1dump_o2, -O2: the speed test), d1obj_asan (d1dump_asan, -fsanitize=address).
PATSCCA=patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$(abspath $(M))
# The objects of the compiler modules ($(M)/pats_X.dats) that the suites link with their drivers: the *obj directories of the suites
# (s2obj d2obj ... c3obj) have no module object of their own when the flags are the default ones, they link the ones of $(MODOBJ),
# which are compiled once, by the rule `$(MODOBJ)/%_dats.o` below (the same patscc options for all of them, and the C text does
# not depend on the directory, because the source is given by its absolute path). The variants with other options (the
# *obj_asan, *obj_cov and *obj_o2 directories, and c3obj_int, which has C3NSTRINTKND=intknd) keep their own module objects;
# their rules are made by MODRULE, which each XRULES macro calls when its second argument (the options) is not empty.
MODOBJ=modobj
define MODRULE
$(1)/%_dats.o: $(M)/%.dats $(3)
	@mkdir -p $(1)
	cd $(1) && $(PATSCCA) $(2) -c -o $$(notdir $$@) $$(abspath $$<)
endef
D1MODS=pats_error pats_basics pats_utils pats_global pats_symbol pats_filename pats_location pats_label pats_syntax pats_syntax_print \
  pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf \
  pats_parsing pats_parsing_util pats_parsing_error pats_parsing_kwds pats_parsing_base pats_parsing_e0xp pats_parsing_sort \
  pats_parsing_staexp pats_parsing_p0at pats_parsing_dynexp pats_parsing_decl pats_parsing_toplevel \
  pats_effect pats_fixity_prec pats_fixity_fxty pats_symmap pats_symenv pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print \
  pats_e1xpval pats_e1xpval_error pats_trans1_env pats_trans1_e0xp pats_trans1_error pats_trans1_effect pats_trans1_sort \
  pats_trans1_staexp pats_trans1_p0at pats_trans1_syndef pats_trans1_dynexp pats_trans1_decl pats_filename_reloc
D1OBJS=$(addprefix $(or $(2),$(1))/,$(addsuffix _dats.o,$(D1MODS))) $(1)/pats_error_sats.o $(1)/d1dump.o

define D1RULES
$(if $(2),$(call MODRULE,$(1),$(2),))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/d1dump.o: d1dump.dats d1dump.cats pardump.cats deepdump.hats deepdump_t1.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ d1dump.dats
endef
$(eval $(call D1RULES,d1obj,))
$(eval $(call D1RULES,d1obj_asan,-g -fsanitize=address))
$(eval $(call D1RULES,d1obj_o2,-O2))
d1dump: $(call D1OBJS,d1obj,$(MODOBJ))
	$(PATSCCA) -o $@ $^ -lgmp
d1dump_asan: $(call D1OBJS,d1obj_asan)
	$(PATSCCA) -g -fsanitize=address -o $@ $^ -lgmp
d1dump_o2: $(call D1OBJS,d1obj_o2)
	$(PATSCCA) -O2 -o $@ $^ -lgmp

# the dumpers with the hook of the staloaded files (generated, not kept in git)
deepdump_t1.hats deepdump1_t1.hats: tree1_gen.py
	python3 tree1_gen.py

d1dump1: d1dump1.dats d1dump.cats pardump.cats deepdump1.hats deepdump1_t1.hats
	sh d1dump1.sh

# The hand-written cases t1cases/ (fixity, #define/#if, $extval, overload, staload, abstypes, datatypes, local, templates, errors...)
# in the 3 modes; t1cases.md5 is the md5sum of the ATS1 output with the directory made anonymous (make t1test needs no ATS1)
t1list.txt: $(wildcard t1cases/*)
	for m in FILE RAW REL; do for f in t1cases/*.sats; do printf "%ssta\t$(CURDIR)/%s\n" $$m $$f; done; \
	  for f in t1cases/*.dats t1cases/*.hats; do printf "%sdyn\t$(CURDIR)/%s\n" $$m $$f; done; done > $@
t1test: d1dump t1list.txt
	@sh d1chunk.sh ./d1dump t1list.txt t1.2; \
	test "`cat t1.2.o t1.2.e | sed 's|$(abspath $(M)/..)/||g' | md5sum | awk '{print $$1}'`" = "`head -1 t1cases.md5`" && echo "t1test: output as expected"; r=$$?; rm -f t1.2.o t1.2.e; exit $$r
t1compare: d1dump d1dump1 t1list.txt
	sh d1chunk.sh ./d1dump1 t1list.txt t1.1; sh d1chunk.sh ./d1dump t1list.txt t1.2; \
	cmp t1.1.o t1.2.o && cmp t1.1.e t1.2.e && echo "t1compare: identical"; \
	cat t1.1.o t1.1.e | sed 's|$(abspath $(M)/..)/||g' | md5sum | awk '{print $$1}' > t1cases.md5; rm -f t1.1.o t1.1.e t1.2.o t1.2.e

# Whole files (d1files.sh): every .sats/.dats/.hats of the repository, in the modes FILE, RAW and REL:
#   make d1files             (needs the ATS1 environment of pardump1, PATSHOME, and d1dump, d1dump1)
d1files: d1dump d1dump1
	sh d1files.sh
.PHONY: t1test t1compare d1files t1list.txt

# ---------------------------------------------------------------------------------------------
# Level 2 (pats_staexp2*, pats_namespace, pats_avlmap): see PORTING.md, "Level 2"
#
# s2dump runs the cases generated by s2_gen.py (s2_cases.py): random values of every type of the level-2 static syntax and calls of
# every function of the modules, dumped completely (s2compat_gen.hats). s2dump1 is the same program for the ATS1 build of $ATS1REF
# (s2dump1.sh); `make s2compare` diffs the two outputs. The cases are generated, not kept in git (s2_cases.py is the source).
# pats_staexp2_util2/util3/solve, pats_stacst2 are real here. The functions of the modules that are not ported yet that they call
# (pats_trans2_env.dats, pats_trans3_env.dats) are test doubles (s2env2.hats, s2env1.hats), see PORTING.md, "Level 2, slice 2".
S2MODS=pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename \
  pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf \
  pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst \
  pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print \
  pats_staexp2_pprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace
S2GENFILES=s2_gen.py s2_cases.py $(M)/pats_staexp2.spec $(M)/pats_staexp2_error.spec
S2HATS=s2case_pre.hats s2common1.hats s2common2.hats s2glue2_pre.hats s2glue2_mid.hats s2glue2_post.hats s2compat_gen.hats $(M)/mylibies.hats
S2CHUNKS=$(sort $(wildcard s2case_[0-9][0-9].dats))
S2COBJS=$(patsubst s2case_%.dats,$(1)/s2case_%.o,$(S2CHUNKS))

s2gen.stamp: $(S2GENFILES)
	python3 s2_gen.py
	@touch $@
.PHONY: s2gen s2dump s2dump_exe s2dump_asan s2dump_asan_exe s2dump1 s2compare
s2gen: s2gen.stamp

define S2RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(M)/pats_staexp2_gen.hats $(M)/pats_staexp2_gen_dats.hats $(M)/pats_staexp2_error_gen.hats $(M)/pats_staexp2_error_gen_dats.hats))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/s2case_%.o: s2case_%.dats s2gen.stamp $(S2HATS) s2cases_%.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/s2dump.o: s2dump.dats s2gen.stamp $(S2HATS) s2env2.hats s2chunks.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
$(eval $(call S2RULES,s2obj,))
$(eval $(call S2RULES,s2obj_asan,-g -fsanitize=address))
# the objects of the chunks are listed after the generation (a recursive make)
s2dump: s2gen.stamp
	$(MAKE) --no-print-directory s2dump_exe
s2dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(S2MODS))) s2obj/pats_error_sats.o s2obj/s2dump.o $(call S2COBJS,s2obj)
	$(PATSCCA) -o s2dump $^ -lgmp
s2dump_asan: s2gen.stamp
	$(MAKE) --no-print-directory s2dump_asan_exe
s2dump_asan_exe: $(addprefix s2obj_asan/,$(addsuffix _dats.o,$(S2MODS))) s2obj_asan/pats_error_sats.o s2obj_asan/s2dump.o $(call S2COBJS,s2obj_asan)
	$(PATSCCA) -g -fsanitize=address -o s2dump_asan $^ -lgmp
s2dump1: s2gen.stamp
	sh s2dump1.sh
s2compare: s2dump s2dump1
	./s2dump1 > /tmp/s2dump1.out 2> /tmp/s2dump1.err; ./s2dump > /tmp/s2dump.out 2> /tmp/s2dump.err; \
	cmp /tmp/s2dump1.out /tmp/s2dump.out && cmp /tmp/s2dump1.err /tmp/s2dump.err && echo "s2compare: identical"
# the generated encodings of pats_staexp2.spec (src/Makefile)
$(M)/pats_staexp2_gen.hats $(M)/pats_staexp2_gen_dats.hats $(M)/pats_staexp2_error_gen.hats $(M)/pats_staexp2_error_gen_dats.hats:
	$(MAKE) -C $(M) $(notdir $@)

# the test of the level 2 without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built s2dump1 (s2dump.md5), the unit test of pats_avlmap
s2test: s2dump test_avlmap
	@./test_avlmap
	@a=`./s2dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./s2dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 s2dump.md5 | cut -d' ' -f1,2`" && echo "s2dump: output as expected"
# the coverage of the constructors and the functions by the generated cases
s2cover: s2gen
	python3 s2cover.py

# Slice 2 of the level 2 (pats_staexp2_util2/util3/solve, pats_stacst2): the line coverage of the four modules by the cases (gcov, by ATS line)
s2gcov: s2dump
	sh s2gcov.sh /tmp/s2cov
.PHONY: s2gcov

# ---------------------------------------------------------------------------------------------
# Level 2 dynamic (pats_dynexp2, _dcst, _dmac, _dvar, _mapgen, _print, _util): see PORTING.md, "Level 2 dynamic (dynexp2)"
#
# d2dump runs the cases generated by d2_gen.py (d2_cases.py): random values of every type of the level-2 dynamic syntax and calls of every
# function of the 7 modules, dumped completely (d2compat_gen.hats). d2dump1 is the same program for the ATS1 build of $ATS1REF (d2dump1.sh);
# `make d2compare` diffs the two outputs. The cases are generated, not kept in git (d2_cases.py is the source).
# pats_staexp2_util2/util3/solve, pats_stacst2 are real here (S2MODS); the trans2_env/trans3_env functions they call are the test doubles of
# the level 2 static test (s2env2.hats, s2env1.hats).
D2MODS=$(S2MODS) pats_dynexp1 pats_dynexp1_print pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util
D2GENFILES=d2_gen.py d2_cases.py $(M)/pats_staexp2.spec $(M)/pats_dynexp2.spec
# the chunks instantiate the templates of these modules (staload _ in d2case_pre.hats)
D2TMPL=$(M)/pats_utils.dats $(M)/pats_error.dats $(M)/pats_syntax.dats $(M)/pats_avlmap.dats $(M)/pats_staexp2.dats $(M)/pats_staexp2_scst.dats $(M)/pats_dynexp2_dcst.dats $(M)/pats_dynexp2_dvar.dats $(M)/pats_dynexp2.sats $(M)/pats_dynexp2_gen.hats
D2HATS=d2case_pre.hats d2common1.hats d2common2.hats d2compat_hand.hats d2compat_hand2.hats d2compat_hand3.hats d2compat_gen.hats $(M)/mylibies.hats
D2CHUNKS=$(sort $(wildcard d2case_[0-9][0-9].dats))
D2COBJS=$(patsubst d2case_%.dats,$(1)/d2case_%.o,$(D2CHUNKS))

d2gen.stamp: $(D2GENFILES)
	python3 d2_gen.py
	@touch $@
.PHONY: d2gen d2dump d2dump_exe d2dump_asan d2dump_asan_exe d2dump1 d2compare d2test d2cover
d2gen: d2gen.stamp

define D2RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(M)/pats_staexp2_gen.hats $(M)/pats_staexp2_gen_dats.hats $(M)/pats_staexp2_error_gen.hats $(M)/pats_staexp2_error_gen_dats.hats $(M)/pats_dynexp2_gen.hats $(M)/pats_dynexp2_gen_dats.hats))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/d2case_%.o: d2case_%.dats d2gen.stamp $(D2HATS) d2cases_%.hats $(D2TMPL)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/d2dump.o: d2dump.dats d2gen.stamp $(D2HATS) s2env2.hats d2chunks.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
# the .hats files that the modules include
$(foreach d,d2obj_asan d2obj_cov,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,d2obj_asan d2obj_cov,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(eval $(call D2RULES,d2obj,))
$(eval $(call D2RULES,d2obj_asan,-g -fsanitize=address))
$(eval $(call D2RULES,d2obj_cov,-g --coverage))
d2dump: d2gen.stamp
	$(MAKE) --no-print-directory d2dump_exe
d2dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(D2MODS))) d2obj/pats_error_sats.o d2obj/d2dump.o $(call D2COBJS,d2obj)
	$(PATSCCA) -o d2dump $^ -lgmp
d2dump_asan: d2gen.stamp
	$(MAKE) --no-print-directory d2dump_asan_exe
d2dump_asan_exe: $(addprefix d2obj_asan/,$(addsuffix _dats.o,$(D2MODS))) d2obj_asan/pats_error_sats.o d2obj_asan/d2dump.o $(call D2COBJS,d2obj_asan)
	$(PATSCCA) -g -fsanitize=address -o d2dump_asan $^ -lgmp
d2dump1: d2gen.stamp
	sh d2dump1.sh
d2compare: d2dump d2dump1
	sh d2cmp.sh
# the generated encodings of pats_dynexp2.spec (src/Makefile)
$(M)/pats_dynexp2_gen.hats $(M)/pats_dynexp2_gen_dats.hats:
	$(MAKE) -C $(M) $(notdir $@)

# the test of the level 2 dynamic without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built d2dump1 (d2dump.md5)
d2test: d2dump
	@a=`./d2dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./d2dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 d2dump.md5 | cut -d' ' -f1,2`" && echo "d2dump: output as expected"
# the coverage of the constructors and the functions by the generated cases
d2cover: d2gen
	python3 d2cover.py
all: d2test

# ---------------------------------------------------------------------------------------------
# Tools: pats_comarg, pats_depgen, pats_taggen, pats_jsonize (see PORTING.md, "Tools (comarg, depgen, taggen, jsonize)")
#
# comdump ARGS...: the command line loop of pats_main.dats (comarglst_parse, the options, -DATS/-IATS) up to the state; run it as
#   `exec -a patsopt ./comdump ARGS...`. tooldump LIST [START]: lines "KIND<TAB>path" (DEPsta/DEPdyn: --depgen, TAGsta/TAGdyn: --taggen,
#   JSNsta/JSNdyn: the JSON of the level-0 tree (jzdump.hats, generated by jsondump_gen.py), API: the functions of pats_jsonize).
#   comdump1 and tooldump1 are the same drivers for the ATS1 objects of $ATS1REF (comdump1.sh). `make toolfiles|comtable|toolasan`.
TOOLMODS=$(D1MODS) pats_intinf pats_counter pats_stamp pats_jsonize pats_depgen pats_taggen pats_comarg
define TOOLRULES
$(if $(2),$(call MODRULE,$(1),$(2),))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/comdump.o: comdump.dats toolmods.hats comdump.cats tooldump.cats pardump.cats $(M)/pats_jsonize.dats $(M)/pats_parsing.dats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ comdump.dats
$(1)/tooldump.o: tooldump.dats toolmods.hats tooldump.cats pardump.cats jzdump.hats tooldump_api.hats $(M)/pats_jsonize.dats $(M)/pats_parsing.dats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ tooldump.dats
endef
TOOLOBJS=$(addprefix $(or $(2),$(1))/,$(addsuffix _dats.o,$(TOOLMODS))) $(1)/pats_error_sats.o
$(eval $(call TOOLRULES,tobj,))
$(eval $(call TOOLRULES,tobj_asan,-g -fsanitize=address))
comdump: $(call TOOLOBJS,tobj,$(MODOBJ)) tobj/comdump.o
	$(PATSCCA) -o $@ $^ -lgmp
tooldump: $(call TOOLOBJS,tobj,$(MODOBJ)) tobj/tooldump.o
	$(PATSCCA) -o $@ $^ -lgmp
comdump_asan: $(call TOOLOBJS,tobj_asan) tobj_asan/comdump.o
	$(PATSCCA) -g -fsanitize=address -o $@ $^ -lgmp
tooldump_asan: $(call TOOLOBJS,tobj_asan) tobj_asan/tooldump.o
	$(PATSCCA) -g -fsanitize=address -o $@ $^ -lgmp
comdump1: comdump1.dats toolmods1.hats comdump.cats tooldump.cats pardump.cats
	sh comdump1.sh comdump1 > /dev/null
tooldump1: tooldump1.dats toolmods1.hats tooldump.cats pardump.cats jzdump1.hats tooldump_api.hats
	sh comdump1.sh tooldump1 > /dev/null
# whole files (toolfiles.sh) and the table of command lines (com_table.py, com_run.py)
toolfiles: tooldump tooldump1
	sh toolfiles.sh
comtable: comdump comdump1 comtable.txt
	python3 com_run.py comtable.txt ./comdump1 ./comdump
.PHONY: toolfiles comtable
# the checks that need no ATS1 (the md5sums are those of the output of the ATS1 drivers; toolcases.md5: line 1 toolcases/ (toolcases.sh), line 2 comtable.txt)
all: tooltest
tooltest: tooldump comdump
	@test "`sh toolcases.sh ./tooldump`" = "`sed -n 1p toolcases.md5`" && echo "toolcases: output as expected"
	@test "`python3 com_run.py comtable.txt - ./comdump`" = "`sed -n 2p toolcases.md5`" && echo "comtable: output as expected"
toolclean:
	$(RM) tooldump comdump tooldump1 comdump1 tooldump_asan comdump_asan
	$(RM) -r tobj tobj_asan
.PHONY: tooltest toolclean
# regenerate the JSON-izer of the level-0 tree (jzdump.hats, jzdump1.hats) from ../pats_syntax.spec
jsongen:
	python3 jsondump_gen.py
.PHONY: jsongen
# the AddressSanitizer builds (leak detection on) against the ATS1 references: no difference means no error and no leak report
toolasan: tooldump_asan comdump_asan tooldump1 comdump1
	python3 com_run.py comtable.txt ./comdump1 ./comdump_asan
	TOOLDUMP=./tooldump_asan sh toolfiles.sh
.PHONY: toolasan

# ---------------------------------------------------------------------------------------------
# The linear constraint solver (pats_lintprgm*): everything is in lp/ (Makefile, drivers, generator)
# make lptest: the ATS2 drivers against lp/lp_small.md5 (the md5 of the ATS1 output); make -C lp compare|asan|cover|mutate|bench
all: lptest
lptest:
	$(MAKE) -C lp test
.PHONY: lptest

# ---------------------------------------------------------------------------------------------
# The typerase trees pats_histaexp*: everything is in hs/ (Makefile, drivers, generator)
# make hstest: the ATS2 driver against hs/hs_small.md5 (the md5 of the output of the ATS1 driver); make -C hs compare|cover|mutate|asan
all: hstest
hstest:
	$(MAKE) -C hs test
.PHONY: hstest

# ---------------------------------------------------------------------------------------------
# Macros (pats_dmacro2, _eval0, _eval1, _print, pats_trans3_error): see PORTING.md, "Macros (dmacro2)"
#
# m2dump runs the scenarios generated by m2_gen.py (m2_cases.py): macros in long and short form, the evaluator of the code level (eval0) and of
# the quoted level (eval1), the environments, the printers, dumped completely (d2compat_gen.hats, m2compat_hand.hats). m2dump1 is the same
# program for the ATS1 build of $ATS1REF (m2dump1.sh); `make m2compare` diffs the two outputs. The cases are generated, not kept in git.
# pats_staexp2_util2/util3/solve, pats_stacst2 are real here; the functions of trans2_env/trans3_env that they call are test doubles (m2env2.hats, m2env1.hats).
M2MODS=$(D2MODS) pats_trans3_error pats_dmacro2 pats_dmacro2_eval0 pats_dmacro2_eval1 pats_dmacro2_print
M2GENFILES=m2_gen.py m2_cases.py d2_gen.py d2_cases.py $(M)/pats_staexp2.spec $(M)/pats_dynexp2.spec
M2TMPL=$(D2TMPL) $(M)/pats_dmacro2_eval1.dats $(M)/pats_dmacro2.sats $(M)/pats_dmacro2_gen.hats $(M)/pats_trans3.sats $(M)/pats_trans3_gen.hats
M2HATS=m2case_pre.hats m2compat_hand.hats m2common.hats $(D2HATS)
M2CHUNKS=$(sort $(wildcard m2case_[0-9][0-9].dats))
M2COBJS=$(patsubst m2case_%.dats,$(1)/m2case_%.o,$(M2CHUNKS))

m2gen.stamp: $(M2GENFILES)
	python3 m2_gen.py
	@touch $@
.PHONY: m2gen m2dump m2dump_exe m2dump_asan m2dump_asan_exe m2dump1 m2compare m2test m2cover
m2gen: m2gen.stamp

define M2RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(M)/pats_staexp2_gen.hats $(M)/pats_staexp2_gen_dats.hats $(M)/pats_staexp2_error_gen.hats $(M)/pats_staexp2_error_gen_dats.hats $(M)/pats_dynexp2_gen.hats $(M)/pats_dynexp2_gen_dats.hats $(M)/pats_dmacro2_gen.hats $(M)/pats_dmacro2_gen_dats.hats $(M)/pats_trans3_gen.hats $(M)/pats_trans3_gen_dats.hats))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/m2case_%.o: m2case_%.dats m2gen.stamp $(M2HATS) m2cases_%.hats $(M2TMPL)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/m2dump.o: m2dump.dats m2gen.stamp $(M2HATS) m2env2.hats m2chunks.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
# the .hats files that the modules include
$(foreach d,m2obj_asan m2obj_cov,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,m2obj_asan m2obj_cov,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,m2obj_asan m2obj_cov,$(eval $(d)/pats_dmacro2_eval0_dats.o: $(M)/pats_syntax_token.hats))
$(eval $(call M2RULES,m2obj,))
$(eval $(call M2RULES,m2obj_asan,-g -fsanitize=address))
$(eval $(call M2RULES,m2obj_cov,-g --gline --coverage))
m2dump: m2gen.stamp
	$(MAKE) --no-print-directory m2dump_exe
m2dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(M2MODS))) m2obj/pats_error_sats.o m2obj/m2dump.o $(call M2COBJS,m2obj)
	$(PATSCCA) -o m2dump $^ -lgmp
m2dump_asan: m2gen.stamp
	$(MAKE) --no-print-directory m2dump_asan_exe
m2dump_asan_exe: $(addprefix m2obj_asan/,$(addsuffix _dats.o,$(M2MODS))) m2obj_asan/pats_error_sats.o m2obj_asan/m2dump.o $(call M2COBJS,m2obj_asan)
	$(PATSCCA) -g -fsanitize=address -o m2dump_asan $^ -lgmp
m2dump1: m2gen.stamp
	sh m2dump1.sh
m2compare: m2dump m2dump1
	sh m2cmp.sh
# the generated encodings of pats_dmacro2.spec and pats_trans3.spec (src/Makefile)
$(M)/pats_dmacro2_gen.hats $(M)/pats_dmacro2_gen_dats.hats $(M)/pats_trans3_gen.hats $(M)/pats_trans3_gen_dats.hats:
	$(MAKE) -C $(M) $(notdir $@)

# the test of the macro evaluator without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built m2dump1 (m2dump.md5)
m2test: m2dump
	@a=`./m2dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./m2dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 m2dump.md5 | cut -d' ' -f1,2`" && echo "m2dump: output as expected"
	@sh m2exit.sh md5
# the coverage of the constructors and the functions by the generated cases
m2cover: m2gen
	python3 m2cover.py
all: m2test
# the coverage build (gcov by ATS line: patscc -g gives #line directives): `make m2cov` runs it and reports the lines of the 5 modules
m2dump_cov: m2gen.stamp
	$(MAKE) --no-print-directory m2dump_cov_exe
m2dump_cov_exe: $(addprefix m2obj_cov/,$(addsuffix _dats.o,$(M2MODS))) m2obj_cov/pats_error_sats.o m2obj_cov/m2dump.o $(call M2COBJS,m2obj_cov)
	$(PATSCCA) -g --coverage -o m2dump_cov $^ -lgmp
m2cov: m2dump_cov
	python3 m2cover.py --gcov
.PHONY: m2dump_cov m2dump_cov_exe m2cov
m2clean:
	$(RM) m2dump m2dump1 m2dump_asan m2dump_cov m2gen.stamp m2case1_[0-9][0-9]_dats.o m2dump1_dats.c
	$(RM) -r m2obj m2obj_asan m2obj_cov
.PHONY: m2clean
# the comparison with the ATS1 build (needs the ATS1 environment of d2dump1.sh): make m2dump m2dump1; make m2compare; sh m2exit.sh; python3 m2mutate.py REF.out REF.err REF.exit

# ---------------------------------------------------------------------------------------------
# Codegen2 and pattern coverage (pats_codegen2*, pats_patcst2, and the temporary pats_stacst2, pats_trans2_env.sats): see PORTING.md,
# "Codegen2" and "Pattern coverage (patcst2)"
#
# cgdump runs the cases generated by cg_gen.py (cg_cases.py): datatypes, abstract records, d2ecls (#codegen2) and patterns, built with
# the wrappers of the level-2 test (d2compat_gen.hats), their results dumped (the generated ATS source, the constraints, the counter-examples).
# cgdump1 is the same program for the ATS1 build of $ATS1REF (cgdump1.sh); `make cgcompare` diffs the two outputs.
# The environment functions of trans2_env (the_s2expenv_find ...) are tables of the driver (cgenv_def.cats), the functions of
# pats_staexp2_util2/util3/solve, pats_stacst2 are real; the recorders of trans3_env that they call are the doubles of cgenv2.hats (cgenv1.hats for ATS1).
CGMODS=$(D2MODS) pats_patcst2 pats_codegen2 pats_codegen2_util pats_codegen2_datype pats_codegen2_fprint pats_codegen2_absrec
CGGENFILES=cg_gen.py cg_cases.py d2_gen.py d2_cases.py $(M)/pats_staexp2.spec $(M)/pats_dynexp2.spec
CGTMPL=$(D2TMPL) $(M)/pats_patcst2.sats $(M)/pats_patcst2_gen.hats $(M)/pats_codegen2.sats $(M)/pats_stacst2.sats $(M)/pats_trans2_env.sats $(M)/pats_trans3_env.sats
CGHATS=cgcase_pre.hats cgcommon.hats cgcompat_hand.hats cgenv.cats $(D2HATS)
CGCHUNKS=$(sort $(wildcard cgcase_[0-9][0-9].dats))
CGCOBJS=$(patsubst cgcase_%.dats,$(1)/cgcase_%.o,$(CGCHUNKS))

cggen.stamp: $(CGGENFILES)
	python3 cg_gen.py
	@touch $@
.PHONY: cggen cgdump cgdump_exe cgdump_asan cgdump_asan_exe cgdump_cov cgdump_cov_exe cgdump1 cgcompare cgtest cgcover
cggen: cggen.stamp

define CGRULES
$(if $(2),$(call MODRULE,$(1),$(2),$(M)/pats_staexp2_gen.hats $(M)/pats_staexp2_gen_dats.hats $(M)/pats_staexp2_error_gen.hats $(M)/pats_staexp2_error_gen_dats.hats $(M)/pats_dynexp2_gen.hats $(M)/pats_dynexp2_gen_dats.hats $(M)/pats_patcst2_gen.hats $(M)/pats_patcst2_gen_dats.hats))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/cgcase_%.o: cgcase_%.dats cggen.stamp $(CGHATS) cgcases_%.hats $(CGTMPL)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/cgdump.o: cgdump.dats cggen.stamp $(CGHATS) cgenv2.hats cgchunks.hats cgenv_def.cats $(CGTMPL)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
$(foreach d,cgobj_asan cgobj_cov,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,cgobj_asan cgobj_cov,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,cgobj_asan cgobj_cov,$(eval $(d)/pats_patcst2_dats.o: $(M)/pats_syntax_token.hats))
$(eval $(call CGRULES,cgobj,))
$(eval $(call CGRULES,cgobj_asan,-g -fsanitize=address))
$(eval $(call CGRULES,cgobj_cov,-g --gline --coverage))
cgdump: cggen.stamp
	$(MAKE) --no-print-directory cgdump_exe
cgdump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(CGMODS))) cgobj/pats_error_sats.o cgobj/cgdump.o $(call CGCOBJS,cgobj)
	$(PATSCCA) -o cgdump $^ -lgmp
cgdump_asan: cggen.stamp
	$(MAKE) --no-print-directory cgdump_asan_exe
cgdump_asan_exe: $(addprefix cgobj_asan/,$(addsuffix _dats.o,$(CGMODS))) cgobj_asan/pats_error_sats.o cgobj_asan/cgdump.o $(call CGCOBJS,cgobj_asan)
	$(PATSCCA) -g -fsanitize=address -o cgdump_asan $^ -lgmp
# the coverage build: the modules with gcov (the ATS lines), the driver and the cases as above (cgcover.py runs it)
cgdump_cov: cggen.stamp
	$(MAKE) --no-print-directory cgdump_cov_exe
cgdump_cov_exe: $(addprefix cgobj_cov/,$(addsuffix _dats.o,$(CGMODS))) cgobj_cov/pats_error_sats.o cgobj/cgdump.o $(call CGCOBJS,cgobj)
	$(PATSCCA) -g --coverage -o cgdump_cov $^ -lgmp
cgdump1: cggen.stamp
	sh cgdump1.sh
cgcompare: cgdump cgdump1
	sh cgcmp.sh

# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built cgdump1 (cgdump.md5)
cgtest: cgdump
	@a=`./cgdump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./cgdump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 cgdump.md5 | cut -d' ' -f1,2`" && echo "cgdump: output as expected"
	@test "`sh cgerr.sh ./cgdump`" = "`sed -n 2p cgdump.md5`" && echo "cgdump errtests: output as expected"
cgcover: cggen
	python3 cgcover.py
all: cgtest

# ---------------------------------------------------------------------------------------------
# Level 3 trees (pats_dynexp3, _print) and the type-checking environment (pats_trans3_env, _dvar, _effect, _lamlp, _lstate, _pfman, _print, _scst,
# _svar, _termet): see PORTING.md, "Level 3 trees (dynexp3)" and "Type-checking environment (trans3_env)"
#
# t3dump runs the cases generated by t3_gen.py (t3_cases.py): random trees of every type of the level-3 syntax and of the constraints, and scenarios
# that call every function of the modules (scopes, linear states, proof manager, metrics, effects, constraints), dumped completely (t3compat_gen.hats).
# t3dump1 is the same program for the ATS1 build of $ATS1REF (t3dump1.sh); `make t3compare` diffs the two outputs. The cases are generated, not kept in git.
# The functions of trans2/trans3 that the environment calls are test doubles (t3hand.tmpl).
T3MODS=$(S2MODS) pats_dynexp1 pats_dynexp1_print pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print \
  pats_dynexp2_util pats_patcst2 pats_trans3_error pats_dynexp3 pats_dynexp3_print pats_trans3_env pats_trans3_env_svar pats_trans3_env_scst \
  pats_trans3_env_termet pats_trans3_env_effect pats_trans3_env_lamlp pats_trans3_env_print pats_trans3_env_pfman pats_trans3_env_dvar pats_trans3_env_lstate
T3GENFILES=t3_gen.py t3_cases.py d2_gen.py d2_cases.py s2_cases2.py t3hand.tmpl t3env.tmpl $(M)/pats_staexp2.spec $(M)/pats_dynexp2.spec $(M)/pats_dynexp3.spec $(M)/pats_trans3_env.spec
T3OWNHATS=$(foreach s,dynexp3 trans3_env trans3_env_effect trans3_env_pfman trans3_env_dvar trans3_env_lstate,$(M)/pats_$(s)_gen.hats $(M)/pats_$(s)_gen_dats.hats)
# the modules of t3g1dump (t3g1.mk; prebuild_t3g1 needs their objects)
T3G1MODS=$(T3MODS) pats_dmacro2 pats_dmacro2_eval0 pats_dmacro2_eval1 pats_dmacro2_print pats_trans3_syncst pats_trans3_util pats_trans3_dynexp_up
T3GENHATS=$(foreach s,staexp2 staexp2_error dynexp2 dmacro2 trans3,$(M)/pats_$(s)_gen.hats $(M)/pats_$(s)_gen_dats.hats) $(T3OWNHATS)
T3HATS=t3case_pre.hats d2common1.hats d2common2.hats d2compat_hand.hats d2compat_hand2.hats d2compat_hand3.hats t3hand_leaf.hats t3hand.hats t3common.hats t3compat_gen.hats $(M)/mylibies.hats
T3CHUNKS=$(sort $(wildcard t3case_[0-9][0-9].dats))
T3COBJS=$(patsubst t3case_%.dats,$(1)/t3case_%.o,$(T3CHUNKS))

t3gen.stamp: $(T3GENFILES)
	python3 t3_gen.py
	@touch $@
.PHONY: t3gen t3dump t3dump_exe t3dump_asan t3dump_asan_exe t3dump_cov t3dump_cov_exe t3dump1 t3compare t3test
t3gen: t3gen.stamp

define T3RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(T3GENHATS)))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/t3case_%.o: t3case_%.dats t3gen.stamp $(T3HATS) t3cases_%.hats $(T3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/t3dump.o: t3dump.dats t3gen.stamp $(T3HATS) t3env.hats t3chunks.hats $(T3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
$(foreach d,t3obj_asan t3obj_cov,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,t3obj_asan t3obj_cov,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,t3obj_asan t3obj_cov,$(eval $(d)/pats_patcst2_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,t3obj_asan t3obj_cov,$(eval $(d)/pats_trans3_env_dats.o: $(M)/pats_trans3_env.hats))
$(eval $(call T3RULES,t3obj,))
$(eval $(call T3RULES,t3obj_asan,-g -fsanitize=address))
$(eval $(call T3RULES,t3obj_cov,-g --gline --coverage))
t3dump: t3gen.stamp
	$(MAKE) --no-print-directory t3dump_exe
t3dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3MODS))) t3obj/pats_error_sats.o t3obj/t3dump.o $(call T3COBJS,t3obj)
	$(PATSCCA) -o t3dump $^ -lgmp
t3dump_asan: t3gen.stamp
	$(MAKE) --no-print-directory t3dump_asan_exe
t3dump_asan_exe: $(addprefix t3obj_asan/,$(addsuffix _dats.o,$(T3MODS))) t3obj_asan/pats_error_sats.o t3obj_asan/t3dump.o $(call T3COBJS,t3obj_asan)
	$(PATSCCA) -g -fsanitize=address -o t3dump_asan $^ -lgmp
t3dump_cov: t3gen.stamp
	$(MAKE) --no-print-directory t3dump_cov_exe
t3dump_cov_exe: $(addprefix t3obj_cov/,$(addsuffix _dats.o,$(T3MODS))) t3obj_cov/pats_error_sats.o t3obj/t3dump.o $(call T3COBJS,t3obj)
	$(PATSCCA) -g --coverage -o t3dump_cov $^ -lgmp
t3dump1: t3gen.stamp
	sh t3dump1.sh
t3compare: t3dump t3dump1
	sh t3cmp.sh
# the generated encodings (src/Makefile)
$(T3OWNHATS):
	$(MAKE) -C $(M) $(notdir $@)

# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built t3dump1 (t3dump.md5)
t3test: t3dump
	@a=`./t3dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./t3dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 t3dump.md5 | cut -d' ' -f1,2`" && echo "t3dump: output as expected"
all: t3test

# ---------------------------------------------------------------------------------------------
# Level 2 translation: pats_trans2*, pats_dyncst2 (see PORTING.md, "Level 2 translation (trans2)")
#
# t2dump LIST [START [time]]: the driver of d1dump extended to the level 2: the_trans2_env_initialize, the_prelude_load (as pats_main.dats does),
#   then for the lines "KIND<TAB>path" (FILEsta/FILEdyn, RAWsta/RAWdyn) the translation up to the d2eclist, which is dumped completely (t2dd.hats,
#   generated by t2_gen.py). t2dump1 is the same driver linked with the ATS1 objects of $ATS1REF (all of them but pats_main). t2files.sh: the whole-file test.
T2MODS=pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_filename pats_location pats_label pats_syntax pats_syntax_print \
  pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf \
  pats_parsing pats_parsing_util pats_parsing_error pats_parsing_kwds pats_parsing_base pats_parsing_e0xp pats_parsing_sort \
  pats_parsing_staexp pats_parsing_p0at pats_parsing_dynexp pats_parsing_decl pats_parsing_toplevel \
  pats_effect pats_fixity_prec pats_fixity_fxty pats_symmap pats_symenv pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print \
  pats_e1xpval pats_e1xpval_error pats_trans1_env pats_trans1_e0xp pats_trans1_error pats_trans1_effect pats_trans1_sort \
  pats_trans1_staexp pats_trans1_p0at pats_trans1_syndef pats_trans1_dynexp pats_trans1_decl pats_filename_reloc \
  pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt \
  pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 \
  pats_stacst2 pats_namespace pats_dynexp2 pats_dyncst2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_print pats_dynexp2_util \
  pats_trans2_env pats_trans2_error pats_trans2_sort pats_trans2_staexp pats_trans2_p1at pats_trans2_dynexp pats_trans2_impdec pats_trans2_decl
T2OBJS=$(addprefix $(or $(2),$(1))/,$(addsuffix _dats.o,$(T2MODS))) $(1)/pats_error_sats.o $(1)/t2dump.o

define T2RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(wildcard $(M)/*.hats)))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/t2dump.o: t2dump.dats t2dump.cats pardump.cats t2dd.hats t2dd_common.hats t2dd_lang2.hats t2dump_tmp.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ t2dump.dats
endef
$(eval $(call T2RULES,t2obj,))
$(eval $(call T2RULES,t2obj_asan,-g -fsanitize=address))
$(eval $(call T2RULES,t2obj_o2,-O2))
t2dump: $(call T2OBJS,t2obj,$(MODOBJ))
	$(PATSCCA) -o $@ $^ -lgmp
t2dump_asan: $(call T2OBJS,t2obj_asan)
	$(PATSCCA) -g -fsanitize=address -o $@ $^ -lgmp
t2dump_o2: $(call T2OBJS,t2obj_o2)
	$(PATSCCA) -O2 -o $@ $^ -lgmp
t2dd.hats t2dd1.hats: t2_gen.py d2_gen.py d2_cases.py ../pats_staexp2.spec ../pats_dynexp2.spec
	python3 t2_gen.py
t2dump1: t2dump1.dats t2dump.cats pardump.cats t2dd1.hats t2dd_common.hats t2dd_lang1.hats
	sh t2dump1.sh
t2files: t2dump t2dump1
	sh t2files.sh

# hand-written cases of the level 2 (t2cases/): the modes FILE and RAW; t2cases.md5 is the md5sum of the ATS1 output with the directory
# made anonymous (make t2test needs no ATS1)
t2list.txt: $(wildcard t2cases/*)
	for m in FILE RAW; do for f in t2cases/*.sats; do printf "%ssta\t$(CURDIR)/%s\n" $$m $$f; done; \
	  for f in t2cases/*.dats t2cases/*.hats; do printf "%sdyn\t$(CURDIR)/%s\n" $$m $$f; done; done > $@
t2test: t2dump t2list.txt
	@sh d1chunk.sh ./t2dump t2list.txt t2.2; \
	test "`cat t2.2.o t2.2.e | sed 's|$(abspath $(M)/..)/||g' | md5sum | awk '{print $$1}'`" = "`head -1 t2cases.md5`" && echo "t2test: output as expected"; r=$$?; rm -f t2.2.o t2.2.e; exit $$r
all: t2test
t2compare: t2dump t2dump1 t2list.txt
	sh d1chunk.sh ./t2dump1 t2list.txt t2.1; sh d1chunk.sh ./t2dump t2list.txt t2.2; \
	cmp t2.1.o t2.2.o && cmp t2.1.e t2.2.e && echo "t2compare: identical"; \
	cat t2.1.o t2.1.e | sed 's|$(abspath $(M)/..)/||g' | md5sum | awk '{print $$1}' > t2cases.md5; rm -f t2.1.o t2.1.e t2.2.o t2.2.e
.PHONY: t2test t2compare t2files t2list.txt

# The erased trees pats_hidynexp* and the type erasure pats_typerase_*: everything is in hd/ (Makefile, drivers, generator)
# make hdtest: the ATS2 driver against hd/hd.md5 (the md5 of the output of the ATS1 driver); make -C hd compare|cover|mutate|asan
all: hdtest
hdtest:
	$(MAKE) -C hd test
.PHONY: hdtest

# ---------------------------------------------------------------------------------------------------------------------
# Level 3 translation, group 1 (pats_trans3_syncst, _util, _dynexp_up): see PORTING.md, "Level 3 translation, group 1 (dynexp_up/util/syncst)".
# t3g1stub.hats holds the ATS2 test doubles of the functions of the other groups. `make t3g1` runs the ATS2 build and compares its output with the md5 sums of
# the ATS1 build (t3g1dump.md5); `make t3g1cmp SRC=<src/ of the ATS1 build>` (ATS1 environment as for t3dump1.sh) compares with the ATS1 build itself;
# `make t3g1mut` is the mutation test (needs the ATS1 output t3g1.out1/t3g1.err1 of t3g1cmp), `make t3g1cov` the line coverage.
.PHONY: t3g1 t3g1cmp t3g1mut t3g1cov t3g1asan
t3g1:
	$(MAKE) -f t3g1.mk t3g1test
t3g1cmp:
	$(MAKE) -f t3g1.mk t3g1compare SRC=$(or $(ATS1REF),$(SRC))
T3G1FARM?=/tmp/t3g1farm
t3g1mut:
	sh linkfarm.sh $(T3G1FARM) && cp t3g1.out1 t3g1.err1 $(T3G1FARM)/test/ && cd $(T3G1FARM)/test && python3 t3g1mutate.py $$PWD/t3g1.out1 $$PWD/t3g1.err1
t3g1cov:
	sh t3g1gcov.sh
t3g1asan:
	$(MAKE) -f t3g1.mk t3g1dump_asan && ./t3g1dump_asan > t3g1.asan.out 2> t3g1.asan.err; echo "exit $$?"; grep -c "ERROR: \(Address\|Leak\)Sanitizer" t3g1.asan.err; cmp t3g1.asan.out t3g1.out2
all: t3g1

# ---------------------------------------------------------------------------------------------
# Level 3 translation, group 2 (pats_trans3_dynexp_dn, _appsym, _caseof, _patcon): see PORTING.md, "Level 3 translation, group 2".
#
# g2dump runs the cases generated by g2_gen.py (g2_cases.py): directed d2exp trees, overloaded symbols, constructor patterns and pattern matrices run through
# d2exp_trdn / p2at_trdn_con / d2exp_trup_applst_sym / c2laulst_trdn in an environment (trans3_env, linear variables, effects), dumped completely. The functions
# of the other groups of the trans3 port that these modules call are test doubles that print their calls (g2env.tmpl). g2dump1 (g2dump1.sh) is the same program
# for the ATS1 build of $ATS1REF (the four modules included: SRC= the main tree's src); `make g2compare` diffs the two outputs.
# g2dump is built by g2build.sh in test/obj (objects of the modules compiled from src/).
.PHONY: g2gen g2dump g2dump1 g2compare g2test g2cover g2mutate
g2gen:
	python3 g2_gen.py
g2dump:
	sh g2build.sh
g2dump1: g2gen
	sh g2dump1.sh
g2compare: g2dump g2dump1
	sh g2cmp.sh
# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built g2dump1 and its exit status (g2dump.md5)
g2test: g2dump
	@a=`./g2dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./g2dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 g2dump.md5 | cut -d' ' -f1,2`" && echo "g2dump: output as expected"
g2cover:
	sh g2gcov.sh
G2FARM?=/tmp/g2farm
g2mutate: g2dump
	@G2STAGE=$(G2FARM) sh g2build.sh
	@mkdir -p /tmp/g2ref && ./g2dump > /tmp/g2ref/ref.out 2> /tmp/g2ref/ref.err; echo $$? > /tmp/g2ref/ref.rc; \
	CG_ERRTEST=1 ./g2dump > /tmp/g2ref/ref_exit.out 2> /tmp/g2ref/ref_exit.err; echo $$? > /tmp/g2ref/ref_exit.rc
	python3 g2mutate.py $(G2FARM) /tmp/g2ref
all: g2test

# ---------------------------------------------------------------------------------------------------------------------
# Level 3 translation, group 3 (pats_trans3_p2at, _selab, _fldfrat, _lvalres): PORTING.md, "Level 3 translation, group 3 (p2at/selab/fldfrat/lvalres)".
# t3g3dump runs the cases generated by t3g3_gen.py (t3g3_cases.py): patterns and types, labeled selections, fold@/free@, left-value restoration, dumped
# completely; the functions of the other groups that these modules call are test doubles (t3g3env.tmpl). t3g3dump1 is the same program for the ATS1
# build of $(SRC) (t3g3dump1.sh); `make t3g3compare` diffs the two outputs. The cases are generated, not kept in git; `make t3g3test` needs no ATS1.
T3G3MODS=$(T3MODS) pats_trans3_p2at pats_trans3_selab pats_trans3_fldfrat pats_trans3_lvalres
T3G3GENFILES=t3g3_gen.py t3g3_cases.py t3g3hand.tmpl t3g3env.tmpl
T3G3HATS=t3g3case_pre.hats t3g3hand.hats $(T3HATS)
T3G3CHUNKS=$(sort $(wildcard t3g3case_[0-9][0-9].dats))
T3G3COBJS=$(patsubst t3g3case_%.dats,$(1)/t3g3case_%.o,$(T3G3CHUNKS))

t3g3gen.stamp: t3gen.stamp $(T3G3GENFILES)
	python3 t3g3_gen.py
	@touch $@
.PHONY: t3g3gen t3g3dump t3g3dump_exe t3g3dump_asan t3g3dump_asan_exe t3g3dump_cov t3g3dump_cov_exe t3g3dump1 t3g3compare t3g3test
t3g3gen: t3g3gen.stamp

define T3G3RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(T3GENHATS)))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/t3g3case_%.o: t3g3case_%.dats t3g3gen.stamp $(T3G3HATS) t3g3cases_%.hats $(T3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/t3g3dump.o: t3g3dump.dats t3g3gen.stamp $(T3G3HATS) t3env.hats t3g3env.hats t3g3chunks.hats $(T3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
$(foreach d,t3g3obj_asan t3g3obj_cov,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,t3g3obj_asan t3g3obj_cov,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,t3g3obj_asan t3g3obj_cov,$(eval $(d)/pats_patcst2_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,t3g3obj_asan t3g3obj_cov,$(eval $(d)/pats_trans3_env_dats.o: $(M)/pats_trans3_env.hats))
$(foreach d,t3g3obj_asan t3g3obj_cov,$(foreach m,p2at selab,$(eval $(d)/pats_trans3_$(m)_dats.o: $(M)/pats_trans1.hats)))
$(eval $(call T3G3RULES,t3g3obj,))
$(eval $(call T3G3RULES,t3g3obj_asan,-g -fsanitize=address))
$(eval $(call T3G3RULES,t3g3obj_cov,-g --gline --coverage))
t3g3dump: t3g3gen.stamp
	$(MAKE) --no-print-directory t3g3dump_exe
t3g3dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3G3MODS))) t3g3obj/pats_error_sats.o t3g3obj/t3g3dump.o $(call T3G3COBJS,t3g3obj)
	$(PATSCCA) -o t3g3dump $^ -lgmp
t3g3dump_asan: t3g3gen.stamp
	$(MAKE) --no-print-directory t3g3dump_asan_exe
t3g3dump_asan_exe: $(addprefix t3g3obj_asan/,$(addsuffix _dats.o,$(T3G3MODS))) t3g3obj_asan/pats_error_sats.o t3g3obj_asan/t3g3dump.o $(call T3G3COBJS,t3g3obj_asan)
	$(PATSCCA) -g -fsanitize=address -o t3g3dump_asan $^ -lgmp
t3g3dump_cov: t3g3gen.stamp
	$(MAKE) --no-print-directory t3g3dump_cov_exe
t3g3dump_cov_exe: $(addprefix t3g3obj_cov/,$(addsuffix _dats.o,$(T3G3MODS))) t3g3obj_cov/pats_error_sats.o t3g3obj/t3g3dump.o $(call T3G3COBJS,t3g3obj)
	$(PATSCCA) -g --coverage -o t3g3dump_cov $^ -lgmp
t3g3dump1: t3g3gen.stamp
	sh t3g3dump1.sh
t3g3compare: t3g3dump t3g3dump1
	sh t3g3cmp.sh
# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built t3g3dump1 (t3g3dump.md5)
t3g3test: t3g3dump
	@a=`./t3g3dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./t3g3dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 t3g3dump.md5 | cut -d' ' -f1,2`" && echo "t3g3dump: output as expected"
all: t3g3test

# ---------------------------------------------------------------------------------------------
# Group 4 of the trans3 port (pats_trans3_{decl,looping,assgn,deref,ptrof,viewat,xchng}): PORTING.md, "Level 3 translation, group 4".
# g4dump runs the scenarios generated by g4_gen.py (random left-values, addresses, loops, declarations) through the 7 modules; the functions of the
# other groups are test doubles (t3g4/g4env.tmpl). g4dump1 is the same program for the ATS1 build of the main tree (g4dump1.sh, SRC=...);
# `make g4compare` diffs the outputs. The 7 modules are compiled from src/ against the real pats_trans3.sats (the doubles of the other groups are in g4env.hats).
G4MODS=pats_trans3_decl pats_trans3_looping pats_trans3_assgn pats_trans3_deref pats_trans3_ptrof pats_trans3_viewat pats_trans3_xchng
G4GENFILES=g4_gen.py t3g4/g4env.tmpl t3g4/g4pre.tmpl t3_gen.py t3_cases.py d2_gen.py d2_cases.py t3case_pre.hats t3case_pre1.hats
G4HATS=g4case_pre.hats g4hand.hats g4state.h d2common1.hats d2common2.hats d2compat_hand.hats d2compat_hand2.hats d2compat_hand3.hats t3hand_leaf.hats t3hand.hats t3common.hats t3compat_gen.hats g4env.hats $(M)/mylibies.hats
G4CHUNKS=$(sort $(wildcard g4case_[0-9][0-9].dats))
G4COBJS=$(patsubst g4case_%.dats,g4obj/g4case_%.o,$(G4CHUNKS))
.PHONY: g4gen g4dump g4dump_exe g4dump1 g4compare
g4gen.stamp: $(G4GENFILES) t3gen.stamp
	python3 g4_gen.py
	@touch $@
g4gen: g4gen.stamp
g4obj/pats_error_sats.c: $(M)/pats_error.sats
	@mkdir -p g4obj
	cd g4obj && patsopt --output pats_error_sats.c --static $(abspath $(M)/pats_error.sats)
g4obj/pats_error_sats.o: g4obj/pats_error_sats.c
	$(PATSCCA) -c -o $@ $<
g4obj/g4case_%.o: g4case_%.dats g4gen.stamp $(G4HATS) g4cases_%.hats $(T3GENHATS)
	@mkdir -p g4obj
	$(PATSCCA) -I$(abspath .) -c -o $@ $<
g4obj/g4state.o: g4state.c g4state.h
	@mkdir -p g4obj
	$(PATSCCA) -c -o $@ $<
g4obj/g4dump.o: g4dump.dats g4gen.stamp $(G4HATS) g4chunks.hats $(T3GENHATS)
	@mkdir -p g4obj
	$(PATSCCA) -I$(abspath .) -c -o $@ $<
g4dump: g4gen.stamp
	$(MAKE) --no-print-directory g4dump_exe
g4dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3MODS) $(G4MODS))) g4obj/pats_error_sats.o g4obj/g4dump.o g4obj/g4state.o $(G4COBJS)
	$(PATSCCA) -o g4dump $^ -lgmp
g4dump1: g4gen.stamp
	sh g4dump1.sh
g4compare: g4dump g4dump1
	sed 's/t3dump/g4dump/g' t3cmp.sh | sh
# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built g4dump1 (g4dump.md5: G4SEED=1, G4SCALE=3)
g4test: g4dump
	@a=`./g4dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./g4dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 g4dump.md5 | cut -d' ' -f1,2`" && echo "g4dump: output as expected"
all: g4test

# ---------------------------------------------------------------------------------------------------------------------
# Level 3 integration: the whole-file test of the type checker (PORTING.md, "Level 3 integration")
#
# f3dump LIST [START [time]]: the driver of t2dump extended to the level 3 (the_trans3_env_initialize, d2eclist_tr_errck, the_trans3_finget_constraint):
#   for the lines "KIND<TAB>path" (FILEsta/FILEdyn, RAWsta/RAWdyn) the d3eclist and the c3nstr are dumped completely (f3dd.hats, generated by f3_gen.py).
#   f3dump1 is the same driver linked with the ATS1 objects of $(SRC) (all of them but pats_main). f3chunk.sh/f3files.sh: the whole-file test;
#   `make t3filestest` (hand-written cases of t3cases/, the md5 of the ATS1 output in t3cases.md5) needs no ATS1; `make t3filescompare` needs it.
F3MODS=$(T2MODS) pats_staexp2_solve pats_dynexp2_mapgen pats_patcst2 pats_dmacro2 pats_dmacro2_eval0 pats_dmacro2_eval1 pats_dmacro2_print \
  pats_trans3_error pats_dynexp3 pats_dynexp3_print pats_trans3_env pats_trans3_env_svar pats_trans3_env_scst pats_trans3_env_termet pats_trans3_env_effect \
  pats_trans3_env_lamlp pats_trans3_env_print pats_trans3_env_pfman pats_trans3_env_dvar pats_trans3_env_lstate \
  pats_trans3_syncst pats_trans3_util pats_trans3_dynexp_up pats_trans3_dynexp_dn pats_trans3_appsym pats_trans3_caseof pats_trans3_patcon \
  pats_trans3_p2at pats_trans3_selab pats_trans3_fldfrat pats_trans3_lvalres pats_trans3_ptrof pats_trans3_viewat pats_trans3_deref pats_trans3_assgn \
  pats_trans3_xchng pats_trans3_looping pats_trans3_decl
F3OBJS=$(addprefix $(or $(2),$(1))/,$(addsuffix _dats.o,$(F3MODS))) $(1)/pats_error_sats.o $(1)/f3dump.o
F3GEN=f3_gen.py t3_gen.py d2_gen.py d2_cases.py t2_gen.py $(M)/pats_staexp2.spec $(M)/pats_dynexp2.spec $(M)/pats_dynexp3.spec $(M)/pats_trans3_env.spec

define F3RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(wildcard $(M)/*.hats) $(wildcard $(M)/*.sats)))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/f3dump.o: f3dump.dats f3dump.cats pardump.cats f3dd.hats t2dd_common.hats t2dd_lang2.hats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ f3dump.dats
endef
$(eval $(call F3RULES,f3obj,))
$(eval $(call F3RULES,f3obj_asan,-g -fsanitize=address))
$(eval $(call F3RULES,f3obj_o2,-O2))
f3dd.hats f3dd1.hats: $(F3GEN)
	python3 f3_gen.py
f3dump: $(call F3OBJS,f3obj,$(MODOBJ))
	$(PATSCCA) -o $@ $^ -lgmp
f3dump_asan: $(call F3OBJS,f3obj_asan)
	$(PATSCCA) -g -fsanitize=address -o $@ $^ -lgmp
f3dump_o2: $(call F3OBJS,f3obj_o2)
	$(PATSCCA) -O2 -o $@ $^ -lgmp
f3dump1: f3dump1.dats f3dump.cats pardump.cats f3dd1.hats t2dd_common.hats t2dd_lang1.hats
	sh f3dump1.sh
f3files: f3dump f3dump1
	sh f3files.sh
.PHONY: f3files

# hand-written cases of the type checker (t3cases/): the modes FILE and RAW; t3cases.md5 is the md5sum of the ATS1 output with the directory
# made anonymous (`make t3filestest` needs no ATS1; `make t3filescompare` compares with ATS1 and rewrites t3cases.md5)
t3list.txt: $(wildcard t3cases/*)
	for m in FILE RAW; do for f in t3cases/*.sats; do if test -f $$f; then printf "%ssta\t$(CURDIR)/%s\n" $$m $$f; fi; done; \
	  for f in t3cases/*.dats t3cases/*.hats; do if test -f $$f; then printf "%sdyn\t$(CURDIR)/%s\n" $$m $$f; fi; done; done > $@
t3filestest: f3dump t3list.txt
	@sh f3chunk.sh ./f3dump t3list.txt t3.2; \
	test "`cat t3.2.o t3.2.e | sh f3anon.sh $(abspath $(M)/..) | md5sum | awk '{print $$1}'`" = "`head -1 t3cases.md5`" && echo "t3filestest: output as expected"; r=$$?; rm -f t3.2.o t3.2.e; exit $$r
t3filescompare: f3dump f3dump1 t3list.txt
	sh f3chunk.sh ./f3dump1 t3list.txt t3.1; sh f3chunk.sh ./f3dump t3list.txt t3.2; \
	cmp t3.1.o t3.2.o && test "`sh f3norm.sh t3.1.e | md5sum`" = "`sh f3norm.sh t3.2.e | md5sum`" && echo "t3filescompare: identical"; \
	cat t3.1.o t3.1.e | sh f3anon.sh $(abspath $(M)/..) | md5sum | awk '{print $$1}' > t3cases.md5; rm -f t3.1.o t3.1.e t3.2.o t3.2.e
.PHONY: t3filestest t3filescompare t3list.txt
all: t3filestest

# ---------------------------------------------------------------------------------------------------------------------
# The ccomp group C1 (pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}): everything is in cc1/ (Makefile, drivers, generator, doubles)
# make cc1test: the ATS2 driver against cc1/cc1.md5 (the md5 of the output of the ATS1 driver; skipped while the modules of phase 1 of the ccomp port are not in src/);
# make -C cc1 compare|cover|mutate|asan
all: cc1test
cc1test:
	$(MAKE) -C cc1 test
.PHONY: cc1test

# ---------------------------------------------------------------------------------------------
# Constraint solving (pats_constraint3*, with pats_lintprgm*) and level-2 jsonize (pats_jsonize_synent2): PORTING.md, "Constraint solving (constraint3)" and
# "Level-2 jsonize". Two programs, each in ATS2 (this Makefile) and ATS1 (the reference: the objects of $(SRC), c3dump1.sh / j2dump1.sh):
#  * c3dump reads the problems of a data file (c3_gen.py, c3_probs.py: lines of operations of the interpreter of c3_ops.py: static expressions, s3exp, the environment of
#    the solver, constraints, the solver itself, their JSON) and prints the results; the data file of the kind of integers of the solver: c3data_gmp.txt (gmp),
#    c3data_int.txt (intknd: c3dump_int, whose pats_intinf, pats_lintprgm_myint, pats_constraint3_solve are compiled with -DATS C3NSTRINTKND=intknd);
#  * j2dump runs the cases generated by j2_gen.py (j2_cases.py: random level-2 trees of every constructor, as t3dump) and prints the JSON text of their results.
# `make c3compare` / `make j2compare` diff the ATS2 and ATS1 outputs (stdout and stderr, exit status); `make c3test` / `make j2test` need no ATS1 (the md5 sums of
# the output of the ATS1 build: c3dump.md5, j2dump.md5); `make c3cover` (c3gcov.sh), `make c3mutate` / `make j2mutate` (c3mutate.py), `make c3asan`.
C3MODS=$(filter-out pats_lintprgm_solve,$(T3MODS)) pats_jsonize pats_lintprgm pats_lintprgm_print pats_lintprgm_myint pats_constraint3 pats_constraint3_print \
  pats_constraint3_icnstr pats_constraint3_simplify pats_constraint3_solve pats_constraint3_init pats_constraint3_mapgen pats_constraint3_jsonize pats_jsonize_synent2
J2MODS=$(T3MODS) pats_jsonize pats_jsonize_synent2
C3INTMODS=pats_intinf pats_lintprgm_myint pats_constraint3_solve
C3OWNHATS=$(M)/pats_constraint3_gen.hats $(M)/pats_constraint3_gen_dats.hats
C3GENHATS=$(T3GENHATS) $(C3OWNHATS)
C3GENFILES=c3_gen.py c3_ops.py c3_probs.py c3hand.tmpl c3decls.hats c3common0.hats c3common.hats c3common2.hats $(T3GENFILES)
C3HATS=c3case_pre.hats c3glue_gen.hats c3common0.hats c3hand.hats c3reg_gen.hats c3common.hats c3exec_gen.hats c3common2.hats c3setup_gen.hats c3decls.hats \
  t3case_pre.hats d2common1.hats d2common2.hats d2compat_hand.hats d2compat_hand2.hats d2compat_hand3.hats t3hand_leaf.hats t3hand.hats t3common.hats t3compat_gen.hats t3env.hats
J2GENFILES=j2_gen.py j2_cases.py j2hand.tmpl c3_gen.py $(T3GENFILES)
J2HATS=j2case_pre.hats j2hand.hats $(T3HATS)
J2CHUNKS=$(sort $(wildcard j2case_[0-9][0-9].dats))
J2COBJS=$(patsubst j2case_%.dats,$(1)/j2case_%.o,$(J2CHUNKS))
$(C3OWNHATS):
	$(MAKE) -C $(M) $(notdir $@)

c3gen.stamp: $(C3GENFILES)
	python3 c3_gen.py data
	@touch $@
j2gen.stamp: $(J2GENFILES)
	python3 j2_gen.py
	@touch $@
.PHONY: c3gen j2gen c3leak c3dump c3dump_int c3dump_asan c3dump_cov c3dump1 c3dump1_int c3compare c3test c3asan c3cover c3mutate j2dump j2dump_asan j2dump1 j2compare j2test j2asan j2mutate
c3gen: c3gen.stamp
j2gen: j2gen.stamp

define C3RULES
$(if $(2),$(call MODRULE,$(1),$(2),$(C3GENHATS)))
$(1)/pats_error_sats.o: pats_error_sats.c
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/c3dump.o: c3dump.dats c3gen.stamp $(C3HATS) $(C3GENHATS) $(M)/pats_constraint3_icnstr.dats $(M)/pats_lintprgm.dats $(M)/pats_lintprgm_print.dats $(M)/pats_lintprgm_myint.dats
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/c3drv.o: c3drv.c c3drv.h
	@mkdir -p $(1)
	$(PATSCCA) $(2) -c -o $$@ $$<
$(1)/j2case_%.o: j2case_%.dats j2gen.stamp $(J2HATS) j2cases_%.hats $(C3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
$(1)/j2dump.o: j2dump.dats j2gen.stamp $(J2HATS) t3env.hats j2chunks.hats $(C3GENHATS)
	@mkdir -p $(1)
	$(PATSCCA) $(2) -I$(abspath .) -c -o $$@ $$<
endef
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_dynexp2_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_dynexp2_appenv.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_dynexp2_print_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_patcst2_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_jsonize_synent2_dats.o: $(M)/pats_syntax_token.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_trans3_env_dats.o: $(M)/pats_trans3_env.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(eval $(d)/pats_constraint3_mapgen_dats.o: $(M)/pats_staexp2_appenv.hats $(M)/pats_constraint3_appenv.hats))
$(foreach d,c3obj_asan c3obj_cov c3obj_int,$(foreach m,constraint3 constraint3_icnstr constraint3_simplify constraint3_solve constraint3_init,$(eval $(d)/pats_$(m)_dats.o: $(M)/pats_constraint3.hats)))
$(eval $(call C3RULES,c3obj,))
$(eval $(call C3RULES,c3obj_asan,-g -fsanitize=address))
$(eval $(call C3RULES,c3obj_cov,-g --gline --coverage))
# the integer kind of the solver
c3obj_int/%_dats.o: $(M)/%.dats $(C3GENHATS)
	@mkdir -p c3obj_int
	cd c3obj_int && $(PATSCCA) -DATS C3NSTRINTKND=intknd -c -o $(notdir $@) $(abspath $<)
c3obj_int/c3dump.o: c3dump.dats c3gen.stamp $(C3HATS) $(C3GENHATS) $(M)/pats_constraint3_icnstr.dats $(M)/pats_lintprgm.dats $(M)/pats_lintprgm_print.dats $(M)/pats_lintprgm_myint.dats
	@mkdir -p c3obj_int $(M)/cc_tmp_c3dump_int
	cd $(M)/cc_tmp_c3dump_int && $(PATSCCA) -DATS C3NSTRINTKND=intknd -I$(abspath .) -IATS $(abspath .) -c -o $(abspath $@) ../test/c3dump.dats
$(foreach d,c3obj_int,$(eval $(d)/pats_error_sats.o: pats_error_sats.c))
c3obj_int/pats_error_sats.o c3obj_int/c3drv.o: c3obj_int/%.o: %.c
	@mkdir -p c3obj_int
	$(PATSCCA) -c -o $@ $<
c3obj_int/c3drv.o: c3drv.h
# the c3dump variants: gmp, int
C3NOTINT=$(filter-out $(C3INTMODS),$(C3MODS))
c3dump: c3gen.stamp
	$(MAKE) --no-print-directory c3dump_exe
c3dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(C3MODS))) c3obj/pats_error_sats.o c3obj/c3drv.o c3obj/c3dump.o
	$(PATSCCA) -o c3dump $^ -lgmp
c3dump_int: c3gen.stamp
	$(MAKE) --no-print-directory c3dump_int_exe
c3dump_int_exe: $(addprefix c3obj_int/,$(addsuffix _dats.o,$(C3INTMODS))) $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(C3NOTINT))) c3obj/pats_error_sats.o c3obj/c3drv.o c3obj_int/c3dump.o
	$(PATSCCA) -o c3dump_int $^ -lgmp
c3dump_asan: c3gen.stamp
	$(MAKE) --no-print-directory c3dump_asan_exe
c3dump_asan_exe: $(addprefix c3obj_asan/,$(addsuffix _dats.o,$(C3MODS))) c3obj_asan/pats_error_sats.o c3obj_asan/c3drv.o c3obj_asan/c3dump.o
	$(PATSCCA) -g -fsanitize=address -o c3dump_asan $^ -lgmp
c3dump1: c3gen.stamp
	sh c3dump1.sh
c3dump1_int: c3gen.stamp
	C3KND=int OUT=c3dump1_int sh c3dump1.sh
c3compare: c3dump c3dump_int c3dump1 c3dump1_int
	sh c3cmp.sh
# the test without ATS1: the md5 sums of the stdout and the stderr of the ATS1-built c3dump1 (line 1: gmp, line 2: int; c3dump.md5)
# (the problems that end in an exception leave the linear values that are alive unfreed, by design: the md5 runs are made without the leak check of a
# sanitized build, and c3leak checks the leaks on the problems that do not end in an exception)
C3NOLEAK=ASAN_OPTIONS="$${ASAN_OPTIONS:+$$ASAN_OPTIONS:}detect_leaks=0"
c3test: c3dump c3dump_int
	@a=`$(C3NOLEAK) ./c3dump c3data_gmp.txt 2>/dev/null | md5sum | awk '{print $$1}'`; b=`$(C3NOLEAK) ./c3dump c3data_gmp.txt 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	c=`$(C3NOLEAK) ./c3dump_int c3data_int.txt 2>/dev/null | md5sum | awk '{print $$1}'`; e=`$(C3NOLEAK) ./c3dump_int c3data_int.txt 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b $$c $$e" = "`head -1 c3dump.md5`" && echo "c3dump: output as expected"
c3data_noexn.txt: c3data_gmp.txt c3dump c3noexn.py
	$(C3NOLEAK) python3 c3noexn.py ./c3dump c3data_gmp.txt $@
c3data_int_noexn.txt: c3data_int.txt c3dump_int c3noexn.py
	$(C3NOLEAK) python3 c3noexn.py ./c3dump_int c3data_int.txt $@
# the leak check of c3dump and c3dump_int when they are built with -fsanitize=address (PATSCCOMP), on the problems that do not end in an exception
c3leak: c3dump c3dump_int c3data_noexn.txt c3data_int_noexn.txt
	@./c3dump c3data_noexn.txt > /dev/null 2> c3leak.err || { tail -40 c3leak.err; exit 1; }
	@./c3dump_int c3data_int_noexn.txt > /dev/null 2> c3leak.err || { tail -40 c3leak.err; exit 1; }
	@echo "c3leak: no leak (or not a sanitized build)"
c3asan: c3dump_asan c3data_noexn.txt
	LSAN_OPTIONS=suppressions=$(abspath c3lsan.supp) ./c3dump_asan c3data_noexn.txt > /dev/null 2> c3asan.err; echo "exit $$?"; grep -c "ERROR: \(Address\|Leak\)Sanitizer" c3asan.err; true
	@LSAN_OPTIONS=detect_leaks=0 ./c3dump_asan c3data_gmp.txt > /dev/null 2> c3asan_all.err; echo "all the problems, without the leak check: exit $$?"; grep -c "ERROR: AddressSanitizer" c3asan_all.err; true
c3cover: c3gen.stamp c3dump j2dump
	C3MODS="$(C3MODS)" J2MODS="$(J2MODS)" sh c3gcov.sh
c3mutate: c3dump
	python3 c3mutate.py c3
all: c3test

# the level-2 jsonize
j2dump: j2gen.stamp
	$(MAKE) --no-print-directory j2dump_exe
j2dump_exe: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(J2MODS))) c3obj/pats_error_sats.o c3obj/j2dump.o $(call J2COBJS,c3obj)
	$(PATSCCA) -o j2dump $^ -lgmp
j2dump_asan: j2gen.stamp
	$(MAKE) --no-print-directory j2dump_asan_exe
j2dump_asan_exe: $(addprefix c3obj_asan/,$(addsuffix _dats.o,$(J2MODS))) c3obj_asan/pats_error_sats.o c3obj_asan/j2dump.o $(call J2COBJS,c3obj_asan)
	$(PATSCCA) -g -fsanitize=address -o j2dump_asan $^ -lgmp
j2dump1: j2gen.stamp
	sh j2dump1.sh
j2compare: j2dump j2dump1
	sh j2cmp.sh
j2test: j2dump
	@a=`./j2dump 2>/dev/null | md5sum | awk '{print $$1}'`; b=`./j2dump 2>&1 >/dev/null | md5sum | awk '{print $$1}'`; \
	test "$$a $$b" = "`head -1 j2dump.md5 | cut -d' ' -f1,2`" && echo "j2dump: output as expected"
j2asan: j2dump_asan
	./j2dump_asan > /dev/null 2> j2asan.err; echo "exit $$?"; grep -c "ERROR: \(Address\|Leak\)Sanitizer" j2asan.err; true
j2mutate: j2dump
	python3 c3mutate.py j2
all: j2test

# The core modules of ccomp (pats_ccomp.dats, pats_ccomp_{tmplab,tmpvar,funlab,funent,d2env,instrseq,util,print}.dats): everything is in cc/ (Makefile, drivers, generator; it reuses hd/)
# make cctest: the ATS2 driver against cc/cc.md5 (the md5 of the output of the ATS1 driver); make -C cc compare|cover|mutate|asan
all: cctest
cctest:
	$(MAKE) -C cc test
.PHONY: cctest

# ---------------------------------------------------------------------------------------------------------------------
# The C emitter pats_ccomp_emit{,2,3}.dats (ccomp group A): everything is in ca/ (Makefile, drivers, generator, test doubles)
# make catest: the ATS2 driver against ca/ca.md5 (the md5 of the output of the ATS1 driver); make -C ca compare|cover|mutate|asan
all: catest
catest:
	$(MAKE) -C ca test
.PHONY: catest

# ---------------------------------------------------------------------------------------------------------------------
# ccomp group C2 (pats_ccomp_dynexp, _decl, _claulst): everything is in cc2/ (Makefile, drivers, generator, doubles); see PORTING.md, "ccomp group C2".
# make cc2test: the ATS2 driver against cc2/cc2.md5 (the md5 of the output of the ATS1 driver); make -C cc2 compare|cover|mutate|asan
all: cc2test
cc2test:
	$(MAKE) -C cc2 test
.PHONY: cc2test

# ---------------------------------------------------------------------------------------------------------------------
# ccomp group B (pats_ccomp_{hitype,hipat,subst,template,main}): everything is in ccb/ (Makefile, drivers, generator)
# make ccbtest: the ATS2 driver against ccb/ccb.md5 (the md5 of the output of the ATS1 driver); make -C ccb compare|cover|mutate|asan
all: ccbtest
ccbtest:
	$(MAKE) -C ccb test
.PHONY: ccbtest

# ---------------------------------------------------------------------------------------------
# The driver and patsopt (PORTING.md, "Driver and ccomp integration"). All need the ATS1-built reference compiler:
#   SRC=<main tree>/src make drvfiles      # every .sats/.dats/.hats of the repository: C code, stderr, status vs ../patsopt
#   SRC=... make drvopt                    # the option table comtable.txt and drvtable.txt (real programs, -o, stdin, -IATS, -DATS)
#   SRC=... sh drvcc.sh /abs/path/X.dats   # compile with patscc (PATSOPT=ref / patsopt), run both, compare
drvfiles:
	sh drvfiles.sh
drvopt:
	python3 -I drvopt.py comtable.txt
	python3 -I drvopt.py drvtable.txt
.PHONY: drvfiles drvopt

# ---------------------------------------------------------------------------------------------------------------------------------
# The objects of the compiler modules that all the suites share (see MODOBJ above): one compilation of each module with the default options,
# in its own directory ($(MODOBJ), whose C files do not collide with those of the other directories). Its prerequisites are those of all the
# suites: the arena encodings and the generated headers, and every header of $(M) (a pattern rule has no list of modules).
MODDEPS=$(sort $(T3GENHATS) $(C3GENHATS) $(M)/pats_patcst2_gen.hats $(M)/pats_patcst2_gen_dats.hats $(wildcard $(M)/*.hats $(M)/*.sats))
$(MODOBJ)/%_dats.o: $(M)/%.dats $(MODDEPS)
	@mkdir -p $(MODOBJ)
	cd $(MODOBJ) && $(PATSCCA) -c -o $(notdir $@) $(abspath $<)
# the value of a variable (the scripts that link the module objects with their own options: s2gcov.sh, t3g1gcov.sh)
echovar:
	@echo $($(VAR))
.PHONY: echovar

# ---------------------------------------------------------------------------------------------------------------------------------
# The prebuild step of `all` (see the top of this file): phase 1 `pregen` (serial), phase 2 `preexes` (make -j$(JOBS), PREBUILD=1).
# Everything that the runs of `all` need is built here, by the rules of the suites themselves, so the serial part finds it up to date
# (the *_exe targets are phony and are only relinked). The suites that have a Makefile of their own build in a staging directory, with their
# own parallel compilations (JOBS): hd cc ca cc2 ccb cc1 lp hs are built here (see the end of this file); t3g1 and
# g2 are built from here.
PREGEN=s2gen.stamp d2gen.stamp m2gen.stamp cggen.stamp t3gen.stamp t3g3gen.stamp g4gen.stamp c3gen.stamp j2gen.stamp \
  t2dd.hats f3dd.hats deepdump_t1.hats treecases.hats pats_error_sats.c $(sort $(T3GENHATS) $(C3OWNHATS))
pregen: $(PREGEN)
	$(MAKE) --no-print-directory -f t3g1.mk t3g1gen.stamp
	python3 g2_gen.py
PREEXES=$(TESTS) pardump e1xdump treedump d1dump t2dump f3dump tooldump comdump \
  s2dump_exe d2dump_exe m2dump_exe cgdump_exe t3dump_exe t3g3dump_exe g4dump_exe c3dump_exe c3dump_int_exe j2dump_exe \
  prebuild_t3g1 prebuild_g2
# The module objects of $(MODOBJ) are made by this make, once each, before the recursive makes and g2build.sh link them: they must not compile
# the same module in the same directory as this make does at the same time.
prebuild_t3g1: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(T3G1MODS)))
	$(MAKE) --no-print-directory -f t3g1.mk t3g1dump
prebuild_g2: $(addprefix $(MODOBJ)/,$(addsuffix _dats.o,$(shell cat g2mods.txt)))
	sh g2build.sh
.PHONY: prebuild_t3g1 prebuild_g2

# ---------------------------------------------------------------------------------------------------------------------------------
# The sub-suites that have a Makefile of their own and build in a staging directory (hd cc ca cc2 ccb cc1) are built here too, so that the serial part of `all`
# (`make -C X test`) only runs the drivers and compares the md5 sums. Each of them has `gen` (the python generators; they write files that suites share: hd's
# generated files are used by cc, ...) and `build` (the staging copy of src, the ~80 modules and the chunks of cases, the link; in parallel inside, JOBS).
#  * subgen (serial, part of pregen): the arena encodings of src that their scripts ask `make -C src` for (once, so that the scripts only find them up to date),
#    and the `gen` of each suite;
#  * prebuild_SUITE (part of preexes, parallel): `make -C SUITE build1` (the build without the generators). The six builds are chained one after the other (each one runs JOBS compilations by itself;
#    they are not run at the same time, so that JOBS compilations at most are added to the others of preexes), and run beside the other programs of preexes.
# SUBS_PREBUILT tells the sub-Makefiles that the program is built: it is set only for `make all` with the prebuild step (JOBS>1); `make -C X test` alone builds it.
SUBSUITES=hd cc ca cc2 ccb cc1 lp hs
SUBHATS=pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
  pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats \
  pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats \
  pats_ccomp_gen.hats pats_ccomp_gen_dats.hats pats_ccomp_claulst_gen.hats pats_ccomp_claulst_gen_dats.hats
ifneq ($(JOBS),1)
ifneq ($(filter all,$(MAKECMDGOALS))$(if $(MAKECMDGOALS),,x),)
export SUBS_PREBUILT=1
endif
endif
SUBEXES=$(addprefix prebuild_,$(SUBSUITES))
subgen:
	$(MAKE) --no-print-directory -j$(JOBS) -C $(M) $(SUBHATS)
	for d in $(SUBSUITES); do $(MAKE) --no-print-directory -C $$d gen || exit 1; done
pregen: subgen
# the chain of the sub-suites is the longest part of preexes: it comes first, so that make -j starts it at once
preexes: $(SUBEXES) $(PREEXES)
$(SUBEXES): prebuild_%:
	$(MAKE) --no-print-directory -C $* build1
prebuild_cc: | prebuild_hd
prebuild_ca: | prebuild_cc
prebuild_cc2: | prebuild_ca
prebuild_ccb: | prebuild_cc2
prebuild_cc1: | prebuild_ccb
prebuild_lp: | prebuild_cc1
prebuild_hs: | prebuild_lp
.PHONY: subgen $(SUBEXES)
