# contrib/CATS-atscc2js

The Javascript backend of ATS2: the compiler `atscc2js` translates ATS2
into Javascript (it is written in ATS2 itself, on the global arena).

    cd contrib/CATS-atscc2js && make -f Makefile all

It uses the shared parser/emitter library `contrib/CATS-parsemit` and the
runtime library `contrib/libatscc2js`.

The directory is part of the release tarball (`doc/DISTRIB`).
