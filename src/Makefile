#
# src/Makefile: build, typecheck and test the compiler patsopt (ATS2 sources, no GC; the old ATS1 sources are gone).
#
#   all          builds ./patsopt and ./libatsopt.a with the stage-0 compiler $(PATSOPT)       (make -j N helps)
#   check        typecheck every .sats/.dats of the compiler (needs only $(PATSOPT))
#   test         check + the unit tests and the md5 suites of test/ (no ATS1; needs bin/patscc: build with Makefile_devl first);
#                the programs of the suites are compiled JOBS at a time (default: nproc; JOBS=1: serial); the runs are always serial, so a -j N is ignored
#   CBOOT        generate the bootstrap C bundle src/CBOOT/ (README there)
#   clean, cleanall
#
# The first patsopt: any ATS2 compiler works as stage 0:   make -C src PATSOPT=/path/to/patsopt
# or the C bundle:  `make bootstrap` in the root, or make -C src/CBOOT && make -C src     (CBOOT/patsopt is found; see CBOOT/README)
# PATSHOME defaults to the root of this repository (the prelude, share/ and the C run-time are read from there).
# C3NSTRINTKND=intknd builds without gmp.
#
PATSHOME ?= $(abspath $(CURDIR)/..)
export PATSHOME
# Stage 0, in this order: PATSOPT; $(PATSHOME)/bin/patsopt (an earlier build); CBOOT/patsopt (built from the tracked bootstrap
# bundle of this tree: `make bootstrap` at the root, or `make -C CBOOT`); patsopt of the PATH (an installed ATS2).
# The patsopt of the bundle belongs to this tree (it reads this tree's prelude): no STAGE0HOME below.
ifndef PATSOPT
ifneq ($(wildcard $(PATSHOME)/bin/patsopt),)
PATSOPT=$(PATSHOME)/bin/patsopt
else ifneq ($(wildcard $(CURDIR)/CBOOT/patsopt),)
PATSOPT=$(CURDIR)/CBOOT/patsopt
$(info stage 0: PATSOPT=$(PATSOPT) (the bootstrap bundle))
else
PATSOPT:=$(shell command -v patsopt 2>/dev/null)
ifeq ($(PATSOPT),)
$(error no stage-0 patsopt: run `make bootstrap` in the root of the repository (it builds one from the C bundle src/CBOOT with a C compiler only), or give PATSOPT=/path/to/patsopt (any ATS2 compiler, e.g. an installed ats2-postiats))
endif
$(info stage 0: PATSOPT=$(PATSOPT) (from the PATH))
endif
endif
CC ?= gcc
RM ?= rm -f

all: patsopt libatsopt.a
.PHONY: all check test clean cleanall cleanboot checksats checkdats

cleanall:: clean
# the generated bootstrap bundle (CBOOT target)
cleanboot:
	$(RM) -r CBOOT/gen_* CBOOT/obj_* CBOOT/patsopt CBOOT/libatsopt.a

SATS= \
  pats_basics.sats \
  pats_utils.sats \
  pats_intinf.sats \
  pats_counter.sats \
  pats_stamp.sats \
  pats_error.sats \
  pats_symbol.sats \
  pats_filename.sats \
  pats_global.sats \
  pats_location.sats \
  pats_errmsg.sats \
  pats_label.sats \
  pats_fixity.sats \
  pats_symmap.sats \
  pats_symenv.sats \
  pats_syntax_boundary.sats \
  pats_syntax.sats \
  pats_reader.sats \
  pats_lexbuf.sats \
  pats_lexing.sats \
  pats_tokbuf.sats \
  pats_parsing.sats \
  pats_effect.sats \
  pats_staexp1.sats \
  pats_dynexp1.sats \
  pats_trans1_env.sats \
  pats_e1xpval.sats \
  pats_trans1.sats \
  pats_avlmap.sats \
  pats_staexp2.sats \
  pats_staexp2_util.sats \
  pats_staexp2_error.sats \
  pats_stacst2.sats \
  pats_trans2_env.sats \
  pats_trans3_env.sats \
  pats_staexp2_solve.sats \
  pats_namespace.sats

DATS= \
  pats_basics.dats \
  pats_utils.dats \
  pats_global.dats \
  pats_intinf.dats \
  pats_counter.dats \
  pats_stamp.dats \
  pats_error.dats \
  pats_symbol.dats \
  pats_filename.dats \
  pats_location.dats \
  pats_errmsg.dats \
  pats_label.dats \
  pats_fixity_prec.dats \
  pats_fixity_fxty.dats \
  pats_symmap.dats \
  pats_symenv.dats \
  pats_syntax.dats \
  pats_syntax_print.dats \
  pats_reader.dats \
  pats_lexbuf.dats \
  pats_lexing_token.dats \
  pats_lexing.dats \
  pats_lexing_error.dats \
  pats_lexing_print.dats \
  pats_tokbuf.dats \
  pats_parsing_util.dats \
  pats_parsing_error.dats \
  pats_parsing_kwds.dats \
  pats_parsing_base.dats \
  pats_parsing_e0xp.dats \
  pats_parsing_sort.dats \
  pats_parsing_staexp.dats \
  pats_parsing_p0at.dats \
  pats_parsing_dynexp.dats \
  pats_parsing_decl.dats \
  pats_parsing.dats \
  pats_parsing_toplevel.dats \
  pats_effect.dats \
  pats_staexp1.dats \
  pats_staexp1_print.dats \
  pats_dynexp1.dats \
  pats_dynexp1_print.dats \
  pats_trans1_env.dats \
  pats_e1xpval.dats \
  pats_e1xpval_error.dats \
  pats_filename_reloc.dats \
  pats_trans1_e0xp.dats \
  pats_trans1_error.dats \
  pats_trans1_effect.dats \
  pats_trans1_sort.dats \
  pats_trans1_staexp.dats \
  pats_trans1_p0at.dats \
  pats_trans1_syndef.dats \
  pats_trans1_dynexp.dats \
  pats_trans1_decl.dats \
  pats_avlmap.dats \
  pats_staexp2_sort.dats \
  pats_staexp2.dats \
  pats_staexp2_scst.dats \
  pats_staexp2_svar.dats \
  pats_staexp2_svvar.dats \
  pats_staexp2_dcon.dats \
  pats_staexp2_hole.dats \
  pats_staexp2_ctxt.dats \
  pats_staexp2_error.dats \
  pats_staexp2_print.dats \
  pats_staexp2_pprint.dats \
  pats_staexp2_szexp.dats \
  pats_staexp2_skexp.dats \
  pats_staexp2_util1.dats \
  pats_staexp2_util2.dats \
  pats_staexp2_util3.dats \
  pats_stacst2.dats \
  pats_staexp2_solve.dats \
  pats_namespace.dats

# the generated encodings of the level-2 trees are large: not kept in git (src/.gitignore)
GENHATS=pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats
ARENAGEN=python3 ../utils/arenagen/arenagen.py
# a generator that fails (no python3) must not leave an empty, up-to-date-looking target
.DELETE_ON_ERROR:
pats_staexp2_gen.hats: pats_staexp2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_staexp2.spec > $@
pats_staexp2_gen_dats.hats: pats_staexp2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_staexp2.spec > $@
pats_staexp2_error_gen.hats: pats_staexp2_error.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_staexp2_error.spec > $@
pats_staexp2_error_gen_dats.hats: pats_staexp2_error.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_staexp2_error.spec > $@

# JOBS: the number of parallel typechecks (check) and compilations (test); JOBS=1 is the serial run. The typecheck of a file only reads.
JOBS ?= $(shell nproc 2>/dev/null || echo 4)
export JOBS
# TYPECHECK(s or d, files): the typecheck of every file, JOBS at a time (all the files are checked; make fails if one does not pass)
TYPECHECK=printf '%s\n' $(2) | xargs -r -P $(JOBS) -I{} sh -c 'echo "typecheck {}"; $(PATSOPT) --typecheck -$(1) {} >/dev/null'

check:: $(GENHATS) checksats checkdats

checksats:
	@$(call TYPECHECK,s,$(SATS))

checkdats:
	@$(call TYPECHECK,d,$(DATS))

# `make -j N test`: check, then the suites, one after the other (the parallel part is in test/, with JOBS)
ifneq ($(filter test,$(MAKECMDGOALS)),)
.NOTPARALLEL:
endif
test:: check
	PATH="$(PATSHOME)/bin:$$PATH" $(MAKE) -C test all JOBS=$(JOBS)

clean::
	$(RM) *_?ats.c *.o $(GENHATS)
	if [ -d test ]; then $(MAKE) -C test clean; fi

# regenerate the arena encodings (see pats_location.spec)
gen::
	python3 ../utils/arenagen/arenagen.py --global sats pats_label.spec > pats_label_gen.hats
	python3 ../utils/arenagen/arenagen.py --global dats pats_label.spec > pats_label_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_fixity.spec > pats_fixity_gen.hats
	python3 ../utils/arenagen/arenagen.py --global dats pats_fixity.spec > pats_fixity_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_location.spec > pats_location_gen.hats
	python3 ../utils/arenagen/arenagen.py --global dats pats_location.spec > pats_location_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_syntax.spec > pats_syntax_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_syntax.spec > pats_syntax_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_lexing_token.spec > pats_lexing_token_gen.hats
	python3 ../utils/arenagen/arenagen.py --global dats pats_lexing_token.spec > pats_lexing_token_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_staexp1.spec > pats_staexp1_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_staexp1.spec > pats_staexp1_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_dynexp1.spec > pats_dynexp1_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_dynexp1.spec > pats_dynexp1_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_e1xpval.spec > pats_e1xpval_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_e1xpval.spec > pats_e1xpval_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_trans1.spec > pats_trans1_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans1.spec > pats_trans1_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_trans1_env.spec > pats_trans1_env_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_trans1_env.spec > pats_trans1_env_gen_dats.hats

# ---------------------------------------------------------------------------------------------
# Level 2 dynamic (pats_dynexp2*): the generated encodings of the trees (not kept in git) and the typecheck of the modules.
# `make check` also runs these (a second double-colon rule); PORTING.md, "Level 2 dynamic (dynexp2)"
DYN2GENHATS=pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats
DYN2SATS=pats_dynexp2.sats
DYN2DATS=pats_dynexp2.dats pats_dynexp2_dcst.dats pats_dynexp2_dmac.dats pats_dynexp2_dvar.dats pats_dynexp2_mapgen.dats pats_dynexp2_print.dats pats_dynexp2_util.dats
pats_dynexp2_gen.hats: pats_dynexp2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_dynexp2.spec > $@
pats_dynexp2_gen_dats.hats: pats_dynexp2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_dynexp2.spec > $@
check:: $(DYN2GENHATS) checkdyn2
checkdyn2:
	@$(call TYPECHECK,s,$(DYN2SATS))
	@$(call TYPECHECK,d,$(DYN2DATS))
clean::
	$(RM) $(DYN2GENHATS)

# Tools (comarg, depgen, taggen, jsonize): see PORTING.md, "Tools (comarg, depgen, taggen, jsonize)"
SATS += pats_jsonize.sats pats_taggen.sats pats_depgen.sats pats_comarg.sats
DATS += pats_jsonize.dats pats_taggen.dats pats_depgen.dats pats_comarg.dats
gen::
	python3 ../utils/arenagen/arenagen.py --global sats pats_jsonize.spec > pats_jsonize_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_jsonize.spec > pats_jsonize_gen_dats.hats
	python3 ../utils/arenagen/arenagen.py --global sats pats_taggen.spec > pats_taggen_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_taggen.spec > pats_taggen_gen_dats.hats

# the linear constraint solver (src/pats_lintprgm*): the sources are added to the lists above
SATS += pats_lintprgm.sats
DATS += pats_lintprgm.dats pats_lintprgm_print.dats pats_lintprgm_solve.dats pats_lintprgm_myint.dats

# the typerase trees (pats_histaexp*), tested in test/hs (the .dats staload the real pats_stacst2.sats)
SATS += pats_histaexp.sats
DATS += pats_histaexp.dats pats_histaexp_print.dats pats_histaexp_funlab.dats
gen::
	python3 ../utils/arenagen/arenagen.py --global sats pats_histaexp.spec > pats_histaexp_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_histaexp.spec > pats_histaexp_gen_dats.hats

# Macros (pats_dmacro2*, pats_trans3 (partial), pats_trans3_error): the generated encodings (not kept in git) and the typecheck of the modules.
# See PORTING.md, "Macros (dmacro2)".
MAC2GENHATS=pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats
MAC2SATS=pats_dmacro2.sats pats_trans3.sats
MAC2DATS=pats_dmacro2.dats pats_dmacro2_eval0.dats pats_dmacro2_eval1.dats pats_dmacro2_print.dats pats_trans3_error.dats
pats_dmacro2_gen.hats: pats_dmacro2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_dmacro2.spec > $@
pats_dmacro2_gen_dats.hats: pats_dmacro2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_dmacro2.spec > $@
pats_trans3_gen.hats: pats_trans3.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_trans3.spec > $@
pats_trans3_gen_dats.hats: pats_trans3.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_trans3.spec > $@
check:: $(MAC2GENHATS) checkmac2
checkmac2:
	@$(call TYPECHECK,s,$(MAC2SATS))
	@$(call TYPECHECK,d,$(MAC2DATS))
clean::
	$(RM) $(MAC2GENHATS)

# Codegen2 and pattern coverage (pats_codegen2*, pats_patcst2; pats_stacst2 and pats_trans2_env.sats are TEMPORARY partial files that the
# slices of stacst2/trans2 replace): see PORTING.md, "Codegen2" and "Pattern coverage (patcst2)"
SATS += pats_trans2_env.sats pats_stacst2.sats pats_patcst2.sats pats_codegen2.sats
DATS += pats_stacst2.dats pats_patcst2.dats pats_codegen2.dats pats_codegen2_util.dats pats_codegen2_datype.dats pats_codegen2_fprint.dats pats_codegen2_absrec.dats
gen::
	python3 ../utils/arenagen/arenagen.py --global sats pats_patcst2.spec > pats_patcst2_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_patcst2.spec > pats_patcst2_gen_dats.hats

# Level 3 trees (pats_dynexp3*) and the type-checking environment (pats_trans3_env*): see PORTING.md, "Level 3 trees (dynexp3)"
# and "Type-checking environment (trans3_env)". The generated encodings are not kept in git (src/.gitignore).
D3SPECS=pats_dynexp3 pats_trans3_env pats_trans3_env_effect pats_trans3_env_pfman pats_trans3_env_dvar pats_trans3_env_lstate
D3GENHATS=$(foreach s,$(D3SPECS),$(s)_gen.hats $(s)_gen_dats.hats)
$(foreach s,$(D3SPECS),$(s)_gen.hats): %_gen.hats: %.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats $*.spec > $@
$(foreach s,$(D3SPECS),$(s)_gen_dats.hats): %_gen_dats.hats: %.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats $*.spec > $@
D3SATS=pats_dynexp3.sats pats_trans3.sats pats_trans3_env.sats pats_trans3_env_effect.sats pats_trans3_env_pfman.sats pats_trans3_env_dvar.sats pats_trans3_env_lstate.sats
D3DATS=pats_dynexp3.dats pats_dynexp3_print.dats pats_trans3_env.dats pats_trans3_env_dvar.dats pats_trans3_env_effect.dats pats_trans3_env_lamlp.dats pats_trans3_env_lstate.dats pats_trans3_env_pfman.dats pats_trans3_env_print.dats pats_trans3_env_scst.dats pats_trans3_env_svar.dats pats_trans3_env_termet.dats
check:: $(D3GENHATS) checkd3
checkd3:
	@$(call TYPECHECK,s,$(D3SATS))
	@$(call TYPECHECK,d,$(D3DATS))
clean::
	$(RM) $(D3GENHATS)

# Level 2 translation (pats_trans2*, pats_dyncst2): PORTING.md, "Level 2 translation (trans2)".
# The generated encoding of [trans2err] is not kept in git (src/.gitignore).
TR2GENHATS=pats_trans2_gen.hats pats_trans2_gen_dats.hats
pats_trans2_gen.hats: pats_trans2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_trans2.spec > $@
pats_trans2_gen_dats.hats: pats_trans2.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_trans2.spec > $@
SATS += pats_trans2.sats pats_dyncst2.sats
DATS += pats_trans2_env.dats pats_trans2_error.dats pats_trans2_sort.dats pats_trans2_staexp.dats pats_trans2_p1at.dats \
  pats_trans2_dynexp.dats pats_trans2_impdec.dats pats_trans2_decl.dats pats_dyncst2.dats
check:: $(TR2GENHATS)
clean::
	$(RM) $(TR2GENHATS)
checksats checkdats: $(TR2GENHATS)

# Erased trees (pats_hidynexp*) and type erasure (pats_typerase*): PORTING.md, "Erased trees (hidynexp)" and "Type erasure (typerase)".
# The generated encodings (hipat, hidexp, hidecl, .. and [trans4err]) are not kept in git (src/.gitignore).
HDGENHATS=pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats
pats_hidynexp_gen.hats: pats_hidynexp.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_hidynexp.spec > $@
pats_hidynexp_gen_dats.hats: pats_hidynexp.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_hidynexp.spec > $@
pats_typerase_gen.hats: pats_typerase.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_typerase.spec > $@
pats_typerase_gen_dats.hats: pats_typerase.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_typerase.spec > $@
SATS += pats_hidynexp.sats pats_typerase.sats
DATS += pats_hidynexp.dats pats_hidynexp_print.dats pats_hidynexp_util.dats \
  pats_typerase_error.dats pats_typerase_staexp.dats pats_typerase_dynexp.dats pats_typerase_decl.dats
check:: $(HDGENHATS)
clean::
	$(RM) $(HDGENHATS)
checksats checkdats: $(HDGENHATS)

# Level 3 translation (pats_trans3_*, the four groups integrated): PORTING.md, "Level 3 translation, group 1..4" and "Level 3 integration".
# pats_trans3.sats is the single interface of the 20 modules (pats_trans3_error is in MAC2DATS above). The generated encoding of the private
# types of pats_trans3_appsym.dats is not kept in git (src/.gitignore).
T3GENHATS=pats_trans3_appsym_gen.hats pats_trans3_appsym_gen_dats.hats
pats_trans3_appsym_gen.hats: pats_trans3_appsym.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_trans3_appsym.spec > $@
pats_trans3_appsym_gen_dats.hats: pats_trans3_appsym.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_trans3_appsym.spec > $@
T3SATS=pats_trans3.sats pats_trans3_appsym.sats
T3DATS=pats_trans3_syncst.dats pats_trans3_util.dats pats_trans3_dynexp_up.dats \
  pats_trans3_p2at.dats pats_trans3_selab.dats pats_trans3_fldfrat.dats pats_trans3_lvalres.dats \
  pats_trans3_patcon.dats pats_trans3_appsym.dats pats_trans3_caseof.dats pats_trans3_dynexp_dn.dats \
  pats_trans3_decl.dats pats_trans3_looping.dats pats_trans3_assgn.dats pats_trans3_deref.dats \
  pats_trans3_ptrof.dats pats_trans3_viewat.dats pats_trans3_xchng.dats
SATS += pats_trans3_appsym.sats
DATS += $(T3DATS)
check:: $(GENHATS) $(DYN2GENHATS) $(MAC2GENHATS) $(D3GENHATS) $(TR2GENHATS) $(HDGENHATS) $(T3GENHATS) checkt3
checkt3:
	@$(call TYPECHECK,s,$(T3SATS))
	@$(call TYPECHECK,d,$(T3DATS))
checksats checkdats: $(GENHATS) $(DYN2GENHATS) $(MAC2GENHATS) $(D3GENHATS) $(TR2GENHATS) $(HDGENHATS) $(T3GENHATS)
clean::
	$(RM) $(T3GENHATS)

# ccomp group C1 (pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}): PORTING.md, "ccomp group C1 (ccompenv/environ/caseof/looping/trywith/lazyeval)".
# pats_ccomp.sats and its generated encoding (pats_ccomp.spec) are those of the ccomp interface; the two rules below are the same as the ones of the other ccomp groups
# (the generation rules are those of the ccomp interface block of this Makefile).
CCOMPGENHATS=pats_ccomp_gen.hats pats_ccomp_gen_dats.hats
CC1SATS=pats_ccomp.sats
CC1DATS=pats_ccomp_ccompenv.dats pats_ccomp_environ.dats pats_ccomp_caseof.dats pats_ccomp_looping.dats pats_ccomp_trywith.dats pats_ccomp_lazyeval.dats
check:: $(CCOMPGENHATS) checkcc1
checkcc1: $(CCOMPGENHATS)
	@$(call TYPECHECK,s,$(CC1SATS))
	@$(call TYPECHECK,d,$(CC1DATS))

# Constraint solving (pats_constraint3*) and level-2 jsonize (pats_jsonize_synent2): PORTING.md, "Constraint solving (constraint3)", "Level-2 jsonize".
# The generated encoding of [s3exp] is not kept in git (src/.gitignore).
C3GENHATS=pats_constraint3_gen.hats pats_constraint3_gen_dats.hats
pats_constraint3_gen.hats: pats_constraint3.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_constraint3.spec > $@
pats_constraint3_gen_dats.hats: pats_constraint3.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_constraint3.spec > $@
SATS += pats_constraint3.sats pats_jsonize_synent2.sats
DATS += pats_constraint3.dats pats_constraint3_print.dats pats_constraint3_icnstr.dats pats_constraint3_simplify.dats pats_constraint3_solve.dats \
  pats_constraint3_init.dats pats_constraint3_mapgen.dats pats_constraint3_jsonize.dats pats_jsonize_synent2.dats
check:: $(C3GENHATS)
clean::
	$(RM) $(C3GENHATS)
checksats checkdats: $(C3GENHATS)

# ccomp (pats_ccomp*): PORTING.md, "ccomp interface" and "ccomp core modules". The generated encoding of the ccomp data
# (tmpvar, funlab, funent, primval, instr, ..) is kept in git (it is one of the tracked generated encodings).
CCGENHATS=pats_ccomp_gen.hats pats_ccomp_gen_dats.hats
pats_ccomp_gen.hats: pats_ccomp.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_ccomp.spec > $@
pats_ccomp_gen_dats.hats: pats_ccomp.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_ccomp.spec > $@
SATS += pats_ccomp.sats
check:: $(CCGENHATS)
# the tracked generated encodings are not removed by clean
checksats checkdats: $(CCGENHATS)
# the core modules of ccomp (phase 1): tmplab, tmpvar, funlab, funent, d2env, instrseq, util, print and pats_ccomp.dats
# (the constructors of primval/instr/primdec; the only one that includes pats_ccomp_gen_dats.hats)
DATS += pats_ccomp.dats pats_ccomp_tmplab.dats pats_ccomp_tmpvar.dats pats_ccomp_funlab.dats pats_ccomp_funent.dats \
  pats_ccomp_d2env.dats pats_ccomp_instrseq.dats pats_ccomp_util.dats pats_ccomp_print.dats

# ---------------------------------------------------------------------------------------------
# ccomp group A (the C emitter): pats_ccomp_emit{,2,3}.dats, see PORTING.md, "ccomp group A (emit)".
# They need pats_ccomp.sats and the generated pats_ccomp_gen*.hats (the ccomp interface).
CCADATS=pats_ccomp_emit.dats pats_ccomp_emit2.dats pats_ccomp_emit3.dats
check:: checkcca
checkcca:
	@$(call TYPECHECK,d,$(CCADATS))

# ccomp group C2 (pats_ccomp_dynexp, pats_ccomp_decl, pats_ccomp_claulst): PORTING.md, "ccomp group C2 (dynexp/decl/claulst)".
# The data of ccomp (pats_ccomp.spec, interface of phase 1: PORTING.md, "ccomp interface") and the private types of claulst (pats_ccomp_claulst.spec) are generated (src/.gitignore).
CCC2GENHATS=pats_ccomp_gen.hats pats_ccomp_gen_dats.hats pats_ccomp_claulst_gen.hats pats_ccomp_claulst_gen_dats.hats
CCC2GENHATS_UNTRACKED=pats_ccomp_claulst_gen.hats pats_ccomp_claulst_gen_dats.hats
pats_ccomp_claulst_gen.hats: pats_ccomp_claulst.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global sats pats_ccomp_claulst.spec > $@
pats_ccomp_claulst_gen_dats.hats: pats_ccomp_claulst.spec ../utils/arenagen/arenagen.py
	$(ARENAGEN) --global --compact dats pats_ccomp_claulst.spec > $@
CCC2SATS=pats_ccomp.sats pats_ccomp_claulst.sats
CCC2DATS=pats_ccomp_dynexp.dats pats_ccomp_decl.dats pats_ccomp_claulst.dats
SATS += $(CCC2SATS)
DATS += $(CCC2DATS)
check:: $(CCC2GENHATS) checkccc2
checkccc2:
	@$(call TYPECHECK,s,$(CCC2SATS))
	@$(call TYPECHECK,d,$(CCC2DATS))
checksats checkdats: $(CCC2GENHATS)
clean::
	$(RM) $(CCC2GENHATS_UNTRACKED)

# ccomp group B (pats_ccomp_{hitype,hipat,subst,template,main}): PORTING.md, "ccomp group B (hitype/hipat/subst/template/main)".
# pats_ccomp_hitype_priv.sats holds the generated private types of pats_ccomp_hitype.dats (the generated files are small: kept in git).
# pats_ccomp_subst.dats staloads phase 1's pats_ccomp_tmpvar.dats (the tmpvarmap_vt templates, CC-5): it must exist when this is run.
CCBSATS=pats_ccomp_hitype_priv.sats
CCBDATS=pats_ccomp_hitype.dats pats_ccomp_hipat.dats pats_ccomp_subst.dats pats_ccomp_template.dats pats_ccomp_main.dats
check:: checkccb
checkccb:
	@$(call TYPECHECK,s,$(CCBSATS))
	@$(call TYPECHECK,d,$(CCBDATS))
gen::
	python3 ../utils/arenagen/arenagen.py --global sats pats_ccomp_hitype.spec > pats_ccomp_hitype_gen.hats
	python3 ../utils/arenagen/arenagen.py --global --compact dats pats_ccomp_hitype.spec > pats_ccomp_hitype_gen_dats.hats

# ---------------------------------------------------------------------------------------------
# The driver (pats_main.dats) and the executable patsopt: PORTING.md, "Driver and ccomp integration".
#   make patsopt [-j N] [C3NSTRINTKND=intknd]    # builds ./patsopt (the objects are in patsopt.obj/)
# Every module is compiled by itself (the C names of a module do not depend on the directory), the dynload order is the one
# of the list in pats_main.dats. pats_lintprgm_solve.dats and pats_lintprgm_myint_{gmp,int}.dats are included by other modules
# (PORTING.md, "Constraint solving"), they are not compiled by themselves.
P2OBJDIR=patsopt.obj
# Stage 0. By default $(PATSOPT) is run with PATSHOME = this repository (the prelude without GC) and the C code is compiled with the
# run-time of the repository. If $(PATSOPT) is an ATS2 compiler with its own prelude (an installed ats2-postiats), give its PATSHOME:
#   make PATSOPT=/usr/bin/patsopt STAGE0HOME=/usr/lib/ats2-postiats-0.4.2
# Then that prelude and run-time are used, and only libats/{SATS,DATS,CATS}/arena.* (the arena that the sources use) is added from the
# repository through the directory stage0/ ("-IATS"): the first stage of a build is thus independent of the repository's prelude.
# STAGE0HOME not given and PATSOPT is another ATS2 install (its ../prelude exists, and is not this repository): infer it
ifndef STAGE0HOME
P2PREL:=$(realpath $(dir $(realpath $(PATSOPT)))/..)
ifneq ($(wildcard $(P2PREL)/prelude),)
ifneq ($(P2PREL),$(realpath $(PATSHOME)))
STAGE0HOME:=$(P2PREL)
$(info stage 0: STAGE0HOME=$(STAGE0HOME))
endif
endif
endif
ifdef STAGE0HOME
# the C code of an older ATS2 (0.4.2) is not safe with strict aliasing at -O2 (gcc 16: a miscompiled patsopt)
P2OPT ?= -O2 -fno-strict-aliasing
P2HOME=$(STAGE0HOME)
P2ENV=env PATSHOME=$(STAGE0HOME)
P2IATS=-IATS $(CURDIR)/stage0
# (the run-time of an older ATS2 needs the memory allocator and alloca.h to be given)
P2CINC=-I$(CURDIR)/stage0 -DATS_MEMALLOC_LIBC -include alloca.h
STAGE0OVL=stage0/libats/SATS/arena.sats stage0/libats/DATS/arena.dats stage0/libats/CATS/arena.cats
stage0/libats/%: ../libats/%
	@mkdir -p $(dir $@); cp $< $@
else
P2HOME=$(PATSHOME)
endif
P2OPT ?= -O2
P2PATSOPT=$(P2ENV) $(PATSOPT) $(P2IATS)
# what patscc does (the C compiler with the run-time), written out so that the stage-0 compiler is $(PATSOPT) alone
P2CC=$(CC) -std=c99 -D_XOPEN_SOURCE -I$(P2HOME) -I$(P2HOME)/ccomp/runtime $(P2CINC) -D_GNU_SOURCE -I$(CURDIR) $(P2OPT)
# C3NSTRINTKND: gmpknd if <gmp.h> is there, else intknd
ifndef C3NSTRINTKND
ifeq ($(shell echo '\#include <gmp.h>' | $(CC) -E - >/dev/null 2>&1 && echo yes),yes)
C3NSTRINTKND=gmpknd
else
C3NSTRINTKND=intknd
$(info C3NSTRINTKND=intknd: no <gmp.h> for $(CC), building without gmp)
endif
endif
ifdef C3NSTRINTKND
P2DATS=-DATS C3NSTRINTKND=$(C3NSTRINTKND)
endif
ifneq ($(C3NSTRINTKND),intknd)
P2LIBS=-lgmp
endif
P2MODS=$(filter-out pats_lintprgm_solve pats_lintprgm_myint_gmp pats_lintprgm_myint_int pats_atspre, \
  $(patsubst %.dats,%,$(wildcard pats_*.dats)))
P2OBJS=$(addprefix $(P2OBJDIR)/,$(addsuffix _dats.o,$(P2MODS))) $(P2OBJDIR)/pats_error_sats.o $(P2OBJDIR)/pats_runtime_ats1.o
P2GENHATS=$(GENHATS) $(DYN2GENHATS) $(MAC2GENHATS) $(D3GENHATS) $(TR2GENHATS) $(HDGENHATS) $(T3GENHATS) $(C3GENHATS) $(CCC2GENHATS)
.PRECIOUS: $(P2OBJDIR)/%_dats.c
$(P2OBJDIR)/%_dats.c: %.dats $(P2GENHATS) $(STAGE0OVL)
	@mkdir -p $(P2OBJDIR)
	cd $(P2OBJDIR) && $(P2PATSOPT) $(P2DATS) --output $(notdir $@) --dynamic $(abspath $<)
$(P2OBJDIR)/%_dats.o: $(P2OBJDIR)/%_dats.c
	$(P2CC) -c -o $@ $<
$(P2OBJDIR)/pats_error_sats.c: pats_error.sats $(STAGE0OVL)
	@mkdir -p $(P2OBJDIR)
	$(P2PATSOPT) --output $@ --static $<
$(P2OBJDIR)/pats_error_sats.o: $(P2OBJDIR)/pats_error_sats.c
	$(P2CC) -c -o $@ $<
# the run-time with the messages of ATS1 (pats_runtime_ats1.c): the main module does not include the ATS2 run-time
$(P2OBJDIR)/pats_main_dats.o: P2CC+=-D_ATS_CCOMP_RUNTIME_NONE_
$(P2OBJDIR)/pats_runtime_ats1.o: pats_runtime_ats1.c
	@mkdir -p $(P2OBJDIR)
	$(P2CC) -c -o $@ $<
# the bootstrap C bundle (CBOOT/README): `make bootc P2OBJDIR=dir` only generates the C code of every module of patsopt into dir,
# `make CBOOT` runs it for both integer kinds and assembles CBOOT/ (CBOOT/mkboot.sh)
P2GENC=$(addprefix $(P2OBJDIR)/,$(addsuffix _dats.c,$(P2MODS))) $(P2OBJDIR)/pats_error_sats.c \
  $(P2OBJDIR)/pats_main_none_dats.c $(P2OBJDIR)/libatsopt_ext_dats.c
bootc: $(P2GENC)
CBOOT:
	PATSOPT="$(PATSOPT)" PATSHOME="$(PATSHOME)" MAKE="$(MAKE)" sh CBOOT/mkboot.sh
.PHONY: bootc CBOOT
P2EXE=patsopt
patsopt: $(P2OBJS)
	$(P2CC) -o $(P2EXE) $^ $(P2LIBS)
clean::
	$(RM) -r $(P2OBJDIR) $(P2EXE) stage0

# libatsopt.a: the compiler as a library (PORTING.md, "Completion of the port"): the objects of patsopt without the driver
# (pats_main_dats.o, pats_runtime_ats1.o) plus pats_main compiled with -DATS PATSOPT_MAIN_NONE (no main0, libatsopt_dynloadall),
# libatsopt_ext.dats/.c (the API of utils/libatsopt). Link a program with `-L. -latsopt2 -lgmp` (the host provides the ATS run-time).
#   make libatsopt.a [-j N]; make libatsopttest    # builds test/libatsopt/libatsopt_test and compares with patsopt
LIBA=libatsopt.a
LIBOBJS=$(filter-out $(P2OBJDIR)/pats_main_dats.o $(P2OBJDIR)/pats_runtime_ats1.o,$(P2OBJS)) \
  $(P2OBJDIR)/pats_main_none_dats.o $(P2OBJDIR)/libatsopt_ext_dats.o $(P2OBJDIR)/libatsopt_ext_c.o
$(P2OBJDIR)/pats_main_none_dats.c: pats_main.dats $(P2GENHATS) $(STAGE0OVL)
	@mkdir -p $(P2OBJDIR)
	$(P2PATSOPT) $(P2DATS) -DATS PATSOPT_MAIN_NONE --output $@ -d $<
$(P2OBJDIR)/pats_main_none_dats.o: $(P2OBJDIR)/pats_main_none_dats.c
	$(P2CC) -c -o $@ $<
$(P2OBJDIR)/libatsopt_ext_dats.c: libatsopt_ext.dats $(STAGE0OVL)
	@mkdir -p $(P2OBJDIR)
	$(P2PATSOPT) --output $@ -d $<
$(P2OBJDIR)/libatsopt_ext_dats.o: $(P2OBJDIR)/libatsopt_ext_dats.c
	$(P2CC) -c -o $@ $<
$(P2OBJDIR)/libatsopt_ext_c.o: libatsopt_ext.c
	@mkdir -p $(P2OBJDIR)
	$(P2CC) -c -o $@ $<
$(LIBA): $(LIBOBJS)
	$(RM) $@; ar rcs $@ $^
libatsopttest: $(LIBA)
	cd test/libatsopt && patscc -o libatsopt_test libatsopt_test.dats ../../$(LIBA) -lgmp
	cd test/libatsopt && sh run.sh
clean::
	$(RM) $(LIBA) test/libatsopt/libatsopt_test test/libatsopt/*_dats.c

# the driver and the stub of the ATS1 prelude includes (typecheck only; `make patsopt` builds the executable)
checkdrv:
	@$(call TYPECHECK,d,pats_atspre.dats pats_main.dats symmap_htlinprb_check.dats)
check:: checkdrv
