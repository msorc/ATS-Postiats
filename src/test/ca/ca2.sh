#!/bin/sh
# usage: ca2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/ca2 (the ATS2 driver of the test of pats_ccomp_emit{,2,3}) in a staging directory
# (a copy of src, so that the generated files and the objects stay out of the tree). -j via JOBS.
# Without REUSE the objects of the last build of the same OUTDIR are reused automatically when nothing that the staging copy
# is built from has changed since (the stamp $OUT/stage2.stamp, as in ../hd/hd2.sh). REUSE=1 keeps the directory whatever
# the stamp says; the stamp is rewritten only by a build that started from the wipe below, after the link succeeded.
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2
stamp=$OUT/stage2.stamp
pb=`command -v patsopt 2>/dev/null`; cb=`command -v patscc 2>/dev/null`
cur=`{ echo "$*"; md5sum $pb $cb $T/*.sats $T/*.dats $T/*.hats $T/*.cats $L/*.dats $L/*.hats $L/ca_stub.c \
  $L/../d2common1.hats $L/../d2compat_hand.hats $L/../d2compat_hand3.hats $L/../d2compat1_hand.hats $L/../d2compat1_hand3.hats $L/../s2env2.hats $L/../s2env1.hats \
  2>/dev/null; } | md5sum | awk '{print $1}'`
wiped=
if [ -n "$REUSE" ]; then
  [ -d $W/obj ] || { wiped=1; REUSE=; rm -rf $W; mkdir -p $W/ca $W/obj; }
elif [ -f "$stamp" ] && [ -d $W/obj ] && [ "`cat $stamp`" = "$cur" ]; then
  REUSE=1
else
  wiped=1; REUSE=; rm -rf $W; mkdir -p $W/ca $W/obj
fi
[ -n "$REUSE" ] || make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
  pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_ccomp_gen.hats pats_ccomp_gen_dats.hats \
  pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats > /dev/null || exit 1
[ -n "$REUSE" ] || for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do cp $f $W/; done
cp $L/*.dats $L/*.hats $L/ca_stub.c $W/ca/
for f in d2common1.hats d2compat_hand.hats d2compat_hand3.hats d2compat1_hand.hats d2compat1_hand3.hats s2env2.hats s2env1.hats; do cp $L/../$f $W/ca/; done
for f in pats_ccomp_emit pats_ccomp_emit2 pats_ccomp_emit3; do cp $T/$f.dats $W/; done
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_sprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util pats_dynexp3 pats_dynexp3_print pats_histaexp pats_histaexp_print pats_histaexp_funlab pats_hidynexp pats_hidynexp_print pats_hidynexp_util pats_ccomp_emit pats_ccomp_emit2 pats_ccomp_emit3"
CHUNKS=`cd $L && ls cacase_[0-9][0-9].dats | sed 's/\.dats$//'`
cd $W/obj; rm -f cacase_*.o cadump.o ca_dbl.o pats_ccomp_emit*.o
[ -n "$REUSE" ] || patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
( if [ -n "$REUSE" ]; then for m in pats_ccomp_emit pats_ccomp_emit2 pats_ccomp_emit3; do echo "$m"; done; else for m in $MODS; do echo "$m"; done; fi; for c in $CHUNKS; do echo "$c"; done; echo cadump; echo ca_dbl ) | xargs -P ${JOBS:-16} -I{} sh -c "
  case {} in cadump|ca_dbl|cacase_*) cd ../ca && $CC -c -o ../obj/{}.o {}.dats;; pats_ccomp_emit*) $CC -c -o {}.o ../{}.dats;; *) $CC -c -o {}.o ../{}.dats;; esac || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -40; exit 1; }
[ -n "$REUSE" ] || $CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o ca_stub.o ../ca/ca_stub.c || exit 1
$CC -o $OUT/ca2 *.o -lgmp || exit 1
[ -z "$wiped" ] || echo "$cur" > $stamp
