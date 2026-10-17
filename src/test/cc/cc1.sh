#!/bin/sh
# usage: cc1.sh OUTDIR    Builds the ATS1 reference driver OUTDIR/cc1 of the test of the core modules of ccomp against the ATS1-built objects of $SRC
# (the objects of an ATS1 build of the old src: ATS1REF=/path/to/it). Environment as for ../hd/hd1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12,
# atscc, a gcc wrapper accepting K&R C).
OUT=$1
L=`cd \`dirname $0\` && pwd`
H=$L/../hd
S=`cd ${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}} && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage1; rm -rf $W; mkdir -p $W
cp $H/*.dats $H/*.hats $W/
cp $L/*.dats $L/*.hats $L/cc_stub.c $W/
# the placeholder funlab of hisexp (HSEtyclo) is a real funlab in this test: dump its name (the hd dumper prints the address)
sed -i 's/^fun dd_funlab (x: funlab): void = .*$/fun dd_funlab (x: funlab): void = (dd_ps "funlab#"; fprint_funlab (dd_out, x))/' $W/hd_hand_a?.hats
sed -i 's/^fun dd_instrlst (x: instrlst): void = .*$/fun dd_instrlst (x: instrlst): void = (dd_ps "instrlst#"; dd_int (list_length ($UN.cast{List (ptr)} (x))))/' $W/hd_hand_a1.hats
for f in d2common1.hats d2compat_hand.hats d2compat_hand3.hats d2compat1_hand.hats d2compat1_hand3.hats s2env2.hats s2env1.hats; do cp $L/../$f $W/; done
cd $W
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 stacst2 staexp2_solve namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util dynexp3 dynexp3_print histaexp histaexp_print histaexp_funlab hidynexp hidynexp_print hidynexp_util typerase_error typerase_staexp typerase_dynexp typerase_decl ccomp ccomp_print ccomp_tmplab ccomp_tmpvar ccomp_d2env ccomp_funlab ccomp_funent ccomp_util ccomp_instrseq; do OBJS="$OBJS $S/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans1_env trans2 trans2_env trans3_env dynexp2 dynexp3 dmacro2 trans3 patcst2 jsonize dyncst2 symmap symenv histaexp hidynexp typerase ccomp; do [ -f $S/pats_${m}_sats.o ] && OBJS="$OBJS $S/pats_${m}_sats.o"; done
CHUNKS=`ls ccase1_[0-9][0-9].dats | sed 's/\.dats$//'`
for c in $CHUNKS; do OBJS="$OBJS ${c}_dats.o"; done
( for c in $CHUNKS; do echo $c; done ) | xargs -P ${JOBS:-16} -I{} sh -c "atscc -I$S -IATS $S -D_ATS_NGC -c {}.dats > $OUT/build1_{}.log 2>&1 || echo FAILED {}" > $OUT/build1.log 2>&1
grep -q FAILED $OUT/build1.log && { head -20 $OUT/build1.log; for f in $OUT/build1_*.log; do grep -l "error" $f; done | head -3; exit 1; }
gcc -c -o cc_stub.o cc_stub.c
atscc -I$S -IATS $S -D_ATS_NGC -o $OUT/cc1 ccdump1.dats cc_stub.o $OBJS -lats -lgmp > $OUT/build1b.log 2>&1 || { grep -v "^atscc\|^gcc" $OUT/build1b.log | head -30; exit 1; }
