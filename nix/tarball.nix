######
#
# Build the release tarball of ATS2 (ATS/Postiats) from this source tree.
#
# The tarball is the one that is published: ATS2-Postiats-<version>.tgz
# (see doc/DISTRIB).
#
######

{ stdenv
, ats2 ? null
, gmp
, autoconf
, automake
, python3
, version
}:

stdenv.mkDerivation rec {
  name = "ATS2-Postiats-${version}.tgz";

  buildInputs = [ autoconf automake gmp ];
  nativeBuildInputs = [ python3 ];

  src = builtins.filterSource (path: type:
    (toString path) != (toString ../.git)
  ) ../.;

  # ATS1 is not needed: the stage-0 compiler is an installed ATS2 (nixpkgs' ats2)
  PATSOPT = if (ats2 == null) then
    (throw "ATS2: no stage-0 compiler: give an installed ATS2 as the argument [ats2]")
  else "${ats2}/bin/patsopt";
  STAGE0HOME = if (ats2 == null) then "" else "${ats2}/lib/ats2-postiats-${ats2.version}";

  configurePhase = ''
    patchShebangs doc/DISTRIB/ATS-Postiats/autogen.sh
    export PATSHOME=$PWD
  '';

  buildPhase = ''
    make -C src PATSOPT=${PATSOPT} STAGE0HOME=${STAGE0HOME} all
    make -C src CBOOT PATSOPT=$PWD/src/patsopt
    make -f Makefile_devl bin_atsdoc  # (atspackaging uses atsdoc to generate the packaging scripts)
    make -C doc/DISTRIB atspackaging
    make -C doc/DISTRIB atspacktarzvcf
  '';

  installPhase = ''
    mkdir -p $out
    mv doc/DISTRIB/${name} $out
  '';

  shellHook = ''
    export PATSHOME=$PWD
    source ./nix/path_hack.sh
  '';
}
