# ATS/Browser Examples

This folder contains some small interactive examples of ATS programs
running in a web browser. All that is needed to compile these examples is
the emscripten compiler (from LLVM to JS) with clang (from C to LLVM).

The examples also need the `HTML-emscripten` package, which is **not** in
this repository: it is part of the external
[ATS-Postiats-contrib](https://github.com/githwxi/ATS-Postiats-contrib)
repository (the directory `contrib/HTML-emscripten` there).

Install that package with the package relocation tool of ATS2
(`ats-pkgreloc`), which sets the environment variable `PATSHOMERELOC` to
the directory where the packages are installed; the Makefiles of the
examples use it:

    --js-library ${PATSHOMERELOC}/contrib/HTML-emscripten/JS/HTMLdocument.js
