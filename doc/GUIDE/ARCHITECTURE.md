# Architecture of the compiler

A summary of `src/` for someone who is about to read or change it. The
detailed historical notes of how the compiler was ported from ATS1 to ATS2
(the rules, the validation of every phase, the open problems at the time) are
in [src/PORTING.md](../../src/PORTING.md); read that file for the why of a
particular design choice. Build and bootstrap: [INSTALL](../../INSTALL) and
[src/README](../../src/README).

## What is where

* `src/`: the compiler `patsopt` (about 150,000 lines of ATS2, no GC). It is
  written in the language it compiles, under the same no-GC rules. Its
  driver is `pats_main.dats`, which `staload`s the interface (`.sats`) of
  each phase and `dynload`s every implementation (`.dats`). A new source file
  goes into that `dynload` list and into the lists of `src/Makefile`.
* `src/CBOOT/`: the compiler as generated C (tracked), so that a clone needs
  no ATS compiler. It is regenerated with `make -C src CBOOT`.
* `prelude/` and `libats/`: the libraries (`SATS/` interfaces, `DATS/`
  implementations, `CATS/` C helpers). The generated prelude sources are in
  `prelude/*/SRCGEN` and are tracked.
* `ccomp/runtime/`: the C headers that the generated C includes;
  `ccomp/atslib/`: `libatslib.a`.
* `utils/`: tools built on the compiler (`atscc` = `patscc`, `myatscc`,
  `libatsopt`, `atsdoc`, `pats2xhtml`, `arenagen`, ...). `contrib/`: packages
  released with ATS2, including the JavaScript backend.

Suffix convention: `.sats` interface, `.dats` implementation, `.hats`
included ATS, `.cats` inline C.

## The pipeline

The file prefixes follow the phases:

1. `pats_lexing*`, `pats_parsing*`: lexing and parsing into the level-0
   syntax tree (`pats_syntax`).
2. `pats_trans1*`: fixity resolution and desugaring into level 1
   (`pats_staexp1`, `pats_dynexp1`), with the evaluation of static macros
   (`pats_e1xpval`).
3. `pats_trans2*`: name binding and sort checking into level 2
   (`pats_staexp2`, `pats_dynexp2`). Dynamic macros live in `pats_dmacro2*`.
4. `pats_trans3*`: type checking, including dependent and linear types, into
   level 3 (`pats_dynexp3`). It generates constraints that
   `pats_constraint3*` solves (integer arithmetic in `pats_lintprgm*`;
   the backend is gmp or machine integers, chosen by `C3NSTRINTKND`).
   Constraints can be exported (`pats_jsonize`, `contrib/ATS-extsolve*`) to
   an external solver such as Z3. The checks of the no-GC rules are in
   `d1atdec_tr` (`pats_trans2_decl.dats`) and `d3exp_linheap_check`
   (`pats_trans3_util.dats`).
5. `pats_typerase*`: proofs and types are erased, giving `pats_histaexp`
   and `pats_hidynexp`.
6. `pats_ccomp*`: compilation to an instruction set and then to C
   (`pats_ccomp_emit*`), including template instantiation
   (`pats_ccomp_template`).

`patscc` (`utils/atscc`) runs `patsopt` on a `.dats` file and then the C
compiler on the output.

## How the data are managed: arenas

Without a garbage collector, a compiler that builds large shared trees needs
a discipline. The syntax trees of every level are *arena data*
(`libats/arena`): nodes live in the global arena and are never freed one by
one; a handle is a small word. They are not written by hand: each
`src/pats_*.spec` file describes the records and the algebraic types of a
module, and `utils/arenagen/arenagen.py` generates `pats_*_gen*.hats` with
the constructors (`N_CON`), the accessors, the tag test and a linear view for
pattern matching (`N_view`, matched with `~` patterns). Sixteen of the
generated files are tracked, the others are build output (`make -C src
check` regenerates them). Everything else in the compiler is plain linear
code: owned values, `!` borrows, `glist`/`gopt` for lists and options of
arena data.

## Tests

`make -C src check` typechecks every module; `make -C src test` runs the unit
drivers and the md5 suites of `src/test`, whose sums were recorded from the
ATS1 compiler (the reference of the port). Stage 2 (the compiler built by
the compiler) and stage 3 are bit-identical. The conventions of the
suites are in [AGENTS.md](../../AGENTS.md).
