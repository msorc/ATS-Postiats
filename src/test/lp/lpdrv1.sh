#!/bin/sh
# usage: lpdrv1.sh gmp|int OUTDIR     Builds the ATS1 reference driver OUTDIR/lp1_<kind> from the ATS1 sources of $ATS1REF
# (atscc, -O2 -fwrapv). Environment as for ../pardump1.sh: ATSHOME (an ATS1 install), ATSHOMERELOC=ATS-0.2.12, atscc and a gcc
# wrapper accepting K&R C (-std=gnu89 -fpermissive) first on the PATH. The sources are compiled by themselves (the prebuilt
# objects of src/ have the names of the directory where they were built).
K=$1; OUT=${2:-.}
L=`cd \`dirname $0\` && pwd`
S=`cd ${ATS1REF:?ATS1REF not set: a checkout of the old (ATS1) src/ is needed (see src/README)} && pwd`
[ -n "$S" ] || exit 1
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/w1_$K; rm -rf $W; mkdir -p $W; cd $W || exit 1
cp $L/lpdrv1.dats $L/lpdrv_common.hats $L/lpdrv.c $L/lpdrv.h .
sed 's/"mac#/"/' $L/lpdrv_decls.hats | grep -v '^// ' > lpdrv_decls1.hats
sed -i "s|\"pats_|\"$S/pats_|g" lpdrv1.dats
if [ "$K" = gmp ]; then D="-DATS LPKNDGMP"; else D=""; fi
atscc -O2 -fwrapv -I$S -IATS $S -D_ATS_NGC $D -I. -o $OUT/lp1_$K lpdrv1.dats lpdrv.c \
  $S/pats_intinf.dats $S/pats_utils.dats $S/pats_lintprgm.dats $S/pats_lintprgm_print.dats \
  $S/pats_location.sats $S/pats_intinf.sats $S/pats_lintprgm.sats $S/pats_utils.sats $S/pats_filename.sats \
  $S/pats_basics.sats $S/pats_symbol.sats $S/pats_error.sats -lgmp > $W/build.log 2>&1 || { cat $W/build.log; exit 1; }
rm -rf $W
