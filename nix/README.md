
## Using ATS-Postiats from a git repo-build

From your ATS-Postiats root directory (NOT this directory)

1.  Clone the ATS-Postiats repo to a desired location
2. `nix-shell nix/shell.nix`
3. `make -f Makefile_devl all`
4.  confirm `patscc` is on your path, and that `PATSHOME` is set!

## The nix entry points

- `flake.nix` — the flake: `nix build` builds ATS2 from this tree
  (the nixpkgs revision is pinned in `flake.lock`).
- `nix/default.nix` — the same, for the users of the classic nix channels
  (`nix-build nix/default.nix -A build`); it uses the nixpkgs revision that
  is pinned in `flake.lock`, so both entry points agree.
- `nix/build.nix` — builds ATS2 from this tree; the result is a `PATSHOME`.
- `nix/tarball.nix` — builds the release tarball
  (`ATS2-Postiats-<version>.tgz`, see `doc/DISTRIB`).

The stage-0 compiler of the build is an installed ATS2 (the argument
`ats2` of `nix/build.nix`); ATS1 is not needed.
