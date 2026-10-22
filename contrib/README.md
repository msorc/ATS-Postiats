# contrib

The contributed packages of ATS2 that are released **with** ATS2.

The packages are:

- `afiber` — the stackful cooperative green threads and the channels.
- `ats2cpp` — the C++ mode of the C backend.
- `atscntrb` — the libraries that wrap the C libraries (cairo, libev,
  libevent, libgmp, libcurl, libhiredis, libjansson, json-c, libpcre, ..).
- `ATS-extsolve`, `ATS-extsolve-z3`, `ATS-extsolve-smt2` — the export of
  the constraints of the type checker to external solvers.
- `CATS-parsemit` — the shared parser and emitter of the backends.
- `CATS-atscc2js` — the Javascript backend.
- `libatscc`, `libatscc2js` — the runtime libraries of the backends.

The licenses of this directory are the MIT license (see the license of
the repository).

## The other contrib tree

There is a second tree of contributed packages: the
[ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib)
repository (the environment variable `PATSCONTRIB` points to it in the
release script). It is a separate repository, it is packaged separately
(the `ATS-Postiats-contrib` tarball) and it is **not** in this tree.

The packages of that repository are: GTK, glib, HTML-emscripten, JNI,
kernelats, libats-hwxi, OpenSSL, SDL2 and zeromq.

The skeleton of that package is in `doc/DISTRIB/ATS-Postiats-contrib/`;
its directories are filled in by the release script from `${PATSCONTRIB}`.
