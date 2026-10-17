#!/bin/sh
# usage: cc2_2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/cc2 (the ATS2 driver of the ccomp group C2 test) in a staging directory (a copy of src, so that the
# generated files and the objects stay out of the tree). -j via JOBS. REUSE=1 rebuilds only the chunks, the doubles and the driver.
# MOD3 (default: the three modules of src) can name other directories of the three modules (the mutation test replaces one file of the staging directory).
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2
if [ -z "$REUSE" ] || [ ! -d $W/obj ]; then REUSE=; rm -rf $W; mkdir -p $W/cc2 $W/obj; fi
[ -n "$REUSE" ] || make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
  pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats \
  pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats \
  pats_ccomp_gen.hats pats_ccomp_gen_dats.hats pats_ccomp_claulst_gen.hats pats_ccomp_claulst_gen_dats.hats > /dev/null || exit 1
[ -n "$REUSE" ] || for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do cp $f $W/; done
cp $L/*.dats $L/*.hats $L/cc2_state.c $L/cc2_state.h $W/cc2/
for f in d2common1.hats d2compat_hand.hats d2compat_hand3.hats d2compat1_hand.hats d2compat1_hand3.hats s2env2.hats s2env1.hats; do cp $L/../$f $W/cc2/; done
for f in hd_common.hats hd_hand_b1.hats hd_hand_b2.hats; do cp $L/../hd/$f $W/cc2/; done
[ -n "$STAGEONLY" ] && exit 0
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util pats_dynexp3 pats_dynexp3_print pats_histaexp pats_histaexp_print pats_histaexp_funlab pats_hidynexp pats_hidynexp_print pats_hidynexp_util pats_typerase_error pats_typerase_staexp pats_typerase_dynexp pats_typerase_decl pats_ccomp_dynexp pats_ccomp_decl pats_ccomp_claulst"
CHUNKS=`cd $L && ls cc2case_[0-9][0-9].dats | sed 's/\.dats$//'`
cd $W/obj; rm -f cc2case_*.o cc2dump.o cc2_dbl2.o
[ -n "$REUSE" ] || patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
( [ -n "$REUSE" ] || for m in $MODS; do echo "$m"; done; for c in $CHUNKS; do echo "$c"; done; echo cc2dump; echo cc2_dbl2 ) | xargs -P ${JOBS:-16} -I{} sh -c "
  case {} in cc2dump|cc2_dbl2|cc2case_*) cd ../cc2 && $CC -c -o ../obj/{}.o {}.dats;; *) $CC -c -o {}.o ../{}.dats;; esac || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -60; exit 1; }
[ -n "$REUSE" ] || $CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o cc2_state.o ../cc2/cc2_state.c || exit 1
$CC -o $OUT/cc2 *.o -lgmp || exit 1
