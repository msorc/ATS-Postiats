# [ATS2](http://www.ats-lang.org/) - ATS/Postiats

A Programming Language System to Unleash the Potentials of Types
and Templates

## Project Description

ATS/Postiats (or ATS2/Postiats) is the name for the current compiler
of ATS2, the successor of ATS (or ATS1).

The actual implementation of ATS/Postiats started in the March of
2011, and it took about two and one-half years to reach the first
release of ATS2 at the beginning of September, 2013. As of now, the
code base for the compiler of ATS2 consists of 180,000+ lines of code
(LOC); the compiler was written in ATS1 and has been ported to ATS2: it
now compiles itself (ATS1 is no longer needed).

When compared to ATS1, the single most important new feature is the
template system of ATS2. This is a feature that could potentially
change the way a programmer writes his or her code. One can certainly
feel that this is a very powerful feature (a bit like feeling that OOP
is a very powerful feature). However, how this feature should be properly
and effectively used in practice needs a lot more investigation.

Another thing about ATS2 is that it is a lot leaner than ATS. One can make
good use of ATS2 without any need for compiled library (libatslib.a). Also,
there is no GC: heap memory is managed through linear types and views only.
The compiler rejects any nonlinear heap allocation (a datatype with a
non-nullary constructor, a cloref closure, a boxed (even linear) tuple or record,
`$delay`, `$list_t`); use datavtypes, linear closures (cloptr/llam), flat
tuples and records, `$ldelay`/stream_vt and list_vt instead. Shared data
whose lifetime is well-delimited can be kept in an arena (libats/arena).

## Build Status

* [![Build Status](https://travis-ci.org/githwxi/ATS-Postiats.svg?branch=master)](https://travis-ci.org/githwxi/ATS-Postiats) Ubuntu
* [![Build Status](https://ci.appveyor.com/api/projects/status/github/githwxi/ats-postiats?branch=master&svg=true)](https://ci.appveyor.com/project/githwxi/ats-postiats/branch/master) Cygwin

## Installing ATS2

Please see
[https://ats-lang.sourceforge.net/DOWNLOAD/](https://ats-lang.sourceforge.net/DOWNLOAD/) for
instructions.

Note that the code in this github directory is primarily meant for people
who would like to help develop ATS2. For someone who just wants to program
in ATS2, please install the current release of ATS2, which can be found at
the following site:
[https://sourceforge.net/projects/ats2-lang/](https://sourceforge.net/projects/ats2-lang/).
There are also pre-compiled debian packages for ATS2 available on-line.

## Developing ATS2

The compiler of ATS2 (`src/`) is implemented in ATS2 itself (no GC, linear
heap data only); ATS1 is not needed. To build it you need a first `patsopt`
(stage 0): any ATS2 compiler (an installed release or an earlier build), or the
bootstrap C bundle that `make -C src CBOOT` generates (it needs only a C
compiler and libgmp to be linked). See `src/README` and `src/CBOOT/README`:

    make -f Makefile_devl PATSOPT=/usr/bin/patsopt STAGE0HOME=/usr/lib/ats2-postiats-0.4.2 all
    make -C src test     # the compiler's own regression tests (no ATS1)

The old ATS1 sources of the compiler are in the git history.

The generated prelude sources (`prelude/*/CODEGEN`), the packaging scripts
(`doc/DISTRIB`) and the documents (`*.atxt`) are produced by `atsdoc` (ATS2, no
GC; `make -C utils/atsdoc`), also without ATS1: `make -f codegen/Makefile_atslib`
regenerates the prelude sources, `make -C utils/atsdoc genall` the text of all
the templates and checks it, `make -C doc/DISTRIB atspackaging` makes a release.

## Documenting ATS2

ATS-users are encouraged to share what they have learned on the
[ATS2 wiki](https://github.com/githwxi/ATS-Postiats/wiki), which currently
contains over 45 articles with content.  A list of article stubs is
maintained at [TODO](https://github.com/githwxi/ATS-Postiats/wiki/TODO).

## Licenses for ATS/Postiats

* The Compiler (`src/`) is under [GPLv3](COPYING-gpl-3.0.txt).
* The ATS source of the Libraries (`prelude/`, `libats/`) is under
  [LGPLv3](COPYING-lgpl-3.0.txt), with a special exception for the C code generated
  from it (see [LICENSES.md](LICENSES.md)).
* The contributed portion (`contrib/`) is under the [MIT license](contrib/LICENSE).

[LICENSES.md](LICENSES.md) has the per-directory table, the full text of the linking
exception, and a note on the license headers of individual source files.
