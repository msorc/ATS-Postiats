# doc/BUGS

An archive of the bug reports that were filed against ATS2, from 2013 to
2020. Each file is a small ATS2 program that reproduces the problem that
was reported; the name of the file is the date of the report.

The directory is an archive: it is not part of the regression suite
(`doc/Makefile_test`), because some of the programs are known not to
compile (they are the reproduction cases of the bugs that are still
open). The `Makefile` of the directory compiles the cases that used to
compile:

    cd doc/BUGS && make -f Makefile all

Most of the bugs have been fixed; the ones that have not are marked in
the source files themselves (e.g. `bug-2020-10-04.dats`: the issue it
reports cannot be fixed easily in ATS2 and is handled in ATS3).
