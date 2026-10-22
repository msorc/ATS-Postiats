# A shell with ATS2 (ATS/Postiats) built from this source tree.
#
# The nixpkgs revision is the one that is pinned in flake.lock.

let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);

  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-${lock.nodes.nixpkgs.locked.rev}";
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
  };

  pkgs = import nixpkgs {};

  version = builtins.head (builtins.match "([^\n]*)\n?" (
    builtins.readFile ../VERSION
  ));
in
pkgs.callPackage ./build.nix { inherit version; src = ../.; }
