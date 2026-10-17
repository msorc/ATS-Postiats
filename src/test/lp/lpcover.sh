#!/bin/sh
# usage: lpcover.sh gmp|int PROBLEMS...   The coverage (gcov, by ATS line) of pats_lintprgm*.dats by the driver on the
# given problem files. Builds in $LPWORK (default /tmp/lpcover_$$), prints the unexecuted lines of every file.
K=$1; shift
L=`cd \`dirname $0\` && pwd`
T=$L/../..
W=${LPWORK:-/tmp/lpcover_$$}
rm -rf $W; mkdir -p $W/test/lp
cp $T/pats_lintprgm* $T/pats_utils.dats $T/pats_utils.sats $T/pats_intinf* $T/pats_basics.* $T/pats_location* $T/pats_filename.sats $T/pats_symbol.sats $T/pats_label.sats $T/pats_params.hats $T/pats_error.sats $W/ 2>/dev/null
cp $T/*.cats $W/ 2>/dev/null
cp $L/lpdrv2.dats $L/lpdrv_common.hats $L/lpdrv_decls.hats $L/lpdrv.c $L/lpdrv.h $W/test/lp/
cd $W/test/lp || exit 1
if [ "$K" = gmp ]; then D="-DATS LPKNDGMP"; else D=""; fi
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I. -I$PATSHOME -I$PATSHOME/ccomp/runtime"
for f in lpdrv2.dats ../../pats_lintprgm.dats ../../pats_utils.dats ../../pats_intinf.dats; do
  b=`basename $f .dats`
  patsopt --gline $D --output ${b}_dats.c -d $f || exit 1
done
gcc -O0 --coverage -w $CF -o drv lpdrv2_dats.c pats_lintprgm_dats.c pats_utils_dats.c pats_intinf_dats.c lpdrv.c -L$PATSHOME/ccomp/atslib/lib -lgmp 2>&1 | head
for p in "$@"; do ./drv $p > /dev/null; done
gcov drv-lpdrv2_dats.gcda drv-pats_lintprgm_dats.gcda > /dev/null 2>&1
python3 $L/lpgcov.py pats_lintprgm*.dats.gcov
