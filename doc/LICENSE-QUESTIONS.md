<!--
SPDX-FileCopyrightText: 2026 Mikhail Sorochan
SPDX-License-Identifier: MIT
-->

# Open licensing questions

This is a list of questions, not a legal audit. [LICENSES.md](../LICENSES.md)
is the summary of the licenses; this file lists where the tree does not
agree with it. Questions 1 and 2 are decisions for the copyright holder;
questions 3 and 4 are mechanical fixes.

## 1. The source headers disagree with the directory licenses

The README designates the licenses per directory; the headers of many files
say something else (counts from the survey in `LICENSES.md`):

- `prelude/`, `libats/`: designated LGPLv3, but 221 and 173 files carry the
  GPLv3 notice inherited from upstream. Only the linking exception of the
  README says otherwise.
- `ccomp/runtime/`: the headers say GPLv3; the README also announces an
  MIT-style release of the C headers
  (`doc/DISTRIB/ATS-Postiats-include/COPYING`). The two statements conflict.
- `contrib/`: designated MIT (`contrib/LICENSE`, `contrib/README.md`), but 54
  files carry GPLv3 headers and 36 LGPLv2.1 headers (for example the libcurl,
  hiredis, jansson and z3 bindings in `contrib/atscntrb/`).
- `utils/`, `libatsdoc/`: 10 files are LGPLv2.1, not GPLv3
  (`COPYING-lgpl-2.1.txt` is kept for them).

`CONTRIBUTING.md` says not to change the headers of existing files, so this
stays open until the copyright holder decides.

## 2. MIT files inside the GPL directories

69 files in `src/`, `libats/`, `prelude/` and `utils/` carry
`SPDX-License-Identifier: MIT`, and `LICENSES.md` says the SPDX line wins
over the directory license. Some of them may be derived from the GPL ATS1
sources:

- `src/*.spec`: they encode the syntax trees of the ATS1 compiler and say
  that "the names of the ATS1 fields and constructors are kept".
- `src/pats_runtime_ats1.c`: reproduces the messages of the ATS1 run-time.
- `src/libatsopt_ext.c`, `src/CBOOT/libatsopt_ext.c`: the C API of the ATS1
  `utils/libatsopt`.
- `src/pats_parsing.hats`, `src/pats_staexp2.hats`, `src/mylibies.hats` and
  similar files: glue that only works inside the GPL compiler.

If these are derivative works, the MIT label does not hold on its own. The
arena library (`libats/*/arena.*`) and `utils/arenagen` are clearly separate
work.

## 3. Generated files carry no license notice

- `src/CBOOT/*_dats.c` (184 files): the C bundle has its comments stripped
  and contains no license notice. It is C generated from the GPL compiler;
  the linking exception covers only C generated from the Libraries, so the
  bundle is GPLv3, but nothing in it says so.
- The tracked `src/pats_*_gen*.hats` have no header. They are generated from
  the MIT specs and compiled into the GPL compiler.

## 4. The packages ship only `COPYING`

`make install` (root `Makefile`) and the release scripts
(`doc/DISTRIB/Makefile.atxt`, `srcget_home`) copy only `COPYING` (GPLv3).
Missing from the tarballs and the installs:

- the LGPLv3 and LGPLv2.1 texts, although the libraries are announced as LGPL;
- `LICENSES.md`, the only place with the linking exception and the map of
  the directories;
- `contrib/LICENSE`: the contrib packages are copied, their MIT text is not.

`doc/PACKAGING-DOC-REVIEW.md` (B10) also notes that the README, which holds
the license prose, is not in the tarball.
