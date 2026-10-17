#!/usr/bin/env sh

######
#
# Installs the stage-0 compiler used to build src/ (the compiler of this
# repository is written in ATS2, ATS1 is no longer needed): the release
# ats2-postiats-$1 (default 0.4.2) is built from its C sources and installed
# in ${HOME}/ats2-stage0. Then (see travis.yml):
#
#   PATSOPT=${HOME}/ats2-stage0/bin/patsopt
#   STAGE0HOME=${HOME}/ats2-stage0/lib/ats2-postiats-$1
#
######
#
ATSVER=${1:-0.4.2}
#
ATSPACK=ats2-postiats-${ATSVER}
ATSPACKTGZ=${ATSPACK}.tgz
#
ATSLANGURL=\
https://sourceforge.net/projects/ats2-lang/files/ats2-lang/${ATSPACK}
#
######
#
cd ${HOME} || exit 1
#
wget -q -O ${ATSPACKTGZ} ${ATSLANGURL}/${ATSPACKTGZ}/download || exit 1
tar -zxf ${ATSPACKTGZ} || exit 1
#
cd ${ATSPACK} || exit 1
./configure --prefix=${HOME}/ats2-stage0 || exit 1
make || exit 1
make install || exit 1
#
######

###### end of [install-ats2.sh] ######
