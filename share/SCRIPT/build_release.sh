#!/usr/bin/env sh

######
#
# HX-2018-12-09:
# Submitted by Richard Kent
# after fixes added to support
# the build and release of both
# ATS2-intknd and ATS2-gmpknd
#
# There is now ONE tarball, ATS2-Postiats-x.y.z.tgz, for both kinds
# of the integers of the constraint solver: ./configure uses libgmp
# when <gmp.h> is there and falls back to intknd with --without-gmp
# (see doc/DISTRIB/Makefile.atxt).
#
######
#
# HX-2018-03-17:
# Created based on a version by
# Brandon Barker
# <brandon dot barker at cornell dot edu>
#
# The following packages are built by the script:
# ATS-Postiats, ATS-Postiats-contrib, and ATS-include
#
######
#
# HX-2018-03-18:
# A typical use of this script
# (for versions 0.3.10+ of ATS only):
# the first argument to the script is the release to be built:
#
# cd /tmp
# sh ${PATSHOME}/share/SCRIPT/build_release.sh 0.3.10
# <
# Upload the following three built packages
# /tmp/ATS-Postiats/doc/DISTRIB/ATS2-Postiats-x.y.z.tgz
# /tmp/ATS-Postiats/doc/DISTRIB/ATS2-Postiats-contrib-x.y.z.tgz
# /tmp/ATS-Postiats/doc/DISTRIB/ATS2-Postiats-include-x.y.z.tgz
# >
# rm -rf /tmp/ATS-Postiats
# rm -rf /tmp/ATS-Postiats-contrib
#
######
#
# HX-2020-11-24:
# Please make sure before each release that the following version
# numbers are properly modified in ${PATSHOME}/src/pats_basics.sats:
#
# #define PATS_MAJOR_VERSION 0
# #define PATS_MINOR_VERSION 4
# #define PATS_MICRO_VERSION 2
#
######
#
# PWD=$(pwd)
#
######

PATSVERSION=$1

######

GIT=$(which git)
# atsdoc (ATS2; the generator of the packaging scripts): built here by
# `make -f Makefile_devl bin_atsdoc` (bin/atsdoc); no ATS1 is needed

######

check_git() {
    if [ -x "$GIT" ] ;
    then echo "$GIT found.";
    else echo "$GIT not found." && exit 1;
    fi
}

######

######

export_pats() {
    export PATSHOME=${PWD}/ATS-Postiats
    export PATSCONTRIB=${PWD}/ATS-Postiats-contrib
}

######

clone_Postiats() {
    $GIT clone --depth 1 \
	 https://github.com/githwxi/ATS-Postiats.git \
	|| (cd ATS-Postiats && $GIT pull origin master)
}

######

clone_Postiats_contrib() {
    $GIT clone --depth 1 \
	 https://github.com/githwxi/ATS-Postiats-contrib.git \
	|| (cd ATS-Postiats-contrib && $GIT pull origin master)
}

######

check_version() {
    if [ -z "$PATSVERSION" ] ; then
	PATSVERSION=$(cat "${PATSHOME}/VERSION")
    fi
}

######

check_ac_init_version() {

    CONFIGURE_AC="${PATSHOME}/doc/DISTRIB/ATS-Postiats/configure.ac"
    AC_INIT_VERSION="AC_INIT([ATS2/Postiats], [${PATSVERSION}], [gmpostiats@gmail.com])"

    if grep -Fxq "$AC_INIT_VERSION" ${CONFIGURE_AC}
    then
	echo "SUCCESS: Correct Postiats version found in configure.ac!"
    else
	echo "FAILURE: Incorrect Postiats version found in configure.ac!"
	#
	# HX: negative exit values are usually for systems code
	#
	exit 1;
    fi
}

######

checkout_build() {
    ( cd "$PATSHOME" && \
	    $GIT checkout -b "tags/v${PATSVERSION}"
    )
}

# The compiler (src/) is written in ATS2: the stage-0 patsopt is the bootstrap bundle
# (make bootstrap) or PATSOPT=... STAGE0HOME=... (an installed ATS2), see src/README.
# `make -C src CBOOT` generates the bootstrap C bundle (src/CBOOT) of the release for
# both integer kinds. atsdoc (ATS2, `make tools`) generates the packaging scripts
# (atspackaging). `make dist` is the packaging of the root Makefile: it checks that
# autoheader, aclocal and autoconf (./autogen.sh) are there, makes the single tarball
# ATS2-Postiats-x.y.z.tgz and ATS2-Postiats-include-x.y.z.tgz and their .sha256 files.
#
build_release() {
    ( cd "$PATSHOME" && \
      make bootstrap && \
      make && \
      make tools && \
      make -C src CBOOT && \
      make dist
    )
}

######

build_release_contrib() {
    clone_Postiats_contrib

    ( cd "$PATSHOME" &&
	    make -C doc/DISTRIB -f Makefile atscontribing && \
	    make -C doc/DISTRIB -f Makefile atscontribtarzvcf
    )
}

######

build_cleanall() {
    (cd $PATSHOME && make -f Makefile_devl src_cleanall)
    (cd $PATSHOME && make -f Makefile_devl atslib_cleanall)
}

_usage() {
    echo "$1"
    local usage="usage: $(basename "$0") [VERSION] [KIND]"
    echo "$usage"
    echo "VERSION"
    echo "x.x.x         release version"
    echo
    echo "KIND"
    echo "release       ATS2: one tarball (./configure uses gmplib when it is there,"
    echo "              ./configure --without-gmp does not need it)"
    echo "contrib       ATS2-contrib: contributed packages"
    echo "(intknd, gmpknd and both are the old names of release)"
    exit
}


main() {

    [ -z "$2" ] && _usage "Please specify build KIND"
    [ -z "$1" ] && _usage "Please specify build VERSION"

    check_git
    export_pats
    clone_Postiats
    check_version
    check_ac_init_version
    checkout_build

    case "$2" in
	release|intknd|gmpknd|both)
	    build_release && build_cleanall ;;
	contrib)
	    build_release_contrib && build_cleanall ;;
	*) _usage ;;
    esac

    ls -alh "$PATSHOME/doc/DISTRIB/"ATS2-*.tgz

}

main "$1" "$2"

###### end of [build_release.sh] ######
