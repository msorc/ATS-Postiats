# ATS/Postiats (ATS2)

[![CI](https://github.com/msorc/ATS-Postiats/actions/workflows/ci.yml/badge.svg)](https://github.com/msorc/ATS-Postiats/actions/workflows/ci.yml)

ATS2 is a statically typed programming language that combines
functional programming, dependent types, linear types and templates,
and compiles to C. Its types can express (and the compiler can check)
facts about the values of a program, the shapes of its data and the
ownership of its memory, so that a program can be as safe as a proof
and as fast and as small as C. `patsopt` is its compiler, `patscc`
the driver that also runs the C compiler.

This repository is a line of ATS2 that follows the release 0.4.2
by Hongwei Xi ([githwxi/ATS-Postiats](https://github.com/githwxi/ATS-Postiats));
its version is 0.4.3. It differs from 0.4.2 in four ways:

* **No garbage collector.** Heap memory is managed by linear types
  only, and the compiler rejects every nonlinear heap allocation: a
  `datatype` with a non-nullary constructor, a `cloref` closure, a
  boxed tuple or record, `$delay` and `$list_t`. Use `datavtype`,
  `list_vt`, `option_vt`, `cloptr`/`lam@`, flat `@(...)` tuples,
  `$ldelay`/`stream_vt` and `arrayptr` instead. The prelude and `libats`
  were rewritten for this; `libats/arena` is new.
* **A self-hosted compiler.** `patsopt` is written in ATS2 (with the same
  rules) and compiles itself. ATS1 is not needed for anything.
* **A bundled bootstrap.** The C code of the compiler is in the repository
  (`src/CBOOT`), so a clone builds with a C compiler, `make`, python3 and
  libgmp (or none, with `KIND=intknd`).
* **Defaults that work.** `patscc -o hello hello.dats` needs no flags; the
  C back ends other than C, C++ and JavaScript are gone.

Programs written for 0.4.2 that use the garbage collector need changes:
see the [migration guide](doc/GUIDE/migrating-from-0.4.2.md).

## Install

From a release (the tarballs are on the
[releases page](https://github.com/msorc/ATS-Postiats/releases)):

```sh
tar -xzvf ATS2-Postiats-0.4.3.tgz
cd ATS-Postiats
./configure --prefix=$HOME/ats2      # --without-gmp if you have no libgmp
make && make install
export PATH=$HOME/ats2/bin:$PATH
```

From a clone (needs a C compiler, GNU make, python3 and libgmp-dev):

```sh
git clone https://github.com/msorc/ATS-Postiats.git
cd ATS-Postiats
make                                  # KIND=intknd if you have no libgmp
make install PREFIX=$HOME/ats2
export PATH=$HOME/ats2/bin:$PATH
```

[INSTALL](INSTALL) has the details: the requirements, `PREFIX` and
`DESTDIR`, the tools, the tests and the common failures.

## Hello, world

```sh
cat > hello.dats <<'END'
#include "share/atspre_staload.hats"
implement main0 () = println! ("Hello, world!")
END
patscc -o hello hello.dats
./hello
```

```
Hello, world!
```

The [quickstart](doc/GUIDE/quickstart.md) goes on from here.

## Learn ATS2

* [doc/GUIDE](doc/GUIDE): the [quickstart](doc/GUIDE/quickstart.md), the
  [migration guide from 0.4.2](doc/GUIDE/migrating-from-0.4.2.md), the
  [FAQ of the compiler's error messages](doc/GUIDE/faq.md) and the
  [architecture of the compiler](doc/GUIDE/ARCHITECTURE.md).
* [doc/BOOK](doc/BOOK): the books (`make book`): *Introduction to
  Programming in ATS*, the *ATS2 tutorial*, *ATS for APUE3* and the
  *Functional Programming Crash Course*.
* [doc/EXAMPLE](doc/EXAMPLE): the examples, among them
  [INTRO](doc/EXAMPLE/INTRO) (a first tour) and
  [LINHEAP](doc/EXAMPLE/LINHEAP) (one test per rule of the linear heap).
* `man patsopt`, `man patscc`, `man myatscc`.
* As background, the [ATS2 wiki](https://github.com/githwxi/ATS-Postiats/wiki)
  and [ats-lang.org](http://www.ats-lang.org/) of the upstream project (they
  describe 0.4.2, which has a garbage collector).

## Contributing

Bug reports and pull requests are welcome; see
[CONTRIBUTING.md](CONTRIBUTING.md) (the build, the tests, the code style
and how to submit a change), [SECURITY.md](SECURITY.md) and the
[code of conduct](CODE_OF_CONDUCT.md). The notes for the coding agents are
in [AGENTS.md](AGENTS.md); the architecture of the compiler is summarized
in [doc/GUIDE/ARCHITECTURE.md](doc/GUIDE/ARCHITECTURE.md).

## Licenses

* The compiler (`src/`) is under [GPLv3](COPYING-gpl-3.0.txt).
* The ATS source of the libraries (`prelude/`, `libats/`) is under
  [LGPLv3](COPYING-lgpl-3.0.txt), with a special exception for the C code
  generated from it.
* The contributed portion (`contrib/`) is under the [MIT license](contrib/LICENSE).

[LICENSES.md](LICENSES.md) has the per-directory table, the text of the
linking exception and a note on the license headers of individual files.
