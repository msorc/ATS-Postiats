# Contributing to ATS2 (ATS/Postiats)

Thank you for helping. This file describes how to build and test the
tree, how to submit a change, the code style, and the conventions of the
repository. The architecture of the compiler is summarized in
[doc/GUIDE/ARCHITECTURE.md](doc/GUIDE/ARCHITECTURE.md) (the detailed
historical notes are `src/PORTING.md`); the notes for the coding agents are
in [AGENTS.md](AGENTS.md). Please follow the
[code of conduct](CODE_OF_CONDUCT.md). A security problem is reported as
described in [SECURITY.md](SECURITY.md), not in a public issue.

## The build

The build, with its requirements and the common failures, is described in
[INSTALL](INSTALL): in short, `make` in a clone (it bootstraps the compiler
from the tracked C bundle `src/CBOOT`, so a C compiler, GNU make, python3 and
libgmp are all you need). **ATS1 is not needed.**

The targets of the root `Makefile`:

| target | what it does |
| --- | --- |
| `all` (default) | the compiler, the tools and the runtime library |
| `bootstrap` | `patsopt` from `src/CBOOT`, then `all` |
| `tools` | `atsdoc`, `pats2xhtml` and their libraries |
| `check` | the type checking of every module of the compiler |
| `test` | the regression suites of the repository |
| `install`, `uninstall` | `PREFIX`, `DESTDIR` |
| `dist` | the release tarballs and their checksums |
| `doc`, `book` | the generated library sources; the books |

The developer's options (another stage-0 compiler, the sub-builds) are in
[src/README](src/README) and AGENTS.md.

## The tests

There is no unit-test framework: the tests are regression suites (`make
test` runs them all, see [INSTALL](INSTALL)). Run the ones that touch what
you changed:

```sh
make -C src check                          # the type checking of the compiler
make -C src test                           # the suites of the compiler
make -C utils/atsdoc test                  # atsdoc and libatsdoc
make -C utils/libatsynmark test            # libatsynmark and pats2xhtml
make -C doc -f Makefile_test testall       # the examples and the book code
make -C utils/atsdoc genall                # the .atxt templates of the repository
sh share/SCRIPT/check_tree_hygiene.sh      # dangling links, absolute paths
```

The md5 suites compare the output with the sums that are recorded in
`utils/atsdoc/TEST/expected.md5` and `utils/atsdoc/TEST/genall.md5` (and in
`src/test`, `utils/libatsynmark/TEST`). The sums are the ones of the ATS1
toolchain (the reference of the port); when a template is edited on
purpose, record the sum of the new output for that template only and say
so in the commit message.

## Submitting changes

1. Open an issue first for anything larger than a fix, so that the design
   can be discussed before the work is done.
2. Fork the repository and branch from `devel` (the development
   branch): `git switch -c my-change devel`.
3. Make small, focused commits. The subject line says what changes, in the
   imperative and in at most about 72 characters, prefixed by the area
   (`src:`, `prelude:`, `libats:`, `doc:`, `utils/atsdoc:`, `ci:`, ...); the
   body says why. Do not mix a formatting change with a change of
   behaviour.
4. Run the tests that your change can affect (see above) and say in the pull
   request which ones you ran. A change of the compiler must keep stage 2
   and stage 3 bit-identical, and `make -C src test` green.
5. A change of behaviour updates the documentation that describes it, and
   adds a user-visible note to `CHANGES-ats2` (the section of the version
   in `VERSION`).
6. Open a pull request against `devel`; the template asks for the above. The
   CI must be green. Expect a review; push further commits rather than
   rewriting the history while it is going on.

## Code style

* ATS: indent by two spaces, no tabs, no trailing white space, lines of at
  most about 80 columns, LF line ends and a final newline. Follow the
  neighbouring file: the style of the sources is not uniform and a change
  should not reformat what it does not touch.
* File suffixes: `.sats` is an interface, `.dats` an implementation, `.hats`
  an included file, `.cats` an inline C file. An interface goes first, its
  implementation in the `.dats`; comments of the form `(* ... *)` and `//`
  as in the neighbouring code.
* The heap is linear only (see below): new code, including the examples
  and the tests, follows the no-GC rules.
* Makefiles: GNU make, tabs for recipes; shell: POSIX `sh`.
* Generated files (`prelude/*/SRCGEN`, `src/pats_*_gen*.hats`, `src/CBOOT`)
  are not edited by hand: change the source (the `.atxt` template, the
  `.spec`) and regenerate.
* Every new file has a license: `SPDX-FileCopyrightText` and
  `SPDX-License-Identifier` lines, the license of its directory (see
  below and [LICENSES.md](LICENSES.md)); do not change the license text or
  the headers of existing files.
* Writing: plain text, short sentences, no marketing; the code of an example
  that appears in a document is a tested file.

## The documents

The documents of the repository are written in the `.atxt` format and are
processed by `atsdoc` (`utils/atsdoc`, an ATS2 program):

```sh
make tools                                  # builds bin/atsdoc
make doc                                    # the sources of the libraries
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

`make dist` builds the tarballs (see [INSTALL](INSTALL)):

- `ATS2-Postiats-<version>.tgz` (the compiler, the libraries and the
  tools; one tarball for both integer backends: `./configure` uses libgmp
  when it is there),
- `ATS2-Postiats-include-<version>.tgz` (the headers and the CATS
  files that are needed to use ATS2 from C),

and `share/SCRIPT/build_release.sh` also builds
`ATS2-Postiats-contrib-<version>.tgz` (the packages of the external
[ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib)
repository). The tarballs are published as a GitHub Release. The process
is described in `doc/DISTRIB/README`.

## The conventions

- The licenses are per directory: the compiler (`src/`) is GPLv3, the
  libraries (`prelude/`, `libats/`) are LGPLv3 and `contrib/` is MIT.
- The heap memory is linear only: there is no garbage collector, and
  the compiler rejects every nonlinear heap allocation. See
  `doc/EXAMPLE/LINHEAP` for a test of each rule and
  [doc/GUIDE/faq.md](doc/GUIDE/faq.md) for the messages.
- A file that is added to the compiler (`src/`) is added to the
  `dynload` list of `src/pats_main.dats` and to the lists of
  `src/Makefile`.
- A change of the compiler is a change of its documentation as well.
