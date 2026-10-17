#!/bin/sh
# usage: lpdrv2.sh gmp|int OUT [CFLAGS...]    Builds the ATS2 driver OUT from ../.. (patscc; default -O2 -fwrapv).
# T2=<dir> uses the sources of another copy of src/ (the mutations of lpmutate.py).
K=$1; OUT=$2; shift; shift
[ $# -eq 0 ] && set -- -O2 -fwrapv
L=`cd \`dirname $0\` && pwd`
T=${T2:-$L/../..}
T=`cd $T && pwd`
if [ "$K" = gmp ]; then D="-DATS LPKNDGMP"; else D=""; fi
W=`mktemp -d`
mkdir -p $W/test/lp
cp $L/lpdrv2.dats $L/lpdrv_common.hats $L/lpdrv_decls.hats $L/lpdrv.c $L/lpdrv.h $W/test/lp/
for f in $T/pats_lintprgm* $T/pats_utils.* $T/pats_intinf* $T/pats_basics.* $T/pats_location* $T/pats_filename.sats \
  $T/pats_symbol.sats $T/pats_label.sats $T/pats_params.hats $T/pats_assert.hats $T/pats_error.sats $T/*.cats; do [ -f $f ] && cp $f $W/; done
case $OUT in /*) ;; *) OUT=`pwd`/$OUT;; esac
cd $W/test/lp
patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I. $D "$@" -o $OUT lpdrv2.dats ../../pats_lintprgm.dats \
  ../../pats_utils.dats ../../pats_intinf.dats lpdrv.c -lgmp > $W/build.log 2>&1 || { cat $W/build.log; rm -rf $W; exit 1; }
rm -rf $W
