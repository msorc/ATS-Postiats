#!/bin/sh
# usage: ccb1.sh OUTDIR    Builds the ATS1 reference driver OUTDIR/ccb1 of the ccomp group B test against the ATS1-built objects of $SRC (the
# objects of the main tree: SRC=/path/to/ATS-Postiats/src). Environment as for ../hd/hd1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, atscc, a gcc wrapper accepting K&R C).
OUT=$1
L=`cd \`dirname $0\` && pwd`
S=`cd ${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}} && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage1; rm -rf $W; mkdir -p $W
cp $L/*.dats $L/*.hats $L/ccb_stub.c $L/ccb_stub.h $W/
cp $L/../hd/hd_common.hats $L/../hd/hd_hand_b1.hats $L/../d2common1.hats $L/../d2compat1_hand3.hats $L/../s2env1.hats $W/
cd $W
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 stacst2 staexp2_solve namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util dynexp3 dynexp3_print histaexp histaexp_print histaexp_funlab hidynexp hidynexp_print hidynexp_util typerase_error typerase_staexp typerase_dynexp typerase_decl ccomp ccomp_tmplab ccomp_tmpvar ccomp_funlab ccomp_funent ccomp_d2env ccomp_instrseq ccomp_util ccomp_hitype ccomp_hipat ccomp_subst ccomp_template ccomp_main; do OBJS="$OBJS $S/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans1_env trans2 trans2_env trans3_env dynexp2 dynexp3 dmacro2 trans3 patcst2 jsonize dyncst2 symmap symenv histaexp hidynexp typerase ccomp; do [ -f $S/pats_${m}_sats.o ] && OBJS="$OBJS $S/pats_${m}_sats.o"; done
CHUNKS=`ls ccbcase1_[0-9][0-9].dats | sed 's/\.dats$//'`
for c in $CHUNKS; do OBJS="$OBJS ${c}_dats.o"; done
( for c in $CHUNKS; do echo $c; done ) | xargs -P ${JOBS:-16} -I{} sh -c "atscc -I$S -IATS $S -D_ATS_NGC -c {}.dats > $OUT/build1_{}.log 2>&1 || echo FAILED {}" > $OUT/build1.log 2>&1
grep -q FAILED $OUT/build1.log && { head -20 $OUT/build1.log; for f in $OUT/build1_*.log; do grep -l "error" $f; done | head -3; exit 1; }
gcc -c -o ccb_stub.o ccb_stub.c
atscc -I$S -IATS $S -D_ATS_NGC -o $OUT/ccb1 ccbdump1.dats ccb_stub.o $OBJS -lats -lgmp > $OUT/build1b.log 2>&1 || { grep -v "^atscc\|^gcc" $OUT/build1b.log | head -40; exit 1; }
