#!/bin/sh
# usage: hsdrv2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/hs2 (the ATS2 driver of the test of pats_histaexp) in a staging directory
# (a copy of src, so that the generated files and the objects stay out of the tree). -j via JOBS.
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2; rm -rf $W; mkdir -p $W/hs $W/obj
make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats > /dev/null || exit 1
for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do cp $f $W/; done
cp $L/hsdrv2.dats $L/hs_leaf.hats $L/hs_common.hats $L/hs_hand2.hats $L/hs_compat2.hats $L/hs_cases.hats $L/hs_env2.hats $L/hs_stub.c $W/hs/
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_histaexp pats_histaexp_print pats_histaexp_funlab"
cd $W/obj
patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
( for m in $MODS; do echo "$m"; done; echo hsdrv2 ) | xargs -P ${JOBS:-16} -I{} sh -c "
  if [ {} = hsdrv2 ]; then cd ../hs && $CC -c -o ../obj/{}.o hsdrv2.dats; else $CC -c -o {}.o ../{}.dats; fi || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -40; exit 1; }
$CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o hs_stub.o ../hs/hs_stub.c || exit 1
$CC -o $OUT/hs2 *.o -lgmp || exit 1
