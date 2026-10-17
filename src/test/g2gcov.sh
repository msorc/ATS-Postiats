# g2gcov.sh: the line coverage (by ATS line, gcov) of pats_trans3_{dynexp_dn,appsym,caseof,patcon} by the cases of the level-3 translation test, group 2.
# Needs the staged build of `make g2dump` (G2STAGE/test/obj/, default /tmp/g2stage) and PATSHOME/PATH of CLAUDE.md. Usage: sh g2gcov.sh [SCRATCHDIR]
D=${1:-/tmp/g2cov}; ST=${G2STAGE:-$(cd .. && pwd)}; P=${PATSHOME:-`pwd`/../..}
MODS="pats_trans3_dynexp_dn pats_trans3_appsym pats_trans3_caseof pats_trans3_patcon"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $ST/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$ST -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
SKIP=`for m in $MODS; do printf "%s_dats\\\\|" $m; done`
OBJS=`ls $ST/test/obj/*.o | grep -v "${SKIP}NONE"`
gcc -g --coverage -o g2dump_cov $OBJS $D/pats_*_dats.o -lgmp -lm || exit 1
(cd $ST/test && $D/g2dump_cov > /dev/null 2> /dev/null)
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
