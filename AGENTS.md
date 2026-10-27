# AGENTS.md

This file provides guidance to the coding agents (Claude Code and the
others) when working with code in this repository. The file `CLAUDE.md` is
a symlink to it.

## What this repo is

ATS/Postiats (ATS2): the compiler `patsopt`, the C-compiler wrapper `patscc`, and the ATS2 libraries (`prelude/`, `libats/`). **The compiler in `src/` is written in ATS2 (no GC) and compiles itself; ATS1 is not needed.** (It was ported from ATS1; the ATS1 sources are in git history, the notes of the port are `src/PORTING.md`: the ATS1->ATS2 rules, the arena design, and the validation of every phase.) The same holds for the tools that used to need ATS1: `pats2xhtml`/`libatsynmark` (`utils/atsynmark`, `utils/libatsynmark`) and `atsdoc`/`libatsdoc` (`utils/atsdoc`, `libatsdoc/`) are ATS2 programs too. Nothing in the build, the tests, the prelude regeneration or the release packaging needs ATS1.

## Environment

- `PATSHOME`: the root of this repo (or of an install). Add `$PATSHOME/bin` to `PATH`. `src/Makefile` defaults it to the repo root.
- You need a C compiler, GNU make, python3 (generates the arena encodings of the compiler's syntax trees via `utils/arenagen`) and libgmp (`libgmp-dev`). Without libgmp, build with `C3NSTRINTKND=intknd`.
- The first `patsopt` (stage 0) is one of (details: `src/README`, `src/CBOOT/README`):
  - any ATS2 compiler built from this repo or a release: `PATSOPT=/path/to/patsopt`;
  - an installed upstream ATS2 0.4.2 release (the one that was tested), e.g. `PATSOPT=<prefix>/lib/ats2-postiats-0.4.2/bin/patsopt STAGE0HOME=<prefix>/lib/ats2-postiats-0.4.2` (it runs with its own prelude; only `libats/*/arena.*` is taken from the repo). An installed package built from this tree (for example ats2-postiats 0.4.3) is not an upstream release: it counts as the first bullet (a compiler built from this repo, `PATSOPT=...`), and was not tested as `STAGE0HOME`;
  - the bootstrap C bundle of a release: `make -C src/CBOOT` (gcc + gmp only) gives `src/CBOOT/patsopt`, then `PATSOPT=$PWD/src/CBOOT/patsopt`. The bundle is tracked (path-independent, comments stripped); `make bootstrap` (root Makefile) builds it and then everything, so a clone builds with `make bootstrap && make`; regenerate it with `make -C src CBOOT`.
- The generated prelude sources (`prelude/*/SRCGEN/*.sats|dats|cats`, generated from `*.atxt` by `atsdoc`) are checked in; `make -f codegen/Makefile_atslib` regenerates them with the ATS2 `bin/atsdoc` (`make -f Makefile_devl bin_atsdoc` after `all`): ATS1 is not needed for anything. `make -C utils/atsdoc genprelude` checks that the regenerated files equal the tracked ones (time stamps aside). Note that `prelude/SATS/*.sats` (and the `DATS`/`CATS` equivalents) are tracked symlinks to these `SRCGEN` outputs, so the `SRCGEN` files must stay tracked: without them a clone has dangling links.
- Nix alternative: `nix-shell nix/shell.nix`, then build as below.

## Build

The user-level build and install (requirements, `make`, `make install`, tarball, troubleshooting) is documented once, in `INSTALL`; this section has only what a developer of the compiler needs beyond it (stage-0 choices, the sub-builds).

```sh
make PATSOPT=<stage-0 patsopt> [STAGE0HOME=<its PATSHOME>] all       # the root Makefile: all, check, test, doc, pack
make -f Makefile_devl PATSOPT=<stage-0 patsopt> [STAGE0HOME=<its PATSHOME>] all   # bin/patsopt, bin/patscc, bin/myatscc, libatsopt.a, ccomp/atslib (libatslib.a)
make -f Makefile_devl CC=gcc C3NSTRINTKND=intknd PATSOPT=... all                   # without gmp
make -C src PATSOPT=<stage-0 patsopt> -j8       # only patsopt and libatsopt.a (src/patsopt, src/libatsopt.a)
make -C src CBOOT                               # regenerate the tracked bootstrap C bundle src/CBOOT (needs a working patsopt)
make -C src/CBOOT -j8                           # link patsopt from the bundle with gcc and gmp only
make -C src libatsopttest                       # the library libatsopt.a, with a test program that calls its API
make -C utils/atsynmark                         # libatsynmark.a and bin/pats2xhtml (needs src/libatsopt.a; also `make -f Makefile_devl bin_pats2xhtml`)
make -C utils/atsdoc                            # bin/atsdoc and ccomp/atslib/lib/libatsdoc.a (also `make -f Makefile_devl bin_atsdoc`)
make -C utils/atslint                           # bin/patslint and bin/patslint-diff, the linter (also `make -f Makefile_devl bin_patslint`; needs libatsynmark.a)
```

- Generated files in `src/`: the arena encodings `pats_*_gen*.hats` are made from `src/pats_*.spec` by `utils/arenagen/arenagen.py` (`make -C src check` or the build regenerates them). The ones of 16 modules (`ccomp`, `ccomp_hitype`, `dynexp1`, `e1xpval`, `fixity`, `histaexp`, `jsonize`, `label`, `lexing_token`, `location`, `patcst2`, `staexp1`, `syntax`, `taggen`, `trans1`, `trans1_env`) are tracked; the others are build output and gitignored. `make -C src clean` does not delete the tracked ones; `make -C src check` regenerates them.
- `src/Makefile` is hand-written (the old ATS1 `Makefile.atxt`/CMake/`Makefile_CBOOT*` are gone). Other directories use the `Makefile.atxt` -> `Makefile` pattern (`make -f Makefile.gen`, atsdoc), e.g. `ccomp/atslib`.
- When `PATSOPT` is not given, the stage-0 compiler is `$PATSHOME/bin/patsopt` if it exists, else `patsopt` of the `PATH`. Rebuilding with the compiler just built gives stage 2 (stage 2 and stage 3 are bit-identical).
- Release tarballs: `make pack` (the root Makefile) or `make -C doc/DISTRIB atspackaging` and `atspacktarzvcf` (one tarball) (`make dist` also writes the `.sha256` files; the packaging scripts are generated by atsdoc, needs `make -f Makefile_devl bin_atsdoc`; the compiler sources and the tracked C bundle are copied by `srcget_patsrc*`; run `make -C src CBOOT` first only if the compiler sources changed since the bundle was generated).

## The books

`make book` (the root Makefile) makes the HTML and the PDF of the books in `doc/BOOK` (`INT2PROGINATS`, `ATS2TUTORIAL`, `ATS-for-APUE3` and `ATS2FUNCRASH`; the tools they need are `xsltproc` with the DocBook XSL stylesheets and a browser in headless mode for the PDF; see `doc/BOOK/README.md`). Note that `make doc` only regenerates the generated sources of the libraries; the books have their own makefiles. The rules that make the HTML and the PDF are shared by the books (`doc/BOOK/Makefile_docbook.mk`).

## The .atxt templates (atsdoc)

A `.atxt` file is processed by `atsdoc --outcode X_atxt.dats -i X.atxt > X_atxt.txt; patscc -DATS_MEMALLOC_LIBC -o X_atxt.exe X_atxt.dats -latsdoc; ./X_atxt.exe > X`
(add `-I$PATSHOME/src -latsynmark -latslib -latsopt -lgmp` for the documents that use `pats2xhtml`/libatsynmark; the DOCUGEN directories
build `share/DOCUGEN/htmlgendecl.atxt` with the data of each document, see their `Makefile`). The code blocks (`%{ .. %}`) of the templates are ATS2
programs under the no-GC rules: `main0`, `glist` for lists of atexts, `ref_make_viewptr` for the counters; `utils/atsdoc/HATS/atsdoc_compat.hats`
(included by `postiatsatxt.hats` and `xhtmlatxt.hats`) provides the ATS1 spellings `sprintf/printf/fprintf/prerrf (fmt, @(strings))` (all conversions are
`%s`) and `string_of_strptr`. A string argument of a placeholder keeps the ATS1 meaning of `\X`: write `\\X` for a backslash that must reach the output.
Do not `dynload "libatsdoc/dynloadall.dats"` twice in one module (the helper hats files already do). `make -C utils/atsdoc genall` (about 30 s; `GENARGS=doc/DISTRIB`
or `GENARGS=prelude` for a part) regenerates the text of every template and compares its md5 sum with `utils/atsdoc/TEST/genall.md5` (the sums are those of the ATS1 toolchain
for most of the templates, and for 4 EFFECTIVATS documents they equal the tracked `main.html`; the others are sums of the new output only: the `Makefile*.atxt` of the DOCUGEN/CODEGEN/DISTRIB directories differ from ATS1 in the lines that name the compiler, and 3 templates were edited when the other backends were removed (`LECTURE/01`, `LECTURE/03-10`, `patscontrib_libatscc.atxt`) (the 6 libcairo tutorial chapters and `PwTP-bool-vs-prop` never ran with ATS1, so they are not in the list).

## Tests

There is no unit-test framework. Regression testing compiles and runs the example and book code under `doc/`, and the compiler has its own suites under `src/test`:

```sh
make -C src check                               # typecheck every module of the compiler (patsopt only)
make -C src test [JOBS=N]                       # check + unit tests + the md5 suites of src/test (no ATS1; needs bin/patscc; ~9 min with JOBS=nproc=32, 35 to 50 min with JOBS=1)
make -C src/test errtest                      # the error messages: ~40 failing programs, expected stderr in src/test/errcases/expected (reviewed by hand; `sh src/test/errcases/run.sh update`; part of `make -C src test`)
make -C utils/atsdoc test                       # atsdoc and libatsdoc: 2653 md5 cases
make -C utils/atsdoc genall                     # regenerates the text of 370 .atxt templates and compares their md5 sums (~30 s)
make -C utils/libatsynmark test                 # libatsynmark and pats2xhtml: 5228 md5 cases (after make -C utils/atsynmark)
make -C utils/atslint test                      # patslint: the cases of TEST/suite.py (expected outputs in TEST/expected, reviewed by hand; `make update` rewrites them)
make lint                                       # patslint on the lines of the ATS files changed since LINTBASE (origin/devel); the CI runs it on pull requests; LINTFLAGS=--semantic adds unused-var, nonexhaustive, ... (trans1+trans2 of each file)
make -C doc -f Makefile_test testall            # all subdirs listed in doc/Makefile_test
make -C doc/EXAMPLE/INTRO regress               # one directory: build its targets and run each binary
make -C doc/EXAMPLE/INTRO acker1 && ./doc/EXAMPLE/INTRO/acker1   # a single test
```

The md5 suites compare output with md5 sums recorded from the ATS1 tools (the compiler's suites in `src/test`, `utils/atsdoc/TEST`, `utils/libatsynmark/TEST`). They run all the cases of a list in one process, so the sums depend on the order of the file list and on how `PATSHOME` is spelled: their Makefiles pin `LC_ALL=C` and the canonical `PATSHOME`, keep that when you add a suite, and regenerate recorded sums from the ATS1 output, never from the ATS2 output alone (the one exception: the 96 `api` cases of `utils/libatsynmark/TEST` with non-ASCII input, recorded from ATS2 when the string reader of the compiler stopped sign-extending bytes; see the header of its `suite.py`). The differential targets (`make -C src/test s2compare`, `t3compare`, `drvfiles`, ..., the `*dump1.sh` scripts) compare against a real ATS1 build and are only needed when you change a ported module's behaviour: you must provide an ATS1 compiler install yourself (it is not part of this repository), check the old `src/` out of git history (the parent of the commit that replaced it: `git log --grep='Replace the ATS1 compiler sources' --format=%H`, then `git archive <that>^ src`), build it with ATS1 and set `ATS1REF=<its src dir>` (see `src/README`; the ATS1 objects only link at the path they were built at); without `ATS1REF` they stop with a message.

`make -C src test` compiles in parallel and runs serially: the `prebuild` step of `src/test/Makefile` first generates every shared generated file once (serial), then builds every program of every suite with `make -j$(JOBS)` (`JOBS` defaults to `nproc`; `JOBS=1` is the old fully serial run), and then `all` runs the suites one after the other, in the same order as before, on the programs that are up to date. A `-j N` given to make is ignored for the runs (`.NOTPARALLEL`: the suites share generated files and their outputs must not interleave); it is harmless. The reasons: `patscc` writes `X_dats.c` into the current directory, so two compilations of the same module must not share a directory (the objects are built in their `*obj` directory, the programs built by one `patscc` call in `../cc_tmp_PROGRAM`), and the generators (`*_gen.py`, `make -C src pats_*_gen*.hats`) must not run twice at the same time. When you add a suite, add its program to `PREEXES` and its generated files to `PREGEN` at the end of `src/test/Makefile`.

Example Makefiles include `$(PATSHOME)/share/atsmake-pre.mk` / `atsmake-post.mk` and declare `all::` / `regress::` / `cleanall::` targets. To quickly check one ATS2 file: `patscc -DATS_MEMALLOC_LIBC -o foo foo.dats` (typecheck only: `patsopt --typecheck -d foo.dats`).

## Compiler architecture (`src/`)

`pats_main.dats` is the driver. It `staload`s each phase's `.sats` interface and `dynload`s every implementation `.dats`. **When you add a source file, add it to the `dynload` list in `pats_main.dats` and to the lists in `src/Makefile` (`SATS`/`DATS` and its group lists; the build compiles every `pats_*.dats` present).** The compiler follows the no-GC rules below itself: its syntax trees are arena data (`libats/arena`) generated from `src/pats_*.spec` by `utils/arenagen/arenagen.py` (the `pats_*_gen*.hats` files are generated, see Build), everything else is linear.

The pipeline follows the file prefixes:

1. `pats_lexing*`, `pats_parsing*`: lex and parse into level-0 syntax (`pats_syntax`).
2. `pats_trans1*`: fixity resolution and desugaring into `staexp1`/`dynexp1`.
3. `pats_trans2*`: name binding and sort checking into `staexp2`/`dynexp2`. Macros live in `pats_dmacro2*`.
4. `pats_trans3*`: type checking, including dependent and linear types, into `dynexp3`. It generates constraints that `pats_constraint3*` solves (integer arithmetic via `pats_lintprgm*`, gmp or int backend chosen by `C3NSTRINTKND`). Constraints can also be exported (`pats_jsonize`, `contrib/ATS-extsolve*`) for external solvers such as Z3.
5. `pats_typerase*`: erases proofs and types into `histaexp`/`hidynexp`.
6. `pats_ccomp*`: compiles to an instruction set and emits C (`pats_ccomp_emit*`), including template instantiation (`pats_ccomp_template`).

File-suffix convention throughout: `.sats` = interface, `.dats` = implementation, `.hats` = included ATS, `.cats` = inline C.

## Other key directories

- `src/`: the compiler of ATS2 (`patsopt`); it is written in ATS2 and compiles itself. `src/PORTING.md` is the architecture document of the compiler: the notes of its port from ATS1, the arena design, and the validation of every phase.
- `prelude/`, `libats/`: ATS2 standard libraries (`SATS/` interfaces, `DATS/` implementations, `CATS/` C helpers).
- `ccomp/runtime/`: C runtime headers that generated C code includes. `ccomp/atslib/`: builds `libatslib.a`.
- `share/`: `atspre_staload.hats`, `atsmake-*.mk`, and other shared include files.
- `utils/`: tools built on the compiler (`atscc` = patscc source, `myatscc`, `libatsopt`, `atsynmark` and `libatsynmark` (`pats2xhtml`, the syntax highlighter that the documents use), `atslint` (`patslint`, the linter: style rules on the tokens of the compiler's lexer, `.patslint` configuration, `utils/atslint/README`), `atexting` (a separate ATS2 text preprocessor with `##name` syntax, not compatible with `.atxt`), `atsdoc` (the `.atxt` text processor; its run-time library is `libatsdoc/`; `make -C utils/atsdoc`; `make -C utils/atsdoc genall` regenerates the 370 runnable templates of the repository and compares them with `TEST/genall.md5`), emacs mode, …).
- `contrib/`: MIT-licensed. It holds the packages that are released *with* ATS2; the packages of the separate [ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib) repository (`PATSCONTRIB`, packaged as `ATS-Postiats-contrib`) are not in this tree (see `contrib/README.md`). Contains the Javascript backend (`CATS-atscc2js` with its `libatscc2js` library and the shared `CATS-parsemit`/`libatscc`), the C++ mode of the C backend (`ats2cpp`), the external constraint solvers, and `afiber` (stackful cooperative green threads and channels, `contrib/afiber/README.md`; tests in `contrib/afiber/TEST`, run by `doc/Makefile_test`).
- `doc/`: books (`BOOK/`), examples (`EXAMPLE/`), and distribution scripts (`DISTRIB/`).

## No GC: heap allocation is linear-only

There is no garbage collector (Boehm support is removed), and the compiler always rejects nonlinear heap allocation. The checks are in `d1atdec_tr` (`pats_trans2_decl.dats`) and `d3exp_linheap_check` (`pats_trans3_util.dats`). The rejected constructs are:

- a `datatype` with a non-nullary constructor
- a cloref `lam`/`fun`
- boxed tuples and records, linear ones included
- `$delay` and `$list_t`

`$list` yields a `list_vt`. Use these instead:

- datavtypes
- `cloptr` or `llam` (one-shot; free a `-<lincloptr1>` closure after calling it), or flat `lam@`
- flat `@(...)` tuples and records
- `$ldelay`/`stream_vt`
- `list_vt`, `option_vt` and `arrayptr`

The prelude has no `list`, `option`, `stream`, `lazy`, `arrayref` or `matrixref`, and `libats/ML` is gone. `ref` can only be made with `ref_make_viewptr` from memory that is never freed (e.g. a toplevel `var`). For shared data in compiler-like code, use `libats/arena` (`the_garena_*`, `glist`, `gopt`) and generate algebraic types with `utils/arenagen/arenagen.py` (`--global`). `doc/EXAMPLE/LINHEAP` tests each rule. Check for leaks with `-fsanitize=address`.

## Licensing

The compiler is GPLv3, the libraries are LGPLv3, and `contrib/` is MIT. Keep new files consistent with the license of the directory they go in.
