# Security policy

## Supported versions

Security fixes are made on the development line of this repository
(`devel`) and released with the next release. The latest release
([releases](https://github.com/msorc/ATS-Postiats/releases)) is the only
supported one. ATS2 0.4.2 and earlier are not maintained here; see the
[upstream project](https://github.com/githwxi/ATS-Postiats).

## What counts

ATS2 is a compiler and a set of libraries. Reports we want:

* a way to make `patsopt`, `patscc`, `myatscc`, `atsdoc` or `pats2xhtml`
  execute code, write a file or read a file that the user did not ask for,
  when given a crafted source or document;
* a crash or memory corruption of the compiler on valid input that could be
  exploited;
* code generated for a program that the type checker accepts, but that has
  a memory error that the linear types are meant to rule out (a use after
  free, a double free, a leak of a linear value). This is a soundness bug of
  the checker; please report it as a security issue when it can be turned
  into an exploit, and as an ordinary bug otherwise;
* a flaw in the install or release scripts (`make install`, `./configure`,
  the wrapper scripts, the tarballs and their checksums).

Compiling an untrusted ATS file runs the C compiler on the generated code,
and a source file can contain inline C (`%{ ... %}`) and `$extfcall`:
compiling untrusted ATS source is as dangerous as compiling untrusted C
source. That is not a vulnerability by itself; use a sandbox.

## Reporting a vulnerability

Please do not open a public issue for a security problem. Use GitHub's
private vulnerability reporting: open a
[security advisory](https://github.com/msorc/ATS-Postiats/security/advisories/new)
on the repository. Give the version (`patsopt --version`), the operating
system, and a small input that shows the problem.

You can expect an acknowledgement within a week and, once the report is
confirmed, a fix or a plan for a fix within about 90 days. We credit the
reporter in the release notes unless asked not to.
