# Contributing to ATS2 (ATS/Postiats)

This file describes how to build, test and release ATS2, and the
conventions of the repository. The details of the architecture of the
compiler are in `src/PORTING.md`; the notes for the coding agents are in
`AGENTS.md`.

## The build

ATS2 is written in ATS2 and compiles itself; **ATS1 is not needed**.

```sh
make PATSOPT=/path/to/patsopt all   # bin/patsopt, bin/patscc, bin/myatscc
```

The stage-0 compiler (`PATSOPT`) is one of:

- any ATS2 compiler (an installed release or an earlier build of this
  repository); for an installed one, its own prelude is needed as well
  (`STAGE0HOME=/usr/lib/ats2-postiats-0.4.2`);
- the bootstrap C bundle of this repository: `make -C src CBOOT` gives
  `src/CBOOT/patsopt` (it needs only a C compiler and libgmp).

The requirements are: a C compiler, GNU make, python3 (it generates the
arena encodings of the syntax trees of the compiler) and libgmp (the
build works without it with `C3NSTRINTKND=intknd`).

The entry points of the build are the targets of the root `Makefile`:

| target | what it does |
| --- | --- |
| `all` | the compiler, the tools and the runtime library |
| `check` | the type checking of every module of the compiler |
| `test` | the regression suites of the repository |
| `doc` | the regeneration of the generated sources of the libraries |
| `pack` | the release tarballs |

`make -f Makefile_devl …` (the old name of the root Makefile) still
works.

## The tests

There is no unit-test framework: the tests are regression suites.

```sh
make -C src check                          # the type checking of the compiler
make -C src test                           # the suites of the compiler
make -C utils/atsdoc test                  # atsdoc and libatsdoc
make -C utils/libatsynmark test            # libatsynmark and pats2xhtml
make -C doc -f Makefile_test testall       # the examples and the book code
make -C utils/atsdoc genall                # the .atxt templates of the repository
```

The md5 suites compare the output with the sums that are recorded in
`utils/atsdoc/TEST/expected.md5` and `utils/atsdoc/TEST/genall.md5`.
The sums are the ones of the ATS1 toolchain (the reference of the port);
when a template is edited, its sum is the one of the new output, and it
is the sum of the ATS1 toolchain that must be recorded for the rest.

## The documents

The documents of the repository are written in the `.atxt` format and are
processed by `atsdoc` (`utils/atsdoc`, an ATS2 program):

```sh
make -f Makefile_devl bin_atsdoc           # the tool
make -f codegen/Makefile_atslib             # the sources of the libraries
make -C utils/atsdoc genall                 # the text of every template
```

The generated sources of the libraries (`prelude/*/SRCGEN`) are tracked
in git: the `CODEGEN` directories (the sources) and the `DOCUGEN`
directories (the documents) have the same file names, and they hold
different things.

## The release

The version of the release is in `VERSION`; it must be declared
consistently in `VERSION`, `doc/DISTRIB/ATS-Postiats/configure.ac`,
`src/pats_basics.sats` and `CHANGES-ats2`:

```sh
sh share/SCRIPT/check_release_version.sh   # checks the four of them
sh share/SCRIPT/make_release_notes.sh       # the release notes from the changelog
```

The tarballs are built by `make pack` (or by
`share/SCRIPT/build_release.sh`, which does the same and checks the
version). The three tarballs are:

- `ATS2-Postiats-<version>.tgz` (the compiler, the libraries and the
  tools; the variants `…-gmp-…` and `…-int-…` differ by the integer
  arithmetic backend),
- `ATS2-Postiats-contrib-<version>.tgz` (the packages of the external
  [ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib)
  repository),
- `ATS2-Postiats-include-<version>.tgz` (the headers and the CATS
  files that are needed to use ATS2 from C).

The process is described in `doc/DISTRIB/README`.

## The conventions

- The licenses are per directory: the compiler (`src/`) is GPLv3, the
  libraries (`prelude/`, `libats/`) are LGPLv3 and `contrib/` is MIT.
- The heap memory is linear only: there is no garbage collector, and
  the compiler rejects every nonlinear heap allocation. See
  `doc/EXAMPLE/LINHEAP` for a test of each rule.
- A file that is added to the compiler (`src/`) is added to the
  `dynload` list of `src/pats_main.dats` and to the lists of
  `src/Makefile`.
- The file suffix convention: `.sats` is an interface, `.dats` an
  implementation, `.hats` an included file, `.cats` an inline C file.
- A change of the compiler is a change of its documentation as well:
  `src/PORTING.md` describes the architecture of the compiler.
