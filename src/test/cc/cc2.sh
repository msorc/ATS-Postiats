#!/bin/sh
# usage: cc2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/cc2 (the ATS2 driver of the test of the core modules of ccomp) in a staging directory
# (a copy of src, so that the generated files and the objects stay out of the tree; the hd test files are copied next to the cc ones). -j via JOBS.
# Without REUSE the objects of the last build of the same OUTDIR are reused automatically when nothing that the staging copy
# is built from has changed since (the stamp $OUT/stage2.stamp, as in ../hd/hd2.sh). REUSE=1 keeps the directory whatever
# the stamp says; the stamp is rewritten only by a build that started from the wipe below, after the link succeeded.
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
H=$L/../hd
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2
stamp=$OUT/stage2.stamp
pb=`command -v patsopt 2>/dev/null`; cb=`command -v patscc 2>/dev/null`
cur=`{ echo "$*"; md5sum $pb $cb $T/*.sats $T/*.dats $T/*.hats $T/*.cats $H/*.dats $H/*.hats $L/*.dats $L/*.hats $L/cc_stub.c \
  $L/../d2common1.hats $L/../d2compat_hand.hats $L/../d2compat_hand3.hats $L/../d2compat1_hand.hats $L/../d2compat1_hand3.hats $L/../s2env2.hats $L/../s2env1.hats \
  2>/dev/null; } | md5sum | awk '{print $1}'`
wiped=
if [ -n "$REUSE" ]; then
  [ -d $W/obj ] || { wiped=1; REUSE=; rm -rf $W; mkdir -p $W/hd $W/obj; }
elif [ -f "$stamp" ] && [ -d $W/obj ] && [ "`cat $stamp`" = "$cur" ]; then
  REUSE=1
else
  wiped=1; REUSE=; rm -rf $W; mkdir -p $W/hd $W/obj
fi
[ -n "$REUSE" ] || make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
  pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats \
  pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats \
  pats_ccomp_gen.hats pats_ccomp_gen_dats.hats > /dev/null || exit 1
[ -n "$REUSE" ] || for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do cp $f $W/; done
cp $H/*.dats $H/*.hats $W/hd/
cp $L/*.dats $L/*.hats $L/cc_stub.c $W/hd/
# the placeholder funlab of hisexp (HSEtyclo) is a real funlab in this test: dump its name (the hd dumper prints the address)
sed -i 's/^fun dd_funlab (x: funlab): void = .*$/fun dd_funlab (x: funlab): void = (dd_ps "funlab#"; fprint_funlab (dd_out, x))/' $W/hd/hd_hand_a?.hats
sed -i 's/^fun dd_instrlst (x: instrlst): void = .*$/fun dd_instrlst (x: instrlst): void = (dd_ps "instrlst#"; dd_int (glist_length ($UN.cast{glist(ptr)} (x))))/' $W/hd/hd_hand_a2.hats
for f in d2common1.hats d2compat_hand.hats d2compat_hand3.hats d2compat1_hand.hats d2compat1_hand3.hats s2env2.hats s2env1.hats; do cp $L/../$f $W/hd/; done
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util pats_dynexp3 pats_dynexp3_print pats_histaexp pats_histaexp_print pats_histaexp_funlab pats_hidynexp pats_hidynexp_print pats_hidynexp_util pats_typerase_error pats_typerase_staexp pats_typerase_dynexp pats_typerase_decl pats_ccomp pats_ccomp_print pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_d2env pats_ccomp_funlab pats_ccomp_funent pats_ccomp_util pats_ccomp_instrseq"
CHUNKS=`cd $L && ls ccase_[0-9][0-9].dats | sed 's/\.dats$//'`
cd $W/obj; rm -f ccase_*.o ccdump.o
[ -n "$REUSE" ] || patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
( [ -n "$REUSE" ] || for m in $MODS; do echo "$m"; done; for c in $CHUNKS; do echo "$c"; done; echo ccdump ) | xargs -P ${JOBS:-16} -I{} sh -c "
  case {} in ccdump|ccase_*) cd ../hd && $CC -c -o ../obj/{}.o {}.dats;; *) $CC -c -o {}.o ../{}.dats;; esac || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -40; exit 1; }
[ -n "$REUSE" ] || $CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o cc_stub.o ../hd/cc_stub.c || exit 1
$CC -o $OUT/cc2 *.o -lgmp || exit 1
[ -z "$wiped" ] || echo "$cur" > $stamp
