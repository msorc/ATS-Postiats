# f3gcov.sh: the line coverage (by ATS line, gcov) of the modules of the type checker (pats_trans3*, dynexp3, patcst2, dmacro2) by the files of LIST
# (default: all.txt of f3files, or the cases of t3cases/ through t3list.txt). Needs the objects of `make f3dump` (f3obj/) and PATSHOME/PATH of CLAUDE.md.
# Usage: sh f3gcov.sh [LIST [DIR]]   (DIR: scratch directory, default /tmp/f3cov; the LIST is cut in chunks of 30 run in parallel, JOBS)
LIST=$(readlink -f ${1:-t3list.txt}); D=${2:-/tmp/f3cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
MODS="pats_trans3_env pats_trans3_env_dvar pats_trans3_env_effect pats_trans3_env_lamlp pats_trans3_env_lstate pats_trans3_env_pfman pats_trans3_env_print pats_trans3_env_scst pats_trans3_env_svar pats_trans3_env_termet pats_trans3_error pats_trans3_syncst pats_trans3_util pats_trans3_dynexp_up pats_trans3_dynexp_dn pats_trans3_appsym pats_trans3_caseof pats_trans3_patcon pats_trans3_p2at pats_trans3_selab pats_trans3_fldfrat pats_trans3_lvalres pats_trans3_ptrof pats_trans3_viewat pats_trans3_deref pats_trans3_assgn pats_trans3_xchng pats_trans3_looping pats_trans3_decl pats_dynexp3"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov c_* 
for m in $MODS; do
  echo "patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats && gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || echo FAILED $m"
done | xargs -P ${JOBS:-16} -I{} sh -c "{}"
SKIP=`for m in $MODS; do printf "f3obj/%s_dats.o\\\\|" $m; done`
OBJS=`cd $T; ls f3obj/*.o | grep -v "${SKIP}NONE" | sed "s|^|$T/|"`
gcc -g --coverage -o f3dump_cov $OBJS $D/pats_*_dats.o -lgmp -lm || exit 1
split -l 30 -d -a 4 $LIST $D/c_
(cd $T && ls $D/c_???? | xargs -P ${JOBS:-16} -I{} sh -c "EXTRA=time sh f3chunk.sh $D/f3dump_cov {} {}.2 > /dev/null 2>&1")
for m in $MODS; do
  gcov -o . ${m}_dats.gcda > /dev/null 2>&1
  python3 - $m.dats.gcov <<'PYEOF'
import sys
ex = hit = 0; miss = []
for l in open(sys.argv[1], errors='replace'):
    p = l.split(':', 2)
    if len(p) < 3: continue
    c = p[0].strip(); n = p[1].strip()
    if c == '-' or n == '0': continue
    ex += 1
    if c.startswith('#####') or c.startswith('====='): miss.append(n)
    else: hit += 1
print('%-34s %5d executable lines, %5d covered (%.1f%%); not covered: %s' % (sys.argv[1], ex, hit, 100.0 * hit / ex, ' '.join(miss)))
PYEOF
done
