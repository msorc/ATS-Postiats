{
  description = "Nix flake for ATS2.";

  # nixos-24.05 as of 2024-09-17
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/8f7492cce28977fbf8bd12c72af08b1f6c7c3e49";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          # the stage-0 compiler of the build (an installed ATS2); ATS1 is not needed
          ats2 = pkgs.ats2 or null;
          version = builtins.head (builtins.match "([^\n]*)\n?" (
            builtins.readFile ./VERSION
          ));
      in
      {
        packages = rec {
          # ATS2 (ATS/Postiats) built from this source tree
          ats2 = pkgs.callPackage ./nix/build.nix { inherit version ats2; src = ./.; };
          default = ats2;
        };
        apps = rec {
          patsopt = flake-utils.lib.mkApp {
            drv = self.packages.${system}.ats2;
            name = "patsopt";
          };
          default = patsopt;
        };
      }
    );
}
