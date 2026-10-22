#!/usr/bin/env sh

######
#
# Generate the release notes of an ATS2 release from the changelog.
#
# The changelog (CHANGES-ats2) is the single source of truth: the section
# that bears the release version is turned into the HTML file
#   doc/DISTRIB/ATS-Postiats/RELEASE/ats2-postiats-<version>-release.html
# so that the two can never disagree.
#
# usage: make_release_notes.sh [VERSION] [OUTFILE]
#
# The version defaults to the content of the file VERSION. The output file
# defaults to doc/DISTRIB/ATS-Postiats/RELEASE/ats2-postiats-<version>-release.html
# and is written in place; use the script check_release_version.sh to verify
# that the committed file is up-to-date.
#
######

PWD=$(pwd)
SCRIPTDIR=$(dirname "$0")
PATSHOME=${PATSHOME:-$(cd "${SCRIPTDIR}/../.." && pwd)}
export PATSHOME

CHANGES="${PATSHOME}/CHANGES-ats2"
RELDIR="${PATSHOME}/doc/DISTRIB/ATS-Postiats/RELEASE"

VERSION=$1
if [ -z "${VERSION}" ] ; then
  VERSION=$(cat "${PATSHOME}/VERSION")
fi

if [ ! -f "${CHANGES}" ] ; then
  echo "FAILURE: cannot find ${CHANGES}" && exit 1
fi

######

section=$(awk -v ver="${VERSION}" '
  # a section header is a line that is exactly the version number
  $0 == ver { inside = 1; next }
  # the section ends at the next "######" separator
  inside && $0 ~ /^######$/ { exit }
  inside { print }
' "${CHANGES}")

if [ -z "${section}" ] ; then
  echo "FAILURE: no section for version ${VERSION} in ${CHANGES}" && exit 1
fi

######

OUT=$2
if [ -z "${OUT}" ] ; then
  OUT="${RELDIR}/ats2-postiats-${VERSION}-release.html"
fi

{
cat <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>ATS2-${VERSION}</title>
</head><!--head-->

<body>

<H2>
ats2-postiats-${VERSION}:
</H2>

<pre>

EOF
echo "${section}"
cat <<EOF

</pre>

</body><!--body-->
</html><!--html-->
EOF
} > "${OUT}"

echo "wrote ${OUT}"
