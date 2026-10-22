#!/usr/bin/env sh

######
#
# Check that the release version is declared consistently:
#
#   * VERSION
#   * doc/DISTRIB/ATS-Postiats/configure.ac (AC_INIT)
#   * src/pats_basics.sats (PATS_{MAJOR,MINOR,MICRO}_VERSION)
#   * CHANGES-ats2 (a section that bears the version)
#   * doc/DISTRIB/ATS-Postiats/RELEASE/ats2-postiats-<version>-release.html
#     (generated from the changelog by make_release_notes.sh)
#
# The release script (share/SCRIPT/build_release.sh) refuses to run when
# the version in configure.ac does not match VERSION; this script checks
# the same thing, plus the other places, so that the skew is caught before
# a release is attempted.
#
# usage: check_release_version.sh [VERSION]
#
######

SCRIPTDIR=$(dirname "$0")
PATSHOME=${PATSHOME:-$(cd "${SCRIPTDIR}/../.." && pwd)}
export PATSHOME

VERSION=$1
if [ -z "${VERSION}" ] ; then
  VERSION=$(cat "${PATSHOME}/VERSION")
fi

STATUS=0

report() {
  # $1: OK|FAIL, $2: message
  if [ "$1" = "OK" ] ; then
    echo "SUCCESS: $2"
  else
    echo "FAILURE: $2"
    STATUS=1
  fi
}

######

if grep -Fxq "AC_INIT([ATS2/Postiats], [${VERSION}], [gmpostiats@gmail.com])" \
   "${PATSHOME}/doc/DISTRIB/ATS-Postiats/configure.ac" ; then
  report OK "configure.ac declares version ${VERSION}"
else
  report FAIL "configure.ac does not declare version ${VERSION}"
fi

######

MAJOR=$(echo "${VERSION}" | cut -d. -f1)
MINOR=$(echo "${VERSION}" | cut -d. -f2)
MICRO=$(echo "${VERSION}" | cut -d. -f3)

if grep -Fxq "#define PATS_MAJOR_VERSION ${MAJOR}" \
   "${PATSHOME}/src/pats_basics.sats" &&
   grep -Fxq "#define PATS_MINOR_VERSION ${MINOR}" \
   "${PATSHOME}/src/pats_basics.sats" &&
   grep -Fxq "#define PATS_MICRO_VERSION ${MICRO}" \
   "${PATSHOME}/src/pats_basics.sats" ; then
  report OK "src/pats_basics.sats declares version ${VERSION}"
else
  report FAIL "src/pats_basics.sats does not declare version ${VERSION}"
fi

######

if awk -v ver="${VERSION}" '$0 == ver { found = 1 } END { exit !found }' \
   "${PATSHOME}/CHANGES-ats2" ; then
  report OK "CHANGES-ats2 has a section for version ${VERSION}"
else
  report FAIL "CHANGES-ats2 has no section for version ${VERSION}"
fi

######

RELDIR="${PATSHOME}/doc/DISTRIB/ATS-Postiats/RELEASE"
RELEASE="${RELDIR}/ats2-postiats-${VERSION}-release.html"

if [ ! -f "${RELEASE}" ] ; then
  report FAIL "missing ${RELEASE}"
else
  TMP=$(mktemp)
  if sh "${PATSHOME}/share/SCRIPT/make_release_notes.sh" "${VERSION}" "${TMP}" \
       > /dev/null ; then
    if cmp -s "${TMP}" "${RELEASE}" ; then
      report OK "the release notes of ${VERSION} are up-to-date"
    else
      report FAIL "the release notes of ${VERSION} are out-of-date; run share/SCRIPT/make_release_notes.sh"
    fi
  else
    report FAIL "cannot regenerate the release notes of ${VERSION}"
  fi
  rm -f "${TMP}"
fi

######

if [ "${STATUS}" = "0" ] ; then
  echo "SUCCESS: the release version ${VERSION} is declared consistently."
fi

exit ${STATUS}

###### end of [check_release_version.sh] ######
