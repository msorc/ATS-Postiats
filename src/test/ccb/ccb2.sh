#!/bin/sh
# usage: ccb2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/ccb2 (the ATS2 driver of the ccomp group B test) in a staging directory (a copy of src, so that the generated files
# and the objects stay out of the tree): the ports of src/, the doubles of test/ccb/dbl (the phase 1 modules of pats_ccomp.sats), the generated cases. -j via JOBS.
# REUSE=1 keeps the objects of the modules of src (only the driver and the chunks are rebuilt). Without REUSE the objects of the last build of the
# same OUTDIR are reused automatically when nothing that the staging copy is built from has changed since (the stamp $OUT/stage2.stamp, as in
# ../hd/hd2.sh: the spec and the arenagen of the pats_ccomp encodings and the dbl doubles belong to the stamp). The stamp is rewritten only by a
# build that started from the wipe below.
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2
stamp=$OUT/stage2.stamp
pb=`command -v patsopt 2>/dev/null`; cb=`command -v patscc 2>/dev/null`
cur=`{ echo "$*"; md5sum $pb $cb $T/pats_ccomp.spec $T/../utils/arenagen/arenagen.py \
  $T/*.sats $T/*.dats $T/*.hats $T/*.cats $L/*.dats $L/*.hats $L/ccb_stub.c $L/ccb_stub.h $L/dbl/*.dats \
  $L/../d2common1.hats $L/../d2compat_hand3.hats $L/../s2env2.hats $L/../hd/hd_common.hats $L/../hd/hd_hand_b2.hats \
  2>/dev/null; } | md5sum | awk '{print $1}'`
wiped=
if [ -n "$REUSE" ]; then
  [ -d $W/obj ] || { wiped=1; REUSE=; rm -rf $W; mkdir -p $W/ccb $W/obj; }
elif [ -f "$stamp" ] && [ -d $W/obj ] && [ "`cat $stamp`" = "$cur" ]; then
  REUSE=1
else
  wiped=1; REUSE=; rm -rf $W; mkdir -p $W/ccb $W/obj
fi
mkdir -p $W/ccb
if [ -z "$REUSE" ]; then
  make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
    pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats \
    pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats > /dev/null || exit 1
  ARENAGEN="python3 $T/../utils/arenagen/arenagen.py"
  ( cd $T && $ARENAGEN --global sats pats_ccomp.spec > $W/pats_ccomp_gen.hats && $ARENAGEN --global --compact dats pats_ccomp.spec > $W/pats_ccomp_gen_dats.hats ) || exit 1
  for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do case $f in */pats_ccomp_gen.hats|*/pats_ccomp_gen_dats.hats) ;; *) cp $f $W/;; esac; done
  cp $L/dbl/*.dats $W/
fi
cp $L/*.dats $L/*.hats $L/ccb_stub.c $L/ccb_stub.h $W/ccb/
cp $L/../hd/hd_common.hats $L/../hd/hd_hand_b2.hats $L/../d2common1.hats $L/../d2compat_hand3.hats $L/../s2env2.hats $W/ccb/
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_sprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util pats_dynexp3 pats_dynexp3_print pats_histaexp pats_histaexp_print pats_histaexp_funlab pats_hidynexp pats_hidynexp_print pats_hidynexp_util pats_typerase_error pats_typerase_staexp pats_typerase_dynexp pats_typerase_decl pats_ccomp pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_funlab pats_ccomp_funent pats_ccomp_d2env pats_ccomp_instrseq pats_ccomp_util pats_ccomp_hitype pats_ccomp_hipat pats_ccomp_subst pats_ccomp_template pats_ccomp_main"
CHUNKS=`cd $L && ls ccbcase_[0-9][0-9].dats | sed 's/\.dats$//'`
cd $W/obj; rm -f ccbcase_*.o ccbdump.o ccb_stub.o
[ -n "$REUSE" ] || patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
( [ -n "$REUSE" ] || for m in $MODS; do echo "$m"; done; for c in $CHUNKS; do echo "$c"; done; echo ccbdump ) | xargs -P ${JOBS:-16} -I{} sh -c "
  case {} in ccbdump|ccbcase_*) cd ../ccb && $CC -c -o ../obj/{}.o {}.dats;; *) $CC -c -o {}.o ../{}.dats;; esac || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -60; exit 1; }
[ -n "$REUSE" ] || $CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o ccb_stub.o ../ccb/ccb_stub.c || exit 1
$CC -o $OUT/ccb2 *.o -lgmp || exit 1
[ -z "$wiped" ] || echo "$cur" > $stamp
