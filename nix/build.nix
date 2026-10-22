######
#
# Build ATS2 (ATS/Postiats) from this source tree.
#
# The compiler (src/) is written in ATS2: the stage-0 compiler is an
# installed ATS2 (nixpkgs' ats2, given by the argument [ats2]); ATS1 is
# not needed. The result is installed in $out, which is a PATSHOME: set
#   PATSHOME=$out
# and put $out/bin on the PATH.
#
######

{ stdenv
, gmp
, python3
, version
, src
, ats2 ? null
}:

stdenv.mkDerivation {
  name = "ATS2-Postiats-${version}";
  inherit src;

  nativeBuildInputs = [ python3 ];
  buildInputs = [ gmp ];

  # ATS1 is not needed: the stage-0 compiler is an installed ATS2 (nixpkgs' ats2)
  PATSOPT = if (ats2 == null) then
    (throw "ATS2: no stage-0 compiler: give an installed ATS2 as the argument [ats2]")
  else "${ats2}/bin/patsopt";
  STAGE0HOME = if (ats2 == null) then "" else "${ats2}/lib/ats2-postiats-${ats2.version}";

  dontConfigure = true;

  buildPhase = ''
    export PATSHOME=$PWD
    make -C src PATSOPT=${PATSOPT} STAGE0HOME=${STAGE0HOME} all
    make -f Makefile_devl PATSOPT=$PWD/src/patsopt STAGE0HOME=${STAGE0HOME} all
    make -f Makefile_devl PATSOPT=$PWD/src/patsopt STAGE0HOME=${STAGE0HOME} bin_atsdoc
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/ccomp
    cp bin/patsopt bin/patscc bin/myatscc $out/bin/
    cp src/libatsopt.a $out/lib/
    cp ccomp/atslib/lib/libatslib.a $out/lib/
    cp -r ccomp/runtime $out/ccomp/
    cp -r prelude libats share $out/
  '';

  shellHook = ''
    export PATSHOME=$PWD
    source ./nix/path_hack.sh
  '';
}
