#!/bin/sh
# usage: cc1_2.sh OUTDIR [CFLAGS...]    Builds OUTDIR/cc1_2 (the ATS2 driver of the test of pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}) in a staging
# directory (a copy of src, so that the generated files and the objects stay out of the tree). -j via JOBS.
#   CC1_REAL=0 (default if a module of phase 1 is missing from src): use the test double cc1_dbl2.dats for the functions of pats_ccomp.dats, instrseq and funent;
#   the modules of phase 1 that exist in $CC1_P1 (default: src) are used, the others are the doubles (a missing tmplab/tmpvar/funlab/d2env is taken from $CC1_P1B).
# Without REUSE the objects of the last build of the same OUTDIR are reused automatically when nothing that the staging copy is built from has changed
# since (the stamp $OUT/stage2.stamp, as in ../hd/hd2.sh: the phase-1 doubles and the sources of $CC1_SRC belong to the stamp). The stamp is rewritten
# only by a build that started from the wipe below.
OUT=$1; shift
L=`cd \`dirname $0\` && pwd`
T=`cd $L/../.. && pwd`
mkdir -p $OUT; OUT=`cd $OUT && pwd`
W=$OUT/stage2
P1=${CC1_P1:-$T}
S1=${CC1_SRC:-$T}
stamp=$OUT/stage2.stamp
pb=`command -v patsopt 2>/dev/null`; cb=`command -v patscc 2>/dev/null`
cur=`{ echo "$* CC1_P1=$P1 CC1_SRC=$S1"; md5sum $pb $cb $T/*.sats $T/*.dats $T/*.hats $T/*.cats $L/*.dats $L/*.hats $L/*.c $L/../s2env2.hats \
  $S1/pats_ccomp_ccompenv.dats $S1/pats_ccomp_environ.dats $S1/pats_ccomp_caseof.dats $S1/pats_ccomp_looping.dats $S1/pats_ccomp_trywith.dats $S1/pats_ccomp_lazyeval.dats \
  $P1/pats_ccomp.dats $P1/pats_ccomp_print.dats $P1/pats_ccomp_tmplab.dats $P1/pats_ccomp_tmpvar.dats $P1/pats_ccomp_d2env.dats $P1/pats_ccomp_funlab.dats \
  $P1/pats_ccomp_funent.dats $P1/pats_ccomp_instrseq.dats $P1/pats_ccomp_util.dats \
  $P1/pats_ccomp.sats $P1/pats_ccomp.spec $P1/pats_ccomp_gen.hats $P1/pats_ccomp_gen_dats.hats \
  2>/dev/null; } | md5sum | awk '{print $1}'`
wiped=
if [ -n "$REUSE" ]; then
  [ -d $W/obj ] || { wiped=1; REUSE=; rm -rf $W; mkdir -p $W/cc1 $W/obj; }
elif [ -f "$stamp" ] && [ -d $W/obj ] && [ "`cat $stamp`" = "$cur" ]; then
  REUSE=1
else
  wiped=1; REUSE=; rm -rf $W; mkdir -p $W/cc1 $W/obj
fi
[ -n "$REUSE" ] || make -C $T pats_staexp2_gen.hats pats_staexp2_gen_dats.hats pats_staexp2_error_gen.hats pats_staexp2_error_gen_dats.hats pats_dynexp2_gen.hats pats_dynexp2_gen_dats.hats \
  pats_dynexp3_gen.hats pats_dynexp3_gen_dats.hats pats_hidynexp_gen.hats pats_hidynexp_gen_dats.hats pats_typerase_gen.hats pats_typerase_gen_dats.hats \
  pats_trans3_env_gen.hats pats_trans3_env_gen_dats.hats pats_trans3_gen.hats pats_trans3_gen_dats.hats pats_dmacro2_gen.hats pats_dmacro2_gen_dats.hats > /dev/null || exit 1
[ -n "$REUSE" ] || for f in $T/*.sats $T/*.dats $T/*.hats $T/*.cats; do cp $f $W/; done
for m in pats_ccomp_ccompenv pats_ccomp_environ pats_ccomp_caseof pats_ccomp_looping pats_ccomp_trywith pats_ccomp_lazyeval; do cp ${CC1_SRC:-$T}/$m.dats $W/; done
# the modules of phase 1 (from $CC1_P1 when it is not src itself)
P1MODS="pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_d2env pats_ccomp_funlab pats_ccomp_funent pats_ccomp_instrseq pats_ccomp_util pats_ccomp_print pats_ccomp"
[ -n "$REUSE" ] || for m in $P1MODS; do [ -f $P1/$m.dats ] && cp $P1/$m.dats $W/; done
[ -n "$REUSE" ] || for f in pats_ccomp.sats pats_ccomp.spec pats_ccomp_gen.hats pats_ccomp_gen_dats.hats; do [ -f $P1/$f ] && cp $P1/$f $W/; done
cp $L/*.dats $L/*.hats $L/*.c $W/cc1/ 2>/dev/null
for f in s2env2.hats; do cp $L/../$f $W/cc1/; done
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W $*"
MODS="pats_error pats_basics pats_utils pats_global pats_intinf pats_counter pats_stamp pats_errmsg pats_symbol pats_label pats_filename pats_location pats_effect pats_reader pats_lexbuf pats_lexing_token pats_lexing pats_lexing_error pats_lexing_print pats_tokbuf pats_syntax pats_syntax_print pats_staexp1 pats_staexp1_print pats_dynexp1 pats_dynexp1_print pats_avlmap pats_staexp2_sort pats_staexp2 pats_staexp2_scst pats_staexp2_svar pats_staexp2_svvar pats_staexp2_dcon pats_staexp2_hole pats_staexp2_ctxt pats_staexp2_error pats_staexp2_print pats_staexp2_pprint pats_staexp2_sprint pats_staexp2_szexp pats_staexp2_skexp pats_staexp2_util1 pats_staexp2_util2 pats_staexp2_util3 pats_stacst2 pats_staexp2_solve pats_namespace pats_dynexp2 pats_dynexp2_dcst pats_dynexp2_dmac pats_dynexp2_dvar pats_dynexp2_mapgen pats_dynexp2_print pats_dynexp2_util pats_dynexp3 pats_dynexp3_print pats_histaexp pats_histaexp_print pats_histaexp_funlab pats_hidynexp pats_hidynexp_print pats_hidynexp_util"
# the modules under test, and the phase-1 modules that are present
CCMODS="pats_ccomp_ccompenv pats_ccomp_environ pats_ccomp_caseof pats_ccomp_looping pats_ccomp_trywith pats_ccomp_lazyeval"
DBL=cc1_dbl2
for m in pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_d2env pats_ccomp_funlab; do [ -f $W/$m.dats ] || { echo "cc1_2.sh: $m.dats missing (set CC1_P1)"; exit 1; }; CCMODS="$CCMODS $m"; done
REALALL=1; for m in pats_ccomp_funent pats_ccomp_instrseq pats_ccomp_util pats_ccomp_print pats_ccomp; do [ -f $W/$m.dats ] && CCMODS="$CCMODS $m" || REALALL=; done
[ -n "$REALALL" ] && DBL=
# the dynload list of the driver
( echo 'dynload "../pats_histaexp_funlab.dats"'; for m in pats_ccomp pats_ccomp_print pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_d2env pats_ccomp_funlab pats_ccomp_funent pats_ccomp_util pats_ccomp_ccompenv pats_ccomp_instrseq pats_ccomp_caseof pats_ccomp_lazyeval pats_ccomp_trywith pats_ccomp_looping pats_ccomp_environ; do
    case " $CCMODS " in *" $m "*) echo "dynload \"../$m.dats\"";; esac
  done; [ -n "$DBL" ] && echo 'dynload "cc1_dbl2.dats"' ) > $W/cc1/cc1_dyn.hats
cd $W/obj; [ -n "$CC1_ONLY" ] && [ -n "$REUSE" ] || rm -f cc1_*.o
[ -n "$REUSE" ] || patsopt --output pats_error_sats.c --static ../pats_error.sats || exit 1
CHUNKS=`cd $L && ls cc1_chunk_[0-9][0-9].dats | sed 's/\.dats$//'`
# CC1_ONLY (with REUSE): recompile only these modules (the mutation test)
( if [ -n "$CC1_ONLY" ] && [ -n "$REUSE" ]; then for m in $CC1_ONLY; do echo $m; done; else
  [ -n "$REUSE" ] || for m in $MODS; do echo "$m"; done; for m in $CCMODS; do echo $m; done; echo cc1_drv; for c in $CHUNKS; do echo $c; done; [ -n "$DBL" ] && echo $DBL; fi ) | xargs -P ${JOBS:-16} -I{} sh -c "
  case {} in cc1_*) cd ../cc1 && $CC -c -o ../obj/{}.o {}.dats;; *) $CC -c -o {}.o ../{}.dats;; esac || echo FAILED {}" > $OUT/build2.log 2>&1
grep -q FAILED $OUT/build2.log && { cat $OUT/build2.log | head -60; exit 1; }
[ -n "$REUSE" ] || $CC -c -o pats_error_sats.o pats_error_sats.c || exit 1
$CC -c -o cc1_stub.o ../cc1/cc1_stub.c || exit 1
$CC -o $OUT/cc1_2 *.o -lgmp || exit 1
[ -z "$wiped" ] || echo "$cur" > $stamp
