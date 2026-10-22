# npm-utils/contrib

The npm packages of the contributed ATS2 libraries.

## Layout

- `atscntrb/` — the packages of `contrib/atscntrb` (the libraries that wrap
  the C libraries: cairo, libev, libevent, sdl2, xml2, ..). Each package is
  a directory `atscntrb-hx-<name>`.
- `libats-hwxi/` — the packages of the `libats-hwxi` libraries (threadkit,
  polyglot, jsonats, kernelats, ..).

`make -f Makefile_test` runs the test suites of the packages that have one.

## The name `libats-` in the external contrib repository

The directory `libats-hwxi` used to be named `libats-/hwxi` (the trailing
dash is an artifact of a rename that was never applied to the directory).
The name has been fixed in this tree.

The separate [ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib)
repository (`PATSCONTRIB`), which is packaged separately, still uses the
directory name `libats-`. That is why the two references to the external
repository keep the old name:

- `share/HATS/atspre_define_pkgreloc.hats`: `$PATSCONTRIB/contrib/libats-/hwxi`
- `doc/DISTRIB/ATS-Postiats-contrib/contrib/libats-/`

They are paths in the external repository, not in this tree.
