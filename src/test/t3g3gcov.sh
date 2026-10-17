# t3g3gcov.sh: the line coverage (by ATS line, gcov) of the four modules of group 3 of the level-3 translation (pats_trans3_p2at, _selab, _fldfrat, _lvalres)
# by the generated cases. Needs the objects of `make t3g3dump` (t3g3obj/) and PATSHOME/PATH of CLAUDE.md. Usage: sh t3g3gcov.sh [DIR]   (DIR: scratch directory, default /tmp/t3g3cov)
D=${1:-/tmp/t3g3cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
MODS="pats_trans3_p2at pats_trans3_selab pats_trans3_fldfrat pats_trans3_lvalres"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
SKIP=`for m in $MODS; do printf "%s_dats\\\\|" $m; done`
OBJS=`cd $T; ls t3g3obj/*.o | grep -v "${SKIP}NONE" | sed "s|^|$T/|"`
gcc -g --coverage -o t3g3dump_cov $OBJS pats_*_dats.o -lgmp -lm || exit 1
(cd $T && $D/t3g3dump_cov > /dev/null 2> /dev/null)
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
