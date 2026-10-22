######
#
# The nix entry points of ATS2 (ATS/Postiats).
#
# The nixpkgs revision is the one that is pinned in flake.lock, so that
# this file and flake.nix use the same nixpkgs.
#
#   tarball : the release tarball (ATS2-Postiats-<version>.tgz)
#   build   : ATS2 built from this source tree (a PATSHOME)
#
######

let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);

  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-${lock.nodes.nixpkgs.locked.rev}";
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
  };

  pkgs = import nixpkgs {};

  # the stage-0 compiler of the build (an installed ATS2); ATS1 is not needed
  ats2 = pkgs.ats2 or null;

  version = builtins.head (builtins.match "([^\n]*)\n?" (
    builtins.readFile ../VERSION
  ));
in rec {
  tarball = pkgs.callPackage ./tarball.nix { inherit version ats2; };

  build   = pkgs.callPackage ./build.nix { inherit version ats2; src = ../.; };
}
