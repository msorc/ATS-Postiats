#!/bin/sh
# usage: hsdrv1.sh OUTDIR    Builds the ATS1 reference driver OUTDIR/hs1 of the test of pats_histaexp from the ATS1 sources of $ATS1REF
# (the modules are compiled here, with the same paths, because the objects of src/ have the mangled names of the directory where they were
# built). Environment as for ../pardump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, atscc, a gcc wrapper accepting K&R C).
OUT=$1
L=`cd \`dirname $0\` && pwd`
S=`cd ${ATS1REF:?ATS1REF not set: a checkout of the old (ATS1) src/ is needed (see src/README)} && pwd`
[ -n "$S" ] || exit 1
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage1; rm -rf $W; mkdir -p $W
cp $L/hsdrv1.dats $L/hs_leaf.hats $L/hs_common.hats $L/hs_hand1.hats $L/hs_compat1.hats $L/hs_cases.hats $L/hs_env1.hats $L/hs_stub.c $W/
cd $W
sed -i "s|\"pats_|\"$S/pats_|g" hsdrv1.dats
MODS="error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print staexp2_sort staexp2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 stacst2 staexp2_solve namespace histaexp histaexp_print"
SATS="error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 staexp2 staexp2_util staexp2_error namespace stacst2 staexp2_solve histaexp symmap dynexp2 dynexp3 patcst2 jsonize dynexp1 trans2_env trans3_env"
mkdir -p obj; cd obj
CC="atscc -c -I$S -IATS $S -D_ATS_NGC"
( for m in $MODS; do echo "$S/pats_$m.dats"; done; for m in $SATS; do echo "$S/pats_$m.sats"; done ) | xargs -P ${JOBS:-16} -I{} sh -c "$CC {} > /dev/null 2>&1 || echo FAILED {}" > $OUT/build1.log 2>&1
grep -q FAILED $OUT/build1.log && { head -20 $OUT/build1.log; exit 1; }
cd $W
atscc -c -I$S -IATS $S -I. -D_ATS_NGC -o hsdrv1_dats.o hsdrv1.dats > $OUT/build1b.log 2>&1 || { head -30 $OUT/build1b.log; exit 1; }
gcc -c -o hs_stub.o hs_stub.c
atscc -o $OUT/hs1 hsdrv1_dats.o hs_stub.o obj/*.o -lgmp > $OUT/build1c.log 2>&1 || { grep -v "^atscc\|^gcc" $OUT/build1c.log | head -20; exit 1; }
