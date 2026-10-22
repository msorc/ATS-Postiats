# contrib/atscntrb

The contributed libraries that wrap the C libraries: `atscntrb-hx-cstream`,
`atscntrb-hx-globals`, `atscntrb-hx-intinf`, `atscntrb-hx-libcurl`,
`atscntrb-hx-libgmp`, `atscntrb-hx-libhiredis`, `atscntrb-hx-libjansson`,
`atscntrb-hx-libjson-c`, `atscntrb-hx-libpcre` and
`atscntrb-smt-libz3`.

Each of them is a package of its own; its `README` (when it has one) and
its `TEST` directory say how to build and to test it.

The packages that are built by the C backend are the ones of the C
libraries; the others (the ones of `atscntrb-hx-intinf`, for instance)
are the ATS2 sources of the packages.

The directory is part of the release tarball (`doc/DISTRIB`).
